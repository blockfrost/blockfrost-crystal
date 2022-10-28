struct Blockfrost::Token
  include JSON::Serializable
  include Shared::TokenFields

  struct Extended
    include JSON::Serializable
    include Shared::TokenFields

    getter decimals : Int32?
    getter has_nft_onchain_metadata : Bool

    def to_unit : Float64
      return quantity.to_f unless places = decimals

      quantity / 10 ** places
    end
  end
end
