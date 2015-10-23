require 'spec_helper'

describe GithubAnalyzer do
  let(:api_endpoint) { 'https://api.github.com/repos/phusion/passenger/issues?labels=Unanswered&per_page=100&state=all' }

  def create_dependencies
    @user = create(:user)
    @github = create(:github_passenger, user: @user)
  end

  def create_tickets(support_source)
    @passenger_crash_monday = create(:passenger_crash_monday,
      support_source: support_source)
    @ruby_5_0_not_supported = create(:ruby_5_0_not_supported,
      support_source: support_source)
    @npm_package_needed = create(:npm_package_needed,
      support_source: support_source)
    @off_by_one_bug = create(:off_by_one_bug,
      support_source: support_source)
    @apache_uploads_fail = create(:apache_uploads_fail,
      support_source: support_source)
    @support_ubuntu_2020 = create(:support_ubuntu_2020,
      support_source: support_source)
  end

  def ticket_to_json(ticket)
    {
      'id' => ticket.id,
      'number' => ticket.external_id.to_i,
      'title' => ticket.title
    }
  end

  def tickets_to_json(*tickets)
    tickets.flatten.map do |ticket|
      ticket_to_json(ticket)
    end
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

    stubbed_body = tickets_to_json(@ruby_5_0_not_supported, @npm_package_needed)
    stub_request(:get, api_endpoint).
      to_return(status: 200, headers: { 'Content-Type': 'application/json' },
        body: stubbed_body.to_json)

    GithubAnalyzer.new.analyze

    expect(Ticket.count).to eq(2)
    expect(Ticket.exists?(@passenger_crash_monday.id)).to be_falsey
    expect(Ticket.exists?(@ruby_5_0_not_supported.id)).to be_truthy
    expect(Ticket.exists?(@npm_package_needed.id)).to be_truthy
    expect(Ticket.exists?(@off_by_one_bug.id)).to be_falsey
  end

  it 'deletes all tickets if there are no unanswered issues' do
    create_dependencies
    @passenger_crash_monday = create(:passenger_crash_monday,
      support_source: @github)
    @ruby_5_0_not_supported = create(:ruby_5_0_not_supported,
      support_source: @github)
    @npm_package_needed = create(:npm_package_needed,
      support_source: @github)
    @off_by_one_bug = create(:off_by_one_bug,
      support_source: @github)

    stub_request(:get, api_endpoint).
      to_return(status: 200, headers: { 'Content-Type': 'application/json' },
        body: '[]')

    GithubAnalyzer.new.analyze

    expect(Ticket.count).to eq(0)
  end

  it 'creates tickets for unanswered issues for which we do not have tickets yet' do
    create_dependencies
    @passenger_crash_monday = create(:passenger_crash_monday,
      support_source: @github)

    stubbed_body = tickets_to_json(@passenger_crash_monday) + [
      {
        'id' => 1,
        'number' => 1,
        'title' => 'New ticket 1'
      },
      {
        'id' => 2,
        'number' => 2,
        'title' => 'New ticket 2'
      }
    ]
    stub_request(:get, api_endpoint).
      to_return(status: 200, headers: { 'Content-Type': 'application/json' },
        body: stubbed_body.to_json)

    GithubAnalyzer.new.analyze

    expect(Ticket.count).to eq(3)
    expect(Ticket.exists?(@passenger_crash_monday.id)).to be_truthy

    ticket1 = Ticket.where(external_id: '1').first
    expect(ticket1.title).to eq('New ticket 1')

    ticket2 = Ticket.where(external_id: '2').first
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

    stubbed_body = tickets_to_json(@passenger_crash_monday,
      @ruby_5_0_not_supported, @npm_package_needed,
      @off_by_one_bug)
    stub_request(:get, api_endpoint).
      to_return(status: 200, headers: { 'Content-Type': 'application/json' },
        body: stubbed_body.to_json)

    GithubAnalyzer.new.analyze

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

    stub_request(:get, api_endpoint).
      to_return(status: 200, headers: { 'Content-Type': 'application/json' },
        body: '[]')

    GithubAnalyzer.new.analyze

    expect(Ticket.count).to eq(2)
    expect(Ticket.exists?(@passenger_crash_monday.id)).to be_truthy
    expect(Ticket.exists?(@ruby_5_0_not_supported.id)).to be_falsey
    expect(Ticket.exists?(@npm_package_needed.id)).to be_truthy
    expect(Ticket.exists?(@off_by_one_bug.id)).to be_falsey
  end
end
