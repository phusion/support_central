class DashboardController < ApplicationController
  def index
    @support_sources = current_user.support_sources.includes(:tickets)
  end
end
