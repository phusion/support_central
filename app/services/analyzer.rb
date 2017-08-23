class Analyzer
  def analyze(integrate_with_parent_transaction = true)
    begin
      @support_sources = get_support_sources
      @support_source_ids = @support_sources.map { |s| s.id }
      @data_sources = get_data_sources

      if !integrate_with_parent_transaction
        ActiveRecord::Base.clear_active_connections!
      end

      @unanswered_external_tickets = fetch_unanswered_external_tickets
      @unanswered_external_tickets = filter_ignored_external_tickets(
        @unanswered_external_tickets)
      @unanswered_external_tickets_index = index_external_tickets(
        @unanswered_external_tickets)
      @unanswered_external_ticket_ids = @unanswered_external_tickets_index.keys
      deduplicate_external_tickets
      check_external_ticket_ids

      Ticket.transaction do
        synchronize_internal_tickets
      end
    ensure
      if !integrate_with_parent_transaction
        ActiveRecord::Base.clear_active_connections!
      end
    end
  end

protected
  ### Hooks and overridable methods ###

  def support_source_class
    raise NotImplementedError
  end

  def get_support_sources
    support_source_class.all
  end

  def get_data_sources
    @support_sources
  end

  def fetch_unanswered_external_tickets
    raise NotImplementedError
  end

  def filter_unanswered_external_ticket_ids_for_support_source(support_source)
    raise NotImplementedError
  end

  def id_for_external_ticket(external_ticket)
    raise NotImplementedError
  end

  def different_data_sources_see_different_tickets?
    raise NotImplementedError
  end

  def synchronize_internal_ticket(internal_ticket, external_ticket)
    internal_ticket.display_id ||= id_for_external_ticket(external_ticket)
    internal_ticket.external_id ||= id_for_external_ticket(external_ticket)
    internal_ticket.external_last_update_time ||= Time.now
  end

  def support_sources_eligible_for_external_ticket(external_ticket)
    @support_sources
  end

private
  def filter_ignored_external_tickets(external_tickets)
    external_ids = external_tickets.map do |ticket|
      id_for_external_ticket(ticket)
    end

    ignored_external_ids = Set.new(
      IgnoreMarker.
        where(support_source_type: support_source_class.to_s).
        where('external_id IN (?)', external_ids).
        pluck(:external_id))

    external_tickets.find_all do |ticket|
      !ignored_external_ids.include?(id_for_external_ticket(ticket))
    end
  end

  def index_external_tickets(external_tickets)
    index = {}
    external_tickets.each do |ticket|
      id = id_for_external_ticket(ticket)
      index[id] ||= ticket
      index[id][:support_source_ids] ||= Set.new
      index[id][:support_source_ids] << ticket[:support_source_id]
    end
    index
  end

  def deduplicate_external_tickets
    @unanswered_external_tickets = @unanswered_external_tickets_index.values
  end

  def check_external_ticket_ids
    if @unanswered_external_ticket_ids.any? { |id| !id.is_a?(String) }
      raise "Bug in #id_for_external_ticket: it must always return a String"
    end
  end

  def synchronize_internal_tickets
    delete_internal_tickets_for_which_external_ticket_is_answered_or_gone
    update_internal_tickets_based_on_external_tickets
    create_internal_tickets_for_which_external_ticket_is_not_known
  end

  def delete_internal_tickets_for_which_external_ticket_is_answered_or_gone
    if @unanswered_external_tickets.empty?
      Ticket.
        where(support_source_id: @support_source_ids).
        delete_all
    elsif different_support_sources_see_different_tickets?
      @support_sources.each do |support_source|
        unanswered_external_ticket_ids = filter_unanswered_external_ticket_ids_for_support_source(
          support_source)
        if unanswered_external_ticket_ids.empty?
          Ticket.
            where(support_source_id: support_source.id).
            delete_all
        else
          Ticket.
            where(support_source_id: support_source.id).
            where('external_id NOT IN (?)', unanswered_external_ticket_ids).
            delete_all
        end
      end
    else
      Ticket.
        where(support_source_id: @support_source_ids).
        where('external_id NOT IN (?)', @unanswered_external_ticket_ids).
        delete_all
    end
  end

  def update_internal_tickets_based_on_external_tickets
    @internal_tickets = Ticket.where(support_source_id: @support_source_ids).all
    @internal_tickets.each do |internal_ticket|
      external_ticket = @unanswered_external_tickets_index[
        internal_ticket.external_id]
      synchronize_internal_ticket(internal_ticket, external_ticket)
      internal_ticket.save!
    end
  end

  def create_internal_tickets_for_which_external_ticket_is_not_known
    if @unanswered_external_tickets.empty?
      return
    end

    # We want to find the IDs of unanswered external tickets for which
    # not all our support sources have a corresponding internal ticket.
    #
    # While we're at it, create a set of
    # [internal_ticket_id, corresponding_support_source_id]
    # which will be used in the next step.
    external_tickets_and_support_sources = {}
    new_external_ticket_ids = []
    external_tickets_and_support_sources_count = {}
    @internal_tickets.each do |internal_ticket|
      external_tickets_and_support_sources_count[internal_ticket.external_id] ||= 0
      external_tickets_and_support_sources_count[internal_ticket.external_id] += 1
      set_key = [internal_ticket.external_id, internal_ticket.support_source_id]
      external_tickets_and_support_sources[set_key] = true
    end
    @unanswered_external_tickets_index.each_pair do |external_id, external_ticket|
      count = external_tickets_and_support_sources_count[external_id] || 0
      if count != @support_sources.size
        new_external_ticket_ids << external_id
      end
    end

    # Create internal tickets for the unanswered externals tickets
    # related to the IDs we just found, if one does not already exist.
    new_external_ticket_ids.each do |external_ticket_id|
      external_ticket = @unanswered_external_tickets_index[external_ticket_id]
      support_sources = support_sources_eligible_for_external_ticket(external_ticket)
      support_sources.each do |support_source|
        set_key = [external_ticket_id, support_source.id]
        if !external_tickets_and_support_sources[set_key]
          internal_ticket = support_source.tickets.build
          internal_ticket.external_id = id_for_external_ticket(external_ticket)
          synchronize_internal_ticket(internal_ticket, external_ticket)
          internal_ticket.save!
        end
      end
    end
  end

  def sql_select_values(*args)
    ActiveRecord::Base.connection.select_values(*args)
  end

  def sql_quote(data)
    if data.is_a?(Array)
      data.map { |s| sql_quote(s) }.join(',')
    else
      ActiveRecord::Base.connection.quote(data)
    end
  end
end
