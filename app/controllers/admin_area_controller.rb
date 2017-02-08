class AdminAreaController < ApplicationController
  def sync_github
    sync_scheduler(GithubScheduler.instance, 'Github')
  end

  def sync_supportbee
    sync_scheduler(SupportbeeScheduler.instance, 'Supportbee')
  end

  def sync_frontapp
    sync_scheduler(FrontappScheduler.instance, 'Frontapp')
  end

private
  def sync_scheduler(scheduler, source_name)
    if SupportCentral::Application.config.cache_classes
      flash[:notice] = "Synchronization with #{source_name} scheduled."
      scheduler.schedule_now
    else
      flash[:notice] = "Synchronization with #{source_name} complete."
      scheduler.perform_directly
    end
    redirect_to admin_area_path
  end
end
