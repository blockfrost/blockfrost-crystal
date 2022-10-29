require "../../spec_helper"

describe Blockfrost::Datum do
  before_each do
    configure_api_keys
  end

  describe ".json" do
    it "fetches json for a given datum" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/scripts/datum/#{test_datum_hash}")
        .to_return(body_io: read_fixture("datum/json.200.json"))

      Blockfrost::Datum.json(test_datum_hash).dig?("int").should eq(42)
    end
  end

  describe ".cbor" do
    it "fetches cbor for a given datum" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/scripts/datum/#{test_datum_hash}/cbor")
        .to_return(body_io: read_fixture("datum/cbor.200.json"))

      Blockfrost::Datum.cbor(test_datum_hash).should eq("19a6aa")
    end
  end
end

private def test_datum_hash
  "db583ad85881a96c73fbb26ab9e24d1120bb38f45385664bb9c797a2ea8d9a2d"
end
