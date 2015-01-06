-- cl_mapvote.lua
-- makes stuff easier, global mapvote

-- cl_mapvote.lua
local didYouKnow = {
"The average penis size is 18cm.\nDesu has the wonderful size of almost 24cm.",
"You get 500 free bananas if you register on our forum.\nFor more information go to www.CasualBananas.com.",
"Our developer, Excl, works very hard to improve the server.\nIf you have a suggestion we would love to hear it.",
"You can type :menu in chat to open the ExclServer menu.\nFrom here you can also access the shop.",
"Bananas are synched throughout all our servers.\nThis includes all games, not just Garry's Mod.",
"Our admin team is carefully selected.\nWe are currently recruiting more european and asian admins.",
"Our community has monthly raffles.\nGo to our site to buy a ticket (2000 bananas).",
"Avoiding punishment will be punished."
}

COLOR_WHITE = COLOR_WHITE or Color(255,255,255);
COLOR_BLACK = COLOR_BLACK or Color(0,0,0);

surface.CreateFont("exclMapTimeleft",{
	font = "Roboto";
	size = 64;
	weight = 500;
});

surface.CreateFont("exclMapDYKandVoters",{
	font = "Roboto";
	size = 28;
	weight = 500;
	antialias = 1;
});
surface.CreateFont("exclVoteRowName",{
	font = "Roboto";
	weight = 500;
	size = 14;
});
local function prettifyName(name)
	name = string.gsub(name,"dr_","");
	name = string.gsub(name,"ttt_","");
	name = string.gsub(name,"ba_jail_","");
	name = string.gsub(name,"jb_","");
	name = string.gsub(name,"deathrun_","");
	name = string.gsub(name,"bhop_","");
	name = string.gsub(name,"_"," ");
	name = string.Trim(name);
	return exclFixCaps(name)
end
local votesCast = {};
local votesMap = {};
local color_votebg = Color(0,0,0,220);
local votemenu = NULL;
local timeStart= CurTime();
local colorProgressYello = Color(255,204,0);

vgui.Register("exclVoteButton",{
	Init = function(self)
		self.map = false;
		self.Hover =false;
	end,
	OnCursorEntered = function(self)
		self.Hover = true;
		if self.OnHover then
			self:OnHover();
		end
	end,
	OnCursorExited = function(self)
		self.Hover = false;
	end,
	Paint = function(self,w,h)
		draw.RoundedBox(4,0,0,w,h,COLOR_BLACK);
		local colDraw = COLOR_WHITE
		if self.Hover then
			colDraw = colorProgressYello;
		end
		draw.RoundedBox(4,1,1,w-2,h-2,colDraw);
		
		surface.SetDrawColor(Color(0,0,0,150));
		surface.DrawRect(5,5,w-10,h-10)
		if self.map then
			surface.SetMaterial(self.map);
			surface.SetDrawColor(COLOR_WHITE);
			surface.DrawTexturedRect(6,6,w-12,h-12)
		else
			surface.SetDrawColor(COLOR_BLACK);
			surface.DrawRect(6,6,w-12,h-12)
			draw.SimpleText("<Current Map>","ESDefaultBold",w/2,h/2,COLOR_WHITE,1,1);
		end
	end
},"Panel");
local colorProgressBG = Color(213,213,213);
local colorProgressOverlay = Color(255,255,255,10);

vgui.Register("exclVotePlayerRow",{
	Init = function(self)
		self.AvatarButton = self:Add( "DButton" )
		self.AvatarButton:Dock( LEFT )
		self.AvatarButton:SetSize( 16, 16 )
		self.AvatarButton.DoClick = function() self.Player:ShowProfile() end

		self.Avatar		= vgui.Create( "AvatarImage", self.AvatarButton )
		self.Avatar:SetSize(16 ,16 )
		self.Avatar:SetMouseInputEnabled( false )		
		
		self.Name = self:Add("DLabel");
		self.Name:SetFont("exclVoteRowName");
		self.Name:SetPos(16+6,2);
	end,
	Setup = function(self,p)


		if IsValid(self) and IsValid(self.Avatar) and IsValid(self.AvatarButton) and IsValid(self.Name) and IsValid(p) then
			

			self.Player = p;
			self.Avatar:SetPlayer(p);
			self.Name:SetText(p:Nick());
			self.Name:SizeToContents();
		elseif IsValid(self) then
			self.Avatar:Remove();
			self.Name:Remove()
			self:Remove();
		end
	end,
	Paint = function(self,w,h)
	--draw.RoundedBox(2,0,0,w,h,Color(0,0,0,150));
end
},"Panel");

