require 'spec_helper'

describe GithubAnalyzer do
  def create_tickets_and_dependent_objects
    @user = create(:user)
    @github = create(:github_passenger, user: @user)
    create_tickets(@github)
  end

  def create_tickets(support_source)
    @tickets = []
    9.times do |i|
      @tickets << Ticket.create!(
        title: "Random ticket #{i}",
        external_id: "#{i}",
        support_source: support_source)
    end
  end

  it 'deletes tickets for which the corresponding issue has already been answered' do
    create_tickets_and_dependent_objects
    GithubAnalyzer.new.analyze
    pending
  end

  it 'creates tickets for unaswered issues for which we do not have tickets yet'
  it 'does not touch existing tickets for unanswered issues'
  it 'does not touch tickets not belonging to GithubSupportSource'
end
