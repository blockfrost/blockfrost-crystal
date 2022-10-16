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
        address.amount.first.quantity.should eq(42_000_000)
        address.stake_address.should eq(
          "stake1ux3g2c9dx2nhhehyrezyxpkstartcqmu9hk63qgfkccw5rqttygt7"
        )
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
        address.amount.first.quantity.should eq(42_000_000)
        address.amount.first.decimals.should eq(6)
        address.amount.first.has_nft_onchain_metadata.should be_falsey
        address.amount.last.decimals.should be_nil
        address.stake_address.should eq(
          "stake1ux3g2c9dx2nhhehyrezyxpkstartcqmu9hk63qgfkccw5rqttygt7"
        )
        address.type.should eq("shelley")
        address.script.should be_falsey
      end
    end
  end

  describe ".total" do
    it "fetches the address' totals" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/addresses/#{fake_address}/total")
        .to_return(body: read_fixture("address/total.200.json"))

      Blockfrost::Address.total(fake_address).tap do |total|
        total.address.should eq(fake_address)
        total.received_sum.first.unit.should eq("lovelace")
        total.received_sum.first.quantity.should eq(42_000_000)
        total.sent_sum.last.unit.should start_with("b0d07d45fe")
        total.sent_sum.last.quantity.should eq(12)
        total.tx_count.should eq(12)
      end
    end
  end

  describe ".utxos" do
    it "fetches the address' current utxos" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/addresses/#{fake_address}/utxos")
        .to_return(body: read_fixture("address/utxos.200.json"))

      Blockfrost::Address.utxos(fake_address).tap do |utxos|
        utxos.first.tx_hash.should eq(
          "39a7a284c2a0948189dc45dec670211cd4d72f7b66c5726c08d9b3df11e44d58"
        )
        utxos.first.output_index.should eq(0)
        utxos.first.amount.first.unit.should eq("lovelace")
        utxos.first.amount.first.quantity.should eq(42_000_000)
        utxos.first.block.should eq(
          "7eb8e27d18686c7db9a18f8bbcfe34e3fed6e047afaa2d969904d15e934847e6"
        )
        utxos.first.data_hash.should eq(
          "9e478573ab81ea7a8e31891ce0648b81229f408d596a3483e6f4f9b92d3cf710"
        )
        utxos.first.inline_datum.should be_nil,
          utxos.first.reference_script_hash.should be_nil
      end
    end

    it "accepts ordering and pagination parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/addresses/#{fake_address}/utxos?order=desc&count=10&page=1")
        .to_return(body: read_fixture("address/utxos.200.json"))

      Blockfrost::Address.utxos(fake_address, "desc", 10, 1)
        .should be_a(Array(Blockfrost::Address::UTXO))
    end
  end
end

private def fake_address
  "addr1qxqs59lphg8g6qndelq8xwqn60ag3aeyfcp33c2kdp46a09re5df3pzwwmyq946axfcejy5n4x0y99wqpgtp2gd0k09qsgy6pz"
end
