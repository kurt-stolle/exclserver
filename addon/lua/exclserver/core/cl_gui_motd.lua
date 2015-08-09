-- cl_motd.lua
-- the motd

local context

surface.CreateFont("ESMOTDHead",{
	font=ES.Font,
	size=50,
	weight=400
})

hook.Add("HUDShouldDraw","ES.MOTD.HideHUD",function()
	if IsValid(context) then
		return false
	end
end)

local gradient=Material("exclserver/gradient.png")
ES.motdEnabled = true
function ES.CloseMOTD()
	if IsValid(context) then
		context:Remove()
	end
end
function ES.OpenMOTD()
	ES.CloseMOTD()

	context=vgui.Create("EditablePanel")
	context:SetSize(ScrW(),ScrH())
	context.Paint=function(self,w,h)
		--Derma_DrawBackgroundBlur(self,1,1)
		surface.SetDrawColor(ES.Color["#000000EF"])
		surface.SetMaterial(gradient)
		surface.DrawTexturedRectRotated(w/2,(h/2)+(h/4),w,h/2,180)
		surface.SetDrawColor(ES.Color["#000000AF"])
		surface.DrawRect(0,0,w,h)
	end

	local mid=vgui.Create("Panel",context)
	mid:SetSize(800,ScrH())
	mid:Center()
	mid:DockPadding(0,80,0,80)

	local lbl_welcome=vgui.Create("esLabel",mid)
	lbl_welcome:SetText("Welcome to Casual Bananas!")
	lbl_welcome:SetFont("ESMOTDHead")
	lbl_welcome:SizeToContents()
	lbl_welcome:Dock(TOP);
	lbl_welcome:DockMargin(10,10,10,10)

	local rules=vgui.Create("esFrame",mid)
	rules:SetTitle("MOTD")
	rules:Dock(FILL)
	rules:EnableCloseButton(false)
	rules:DockMargin(10,10,10,10)

		local lbl_rules=vgui.Create("esLabel",rules)
		lbl_rules:SetFont("ESDefault")
		lbl_rules:SetText([[The following are our community rules.
		Please follow them to make everyone's time here as enjoyable as possible.

		1. Do not cheat.
		2. Do not spam.
		3. Do not advertise.
		4. Do not harass other players.
		5. Do not impersonate an admin.

		Please be advised that gamemode rules will always override community rules.
		To view our full set of gamemode rules, please refer to our forums.


		This server is running ExclServer 2.
		You can access the ExclServer menu by pressing ESC.
		From here you can access the shop, player list, and more.


		We have a TeamSpeak 3 server at ts.casualbananas.com.


		To get in touch with the administration team, please refer to our forums.]])
		lbl_rules:SizeToContents()
		lbl_rules:Dock(FILL)
		lbl_rules:DockMargin(15,15,15,15)

	local sidebar=vgui.Create("Panel",mid)
	sidebar:Dock(RIGHT)
	sidebar:SetWide(256)
	sidebar:DockMargin(10,0,10,0)

		local forums=vgui.Create("esFrame",sidebar)
		forums:SetTitle("Forums")
		forums:SetTall(260)
		forums:Dock(TOP)
		forums:EnableCloseButton(false)
		forums:DockMargin(0,10,0,10)

			local hack=vgui.Create("Panel",forums)
			hack:Dock(FILL)
			hack:DockMargin(1,1,1,1)

			local html=vgui.Create("DHTML",hack)
			html:OpenURL("https://community.casualbananas.com/")
			html:Dock(FILL)
			html:DockMargin(0,0,-80,0)
			html:Call("$('body').css({zoom:'70%'})")
			html:SetScrollbars(false)

			local overlay=html:Add("Panel")
			overlay:Dock(FILL)

			overlay.OnMouseReleased=function()
				gui.OpenURL("https://community.casualbananas.com/")
			end

		local bananas=vgui.Create("esFrame",sidebar)
		bananas:SetTitle("Bananas")
		bananas:SetTall(30+50)
		bananas:Dock(TOP)
		bananas:EnableCloseButton(false)
		bananas:DockMargin(0,10,0,10)

			local counter=vgui.Create("esBananaCounter",bananas)
			counter:Dock(FILL)
			counter:DockMargin(15,15,15,15)

		local donate=vgui.Create("esFrame",sidebar)
		donate:SetTitle("Donate")
		donate:SetTall(174)
		donate:Dock(TOP)
		donate:EnableCloseButton(false)
		donate:DockMargin(0,10,0,10)

			local lbl_donate=vgui.Create("esLabel",donate)
			lbl_donate:SetText("For every 1 USD you donate, you will\nreceive 1000 bananas. Awesome!")
			lbl_donate:SetFont("ESDefault")
			lbl_donate:SetColor(ES.Color.White)
			lbl_donate:SizeToContents()
			lbl_donate:Dock(TOP)
			lbl_donate:DockMargin(15,15,15,0)

			local sub=donate:Add("EditablePanel")
			sub:SetTall(20)
			sub:Dock(TOP)
			sub:DockMargin(15,15,15,15)

				local amount_lbl=Label("Enter donation amount: ",sub)
				amount_lbl:SetFont("ESDefaultBold")
				amount_lbl:Dock(LEFT)
				amount_lbl:SetColor(ES.Color.White)
				amount_lbl:SizeToContents()

				local entry=vgui.Create("esTextEntry",sub)
				entry:Dock(LEFT);
				entry:SetWide(40);
				entry:SetNumeric(true)
				entry:SetFont("ESDefaultBold")
				entry:SetValue(5)

				local usd_lbl=Label(" USD",sub)
				usd_lbl:SetFont("ESDefaultBold")
				usd_lbl:Dock(LEFT)
				usd_lbl:SizeToContents()
				usd_lbl:SetColor(ES.Color.White)

			local btn_donate=vgui.Create("esButton",donate)
			btn_donate:SetText("Donate")
			btn_donate:Dock(BOTTOM)
			btn_donate:SetTall(30)
			btn_donate:DockMargin(15,0,15,15)
			btn_donate.OnMouseReleased=function()
				gui.OpenURL("https://es2-api.casualbananas.com/api/donate?amt="..(entry:GetValue() ~= "" and entry:GetValue() or "1").."&sid="..LocalPlayer():SteamID())

				local fill=vgui.Create("esPanel")
				fill:SetSize(ScrW(),ScrH())
				fill:MakePopup()

				local lbl=Label("You are currently making a donation of $"..(entry:GetValue() ~= "" and entry:GetValue() or "1").." to Casual Bananas.",fill)
				lbl:SetFont("ESDefault++")
				lbl:SizeToContents()
				lbl:Center();
				lbl:SetColor(ES.Color.White)
				local btn=fill:Add("esButton")
				btn:SetText("Done")
				btn:SetSize(300,30)
				btn:SetPos(fill:GetWide()/2 - btn:GetWide()/2, lbl.y + lbl:GetTall()+30)
				btn.DoClick=function()
					LocalPlayer():ConCommand("retry;")
				end
			end

	local btn_close=vgui.Create("esButton",mid)
	btn_close:SetText("Enter server")
	btn_close:SetTall(40)
	btn_close:DockMargin(10,10,10,10)
	btn_close:Dock(BOTTOM)
	btn_close.OnMouseReleased=function()
		if IsValid(context) then
			context:Remove()
		end
	end

	context:MakePopup()
end

-- Open this when the client loads.
hook.Add("InitPostEntity","ES.OpenMOTD",function() timer.Simple(0,function() ES.OpenMOTD() end) end)
