require "../../spec_helper"

describe Blockfrost::Account do
  before_each do
    configure_api_keys
  end

  describe ".get" do
    it "fetches a specific account" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/accounts/#{stake_address}")
        .to_return(body_io: read_fixture("account/get.200.json"))

      account = Blockfrost::Account.get(stake_address)
      account.stake_address.should eq(stake_address)
      account.active.should be_truthy
      account.active_epoch.should eq(412)
      account.controlled_amount.should eq(619154618165)
      account.rewards_sum.should eq(319154618165)
      account.withdrawals_sum.should eq(12125369253)
      account.reserves_sum.should eq(319154618165)
      account.treasury_sum.should eq(12000000)
      account.withdrawable_amount.should eq(319154618165)
      account.pool_id
        .should eq("pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2q3lkdy")
    end
  end

  describe ".rewards" do
    it "fetches the rewards for a given account" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/accounts/#{stake_address}/rewards")
        .to_return(body_io: read_fixture("account/rewards.200.json"))

      reward = Blockfrost::Account.rewards(stake_address).first
      reward.epoch.should eq(215)
      reward.amount.should eq(12695385)
      reward.pool_id
        .should eq("pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2q3lkdy")
      reward.type.should eq(Blockfrost::Account::Reward::Type::Member)
      reward.type.to_s.should eq("member")
    end

    it "accepts parameters for ordering and pagination" do
      WebMock.stub(:get, "https://cardano-testnet.blockfrost.io/api/v0/accounts/#{stake_address}/rewards?order=desc&count=2&page=3")
        .to_return(body_io: read_fixture("account/rewards.200.json"))

      Blockfrost::Account.rewards(stake_address, "desc", 2, 3)
        .should be_a(Array(Blockfrost::Account::Reward))
    end
  end

  describe ".history" do
    it "fetches the history for a given account" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/accounts/#{stake_address}/history")
        .to_return(body_io: read_fixture("account/history.200.json"))

      history = Blockfrost::Account.history(stake_address)
      history.first.active_epoch.should eq(210)
      history.first.amount.should eq(12695385)
      history.first.pool_id
        .should eq("pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2q3lkdy")
    end

    it "accepts parameters for ordering and pagination" do
      WebMock.stub(:get, "https://cardano-testnet.blockfrost.io/api/v0/accounts/#{stake_address}/history?order=desc&count=2&page=3")
        .to_return(body_io: read_fixture("account/history.200.json"))

      Blockfrost::Account.history(stake_address, "desc", 2, 3)
        .should be_a(Array(Blockfrost::Account::Event))
    end
  end

  describe ".delegations" do
    it "fetches the delegations for a given account" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/accounts/#{stake_address}/delegations")
        .to_return(body_io: read_fixture("account/delegations.200.json"))

      delegation = Blockfrost::Account.delegations(stake_address).first
      delegation.active_epoch.should eq(210)
      delegation.tx_hash.should eq(
        "2dd15e0ef6e6a17841cb9541c27724072ce4d4b79b91e58432fbaa32d9572531"
      )
      delegation.amount.should eq(12695385)
      delegation.pool_id.should eq(
        "pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2q3lkdy"
      )
    end

    it "accepts parameters for ordering and pagination" do
      WebMock.stub(:get, "https://cardano-testnet.blockfrost.io/api/v0/accounts/#{stake_address}/delegations?order=desc&count=2&page=3")
        .to_return(body_io: read_fixture("account/delegations.200.json"))

      Blockfrost::Account.delegations(stake_address, "desc", 2, 3)
        .should be_a(Array(Blockfrost::Account::Delegation))
    end
  end

  describe ".registrations" do
    it "fetches the registrations for a given account" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/accounts/#{stake_address}/registrations")
        .to_return(body_io: read_fixture("account/registrations.200.json"))

      registration = Blockfrost::Account.registrations(stake_address).first
      registration.tx_hash.should eq(
        "2dd15e0ef6e6a17841cb9541c27724072ce4d4b79b91e58432fbaa32d9572531"
      )
      registration.action
        .should eq(Blockfrost::Account::Registration::Action::Registered)
    end

    it "accepts parameters for ordering and pagination" do
      WebMock.stub(:get, "https://cardano-testnet.blockfrost.io/api/v0/accounts/#{stake_address}/registrations?order=desc&count=2&page=3")
        .to_return(body_io: read_fixture("account/registrations.200.json"))

      Blockfrost::Account.registrations(stake_address, "desc", 2, 3)
        .should be_a(Array(Blockfrost::Account::Registration))
    end
  end

  describe ".withdrawals" do
    it "fetches the withdrawals for a given account" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/accounts/#{stake_address}/withdrawals")
        .to_return(body_io: read_fixture("account/withdrawals.200.json"))

      withdrawal = Blockfrost::Account.withdrawals(stake_address).first
      withdrawal.tx_hash.should eq(
        "48a9625c841eea0dd2bb6cf551eabe6523b7290c9ce34be74eedef2dd8f7ecc5"
      )
      withdrawal.amount.should eq(454541212442)
    end

    it "accepts parameters for ordering and pagination" do
      WebMock.stub(:get, "https://cardano-testnet.blockfrost.io/api/v0/accounts/#{stake_address}/withdrawals?order=desc&count=2&page=3")
        .to_return(body_io: read_fixture("account/withdrawals.200.json"))

      Blockfrost::Account.withdrawals(stake_address, "desc", 2, 3)
        .should be_a(Array(Blockfrost::Account::Withdrawal))
    end
  end

  describe ".mirs" do
    it "fetches the mirs for a given account" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/accounts/#{stake_address}/mirs")
        .to_return(body_io: read_fixture("account/mirs.200.json"))

      mir = Blockfrost::Account.mirs(stake_address).first
      mir.tx_hash.should eq(
        "69705bba1d687a816ff5a04ec0c358a1f1ef075ab7f9c6cc2763e792581cec6d"
      )
      mir.amount.should eq(2193707473)
    end

    it "accepts parameters for ordering and pagination" do
      WebMock.stub(:get, "https://cardano-testnet.blockfrost.io/api/v0/accounts/#{stake_address}/mirs?order=desc&count=2&page=3")
        .to_return(body_io: read_fixture("account/mirs.200.json"))

      Blockfrost::Account.mirs(stake_address, "desc", 2, 3)
        .should be_a(Array(Blockfrost::Account::Mir))
    end
  end

  describe ".addresses" do
    it "fetches the addresses for a given account" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/accounts/#{stake_address}/addresses")
        .to_return(body_io: read_fixture("account/addresses.200.json"))

      Blockfrost::Account.addresses(stake_address).first.address
        .should eq(
          "addr1qx2kd28nq8ac5prwg32hhvudlwggpgfp8utlyqxu6wqgz62f79qsdmm5dsknt9ecr5w468r9ey0fxwkdrwh08ly3tu9sy0f4qd"
        )
    end

    it "accepts parameters for ordering and pagination" do
      WebMock.stub(:get, "https://cardano-testnet.blockfrost.io/api/v0/accounts/#{stake_address}/addresses?order=desc&count=2&page=3")
        .to_return(body_io: read_fixture("account/addresses.200.json"))

      Blockfrost::Account.addresses(stake_address, "desc", 2, 3)
        .should be_a(Array(Blockfrost::Account::Address))
    end
  end

  describe ".assets_from_addresses" do
    it "fetches the assets from the addresses for a given account" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/accounts/#{stake_address}/addresses/assets")
        .to_return(body_io: read_fixture("account/assets.200.json"))

      asset = Blockfrost::Account.assets_from_addresses(stake_address).first
      asset.unit.should eq(
        "d5e6bf0500378d4f0da4e8dde6becec7621cd8cbf5cbb9b87013d4cc537061636542756433343132"
      )
      asset.quantity.should eq(1i64)
    end

    it "accepts parameters for ordering and pagination" do
      WebMock.stub(:get, "https://cardano-testnet.blockfrost.io/api/v0/accounts/#{stake_address}/addresses/assets?order=desc&count=2&page=3")
        .to_return(body_io: read_fixture("account/assets.200.json"))

      Blockfrost::Account.assets_from_addresses(stake_address, "desc", 2, 3)
        .should be_a(Array(Blockfrost::Token))
    end
  end

  describe ".total_from_addresses" do
    it "fetches the totals of all addresses combined" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/accounts/#{stake_address}/addresses/total")
        .to_return(body_io: read_fixture("account/total.200.json"))

      total = Blockfrost::Account.total_from_addresses(stake_address)
      total.stake_address.should eq(
        "stake1u9l5q5jwgelgagzyt6nuaasefgmn8pd25c8e9qpeprq0tdcp0e3uk"
      )
      total.received_sum.first.unit.should eq("lovelace")
      total.received_sum.first.quantity.should eq(42000000)
      total.sent_sum.last.unit.should eq(
        "b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a76e7574636f696e"
      )
      total.sent_sum.last.quantity.should eq(12)
      total.tx_count.should eq(12)
    end
  end
end

private def stake_address
  "stake1ux3g2c9dx2nhhehyrezyxpkstartcqmu9hk63qgfkccw5rqttygt7"
end
