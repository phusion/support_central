# == Schema Information
#
# Table name: tickets
#
#  id                        :integer          not null, primary key
#  support_source_id         :integer          not null
#  title                     :string           not null
#  labels                    :text             default([]), is an Array
#  external_id               :string
#  external_last_update_time :datetime         not null
#  status                    :integer          default(0), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  fk__tickets_support_source_id  (support_source_id)
#

FactoryGirl.define do
  ### Github issues ###

  factory :passenger_crash_monday, class: 'Ticket' do
    title 'Passenger crashes on Monday'
    external_id 'phusion/passenger/issues/27'
    external_last_update_time 1.day.ago
  end

  factory :ruby_5_0_not_supported, class: 'Ticket' do
    title 'Ruby 5.0 not supported'
    external_id 'phusion/passenger/issues/28'
    external_last_update_time 1.day.ago
  end

  factory :npm_package_needed, class: 'Ticket' do
    title 'NPM package needed'
    external_id 'phusion/passenger/issues/29'
    external_last_update_time 1.day.ago
  end

  factory :off_by_one_bug, class: 'Ticket' do
    title 'Off-by-one bug'
    external_id 'phusion/passenger/issues/30'
    external_last_update_time 1.day.ago
  end

  factory :apache_uploads_fail, class: 'Ticket' do
    title 'Apache uploads fail'
    external_id 'phusion/passenger/issues/31'
    external_last_update_time 1.day.ago
  end

  factory :support_ubuntu_2020, class: 'Ticket' do
    title 'Support Ubuntu 20.20'
    external_id 'phusion/passenger/issues/32'
    external_last_update_time 1.day.ago
  end

  ### Supportbee tickets ###

  factory :frequent_memory_warnings, class: 'Ticket' do
    title 'Frequent memory warnings'
    external_id '50'
    external_last_update_time 1.day.ago
  end

  factory :bundle_install_error, class: 'Ticket' do
    title 'Bundle install error'
    external_id '51'
    external_last_update_time 1.day.ago
  end

  factory :apt_repo_down, class: 'Ticket' do
    title 'APT repo down'
    external_id '52'
    external_last_update_time 1.day.ago
  end

  factory :yum_repo_signature_error, class: 'Ticket' do
    title 'YUM repo signature error'
    external_id '54'
    external_last_update_time 1.day.ago
  end

  factory :view_rolling_restart_status, class: 'Ticket' do
    title 'View rolling restart status'
    external_id '55'
    external_last_update_time 1.day.ago
  end
end
