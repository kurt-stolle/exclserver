function ES.IsIdenticalTable(a,b)
	for k,v in pairs(a) do
		if not b[k] or v ~= b[k] then
			return false
		end
	end
	for k,v in pairs(b) do
		if not a[k] or v ~= a[k] then
			return false
		end
	end
	return true
end

function ES.MatchSubKey(tab,key_sub,value)
	for k,v in ipairs(tab)do
		if v[key_sub] and tostring(v[key_sub]) == tostring(value) then
			return v
		end
	end
	return nil
end

function ES.ImplementIndexMatcher(tbl,key_sub)
	setmetatable(tbl,{
		__index = function(self,key)
			return ES.MatchSubKey(self,key_sub,key)
		end
	})
end