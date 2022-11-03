module Blockfrost
  alias QueryData = Hash(String, Int32 | String?)
  alias BodyData = IO | String

  enum QueryOrder
    ASC
    DESC

    def to_s
      super.downcase
    end

    def self.from_string?(value : String) : QueryOrder?
      return unless value = names.map(&.downcase).index(value)

      from_value(value)
    end
  end
end
