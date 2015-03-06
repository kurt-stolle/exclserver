
local colMainElementBg = Color(30,30,30)
local colTransBlack = Color(0,0,0,200)
local colElementMainFoot = Color(213,213,213)
local colElementChoise = Color(30,30,30)

ES.CreateFont("ES.MainMenu.MainElementHeader",{
	font = "Roboto",
	weight = 400,
	size = 48,
})
ES.CreateFont("ES.MainMenu.MainElementInfoBnns",{
	font = "Roboto",
	weight = 400,
	size = 38
})
ES.CreateFont("ES.MainMenu.MainElementInfoBnnsSmall",{
	font = "Roboto",
	weight = 400,
	size = 17,
	italic=true
})
ES.CreateFont("ES.MainMenu.ChoiseElement",{
	font = "Roboto",
	weight = 400,
	size = 14,
})
ES.CreateFont("ES.MainMenu.ChoiseElementSub",{
	font = "Roboto",
	weight = 400,
	size = 12,
})

local PNL = {}
function PNL:Init()
	self.TimeCreate = SysTime()

	self.LogoMat = Material("exclserver/logo.png")

	-- main element
	self.rm = vgui.Create("esIconButton",self)
	self.rm:SetIcon(Material("exclserver/mmarrowicon.png"))
	self.rm:SetSize(32,50)
	self.rm.DoClick = function(self)
		if IsValid(self:GetParent()) then self:GetParent():Remove() end
	end
	self.rm.Paint = function(self,w,h)
		if not self.Mat then return end

		surface.SetMaterial(self.Mat)
		surface.SetDrawColor(ES.Color.White)
		surface.DrawTexturedRectRotated(w/2,w/2,w,w,180)

		draw.SimpleText("Close","ESDefault",w/2,h-14,Color(255,255,255),1)
	end

	self.ElementMainX = -256
	self.ElementMainButtons = {}
	self.yCreateMainButtons = 110

	-- choise panel
	self.ElementChoiseX = 0 -- this is relative!
	self.ElementChoiseEnabled = false
	self.ElementChoiseElements = {}
	self.ElementChoiseDummies = {}

	-- frames
	self.ActiveFrame = false
end
function PNL:OpenFrame(w,h)
	if self.ActiveFrame and IsValid(self.ActiveFrame) then self.ActiveFrame:Remove() end

	self.ActiveFrame = self:Add("ES.MainMenu.Frame")
	local width_max = (self:GetWide()-(256+10+64+10+10))
	if not w or w > width_max then
		w = width_max
	end

	self.ActiveFrame:SetSize(w,h and h+70 or (self:GetTall()-20))
	self.ActiveFrame.y = 10
	self.ActiveFrame.x = self:GetWide()
	self.ActiveFrame.xDesired = self:GetWide()-w-10
	self.ActiveFrame:PerformLayout()
	return self.ActiveFrame.context
end
function PNL:CloseChoisePanel()
	for k,v in pairs(self.ElementChoiseDummies)do
		if IsValid(v) then v:Remove() end
	end
	self.ElementChoiseEnabled = false
end
function PNL:OpenChoisePanel(tblOptions)
	for k,v in pairs(self.ElementChoiseDummies)do
		if IsValid(v) then v:Remove() end
	end

	surface.PlaySound("common/wpn_moveselect.wav")

	self.ElementChoiseX = -32*3 -- we want just the last part of the smoothing
	self.ElementChoiseEnabled = true
	self.ElementChoiseElements = tblOptions

	for k,v in pairs(tblOptions)do
		local b = self:Add("Panel")
		b:SetSize(64,64)
		b:SetPos(255+8,80+2+((k-1)*(64+8)))
		b.OnMouseReleased = v.func
		b.OnCursorEntered = function() v.Hover = true end
		b.OnCursorExited = function() v.Hover = false end

		table.insert(self.ElementChoiseDummies,b)
	end
end
function PNL:AddButton(name,icon,func)
	local b = vgui.Create("ES.MainMenu.NavigationItem",self)
	b:SetSize(256,32)
	b:SetPos(self.ElementMainX,self.yCreateMainButtons)
	b.title = name
	b.icon = icon
	b.OnMouseReleased = func

	table.insert(self.ElementMainButtons,b)

	self.yCreateMainButtons = self.yCreateMainButtons+32
end
function PNL:AddWhitespace()
	self.yCreateMainButtons = self.yCreateMainButtons+30
