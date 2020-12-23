# frozen_string_literal: true

require "net/http"
require "uri"
require "json"
require "date"
require "nokogiri"
require "open-uri"
require "./all_type"
require "./product_type"
require "./doc_type"
require "./info_type"
require "./practice_type"
require "./report_type"
require "./question_type"

LOGINNAME = ENV["loginname"]
PASSWORD = ENV["password"]

def search_type
  abbr, *query = ARGV
  keyword = query.join(" ")
  case abbr
  when AllType::ABBREVIATION then
    AllType.new(keyword)
  when InfoType::ABBREVIATION then
    InfoType.new(keyword)
  when DocType::ABBREVIATION then
    DocType.new(keyword)
  when PracticeType::ABBREVIATION then
    PracticeType.new(keyword)
  when ReportType::ABBREVIATION then
    ReportType.new(keyword)
  when QuestionType::ABBREVIATION then
    QuestionType.new(keyword)
  end
end

@search_type = search_type
return if @search_type.nil?

def request_options(uri)
  { use_ssl: uri.scheme == "https" }
end

def fetch_jwt_token
  uri = URI.parse("https://bootcamp.fjord.jp/api/session")
  request = Net::HTTP::Post.new(uri)
  request.content_type = "application/json"
  request.body = JSON.dump({
                             "login_name" => LOGINNAME,
                             "password" => PASSWORD
                           })
  response = http_request(uri, request)
  response.body.gsub(/{\"token\":\"|"}/, "")
end

def http_request(uri, request)
  Net::HTTP.start(uri.hostname, uri.port, request_options(uri)) do |http|
    http.request(request)
  end
end

def fetch_csrf_token
  uri = URI.parse("https://bootcamp.fjord.jp/")
  request = Net::HTTP::Get.new(uri)
  request["Authorization"] = fetch_jwt_token
  response = http_request(uri, request)
  re = Regexp.new("csrf-token.+?==")
  s = response.body
  csrf_token = re.match(s).to_s.gsub('csrf-token" content="', "")
  { csrf_token: csrf_token, cookie: extract_cookie(response) }
end

def extract_cookie(response)
  cookie = {}
  response.get_fields("Set-Cookie").each do |str|
    k, v = str[0...str.index(";")].split("=")
    cookie[k] = v
  end
  cookie
end

def add_cookie(request, cookie)
  request.add_field("Cookie", cookie.map do |k, v|
    "#{k}=#{v}"
  end.join(";"))
  request
end

def get_infos(token)
  uri = URI.parse(@search_type.search_url)
  request = Net::HTTP::Get.new(uri)
  request.content_type = "text/html"
  request = add_cookie(request, token[:cookie])
  response = http_request(uri, request)
  doc = Nokogiri::HTML.parse(response.body, nil, "utf-8")
  thread_list_items =  doc.css(".thread-list-item")

  {
    items: thread_list_items.map(&@search_type.method(:create_item))
  }.to_json
end

token = fetch_csrf_token

if (PASSWORD == "password") && (LOGINNAME == "username")
  puts "LOGINNAMEとPASSWORDを設定してください"
  return
end

puts get_infos(token)
