# encoding=utf-8 
require "Date"
require "open-uri"
require "colorize"
require "gchart"
require "gruff"

dic = {'USD'=>'美金', 'JPY'=>'日圓', 'CAD'=>'加拿大幣', 'AUD'=>'澳幣'}

case ARGV.length
when 0
	cur = 'USD'
when 1
	cur = ARGV[0]
else
	puts "invalid inputs"
end
cur_ch = dic[cur]

today = Date.today


url = "http://rate.bot.com.tw/Pages/UIP004/UIP00421.aspx?lang=zh-TW&whom1="\
 + cur + "&whom2=&date="\
 + today.strftime("%Y%m%d")\
 +  "&entity=1&year=2015&month=04&term=99&afterOrNot=0&view=1"
pat = /([\d\/]{10})\s+([\d:]{8})<\/td><td class="title">#{cur_ch} \(#{cur}\)<\/td><td class="decimal">([\d.]+)<\/td><td class="decimal">([\d.]+)<\/td><td class="decimal">([\d.]+)<\/td><td class="decimal">([\d.]+)/

puts "           \e[0;34mToday is  #{today.strftime("%Y/%m/%d")}\e[0m"

old_page = ""
old_len  = 0
now = Time.now

while now.hour < 16
	
	now = Time.now

	page = open(url).read
	if page == old_page
		puts now.strftime('%H:%M:%S') + "   \e[1;30mno update\e[0m"
	else
		old_page = page
		data = page.scan(pat).to_a
		open_price = data.first
		for update in data[old_len..(data.length-1)]
			change = update[5].to_f - open_price[5].to_f
			msg = update[1] + "   " + "\e[0;32;47mBUY  #{'%.3f'  % update[4].to_f}\e[0m" \
			                + "   " + "\e[0;31;47mSELL #{'%.3f' % update[5].to_f}\e[0m"
			if change == 0
				puts msg + "   " + "\e[0;37;40m#{' %.3f' % change}\e[0m"
			else
				if change > 0
					puts msg + "   " + "\e[0;37;41m#{'+%.3f' % change}\e[0m"
				else
					puts msg + "   " + "\e[0;37;42m#{'%.3f' % change}\e[0m"
				end
			end
		end
		old_len = data.length

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
	sleep(300)
end
puts "\e[1;34m#{now.strftime('%H:%M:%S')}   Market closed\e[0m"
