function ES.IsIdenticalTable(a,b)
	for k,v in pairs(a) do
		if not b[k] or v ~= b[k] then
			return false;
		end
	end
	for k,v in pairs(b) do
		if not a[k] or v ~= a[k] then
			return false;
		end
	end
	return true
end

function ES.MatchKey(tab,key_sub,value)
	for k,v in ipairs(tab)do
		if v[key_sub] and v[key_sub] == value then
			return v;
		end
	end
end