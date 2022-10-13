require "../spec_helper"

describe Blockfrost::Block do
  before_each do
    configure_api_key
  end

  describe ".latest" do
    it "loads the latest block" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v9/blocks/latest"
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
      {% for name, status in Blockfrost::Exception
                               .annotation(Blockfrost::RequestExceptions)
                               .args
                               .first %}
        it "handels {{status}} exceptions" do
          WebMock.stub(
            :get, "https://cardano-testnet.blockfrost.io/api/v9/blocks/latest"
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
        "https://cardano-testnet.blockfrost.io/api/v9/blocks/latest"
      ).to_return(body: read_fixture("block/latest.403.json"), status: 403)

      expect_raises(
        Blockfrost::Client::ForbiddenException,
        "Invalid project token."
      ) do
        Blockfrost::Block.latest
      end
    end
  end
end
