--[[ the custom chat
COLOR_BLACK = COLOR_BLACK or Color(0,0,0);

local lineIconsDefault = { -- for ranks see the ranks file
	player = Material("icon16/user_comment.png"),
	error = Material("icon16/error.png"),
	admincommand = Material("icon16/lightning.png");
	accessdenied = Material("icon16/user_delete.png");
	global =  Material("icon16/world.png"),
	server =  Material("icon16/server.png"),
	default =  Material("icon16/asterisk_orange.png"),
	join =  Material("icon16/group_add.png"),
	leave =  Material("icon16/group_delete.png"),
	star =  Material("icon16/star.png"),
	medal = Material("icon16/award_star_gold_1.png"),
	announce = Material("icon16/sound.png"),
	heart = Material("icon16/heart.png")
}
local chatColorDefault = Color(240,240,240);
local chatColors = {}
	chatColors[1] = Color(255,0,0) -- red
	chatColors[2] = Color(0,255,0) -- green
	chatColors[3] = Color(255,255,0) -- yellow
	chatColors[4] = Color(0,0,255) -- blue
	chatColors[5] = Color(51,204,255) -- cyan
	chatColors[6] = Color(255,0,255) -- purple
	chatColors[7] = Color(255,255,255) -- white
	chatColors[8] = Color(150,150,150) -- grey
	chatColors[9] = "chat default" -- chat default
	chatColors[0] = Color(0,0,0) -- black

local chatEmotes = {}
	chatEmotes[":)"] 		= Material("icon16/emoticon_smile.png");
	chatEmotes[":linux:"] 	= Material("icon16/tux.png");
	chatEmotes[":("] 		= Material("icon16/emoticon_unhappy.png");
	chatEmotes[":P"]		= Material("icon16/emoticon_tongue.png"); 
	chatEmotes[">:D"]		= Material("icon16/emoticon_evilgrin.png");
	chatEmotes[":D"]		= Material("icon16/emoticon_grin.png");
	chatEmotes[":O"]		= Material("icon16/emoticon_surprised.png");
	chatEmotes[";)"	]		= Material("icon16/emoticon_wink.png");
	chatEmotes[":bday:"]		= Material("icon16/cake.png");
	chatEmotes[":coin:"]		= Material("icon16/coins.png");
	chatEmotes["<3"]		= Material("icon16/heart.png");
	chatEmotes[":star:"]		= Material("icon16/star.png");
	chatEmotes[":gmod:"]		= Material("games/16/garrysmod.png");


local chatGui = NULL;
local chatText 		  = {}
local chatTextHistory = {}
local lastAdd = CurTime();

local isTeam  = false;

local function testString(s,d,constr)
	if s and type(s) == "string" and s != "" then
		local find =string.find(s,d,1,true);
		if find then
			table.insert(constr,string.Left(s,find-1));
			s = string.Right(s,#s-(find-1));			
			table.insert(constr,chatEmotes[d])

			if s and s[#d] and s[#d+1] and s[#d+1] != "" and s[#d+1] != "\n" then
				return testString(string.Right(s, #s - #d),d,constr);
			else
				return false;
			end
		else
			return s;
		end
		return false;
	end
	return false;
end
local function esAddText(icon,tblText)
	if not icon or not tblText or not tblText[1] then return end

	local constrPre = {} -- parse smilies first
	for a,v in pairs(tblText)do
		if type(v) == "string" then	
			local c = 1;
			for d,e in pairs(chatEmotes)do
				c = c+1;
				
				v = testString(v,d,constrPre)
			end
			if v then
				table.insert(constrPre,v);
			end
		else 
			table.insert(constrPre,v);
		end
	end
	
	local constr = {}
	
	if icon and lineIconsDefault[icon] then
		table.insert(constr,lineIconsDefault[icon]);
		table.insert(constr," ");
	end
	for a,v in pairs(constrPre)do
		if type(v) == "string" and string.find(v,"^",1,true) then
				local s = ""
				local con = false;
				for k=1,#v do
					if con then 
						con = false; 
						continue; 
					end
					if v[k]=="^" and v[k+1] and chatColors[tonumber(v[k+1])] then
						table.insert(constr,s)
						if type(chatColors[tonumber(v[k+1])]) == "string" then
							if chatColors[tonumber(v[k+1])]== "chat default" then
								table.insert(constr,chatColorDefault)
							end
						else
							table.insert(constr,chatColors[tonumber(v[k+1])])
						end
						
						s = "";
						con = true;
						continue;
					elseif v[k] then
						s = s..v[k];
					end
				end
				table.insert(constr,s)
		elseif type(v) == "Player" and IsValid(v) then
			table.insert(constr,team.GetColor(v:Team()));
			table.insert(constr,v:Nick());
			table.insert(constr,chatColorDefault);
		else
			table.insert(constr,v);
		end
	end

	if #chatTextHistory >= 60 then
		table.remove(chatTextHistory,1);
	end
	table.insert(chatTextHistory,{icon=icon,tbl=tblText});
	if #chatText >= 10 then
		table.remove(chatText,1);
	end
	table.insert(chatText,{icon=icon,tbl=constr});
	lastAdd = CurTime();
	
	MsgC(COLOR_WHITE,"["..os.date().."] ")
	for k,v in pairs(tblText)do
		local color = chatColorDefault;
		if type(v) == "string" then
			MsgC(color,v);
		elseif type(v) == "table" and v.a and v.g and v.b then
			color = v;
		elseif type(v) == "Player" and IsValid(v) and v:IsPlayer() then
			MsgC(team.GetColor(v:Team()),v:Nick());
		end
	end
	MsgC(COLOR_WHITE,"\n");
	
	constrPre = nil;
end

local guiEnabled = false;-- we use normal drawing when no gui is enabled.
local x = 20;
local alpha = 0;
surface.CreateFont("exclChatFont",{
	font = "Roboto",
	size = 16,
	weight = 700,
})
surface.CreateFont("exclChatFontShadow",{
	font = "Roboto",
	size = 16,
	weight = 700,
	blursize = 2
})
surface.SetFont("exclChatFont");
local _,lineHeight = surface.GetTextSize("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()_+}{1234567890");
local simpleText = draw.SimpleText;
local simpleTextOutlined = draw.SimpleTextOutlined;
local getTextSize = surface.GetTextSize
local setFont = surface.SetFont;
local setMaterial = surface.SetMaterial;
local drawTexturedRect = surface.DrawTexturedRect;
local setDrawColor = surface.SetDrawColor;

yNow = ScrH()/100*65 + lineHeight + 10

local colorOutline = Color(0,0,0,80);
local lastShadow = Color(0,0,0);
local lastColor = Color(0,0,0,255); 
local function drawShadow(t,x,y,c)
	if c != lastColor then
		local alpha = 0;
		if c.r > alpha then
			alpha = c.r
		elseif c.g > alpha then
			alpha = c.g
		elseif c.b > alpha then
			alpha = c.b
		end
		lastShadow.a = alpha*0.70;
	end
	simpleText(t,"exclChatFontShadow",x+1,y+1,lastShadow);	
	simpleText(t,"exclChatFontShadow",x+1,y+1,lastShadow);	
	simpleTextOutlined(t,"exclChatFont",x,y,c,0,0,1,colorOutline);
end
hook.Add("HUDPaint","exclDrawChatbox",function()
	if lastAdd + 8 > CurTime() then
		local maxLineWidth = (ScrW()/10)*4;
		setFont("exclChatFont");
		local y = ScrH()/100*55;
		local useColor = chatColorDefault; 
		local yTxt = y + -(lineHeight + 2);

		for a,b in pairs(chatText)do
			yTxt = yTxt + lineHeight + 2;
			local xTxt = x;
			for k,v in pairs(b.tbl)do
				local str = "";
				local len = 0;
				if type(v) == "string" and #v and #v > 0 then
					
					for i=1,string.len(v) do
						len = getTextSize(string.Left(v,i))
						--len = len + w;
						if len > maxLineWidth then
							drawShadow(string.Left(v,i-1),xTxt,yTxt,useColor);
							
							--str = "";
							v = string.Right(v,string.len(v) - i + 1);
							yTxt = yTxt + lineHeight + 1;
							len = 0;
							xTxt = x;
						end 
						--str = string.Left(v,i);
					end					
					
					drawShadow(v,xTxt,yTxt,useColor);					
					
					xTxt=  xTxt+len;
				elseif type(v) == "IMaterial" then
					setMaterial(v);
					setDrawColor(COLOR_WHITE);
					drawTexturedRect(xTxt,yTxt,16,16);
					
					xTxt = xTxt + 16;
				elseif type(v) == "table" and v.r and v.g and v.b and v.a then
					useColor = v;
				end	
			end
		end
		yNow  = yTxt + 10;
	else
		alpha = Lerp(0.02,alpha,0);
		yNow = ScrH()/100*65 + lineHeight + 10
	end
end)
surface.CreateFont("exclChatFontSmall",{
	font = "Roboto",
	size = 14,
	weight = 800,
})
function ES:CloseChatGui()
	if chatGui and IsValid(chatGui) and chatGui:IsVisible() then 
		chatGui:Hide()
	end
end
function ES:OpenChatGui()
	if chatGui and IsValid(chatGui) then 
		chatGui:Show(); 
		chatGui:MakePopup(); 
		lastAdd = CurTime(); 
		return; 
	end
	
	lastAdd = CurTime();
	
	chatGui = vgui.Create("EditablePanel");
	chatGui:SetPos(x, yNow + lineHeight);
	chatGui:SetSize((ScrW()/10*4)+2, lineHeight+6);
	chatGui:MakePopup();
	chatGui.Think = function(self)
		self:SetPos(x,yNow + lineHeight)
		lastAdd = CurTime();
	end
	chatGui.Paint = function(self,w,h)
		draw.RoundedBox(4,0,0,w,h,Color(20,20,20,255))
		draw.RoundedBox(4,1,1,w-2,(h)/2,Color(255,255,255,15))
	end
	
	local entry = vgui.Create("DTextEntry",chatGui)
	entry:StretchToParent(2,2,2,2);
	entry:SetFont("exclChatFontSmall")
	entry:SetEnterAllowed(true);
	entry.GetAutoComplete = function(self,txt)
		if string.Left(txt,1) == "/" or string.Left(txt,1) == "!" or string.Left(txt,1) == ":" or string.Left(txt,1) == "@" then
			local tab = {};
			if string.len(txt) > 1 then
				for k,v in pairs(ES:GetCommandsList())do
					if string.Left(v.name,string.len(txt)-1) == string.Right(txt,string.len(txt)-1) then
						table.insert(tab,string.Left(txt,1)..v.name);
					end
				end
			else
				for k,v in pairs(ES:GetCommandsList())do
					if not v.power or v.power <= LocalPlayer():ESGetRank().power then
						table.insert(tab,string.Left(txt,1)..v.name);
					end
				end
			end
			return tab or {"No commands found!"};
		end
	end
	entry.OnEnter = function()
		local tr = LocalPlayer():GetEyeTrace();
		local t = entry:GetValue();
		t = string.gsub(t,"$player",(IsValid(tr.Entity) and tr.Entity:IsPlayer()) and tr.Entity:Nick() or "nobody");
		t = string.gsub(t,"$entity",(IsValid(tr.Entity) and tr.Entity:IsPlayer()) and tr.Entity:GetClass() or "undefined");
		t = string.gsub(t,"$pos",tostring(LocalPlayer():GetPos()) );
		t = string.gsub(t,"$angles",tostring(LocalPlayer():GetAngles()) );
		t = string.gsub(t,"$self",LocalPlayer():Nick() );
		
		if isTeam then
			RunConsoleCommand("say_team",t);
		else
			RunConsoleCommand("say",t);
		end
		
		entry:SetText("");
		ES:CloseChatGui()
	end
	entry.OnLoseFocus = function() entry:RequestFocus() end
	
	chatGui:RequestFocus();
	entry:RequestFocus();
end

hook.Add( "HUDShouldDraw", "esChatHudDrawPls", function (thing) 
	if ( thing == "CHudChat" ) then 
		return false;
	end
end )

hook.Add("PlayerBindPress","esChatBinds",function(ply, bind, pressed)
	if (ply == LocalPlayer()) then
		if chatGui and IsValid(chatGui) and chatGui:IsVisible() then 
			if (bind == "cancelselect") then ES:CloseChatGui() return true end
			if (bind ~= "toggleconsole") then return true end 
		elseif (bind == "messagemode" or bind == "messagemode2") and pressed then
			isTeam = (bind == "messagemode2")

			ES:OpenChatGui()

			hook.Call("StartChat", GAMEMODE) 
			
			return true
		end
	end
end)

hook.Add("Think","esChatWatchThinkStuff",function()
	if chatGui and IsValid(chatGui) then 
		if input.IsKeyDown(KEY_ENTER) then
			
		elseif input.IsKeyDown(KEY_ESCAPE) then
			ES:CloseChatGui()
		end
	end
end)


function ES:ChatAddText(icon,...)
	local a = {...}
	if a[1] then
		if type(a[1]) == "string" then
			local add = {};
			add[1] = chatColorDefault;
			for k,v in pairs(a)do
				add[k+1] = v;
			end
		else
			add = a;
		end
		esAddText(icon,add)
	end
end
function chat.AddText(...)
	local a = {...}
	if a[1] then
		esAddText("default",a)
	end
end
net.Receive("ESChatPrint",function()
	local icon = net.ReadString();
	local message = net.ReadTable();
	ES:ChatAddText(icon or "default",COLOR_WHITE,unpack(message));
end)
hook.Add("ChatText","esChatTextHooks", function( id, n , text , typ )
	if typ == "joinleave" and text and string.find(text, "join",0,true) then 
		ES:ChatAddText( "join",  chatColorDefault,text);
		return true;
	elseif typ == "joinleave" or (text and ( string.find(text, "left",0,true) or string.find(text, "Disconnect",0,true))) then
		ES.DebugPrint(text)
		return true;
	end

	ES:ChatAddText( "default", chatColorDefault,text);
	
	return false;
end)]]