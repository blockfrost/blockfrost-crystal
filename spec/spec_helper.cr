require "spec"
require "webmock"
require "../src/blockfrost"

def fake_api_key
  "testnetVas4TOfOvQeVjTVGxxYNRLOt6Fb4FAKE"
end

def configure_api_key(api_key : String? = fake_api_key) : Void
  Blockfrost.configure do |settings|
    settings.api_key = fake_api_key
    settings.api_version = "v0"
  end
end

def read_fixture(file : String) : String
  path = "#{__DIR__}/fixtures/#{file}"
  if File.exists?(path)
    File.read(path)
  else
    raise Exception.new("Fixture #{file} does not exist.")
  end
end

Spec.after_each do
  WebMock.reset
end