end
function PNL:Think()
	if self.ElementMainX < -.5 then
		self.ElementMainX = Lerp(5 * FrameTime(),self.ElementMainX,0)
		for k,v in pairs(self.ElementMainButtons)do
			if IsValid(v) then v:SetPos(self.ElementMainX,v.y) end
		end
		self.rm:SetPos(self.ElementMainX + 256 + 16,16)
	elseif self.ElementMainX ~= 0 then
		self.ElementMainX = 0
		self.rm:SetPos(self.ElementMainX + 256 + 16,16)
	end

end
local color_choice_bg=Color(35,35,35)
local color_choice_border=Color(255,255,255,5)
function PNL:Paint(w,h)
	local p = LocalPlayer()
	local scrW,scrH = ScrW(),ScrH()

	--[[surface.SetDrawColor(colTransBlack)
	surface.DrawRect(0,0,w,h)]]
	Derma_DrawBackgroundBlur(self,self.TimeCreate)

	-- THE CHOISE ELEMENT

	if self.ElementChoiseEnabled then
		render.PushFilterMag( TEXFILTER.ANISOTROPIC )
		render.PushFilterMin( TEXFILTER.ANISOTROPIC )

		local x,y

		for k,v in pairs(self.ElementChoiseElements)do
			if not v.wait then
				v.wait = CurTime()+(k-1)*.1
			end

			if CurTime() < v.wait then continue end

			x=self.ElementMainX+256+8
			y=80+((k-1)*(64+8))
			render.SetViewPort( x,y,64,64 )
			cam.Start2D()

			if not v.scale then v.scale=0 end

			v.Matrix=Matrix()
			v.Matrix:SetTranslation(Vector(32-v.scale*32,32-v.scale*32,0))
			v.Matrix:Scale( Vector(v.scale,v.scale,0) )

			v.scale=Lerp(FrameTime()*10,v.scale,1)

			cam.PushModelMatrix( v.Matrix )
				local w,h = ScrW(),ScrH()

				surface.SetDrawColor(ES.Color.Black)
				surface.DrawRect(0,0,w,h)
				if v.Hover then
					surface.SetDrawColor(ES.GetColorScheme(3))
				else
					surface.SetDrawColor(ES.Color["#1E1E1E"])
				end
				surface.DrawRect(1,1,w-2,h-2)
				surface.SetDrawColor(ES.Color["#FFFFFF03"])
				surface.DrawRect(1,1,w-2,1)
				surface.DrawRect(1,h-2,w-2,1)
				surface.DrawRect(1,2,1,h-4)
				surface.DrawRect(w-2,2,1,h-4)

				surface.SetMaterial(v.icon)

				surface.SetDrawColor(ES.Color.Black)
				surface.DrawTexturedRectRotated(32,25,32,32,0)

				surface.SetDrawColor(ES.Color.White)
				surface.DrawTexturedRectRotated(32,24,32,32,0)

				draw.SimpleText(v.name,"ES.MainMenu.ChoiseElementSub",w/2	,h-14+1,ES.Color.Black,1,1)
				draw.SimpleText(v.name,"ES.MainMenu.ChoiseElementSub",w/2	,h-14,ES.Color.White,1,1)

			cam.PopModelMatrix()

			cam.End2D()
			render.SetViewPort( 0, 0, scrW,scrH )
		end
		render.PopFilterMin()
		render.PopFilterMag()
	end

	-- THE MAIN ELEMENT
	surface.SetDrawColor(colMainElementBg)
	surface.DrawRect(self.ElementMainX,0,256,h)

	surface.SetDrawColor(ES.GetColorScheme(1))
	surface.DrawRect(self.ElementMainX,0,256,80)

	surface.SetDrawColor(ES.Color["#000000FF"])
	surface.DrawRect(self.ElementMainX,79,256,1)
	surface.SetDrawColor(ES.Color["#FFFFFF03"])
	surface.DrawRect(self.ElementMainX,80,256,1)

	surface.SetDrawColor(ES.Color["#000"])
	surface.DrawRect(self.ElementMainX+256,0,1,h)
	surface.SetDrawColor(ES.Color["#FFFFFF03"])
	surface.DrawRect(self.ElementMainX+255,0,1,h)

	---draw.SimpleText("ExclServer","ES.MainMenu.MainElementHeader",self.ElementMainX+10,24,ES.Color.White)

	surface.SetMaterial(self.LogoMat)
	surface.SetDrawColor(ES.Color.White)
	surface.DrawTexturedRect(self.ElementMainX,80-64,256,64)

	--display bananas
	--[[surface.SetDrawColor(ES.Color["#00000077"])
	surface.DrawRect(self.ElementMainX,h-10-60,256,60)

	surface.SetDrawColor(ES.Color["#FFFFFF02"])
	surface.DrawRect(self.ElementMainX,h-10-60,256,1)
	surface.DrawRect(self.ElementMainX,h-10,256,1)]]

	draw.SimpleText("Bananas","ES.MainMenu.MainElementInfoBnnsSmall",self.ElementMainX+10,h-10-60+4,ES.Color.White)
	if not (IsValid(p) or not p:ESGetNetworkedVariable("bananas",false) ) then
		draw.SimpleText("Loading...","ES.MainMenu.MainElementInfoBnns",self.ElementMainX+10,h-10-60+18,ES.Color.White)
	else
		if not didLoad then
			bananaDisplay = p:ESGetBananas()
			didLoad = true
		end
		local bananaDisplayRound = math.Round(bananaDisplay)
			if bananaDisplayRound ~= p:ESGetBananas() then
			if bananaDisplay - p:ESGetBananas() > 0 then
				bananaDisplay = Lerp(FrameTime(),bananaDisplay-1,p:ESGetBananas())
			else
				bananaDisplay = Lerp(FrameTime(),bananaDisplay+1,p:ESGetBananas())
			end
		else
			bananaDisplay = bananaDisplayRound
		end
		draw.SimpleText(tostring(bananaDisplayRound),"ES.MainMenu.MainElementInfoBnns",self.ElementMainX+10,h-10-60+18,ES.Color.White)
	end
