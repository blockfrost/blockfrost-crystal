require "../../spec_helper"

describe Blockfrost::Script do
  before_each do
    configure_api_keys
  end

  describe ".all" do
    it "fetches all scripts" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/scripts")
        .to_return(body_io: read_fixture("script/all.200.json"))

      script = Blockfrost::Script.all.first
      script.script_hash.should eq(test_script_hash)
    end

    it "accepts ordering and pagination parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/scripts?order=desc")
        .to_return(body_io: read_fixture("script/all.200.json"))

      Blockfrost::Script.all(order: "desc")
        .should be_a(Array(Blockfrost::Script::Abbreviated))
    end
  end

  describe ".get" do
    it "fetches a specific script" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/scripts/#{test_script_hash}")
        .to_return(body_io: read_fixture("script/get.200.json"))

      script = Blockfrost::Script.get(test_script_hash)
      script.script_hash.should eq(test_script_hash)
      script.type.should eq(Blockfrost::Script::Type::PlutusV1)
      script.serialised_size.should eq(3119)
    end
  end

  describe ".json" do
    it "fetches the json data of a timelock script" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/scripts/#{test_script_hash}/json")
        .to_return(body_io: read_fixture("script/json.200.json"))

      json = Blockfrost::Script.json(test_script_hash)
      json.dig?("scripts", 0, "type").should eq("sig")
    end
  end

  describe ".cbor" do
    it "fetches the cbor representation of a plutus script" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/scripts/#{test_script_hash}/cbor")
        .to_return(body_io: read_fixture("script/cbor.200.json"))

      cbor = Blockfrost::Script.cbor(test_script_hash)
      cbor.should eq("4e4d01000033222220051200120011")
    end
  end

  describe ".redeemers" do
    it "fetches the redeemers for a given script" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/scripts/#{test_script_hash}/redeemers")
        .to_return(body_io: read_fixture("script/redeemers.200.json"))

      redeemer = Blockfrost::Script.redeemers(test_script_hash).first
      redeemer.tx_hash.should eq(
        "1a0570af966fb355a7160e4f82d5a80b8681b7955f5d44bec0dce628516157f0"
      )
      redeemer.tx_index.should eq(0)
      redeemer.purpose.should eq(Blockfrost::Script::Redeemer::Purpose::Spend)
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

    it "accepts ordering and pagination parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/scripts/#{test_script_hash}/redeemers?order=desc&count=3&page=1")
        .to_return(body_io: read_fixture("script/redeemers.200.json"))

      Blockfrost::Script.redeemers(test_script_hash, "desc", 3, 1)
        .should be_a(Array(Blockfrost::Script::Redeemer))
    end
  end

  describe ".redeemers" do
    it "fetches the redeemers for the current script" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/scripts/#{test_script_hash}")
        .to_return(body_io: read_fixture("script/get.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/scripts/#{test_script_hash}/redeemers")
        .to_return(body_io: read_fixture("script/redeemers.200.json"))

      script = Blockfrost::Script.get(test_script_hash)
      script.redeemers.should be_a(Array(Blockfrost::Script::Redeemer))
    end
  end

  describe Blockfrost::Script::Type do
    it "converts to string with lower camelcase" do
      Blockfrost::Script::Type::Timelock.to_s.should eq("timelock")
      Blockfrost::Script::Type::PlutusV1.to_s.should eq("plutusV1")
      Blockfrost::Script::Type::PlutusV2.to_s.should eq("plutusV2")
    end
  end
end

private def test_script_hash
  "13a3efd825703a352a8f71f4e2758d08c28c564e8dfcce9f77776ad1"
end
