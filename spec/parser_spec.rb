$:.unshift(File.dirname(__FILE__))
require 'spec_helper'
require 'sample_parser'

module Raspar

  describe Parser do

    before do
      @site = 'http://sample.com'
      @domain = URI(@site).host
      @parent_selector = 'div,span.second'

      Raspar.register(@site, SampleParser) unless Raspar.parser_list[@domain]
    end

    #On load SampleParser class
    describe 'onload' do

      it "should register SampleParser to Raspar parser list" do
        Raspar.parser_list.should include({@domain => SampleParser})

        SampleParser.domain.should == @domain
      end

      it "should set domain_url" do
        SampleParser.domain_url.should == @site
      end

      it 'should return absoulte url' do
        SampleParser.absolute_url('/test').should == @site + '/test'
      end

      it "should have info" do
        SampleParser.info.should == {:domain => @domain, :parent => @parent_selector }
      end

      it "should not define accessor if options not contail :selector" do
        SampleParser.instance_methods.include?(:extra) == false
      end

      it "should have parent assignment only once" do
        parent = SampleParser.info[:parent]
        SampleParser.parent 'change'

        SampleParser.info[:parent].should == parent
      end

    end

    describe 'parse' do

      it "should parse html and create object" do
        parsed_objs = Raspar.parse(@site, FAKE_PAGE)
        parsed_objs.length.should == 4

        count = 1
        parsed_objs.each do |o|
          o[:name].should == "Full Name: Test#{count}"
          o[:image].should == count.to_s

          #Price should eval using proc given in option which convert string value
          #to integer
          o[:price].should == (count * 10)

          #External Field check
          o[:desc].should == "Description for Full Name: Test#{count}"

          #self selector 
          o[:all_text].should == "Test#{count}\n    #{count*10}"

          o[:price_map].should == {"Test#{count}" => (count*10).to_f}

          o[:specs].should == ['spec 1', 'spec 2', 'spec 3']

          count = count + 1
        end

      end

    end

  end
end
