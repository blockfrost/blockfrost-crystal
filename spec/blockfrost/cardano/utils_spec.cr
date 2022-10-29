require "../../spec_helper"

describe Blockfrost::Utils do
  before_each do
    configure_api_keys
  end

  describe ".addresses" do
    it "derive a Shelley address from an xpub" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/utils/addresses/xpub/#{test_xpub}/0/0")
        .to_return(body_io: read_fixture("utils/addresses.200.json"))

      address = Blockfrost::Utils.addresses(test_xpub, 0, 0).first
      address.xpub.should eq(test_xpub)
      address.role.should eq(0)
      address.index.should eq(0)
      address.address.should eq(
        "addr1q90sqnljxky88s0jsnps48jd872p7znzwym0jpzqnax6qs5nfrlkaatu28n0qzmqh7f2cpksxhpc9jefx3wrl0a2wu8q5amen7"
      )
    end
  end
end

private def test_xpub
  "d507c8f866691bd96e131334c355188b1a1d0b2fa0ab11545075aab332d77d9eb19657ad13ee581b56b0f8d744d66ca356b93d42fe176b3de007d53e9c4c4e7a"
end
