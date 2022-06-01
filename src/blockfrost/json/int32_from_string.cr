module Blockfrost
  struct Json
    struct Int32FromString
      def self.from_json(pull : JSON::PullParser)
        pull.read_string.to_s.to_i
      end

      def self.to_json(value : Int32, json : JSON::Builder)
        json.string(value.to_s)
      end
    end
  end
end
