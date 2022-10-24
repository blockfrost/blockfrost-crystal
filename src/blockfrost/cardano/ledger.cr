struct Blockfrost::Ledger < Blockfrost::BaseResource
  def self.genesis
    Genesis.from_json(client.get("genesis"))
  end

  struct Genesis
    include JSON::Serializable

    getter active_slots_coefficient : Float64
    getter update_quorum : Int32
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter max_lovelace_supply : Int64
    getter network_magic : Int32
    getter epoch_length : Int32
    getter system_start : Int32
    getter slots_per_kes_period : Int32
    getter slot_length : Int32
    getter max_kes_evolutions : Int32
    getter security_param : Int32
  end
end
