module Blockfrost::Client
  extend self

  enum Method
    GET
    POST
  end

  def get(
    resource : String,
    query : QueryData = QueryData.new
  ) : String
    perform_http_call(Method::GET, resource, query: query)
  end

  def post(
    resource : String,
    body : BodyData,
    content_type : String = "application/json"
  ) : String
    perform_http_call(
      Method::POST,
      resource,
      body: body,
      content_type: content_type
    )
  end

  def sdk_version_string
    "blockfrost-crystal/#{Blockfrost::VERSION} crystal/#{Crystal::VERSION}"
  end

  private def perform_http_call(
    method : Method,
    path : String,
    body : BodyData? = nil,
    query : QueryData = QueryData.new,
    content_type : String = "application/json"
  ) : String
    case method
    when Method::GET
      render(
        HTTP::Client.get(
          build_uri(path, query),
          headers: headers(path, content_type)
        )
      )
    else
      render(
        HTTP::Client.post(
          build_uri(path, query),
          headers: headers(path, content_type),
          body: body
        )
      )
    end
  rescue e : IO::TimeoutError
    raise TimeoutException.new(e.message)
  rescue e : IO::EOFError
    raise Exception.new(e.message)
  end

  private def build_uri(
    path : String,
    query : QueryData
  ) : String
    uri = URI.parse(Blockfrost.host_for_path(path))
    uri.path = File.join("/api", Blockfrost.api_version_for_path(path), path)
    uri.query = QueryString.new(query).build
    uri.to_s
  end

  private def headers(
    path : String,
    content_type : String
  ) : HTTP::Headers
    HTTP::Headers{
      "Accept"       => "application/json",
      "Content-Type" => content_type,
      "User-Agent"   => sdk_version_string,
      "project_id"   => Blockfrost.api_key_for_path(path),
    }
  end

  private def render(response : HTTP::Client::Response) : String
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
