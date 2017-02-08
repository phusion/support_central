class FrontappScheduler < Scheduler
  if SupportCentral::Application.config.cache_classes
    def self.instance
      FRONTAPP_SCHEDULER
    end
  else
    def self.instance
      FrontappScheduler.new
    end
  end

protected
  def perform_work(integrate_with_parent_transaction)
    FrontappAnalyzer.new.analyze(integrate_with_parent_transaction)
  end
end
