module Blockfrost
  alias QueryData = Hash(String, Int32 | String?)
  alias BodyData = IO | String

  alias QueryCount = Int32
  alias QueryPage = Int32

  Blockfrost.enum_castable_from_string(QueryOrder, {
    ASC,
    DESC,
  }, downcase)
end
