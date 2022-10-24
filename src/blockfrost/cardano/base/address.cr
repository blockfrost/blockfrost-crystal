abstract struct Blockfrost::BaseAddress < Blockfrost::BaseResource
  getter address : String
  getter stake_address : String?
  getter type : String
  getter script : Bool
end
