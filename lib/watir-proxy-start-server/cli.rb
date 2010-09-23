require 'optparse'

module WatirProxyStartServer
  class CLI
    def self.execute(stdout, arguments=[], &block)

      options = { }
      mandatory_options = %w(  )

      parser = OptionParser.new do |opts|
        opts.banner = <<-BANNER.gsub(/^          /,'')
          Usage: #{File.basename($0)} [options]

          Options are:
        BANNER
        opts.separator ""
        opts.on("-d", "--drb-uri URI", String,
                "URI passed to DRb.start_service",
                "Default: " + WatirProxy::Server.default_drb_uri
               ) { |arg| options[:drb_uri] = arg }
        opts.on("-h", "--help",
                "Show this help message.") { stdout.puts opts; exit }
        opts.parse!(arguments)

        if mandatory_options && mandatory_options.find { |option| options[option.to_sym].nil? }
          stdout.puts opts; exit
        end
      end

      WatirProxy::Server.start_service(options) do
        block.call stdout if block
      end
      WatirProxy::Server.thread.join if WatirProxy::Server.thread
    end
  end
end
