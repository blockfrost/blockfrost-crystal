struct Blockfrost::Root
  include JSON::Serializable

  getter url : String
  getter version : String

  # Root endpoint has no other function than to point end users to
  # documentation.
  #
  # ```
  # Blockfrost::Root.get
  # ```
  def self.get
    Root.from_json(Client.get("/"))
  end
end
