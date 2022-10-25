struct Blockfrost::Health
  include JSON::Serializable

  getter is_healthy : Bool

  def self.get
    Health.from_json(Client.get("/health"))
  end

  def self.clock
    Clock.from_json(Client.get("/health/clock"))
  end

  struct Clock
    include JSON::Serializable

    @[JSON::Field(converter: Blockfrost::Json::TimeMsFromInt)]
    getter server_time : Time
  end
end
