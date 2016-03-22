require 'uri'

class GithubAnalyzer < Analyzer
  UNANSWERED_LABEL = 'SupportCentral'

  DataSource = Struct.new(:owner_and_repo)

  def initialize
    @octokit = Octokit::Client.new(:access_token => CONFIG['github_api_token'])
    @octokit.auto_paginate = true
  end

protected
  def support_source_class
    GithubSupportSource
  end

  def get_data_sources
    data_sources = {}
    @support_sources.each do |support_source|
      key = support_source.github_owner_and_repo
      data_sources[key] ||= DataSource.new(support_source.github_owner_and_repo)
    end
    data_sources.values
  end

  def fetch_unanswered_external_tickets
    result = []
    @data_sources.each do |data_source|
      result.concat(@octokit.list_issues(data_source.owner_and_repo,
        state: 'all', labels: UNANSWERED_LABEL))
    end
    result
  end

  def id_for_external_ticket(external_ticket)
    external_ticket.html_url.sub(%r{^https://github.com/}, '')
  end

  def different_support_sources_see_different_tickets?
    false
  end

  def synchronize_internal_ticket(internal_ticket, external_ticket)
    super

    repo_full_name = extract_repo_full_name(external_ticket.html_url)

    internal_ticket.title = external_ticket.title
    internal_ticket.display_id = "#{repo_full_name} ##{external_ticket.number}"

    comments = @octokit.issue_comments(repo_full_name,
      external_ticket.number)
    if comments.last
      internal_ticket.external_last_update_time = comments.last.created_at
    end
  end

  def support_sources_eligible_for_external_ticket(external_ticket)
    repo_full_name = extract_repo_full_name(external_ticket.html_url)
    @support_sources.find_all do |support_source|
      support_source.github_owner_and_repo == repo_full_name
    end
  end

private
  def extract_repo_full_name(issue_html_url)
    URI.parse(issue_html_url).path.
      sub(/^\//, '').
      sub(%r{(.+)/issues/.*}, '\1')
  end
end
