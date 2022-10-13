require "../spec_helper"

describe Blockfrost::Block do
  before_each do
    configure_api_key
  end

  describe ".latest" do
    it "loads the latest block" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/latest"
      ).to_return(body: read_fixture("block/latest.200.json"))

      Blockfrost::Block.latest.tap do |block|
        block.block_vrf.should eq("vrf_vk1wf2k6lhujezqcfe00l6zetxpnmh9n6mwhpmhm0dvfh3fxgmdnrfqkms8ty")
        block.confirmations.should eq(4698)
        block.epoch.should eq(425)
        block.epoch_slot.should eq(12)
        block.fees.should eq(592661)
        block.hash.should eq("4ea1ba291e8eef538635a53e59fddba7810d1679631cc3aed7c8e6c4091a516a")
        block.height.should eq(15243593)
        block.next_block.should eq("8367f026cf4b03e116ff8ee5daf149b55ba5a6ec6dec04803b8dc317721d15fa")
        block.op_cert.should eq("da905277534faf75dae41732650568af545134ee08a3c0392dbefc8096ae177c")
        block.op_cert_counter.should eq(18)
        block.output.should eq(128314491794)
        block.previous_block.should eq("43ebccb3ac72c7cebd0d9b755a4b08412c9f5dcb81b8a0ad1e3c197d29d47b05")
        block.size.should eq(3)
        block.slot.should eq(412162133)
        block.slot_leader.should eq("pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2qnikdy")
        block.time.should eq(Time.unix(1641338934))
        block.tx_count.should eq(1)
      end
    end

    {% begin %}
      {% for name, status in Blockfrost
                               .annotation(Blockfrost::RequestExceptions)
                               .args.first %}
        it "handels {{status}} exceptions" do
          WebMock.stub(
            :get, "https://cardano-testnet.blockfrost.io/api/v0/blocks/latest"
          ).to_return(
            body: read_fixture("block/latest.{{status}}.json"), status: {{status}}
          )

          expect_raises(Blockfrost::Client::{{name.id}}Exception) do
            Blockfrost::Block.latest
          end
        end
      {% end %}
    {% end %}

    it "handels forbidden exceptions" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/latest"
      ).to_return(body: read_fixture("block/latest.403.json"), status: 403)

      expect_raises(
        Blockfrost::Client::ForbiddenException,
        "Invalid project token."
      ) do
        Blockfrost::Block.latest
      end
    end
  end

  describe ".latest_tx_ids" do
    it "fetches transaction ids for the latest transaction" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/latest/txs")
        .to_return(body: read_fixture("block/latest_tx_ids.200.json"))

      Blockfrost::Block.latest_tx_ids.should eq([
        "8788591983aa73981fc92d6cddbbe643959f5a784e84b8bee0db15823f575a5b",
        "4eef6bb7755d8afbeac526b799f3e32a624691d166657e9d862aaeb66682c036",
        "52e748c4dec58b687b90b0b40d383b9fe1f24c1a833b7395cdf07dd67859f46f",
        "e8073fd5318ff43eca18a852527166aa8008bee9ee9e891f585612b7e4ba700b",
      ])
    end

    it "accepts query parameters for pagination and ordering" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/latest/txs?count=4&page=1&order=asc")
        .to_return(body: read_fixture("block/latest_tx_ids.200.json"))

      Blockfrost::Block.latest_tx_ids(
        count: 4,
        page: 1,
        order: Blockfrost::QueryOrder::ASC
      )
    end

    it "accepts a string as query parameter for ordering" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/latest/txs?order=desc")
        .to_return(body: read_fixture("block/latest_tx_ids.200.json"))

      Blockfrost::Block.latest_tx_ids(order: "desc")
    end

    it "uses default ordering if the order query parameter is invalid" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/latest/txs?order=asc")
        .to_return(body: read_fixture("block/latest_tx_ids.200.json"))

      Blockfrost::Block.latest_tx_ids(order: "forward")
    end
  end

  describe ".next" do
    it "fetches the next block for a given hash" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/5ea1ba291e8eef538635a53e59fddba7810d1679631cc3aed7c8e6c4091a516a/next")
        .to_return(body: read_fixture("block/next.200.json"))

      hash = "5ea1ba291e8eef538635a53e59fddba7810d1679631cc3aed7c8e6c4091a516a"

      Blockfrost::Block.next(hash).first.should be_a(Blockfrost::Block)
    end

    it "fetches the next block for a given block height" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/15243592/next")
        .to_return(body: read_fixture("block/next.200.json"))

      Blockfrost::Block.next(15243592).first.should be_a(Blockfrost::Block)
    end

    it "fetches the next number of blocks at a given page" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/15243592/next?count=3&page=2")
        .to_return(body: read_fixture("block/next.200.json"))

      Blockfrost::Block.next(15243592, count: 3, page: 2).first
        .should be_a(Blockfrost::Block)
    end
  end

  describe "#next" do
    it "fetches the next block in relation to the current block" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/15243592")
        .to_return(body: read_fixture("block/block.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/4ea1ba291e8eef538635a53e59fddba7810d1679631cc3aed7c8e6c4091a516a/next")
        .to_return(body: read_fixture("block/next.200.json"))

      Blockfrost::Block.get(15243592).next.first
        .should be_a(Blockfrost::Block)
    end
  end

  describe ".previous" do
    it "fetches the previous block for a given hash" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/5ea1ba291e8eef538635a53e59fddba7810d1679631cc3aed7c8e6c4091a516a/previous")
        .to_return(body: read_fixture("block/previous.200.json"))

      hash = "5ea1ba291e8eef538635a53e59fddba7810d1679631cc3aed7c8e6c4091a516a"

      Blockfrost::Block.previous(hash).first.should be_a(Blockfrost::Block)
    end

    it "fetches the previous block for a given block height" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/15243592/previous")
        .to_return(body: read_fixture("block/previous.200.json"))

      height = 15243592

      Blockfrost::Block.previous(height).first.should be_a(Blockfrost::Block)
    end

    it "fetches the previous number of blocks at a given page" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/15243592/previous?count=3&page=2")
        .to_return(body: read_fixture("block/previous.200.json"))

      Blockfrost::Block.previous(15243592, count: 3, page: 2).first
        .should be_a(Blockfrost::Block)
    end
  end

  describe "#previous" do
    it "fetches the previous block in relation to the current block" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/15243592")
        .to_return(body: read_fixture("block/block.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/4ea1ba291e8eef538635a53e59fddba7810d1679631cc3aed7c8e6c4091a516a/previous")
        .to_return(body: read_fixture("block/previous.200.json"))

      Blockfrost::Block.get(15243592).previous.first
        .should be_a(Blockfrost::Block)
    end
  end
end
