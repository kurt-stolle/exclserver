-- cl_achievements.luaw
surface.CreateFont("ESAchievementFontBig",{
	font = "Arial Narrow",
	weight = 520,
	size = 24
})
vgui.Register("ESAchievementPopupPanel",{
	Paint = function(self,w,h)
		local a,b,c = ES.GetColorScheme();

		surface.SetDrawColor(c);
		surface.DrawRect(0,0,w,h)

		surface.SetDrawColor(b)
		surface.DrawRect(1,1,w-2,h-2);

		--draw.SimpleText("www.CasualBananas.com","ESDefaultBold",w-5,4,Color(0,0,0,100),2);
	end,
	Init = function(self)
		self.TimeCreated = CurTime();
	end,
	Think = function(self)
		if CurTime() - self.TimeCreated < 7 then
			self.y = math.Clamp(self.y + 4, -self:GetTall(), 20);
		else
			self.y = math.Clamp(self.y - 4, -self:GetTall(), 20);
			if self.y <= -self:GetTall() + 1 then
				self:Remove();
				return;
			end
		end 
	end,
},"Panel");

local ach;
local sounds = {Sound("vo/npc/Barney/ba_ohyeah.wav"),Sound("vo/npc/female01/yeah02.wav"),Sound("vo/npc/male01/yeah02.wav"),
Sound("combined/k_lab/k_lab_kl_mygoodness02_cc.wav"),Sound("vo/Citadel/eli_goodgod.wav"),Sound("vo/Citadel/eli_mygirl.wav"),Sound("vo/eli_lab/al_goodcatch.wav"),
Sound("vo/coast/odessa/male01/nlo_cheer01.wav"),Sound("vo/coast/odessa/male01/nlo_cheer02.wav"),Sound("vo/coast/odessa/male01/nlo_cheer03.wav"),Sound("vo/coast/odessa/male01/nlo_cheer04.wav"),
Sound("vo/coast/odessa/female01/nlo_cheer01.wav"),Sound("vo/coast/odessa/female01/nlo_cheer02.wav"),Sound("vo/coast/odessa/female01/nlo_cheer03.wav")}
function ES.CreateAchievementPopup(text,name,icon)
	if ach and IsValid(ach) then ach:Remove() end
	
	local a,b,c = ES.GetColorScheme();

	ach = vgui.Create("ESAchievementPopupPanel");
	ach:SetSize(400,80);
	ach:SetPos(ScrW()/2 - ach:GetWide()/2,-ach:GetTall());

	local ic = ach:Add("DImage");
	ic:SetMaterial(icon);
	ic:SetSize(64,64);
	ic:SetPos(8,8);

	local lb = Label(text,ach);
	lb:SetFont("ESDefaultBold");
	lb:SetPos(72+6,4);
	lb:SizeToContents();
	lb:SetColor(Color(50,50,50));

	local lb2 = Label(name,ach);
	lb2:SetFont("ESAchievementFontBig");
	lb2:SetPos(72+6,lb.y+lb:GetTall());
	lb2:SizeToContents();
	lb2:SetColor(COLOR_WHITE);

	ach.name = lb2;

	ach:RequestFocus();

	return ach;
end

net.Receive("ESAchProgr",function()
	local p = LocalPlayer();
	if not p.excl then return end
	if not p.excl.achievements then p.excl.achievements = {} end

	local id = net.ReadString();
	p.excl.achievements[id] = net.ReadUInt(32);

	if ES.Achievements[id].nonotify then return end

	local a,b,c = ES.GetColorScheme();
	local pnl = ES.CreateAchievementPopup("Achievement progress...",ES.Achievements[id].name,ES.Achievements[id].icon)
	local dr = vgui.Create("Panel",pnl);
	dr:SetPos(pnl.name.x, pnl:GetTall()-10-20);
	dr:SetSize(pnl:GetWide() - pnl:GetTall() - 8,20);
	dr.Paint = function(self,w,h)
		draw.RoundedBox(2,0,0,w,h,Color(30,30,30));
		draw.RoundedBox(2,1,1,(w-2)*(p.excl.achievements[id]/ES.Achievements[id].progressNeeded),h-2,a);
		draw.SimpleText(p.excl.achievements[id].." / "..ES.Achievements[id].progressNeeded,"ESDefaultBoldBlur",w/2,h/2,COLOR_BLACK,1,1);
		--draw.SimpleText(p.excl.achievements[id].." / "..ES.Achievements[id].progressNeeded,"ESDefaultBold",w/2 +1,h/2 +1,COLOR_BLACK,1,1);
		draw.SimpleText(p.excl.achievements[id].." / "..ES.Achievements[id].progressNeeded,"ESDefaultBold",w/2,h/2,COLOR_WHITE,1,1);
	end

end)

net.Receive("ESAchSynch",function()
	local p = LocalPlayer();
	local tbl = net.ReadTable();
	if not tbl then return end

	if not p.excl then p.excl = {} end
	p.excl.achievements = tbl;
end)

net.Receive("ESAchEarned",function()
	local ply = net.ReadEntity();
	local id = net.ReadString();

	surface.PlaySound(table.Random(sounds));

	if ES.Achievements[id].earnsilent then
		ES.ChatAddText("medal",COLOR_WHITE,"(HIDDEN) ",Color(102,255,51),ply:Nick(),COLOR_WHITE," has earned the achievement ",Color(102,255,51),ES.Achievements[id] and ES.Achievements[id].name or id or "Unknown",COLOR_WHITE,".");
	else
		ES.ChatAddText("medal",Color(102,255,51),ply:Nick(),COLOR_WHITE," has earned the achievement ",Color(102,255,51),ES.Achievements[id] and ES.Achievements[id].name or id or "Unknown",COLOR_WHITE,".");
	end
	if ply == LocalPlayer() and LocalPlayer().excl then
		if not LocalPlayer().excl.achievements then LocalPlayer().excl.achievements = {} end
		LocalPlayer().excl.achievements[id] = ES.Achievements[id].progressNeeded;

		local pnl = ES.CreateAchievementPopup("Achievement unlocked!",ES.Achievements[id].name,ES.Achievements[id].icon)
		local lbl = Label(ES.FormatLine(ES.Achievements[id].descr,"ESDefault",ach:GetWide() - 80 - 4 - 4),pnl);
		lbl:SetFont("ESDefault");
		lbl:SizeToContents();
		lbl:SetPos(ach.name.x+2,ach.name.y + ach.name:GetTall()+3);
		lbl:SetColor(COLOR_WHITE);
	end
end)