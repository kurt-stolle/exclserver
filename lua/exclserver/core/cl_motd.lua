-- cl_motd.lua
-- the motd

local motd


hook.Add("HUDShouldDraw","ES.MOTD.SupressHUD",function()
	if IsValid(motd) then return false end
end)

local fx = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = -.1,
	["$pp_colour_contrast"] = 1.1,
	["$pp_colour_colour"] = 0,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}
hook.Add("RenderScreenspaceEffects","ES.MOTDBlackWhite",function()
	if IsValid(motd) then
		DrawColorModify(fx)
	end
end)
hook.Add("ShouldDrawLocalPlayer","ES.MOTDDrawLocal",function()
	if IsValid(motd) then
		return true
	end
end)
local view = {}
local rot=0
hook.Add("CalcView","ES.MOTDCalcView",function(ply,pos,angles,fov)
	if not view.origin or not view.angles or not IsValid(motd) then
		view.origin=pos
		view.angles=angles
	elseif IsValid(motd) then
		local bone=ply:LookupBone("ValveBiped.Bip01_Spine")

		if bone then

			pos,angles=ply:GetBonePosition(bone)

			if pos and angles then

				rot=(rot + (FrameTime() * 6)) % 360

				angles=ply:GetAngles()
				angles:RotateAroundAxis(angles:Up(),rot)

				local tr=util.TraceLine( {
					start=pos,
					endpos=pos-(angles:Forward()*70),
					filter=ply
				} )

				view.origin = tr.HitPos + angles:Forward()*10
				view.angles = angles
				view.fov = fov

				return view

			end
		end
	end
end)
ES.motdEnabled = true
ES.ServerRules = {
	"Do act friendly towards other players.",
	"Do obey to the administration team's directions.",
	"Do not spam in any way.",
	"Do not cheat."
}

local color_background_faded=Color(0,0,0,150)

local timeOpen=0
local motdPaint=function(self,w,h)
	Derma_DrawBackgroundBlur(self,timeOpen)
end
local navPaint=function(self,w,h)
	surface.SetDrawColor(color_background_faded)
	surface.DrawRect(0,0,w,h)
end
local navPaintButton=function(self,w,h)
	surface.SetDrawColor((self:GetHover() and not self:GetSelected()) and ES.GetColorScheme(3) or Color(150,150,150,1))
	surface.DrawRect(0,1,w-1,h-2)

	if self:GetSelected() then
		surface.SetDrawColor(ES.Color["#1E1E1E"])
		surface.DrawRect(0,0,w,h)
	end

	surface.SetDrawColor(ES.Color.White)
	surface.SetMaterial(self.Icon)
	surface.DrawTexturedRect(w/2-(64/2),0,64,64)

	draw.DrawText(self.title,"ESDefault",w/2,h-22,ES.Color.White,1,1)
