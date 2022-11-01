struct Blockfrost::QueryString
  getter query : Hash(String, String)

  def initialize(raw_query : QueryData)
    @query = sanitize_raw_query(raw_query)
  end

  def build : String
    URI::Params.encode(@query)
  end

  private def sanitize_raw_query(
    raw_query : QueryData
  ) : Hash(String, String)
    raw_query
      .map { |k, v| sanitize_raw_pair(k, v) }
      .to_h
      .reject { |_, v| v.blank? }
  end

  private def sanitize_raw_pair(
    key : String,
    value : Int32
  ) : Tuple(String, String)
    case key
    when "count"
      {key, limit_upper_value(value, Blockfrost::MAX_COUNT_PER_PAGE).to_s}
    when "page"
      {key, limit_upper_value(value, Blockfrost::MAX_PAGINATION_PAGES).to_s}
    else
      {key, value.to_s}
    end
  end

  private def sanitize_raw_pair(
    key : String,
    value : String?
  ) : Tuple(String, String)
    {key, value.to_s}
  end

  private def limit_upper_value(
    value : Int32,
    limit : Int32
  ) : Int32
    {({1, value}.max), limit}.min
  end
end