end
vgui.Register("ESMainMenu",PNL,"EditablePanel")

--### MAIN ELEMENT BUTTON

ES.CreateFont("ES.MainMenu.MainElementButtonShad",{
	font = "Roboto",
	size = 14,
	weight = 700,
	blursize=2,
})
ES.CreateFont("ES.MainMenu.MainElementButton",{
	font = "Roboto",
	size = 14,
	weight = 700,
})
local PNL = {}
function PNL:Init()
	self.bg = Material("exclserver/mmmainitem.png")
	self.icon = Material("icon16/car.png")
	self.title = "Undefined"
	self.Hover = false
	self.rot = 0
	self.tick = 0

	ES.UIInitRippleEffect(self)
end
function PNL:OnMousePressed()
	ES.UIMakeRippleEffect(self)
end
function PNL:OnCursorEntered()
	self.Hover = true
end
function PNL:OnCursorExited()
	self.Hover = false
end
function PNL:Paint(w,h)
	if not self.bg then return end

	if self.Hover then
		surface.SetDrawColor(ES.GetColorScheme(2))
	else
		surface.SetDrawColor(ES.Color["#DDD"])
	end
	surface.SetMaterial(self.bg)
	surface.DrawTexturedRect(0,0,w,h)

	surface.SetDrawColor(Color(0,0,0,100))
	surface.DrawRect(0,0,w,1)

	surface.SetDrawColor(ES.Color.White)
	surface.SetMaterial(self.icon)

	surface.DrawTexturedRectRotated(10+h/2,h/2,16,16,0)

	ES.UIDrawRippleEffect(self,w,h)

	local col = ES.Color["#444"]
	if self.Hover then
		col = ES.Color.White
	end
	draw.SimpleText(self.title,"ES.MainMenu.MainElementButton",42 + 10,h/2,col,0,1)
end
vgui.Register("ES.MainMenu.NavigationItem",PNL,"Panel")


ES.CreateFont("ES.MainMenu.FrameHead",{
	font = "Roboto",
	size = 48,
	weight = 500
})
local PNL = {}
function PNL:Init()
	--surface.PlaySound("ambient/levels/canals/drip3.wav")

	self.context = self:Add("Panel")
	self.context.SetTitle = function(self,title) self:GetParent().title = title end
	self.title = "Undefined Panel"
	self.xDesired = 0
end
function PNL:PerformLayout()
	local w=self:GetWide()
	local h=self:GetTall()

	self.context:SetSize(w-2,h-72)
	self.context:SetPos(1,71)
end
function PNL:Think(w,h)
	if not self.x or self.x <= self.xDesired then return end

	self.x = Lerp(FrameTime() *7,self.x,self.xDesired)

	if self.x <= self.xDesired + .00001 then
		self.x = self.xDesired
		if type(self.context.OnReady) == "function" then
			self.context.OnReady(self)
		end
	end
