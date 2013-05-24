class SampleParser
  include Raspar

  domain 'http://sample.com'

  field :desc, '.desc', :common => true, :eval => :full_desc
  field :specs, '.specs li', :common => true, :as => :array, :eval => :format_specs

  parent 'div,span.second'

  field :image, 'img', :attr => 'src'
  field :image_url, 'img', :attr => 'src', :eval => :make_image_url
  field :name,  'span:first, .name', :eval => :full_name
  field :price, '.price', :eval => Proc.new{|i| i.to_i}
  field :all_text 
  field :price_map do |text, ele|
    val = ele.search('span').collect{|s| s.content.strip}
    {val[0] => val[1].to_f}
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
    "#{text} for #{self[:name]}"
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

  <div>
    <img src="3">
    <span>Test3</span>
    <span class="price">30</span>
  </div>

  <span class="second">
    <img src="4">
    <span>Test4</span>
    <span class="price">40</span>
  </span>

  </body>
  </html>
}


