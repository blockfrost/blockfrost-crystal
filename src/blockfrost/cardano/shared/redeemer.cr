module Blockfrost::Shared::Redeemer
  Blockfrost.enum_castable_from_string(Purpose, {
    Spend,
    Mint,
    Cert,
    Reward,
  })

  getter tx_index : Int32
  getter purpose : Purpose
  getter redeemer_data_hash : String
  getter datum_hash : String
  @[JSON::Field(converter: Blockfrost::Int64FromString)]
  getter unit_mem : Int64
  @[JSON::Field(converter: Blockfrost::Int64FromString)]
  getter unit_steps : Int64
  @[JSON::Field(converter: Blockfrost::Int64FromString)]
  getter fee : Int64
end
