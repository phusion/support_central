require 'spec_helper'

describe SupportbeeAnalyzer do
  def create_dependencies
    @user = create(:user)
    @supportbee = create(:supportbee, user: @user)
  end

  def stub_supportbee_request(assignment, body, auth_token = 1234)
    url = "https://phusion.supportbee.com/tickets.json?archived=false&#{assignment}&auth_token=#{auth_token}&page=1&spam=false&trash=false"
    stub_request(:get, url).
      to_return(status: 200, headers: { 'Content-Type': 'application/json' },
        body: body)
  end

  def ticket_as_json(ticket)
    if !ticket.is_a?(Hash)
      ticket = {
        'id' => ticket.external_id.to_i,
        'subject' => ticket.title
      }
    end
    ticket['unanswered'] = true
    ticket['archived'] = false
    ticket['spam'] = false
    ticket['trash'] = false
    ticket
  end

  def tickets_as_json(*tickets)
    tickets = tickets.flatten.map do |ticket|
      ticket_as_json(ticket)
    end
    {
      'total' => tickets.size,
      'current_page' => 1,
      'per_page' => 50,
      'total_pages' => 1,
      'tickets' => tickets
    }
  end

  context 'when there is one user' do
    it 'deletes internal tickets for which the corresponding Supportbee ticket has already been answered' do
      create_dependencies
      @passenger_crash_monday = create(:passenger_crash_monday,
        support_source: @supportbee)
      @ruby_5_0_not_supported = create(:ruby_5_0_not_supported,
        support_source: @supportbee)
      @npm_package_needed = create(:npm_package_needed,
        support_source: @supportbee)
      @off_by_one_bug = create(:off_by_one_bug,
        support_source: @supportbee)
      @apache_uploads_fail = create(:apache_uploads_fail,
        support_source: @supportbee)

      stub_request(:get, api_endpoint_none_assigned).
        to_return(status: 200, headers: { 'Content-Type': 'application/json' },
          body: tickets_as_json(@ruby_5_0_not_supported).to_json)
      stub_request(:get, api_endpoint_me_assigned).
        to_return(status: 200, headers: { 'Content-Type': 'application/json' },
          body: tickets_as_json(@npm_package_needed).to_json)
      stub_request(:get, api_endpoint_my_groups_assigned).
        to_return(status: 200, headers: { 'Content-Type': 'application/json' },
          body: tickets_as_json(@off_by_one_bug).to_json)

      SupportbeeAnalyzer.new.analyze

      expect(Ticket.count).to eq(3)
      expect(Ticket.exists?(@passenger_crash_monday.id)).to be_falsey
      expect(Ticket.exists?(@ruby_5_0_not_supported.id)).to be_truthy
      expect(Ticket.exists?(@npm_package_needed.id)).to be_truthy
      expect(Ticket.exists?(@off_by_one_bug.id)).to be_truthy
      expect(Ticket.exists?(@apache_uploads_fail.id)).to be_falsey
    end

    it 'deletes all internal tickets if there are no unanswered Supportbee tickets' do
      create_dependencies
      @passenger_crash_monday = create(:passenger_crash_monday,
        support_source: @supportbee)
      @ruby_5_0_not_supported = create(:ruby_5_0_not_supported,
        support_source: @supportbee)
      @npm_package_needed = create(:npm_package_needed,
        support_source: @supportbee)
      @off_by_one_bug = create(:off_by_one_bug,
        support_source: @supportbee)

      stub_request(:get, api_endpoint).
        to_return(status: 200, headers: { 'Content-Type': 'application/json' },
          body: '[]')

      SupportbeeAnalyzer.new.analyze

      expect(Ticket.count).to eq(0)
    end

    it 'creates internal tickets for not-seen-beofre unanswered Supportbee tickets' do
      create_dependencies
      @passenger_crash_monday = create(:passenger_crash_monday,
        support_source: @supportbee)

      stubbed_body = tickets_as_json(@passenger_crash_monday) + [
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

      SupportbeeAnalyzer.new.analyze

      expect(Ticket.count).to eq(3)
      expect(Ticket.exists?(@passenger_crash_monday.id)).to be_truthy

      ticket1 = Ticket.where(external_id: '1').first
      expect(ticket1.title).to eq('New ticket 1')

      ticket2 = Ticket.where(external_id: '2').first
      expect(ticket2.title).to eq('New ticket 2')
    end

    it 'does not touch existing tickets for unanswered Supportbee tickets' do
      create_dependencies
      @passenger_crash_monday = create(:passenger_crash_monday,
        support_source: @supportbee)
      @ruby_5_0_not_supported = create(:ruby_5_0_not_supported,
        support_source: @supportbee)
      @npm_package_needed = create(:npm_package_needed,
        support_source: @supportbee)
      @off_by_one_bug = create(:off_by_one_bug,
        support_source: @supportbee)

      stubbed_body = tickets_as_json(@passenger_crash_monday,
        @ruby_5_0_not_supported, @npm_package_needed,
        @off_by_one_bug)
      stub_request(:get, api_endpoint).
        to_return(status: 200, headers: { 'Content-Type': 'application/json' },
          body: stubbed_body.to_json)

      SupportbeeAnalyzer.new.analyze

      expect(Ticket.count).to eq(4)
      expect(Ticket.exists?(@passenger_crash_monday.id)).to be_truthy
      expect(Ticket.exists?(@ruby_5_0_not_supported.id)).to be_truthy
      expect(Ticket.exists?(@npm_package_needed.id)).to be_truthy
      expect(Ticket.exists?(@off_by_one_bug.id)).to be_truthy
    end

    it 'does not touch tickets not belonging to SupportbeeSupportSource' do
      create_dependencies
      @github = create(:github_passenger, user: @user)
      @passenger_crash_monday = create(:passenger_crash_monday,
        support_source: @github)
      @ruby_5_0_not_supported = create(:ruby_5_0_not_supported,
        support_source: @supportbee)
      @npm_package_needed = create(:npm_package_needed,
        support_source: @github)
      @off_by_one_bug = create(:off_by_one_bug,
        support_source: @supportbee)

      stubbed_body = {
        'total' => 0,
        'current_page' => 1,
        'per_page' => 10,
        'total_pages' => 1,
        'tickets' => []
      }
      stub_request(:get, api_endpoint).
        to_return(status: 200, headers: { 'Content-Type': 'application/json' },
          body: stubbed_body.to_json)

      SupportbeeAnalyzer.new.analyze

      expect(Ticket.count).to eq(2)
      expect(Ticket.exists?(@passenger_crash_monday.id)).to be_truthy
      expect(Ticket.exists?(@ruby_5_0_not_supported.id)).to be_falsey
      expect(Ticket.exists?(@npm_package_needed.id)).to be_truthy
      expect(Ticket.exists?(@off_by_one_bug.id)).to be_falsey
    end
  end

  context 'when there are two support sources with both distinct and overlapping groups' do
    let(:traveling_ruby_group) { 4567 }
    let(:passenger_group) { 4568 }
    let(:docker_group) { 4569 }
    let(:union_station_group) { 4570 }

    before :each do
      @user = create(:user)
      @supportbee_hongli = create(:supportbee,
        supportbee_auth_token: 'hongli',
        supportbee_user_id: 1234,
        supportbee_group_ids: [traveling_ruby_group, passenger_group, docker_group],
        user: @user)
      @supportbee_tinco = create(:supportbee,
        supportbee_auth_token: 'tinco',
        supportbee_user_id: 1235,
        supportbee_group_ids: [passenger_group, docker_group, union_station_group],
        user: @user)
    end

    context 'given not-seen-before unanswered Supportbee tickets' do
      it 'creates corresponding internal tickets for support sources ' \
         'matching the assigned user' \
      do
        # API requests for Hongli
        stub_supportbee_request('assigned_user=none',
          tickets_as_json([]).to_json,
          @supportbee_hongli.supportbee_auth_token)
        stubbed_body = tickets_as_json(
          {
            'id' => 600,
            'subject' => 'Frequent memory warnings',
            'current_assignee' => { 'user' => {
              'id' => @supportbee_hongli.supportbee_user_id
            } }
          },
          {
            'id' => 601,
            'subject' => 'Bundle install error',
            'current_assignee' => { 'user' => {
              'id' => @supportbee_hongli.supportbee_user_id
            } }
          }
        )
        stub_supportbee_request('assigned_user=me',
          stubbed_body.to_json,
          @supportbee_hongli.supportbee_auth_token)
        stub_supportbee_request('assigned_group=mine',
          tickets_as_json([]).to_json,
          @supportbee_hongli.supportbee_auth_token)

        # API requests for Tinco
        stub_supportbee_request('assigned_user=none',
          tickets_as_json([]).to_json,
          @supportbee_tinco.supportbee_auth_token)
        stubbed_body = tickets_as_json(
          {
            'id' => 610,
            'subject' => 'Metrics frontend crashes',
            'current_assignee' => { 'user' => {
              'id' => @supportbee_tinco.supportbee_user_id
            } }
          },
          {
            'id' => 611,
            'subject' => 'Indexer protocol change',
            'current_assignee' => { 'user' => {
              'id' => @supportbee_tinco.supportbee_user_id
            } }
          }
        )
        stub_supportbee_request('assigned_user=me',
          stubbed_body.to_json,
          @supportbee_tinco.supportbee_auth_token)
        stub_supportbee_request('assigned_group=mine',
          tickets_as_json([]).to_json,
          @supportbee_tinco.supportbee_auth_token)

        SupportbeeAnalyzer.new.analyze
        expect(Ticket.count).to eq(4)
        expect(Ticket.where(title: 'Frequent memory warnings').count).to eq(1)
        expect(Ticket.where(title: 'Bundle install error').count).to eq(1)
        expect(Ticket.where(title: 'Metrics frontend crashes').count).to eq(1)
        expect(Ticket.where(title: 'Indexer protocol change').count).to eq(1)

        expect(Ticket.where(title: 'Frequent memory warnings').first.
          support_source.id).to eq(@supportbee_hongli.id)
        expect(Ticket.where(title: 'Bundle install error').first.
          support_source.id).to eq(@supportbee_hongli.id)
        expect(Ticket.where(title: 'Metrics frontend crashes').first.
          support_source.id).to eq(@supportbee_tinco.id)
        expect(Ticket.where(title: 'Indexer protocol change').first.
          support_source.id).to eq(@supportbee_tinco.id)
      end

      it 'creates corresponding internal tickets for support sources ' \
         'matching the assigned group' \
      do
        # API requests for Hongli
        stub_supportbee_request('assigned_user=none',
          tickets_as_json([]).to_json,
          @supportbee_hongli.supportbee_auth_token)
        stub_supportbee_request('assigned_user=me',
          tickets_as_json([]).to_json,
          @supportbee_hongli.supportbee_auth_token)
        stubbed_body = tickets_as_json(
          {
            'id' => 600,
            'subject' => 'Frequent memory warnings',
            'current_assignee' => { 'group' => {
              'id' => passenger_group
            } }
          },
          {
            'id' => 601,
            'subject' => 'Bundle install error',
            'current_assignee' => { 'group' => {
              'id' => passenger_group
            } }
          }
        )
        stub_supportbee_request('assigned_group=mine',
          stubbed_body.to_json,
          @supportbee_hongli.supportbee_auth_token)

        # API requests for Tinco
        stub_supportbee_request('assigned_user=none',
          tickets_as_json([]).to_json,
          @supportbee_tinco.supportbee_auth_token)
        stub_supportbee_request('assigned_user=me',
          tickets_as_json([]).to_json,
          @supportbee_tinco.supportbee_auth_token)
        stubbed_body = tickets_as_json(
          {
            'id' => 610,
            'subject' => 'Metrics frontend crashes',
            'current_assignee' => { 'group' => {
              'id' => union_station_group
            } }
          },
          {
            'id' => 611,
            'subject' => 'Indexer protocol change',
            'current_assignee' => { 'group' => {
              'id' => union_station_group
            } }
          }
        )
        stub_supportbee_request('assigned_group=mine',
          stubbed_body.to_json,
          @supportbee_tinco.supportbee_auth_token)

        SupportbeeAnalyzer.new.analyze
        expect(Ticket.count).to eq(6)
        expect(Ticket.where(title: 'Frequent memory warnings').count).to eq(2)
        expect(Ticket.where(title: 'Bundle install error').count).to eq(2)
        expect(Ticket.where(title: 'Metrics frontend crashes').count).to eq(1)
        expect(Ticket.where(title: 'Indexer protocol change').count).to eq(1)

        frequent_memory_warnings = Ticket.where(title: 'Frequent memory warnings').all
        bundle_install_error = Ticket.where(title: 'Bundle install error').all
        expect(frequent_memory_warnings.map { |t| t.support_source.id }.sort).to \
          eq([@supportbee_hongli.id, @supportbee_tinco.id].sort)
        expect(bundle_install_error.map { |t| t.support_source.id }.sort).to \
          eq([@supportbee_hongli.id, @supportbee_tinco.id].sort)

        expect(Ticket.where(title: 'Metrics frontend crashes').first.
          support_source.id).to eq(@supportbee_tinco.id)
        expect(Ticket.where(title: 'Indexer protocol change').first.
          support_source.id).to eq(@supportbee_tinco.id)
      end

      it 'creates corresponding internal tickets for all support sources ' \
         'if the Supportbee ticket is not assigned' \
      do
        # API requests for Hongli
        stubbed_body = tickets_as_json(
          {
            'id' => 600,
            'subject' => 'Frequent memory warnings'
          },
          {
            'id' => 601,
            'subject' => 'Bundle install error'
          }
        )
        stub_supportbee_request('assigned_user=none',
          stubbed_body.to_json,
          @supportbee_hongli.supportbee_auth_token)
        stub_supportbee_request('assigned_user=me',
          tickets_as_json([]).to_json,
          @supportbee_hongli.supportbee_auth_token)
        stub_supportbee_request('assigned_group=mine',
          tickets_as_json([]).to_json,
          @supportbee_hongli.supportbee_auth_token)

        # API requests for Tinco
        stubbed_body = tickets_as_json(
          {
            'id' => 610,
            'subject' => 'Metrics frontend crashes'
          },
          {
            'id' => 611,
            'subject' => 'Indexer protocol change'
          }
        )
        stub_supportbee_request('assigned_user=none',
          stubbed_body.to_json,
          @supportbee_tinco.supportbee_auth_token)
        stub_supportbee_request('assigned_user=me',
          tickets_as_json([]).to_json,
          @supportbee_tinco.supportbee_auth_token)
        stub_supportbee_request('assigned_group=mine',
          tickets_as_json([]).to_json,
          @supportbee_tinco.supportbee_auth_token)

        SupportbeeAnalyzer.new.analyze
        expect(Ticket.count).to eq(8)
        expect(Ticket.where(title: 'Frequent memory warnings').count).to eq(2)
        expect(Ticket.where(title: 'Bundle install error').count).to eq(2)
        expect(Ticket.where(title: 'Metrics frontend crashes').count).to eq(2)
        expect(Ticket.where(title: 'Indexer protocol change').count).to eq(2)

        frequent_memory_warnings = Ticket.where(title: 'Frequent memory warnings').all
        bundle_install_error = Ticket.where(title: 'Bundle install error').all
        metrics_frontend_crashes = Ticket.where(title: 'Metrics frontend crashes').all
        indexer_protocol_change = Ticket.where(title: 'Indexer protocol change').all

        expect(frequent_memory_warnings.map { |t| t.support_source.id }.sort).to \
          eq([@supportbee_hongli.id, @supportbee_tinco.id].sort)
        expect(bundle_install_error.map { |t| t.support_source.id }.sort).to \
          eq([@supportbee_hongli.id, @supportbee_tinco.id].sort)
        expect(metrics_frontend_crashes.map { |t| t.support_source.id }.sort).to \
          eq([@supportbee_hongli.id, @supportbee_tinco.id].sort)
        expect(indexer_protocol_change.map { |t| t.support_source.id }.sort).to \
          eq([@supportbee_hongli.id, @supportbee_tinco.id].sort)
      end
    end
  end
end
