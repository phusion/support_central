require 'rails_helper'

RSpec.describe "github_support_sources/new", type: :view do
  before(:each) do
    assign(:github_support_source, GithubSupportSource.new())
  end

  it "renders new github_support_source form" do
    render

    assert_select "form[action=?][method=?]", github_support_sources_path, "post" do
    end
  end
end
