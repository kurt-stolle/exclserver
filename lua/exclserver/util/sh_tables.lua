function ES.IsIdenticalTable(a,b)
	for k,v in pairs(a) do
		if not b[k] or v ~= b[k] then
			return false;
		end
	end
	return true
end