struct Blockfrost::Block < Blockfrost::BaseResource
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

  get_all_with_order_and_pagination(
    :tx_ids,
    Array(String),
    "blocks/#{hash_or_number}/txs",
    hash_or_number : Int32 | String
  )

  def self.latest_tx_ids(**args) : Array(String)
    tx_ids("latest", **args)
  end

  {% for method in %w[next previous] %}
    get_all_with_pagination(
      :{{method.id}},
      Array(Block),
      "blocks/#{hash_or_number}/{{method.id}}",
      hash_or_number : Int32 | String
    )
  {% end %}

  def self.in_slot(slot_number : Int32) : Block
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

  get_all_with_pagination(
    :addresses,
    Array(Address),
    "blocks/#{hash_or_number}/addresses",
    hash_or_number : Int32 | String
  )

  private def hash_or_number : String
    hash
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
