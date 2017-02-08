# == Schema Information
#
# Table name: support_sources
#
#  id                    :integer          not null, primary key
#  type                  :string           not null
#  name                  :string           not null
#  user_id               :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  github_owner_and_repo :string
#  supportbee_company_id :string
#  supportbee_auth_token :string
#  supportbee_user_id    :string
#  supportbee_group_ids  :text             default([]), is an Array
#  frontapp_user_id      :string
#  frontapp_auth_token   :string
#  frontapp_inbox_ids    :text             default([]), is an Array
#
# Indexes
#
#  fk__support_sources_user_id                (user_id)
#  index_support_sources_on_user_id_and_name  (user_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_support_sources_user_id  (user_id => users.id) ON DELETE => cascade ON UPDATE => cascade
#

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
