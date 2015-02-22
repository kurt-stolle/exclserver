-- cl_chat.lua

local chatPanel

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
			if name and name != "" then
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

	local tab={};
	for k,v in ipairs{...}do
		if type(v)=="Player" then
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
	base:Dock(TOP);
	base.activeColor=ES.Color.White

	local margin=0;
	MsgC(base.activeColor,os.date("[%dth %b %Y @ %H:%M] "));
	for k,v in ipairs(tab)do
		if type(v) == "table" then
			base.activeColor=v;
			continue;
		end

		MsgC(base.activeColor,v);

		local text=v;
		while (text) do
			local noMatch=true;

			for _,exp in ipairs(ES.Expressions)do
				local startpos,endpos=string.find(v,exp:GetExpression());

				if not startpos or not endpos then continue end

				noMatch=false;

				local before=string.sub(text,1,startpos-1);
				local after=string.sub(text,endpos+1,string.len(text));

				if before and before ~="" then
					local lbl=base:Add("esLabel");
					lbl:SetText(before);
					lbl:SetColor(base.activeColor);
					lbl:SetFont("ESDefault");
					lbl:SizeToContents();

					base:Inline(lbl);
				end

				base:Inline(exp:Execute(base,string.match(string.sub(text,startpos,endpos),exp:GetExpression())));

				if after and after ~= "" then
					text=after;
				else
					text=nil;
				end

				break;
			end

			if noMatch then 
				local lbl=base:Add("esLabel");
					lbl:SetText(text);
					lbl:SetColor(base.activeColor);
					lbl:SetFont("ESDefault");
					lbl:SizeToContents();

					base:Inline(lbl);
				break 
			end
		end
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