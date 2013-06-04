require 'rubygems'
require 'bundler/setup'
require 'open-uri'
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
        :image          => { :select => 'img', :attr => 'src'},
        :price          => { :select => '.price .euro.gopt', :eval => :parse_price},
        :orignal_price  => { :select => '.price .barre', :eval => :parse_price},
        :desc           => { :select => '.gopt.description,.info .description'},
        :vendor         => { :select => '.name a' },
        :availability   => { :select => '.av', :attr => 'data-value', :eval => :data_attr_parse},
        :delivery_time  => { :select => '.dv', :attr => 'data-value', :eval => :data_attr_parse},
        :shipping_price => { :select => '.delivery.gopt'}
      }
    }
  }
}

Raspar.add_parsing_map(domain, selector_map, ParserHelper)

url = 'http://www.leguide.com/sb/bp/5010500/hotpoint_ariston/ECO9F_149_FRS/55743410.htm'
page = open(url).read()

Raspar.parse(url, page).each do |i|
  pp i
  p "*"*40  
end


