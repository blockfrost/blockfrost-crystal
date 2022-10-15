require "../spec_helper"

describe Blockfrost::Unit do
  describe "serialization" do
    it "parses a unit with a quantity" do
      unit = Blockfrost::Unit.from_json(read_fixture("unit/lovelace.json"))

      unit.quantity.should eq(42000000)
      unit.unit.should eq("lovelace")
    end
  end
end
