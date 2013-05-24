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

  #For normal field use instance method 
  def parse_price(val, ele)
    val.gsub(/[ ,]/, ' ' => '', ',' => '.')
  end

  def parse_shipping_price(text, ele)
    text.split(':').last.strip
  end

  def data_field_parse(text, ele)
    Nokogiri::HTML.parse(text).text.split(':').last.strip
  end
end

domain  = 'http://www.leguide.com'
selector_map = {
  :parent => '.offers_list li',
  :fields => {
    :name           => { :select => '.block_bpu_feature .p b', :common => true},
    :specifications => { :select => '#page2', :common => true, :eval => :build_specification },
    :image          => { :select => 'img', :attr => 'src'},
    :price          => { :select => '.price .euro.gopt', :eval => :parse_price},
    :orignal_price  => { :select => '.price .barre', :eval => :parse_price},
    :desc           => { :select => '.gopt.description,.info .description'},
    :vendor         => { :select => '.name a' },
    :availability   => { :select => '.av', :attr => 'data-value', :eval => :data_field_parse},
    :delivery_time  => { :select => '.dv', :attr => 'data-value', :eval => :data_field_parse},
    :shipping_price => { :select => '.delivery.gopt'}
  }
}

Raspar.add_parseing_map(domain, selector_map, ParserHelper)

url = 'http://www.leguide.com/sb/bp/5010500/hotpoint_ariston/ECO9F_149_FRS/55743410.htm'
page = open(url).read()

Raspar.parse(url, page).each do |i|
  i.attributes.each do |field, value|
    p "%-20s: %s" % [field, value ]
  end
  p "*"*40  
end


