class Webhooks::GithubWebhookController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  def github
    authenticate_github_request!
    if event == :issues
      handle_issue_event
    elsif event == :issue_comment
      handle_issue_comment_event
    end
    render text: 'ok'
  end

private
  HMAC_DIGEST = OpenSSL::Digest.new('sha1')

  def handle_issue_event
    if json_body['action'] == 'opened' && !sender_is_from_phusion?
      add_unanswered_label
    end
  end

  def handle_issue_comment_event
    if json_body['action'] == 'created'
      if sender_is_from_phusion?
        remove_unanswered_label
      else
        add_unanswered_label
      end
    end
  end

  def sender_is_from_phusion?
    CONFIG['phusion_github_usernames'].include?(json_body['sender']['login'].downcase)
  end

  def add_unanswered_label
    set_labels((label_names + ['unanswered']).uniq.join(','))
  end

  def remove_unanswered_label
    set_labels((label_names - ['unanswered']).join(','))
  end

  def label_names
    json_body['issue']['labels'].map { |l| l['name'] }
  end

  def set_labels(labels)
    octokit.update_issue(json_body['repository']['full_name'],
      json_body['issue']['number'],
      labels: labels)
  end

  def authenticate_github_request!
    secret = CONFIG['github_webhook_secret']
    expected_signature = "sha1=#{OpenSSL::HMAC.hexdigest(HMAC_DIGEST,
      secret, request_body)}"
    if signature_header != expected_signature
      raise "Github signature mismatch. " \
        "Actual: #{signature_header}, " \
        "expected: #{expected_signature}"
    end
  end

  def signature_header
    @signature_header ||= request.headers['X-Hub-Signature']
  end

  def event
    @event ||= request.headers['X-GitHub-Event'].to_sym
  end

  def octokit
    @octokit ||= Octokit::Client.new(:access_token => CONFIG['github_api_token'])
  end

  def request_body
    @request_body ||= begin
      if request.body.respond_to?(:rewind)
        request.body.rewind
      end
      request.body.read
    end
  end

  def json_body
    @json_body ||= ActiveSupport::HashWithIndifferentAccess.new(JSON.load(request_body))
  end
end
