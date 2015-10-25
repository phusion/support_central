require 'rails_helper'

RSpec.describe "support_sources/show", type: :view do
  before(:each) do
    @support_source = assign(:support_source, SupportSource.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
