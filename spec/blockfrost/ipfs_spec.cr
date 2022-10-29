require "../spec_helper"

describe Blockfrost::IPFS do
  before_each do
    configure_api_keys
  end

  describe ".add" do
    it "adds a file to ipfs" do
      WebMock.stub(:post, "https://ipfs.blockfrost.io/api/v0/ipfs/add")
        .with(headers: {
          "Accept"       => "application/json",
          "Content-Type" => "text/markdown",
          "project_id"   => test_ipfs_api_key,
        })
        .to_return(body_io: read_fixture("ipfs/add.200.json"))

      Blockfrost::IPFS.add("spec/fixtures/ipfs/README.md")
    end
  end
end
