struct Blockfrost::Pool < Blockfrost::BaseResource
  include JSON::Serializable

  getter pool_id : String
  getter hex : String
  getter vrf_key : String
  getter blocks_minted : Int32
  getter blocks_epoch : Int32
  @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
  getter live_stake : Int64
  getter live_size : Float64
  getter live_saturation : Float64
  getter live_delegators : Int32
  @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
  getter active_stake : Int64
  getter active_size : Float64
  @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
  getter declared_pledge : Int64
  @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
  getter live_pledge : Int64
  getter margin_cost : Float64
  @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
  getter fixed_cost : Int64
  getter reward_account : String
  getter owners : Array(String)
  getter registration : Array(String)
  getter retirement : Array(String)

  gets_all_with_order_and_pagination(
    :all_ids,
    Array(String),
    "pools"
  )

  gets_all_with_order_and_pagination(
    :all_ids_with_stake,
    Array(Abbreviated),
    "pools/extended"
  )

  gets_all_with_order_and_pagination(
    :retired_ids,
    Array(Retired),
    "pools/retired"
  )

  gets_all_with_order_and_pagination(
    :retiring_ids,
    Array(Retiring),
    "pools/retiring"
  )

  def self.get(pool_id : String) : Pool
    Pool.from_json(client.get("pools/#{pool_id}"))
  end

  gets_all_with_order_and_pagination(
    :history,
    Array(Event),
    "pools/#{pool_id}/history",
    pool_id : String
  )

  struct Abbreviated
    include JSON::Serializable

    getter pool_id : String
    getter hex : String
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter active_stake : Int64
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
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
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter active_stake : Int64
    getter active_size : Float64
    getter delegators_count : Int32
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter rewards : Int64
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter fees : Int64
  end
end
