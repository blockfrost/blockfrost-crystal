module Blockfrost::IPFS
  def self.add(file_path : String)
    reader, writer = IO.pipe

    HTTP::FormData.build(writer) do |formdata|
      File.open(file_path) do |file|
        formdata.file("file", file)
      end
    end

    writer.close

    Object.from_json(
      Client.post(
        "ipfs/add",
        reader,
        content_type: MIME.from_filename(file_path)
      )
    )
  end

  def self.gateway(ipfs_path : String)
    String.from_json(Client.get("ipfs/gateway/#{ipfs_path}"))
  end

  def self.pin(ipfs_path : String)
    Pin.from_json(Client.post("ipfs/pin/add/#{ipfs_path}", ""))
  end

  struct Object
    include JSON::Serializable

    getter name : String
    getter ipfs_hash : String
    @[JSON::Field(converter: Blockfrost::Int64FromString)]
    getter size : Int64
  end

  struct Pin
    include JSON::Serializable

    Blockfrost.enum_castable_from_string(State, {
      Queued,
      Pinned,
      Unpinned,
      Failed,
      Gc,
    })

    getter ipfs_hash : String
    getter state : State
  end
end
