require 'rails_helper'

RSpec.describe "support_sources/index", type: :view do
  before(:each) do
    assign(:support_sources, [
      SupportSource.create!(),
      SupportSource.create!()
    ])
  end

  it "renders a list of support_sources" do
    render
  end
end
