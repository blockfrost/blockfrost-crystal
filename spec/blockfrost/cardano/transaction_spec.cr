require "../../spec_helper"

describe Blockfrost::Transaction do
  before_each do
    configure_api_keys
  end

  describe ".get" do
    it "fetches a specific transaction" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}")
        .to_return(body_io: read_fixture("tx/get.200.json"))

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
        .to_return(body_io: read_fixture("tx/utxos.200.json"))

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
        .to_return(body_io: read_fixture("tx/stakes.200.json"))

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
        .to_return(body_io: read_fixture("tx/get.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}/stakes")
        .to_return(body_io: read_fixture("tx/stakes.200.json"))

      Blockfrost::Transaction.get(test_tx_hash).stakes
        .should be_a(Array(Blockfrost::Transaction::Stake))
    end
  end

  describe ".delegations" do
    it "fetches information about delegation certificates of a specific transaction" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}/delegations")
        .to_return(body_io: read_fixture("tx/delegations.200.json"))

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
        .to_return(body_io: read_fixture("tx/get.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}/delegations")
        .to_return(body_io: read_fixture("tx/delegations.200.json"))

      Blockfrost::Transaction.get(test_tx_hash).delegations
        .should be_a(Array(Blockfrost::Transaction::Delegation))
    end
  end

  describe ".withdrawals" do
    it "fetches information about withdrawals of a specific transaction" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}/withdrawals")
        .to_return(body_io: read_fixture("tx/withdrawals.200.json"))

      withdrawal = Blockfrost::Transaction.withdrawals(test_tx_hash).first
      withdrawal.address.should eq(
        "stake1u9r76ypf5fskppa0cmttas05cgcswrttn6jrq4yd7jpdnvc7gt0yc"
      )
      withdrawal.amount.should eq(431_833_601)
    end
  end

  describe "#withdrawals" do
    it "fetches information about withdrawals of the current transaction" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}")
        .to_return(body_io: read_fixture("tx/get.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}/withdrawals")
        .to_return(body_io: read_fixture("tx/withdrawals.200.json"))

      Blockfrost::Transaction.get(test_tx_hash).withdrawals
        .should be_a(Array(Blockfrost::Transaction::Withdrawal))
    end
  end

  describe ".mirs" do
    it "fetches information about Move Instantaneous Rewards (MIRs) of a specific transaction" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}/mirs")
        .to_return(body_io: read_fixture("tx/mirs.200.json"))

      mir = Blockfrost::Transaction.mirs(test_tx_hash).first
      mir.pot.should eq(Blockfrost::Transaction::Mir::Pot::Reserve)
      mir.cert_index.should eq(0)
      mir.address.should eq(
        "stake1u9r76ypf5fskppa0cmttas05cgcswrttn6jrq4yd7jpdnvc7gt0yc"
      )
      mir.amount.should eq(431_833_601)
    end
  end

  describe "#mirs" do
    it "fetches information about mirs of the current transaction" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}")
        .to_return(body_io: read_fixture("tx/get.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}/mirs")
        .to_return(body_io: read_fixture("tx/mirs.200.json"))

      Blockfrost::Transaction.get(test_tx_hash).mirs
        .should be_a(Array(Blockfrost::Transaction::Mir))
    end
  end

  describe ".pool_updates" do
    it "fetches information about stake pool registration and update certificates of a specific transaction" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}/pool_updates")
        .to_return(body_io: read_fixture("tx/pool-updates.200.json"))

      pool_update = Blockfrost::Transaction.pool_updates(test_tx_hash).first
      pool_update.cert_index.should eq(0)
      pool_update.pool_id.should eq(
        "pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2q3lkdy"
      )
      pool_update.vrf_key.should eq(
        "0b5245f9934ec2151116fb8ec00f35fd00e0aa3b075c4ed12cce440f999d8233"
      )
      pool_update.pledge.should eq(5000000000)
      pool_update.margin_cost.should eq(0.05)
      pool_update.fixed_cost.should eq(340000000)
      pool_update.reward_account.should eq(
        "stake1uxkptsa4lkr55jleztw43t37vgdn88l6ghclfwuxld2eykgpgvg3f"
      )

      pool_update.owners.should eq([
        "stake1u98nnlkvkk23vtvf9273uq7cph5ww6u2yq2389psuqet90sv4xv9v",
      ])

      metadata = pool_update.metadata.as(Blockfrost::Transaction::PoolUpdate::Metadata)
      metadata.url.should eq(
        "https://stakenuts.com/mainnet.json"
      )
      metadata.hash.should eq(
        "47c0c68cb57f4a5b4a87bad896fc274678e7aea98e200fa14a1cb40c0cab1d8c"
      )
      metadata.ticker.should eq("NUTS")
      metadata.name.should eq("Stake Nuts")
      metadata.description.should eq("The best pool ever")
      metadata.homepage.should eq("https://stakentus.com/")

      relay = pool_update.relays.first
      relay.ipv4.should eq("4.4.4.4")
      relay.ipv6.should eq("https://stakenuts.com/mainnet.json")
      relay.dns.should eq("relay1.stakenuts.com")
      relay.dns_srv.should eq("_relays._tcp.relays.stakenuts.com")
      relay.port.should eq(3001)

      pool_update.active_epoch.should eq(210)
    end
  end

  describe "#pool_updates" do
    it "fetches information about stake pool registration and update certificates of the current transaction" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}")
        .to_return(body_io: read_fixture("tx/get.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}/pool_updates")
        .to_return(body_io: read_fixture("tx/pool-updates.200.json"))

      Blockfrost::Transaction.get(test_tx_hash).pool_updates
        .should be_a(Array(Blockfrost::Transaction::PoolUpdate))
    end
  end

  describe ".pool_retires" do
    it "fetches information about stake pool retirements within a specific transaction" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}/pool_retires")
        .to_return(body_io: read_fixture("tx/pool-retires.200.json"))

      pool_retire = Blockfrost::Transaction.pool_retires(test_tx_hash).first
      pool_retire.cert_index.should eq(0)
      pool_retire.pool_id.should eq(
        "pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2q3lkdy"
      )
      pool_retire.retiring_epoch.should eq(216)
    end
  end

  describe "#pool_retires" do
    it "fetches information about stake pool retirements within the current transaction" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}")
        .to_return(body_io: read_fixture("tx/get.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}/pool_retires")
        .to_return(body_io: read_fixture("tx/pool-retires.200.json"))

      Blockfrost::Transaction.get(test_tx_hash).pool_retires
        .should be_a(Array(Blockfrost::Transaction::PoolRetire))
    end
  end

  describe ".metadata" do
    it "fetches metadata of a specific transaction" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}/metadata")
        .to_return(body_io: read_fixture("tx/metadata.200.json"))

      metadata = Blockfrost::Transaction.metadata(test_tx_hash)
      metadata.first.label.should eq("1967")
      metadata.first.json_metadata.dig("metadata").should eq(
        "https://nut.link/metadata.json"
      )
    end
  end

  describe "#metadata" do
    it "fetches metadata of the current transaction" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}")
        .to_return(body_io: read_fixture("tx/get.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}/metadata")
        .to_return(body_io: read_fixture("tx/metadata.200.json"))

      Blockfrost::Transaction.get(test_tx_hash).metadata
        .should be_a(Array(Blockfrost::Transaction::MetadataJSON))
    end
  end

  describe ".metadata_in_cbor" do
    it "fetches metadata of a specific transaction in CBOR" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}/metadata/cbor")
        .to_return(body_io: read_fixture("tx/metadata-cbor.200.json"))

      metadata = Blockfrost::Transaction.metadata_in_cbor(test_tx_hash)
      metadata.first.label.should eq("1968")
      metadata.first.metadata.should eq(
        "a100a16b436f6d62696e6174696f6e8601010101010c"
      )
    end
  end

  describe "#metadata_in_cbor" do
    it "fetches metadata of the current transaction in CBOR" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}")
        .to_return(body_io: read_fixture("tx/get.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}/metadata/cbor")
        .to_return(body_io: read_fixture("tx/metadata-cbor.200.json"))

      Blockfrost::Transaction.get(test_tx_hash).metadata_in_cbor
        .should be_a(Array(Blockfrost::Transaction::MetadataCBOR))
    end
  end

  describe ".redeemers" do
    it "fetches redeemers of a specific transaction" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}/redeemers")
        .to_return(body_io: read_fixture("tx/redeemers.200.json"))

      redeemer = Blockfrost::Transaction.redeemers(test_tx_hash).first
      redeemer.tx_index.should eq(0)
      redeemer.purpose.should eq(
        Blockfrost::Transaction::Redeemer::Purpose::Spend
      )
      redeemer.script_hash.should eq(
        "ec26b89af41bef0f7585353831cb5da42b5b37185e0c8a526143b824"
      )
      redeemer.redeemer_data_hash.should eq(
        "923918e403bf43c34b4ef6b48eb2ee04babed17320d8d1b9ff9ad086e86f44ec"
      )
      redeemer.datum_hash.should eq(
        "923918e403bf43c34b4ef6b48eb2ee04babed17320d8d1b9ff9ad086e86f44ec"
      )
      redeemer.unit_mem.should eq(1700)
      redeemer.unit_steps.should eq(476468)
      redeemer.fee.should eq(172033)
    end
  end

  describe "#redeemers" do
    it "fetches redeemers of the current transaction" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}")
        .to_return(body_io: read_fixture("tx/get.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/txs/#{test_tx_hash}/redeemers")
        .to_return(body_io: read_fixture("tx/redeemers.200.json"))

      Blockfrost::Transaction.get(test_tx_hash).redeemers
        .should be_a(Array(Blockfrost::Transaction::Redeemer))
    end
  end

  describe ".submit" do
    it "submits an already serialized transaction to the network" do
      WebMock.stub(:post,
        "https://cardano-testnet.blockfrost.io/api/v0/tx/submit")
        .with(
          body: read_fixture("tx/cbor-data").gets_to_end,
          headers: {
            "Accept"       => "application/json",
            "Content-Type" => "application/cbor",
            "project_id"   => test_cardano_api_key,
          })
        .to_return(body_io: read_fixture("tx/submit.200.json"))

      Blockfrost::Transaction.submit(read_fixture("tx/cbor-data")).should eq(
        "d1662b24fa9fe985fc2dce47455df399cb2e31e1e1819339e885801cc3578908"
      )
    end
  end
end

private def test_tx_hash
  "6e5f825c42c1c6d6b77f2a14092f3b78c8f1b66db6f4cf8caec1555b6f967b3b"
end
