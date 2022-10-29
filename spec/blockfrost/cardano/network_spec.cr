require "../../spec_helper"

describe Blockfrost::Network do
  before_each do
    configure_api_keys
  end

  describe ".get" do
    it "fetches fetailed network information" do
      WebMock.stub(:get, "https://cardano-testnet.blockfrost.io/api/v0/network")
        .to_return(body_io: read_fixture("network/get.200.json"))

      network = Blockfrost::Network.get
      network.supply.max.should eq(45000000000000000)
      network.supply.total.should eq(32890715183299160)
      network.supply.circulating.should eq(32412601976210393)
      network.supply.locked.should eq(125006953355)
      network.supply.treasury.should eq(98635632000000)
      network.supply.reserves.should eq(46635632000000)
      network.stake.live.should eq(23204950463991654)
      network.stake.active.should eq(22210233523456321)
    end
  end
end
