require 'rails_helper'

RSpec.describe "supportbee_support_sources/new", type: :view do
  before(:each) do
    assign(:supportbee_support_source, SupportbeeSupportSource.new())
  end

  it "renders new supportbee_support_source form" do
    render

    assert_select "form[action=?][method=?]", supportbee_support_sources_path, "post" do
    end
  end
end
