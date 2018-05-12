class AdminAreaController < ApplicationController
  def sync_github
    sync_scheduler(GithubScheduler.instance, 'Github')
    redirect_to admin_area_path
  end

  def sync_supportbee
    sync_scheduler(SupportbeeScheduler.instance, 'Supportbee')
    redirect_to admin_area_path
  end

  def sync_frontapp
    sync_scheduler(FrontappScheduler.instance, 'Frontapp')
    redirect_to admin_area_path
  end

  def sync_rss
    sync_scheduler(RssScheduler.instance, 'RSS')
    redirect_to admin_area_path
  end

  def sync_my_sources
    sources = current_user.support_sources.map(&:type_name).uniq
    sources.each do |name|
      sync_scheduler("#{name}Scheduler".constantize.send(:instance), name)
    end
    flash[:notice] = "Synchronization with #{sources.join(', ')} " \
    "#{SupportCentral::Application.config.cache_classes ? 'scheduled' : 'complete'}"
    redirect_to admin_area_path
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
  end
end
