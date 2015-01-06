-- cl_motd.lua
-- the motd
ES.motdEnabled = true;

local motdString = [[
This server is running ExclServer, to open up the menu press F6.
Visit our website at www.CasualBananas.com

Enjoy your stay!
]]
local rulesString = [[
Todo: Add Hook: "ESGetRules" to retrieve gamemode rules.
]]

local motd
concommand.Add("excl_debug_closemotd",function()
	if motd and motd:IsValid() then motd:Remove() end
end)
function ES:ToggleMotd()
	if not ES.motdEnabled or hook.Call("ESShouldPreventMOTD") then return end
	if motd and motd:IsValid() then motd:Remove() end

	motd = vgui.Create("esFrame");
	motd:SetPos(ScrW()/2-200,ScrH()/2-250);
	motd:SetSize(460,530);
	motd.Title= "Welcome to CasualBananas"--GetHostName();
	motd.showCloseBut = false;
	motd:MakePopup();

	local sl = vgui.Create("esSlideButton",motd);
	sl:SetPos(20,motd:GetTall()-50);
	sl:SetSize(motd:GetWide()-40,30);
	sl.Text = "Drag the car to the other side to close this panel."
	sl.car.OnDone = function()
		if motd and motd:IsValid() then motd:Remove(); hook.Call("ESMotdClosed"); return end
	end

	local p = vgui.Create("esPanel",motd);
	p:SetPos(5,35);
	p:SetSize(motd:GetWide()-10,100);
	p.PaintHook = function(w,h)
		draw.RoundedBox(2,2,2,w-4,20,Color(0,0,0,200));
		draw.SimpleText("Message of the day","ESDefaultBold",w/2,12,Color(255,255,255),1,1);
	end

	local l = Label(exclFormatLine(motdString,"ESDefault",p:GetWide()-20),p)
	l:SetFont("ESDefault");
	l:SetPos(10,30);
	l:SetColor(COLOR_BLACK)
	l:SizeToContents();

	local p = vgui.Create("esPanel",motd);
	p:SetPos(5,35+100+5);
	p:SetSize(motd:GetWide()-10,330);
	p.PaintHook = function(w,h)
		draw.RoundedBox(2,2,2,w-4,20,Color(0,0,0,200));
		draw.SimpleText("Gamemode Rules","ESDefaultBold",w/2,12,Color(255,255,255),1,1);
	end

	local cont = vgui.Create("Panel",p);
	cont:SetPos(0,22);
	cont:SetSize(p:GetWide(),p:GetTall()-22);

	local l = Label(exclFormatLine(rulesString,"ESDefault",p:GetWide()-20),cont)
	l:SetFont("ESDefault");
	l:SetPos(10,5);
	l:SetColor(COLOR_BLACK)
	l:SizeToContents();	

	if l.y + l:GetTall() > cont:GetTall() then
		local scr = cont:Add("esScrollbar");
		scr:SetPos(cont:GetWide()-17,2);
		scr:SetSize(15,cont:GetTall()-4);
		scr:SetUp()
	end
	
end

-- Open this when the client loads.
hook.Add("Initialize","whiowdhwiouwdhiowd",function()
	rulesString = hook.Call("ESGetRules") or rulesString;

	if !system.IsOSX() then

		ES:ToggleMotd()

	end
end)