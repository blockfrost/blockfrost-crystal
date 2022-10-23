require "../spec_helper"

describe Blockfrost do
  describe Blockfrost::QueryOrder do
    describe "#to_s" do
      it "converts enum values to downcase" do
        Blockfrost::QueryOrder::ASC.to_s.should eq("asc")
        Blockfrost::QueryOrder::DESC.to_s.should eq("desc")
      end
    end

    describe ".from_string" do
      it "creates an enum value from a string" do
        Blockfrost::QueryOrder.from_string("asc")
          .should eq(Blockfrost::QueryOrder::ASC)
        Blockfrost::QueryOrder.from_string("desc")
          .should eq(Blockfrost::QueryOrder::DESC)
      end
    end
  end

  describe Blockfrost::ContentType do
    describe "#to_s" do
      it "converts enum values to content type strings" do
        Blockfrost::ContentType::Json.to_s.should eq("application/json")
        Blockfrost::ContentType::Cbor.to_s.should eq("application/cbor")
      end
    end
  end
end
