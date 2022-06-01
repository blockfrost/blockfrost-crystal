module Blockfrost
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

  struct Config
    class InvalidApiKeyException < ::Exception; end
  end

  struct Client
    class NotFoundException < Blockfrost::RequestException; end

    class TimeoutException < Blockfrost::Exception; end
  end
end
