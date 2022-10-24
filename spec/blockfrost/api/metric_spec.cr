require "../../spec_helper"

describe Blockfrost::Metric do
  before_each do
    configure_api_keys
  end

  describe ".all" do
    it "fetches the metrics endpoint " do
      WebMock.stub(:get, "https://cardano-testnet.blockfrost.io/api/v0/metrics")
        .to_return(body: read_fixture("metric/all.200.json"))

      Blockfrost::Metric.all.tap do |metrics|
        metrics.first.time.should eq(Time.unix(1612543884))
        metrics.first.calls.should eq(42)
      end
    end
  end

  describe ".endpoints" do
    it "fetches the metric endpoints endpoint " do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/metrics/endpoints")
        .to_return(body: read_fixture("metric/endpoints.200.json"))

      Blockfrost::Metric.endpoints.tap do |metrics|
        metrics.first.time.should eq(Time.unix(1612543814))
        metrics.first.calls.should eq(182)
        metrics.first.endpoint.should eq("block")
      end
    end
  end
end
