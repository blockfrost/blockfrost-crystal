abstract struct Blockfrost::Resource
  include JSON::Serializable

  def self.client
    Client.new
  end
end
