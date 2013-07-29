$:.unshift(File.dirname(__FILE__))
require 'spec_helper'
require 'sample_parser'

module Raspar

  describe DynamicParser do

    before do
      @site = 'http://dynmaicparser.com'
      @domain = URI(@site).host

      selector_map = {
        :common_attrs => {
          :desc => {:select => '.desc'}
        },
        :collections =>{
          :product => {
            :select => 'div.item, span.second', 
            :attrs => {
              :name =>  { :select => 'span:first'},
              :price =>  { :select => 'span.price'},
              :image => { :select => 'img', :prop => 'src'}
            }
          }
        }
      }

      @dynmaic_parser = Raspar.add(@site, selector_map)
    end

    describe '#onload' do

      it "should register DynamicParser to Raspar parser list" do
        Raspar.parsers[@domain].class.should == Raspar::DynamicParser

        @dynmaic_parser.domain.should == @domain
      end

    end

    describe '#parse' do

      it "should parse html and create object" do
        parsed_objs = Raspar.parse(@site, FAKE_PAGE)
        parsed_objs.length.should == 4

        count = 1
        parsed_objs.each do |o|
          o.class.should == Raspar::Result

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

      it 'should return absoulte url' do
        @dynmaic_parser.absolute_url('/test').should == @site + '/test'
      end

    end

  end
end
