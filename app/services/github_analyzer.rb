class GithubAnalyzer < Analyzer
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
      result.concat(@octokit.issues(data_source.owner_and_repo,
        state: 'all', labels: 'Unanswered'))
    end
    result
  end

  def id_for_external_ticket(external_ticket)
    external_ticket.html_url.sub(%r{^https://github.com/}, '')
  end

  def title_for_external_ticket(external_ticket)
    external_ticket.title
  end
end
