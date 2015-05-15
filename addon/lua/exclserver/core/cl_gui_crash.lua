-- cl_crash.lua
local lastmovetime = CurTime() + 10 -- Variable to check when move packets were last received
local reconnecttime = math.min(GetConVarNumber("sv_timeout") - 6 , GetConVarNumber("cl_timeout") - 6 , 30) -- in seconds
local crashtime = 1
local shouldretry = true
local crashed = false
local spawned = false
local pending = false
local spawntime

local apology = [[There appears to be a problem with your connection to the server. 
This can be caused by two things, your connection to the internet or the server's connection to the internet is experiencing problems.
]]

ES.CreateFont("ESConnectionProblem",{
	font = "Arial Narrow",
	size = 52,
})
ES.CreateFont("ESConnectionAlternatives",{
	font = "Arial Narrow",
	size = 32
})
ES.CreateFont("ESConnectionAlternativesName",{
	font = "Arial",
	size = 20,
	weight = 700,
})

ES.CreateFont("ESConnectionCloseRetry",{
	font = "Arial Narrow",
	size = 24,
	weight = 500,
})

local crashPnl
local function createMenu()

        local menucrashtime = CurTime()
        local retrytime = menucrashtime + reconnecttime
       
        for k , v  in ipairs(player.GetAll()) do
            v.CrashedPing = v:Ping()
        end
 		
 		if crashPnl and IsValid(crashPnl) then
 			crashPnl:Remove()
 		end

 		crashPnl = vgui.Create("Panel")
 		crashPnl:SetSize(ScrW(),ScrH())
 		crashPnl:SetPos(0,0)

 		surface.SetFont("ESConnectionProblem")
 		local wideText = surface.GetTextSize("Connection Problem")
 		crashPnl.Paint = function(self,w,h)
 			local a,b,c = ES.GetColorScheme()

 			surface.SetDrawColor(Color(50,50,50))
 			surface.DrawRect(0,0,w,h)

 			surface.SetDrawColor(b)
 			surface.DrawRect(0,0,w,4)

 			surface.SetDrawColor(a)
 			surface.DrawRect(0,ScrH()-60,w,60)

 			draw.SimpleText("Connection Problem","ESConnectionProblem",10,40,COLOR_WHITE)
 			
 			draw.SimpleText(string.format("You will automatically try a reconnect in %d seconds", retrytime - CurTime()),"ESDefaultBold",15,95,COLOR_WHITE)

 			local txt = ES.FormatLine( apology, "ESDefault", wideText )

 			draw.DrawText(txt,"ESDefault",15,95+100,COLOR_WHITE)

 		end

 		local btnClose = vgui.Create("esIconButton",crashPnl)
		btnClose:SetIcon(Material("exclserver/mmarrowicon.png"))
		btnClose:SetPos((60-32)/2,ScrH() - (60-32)/2 - 32)
		btnClose:SetSize(250,32)
		btnClose.DoClick = function(self)
			if crashPnl and IsValid(crashPnl) then
			 	crashPnl:Remove()
			 end
		end
		btnClose.Paint = function(self,w,h)
			if not self.Mat then return end
			
			surface.SetMaterial(self.Mat)
			surface.SetDrawColor(COLOR_WHITE)
			surface.DrawTexturedRectRotated(h/2,h/2,h,h,180)

			draw.SimpleText("Close","ESConnectionCloseRetry",40,h/2,COLOR_WHITE,0,1)
		end

		local btnClose = vgui.Create("esIconButton",crashPnl)
		btnClose:SetIcon(Material("exclserver/mmarrowicon.png"))
		btnClose:SetPos(ScrW() - 250 - (60-32)/2,ScrH() - (60-32)/2 - 32)
		btnClose:SetSize(250,32)
		btnClose.DoClick = function(self)
			if crashPnl and IsValid(crashPnl) then
			 	LocalPlayer():ConCommand("retry")
			 end
		end
		btnClose.Paint = function(self,w,h)
			if not self.Mat then return end
			
			surface.SetMaterial(self.Mat)
			surface.SetDrawColor(COLOR_WHITE)
			surface.DrawTexturedRectRotated(w-h/2,h/2,h,h,0)

			draw.SimpleText("Force reconnect","ESConnectionCloseRetry",w-40,h/2,COLOR_WHITE,2,1)
		end

 		local alt = crashPnl:Add("Panel")
 		alt:SetPos(wideText + 40 + 40, 45)
 		alt:SetSize(ScrW() - (wideText + 40 + 40) - 40, ScrH()-45-20-60)

 		local lbAlt = Label("Alternative Servers:",alt)
 		lbAlt:SetPos(0,0)
 		lbAlt:SetFont("ESConnectionAlternatives")
 		lbAlt:SizeToContents()
 		lbAlt:SetColor(COLOR_WHITE)

 		local context = alt:Add("Panel")
 		context:SetPos(0,40)
 		context:SetSize(alt:GetWide(),alt:GetTall()-40)


 		http.Fetch("http://casualbananas.com/forums/inc/servers/cache/servers.gmod.json.php",
			function(rtrn)
				if !crashPnl or !IsValid(crashPnl) then return end

				cbcservers = util.JSONToTable(rtrn)
				
				if not cbcservers then return end
				
				local y = 0
				for k,v in pairs(cbcservers)do
					if v.ip == exclGetIP() then continue end

					local pnl = context:Add("esMMPanel")
					local a,b,c = ES.GetColorScheme()
					pnl:SetColor(b)
					pnl:SetSize(context:GetWide()-15-2,40)
					pnl:SetPos(0,y)

					local bar = pnl:Add("esMMPanel")
					bar:SetColor(c)
					bar:SetSize(6,pnl:GetTall()-4)
					bar:SetPos(2,2)

					local lbName = Label(string.gsub(v.name,"CasualBananas.com |",""),pnl)
					lbName:SetFont("ESConnectionAlternativesName")
					lbName:SetPos(10,2)
					lbName:SizeToContents()
					lbName:SetColor(COLOR_WHITE)

					local lbPlayers = Label(v.players.."/"..v.maxplayers.." players online, playing on "..v.mapname,pnl)
					lbPlayers:SetFont("ESDefault-")
					lbPlayers:SetPos(15,lbName.y + lbName:GetTall()+2)
					lbPlayers:SizeToContents()
					lbPlayers:SetColor(Color(230,230,230))

					local con = vgui.Create("esButton",pnl)
					con:SetPos(pnl:GetWide()-150,5)
					con:SetSize(145,(pnl:GetTall()-10))
					con.DoClick = function()
						LocalPlayer():ConCommand("connect "..v.ip)
					end
					con:SetText("Connect")					

					y = y + pnl:GetTall() + 5

				end	

				if y > context:GetTall() then
					local scr = context:Add("esScrollbar")
					scr:SetPos(context:GetWide()-15,0)
					scr:SetSize(15,context:GetTall())
					scr:SetUp()
				end
			end,
			function() end
		)
		

	crashPnl:MakePopup()
       
   hook.Add("Think" , "Crashed" , function()
		for k , v in ipairs(player.GetAll()) do
			if v.CrashedPing ~= v:Ping() then
				ES.DebugPrint("Connection regained (ping changed)")
				hook.Remove("Think" , "Crashed")
				crashed = false
				lastmovetime = CurTime() + 5
			end
		end
		
		local moving = false
		
		for k , v in ipairs(ents.GetAll()) do
			if v:GetVelocity():Length() > 5 then
				moving = true
				break
			end
		end
		
		if moving then
			hook.Remove("Think" , "Crashed")
			ES.DebugPrint("Connection regained (moving)")
			crashed = false
			lastmovetime = CurTime() + 5
		end
		
	
		if crashed and (retrytime - CurTime() - 0.5) < 0 and lastmovetime + 5 < CurTime() then
			if shouldretry then
				RunConsoleCommand("retry")
			end
		elseif lastmovetime + crashtime - 1 > CurTime() then
			hook.Remove("Think" , "Crashed")
			crashed = false
			if crashPnl and IsValid(crashPnl) then
			 	crashPnl:Remove()
			 end
		end
	end )
