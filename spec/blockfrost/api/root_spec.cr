require "../../spec_helper"

describe Blockfrost::Root do
  before_each do
    configure_api_keys
  end

  describe ".get" do
    it "fetches the root endpoint" do
      WebMock.stub(:get, "https://cardano-testnet.blockfrost.io/api/v0/")
        .to_return(body_io: read_fixture("root/get.200.json"))

      root = Blockfrost::Root.get
      root.url.should eq("https://blockfrost.io/")
      root.version.should eq("0.1.0")
    end
  end
end
