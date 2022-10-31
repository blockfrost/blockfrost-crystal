require "../spec_helper"

describe Blockfrost::QueryString do
  describe "#build" do
    it "builds a query string" do
      Blockfrost::QueryString.new({"some" => "value", "id" => "123"}).build
        .should eq("some=value&id=123")
    end

    it "returns an empty value if no data is given" do
      Blockfrost::QueryString.new(Blockfrost::QueryData.new).build
        .should eq("")
    end

    it "returns an empty value if the query only constains empty values" do
      Blockfrost::QueryString.new({"some" => "", "id" => ""}).build
        .should eq("")
    end

    it "coerces 'count' values to fit within the accepted range" do
      Blockfrost::QueryString.new({"count" => 350}).build
        .should eq("count=100")
      Blockfrost::QueryString.new({"count" => 50}).build
        .should eq("count=50")
      Blockfrost::QueryString.new({"count" => 0}).build
        .should eq("count=1")
    end

    it "coerces 'page' values to fit within the accepted range" do
      Blockfrost::QueryString.new({"page" => 42_000_000}).build
        .should eq("page=21474836")
      Blockfrost::QueryString.new({"page" => 50}).build
        .should eq("page=50")
      Blockfrost::QueryString.new({"page" => 0}).build
        .should eq("page=1")
    end
  end
end
