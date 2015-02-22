-- cl_voice.lua
-- controls the voice chat panels

if hook.Call("ESSupressCustomVoice") then return end

g_VoicePanelList = nil -- from base gamemode

local voiceRows = {}

hook.Add("PlayerStartVoice","esPlayerStartVoice",function(ply)
	if !hook.Call("ESSupressCustomVoice") then

		if not g_VoicePanelList or not IsValid(g_VoicePanelList) then return true end

	   	local pnl = g_VoicePanelList:Add("esMMPlayerRow") -- check: cl_mainmenu_vgui.lua
	   	pnl:Setup(ply,true)
	   	pnl:PerformLayout()
	   	pnl:SetSize(275,52)

	   	voiceRows[ply] = pnl


	    return true

	end
end)

local function VoiceClean()
	if hook.Call("ESSupressCustomVoice") then return end

   	for ply, pnl in pairs( voiceRows ) do
      	if (not IsValid(pnl)) or (not IsValid(ply)) then
        	hook.Call("PlayerEndVoice",GAMEMODE,ply)
      	end
   	end
end
timer.Create( "VoiceClean", 10, 0, VoiceClean )

hook.Add("PlayerEndVoice","esPlayerEndVoice",function(ply, no_reset)
	if !hook.Call("ESSupressCustomVoice") then

		if IsValid( voiceRows[ply] ) then
			voiceRows[ply]:Remove()
			voiceRows[ply] = nil
		end

		return true
	end
end)

hook.Add( "InitPostEntity", "CreateVoiceVGUI",function()
	if !hook.Call("ESSupressCustomVoice") then
	    g_VoicePanelList = vgui.Create( "DPanel" )

	    g_VoicePanelList:ParentToHUD()
	    g_VoicePanelList:SetPos(ScrW()-38-(275*2 + 5), 140)
	    g_VoicePanelList:SetSize(275*2 + 5, ScrH() - (140+80))
	    g_VoicePanelList:SetDrawBackground(false)

	    function g_VoicePanelList:Think()
	    	local countActual = 0
	    	local row = 0
	    	for k,v in pairs(voiceRows)do
	    		if k and v and IsValid(v) and IsValid(k) then
	    			if (countActual+1)*56 > self:GetTall() then
	    				row = 1
	    				countActual = 0
	    			end

	    			countActual = countActual+1

	    			v:SetPos(self:GetWide() - 275 - (row*280),self:GetTall() - countActual*56)

	    			
	    		elseif v and IsValid(v) and (k and not IsValid(k)) then
	    			hook.Call("PlayerEndVoice",GAMEMODE,k)
	    		end
	    	end
	    end
	end
end)