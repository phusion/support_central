require 'rails_helper'

RSpec.describe AdminAreaController, type: :controller do
  before :each do
    @current_user = create(:user)
    @frontapp = create(:frontapp, user: @current_user)
    @github = create(:github_passenger, user: @current_user)

    ticket1 = create(:ruby_5_0_not_supported, support_source: @frontapp)
    ticket2 = create(:ruby_5_0_not_supported, support_source: @github)
  end

  specify 'GET #index works' do
    sign_in(@current_user)
    get :index
    expect(response.status).to eq(200)
  end

  specify 'POST #sync_github works' do
    expect_any_instance_of(GithubAnalyzer).to receive(:analyze)
    sign_in(@current_user)
    post :sync_github
    expect(response.status).to eq(302)
    expect(subject).to redirect_to(admin_area_path)
  end

  specify 'POST #sync_my_sources works' do
    expect_any_instance_of(GithubAnalyzer).to receive(:analyze)
    expect_any_instance_of(FrontappAnalyzer).to receive(:analyze)

    sign_in(@current_user)
    post :sync_my_sources
    expect(response.status).to eq(302)
    expect(subject).to redirect_to(admin_area_path)
  end
end
