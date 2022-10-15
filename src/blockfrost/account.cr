struct Blockfrost::Account < Blockfrost::Resource
  getter stake_address : String
  getter active : Bool
  getter active_epoch : Int32?
  @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
  getter controlled_amount : Int64
  @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
  getter rewards_sum : Int64
  @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
  getter withdrawals_sum : Int64
  @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
  getter reserves_sum : Int64
  @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
  getter treasury_sum : Int64
  @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
  getter withdrawable_amount : Int64
  getter pool_id : String?

  def self.get(stake_address : String) : Account
    Account.from_json(client.get("accounts/#{stake_address}"))
  end

  {% for method, model in {
                            rewards:       "Reward",
                            history:       "Event",
                            delegations:   "Delegation",
                            registrations: "Registration",
                            withdrawals:   "Withdrawal",
                            mirs:          "Mir",
                            addresses:     "Address",
                          } %}
    def self.{{method.id}}(
      stake_address : String,
      order : QueryOrder? = nil,
      count : QueryCount? = nil,
      page : QueryPage? = nil
    ) : Array({{model.id}})
      Array({{model.id}}).from_json(
        client.get("accounts/#{stake_address}/{{method.id}}", {
          "order" => order.try(&.to_s),
          "count" => count,
          "page"  => page,
        })
      )
    end

    def self.{{method.id}}(
      stake_address : String,
      order : String,
      count : QueryCount? = nil,
      page : QueryPage? = nil
    ) : Array({{model.id}})
      {{method.id}}(stake_address, order_from_string(order), count, page)
    end
  {% end %}

  def self.assets_from_addresses(
    stake_address : String,
    order : QueryOrder? = nil,
    count : QueryCount? = nil,
    page : QueryPage? = nil
  ) : Array(Asset)
    Array(Asset).from_json(
      client.get("accounts/#{stake_address}/addresses/assets", {
        "order" => order.try(&.to_s),
        "count" => count,
        "page"  => page,
      })
    )
  end

  def self.assets_from_addresses(
    stake_address : String,
    order : String,
    count : QueryCount? = nil,
    page : QueryPage? = nil
  ) : Array(Asset)
    assets_from_addresses(stake_address, order_from_string(order), count, page)
  end

  def self.total_from_addresses(
    stake_address : String
  ) : Total
    Total.from_json(client.get("accounts/#{stake_address}/addresses/total"))
  end

  struct Reward
    include JSON::Serializable

    getter epoch : Int32
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter amount : Int64
    getter pool_id : String
    getter type : String
  end

  struct Event
    include JSON::Serializable

    getter active_epoch : Int32
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter amount : Int64
    getter pool_id : String
  end

  struct Delegation
    include JSON::Serializable

    getter active_epoch : Int32
    getter tx_hash : String
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter amount : Int64
    getter pool_id : String
  end

  struct Registration
    include JSON::Serializable

    getter tx_hash : String
    getter action : String
  end

  struct Withdrawal
    include JSON::Serializable

    getter tx_hash : String
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter amount : Int64
  end

  struct Mir
    include JSON::Serializable

    getter tx_hash : String
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter amount : Int64
  end

  struct Address
    include JSON::Serializable

    getter address : String
  end

  struct Asset
    include JSON::Serializable

    getter unit : String
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter quantity : Int64
  end

  struct Total
    include JSON::Serializable

    getter stake_address : String
    getter received_sum : Array(Unit)
    getter sent_sum : Array(Unit)
    getter tx_count : Int32
  end
end
