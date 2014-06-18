$:.unshift(File.dirname(__FILE__))
require 'spec_helper'
require 'sample_parser'

module Raspar

  describe Parser do

    before do
      @site = 'http://sample.com'
      @domain = URI(@site).host

      Raspar.register(@site, SampleParser) unless Raspar.parsers[@domain]
    end

    #On load SampleParser class
    describe 'onload' do

      it "should register SampleParser to Raspar parser list" do
        Raspar.parsers.should include({@domain => SampleParser})

        SampleParser.domain.should == @domain
      end

      it 'should return absoulte url' do
        SampleParser.absolute_url('/test').should == @site + '/test'
      end

      it "should have info" do
        SampleParser.info.should == {
                        :domain => @domain, 
                        :collections => [:products, :offers, :related_products], 
                        :common_attrs => [:desc, :specs] 
                      }
      end

      it "should not define accessor if options not contail :selector" do
        SampleParser.instance_methods.include?(:extra) == false
      end

    end

    describe 'parse' do

      it "should parse html and create object" do
        parsed_objs = Raspar.parse(@site, FAKE_PAGE)

        #Total parse objects
        parsed_objs.keys.length.should == 3

        parsed_objs[:products].length.should == 4
        parsed_objs[:offers].length.should == 1
        parsed_objs[:related_products].length.should == 1

        count = 1
        parsed_objs[:products].each do |o|
          o[:name].should == "Full Name: Test#{count}"
          o[:image].should == count.to_s

          #Price should eval using proc given in option which convert string value
          #to integer
          o[:price].should == (count * 10)

          #External Field check
          o[:desc].should == "Description is full desc"

          #self selector 
          o[:all_text].should == "Test#{count}\n    #{count*10}"

          o[:price_map].should == {"Test#{count}" => (count*10).to_f}

          o[:specs].should == ['spec 1', 'spec 2', 'spec 3']

          count = count + 1
        end

        parsed_objs[:offers].each do |o|
          o[:name].should == 'First Offer'
          o[:percentage].should == '10% off'
        end

      end

    end

  end
end
