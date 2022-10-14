struct Blockfrost::Block < Blockfrost::Resource
  @[JSON::Field(converter: Blockfrost::Json::TimeFromInt)]
  getter time : Time
  getter height : Int32?
  getter hash : String
  getter slot : Int32?
  getter epoch : Int32?
  getter epoch_slot : Int32?
  getter slot_leader : String
  getter size : Int32
  getter tx_count : Int32
  @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
  getter output : Int64?
  @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
  getter fees : Int64?
  getter block_vrf : String?
  getter op_cert : String?
  @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
  getter op_cert_counter : Int64?
  getter previous_block : String?
  getter next_block : String?
  getter confirmations : Int32

  def self.get(hash_or_number : Int32 | String) : Block
    Block.from_json(client.get("blocks/#{hash_or_number}"))
  end

  def self.latest : Block
    get("latest")
  end

  def self.tx_ids(
    hash_or_number : Int32 | String,
    order : QueryOrder? = nil,
    count : QueryCount? = nil,
    page : QueryPage? = nil
  ) : Array(String)
    Array(String).from_json(
      client.get("blocks/#{hash_or_number}/txs", {
        "order" => order.try(&.to_s),
        "count" => count,
        "page"  => page,
      })
    )
  end

  def self.tx_ids(
    hash_or_number : Int32 | String,
    order : String? = nil,
    **args
  ) : Array(String)
    tx_ids(hash_or_number, order_from_string(order), **args)
  end

  def tx_ids(**args) : Array(String)
    Block.tx_ids(hash, **args)
  end

  def self.latest_tx_ids(**args) : Array(String)
    tx_ids("latest", **args)
  end

  {% for key in %w[next previous] %}
    def self.{{key.id}}(
      hash_or_number : Int32 | String,
      count : QueryCount? = nil,
      page : QueryPage? = nil
    ) : Array(Block)
      Array(Block).from_json(
        client.get("blocks/#{hash_or_number}/{{key.id}}", {
          "count" => count,
          "page" => page
        })
      )
    end

    def {{key.id}}(**args) : Array(Block)
      Block.{{key.id}}(hash, **args)
    end
  {% end %}

  def self.in_slot(
    slot_number : Int32
  ) : Block
    Block.from_json(client.get("blocks/slot/#{slot_number}"))
  end

  def self.in_epoch_in_slot(
    epoch_number : Int32,
    slot_number : Int32
  ) : Block
    Block.from_json(
      client.get("blocks/epoch/#{epoch_number}/slot/#{slot_number}")
    )
  end

  def self.addresses(
    hash_or_number : Int32 | String,
    count : QueryCount? = nil,
    page : QueryPage? = nil
  ) : Array(Address)
    Array(Address).from_json(
      client.get("blocks/#{hash_or_number}/addresses", {
        "count" => count,
        "page"  => page,
      })
    )
  end

  def addresses(**args) : Array(Address)
    Block.addresses(hash, **args)
  end

  struct Address
    include JSON::Serializable

    getter address : String
    getter transactions : Array(Transaction)
  end

  struct Transaction
    include JSON::Serializable

    getter tx_hash : String
  end
end
