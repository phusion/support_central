require 'rails_helper'

RSpec.describe "github_support_sources/edit", type: :view do
  before(:each) do
    @github_support_source = assign(:github_support_source, GithubSupportSource.create!())
  end

  it "renders the edit github_support_source form" do
    render

    assert_select "form[action=?][method=?]", github_support_source_path(@github_support_source), "post" do
    end
  end
end
