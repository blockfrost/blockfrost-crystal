struct Blockfrost::Metadata
  include JSON::Serializable

  Blockfrost.gets_all_with_order_and_pagination(
    :labels,
    Array(Label),
    "metadata/txs/labels"
  )

  Blockfrost.gets_all_with_order_and_pagination(
    :label_json_content,
    Array(ContentJSON),
    "metadata/txs/labels/#{label}",
    label : String
  )

  Blockfrost.gets_all_with_order_and_pagination(
    :label_cbor_content,
    Array(ContentCBOR),
    "metadata/txs/labels/#{label}/cbor",
    label : String
  )

  struct Label
    include JSON::Serializable

    getter label : String
    getter cip10 : String?
    @[JSON::Field(converter: Blockfrost::Int128FromString)]
    getter count : Int128
  end

  struct ContentJSON
    include JSON::Serializable

    getter tx_hash : String
    getter json_metadata : JSON::Any
  end

  struct ContentCBOR
    include JSON::Serializable

    getter tx_hash : String
    getter cbor_metadata : String?
    getter metadata : String?
  end
end
