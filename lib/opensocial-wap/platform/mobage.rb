module OpensocialWap
  module Platform
    # Singleton Pattern
    extend self

    API_ENDPOINT_BASE = "app.mbga.jp/api/restful/v1/"
    FP_CONTAINER_HOST = "pf.mbga.jp/%s"
    SB_FP_CONTAINER_HOST = "sb" + FP_CONTAINER_HOST
    SP_CONTAINER_HOST = "g%s.sp.pf.mbga.jp"
    SB_SP_CONTAINER_HOST = "g%s.sb.sp.pf.mbga.jp"

    def mobage(config, &block)
      @config = config
      @sandbox = false
      instance_eval(&block)

      consumer_key    = @consumer_key
      consumer_secret = @consumer_secret
      app_id          = @app_id
      api_endpoint = lambda { |request|
        if request && request.smart_phone?
          _api_endpoint(true)
        else
          _api_endpoint
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
      @config.opensocial_wap.url = lambda { |context|
        if context.request.smart_phone?
          _ = _container_host(true)
          OpensocialWap::Config::Url.configure do
            container_host _
            default        :format => :full
            redirect       :format => :local
            public_path    :format => :local
          end
        else
          _ = _container_host
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
      if @sandbox
        sp ? SB_SP_CONTAINER_HOST : SB_FP_CONTAINER_HOST
      else
        sp ? SP_CONTAINER_HOST : FP_CONTAINER_HOST
      end
    end

    def _api_endpoint(sp=false)
      _ = (sp ? "sp.#{API_ENDPOINT_BASE}" : API_ENDPOINT_BASE)
      @sandbox ? "http://sb.#{_}" : "http://#{_}"
    end
  end
end
