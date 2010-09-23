require File.dirname(__FILE__) + '/spec_helper.rb'

require 'webrick'

describe WatirProxy do

  before :all do
    @access_log = StringIO.new
    @server_thread = Thread.new do
      @server = WEBrick::HTTPServer.new({
        :BindAddress => '127.0.0.1',
        :Logger      => WEBrick::Log.new(@access_log),
        :AccessLog   => [[@access_log, WEBrick::AccessLog::COMBINED_LOG_FORMAT]],
        :Port => 11111,
      })
      @server.mount_proc '/' do |req, res|
        res.body = <<-HTML
<html>
<head>
</head>
<body>
  content
</body>
</html>
        HTML
      end
      @server.start
    end
  end

  after :all do
    @server.shutdown
    @server_thread.exit
    @server_thread.join
  end

  before :each do
    WatirProxy::Server.start_service
  end

  after :each do
    begin
      @browser.close
    rescue LoadError, NameError, ArgumentError => e
      #
    end
    WatirProxy::Server.stop_service
  end

  browsers = [:firefox, :chrome, :ie]
  #browsers << :opera
  #browsers << :safari

  browsers.each do |type|
    describe type do
      it "create" do
        begin
          @browser = WatirProxy::Server.browser(:type => type)
        rescue LoadError, NameError, ArgumentError => e
          #
        else
          @browser.should be_instance_of WatirProxy::Browser
        end
      end

      it "goto" do
        begin
          @browser = WatirProxy::Server.browser(:type => type)
          @browser.goto 'http://localhost:11111'
        rescue LoadError, NameError, ArgumentError => e
          #
        else
          @browser.html.should match /content/
        end
      end
    end
  end

end
