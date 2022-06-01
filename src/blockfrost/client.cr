struct Blockfrost::Client
  def get(
    resource : String,
    query : Hash? = nil
  )
    perform_http_call("GET", resource, query: query)
  end

  def post(
    resource : String,
    payload : Hash
  )
    perform_http_call("POST", resource, body: payload)
  end

  private def perform_http_call(
    method : String,
    path : String,
    body : Hash = {} of String => String,
    query = {} of String => String
  )
    uri = URI.parse(Blockfrost.config.host)
    uri.path = File.join("/api", Blockfrost.config.api_version, path)
    query_string(query).tap { |q| uri.query = q unless q.nil? }

    begin
      if method == "GET"
        response = HTTP::Client.get(uri, headers: headers)
      else
        response = HTTP::Client.exec(
          method, uri,
          headers: headers,
          body: body.compact.to_json
        )
      end
      render(response)
    rescue e : IO::TimeoutError
      raise TimeoutException.new(e.message)
    rescue e : IO::EOFError
      raise Exception.new(e.message)
    end
  end

  private def headers
    HTTP::Headers{
      "Accept"       => "application/json",
      "Content-Type" => "application/json",
      "project_id"   => Blockfrost.config.api_key,
    }
  end

  private def query_string(query : Hash?) : String?
    query = query.try(&.compact.transform_values(&.to_s))
    URI::Params.encode(query) unless query.nil?
  end

  private def render(response : HTTP::Client::Response)
    case response.status_code
    when 200, 201
      response.body
    when 204
      ""
    when 404
      raise NotFoundException.from_json(response.body)
    else
      raise response.body
    end
  end
end
