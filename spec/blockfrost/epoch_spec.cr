require "../spec_helper"

describe Blockfrost::Epoch do
  before_each do
    configure_api_key
  end

  describe ".get" do
    it "fetches a given epoch" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/epochs/225")
        .to_return(body: read_fixture("epoch/epoch.200.json"))

      Blockfrost::Epoch.get(225).should be_a(Blockfrost::Epoch)
    end
  end

  describe ".latest" do
    it "fetches the latest epoch" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/epochs/latest")
        .to_return(body: read_fixture("epoch/latest.200.json"))

      Blockfrost::Epoch.latest.tap do |epoch|
        epoch.epoch.should eq(225)
        epoch.start_time.should eq(Time.unix(1603403091))
        epoch.end_time.should eq(Time.unix(1603835086))
        epoch.first_block_time.should eq(Time.unix(1603403092))
        epoch.last_block_time.should eq(Time.unix(1603835084))
        epoch.block_count.should eq(21298)
        epoch.tx_count.should eq(17856)
        epoch.output.should eq(7849943934049314)
        epoch.fees.should eq(4203312194)
        epoch.active_stake.should eq(784953934049314)
      end
    end
  end

  describe ".next" do
    it "fetches the next epoch for a given hash" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/epochs/225/next")
        .to_return(body: read_fixture("epoch/next.200.json"))

      Blockfrost::Epoch.next(225).first.should be_a(Blockfrost::Epoch)
    end

    it "fetches the next number of epochs at a given page" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/epochs/225/next?count=3&page=2")
        .to_return(body: read_fixture("epoch/next.200.json"))

      Blockfrost::Epoch.next(225, count: 3, page: 2).first
        .should be_a(Blockfrost::Epoch)
    end
  end

  describe "#next" do
    it "fetches the next epoch in relation to the current epoch" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/epochs/225")
        .to_return(body: read_fixture("epoch/epoch.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/epochs/225/next")
        .to_return(body: read_fixture("epoch/next.200.json"))

      Blockfrost::Epoch.get(225).next.first
        .should be_a(Blockfrost::Epoch)
    end
  end

  describe ".previous" do
    it "fetches the previous block for a given hash" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/epochs/225/previous")
        .to_return(body: read_fixture("epoch/previous.200.json"))

      Blockfrost::Epoch.previous(225).first.should be_a(Blockfrost::Epoch)
    end

    it "fetches the previous number of epochs at a given page" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/epochs/225/previous?count=3&page=2")
        .to_return(body: read_fixture("epoch/previous.200.json"))

      Blockfrost::Epoch.previous(225, count: 3, page: 2).first
        .should be_a(Blockfrost::Epoch)
    end
  end

  describe "#previous" do
    it "fetches the previous block in relation to the current block" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/epochs/225")
        .to_return(body: read_fixture("epoch/epoch.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/epochs/225/previous")
        .to_return(body: read_fixture("epoch/previous.200.json"))

      Blockfrost::Epoch.get(225).previous.first
        .should be_a(Blockfrost::Epoch)
    end
  end
end