end
local navigationOptions={
	{
			title="Rules",
			icon=Material("exclserver/motd/rules.png"),
			fn=function(pnl)
				local y=20

				local text
				text=Label(ES.FormatLine("Below is a list of all rules that apply to this server. Not following any of the rules stated below may result in receiving a punishment or penalty.\n","ESDefault",pnl:GetWide()-40),pnl)
				text:SetPos(20,y)
				text:SetFont("ESDefault")
				text:SizeToContents()

				y=y+text:GetTall()

				for k,v in ipairs(ES.ServerRules)do


					text=Label(ES.FormatLine(k..". "..v,"ESDefault",pnl:GetWide()-40),pnl)
					text:SetPos(20,y)
					text:SetFont("ESDefault")
					text:SizeToContents()

					y=y+text:GetTall()
				end

				local btn_close=pnl:Add("esButton")
				btn_close:SetSize(pnl:GetWide()-40,30)
				btn_close:SetPos(20,pnl:GetTall()-20-30)
				btn_close.Text="Close MOTD"
				btn_close.DoClick=ES.CloseMOTD
			end
	},
	{
			title="About",
			icon=Material("exclserver/motd/info.png"),
			fn=function(pnl)
				local text=Label(ES.FormatLine("This server is running ExclServer. ExclServer is a all-in-one server system that includes a shop, donation system, motd, administration, group management and an elaborate plugin system.\n\nPlayers can use ExclServer by pressing F5. From this menu the player can choose a number of different actions.\n\nItems can be bought with the Bananas currency. Bananas are earned through playing and achieving in-game goals. Completing achievements, listed in the F6 menu, also award Bananas.\n\nExclServer is made by Casual Bananas Software Development.\nPlease report any bugs to info@casualbananas.com.\n\n\n\nCOPYRIGHT (c) 2011-2015 CASUALBANANAS.COM","ESDefault",pnl:GetWide()-40),pnl)
				text:SetPos(20,20)
				text:SetFont("ESDefault")
				text:SizeToContents()
			end
	},
	{
			title="Donate",
			icon=Material("exclserver/motd/donate.png"),
			fn=function(pnl)
				local text=Label(ES.FormatLine("For every $1 you donate, you will get 1000 bananas.\nDonating is the easiest way to earn bananas quickly.\nDon't wait any longer!","ESDefault",pnl:GetWide()-40),pnl)
				text:DockMargin(20,20,20,20)
				text:SetFont("ESDefault")
				text:Dock(TOP)
				text:SizeToContents()

				local sub=pnl:Add("Panel")
				sub:SetTall(20)
				sub:Dock(TOP)
				sub:DockMargin(20,0,40,0)

					local amount_lbl=Label("DONATION AMOUNT (USD):   ",sub)
					amount_lbl:SetFont("ESDefaultBold")
					amount_lbl:Dock(LEFT)
					amount_lbl:SizeToContents()

					local entry=vgui.Create("esTextEntry",sub)
					entry:Dock(FILL);
					entry:SetNumeric(true)
					entry:SetFont("ESDefaultBold")
					entry:SetValue(5)

				local btn_donate=vgui.Create("esButton",pnl)
				btn_donate:SetText("Donate")
				btn_donate:Dock(TOP)
				btn_donate:SetTall(30)
				btn_donate:DockMargin(20,40,20,20)
				btn_donate.OnMouseReleased=function()
					gui.OpenURL("https://es2-api.casualbananas.com/donate?amt="..(entry:GetValue() ~= "" and entry:GetValue() or "1").."&sid="..LocalPlayer():SteamID())

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
			end
	},

}


local w=560
local h=600
function ES.CloseMOTD()
	if IsValid(motd) then
		motd:Remove()
	end
end
function ES.OpenMOTD()
	ES.CloseMOTD()

	timeOpen=SysTime()

	motd=vgui.Create("EditablePanel")
	motd:SetSize(ScrW(),ScrH())
	motd:SetPos(0,0)
	motd.Paint=motdPaint

		local master=motd:Add("esFrame")
		master:SetSize(w,h)
		--[[master:SetPos(ScrW(),(ScrH()/2)-(h/2))
		master.title="Welcome"
		master.xDesired=(ScrW()/2)-(w/2)
		master:PerformLayout()]]
		master.title="Welcome"
		master:Center()

		local oldRemove=master.Remove
		function master:Remove()
			oldRemove(self)
			motd:Remove()
		end

		local frame=master:Add("Panel")
		frame:SetSize(w-2,h-31)
		frame:SetPos(1,30)


		local context=frame:Add("Panel")
		local navigation=frame:Add("Panel")


		navigation:SetPos(0,0)
		navigation:SetSize(74,frame:GetTall())
		navigation.Paint=navPaint

			local i=0
			for k,v in ipairs(navigationOptions)do
				local btn=navigation:Add("Panel")
				btn:SetSize(74,74)
				btn:SetPos(0,i*74)
				btn.title=v.title
				btn.Icon=v.icon
				btn.Paint = navPaintButton
				btn.OnMouseReleased=function(self)
					for k,v in pairs(context:GetChildren())do
						if IsValid(v) then
							v:Remove()
						end
					end

					v.fn(context)

					for k,v in ipairs(navigationOptions)do
						if IsValid(v._Panel) then
							v._Panel:SetSelected(false)
						end
					end

					self:SetSelected(true)
				end

				ES.UIAddHoverListener(btn)
				AccessorFunc(btn,"selected","Selected",FORCE_BOOL)

				if k == 1 then
					btn:SetSelected(true)
				end

				v._Panel=btn

				i=i+1
			end


		context:SetSize(frame:GetWide()-navigation:GetWide(),frame:GetTall())
		context:SetPos(navigation.x+navigation:GetWide(),0)

		navigationOptions[1]._Panel:OnMouseReleased()

	motd:MakePopup()
end

-- Open this when the client loads.
hook.Add("InitPostEntity","ES.OpenMOTD",ES.OpenMOTD)
