local PLUGIN=ES.Plugin();
PLUGIN:SetInfo("Ban","Allows you to ban people from your server if you have the right rank.","Excl")
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE)
if SERVER then
	PLUGIN:AddCommand("ban",function(p,a)
		if type(a[1]) ~= "string" or type(a[2]) ~="string" or type(a[3]) ~="string" then
			p:ESChatPrint("Invalid arguments passed to command <hl>ban</hl>.")
			return
		end

		local user = a[1]
		local time = tonumber(a[2])
		local reason = table.concat(a," ",3)

		if not user or not time or not reason or time < 0 then
			p:ESChatPrint("Invalid arguments passed to command <hl>ban</hl>.")
		return end

		local userFound = ES.GetPlayerByName(user)
		if not userFound or not IsValid(userFound[1]) then
			if ES.IsSteamID(user) then
				ES.AddBan(user,p:SteamID(),time,true,reason,user,p:Nick())
				ES.ChatBroadcast("<hl>"..p:Nick().."</hl> banned <hl>"..user.."</hl>, reason: <hl>"..reason.."</hl>.")
				return;
			end

			p:ESChatPrint("No player matching <hl>"..a[1].."</hl> found. Try finding the player by SteamID.")
			return
		elseif #userFound > 1 then
			p:ESChatPrint("Multiple players matching <hl>"..a[1].."</hl> found. Try finding the player by SteamID.")
			return;
		end
		local userFound=userFound[1]

		ES.AddBan(userFound:SteamID(),p:SteamID(),time,true,reason,userFound:Nick(),p:Nick())
		ES.DropUser(userFound:UserID(), "You are banned! Your ban will expire in "..time.." minutes. Reason: "..reason)
		ES.ChatBroadcast("<hl>"..p:Nick().."</hl> banned <hl>"..userFound:Nick().."</hl>, reason: <hl>"..reason.."</hl>.")
	end,20)

	PLUGIN:AddCommand("unban",function(p,a)
		local user = a[1]
		if type(user) ~= "string" and ES.IsSteamID(user) then
			p:ESChatPrint("Invalid arguments passed to command <hl>unban</hl>.");
		end

		ES.RemoveBan( string.upper(user) )
		ES.ChatBroadcast("<hl>"..p:Nick().."</hl> unbanned <hl>"..user.."</hl>.")
	end,40)
end
PLUGIN()
