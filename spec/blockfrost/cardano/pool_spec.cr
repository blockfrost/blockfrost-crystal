require "../../spec_helper"

describe Blockfrost::Pool do
  before_each do
    configure_api_keys
  end

  describe ".all_ids" do
    it "fetches all pool ids" do
      WebMock.stub(:get, "https://cardano-testnet.blockfrost.io/api/v0/pools")
        .to_return(body: read_fixture("pool/all_ids.200.json"))

      Blockfrost::Pool.all_ids.should eq([
        "pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2q3lkdy",
        "pool1hn7hlwrschqykupwwrtdfkvt2u4uaxvsgxyh6z63703p2knj288",
        "pool1ztjyjfsh432eqetadf82uwuxklh28xc85zcphpwq6mmezavzad2",
      ])
    end

    it "accepts ordering and pagination parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools?order=desc&count=10&page=10")
        .to_return(body: read_fixture("pool/all_ids.200.json"))

      Blockfrost::Pool.all_ids("desc", 10, 10).should be_a(Array(String))
    end
  end

  describe ".all_ids_with_stake" do
    it "fetches all pool ids with stake" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools/extended")
        .to_return(body: read_fixture("pool/all_ids_with_stake.200.json"))

      pool = Blockfrost::Pool.all_ids_with_stake.first
      pool.pool_id.should eq(
        "pool1z5uqdk7dzdxaae5633fqfcu2eqzy3a3rgtuvy087fdld7yws0xt"
      )
      pool.hex.should eq(
        "153806dbcd134ddee69a8c5204e38ac80448f62342f8c23cfe4b7edf"
      )
      pool.active_stake.should eq(44709944758094)
      pool.live_stake.should eq(46600529805358)
    end

    it "accepts ordering and pagination parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools/extended?order=asc&count=3&page=1")
        .to_return(body: read_fixture("pool/all_ids_with_stake.200.json"))

      Blockfrost::Pool.all_ids_with_stake("asc", 3, 1)
        .should be_a(Array(Blockfrost::Pool::Abbreviated))
    end
  end

  describe ".retired_ids" do
    it "fetches all the retired pool ids" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools/retired")
        .to_return(body: read_fixture("pool/retired_ids.200.json"))

      pool = Blockfrost::Pool.retired_ids.first
      pool.pool_id.should eq(
        "pool19u64770wqp6s95gkajc8udheske5e6ljmpq33awxk326zjaza0q"
      )
      pool.epoch.should eq(225)
    end

    it "accepts ordering and pagination parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools/retired?order=desc&count=3&page=2")
        .to_return(body: read_fixture("pool/retired_ids.200.json"))

      Blockfrost::Pool.retired_ids("desc", 3, 2)
        .should be_a(Array(Blockfrost::Pool::Retired))
    end
  end

  describe ".retiring_ids" do
    it "fetches all the retiring pool ids" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools/retiring")
        .to_return(body: read_fixture("pool/retiring_ids.200.json"))

      pools = Blockfrost::Pool.retiring_ids
      pools.first.pool_id.should eq(
        "pool19u64770wqp6s95gkajc8udheske5e6ljmpq33awxk326zjaza0q"
      )
      pools.first.epoch.should eq(225)
    end

    it "accepts ordering and pagination parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools/retiring?order=desc&count=3&page=2")
        .to_return(body: read_fixture("pool/retiring_ids.200.json"))

      Blockfrost::Pool.retiring_ids("desc", 3, 2)
        .should be_a(Array(Blockfrost::Pool::Retiring))
    end
  end

  describe ".get" do
    it "fetches a pool for the given pool id" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools/#{fake_pool_id}")
        .to_return(body: read_fixture("pool/get.200.json"))

      pool = Blockfrost::Pool.get(fake_pool_id)
      pool.pool_id.should eq(fake_pool_id)
      pool.hex.should eq(
        "0f292fcaa02b8b2f9b3c8f9fd8e0bb21abedb692a6d5058df3ef2735"
      )
      pool.vrf_key.should eq(
        "0b5245f9934ec2151116fb8ec00f35fd00e0aa3b075c4ed12cce440f999d8233"
      )
      pool.blocks_minted.should eq(69)
      pool.blocks_epoch.should eq(4)
      pool.live_stake.should eq(6900000000)
      pool.live_size.should eq(0.42)
      pool.live_saturation.should eq(0.93)
      pool.live_delegators.should eq(127)
      pool.active_stake.should eq(4200000000)
      pool.active_size.should eq(0.43)
      pool.declared_pledge.should eq(5000000000)
      pool.live_pledge.should eq(5000000001)
      pool.margin_cost.should eq(0.05)
      pool.fixed_cost.should eq(340000000)
      pool.reward_account.should eq(
        "stake1uxkptsa4lkr55jleztw43t37vgdn88l6ghclfwuxld2eykgpgvg3f"
      )
    end
  end

  describe ".history" do
    it "fetches a pool's history" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools/#{fake_pool_id}/history")
        .to_return(body: read_fixture("pool/history.200.json"))

      history = Blockfrost::Pool.history(fake_pool_id)
      history.first.epoch.should eq(233)
      history.first.blocks.should eq(22)
      history.first.active_stake.should eq(20485965693569)
      history.first.active_size.should eq(1.2345)
      history.first.delegators_count.should eq(115)
      history.first.rewards.should eq(206936253674159)
      history.first.fees.should eq(1290968354)
    end

    it "accepts ordering and pagination parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools/#{fake_pool_id}/history?order=asc&count=2&page=3")
        .to_return(body: read_fixture("pool/history.200.json"))

      Blockfrost::Pool.history(fake_pool_id, Blockfrost::QueryOrder::ASC, 2, 3)
        .should be_a(Array(Blockfrost::Pool::Event))
    end
  end

  describe "#history" do
    it "fetches the current pool's history" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools/#{fake_pool_id}")
        .to_return(body: read_fixture("pool/get.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools/#{fake_pool_id}/history")
        .to_return(body: read_fixture("pool/history.200.json"))

      Blockfrost::Pool.get(fake_pool_id).history
        .should be_a(Array(Blockfrost::Pool::Event))
    end
  end

  describe ".metadata" do
    it "fetches a pool's metadata" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools/#{fake_pool_id}/metadata")
        .to_return(body: read_fixture("pool/metadata.200.json"))

      metadata = Blockfrost::Pool.metadata(fake_pool_id)
      metadata.pool_id.should eq(fake_pool_id)
      metadata.hex.should eq(
        "0f292fcaa02b8b2f9b3c8f9fd8e0bb21abedb692a6d5058df3ef2735"
      )
      metadata.url.should eq("https://stakenuts.com/mainnet.json")
      metadata.hash.should eq(
        "47c0c68cb57f4a5b4a87bad896fc274678e7aea98e200fa14a1cb40c0cab1d8c"
      )
      metadata.ticker.should eq("NUTS")
      metadata.name.should eq("Stake Nuts")
      metadata.description.should eq("The best pool ever")
      metadata.homepage.should eq("https://stakentus.com/")
    end
  end

  describe "#metadata" do
    it "fetches the current pool's metadata" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools/#{fake_pool_id}")
        .to_return(body: read_fixture("pool/get.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools/#{fake_pool_id}/metadata")
        .to_return(body: read_fixture("pool/metadata.200.json"))

      Blockfrost::Pool.get(fake_pool_id).metadata
        .should be_a(Blockfrost::Pool::Metadata)
    end
  end

  describe ".relays" do
    it "fetches a pool's relays" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools/#{fake_pool_id}/relays")
        .to_return(body: read_fixture("pool/relays.200.json"))

      relay = Blockfrost::Pool.relays(fake_pool_id).first
      relay.ipv4.should eq("4.4.4.4")
      relay.ipv6.should eq("https://stakenuts.com/mainnet.json")
      relay.dns.should eq("relay1.stakenuts.com")
      relay.dns_srv.should eq("_relays._tcp.relays.stakenuts.com")
      relay.port.should eq(3001)
    end
  end

  describe "#relays" do
    it "fetches the current pool's relays" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools/#{fake_pool_id}")
        .to_return(body: read_fixture("pool/get.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools/#{fake_pool_id}/relays")
        .to_return(body: read_fixture("pool/relays.200.json"))

      Blockfrost::Pool.get(fake_pool_id).relays
        .should be_a(Array(Blockfrost::Pool::Relay))
    end
  end

  describe ".delegators" do
    it "fetches a pool's delegators" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools/#{fake_pool_id}/delegators")
        .to_return(body: read_fixture("pool/delegators.200.json"))

      delegator = Blockfrost::Pool.delegators(fake_pool_id).first
      delegator.address.should eq(
        "stake1ux4vspfvwuus9uwyp5p3f0ky7a30jq5j80jxse0fr7pa56sgn8kha"
      )
      delegator.live_stake.should eq(1137959159981411)
    end

    it "accepts ordering and pagination parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools/#{fake_pool_id}/delegators?order=asc&count=1&page=2")
        .to_return(body: read_fixture("pool/delegators.200.json"))

      Blockfrost::Pool.delegators(fake_pool_id, "asc", 1, 2)
        .should be_a(Array(Blockfrost::Pool::Delegator))
    end
  end

  describe "#delegators" do
    it "fetches the current pool's delegators" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools/#{fake_pool_id}")
        .to_return(body: read_fixture("pool/get.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools/#{fake_pool_id}/delegators?count=10")
        .to_return(body: read_fixture("pool/delegators.200.json"))

      Blockfrost::Pool.get(fake_pool_id).delegators(count: 10)
        .should be_a(Array(Blockfrost::Pool::Delegator))
    end
  end

  describe ".block_hashes" do
    it "fetches a pool's block_hashes" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools/#{fake_pool_id}/blocks")
        .to_return(body: read_fixture("pool/block_hashes.200.json"))

      Blockfrost::Pool.block_hashes(fake_pool_id).first.should eq(
        "d8982ca42cfe76b747cc681d35d671050a9e41e9cfe26573eb214e94fe6ff21d"
      )
    end

    it "accepts ordering and pagination parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools/#{fake_pool_id}/blocks?order=asc&count=1&page=2")
        .to_return(body: read_fixture("pool/block_hashes.200.json"))

      Blockfrost::Pool.block_hashes(fake_pool_id, "asc", 1, 2)
        .should be_a(Array(String))
    end
  end

  describe "#block_hashes" do
    it "fetches the current pool's block_hashes" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools/#{fake_pool_id}")
        .to_return(body: read_fixture("pool/get.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools/#{fake_pool_id}/blocks?count=10")
        .to_return(body: read_fixture("pool/block_hashes.200.json"))

      Blockfrost::Pool.get(fake_pool_id).block_hashes(count: 10)
        .should be_a(Array(String))
    end
  end

  describe ".updates" do
    it "fetches a pool's updates" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools/#{fake_pool_id}/updates")
        .to_return(body: read_fixture("pool/updates.200.json"))

      update = Blockfrost::Pool.updates(fake_pool_id).first
      update.tx_hash.should eq(
        "6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad"
      )
      update.cert_index.should eq(0)
      update.action.should eq("registered")
    end

    it "accepts ordering and pagination parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools/#{fake_pool_id}/updates?order=asc&count=1&page=2")
        .to_return(body: read_fixture("pool/updates.200.json"))

      Blockfrost::Pool.updates(fake_pool_id, "asc", 1, 2)
        .should be_a(Array(Blockfrost::Pool::Update))
    end
  end

  describe "#updates" do
    it "fetches the current pool's updates" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools/#{fake_pool_id}")
        .to_return(body: read_fixture("pool/get.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools/#{fake_pool_id}/updates?page=2")
        .to_return(body: read_fixture("pool/updates.200.json"))

      Blockfrost::Pool.get(fake_pool_id).updates(page: 2)
        .should be_a(Array(Blockfrost::Pool::Update))
    end
  end
end

private def fake_pool_id
  "pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2q3lkdy"
end
