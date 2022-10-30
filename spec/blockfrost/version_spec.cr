require "../spec_helper"

describe Blockfrost::VERSION do
  describe "shard.yml" do
    it "matches the current version" do
      info = YAML.parse(File.read("./shard.yml"))

      Blockfrost::VERSION.should eq(info["version"])
    end
  end
end
