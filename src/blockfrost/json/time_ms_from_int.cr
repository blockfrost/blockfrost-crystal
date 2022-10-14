module Blockfrost
  struct Json
    struct TimeMsFromInt
      def self.from_json(pull : JSON::PullParser)
        Time.unix_ms(pull.read_int.to_i64)
      end

      def self.to_json(value : Time, json : JSON::Builder)
        value.to_unix_ms
      end
    end
  end
end
