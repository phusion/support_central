require 'thread'

class Scheduler
  # We want to schedule work to be done every hour
  # on the 5th minute. This is because the Supportbee
  # SLA enforcement script runs every hour on the 0th
  # minute.
  MINUTE_OFFSET = 5
  INTERVAL = 1.hour

  def initialize
    @mutex = Mutex.new
    @cond  = ConditionVariable.new
    # Possible states: idle, working, quit
    @state = :idle
    schedule(calculate_next_run_time)
  end

  def start_thread
    @thread ||= Thread.new do
      begin
        thread_main
      rescue Exception => e
        abort("*** Exception: #{e} (#{e.class})\n" \
          "#{e.backtrace.join("\n")}")
      end
    end
  end

  def shutdown
    return if !@thread
    @mutex.synchronize do
      @quit = true
      @cond.signal
    end
    @thread.join
    @thread = nil
  end

  def state
    @mutex.synchronize { @state }
  end

  def working?
    state == :working
  end

  def next_run_time
    @mutex.synchronize { @next_run_time }
  end

  def last_run_time
    @mutex.synchronize { @last_run_time }
  end

  def schedule_now
    schedule(Time.now)
  end

  def schedule_after(seconds)
    schedule(Time.now + seconds)
  end

protected
  def perform_work
    raise NotImplementedError
  end

private
  def schedule(time)
    time = [Time.now, time].max
    @mutex.synchronize do
      schedule_unlocked(time)
    end
  end

  def thread_main
    @mutex.synchronize do
      while !@quit
        while !@quit && Time.now < @next_run_time
          interval = @next_run_time - Time.now
          @cond.wait(@mutex, [interval, 0].max)
        end
        break if @quit

        @state = :working
        @next_run_time = nil

        @mutex.unlock
        begin
          perform_work
        ensure
          @mutex.lock
        end

        @state = :idle
        @last_run_time = Time.now
        break if @quit
        schedule_unlocked(calculate_next_run_time)
      end
      @state = :quit
    end
  end

  def schedule_unlocked(time)
    if @next_run_time.nil? || time < @next_run_time
      @next_run_time = time
      @cond.signal
    end
  end

  def calculate_next_run_time
    INTERVAL.from_now.beginning_of_hour + MINUTE_OFFSET
  end
end
