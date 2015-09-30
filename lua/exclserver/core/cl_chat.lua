-- cl_chat.lua
local chatPanel;
local chatOpen = chat.Open
local chatClose = chat.Close
local chatPos = chat.GetChatBoxPos
local chatAdd = chat.AddText
function chat.AddText(...)
	local new={}
	for k,v in ipairs{...}do
		if type(v) == "string" then
			//<(.-)>(.-)</(.-)> parse this
		end
		table.insert(new,v);
	end
	chatAdd(unpack(new));
end
chatAdd=chat.AddText;

hook.Add("ESSettingsChanged","exclserver.motd.update",function(setti)
	if not ES.GetSetting("General:Chatbox.Enabled",true) then
		if IsValid(chatPanel) then
			chatPanel:Remove();
			timer.Destroy("ES.AdvertiseInChat")
			hook.Remove("HUDShouldDraw", "ES.Chat.DisableCHudChat")
			hook.Remove("PlayerBindPress", "ES.Chat.OpenOnBind")
			hook.Remove("ChatText", "ES.Chat.ChatText")
			hook.Remove("ChatText", "ES.Chat.ChatText")
		end
		return
	end

	ES.CreateFont("ESChatFont.Shadow",{
		font=ES.Font,
		size=18,
		weight=400,
		blursize=2
	})
	ES.CreateFont("ESChatFont",{
		font=ES.Font,
		size=18,
		weight=400
	})
	ES.CreateFont("ESChatFont.Italic.Shadow",{
		font=ES.Font,
		size=18,
		weight=400,
		italic=true,
		blursize=2
	})
	ES.CreateFont("ESChatFont.Italic",{
		font=ES.Font,
		size=18,
		weight=400,
		italic=true
	})
	ES.CreateFont("ESChatFont.Bold.Shadow",{
		font=ES.Font,
		size=18,
		weight=700,
		blursize=2
	})
	ES.CreateFont("ESChatFont.Bold",{
		font=ES.Font,
		size=18,
		weight=700
	})

	local ads={
		"Visit our forums at <url>community.casualbananas.com</url>!",
		"Donate and receive <hl>1000 bananas</hl> for every <hl>1 USD</hl> you donate. Type <hl>!donate</hl> in chat to donate!",
		"Press <hl>ESC</hl> to open ExclServer, where you can spend your bananas.",
		"Put <hl>[CB]</hl> in your steam name to join our community!",
		"You are playing on a <hl>Casual Bananas</hl> community server.",
	}
	timer.Create("ES.AdvertiseInChat",60*5,0,function()
		local str=table.Random(ads)
		chat.AddText(ES.Color.White,str)
	end)

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
		local activeColor=ES.Color.White
		MsgC(ES.Color.BlueGrey,os.date("[%d %b %Y @ %H:%M] "));
		for k,v in ipairs{...}do
			if type(v)=="Player" then
				table.insert(tab,"<av="..v:SteamID().."> ");
			 	table.insert(tab,team.GetColor(v:Team()));
			 	table.insert(tab,v:Nick());
				MsgC(activeColor,v:Nick());
			elseif type(v)=="string" then
				if type(tab[#tab])=="string" then
					tab[#tab]=tab[#tab]..v;
				else
					table.insert(tab,v);
				end
				MsgC(activeColor,v);
			elseif type(v)=="table" and v.r and v.g and v.b then
				table.insert(tab,v);
				activeColor=v
			elseif type(v) ~= "nil" then
				v=tostring(v);

				MsgC(activeColor,v);

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

		for k,v in ipairs(tab)do
			if type(v) == "table" then
				base.activeColor=v;
				continue
			end

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
					lbl:SetShadow(2)
					lbl:SizeToContents();
					lbl:SetLineHeight(lineHeight);

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
						lbl:SetShadow(2)

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
				base:Inline(v,lineHeight);
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

	-- Chatbox!
	chatPanel=vgui.Create("esChat");
	chatPanel:SetSize(500,240);
	chatPanel:SetPos(10,ScrH()-chatPanel:GetTall()-100);
	chatPanel:SetVisible(false);

	chat.AddText("Wecome to "..ES.GetSetting("Community:Name","my server").."!")
end);

net.Receive("ES.ChatBroadcast",function()
	chat.AddText(unpack(net.ReadTable()))
end)
