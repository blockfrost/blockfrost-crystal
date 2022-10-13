module Blockfrost::Utils
  extend self

  def sanitize_query(
    query : Hash(String, Int | String | Nil)
  ) : Client::RequestData
    query.reject { |_, v| v.nil? }.transform_values(&.to_s)
  end
end
