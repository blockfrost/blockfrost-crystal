struct Blockfrost::Root
  include JSON::Serializable

  getter url : String
  getter version : String

  def self.get
    Root.from_json(Client.get("/"))
  end
end
