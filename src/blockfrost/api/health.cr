struct Blockfrost::Health
  include JSON::Serializable

  getter is_healthy : Bool

  # Return backend status as a boolean. Your application should handle
  # situations when backend for the given chain is unavailable.
  #
  # ```
  # Blockfrost::Health.get.is_healthy
  # # => true
  # ```
  def self.get
    Health.from_json(Client.get("health"))
  end

  # Alias for `.get.is_healthy`.
  #
  # ```
  # Blockfrost::Health.is_healthy?
  # # => true
  # ```
  def self.is_healthy?
    get.is_healthy
  end

  # This endpoint provides the current UNIX time. Your application might use
  # this to verify if the client clock is not out of sync.
  #
  # ```
  # Blockfrost::Health.clock.server_time
  # # => 2020-10-22 21:09:18.947000000 UTC
  # ```
  def self.clock
    Clock.from_json(Client.get("health/clock"))
  end

  # Alias for `.clock.server_time`.
  #
  # ```
  # Blockfrost::Health.server_time
  # # => 2020-10-22 21:09:18.947000000 UTC
  # ```
  def self.server_time
    clock.server_time
  end

  struct Clock
    include JSON::Serializable

    @[JSON::Field(converter: Blockfrost::TimeMsFromInt)]
    getter server_time : Time
  end
end
