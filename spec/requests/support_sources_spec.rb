require 'rails_helper'

RSpec.describe "SupportSources", type: :request do
  describe "GET /support_sources" do
    it "works! (now write some real specs)" do
      get support_sources_path
      expect(response).to have_http_status(200)
    end
  end
end
