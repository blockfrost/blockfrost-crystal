abstract struct Blockfrost::BaseResource
  include JSON::Serializable

  def self.client : Client
    Client.new
  end

  def self.order_from_string(order : String?) : QueryOrder?
    return unless order

    QueryOrder.from_string(order)
  end

  def order_from_string(**args)
    self.order_from_string(**args)
  end
end
