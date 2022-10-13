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
    count : QueryCount? = nil,
    page : QueryPage? = nil,
    order : QueryOrder? = nil
  ) : Array(String)
    Array(String).from_json(
      client.get("blocks/#{hash_or_number}/txs", {
        "count" => count,
        "page"  => page,
        "order" => order.try(&.to_s),
      })
    )
  end

  def self.tx_ids(
    hash_or_number : Int32 | String,
    count : QueryCount? = nil,
    page : QueryPage? = nil,
    order : String? = nil
  ) : Array(String)
    tx_ids(
      hash_or_number,
      count,
      page,
      order ? QueryOrder.from_string(order) : nil
    )
  end

  def tx_ids(
    count : QueryCount? = nil,
    page : QueryPage? = nil,
    order : QueryOrder | String? = nil
  ) : Array(String)
    Block.tx_ids(hash, count, page, order)
  end

  def self.latest_tx_ids(
    count : QueryCount? = nil,
    page : QueryPage? = nil,
    order : String | QueryOrder? = nil
  ) : Array(String)
    tx_ids("latest", count, page, order)
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

    def {{key.id}}(
      count : QueryCount? = nil,
      page : QueryPage? = nil
    ) : Array(Block)
      Block.{{key.id}}(hash, count: count, page: page)
    end
  {% end %}

  def self.in_slot(slot_number : Int32) : Block
    Block.from_json(client.get("blocks/slot/#{slot_number}"))
  end
end
