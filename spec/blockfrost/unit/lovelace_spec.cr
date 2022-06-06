require "../../spec_helper"

describe Blockfrost::Unit::Lovelace do
  describe "serialization" do
    it "parses a unit with a quantity" do
      unit = Blockfrost::Unit.from_json(read_fixture("classes/lovelace.json"))

      unit.value.should eq(42000000)
      unit.unit.should eq("lovelace")
    end
  end

  describe "#to_ada" do
    it "returns the lovelace value in ada" do
      unit = Blockfrost::Unit.from_json(read_fixture("classes/lovelace.json"))

      unit.to_ada.should eq(unit.value / 1_000_000)
    end
  end
end
