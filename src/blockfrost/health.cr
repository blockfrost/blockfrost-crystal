struct Blockfrost::Health < Blockfrost::BaseResource
  getter is_healthy : Bool

  def self.get : Health
    Health.from_json(client.get("/health"))
  end

  def self.clock : Clock
    Clock.from_json(client.get("/health/clock"))
  end

  struct Clock
    include JSON::Serializable

    @[JSON::Field(converter: Blockfrost::Json::TimeMsFromInt)]
    getter server_time : Time
  end
end
