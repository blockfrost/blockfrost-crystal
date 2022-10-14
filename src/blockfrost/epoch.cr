struct Blockfrost::Epoch < Blockfrost::Resource
  getter epoch : Int32
  @[JSON::Field(converter: Blockfrost::Json::TimeFromInt)]
  getter start_time : Time
  @[JSON::Field(converter: Blockfrost::Json::TimeFromInt)]
  getter end_time : Time
  @[JSON::Field(converter: Blockfrost::Json::TimeFromInt)]
  getter first_block_time : Time
  @[JSON::Field(converter: Blockfrost::Json::TimeFromInt)]
  getter last_block_time : Time
  getter block_count : Int32
  getter tx_count : Int32
  @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
  getter output : Int64
  @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
  getter fees : Int64
  @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
  getter active_stake : Int64

  def self.get(epoch_number : Int32) : Epoch
    Epoch.from_json(client.get("epochs/#{epoch_number}"))
  end

  def self.latest : Epoch
    Epoch.from_json(client.get("epochs/latest"))
  end

  {% for key in %w[next previous] %}
    def self.{{key.id}}(
      epoch_number : Int32,
      count : QueryCount? = nil,
      page : QueryPage? = nil
    ) : Array(Epoch)
      Array(Epoch).from_json(
        client.get("epochs/#{epoch_number}/{{key.id}}", {
          "count" => count,
          "page" => page
        })
      )
    end

    def {{key.id}}(**args) : Array(Epoch)
      Epoch.{{key.id}}(epoch, **args)
    end
  {% end %}

  def self.stakes(
    epoch_number : Int32,
    count : QueryCount? = nil,
    page : QueryPage? = nil
  ) : Array(Stake)
    Array(Stake).from_json(
      client.get("epochs/#{epoch_number}/stakes", {
        "count" => count,
        "page"  => page,
      })
    )
  end

  def self.stakes_by_pool(
    epoch_number : Int32,
    pool_id : String,
    count : QueryCount? = nil,
    page : QueryPage? = nil
  ) : Array(Stake)
    Array(Stake).from_json(
      client.get("epochs/#{epoch_number}/stakes/#{pool_id}", {
        "count" => count,
        "page"  => page,
      })
    )
  end

  def self.block_ids(
    epoch_number : Int32,
    count : QueryCount? = nil,
    page : QueryPage? = nil
  ) : Array(String)
    Array(String).from_json(
      client.get("epochs/#{epoch_number}/blocks", {
        "count" => count,
        "page"  => page,
      })
    )
  end

  def self.block_ids_by_pool(
    epoch_number : Int32,
    pool_id : String,
    count : QueryCount? = nil,
    page : QueryPage? = nil
  ) : Array(String)
    Array(String).from_json(
      client.get("epochs/#{epoch_number}/blocks/#{pool_id}", {
        "count" => count,
        "page"  => page,
      })
    )
  end

  def self.parameters(
    epoch_number : Int32
  ) : Parameters
    Parameters.from_json(client.get("epochs/#{epoch_number}/parameters"))
  end

  struct Stake
    include JSON::Serializable

    getter stake_address : String
    getter pool_id : String
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter amount : Int64
  end

  struct Parameters
    include JSON::Serializable

    getter epoch : Int32
    getter min_fee_a : Int32
    getter min_fee_b : Int32
    getter max_block_size : Int32
    getter max_tx_size : Int32
    getter max_block_header_size : Int32
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter key_deposit : Int64
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter pool_deposit : Int64
    getter e_max : Int32
    getter n_opt : Int32
    getter a0 : Float64
    getter rho : Float64
    getter tau : Float64
    getter decentralisation_param : Float64
    getter extra_entropy : String?
    getter protocol_major_ver : Int32
    getter protocol_minor_ver : Int32
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter min_utxo : Int64
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter min_pool_cost : Int64
    getter nonce : String
    getter cost_models : Hash(String, Hash(String, Int32))?
    getter price_mem : Float64?
    getter price_step : Float64?
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter max_tx_ex_mem : Int64?
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter max_tx_ex_steps : Int64?
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter max_block_ex_mem : Int64?
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter max_block_ex_steps : Int64?
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter max_val_size : Int64?
    getter collateral_percent : Int32?
    getter max_collateral_inputs : Int32?
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter coins_per_utxo_size : Int64?
  end
end
