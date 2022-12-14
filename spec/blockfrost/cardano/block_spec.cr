require "../../spec_helper"

describe Blockfrost::Block do
  before_each do
    configure_api_keys
  end

  describe ".get" do
    it "fetches the block for a given hash" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/5ea1ba291e8eef538635a53e59fddba7810d1679631cc3aed7c8e6c4091a516a")
        .with(
          headers: {
            "Accept"       => "application/json",
            "Content-Type" => "application/json",
            "User-Agent"   => Blockfrost::Client.sdk_version_string,
            "project_id"   => test_cardano_api_key,
          })
        .to_return(body_io: read_fixture("block/block.200.json"))

      Blockfrost::Block.get("5ea1ba291e8eef538635a53e59fddba7810d1679631cc3aed7c8e6c4091a516a")
        .should be_a(Blockfrost::Block)
    end

    it "fetches the block for a given height" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/15243593")
        .to_return(body_io: read_fixture("block/block.200.json"))

      Blockfrost::Block.get(15243593).should be_a(Blockfrost::Block)
    end
  end

  describe ".latest" do
    it "fetches the latest block" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/latest"
      ).to_return(body_io: read_fixture("block/latest.200.json"))

      block = Blockfrost::Block.latest
      block.block_vrf.should eq(
        "vrf_vk1wf2k6lhujezqcfe00l6zetxpnmh9n6mwhpmhm0dvfh3fxgmdnrfqkms8ty"
      )
      block.confirmations.should eq(4698)
      block.epoch.should eq(425)
      block.epoch_slot.should eq(12)
      block.fees.should eq(592661)
      block.hash.should eq(
        "4ea1ba291e8eef538635a53e59fddba7810d1679631cc3aed7c8e6c4091a516a"
      )
      block.height.should eq(15243593)
      block.next_block.should eq(
        "8367f026cf4b03e116ff8ee5daf149b55ba5a6ec6dec04803b8dc317721d15fa"
      )
      block.op_cert.should eq(
        "da905277534faf75dae41732650568af545134ee08a3c0392dbefc8096ae177c"
      )
      block.op_cert_counter.should eq(18)
      block.output.should eq(128314491794)
      block.previous_block.should eq(
        "43ebccb3ac72c7cebd0d9b755a4b08412c9f5dcb81b8a0ad1e3c197d29d47b05"
      )
      block.size.should eq(3)
      block.slot.should eq(412162133)
      block.slot_leader.should eq(
        "pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2qnikdy"
      )
      block.time.should eq(Time.unix(1641338934))
      block.tx_count.should eq(1)
    end

    {% begin %}
      {% for name, status in Blockfrost
                               .annotation(Blockfrost::RequestExceptions)
                               .args.first %}
        it "handels {{status}} exceptions" do
          WebMock.stub(
            :get, "https://cardano-testnet.blockfrost.io/api/v0/blocks/latest"
          ).to_return(
            body_io: read_fixture("block/latest.{{status}}.json"),
            status: {{status}}
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
      ).to_return(body_io: read_fixture("block/latest.403.json"), status: 403)

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
        .to_return(body_io: read_fixture("block/tx_ids.200.json"))

      Blockfrost::Block.latest_tx_ids.should eq([
        "8788591983aa73981fc92d6cddbbe643959f5a784e84b8bee0db15823f575a5b",
        "4eef6bb7755d8afbeac526b799f3e32a624691d166657e9d862aaeb66682c036",
        "52e748c4dec58b687b90b0b40d383b9fe1f24c1a833b7395cdf07dd67859f46f",
        "e8073fd5318ff43eca18a852527166aa8008bee9ee9e891f585612b7e4ba700b",
      ])
    end

    it "accepts query parameters for pagination and ordering" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/latest/txs?order=asc&count=4&page=1")
        .to_return(body_io: read_fixture("block/tx_ids.200.json"))

      Blockfrost::Block.latest_tx_ids(
        order: Blockfrost::QueryOrder::ASC,
        count: 4,
        page: 1
      )
    end

    it "accepts a string as query parameter for ordering" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/latest/txs?order=desc")
        .to_return(body_io: read_fixture("block/tx_ids.200.json"))

      Blockfrost::Block.latest_tx_ids(order: "desc")
    end

    it "uses default api ordering if the order query parameter is invalid" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/latest/txs")
        .to_return(body_io: read_fixture("block/tx_ids.200.json"))

      Blockfrost::Block.latest_tx_ids(order: "forward")
    end
  end

  describe ".tx_ids" do
    it "fetches the latest transaction ids for the given block" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/15243592/txs")
        .to_return(body_io: read_fixture("block/tx_ids.200.json"))

      Blockfrost::Block.tx_ids(15243592).should be_a(Array(String))
    end
  end

  describe "#tx_ids" do
    it "fetches the latest transaction ids for the current block" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/latest")
        .to_return(body_io: read_fixture("block/block.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/4ea1ba291e8eef538635a53e59fddba7810d1679631cc3aed7c8e6c4091a516a/txs")
        .to_return(body_io: read_fixture("block/tx_ids.200.json"))

      Blockfrost::Block.latest.tx_ids.should be_a(Array(String))
    end
  end

  describe ".next" do
    it "fetches the next block for a given hash" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/5ea1ba291e8eef538635a53e59fddba7810d1679631cc3aed7c8e6c4091a516a/next")
        .to_return(body_io: read_fixture("block/next.200.json"))

      hash = "5ea1ba291e8eef538635a53e59fddba7810d1679631cc3aed7c8e6c4091a516a"

      Blockfrost::Block.next(hash).first.should be_a(Blockfrost::Block)
    end

    it "fetches the next block for a given block height" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/15243592/next")
        .to_return(body_io: read_fixture("block/next.200.json"))

      Blockfrost::Block.next(15243592).first.should be_a(Blockfrost::Block)
    end

    it "fetches the next number of blocks at a given page" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/15243592/next?count=3&page=2")
        .to_return(body_io: read_fixture("block/next.200.json"))

      Blockfrost::Block.next(15243592, count: 3, page: 2).first
        .should be_a(Blockfrost::Block)
    end
  end

  describe "#next" do
    it "fetches the next block in relation to the current block" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/15243592")
        .to_return(body_io: read_fixture("block/block.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/4ea1ba291e8eef538635a53e59fddba7810d1679631cc3aed7c8e6c4091a516a/next")
        .to_return(body_io: read_fixture("block/next.200.json"))

      Blockfrost::Block.get(15243592).next.first
        .should be_a(Blockfrost::Block)
    end
  end

  describe ".previous" do
    it "fetches the previous block for a given hash" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/5ea1ba291e8eef538635a53e59fddba7810d1679631cc3aed7c8e6c4091a516a/previous")
        .to_return(body_io: read_fixture("block/previous.200.json"))

      hash = "5ea1ba291e8eef538635a53e59fddba7810d1679631cc3aed7c8e6c4091a516a"

      Blockfrost::Block.previous(hash).first.should be_a(Blockfrost::Block)
    end

    it "fetches the previous block for a given block height" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/15243592/previous")
        .to_return(body_io: read_fixture("block/previous.200.json"))

      height = 15243592

      Blockfrost::Block.previous(height).first.should be_a(Blockfrost::Block)
    end

    it "fetches the previous number of blocks at a given page" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/15243592/previous?count=3&page=2")
        .to_return(body_io: read_fixture("block/previous.200.json"))

      Blockfrost::Block.previous(15243592, count: 3, page: 2).first
        .should be_a(Blockfrost::Block)
    end
  end

  describe "#previous" do
    it "fetches the previous block in relation to the current block" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/15243592")
        .to_return(body_io: read_fixture("block/block.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/4ea1ba291e8eef538635a53e59fddba7810d1679631cc3aed7c8e6c4091a516a/previous")
        .to_return(body_io: read_fixture("block/previous.200.json"))

      Blockfrost::Block.get(15243592).previous.first
        .should be_a(Blockfrost::Block)
    end
  end

  describe ".in_slot" do
    it "fetches the block for a given slot number" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/slot/30895909")
        .to_return(body_io: read_fixture("block/block.200.json"))

      Blockfrost::Block.in_slot(30895909).should be_a(Blockfrost::Block)
    end
  end

  describe ".in_epoch_in_slot" do
    it "fetches the block for a given epoch and slot number" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/epoch/219/slot/30895909")
        .to_return(body_io: read_fixture("block/block.200.json"))

      Blockfrost::Block.in_epoch_in_slot(219, 30895909)
        .should be_a(Blockfrost::Block)
    end
  end

  describe ".addresses" do
    it "fetches addresses with transactions for a given block height" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/15243593/addresses")
        .to_return(body_io: read_fixture("block/addresses.200.json"))

      Blockfrost::Block.addresses(15243593)
        .should be_a(Array(Blockfrost::Block::Address))
    end

    it "accepts pagination parameters" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/15243593/addresses?count=3&page=2")
        .to_return(body_io: read_fixture("block/addresses.200.json"))

      Blockfrost::Block.addresses(15243593, count: 3, page: 2)
        .should be_a(Array(Blockfrost::Block::Address))
    end

    it "fetches addresses with transactions for a given block height concurrently" do
      1.upto(3) do |p|
        WebMock.stub(:get,
          "https://cardano-testnet.blockfrost.io/api/v0/blocks/15243593/addresses?count=100&page=#{p}")
          .to_return(body_io: read_fixture("block/addresses.200.json"))
      end

      Blockfrost::Block.addresses(15243593, 1..3)
        .should be_a(Array(Blockfrost::Block::Address))
    end
  end

  describe "#addresses" do
    it "fetches addresses with transactions for the current block" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/latest")
        .to_return(body_io: read_fixture("block/block.200.json"))
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/blocks/4ea1ba291e8eef538635a53e59fddba7810d1679631cc3aed7c8e6c4091a516a/addresses")
        .to_return(body_io: read_fixture("block/addresses.200.json"))

      addresses = Blockfrost::Block.latest.addresses
      addresses.should be_a(Array(Blockfrost::Block::Address))
      addresses.first.address.should eq(
        "addr1q9ld26v2lv8wvrxxmvg90pn8n8n5k6tdst06q2s856rwmvnueldzuuqmnsye359fqrk8hwvenjnqultn7djtrlft7jnq7dy7wv"
      )

      transactions = addresses.first.transactions
      transactions.should be_a(Array(Blockfrost::Block::Transaction))
      transactions.first.tx_hash.should eq(
        "1a0570af966fb355a7160e4f82d5a80b8681b7955f5d44bec0dce628516157f0"
      )
    end
  end
end
