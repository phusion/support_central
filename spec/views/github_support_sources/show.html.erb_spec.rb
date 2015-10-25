require 'rails_helper'

RSpec.describe "github_support_sources/show", type: :view do
  before(:each) do
    @github_support_source = assign(:github_support_source, GithubSupportSource.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
