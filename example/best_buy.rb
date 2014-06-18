require 'rubygems'
require 'rest_client'
require 'bundler/setup'
require 'raspar'
require 'pp'

class BestBuy
  include Raspar

  domain 'www.bestbuy.com'

  collection :products, '.hproduct' do
    attr :image, '.image-col img', prop: 'src'
    attr :name, '.info-main .name'
    attr :price, 'span[itemprop="price"]'
    attr :sku,  '.sku'
    attr :description, '.product-short-description li', as: :array
    attr :rating, 'span[itemprop="ratingValue"]', eval: ->(text, ele){ text.to_f }
  end

end

url = ARGV[0] || "http://www.bestbuy.com/site/promo/htc-one-offer-118429"
p url
page = RestClient.get(url).to_str

Raspar.parse(url, page).each do |product|
  pp product
  p "*"*40  
end
