require 'rubygems'
require 'bundler/setup'
require 'open-uri'
require 'raspar'
require 'pp'

FAKE_PAGE = %q{
  <!DOCTYPE html>
  <html>
  <body>

  <span class="desc">Description</span>
  <ul class="specs">
    <li>Spec 1</li>
    <li>Spec 2</li>
    <li>Spec 3</li>
  </ul>

  <div>
    <img src="1">
    <span>Test1</span>
    <span class="price">10</span>
  </div>

  <div>
    <img src="2">
    <span>Test2</span>
    <span class="price">20</span>
  </div>

  <span class="second">
    <img src="3">
    <span>Test3</span>
    <span class="price">30</span>
  </span>

  <div class="offer">
    <span class="name">First Offer</span>
    <span class="percentage">10% off</span>
  </div>

  </body>
  </html>
}

class SampleParser
  include Raspar

  domain 'http://sample.com'

  attr :desc, '.desc', :eval => :full_desc
  attr :specs, '.specs li', :as => :array, :eval => :format_specs

  collection :product, 'div,span.second' do
    attr :image, 'img', :attr => 'src'
    attr :image_url, 'img', :attr => 'src', :eval => :make_image_url
    attr :name,  'span:first, .name', :eval => :full_name
    attr :price, '.price', :eval => Proc.new{|i| i.to_i}
    attr :all_text 
    attr :price_map do |text, ele|
      val = ele.search('span').collect{|s| s.content.strip}
      {val[0] => val[1].to_f}
    end
  end

  collection :offer, '.offer' do
    attr :name, '.name'
    attr :percentage, '.percentage'
  end

  def full_name(val, ele)
    "Full Name: #{val}"
  end

  def name_price(val, ele)
    val = ele.search('span').collect{|s| s.content.strip}
    {val[0] => val[1].to_f}
  end

  def make_image_url(path, ele)
    self.class.absolute_url(path)
  end

  def full_desc(text, ele)
    "#{text} full desc"
  end

  def format_specs(text, ele)
    text.downcase
  end

end

##pp SampleParser.attrs
pp Raspar.parse('http://sample.com', FAKE_PAGE)


selector_map = {
  :common_attrs => {
    :desc => {:select => '.desc'}
  },
  :collections =>{
    :product => {
      :select => 'div, span.second', 
      :attrs => {
        :name =>  { :select => 'span:first'},
        :price =>  { :select => 'span.price'},
        :image => { :select => 'img', :attr => 'src'}
      }
    }
  }
}

@site = 'http://dynmaicparser.com'
@dynmaic_parser = Raspar.add(@site, selector_map)
pp @dynmaic_parser.attrs
pp Raspar.parse(@site, FAKE_PAGE)
