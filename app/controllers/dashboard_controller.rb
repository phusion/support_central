class DashboardController < ApplicationController
  def index
    @support_sources = current_user.support_sources.
      order(:position).
      includes(:tickets)
  end

  def ignore
    support_source = current_user.support_sources.find(
      params[:support_source_id])
    tickets = support_source.tickets.where(id: params[:ticket_ids])
    IgnoreMarker.ignore(tickets)

    if SupportCentral::Application.config.cache_classes
      support_source.scheduler.schedule_now
    else
      support_source.scheduler.perform_directly
    end

    render text: 'ok'
  end
end
