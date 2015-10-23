class GithubAnalyzer < Analyzer
  class Error < StandardError
  end

  def initialize
    @octokit = Octokit::Client.new(:access_token => CONFIG['github_api_token'])
    @octokit.auto_paginate = true
  end

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
    sources.each do |source|
      issues = fetch_unanswered_issues_from(source)
      result.concat(issues)
    end
    result
  end

  def fetch_unanswered_issues_from(source)
    @octokit.issues(source.github_owner_and_repo,
      state: 'all', labels: 'Unanswered')
  end

  def synchronize_tickets(sources, unanswered_issues)
    support_source_ids = sources.map { |source| source.id }
    unanswered_issue_numbers = unanswered_issues.
      map { |issue| issue.number.to_i.to_s }

    # Delete all tickets for which the corresponding issue has already
    # been answered
    if unanswered_issue_numbers.empty?
      Ticket.
        where(support_source_id: support_source_ids).
        delete_all
    else
      Ticket.
        where(support_source_id: support_source_ids).
        where('external_id NOT IN (?)', unanswered_issue_numbers).
        delete_all
    end

    # Find the numbers of unanswered issues for which we don't have
    # tickets yet
    if unanswered_issue_numbers.empty?
      new_numbers = []
    else
      new_numbers = ActiveRecord::Base.connection.select_values(%Q{
        SELECT UNNEST(ARRAY[%s])
        EXCEPT (SELECT external_id FROM tickets
          WHERE support_source_id IN (%s))
      } % [
        quote_array(unanswered_issue_numbers),
        quote_array(support_source_ids)
      ])
    end

    # Create tickets for unanswered issues for which we don't have
    # tickets yet
    unanswered_issues_index = {}
    unanswered_issues.each do |issue|
      unanswered_issues_index[issue.number] = issue
    end
    new_numbers.each do |number|
      number = number.to_i
      issue = unanswered_issues_index[number]
      sources.each do |source|
        source.tickets.create!(title: issue.title,
          external_id: issue.number)
      end
    end
  end

  def quote_array(array)
    array.map { |s| ActiveRecord::Base.connection.quote(s) }.join(',')
  end
end
