def IsMarketOpen(d)
if d.wday == 6 or d.wday == 0
	return false
else
	if d.month * d.day == 1
		return false
	else
		return true
	end
end
end