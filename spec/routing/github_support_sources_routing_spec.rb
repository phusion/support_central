require "rails_helper"

RSpec.describe GithubSupportSourcesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/github_support_sources").to route_to("github_support_sources#index")
    end

    it "routes to #new" do
      expect(:get => "/github_support_sources/new").to route_to("github_support_sources#new")
    end

    it "routes to #show" do
      expect(:get => "/github_support_sources/1").to route_to("github_support_sources#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/github_support_sources/1/edit").to route_to("github_support_sources#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/github_support_sources").to route_to("github_support_sources#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/github_support_sources/1").to route_to("github_support_sources#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/github_support_sources/1").to route_to("github_support_sources#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/github_support_sources/1").to route_to("github_support_sources#destroy", :id => "1")
    end

  end
end
