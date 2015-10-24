require 'rails_helper'
require 'time'

describe GithubAnalyzer do
  let(:issue1_first_comment_date) { '2015-10-24T16:00:49Z' }
  let(:issue1_last_comment_date) { '2015-10-25T09:00:12Z' }
  let(:issue1_comments) do
    [
      {
        id: 1,
        body: 'me too',
        created_at: issue1_first_comment_date,
        updated_at: issue1_first_comment_date
      },
      {
        id: 2,
        body: 'me too',
        created_at: '2015-10-24T16:05:49Z',
        updated_at: '2015-10-24T16:05:49Z'
      },
      {
        id: 3,
        body: 'me too',
        created_at: issue1_last_comment_date,
        updated_at: issue1_last_comment_date
      }
    ]
  end

  let(:issue2_first_comment_date) { '2015-09-24T16:00:49Z' }
  let(:issue2_last_comment_date) { '2015-09-25T09:00:12Z' }
  let(:issue2_comments) do
    [
      {
        id: 11,
        body: 'me too',
        created_at: issue2_first_comment_date,
        updated_at: issue2_first_comment_date
      },
      {
        id: 12,
        body: 'me too',
        created_at: '2015-09-24T16:05:49Z',
        updated_at: '2015-09-24T16:05:49Z'
      },
      {
        id: 13,
        body: 'me too',
        created_at: issue2_last_comment_date,
        updated_at: issue2_last_comment_date
      }
    ]
  end

  let(:issue3_first_comment_date) { '2015-08-24T16:00:49Z' }
  let(:issue3_last_comment_date) { '2015-08-25T09:00:12Z' }
  let(:issue3_comments) do
    [
      {
        id: 11,
        body: 'me too',
        created_at: issue3_first_comment_date,
        updated_at: issue3_first_comment_date
      },
      {
        id: 12,
        body: 'me too',
        created_at: '2015-08-24T16:05:49Z',
        updated_at: '2015-08-24T16:05:49Z'
      },
      {
        id: 13,
        body: 'me too',
        created_at: issue3_last_comment_date,
        updated_at: issue3_last_comment_date
      }
    ]
  end

  def create_dependencies
    @user = create(:user)
    @github = create(:github_passenger, user: @user)
  end

  def stub_github_issues_request(body)
    if !body.is_a?(String)
      body = body.to_json
    end
    url = 'https://api.github.com/repos/phusion/passenger/issues?' \
      'labels=Unanswered&per_page=100&state=all'
    stub_request(:get, url).
      to_return(status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: body)
  end

  def stub_github_comments_request(issue_path, body)
    if !body.is_a?(String)
      body = body.to_json
    end
    url = "https://api.github.com/repos/#{issue_path}/comments?per_page=100"
    stub_request(:get, url).
      to_return(status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: body)
  end

  def ticket_as_json(ticket)
    ticket.external_id =~ /(\d+)$/
    result = {
      id: ticket.id,
      number: $1.to_i,
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

    stub1 = stub_github_issues_request([
      ticket_as_json(@ruby_5_0_not_supported),
      ticket_as_json(@npm_package_needed)
    ])
    stub2 = stub_github_comments_request(
      @ruby_5_0_not_supported.external_id,
      issue1_comments)
    stub3 = stub_github_comments_request(
      @npm_package_needed.external_id,
      issue2_comments)

    GithubAnalyzer.new.analyze

    assert_requested(stub1)
    assert_requested(stub2)
    assert_requested(stub3)
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

    stub = stub_github_issues_request([])

    GithubAnalyzer.new.analyze

    assert_requested(stub)
    expect(Ticket.count).to eq(0)
  end

  it 'creates tickets for not-seen-before unanswered issues' do
    create_dependencies
    @passenger_crash_monday = create(:passenger_crash_monday,
      support_source: @github)

    stub1 = stub_github_issues_request([
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
    stub2 = stub_github_comments_request(
      @passenger_crash_monday.external_id,
      issue1_comments)
    stub3 = stub_github_comments_request(
      'phusion/passenger/issues/1',
      issue2_comments)
    stub4 = stub_github_comments_request(
      'phusion/passenger/issues/2',
      issue3_comments)

    GithubAnalyzer.new.analyze

    assert_requested(stub1)
    assert_requested(stub2)
    assert_requested(stub3)
    assert_requested(stub4)

    expect(Ticket.count).to eq(3)
    expect(Ticket.exists?(@passenger_crash_monday.id)).to be_truthy
    @passenger_crash_monday.reload
    expect(@passenger_crash_monday.external_last_update_time).to \
      eq(Time.parse(issue1_last_comment_date))

    ticket1 = Ticket.where(external_id: 'phusion/passenger/issues/1').first
    expect(ticket1).not_to be_nil
    expect(ticket1.title).to eq('New ticket 1')
    expect(ticket1.external_last_update_time).to \
      eq(Time.parse(issue2_last_comment_date))

    ticket2 = Ticket.where(external_id: 'phusion/passenger/issues/2').first
    expect(ticket2).not_to be_nil
    expect(ticket2.title).to eq('New ticket 2')
    expect(ticket2.external_last_update_time).to \
      eq(Time.parse(issue3_last_comment_date))
  end

  it "updates the times and titles of tickets to the corresponding " \
     "issues' titles and last comment dates" \
  do
    create_dependencies
    @passenger_crash_monday = create(:passenger_crash_monday,
      support_source: @github)
    @ruby_5_0_not_supported = create(:ruby_5_0_not_supported,
      support_source: @github)
    @npm_package_needed = create(:npm_package_needed,
      support_source: @github)

    stub1 = stub_github_issues_request([
      ticket_as_json(@passenger_crash_monday).merge(title: 'ticket 1'),
      ticket_as_json(@ruby_5_0_not_supported).merge(title: 'ticket 2'),
      ticket_as_json(@npm_package_needed).merge(title: 'ticket 3')
    ])
    stub2 = stub_github_comments_request(
      @passenger_crash_monday.external_id,
      issue1_comments)
    stub3 = stub_github_comments_request(
      @ruby_5_0_not_supported.external_id,
      issue2_comments)
    stub4 = stub_github_comments_request(
      @npm_package_needed.external_id,
      issue3_comments)

    GithubAnalyzer.new.analyze

    assert_requested(stub1)
    assert_requested(stub2)
    assert_requested(stub3)
    assert_requested(stub4)

    expect(Ticket.count).to eq(3)
    expect(Ticket.exists?(@passenger_crash_monday.id)).to be_truthy
    expect(Ticket.exists?(@ruby_5_0_not_supported.id)).to be_truthy
    expect(Ticket.exists?(@npm_package_needed.id)).to be_truthy

    @passenger_crash_monday.reload
    expect(@passenger_crash_monday.title).to eq('ticket 1')
    expect(@passenger_crash_monday.external_last_update_time).to \
      eq(Time.parse(issue1_last_comment_date))

    @ruby_5_0_not_supported.reload
    expect(@ruby_5_0_not_supported.title).to eq('ticket 2')
    expect(@ruby_5_0_not_supported.external_last_update_time).to \
      eq(Time.parse(issue2_last_comment_date))

    @npm_package_needed.reload
    expect(@npm_package_needed.title).to eq('ticket 3')
    expect(@npm_package_needed.external_last_update_time).to \
      eq(Time.parse(issue3_last_comment_date))
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

    stub = stub_github_issues_request([])

    GithubAnalyzer.new.analyze

    assert_requested(stub)
    expect(Ticket.count).to eq(2)
    expect(Ticket.exists?(@passenger_crash_monday.id)).to be_truthy
    expect(Ticket.exists?(@ruby_5_0_not_supported.id)).to be_falsey
    expect(Ticket.exists?(@npm_package_needed.id)).to be_truthy
    expect(Ticket.exists?(@off_by_one_bug.id)).to be_falsey
  end
end
