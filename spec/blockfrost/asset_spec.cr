require "../spec_helper"

describe Blockfrost::Asset do
  before_each do
    configure_api_key
  end

  describe ".all" do
    it "fetches all assets in abbreviated form" do
      WebMock.stub(:get, "https://cardano-testnet.blockfrost.io/api/v0/assets")
        .to_return(body: read_fixture("asset/all.200.json"))

      Blockfrost::Asset.all.tap do |assets|
        assets.should be_a(Array(Blockfrost::Asset::Abbreviated))
        assets.first.asset.should eq(
          "b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a76e7574636f696e"
        )
        assets.last.quantity.should eq(18605647)
      end
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

      Blockfrost::Asset.get("b0d07d45...").tap do |asset|
        asset.asset
          .should eq("b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a76e7574636f696e")
        asset.policy_id
          .should eq("b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a7")
        asset.asset_name.should eq("6e7574636f696e")
        asset.fingerprint
          .should eq("asset1pkpwyknlvul7az0xx8czhl60pyel45rpje4z8w")
        asset.quantity.should eq(12000)
        asset.initial_mint_tx_hash
          .should eq("6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad")
        asset.mint_or_burn_count.should eq(1)

        metadata = asset.onchain_metadata.as(Blockfrost::Asset::OnchainMetadata)
        metadata.name.should eq("My NFT token")
        metadata.image
          .should eq("ipfs://ipfs/QmfKyJ4tuvHowwKQCbCHj4L5T3fSj8cjs7Aau8V7BWv226")

        metadata = asset.metadata.as(Blockfrost::Asset::Metadata)
        metadata.name.should eq("nutcoin")
        metadata.description.should eq("The Nut Coin")
        metadata.ticker.should eq("nutc")
        metadata.url.should eq("https://www.stakenuts.com/")
        metadata.logo.should start_with("iVBORw0KGgoAAAANSUhEUg")
        metadata.decimals.should eq(6)
      end
    end
  end

  describe ".history" do
    it "fetches all events for a given asset" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/assets/b0d07d45.../history")
        .to_return(body: read_fixture("asset/history.200.json"))

      Blockfrost::Asset.history("b0d07d45...").tap do |events|
        events.first.tx_hash.should start_with("2dd15e0ef6")
        events.first.amount.should eq(10)
        events.first.action.should start_with("minted")
        events.last.action.should start_with("burned")
      end
    end

    it "accepts ordering and pagination parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/assets/b0d07d45.../history?order=desc&count=3&page=5")
        .to_return(body: read_fixture("asset/history.200.json"))

      Blockfrost::Asset.history("b0d07d45...", order: "desc", count: 3, page: 5)
        .should be_a(Array(Blockfrost::Asset::Event))
    end
  end

  describe ".transactions" do
    it "fetches all transactions for a given asset" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/assets/b0d07d45.../transactions")
        .to_return(body: read_fixture("asset/transactions.200.json"))

      Blockfrost::Asset.transactions("b0d07d45...").tap do |transactions|
        transactions.first.tx_hash.should start_with("8788591983")
        transactions.first.tx_index.should eq(6)
        transactions.first.block_height.should eq(69)
        transactions.first.block_time.should eq(Time.unix(1635505891))
      end
    end

    it "accepts ordering and pagination parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/assets/b0d07d45.../transactions?order=desc&count=3&page=5")
        .to_return(body: read_fixture("asset/transactions.200.json"))

      Blockfrost::Asset.transactions("b0d07d45...", order: "desc", count: 3, page: 5)
        .should be_a(Array(Blockfrost::Asset::Transaction))
    end
  end
end
