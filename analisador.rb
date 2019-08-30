#encoding: utf-8
require 'json'

class Analisador
  attr_reader :result

  def initialize(result)
    @result = result
  end

  def to_hash
    @result_hash ||= JSON.parse(result)
  end

  def to_a
    @result_array ||= convert_hash_to_array
  end

  def convert_hash_to_array
    @result_array = []
    urls = to_hash["urls"].keys.to_a.join(",")
    applications = []
    unless error? then
      to_hash["applications"].each do |a|
        a["categories"].each do |c|
          c.values.each do |c_name|
            applications << [urls, a["name"], a["confidence"], c_name ]
          end
        end
      end
    else
      applications << [urls, "", "", to_hash["urls"].values.flatten.to_s]
    end
    applications
  end

  def error?
    to_hash["applications"].size <= 0
  end

  def success?
    to_hash["applications"].size > 0
  end
end
=begin
a = Analisador.new(
  "{\"urls\":{\"http://www.saraiva.com.br/\":{\"status\":200}},\"applications\":[{\"name\":\"DoubleClick for Publishers (DFP)\",\"confidence\":\"100\",\"version\":null,\"icon\":\"DoubleClick.svg\",\"website\":\"http://www.google.com/dfp\",\"categories\":[{\"36\":\"Advertising Networks\"}]},{\"name\":\"Facebook\",\"confidence\":\"100\",\"version\":null,\"icon\":\"Facebook.svg\",\"website\":\"http://facebook.com\",\"categories\":[{\"5\":\"Widgets\"}]},{\"name\":\"Google AdSense\",\"confidence\":\"100\",\"version\":null,\"icon\":\"Google AdSense.svg\",\"website\":\"https://www.google.fr/adsense/start/\",\"categories\":[{\"36\":\"Advertising Networks\"}]},{\"name\":\"Google Font API\",\"confidence\":\"100\",\"version\":null,\"icon\":\"Google Font API.png\",\"website\":\"http://google.com/fonts\",\"categories\":[{\"17\":\"Font Scripts\"}]},{\"name\":\"Lightbox\",\"confidence\":\"100\",\"version\":null,\"icon\":\"Lightbox.png\",\"website\":\"http://lokeshdhakar.com/projects/lightbox2/\",\"categories\":[{\"59\":\"JavaScript Libraries\"}]},{\"name\":\"Magento\",\"confidence\":\"100\",\"version\":null,\"icon\":\"Magento.png\",\"website\":\"https://magento.com\",\"categories\":[{\"6\":\"Ecommerce\"}]},{\"name\":\"New Relic\",\"confidence\":\"100\",\"version\":null,\"icon\":\"New Relic.png\",\"website\":\"https://newrelic.com\",\"categories\":[{\"10\":\"Analytics\"}]},{\"name\":\"Nginx\",\"confidence\":\"100\",\"version\":null,\"icon\":\"Nginx.svg\",\"website\":\"http://nginx.org/en\",\"categories\":[{\"22\":\"Web Servers\"},{\"64\":\"Reverse Proxy\"}]},{\"name\":\"Prototype\",\"confidence\":\"100\",\"version\":\"1.7\",\"icon\":\"Prototype.png\",\"website\":\"http://www.prototypejs.org\",\"categories\":[{\"12\":\"JavaScript Frameworks\"}]},{\"name\":\"Slick\",\"confidence\":\"100\",\"version\":null,\"icon\":\"default.svg\",\"website\":\"https://kenwheeler.github.io/slick\",\"categories\":[{\"59\":\"JavaScript Libraries\"}]},{\"name\":\"Varnish\",\"confidence\":\"100\",\"version\":null,\"icon\":\"Varnish.svg\",\"website\":\"http://www.varnish-cache.org\",\"categories\":[{\"23\":\"Cache Tools\"}]},{\"name\":\"jQuery\",\"confidence\":\"100\",\"version\":\"2.1.1\",\"icon\":\"jQuery.svg\",\"website\":\"https://jquery.com\",\"categories\":[{\"59\":\"JavaScript Libraries\"}]},{\"name\":\"script.aculo.us\",\"confidence\":\"100\",\"version\":null,\"icon\":\"script.aculo.us.png\",\"website\":\"https://script.aculo.us\",\"categories\":[{\"59\":\"JavaScript Libraries\"}]},{\"name\":\"PHP\",\"confidence\":\"0\",\"version\":null,\"icon\":\"PHP.svg\",\"website\":\"http://php.net\",\"categories\":[{\"27\":\"Programming Languages\"}]},{\"name\":\"MySQL\",\"confidence\":\"0\",\"version\":null,\"icon\":\"MySQL.svg\",\"website\":\"http://mysql.com\",\"categories\":[{\"34\":\"Databases\"}]}],\"meta\":{\"language\":\"pt\"}}\n"
)

a.to_hash

b = Analisador.new("{\"urls\":{\"djdj.ddd\":{\"status\":0,\"error\":{\"type\":\"NO_RESPONSE\",\"message\":\"No response from server\"}}},\"applications\":[],\"meta\":{}}\n"
)
b.to_hash
=end
