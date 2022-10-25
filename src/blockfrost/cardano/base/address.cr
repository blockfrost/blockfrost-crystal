abstract struct Blockfrost::BaseAddress
  include JSON::Serializable

  getter address : String
  getter stake_address : String?
  getter script : Bool
end
