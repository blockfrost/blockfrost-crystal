struct Blockfrost::Metadata < Blockfrost::BaseResource
  Blockfrost.gets_all_with_order_and_pagination(
    :labels,
    Array(Label),
    "metadata/txs/labels"
  )

  Blockfrost.gets_all_with_order_and_pagination(
    :label_json_content,
    Array(JsonContent),
    "metadata/txs/labels/#{label}",
    label : String
  )

  Blockfrost.gets_all_with_order_and_pagination(
    :label_cbor_content,
    Array(CborContent),
    "metadata/txs/labels/#{label}/cbor",
    label : String
  )

  struct Label
    include JSON::Serializable

    getter label : String
    getter cip10 : String?
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter count : Int64
  end

  struct JsonContent
    include JSON::Serializable

    getter tx_hash : String
    getter json_metadata : JSON::Any
  end

  struct CborContent
    include JSON::Serializable

    getter tx_hash : String
    getter cbor_metadata : String?
    getter metadata : String?
  end
end
