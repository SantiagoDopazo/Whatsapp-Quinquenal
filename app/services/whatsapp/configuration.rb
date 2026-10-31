module Whatsapp
  class Configuration
    class MissingSetting < StandardError; end

    def initialize(environment = ENV)
      @environment = environment
    end

    def verify_token
      required("WHATSAPP_VERIFY_TOKEN")
    end

    def app_secret
      required("WHATSAPP_APP_SECRET")
    end

    def access_token
      required("WHATSAPP_ACCESS_TOKEN")
    end

    def graph_api_version
      required("WHATSAPP_GRAPH_API_VERSION").tap do |version|
        raise MissingSetting, "WHATSAPP_GRAPH_API_VERSION must use vNN.N format" unless version.match?(/\Av\d+\.\d+\z/)
      end
    end

    def graph_api_url
      "https://graph.facebook.com/#{graph_api_version}"
    end

    def inspect
      "#<#{self.class.name}>"
    end

    private

    def required(name)
      @environment[name].presence || raise(MissingSetting, "Missing #{name}")
    end
  end
end
