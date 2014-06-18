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
          :products => {
            :select => 'div.item, span.second', 
            :attrs => {
              :name =>  { :select => 'span:first'},
              :price =>  { :select => 'span.price'},
              :image => { :select => 'img', :prop => 'src'}
            }
          }
        }
      }

      Raspar.clear_parser_list
      @dynmaic_parser = Raspar.add(@site, selector_map)
    end

    describe '#onload' do

      it "should register DynamicParser to Raspar parser list" do
        expect(Raspar.parsers[@domain].class).to eq(Raspar::DynamicParser)

        expect(@dynmaic_parser.domain).to eq(@domain)
      end

    end

    describe '#parse' do

      it "should parse html and create object" do
        parsed_objs = Raspar.parse(@site, FAKE_PAGE)
        parsed_objs[:products] == 4

        count = 1
        parsed_objs[:products].each do |o|
          expect(o.class).to eq(Raspar::Result)

          expect(o[:name]).to eq("Test#{count}")
          expect(o[:image]).to eq(count.to_s)

          #Price should eval using proc given in option which convert string value
          #to integer
          expect(o[:price]).to eq((count * 10).to_s)

          #External Field check
          expect(o[:desc]).to eq("Description")
          count = count + 1
        end

      end

      it 'should return absoulte url' do
        expect(@dynmaic_parser.absolute_url('/test')).to eq(@site + '/test')
      end

    end

  end
end
