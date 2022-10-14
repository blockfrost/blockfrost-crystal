struct Blockfrost::Asset < Blockfrost::Resource
  getter asset : String
  @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
  getter quantity : Int64
  getter policy_id : String
  getter asset_name : String?
  getter fingerprint : String
  getter initial_mint_tx_hash : String
  getter mint_or_burn_count : Int32
  getter onchain_metadata : OnchainMetadata?
  getter metadata : Metadata?

  def self.all(
    order : QueryOrder? = nil,
    count : QueryCount? = nil,
    page : QueryPage? = nil
  ) : Array(Abbreviated)
    Array(Abbreviated).from_json(
      client.get("assets", {
        "order" => order.try(&.to_s),
        "count" => count,
        "page"  => page,
      })
    )
  end

  def self.all(
    order : String,
    **args
  ) : Array(Abbreviated)
    all(order_from_string(order), **args)
  end

  def self.get(asset : String) : Asset
    Asset.from_json(client.get("assets/#{asset}"))
  end

  {% for resource, model in {
                              addresses:    "Address",
                              history:      "Event",
                              transactions: "Transaction",
                            } %}
    def self.{{resource.id}}(
      asset : String,
      order : QueryOrder? = nil,
      count : QueryCount? = nil,
      page : QueryPage? = nil
    ) : Array({{model.id}})
      Array({{model.id}}).from_json(
        client.get("assets/#{asset}/{{resource.id}}", {
          "order" => order.try(&.to_s),
          "count" => count,
          "page"  => page,
        })
      )
    end

    def self.{{resource.id}}(
      asset : String,
      order : String,
      **args
    ) : Array({{model.id}})
      {{resource.id}}(asset, order_from_string(order), **args)
    end

    def {{resource.id}}(**args) : Array({{model.id}})
      Asset.{{resource.id}}(**args)
    end
  {% end %}

  def self.all_of_policy(
    policy_id : String,
    order : QueryOrder? = nil,
    count : QueryCount? = nil,
    page : QueryPage? = nil
  ) : Array(Abbreviated)
    Array(Abbreviated).from_json(
      client.get("assets/policy/#{policy_id}", {
        "order" => order.try(&.to_s),
        "count" => count,
        "page"  => page,
      })
    )
  end

  def self.all_of_policy(
    policy_id : String,
    order : String,
    **args
  ) : Array(Abbreviated)
    all_of_policy(policy_id, order_from_string(order), **args)
  end

  struct Abbreviated
    include JSON::Serializable

    getter asset : String
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter quantity : Int64
  end

  struct OnchainMetadata
    include JSON::Serializable

    getter name : String
    getter image : String
  end

  struct Metadata
    include JSON::Serializable

    getter name : String
    getter description : String
    getter ticker : String
    getter url : String
    getter logo : String
    getter decimals : Int32
  end

  struct Address
    include JSON::Serializable

    getter address : String
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter quantity : Int64
  end

  struct Event
    include JSON::Serializable

    getter tx_hash : String
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter amount : Int64
    getter action : String
  end

  struct Transaction
    include JSON::Serializable

    getter tx_hash : String
    getter tx_index : Int32
    getter block_height : Int32
    @[JSON::Field(converter: Blockfrost::Json::TimeFromInt)]
    getter block_time : Time
  end
end
