-- cl_chat.lua

surface.CreateFont("ESChatFont",{
	font="Calibri",
	size=20,
	weight=500
})
surface.CreateFont("ESChatFont.Italic",{
	font="Calibri",
	size=20,
	weight=500,
	italic=true
})
surface.CreateFont("ESChatFont.Bold",{
	font="Calibri",
	size=20,
	weight=800
})

local chatPanel

local lineHeight=24;

-- Hooks
hook.Add("HUDShouldDraw", "ES.Chat.DisableCHudChat", function(item)
	if IsValid(chatPanel) and item == "CHudChat" then
		return false
	end
end)
hook.Add("PlayerBindPress", "ES.Chat.OpenOnBind", function(ply,bind,pressed)
	if bind == "messagemode" and pressed then
		if IsValid(chatPanel) then
			if (GAMEMODE.round_state) then -- For the TTT gamemode
				if ply:IsSpec() and GAMEMODE.round_state == ROUND_ACTIVE and DetectiveMode() then
					LANG.Msg("spec_teamchat_hint")
				else
					chatPanel._team = false
					chat.Open()
					hook.Run("StartChat", false)
				end
			else
				chatPanel._team = false
				chat.Open()
				hook.Run("StartChat", false)
			end

			return true
		end
	end

	if (bind == "messagemode2" and pressed) then
		if IsValid(chatPanel) then
			chatPanel._team = true
			chat.Open()
			hook.Run("StartChat", true)
			
			return true
		end
	end
end)
hook.Add("ChatText", "ES.Chat.ChatText", function(index, name, text, filter)
	if tonumber(index) == 0 then
		if filter == "joinleave" then
			return ""
		elseif filter == "none" and name == "Console" then
			chat.AddText(ES.Color.White, text)
		elseif filter == "chat" then
			if name and name ~= "" then
				chat.AddText(ES.Color["#FAFAFA"], name, ES.Color.White, text)
			else
				timer.Simple(0, function() chat.AddText(ES.Color.White, text) end)
			end
		end
	end
end)

-- Override chat library
function chat.Open()
	if IsValid(chatPanel) then 
		chatPanel:SetVisible(true);
	end
end

function chat.Close()
	if IsValid(chatPanel) then
		chatPanel:SetVisible(false);
	end
end
function chat.GetChatBoxPos()
	return (IsValid(chatPanel) and chatPanel:GetPos()) or 0,0
end
function chat.AddText(...)
	if not IsValid(chatPanel) then return end

	chatPanel.becomeInvisible=CurTime()+3;

	local tab={};
	for k,v in ipairs{...}do
		if type(v)=="Player" then
			table.insert(tab,"<av="..v:SteamID().."> ");
		 	table.insert(tab,team.GetColor(v:Team()));
		 	table.insert(tab,v:Nick());
		elseif type(v)=="string" then
			if type(tab[#tab])=="string" then
				tab[#tab]=tab[#tab]..v;
			else
				table.insert(tab,v);
			end
		elseif type(v)=="table" and v.r and v.g and v.b then
			table.insert(tab,v);
		else
			v=tostring(v);

			if type(tab[#tab])=="string" then
				tab[#tab]=tab[#tab]..v;
			else
				table.insert(tab,v);
			end
		end
	end

	local base=vgui.Create("esPanel",chatPanel.container);
	base:SetColor(ES.Color.Invisible);
	base:SetWide(chatPanel.container:GetWide());
	base:SetTall(lineHeight);
	base:Dock(TOP);
	base:DockMargin(4,4,4,2);
	base.activeColor=ES.Color.White

	local margin=0;
	MsgC(base.activeColor,os.date("[%dth %b %Y @ %H:%M] "));
	for k,v in ipairs(tab)do
		if type(v) == "table" then
			base.activeColor=v;
			continue;
		end

		--MsgC(base.activeColor,v);

		local panels={};
		local startposEarliest,endposEarliest,expressionFound,noMatch;
		local function parse(text)

			noMatch=true;
			startposEarliest,endposEarliest,expressionFound=nil,nil,nil;

			for _,exp in ipairs(ES.Expressions)do
				local startpos,endpos=string.find(text,exp:GetExpression());

				if not startpos or not endpos then continue end

				if not startposEarliest or startposEarliest > startpos then
					startposEarliest=startpos;
					endposEarliest=endpos;
					expressionFound=exp;
				end

				noMatch=false;
			end

			if noMatch then 
				local lbl=base:Add("esLabel");
				lbl:SetText(text);
				lbl:SetColor(base.activeColor);
				lbl:SetFont("ESChatFont");
				lbl:SizeToContents();

				table.insert(panels,lbl);
			elseif startposEarliest and endposEarliest and expressionFound then
				local before=string.sub(text,1,startposEarliest-1);
				local current=string.sub(text,startposEarliest,endposEarliest);
				local after=string.sub(text,endposEarliest+1,string.len(text));

				if before and before ~= "" then
					local lbl=base:Add("esLabel");
					lbl:SetText(before);
					lbl:SetColor(base.activeColor);
					lbl:SetFont("ESChatFont");
					lbl:SizeToContents();

					table.insert(panels,lbl);
				end
				table.insert(panels,expressionFound:Execute(base,string.match(current,expressionFound:GetExpression())));
				if after and after ~="" then
					parse(after)
				end
			end
		end
		parse(v);

		for k,v in ipairs(panels)do
			base:Inline(v);
		end

		base:UpdateTall();
	end

	MsgC(color,"\n");
end

-- Override player meta
local PLAYER=FindMetaTable("Player")
function PLAYER:IsTyping()
	return self:ESGetNetworkedVariable("typing",false)
end

hook.Add("Initialize","ES.CreateChatBox",function()
	chatPanel=vgui.Create("esChat");
	chatPanel:SetSize(500,300);
	chatPanel:SetPos(10,ScrH()-chatPanel:GetTall()-110);
	chatPanel:SetVisible(false);
end);