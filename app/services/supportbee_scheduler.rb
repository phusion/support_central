class SupportbeeScheduler < Scheduler
  if SupportCentral::Application.config.cache_classes
    def self.instance
      SUPPORTBEE_SCHEDULER
    end
  else
    def self.instance
      SupportbeeScheduler.new
    end
  end

protected
  def perform_work(integrate_with_parent_transaction)
    SupportbeeAnalyzer.new.analyze(integrate_with_parent_transaction)
  end
end
