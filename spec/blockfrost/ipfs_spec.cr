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

  describe ".gateway" do
    it "retrieves an object from the IPFS gateway (useful if you do not want to rely on a public gateway" do
      WebMock.stub(:get,
        "https://ipfs.blockfrost.io/api/v0/ipfs/gateway/#{test_ipfs_path}")
        .to_return(body_io: read_fixture("ipfs/gateway.200.json"))

      Blockfrost::IPFS.gateway(test_ipfs_path)
        .should eq("ipfs.blockfrost.dev")
    end
  end

  describe ".pin" do
    it "pins an object" do
      WebMock.stub(:post,
        "https://ipfs.blockfrost.io/api/v0/ipfs/pin/add/#{test_ipfs_path}")
        .with(body: "", headers: {
          "Accept"       => "application/json",
          "Content-Type" => "application/json",
          "project_id"   => test_ipfs_api_key,
        })
        .to_return(body_io: read_fixture("ipfs/pin.200.json"))

      pinned = Blockfrost::IPFS.pin(test_ipfs_path)
      pinned.ipfs_hash.should eq(test_ipfs_path)
      pinned.state.should eq(Blockfrost::IPFS::Pin::State::Queued)
    end
  end
end

private def test_ipfs_path
  "QmPojRfAXYAXV92Dof7gtSgaVuxEk64xx9CKvprqu9VwA8"
end
