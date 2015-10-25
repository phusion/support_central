require 'rails_helper'

RSpec.describe "support_sources/new", type: :view do
  before(:each) do
    assign(:support_source, SupportSource.new())
  end

  it "renders new support_source form" do
    render

    assert_select "form[action=?][method=?]", support_sources_path, "post" do
    end
  end
end
