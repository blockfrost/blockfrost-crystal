require "../spec_helper"

describe Blockfrost::Account do
  before_each do
    configure_api_keys
  end

  describe ".get" do
    it "fetches a specific account" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/accounts/#{stake_address}")
        .to_return(body: read_fixture("account/get.200.json"))

      Blockfrost::Account.get(stake_address).tap do |account|
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
  end

  describe ".rewards" do
    it "fetches the rewards for a given account" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/accounts/#{stake_address}/rewards")
        .to_return(body: read_fixture("account/rewards.200.json"))

      Blockfrost::Account.rewards(stake_address).tap do |rewards|
        rewards.first.epoch.should eq(215)
        rewards.first.amount.should eq(12695385)
        rewards.first.pool_id
          .should eq("pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2q3lkdy")
        rewards.first.type.should eq("member")
      end
    end

    it "accepts parameters for ordering and pagination" do
      WebMock.stub(:get, "https://cardano-testnet.blockfrost.io/api/v0/accounts/#{stake_address}/rewards?order=desc&count=2&page=3")
        .to_return(body: read_fixture("account/rewards.200.json"))

      Blockfrost::Account.rewards(stake_address, "desc", 2, 3)
        .should be_a(Array(Blockfrost::Account::Reward))
    end
  end

  describe ".history" do
    it "fetches the history for a given account" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/accounts/#{stake_address}/history")
        .to_return(body: read_fixture("account/history.200.json"))

      Blockfrost::Account.history(stake_address).tap do |history|
        history.first.active_epoch.should eq(210)
        history.first.amount.should eq(12695385)
        history.first.pool_id
          .should eq("pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2q3lkdy")
      end
    end

    it "accepts parameters for ordering and pagination" do
      WebMock.stub(:get, "https://cardano-testnet.blockfrost.io/api/v0/accounts/#{stake_address}/history?order=desc&count=2&page=3")
        .to_return(body: read_fixture("account/history.200.json"))

      Blockfrost::Account.history(stake_address, "desc", 2, 3)
        .should be_a(Array(Blockfrost::Account::Event))
    end
  end

  describe ".delegations" do
    it "fetches the delegations for a given account" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/accounts/#{stake_address}/delegations")
        .to_return(body: read_fixture("account/delegations.200.json"))

      Blockfrost::Account.delegations(stake_address).tap do |delegations|
        delegations.first.active_epoch.should eq(210)
        delegations.first.tx_hash
          .should eq("2dd15e0ef6e6a17841cb9541c27724072ce4d4b79b91e58432fbaa32d9572531")
        delegations.first.amount.should eq(12695385)
        delegations.first.pool_id
          .should eq("pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2q3lkdy")
      end
    end

    it "accepts parameters for ordering and pagination" do
      WebMock.stub(:get, "https://cardano-testnet.blockfrost.io/api/v0/accounts/#{stake_address}/delegations?order=desc&count=2&page=3")
        .to_return(body: read_fixture("account/delegations.200.json"))

      Blockfrost::Account.delegations(stake_address, "desc", 2, 3)
        .should be_a(Array(Blockfrost::Account::Delegation))
    end
  end

  describe ".registrations" do
    it "fetches the registrations for a given account" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/accounts/#{stake_address}/registrations")
        .to_return(body: read_fixture("account/registrations.200.json"))

      Blockfrost::Account.registrations(stake_address).tap do |registrations|
        registrations.first.tx_hash
          .should eq("2dd15e0ef6e6a17841cb9541c27724072ce4d4b79b91e58432fbaa32d9572531")
        registrations.first.action
          .should eq("registered")
      end
    end

    it "accepts parameters for ordering and pagination" do
      WebMock.stub(:get, "https://cardano-testnet.blockfrost.io/api/v0/accounts/#{stake_address}/registrations?order=desc&count=2&page=3")
        .to_return(body: read_fixture("account/registrations.200.json"))

      Blockfrost::Account.registrations(stake_address, "desc", 2, 3)
        .should be_a(Array(Blockfrost::Account::Registration))
    end
  end
end

private def stake_address
  "stake1ux3g2c9dx2nhhehyrezyxpkstartcqmu9hk63qgfkccw5rqttygt7"
end
