module Blockfrost
  alias RequestData = Hash(String, Int32 | String?)

  alias QueryCount = Int32
  alias QueryPage = Int32

  enum QueryOrder
    ASC
    DESC

    def to_s
      super.downcase
    end

    def self.from_string(value : String) : QueryOrder
      QueryOrder.from_value(
        QueryOrder.names.map(&.underscore).index(value) || 0
      )
    end
  end

  enum ContentType
    Json
    Cbor

    def to_s
      "application/#{super.downcase}"
    end
  end
end
