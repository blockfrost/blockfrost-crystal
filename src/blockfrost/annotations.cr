module Blockfrost
  annotation CardanoNetworks
  end
  annotation RequestExceptions
  end
end

@[Blockfrost::CardanoNetworks({
  :mainnet,
  :preprod,
  :preview,
  :testnet,
})]
@[Blockfrost::RequestExceptions({
  BadRequest:  400,
  Forbidden:   403,
  NotFound:    404,
  IpBanned:    418,
  OverLimit:   429,
  ServerError: 500,
})]
module Blockfrost
end
