require 'rails_helper'

RSpec.describe Scheduler do
  before :each do
    @scheduler = Scheduler.new
    @mutex = Mutex.new
    @cond = ConditionVariable.new
    @work_count = 0
    @work_semaphore_count = 0
    @work_semaphore_cond = ConditionVariable.new
  end

  after :each do
    @scheduler.shutdown if @scheduler
  end

  def do_work
    @mutex.synchronize do
      @work_count += 1
      @last_work_time = Time.now
      @cond.broadcast
    end
  end

  def wait_for_work(count = 1)
    @mutex.synchronize do
      while @work_count < count
        @cond.wait(@mutex)
      end
    end
  end

  def do_blocking_work
    @mutex.synchronize do
      while @work_semaphore_count == 0
        @work_semaphore_cond.wait(@mutex)
      end

      @work_semaphore_count -= 1
      @work_count += 1
      @last_work_time = Time.now
      @cond.broadcast
    end
  end

  def unblock_work
    @mutex.synchronize do
      @work_semaphore_count += 1
      @work_semaphore_cond.broadcast
    end
  end

  describe 'initial state' do
    it 'is idle' do
      expect(@scheduler.state).to eq(:idle)
    end

    it 'is scheduled for about one hour from now' do
      expect(@scheduler.next_run_time.beginning_of_hour).to eq(
        1.hour.from_now.beginning_of_hour)
    end

    it 'does not have a last run time' do
      expect(@scheduler.last_run_time).to be_nil
    end
  end

  describe '#schedule_now' do
    it 'schedules work to be done as soon as possible' do
      expect(@scheduler).to receive(:perform_work) { do_work }
      @scheduler.start_thread
      @scheduler.schedule_now
      now = Time.now
      wait_for_work
      expect(@last_work_time).to be_within(0.5).of(now)
    end

    it 'schedules work to be done as soon as possible even ' \
       'if #schedule_after was called before' \
    do
      expect(@scheduler).to receive(:perform_work) { do_work }
      @scheduler.start_thread
      @scheduler.schedule_after(10)
      sleep 0.1
      @scheduler.schedule_now
      now = Time.now
      wait_for_work
      expect(@last_work_time).to be_within(0.5).of(now)
    end

    it 'schedules work to be done as soon as possible even ' \
       'if work is already being performed' \
    do
      expect(@scheduler).to receive(:perform_work) { do_blocking_work }.twice
      @scheduler.start_thread
      @scheduler.schedule_now

      eventually { @scheduler.working? }
      @scheduler.schedule_now
      expected_next_runtime = Time.now

      unblock_work # Unblock last work
      unblock_work # Unblock next work
      wait_for_work(2) # Wait for next work to be performed

      expect(@last_work_time).to be_within(0.25).of(expected_next_runtime)
    end
  end

  describe '#schedule_after' do
    it 'schedules work to be done after N seconds' do
      expect(@scheduler).to receive(:perform_work) { do_work }
      @scheduler.start_thread
      @scheduler.schedule_after(1)
      now = Time.now
      wait_for_work
      expect(@last_work_time).to be_within(0.25).of(now + 1)
    end

    it 'schedules work to be done after N seconds even ' \
       'if work is already being performed' \
    do
      expect(@scheduler).to receive(:perform_work) { do_blocking_work }.twice
      @scheduler.start_thread
      @scheduler.schedule_now

      eventually { @scheduler.working? }
      @scheduler.schedule_after(1)
      expected_next_runtime = Time.now + 1

      unblock_work # Unblock last work
      unblock_work # Unblock next work
      wait_for_work(2) # Wait for next work to be performed

      expect(@last_work_time).to be_within(0.25).of(expected_next_runtime)
    end
  end

  describe 'working' do
    it 'sets a last run time when done' do
      expect(@scheduler).to receive(:perform_work) { do_work }
      @scheduler.start_thread
      @scheduler.schedule_now
      wait_for_work
      expect(@scheduler.last_run_time).to be_within(2.seconds).of(Time.now)
    end

    it 'schedules the next run to be about one hour from now when done' do
      expect(@scheduler).to receive(:perform_work) { do_work }
      @scheduler.start_thread
      @scheduler.schedule_now
      wait_for_work
      expect(@scheduler.next_run_time.beginning_of_hour).to eq(
        1.hour.from_now.beginning_of_hour)
    end
  end
end
