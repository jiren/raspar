$:.unshift(File.dirname(__FILE__))
require 'spec_helper'
  
describe Raspar do

  before(:each) do
    @site = 'http://test.com'
    @host = URI(@site).host
  end

  it "should add domain to register parser list" do
    expect(Raspar.register(@site, TestParser)).to eq(@host)
    expect(Raspar.parsers).to include({@host => TestParser})
    expect(Raspar.parsers.size).to be > 0
  end

  it "should clear registered domains" do
    Raspar.register(@site, TestParser)
    Raspar.clear_parser_list

    expect(Raspar.parsers.size).to eq(0)
  end

  it "should able to remove parser from the registered list" do
    Raspar.clear_parser_list
    Raspar.register(@site, TestParser)

    Raspar.remove(@site)

    expect(Raspar.parsers).not_to include(@host) 
  end
end

