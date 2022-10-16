struct Blockfrost::Root < Blockfrost::Base::Resource
  getter url : String
  getter version : String

  def self.get : Root
    Root.from_json(client.get("/"))
  end
end
