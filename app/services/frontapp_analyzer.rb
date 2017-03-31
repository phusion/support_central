class FrontappAnalyzer < Analyzer
  DataSource = Struct.new(:auth_token, :inboxes, :support_source_id)

protected
  def support_source_class
    FrontappSupportSource
  end

  def get_data_sources
    data_sources = {}
    @support_sources.each do |support_source|
      key = [support_source.frontapp_user_id, support_source.frontapp_auth_token]
      data_sources[key] ||= DataSource.new(support_source.frontapp_auth_token,
        support_source.frontapp_inbox_ids, support_source.id)
    end
    data_sources.values
  end

  def fetch_unanswered_external_tickets
    result = []
    @data_sources.each do |source|
      client = Frontapp::Client.new(auth_token: source.auth_token)
      result.concat(query_unanswered_tickets(source,
        client, { q: { statuses: ["unassigned", "assigned"] } }))
    end
    result
  end

  def filter_unanswered_external_ticket_ids_for_support_source(support_source)
    @unanswered_external_tickets.find_all do |external_ticket|
      external_ticket[:support_source_id] == support_source.id
    end.map do |external_ticket|
      id_for_external_ticket(external_ticket)
    end
  end

  def id_for_external_ticket(external_ticket)
    external_ticket['id'].to_s
  end

  def different_support_sources_see_different_tickets?
    true
  end

  def synchronize_internal_ticket(internal_ticket, external_ticket)
    super

    internal_ticket.title = external_ticket['subject']

    tags = external_ticket['tags'].map { |l| l['name'] }
    if tags.include?('Overdue')
      internal_ticket.status = 'overdue'
    elsif tags.include?('Respond Now')
      internal_ticket.status = 'respond_now'
    else
      internal_ticket.status = 'normal'
    end

    internal_ticket.labels = external_ticket['tags'].map do |label|
      label['name']
    end
    internal_ticket.labels.delete('Overdue')
    internal_ticket.labels.delete('Respond Now')

    internal_ticket.external_last_update_time =
      Time.at(external_ticket['last_message']['created_at'])
  end

  def support_sources_eligible_for_external_ticket(external_ticket)
    @support_sources.find_all {|s| external_ticket[:support_source_ids].include?(s.id)}
  end

private
  def query_unanswered_tickets(source, client, options)
    result = []
    source.inboxes.each do |inbox|
      result.concat(client.get_inbox_conversations(inbox, options))
    end
    result.each do |external_ticket|
      external_ticket[:support_source_id] = source.support_source_id
    end
    result
  end
end
