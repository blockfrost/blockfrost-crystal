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
