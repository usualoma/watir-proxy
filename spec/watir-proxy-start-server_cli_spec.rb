require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'watir-proxy-start-server/cli'

describe WatirProxyStartServer::CLI, "execute" do
  before(:each) do
    @stdout_io = StringIO.new
    WatirProxyStartServer::CLI.execute(@stdout_io, []) do |stdout|
      stdout.puts 'successfully executed'
      WatirProxy::Server.stop_service
    end
    @stdout_io.rewind
    @stdout = @stdout_io.read
  end
  
  it "should print default output" do
    @stdout.should match "successfully executed\n"
  end
end
