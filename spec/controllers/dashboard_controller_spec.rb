require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  before :each do
    @current_user = create(:user)
    @other_user = create(:user2)
    @frontapp = create(:frontapp, user: @current_user)
    @github = create(:github_passenger, user: @current_user)

    ticket1 = create(:ruby_5_0_not_supported, support_source: @frontapp)
    ticket2 = create(:ruby_5_0_not_supported, support_source: @github)
  end

  describe "current user dashboard" do 
    before :each do
      sign_in(@current_user)
      get :index
    end
    it "has the number of sources + 1" do
      expect(assigns(:support_sources).count).to eq(3) 
    end

    it "has the total number of tickets" do
      expect(@frontapp.tickets.count).to eq(1)
      expect(@github.tickets.count).to eq(1)
      expect(assigns(:all_tickets)[:tickets].count).to eq(2)
    end
  end 

  describe "other user dashboard" do 
    before :each do
      sign_in(@other_user)
      get :index
    end
    it "has zero tickets" do 
      expect(assigns(:all_tickets)[:tickets].count).to eq(0)
    end
    it "has 1 source only" do
      expect(assigns(:support_sources).count).to eq(1)
    end 
  end
end
