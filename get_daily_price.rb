# encoding=utf-8 
require "Date"
require_relative "IsMarketOpen.rb"
require "open-uri"
require "csv"

cur = 'JPY'
cur_ch = '日圓'

if ARGV.length == 0
	date_str = Date.today.to_s
else
	date_str = ARGV[0]
end
if ARGV.length > 1
	date_end = ARGV[1]
else
	date_end = date_str
end


date_str = Date.parse(date_str)
date_end = Date.parse(date_end)
if date_str < Date.parse("2008/11/17")
	date_str = Date.parse("2008/11/17")
end
if date_end > Date.today
	date_end = Date.today
end


pat = /([\d\/]{10})\s+([\d:]{8})<\/td><td class="title">#{cur_ch} \(#{cur}\)<\/td><td class="decimal">([\d.]+)<\/td><td class="decimal">([\d.]+)<\/td><td class="decimal">([\d.]+)<\/td><td class="decimal">([\d.]+)/

for d in date_str..date_end
	if IsMarketOpen(d)
		url = "http://rate.bot.com.tw/Pages/UIP004/UIP00421.aspx?lang=zh-TW&whom1=" + cur + "&whom2=&date="\
		+ d.strftime("%Y%m%d") +  "&entity=1&year=2015&month=04&term=99&afterOrNot=0&view=1"
		page = open(url).read
		data = page.scan(pat).to_a
		unless data.empty?
			CSV.open(cur + "TWD/" + d.strftime("%Y%m%d") + ".csv", "w") do |csv|
			  for tick in data
			  	csv << tick
			  end
			end
			puts d.strftime("%Y/%m/%d saved")
		end
	end
end

