module Blockfrost::Shared::TokenFields
  getter unit : String
  @[JSON::Field(converter: Blockfrost::Int64FromString)]
  getter quantity : Int64
end
