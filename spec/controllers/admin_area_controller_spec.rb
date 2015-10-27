require 'rails_helper'

RSpec.describe AdminAreaController, type: :controller do
  specify 'GET #index works' do
    sign_in(create(:user))
    get :index
    expect(response.status).to eq(200)
  end
end
