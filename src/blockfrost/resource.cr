abstract struct Blockfrost::Resource
  include JSON::Serializable

  def self.client : Client
    Client.new
  end
end
