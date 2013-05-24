require 'rubygems'
require 'bundler/setup'
require 'open-uri'
require 'raspar'

class Leguide
  include Raspar

  SHIPPING_PROC = Proc.new{|text, ele| text.split(':').last.strip}
  DATA_PROC = Proc.new{|text, ele| Nokogiri::HTML.parse(text).text.split(':').last.strip}

  domain 'http://www.leguide.com'
  parent '.offers_list li'

  #External fields
  field :name, '.block_bpu_feature .p b', :common => true
  field :specifications, '#page2', :common => true, :eval => :build_specification

  field :image,          '.lg_photo img', :attr => 'src'
  field :price,          '.price .euro.gopt'
  field :orignal_price,  '.price .barre'
  field :desc,           '.gopt.description,.info .description'
  field :vendor,         '.name a'
  field :availability,   '.av', :attr => 'data-value', :eval => DATA_PROC
  field :delivery_time,  '.dv', :attr => 'data-value', :eval => DATA_PROC
  field :shipping_price, '.delivery.gopt', :eval => SHIPPING_PROC

  #For External field define class method because it evalute only once for all object in sigle html doc.
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

end

url = 'http://www.leguide.com/sb/bp/5010500/hotpoint_ariston/ECO9F_149_FRS/55743410.htm'
p ARGV[0] || url
#page = open(ARGV[0] || url).read().gsub(/[[:cntrl:]@]/, '')
page = open(ARGV[0] || url).read()

Raspar.parse('http://www.leguide.com', page).collect do |i|
  i.class.field_names.each do |field|
    p "%-20s: %s" % [field, i[field] ]
  end
  p "*"*40  
end
