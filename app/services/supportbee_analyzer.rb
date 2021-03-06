class SupportbeeAnalyzer < Analyzer
  DataSource = Struct.new(:company_id, :auth_token, :support_source_id)

protected
  def support_source_class
    SupportbeeSupportSource
  end

  def get_data_sources
    result = {}
    @support_sources.each do |source|
      key = [source.supportbee_company_id, source.supportbee_auth_token]
      result[key] ||= DataSource.new(source.supportbee_company_id,
        source.supportbee_auth_token,
        source.id)
    end
    result.values
  end

  def fetch_unanswered_external_tickets
    result = []
    @data_sources.each do |source|
      client = Supportbee::Client.new(company: source.company_id,
        auth_token: source.auth_token)
      result.concat(query_unanswered_tickets(source.support_source_id,
        client, assigned_user: 'none', assigned_team: 'none'))
      result.concat(query_unanswered_tickets(source.support_source_id,
        client, assigned_user: 'me'))
      result.concat(query_unanswered_tickets(source.support_source_id,
        client, assigned_team: 'mine'))
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

    labels = external_ticket['labels'].map { |l| l['name'] }
    if labels.include?('overdue')
      internal_ticket.status = 'overdue'
    elsif labels.include?('respond now')
      internal_ticket.status = 'respond_now'
    else
      internal_ticket.status = 'normal'
    end

    internal_ticket.labels = external_ticket['labels'].map do |label|
      label['name']
    end
    internal_ticket.labels.delete('overdue')
    internal_ticket.labels.delete('respond now')

    internal_ticket.external_last_update_time =
      Time.parse(external_ticket['last_activity_at'])
  end

  def support_sources_eligible_for_external_ticket(external_ticket)
    assignee = external_ticket['current_team_assignee']
    if assignee
      if assignee['user']
        user_id = assignee['user']['id']
        @support_sources.find_all do |support_source|
          support_source.supportbee_user_id == user_id
        end
      else
        team_id = assignee['team']['id'].to_s
        @support_sources.find_all do |support_source|
          support_source.supportbee_group_ids.include?(team_id)
        end
      end
    else
      @support_sources
    end
  end

private
  def query_unanswered_tickets(support_source_id, client, options)
    result = client.tickets(options).find_all do |external_ticket|
      external_ticket['unanswered']
    end
    result.each do |external_ticket|
      external_ticket[:support_source_id] = support_source_id
    end
    result
  end
end
