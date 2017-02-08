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

RSpec.describe GithubSupportSourcesController, type: :controller do
  let(:valid_attributes) {
    {
      name: 'GithubRepo',
      github_owner_and_repo: 'phusion/support_central'
    }
  }

  let(:invalid_attributes) {
    {
      name: '',
      github_owner_and_repo: ''
    }
  }

  describe "GET #new" do
    it "assigns a new support source as @support_source" do
      sign_in(create(:user))
      get :new
      expect(assigns(:support_source)).to be_a_new(GithubSupportSource)
    end
  end

  describe "GET #edit" do
    it "assigns the requested support source as @support_source" do
      @user = create(:user)
      sign_in(@user)
      @source = create(:github_passenger, user: @user)
      get :edit, id: @source.to_param
      expect(assigns(:support_source)).to eq(@source)
    end
  end

  describe "POST #create" do
    before :each do
      @user = create(:user)
      sign_in(@user)
    end

    context "with valid params" do
      it "creates a new GithubSupportSource" do
        expect {
          post :create, :github_support_source => valid_attributes
        }.to change(GithubSupportSource, :count).by(1)
      end

      it "assigns a newly created support source as @support_source" do
        post :create, :github_support_source => valid_attributes
        expect(assigns(:support_source)).to be_a(GithubSupportSource)
        expect(assigns(:support_source)).to be_persisted
      end

      it "redirects to the support source listing" do
        post :create, :github_support_source => valid_attributes
        expect(response).to redirect_to(support_sources_url)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved support source as @support_source" do
        post :create, :github_support_source => invalid_attributes
        expect(assigns(:support_source)).to be_a_new(GithubSupportSource)
      end

      it "re-renders the 'new' template" do
        post :create, :github_support_source => invalid_attributes
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    let :new_attributes do
      {
        name: 'New name',
        github_owner_and_repo: 'phusion/unicorn'
      }
    end

    before :each do
      @user = create(:user)
      sign_in(@user)
      @source = create(:github_passenger, user: @user)
    end

    context "with valid params" do
      it "updates the requested support source" do
        put :update, id: @source.to_param, github_support_source: new_attributes
        @source.reload
        expect(@source.name).to eq('New name')
        expect(@source.github_owner_and_repo).to eq('phusion/unicorn')
      end

      it "assigns the requested support source as @support_source" do
        put :update, id: @source.to_param, github_support_source: new_attributes
        expect(assigns(:support_source)).to eq(@source)
      end

      it "redirects to the support source editing page" do
        put :update, id: @source.to_param, github_support_source: new_attributes
        expect(response).to redirect_to(edit_github_support_source_url(@source))
      end
    end

    context "with invalid params" do
      it "assigns the support source as @support_source" do
        put :update, id: @source.to_param, github_support_source: invalid_attributes
        expect(assigns(:support_source)).to eq(@source)
      end

      it "re-renders the 'edit' template" do
        put :update, id: @source.to_param, github_support_source: invalid_attributes
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      @user = create(:user)
      sign_in(@user)
      @source = create(:github_passenger, user: @user)
    end

    it "destroys the requested support source" do
      expect {
        delete :destroy, id: @source.to_param
      }.to change(GithubSupportSource, :count).by(-1)
    end

    it "redirects to the source source list" do
      delete :destroy, id: @source.to_param
      expect(response).to redirect_to(support_sources_url)
    end
  end

end
