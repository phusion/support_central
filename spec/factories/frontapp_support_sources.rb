FactoryGirl.define do
  factory :frontapp, class: 'FrontappSupportSource' do
    name 'phusion'
    frontapp_auth_token '1234'
    frontapp_user_id 'a@b.c'
    frontapp_inbox_ids ['inb1', 'inb2']
  end
end
