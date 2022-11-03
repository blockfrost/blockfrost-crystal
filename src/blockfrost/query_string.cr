struct Blockfrost::QueryString
  getter query : Hash(String, String)

  def initialize(raw_query : QueryData)
    @query = default_values.merge(sanitized_raw_query(raw_query))
  end

  def build : String
    URI::Params.encode(@query)
  end

  private def sanitized_raw_query(
    raw_query : QueryData
  ) : Hash(String, String)
    raw_query
      .map { |k, v| sanitized_raw_pair(k, v) }
      .to_h
      .reject { |_, v| v.blank? }
  end

  private def sanitized_raw_pair(
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

  private def sanitized_raw_pair(
    key : String,
    value : QueryOrder | String?
  ) : Tuple(String, String)
    case key
    when "order"
      {key, QueryOrder.from_string?(value.to_s).to_s}
    else
      {key, value.to_s}
    end
  end

  private def limit_upper_value(
    value : Int32,
    limit : Int32
  ) : Int32
    {({1, value}.max), limit}.min
  end

  private def default_values : Hash(String, String)
    {
      "order" => default_order,
      "count" => default_count_per_page,
    }.compact
  end

  private def default_order : String?
    value = Blockfrost.settings.default_order
    value.to_s unless value.nil? || value == DEFAULT_API_ORDER
  end

  private def default_count_per_page : String?
    value = Blockfrost.settings.default_count_per_page
    value.to_s unless value.nil? || value == DEFAULT_API_COUNT_PER_PAGE
  end
end
