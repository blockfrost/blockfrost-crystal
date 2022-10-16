abstract struct Blockfrost::BaseAddress < Blockfrost::Resource
  getter address : String
  getter stake_address : String?
  getter type : String
  getter script : Bool
end

struct Blockfrost::Address < Blockfrost::BaseAddress
  getter amount : Array(Token)

  def self.get(address : String) : Address
    Address.from_json(client.get("addresses/#{address}"))
  end

  def self.extended(address : String) : Address::Extended
    Address::Extended.from_json(client.get("addresses/#{address}/extended"))
  end

  def self.total(address : String) : Total
    Total.from_json(client.get("addresses/#{address}/total"))
  end

  struct Extended < BaseAddress
    getter amount : Array(Token::Extended)
  end

  struct Total
    include JSON::Serializable

    getter address : String
    getter received_sum : Array(Token)
    getter sent_sum : Array(Token)
    getter tx_count : Int32
  end
end
