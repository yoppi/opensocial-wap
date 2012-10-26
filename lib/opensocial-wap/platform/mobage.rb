module OpensocialWap
  module Platform
    # Singleton Pattern
    extend self

    API_ENDPOINT_BASE = "app.mbga.jp/api/restful/v1/"
    CONTAINER_HOST_BASE = "pf.mbga.jp"

    def mobage(config, &block)
      @config = config
      @sandbox = false
      instance_eval(&block)

      consumer_key    = @consumer_key
      consumer_secret = @consumer_secret
      app_id          = @app_id
      api_endpoint = proc { |request|
        if request.mobile?
          _api_endpoint
        else
          _api_endpoint(true)
        end
      }

      OpensocialWap::OAuth::Helpers::MobageHelper.configure do
        consumer_key    consumer_key
        consumer_secret consumer_secret
        api_endpoint    api_endpoint
        app_id          app_id
      end
      @config.opensocial_wap.oauth = OpensocialWap::Config::OAuth.configure do
        helper_class OpensocialWap::OAuth::Helpers::MobageHelper
      end
      @config.opensocial_wap.url = proc { |context|
        if context.request.mobile?
          _ = _container_host
          OpensocialWap::Config::Url.configure do
            container_host _
            default        :format => :full
            redirect       :format => :local
            public_path    :format => :local
          end
        else
          _ = _container_host(true)
          OpensocialWap::Config::Url.configure do
            container_host _
            default        :format => :full
            redirect       :format => :local
            public_path    :format => :local
          end
        end
      }
      @config.opensocial_wap.session_id = @session ? :parameter : :cookie
    end

    def _container_host(sp=false)
      _ = (sp ? "sp.#{CONTAINER_HOST_BASE}" : CONTAINER_HOST_BASE)
      @sandbox ? "sb.#{_}" : _
    end

    def _api_endpoint(sp=false)
      _ = (sp ? "sp.#{API_ENDPOINT_BASE}" : API_ENDPOINT_BASE)
      @sandbox ? "http://sb.#{_}" : "http://#{_}"
    end
  end
end
