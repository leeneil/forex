# encoding=utf-8 
require "Date"
require "csv"
require "gchart"
require "gruff"

if ARGV.length == 0
	date_str = Date.today
else
	date_str =  Date.parse( ARGV[0] )
end

data = CSV.read("USDNTD/" + date_str.strftime("%Y%m%d") + ".csv").to_a

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
	:title => "USD/NTD on " + date_str.strftime("%Y/%m/%d"),
	:legend => ['買入', '賣出'],
	:format => 'file', 
	:filename => 'test_gchart.png',
	:min_value => buy_prices.min-1,
	:max_value => sel_prices.max+1,
	:axis_with_labels => 'x, r',
    # :axis_labels => time
    )

g = Gruff::Line.new
g.title = "USD/NTD on " + date_str.strftime("%Y/%m/%d")
g.dataxy('BUY',  x, buy_prices)
g.dataxy('SELL', x, sel_prices)
# g.dataxy 'BUY',  time, buy_prices 
# g.dataxy 'SELL', time, sel_prices 
g.write("test_gruff.png")

puts "Highest buy: " + buy_prices.max.to_s
puts "Lowest sell: " + sel_prices.min.to_s 
