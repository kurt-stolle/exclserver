-- GetPlayerByName

function exclPlayerByName(n)
	if n == "*" then 
		return player.GetAll();
	elseif n == " " then 
		return {} 
	elseif n == "" then 
		return {} 
	end
	
	local star = false;
	local found = {}
	for k,v in pairs(player.GetAll())do
		local nb = string.gsub(n,"_"," ");
		if string.find(string.gsub(string.lower(v:Nick()),"_"," "),string.gsub(string.lower(nb),"_"," ")) then
			found[#found+1]=v;
		end
	end
	
	if not found or not found[1] then
		return {exclPlayerBySteamID(n)};
	end
	return found;
end