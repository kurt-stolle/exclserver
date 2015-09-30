
-- Functions for adding and removing commands
ES.Commands= {}
function ES.AddCommand(n,c,power)
	ES.Commands[n] = {func = c, power = power}
end
function ES.RemoveCommand(n)
	local c = 0
	for k,v in pairs(ES.Commands)do
		c=c+1
		if k==n then
			table.remove(ES.Commands,c)
			break
		end
	end
end

-- Command handling
util.AddNetworkString("ES.SyncCommands")
hook.Add("ESPlayerReady","ES.SendCommandToPlayers",function(p)
	local dumbTable={}
	for k,v in pairs(ES.Commands)do
		dumbTable[k]={power=v.power or 0}
	end

	net.Start("ES.SyncCommands")
		net.WriteTable(dumbTable)
	net.Send(p)
end)

-- Running commands
concommand.Add("excl",function(p,c,a)
	if p._es_NextCmd and p._es_NextCmd > CurTime() then return end
	p._es_NextCmd = CurTime()+.2

	c = a[1]

	if not ES.Commands or not ES.Commands[c] then
		ES.DebugPrint(p:Nick().." attempted to run invalid command "..c)
		return
	end
	if ES.Commands[c] then
		if ES.Commands[c].power and (ES.Commands[c].power > 0 and not p:ESHasPower(ES.Commands[c].power)) then
			p:ESChatPrint("Access denied.")
				return
		end
		table.remove(a,1)
		ES.Commands[c].func(p,a)
		ES.Log(ES.LOG_COMMAND,p:Nick()..": "..c.."("..table.concat(a,",",1)..")")
	end
end)
hook.Add("PlayerSay","exclPlayerChatCommandSay",function(p,t)
	if (p._es_NextCmd and p._es_NextCmd > CurTime()) or not p or not t then return end
	p._es_NextCmd = CurTime()+.2

	if t and string.Left(t,2) == "# " and p:ESHasPower(20) then

		local t = string.Explode(" ",t or "",false)
		table.remove(t,1)

		ES.Commands["announce"].func(p,t)
		ES.Log(ES.LOG_COMMAND + ES.LOG_CHAT,p:Nick()..": announce("..table.concat(t,",",1)..")")

		return false
	elseif t and string.Left(t,2) == "@ " then

		local t = string.Explode(" ",t or "",false)
		table.remove(t,1)

		ES.Commands["adminchat"].func(p,t)
		ES.Log(ES.LOG_COMMAND + ES.LOG_CHAT,p:Nick()..": adminchat("..table.concat(t,",",1)..")")

		return false
	elseif t and (string.Left(t,1) == ":") then -- strict mode: only allow the : prefix for ExclServer commands.
		local t = string.Explode(" ",t or "",false)
		t[1] = string.gsub(t[1] or "",string.Left(t[1],1) or "","")

		if t and t[1] then
			local c = string.lower(t[1])
			if ES.Commands and ES.Commands[c] then
				if ES.Commands[c].power and (ES.Commands[c].power > 0 and not p:ESHasPower(ES.Commands[c].power)) then
					p:ESChatPrint("Access denied.")
					return false
				end
				table.remove(t,1)
				ES.Commands[c].func(p,t)
				ES.Log(ES.LOG_COMMAND + ES.LOG_CHAT,p:Nick()..": "..c.."("..table.concat(t,",",1)..")")

				return false
			end
		end

	end
end)
