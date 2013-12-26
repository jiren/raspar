require 'rubygems'
require 'bundler/setup'
require 'open-uri'
require 'raspar'
require 'pp'

class BestBuy
  include Raspar

  domain 'www.bestbuy.com'

  collection :products, '.hproduct' do
    attr :image, '.image-col img', prop: 'src'
    attr :name, '.info-main .name'
    attr :sku,  '.sku'
    attr :description, '.product-short-description li', as: :array
    attr :rating, 'span[itemprop="ratingValue"]', eval: ->(text, ele){ text.to_f }
  end

end

url = "http://www.bestbuy.com/site/promo/samsung-galaxy-s-4-and-note-3-115626"
p ARGV[0] || url
page = open(ARGV[0] || url).read()

Raspar.parse(url, page).each do |product|
  pp product
  p "*"*40  
end
