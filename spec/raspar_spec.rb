$:.unshift(File.dirname(__FILE__))
require 'spec_helper'
  
describe Raspar do

  before(:each) do
    @site = 'http://test.com'
    @host = URI(@site).host
  end

  it "should add domain to register parser list" do
    Raspar.register(@site, TestParser).should == @host
    Raspar.parsers.should include({@host => TestParser})
    Raspar.parsers.size.should > 0
  end

  it "should clear registered domains" do
    Raspar.register(@site, TestParser)
    Raspar.clear_parser_list

    Raspar.parsers.size.should == 0
  end

  it "should able to remove parser from the registered list" do
    Raspar.clear_parser_list
    Raspar.register(@site, TestParser)

    Raspar.remove(@site)

    Raspar.parsers.should_not include(@host) 
  end
end

