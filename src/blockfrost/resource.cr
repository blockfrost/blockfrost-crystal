abstract struct Blockfrost::Resource
  include JSON::Serializable

  def self.client : Client
    Client.new
  end

  def self.order_from_string(order : String?) : QueryOrder?
    order ? QueryOrder.from_string(order) : nil
  end

  def order_from_string(**args)
    self.order_from_string(**args)
  end
end
