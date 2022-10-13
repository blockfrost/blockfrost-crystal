module Blockfrost
  annotation RequestExceptions
  end

  @[Blockfrost::RequestExceptions({
    BadRequest:  400,
    Forbidden:   403,
    NotFound:    404,
    IpBanned:    418,
    OverLimit:   429,
    ServerError: 500,
  })]
  class Exception < Exception; end

  class RequestException < Blockfrost::Exception
    def initialize(@mapper : Mapper)
    end

    def self.from_json(json : String)
      new(Mapper.from_json(json))
    end

    delegate error, message, status_code, to: @mapper

    def to_s
      message
    end

    struct Mapper
      include JSON::Serializable

      getter error : String
      getter message : String
      getter status_code : Int32
    end
  end

  struct Client
    {% begin %}
      {% for name in Blockfrost::Exception
                       .annotation(Blockfrost::RequestExceptions)
                       .args
                       .first %}
        class {{name.id}}Exception < Blockfrost::RequestException; end
      {% end %}
    {% end %}

    class TimeoutException < Blockfrost::Exception; end
  end
end
