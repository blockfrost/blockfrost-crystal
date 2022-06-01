module Blockfrost
  struct Json
    struct Int64FromString
      def self.from_json(pull : JSON::PullParser)
        pull.read_string.to_s.to_i64
      end

      def self.to_json(value : Int64, json : JSON::Builder)
        json.string(value.to_s)
      end
    end
  end
end
