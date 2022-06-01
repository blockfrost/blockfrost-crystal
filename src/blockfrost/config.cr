module Blockfrost
  def self.configure : Void
    yield(Blockfrost.config)
  end

  def self.config : Config
    Fiber.current.blockfrost_config ||= Config.new
  end

  struct Config
    getter host : String
    getter network : String
    property api_key = ENV.fetch("BLOCKFROST_API_KEY")
    property api_version = "v0"

    def initialize
      unless match = api_key.match(/^((main|test)net)/)
        raise InvalidApiKeyException.new("Invalid API key")
      end

      @network = match[1]
      @host = "https://cardano-#{network}.blockfrost.io"
    end
  end
end
