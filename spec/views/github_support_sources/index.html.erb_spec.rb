require 'rails_helper'

RSpec.describe "github_support_sources/index", type: :view do
  before(:each) do
    assign(:github_support_sources, [
      GithubSupportSource.create!(),
      GithubSupportSource.create!()
    ])
  end

  it "renders a list of github_support_sources" do
    render
  end
end
