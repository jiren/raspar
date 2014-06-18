$:.unshift(File.dirname(__FILE__))
require 'spec_helper'
require 'sample_parser'

describe 'Add Parser' do

  def add_parser
    Raspar.add(@site) do
      attr :desc, '.desc', :common => true

      collection :products, '.item,span.second' do
        attr :name,  'span:first, .name', :eval => :full_name
        attr :price, '.price', :eval => Proc.new{|i| i.to_i}
      end

      def full_name(val, ele)
        "Full Name: #{val}"
      end

    end
  end

  before(:all) do
    @site = 'http://addparser.com'
    @domain = URI(@site).host
    @parser_class = add_parser
  end

  it 'should register parser and parse data' do
    Raspar.parsers.should include({@domain => @parser_class})
  end

  it "should have info" do
    @parser_class.info.should == {
      :domain => @domain, 
      :collections => [:products], 
      :common_attrs => [:desc] 
    }
  end

  it "should parse html and create object" do
    parsed_objs = Raspar.parse(@site, FAKE_PAGE)

    parsed_objs[:products].length.should == 4
    count = 1
    parsed_objs[:products].each do |o|
      o[:name].should == "Full Name: Test#{count}"
      o[:price].should == (count * 10)
      o[:desc].should == "Description"

      count = count + 1
    end
  end

end
