$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'watir-webdriver'
require 'drb/drb'

module WatirProxy
  VERSION = '0.0.1'

  class Browser
    def initialize(opts = {})
      @drb     = opts[:drb]
      @browser = opts[:browser]
      @options = opts[:options]
    end

    def method_missing(name, *args)
      if @browser
        @browser.send name, *args
      else
        @drb.browser_call @options, name, *args
      end
    end
  end

  class Server
    attr_accessor :stream, :current_browser

    @@default_browser = :firefox
    @@default_drb_uri = 'druby://localhost:12444'

    def self.browser(opts = {})
      drb, browser = nil, nil
      begin
        drb = DRbObject.new_with_uri(self.drb_uri(opts))
        drb.alive? if drb.respond_to?(:alive?);
      rescue DRb::DRbConnError => e
        browser = self.new(StringIO.new).browser(opts)
      end

      Browser.new({
        :drb     => drb,
        :browser => browser,
        :options => opts,
      })
    end

    def self.default_drb_uri
      @@default_drb_uri
    end

    def self.drb_uri(opts = {})
      opts[:drb_uri] || ENV['WATIR_PROXY_DRB_URI'] || self.default_drb_uri
    end

    def self.start_service(opts = {}, &block)
      DRb.start_service(self.drb_uri(opts), self.new)
      yield if block
    end

    def self.stop_service(&block)
      DRb.stop_service
    end

    def self.thread
      DRb.thread
    end

    def initialize(stream = $stdout)
      @stream  = stream
      @current_browser = @@default_browser
      @browsers = {}
    end

    def browser_call(opts, name, *args)
      self.browser(opts).send name, *args
    end

    def browser(opts = {})
      @current_browser = opts[:type] || @current_browser
      @browsers[@current_browser] ||= new_browser(@current_browser, opts[:driver])
    end

    def new_browser(type, driver)
      driver = case driver
               when String
                 eval driver
               when nil
                 type
               else
                 driver
               end
      Watir::Browser.new(driver)
    end

  end
end
