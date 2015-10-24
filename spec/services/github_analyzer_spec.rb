require 'rails_helper'

describe GithubAnalyzer do
  let(:api_endpoint) { 'https://api.github.com/repos/phusion/passenger/issues?labels=Unanswered&per_page=100&state=all' }

  def create_dependencies
    @user = create(:user)
    @github = create(:github_passenger, user: @user)
  end

  def stub_github_request(body)
    if !body.is_a?(String)
      body = body.to_json
    end
    stub_request(:get, api_endpoint).
      to_return(status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: body)
  end

  def ticket_as_json(ticket)
    result = {
      id: ticket.id,
      number: ticket.external_id.to_i,
      title: ticket.title,
      html_url: "https://github.com/#{ticket.external_id}",
      labels: [ { name: 'Unanswered' } ]
    }
    result
  end

  it 'deletes tickets for which the corresponding issue has already been answered' do
    create_dependencies
    @passenger_crash_monday = create(:passenger_crash_monday,
      support_source: @github)
    @ruby_5_0_not_supported = create(:ruby_5_0_not_supported,
      support_source: @github)
    @npm_package_needed = create(:npm_package_needed,
      support_source: @github)
    @off_by_one_bug = create(:off_by_one_bug,
      support_source: @github)

    stub = stub_github_request([
      ticket_as_json(@ruby_5_0_not_supported),
      ticket_as_json(@npm_package_needed)
    ])

    GithubAnalyzer.new.analyze

    assert_requested(stub)
    expect(Ticket.count).to eq(2)
    expect(Ticket.exists?(@passenger_crash_monday.id)).to be_falsey
    expect(Ticket.exists?(@ruby_5_0_not_supported.id)).to be_truthy
    expect(Ticket.exists?(@npm_package_needed.id)).to be_truthy
    expect(Ticket.exists?(@off_by_one_bug.id)).to be_falsey
  end

  it 'deletes all tickets if there are no unanswered issues' do
    create_dependencies
    create(:passenger_crash_monday,
      support_source: @github)
    create(:ruby_5_0_not_supported,
      support_source: @github)
    create(:npm_package_needed,
      support_source: @github)

    stub = stub_github_request([])

    GithubAnalyzer.new.analyze

    assert_requested(stub)
    expect(Ticket.count).to eq(0)
  end

  it 'creates tickets for not-seen-before unanswered issues' do
    create_dependencies
    @passenger_crash_monday = create(:passenger_crash_monday,
      support_source: @github)

    stub = stub_github_request([
      ticket_as_json(@passenger_crash_monday),
      {
        id: 1,
        number: 1,
        title: 'New ticket 1',
        html_url: 'https://github.com/phusion/passenger/issues/1',
        labels: [ { name: 'Unanswered' } ]
      },
      {
        id: 2,
        number: 2,
        title: 'New ticket 2',
        html_url: 'https://github.com/phusion/passenger/issues/2',
        labels: [ { name: 'Unanswered' } ]
      }
    ])

    GithubAnalyzer.new.analyze

    assert_requested(stub)
    expect(Ticket.count).to eq(3)
    expect(Ticket.exists?(@passenger_crash_monday.id)).to be_truthy

    ticket1 = Ticket.where(external_id: 'phusion/passenger/issues/1').first
    expect(ticket1).not_to be_nil
    expect(ticket1.title).to eq('New ticket 1')

    ticket2 = Ticket.where(external_id: 'phusion/passenger/issues/2').first
    expect(ticket2).not_to be_nil
    expect(ticket2.title).to eq('New ticket 2')
  end

  it 'does not touch existing tickets for unanswered issues' do
    create_dependencies
    @passenger_crash_monday = create(:passenger_crash_monday,
      support_source: @github)
    @ruby_5_0_not_supported = create(:ruby_5_0_not_supported,
      support_source: @github)
    @npm_package_needed = create(:npm_package_needed,
      support_source: @github)
    @off_by_one_bug = create(:off_by_one_bug,
      support_source: @github)

    stub = stub_github_request([
      ticket_as_json(@passenger_crash_monday),
      ticket_as_json(@ruby_5_0_not_supported),
      ticket_as_json(@npm_package_needed),
      ticket_as_json(@off_by_one_bug)
    ])

    GithubAnalyzer.new.analyze

    assert_requested(stub)
    expect(Ticket.count).to eq(4)
    expect(Ticket.exists?(@passenger_crash_monday.id)).to be_truthy
    expect(Ticket.exists?(@ruby_5_0_not_supported.id)).to be_truthy
    expect(Ticket.exists?(@npm_package_needed.id)).to be_truthy
    expect(Ticket.exists?(@off_by_one_bug.id)).to be_truthy
  end

  it 'does not touch tickets not belonging to GithubSupportSource' do
    create_dependencies
    @supportbee = create(:supportbee, user: @user)
    @passenger_crash_monday = create(:passenger_crash_monday,
      support_source: @supportbee)
    @ruby_5_0_not_supported = create(:ruby_5_0_not_supported,
      support_source: @github)
    @npm_package_needed = create(:npm_package_needed,
      support_source: @supportbee)
    @off_by_one_bug = create(:off_by_one_bug,
      support_source: @github)

    stub = stub_github_request([])

    GithubAnalyzer.new.analyze

    assert_requested(stub)
    expect(Ticket.count).to eq(2)
    expect(Ticket.exists?(@passenger_crash_monday.id)).to be_truthy
    expect(Ticket.exists?(@ruby_5_0_not_supported.id)).to be_falsey
    expect(Ticket.exists?(@npm_package_needed.id)).to be_truthy
    expect(Ticket.exists?(@off_by_one_bug.id)).to be_falsey
  end
end
