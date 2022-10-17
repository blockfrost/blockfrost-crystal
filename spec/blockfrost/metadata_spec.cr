require "../spec_helper"

describe Blockfrost::Metadata do
  before_each do
    configure_api_keys
  end

  describe ".labels" do
    it "fetches labels" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/metadata/txs/labels")
        .to_return(body: read_fixture("metadata/labels.200.json"))

      Blockfrost::Metadata.labels.tap do |labels|
        labels.first.label.should eq("1990")
        labels.first.cip10.should be_nil
        labels.first.count.should eq(1)
        labels.last.label.should eq("1968")
        labels.last.cip10.should eq("nut.link metadata oracles data points")
        labels.last.count.should eq(16321)
      end
    end

    it "accepts ordering and pagination labels" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/metadata/txs/labels?order=desc&count=1&page=1")
        .to_return(body: read_fixture("metadata/labels.200.json"))

      Blockfrost::Metadata.labels("desc", 1, 1)
        .should be_a(Array(Blockfrost::Metadata::Label))
    end
  end

  describe ".label_json_content" do
    it "fetches the transaction metadata for the given label" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/metadata/txs/labels/1990")
        .to_return(body: read_fixture("metadata/json-content.200.json"))

      Blockfrost::Metadata.label_json_content("1990").tap do |txs|
        txs.first.tx_hash.should eq(
          "257d75c8ddb0434e9b63e29ebb6241add2b835a307aa33aedba2effe09ed4ec8"
        )
        txs.first.json_metadata.should be_a(JSON::Any)
        txs.first.json_metadata.dig("ADAUSD").should eq(
          [
            {
              "value"  => "0.10409800535729975",
              "source" => "ergoOracles",
            },
          ]
        )
        txs.last.json_metadata.should be_a(JSON::Any)
        txs.last.json_metadata.as_nil.should be_nil
      end
    end

    it "accepts ordering and pagination parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/metadata/txs/labels/1990?order=desc&count=1&page=1")
        .to_return(body: read_fixture("metadata/json-content.200.json"))

      Blockfrost::Metadata.label_json_content("1990", "desc", 1, 1)
        .should be_a(Array(Blockfrost::Metadata::JsonContent))
    end
  end

  describe ".label_cbor_content" do
    it "fetches the transaction metadata for the given label" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/metadata/txs/labels/1990/cbor")
        .to_return(body: read_fixture("metadata/cbor-content.200.json"))

      Blockfrost::Metadata.label_cbor_content("1990").tap do |txs|
        txs.first.tx_hash.should eq(
          "257d75c8ddb0434e9b63e29ebb6241add2b835a307aa33aedba2effe09ed4ec8"
        )
        txs.first.cbor_metadata.should be_nil
        txs.first.metadata.should be_nil

        txs.last.tx_hash.should eq(
          "4237501da3cfdd53ade91e8911e764bd0699d88fd43b12f44a1f459b89bc91be"
        )
        txs.last.cbor_metadata
          .should eq("\\xa100a16b436f6d62696e6174696f6e8601010101010c")
        txs.last.metadata
          .should eq("a100a16b436f6d62696e6174696f6e8601010101010c")
      end
    end

    it "accepts ordering and pagination parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/metadata/txs/labels/1990/cbor?order=desc&count=1&page=1")
        .to_return(body: read_fixture("metadata/cbor-content.200.json"))

      Blockfrost::Metadata.label_cbor_content("1990", "desc", 1, 1)
        .should be_a(Array(Blockfrost::Metadata::CborContent))
    end
  end
end
