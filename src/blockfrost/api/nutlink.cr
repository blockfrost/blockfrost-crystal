struct Blockfrost::Nutlink
  include JSON::Serializable

  getter address : String
  getter metadata_url : String
  getter metadata_hash : String
  getter metadata : JSON::Any?

  def self.get(address : String)
    Nutlink.from_json(Client.get("nutlink/#{address}"))
  end

  Blockfrost.gets_all_with_order_and_pagination(
    :tickers,
    Array(Ticker),
    "nutlink/#{address}/tickers",
    address : String
  )

  Blockfrost.gets_all_scoped_with_order_and_pagination(
    :ticker_records_for_address,
    Array(Ticker::Record),
    "nutlink/#{address}/tickers/#{ticker}",
    address : String,
    ticker : String
  )

  Blockfrost.gets_all_with_order_and_pagination(
    :ticker_records,
    Array(Ticker::Record),
    "nutlink/tickers/#{ticker}",
    ticker : String
  )

  struct Ticker
    include JSON::Serializable

    getter name : String
    getter count : Int32
    getter latest_block : Int32

    struct Record
      include JSON::Serializable

      getter tx_hash : String
      getter block_height : Int32
      getter tx_index : Int32
      getter payload : JSON::Any
    end
  end
end
