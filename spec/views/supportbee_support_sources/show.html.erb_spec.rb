require 'rails_helper'

RSpec.describe "supportbee_support_sources/show", type: :view do
  before(:each) do
    @supportbee_support_source = assign(:supportbee_support_source, SupportbeeSupportSource.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