end
function PNL:Paint(w,h)
	surface.SetDrawColor(ES.Color.Black)
	surface.DrawRect(0,0,w,h)
	surface.SetDrawColor(Color(30,30,30))
	surface.DrawRect(1,1,w-2,h-2)
	surface.SetDrawColor(ES.Color["#FFFFFF03"])
	surface.DrawRect(1,1,w-2,1)
	surface.DrawRect(1,h-2,w-2,1)
	surface.DrawRect(1,2,1,h-4)
	surface.DrawRect(w-2,2,1,h-4)

	surface.SetDrawColor(ES.GetColorScheme(2))
	surface.DrawRect(1,1,w-2,70)


	surface.SetDrawColor(Color(0,0,0,20))
	surface.DrawRect(1,1,w,math.floor(69/4)*4 + 4)

	draw.SimpleText(self.title,"ES.MainMenu.FrameHead",15,70/2,ES.Color.White,0,1)
end
vgui.Register("ES.MainMenu.Frame",PNL,"Panel")

local colPlayerRowBg = Color(23,22,20)
local colPlayerRowBgSelf = Color(23,22,20)

local colOozyRedA = Color(117,31,25)
local colOozyRedB = Color(214,28,20)
local colOozyRedC = Color(124,49,54)

local colOozyBlueA = Color(72,105,145)
local colOozyBlueB = Color(111,170,229)
local colOozyBlueC = Color(91,137,186)

local colOozyGreenA = Color(105,135,105)
local colOozyGreenB = Color(162,211,106)
local colOozyGreenC = Color(131,167,104)

local PNL = {}
function PNL:Init()
	self.Player = NULL
	self.Avatar = vgui.Create("AvatarImage",self)
	self.Avatar:SetSize(32,32)
	function self.Avatar:OnMouseReleased()
		if IsValid(self.Player) then
			self.Player:ShowProfile()
		end
	end
	self.LblNick = self:Add("esLabel")
	self.LblNick:SetFont("ESDefault")
	self.LblRank = self:Add("esLabel")
	self.LblRank:SetFont("ESDefault")
	self.LblSteam = self:Add("esLabel")
	self.LblSteam:SetFont("ESDefault")

	self.mic = false
	self.recordWaveForm = {}
end
function PNL:Think()
	if self.Mute and ( self.Muted == nil || self.Muted ~= self.Player:IsMuted() ) then
		self.Muted = self.Player:IsMuted()
		if ( self.Muted ) then
			self.Mute:SetImage( "icon32/muted.png" )
		else
			self.Mute:SetImage( "icon32/unmuted.png" )
		end

		self.Mute.DoClick = function() self.Player:SetMuted( !self.Muted ) end

	end

	if !self.mic and IsValid(self.Player) and self.Player:VoiceVolume() > 0 then
		self.mic = true
		self.recordWaveform = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	end

	if self.mic then
		if IsValid(self.Player) and self.Player ~= LocalPlayer() then
			table.remove(self.recordWaveform,1)
			table.insert(self.recordWaveform,self.Player:VoiceVolume() * 30)
		end
	end
end
function PNL:Setup(p,plain)
	if not p or not IsValid(p) then self:Remove() return end

	if not plain then
		self.btnCopyID = self:Add("Panel")
		self.btnCopyID.OnMouseReleased = function()
			if IsValid(self.Player) then
				SetClipboardText(self.Player:SteamID())
			end
		end
		self.btnCopyID.OnCursorEntered = function()
			self.LblSteam:SetText("Click to copy SteamID")
			self:PerformLayout()
		end
		self.btnCopyID.OnCursorExited = function()
			if IsValid(self.Player) then
				self.LblSteam:SetText(self.Player:SteamID())
				self:PerformLayout()
			end
		end
		self.Mute		= self:Add( "DImageButton" )
		self.Mute:SetColor(ES.Color.White)
	end

	self.Avatar:SetPlayer(p,32)
	self.Player = p
	self.Avatar.Player = p

	self.LblNick:SetText(p:Nick() or "Undefined")
	self.LblNick:SetColor(colOozyGreenB)

	if p:ESGetRank() ~= "user" and p:ESGetRank() and p:ESGetRank().pretty and self.LblRank then
		self.LblRank:SetText("("..(p:ESGetRank().pretty or p:ESGetRank().name or "Unknown")..")")
	elseif self.LblRank then
		self.LblRank:SetVisible(false)
	end

	self.LblSteam:SetText(p:SteamID())
