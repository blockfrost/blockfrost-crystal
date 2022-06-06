struct Blockfrost::Unit::Lovelace < Blockfrost::Unit
  def to_ada
    value / 1_000_000
  end
end
