class GithubAnalyzer < Analyzer
  def analyze
    Ticket.transaction do
      sources = GithubSupportSource.all
      issues = fetch_unanswered_issues(sources)
      synchronize_tickets(sources, issues)
    end
  end

private
  def fetch_unanswered_issues(sources)
    result = []
    determine_api_endpoints(sources).each do |url|
      make_request(url)
      issues.each do |issue|
        if issue['labels'].include?('Unanswered')
          result << issue
        end
      end
    end
    result
  end

  def determine_api_endpoints(sources)
    sources.map do |source|
      issues_api_url(source)
    end
  end

  def issues_api_url(source)
    "https://api.github.com/repos/#{source.github_owner_and_repo}/issues"
  end

  def synchronize_tickets(sources, unanswered_issues)
    support_source_ids = sources.map { |source| source.id }
    unanswered_issue_ids = unanswered_issues.
      map { |issue| issue['id'].to_i.to_s }

    # Delete all tickets for which the corresponding issue has already
    # been answered
    Ticket.
      where(support_source_id: support_source_ids).
      where('external_id NOT IN (?)', unanswered_issue_ids).
      delete_all

    # Find IDs of unaswered issues for which we don't have tickets yet
    new_ids = ActiveRecord::Base.connection.select_values(%Q{
      SELECT UNNEST(ARRAY#{unanswered_issue_ids.inspect})
      EXCEPT (SELECT external_id FROM tickets
        WHERE support_source_id IN (#{support_source_ids.inspect}))
    })

    # Create tickets for unanswered issues for which we don't have
    # tickets yet
    new_ids.each do ||
    end
  end
end
