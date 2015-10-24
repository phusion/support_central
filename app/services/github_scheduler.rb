class GithubScheduler < Scheduler
protected
  def perform_work
    GithubAnalyzer.new.analyze
  end
end
