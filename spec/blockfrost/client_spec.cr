require "../spec_helper"

describe Blockfrost::IPFS do
  before_each do
    configure_api_keys
  end

  describe ".sdk_version_string" do
    it "returns the string with the shard's version and the crystal version" do
      Blockfrost::Client.sdk_version_string.should eq(
        "blockfrost-crystal/#{Blockfrost::VERSION} crystal/#{Crystal::VERSION}"
      )
    end
  end
end