end

local function IsCrashed()
	if not crashed then
		if spawned and spawntime < CurTime() then
			if lastmovetime + crashtime < CurTime() then
				if (LocalPlayer and IsValid(LocalPlayer()) and not LocalPlayer():IsFrozen() and not LocalPlayer():InVehicle()) then
					return true
				end
			end
		end
	end
end

net.Receive("ESCrashPong", function()
	lastmovetime = CurTime() + 10
	ES.DebugPrint("Connection regained (pong)")
end )

hook.Add("Move" , "ESCrashReconnect" , function()
	lastmovetime = CurTime()
end )

hook.Add("InitPostEntity" , "ESCrashReconnect" , function()
	spawned = true
	spawntime = CurTime() + 30
end )

local test = 0
hook.Add("Think" , "ESCrashReconnect" , function()
	if not game.SinglePlayer() then	
		if not crashed and IsCrashed() and not pending then
			pending = true
			RunConsoleCommand("excl_ping")
		
			test = CurTime() + 3.5

			ES.DebugPrint("Connection lost! Sending ping!")
		end

		if test and test ~= 0 and test < CurTime() then
			if lastmovetime + crashtime < CurTime() then
				ES.DebugPrint("Connection to gameserver lost")
				crashed = true
				shouldretry = true
				pending = false
				
				createMenu()
			else
				ES.DebugPrint("Connection to gameserver regained")
				pending = false
				crashed = false
			end

			test = 0
		end
	end
end )