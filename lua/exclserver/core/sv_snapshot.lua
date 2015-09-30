-- sv_snapshot.lua
util.AddNetworkString("exclserver.snapshot.capture")
util.AddNetworkString("exclserver.snapshot.send.sync")
util.AddNetworkString("exclserver.snapshot.send.part")

local build = {}
local requesters = {}
net.Receive("exclserver.snapshot.send.sync",function(len,p)
	build[p:UniqueID()] = {ss = {},frag = net.ReadInt(16)}
end)
net.Receive("exclserver.snapshot.send.part",function(len,p)
	if not build[p:UniqueID()] then return end

	build[p:UniqueID()].ss[net.ReadInt(8)] = net.ReadData(net.ReadInt(32))

	local complete= true
	for i=1,build[p:UniqueID()].frag do
		if not build[p:UniqueID()].ss[i] then
			complete = false
			break
		end
	end

	if not complete or not requesters[p:UniqueID()] then return end

	for k,v in ipairs(requesters[p:UniqueID()]) do
		p._es_snapshotCooldown = false
	end

	net.Start("exclserver.snapshot.send.sync")
	net.WriteEntity(p)
	net.WriteInt(build[p:UniqueID()].frag,16)
	net.WriteString(p:Nick().."\n"..p:SteamID())
	net.Send(requesters[p:UniqueID()])

	for i=1,build[p:UniqueID()].frag do
		net.Start("exclserver.snapshot.send.part")
		net.WriteEntity(p)
		net.WriteInt(i,8)
		net.WriteInt(build[p:UniqueID()].ss[i]:len(),32)
		net.WriteData(build[p:UniqueID()].ss[i],build[p:UniqueID()].ss[i]:len())
		net.Send(requesters[p:UniqueID()])
	end

	requesters[p:UniqueID()] = nil
	build[p:UniqueID()] = nil

	if !file.Exists("exclserver", "DATA") then
		file.CreateDir("exclserver")

		if !file.Exists("exclserver/snapshots", "DATA") then
			file.CreateDir("exclserver/snapshots")
		end
	end
	file.Write("exclserver/snapshots/"..p:SteamID().."_"..os.time().."_base64.txt", util.Base64Encode(data))
end)

ES.AddCommand("snapshot",function(p,a)
	if not IsValid(p) or not a or not a[1] then return end

	if  p._es_snapshotCooldown then p:ESSendNotificationPopup("Cooldown","This command is currently on cooldown to reduce server load. Wait until the current snapshot has been processed.") return end

	local vic = ES.GetPlayerByName(a[1])[1]
	local quality = math.Clamp(a[2] and tonumber(a[2]) or 25,10,50)

	if IsValid(vic) then return p:ESChatPrint("Target not found.") end

	net.Start("exclserver.snapshot.capture")
	net.WriteUInt(quality,16)
	net.Send(vic)

	if not requesters[vic:UniqueID()] then
		requesters[vic:UniqueID()] = {}
	end

	requesters[vic:UniqueID()][#requesters[vic:UniqueID()] + 1] = p

	p._es_snapshotCooldown = true
	p:ESSendNotificationPopup("Success","The snapshot is being taken and sent to you and the server. Please be patient while the snapshot is loading. This may take a while.")
end,20)
