module Blockfrost::Shared::TokenFields
  getter unit : String
  @[JSON::Field(converter: Blockfrost::Int128FromString)]
  getter quantity : Int128
end
