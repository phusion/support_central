require 'rails_helper'

RSpec.describe Webhooks::GithubWebhookController, type: :controller do
  HMAC_DIGEST = OpenSSL::Digest.new('sha1')

  let(:body_issue_opened_by_phusion_user) do
    {
      action: 'opened',
      issue: {
        number: 1234,
        title: 'Something is wrong',
        user: {
          login: CONFIG['phusion_github_usernames'][0]
        },
        labels: [
          { name: 'usability' },
          { name: 'documentation' }
        ],
      },
      repository: {
        full_name: 'phusion/passenger'
      },
      sender: {
        login: CONFIG['phusion_github_usernames'][0]
      }
    }
  end

  let(:body_issue_comment_created_by_phusion_user) do
    {
      action: 'created',
      issue: {
        number: 1234,
        title: 'Something is wrong',
        user: {
          login: CONFIG['phusion_github_usernames'][0]
        },
        labels: [],
      },
      repository: {
        full_name: 'phusion/passenger'
      },
      sender: {
        login: CONFIG['phusion_github_usernames'][0]
      }
    }
  end

  let(:body_issue_not_opened_by_phusion_user) do
    body = body_issue_opened_by_phusion_user.dup
    body[:issue][:user][:login] = 'randomuser'
    body[:sender][:login] = 'randomuser'
    body
  end

  let(:body_issue_comment_not_created_by_phusion_user) do
    body = body_issue_comment_created_by_phusion_user.dup
    body[:issue][:user][:login] = 'randomuser'
    body[:sender][:login] = 'randomuser'
    body
  end

  def post_json_with_signature(event, json)
    secret = CONFIG['github_webhook_secret']
    request_body = JSON.generate(json)
    request.headers['X-GitHub-Event'] = event.to_s
    request.headers['X-Hub-Signature'] = "sha1=#{OpenSSL::HMAC.hexdigest(HMAC_DIGEST,
      secret, request_body)}"
    post :hook, request_body
  end

  describe 'security' do
    it 'raises an error if the Github signature is incorrect' do
      secret = CONFIG['github_webhook_secret']
      begin
        CONFIG['github_webhook_secret'] += 'wrong garbage'
        post_json_with_signature(:issues,
          body_issue_opened_by_phusion_user)
      ensure
        CONFIG['github_webhook_secret'] = secret
      end
    end
  end

  describe 'IssuesEvent' do
    it 'does nothing if the action is not "opened"' do
      body = body_issue_opened_by_phusion_user.dup
      body[:action] = 'closed'
      post_json_with_signature(:issues, body)
      expect(response.status).to eq(200)
    end

    it 'does nothing if the sender is a Phusion user' do
      post_json_with_signature(:issues,
        body_issue_opened_by_phusion_user)
      expect(response.status).to eq(200)
    end

    it 'adds the "unanswered" label otherwise' do
      stub = stub_request(:patch,
            'https://api.github.com/repos/phusion/passenger/issues/1234').
          with(body: '{"labels":"usability,documentation,unanswered"}').
          to_return(status: 200, body: 'ok')

      post_json_with_signature(:issues,
        body_issue_not_opened_by_phusion_user)

      assert_requested(stub)
      expect(response.status).to eq(200)
    end
  end

  describe 'IssueCommentEvent' do
    it 'does nothing if the action is not "created"' do
      body = body_issue_comment_created_by_phusion_user.dup
      body[:action] = 'destroyed'
      post_json_with_signature(:issue_comment, body)
      expect(response.status).to eq(200)
    end

    context 'if the sender is a Phusion user' do
      it 'does nothing if the issue did not have an "unanswered" label' do
        post_json_with_signature(:issue_comment,
          body_issue_comment_created_by_phusion_user)
        expect(response.status).to eq(200)
      end

      it 'removes the "unanswered" label otherwise' do
        body = body_issue_comment_created_by_phusion_user.dup
        body[:issue][:labels] = [
          { name: 'security' },
          { name: 'unanswered' },
          { name: 'priority/high' }
        ]

        stub = stub_request(:patch,
            'https://api.github.com/repos/phusion/passenger/issues/1234').
          with(body: '{"labels":"security,priority/high"}').
          to_return(status: 200, body: 'ok')

        post_json_with_signature(:issue_comment, body)
        expect(response.status).to eq(200)
        assert_requested(stub)
      end
    end

    context 'if the sender is not a Phusion user' do
      it 'does nothing if the issue already has an "unanswered" label' do
        body = body_issue_comment_not_created_by_phusion_user.dup
        body[:issue][:labels] = [
          { name: 'security' },
          { name: 'unanswered' },
          { name: 'priority/high' }
        ]
        post_json_with_signature(:issue_comment, body)
        expect(response.status).to eq(200)
      end

      it 'adds the "unanswered" label otherwise' do
        body = body_issue_comment_not_created_by_phusion_user.dup
        body[:issue][:labels] = [
          { name: 'security' },
          { name: 'priority/high' }
        ]

        stub = stub_request(:patch,
            'https://api.github.com/repos/phusion/passenger/issues/1234').
          with(body: '{"labels":"security,priority/high,unanswered"}').
          to_return(status: 200, body: 'ok')

        post_json_with_signature(:issue_comment, body)

        expect(response.status).to eq(200)
        assert_requested(stub)
      end
    end
  end
end
