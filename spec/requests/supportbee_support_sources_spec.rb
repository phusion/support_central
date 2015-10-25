require 'rails_helper'

RSpec.describe "SupportbeeSupportSources", type: :request do
  describe "GET /supportbee_support_sources" do
    it "works! (now write some real specs)" do
      get supportbee_support_sources_path
      expect(response).to have_http_status(200)
    end
  end
end
