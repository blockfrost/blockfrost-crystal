require "../spec_helper"

describe Blockfrost::QueryString do
  describe "#build" do
    it "builds a query string" do
      Blockfrost::QueryString.new({"some" => "value", "id" => "123"}).build
        .should eq("some=value&id=123")
    end

    it "returns an empty value if no data is given" do
      Blockfrost::QueryString.new(Blockfrost::RequestData.new).build
        .should eq("")
    end

    it "returns an empty value if the query only constains empty values" do
      Blockfrost::QueryString.new({"some" => "", "id" => ""}).build
        .should eq("")
    end
  end
end
