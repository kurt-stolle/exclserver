-- tp
-- tp people

local PLUGIN=ES.Plugin();
PLUGIN:SetInfo("Teleport","Allows you to teleport.","Excl")
local function findLocation( from, to, force )
	if not to:IsInWorld() and not force then return false end

	local yawForward = to:EyeAngles().yaw
	local directions = {
		math.NormalizeAngle( yawForward - 180 ),
		math.NormalizeAngle( yawForward + 90 ),
		math.NormalizeAngle( yawForward - 90 ),
		yawForward,
	}

	local t = {}
	t.start = to:GetPos() + Vector( 0, 0, 32 )
	t.filter = { to, from }

	local i = 1
	t.endpos = to:GetPos() + Angle( 0, directions[ i ], 0 ):Forward() * 47
	local tr = util.TraceEntity( t, from )
	while tr.Hit do
		i = i + 1
		if i > #directions then
			if force then
				return to:GetPos() + Angle( 0, directions[ 1 ], 0 ):Forward() * 47
			else
				return false
			end
		end

		t.endpos = to:GetPos() + Angle( 0, directions[ i ], 0 ):Forward() * 47

		tr = util.TraceEntity( t, from )
	end

	return tr.HitPos
end
local function teleport(p,arg)
	if not p or not IsValid(p) or not arg or not arg[2] then return end
	
	local a = exclPlayerByName(arg[1]);
	local b = exclPlayerByName(arg[2]);

	if !a or !b then return end
	
	a = a[1];
	b = b[1];

	if !a or !b or !IsValid(a) or !IsValid(b) then return end
	
	local pos = findLocation( a,b,p:GetMoveType() == MOVETYPE_NOCLIP or p:GetMoveType() == MOVETYPE_OBSERVER or tobool(a[3]) );
	if not pos then p:ChatPrint("Not enough space to teleport, put \"1\" as third argument to force teleport (this will probably resuly in getting stuck).") return end

	a:SetPos(pos);

	net.Start("exclTP");
	net.WriteEntity(p);
	net.WriteEntity(a);
	net.WriteEntity(b);
	net.Broadcast();
end
PLUGIN:AddCommand("tp",teleport,10);
PLUGIN:AddCommand("teleport",teleport,10);
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE)
PLUGIN();

if SERVER then 
	util.AddNetworkString("exclTP");

	return 
end
net.Receive("exclTP",function()
	local p = net.ReadEntity();
	local a = net.ReadEntity();
	local b = net.ReadEntity();

	if not IsValid(p) or not IsValid(a) or not IsValid(b) then return end
	
	if p == a then
		ES.ChatAddText("admincommand",COLOR_WHITE,exclFixCaps(p:ESGetRank().name).." ",Color(102,255,51),p:Nick(),COLOR_WHITE," has teleported to ",Color(102,255,51),b:Nick(),COLOR_WHITE,".");
	elseif p == b then
		ES.ChatAddText("admincommand",COLOR_WHITE,exclFixCaps(p:ESGetRank().name).." ",Color(102,255,51),p:Nick(),COLOR_WHITE," has teleported ",Color(102,255,51),a:Nick(),Color(255,255,255,255)," to his/her location.");
	else
		ES.ChatAddText("admincommand",COLOR_WHITE,exclFixCaps(p:ESGetRank().name).." ",Color(102,255,51),p:Nick(),COLOR_WHITE," has teleported ",Color(102,255,51),a:Nick(),Color(255,255,255,255)," to ",Color(102,255,51),b:Nick(),COLOR_WHITE,".");
	end
	chat.PlaySound()
end)