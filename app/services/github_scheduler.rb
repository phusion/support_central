class GithubScheduler < Scheduler
  if SupportCentral::Application.config.cache_classes
    def self.instance
      GITHUB_SCHEDULER
    end
  else
    def self.instance
      GithubScheduler.new
    end
  end

protected
  def perform_work(integrate_with_parent_transaction)
    GithubAnalyzer.new.analyze(integrate_with_parent_transaction)
  end
end
