## Raspar - scraping library

Raspar is a html scraping library which help to map html elements to ruby object using 'css' or 'xpath' selector.Using this library user can define multiple parser for different websites and it select parser according to input html page url.


## Installation

Add this line to your application's Gemfile:

    gem 'raspar', :git => 'git://github.com:jiren/raspar.git'

And then execute:

    $ bundle

## Usage

```ruby
  
  result = Rapsar.parse(url, html) #This will return parsed result object array.

  #Result
  [
    #<Raspar::Result:0x007ffc91e4d640
      @attrs={:name=>"Test1", :price=>"10", :image=>"1", :desc=>"Description"},
      @domain="example.com",
      @name=:product>,
    #<Raspar::Result:0x007ffc91e57be0
      @attrs={:name=>"Test2", :price=>"20", :image=>"2", :desc=>"Description"},
      @domain="example.com",
      @name=:product>
   ]

```

## Example

### Sample HTML

```html
<!DOCTYPE html>
<html>
    <body>
    <span class="desc">Description</span>
    <divi class="item">
      <img src="1">
      <span>Test1</span>
      <span class="price">10</span>
    </div>

    <div class="item">
      <img src="2">
      <span>Test2</span>
      <span class="price">20</span>
    </div>

    <span class="second">
      <img src="2">
      <span>Test2</span>
      <span class="price">20</span>
    </span>

    <div class="offer">
      <span class="name">First Offer</span>
      <span class="percentage">10% off</span>
    </div>

  </body>
</html>
```


#### Parser for above HTML 

```ruby
class SampleParser
  include Raspar

  domain 'http://sample.com'

  attr :desc, '.desc', :eval => :format_desc

  collection :product, '.item,span.second' do
    attr :image_url, 'img', :prop => 'src', :eval => :make_image_url
    attr :name,  'span:first'
    attr :price, 'span.price', :eval => Proc.new{|price, ele| price.to_i} 
    attr :price_map do |text, ele|
      val = ele.search('span').collect{|s| s.content.strip}
      {val[0] => val[1].to_f}
    end
  end

  collection :offer, '.offer' do
    attr :name, '.name'
    attr :discount, '.discount' do |text, ele|
      test.split('%').first.to_f
    end
  end

  def name_price(val, ele)
    val = ele.search('span').collect{|s| s.content.strip}
    {val[0] => val[1].to_f}
  end

  def make_image_url(path, ele)
    URI(@domain_url).merge(path).to_s
  end

  def format_desc(text, ele)
    "Description: #{text}"
  end

end
```

- 'domain' method register parser for given domain value so raspar can differentiate parser at runtime.
- Define 'attr' which is going to parse. First argument is 'css' or 'xpath' selector. Second argument contain options.
  - Valid options are :field, :eval.
  - :porp is selecting particular property/attribute for html element. In example for image, select image url using :prop => 'src'
  - :eval is use to post process attr value. It can be proc, method or block. Each method, proc or block use for eval has two argument, first is html element text and second is html element as a Nokogiri doc.  
  - if :eval is not define then parser will return text of selected html element.
- If your page has multiple type of objects or collections then define using 'collection' block. In above example '.item' and 'span.second' are product while '.offer' element contain offer detail.
- In html page some of attributes are common which is not reside under particular collection and this attributes values are going to add for each parse object.

### Add Parser in different way

It takes only one argument domain url and block.

```ruby

Raspar.add('http://example.com') do
  attr :desc, '.desc', :eval => :format_desc

  collection :product, '.item,span.second' do
    attr :image_url, 'img', :prop => 'src', :eval => :make_image_url
    attr :name,  'span:first'
    attr :price, 'span.price', :eval => Proc.new{|price, ele| price.to_i} 
    attr :price_map do |text, ele|
      val = ele.search('span').collect{|s| s.content.strip}
      {val[0] => val[1].to_f}
    end
  end
end


```


### Dynamically add Parser

```ruby
  
domain  = 'http://www.sample.com'
selector_map = {
  :common_attrs => {
    :desc => {:select => '.desc'}
  },
  :collections =>{
    :item => {
      :select => 'div, span.second', 
      :attrs => {
        :name =>  { :select => 'span:first'},
        :price =>  { :select => 'span.price', :eval => :parse_price},
        :image => { :select => 'img', :prop => 'src'}
      }
    }
  }
}

module ParserHelper
  def parse_price(val, ele)
    val.gsub(/[ ,]/, ' ' => '', ',' => '.').to_f
  end
end

Raspar.add(domain, selector_map, ParserHelper) //Add parser

```

For post processing user can add parser helper, but it is not mandatory.


## Contributing

Please send me a pull request so that this can be improved.

## License

This is released under the MIT license.
