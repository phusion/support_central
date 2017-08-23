if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    THREAD_POOL = Concurrent::FixedThreadPool.new(16)
  end
else
  THREAD_POOL = Concurrent::FixedThreadPool.new(16)
end

def execute_future(options = {}, &block)
  Concurrent::Future.execute(options.reverse_merge(executor: THREAD_POOL), &block)
end
