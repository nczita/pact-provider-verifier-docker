require 'net/https'
require 'faraday_middleware'
require 'json'

def get_json(path)
  case path
  when URI::DEFAULT_PARSER.make_regexp
    get_json_from_server(path)
  else
    get_json_from_local_file(path)
  end
end

def get_json_from_server(path)
  url = URI.parse(path)
  conn = Faraday.new("http://#{url.host}:#{url.port}") do |c|
    c.use FaradayMiddleware::ParseJson
    c.use Faraday::Adapter::NetHttp
  end

  response = conn.get(url.request_uri)
  response.body
end

def get_json_from_local_file(path)
  file = File.read(path)
  JSON.parse(file)
end
