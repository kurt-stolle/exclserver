-- cl_chat.lua

local chatPanel;

-- Hooks
hook.Add("HUDShouldDraw", "ES.Chat.DisableCHudChat", function(item)
	if IsValid(chatPanel) and item == "CHudChat" then
		return false;
	end
end)
hook.Add("PlayerBindPress", "ES.Chat.OpenOnBind", function(ply,bind,pressed)
	if bind == "messagemode" and pressed then
		if IsValid(chatPanel) then
			if (GAMEMODE.round_state) then -- For the TTT gamemode
				if ply:IsSpec() and GAMEMODE.round_state == ROUND_ACTIVE and DetectiveMode() then
					LANG.Msg("spec_teamchat_hint")
				else
					chatPanel.team = false

					--open
					hook.Run("StartChat", false)
				end
			else
				chatPanel.team = false
				--open
				hook.Run("StartChat", false)
			end

			return true
		end
	end

	if (bind == "messagemode2" and pressed) then
		if IsValid(chatPanel) then
			chatPanel.team = true

			-- open
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
	
end

function chat.Close()
	
end
function chat.GetChatBoxPos()
	return (IsValid(chatPanel) and chatPanel:GetPos()) or 0,0;
end
function chat.AddText(...)
	-- add text
end

-- Override player meta
local PLAYER=FindMetaTable("Player");
function PLAYER:IsTyping()
	return self:ESGetNetworkedVariable("typing",false);
end