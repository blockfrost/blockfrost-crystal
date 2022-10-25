struct Blockfrost::Datum
  def self.json(datum_hash : String)
    JSON.from_json(Client.get("scripts/datum/#{datum_hash}")).value
  end

  def self.cbor(datum_hash : String)
    CBOR.from_json(Client.get("scripts/datum/#{datum_hash}/cbor")).value
  end

  struct JSON
    include ::JSON::Serializable

    @[::JSON::Field(key: "json_value")]
    getter value : ::JSON::Any
  end

  struct CBOR
    include ::JSON::Serializable

    @[::JSON::Field(key: "cbor")]
    getter value : String
  end
end
