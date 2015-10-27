require 'rails_helper'

RSpec.describe SupportSourcesController, type: :controller do
  describe "GET #index" do
    it "assigns all support sources as @support_sources" do
      @user = create(:user)
      sign_in(@user)
      @github = create(:github_passenger, user: @user)
      @supportbee = create(:supportbee, user: @user)
      get :index
      expect(assigns(:support_sources)).to eq([@github, @supportbee])
    end
  end

  describe "GET #new" do
    it "works" do
      sign_in(create(:user))
      get :new
      expect(response.status).to eq(200)
    end
  end

  describe "GET #edit" do
    it "redirects to the edit page for the type-specific support source controller" do
      @user = create(:user)
      sign_in(@user)
      @source = create(:github_passenger, user: @user)
      get :edit, id: @source.to_param
      expect(response).to redirect_to(edit_github_support_source_url(@source))
    end
  end

  describe "DELETE #destroy" do
    before :each do
      @user = create(:user)
      sign_in(@user)
      @source = create(:supportbee, user: @user)
    end

    it "destroys the requested support source" do
      expect {
        delete :destroy, id: @source.to_param
      }.to change(SupportSource, :count).by(-1)
    end

    it "redirects to the support sources list" do
      delete :destroy, id: @source.to_param
      expect(response).to redirect_to(support_sources_url)
    end
  end

end
