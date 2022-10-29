struct Blockfrost::IPFS
  include JSON::Serializable

  getter name : String
  getter ipfs_hash : String
  @[JSON::Field(converter: Blockfrost::Int64FromString)]
  getter size : Int64

  def self.add(file_path : String)
    reader, writer = IO.pipe

    HTTP::FormData.build(writer) do |formdata|
      File.open(file_path) do |file|
        formdata.file("file", file)
      end
    end

    writer.close

    from_json(
      Client.post(
        "ipfs/add",
        reader,
        content_type: MIME.from_filename(file_path)
      )
    )
  end

  struct Pin
    include JSON::Serializable

    getter name : String
    getter ipfs_hash : String
    @[JSON::Field(converter: Blockfrost::Int64FromString)]
    getter size : Int64
  end
end
