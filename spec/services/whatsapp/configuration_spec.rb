require "rails_helper"

RSpec.describe Whatsapp::Configuration do
  let(:settings) { { "WHATSAPP_GRAPH_API_VERSION" => "v26.0", "WHATSAPP_APP_SECRET" => "synthetic-app-secret", "WHATSAPP_VERIFY_TOKEN" => "synthetic-verify-token", "WHATSAPP_ACCESS_TOKEN" => "synthetic-access-token" } }
  let(:configuration) { described_class.new(settings) }

  it "reads named credentials without exposing a configurable provider host" do
    expect(configuration.app_secret).to eq("synthetic-app-secret")
    expect(configuration.verify_token).to eq("synthetic-verify-token")
    expect(configuration.access_token).to eq("synthetic-access-token")
    expect(configuration.graph_api_url).to eq("https://graph.facebook.com/v26.0")
  end

  it "does not require provider secrets to boot the application" do
    expect(described_class.new({})).to be_a(described_class)
  end

  it "does not expose credentials when inspecting the configuration" do
    expect(configuration.inspect).to eq("#<Whatsapp::Configuration>")
  end

  it "fails explicitly without a required setting" do
    expect { described_class.new({}).app_secret }.to raise_error(described_class::MissingSetting, "Missing WHATSAPP_APP_SECRET")
  end

  it "rejects malformed versions without including their values in the error" do
    settings["WHATSAPP_GRAPH_API_VERSION"] = "https://unexpected.invalid"
    expect { configuration.graph_api_url }.to raise_error(described_class::MissingSetting, "WHATSAPP_GRAPH_API_VERSION must use vNN.N format")
  end
end
