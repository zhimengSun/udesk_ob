module UdeskOb
  # insert middle to rails
  class Railtie < Rails::Railtie
    initializer 'udesk_ob.insert_middleware' do |app|
      app.middleware.use UdeskOb::RailsMiddleware
    end
  end

  # get trace from http request header
  class RailsMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      header_name = "HTTP_#{UdeskOb::Log::HTTP_HEADER.tr('-', '_')}"
      UdeskOb::Log.trace_id = env[header_name] if env.key?(header_name)
      UdeskOb::Log.process_type = 'RailsAction'
      if env.key?('action_dispatch.request_id')
        UdeskOb::Log.process_id = env['action_dispatch.request_id']
      end
      @app.call(env)
    ensure
      UdeskOb::Log.trace_id = nil
    end
  end
end
