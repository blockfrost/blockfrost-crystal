require "../../spec_helper"

describe Blockfrost::Asset do
  before_each do
    configure_api_keys
  end

  describe ".all" do
    it "fetches all assets in abbreviated form" do
      WebMock.stub(:get, "https://cardano-testnet.blockfrost.io/api/v0/assets")
        .to_return(body: read_fixture("asset/all.200.json"))

      assets = Blockfrost::Asset.all
      assets.should be_a(Array(Blockfrost::Asset::Abbreviated))
      assets.first.asset.should eq(
        "b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a76e7574636f696e"
      )
      assets.last.quantity.should eq(18605647)
    end

    it "accepts ordering and pagination parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/assets?order=desc&count=10&page=2"
      ).to_return(body: read_fixture("asset/all.200.json"))

      Blockfrost::Asset.all(order: "desc", count: 10, page: 2)
        .should be_a(Array(Blockfrost::Asset::Abbreviated))
    end
  end

  describe ".get" do
    it "fetches a specific asset" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/assets/b0d07d45...")
        .to_return(body: read_fixture("asset/asset.200.json"))

      asset = Blockfrost::Asset.get("b0d07d45...")
      asset.asset.should eq(
        "b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a76e7574636f696e"
      )
      asset.policy_id.should eq(
        "b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a7"
      )
      asset.asset_name.should eq("6e7574636f696e")
      asset.fingerprint.should eq(
        "asset1pkpwyknlvul7az0xx8czhl60pyel45rpje4z8w"
      )
      asset.quantity.should eq(12000)
      asset.initial_mint_tx_hash.should eq(
        "6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad"
      )
      asset.mint_or_burn_count.should eq(1)

      metadata = asset.onchain_metadata.as(Blockfrost::Asset::OnchainMetadata)
      metadata.name.should eq("My NFT token")
      metadata.image.should eq(
        "ipfs://ipfs/QmfKyJ4tuvHowwKQCbCHj4L5T3fSj8cjs7Aau8V7BWv226"
      )

      metadata = asset.metadata.as(Blockfrost::Asset::Metadata)
      metadata.name.should eq("nutcoin")
      metadata.description.should eq("The Nut Coin")
      metadata.ticker.should eq("nutc")
      metadata.url.should eq("https://www.stakenuts.com/")
      metadata.logo.should start_with("iVBORw0KGgoAAAANSUhEUg")
      metadata.decimals.should eq(6)
    end
  end

  describe ".history" do
    it "fetches all events for a given asset" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/assets/b0d07d45.../history")
        .to_return(body: read_fixture("asset/history.200.json"))

      events = Blockfrost::Asset.history("b0d07d45...")
      events.first.tx_hash.should start_with("2dd15e0ef6")
      events.first.amount.should eq(10)
      events.first.action.should eq(Blockfrost::Asset::Event::Action::Minted)
      events.last.action.should eq(Blockfrost::Asset::Event::Action::Burned)
    end

    it "accepts ordering and pagination parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/assets/b0d07d45.../history?order=desc&count=3&page=5")
        .to_return(body: read_fixture("asset/history.200.json"))

      Blockfrost::Asset.history("b0d07d45...", order: "desc", count: 3, page: 5)
        .should be_a(Array(Blockfrost::Asset::Event))
    end
  end

  describe "#history" do
    it "fetches events for the current asset" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/assets/b0d07d45...")
        .to_return(body: read_fixture("asset/asset.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/assets/b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a76e7574636f696e/history")
        .to_return(body: read_fixture("asset/history.200.json"))

      Blockfrost::Asset.get("b0d07d45...").history
        .should be_a(Array(Blockfrost::Asset::Event))
    end
  end

  describe ".transactions" do
    it "fetches all transactions for a given asset" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/assets/b0d07d45.../transactions")
        .to_return(body: read_fixture("asset/transactions.200.json"))

      transaction = Blockfrost::Asset.transactions("b0d07d45...").first
      transaction.tx_hash.should start_with("8788591983")
      transaction.tx_index.should eq(6)
      transaction.block_height.should eq(69)
      transaction.block_time.should eq(Time.unix(1635505891))
    end

    it "accepts ordering and pagination parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/assets/b0d07d45.../transactions?order=desc&count=3&page=5")
        .to_return(body: read_fixture("asset/transactions.200.json"))

      Blockfrost::Asset.transactions("b0d07d45...", order: "desc", count: 3, page: 5)
        .should be_a(Array(Blockfrost::Asset::Transaction))
    end
  end

  describe "#transactions" do
    it "fetches transactions for the current asset" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/assets/b0d07d45...")
        .to_return(body: read_fixture("asset/asset.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/assets/b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a76e7574636f696e/transactions")
        .to_return(body: read_fixture("asset/transactions.200.json"))

      Blockfrost::Asset.get("b0d07d45...").transactions
        .should be_a(Array(Blockfrost::Asset::Transaction))
    end
  end

  describe ".addresses" do
    it "fetches all addresses for a given asset" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/assets/b0d07d45.../addresses")
        .to_return(body: read_fixture("asset/addresses.200.json"))

      address = Blockfrost::Asset.addresses("b0d07d45...").first
      address.address.should start_with("addr1qxqs59lp")
      address.quantity.should eq(1)
    end

    it "accepts ordering and pagination parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/assets/b0d07d45.../addresses?order=desc&count=3&page=5")
        .to_return(body: read_fixture("asset/addresses.200.json"))

      Blockfrost::Asset.addresses("b0d07d45...", order: "desc", count: 3, page: 5)
        .should be_a(Array(Blockfrost::Asset::Address))
    end
  end

  describe "#addresses" do
    it "fetches addresses for the current asset" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/assets/b0d07d45...")
        .to_return(body: read_fixture("asset/asset.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/assets/b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a76e7574636f696e/addresses")
        .to_return(body: read_fixture("asset/addresses.200.json"))

      Blockfrost::Asset.get("b0d07d45...").addresses
        .should be_a(Array(Blockfrost::Asset::Address))
    end
  end

  describe ".all_of_policy" do
    it "fetches all assets for a given policy id" do
      WebMock.stub(:get, "https://cardano-testnet.blockfrost.io/api/v0/assets/policy/476039a0...")
        .to_return(body: read_fixture("asset/policy.200.json"))

      Blockfrost::Asset.all_of_policy("476039a0...")
        .should be_a(Array(Blockfrost::Asset::Abbreviated))
    end

    it "accepts ordering and pagination parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/assets/policy/476039a0...?order=desc&count=10&page=2"
      ).to_return(body: read_fixture("asset/policy.200.json"))

      Blockfrost::Asset.all_of_policy(
        policy_id: "476039a0...",
        order: "desc",
        count: 10,
        page: 2
      ).should be_a(Array(Blockfrost::Asset::Abbreviated))
    end
  end
end
