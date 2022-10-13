struct Blockfrost::QueryString
  getter query : Hash(String, String)

  def initialize(raw_query : RequestData)
    @query = sanitize_raw_query(raw_query)
  end

  def build : String
    URI::Params.encode(@query)
  end

  private def sanitize_raw_query(
    raw_query : RequestData
  ) : Hash(String, String)
    raw_query.transform_values(&.to_s).reject { |_, v| v.blank? }
  end
end
