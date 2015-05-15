function ES.GetPlayerBySteamID(sid)
	for k,v in ipairs(player.GetAll())do
		if IsValid(v) and v:SteamID() == sid then
			return v
		end
	end
	return nil
end

local RussianEquiv={
	["À"] = "A",
	["Á"] = "A",
	["Â"] = "A",
	["Ã"] = "A",
	["Ä"] = "A",
	["Å"] = "A",
	["Æ"] = "AE",
	["Ç"] = "C",
	["È"] = "E",
	["É"] = "E",
	["Ê"] = "E",
	["Ë"] = "E",
	["Ì"] = "I",
	["Í"] = "I",
	["Î"] = "I",
	["Ï"] = "I",
	["Ð"] = "D",
	["Ñ"] = "N",
	["Ò"] = "O",
	["Ó"] = "O",
	["Ô"] = "O",
	["Õ"] = "O",
	["Ö"] = "O",
	["×"] = "X",
	["ß"] = "B",
	["Ø"] = "O",
	["Ù"] = "U",
	["Ú"] = "U",
	["Û"] = "U",
	["Ü"] = "U",
	["Ý"] = "Y",
}
function ES.DeRussianify(str)
	local build = ""
	local char
	for i=1,string.len(str) do
		char = string.GetChar(str,i)

		if RussianEquiv[char] then
			build = build .. ( RussianEquiv[char] )
			continue
		end

		build = build .. char
	end

	return build
end

function ES.GetPlayerByName(_n)
	print(_n)
	local n=_n;
	if type(n) ~= "string" or n == " " or n == "" then
		return {}
	elseif n == "*" then
		return player.GetAll()
	end

	n=string.lower(n)
	n=string.Trim(n)

	local found = {}
	local nick

	for k,v in ipairs(player.GetAll())do
		nick=string.lower(v:Nick())
		nick=string.Trim(nick)
		nick=ES.DeRussianify(nick)
		print(nick,n)
		if nick == n or string.find(nick,n,1,false) then
			found[#found+1]=v
		end
	end

	return found[1] and found or {ES.GetPlayerBySteamID(_n)}
end

function ES.DropUser(userid, reason)
    game.ConsoleCommand(string.format("kickid %d %s\n",userid,reason:gsub('|\n','')))
end
