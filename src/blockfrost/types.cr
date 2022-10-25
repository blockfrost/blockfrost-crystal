module Blockfrost
  alias RequestData = Hash(String, Int32 | String?)

  alias QueryCount = Int32
  alias QueryPage = Int32

  Blockfrost.castable_enum_from_string(QueryOrder, {
    ASC,
    DESC,
  }, downcase)

  enum ContentType
    Json
    Cbor

    def to_s
      "application/#{super.downcase}"
    end
  end
end
