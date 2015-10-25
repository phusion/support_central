require 'rails_helper'

RSpec.describe "support_sources/edit", type: :view do
  before(:each) do
    @support_source = assign(:support_source, SupportSource.create!())
  end

  it "renders the edit support_source form" do
    render

    assert_select "form[action=?][method=?]", support_source_path(@support_source), "post" do
    end
  end
end
