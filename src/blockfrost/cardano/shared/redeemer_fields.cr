module Blockfrost::Shared::RedeemerFields
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
  @[JSON::Field(converter: Blockfrost::Int128FromString)]
  getter unit_mem : Int128
  @[JSON::Field(converter: Blockfrost::Int128FromString)]
  getter unit_steps : Int128
  @[JSON::Field(converter: Blockfrost::Int128FromString)]
  getter fee : Int128
end
