require "spec"
require "webmock"
require "../src/blockfrost"

def fake_cardano_api_key
  "testnetVas4TOfOvQeVjTVGxxYNRLOt6Fb4FAKE"
end

def fake_ipfs_api_key
  "ipfsVas4TOfOvQeVjTVGxxYNRLOt6Fb4FAKE"
end

def configure_api_keys(
  cardano_api_key : String = fake_cardano_api_key,
  ipfs_api_key : String = fake_ipfs_api_key
) : Void
  Blockfrost.configure do |settings|
    settings.cardano_api_key = cardano_api_key
    settings.ipfs_api_key = ipfs_api_key
    settings.api_version = "v0"
  end
end

def read_fixture(file : String) : String
  path = "#{__DIR__}/fixtures/#{file}"

  File.exists?(path) ||
    raise Exception.new("Fixture #{file} does not exist.")

  File.read(path)
end

Spec.after_each do
  WebMock.reset
end
