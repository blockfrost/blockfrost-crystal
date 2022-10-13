struct Blockfrost::Client
  alias RequestData = Hash(String, String)

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
        render(HTTP::Client.get(build_uri(path, query), headers: headers))
      else
        render(
          HTTP::Client.exec(
            method.to_s,
            build_uri(path, query),
            headers: headers,
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
    uri = URI.parse(Blockfrost.host)
    uri.path = File.join("/api", Blockfrost.settings.api_version, path)
    query_string(query).tap { |q| uri.query = q unless q.blank? }
    uri.to_s
  end

  private def query_string(
    query : RequestData
  ) : String
    return "" if query.compact.empty?

    URI::Params.encode(query.compact.transform_values(&.to_s))
  end

  private def headers : HTTP::Headers
    HTTP::Headers{
      "Accept"       => "application/json",
      "Content-Type" => "application/json",
      "project_id"   => Blockfrost.settings.api_key,
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
      {% for name, status in Blockfrost::Exception
                               .annotation(Blockfrost::RequestExceptions)
                               .args
                               .first %}
        when {{status}}
          raise {{name.id}}Exception.from_json(response.body)
      {% end %}
      else
        raise response.body
      end
    {% end %}
  end
end
