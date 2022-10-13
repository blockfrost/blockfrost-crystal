require "../spec_helper"

describe Blockfrost::Block do
  before_each do
    configure_api_key
  end

  describe ".get" do
    it "fetches a given epoch" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/epoch/225")
        .to_return(body: read_fixture("epoch/epoch.200.json"))

      Blockfrost::Epoch.get(225).should be_a(Blockfrost::Epoch)
    end
  end

  describe ".latest" do
    it "fetches the latest epoch" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/epoch/latest")
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
end
