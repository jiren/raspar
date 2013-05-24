class RealParser
  include Raspar::Parser

  domain 'http://www.leguide.com'
  parent '.offers_list li'

  field :image,         :select => 'img', :value => 'src'
  field :price,         :select => '.euro.gopt', :eval => Proc.new{|i| i.gsub(/[ ,]/, ' ' => '', ',' => '.')}
  field :desc,          :select => '.gopt.description'
  field :vendor,        :select => '.name'
  field :delivery,      :select => '.delivery.gopt'
  field :delivery_time, :select => '.dispo'

end

