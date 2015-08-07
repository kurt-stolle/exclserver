-- the new main
local mm
hook.Add("HUDShouldDraw","ES.MM.SupressHUD",function()
	if IsValid(mm) then return false end
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
hook.Add("RenderScreenspaceEffects","ES.MMBlackWhite",function()
	if IsValid(mm) then
		fx["$pp_colour_colour"]=Lerp(FrameTime()*8,fx["$pp_colour_colour"],.1)
		DrawColorModify(fx)
	else
		fx["$pp_colour_colour"]=1
	end
end)
hook.Add("ShouldDrawLocalPlayer","es.ShouldDrawLocalPlayer.mainmenu",function()
	if IsValid(mm) then
		return true
	end
end)
local view = {}
local rot=0
hook.Add("CalcView","ES.MMCalcView",function(ply,pos,angles,fov)
	if not view.origin or not view.angles or not IsValid(mm) then
		view.origin=pos
		view.angles=angles
	elseif IsValid(mm) then
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

				view.origin = LerpVector(FrameTime(),view.origin,tr.HitPos + angles:Forward()*10)
				view.angles = LerpAngle(FrameTime(),view.angles,angles)
				view.fov = fov

				return view

			end
		end
	end
end)

ES.CreateFont("ES.MainMenu.HeadingText",{
	font = ES.Font,
	size = 28,
})

local function addCheckbox(help,txt,convar,oncheck)
	local ply = LocalPlayer()

	local togOwn = vgui.Create("esToggleButton",help)
	togOwn:DockMargin(10,10,10,0)
	togOwn:Dock(TOP)
	togOwn.Text = txt
	togOwn.DoClick = function(self)
		if self:GetChecked() then
			ply:ConCommand(convar.." 1")
			oncheck(togOwn)
		else
			ply:ConCommand(convar.." 0")
			oncheck(togOwn)
		end
	end

	togOwn:SetChecked(GetConVarNumber(convar) == 1)
end

function ES.CloseMainMenu()
	if IsValid(mm) then mm:Remove() end
end

function ES.CreateMainMenu()
	if IsValid(mm) then mm:Remove() return end

	local ply = LocalPlayer()

	mm = vgui.Create("ESMainMenu")
	mm:SetPos(0,0)
	mm:SetSize(ScrW(),ScrH())
	mm:MakePopup()

	--### main items
	mm:AddButton("General",Material("icon16/car.png"),function()
		mm:OpenChoisePanel({
			{icon = Material("exclserver/menuicons/generic.png"), name = "About",func = function()
				local p = mm:OpenFrame(640)
				p:SetTitle("About")
				local l = Label(ES.FormatLine([[ExclServer is an all-in-one server system that handles items, forums, administration and has a plugin framework. The global currency used to buy items is Bananas. You can earn these bananas simply by playing, or you can purchase then on the forum.

Bananas can be spent in the shop menu (accessable from this screen). If you are not familar with ExclServer the best way to get to know it is to simply explore these menus, we would suggest you to click the 'My account' tab and make a forum account or link your existing account. Doing so will give you 500 bananas. Bananas are shared across all our servers (including the forums). This means that bananas earned on one server are automatically transferred to all other servers.

ExclServer is created and constructed by Excl.]],"ESDefault+",640-20*2),p)
				l:SetColor(Color(255,255,255,200))
				l:SetFont("ESDefault+")
				l:SetPos(20,20)
				l:SizeToContents()
			end},
			{icon = Material("exclserver/menuicons/generic.png"), name = "Settings",func = function()
				local p = mm:OpenFrame(300)
				p:SetTitle("Settings")

				addCheckbox(p,"Disable trails","excl_trails_disable",function()
					timer.Simple(.5,function()
						RunConsoleCommand( "excl_trails_reload")
					end)
				end)
				addCheckbox(p,"Bind ExclServer to F5","excl_bind_to_f5",function() end)
			end},
			{icon = Material("exclserver/menuicons/generic.png"), name = "Colors",func = function()
				local p = mm:OpenFrame(10+256+10+256+10)
				p:SetTitle("Colors")

				local firstCube = p:Add("DColorMixer")
				local secondCube = p:Add("DColorMixer")
				local thirdCube = p:Add("DColorMixer")

				local ignore=true

				firstCube:SetPos(10,10)
				firstCube:SetSize(256,200)
				firstCube:SetLabel("Primary Color")
				firstCube.label:SetFont("ESDefaultBold")
				firstCube.label:SetColor(ES.Color.White)
				firstCube:SetColor(ES.GetColorScheme(1))
				function firstCube:ValueChanged()
					if ignore then return end

					ES.PushColorScheme(firstCube:GetColor(),secondCube:GetColor(),thirdCube:GetColor())
					ES.SaveColorScheme()
				end


				secondCube:SetPos(10,firstCube.y+firstCube:GetTall()+10)
				secondCube:SetSize(256,200)
				secondCube:SetLabel("Secondary Color")
				secondCube.label:SetFont("ESDefaultBold")
				secondCube.label:SetColor(ES.Color.White)
				secondCube:SetColor(ES.GetColorScheme(2))
				function secondCube:ValueChanged()
					if ignore then return end

					ES.PushColorScheme(firstCube:GetColor(),secondCube:GetColor(),thirdCube:GetColor())
					ES.SaveColorScheme()
				end

				thirdCube:SetPos(10+256+10,10)
				thirdCube:SetSize(256,200)
				thirdCube:SetLabel("Third Color")
				thirdCube.label:SetFont("ESDefaultBold")
				thirdCube.label:SetColor(ES.Color.White)
				thirdCube:SetColor(ES.GetColorScheme(3))
				function thirdCube:ValueChanged()
					if ignore then return end

					ES.PushColorScheme(firstCube:GetColor(),secondCube:GetColor(),thirdCube:GetColor())
					ES.SaveColorScheme()
				end

				local b = vgui.Create("esButton",p)
				b:SetSize(p:GetWide()-10*2,30)
				b:SetPos(10,p:GetTall()-30-10)
				b:SetText("Reset")
				b.DoClick = function()
					ES.PushColorScheme()

					local f,s,t = ES.GetColorScheme()

					ignore=true

					timer.Simple(0,function()
						firstCube:SetColor(f)
						timer.Simple(0,function()
							secondCube:SetColor(s)
							timer.Simple(0,function()
								thirdCube:SetColor(t)
								ES.SaveColorScheme()
								ignore=false
							end)
						end)
					end)

					ES.NotifyPopup("Success","The ExclServer color scheme has been reset.")
				end

				ignore=false

			end},
		})
	end)
	mm:AddButton("System",Material("icon16/shield.png"),function()
		mm:CloseChoisePanel()

		mm:OpenChoisePanel({
			{icon = Material("exclserver/menuicons/generic.png"), name = "Commands",func = function()
				ES._MMGenerateCommands(mm)
			end},
			{icon = Material("exclserver/menuicons/generic.png"), name = "Config",func = function()
				ES._MMGenerateConfiguration(mm)
			end},
			{icon = Material("exclserver/menuicons/generic.png"), name = "Plugins",func = function()
				ES._MMGeneratePlugins(mm)
			end},
		})
	end)
	mm:AddWhitespace()
	mm:AddButton("Shop",Material("icon16/basket.png"),function()
		mm:OpenChoisePanel({
			{icon = Material("exclserver/menuicons/generic.png"), name = "Items",func = function()
				ES._MMGenerateShop(mm,"Prop",ES.ITEM_PROP)
			end},
			{icon = Material("exclserver/menuicons/generic.png"), name = "Trails",func = function()
				ES._MMGenerateShop(mm,"Trail",ES.ITEM_TRAIL)
			end},
			{icon = Material("exclserver/menuicons/generic.png"), name = "Melee",func = function()
				ES._MMGenerateShop(mm,"Melee",ES.ITEM_MELEE)
			end},
			{icon = Material("exclserver/menuicons/generic.png"), name = "Models",func = function()
				ES._MMGenerateShop(mm,"Model",ES.ITEM_MODEL)
			end},
			{icon = Material("exclserver/menuicons/generic.png"), name = "Auras",func = function()
				ES._MMGenerateShop(mm,"Aura",ES.ITEM_AURA)
			end}
		})
	end)
	mm:AddButton("Inventory",Material("icon16/plugin.png"),function()
		mm:OpenChoisePanel({
			{icon = Material("exclserver/menuicons/generic.png"), name = "Effects",func = function()
				ES._MMGenerateInventoryEffects(mm)
			end},
			{icon = Material("exclserver/menuicons/generic.png"), name = "Outfit",func = function()

				ES._MMGenerateInventoryOutfit(mm)

			end},
		})
	end)
	mm:AddButton("VIP",Material("icon16/star.png"),function()
		mm:CloseChoisePanel()
		local p = mm:OpenFrame(700)
		p:SetTitle("VIP")
		local lblVIPHelp = Label("Information",p)
		lblVIPHelp:SetFont("ES.MainMenu.HeadingText")
		lblVIPHelp:SetColor(ES.Color.White)
		lblVIPHelp:Dock(TOP)
		lblVIPHelp:DockMargin(15,15,15,0)
		lblVIPHelp:SizeToContents()
		local lblVIPInfo = Label([[Becoming VIP is a way to both support the server you are currently playing on, and get
			yourself access to features that are not accessible by non-VIP players.]],p)
		lblVIPInfo:SetFont("ESDefault+")
		lblVIPInfo:SizeToContents()
		lblVIPInfo:Dock(TOP)
		lblVIPInfo:DockMargin(15,15,15,0)
		lblVIPInfo:SetColor(Color(255,255,255,200))
		local lblVIPHelp = Label("Benefits",p)
		lblVIPHelp:SetFont("ES.MainMenu.HeadingText")
		lblVIPHelp:SetColor(ES.Color.White)
		lblVIPHelp:Dock(TOP)
		lblVIPHelp:DockMargin(15,15,15,0)
		lblVIPHelp:SizeToContents()
		local lblVIPInfo = Label([[The table below outlines most of the benefits that upgrading your VIP rank will give.
Press the button below the column to purchase the VIP tier.
If you purchase a tier below Carebear, all tiers above said tier will decrease in price.]],p)
		lblVIPInfo:SetFont("ESDefault+")
		lblVIPInfo:SizeToContents()
		lblVIPInfo:Dock(TOP)
		lblVIPInfo:DockMargin(15,15,15,15)
		lblVIPInfo:SetColor(Color(255,255,255,200))

		local curtier = ply:ESGetVIPTier()
		local tbl = vgui.Create("ES.MMVIPTable",p)
		tbl:Dock(TOP)
		tbl:DockMargin(15,15,15,15)
		tbl:SetTall(260)
		tbl:SetRows(5,8)
		tbl.headColors[2] = Color(152,101,0)
		tbl.headColors[3] = Color(180,180,180)
		tbl.headColors[4] = Color(245,184,0)
		tbl.headColors[5] = Color(201,53,71)
		tbl.itemPrice[2] = (1 - curtier) * 5000

		if tbl.itemPrice[2] < 0 then tbl.itemPrice[2] = 0 end
		tbl.itemPrice[3] = (2 - curtier) * 5000
		if tbl.itemPrice[3] < 0 then tbl.itemPrice[3] = 0 end
		tbl.itemPrice[4] = (3 - curtier) * 5000
		if tbl.itemPrice[4] < 0 then tbl.itemPrice[4] = 0 end
		tbl.itemPrice[5] = (4 - curtier) * 5000
		if tbl.itemPrice[5] < 0 then tbl.itemPrice[5] = 0 end

		tbl.rows[2][1] = "Bronze"
		tbl.rows[3][1] = "Silver"
		tbl.rows[4][1] = "Gold"
		tbl.rows[5][1] = "Carebear"

		tbl.rows[1][2] = "Joke access"
		tbl.rows[2][2] = true
		tbl.rows[3][2] = true
		tbl.rows[4][2] = true
		tbl.rows[5][2] = true
		tbl.rows[1][3] = "VIP items"
		tbl.rows[2][3] = true
		tbl.rows[3][3] = true
		tbl.rows[4][3] = true
		tbl.rows[5][3] = true
		tbl.rows[1][4] = "Long trail"
		tbl.rows[3][4] = true
		tbl.rows[4][4] = true
		tbl.rows[5][4] = true
		tbl.rows[1][5] = "Thirdperson"
		tbl.rows[4][5] = true
		tbl.rows[5][5] = true
		tbl.rows[1][6] = "Player models"
		tbl.rows[4][6] = true
		tbl.rows[5][6] = true
		tbl.rows[1][7] = "Hat particles"
		tbl.rows[5][7] = true
		tbl.rows[1][8] = "Large trail"
		tbl.rows[2][8] = false
		tbl.rows[3][8] = false
		tbl.rows[4][8] = false
		tbl.rows[5][8] = true

		tbl.buttons[2].DoClick = (function()
			if ply:ESGetVIPTier() >= 1 then return end

			net.Start("ES.BuyVIP")
				net.WriteUInt(1,4)
			net.SendToServer()

			p:GetParent():Remove()
		end)
		tbl.buttons[3].DoClick = (function()
			if ply:ESGetVIPTier() >= 2 then return end

			net.Start("ES.BuyVIP")
				net.WriteUInt(2,4)
			net.SendToServer()

			p:GetParent():Remove()
		end)
		tbl.buttons[4].DoClick = (function()
			if ply:ESGetVIPTier() >= 3 then return end

			net.Start("ES.BuyVIP")
				net.WriteUInt(3,4)
			net.SendToServer()

			p:GetParent():Remove()
		end)
		tbl.buttons[5].DoClick = (function()
			if ply:ESGetVIPTier() >= 4 then return end

			net.Start("ES.BuyVIP")
				net.WriteUInt(4,4)
			net.SendToServer()

			p:GetParent():Remove()
		end)
	end)
	mm:AddWhitespace()
	mm:AddButton("Achievements",Material("icon16/rosette.png"),function()
		mm:CloseChoisePanel()
		local p = mm:OpenFrame(500)
		p:SetTitle("Achievements")

		local context = p:Add("Panel")
		context:SetSize(p:GetWide()-30,p:GetTall()-30);
		context:SetPos(15,15);
		local y = 0
		for k,v in pairs(ES.Achievements)do
			local ach = context:Add("esPanel")
			ach:SetPos(0,y)
			ach:SetSize(context:GetWide()-15-2,110)
			ach:SetColor(ES.GetColorScheme(3))

			local ic = ach:Add("DImage")
			ic:SetMaterial(v.icon)
			ic:SetSize(64,64)
			ic:SetPos(8,8)

			local lb2 = Label(v.name,ach)
			lb2:SetFont("ESAchievementFontBig")
			lb2:SetPos(72+6,10)
			lb2:SizeToContents()
			lb2:SetColor(COLOR_WHITE)

			local lbl = Label(v.hidden and not ply:ESHasCompletedAchievement(k) and "<secret>" or ES.FormatLine(v.descr,"ESDefault",ach:GetWide() - 80 - 4 - 4) or "Unknown",ach)
			lbl:SetFont("ESDefault+")
			lbl:SizeToContents()
			lbl:SetPos(lb2.x+2,lb2.y + lb2:GetTall()+3)
			lbl:SetColor(COLOR_WHITE)

			local dr = vgui.Create("Panel",ach)
			dr:Dock(BOTTOM)
			dr:SetTall(28)
			local a = ES.GetColorScheme()
			dr.Paint = function(self,w,h)
				draw.RoundedBox(2,0,0,w,h,ES.Color["#0000008F"])

				if (ply._es_achievements and ply._es_achievements[v.id] or 0) > 0 then
					draw.RoundedBox(2,0,0,(w)*((ply._es_achievements and ply._es_achievements[v.id] or 0)/ES.Achievements[v.id].progressNeeded),h,a)
				end
				draw.SimpleText((ply._es_achievements and ply._es_achievements[v.id] or 0).." / "..ES.Achievements[v.id].progressNeeded,"ESDefaultBold.Shadow",w/2,h/2,COLOR_BLACK,1,1)
				draw.SimpleText((ply._es_achievements and ply._es_achievements[v.id] or 0).." / "..ES.Achievements[v.id].progressNeeded,"ESDefaultBold",w/2,h/2,COLOR_WHITE,1,1)
			end

			y = y + ach:GetTall() + 15
		end

		local scr = context:Add("esScrollbar")
		scr:SetTall(context:GetTall()-8);
		scr:Setup()
	end)
	mm:AddButton("Server list",Material("icon16/server.png"),function()
		ES._MMGenerateServerList(mm)
	end)
	mm:AddButton("Player list",Material("icon16/user.png"),function()
		mm:CloseChoisePanel()
		local p = mm:OpenFrame(320+320+5+15+15)
		p:SetTitle("Players")

		local context = p:Add("EditablePanel")
		context:SetSize(p:GetWide()-30,p:GetTall()-60)
		context:SetPos(15,15)

		local max = math.floor(context:GetTall()/57)
		local page = 0
		local tickskip = 0
		local oldAll
		function context:Think()
			if not self.rows then
				self.rows = {}
			end

				for k,v in pairs(player.GetAll())do
					if not v.esMMPlayerRow or not IsValid(v.esMMPlayerRow) then
						v.esMMPlayerRow = vgui.Create("esMMPlayerRow",self)
						v.esMMPlayerRow:Setup(v)
						v.esMMPlayerRow:PerformLayout()
						v.esMMPlayerRow:SetSize(320,52)
						v.esMMPlayerRow:SetPos(0,0)
						table.insert(self.rows,v.esMMPlayerRow)
					end
				end
				local colomn = 0
				local row = 0
				local skip = 0

				for k,v in pairs(self.rows)do
					if not v or not k or not IsValid(v) then continue end

					if IsValid(v) and IsValid(v.Player) and colomn <= 1 and skip >= (page * max * 2) then
						v:SetVisible(true)
						v:SetPos(5 + 325*colomn,(row)*(57))
						row = row + 1
						if row >= max then
							row = 0
							colomn = colomn + 1
						end
					elseif IsValid(v) and not IsValid(v.Player) then
						v:Remove()
					elseif IsValid(v) then
						v:SetVisible(false)
						skip = skip + 1
					end
				end

		end
		local butPrev = vgui.Create("esIconButton",p)
		butPrev:SetIcon(Material("exclserver/mmarrowicon.png"))
		butPrev:SetSize(32,32)
		butPrev:SetPos(20,p:GetTall()-32-15)
		butPrev.DoClick = function(self)
			page = page - 1
			if page < 0 then page = 0 end
		end
		butPrev.Paint = function(self,w,h)
			if not self.Mat then return end

			surface.SetMaterial(self.Mat)
			surface.SetDrawColor(COLOR_WHITE)
			surface.DrawTexturedRectRotated(w/2,w/2,w,w,180)
		end

		local butNext = vgui.Create("esIconButton",p)
		butNext:SetIcon(Material("exclserver/mmarrowicon.png"))
		butNext:SetSize(32,32)
		butNext:SetPos(butPrev.x + butPrev:GetWide() + 32/2,butPrev.y)
		butNext.DoClick = function(self)
			page = (page + 1)
			if page+1 >  math.ceil( #player.GetAll() / (max*2) ) then
				page =  math.ceil( #player.GetAll() / (max*2) )-1
			end
		end
		butNext.Paint = function(self,w,h)
			if not self.Mat then return end

			surface.SetMaterial(self.Mat)
			surface.SetDrawColor(COLOR_WHITE)
			surface.DrawTexturedRectRotated(w/2,w/2,w,w,0)
		end

		local lblPg = Label("Page 1/1",p)
		lblPg:SetFont("ESDefaultBold")
		lblPg:SetPos(butNext.x + butNext:GetWide() +32/2, butNext.y+1)
		lblPg:SetColor(COLOR_WHITE)
		lblPg:SizeToContents()
		lblPg.Think = function(self)
			self:SetText("Page "..tostring(page+1).."/".. math.ceil( #player.GetAll() / (max*2) ) )
			self:SizeToContents()
		end


		local lblPl = Label("0 active players",p)
		lblPl:SetFont("ESDefaultBold")
		lblPl:SetPos(lblPg.x, lblPg.y + lblPg:GetTall() + 1)
		lblPl:SetColor(COLOR_WHITE)
		lblPl:SizeToContents()
		lblPl.Think = function(self)
			self:SetText(#player.GetAll().." active players")
			self:SizeToContents()
		end
	end)
	mm:AddButton("Website",Material("icon16/world.png"),function()
		mm:CloseChoisePanel()
		local p = mm:OpenFrame()
		p:SetTitle("Website")

		local lbl = Label("Loading...",p)
		lbl:SetFont("ESDefaultBold")
		lbl:SizeToContents()
		lbl:Center()
		lbl:SetColor(COLOR_WHITE)

		local web = vgui.Create("HTML",p)
		web:SetSize(p:GetWide()-2,p:GetTall()-1)
		web:SetPos(1,0)
		web:OpenURL("http://casualbananas.com/")
	end)

	return mm
end

net.Receive("ESToggleMenu",function() ES.CreateMainMenu() end)

local was_pressed = false
hook.Add("Think","exclMMOpenWithF5",function()
	if input.IsKeyDown(KEY_F5) and not was_pressed then
		was_pressed = true
		ES.CreateMainMenu()
	elseif not input.IsKeyDown(KEY_F5) then
		was_pressed = false
	end
end)

hook.Add("PlayerBindPress","exclMMSupressJPeg",function(ply, bind, pressed)
	if string.find(bind,"jpeg",0,false) and input.IsKeyDown(KEY_F5) then
		return true
	end
end)
