require "../../spec_helper"

describe Blockfrost::Nutlink do
  before_each do
    configure_api_keys
  end

  describe ".get" do
    it "fetches a nutlink address" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/nutlink/#{fake_address}")
        .to_return(body: read_fixture("nutlink/address.200.json"))

      nutlink = Blockfrost::Nutlink.get(fake_address)
      nutlink.address.should eq(fake_address)
      nutlink.metadata_url.should eq("https://nut.link/metadata.json")
      nutlink.metadata_hash.should eq(
        "6bf124f217d0e5a0a8adb1dbd8540e1334280d49ab861127868339f43b3948af"
      )
      nutlink.metadata.should be_a(JSON::Any)
    end
  end

  describe ".tickers" do
    it "fetchers records of a specific ticker" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/nutlink/#{fake_address}/tickers")
        .to_return(body: read_fixture("nutlink/tickers.200.json"))

      ticker = Blockfrost::Nutlink.tickers(fake_address).first
      ticker.name.should eq("ADAUSD")
      ticker.count.should eq(1980038)
      ticker.latest_block.should eq(2657092)
    end

    it "accepts ordering and pagination parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/nutlink/#{fake_address}/tickers?order=desc")
        .to_return(body: read_fixture("nutlink/tickers.200.json"))

      Blockfrost::Nutlink.tickers(fake_address, "desc")
        .should be_a(Array(Blockfrost::Nutlink::Ticker))
    end
  end

  describe "#tickers" do
    it "fetchers the current records of a specific ticker" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/nutlink/#{fake_address}")
        .to_return(body: read_fixture("nutlink/address.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/nutlink/#{fake_address}/tickers")
        .to_return(body: read_fixture("nutlink/tickers.200.json"))

      Blockfrost::Nutlink.get(fake_address).tickers
        .should be_a(Array(Blockfrost::Nutlink::Ticker))
    end
  end

  describe ".ticker_records_for_address" do
    it "fetchers a record of a specific ticker" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/nutlink/#{fake_address}/tickers/#{fake_ticker}")
        .to_return(body: read_fixture("nutlink/ticker_records.200.json"))

      ticker = Blockfrost::Nutlink.ticker_records_for_address(
        fake_address,
        fake_ticker
      ).first
      ticker.tx_hash.should eq(
        "e8073fd5318ff43eca18a852527166aa8008bee9ee9e891f585612b7e4ba700b"
      )
      ticker.block_height.should eq(2657092)
      ticker.tx_index.should eq(8)
      ticker.payload.should be_a(JSON::Any)
    end

    it "accepts ordering and pagination parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/nutlink/#{fake_address}/tickers/#{fake_ticker}?order=desc")
        .to_return(body: read_fixture("nutlink/ticker_records.200.json"))

      Blockfrost::Nutlink.ticker_records_for_address(fake_address, fake_ticker, "desc")
        .should be_a(Array(Blockfrost::Nutlink::Ticker::Record))
    end
  end

  describe ".ticker_records" do
    it "fetchers a record of a specific ticker" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/nutlink/tickers/#{fake_ticker}")
        .to_return(body: read_fixture("nutlink/ticker_records.200.json"))

      ticker = Blockfrost::Nutlink.ticker_records(fake_ticker).first
      ticker.tx_hash.should eq(
        "e8073fd5318ff43eca18a852527166aa8008bee9ee9e891f585612b7e4ba700b"
      )
      ticker.block_height.should eq(2657092)
      ticker.tx_index.should eq(8)
      ticker.payload.should be_a(JSON::Any)
    end

    it "accepts ordering and pagination parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/nutlink/tickers/#{fake_ticker}?order=desc")
        .to_return(body: read_fixture("nutlink/ticker_records.200.json"))

      Blockfrost::Nutlink.ticker_records(fake_ticker, "desc")
        .should be_a(Array(Blockfrost::Nutlink::Ticker::Record))
    end
  end
end

private def fake_address
  "addr1qxqs59lphg8g6qndelq8xwqn60ag3aeyfcp33c2kdp46a09re5df3pzwwmyq946axfcejy5n4x0y99wqpgtp2gd0k09qsgy6pz"
end

private def fake_ticker
  "ADAUSD"
end