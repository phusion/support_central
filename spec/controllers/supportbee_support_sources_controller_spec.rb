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
#  rss_url               :string
#  position              :integer
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

RSpec.describe SupportbeeSupportSourcesController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # SupportbeeSupportSource. As you add validations to SupportbeeSupportSource, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
      name: 'phusion',
      supportbee_company_id: 'phusion',
      supportbee_auth_token: '1234',
      supportbee_user_id: '5678',
      supportbee_group_ids_as_string: '9012, 9013'
    }
  }

  let(:invalid_attributes) {
    {
      name: '',
      supportbee_company_id: '',
      supportbee_auth_token: '',
      supportbee_user_id: '',
      supportbee_group_ids_as_string: ''
    }
  }

  describe "GET #new" do
    it "assigns a new supportbee_support_source as @support_source" do
      sign_in(create(:user))
      get :new
      expect(assigns(:support_source)).to be_a_new(SupportbeeSupportSource)
    end
  end

  describe "GET #edit" do
    it "assigns the requested supportbee_support_source as @support_source" do
      @user = create(:user)
      sign_in(@user)
      @source = create(:supportbee, user: @user)
      get :edit, params: { id: @source.to_param }
      expect(assigns(:support_source)).to eq(@source)
    end
  end

  describe "POST #create" do
    before :each do
      @user = create(:user)
      sign_in(@user)
    end

    context "with valid params" do
      it "creates a new SupportbeeSupportSource" do
        expect {
          post :create, params: { supportbee_support_source: valid_attributes }
        }.to change(SupportbeeSupportSource, :count).by(1)
      end

      it "assigns a newly created supportbee_support_source as @support_source" do
        post :create, params: { supportbee_support_source: valid_attributes }
        expect(assigns(:support_source)).to be_a(SupportbeeSupportSource)
        expect(assigns(:support_source)).to be_persisted
      end

      it "redirects to the created supportbee_support_source" do
        post :create, params: { supportbee_support_source: valid_attributes }
        expect(response).to redirect_to(support_sources_url)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved supportbee_support_source as @support_source" do
        post :create, params: { supportbee_support_source: invalid_attributes }
        expect(assigns(:support_source)).to be_a_new(SupportbeeSupportSource)
      end

      it "re-renders the 'new' template" do
        post :create, params: { supportbee_support_source: invalid_attributes }
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    let :new_attributes do
      {
        name: 'New name',
        supportbee_company_id: 'photonblast'
      }
    end

    before :each do
      @user = create(:user)
      sign_in(@user)
      @source = create(:supportbee, user: @user)
    end

    context "with valid params" do
      it "updates the requested support source" do
        put :update, params: { id: @source.to_param, supportbee_support_source: new_attributes }
        @source.reload
        expect(@source.name).to eq('New name')
        expect(@source.supportbee_company_id).to eq('photonblast')
      end

      it "assigns the requested support source as @support_source" do
        put :update, params: { id: @source.to_param, supportbee_support_source: valid_attributes }
        expect(assigns(:support_source)).to eq(@source)
      end

      it "redirects to the support source" do
        put :update, params: { id: @source.to_param, supportbee_support_source: valid_attributes }
        expect(response).to redirect_to(@source)
      end
    end

    context "with invalid params" do
      it "assigns the support source as @support_source" do
        put :update, params: { id: @source.to_param, supportbee_support_source: invalid_attributes }
        expect(assigns(:support_source)).to eq(@source)
      end

      it "re-renders the 'edit' template" do
        put :update, params: { id: @source.to_param, supportbee_support_source: invalid_attributes }
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    before :each do
      @user = create(:user)
      sign_in(@user)
      @source = create(:supportbee, user: @user)
    end

    it "destroys the requested supportbee_support_source" do
      expect {
        delete :destroy, params: { id: @source.to_param }
      }.to change(SupportbeeSupportSource, :count).by(-1)
    end

    it "redirects to the supportbee_support_sources list" do
      delete :destroy, params: { id: @source.to_param }
      expect(response).to redirect_to(support_sources_url)
    end
  end

end
