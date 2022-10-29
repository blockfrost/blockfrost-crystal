require "../../spec_helper"

describe Blockfrost::Ledger do
  before_each do
    configure_api_keys
  end

  describe ".genesis" do
    it "fetches the information about blockchain genesis" do
      WebMock.stub(:get, "https://cardano-testnet.blockfrost.io/api/v0/genesis")
        .to_return(body_io: read_fixture("ledger/genesis.200.json"))

      genesis = Blockfrost::Ledger.genesis
      genesis.active_slots_coefficient.should eq(0.05)
      genesis.update_quorum.should eq(5)
      genesis.max_lovelace_supply.should eq(45000000000000000)
      genesis.network_magic.should eq(764824073)
      genesis.epoch_length.should eq(432000)
      genesis.system_start.should eq(1506203091)
      genesis.slots_per_kes_period.should eq(129600)
      genesis.slot_length.should eq(1)
      genesis.max_kes_evolutions.should eq(62)
      genesis.security_param.should eq(2160)
    end
  end
end
