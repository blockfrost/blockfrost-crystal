require "../spec_helper"

describe Blockfrost::Token do
  describe "serialization" do
    it "parses a token with a quantity" do
      token = Blockfrost::Token.from_json(read_fixture("token/base.json"))

      token.quantity.should eq(42000000)
      token.unit.should eq("lovelace")
    end
  end
end

describe Blockfrost::Token::Extended do
  describe "serialization" do
    it "parses a token with a quantity and extended info" do
      token = Blockfrost::Token::Extended.from_json(
        read_fixture("token/extended.json")
      )

      token.quantity.should eq(42000000)
      token.unit.should eq("lovelace")
      token.decimals.should eq(6)
      token.has_nft_onchain_metadata.should be_falsey
    end
  end

  describe "#to_unit" do
    it "applies the decimals to the quantity" do
      token = Blockfrost::Token::Extended.from_json(
        read_fixture("token/extended.json")
      )

      token.quantity.should eq(42000000)
      token.to_unit.should eq(42.0)
    end

    it "returns the quantity as a float in case no decimal values are given" do
      token = Blockfrost::Token::Extended.from_json(
        read_fixture("token/extended-no-decimals.json")
      )

      token.quantity.should eq(12)
      token.to_unit.should eq(12.0)
    end
  end
end
