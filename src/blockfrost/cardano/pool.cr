struct Blockfrost::Pool
  include JSON::Serializable

  include JSON::Serializable

  getter pool_id : String
  getter hex : String
  getter vrf_key : String
  getter blocks_minted : Int32
  getter blocks_epoch : Int32
  @[JSON::Field(converter: Blockfrost::Int64FromString)]
  getter live_stake : Int64
  getter live_size : Float64
  getter live_saturation : Float64
  getter live_delegators : Int32
  @[JSON::Field(converter: Blockfrost::Int64FromString)]
  getter active_stake : Int64
  getter active_size : Float64
  @[JSON::Field(converter: Blockfrost::Int64FromString)]
  getter declared_pledge : Int64
  @[JSON::Field(converter: Blockfrost::Int64FromString)]
  getter live_pledge : Int64
  getter margin_cost : Float64
  @[JSON::Field(converter: Blockfrost::Int64FromString)]
  getter fixed_cost : Int64
  getter reward_account : String
  getter owners : Array(String)
  getter registration : Array(String)
  getter retirement : Array(String)

  Blockfrost.gets_all_with_order_and_pagination(
    :all_ids,
    Array(String),
    "pools"
  )

  Blockfrost.gets_all_with_order_and_pagination(
    :all_ids_with_stake,
    Array(Abbreviated),
    "pools/extended"
  )

  Blockfrost.gets_all_with_order_and_pagination(
    :retired_ids,
    Array(Retired),
    "pools/retired"
  )

  Blockfrost.gets_all_with_order_and_pagination(
    :retiring_ids,
    Array(Retiring),
    "pools/retiring"
  )

  def self.get(pool_id : String)
    Pool.from_json(Client.get("pools/#{pool_id}"))
  end

  Blockfrost.gets_all_with_order_and_pagination(
    :history,
    Array(Event),
    "pools/#{pool_id}/history",
    pool_id : String
  )

  def self.metadata(pool_id : String)
    Metadata.from_json(Client.get("pools/#{pool_id}/metadata"))
  end

  def metadata
    self.class.metadata(pool_id)
  end

  def self.relays(pool_id : String)
    Array(Relay).from_json(Client.get("pools/#{pool_id}/relays"))
  end

  def relays
    self.class.relays(pool_id)
  end

  Blockfrost.gets_all_with_order_and_pagination(
    :delegators,
    Array(Delegator),
    "pools/#{pool_id}/delegators",
    pool_id : String
  )

  Blockfrost.gets_all_with_order_and_pagination(
    :block_hashes,
    Array(String),
    "pools/#{pool_id}/blocks",
    pool_id : String
  )

  Blockfrost.gets_all_with_order_and_pagination(
    :updates,
    Array(Update),
    "pools/#{pool_id}/updates",
    pool_id : String
  )

  struct Abbreviated
    include JSON::Serializable

    getter pool_id : String
    getter hex : String
    @[JSON::Field(converter: Blockfrost::Int64FromString)]
    getter active_stake : Int64
    @[JSON::Field(converter: Blockfrost::Int64FromString)]
    getter live_stake : Int64
  end

  struct Retired
    include JSON::Serializable

    getter pool_id : String
    getter epoch : Int32
  end

  struct Retiring
    include JSON::Serializable

    getter pool_id : String
    getter epoch : Int32
  end

  struct Event
    include JSON::Serializable

    getter epoch : Int32
    getter blocks : Int32
    @[JSON::Field(converter: Blockfrost::Int64FromString)]
    getter active_stake : Int64
    getter active_size : Float64
    getter delegators_count : Int32
    @[JSON::Field(converter: Blockfrost::Int64FromString)]
    getter rewards : Int64
    @[JSON::Field(converter: Blockfrost::Int64FromString)]
    getter fees : Int64
  end

  struct Metadata
    include JSON::Serializable
    include Shared::PoolMetadata

    getter pool_id : String
    getter hex : String
  end

  struct Relay
    include JSON::Serializable
    include Shared::PoolRelay
  end

  struct Delegator
    include JSON::Serializable

    getter address : String
    @[JSON::Field(converter: Blockfrost::Int64FromString)]
    getter live_stake : Int64
  end

  struct Update
    include JSON::Serializable

    Blockfrost.enum_castable_from_string(Action, {
      Registered,
      Deregistered,
    })

    getter tx_hash : String
    getter cert_index : Int32
    getter action : Action
  end
end