local logoMat = Material("excl/vgui/bananaLogo.png");
local marginY = 20;
local lastSetupPeopleWho = false;
local lastSetupPeopleWhoP = false;
local lastSetupPeopleWhoL = false;
local function setupPeopleWho(p,l,m)	
	lastSetupPeopleWho = m;
	lastSetupPeopleWhoP = p;
	lastSetupPeopleWhoL = l;
		
	local txt = prettifyName(m);
	
	l:SetText(txt);
	l:SizeToContents();
	
	if p.rows then
		for k,v in pairs(p.rows)do
			if v and IsValid(v) then
				v:Remove();
				table.remove(p.rows,k);
			end
		end
	end
	
	local h = -1;
	local cX = 0;
	for k,v in pairs(votesCast)do
		if v == m then
			local ava = vgui.Create("exclVotePlayerRow",p);
			ava:SetSize(150,16);
			h = h+1;
			if h*(16+6) >= p:GetTall() then
				h = 0;
				cX = cX+1;
			end
			ava:SetPos(cX*(150+4),h*(16+6));
			ava:Setup(k);
			
			if not p.rows then
				p.rows = {};
			end
			table.insert(p.rows,ava);
		end
	end
end
surface.CreateFont("esMapvoteSpecialText",{
	font = "Roboto",
	size = 24,
	weight = 700
})
surface.CreateFont("esMapvoteSpecialTextBlur",{
	font = "Roboto",
	size = 24,
	weight = 700,
	blursize = 2
})
local iconStar = Material("icon16/star.png");
local gradient = Material("exclserver/gradient.png");
local width = 200;
local height = 512;
local marginX = (ScrW()-(width*5))/6;
vgui.Register("exclVotePanel",{
	Paint = function(self,w,h)	
		Derma_DrawBackgroundBlur(self,6);
		surface.SetDrawColor( color_votebg );
		surface.DrawRect(0,0,w,h);

		local c = ES.GetColorScheme();
		surface.SetDrawColor(c);
		surface.DrawRect(0,0,w,4);
		
		draw.SimpleText("MAPVOTE","exclMapTimeleft",marginX,ScrH()/2 - 512/2 - 74,COLOR_WHITE,0,0);
		draw.SimpleText(math.Round(20 - (CurTime()-timeStart)),"exclMapTimeleft",w-marginX,ScrH()/2 - 512/2 - 74,COLOR_WHITE,2,0);
	end
},"EditablePanel");
vgui.Register("esMapVotePanel",{
	Paint = function(self,w,h)
		draw.RoundedBox( 2,0,0,w,h,Color(40,40,40) );
		draw.RoundedBox( 2,1,1,w-2,h-2,Color(50,50,50) );
	end
},"Panel");
vgui.Register("esMapVoteButton",{
	Init = function(self)
		self.map = false;
		self.Hover =false;
		self.specialText = false;

		self.fadeSelect = 255;
	end,
	OnCursorEntered = function(self)
		self.Hover = true;
		if self.OnHover then
			self:OnHover();
		end
	end,
	OnCursorExited = function(self)
		self.Hover = false;
	end,
	Paint = function(self,w,h)

		if !self.Hover then
			self.fadeSelect= Lerp(0.1,self.fadeSelect,255);
		else
			self.fadeSelect= Lerp(0.4,self.fadeSelect,150);
		end
		surface.SetDrawColor(Color(0,0,0,self.fadeSelect));
			surface.SetMaterial(gradient);
			surface.DrawTexturedRectRotated(w/2,h/2,w,h,180);

		if self.specialText then
			surface.SetDrawColor(Color(0,0,0,150))
			surface.DrawRect(0,0,w,40);
			draw.SimpleText(self.specialText or "","esMapvoteSpecialTextBlur",8,8,Color(0,0,0,100));
			draw.SimpleText(self.specialText or "","esMapvoteSpecialText",8,8,COLOR_WHITE);

		end

		draw.SimpleText(string.upper(prettifyName(self.mapText or "")),"ESDefaultBlur",4,h-38,COLOR_BLACK);
		draw.SimpleText(string.upper(prettifyName(self.mapText or "")),"ESDefault",4,h-38,COLOR_WHITE);

		--[[for i=1,5 do
			surface.SetMaterial(iconStar);
			surface.SetDrawColor(i < 4 and COLOR_WHITE or Color(100,100,100));
			surface.DrawTexturedRect(8 + (i-1)*20,h-16-8,16,16)
		end
]]
		local _,color = ES.GetColorScheme();
		--[[color = table.Copy(color);
		color.a = 50;]]

		local perc = math.Round(((votesMap[self.mapText] or 0)/table.Count(votesCast) * 100) or 0) or 0;
		if !perc then perc = 0 end
		perc = tonumber(perc);
		local vWide = (perc/100)*(w-8);
		draw.RoundedBox(2,4-1,h-4-18-1,w-6,18,COLOR_BLACK)
		if vWide <= 4 then

			draw.RoundedBox(2,4,h-4-18,4,16,color);
		else
		
			draw.RoundedBox(2,4,h-4-18,vWide,16,color);
		end
		
		draw.SimpleText(tostring(perc or 0).." %","ESDefault",w/2,h-8-6,COLOR_WHITE,1,1);

		surface.SetDrawColor(Color(0,0,0,100));
		surface.DrawRect(0,0,w,1);
		surface.DrawRect(0,1,1,h-2);
		surface.DrawRect(w-1,1,1,h-2);
		surface.DrawRect(0,h-1,w,1);
	end
},"Panel");


