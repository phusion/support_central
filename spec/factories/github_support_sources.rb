FactoryGirl.define do
  factory :github_passenger, class: 'GithubSupportSource' do
    name 'passenger'
    github_owner_and_repo 'phusion/passenger'
  end
end