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

  describe "::Pin.add" do
    it "pins an object" do
      WebMock.stub(:post,
        "https://ipfs.blockfrost.io/api/v0/ipfs/pin/add/#{test_ipfs_path}")
        .with(body: "", headers: {
          "Accept"       => "application/json",
          "Content-Type" => "application/json",
          "project_id"   => test_ipfs_api_key,
        })
        .to_return(body_io: read_fixture("ipfs/pin.200.json"))

      pinned = Blockfrost::IPFS::Pin.add(test_ipfs_path)
      pinned.ipfs_hash.should eq(test_ipfs_path)
      pinned.state.should eq(Blockfrost::IPFS::Pinning::State::Queued)
    end
  end

  describe "::Pin.all" do
    it "lists objects pinned to local storage" do
      WebMock.stub(:get, "https://ipfs.blockfrost.io/api/v0/ipfs/pin/list")
        .to_return(body_io: read_fixture("ipfs/all.200.json"))

      pin = Blockfrost::IPFS::Pin.all.first
      pin.time_created.should eq(Time.unix(1615551024))
      pin.time_pinned.should eq(Time.unix(1615551024))
      pin.ipfs_hash.should eq("QmdVMnULrY95mth2XkwjxDtMHvzuzmvUPTotKE1tgqKbCx")
      pin.size.should eq(1615551024)
      pin.state.should eq(Blockfrost::IPFS::Pin::State::Pinned)
    end

    it "accepts ordering and pagination parameters" do
      WebMock.stub(:get,
        "https://ipfs.blockfrost.io/api/v0/ipfs/pin/list?order=desc&count=10&page=2")
        .to_return(body_io: read_fixture("ipfs/all.200.json"))

      Blockfrost::IPFS::Pin.all("desc", 10, 2)
        .should be_a(Array(Blockfrost::IPFS::Pin))
    end
  end

  describe "::Pin.get" do
    it "gets information about a locally pinned IPFS object" do
      WebMock.stub(:get,
        "https://ipfs.blockfrost.io/api/v0/ipfs/pin/list/#{test_ipfs_path}")
        .to_return(body_io: read_fixture("ipfs/get.200.json"))

      Blockfrost::IPFS::Pin.get(test_ipfs_path)
        .should be_a(Blockfrost::IPFS::Pin)
    end
  end
end

private def test_ipfs_path
  "QmPojRfAXYAXV92Dof7gtSgaVuxEk64xx9CKvprqu9VwA8"
end
