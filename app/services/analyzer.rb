class Analyzer
  def analyze
    @support_sources = get_support_sources
    @support_source_ids = @support_sources.map { |s| s.id }
    @data_sources = get_data_sources

    @unanswered_external_tickets = fetch_unanswered_external_tickets
    @unanswered_external_tickets_index = index_external_tickets(
      @unanswered_external_tickets)
    @unanswered_external_ticket_ids = @unanswered_external_tickets_index.keys
    deduplicate_external_tickets
    check_external_ticket_ids

    Ticket.transaction do
      synchronize_internal_tickets
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

  def id_for_external_ticket(external_ticket)
    raise NotImplementedError
  end

  def title_for_external_ticket(external_ticket)
    raise NotImplementedError
  end

  def support_sources_eligible_for_external_ticket(external_ticket)
    @support_sources
  end

private
  def index_external_tickets(external_tickets)
    index = {}
    external_tickets.each do |ticket|
      index[id_for_external_ticket(ticket)] = ticket
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
    delete_internal_tickets_for_which_external_ticket_is_answered
    create_internal_tickets_for_which_external_ticket_is_not_known
    update_internal_tickets_based_on_external_tickets
  end

  def delete_internal_tickets_for_which_external_ticket_is_answered
    if @unanswered_external_tickets.empty?
      Ticket.
        where(support_source_id: @support_source_ids).
        delete_all
    else
      Ticket.
        where(support_source_id: @support_source_ids).
        where('external_id NOT IN (?)', @unanswered_external_ticket_ids).
        delete_all
    end
  end

  def create_internal_tickets_for_which_external_ticket_is_not_known
    # Find the IDs of unanswered external tickets for which we
    # don't have internal tickets yet
    if @unanswered_external_tickets.empty?
      new_external_ticket_ids = []
    else
      new_external_ticket_ids = sql_select_values(%Q{
        SELECT UNNEST(ARRAY[%s])
        EXCEPT (SELECT external_id FROM tickets
          WHERE support_source_id IN (%s))
      } % [
        sql_quote(@unanswered_external_ticket_ids),
        sql_quote(@support_source_ids)
      ])
    end

    # Create internal tickets for the unanswered externals tickets
    # related to the IDs we just found
    new_external_ticket_ids.each do |external_ticket_id|
      external_ticket = @unanswered_external_tickets_index[external_ticket_id]
      support_sources = support_sources_eligible_for_external_ticket(external_ticket)
      support_sources.each do |support_source|
        support_source.tickets.create!(
          title: title_for_external_ticket(external_ticket),
          external_id: id_for_external_ticket(external_ticket)
        )
      end
    end
  end

  def update_internal_tickets_based_on_external_tickets
    # TODO
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