local function OpenMapvote(maps)
	if votemenu and IsValid(votemenu) then votemenu:Remove() end

	timer.Simple(20,function()
		if votemenu and IsValid(votemenu) then votemenu:Remove() end
	end)

	timeStart= CurTime();
	votesCast = {};
	votesMap = {};

	votemenu = vgui.Create("exclVotePanel");
	votemenu:SetSize(ScrW(),ScrH());
	votemenu:SetPos(0,0);
	local pPeopleWho
	local maplbl

	for i=1,5 do
		local pnl = vgui.Create("esMapVotePanel",votemenu);
		pnl:SetPos(marginX*i + ((i-1)*width),ScrH()/2 - height/2);
		pnl:SetSize(width,height);

		local HTML = vgui.Create("DHTML",pnl)
		HTML:SetSize(pnl:GetWide(),pnl:GetTall())
		HTML:SetPos(0,0)
		HTML:OpenURL("www.casualbananas.com/api/mapvote.php?map="..(maps[i] or game.GetMap()));

		local btn = vgui.Create("esMapVoteButton",pnl);
		btn:SetSize(pnl:GetWide(),pnl:GetTall());
		btn:SetPos(0,0);
		btn.OnMouseReleased = function()
			RunConsoleCommand("excl_castmapvote",maps[i] or game.GetMap());
			ES.DebugPrint("Vote has been cast");
		end
		btn.OnHover = function(self)
			if IsValid(maplbl) and IsValid(pPeopleWho) then
				setupPeopleWho(pPeopleWho,maplbl,maps[i] or game.GetMap());
			end
		end
		HTML.OnMouseReleased = btn.OnMouseReleased;
		pnl.OnMouseReleased = btn.OnMouseReleased;


		if i == 1 then
			btn.specialText = "HIGH RATING";
		elseif i == 2 then
			btn.specialText = "UNDERPLAYED";
		elseif i == 5 and !maps[i] then
			btn.specialText = "EXTEND";
		end

		btn.mapText = maps[i] or game.GetMap();


	end




	local logo = votemenu:Add("DImage");
	logo:SetSize(512/2,128/2);
	logo:SetMaterial(logoMat);
	logo:SetPos(ScrW()-marginX-512/2,ScrH()-marginX/2-128/2);

	local lb = Label("YOU'RE PLAYING ON",votemenu);
	lb:SetFont("ESDefault");
	lb:SetColor(COLOR_WHITE);
	lb:SizeToContents();
	lb:SetPos(logo.x - lb:GetWide()-10,logo.y + 30);
	

	

	local bottom = votemenu:Add("Panel");
	bottom:SetSize(votemenu:GetWide()-marginX*2,140);
	bottom:SetPos(marginX,votemenu:GetTall()-140-20)
	
	local temp = table.Random(maps);
	local votedfor = Label("People who voted for ",bottom)
	votedfor:SetFont("exclMapDYKandVoters");
	votedfor:SetColor(COLOR_WHITE)
	votedfor:SizeToContents();
	votedfor:SetPos(0,0);
	
	local mycolor = ES.GetColorScheme();
	maplbl = Label(temp,bottom)
	maplbl:SetFont("exclMapDYKandVoters");
	maplbl:SetColor(mycolor)
	maplbl:SizeToContents();
	maplbl:SetPos(votedfor:GetWide(),0);
	
	pPeopleWho = bottom:Add("Panel");
	pPeopleWho:SetSize((bottom:GetWide()/10*65),bottom:GetTall()-votedfor:GetTall());
	pPeopleWho:SetPos(0,votedfor:GetTall());
	
	setupPeopleWho(pPeopleWho,maplbl,temp);

	votemenu:MakePopup();


	--[[local marginX = (ScrW()-(132*4))/5;
	
	votemenu = vgui.Create("exclVotePanel");
	votemenu:SetSize(ScrW(),ScrH());
	votemenu:SetPos(0,0);
	votemenu:MakePopup();
	
	local logo = votemenu:Add("DImage");
	logo:SetSize(512,128);
	logo:SetMaterial(logoMat);
	logo:SetPos(votemenu:GetWide()/2 - 512/2,((votemenu:GetTall()/2) - (marginY/2) - 140-20-20) / 2 - 128/2);
	
	local pPeopleWho
	local maplbl
	
	for i=1,6 do
		if not maps[i] then continue end
		local p = vgui.Create("Panel",votemenu);
		p:SetSize(140,140+20+20);

		local txt = prettifyName(maps[i] or "Undefined");
		if maps[i] == game.GetMap() then
			txt = "Extend Current"
		end
		local l = Label(txt,p);
		l:SetFont("exclMapLabels");
		l:SizeToContents();
		l:Center();
		l:SetColor(COLOR_WHITE);
		l.y = 0;
		local b = vgui.Create("exclVoteButton",p);
		b:SetSize(140,140);
		b:SetPos(0,20);
		if maps[i] != game.GetMap() then
			b.map = Material("excl/maps/"..maps[i]..".png");
		end
		b.OnMouseReleased = function()
			RunConsoleCommand("excl_castmapvote",maps[i]);
		end
		b.OnHover = function(self)
			if IsValid(maplbl) and IsValid(pPeopleWho) then
				setupPeopleWho(pPeopleWho,maplbl,maps[i]);
			end
		end
		if i > 4 then
			p:SetPos(marginX + ((i-5)*(marginX+140)),(votemenu:GetTall()/2) + (marginY/2));
		else
			p:SetPos(marginX + ((i-1)*(marginX+140)),(votemenu:GetTall()/2) - (marginY/2) -p:GetTall());
		end
		local prg = vgui.Create("exclVoteProgress",p);
		prg:SetPos(0,p:GetTall()-16);
		prg:SetSize(p:GetWide(),16);
		prg.map = maps[i];
	end
	
	local bottom = votemenu:Add("Panel");
	bottom:SetSize(votemenu:GetWide()-marginX*2,140);
	bottom:SetPos(marginX,votemenu:GetTall()-140-20)
	
	local dyk = Label("Did you know?",bottom)
	dyk:SetFont("exclMapDYKandVoters");
	dyk:SetColor(COLOR_WHITE)
	dyk:SizeToContents();
	dyk:SetPos(bottom:GetWide() - (bottom:GetWide()/10*3),0);
	local fact = Label(table.Random(didYouKnow),bottom)
	fact:SetFont("DermaDefault");
	fact:SizeToContents();
	fact:SetPos(bottom:GetWide() - (bottom:GetWide()/10*3),dyk:GetTall()+10);
	
	local temp = table.Random(maps);
	local votedfor = Label("People who voted for ",bottom)
	votedfor:SetFont("exclMapDYKandVoters");
	votedfor:SetColor(COLOR_WHITE)
	votedfor:SizeToContents();
	votedfor:SetPos(0,0);
	
	maplbl = Label(temp,bottom)
	maplbl:SetFont("exclMapDYKandVoters");
	maplbl:SetColor(colorProgressYello)
	maplbl:SizeToContents();
	maplbl:SetPos(votedfor:GetWide(),0);
	
	pPeopleWho = bottom:Add("Panel");
	pPeopleWho:SetSize((bottom:GetWide()/10*6),bottom:GetTall()-votedfor:GetTall());
	pPeopleWho:SetPos(0,votedfor:GetTall());
	
	setupPeopleWho(pPeopleWho,maplbl,temp);]]
end

net.Receive("exclStartMapvote",function()
	OpenMapvote(net.ReadTable());
end)
net.Receive("exclReceiveMapVote",function()
	local p = net.ReadEntity();
	if IsValid(p) then
		if votesCast[p] then
			votesMap[votesCast[p]] = (votesMap[votesCast[p]] or 1) - 1;
		end
		votesCast[p] = net.ReadString();
		votesMap[votesCast[p]] = (votesMap[votesCast[p]] or 0) + 1;
		p.votefor = votesCast[p];
	end
	
	if lastSetupPeopleWho and lastSetupPeopleWhoP and lastSetupPeopleWhoL then
		setupPeopleWho(lastSetupPeopleWhoP,lastSetupPeopleWhoL,lastSetupPeopleWho)
	end
end)