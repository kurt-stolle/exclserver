
local PLUGIN=ES.Plugin();
PLUGIN:SetInfo("RTV","Mapvoting.","Excl")


local rockers = {}
local canRtv = 90 -- wait 90 s before allowing rtv
local function doRTV(p)
	if not (ES.MapvoteEnabled and p and IsValid(p)) then return
	elseif CurTime() < canRtv then p:ChatPrint("RTV will be enabled in "..math.Round(canRtv-CurTime()).." seconds. Try again later.") return end

	local needed = math.Round(#player.GetAll()*0.65);

	if not rockers[p:UniqueID()] then
		rockers[p:UniqueID()] = true;
		net.Start("exclRTV");
		net.WriteEntity(p);
		net.WriteInt(math.Clamp(needed-table.Count(rockers),0,1000),16);
		net.Broadcast();
	else
		p:ChatPrint("You have already voted. Currently the RTV needs "..math.Clamp(needed-table.Count(rockers),0,1000).." more voters.");
	end

	if table.Count(rockers) >= needed then
		ES:StartMapVote();
	end
end
PLUGIN:AddCommand("rtv",function(p,a)
	doRTV(p);		
end,0);
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE)
PLUGIN();

function ES:ResetRTV()
	rockers = {};
end

if SERVER then 
	util.AddNetworkString("exclRTV");

	hook.Add("PlayerSay","exclSayRTVVVVRTV",function(p,tx)
		local t = string.lower(tx);
		if t == "rtv" then
			doRTV(p)
			return false;
		end
	end)

	return 
end
net.Receive("exclRTV",function()
	local p = net.ReadEntity();
	local num = net.ReadInt(16);
	if not IsValid(p) then return end
	
	ES:ChatAddText("global",Color(102,255,51),p:Nick(),Color(255,255,255)," wants to rock the vote, ",Color(102,255,51),tostring(num),Color(255,255,255,255)," more vote(s) needed. Type ",Color(102,255,51),"rtv",Color(255,255,255,255)," to rock the vote.");
end)