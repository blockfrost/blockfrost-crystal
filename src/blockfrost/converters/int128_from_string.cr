module Blockfrost
  struct Int128FromString
    def self.from_json(pull : JSON::PullParser)
      pull.read_string.to_s.to_i128
    end

    def self.to_json(value : Int128, json : JSON::Builder)
      json.string(value.to_s)
    end
  end
end
