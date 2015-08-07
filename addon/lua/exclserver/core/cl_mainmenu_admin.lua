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

				local author=header:Add("DLabel")
	  		author:SetColor(ES.Color.White)
	  		author:Dock(LEFT)
	  		author:SetText(" created by "..v:GetAuthor())
	  		author:SetFont("ESDefault")
	  		author:SizeToContents()

	  		local status=header:Add("DLabel")
	  		status:SetColor(ES.Color.White)
	  		status:Dock(RIGHT)
				status:SetText("Enabled")
				status:SetFont("ESDefault")
				status:SizeToContents()

				if LocalPlayer():ESGetRank():GetPower() >= ES.POWER_OWNER then
					local toggleEnabled=row:Add("esToggleButton")
					toggleEnabled:SetText(v:GetDescription())
					toggleEnabled:SetChecked(true)
					toggleEnabled:Dock(BOTTOM)
					toggleEnabled:DockMargin(10,10,10,10)
					toggleEnabled.DoClick = function(self,checked)

					end
				else
					local descr=row:Add("DLabel")
					descr:SetFont("ESDefault")
					descr:SetPos(10,42)
					descr:SetText(v:GetDescription())
					descr:SizeToContents()
					descr:SetColor(ES.Color.White)
				end
	end

	scrollbuddy:SetTall(table.Count(ES.Plugins)*(80))

	local scroll=list:Add("esScrollbar")

  	function list:PerformLayout()
	  	scrollbuddy:SetWide(list:GetWide()-16)

	  	scroll:Setup()
	end
end

function ES._MMGenerateConfiguration(base)
	local frame= base:OpenFrame(380)
  	frame:SetTitle("Configuration")

  	local help=frame:Add("DLabel")
  	help:SetText(ES.FormatLine("This tab is a work in progress. Check back later.","ESDefault+",380))
  	help:SetFont("ESDefault+")
  	help:SetColor(ES.Color.White)
  	help:DockMargin(10,10,10,0)
  	help:SizeToContents()
  	help:Dock(TOP)
end
