require "../../spec_helper"

describe Blockfrost::Epoch do
  before_each do
    configure_api_keys
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

      epoch = Blockfrost::Epoch.latest
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

  describe ".stakes" do
    it "fetches the stakes for an epoch" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/epochs/225/stakes")
        .to_return(body: read_fixture("epoch/stakes.200.json"))

      stakes = Blockfrost::Epoch.stakes(225)
      stakes.should be_a(Array(Blockfrost::Epoch::Stake))
      stakes.first.stake_address.should eq(
        "stake1u9l5q5jwgelgagzyt6nuaasefgmn8pd25c8e9qpeprq0tdcp0e3uk"
      )
      stakes.first.pool_id.should eq(
        "pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2q3lkdy"
      )
      stakes.first.amount.should eq(4440295078)
    end

    it "fetches the stakes with pagination parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/epochs/225/stakes?count=3&page=2")
        .to_return(body: read_fixture("epoch/stakes.200.json"))

      Blockfrost::Epoch.stakes(225, count: 3, page: 2)
        .should be_a(Array(Blockfrost::Epoch::Stake))
    end
  end

  describe "#stakes" do
    it "fetches the stakes for the current epoch" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/epochs/latest")
        .to_return(body: read_fixture("epoch/latest.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/epochs/225/stakes")
        .to_return(body: read_fixture("epoch/stakes.200.json"))

      Blockfrost::Epoch.latest.stakes
        .should be_a(Array(Blockfrost::Epoch::Stake))
    end
  end

  describe ".stakes_by_pool" do
    it "fetches the stakes by pool with pagination parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/epochs/225/stakes/pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2q3lkdy?count=3&page=2")
        .to_return(body: read_fixture("epoch/stakes.200.json"))

      pool_id = "pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2q3lkdy"

      Blockfrost::Epoch.stakes_by_pool(225, pool_id, count: 3, page: 2)
        .should be_a(Array(Blockfrost::Epoch::Stake))
    end
  end

  describe "#stakes_by_pool" do
    it "fetches the stakes by pool with pagination parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/epochs/latest")
        .to_return(body: read_fixture("epoch/latest.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/epochs/225/stakes/pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2q3lkdy?count=3&page=2")
        .to_return(body: read_fixture("epoch/stakes.200.json"))

      pool_id = "pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2q3lkdy"

      Blockfrost::Epoch.latest.stakes_by_pool(pool_id, count: 3, page: 2)
        .should be_a(Array(Blockfrost::Epoch::Stake))
    end
  end

  describe ".block_hashes" do
    it "fetches the block ids the given epoch" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/epochs/225/blocks?count=3&page=2")
        .to_return(body: read_fixture("epoch/blocks.200.json"))

      Blockfrost::Epoch.block_hashes(225, count: 3, page: 2).should eq([
        "d0fa315687e99ccdc96b14cc2ea74a767405d64427b648c470731a9b69e4606e",
        "38bc6efb92a830a0ed22a64f979d120d26483fd3c811f6622a8c62175f530878",
        "f3258fcd8b975c061b4fcdcfcbb438807134d6961ec278c200151274893b6b7d",
      ])
    end
  end

  describe "#block_hashes" do
    it "fetches block ids for the current epoch" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/epochs/latest")
        .to_return(body: read_fixture("epoch/latest.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/epochs/225/blocks")
        .to_return(body: read_fixture("epoch/blocks.200.json"))

      Blockfrost::Epoch.latest.block_hashes.should be_a(Array(String))
    end
  end

  describe ".block_hashes_by_pool" do
    it "fetches the block ids the given epoch for a given pool" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/epochs/225/blocks/#{fake_pool_id}?count=3&page=2")
        .to_return(body: read_fixture("epoch/blocks.200.json"))

      Blockfrost::Epoch.block_hashes_by_pool(
        225,
        fake_pool_id,
        count: 3,
        page: 2
      ).should be_a(Array(String))
    end
  end

  describe "#block_hashes_by_pool" do
    it "fetches block ids for the current epoch for a given pool" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/epochs/latest")
        .to_return(body: read_fixture("epoch/latest.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/epochs/225/blocks/#{fake_pool_id}")
        .to_return(body: read_fixture("epoch/blocks.200.json"))

      Blockfrost::Epoch.latest.block_hashes_by_pool(fake_pool_id)
        .should be_a(Array(String))
    end
  end

  describe ".parameters" do
    it "fetches the parameters for the given epoch" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/epochs/225/parameters")
        .to_return(body: read_fixture("epoch/parameters.200.json"))

      Blockfrost::Epoch.parameters(225).tap do |parameters|
        parameters.should be_a(Blockfrost::Epoch::Parameters)
        parameters.epoch.should eq(225)
        parameters.pool_deposit.should eq(500000000)
        parameters.decentralisation_param.should eq(0.5)
        parameters.cost_models
          .as(Hash)
          .dig("PlutusV2", "addInteger-cpu-arguments-intercept")
          .should eq(197209)
        parameters.coins_per_utxo_size.should eq(34482)
      end
    end
  end
end

private def fake_pool_id
  "pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2q3lkdy"
end
