require 'rails_helper'
require 'time'

describe FrontappAnalyzer do
  let(:time1_str) { '2012-01-18T15:17:33Z' }
  let(:time2_str) { '2012-01-18T16:17:33Z' }
  let(:time3_str) { '2012-01-18T17:17:33Z' }
  let(:time4_str) { '2012-01-18T18:17:33Z' }
  let(:time1) { Time.parse(time1_str) }
  let(:time2) { Time.parse(time2_str) }
  let(:time3) { Time.parse(time3_str) }
  let(:time4) { Time.parse(time4_str) }

  let(:support_inbox) { 'inb1' }
  let(:union_station_support_inbox) { 'inb2' }

  def stub_frontapp_request(inbox, assignment, body, auth_token = 1234)
    url = "https://api2.frontapp.com/inboxes/#{inbox}/conversations?#{assignment}"
    if !body.is_a?(String)
      body = body.to_json
    end

    stub_request(:get, url).
      with(headers: {
              "Accept" => "application/json",
              "Authorization" => "Bearer #{auth_token}",
            }).
      to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
        body: body)
  end

  def ticket_as_json(ticket)
    if !ticket.is_a?(Hash)
      ticket = {
        id: ticket.external_id,
        subject: ticket.title,
        tags: [],
        last_message: {
          created_at: time1_str.to_f
        }
      }
    end
    ticket
  end

  def make_tickets_array(*tickets)
    tickets = tickets.flatten
    {
      '_results' => tickets
    }
  end

  context 'when there is one user' do
    before :each do
      @user = create(:user)
      @frontapp = create(:frontapp, user: @user)
    end

    it 'deletes internal tickets for which the corresponding Frontapp ticket has already been answered' do
      @frequent_memory_warnings = create(:frequent_memory_warnings,
        support_source: @frontapp)
      @bundle_install_error = create(:bundle_install_error,
        support_source: @frontapp)
      @apt_repo_down = create(:apt_repo_down,
        support_source: @frontapp)
      @yum_repo_signature_error = create(:yum_repo_signature_error,
        support_source: @frontapp)
      @view_rolling_restart_status = create(:view_rolling_restart_status,
        support_source: @frontapp)

      stub1 = stub_frontapp_request(support_inbox, 'q[statuses][0]=unassigned&q[statuses][1]=assigned',
        make_tickets_array(
          ticket_as_json(@frequent_memory_warnings),
        )
      )
      stub2 = stub_frontapp_request(union_station_support_inbox, 'q[statuses][0]=unassigned&q[statuses][1]=assigned',
        make_tickets_array(
          ticket_as_json(@view_rolling_restart_status),
        )
      )

      FrontappAnalyzer.new.analyze

      assert_requested(stub1)
      assert_requested(stub2)
      expect(Ticket.count).to eq(2)
      expect(Ticket.exists?(@frequent_memory_warnings.id)).to be_truthy
      expect(Ticket.exists?(@bundle_install_error.id)).to be_falsey
      expect(Ticket.exists?(@apt_repo_down.id)).to be_falsey
      expect(Ticket.exists?(@yum_repo_signature_error.id)).to be_falsey
      expect(Ticket.exists?(@view_rolling_restart_status.id)).to be_truthy
    end

    it 'deletes internal tickets for which there is no corresponding Frontapp ticket' do
      @frequent_memory_warnings = create(:frequent_memory_warnings,
        support_source: @frontapp)
      @bundle_install_error = create(:bundle_install_error,
        support_source: @frontapp)
      @apt_repo_down = create(:apt_repo_down,
        support_source: @frontapp)

      stub1 = stub_frontapp_request(support_inbox, 'q[statuses][0]=unassigned&q[statuses][1]=assigned',
        make_tickets_array([])
      )
      stub2 = stub_frontapp_request(union_station_support_inbox, 'q[statuses][0]=unassigned&q[statuses][1]=assigned',
        make_tickets_array(
          ticket_as_json(@apt_repo_down)
        )
      )

      FrontappAnalyzer.new.analyze

      assert_requested(stub1)
      assert_requested(stub2)
      expect(Ticket.count).to eq(1)
      expect(Ticket.exists?(@frequent_memory_warnings.id)).to be_falsey
      expect(Ticket.exists?(@bundle_install_error.id)).to be_falsey
      expect(Ticket.exists?(@apt_repo_down.id)).to be_truthy
    end

    it 'deletes internal tickets for which the corresponding Frontapp ticket has been reassigned ' \
      'to a team that the current user is not part of' \
    do
      @frequent_memory_warnings = create(:frequent_memory_warnings,
        support_source: @frontapp)
      @bundle_install_error = create(:bundle_install_error,
        support_source: @frontapp)
      @apt_repo_down = create(:apt_repo_down,
        support_source: @frontapp)
      @yum_repo_signature_error = create(:yum_repo_signature_error,
        support_source: @frontapp)
      @view_rolling_restart_status = create(:view_rolling_restart_status,
        support_source: @frontapp)

      stub1 = stub_frontapp_request(support_inbox, 'q[statuses][0]=unassigned&q[statuses][1]=assigned',
        make_tickets_array(
          ticket_as_json(@frequent_memory_warnings)
        )
      ).times(2)
      stub2 = stub_frontapp_request(union_station_support_inbox, 'q[statuses][0]=unassigned&q[statuses][1]=assigned',
        make_tickets_array(
          ticket_as_json(@view_rolling_restart_status)
        )
      ).times(2)
      stub3 = stub_frontapp_request(union_station_support_inbox, 'q[statuses][0]=unassigned&q[statuses][1]=assigned',
        make_tickets_array(
          []
        )
      ).then.to_return(
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: make_tickets_array(
          []
        ).to_json
      )

      FrontappAnalyzer.new.analyze
      FrontappAnalyzer.new.analyze

      assert_requested(stub1, times: 2)
      assert_requested(stub2, times: 2)
      assert_requested(stub3, times: 2)
      expect(Ticket.count).to eq(1)
      expect(Ticket.exists?(@frequent_memory_warnings.id)).to be_truthy
      expect(Ticket.exists?(@bundle_install_error.id)).to be_falsey
      expect(Ticket.exists?(@apt_repo_down.id)).to be_falsey
      expect(Ticket.exists?(@yum_repo_signature_error.id)).to be_falsey
      expect(Ticket.exists?(@view_rolling_restart_status.id)).to be_falsey
    end

    it 'deletes all internal tickets if there are no unanswered Frontapp tickets' do
      @frequent_memory_warnings = create(:frequent_memory_warnings,
        support_source: @frontapp)
      @bundle_install_error = create(:bundle_install_error,
        support_source: @frontapp)
      @apt_repo_down = create(:apt_repo_down,
        support_source: @frontapp)
      @yum_repo_signature_error = create(:yum_repo_signature_error,
        support_source: @frontapp)

      stub1 = stub_frontapp_request(support_inbox, 'q[statuses][0]=unassigned&q[statuses][1]=assigned',
        make_tickets_array([]))
      stub2 = stub_frontapp_request(union_station_support_inbox, 'q[statuses][0]=unassigned&q[statuses][1]=assigned',
        make_tickets_array([]))

      FrontappAnalyzer.new.analyze

      assert_requested(stub1)
      assert_requested(stub2)
      expect(Ticket.count).to eq(0)
    end

    it 'creates internal tickets for not-seen-before unanswered Frontapp tickets' do
      @frequent_memory_warnings = create(:frequent_memory_warnings,
        support_source: @frontapp)

      stubbed_body = make_tickets_array(
        ticket_as_json(@frequent_memory_warnings),
        ticket_as_json({
          id: 1,
          number: 1,
          subject: 'New ticket 1',
          tags: [ { name: 'foo' } ],
          last_message: { created_at: time2.to_f }
        }),
        ticket_as_json({
          id: 2,
          number: 2,
          subject: 'New ticket 2',
          tags: [ { name: 'bar' } ],
          last_message: { created_at: time3.to_f }
        })
      )
      stub1 = stub_frontapp_request(support_inbox, 'q[statuses][0]=unassigned&q[statuses][1]=assigned',
        stubbed_body)
      stub2 = stub_frontapp_request(union_station_support_inbox, 'q[statuses][0]=unassigned&q[statuses][1]=assigned',
        make_tickets_array([]))

      FrontappAnalyzer.new.analyze

      assert_requested(stub1)
      assert_requested(stub2)

      expect(Ticket.count).to eq(3)
      expect(Ticket.exists?(@frequent_memory_warnings.id)).to be_truthy

      ticket1 = Ticket.where(external_id: '1').first
      expect(ticket1.title).to eq('New ticket 1')
      expect(ticket1.labels).to eq(['foo'])
      expect(ticket1.display_id).to eq('1')
      expect(ticket1.external_id).to eq('1')
      expect(ticket1.external_last_update_time).to eq(time2)

      ticket2 = Ticket.where(external_id: '2').first
      expect(ticket2.title).to eq('New ticket 2')
      expect(ticket2.labels).to eq(['bar'])
      expect(ticket2.display_id).to eq('2')
      expect(ticket2.external_id).to eq('2')
      expect(ticket2.external_last_update_time).to eq(time3)
    end

    it 'does not touch existing tickets for unanswered Frontapp tickets' do
      @frequent_memory_warnings = create(:frequent_memory_warnings,
        support_source: @frontapp)
      @bundle_install_error = create(:bundle_install_error,
        support_source: @frontapp)
      @apt_repo_down = create(:apt_repo_down,
        support_source: @frontapp)
      @yum_repo_signature_error = create(:yum_repo_signature_error,
        support_source: @frontapp)

      stubbed_body = make_tickets_array(
        ticket_as_json(@frequent_memory_warnings),
        ticket_as_json(@bundle_install_error),
        ticket_as_json(@apt_repo_down),
        ticket_as_json(@yum_repo_signature_error)
      )
      stub1 = stub_frontapp_request(support_inbox, 'q[statuses][0]=unassigned&q[statuses][1]=assigned',
        stubbed_body)
      stub2 = stub_frontapp_request(union_station_support_inbox, 'q[statuses][0]=unassigned&q[statuses][1]=assigned',
        make_tickets_array([]))

      FrontappAnalyzer.new.analyze

      assert_requested(stub1)
      assert_requested(stub2)
      expect(Ticket.count).to eq(4)
      expect(Ticket.exists?(@frequent_memory_warnings.id)).to be_truthy
      expect(Ticket.exists?(@bundle_install_error.id)).to be_truthy
      expect(Ticket.exists?(@apt_repo_down.id)).to be_truthy
      expect(Ticket.exists?(@yum_repo_signature_error.id)).to be_truthy
    end

    it 'does not touch tickets not belonging to FrontappSupportSource' do
      @github = create(:github_passenger, user: @user)
      @frequent_memory_warnings = create(:frequent_memory_warnings,
        support_source: @github)
      @bundle_install_error = create(:bundle_install_error,
        support_source: @frontapp)
      @apt_repo_down = create(:apt_repo_down,
        support_source: @github)
      @yum_repo_signature_error = create(:yum_repo_signature_error,
        support_source: @frontapp)

      stub1 = stub_frontapp_request(support_inbox, 'q[statuses][0]=unassigned&q[statuses][1]=assigned',
        make_tickets_array([]))
      stub2 = stub_frontapp_request(union_station_support_inbox, 'q[statuses][0]=unassigned&q[statuses][1]=assigned',
        make_tickets_array([]))

      FrontappAnalyzer.new.analyze

      assert_requested(stub1)
      assert_requested(stub2)
      expect(Ticket.count).to eq(2)
      expect(Ticket.exists?(@frequent_memory_warnings.id)).to be_truthy
      expect(Ticket.exists?(@bundle_install_error.id)).to be_falsey
      expect(Ticket.exists?(@apt_repo_down.id)).to be_truthy
      expect(Ticket.exists?(@yum_repo_signature_error.id)).to be_falsey
    end

    it "sets a ticket's status to 'respond_now' if the corresponding " \
       "Frontapp ticket has the 'respond now' label" \
    do
      @frequent_memory_warnings = create(:frequent_memory_warnings,
        support_source: @frontapp)

      json = ticket_as_json(@frequent_memory_warnings)
      json[:tags] = [ { name: 'Respond Now' } ]

      stub1 = stub_frontapp_request(support_inbox, 'q[statuses][0]=unassigned&q[statuses][1]=assigned',
        make_tickets_array(json))
      stub2 = stub_frontapp_request(union_station_support_inbox, 'q[statuses][0]=unassigned&q[statuses][1]=assigned',
        make_tickets_array([]))

      FrontappAnalyzer.new.analyze

      assert_requested(stub1)
      assert_requested(stub2)
      @frequent_memory_warnings.reload
      expect(@frequent_memory_warnings.status).to eq('respond_now')
    end

    it "sets a ticket's status to 'overdue' if the corresponding " \
       "Frontapp ticket has the 'overdue' label" \
    do
      @frequent_memory_warnings = create(:frequent_memory_warnings,
        support_source: @frontapp)

      json = ticket_as_json(@frequent_memory_warnings)
      json[:tags] = [ { name: 'Overdue' } ]

       stub1 = stub_frontapp_request(support_inbox, 'q[statuses][0]=unassigned&q[statuses][1]=assigned',
        make_tickets_array(json))
      stub2 = stub_frontapp_request(union_station_support_inbox, 'q[statuses][0]=unassigned&q[statuses][1]=assigned',
        make_tickets_array([]))

      FrontappAnalyzer.new.analyze

      assert_requested(stub1)
      assert_requested(stub2)
      @frequent_memory_warnings.reload
      expect(@frequent_memory_warnings.status).to eq('overdue')
    end

    it "sets a ticket's status to 'overdue' if the corresponding " \
       "Frontapp ticket has both the 'respond now' and 'overdue' labels" \
    do
      @frequent_memory_warnings = create(:frequent_memory_warnings,
        support_source: @frontapp)

      json = ticket_as_json(@frequent_memory_warnings)
      json[:tags] = [ { name: 'Respond Now' }, { name: 'Overdue' } ]
       stub1 = stub_frontapp_request(support_inbox, 'q[statuses][0]=unassigned&q[statuses][1]=assigned',
        make_tickets_array(json))
      stub2 = stub_frontapp_request(union_station_support_inbox, 'q[statuses][0]=unassigned&q[statuses][1]=assigned',
        make_tickets_array([]))

      FrontappAnalyzer.new.analyze

      assert_requested(stub1)
      assert_requested(stub2)
      @frequent_memory_warnings.reload
      expect(@frequent_memory_warnings.status).to eq('overdue')
    end

    it "sets a ticket's status to 'normal' if the corresponding " \
       "Frontapp ticket has neither the 'respond now' nor the 'overdue' label" \
    do
      @frequent_memory_warnings = create(:frequent_memory_warnings,
        status: 'overdue',
        support_source: @frontapp)

      json = ticket_as_json(@frequent_memory_warnings)
      stub1 = stub_frontapp_request(support_inbox, 'q[statuses][0]=unassigned&q[statuses][1]=assigned',
        make_tickets_array(json))
      stub2 = stub_frontapp_request(union_station_support_inbox, 'q[statuses][0]=unassigned&q[statuses][1]=assigned',
        make_tickets_array([]))

      FrontappAnalyzer.new.analyze

      assert_requested(stub1)
      assert_requested(stub2)
      @frequent_memory_warnings.reload
      expect(@frequent_memory_warnings.status).to eq('normal')
    end

    it "saves the Frontapp's ticket's labels except for 'respond now' and 'overdue'" do
      @frequent_memory_warnings = create(:frequent_memory_warnings,
        support_source: @frontapp)

      json = ticket_as_json(@frequent_memory_warnings)
      json[:tags] = [
        { name: 'Silver' },
        { name: 'Passenger' },
        { name: 'Overdue' },
        { name: 'Respond Now' }
      ]
      stub1 = stub_frontapp_request(support_inbox, 'q[statuses][0]=unassigned&q[statuses][1]=assigned',
        make_tickets_array(json))
      stub2 = stub_frontapp_request(union_station_support_inbox, 'q[statuses][0]=unassigned&q[statuses][1]=assigned',
        make_tickets_array([]))

      FrontappAnalyzer.new.analyze

      assert_requested(stub1)
      assert_requested(stub2)
      @frequent_memory_warnings.reload
      expect(@frequent_memory_warnings.labels).to eq(['Silver', 'Passenger'])
    end
  end

  context 'given two support sources, one with and one without internal tickets' do
    before :each do
      @user = create(:user)
      @user2 = create(:user2)
      @frontapp_hongli = create(:frontapp,
        name: 'Supportbee Hongli',
        frontapp_auth_token: 'shared',
        frontapp_user_id: 1234,
        frontapp_inbox_ids: [support_inbox],
        user: @user)
      @frontapp_tinco = create(:frontapp,
        name: 'Supportbee Tinco',
        frontapp_auth_token: 'shared',
        frontapp_user_id: 1235,
        frontapp_inbox_ids: [support_inbox, union_station_support_inbox],
        user: @user2)
    end

    specify 'if there are unanswered external tickets, it creates internal tickets ' \
            'in the support source that did not have any' \
    do
      @frequent_memory_warnings = create(:frequent_memory_warnings,
        support_source: @frontapp_hongli)
      @bundle_install_error = create(:bundle_install_error,
        support_source: @frontapp_tinco)

      # API requests by Hongli
      stub1 = stub_frontapp_request(support_inbox, 'q[statuses][0]=unassigned&q[statuses][1]=assigned',
        make_tickets_array([ticket_as_json(@frequent_memory_warnings)]),
        @frontapp_hongli.frontapp_auth_token)

      # API requests by Tinco
      stub2 = stub_frontapp_request(union_station_support_inbox, 'q[statuses][0]=unassigned&q[statuses][1]=assigned',
        make_tickets_array([ticket_as_json(@bundle_install_error)]),
        @frontapp_tinco.frontapp_auth_token)

      FrontappAnalyzer.new.analyze

      assert_requested(stub1, times: 2) # 2 times, because the api key is shared
      assert_requested(stub2)
      expect(Ticket.count).to eq(3)
    end
  end
end
