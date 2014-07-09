# A Parser class illustrates a LinkedIn public Profile page parsing  
# Example ULR: http://in.linkedin.com/pub/pramod-shinde/80/102/b29
class LinkedinParser
  include Raspar
  # Reason for defining a domain as a constant is Linkedin host is not a common, its changes based on User locations which
  # prepends country codes like http://us.linkedin.com, http://in.linkedin.com
  DOMAIN_URL = 'http://linkedin.com'
  domain DOMAIN_URL
  
  # Parsing basic fields like name, headline, location which areenclosed in div with class .vcard and .contact, 
  # Its always a best practice to mention more than one class for a collection 

  # Here collection of basic fields named as basic_info and has 
  # Atrributes defined with selector as 
  # Example: 
  # attr :name(attribute name), ".full-name"(selector class)
  # 
  # Additionaly you can define a html property parameter to capture as a attribute value
  # Example:
  # attr :image_url, "img", prop: 'src'(html property mentioned as 'src')
  collection :basic_info, '.vcard.contact' do 
    attr :name, ".full-name" 
    attr :headline, ".headline-title.title"
    attr :location, ".locality"
    attr :industry, ".industry"
    attr :image_url, "img", prop: 'src'
  end
  
  # Parsing Education
  # A collection enclosed in div with .position.education.vcard which are a repeating div's on the page
  # Here eval option is intresting to note 
  # Example 
  # attr :start_date,  ".dtstart" , prop: "title", eval: :format_date 
  # Some times the property title has a value with only year like 2007, to normalize date format you can use the 
  # eval option with method or Proc, Which will return a formated date like 2007-01-01
  collection :education, ".position.education.vcard" do
    attr :school, ".summary.org"
    attr :degree, ".degree"
    attr :major, ".major"
    attr :start_date,  ".dtstart" , prop: "title", eval: :format_date 
    attr :end_date,  ".dtend", prop: "title", eval: :format_date 
  end
  
  # Parsing Skills, as a Array 
  # If you see the skills div this in the orderd html li elements inclosed in ol element with class skills 
  # If you provide a option like, as: :array, collection will be collected as Array
  collection :skills, "ol.skills" do
    attr :skills, "li", as: :array 
  end
  
  
  # Parsing Positions, with a is_current flag
  # ALL positions(cuurent/past) enclosed in div with classes .vcard.summary-current, .vcard.summary-past, 
  # which are repeated on page
  # Here intresting part is you can have flag for a position as is_current, 
  # Example:
  # Args : 
  # text => A parsed text for a current collection element 
  # ele => A current collection element which is being parsed 
  #
  #  attr :is_current do |text, ele|
  #    ele.attr('class').to_s.include?('summary-current') # returns true if ele has class 'summay-current'
  #  end
  # 
  collection :positions, '.vcard.summary-current, .vcard.summary-past' do
    attr :company, ".org.summary"
    attr :company_linkedin_url, ".company-profile-public", prop: "href", eval: :form_url
    attr :title, '.postitle .title'
    attr :company_info, ".organization-details", eval: :parse_company_info
    attr :start_date, ".dtstart", prop: "title", eval: :format_date 
    attr :end_date, ".dtend, .dtstamp", prop: "title", eval: :format_date 
    attr :duration, ".duration", eval: Proc.new{|duration, ele| duration.gsub(/[()]/,"")} 
    attr :is_current do |text, ele|
      ele.attr('class').to_s.include?('summary-current') 
    end
  end
  
  # Other collections like, summary, languages, connections, group  
  collection :summary, ".description.summary" do
    attr :summary
  end

  collection :languages, "ul.languages" do
    attr :languages, "li", as: :array
  end

  collection :connections, ".overview-connections" do
    attr :connections
  end
  
  collection :groups, ".group-data" do
    attr :name, ".fn.org"
    attr :group_link, "a", prop: "href", eval: :form_url
  end

  def form_url(text, ele)
   (text.include? "linkedin.com" ) ? text : ("www.linkedin.com" + text.to_s.split("?").first)
  end

  def format_date(text, ele)
    text.include?('-') ? text : text + "-01-01"
  end

  def parse_company_info(text, ele) 
    data = text.split(";").collect(&:strip)
    if data.size == 4
      {type: data[0], employees: data[1], ticker: data[2], industry: data[3]} 
    elsif data.size == 3
      {type: data[0], employees: data[1], industry: data[2]} 
    end
  end

  def self.fetch_and_parse(url)
    html = RestClient.get(url)
    Raspar.parse(DOMAIN_URL, html).as_json
  end
end

# Overriding as_json method to returns collection attributes only
class Raspar::Result
  def as_json(*args)
    attrs
  end
end

# Fetching and Parsing 
LinkedinParser.fetch_and_parse("http://in.linkedin.com/pub/pramod-shinde/80/102/b29")

# Sample Output
=begin
"basic_info": [
  {
    "name": "Pramod Shinde",
    "headline": "Rails Developer at Josh Software Private Limited",
    "location": "Pune Area, India",
    "industry": "Information Technology and Services",
    "image_url": "http://m.c.lnkd.licdn.com/mpr/pub/image-Wzra0c-E6CJ0tt9GCwKgySG51BXynTmsdFxmH9Dv1OtKUPRwWzrmKKuE1uPVUbS_ZPhL/pramod-shinde.jpg"
  }
],
"education": [
  {
    "school": "Fergusson College, Pune",
    "degree": "Master's degree",
    "major": "Mathematics and Computer Science",
    "start_date": "2007-01-01",
    "end_date": "2013-12-31"
  }
],
"skills": [
  [
    "Ruby on Rails",
    "Web Development",
    "MongoDB",
    "SQL",
    "Ruby",
    "Git",
    "PostgreSQL"
  ]
],
"connections": [
  "94 connections"
],
"groups": [
  {
    "name": "RoR (Ruby on Rails) Open Source Network",
    "group_link": "www.linkedin.com/groups"
  },
  {
    "name": "Ruby on Rails (ROR)",
    "group_link": "www.linkedin.com/groups"
  }
],
"positions": [
  {
    "company": "Josh Software Private Limited",
    "company_linkedin_url": "www.linkedin.com/company/josh-software-private-limited",
    "title": "Rails Developer",
    "company_info": {
      "type": "Privately Held",
      "employees": "11-50 employees",
      "industry": "Information Technology and Services industry"
    },
    "start_date": "2013-01-01",
    "end_date": "2014-07-09",
    "duration": "1 year 7 months",
    "is_current": true
  }
]
=end                                                                          }i
