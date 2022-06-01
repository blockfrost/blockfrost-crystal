struct Blockfrost::Block < Blockfrost::Resource
  MAX_BLOCK_SIZE_IN_BYTES = 88 * 1024

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
  getter previous_block : String?
  getter next_block : String?
  getter confirmations : Int32

  def self.get(hash_or_number : Int32 | String) : Block
    Block.from_json(client.get("blocks/#{hash_or_number}"))
  end

  def self.latest : Block
    get("latest")
  end

  {% for key in %w[next previous] %}
    def self.{{key.id}}(
      hash_or_number : Int32 | String,
      count : Int32? = nil,
      page : Int32? = nil
    ) : Array(Block)
      query = {"count" => count, "page" => page} of String => Int32?
      response = client.get("blocks/#{hash_or_number}/{{key.id}}", query)
      Array(Block).from_json(response)
    end

    def {{key.id}}(
      count : Int32? = nil,
      page : Int32? = nil
    ) : Array(Block)
      Block.{{key.id}}(hash, count: count, page: page)
    end
  {% end %}
end
