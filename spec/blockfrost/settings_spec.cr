require "../spec_helper"

describe Blockfrost do
  describe ".settings" do
    it "accepts a valid api key and api version" do
      Blockfrost.configure do |settings|
        settings.api_key = fake_api_key
        settings.api_version = "v9"
      end

      Blockfrost.settings.api_key.should eq(fake_api_key)
      Blockfrost.settings.api_version.should eq("v9")
    end

    it "raises with an invalid api key" do
      expect_raises(Habitat::InvalidSettingFormatError) do
        Blockfrost.configure do |settings|
          settings.api_key = "sumtingwong"
        end
      end
    end

    it "raises with an invalid api version" do
      expect_raises(Habitat::InvalidSettingFormatError) do
        Blockfrost.configure do |settings|
          settings.api_version = "1"
        end
      end
    end
  end

  describe ".network" do
    it "returns the current network" do
      Blockfrost.configure do |settings|
        settings.api_key = "mainnetVas4TOfOvQeVjTVGxxYNRLOt6Fb4FAKE"
      end

      Blockfrost.network.should eq("mainnet")

      Blockfrost.temp_config(api_key: "testnetVas4TOfOvQeVjTVGxxYNRLOt6Fb4FAKE") do
        Blockfrost.network.should eq("testnet")
      end
    end
  end

  describe ".testnet?" do
    it "tests if the current network is testnet or not" do
      Blockfrost.temp_config(api_key: "testnetVas4TOfOvQeVjTVGxxYNRLOt6Fb4FAKE") do
        Blockfrost.testnet?.should be_truthy
      end

      Blockfrost.temp_config(api_key: "mainnetVas4TOfOvQeVjTVGxxYNRLOt6Fb4FAKE") do
        Blockfrost.testnet?.should be_falsey
      end
    end
  end

  {% for network in Blockfrost.annotation(Blockfrost::Networks)
                      .args.first.reject { |n| n == :testnet }.map(&.id) %}
    describe ".{{network.id}}?" do
      it "tests if the current network is {{network.id}} or not" do
        Blockfrost.temp_config(api_key: "{{network.id}}Vas4TOfOvQeVjTVGxxYNRLOt6Fb4FAKE") do
          Blockfrost.{{network.id}}?.should be_truthy
        end

        Blockfrost.temp_config(api_key: "testnetVas4TOfOvQeVjTVGxxYNRLOt6Fb4FAKE") do
          Blockfrost.{{network.id}}?.should be_falsey
        end
      end
    end
  {% end %}

  describe ".mainnet?" do
    it "tests if the current network is mainnet or not" do
      Blockfrost.temp_config(api_key: "mainnetVas4TOfOvQeVjTVGxxYNRLOt6Fb4FAKE") do
        Blockfrost.mainnet?.should be_truthy
      end

      Blockfrost.temp_config(api_key: "testnetVas4TOfOvQeVjTVGxxYNRLOt6Fb4FAKE") do
        Blockfrost.mainnet?.should be_falsey
      end
    end
  end

  describe ".host" do
    it "builds a cardano host name" do
      {% for network in %w[mainnet preprod preview testnet] %}
        Blockfrost.configure do |settings|
          settings.api_key = "{{network.id}}Vas4TOfOvQeVjTVGxxYNRLOt6Fb4FAKE"
        end

        Blockfrost.host.should eq("https://cardano-{{network.id}}.blockfrost.io")
      {% end %}
    end

    it "builds a milkomeda host name" do
      {% for network in %w[mainnet testnet] %}
        Blockfrost.configure do |settings|
          settings.api_key = "milk{{network.id}}Vas4TOfOvQeVjTVGxxYNRLOt6Fb4FAKE"
        end

        Blockfrost.host.should eq("https://milkomeda-{{network.id}}.blockfrost.io")
      {% end %}
    end

    it "builds an ipfs hostname" do
      Blockfrost.configure do |settings|
        settings.api_key = "ipfsVas4TOfOvQeVjTVGxxYNRLOt6Fb4FAKE"
      end

      Blockfrost.host.should eq("https://ipfs.blockfrost.io")
    end
  end
end
