$:.unshift(File.dirname(__FILE__))
require 'spec_helper'
require 'sample_parser'

module Raspar

  describe DynamicParser do

    before do
      @site = 'http://dynmaicparser.com'
      @domain = URI(@site).host

      selector_map = {
        :parent => 'div,span.second',
        :fields => {
          :desc  => { :select => '.desc', :common => true},
          :name =>  { :select => 'span:first'},
          :price =>  { :select => 'span.price'},
          :image => { :select => 'img', :attr => 'src'}
        }
      }

      @parent_selector = selector_map[:parent]
      @dynmaic_parser = Raspar.add_parsing_map(@site, selector_map)
    end

    describe 'onload' do

      it "should register DynamicParser to Raspar parser list" do
        Raspar.parser_list[@domain].class.should == Raspar::DynamicParser

        @dynmaic_parser.domain.should == @domain
      end

      it "should set domain_url" do
        @dynmaic_parser.domain_url.should == @site
      end

      it 'should return absoulte url' do
        @dynmaic_parser.absolute_url('/test').should == @site + '/test'
      end

    end

    describe 'parse' do

      it "should parse html and create object" do
        parsed_objs = Raspar.parse(@site, FAKE_PAGE)
        parsed_objs.length.should == 4

        count = 1
        parsed_objs.each do |o|
          o.class.should == Raspar::Result
          o.domain.should == @domain

          o[:name].should == "Test#{count}"
          o[:image].should == count.to_s

          #Price should eval using proc given in option which convert string value
          #to integer
          o[:price].should == (count * 10).to_s

          #External Field check
          o[:desc].should == "Description"
          count = count + 1
        end

      end

    end

  end
end
