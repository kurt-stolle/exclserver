-- cl_achievements.luaw
ES.CreateFont("ESAchievementFontBig",{
	font = "Roboto",
	weight = 500,
	size = 28
})
vgui.Register("ESAchievementPopupPanel",{
	Init=function(self)
		self.TimeCreated=CurTime();

		if self.BaseClass.Init then
			self.BaseClass:Init()
		end
	end,
	Think = function(self)
		if CurTime() - self.TimeCreated < 7 then
			self.y = math.Clamp(self.y + 4, -self:GetTall(), 20)
		else
			self.y = math.Clamp(self.y - 4, -self:GetTall(), 20)
			if self.y <= -self:GetTall() + 1 then
				self:Remove()
				return
			end
		end

		if self.BaseClass.Think then
			self.BaseClass:Think();
		end
	end,
},"esPanel")

local ach
local sounds = {
	Sound("vo/npc/Barney/ba_ohyeah.wav"),
	Sound("vo/npc/female01/yeah02.wav"),
	Sound("vo/npc/male01/yeah02.wav"),
	Sound("combined/k_lab/k_lab_kl_mygoodness02_cc.wav"),
	Sound("vo/Citadel/eli_goodgod.wav"),
	Sound("vo/Citadel/eli_mygirl.wav"),
	Sound("vo/eli_lab/al_goodcatch.wav"),
	Sound("vo/coast/odessa/male01/nlo_cheer01.wav"),
	Sound("vo/coast/odessa/male01/nlo_cheer02.wav"),
	Sound("vo/coast/odessa/male01/nlo_cheer03.wav"),
	Sound("vo/coast/odessa/male01/nlo_cheer04.wav"),
	Sound("vo/coast/odessa/female01/nlo_cheer01.wav"),
	Sound("vo/coast/odessa/female01/nlo_cheer02.wav"),
	Sound("vo/coast/odessa/female01/nlo_cheer03.wav")
}

function ES.CreateAchievementPopup(text,name,icon)
	if ach and IsValid(ach) then ach:Remove() end

	local a,b,c = ES.GetColorScheme()

	ach = vgui.Create("ESAchievementPopupPanel")
	ach:SetSize(400,80)
	ach:SetPos(ScrW()/2 - ach:GetWide()/2,-ach:GetTall())

	local ic = ach:Add("DImage")
	ic:SetMaterial(icon)
	ic:SetSize(64,64)
	ic:SetPos(8,8)

	local lb = Label(text,ach)
	lb:SetFont("ESDefaultBold")
	lb:SetPos(72+6,6)
	lb:SizeToContents()
	lb:SetColor(ES.Color.White)

	local lb2 = Label(name,ach)
	lb2:SetFont("ESAchievementFontBig")
	lb2:SetPos(72+6,lb.y+lb:GetTall())
	lb2:SizeToContents()
	lb2:SetColor(ES.Color.White)

	ach.name = lb2

	ach:RequestFocus()

	return ach
end

net.Receive("ESAchProgr",function()
	local p = LocalPlayer()
	if not p._es_achievements then p._es_achievements = {} end

	local id = net.ReadString()
	p._es_achievements[id] = net.ReadUInt(32)

	if ES.Achievements[id].nonotify then return end

	local a,b,c = ES.GetColorScheme()
	local pnl = ES.CreateAchievementPopup("Achievement progress",ES.Achievements[id].name,ES.Achievements[id].icon)
	local dr = vgui.Create("Panel",pnl)
	dr:SetPos(pnl.name.x, pnl:GetTall()-10-16)
	dr:SetSize(pnl:GetWide() - pnl:GetTall() - 8,16)
	dr.Paint = function(self,w,h)
		draw.RoundedBox(2,0,0,w,h,Color(30,30,30))
		draw.RoundedBox(2,1,1,(w-2)*(p._es_achievements[id]/ES.Achievements[id].progressNeeded),h-2,a)
		draw.SimpleText(p._es_achievements[id].." / "..ES.Achievements[id].progressNeeded,"ESDefaultBold.Shadow",w/2,h/2,COLOR_BLACK,1,1)
		--draw.SimpleText(p._es_achievements[id].." / "..ES.Achievements[id].progressNeeded,"ESDefaultBold",w/2 +1,h/2 +1,COLOR_BLACK,1,1)
		draw.SimpleText(p._es_achievements[id].." / "..ES.Achievements[id].progressNeeded,"ESDefaultBold",w/2,h/2,COLOR_WHITE,1,1)
	end

end)

net.Receive("ESAchSynch",function()
	local p = LocalPlayer()
	local tbl = net.ReadTable()
	if not tbl then return end

	p._es_achievements = tbl
end)

net.Receive("ESAchEarned",function()
	local ply = net.ReadEntity()
	local id = net.ReadString()

	surface.PlaySound(table.Random(sounds))

	if ES.Achievements[id].earnsilent then
		chat.AddText(COLOR_WHITE,"(HIDDEN) ",ply,COLOR_WHITE," has earned the achievement ",Color(102,255,51),ES.Achievements[id] and ES.Achievements[id].name or id or "Unknown",COLOR_WHITE,".")
	else
		chat.AddText(ply,COLOR_WHITE," has earned the achievement ",Color(102,255,51),ES.Achievements[id] and ES.Achievements[id].name or id or "Unknown",COLOR_WHITE,".")
	end
	if ply == LocalPlayer() then
		if not LocalPlayer()._es_achievements then LocalPlayer()._es_achievements = {} end
		LocalPlayer()._es_achievements[id] = ES.Achievements[id].progressNeeded

		local pnl = ES.CreateAchievementPopup("Achievement unlocked",ES.Achievements[id].name,ES.Achievements[id].icon)
		local lbl = Label(ES.FormatLine(ES.Achievements[id].descr,"ESDefault",ach:GetWide() - 80 - 4 - 4),pnl)
		lbl:SetFont("ESDefault")
		lbl:SizeToContents()
		lbl:SetPos(ach.name.x+2,ach.name.y + ach.name:GetTall()+3)
		lbl:SetColor(COLOR_WHITE)
	end
end)
