-- cl_ranks

net.Receive("ESSynchRankConfig",function()
	local tbl = net.ReadTable();
	if not tbl then return end
	
	for k,v in pairs(tbl) do
		if not v.pretty or not v.power then return end

		ES.SetupRank(k,v.pretty,v.power);
	end
end)