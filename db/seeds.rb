# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'securerandom'

class SeedUtils
  DEFAULT_PASSWORD_FOR_DEVELOPMENT = '12345678'

  def initialize
    @users_created = 0
    @support_sources_created = 0
    @tickets_created = 0
  end

  def create_user(email)
    user = User.where(email: email).first
    if user
      puts "User already exists: #{email}"
    else
      @users_created += 1
      puts "Creating user: #{email}"
      user = User.new
      user.email = email
      user.password = user.password_confirmation = generate_or_query_password
      user.save!
    end
    user
  end

  def create_github_support_source(owner, repo)
    source = owner.support_sources.where(github_owner_and_repo: repo).first
    if source
      puts "Github support source already exists for #{owner.email}: #{repo}"
    else
      @support_sources_created += 1
      puts "Creating Github support source: #{repo}"
      source = GithubSupportSource.new
      source.user = owner
      source.github_owner_and_repo = repo
      source.save!
    end
    source
  end

  def create_supportbee_support_source(owner, company_id, user_id, group_ids)
    source = owner.support_sources.where(supportbee_user_id: user_id).first
    if source
      puts "Supportbee support source already exists for #{owner.email}: #{user_id}"
    else
      @support_sources_created += 1
      puts "Creating Github support source: #{user_id}"
      source = SupportbeeSupportSource.new
      source.user = owner
      source.supportbee_company_id = company_id
      source.supportbee_auth_token = 'xxx'
      source.supportbee_user_id = user_id
      source.supportbee_group_ids = group_ids
      source.save!
    end
    source
  end

  def create_ticket(support_source, attributes)
    ticket = support_source.tickets.where(title: attributes[:title]).first
    if ticket
      puts "Ticket already exists: #{attributes[:title]}"
    else
      @tickets_created += 1
      puts "Creating ticket: #{attributes[:title]}"
      ticket = support_source.tickets.build
      ticket.attributes = attributes
      ticket.save!
    end
    ticket
  end

  def print_statistics
    puts "---------------------------------------"
    puts " * #{@users_created} users created"
    if @users_created > 0
      if Rails.env.development?
        puts "   The password is #{DEFAULT_PASSWORD_FOR_DEVELOPMENT}"
      else
        puts "   Please tell these users to initiate a password reset."
      end
    end
    puts " * #{@support_sources_created} support sources created"
    puts " * #{@tickets_created} tickets created"
  end

private
  def generate_or_query_password
    if Rails.env.development?
      DEFAULT_PASSWORD_FOR_DEVELOPMENT
    else
      SecureRandom.hex(16)
    end
  end
end

seeder = SeedUtils.new
Ticket.transaction do
  hongli = seeder.create_user('hongli@phusion.nl')
  seeder.create_user('daniel@phusion.nl')
  seeder.create_user('tinco@phusion.nl')

  if Rails.env.development?
    github = seeder.create_github_support_source(hongli, 'phusion/passenger')
    seeder.create_supportbee_support_source(hongli, 'phusion', 1823903, [4678])
    seeder.create_ticket(github, title: 'Passenger does not work',
      status: 'overdue',
      display_id: 'phusion/passenger #1',
      external_id: 'phusion/passenger/issues/1',
      external_last_update_time: 1.hour.ago)
    seeder.create_ticket(github, title: 'APT repo down',
      status: 'respond_now',
      display_id: 'phusion/passenger #2',
      external_id: 'phusion/passenger/issues/2',
      external_last_update_time: Time.now)
  end
end

seeder.print_statistics
