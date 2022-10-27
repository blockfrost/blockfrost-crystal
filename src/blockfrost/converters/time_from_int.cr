module Blockfrost
  struct TimeFromInt
    def self.from_json(pull : JSON::PullParser)
      Time.unix(pull.read_int.to_i)
    end

    def self.to_json(value : Time, json : JSON::Builder)
      value.to_unix
    end
  end
end
