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
        expect(Raspar.parsers).to include({@domain => SampleParser})

        expect(SampleParser.domain).to eq(@domain)
      end

      it 'should return absoulte url' do
        expect(SampleParser.absolute_url('/test')).to eq(@site + '/test')
      end

      it "should have info" do
        expect(SampleParser.info).to eq({
                        :domain => @domain, 
                        :collections => [:products, :offers, :related_products], 
                        :common_attrs => [:desc, :specs] 
                      })
      end

      it "should not define accessor if options not contail :selector" do
        SampleParser.instance_methods.include?(:extra) == false
      end

    end

    describe 'parse' do

      it "should parse html and create object" do
        parsed_objs = Raspar.parse(@site, FAKE_PAGE)

        #Total parse objects
        expect(parsed_objs.keys.length).to eq(3)

        expect(parsed_objs[:products].length).to eq(4)
        expect(parsed_objs[:offers].length).to eq(1)
        expect(parsed_objs[:related_products].length).to eq(1)

        count = 1
        parsed_objs[:products].each do |o|
          expect(o[:name]).to eq("Full Name: Test#{count}")
          expect(o[:image]).to eq(count.to_s)

          #Price should eval using proc given in option which convert string value
          #to integer
          expect(o[:price]).to eq(count * 10)

          #External Field check
          expect(o[:desc]).to eq("Description is full desc")

          #self selector 
          expect(o[:all_text]).to eq("Test#{count}\n    #{count*10}")

          expect(o[:price_map]).to eq({"Test#{count}" => (count*10).to_f})

          expect(o[:specs]).to eq(['spec 1', 'spec 2', 'spec 3'])

          count = count + 1
        end

        parsed_objs[:offers].each do |o|
          expect(o[:name]).to eq('First Offer')
          expect(o[:percentage]).to eq('10% off')
        end

      end

    end

  end
end
