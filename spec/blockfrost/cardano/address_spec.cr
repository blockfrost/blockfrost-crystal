require "../../spec_helper"

describe Blockfrost::Address do
  before_each do
    configure_api_keys
  end

  describe ".get" do
    it "fetches a specific address" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/addresses/#{test_address}")
        .to_return(body_io: read_fixture("address/get.200.json"))

      address = Blockfrost::Address.get(test_address)
      address.address.should eq(test_address)
      address.amount.first.unit.should eq("lovelace")
      address.amount.first.quantity.should eq(42_000_000)
      address.stake_address.should eq(
        "stake1ux3g2c9dx2nhhehyrezyxpkstartcqmu9hk63qgfkccw5rqttygt7"
      )
      address.type.should eq(Blockfrost::Address::Type::Shelley)
      address.script.should be_falsey
    end
  end

  describe ".extended" do
    it "fetches a specific address with extended information" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/addresses/#{test_address}/extended")
        .to_return(body_io: read_fixture("address/extended.200.json"))

      address = Blockfrost::Address.extended(test_address)
      address.address.should eq(test_address)
      address.amount.first.unit.should eq("lovelace")
      address.amount.first.quantity.should eq(42_000_000)
      address.amount.first.decimals.should eq(6)
      address.amount.first.has_nft_onchain_metadata.should be_falsey
      address.amount.last.decimals.should be_nil
      address.stake_address.should eq(
        "stake1ux3g2c9dx2nhhehyrezyxpkstartcqmu9hk63qgfkccw5rqttygt7"
      )
      address.type.should eq(Blockfrost::Address::Type::Shelley)
      address.script.should be_falsey
    end
  end

  describe ".total" do
    it "fetches the address' totals" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/addresses/#{test_address}/total")
        .to_return(body_io: read_fixture("address/total.200.json"))

      total = Blockfrost::Address.total(test_address)
      total.address.should eq(test_address)
      total.received_sum.first.unit.should eq("lovelace")
      total.received_sum.first.quantity.should eq(42_000_000)
      total.sent_sum.last.unit.should start_with("b0d07d45fe")
      total.sent_sum.last.quantity.should eq(12)
      total.tx_count.should eq(12)
    end
  end

  describe ".utxos" do
    it "fetches the address' current utxos" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/addresses/#{test_address}/utxos")
        .to_return(body_io: read_fixture("address/utxos.200.json"))

      utxo = Blockfrost::Address.utxos(test_address).first
      utxo.tx_hash.should eq(
        "39a7a284c2a0948189dc45dec670211cd4d72f7b66c5726c08d9b3df11e44d58"
      )
      utxo.output_index.should eq(0)
      utxo.amount.first.unit.should eq("lovelace")
      utxo.amount.first.quantity.should eq(42_000_000)
      utxo.block.should eq(
        "7eb8e27d18686c7db9a18f8bbcfe34e3fed6e047afaa2d969904d15e934847e6"
      )
      utxo.data_hash.should eq(
        "9e478573ab81ea7a8e31891ce0648b81229f408d596a3483e6f4f9b92d3cf710"
      )
      utxo.inline_datum.should be_nil
      utxo.reference_script_hash.should be_nil
    end

    it "accepts ordering and pagination parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/addresses/#{test_address}/utxos?order=desc&count=10&page=1")
        .to_return(body_io: read_fixture("address/utxos.200.json"))

      Blockfrost::Address.utxos(test_address, "desc", 10, 1)
        .should be_a(Array(Blockfrost::Address::UTXO))
    end

    it "fetches the address' current utxos concurrently" do
      1.upto(2) do |p|
        WebMock.stub(:get,
          "https://cardano-testnet.blockfrost.io/api/v0/addresses/#{test_address}/utxos?order=desc&page=#{p}")
          .to_return(body_io: read_fixture("address/utxos.200.json"))
      end

      Blockfrost::Address.utxos(test_address, pages: 1..2, order: "desc")
        .size.should eq(6)
    end
  end

  describe "#utxos" do
    it "fetches current address' current utxos" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/addresses/#{test_address}")
        .to_return(body_io: read_fixture("address/get.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/addresses/#{test_address}/utxos")
        .to_return(body_io: read_fixture("address/utxos.200.json"))

      Blockfrost::Address.get(test_address).utxos
        .should be_a(Array(Blockfrost::Address::UTXO))
    end
  end

  describe ".utxos_of_asset" do
    it "fetches the address' current utxos for a given asset" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/addresses/#{test_address}/utxos/#{test_asset}")
        .to_return(body_io: read_fixture("address/utxos-of-asset.200.json"))

      utxo = Blockfrost::Address.utxos_of_asset(test_address, test_asset).first
      utxo.tx_hash.should eq(
        "39a7a284c2a0948189dc45dec670211cd4d72f7b66c5726c08d9b3df11e44d58"
      )
      utxo.output_index.should eq(0)
      utxo.amount.first.unit.should eq("lovelace")
      utxo.amount.first.quantity.should eq(42_000_000)
      utxo.block.should eq(
        "7eb8e27d18686c7db9a18f8bbcfe34e3fed6e047afaa2d969904d15e934847e6"
      )
      utxo.data_hash.should eq(
        "9e478573ab81ea7a8e31891ce0648b81229f408d596a3483e6f4f9b92d3cf710"
      )
      utxo.inline_datum.should be_nil
      utxo.reference_script_hash.should be_nil
    end

    it "accepts ordering and pagination parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/addresses/#{test_address}/utxos/#{test_asset}?order=desc&count=10&page=1")
        .to_return(body_io: read_fixture("address/utxos-of-asset.200.json"))

      Blockfrost::Address.utxos_of_asset(test_address, test_asset, "desc", 10, 1)
        .should be_a(Array(Blockfrost::Address::UTXO))
    end

    it "fetches the address' current utxos for a given asset concurrently" do
      1.upto(2) do |p|
        WebMock.stub(:get,
          "https://cardano-testnet.blockfrost.io/api/v0/addresses/#{test_address}/utxos/#{test_asset}?page=#{p}")
          .to_return(body_io: read_fixture("address/utxos-of-asset.200.json"))
      end

      Blockfrost::Address.utxos_of_asset(test_address, test_asset, pages: 1..2)
        .size.should eq(6)
    end
  end

  describe "#utxos_of_asset" do
    it "fetches current address' current utxos for a given asset" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/addresses/#{test_address}")
        .to_return(body_io: read_fixture("address/get.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/addresses/#{test_address}/utxos/#{test_asset}")
        .to_return(body_io: read_fixture("address/utxos-of-asset.200.json"))

      Blockfrost::Address.get(test_address).utxos_of_asset(test_asset)
        .should be_a(Array(Blockfrost::Address::UTXO))
    end
  end

  describe ".transactions" do
    it "fetches the address' transactions" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/addresses/#{test_address}/transactions")
        .to_return(body_io: read_fixture("address/transactions.200.json"))

      tx = Blockfrost::Address.transactions(test_address).first
      tx.tx_hash.should eq(
        "8788591983aa73981fc92d6cddbbe643959f5a784e84b8bee0db15823f575a5b"
      )
      tx.tx_index.should eq(6)
      tx.block_height.should eq(69)
      tx.block_time.should eq(Time.unix(1635505891))
    end

    it "accepts ordering, pagination, from and to parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/addresses/#{test_address}/transactions?order=desc&count=10&page=1&from=8929261&to=9999269:10")
        .to_return(body_io: read_fixture("address/transactions.200.json"))

      Blockfrost::Address.transactions(
        test_address,
        order: "desc",
        count: 10,
        page: 1,
        from: "8929261",
        to: "9999269:10"
      ).should be_a(Array(Blockfrost::Address::Transaction))
    end

    it "fetches the address' transactions concurrently" do
      1.upto(2) do |p|
        WebMock.stub(:get,
          "https://cardano-testnet.blockfrost.io/api/v0/addresses/#{test_address}/transactions?order=desc&page=#{p}&from=8929261&to=9999269:10")
          .to_return(body_io: read_fixture("address/transactions.200.json"))
      end

      Blockfrost::Address.transactions(
        test_address,
        pages: 1..2,
        order: "desc",
        from: "8929261",
        to: "9999269:10"
      ).size.should eq(6)
    end
  end

  describe "#transactions" do
    it "fetches the current address' transactions" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/addresses/#{test_address}")
        .to_return(body_io: read_fixture("address/get.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/addresses/#{test_address}/transactions?from=8929261")
        .to_return(body_io: read_fixture("address/transactions.200.json"))

      Blockfrost::Address.get(test_address).transactions(from: "8929261")
        .should be_a(Array(Blockfrost::Address::Transaction))
    end
  end

  describe Blockfrost::Address::Type do
    it "allows being strict about address types" do
      address = Blockfrost::Address.from_json(
        read_fixture("address/get.200.json")
      )

      expect_raises(Exception, "it's shelley") do
        case address.type
        in Blockfrost::Address::Type::Byron
          raise "it's byron"
        in Blockfrost::Address::Type::Shelley
          raise "it's shelley"
        end
      end
    end
  end
end

private def test_address
  "addr1qxqs59lphg8g6qndelq8xwqn60ag3aeyfcp33c2kdp46a09re5df3pzwwmyq946axfcejy5n4x0y99wqpgtp2gd0k09qsgy6pz"
end

private def test_asset
  "b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a76e7574636f696e"
end
