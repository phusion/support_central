class DashboardController < ApplicationController
  def index
    @support_sources = current_user.support_sources.
      order(:position).
      includes(:tickets)
  end
end
