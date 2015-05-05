# encoding=utf-8 
require "Date"
require "open-uri"
require "colorize"
require "gchart"
require "gruff"

cur = 'USD'
cur_ch = '美金'

today = Date.today


url = "http://rate.bot.com.tw/Pages/UIP004/UIP00421.aspx?lang=zh-TW&whom1="\
 + cur + "&whom2=&date="\
 + today.strftime("%Y%m%d")\
 +  "&entity=1&year=2015&month=04&term=99&afterOrNot=0&view=1"
pat = /([\d\/]{10})\s+([\d:]{8})<\/td><td class="title">#{cur_ch} \(#{cur}\)<\/td><td class="decimal">([\d.]+)<\/td><td class="decimal">([\d.]+)<\/td><td class="decimal">([\d.]+)<\/td><td class="decimal">([\d.]+)/

puts "Today is " + today.strftime("%Y/%m/%d")

old_page = ""
now = Time.now

while now.hour < 16
	
	now = Time.now

	page = open(url).read
	if page == old_page
		puts now.strftime('%H:%M:%S') + "            no update"
	else
		old_page = page
		data = page.scan(pat).to_a
		open_price = data.first
		update = data.last
		change = update[5].to_f - open_price[5].to_f
		change = change.round(2)
		msg = update[1] + "  " + "\e[0;32;47mBUY:  #{update[4]}\e[0m" + "   " + "\e[0;31;47mSELL:  #{update[5]}\e[0m"
		if change == 0
			puts msg + "   " + "\e[0;37;40mBUY:  #{change}\e[0m"
		else
			if change > 0
				puts msg + "   " + "\e[0;37;41m#{change}\e[0m"
			else
				puts msg + "   " + "\e[0;37;42m#{change}\e[0m"
			end
		end
		

		buy_prices = Array.new(0)
		sel_prices = Array.new(0)
		time       = Array.new(0)

		for p in data
			buy_prices << p[4].to_f
			sel_prices << p[5].to_f
			time   << p[1]
		end

		x = (1..data.length).to_a

		Gchart.line(:data => [buy_prices, sel_prices],
			:size => "600x400",
			:title => cur + "/NTD on " + today.strftime("%Y/%m/%d") + " " + update[1],
			:legend => ['買入', '賣出'],
			:format => 'file', 
			:filename => 'test_gchart_reamtime_' + today.strftime("%Y%m%d") + '.png',
			:min_value => buy_prices.min-0.1,
			:max_value => sel_prices.max+0.1,
			:axis_with_labels => 'x, r',
		    # :axis_labels => time
		    )

		g = Gruff::Line.new
		g.title = cur + "/NTD on " + today.strftime("%Y/%m/%d") + " " + update[1]
		g.dataxy('BUY',  x, buy_prices)
		g.dataxy('SELL', x, sel_prices)
		# g.dataxy 'BUY',  time, buy_prices 
		# g.dataxy 'SELL', time, sel_prices 
		g.write('test_gruff_reamtime_' + today.strftime("%Y%m%d") + '.png')
	end
	sleep(60)
end
