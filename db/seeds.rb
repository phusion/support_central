# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'securerandom'

class SeedUtils
  def initialize
    @users_created = 0
  end

  def create_user(email)
    if User.where(email: email).exists?
      puts "User already exists: #{email}"
    else
      @users_created += 1
      puts "Creating user: #{email}"
      user = User.new
      user.email = email
      user.password = user.password_confirmation = SecureRandom.hex(16)
      user.save!
    end
  end

  def print_statistics
    puts "---------------------------------------"
    puts "#{@users_created} users created"
    if @users_created > 0
      puts "Please tell these users to initiate a password reset."
    end
  end
end

seeder = SeedUtils.new
seeder.create_user('hongli@phusion.nl')
seeder.create_user('daniel@phusion.nl')
seeder.create_user('tinco@phusion.nl')
seeder.print_statistics
