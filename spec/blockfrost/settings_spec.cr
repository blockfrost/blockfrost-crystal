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

  describe ".host" do
    Blockfrost.configure do |settings|
      settings.api_key = "mainnetVas4TOfOvQeVjTVGxxYNRLOt6Fb4FAKE"
    end

    Blockfrost.host.should eq("https://cardano-mainnet.blockfrost.io")

    Blockfrost.configure do |settings|
      settings.api_key = "testnetVas4TOfOvQeVjTVGxxYNRLOt6Fb4FAKE"
    end

    Blockfrost.host.should eq("https://cardano-testnet.blockfrost.io")
  end
end
