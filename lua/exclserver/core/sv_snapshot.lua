-- sv_snapshot.lua
util.AddNetworkString("ESMakeSnapshot")
util.AddNetworkString("ESUploadSnapshot");
util.AddNetworkString("ESUploadSnapshotProg");
util.AddNetworkString("ESShowSnapshot");
util.AddNetworkString("ESShowSnapshotProg");

local build = {};
local requesters = {};
net.Receive("ESUploadSnapshot",function(len,p)
	build[p:UniqueID()] = {ss = {},frag = net.ReadInt(16)};
end);
net.Receive("ESUploadSnapshotProg",function(len,p)
	if not build[p:UniqueID()] then return end

	ES.DebugPrint("Received SS fragment")
	
	build[p:UniqueID()].ss[net.ReadInt(8)] = net.ReadData(net.ReadInt(32));

	local complete= true;
	for i=1,build[p:UniqueID()].frag do
		if not build[p:UniqueID()].ss[i] then
			complete = false;
			break;
		end
	end

	if not complete or not requesters[p:UniqueID()] then return end

	ES.DebugPrint("Upload complete")

	net.Start("ESShowSnapshot");
	net.WriteEntity(p);
	net.WriteInt(build[p:UniqueID()].frag,16);
	net.WriteString(p:Nick().."\n"..p:SteamID())
	net.Send(requesters[p:UniqueID()]);

	for i=1,build[p:UniqueID()].frag do
		--print(build[p:UniqueID()].ss[i]:len());
		net.Start("ESShowSnapshotProg");
		net.WriteEntity(p);
		net.WriteInt(i,8);
		net.WriteInt(build[p:UniqueID()].ss[i]:len(),32);
		net.WriteData(build[p:UniqueID()].ss[i],build[p:UniqueID()].ss[i]:len());
		net.Send(requesters[p:UniqueID()]);
	end

	requesters[p:UniqueID()] = nil;
	build[p:UniqueID()] = nil;

	if !file.Exists("exclsnapshots", "DATA") then
		file.CreateDir("exclsnapshots");
	end
	file.Write("exclsnapshots/"..requesters[p:UniqueID()].."_"..p:ESID().."_"..os.time().."_base64.txt", util.Base64Encode(data));
end);
	
ES:AddCommand("snapshot",function(p,a) 
	if not IsValid(p) or not a or not a[1] then return end
	if  (p.exclNextSnap and p.exclNextSnap > CurTime()) then p:ChatPrint("This command is currently on cooldown. Please wait " .. math.Round(p.exclNextSnap - CurTime()) .." more seconds.") return end

	local vic = exclPlayerByName(a[1])
	local quality = a[2] and tonumber(a[2]) or 50;

	if quality > 50 then quality = 50 end

	if not vic then return end
	vic = vic[1];
	if not vic or not IsValid(vic) then return end
	
	net.Start("ESMakeSnapshot")
	net.WriteInt(quality,32);
	net.Send(vic);

	if not requesters[vic:UniqueID()] then requesters[vic:UniqueID()] = {} end
	requesters[vic:UniqueID()][#requesters[vic:UniqueID()] + 1] = p;

	p.exclNextSnap = CurTime() + 30;
	p:ChatPrint("The snapshot is being taken and sent to you and the server. Please be patient while the snapshot is loading.");
end,20);