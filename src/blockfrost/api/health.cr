struct Blockfrost::Health
  include JSON::Serializable

  getter is_healthy : Bool

  def self.get
    Health.from_json(Client.get("health"))
  end

  def self.is_healthy
    get.is_healthy
  end

  def self.clock
    Clock.from_json(Client.get("health/clock"))
  end

  def self.server_time
    clock.server_time
  end

  struct Clock
    include JSON::Serializable

    @[JSON::Field(converter: Blockfrost::TimeMsFromInt)]
    getter server_time : Time
  end
end
