module Blockfrost
  annotation Networks
  end
  annotation RequestExceptions
  end
end

@[Blockfrost::Networks({
  :ipfs,
  :mainnet,
  :milkmainnet,
  :milktestnet,
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
