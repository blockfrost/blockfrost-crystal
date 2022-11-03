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
      Blockfrost::QueryString.new({"some" => "", "id" => nil}).build
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

    it "coerces 'order' values" do
      Blockfrost::QueryString.new({"order" => Blockfrost::QueryOrder::ASC}).build
        .should eq("order=asc")
      Blockfrost::QueryString.new({"order" => Blockfrost::QueryOrder::DESC}).build
        .should eq("order=desc")
      Blockfrost::QueryString.new({"order" => "asc"}).build
        .should eq("order=asc")
      Blockfrost::QueryString.new({"order" => "desc"}).build
        .should eq("order=desc")
      Blockfrost::QueryString.new({"order" => "abc"}).build
        .should eq("")
    end

    it "always adds 'order' if the default is different from the api's default" do
      Blockfrost.temp_config(
        default_order: Blockfrost::DEFAULT_API_ORDER
      ) do
        Blockfrost::QueryString.new({"page" => "2"}).build
          .should eq("page=2")
        Blockfrost::QueryString.new({"order" => "abc"}).build
          .should eq("")
      end

      Blockfrost.temp_config(
        default_order: Blockfrost::QueryOrder::DESC
      ) do
        Blockfrost::QueryString.new({"page" => "3"}).build
          .should eq("order=desc&page=3")
        Blockfrost::QueryString.new({"order" => "abc"}).build
          .should eq("order=desc")
      end
    end

    it "always adds 'count' if the default is different from the api's default" do
      Blockfrost.temp_config(
        default_count_per_page: Blockfrost::DEFAULT_API_COUNT_PER_PAGE
      ) do
        Blockfrost::QueryString.new({"page" => "2"}).build
          .should eq("page=2")
      end

      Blockfrost.temp_config(
        default_count_per_page: 42
      ) do
        Blockfrost::QueryString.new({"page" => "3"}).build
          .should eq("count=42&page=3")
      end
    end
  end
end
