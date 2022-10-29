struct Blockfrost::Utils
  include JSON::Serializable

  def self.addresses(
    xpub : String,
    role : Int32,
    index : Int32
  )
    Array(Address).from_json(
      Client.get("utils/addresses/xpub/#{xpub}/#{role}/#{index}")
    )
  end

  struct Address
    include JSON::Serializable

    getter xpub : String
    getter role : Int32
    getter index : Int32
    getter address : String
  end
end
