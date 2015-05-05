# encoding=utf-8 
require "Date"
require "csv"
require "gchart"
require "gruff"

# cur = 'JPY'
cur = 'USD'

case ARGV.length
when 0
	cur = 'USD'
	date_end = Date.today
	date_str = date_end - 365
when 1
	cur = ARGV[0]
	date_end = Date.today
	date_str = date_end - 365
when 2
	cur = ARGV[0]
	date_str = Date.parse( ARGV[1] )
	date_end = Date.today
when 3
	cur = ARGV[0]
	date_str = Date.parse( ARGV[1] )
	date_end = Date.parse( ARGV[2] )
else
	puts "Invalid inputs"
end

# dic = {}
open_prices = []
close_prices = []
high_prices = []
low_prices = []
count = -1
for d in date_str..date_end
	filename = cur + "TWD/" + d.strftime("%Y%m%d") + ".csv"
	if File.exist?(filename)
		data = CSV.read(filename).to_a
		open_price  = data.first
		close_price = data.last
		high_price = data.transpose[4].max.to_f
		low_price  = data.transpose[4].min.to_f
		count = count + 1
		open_prices[count]  = [d.strftime("%Y/%m/%d"),  open_price[4].to_f,  open_price[5].to_f]
		close_prices[count] = [d.strftime("%Y/%m/%d"), close_price[4].to_f, close_price[5].to_f]
		high_prices[count] = high_price
		low_prices[count]  = low_price
		# dic[d.strftime("%Y%m%d")] = [{"oepn"=>[{"buy"=>open_price[4]},\
		# 									 {"sell"=>open_price[5]}]},\
		# 						   {"close"=>[{"buy"=>close_price[4]},\
		# 									 {"sell"=>close_price[5]}]}] 
	end
end

# puts open_prices.transpose[1]

# buy_prices = Array.new(0)
# sel_prices = Array.new(0)
# time       = Array.new(0)

# for p in data
# 	buy_prices << p[4].to_f
# 	sel_prices << p[5].to_f
# 	time   << p[1]
# end

# x = (1..data.length).to_a

Gchart.line(
	:data => [close_prices.transpose[1]],
	:size => "600x400",
	:title => cur + "/NTD during " + date_str.strftime("%Y/%m/%d") \
	+ " ~ " + date_end.strftime("%Y/%m/%d"),
	:legend => ['Close'],
	:format => 'file', 
	:filename => 'test_gchart.png',
	:min_value => close_prices.transpose[1].min-0.1,
	:max_value => close_prices.transpose[1].max+0.1,
	:axis_with_labels => 'x',
    :axis_labels => open_prices.transpose[0]
    )

g = Gruff::Line.new
g.title = cur + "/TWD during " + date_str.strftime("%Y/%m/%d") \
	+ " ~ " + date_end.strftime("%Y/%m/%d")
# g.labels = open_prices.transpose[0]
g.data('OPEN',    open_prices.transpose[1])
g.data('CLOSE',   close_prices.transpose[1])
# g.dataxy('OPEN',  open_prices.transpose[1])
# g.dataxy('CLOSE', close_prices.transpose[1])
# g.dataxy 'BUY',  time, buy_prices 
# g.dataxy 'SELL', time, sel_prices 
g.write("test_gruff_openclose.png")

g = Gruff::Line.new
g.title = cur + "/TWD during " + date_str.strftime("%Y/%m/%d") \
	+ " ~ " + date_end.strftime("%Y/%m/%d")
# g.labels = open_prices.transpose[0]
g.data('highest', high_prices)
g.data('lowest',  low_prices)
# g.dataxy('OPEN',  open_prices.transpose[1])
# g.dataxy('CLOSE', close_prices.transpose[1])
# g.dataxy 'BUY',  time, buy_prices 
# g.dataxy 'SELL', time, sel_prices 
g.write("test_gruff_highlow.png")

# puts "Highest buy: " + buy_prices.max.to_s
# puts "Lowest sell: " + sel_prices.min.to_s 
