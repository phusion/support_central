module SpecSupport
  # Asserts that something should eventually happen. This is done by checking
  # that the given block eventually returns true. The block is called
  # once every `check_interval` msec. If the block does not return true
  # within `deadline_duration` secs, then an exception is raised.
  def eventually(deadline_duration = 3, check_interval = 0.05)
    deadline = Time.now + deadline_duration
    while Time.now < deadline
      if yield
        return
      else
        sleep(check_interval)
      end
    end
    raise 'Time limit exceeded'
  end

  # Asserts that something should never happen. This is done by checking that
  # the given block never returns true. The block is called once every
  # `check_interval` msec, until `deadline_duration` seconds have passed.
  # If the block ever returns true, then an exception is raised.
  def should_never_happen(deadline_duration = 0.5, check_interval = 0.05)
    deadline = Time.now + deadline_duration
    while Time.now < deadline
      if yield
        raise "That which shouldn't happen happened anyway"
      else
        sleep(check_interval)
      end
    end
  end
end
