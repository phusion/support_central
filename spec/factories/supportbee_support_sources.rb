FactoryGirl.define do
  factory :supportbee, class: 'SupportbeeSupportSource' do
    name 'phusion'
    supportbee_company_id 'phusion'
    supportbee_auth_token '1234'
    supportbee_user_id 5678
    supportbee_group_ids [9012, 9013]
  end
end
