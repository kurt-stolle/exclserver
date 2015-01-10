-- cl_snapshots.lua
-- takes snapshots

local takesnap = false;
net.Receive("ESMakeSnapshot",function()
	takesnap = net.ReadInt(32);
end)
hook.Add("PostRender","ESMakeSnapshot_PostRender",function()
	if takesnap then
		local data = render.Capture{format = "jpeg", quality = takesnap, x = 0, y = 0, w = ScrW(), h = ScrH()};
		net.Start("ESUploadSnapshot");
		net.WriteInt(math.ceil(data:len()/50000),16)
		--net.WriteInt(data:len(),32);
		--net.WriteData(data,data:len());
		net.SendToServer();

		for i=1,math.ceil(data:len()/50000) do
			net.Start("ESUploadSnapshotProg");
			net.WriteInt(i,8);
			net.WriteInt(data:sub(50000*(i-1),-1 + 50000*i):len(),32);
			net.WriteData(data:sub(50000*(i-1),-1 + 50000*i),data:sub(50000*(i-1),-1 + 50000*i):len());
			net.SendToServer();
		end

		--print(data:len());
		--print(math.ceil(data:len()/50000))

		takesnap = false;
	end
end)

local frame;
local function makeFrame(data,ply,p)
	if frame then frame:Remove() end

	frame = vgui.Create("esFrame");
	frame:SetSize(ScrW()-20,ScrH()-20);
	frame:Center();
	frame:SetTitle("ExclServer Snapshot")
	local dum = frame:Add("esPanel");
	dum:SetSize(frame:GetWide() - 200 - 10,frame:GetTall()-40);
	dum:SetPos(205,35);
	local ht = vgui.Create("HTML",dum);
	ht:SetSize(dum:GetWide()-4,dum:GetTall()-4);
	ht:SetPos(2,2);
	ht:SetHTML([[
			<!DOCTYPE html>
		   <html>
		     <body marginheight="0" marginwidth="0">
		     <img style='display:block; margin: 0; padding: 0; width:100%;' src='data:image/jpeg;base64, ]]..util.Base64Encode(data)..[[' />
		   </body>]])--height:100%;
	local bsave = frame:Add("esButton");
	bsave:SetPos(5,35);
	bsave:SetSize(195,30);
	bsave:SetText("Save JPEG data as .txt")
	bsave.DoClick = function()
		if !file.Exists("exclsnapshots", "DATA") then
			file.CreateDir("exclsnapshots");
		end
		file.Write("exclsnapshots/"..p:ESID().."_"..os.time()..".txt", data)
	end

	local bsave2 = frame:Add("esButton");
	bsave2:SetPos(5,35+35);
	bsave2:SetSize(195,30);
	bsave2:SetText("Save Base64 encoded as .txt")
	bsave2.DoClick = function()
		if !file.Exists("exclsnapshots", "DATA") then
			file.CreateDir("exclsnapshots");
		end
		file.Write("exclsnapshots/"..p:ESID().."_"..os.time().."_base64.txt", util.Base64Encode(data));
	end

	local btrack = frame:Add("esButton");
	btrack:SetPos(5,35+35+35);
	btrack:SetSize(195,30);
	btrack:SetText("Track user (OP+)")
	btrack.DoClick = function()
		RunConsoleCommand("excl","info",p:SteamID())
	end

	local lb = Label("User:",frame);
	lb:SetPos(10,frame:GetTall()-100);
	lb:SetFont("ESDefaultBold");
	lb:SetColor(COLOR_WHITE);
	lb:SizeToContents();

	local lb = Label(ply,frame);
	lb:SetPos(10,frame:GetTall()-85);
	lb:SetFont("ESDefault");
	lb:SetColor(COLOR_WHITE);
	lb:SizeToContents();

	local lb = Label("Binary data length:",frame);
	lb:SetPos(10,frame:GetTall()-45);
	lb:SetFont("ESDefaultBold");
	lb:SetColor(COLOR_WHITE);
	lb:SizeToContents();

	local lb = Label(data:len(),frame);
	lb:SetPos(10,frame:GetTall()-25);
	lb:SetFont("ESDefault");
	lb:SetColor(COLOR_WHITE);
	lb:SizeToContents();

	frame:MakePopup();
end

local build = {};
net.Receive("ESShowSnapshot",function()
	build[net.ReadEntity():UniqueID()] = {ss = {},frag = net.ReadInt(16),ply = net.ReadString()};
end);

net.Receive("ESShowSnapshotProg",function()
	local p = net.ReadEntity();
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

	if not complete then return end

	ES.DebugPrint("Download complete")

	local str = "";
	for i=1,#build[p:UniqueID()].ss do
		str = str..build[p:UniqueID()].ss[i];
	end

	makeFrame(str,build[p:UniqueID()].ply,p)
end);