end
function PNL:PerformLayout()
	self.Avatar:SetPos(10,10)
	if self.Mute then
		self.Mute:SetSize( 32, 32 )
		self.Mute:SetPos(self:GetWide()-10-32,10)
	end
	self.LblSteam:SizeToContents()
	self.LblSteam:SetColor(Color(80,80,80))
	self.LblSteam:SetPos(self.LblNick.x , self.LblNick.y + self.LblNick:GetTall() + 3)

	if self.btnCopyID then
		self.btnCopyID:SetSize(self.LblSteam:GetWide(),self.LblSteam:GetTall())
		self.btnCopyID:SetPos(self.LblSteam.x,self.LblSteam.y)
	end

	self.LblRank:SizeToContents()
	self.LblRank:SetPos(self.LblNick.x + self.LblNick:GetWide() + 5, self.LblNick.y)
	self.LblRank:SetColor(colOozyGreenA)

	self.LblNick:SizeToContents()
	self.LblNick:SetPos(10+32+10+5,10)
end
local texGradient = Material("exclserver/gradient.png")
local friends = {}
local blocked = {}
function PNL:Paint(w,h)
	if not self.Player or not IsValid(self.Player) then return end

	draw.RoundedBox(2,0,0,w,h,Color(67,66,64))
	draw.RoundedBox(2,1,1,w-2,h-2,colPlayerRowBg)

	surface.SetDrawColor(Color(55,55,55,255))
	if self.mic then
		for k,v in pairs(self.recordWaveform)do
			if v < 2 then continue end
			--surface.SetDrawColor(Color(55,55,55,(k/#self.recordWaveform)*255 ))
			surface.DrawRect(w-1- #self.recordWaveform*3 + k*3,20+30-v,2,v)
		end

		surface.SetMaterial(texGradient)
		surface.SetDrawColor(colPlayerRowBg) //Makes sure the image draws correctly
		surface.DrawTexturedRectRotated(self:GetWide()- #self.recordWaveform*3 + (#self.recordWaveform*3 / 2),self:GetTall()/2,self:GetTall()-2,#self.recordWaveform*3,90)
	end

	if self.Player and self.Player:GetFriendStatus() == "friend" then
		draw.RoundedBox(6,6,6,32+8,32+8,colOozyGreenA)
		draw.RoundedBox(4,7,7,32+6,32+6,colOozyGreenB)
		draw.RoundedBox(4,9,9,32+2,32+2,colOozyGreenC)
	elseif self.Player and self.Player:GetFriendStatus() == "blocked" then
		draw.RoundedBox(6,6,6,32+8,32+8,colOozyRedA)
		draw.RoundedBox(4,7,7,32+6,32+6,colOozyRedB)
		draw.RoundedBox(4,9,9,32+2,32+2,colOozyRedC)
	else
		draw.RoundedBox(6,6,6,32+8,32+8,colOozyBlueA)
		draw.RoundedBox(4,7,7,32+6,32+6,colOozyBlueB)
		draw.RoundedBox(4,9,9,32+2,32+2,colOozyBlueC)
	end
end
vgui.Register("esMMPlayerRow",PNL,"Panel")

--### SERVER ROW
ES.CreateFont("esMMServerRowBoldSmall",{
	font="Arial Narrow",
	weight = 500,
	size = 12,
	italic = true
})
ES.CreateFont("esMMServerRowBold",{
	font="Arial Narrow",
	weight = 500,
	size = 32
	--shadow = true
})
local PNL = {}
function PNL:Init()
	self.HTML = self:Add("HTML")
	self.HTML:SetSize(128,128)

	self.lblName = self:Add("esLabel")
	self.lblName:SetFont("esMMServerRowBold")
	self.lblName:SetColor(ES.Color.White)

	self.lblPlayers = self:Add("esLabel")
	self.lblPlayers:SetFont("ESDefaultBold")
	self.lblPlayers:SetColor(Color(150,150,150))

	self.lblMap = self:Add("esLabel")
	self.lblMap:SetFont("ESDefaultBold")
	self.lblMap:SetColor(Color(150,150,150))

	self.lblIP = self:Add("esLabel")
	self.lblIP:SetFont("ESDefaultBold")
	self.lblIP:SetColor(Color(150,150,150))

	self.btnCopy = self:Add("esButton")
	self.btnCopy.DoClick = function()
		SetClipboardText(self.ip)
	end
	self.btnConnect = self:Add("esButton")
	self.btnConnect.DoClick = function()
		LocalPlayer():ConCommand("connect "..self.ip)
	end
end
local function prettifyName(name)
	name = string.gsub(name,"dr_","")
	name = string.gsub(name,"ttt_","")
	name = string.gsub(name,"ba_jail_","")
	name = string.gsub(name,"jb_","")
	name = string.gsub(name,"deathrun_","")
	name = string.gsub(name,"bhop_","")
	name = string.gsub(name,"_"," ")
	name = string.Trim(name)
	return exclFixCaps(name)
end
function PNL:PerformLayout()
	if not self.name then return end
	self.HTML:SetPos(self:GetWide()-128-1,1)

	self.lblName:SetText(string.gsub(self.name,"CasualBananas.com | ",""))
	self.lblName:SetPos(12,10)
	self.lblName:SizeToContents()

	self.lblPlayers:SetText("Players: "..self.players .. "/" .. self.maxplayers)
	self.lblPlayers:SetPos(15,50)
	self.lblPlayers:SizeToContents()

	self.lblMap:SetText("Map: "..prettifyName(self.mapname))
	self.lblMap:SetPos(15,self.lblPlayers.y+20)
	self.lblMap:SizeToContents()

	self.lblIP:SetText("IP: "..self.ip)
	self.lblIP:SetPos((self:GetWide() - 10 - 130 - 10 - 10)/2 + 20,self.lblPlayers.y)
	self.lblIP:SizeToContents()

	self.btnCopy:SetPos(10,self:GetTall()-10-22)
	self.btnCopy:SetSize((self:GetWide() - 10 - 130 - 10 - 10)/2 ,22)
	self.btnCopy.Text = "Copy IP"

	self.btnConnect:SetPos(self.btnCopy.x + self.btnCopy:GetWide() + 10,self.btnCopy.y)
	self.btnConnect:SetSize((self:GetWide() - 10 - 130 - 10 - 10)/2 ,22)
	self.btnConnect.Text = "Connect"
	if self.players == self.maxplayers then
		self.btnConnect.Evil = true
		self.btnConnect.Text = "Connect (full)"
	end

	self.HTML:SetHTML([[
		<html>
			<body style="margin: 0px">
				<img style="" src="]]..(self.mapicon or 'http://casualbananas.com/forums/images/mapicons/128px/not_found.png')..[[">
			</body>
			<style type="text/css"></style>
		</html>]])
end
function PNL:Paint(w,h)
	surface.SetDrawColor(ES.Color.Black)
	surface.DrawRect(0,0,w,h)

	surface.SetDrawColor(Color(40,40,40))
	surface.SetMaterial( texGradient)
	surface.DrawTexturedRect(1,1,w-2,h-2)
end
vgui.Register("esMMServerRow",PNL,"Panel")

--### MUSIC PLAYER
ES.CreateFont("esMMPlayButton",{
	font = "Arial",
	size = 120,
	weight = 700
})
ES.CreateFont("esMMSongTitle",{
	font = "Arial",
	size = 34,
	weight = 700
})
vgui.Register("esMMMusicPlayer",{
	Init = function(self)

	end,
	Paint = function(self,w,h)
		surface.SetDrawColor(Color(30,30,30))
		surface.DrawRect(0,0,w,h)

		surface.SetDrawColor(ES.GetColorScheme(1))
		surface.DrawRect(0,0,h,h)

		local info = ES.GetMusicInfo()
		if info.active then
			draw.SimpleText("ll","esMMPlayButton",h/2,h/2,ES.Color.White,1,1)
		else
			draw.SimpleText("►","esMMPlayButton",h/2,h/2 - 2,ES.Color.White,1,1)
		end

		draw.SimpleText(info.title,"esMMSongTitle",h+15,10,ES.Color.White,0,0)
	end,
},"Panel")

vgui.Register("esMMPanel",{
	Paint = function(self,w,h)
		surface.SetDrawColor(self.color)
		surface.DrawRect(0,0,w,h)

		surface.SetDrawColor(Color(0,0,0,150))
		surface.DrawRect(0,0,w,1)
		surface.DrawRect(0,h-1,w,1)
		surface.DrawRect(0,1,1,h-2)
		surface.DrawRect(w-1,1,1,h-2)
	end,
	SetColor = function(self,color)
		self.color = color
	end,
	Init = function(self)
		self.color = colMainElementBg
	end
},"Panel")
