class RssScheduler < Scheduler
  if SupportCentral::Application.config.cache_classes
    def self.instance
      RSS_SCHEDULER
    end
  else
    def self.instance
      RssScheduler.new
    end
  end

protected
  def perform_work(integrate_with_parent_transaction)
    RssAnalyzer.new.analyze(integrate_with_parent_transaction)
  end
end
