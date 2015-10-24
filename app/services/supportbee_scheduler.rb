class SupportbeeScheduler < Scheduler
protected
  def perform_work
    SupportbeeAnalyzer.new.analyze
  end
end
