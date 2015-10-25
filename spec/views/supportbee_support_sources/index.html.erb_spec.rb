require 'rails_helper'

RSpec.describe "supportbee_support_sources/index", type: :view do
  before(:each) do
    assign(:supportbee_support_sources, [
      SupportbeeSupportSource.create!(),
      SupportbeeSupportSource.create!()
    ])
  end

  it "renders a list of supportbee_support_sources" do
    render
  end
end
