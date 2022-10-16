require "../spec_helper"

describe Blockfrost::Address do
  before_each do
    configure_api_keys
  end

  describe ".get" do
    it "fetches a specific address" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/addresses/#{fake_address}")
        .to_return(body: read_fixture("address/get.200.json"))

      Blockfrost::Address.get(fake_address).tap do |address|
        address.address.should eq(fake_address)
        address.amount.first.unit.should eq("lovelace")
        address.amount.first.quantity.should eq(42000000)
        address.stake_address
          .should eq("stake1ux3g2c9dx2nhhehyrezyxpkstartcqmu9hk63qgfkccw5rqttygt7")
        address.type.should eq("shelley")
        address.script.should be_falsey
      end
    end
  end

  describe ".extended" do
    it "fetches a specific address with extended information" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/addresses/#{fake_address}/extended")
        .to_return(body: read_fixture("address/extended.200.json"))

      Blockfrost::Address.extended(fake_address).tap do |address|
        address.address.should eq(fake_address)
        address.amount.first.unit.should eq("lovelace")
        address.amount.first.quantity.should eq(42000000)
        address.amount.first.decimals.should eq(6)
        address.amount.first.has_nft_onchain_metadata.should be_falsey
        address.amount.last.decimals.should be_nil
        address.stake_address
          .should eq("stake1ux3g2c9dx2nhhehyrezyxpkstartcqmu9hk63qgfkccw5rqttygt7")
        address.type.should eq("shelley")
        address.script.should be_falsey
      end
    end
  end
end

private def fake_address
  "addr1qxqs59lphg8g6qndelq8xwqn60ag3aeyfcp33c2kdp46a09re5df3pzwwmyq946axfcejy5n4x0y99wqpgtp2gd0k09qsgy6pz"
end
