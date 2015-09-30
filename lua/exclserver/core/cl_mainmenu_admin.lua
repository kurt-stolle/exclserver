-- cl_mainmenu_admin.lua
-- admin features in the main menu

function ES._MMGenerateCommands(base)
	local frame= base:OpenFrame(500)
  	frame:SetTitle("Commands")

  	local help=frame:Add("DLabel")
  	help:SetText(ES.FormatLine("These commands can be executed in chat by adding the ':' prefix character.","ESDefault+",380))
  	help:SetFont("ESDefault+")
  	help:SetColor(ES.Color.White)
  	help:DockMargin(10,10,10,0)
  	help:SizeToContents()
  	help:Dock(TOP)

  	local list=frame:Add("Panel")
  	list:DockMargin(10,10,10,0)
  	list:Dock(FILL)

  	local scrollbuddy=list:Add("Panel")

  	for k,v in pairs(ES.Commands)do
	  		local row=scrollbuddy:Add("esPanel")
	  		row:SetColor(ES.GetColorScheme(2))
	  		row:SetTall(26)
	  		row:Dock(TOP)
	  		row:DockMargin(0,0,0,10)
	  		row:DockPadding(10,0,10,0)

	  		local txt=row:Add("DLabel")
	  		txt:SetColor(ES.Color.White)
	  		txt:Dock(LEFT)
	  		txt:SetText(k)
	  		txt:SetFont("ESDefaultBold")
	  		txt:SizeToContents()

	  		local rankname="No required rank"
	  		if v.power > 0 then
	  			local lowestPower
		  		for _,rank in ipairs(ES.Ranks)do
		  			if (not lowestPower or rank:GetPower() < lowestPower) and rank:GetPower() >= v.power then
		  				lowestPower = rank:GetPower()
		  				rankname=rank:GetPrettyName()
		  			end
		  		end
		  	end

	  		local txt=row:Add("DLabel")
	  		txt:SetColor(ES.Color.White)
	  		txt:Dock(RIGHT)
		txt:SetText(rankname)
		txt:SetFont("ESDefault")
		txt:SizeToContents()
	end

	scrollbuddy:SetTall(table.Count(ES.Commands)*(26+10))

	local scroll=list:Add("esScrollbar")

  	function list:PerformLayout()
	  	scrollbuddy:SetWide(list:GetWide()-16)

	  	scroll:Setup()
	end
end

function ES._MMGeneratePlugins(base)
	local frame= base:OpenFrame(800)
  	frame:SetTitle("Plugins")

  	local help=frame:Add("DLabel")
  	help:SetText(ES.FormatLine("These are all ExclServer plugins currently installed on the server.","ESDefault+",380))
  	help:SetFont("ESDefault+")
  	help:SetColor(ES.Color.White)
  	help:DockMargin(10,10,10,0)
  	help:SizeToContents()
  	help:Dock(TOP)

  	local list=frame:Add("Panel")
  	list:DockMargin(10,10,10,0)
  	list:Dock(FILL)

  	local scrollbuddy=list:Add("Panel")
		local tall=0;
  	for k,v in pairs(ES.Plugins)do
	  		local row=scrollbuddy:Add("esPanel")
	  		row:SetColor(ES.GetColorScheme(3))
	  		row:SetTall(70)
	  		row:Dock(TOP)
	  		row:DockMargin(0,0,0,10)

				local header=row:Add("esPanel")
				header:SetColor(ES.GetColorScheme(2))
				header:SetTall(32)
				header:Dock(TOP)
				header:DockPadding(10,0,10,0)

	  		local name=header:Add("DLabel")
	  		name:SetColor(ES.Color.White)
	  		name:Dock(LEFT)
	  		name:SetText(v:GetName())
	  		name:SetFont("ESDefaultBold")
	  		name:SizeToContents()

				local info=header:Add("DLabel")
	  		info:SetColor(ES.Color.White)
	  		info:Dock(LEFT)
	  		info:SetText(" "..v:GetVersion())
	  		info:SetFont("ESDefault")
	  		info:SizeToContents()

	  		local status=header:Add("esToggleButton")
	  		status.PerformLayout = function(status)
					status:SetPos(header:GetWide() - status:GetWide()-8,8)
				end
				status.DoClick = function(status,enabled)
					net.Start("exclserver.settings.send");
					net.WriteString("PLUGIN:"..v:GetName()..".Enabled");
					net.WriteString(tostring(enabled))
					net.SendToServer();
				end
				status:SetChecked(ES.GetSetting("PLUGIN:"..v:GetName()..".Enabled",false));

				local descr=row:Add("DLabel")
				descr:SetFont("ESDefault")
				descr:Dock(BOTTOM)
				descr:DockMargin(10,0,10,10)
				descr:SetText(v:GetDescription())
				descr:SizeToContents()
				descr:SetColor(ES.Color.White)

				local prfx="PLUGIN:"..v:GetName()..".";
				for k,v in pairs(ES.GetSettings())do
					if string.find(k,prfx,0,false) and k ~= prfx.."Enabled" then
						ES.DebugPrint("Added Config option to menu: "..k);
						local toggleEnabled=row:Add("esToggleButton")
						toggleEnabled:SetText(string.gsub(string.gsub(k,prfx,""),"%."," "))
						toggleEnabled:SetChecked(true)
						toggleEnabled:Dock(BOTTOM)
						toggleEnabled:DockMargin(10,10,10,10)
						toggleEnabled.DoClick = function(self,checked)
							net.Start("exclserver.settings.send");
							net.WriteString(k);
							net.WriteString(tostring(checked))
							net.SendToServer();
						end

						row:SetTall( row:GetTall() + toggleEnabled:GetTall() + 20 )
					end
				end

				tall=tall+row:GetTall()+10;
	end

	scrollbuddy:SetTall(tall)

	local scroll=list:Add("esScrollbar")

  	function list:PerformLayout()
	  	scrollbuddy:SetWide(list:GetWide()-16)

	  	scroll:Setup()
	end
end

function ES._MMGenerateConfiguration(base)
	local frame= base:OpenFrame(800)
  	frame:SetTitle("Configuration")

  	local help=frame:Add("DLabel")
  	help:SetText(ES.FormatLine("These are all non-plugin related settings. For plugin settings see the Plugins tab.","ESDefault+",380))
  	help:SetFont("ESDefault+")
  	help:SetColor(ES.Color.White)
  	help:DockMargin(10,10,10,0)
  	help:SizeToContents()
  	help:Dock(TOP)

		for k,v in ipairs(ES.GetSettings())do
			if not string.find(v,"PLUGIN",1,true) then
				local pnl=ES.UICreateSettingModPanel(v)
				pnl:SetWide(360)
				pnl:Dock(TOP)
				pnl:SetParent(frame)
			end
		end
end
