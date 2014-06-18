class SampleParser
  include Raspar

  domain 'http://sample.com'

  attr :desc, '.desc', :common => true, :eval => :full_desc
  attr :specs, '.specs li', :common => true, :as => :array, :eval => :format_specs

  collection :products, '.item,span.second' do
    attr :image, 'img', :prop => 'src'
    attr :image_url, 'img', :prop => 'src', :eval => :make_image_url
    attr :name,  'span:first, .name', :eval => :full_name
    attr :price, '.price', :eval => Proc.new{|i| i.to_i}
    attr :all_text 
    attr :price_map do |text, ele|
      val = ele.search('span').collect{|s| s.content.strip}
      {val[0] => val[1].to_f}
    end
  end

  collection :offers, '.offer' do
    attr :name, '.name'
    attr :percentage, '.percentage'
  end

  collection :related_products, 'ol.related_products' do
    attr :name, 'li', as: :array
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
    "#{text} is full desc"
  end

  def format_specs(text, ele)
    text.downcase
  end

end

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

  <div class="item">
    <img src="1">
    <span>Test1</span>
    <span class="price">10</span>
  </div>

  <div class="item">
    <img src="2">
    <span>Test2</span>
    <span class="price">20</span>
  </div>

  <div class="item">
    <img src="3">
    <span>Test3</span>
    <span class="price">30</span>
  </div>

  <span class="second">
    <img src="4">
    <span>Test4</span>
    <span class="price">40</span>
  </span>

  <div class="offer">
    <span class="name">First Offer</span>
    <span class="percentage">10% off</span>
  </div>

  <ol class="related_products">
    <li> Product 1 </li>
    <li> Product 2 </li>
    <li> Product 3 </li>
  </ol>

  </body>
  </html>
}


