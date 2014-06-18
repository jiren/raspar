require 'rubygems'
require 'rest_client'
require 'bundler/setup'
require 'raspar'
require 'pp'

module ParserHelper
  def build_specification(val, ele)
    attrs = {}
    ele.search('li').each do |li|
      attrs[li.search('.title').first.content] =  li.search('.value').first.content
    end
    attrs
  end

  #For normal attr use instance method 
  def parse_price(val, ele)
    val.gsub(/[ ,]/, ' ' => '', ',' => '.')
  end

  def parse_shipping_price(text, ele)
    text.split(':').last.strip
  end

  def data_attr_parse(text, ele)
    Nokogiri::HTML.parse(text).text.split(':').last.strip
  end
end

domain  = 'http://www.leguide.com'
selector_map = {
  :common_attrs => {
    :name => {:select => '.block_bpu_feature .p b'},
    :specifications => {:select => '#page2', :eval => :build_specification}
  },
  :collections => {
    :product =>{
      :select => '.offers_list li',
      :attrs => {
        :image          => { :select => 'img', :prop => 'src'},
        :price          => { :select => '.gopt .prices', :eval => :parse_price},
        :desc           => { :select => '.gopt.description,.info .description'},
        :vendor         => { :select => '.name a' },
      }
    }
  }
}

Raspar.add(domain, selector_map, ParserHelper)

url = 'http://www.leguide.com/electromenager.htm'
p url
page = RestClient.get(url).to_str

Raspar.parse(url, page).each do |i|
  pp i
  p "*"*40  
end


