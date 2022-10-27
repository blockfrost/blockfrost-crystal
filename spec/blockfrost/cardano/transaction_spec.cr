require "../../spec_helper"

describe Blockfrost::Transaction do
  before_each do
    configure_api_keys
  end

  describe ".get" do
    it "fetches a specific transaction" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}")
        .to_return(body: read_fixture("tx/get.200.json"))

      tx = Blockfrost::Transaction.get(test_tx_hash)
      tx.hash.should eq(test_tx_hash)
      tx.block.should eq(
        "356b7d7dbb696ccd12775c016941057a9dc70898d87a63fc752271bb46856940"
      )
      tx.block_height.should eq(123_456)
      tx.block_time.should eq(Time.unix(1635505891))
      tx.slot.should eq(42_000_000)
      tx.index.should eq(1)
      tx.output_amount.first.unit.should eq("lovelace")
      tx.output_amount.first.quantity.should eq(42_000_000)
      tx.output_amount.last.unit.should eq(
        "b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a76e7574636f696e"
      )
      tx.output_amount.last.quantity.should eq(12)

      tx.fees.should eq(182_485)
      tx.deposit.should eq(0)
      tx.size.should eq(433)
      tx.invalid_before.should be_nil
      tx.invalid_hereafter.should eq(13_885_913)
      tx.utxo_count.should eq(4)
      tx.withdrawal_count.should eq(0)
      tx.mir_cert_count.should eq(0)
      tx.delegation_count.should eq(0)
      tx.stake_cert_count.should eq(0)
      tx.pool_update_count.should eq(0)
      tx.pool_retire_count.should eq(0)
      tx.asset_mint_or_burn_count.should eq(0)
      tx.redeemer_count.should eq(0)
      tx.valid_contract.should eq(true)
    end
  end

  describe ".utxos" do
    it "fetches the utxos of a given transaction" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}/utxos")
        .to_return(body: read_fixture("tx/utxos.200.json"))

      tx = Blockfrost::Transaction.utxos(test_tx_hash)
      tx.hash.should eq(test_tx_hash)

      input = tx.inputs.first
      input.address.should eq(
        "addr1q9ld26v2lv8wvrxxmvg90pn8n8n5k6tdst06q2s856rwmvnueldzuuqmnsye359fqrk8hwvenjnqultn7djtrlft7jnq7dy7wv"
      )
      input.amount.first.unit.should eq("lovelace")
      input.amount.first.quantity.should eq(42_000_000)
      input.tx_hash.should eq(
        "1a0570af966fb355a7160e4f82d5a80b8681b7955f5d44bec0dce628516157f0"
      )
      input.output_index.should eq(0)
      input.data_hash.should eq(
        "9e478573ab81ea7a8e31891ce0648b81229f408d596a3483e6f4f9b92d3cf710"
      )
      input.inline_datum.should eq("19a6aa")
      input.reference_script_hash.should eq(
        "13a3efd825703a352a8f71f4e2758d08c28c564e8dfcce9f77776ad1"
      )
      input.collateral.should be_falsey
      input.reference.should be_falsey

      output = tx.outputs.first
      output.address.should eq(
        "addr1q9ld26v2lv8wvrxxmvg90pn8n8n5k6tdst06q2s856rwmvnueldzuuqmnsye359fqrk8hwvenjnqultn7djtrlft7jnq7dy7wv"
      )
      output.amount.first.unit.should eq("lovelace")
      output.amount.first.quantity.should eq(42_000_000)
      output.output_index.should eq(0)
      output.data_hash.should eq(
        "9e478573ab81ea7a8e31891ce0648b81229f408d596a3483e6f4f9b92d3cf710"
      )
      output.inline_datum.should eq("19a6aa")
      input.collateral.should be_falsey
      output.reference_script_hash.should eq(
        "13a3efd825703a352a8f71f4e2758d08c28c564e8dfcce9f77776ad1"
      )
    end
  end

  describe ".stakes" do
    it "fetches information about (de)registration of stake addresses within a given transaction" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}/stakes")
        .to_return(body: read_fixture("tx/stakes.200.json"))

      stake = Blockfrost::Transaction.stakes(test_tx_hash).first
      stake.cert_index.should eq(0)
      stake.address.should eq(
        "stake1u9t3a0tcwune5xrnfjg4q7cpvjlgx9lcv0cuqf5mhfjwrvcwrulda"
      )
      stake.registration.should be_truthy
    end
  end

  describe "#stakes" do
    it "fetches information about (de)registration of stake addresses within the current transaction" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}")
        .to_return(body: read_fixture("tx/get.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}/stakes")
        .to_return(body: read_fixture("tx/stakes.200.json"))

      Blockfrost::Transaction.get(test_tx_hash).stakes
        .should be_a(Array(Blockfrost::Transaction::Stake))
    end
  end

  describe ".delegations" do
    it "fetches information about delegation certificates of a specific transaction" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}/delegations")
        .to_return(body: read_fixture("tx/delegations.200.json"))

      delegation = Blockfrost::Transaction.delegations(test_tx_hash).first
      delegation.index.should eq(0)
      delegation.cert_index.should eq(0)
      delegation.address.should eq(
        "stake1u9r76ypf5fskppa0cmttas05cgcswrttn6jrq4yd7jpdnvc7gt0yc"
      )
      delegation.pool_id.should eq(
        "pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2q3lkdy"
      )
      delegation.active_epoch.should eq(210)
    end
  end

  describe "#delegations" do
    it "fetches information about delegation certificates of the current transaction" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}")
        .to_return(body: read_fixture("tx/get.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}/delegations")
        .to_return(body: read_fixture("tx/delegations.200.json"))

      Blockfrost::Transaction.get(test_tx_hash).delegations
        .should be_a(Array(Blockfrost::Transaction::Delegation))
    end
  end
end

private def test_tx_hash
  "6e5f825c42c1c6d6b77f2a14092f3b78c8f1b66db6f4cf8caec1555b6f967b3b"
end
