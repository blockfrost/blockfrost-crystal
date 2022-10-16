struct Blockfrost::Root < Blockfrost::BaseResource
  getter url : String
  getter version : String

  def self.get : Root
    Root.from_json(client.get("/"))
  end
end
