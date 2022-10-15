require "../spec_helper"

describe Blockfrost::Lovelace do
  describe "serialization" do
    it "parses a unit with a quantity" do
      unit = Blockfrost::Lovelace.from_json(read_fixture("unit/lovelace.json"))

      unit.quantity.should eq(42000000)
      unit.unit.should eq("lovelace")
    end
  end

  describe "#to_ada" do
    it "returns the lovelace quantity in ada" do
      unit = Blockfrost::Lovelace.from_json(read_fixture("unit/lovelace.json"))

      unit.to_ada.should eq(unit.quantity / 1_000_000)
    end
  end
end
