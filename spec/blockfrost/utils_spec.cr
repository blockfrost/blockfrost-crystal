require "../spec_helper"

describe Blockfrost::Utils do
  describe ".sanitize_query" do
    it "removes nils" do
      Blockfrost::Utils.sanitize_query({"some" => "value", "just" => nil})
        .should eq({"some" => "value"})
    end

    it "converts int to strings" do
      Blockfrost::Utils.sanitize_query({"id" => 123})
        .should eq({"id" => "123"})
    end
  end
end
