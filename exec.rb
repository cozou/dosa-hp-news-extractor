require 'nokogiri'
require 'open-uri'
require 'csv'

url = "http://dosa.or.jp/index.html"

html = open(url, "r:cp932").read.encode('utf-8')
page = Nokogiri::HTML.parse(html)

table = page.css('#info table').first
rows = table.css('tr')
text_all_rows = rows.map do |row|
  row_values = row.css('td').map(&:text)
  a = row.css('a').attr('href')&.value
  [*row_values, a =~ /http.*/ ? a : a && "https://www.dosa.or.jp/#{a}"] if row_values.length != 0
end.compact

write_file = 'news.csv'
url_file = 'url.csv'

CSV.open(write_file, "wb") do |csv|
CSV.open(url_file, "wb") do |list|
  csv << ['post_id', 'post_name', 'post_author', 'post_date', 'post_type', 'post_status', 'post_title', 'post_content', 'post_category', 'post_tags', 'custom_field']
  text_all_rows.each do |row|
    date = row[0].gsub(/\./, '/')
    title = row[1].gsub(/詳細はこちら/, '').gsub(/★ご案内/, '').gsub(/★詳細/, '').gsub(/詳細/, '').strip
    list << [row[2].strip] if row[2]
    url = row[2] ? "\n<a href='#{row[2].strip}'>#{row[2].strip}</a>" : ''
    csv << [nil, nil, 'sugimoto', date, 'post', 'publish', title, "#{title}#{url}", 'お知らせ', nil, nil]
  end
end
end