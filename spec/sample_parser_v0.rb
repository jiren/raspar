class SampleParser
  include Raspar::Parser

  domain 'http://sample.com'

  field :desc, :external => true, :select => '.desc'

  parent 'div,span.second'

  field :image, :select => 'img', :value => 'src'
  field :name,  :select => 'span:first', :eval => :full_name
  field :price, :select => 'span.price', :eval => Proc.new{|i| i.to_i}
  field :all_text, :select => :self
  field :extra

  def full_name(val)
    val = "Full Name: #{val}"
  end

end

FAKE_PAGE = %q{
  <!DOCTYPE html>
  <html>
  <body>

  <span class="desc">Desc</span>

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


