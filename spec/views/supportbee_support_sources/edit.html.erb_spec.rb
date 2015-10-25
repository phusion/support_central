require 'rails_helper'

RSpec.describe "supportbee_support_sources/edit", type: :view do
  before(:each) do
    @supportbee_support_source = assign(:supportbee_support_source, SupportbeeSupportSource.create!())
  end

  it "renders the edit supportbee_support_source form" do
    render

    assert_select "form[action=?][method=?]", supportbee_support_source_path(@supportbee_support_source), "post" do
    end
  end
end
