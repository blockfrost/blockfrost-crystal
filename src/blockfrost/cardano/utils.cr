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

  def self.evaluate_transaction(data : BodyData)
    JSON::Any.from_json(
      Client.post(
        "/utils/txs/evaluate",
        body: data,
        content_type: "application/cbor"
      )
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
