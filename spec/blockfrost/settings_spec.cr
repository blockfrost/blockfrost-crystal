require "../spec_helper"

describe Blockfrost do
  describe ".settings" do
    it "accepts valid api keys" do
      Blockfrost.configure do |settings|
        settings.cardano_api_key = test_cardano_api_key
        settings.ipfs_api_key = test_ipfs_api_key
      end

      Blockfrost.settings.cardano_api_key.should eq(test_cardano_api_key)
      Blockfrost.settings.ipfs_api_key.should eq(test_ipfs_api_key)
    end

    it "accepts valid api versions" do
      Blockfrost.configure do |settings|
        settings.cardano_api_version = "v0"
        settings.ipfs_api_version = "v1"
      end

      Blockfrost.settings.cardano_api_version.should eq("v0")
      Blockfrost.settings.ipfs_api_version.should eq("v1")
    end
  end

  describe ".validate_cardano_api_key" do
    it "raises with an invalid cardano api key" do
      expect_raises(
        Habitat::InvalidSettingFormatError,
        "Cardano API key is invalid"
      ) do
        Blockfrost.configure do |settings|
          settings.cardano_api_key = "sumtingwong"
        end
      end
    end
  end

  describe ".validate_ipfs_api_key" do
    it "raises with an invalid ipfs api key" do
      expect_raises(
        Habitat::InvalidSettingFormatError,
        "IPFS API key is invalid"
      ) do
        Blockfrost.configure do |settings|
          settings.ipfs_api_key = "sumtingwong"
        end
      end
    end
  end

  describe ".validate_api_version" do
    it "raises with an invalid cardano api version" do
      expect_raises(
        Habitat::InvalidSettingFormatError,
        "API version is invalid (e.g. v0)"
      ) do
        Blockfrost.configure do |settings|
          settings.cardano_api_version = "1"
        end
      end
    end

    it "raises with an invalid ipfs api version" do
      expect_raises(
        Habitat::InvalidSettingFormatError,
        "API version is invalid (e.g. v0)"
      ) do
        Blockfrost.configure do |settings|
          settings.ipfs_api_version = "v"
        end
      end
    end
  end

  describe ".validate_default_count_per_page" do
    it "raises with a count per page lower than 1" do
      expect_raises(Habitat::InvalidSettingFormatError) do
        Blockfrost.configure do |settings|
          settings.default_count_per_page = 0
        end
      end
    end

    it "raises with a count per page higher than the maximum allowed value" do
      expect_raises(Habitat::InvalidSettingFormatError) do
        Blockfrost.configure do |settings|
          max = Blockfrost::MAX_COUNT_PER_PAGE
          settings.default_count_per_page = max + 1
        end
      end
    end
  end

  describe ".validate_retries_in_concurrent_requests" do
    it "raises with max retries in concurrent requests lower than 0" do
      expect_raises(
        Habitat::InvalidSettingFormatError,
        "Maximum retries in concurrent requests is invalid (min 0 and max 10)"
      ) do
        Blockfrost.configure do |settings|
          settings.retries_in_concurrent_requests = -1
        end
      end
    end

    it "raises with max retries in concurrent requests higher than 10" do
      expect_raises(
        Habitat::InvalidSettingFormatError,
        "Maximum retries in concurrent requests is invalid (min 0 and max 10)"
      ) do
        Blockfrost.configure do |settings|
          max = Blockfrost::MAX_RETRIES_IN_CONCURRENT_REQUESTS
          settings.retries_in_concurrent_requests = max + 1
        end
      end
    end
  end

  describe ".validate_sleep_between_retries_ms" do
    it "raises with max concurrent requests lower than 1" do
      expect_raises(
        Habitat::InvalidSettingFormatError,
        "Sleep between retries must be greater than or equal to 0"
      ) do
        Blockfrost.configure do |settings|
          settings.sleep_between_retries_ms = -1
        end
      end
    end
  end

  describe ".cardano_network" do
    it "returns the current network" do
      Blockfrost.configure do |settings|
        settings.cardano_api_key = "mainnetVas4TOfOvQeVjTVGxxYNRLOt6Fb4FAKE"
      end

      Blockfrost.cardano_network.should eq("mainnet")

      Blockfrost.temp_config(
        cardano_api_key: "testnetVas4TOfOvQeVjTVGxxYNRLOt6Fb4FAKE") do
        Blockfrost.cardano_network.should eq("testnet")
      end
    end
  end

  describe ".cardano_testnet?" do
    it "tests if the current network is testnet or not" do
      Blockfrost.temp_config(
        cardano_api_key: "testnetVas4TOfOvQeVjTVGxxYNRLOt6Fb4FAKE") do
        Blockfrost.cardano_testnet?.should be_truthy
      end

      Blockfrost.temp_config(
        cardano_api_key: "mainnetVas4TOfOvQeVjTVGxxYNRLOt6Fb4FAKE") do
        Blockfrost.cardano_testnet?.should be_falsey
      end
    end
  end

  {% for network in Blockfrost.annotation(Blockfrost::CardanoNetworks)
                      .args.first.reject { |n| n == :testnet }.map(&.id) %}
    describe ".cardano_{{network.id}}?" do
      it "tests if the current network is {{network.id}} or not" do
        Blockfrost.temp_config(
          cardano_api_key: "{{network.id}}Vas4TOfOvQeVjTVGxxYNRLOt6Fb4FAKE") do
          Blockfrost.cardano_{{network.id}}?.should be_truthy
        end

        Blockfrost.temp_config(
          cardano_api_key: "testnetVas4TOfOvQeVjTVGxxYNRLOt6Fb4FAKE") do
          Blockfrost.cardano_{{network.id}}?.should be_falsey
        end
      end
    end
  {% end %}

  describe ".host_for_path" do
    it "builds a cardano host name" do
      {% for network in %w[mainnet preprod preview testnet] %}
        Blockfrost.configure do |settings|
          settings
            .cardano_api_key = "{{network.id}}Vas4TOfOvQeVjTVGxxYNRLOt6Fb4FAKE"
        end

        Blockfrost.host_for_path("blocks/latest")
          .should eq("https://cardano-{{network.id}}.blockfrost.io")
      {% end %}
    end

    it "builds an ipfs hostname" do
      Blockfrost.configure do |settings|
        settings.ipfs_api_key = "ipfsVas4TOfOvQeVjTVGxxYNRLOt6Fb4FAKE"
      end

      Blockfrost.host_for_path("ipfs/gateway/QmZbHqiC")
        .should eq("https://ipfs.blockfrost.io")
    end
  end

  describe ".api_key_for_path" do
    it "returns the appropriate api key for a given path" do
      Blockfrost.api_key_for_path("blocks/latest")
        .should eq("testnetVas4TOfOvQeVjTVGxxYNRLOt6Fb4FAKE")
      Blockfrost.api_key_for_path("ipfs/gateway/QmZbHqiC")
        .should eq("ipfsVas4TOfOvQeVjTVGxxYNRLOt6Fb4FAKE")
    end

    it "raises if no cardano api key is configured" do
      Blockfrost.configure do |settings|
        settings.cardano_api_key = nil
      end

      expect_raises(
        Habitat::InvalidSettingFormatError, "Missing Cardano API key"
      ) do
        Blockfrost.api_key_for_path("blocks/latest")
      end
    end

    it "raises if no ipfs api key is configured" do
      Blockfrost.configure do |settings|
        settings.ipfs_api_key = nil
      end

      expect_raises(
        Habitat::InvalidSettingFormatError, "Missing IPFS API key"
      ) do
        Blockfrost.api_key_for_path("ipfs/gateway/QmZbHqiC")
      end
    end
  end

  describe ".api_version_for_path" do
    it "returns the appropriate api key for a given path" do
      Blockfrost.configure do |settings|
        settings.cardano_api_key = test_cardano_api_key
        settings.cardano_api_version = "v0"
        settings.ipfs_api_key = test_ipfs_api_key
        settings.ipfs_api_version = "v1"
      end

      Blockfrost.api_version_for_path("blocks/latest").should eq("v0")
      Blockfrost.api_version_for_path("ipfs/gateway/QmZbHqiC").should eq("v1")
    end
  end

  describe ".default_order" do
    it "globally configures a default sort order" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools?order=desc")
        .to_return(body_io: read_fixture("pool/all-ids.200.json"))

      Blockfrost.temp_config(default_order: Blockfrost::QueryOrder::DESC) do
        Blockfrost::Pool.all_ids
      end
    end
  end

  describe ".default_count_per_page" do
    it "globally configures a default count per page" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/pools?count=42")
        .to_return(body_io: read_fixture("pool/all-ids.200.json"))

      Blockfrost.temp_config(default_count_per_page: 42) do
        Blockfrost::Pool.all_ids
      end
    end
  end
end
