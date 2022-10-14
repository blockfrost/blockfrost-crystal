struct Blockfrost::Client
  enum Method
    GET
    POST
  end

  def get(
    resource : String,
    query : RequestData = RequestData.new
  ) : String
    perform_http_call(Method::GET, resource, query: query)
  end

  def post(
    resource : String,
    body : RequestData
  ) : String
    perform_http_call(Method::POST, resource, body: body)
  end

  private def perform_http_call(
    method : Method,
    path : String,
    body : RequestData = RequestData.new,
    query : RequestData = RequestData.new
  ) : String
    begin
      case method
      when Method::GET
        render(HTTP::Client.get(build_uri(path, query), headers: headers(path)))
      else
        render(
          HTTP::Client.exec(
            method.to_s,
            build_uri(path, query),
            headers: headers(path),
            body: body.compact.to_json
          )
        )
      end
    rescue e : IO::TimeoutError
      raise TimeoutException.new(e.message)
    rescue e : IO::EOFError
      raise Exception.new(e.message)
    end
  end

  private def build_uri(
    path : String,
    query : RequestData
  ) : String
    uri = URI.parse(Blockfrost.host_for_path(path))
    uri.path = File.join("/api", Blockfrost.settings.api_version, path)
    uri.query = QueryString.new(query).build
    uri.to_s
  end

  private def headers(
    path : String
  ) : HTTP::Headers
    HTTP::Headers{
      "Accept"       => "application/json",
      "Content-Type" => "application/json",
      "project_id"   => Blockfrost.api_key_for_path(path),
    }
  end

  private def render(
    response : HTTP::Client::Response
  ) : String
    {% begin %}
      case response.status_code
      when 200, 201
        response.body
      when 204
        ""
      {% for name, status in Blockfrost
                               .annotation(Blockfrost::RequestExceptions)
                               .args.first %}
        when {{status}}
          raise {{name.id}}Exception.from_json(response.body)
      {% end %}
      else
        raise response.body
      end
    {% end %}
  end
end
