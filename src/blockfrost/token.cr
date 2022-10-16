abstract struct Blockfrost::BaseToken
  include JSON::Serializable

  getter unit : String
  @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
  getter quantity : Int64
end

struct Blockfrost::Token < Blockfrost::BaseToken
  struct Extended < Blockfrost::BaseToken
    getter decimals : Int32?
    getter has_nft_onchain_metadata : Bool

    def to_unit : Float64
      return quantity.to_f unless places = decimals

      quantity / 10 ** places
    end
  end
end
