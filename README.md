Raspar - scraping library
=========================

Raspar is a scraping library which help to map html elements to ruby object using css or xpath selector.Using this library user can define multiple parser for different websites, also user can add parsers dynamically and it will apply perticular scraper accoriding to input html page url.

Usage
=====

```ruby
  
  Rapser.parse(url, html) // This will return parsed object array.

```

Example
=======

Sample HTML
-----------

```html
<!DOCTYPE html>
<html>
    <body>
    <span class="desc">Description</span>
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
      <img src="4">
      <span>Test4</span>
      <span class="price">40</span>
    </span>

  </body>
</html>
```


Parser for above HTML 
---------------------

```ruby
class SampleParser
  include Raspar

  domain 'http://sample.com'

  field :desc, '.desc', :common => true, :eval => :format_desc

  parent 'div,span.second'

  field :image_url, 'img', :attr => 'src', :eval => :make_image_url
  field :name,  'span:first'
  field :price, 'span.price', :eval => Proc.new{|price, ele| price.to_i}

  field :price_map do |text, ele|
    val = ele.search('span').collect{|s| s.content.strip}
    {val[0] => val[1].to_f}
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

- Add domain url using domain method. This will help selecting parser according to url.
- Define field which is going to parse. First argument is 'css' selector or 'xpath'. Second argument contain option.
  - Valid options are :attr, :eval.
  - :attr is selecting particular attribute for html element. In example for image, select image url using :attr => 'src'
  - :eval is use to post process field value. It can be proc, method or block. Each method, proc or block use for eval has two argument, first is html element text and second is html element as a Nokogiri doc.  
  - if :eval is not define then parser will return text selected html element.
- If your page has multiple item then define parent. In above example 'div' and 'span.second' are parent and it contains field which is going to parse.
- In html page some of attributes are common which is not reside under parent items. In example we want description should be added to all the parse item then add option :common => true

To Dyanamicaly add Parser
=========================

```ruby
  
domain  = 'http://www.sample.com'
selector_map = {
  :parent => '.product_list',
  :fields => {
    :name           => { :select => '.block_bpu_feature .p b', :common => true},
    :specifications => { :select => '#page2', :common => true, :eval => :build_specification },
    :image          => { :select => 'img', :attr => 'src'},
    :price          => { :select => '.price .euro.gopt', :eval => :parse_price},
    :orignal_price  => { :select => '.price .barre', :eval => :parse_price},
    :desc           => { :select => '.gopt.description,.info .description'},
    :vendor         => { :select => '.name a' }
  }
}

module ParserHelper
  def build_specification(val, ele)
    attrs = {}
    ele.search('li').each do |li|
      attrs[li.search('.title').first.content] =  li.search('.value').first.content
    end
    attrs
  end

  def parse_price(val, ele)
    val.gsub(/[ ,]/, ' ' => '', ',' => '.')
  end

end

Raspar.add_parsing_map(domain, selector_map, ParserHelper) //Add parser

```
For post processing user can add parser helper, but it is not mandatory.


Contributing
------------
Please send me a pull request so that this can be improved.

License
-------
This is released under the MIT license.
