module Blockfrost
  alias QueryData = Hash(String, Int32 | String?)
  alias BodyData = IO | String

  Blockfrost.enum_castable_from_string(QueryOrder, {
    ASC,
    DESC,
  }, downcase)
end
