-- the new main
local mm;

local helpText = [[ExclServer is an all-in-one server system that handles items, forums, administration and has a plugin framework.
The global currency used to buy items is Bananas. You can earn these bananas simply by playing, or you can purchase then
on the forum.

Bananas can be spent in the shop menu (accessable from this screen).
If you are not familar with ExclServer the best way to get to know it is to simply explore these menus, we would suggest you
to click the 'My account' tab and make a forum account or link your existing account. Doing so will give you 500 bananas.
Bananas are shared across all our servers (including the forums). This means that bananas earned on one server are 
automatically transferred
to all other servers.


ExclServer is created and constructed by Excl.]]

surface.CreateFont("Coolvetica28",{
	font = "Roboto",
	size = 28,
})
local needvip;
function openNeedVIP(tier)
	if needvip and IsValid(needvip) then needvip:Remove() end
	needvip= vgui.Create("esFrame");
	needvip:SetTitle("VIP Exclusive");
	local l = Label("You need "..tier.." VIP.\nClick on VIP to check out the available VIP tiers.",needvip)
	l:SetPos(15,45);
	l:SizeToContents();
	l:SetColor(COLOR_WHITE);
	needvip:SetSize(15+l:GetWide()+15,45+l:GetTall()+15);
	needvip:Center();
	needvip:MakePopup();
end
local workingon;
function openWorkingOnIt()
	if workingon and IsValid(workingon) then workingon:Remove() end
	workingon= vgui.Create("esFrame");
	workingon:SetTitle("Sorry!");
	local l = Label("This feature is not yet implemented.\nI'm working on getting this all to work.\n\n~ Excl",workingon)
	l:SetPos(15,45);
	l:SizeToContents();
	l:SetColor(COLOR_WHITE);
	workingon:SetSize(15+l:GetWide()+15,45+l:GetTall()+15);
	workingon:Center();
	workingon:MakePopup();
end
local pnlConfirm;
function makePurchaseConfirmer(cost,item,typ)
	if pnlConfirm and IsValid(pnlConfirm) then pnlConfirm:Remove() end
	pnlConfirm = vgui.Create("esFrame");
	if LocalPlayer():ESHasItem(item,typ) then
		pnlConfirm:SetTitle("Nope");
		local l = Label("You already own this item.\nSilly you!",pnlConfirm)
		l:SetPos(15,45);
		l:SizeToContents();
		l:SetColor(COLOR_WHITE);
		pnlConfirm:SetSize(15+l:GetWide()+15,45+l:GetTall()+15);
	elseif LocalPlayer():ESGetBananas() < cost then
		pnlConfirm:SetTitle("Nope");
		local l = Label("It would appear that you do not have enough bananas.\nTry again when you have enough bananas to make this purchase.",pnlConfirm)
		l:SetPos(15,45);
		l:SizeToContents();
		l:SetColor(COLOR_WHITE);
		pnlConfirm:SetSize(15+l:GetWide()+15,45+l:GetTall()+15);
	else
		if pnlConfirm and IsValid(pnlConfirm) then pnlConfirm:Remove() end
		pnlConfirm = vgui.Create("esFrame");
		pnlConfirm:SetTitle("Are you sure");
		local l = Label("You're about to buy an item for "..cost.." bananas.\nThere are no refunds, make sure you selected the right item.\nAre you sure you want to make this purchase?",pnlConfirm)
		l:SetPos(15,45);
		l:SizeToContents();
		l:SetColor(COLOR_WHITE);
		local b = pnlConfirm:Add("esButton")
		b:SetSize(((15+l:GetWide()+15)/2)-15,30);
		b:SetPos(10,l.y+l:GetTall()+10);
		b.Text = "Confirm"
		b.DoClick = function()
			if pnlConfirm and IsValid(pnlConfirm) then pnlConfirm:Remove() end
			
			local sType = "trail"
			if typ == ITEM_TRAIL then
				sType = "trail"
				--LocalPlayer().excl.activetrail = item;
				--table.insert(LocalPlayer()._es_inventory_trails,item);
			elseif typ == ITEM_MELEE then
				sType = "melee"
				--LocalPlayer().excl.activemelee = item;
				--table.insert(LocalPlayer()._es_inventory_meleeweapons,item);
			elseif typ == ITEM_MODEL then
				sType = "model"
				--LocalPlayer().excl.activemodel = item;
				--table.insert(LocalPlayer()._es_inventory_models,item);
			elseif typ == ITEM_AURA then
				sType = "aura"
				--LocalPlayer().excl.activeaura = item;
				--table.insert(LocalPlayer()._es_inventory_auras,item);
			elseif typ == ITEM_PROP then
				sType = "prop"
				--LocalPlayer():ESGetInventory():AddItem(item,1);
			end


			RunConsoleCommand("excl","buy",item,sType);
		end
		local b = pnlConfirm:Add("esButton")
		b:SetSize(((15+l:GetWide()+15)/2)-15,30);
		b:SetPos(10+10+b:GetWide(),l.y+l:GetTall()+10);
		b.DoClick = function()
			if pnlConfirm and IsValid(pnlConfirm) then pnlConfirm:Remove() end
		end
		b.Text = "Cancel"
		b.Evil = true;
		pnlConfirm:SetSize(15+l:GetWide()+15,b.y+b:GetTall()+15);
	end
	pnlConfirm:Center();
	pnlConfirm:MakePopup();
end

local function addCheckbox(help,txt,convar,x,y,oncheck)

	local togOwn = vgui.Create("esToggleButton",help);
	togOwn:SetPos(x,y);
	togOwn:SetSize(help:GetWide()-30,22);
	togOwn.Text = txt
	togOwn.DoClick = function(self)
		if self:GetChecked() then
			LocalPlayer():ConCommand(convar.." 1")
			oncheck(togOwn);
		else
			LocalPlayer():ConCommand(convar.." 0")
			oncheck(togOwn);
		end
	end
	togOwn:SetChecked(GetConVar(convar):GetBool());
end
function ES:CreateMainMenu()
	if mm and IsValid(mm) then mm:Remove(); end
	
	mm = vgui.Create("ESMainMenu");
	mm:SetPos(0,0);
	mm:SetSize(ScrW(),ScrH());
	mm:MakePopup();

	--### main items
	mm:AddButton("Main",Material("icon16/car.png"),function() 
		mm:OpenChoisePanel({
			{icon = Material("exclserver/help.png"), name = "Help",func = function()
				local p = mm:OpenFrame(640)
				p:SetTitle("Help");
				local l = Label(helpText,p);
				l:SetColor(Color(255,255,255,200));
				l:SetPos(15,15);
				l:SizeToContents();
			end},
			{icon = Material("exclserver/settings.png"), name = "Settings",func = function()
				local p = mm:OpenFrame(300)
				p:SetTitle("Settings");

				addCheckbox(p,"Hide all trails","excl_trails_disable",15,15,function()
					timer.Simple(.5,function()
						RunConsoleCommand( "excl_trails_reload")
					end);
				end);
				--addCheckbox(p,"Hide all hats","excl_hats_disable",15,15+22+5,function() end);
			end},
			{icon = Material("icon32/wand.png"), name = "Colors",func = function()
				local p = mm:OpenFrame(300)
				p:SetTitle("Colors");

				local l = Label("Color scheme",p)
				l:SetFont("Coolvetica28");
				l:SetPos(15,15);
				l:SizeToContents();
				l:SetColor(COLOR_WHITE);

				local f,s,t = ES.GetColorScheme();

				local firstCube = p:Add("DColorMixer");
				local secondCube = p:Add("DColorMixer");
				local thirdCube = p:Add("DColorMixer");

				firstCube:SetPos(15,l.y+l:GetTall()+10);
				firstCube:SetSize(256,200);
				firstCube:SetLabel("Primary Color")
				firstCube:SetColor(f);
				function firstCube:ValueChanged()
					ES.PushColorScheme(firstCube:GetColor(),secondCube:GetColor(),thirdCube:GetColor())
				end

				
				secondCube:SetPos(15,firstCube.y+firstCube:GetTall()+10);
				secondCube:SetSize(256,200);
				secondCube:SetLabel("Secondary Color")
				secondCube:SetColor(s);
				function secondCube:ValueChanged()
					ES.PushColorScheme(firstCube:GetColor(),secondCube:GetColor(),thirdCube:GetColor())
				end

				thirdCube:SetPos(15,secondCube.y+firstCube:GetTall()+10);
				thirdCube:SetSize(256,200);
				thirdCube:SetLabel("Third Color")
				thirdCube:SetColor(t);
				function thirdCube:ValueChanged()
					ES.PushColorScheme(firstCube:GetColor(),secondCube:GetColor(),thirdCube:GetColor())
				end

				local b = vgui.Create("esButton",p);
				b:SetSize(100,30);
				b:SetPos(p:GetWide()-100-20,15)
				b:SetText("Reset")
				b.DoClick = function()
					ES.PushColorScheme();
					f,s,t = ES.GetColorScheme();
					firstCube:SetColor(f);
					secondCube:SetColor(s);
					thirdCube:SetColor(t);

					ES.SaveColorScheme();
				end

			end},
		})
	end)
	--mm:AddWhitespace();
	mm:AddButton("Shop",Material("icon16/basket.png"),function() 
		mm:OpenChoisePanel({
			{icon = Material("exclserver/bananas.png"), name = "Items",func = function()
				local p = mm:OpenFrame();
				p:SetTitle("Items shop");

				local mdl = p:Add("DModelPanel");
				mdl:SetSize(500,500);
				mdl:SetPos(p:GetWide()-380,p:GetTall()-501);
				mdl:SetLookAt(Vector(0,0,50));
				mdl:SetCamPos(Vector(100,100,50));
				mdl:SetVisible(false);

				local createIcons; -- prototype
				local rowsX = math.floor((p:GetWide()-15-15-200)/105);
				local rowsY = math.floor((p:GetTall()-15-100)/105);
				local rowsTotal = rowsX * rowsY;
				local icons = {}
				local page = 1;
				local first;
				local pnlInfo = p:Add("esPanel");
				pnlInfo:SetSize(rowsX*105 - 5,100);
				pnlInfo:SetPos(15,p:GetTall()-(100) - 15);
				pnlInfo.color = Color(250,250,250);
				pnlInfo.item = 0;

				local lblInfo = Label("No item selected",pnlInfo);
				lblInfo:SetColor(Color(0,0,0,220));
				lblInfo:SetPos(12,8);
				lblInfo:SetFont("Coolvetica28");
				lblInfo:SizeToContents();

				local lblInfoTxt = Label("",pnlInfo);
				lblInfoTxt:SetPos(15,lblInfo.y+lblInfo:GetTall());
				lblInfoTxt:SizeToContents();
				lblInfoTxt:SetColor(Color(0,0,0,210))

				local buyBtn = vgui.Create("esButton",pnlInfo);
				buyBtn:SetPos(pnlInfo:GetWide()-110,pnlInfo:GetTall()-10-30);
				buyBtn:SetSize(100,30);
				buyBtn.Text = "Buy";
				buyBtn.DoClick = function(self)
					if not self:GetParent().item or not ES.Items[self:GetParent().item] then return end

					if ES.Items[self:GetParent().item]:GetVIPOnly() and LocalPlayer():ESGetVIPTier() <= 0 then
						openNeedVIP("bronze")
						return;
					end

					makePurchaseConfirmer(ES.Items[self:GetParent().item].cost,self:GetParent().item,ITEM_PROP);
				end


				local maxPages = math.ceil(table.Count(ES:GetBuyableItems())/rowsTotal);
				local lblPage = Label("Page "..page.."/"..maxPages,p)
				local butPrev = vgui.Create("esIconButton",p)
				butPrev:SetIcon(Material("exclserver/mmarrowicon.png"));
				butPrev:SetSize(32,32);
				butPrev:SetPos(15 + rowsX*105 +10,15);
				butPrev.DoClick = function(self)
					page = page - 1;
					if page < 1 then page = 1 end;

					createIcons();
					lblPage:SetText("Page "..page.."/"..maxPages)
					lblPage:SizeToContents();
				end
				butPrev.Paint = function(self,w,h)
					if not self.Mat then return end
					
					surface.SetMaterial(self.Mat)
					if page-1 < 1 then
						surface.SetDrawColor(Color(150,150,150));
					else
						surface.SetDrawColor(COLOR_WHITE);
					end
					
					surface.DrawTexturedRectRotated(w/2,w/2,w,w,180);

				end
				local butNext = vgui.Create("esIconButton",p)
				butNext:SetIcon(Material("exclserver/mmarrowicon.png"));
				butNext:SetSize(32,32);
				butNext:SetPos(butPrev.x + 32 + 15,15);
				butNext.DoClick = function(self)
					page = page + 1;
					if page > maxPages then page = maxPages end;

					createIcons();
					lblPage:SetText("Page "..page.."/"..maxPages)
					lblPage:SizeToContents();
				end
				butNext.Paint = function(self,w,h)
					if not self.Mat then return end
					
					surface.SetMaterial(self.Mat)
					if page+1 > maxPages then
						surface.SetDrawColor(Color(150,150,150));
					else
						surface.SetDrawColor(COLOR_WHITE);
					end
					surface.DrawTexturedRectRotated(w/2,w/2,w,w,0);

				end
				
				lblPage:SetColor(COLOR_WHITE);
				lblPage:SetFont("ESDefaultBold");
				lblPage:SetPos(butPrev.x, butPrev.y + butPrev:GetTall() + 15);
				lblPage:SizeToContents();



				buyBtn:SetVisible(false);
				local icons = {}
				createIcons = function()
					for k,v in pairs(icons)do
						if v and IsValid(v) then
							v:Remove();
						end
					end
					icons = {};

					local count_all = 0;
					local count = 0;
					local curRow = 0;
					local curNum = 0;
					for k,v in pairs(ES:GetBuyableItems() or {})do	
						
						count_all = count_all + 1;
						if count >= rowsTotal  or count_all < (page-1) * rowsTotal then
							continue;
						end
						if not first then first = k end
						local icon = vgui.Create("esMMItemBuyTile",p);
						icon.delay=CurTime() + (k-1-((page-1)*rowsTotal))*.02;

						curNum = curNum + 1;

						if curNum > rowsX then
							curRow = curRow + 1;
							curNum = 1;
						end

						icon:SetSize(105,105);
						icon:SetPos(15 + (curNum-1)*105,15 + curRow*105);
						icon:PerformLayout();
						icon.icon:SetModel(v.model);
						icon.text = v.name;
						icon.item = v.id;
						icon.OnMouseReleased = function()
							if IsValid(pnlInfo) and IsValid(lblInfo) and IsValid(lblInfoTxt) then
								pnlInfo.item = v.id;
								lblInfo:SetText(v.name);
								lblInfo:SizeToContents();
								lblInfoTxt:SetText(v.descr);
								lblInfoTxt:SizeToContents();
								mdl:SetModel(v:GetModel());
								mdl:SetVisible(true);

								buyBtn:SetVisible(true);
							end
						end

						table.insert(icons,icon);
						count = count + 1;
					end
				end
				createIcons()
			end},
			
			{icon = Material("exclserver/editor.png"), name = "Trails",func = function()
				local p = mm:OpenFrame()
				p:SetTitle("Trails shop");

				local previewIcons = {};
				local function buildPreview(material)
					for k,v in pairs(previewIcons)do if IsValid(v) then v:Remove() end end
					local icons = math.ceil(p:GetTall()/80);
					for i=0,icons-1 do
						local ic = vgui.Create("DImage",p);
						ic:SetSize(100,100);
						ic:SetImage(material);
						ic:SetPos(p:GetWide()-130,i*100);

						table.insert(previewIcons,ic);
					end
				
				end

				local rowsX = math.floor((p:GetWide()-15-15-200)/105);
				local rowsY = math.floor((p:GetTall()-15-100)/105);
				local rowsTotal = rowsX * rowsY;
				local icons = {}
				local page = 1;
				local first;
				local createIcons;
				local pnlInfo = p:Add("esPanel");
				pnlInfo:SetSize(rowsX*105 - 5,100);
				pnlInfo:SetPos(15,p:GetTall()-(100) - 15);
				pnlInfo.color = Color(250,250,250);
				pnlInfo.item = 0;

				local lblInfo = Label("No more items",pnlInfo);
				lblInfo:SetColor(Color(0,0,0,220));
				lblInfo:SetPos(12,8);
				lblInfo:SetFont("Coolvetica28");
				lblInfo:SizeToContents();

				local lblInfoTxt = Label("You already have all items",pnlInfo);
				lblInfoTxt:SetPos(15,lblInfo.y+lblInfo:GetTall());
				lblInfoTxt:SizeToContents();
				lblInfoTxt:SetColor(Color(0,0,0,210))

				local buyBtn = vgui.Create("esButton",pnlInfo);
				buyBtn:SetPos(pnlInfo:GetWide()-110,pnlInfo:GetTall()-10-30);
				buyBtn:SetSize(100,30);
				buyBtn.Text = "Buy";
				buyBtn.DoClick = function(self)
					if not self:GetParent().item or not ES.TrailsBuy[self:GetParent().item] then return end

					makePurchaseConfirmer(ES.TrailsBuy[self:GetParent().item].cost,self:GetParent().item,ITEM_TRAIL);
				end

				local maxPages = math.ceil(table.Count(ES.TrailsBuy)/rowsTotal);
				local lblPage = Label("Page "..page.."/"..maxPages,p)
				local butPrev = vgui.Create("esIconButton",p)
				butPrev:SetIcon(Material("exclserver/mmarrowicon.png"));
				butPrev:SetSize(32,32);
				butPrev:SetPos(15 + rowsX*105 +10,15);
				butPrev.DoClick = function(self)
					page = page - 1;
					if page < 1 then page = 1 end;

					createIcons();
					lblPage:SetText("Page "..page.."/"..maxPages)
					lblPage:SizeToContents();
				end
				butPrev.Paint = function(self,w,h)
					if not self.Mat then return end
					
					surface.SetMaterial(self.Mat)
					if page-1 < 1 then
						surface.SetDrawColor(Color(150,150,150));
					else
						surface.SetDrawColor(COLOR_WHITE);
					end
					
					surface.DrawTexturedRectRotated(w/2,w/2,w,w,180);

				end
				local butNext = vgui.Create("esIconButton",p)
				butNext:SetIcon(Material("exclserver/mmarrowicon.png"));
				butNext:SetSize(32,32);
				butNext:SetPos(butPrev.x + 32 + 15,15);
				butNext.DoClick = function(self)
					page = page + 1;
					if page > maxPages then page = maxPages end;

					createIcons();
					lblPage:SetText("Page "..page.."/"..maxPages)
					lblPage:SizeToContents();
				end
				butNext.Paint = function(self,w,h)
					if not self.Mat then return end
					
					surface.SetMaterial(self.Mat)
					if page+1 > maxPages then
						surface.SetDrawColor(Color(150,150,150));
					else
						surface.SetDrawColor(COLOR_WHITE);
					end
					surface.DrawTexturedRectRotated(w/2,w/2,w,w,0);

				end
				
				lblPage:SetColor(COLOR_WHITE);
				lblPage:SetFont("ESDefaultBold");
				lblPage:SetPos(butPrev.x, butPrev.y + butPrev:GetTall() + 15);
				lblPage:SizeToContents();

				buyBtn:SetVisible(false);
				createIcons = function()
					local count_all = 0;
					local count = 0;
					local curRow = 0;
					local curNum = 0;

					for k,v in pairs(icons) do
						if IsValid(v) then v:Remove() end
					end

					for k,v in pairs(ES.TrailsBuy or {})do	
						count_all = count_all + 1;
						if count >= rowsTotal  or count_all < (page-1) * rowsTotal then
							continue;
						end
						if not first then first = k end
						local icon = vgui.Create("esMMTrailBuyTile",p);
						icon.delay=CurTime() + ((count_all-1)-((page-1)*rowsTotal))*.02;

						curNum = curNum + 1;

						if curNum > rowsX then
							curRow = curRow + 1;
							curNum = 1;
						end

						icon:SetSize(105,105);
						icon:SetPos(15 + (curNum-1)*105,10 + curRow*105);
						icon:PerformLayout();
						icon.icon:SetImage(v.text);
						icon.text = v.name;
						icon.item = k;
						icon.OnMouseReleased = function()
							if IsValid(pnlInfo) and IsValid(lblInfo) and IsValid(lblInfoTxt) then
								pnlInfo.item = k;
								lblInfo:SetText(v.name);
								lblInfo:SizeToContents();
								lblInfoTxt:SetText(v.descr);
								lblInfoTxt:SizeToContents();
								buildPreview(v.text)
							end
						end

						table.insert(icons,icon);

						count = count + 1;
					end
				end
				createIcons()
				if not first then return end

				local info = ES.TrailsBuy[first]

				pnlInfo.item = first;
				lblInfo:SetText(info.name);
				lblInfo:SizeToContents();
				lblInfoTxt:SetText(info.descr);
				lblInfoTxt:SizeToContents();
				buyBtn:SetVisible(true);
				buildPreview(info.text);
			end},
			{icon = Material("exclserver/melee.png"), name = "Melee",func = function()
				local p = mm:OpenFrame()
				p:SetTitle("Melee weapon shop");

				local mdl = p:Add("DModelPanel");
				mdl:SetSize(500,500);
				mdl:SetPos(p:GetWide()-380,p:GetTall()-501);
				mdl:SetLookAt(Vector(0,0,0));
				mdl:SetCamPos(Vector(38,18,0));
				mdl:SetVisible(false);

				local createIcons; -- prototype
				local rowsX = math.floor((p:GetWide()-15-15-200)/105);
				local rowsY = math.floor((p:GetTall()-15-100)/105);
				local rowsTotal = rowsX * rowsY;
				local icons = {}
				local page = 1;
				local first;
				local pnlInfo = p:Add("esPanel");
				pnlInfo:SetSize(rowsX*105 - 5,100);
				pnlInfo:SetPos(15,p:GetTall()-(100) - 15);
				pnlInfo.color = Color(250,250,250);
				pnlInfo.item = 0;

				local lblInfo = Label("No more items",pnlInfo);
				lblInfo:SetColor(Color(0,0,0,220));
				lblInfo:SetPos(12,8);
				lblInfo:SetFont("Coolvetica28");
				lblInfo:SizeToContents();

				local lblInfoTxt = Label("You already have all items",pnlInfo);
				lblInfoTxt:SetPos(15,lblInfo.y+lblInfo:GetTall());
				lblInfoTxt:SizeToContents();
				lblInfoTxt:SetColor(Color(0,0,0,210))

				local buyBtn = vgui.Create("esButton",pnlInfo);
				buyBtn:SetPos(pnlInfo:GetWide()-110,pnlInfo:GetTall()-10-30);
				buyBtn:SetSize(100,30);
				buyBtn.Text = "Buy";
				buyBtn.DoClick = function(self)
					if not self:GetParent().item or not ES.MeleeBuy[self:GetParent().item] then return end

					makePurchaseConfirmer(ES.MeleeBuy[self:GetParent().item].cost,self:GetParent().item,ITEM_MELEE);
				end

				local maxPages = math.ceil(table.Count(ES.MeleeBuy)/rowsTotal);
				local lblPage = Label("Page "..page.."/"..maxPages,p)
				local butPrev = vgui.Create("esIconButton",p)
				butPrev:SetIcon(Material("exclserver/mmarrowicon.png"));
				butPrev:SetSize(32,32);
				butPrev:SetPos(15 + rowsX*105 +10,15);
				butPrev.DoClick = function(self)
					page = page - 1;
					if page < 1 then page = 1 end;

					createIcons();
					lblPage:SetText("Page "..page.."/"..maxPages)
					lblPage:SizeToContents();
				end
				butPrev.Paint = function(self,w,h)
					if not self.Mat then return end
					
					surface.SetMaterial(self.Mat)
					if page-1 < 1 then
						surface.SetDrawColor(Color(150,150,150));
					else
						surface.SetDrawColor(COLOR_WHITE);
					end
					
					surface.DrawTexturedRectRotated(w/2,w/2,w,w,180);

				end
				local butNext = vgui.Create("esIconButton",p)
				butNext:SetIcon(Material("exclserver/mmarrowicon.png"));
				butNext:SetSize(32,32);
				butNext:SetPos(butPrev.x + 32 + 15,15);
				butNext.DoClick = function(self)
					page = page + 1;
					if page > maxPages then page = maxPages end;

					createIcons();
					lblPage:SetText("Page "..page.."/"..maxPages)
					lblPage:SizeToContents();
				end
				butNext.Paint = function(self,w,h)
					if not self.Mat then return end
					
					surface.SetMaterial(self.Mat)
					if page+1 > maxPages then
						surface.SetDrawColor(Color(150,150,150));
					else
						surface.SetDrawColor(COLOR_WHITE);
					end
					surface.DrawTexturedRectRotated(w/2,w/2,w,w,0);

				end
				
				lblPage:SetColor(COLOR_WHITE);
				lblPage:SetFont("ESDefaultBold");
				lblPage:SetPos(butPrev.x, butPrev.y + butPrev:GetTall() + 15);
				lblPage:SizeToContents();



				buyBtn:SetVisible(false);
				createIcons = function()
					local count_all = 0;
					local count = 0;
					local curRow = 0;
					local curNum = 0;
					for k,v in pairs(ES.MeleeBuy or {})do	
						
						count_all = count_all + 1;
						if count >= rowsTotal  or count_all < (page-1) * rowsTotal then
							continue;
						end
						if not first then first = k end
						local icon = vgui.Create("esMMMeleeBuyTile",p);
						icon.delay=CurTime() + ((count_all-1)-((page-1)*rowsTotal))*.02;

						curNum = curNum + 1;

						if curNum > rowsX then
							curRow = curRow + 1;
							curNum = 1;
						end

						icon:SetSize(105,105);
						icon:SetPos(15 + (curNum-1)*105,15 + curRow*105);
						icon:PerformLayout();
						icon.icon:SetModel(v.model);
						icon.text = v.name;
						icon.item = k;
						icon.OnMouseReleased = function()
							if IsValid(pnlInfo) and IsValid(lblInfo) and IsValid(lblInfoTxt) then
								pnlInfo.item = k;
								lblInfo:SetText(v.name);
								lblInfo:SizeToContents();
								lblInfoTxt:SetText(v.descr);
								lblInfoTxt:SizeToContents();
								mdl:SetModel(v.model);
								mdl:SetVisible(true);
							end
						end

						table.insert(icons,icon);
						count = count + 1;
					end
				end
				createIcons()
				if not first then return end

				local info = ES.MeleeBuy[first]

				pnlInfo.item = first;
				lblInfo:SetText(info.name);
				lblInfo:SizeToContents();
				lblInfoTxt:SetText(info.descr);
				lblInfoTxt:SizeToContents();
				buyBtn:SetVisible(true);
				mdl:SetModel(info.model);
				mdl:SetVisible(true);

			end},
			{icon = Material("exclserver/effects.png"), name = "Models",func = function()
				local p = mm:OpenFrame()
				p:SetTitle("Models shop");

				local mdl = p:Add("esMMHatPreview");
				mdl.useCurrentHat = true;
				mdl:SetSize(500,500);
				mdl:SetModel(Model("models/player/Group01/male_07.mdl"));
				mdl:SetPos(p:GetWide()-380,p:GetTall()-501);
				mdl:SetLookAt(Vector(0,0,62));
				mdl:SetCamPos(Vector(38,18,64));
				function mdl:LayoutEntity() end

				local createIcons; -- prototype
				local rowsX = math.floor((p:GetWide()-15-15-200)/105);
				local rowsY = math.floor((p:GetTall()-15-100)/105);
				local rowsTotal = rowsX * rowsY;
				local icons = {}
				local page = 1;
				local first;
				local pnlInfo = p:Add("esPanel");
				pnlInfo:SetSize(rowsX*105 - 5,100);
				pnlInfo:SetPos(15,p:GetTall()-(100) - 15);
				pnlInfo.color = Color(250,250,250);
				pnlInfo.item = 0;

				local lblInfo = Label("No more items",pnlInfo);
				lblInfo:SetColor(Color(0,0,0,220));
				lblInfo:SetPos(12,8);
				lblInfo:SetFont("Coolvetica28");
				lblInfo:SizeToContents();

				local lblInfoTxt = Label("You already have all items",pnlInfo);
				lblInfoTxt:SetPos(15,lblInfo.y+lblInfo:GetTall());
				lblInfoTxt:SizeToContents();
				lblInfoTxt:SetColor(Color(0,0,0,210))

				local buyBtn = vgui.Create("esButton",pnlInfo);
				buyBtn:SetPos(pnlInfo:GetWide()-110,pnlInfo:GetTall()-10-30);
				buyBtn:SetSize(100,30);
				buyBtn.Text = "Buy";
				buyBtn.DoClick = function(self)
					if not self:GetParent().item or not ES.ModelsBuy[self:GetParent().item] then return end

					if ES.ModelsBuy[self:GetParent().item].VIPOnly and LocalPlayer():ESGetVIPTier() <= 2 then
						openNeedVIP("gold")
						return;
					end

					makePurchaseConfirmer(ES.ModelsBuy[self:GetParent().item].cost,self:GetParent().item,ITEM_MODEL);
				end


				local maxPages = math.ceil(table.Count(ES.ModelsBuy)/rowsTotal);
				local lblPage = Label("Page "..page.."/"..maxPages,p)
				local butPrev = vgui.Create("esIconButton",p)
				butPrev:SetIcon(Material("exclserver/mmarrowicon.png"));
				butPrev:SetSize(32,32);
				butPrev:SetPos(15 + rowsX*105 +10,15);
				butPrev.DoClick = function(self)
					page = page - 1;
					if page < 1 then page = 1 end;

					createIcons();
					lblPage:SetText("Page "..page.."/"..maxPages)
					lblPage:SizeToContents();
				end
				butPrev.Paint = function(self,w,h)
					if not self.Mat then return end
					
					surface.SetMaterial(self.Mat)
					if page-1 < 1 then
						surface.SetDrawColor(Color(150,150,150));
					else
						surface.SetDrawColor(COLOR_WHITE);
					end
					
					surface.DrawTexturedRectRotated(w/2,w/2,w,w,180);

				end
				local butNext = vgui.Create("esIconButton",p)
				butNext:SetIcon(Material("exclserver/mmarrowicon.png"));
				butNext:SetSize(32,32);
				butNext:SetPos(butPrev.x + 32 + 15,15);
				butNext.DoClick = function(self)
					page = page + 1;
					if page > maxPages then page = maxPages end;

					createIcons();
					lblPage:SetText("Page "..page.."/"..maxPages)
					lblPage:SizeToContents();
				end
				butNext.Paint = function(self,w,h)
					if not self.Mat then return end
					
					surface.SetMaterial(self.Mat)
					if page+1 > maxPages then
						surface.SetDrawColor(Color(150,150,150));
					else
						surface.SetDrawColor(COLOR_WHITE);
					end
					surface.DrawTexturedRectRotated(w/2,w/2,w,w,0);

				end
				
				lblPage:SetColor(COLOR_WHITE);
				lblPage:SetFont("ESDefaultBold");
				lblPage:SetPos(butPrev.x, butPrev.y + butPrev:GetTall() + 15);
				lblPage:SizeToContents();



				buyBtn:SetVisible(false);
				local icons = {}
				createIcons = function()
					for k,v in pairs(icons)do
						if v and IsValid(v) then
							v:Remove();
						end
					end
					icons = {};

					local count_all = 0;
					local count = 0;
					local curRow = 0;
					local curNum = 0;
					for k,v in pairs(ES.ModelsBuy or {})do	
						
						count_all = count_all + 1;
						if count >= rowsTotal  or count_all < (page-1) * rowsTotal then
							continue;
						end
						if not first then first = k end
						local icon = vgui.Create("esMMModelBuyTile",p);
						icon.delay=CurTime() + ((count_all-1)-((page-1)*rowsTotal))*.02;
						curNum = curNum + 1;

						if curNum > rowsX then
							curRow = curRow + 1;
							curNum = 1;
						end

						icon:SetSize(105,105);
						icon:SetPos(15 + (curNum-1)*105,15 + curRow*105);
						icon:PerformLayout();
						icon.icon:SetModel(v.model);
						icon.text = v.name;
						icon.item = k;
						icon.OnMouseReleased = function()
							if IsValid(pnlInfo) and IsValid(lblInfo) and IsValid(lblInfoTxt) then
								pnlInfo.item = k;
								lblInfo:SetText(v.name);
								lblInfo:SizeToContents();
								lblInfoTxt:SetText(v.descr);
								lblInfoTxt:SizeToContents();
								mdl:SetModel(ES.ModelsBuy[k].model)
							end
						end

						table.insert(icons,icon);
						count = count + 1;
					end
				end
				createIcons()
				if not first then return end

				local info = ES.ModelsBuy[first]

				pnlInfo.item = first;
				lblInfo:SetText(info.name);
				lblInfo:SizeToContents();
				lblInfoTxt:SetText(info.descr);
				lblInfoTxt:SizeToContents();
				buyBtn:SetVisible(true);
				mdl:SetModel(info.model);

			end},
			{icon = Material("exclserver/effects.png"), name = "Auras",func = function()
				local p = mm:OpenFrame()
				p:SetTitle("Aura shop");

				local mdl = p:Add("DImage");
				mdl:SetSize(256,256);
				mdl:SetPos(p:GetWide()-200,p:GetTall()-330);

				local createIcons; -- prototype
				local rowsX = math.floor((p:GetWide()-15-15-200)/105);
				local rowsY = math.floor((p:GetTall()-15-100)/105);
				local rowsTotal = rowsX * rowsY;
				local icons = {}
				local page = 1;
				local first;
				local pnlInfo = p:Add("esPanel");
				pnlInfo:SetSize(rowsX*105 - 5,100);
				pnlInfo:SetPos(15,p:GetTall()-(100) - 15);
				pnlInfo.color = Color(250,250,250);
				pnlInfo.item = 0;

				local lblInfo = Label("No more items",pnlInfo);
				lblInfo:SetColor(Color(0,0,0,220));
				lblInfo:SetPos(12,8);
				lblInfo:SetFont("Coolvetica28");
				lblInfo:SizeToContents();

				local lblInfoTxt = Label("You already have all items",pnlInfo);
				lblInfoTxt:SetPos(15,lblInfo.y+lblInfo:GetTall());
				lblInfoTxt:SizeToContents();
				lblInfoTxt:SetColor(Color(0,0,0,210))

				local buyBtn = vgui.Create("esButton",pnlInfo);
				buyBtn:SetPos(pnlInfo:GetWide()-110,pnlInfo:GetTall()-10-30);
				buyBtn:SetSize(100,30);
				buyBtn.Text = "Buy";
				buyBtn.DoClick = function(self)
					if not self:GetParent().item or not ES.AurasBuy[self:GetParent().item] then return end

					if ES.AurasBuy[self:GetParent().item].VIPOnly and LocalPlayer():ESGetVIPTier() <= 2 then
						openNeedVIP("gold")
						return;
					end

					makePurchaseConfirmer(ES.AurasBuy[self:GetParent().item].cost,self:GetParent().item,ITEM_AURA);
				end


				local maxPages = math.ceil(table.Count(ES.AurasBuy)/rowsTotal);
				local lblPage = Label("Page "..page.."/"..maxPages,p)
				local butPrev = vgui.Create("esIconButton",p)
				butPrev:SetIcon(Material("exclserver/mmarrowicon.png"));
				butPrev:SetSize(32,32);
				butPrev:SetPos(15 + rowsX*105 +10,15);
				butPrev.DoClick = function(self)
					page = page - 1;
					if page < 1 then page = 1 end;

					createIcons();
					lblPage:SetText("Page "..page.."/"..maxPages)
					lblPage:SizeToContents();
				end
				butPrev.Paint = function(self,w,h)
					if not self.Mat then return end
					
					surface.SetMaterial(self.Mat)
					if page-1 < 1 then
						surface.SetDrawColor(Color(150,150,150));
					else
						surface.SetDrawColor(COLOR_WHITE);
					end
					
					surface.DrawTexturedRectRotated(w/2,w/2,w,w,180);

				end
				local butNext = vgui.Create("esIconButton",p)
				butNext:SetIcon(Material("exclserver/mmarrowicon.png"));
				butNext:SetSize(32,32);
				butNext:SetPos(butPrev.x + 32 + 15,15);
				butNext.DoClick = function(self)
					page = page + 1;
					if page > maxPages then page = maxPages end;

					createIcons();
					lblPage:SetText("Page "..page.."/"..maxPages)
					lblPage:SizeToContents();
				end
				butNext.Paint = function(self,w,h)
					if not self.Mat then return end
					
					surface.SetMaterial(self.Mat)
					if page+1 > maxPages then
						surface.SetDrawColor(Color(150,150,150));
					else
						surface.SetDrawColor(COLOR_WHITE);
					end
					surface.DrawTexturedRectRotated(w/2,w/2,w,w,0);

				end
				
				lblPage:SetColor(COLOR_WHITE);
				lblPage:SetFont("ESDefaultBold");
				lblPage:SetPos(butPrev.x, butPrev.y + butPrev:GetTall() + 15);
				lblPage:SizeToContents();



				buyBtn:SetVisible(false);
				local icons = {}
				createIcons = function()
					for k,v in pairs(icons)do
						if v and IsValid(v) then
							v:Remove();
						end
					end
					icons = {};

					local count_all = 0;
					local count = 0;
					local curRow = 0;
					local curNum = 0;
					for k,v in pairs(ES.AurasBuy or {})do	
						
						count_all = count_all + 1;
						if count >= rowsTotal  or count_all < (page-1) * rowsTotal then
							continue;
						end
						if not first then first = k end
						local icon = vgui.Create("esMMAuraBuyTile",p);
						icon.delay=CurTime() + ((count_all-1)-((page-1)*rowsTotal))*.02;
						curNum = curNum + 1;

						if curNum > rowsX then
							curRow = curRow + 1;
							curNum = 1;
						end

						icon:SetSize(105,105);
						icon:SetPos(15 + (curNum-1)*105,15 + curRow*105);
						icon:PerformLayout();
						icon.icon:SetMaterial(v.text);
						icon.text = v.name;
						icon.item = k;
						icon.OnMouseReleased = function()
							if IsValid(pnlInfo) and IsValid(lblInfo) and IsValid(lblInfoTxt) then
								pnlInfo.item = k;
								lblInfo:SetText(v.name);
								lblInfo:SizeToContents();
								lblInfoTxt:SetText(v.descr);
								lblInfoTxt:SizeToContents();
								mdl:SetMaterial(ES.AurasBuy[k].text)
							end
						end

						table.insert(icons,icon);
						count = count + 1;
					end
				end
				createIcons()
				if not first then return end

				local info = ES.AurasBuy[first]

				pnlInfo.item = first;
				lblInfo:SetText(info.name);
				lblInfo:SizeToContents();
				lblInfoTxt:SetText(info.descr);
				lblInfoTxt:SizeToContents();
				buyBtn:SetVisible(true);
				mdl:SetMaterial(info.text);

			end}
		}) 
	end)
	mm:AddButton("Inventory",Material("icon16/plugin.png"),function() 
		mm:OpenChoisePanel({
			{icon = Material("exclserver/bananas.png"), name = "Items",func = function()
				local p = mm:OpenFrame();
				p:SetTitle("Items inventory");

				local mdl = p:Add("DModelPanel");
				mdl:SetSize(500,500);
				mdl:SetPos(p:GetWide()-380,p:GetTall()-501);
				mdl:SetLookAt(Vector(0,0,50));
				mdl:SetCamPos(Vector(100,100,50));
				mdl:SetVisible(false);

				local createIcons; -- prototype
				local rowsX = math.floor((p:GetWide()-15-15-200)/105);
				local rowsY = math.floor((p:GetTall()-15-100)/105);
				local rowsTotal = rowsX * rowsY;
				local icons = {}
				local page = 1;
				local first;
				local pnlInfo = p:Add("esPanel");
				pnlInfo:SetSize(rowsX*105 - 5,100);
				pnlInfo:SetPos(15,p:GetTall()-(100) - 15);
				pnlInfo.color = Color(250,250,250);
				pnlInfo.item = 0;

				local lblInfo = Label("No item selected",pnlInfo);
				lblInfo:SetColor(Color(0,0,0,220));
				lblInfo:SetPos(12,8);
				lblInfo:SetFont("Coolvetica28");
				lblInfo:SizeToContents();

				local lblInfoTxt = Label("",pnlInfo);
				lblInfoTxt:SetPos(15,lblInfo.y+lblInfo:GetTall());
				lblInfoTxt:SizeToContents();
				lblInfoTxt:SetColor(Color(0,0,0,210))

				local buyBtn = vgui.Create("esButton",pnlInfo);
				buyBtn:SetPos(pnlInfo:GetWide()-160,pnlInfo:GetTall()-10-30);
				buyBtn:SetSize(150,30);
				buyBtn.Text = "Sell for 50% value";
				local plsnospam = CurTime()+1;
				buyBtn.DoClick = function(self)
					if not self:GetParent().item or not ES.Items[self:GetParent().item] then return end

					if plsnospam > CurTime() then return end

					RunConsoleCommand("excl","sell",self:GetParent().item)
					plsnospam = CurTime()+1;
					LocalPlayer():ESGetInventory():RemoveItem(self:GetParent().item,1);

					createIcons();
				end


				local maxPages = math.ceil(table.Count(LocalPlayer():ESGetInventory():GetItems())/rowsTotal);
				local lblPage = Label("Page "..page.."/"..maxPages,p)
				local butPrev = vgui.Create("esIconButton",p)
				butPrev:SetIcon(Material("exclserver/mmarrowicon.png"));
				butPrev:SetSize(32,32);
				butPrev:SetPos(15 + rowsX*105 +10,15);
				butPrev.DoClick = function(self)
					page = page - 1;
					if page < 1 then page = 1 end;

					createIcons();
					lblPage:SetText("Page "..page.."/"..maxPages)
					lblPage:SizeToContents();
				end
				butPrev.Paint = function(self,w,h)
					if not self.Mat then return end
					
					surface.SetMaterial(self.Mat)
					if page-1 < 1 then
						surface.SetDrawColor(Color(150,150,150));
					else
						surface.SetDrawColor(COLOR_WHITE);
					end
					
					surface.DrawTexturedRectRotated(w/2,w/2,w,w,180);

				end
				local butNext = vgui.Create("esIconButton",p)
				butNext:SetIcon(Material("exclserver/mmarrowicon.png"));
				butNext:SetSize(32,32);
				butNext:SetPos(butPrev.x + 32 + 15,15);
				butNext.DoClick = function(self)
					page = page + 1;
					if page > maxPages then page = maxPages end;

					createIcons();
					lblPage:SetText("Page "..page.."/"..maxPages)
					lblPage:SizeToContents();
				end
				butNext.Paint = function(self,w,h)
					if not self.Mat then return end
					
					surface.SetMaterial(self.Mat)
					if page+1 > maxPages then
						surface.SetDrawColor(Color(150,150,150));
					else
						surface.SetDrawColor(COLOR_WHITE);
					end
					surface.DrawTexturedRectRotated(w/2,w/2,w,w,0);

				end
				
				lblPage:SetColor(COLOR_WHITE);
				lblPage:SetFont("ESDefaultBold");
				lblPage:SetPos(butPrev.x, butPrev.y + butPrev:GetTall() + 15);
				lblPage:SizeToContents();



				buyBtn:SetVisible(false);
				local icons = {}
				createIcons = function()
					for k,v in pairs(icons)do
						if v and IsValid(v) then
							v:Remove();
						end
					end
					icons = {};

					local count_all = 0;
					local count = 0;
					local curRow = 0;
					local curNum = 0;
					for k,v in pairs(LocalPlayer():ESGetInventory():GetItems() or {})do	
						
						count_all = count_all + 1;
						if count >= rowsTotal  or count_all < (page-1) * rowsTotal then
							continue;
						end
						if not first then first = k end
						local icon = vgui.Create("esMMItemBuyTile",p);

						curNum = curNum + 1;

						if curNum > rowsX then
							curRow = curRow + 1;
							curNum = 1;
						end

						icon:SetSize(105,105);
						icon:SetPos(15 + (curNum-1)*105,15 + curRow*105);
						icon:PerformLayout();
						icon.icon:SetModel(ES.Items[k].model);
						icon.text = ES.Items[k].name;
						icon.item = k;
						icon.OnMouseReleased = function()
							if IsValid(pnlInfo) and IsValid(lblInfo) and IsValid(lblInfoTxt) then
								pnlInfo.item = k;
								lblInfo:SetText(ES.Items[k].name);
								lblInfo:SizeToContents();
								lblInfoTxt:SetText(ES.Items[k].descr);
								lblInfoTxt:SizeToContents();
								mdl:SetModel(ES.Items[k]:GetModel());
								mdl:SetVisible(true);

								buyBtn:SetVisible(true);
							end
						end

						table.insert(icons,icon);
						count = count + 1;
					end
				end
				createIcons()
			end},
			{icon = Material("exclserver/editor.png"), name = "Effects",func = function()
				--mm:CloseChoisePanel()
				local p = mm:OpenFrame(nil,200*3+15*4)
				p:SetTitle("Effects");

				local mdl = p:Add("esMMHatPreview");
				mdl.useCurrentHat = true;
				mdl:SetSize(500,500);
				mdl:SetModel(LocalPlayer():ESGetActiveModel());
				mdl:SetPos(p:GetWide()-380,p:GetTall()-501);
				mdl:SetLookAt(Vector(0,0,62));
				mdl:SetCamPos(Vector(38,18,64));

				local models = LocalPlayer()._es_inventory_models or {};
				local function modelbykey(k)
					if k < 1 then
						return "models/player/Group01/Male_02.mdl"
					else
						return ES.ModelsBuy[ models[k] ].model
					end
				end
				
				local nextPress = CurTime()+2;
				local page = 0;
				for k,v in pairs(models)do
					if LocalPlayer().excl and LocalPlayer().excl.activemodel and LocalPlayer().excl.activemodel == v then
						page = k;
						break;
					end
				end

				mdl:SetModel(modelbykey(page))

				local pnlmdl = p:Add("Panel");
				function pnlmdl:Paint(w,h)
					local _,_,col = ES.GetColorScheme();
					surface.SetDrawColor(col)
					surface.DrawRect(0,0,w,h)
					surface.SetDrawColor(Color(45,45,45))
					surface.DrawRect(0,5,w,h-5)
					draw.SimpleText("Model","esMMInventoryTitle",10,10,COLOR_WHITE);
					if LocalPlayer().excl.activemodel and ES.ModelsBuy[LocalPlayer().excl.activemodel] then
						draw.SimpleText(ES.ModelsBuy[LocalPlayer().excl.activemodel].name,"ESDefaultBold",15,h-30,COLOR_WHITE);
						return
					end
					
					draw.SimpleText("Random citizen","ESDefaultBold",15,h-30,COLOR_WHITE);

				end
				pnlmdl:SetSize(p:GetWide() - 30 - 15 - (p:GetWide()-30-230),64 + 5*4)
				pnlmdl:SetPos(p:GetWide()-15-pnlmdl:GetWide(),p:GetTall()-pnlmdl:GetTall()-15);
				mdl.y = pnlmdl.y-500;

				local butPrev = vgui.Create("esIconButton",pnlmdl)
				butPrev:SetIcon(Material("exclserver/mmarrowicon.png"));
				butPrev:SetSize(32,32);
				butPrev:SetPos(pnlmdl:GetWide()-32-10-32-9,15);
				butPrev.DoClick = function(self)
					if CurTime() < nextPress then return end
					nextPress = CurTime()+.7;
					page = page - 1;
					if page < 0 then page = 0 end;

					mdl:SetModel(modelbykey(page))
					if page <= 0 then
						RunConsoleCommand("excl","deactivate","model");
					else
						RunConsoleCommand("excl","activate",models[page],"model");
					end
				end
				butPrev.Paint = function(self,w,h)
					if not self.Mat then return end
					
					surface.SetMaterial(self.Mat)
					if page-1 < 0 then
						surface.SetDrawColor(Color(150,150,150));
					else
						surface.SetDrawColor(COLOR_WHITE);
					end
					
					surface.DrawTexturedRectRotated(w/2,w/2,w,w,180);

				end
				local butNext = vgui.Create("esIconButton",pnlmdl)
				butNext:SetIcon(Material("exclserver/mmarrowicon.png"));
				butNext:SetSize(32,32);
				butNext:SetPos(pnlmdl:GetWide()-32-10,15);
				butNext.DoClick = function(self)
					if CurTime() < nextPress then return end
					nextPress = CurTime()+.7;
					page = page + 1;
					if page > #models then page = #models end;

					mdl:SetModel(modelbykey(page))
					RunConsoleCommand("excl","activate",models[page],"model");
				end
				butNext.Paint = function(self,w,h)
					if not self.Mat then return end
					
					surface.SetMaterial(self.Mat)
					if !models[page+1] then
						surface.SetDrawColor(Color(150,150,150));
					else
						surface.SetDrawColor(COLOR_WHITE);
					end
					surface.DrawTexturedRectRotated(w/2,w/2,w,w,0);

				end
				
				local invAuras = vgui.Create("esMMInventory",p);
				invAuras:SetSize(p:GetWide()-30-230,200);
				invAuras.Title = "Auras";
				invAuras:SetPos(15,15);
				invAuras.rm.typ = "aura";

				local iconAura = invAuras.PanelCurrent:Add("DImage");

					local y = 0;
					local x = 0;
					for k,v in pairs(LocalPlayer()._es_inventory_auras or {}) do
						if not ES:ValidItem(v,ITEM_AURA) then continue end
						
						local ic = invAuras.PanelInventory:Add("esMMAuraInventoryTile");
						ic:SetPos(x*100,y*100);
						ic:SetSize(100,100);
						ic.item = v;
						ic.icon:SetMaterial(ES.AurasBuy[v].text);
						ic.text = ES.AurasBuy[v].name
						ic.OnMouseReleased = function()
							iconAura:SetMaterial(ES.AurasBuy[v].text);
							iconAura:SetVisible(true);
							invAuras.rm:SetVisible(true);
							
							
							LocalPlayer().excl.activeaura = v;
							RunConsoleCommand("excl","activate",v,"aura");
						end

						table.insert(invAuras.PanelInventory.items,ic);

						y = y + 1;
						if y >= 2 then
							y = 0;
							x = x + 1;
						end
					end
				iconAura:SetSize(90,90);
				iconAura:SetPos(5,5);
				
				local invTrails = vgui.Create("esMMInventory",p);
				invTrails:SetSize(p:GetWide()-30-230,200);
				invTrails.Title = "Trails";
				invTrails:SetPos(15,invAuras.y + invAuras:GetTall() + 15);
				invTrails.rm.typ = "trail";

				local iconTrail = invTrails.PanelCurrent:Add("DImage");

					local y = 0;
					local x = 0;
					for k,v in pairs(LocalPlayer()._es_inventory_trails or {})do
						if not ES:ValidItem(v,ITEM_TRAIL) then continue end
						
						local ic = invTrails.PanelInventory:Add("esMMTrailInventoryTile");
						ic:SetPos(x*100,y*100);
						ic:SetSize(100,100);
						ic.item = v;
						ic.icon:SetImage(ES.TrailsBuy[v].text);
						ic.text = ES.TrailsBuy[v].name
						ic.OnMouseReleased = function()
							iconTrail:SetImage(ES.TrailsBuy[v].text);
							iconTrail:SetVisible(true);
							invTrails.rm:SetVisible(true);

							LocalPlayer().excl.activetrail = v;
							RunConsoleCommand("excl","activate",v,"trail");
						end

						table.insert(invTrails.PanelInventory.items,ic);

						y = y + 1;
						if y >= 2 then
							y = 0;
							x = x + 1;
						end
					end
				iconTrail:SetSize(90,90);
				iconTrail:SetPos(5,5);

				if LocalPlayer().excl.activetrail and ES.TrailsBuy[LocalPlayer().excl.activetrail] then
					iconTrail:SetImage(ES.TrailsBuy[LocalPlayer().excl.activetrail].text);
					invTrails.rm:SetVisible(true);
				end

				local invMelee = vgui.Create("esMMInventory",p);
				invMelee:SetSize(p:GetWide()-30-230,200);
				invMelee.Title = "Melee";
				invMelee:SetPos(15,invTrails.y + invTrails:GetTall() + 15);
				invMelee.rm.typ = "melee";

				local iconMelee = invMelee.PanelCurrent:Add("Spawnicon");

					local y = 0;
					local x = 0;
					for k,v in pairs(LocalPlayer()._es_inventory_meleeweapons or {})do
						if not ES:ValidItem(v,ITEM_MELEE) then continue end
						
						local ic = invMelee.PanelInventory:Add("esMMMeleeInventoryTile");
						ic:SetPos(x*100,y*100);
						ic:SetSize(100,100);
						ic.item = v;
						ic.icon:SetModel(ES.MeleeBuy[v].model);
						ic.text = ES.MeleeBuy[v].name
						ic.OnMouseReleased = function()
							iconMelee:SetModel(ES.MeleeBuy[v].model);
							iconMelee:SetVisible(true);
							invMelee.rm:SetVisible(true);
							
							LocalPlayer().excl.activemelee = v;
							RunConsoleCommand("excl","activate",v,"melee");
						end

						table.insert(invMelee.PanelInventory.items,ic);

						y = y + 1;
						if y >= 2 then
							y = 0;
							x = x + 1;
						end
					end
				iconMelee:SetSize(90,90);
				iconMelee:SetPos(5,5);

				if LocalPlayer().excl.activemelee and ES.MeleeBuy[LocalPlayer().excl.activemelee] then
					iconMelee:SetModel(ES.MeleeBuy[LocalPlayer().excl.activemelee].model);
					invMelee.rm:SetVisible(true);
				else
					iconMelee:SetVisible(false);
				end

	
			end},
			{icon = Material("exclserver/editor.png"), name = "Outfit",func = function()
				local p = mm:OpenFrame(860); p:SetTitle("Outfit");
				local inv = table.Copy(LocalPlayer():ESGetInventory():GetItems());
				local a,b,c = ES.GetColorScheme();
				local openEditor; -- prototype
				local tab = vgui.Create("Panel",p);
				tab:SetPos(1,p:GetTall()-64-1);
				tab:SetSize(p:GetWide(),64)
				tab.Paint = function(self,w,h)
					draw.RoundedBox(0,0,0,w,h,Color(50,50,50));

					draw.SimpleText("Outfit Slots","ES.MainMenu.MainElementInfoBnns",64*6.3,h/2,Color(170,170,170),0,1);
				end
				local slotSelected = 1;				
				for i=1,6 do
					local tab = vgui.Create("Panel",p);
					tab:SetPos(-63 + i*64,p:GetTall()-65);
					tab:SetSize(64,64)
					tab.OnCursorEntered = function(self) self.Hover = true end; tab.OnCursorExited = function(self) self.Hover = false end;
					tab.Paint = function(self,w,h)
						if slotSelected != i then
							draw.RoundedBox(0,1,1,w-2,h-1,self.Hover and Color(255,255,255,20) or Color(255,255,255,5));
						else
							draw.RoundedBox(0,0,0,w,h,b);
						end
						draw.SimpleText(i,"ES.MainMenu.MainElementInfoBnns",w/2,h/2,(slotSelected == i or self.Hover) and COLOR_WHITE or Color(255,255,255,50),1,1);
					end
					tab.OnMouseReleased = function()
						if i > 2+LocalPlayer():ESGetVIPTier() then
							openNeedVIP(i == 3 and "bronze" or i == 4 and "silver" or i == 5 and "gold" or i == 6 and "carebear");
							return;
						end
						slotSelected = i;
						openEditor(i);
					end
				end
				local editor;
				local slots = {};
				for i=1, 2+(LocalPlayer():ESGetVIPTier()) do
					slotdata = LocalPlayer():ESGetGlobalData("slot"..i,false);
					if slotdata and type( slotdata ) == "string" and slotdata != "" then
						local exp = string.Explode("|",slotdata);
						if not exp or not exp[1] or not exp[2] or not exp[3] or not exp[4] or not exp[5] or not exp[6] then continue end
						slots[i] = {};
						slots[i].item = exp[1];
						if not slots[i].item then return end						
						slots[i].pos = Vector(exp[2]);
						slots[i].ang = Angle(exp[3]); 
						slots[i].scale = Vector(exp[4]);
						slots[i].bone = tostring(exp[5]);
						local color = string.Explode(" ",exp[6]) or {};
						slots[i].color = Color(color[1] or 255,color[2] or 255,color[3] or 255)
						if inv[exp[1]] then
							inv[exp[1]] = inv[exp[1]] - 1;
						end
					end
				end
				openEditor = function(slot)



					if editor and IsValid(editor) then editor:Remove() end
					editor = vgui.Create("Panel",p);
					editor:SetPos(1,0);
					editor:SetSize(p:GetWide()-1,p:GetTall()-65);
					local mdl = vgui.Create("esMMHatPreview",editor);
					local itemSelected;
					local createIcons; -- prototype
					local invpnl = editor:Add("esPanel");
					invpnl:SetPos(editor:GetWide()-10-105*3,10);
					invpnl:SetSize(105*3,editor:GetTall()-20-10-32);
					invpnl:SetColor(Color(30,30,30))
					local eqpnl = invpnl:Add("esPanel");
					eqpnl:SetSize(invpnl:GetWide(),100);
					eqpnl:SetColor(c);
					local itemname = Label("No item selected",eqpnl);
					itemname:SetPos(105,10);
					itemname:SetFont("Coolvetica28");
					itemname:SetColor(COLOR_WHITE);
					itemname:SizeToContents();
					local spicon = invpnl:Add("SpawnIcon");
					spicon:SetSize(98,98);
					spicon:SetPos(1,1);
					spicon:SetVisible(false);
					local rm = vgui.Create("esIconButton",eqpnl)
					rm:SetIcon(Material("icon16/cancel.png"));
					rm:SetSize(16,16);
					rm:SetPos(100-16-5,5)
					rm.DoClick = function()
						spicon:SetVisible(false);
						rm:SetVisible(false);
						itemname:SetText("No item selected");
						itemname:SizeToContents()
						inv[itemSelected] = inv[itemSelected] and inv[itemSelected] + 1 or 1;
						slots[slot] = {};
						openEditor(slot);
					end
					spicon.OnMouseReleased = rm.DoClick
					rm:SetVisible(false);
					local boneSelected = slots[slot] and slots[slot].bone or "ValveBiped.Bip01_Head1";
					local DComboBox = vgui.Create( "DComboBox",eqpnl )
					DComboBox:SetPos( 105,eqpnl:GetTall()-10-20 )
					DComboBox:SetSize( eqpnl:GetWide()-105-10, 20 )
					DComboBox:SetValue( boneSelected )
					for k,v in pairs(ES.ItemBones)do
						DComboBox:AddChoice( v )
					end
					DComboBox.OnSelect = function( panel, index, value, data )
						boneSelected = value;
						mdl:SetFocus(boneSelected);

						if slots[slot] and slots[slot].item then
							slots[slot].bone = boneSelected;
						end
					end
					local lblPage;
					local page=1;
					local perPage = math.floor((invpnl:GetTall()-100)/105)*3;
					local maxPages = math.ceil(table.Count(inv)/perPage);
					local butPrev = vgui.Create("esIconButton",editor)
					butPrev:SetIcon(Material("exclserver/mmarrowicon.png"));
					butPrev:SetSize(32,32);
					butPrev:SetPos(invpnl.x,invpnl.y + invpnl:GetTall() + 10);
					butPrev.DoClick = function(self)
						page = page - 1;
						if page < 1 then page = 1 end;

						createIcons();
						lblPage:SetText("Inventory Page "..page.."/"..maxPages)
						lblPage:SizeToContents();
					end
					butPrev.Paint = function(self,w,h)
						if not self.Mat then return end
						surface.SetMaterial(self.Mat)
						surface.SetDrawColor(COLOR_WHITE);
						surface.DrawTexturedRectRotated(w/2,w/2,w,w,180);
					end
					local butNext = vgui.Create("esIconButton",editor)
					butNext:SetIcon(Material("exclserver/mmarrowicon.png"));
					butNext:SetSize(32,32);
					butNext:SetPos(butPrev.x + 32 + 16,butPrev.y);
					butNext.DoClick = function(self)
						page = page + 1;
						if page > maxPages then page = maxPages end;

						createIcons();
						lblPage:SetText("Inventory Page "..page.."/"..maxPages)
						lblPage:SizeToContents();
					end
					butNext.Paint = function(self,w,h)
						if not self.Mat then return end
						surface.SetMaterial(self.Mat)
						surface.SetDrawColor(COLOR_WHITE);
						surface.DrawTexturedRectRotated(w/2,w/2,w,w,0);
					end
					lblPage = Label("Inventory Page 1/"..maxPages,editor);
					lblPage:SetFont("Coolvetica28");
					lblPage:SetPos(butNext.x + 32 + 16,butNext.y+2);
					lblPage:SizeToContents();
					lblPage:SetColor(COLOR_WHITE);
					local icons = {};
					createIcons = function()
						for k,v in pairs(icons)do
							if v and IsValid(v) then
								v:Remove();
							end
						end
						icons = {};

						local count_all = 0;
						local count = 0;
						local curRow = 0;
						local curNum = 0;
						for k,v in pairs(inv or {})do	
							if v < 1 then continue end

							count_all = count_all + 1;
							if count >= perPage  or count_all < (page-1) * perPage then
								continue;
							end
							if not first then first = k end
							local icon = vgui.Create("esMMItemBuyTile",invpnl);

							curNum = curNum + 1;

							if curNum > 3 then
								curRow = curRow + 1;
								curNum = 1;
							end

							local it = ES.Items[k];
							if not it then continue end
							icon:SetSize(105,105);
							icon:SetPos((curNum-1)*105,100 + curRow*105);
							icon:PerformLayout();
							icon.icon:SetModel(it.model);
							icon.text = it.name;
							icon.item = it.id;
							icon.OnMouseReleased = function()
								itemname:SetText(it.name);
								itemname:SizeToContents();
								rm:SetVisible(true);
								spicon:SetModel(it.model);
								spicon:SetVisible(true);
								if itemSelected and ES.Items[itemSelected] then
									inv[itemSelected] = inv[itemSelected] + 1;
								end
								itemSelected = k;
								inv[k] = inv[k] - 1;
								createIcons();

								if slots[slot] and slots[slot].item then
									slots[slot].item = k;
									slots[slot].scale = Vector(0,0,0);
								else
									slots[slot] = {};
									slots[slot].item = k;
									slots[slot].bone = boneSelected;
									slots[slot].pos = Vector(0,0,0);
									slots[slot].ang = Angle(0,0,0);
									slots[slot].scale = Vector(0,0,0);
									slots[slot].color = Color(255,255,255);
								end
							end
							count = count + 1;
							table.insert(icons,icon);
						end					
					end
					createIcons();

					local sizePreview = p:GetWide() - 10 - invpnl:GetWide();
					if sizePreview > editor:GetTall()-10-32-10-170 then
						sizePreview = editor:GetTall()-10-32-10-172; 
					end
					mdl:SetPos(1,editor:GetTall()-10-170-10-32-1-sizePreview);
					mdl:SetSize(sizePreview,sizePreview);
					mdl:SetModel(LocalPlayer():ESGetActiveModel());
					mdl:SetLookAt(Vector(0,0,0));
					mdl:SetCamPos(Vector(10,10,10));
					mdl:SetFocus(boneSelected);
					mdl.slots = slots;

					local zoommin = vgui.Create("esIconButton",p)
					zoommin:SetIcon(Material("icon16/zoom_out.png"));
					zoommin:SetSize(16,16);
					zoommin:SetPos(10 + p:GetWide() - 10 - 10 - 10 - invpnl:GetWide() - 16,10);
					zoommin.DoClick = function(self)
						mdl.zoom = mdl.zoom + 2;
						mdl:SetFocus(boneSelected);
					end
					local zoommore = vgui.Create("esIconButton",p)
					zoommore:SetIcon(Material("icon16/zoom_in.png"));
					zoommore:SetSize(16,16);
					zoommore:SetPos(zoommin.x - 8 - 16,zoommin.y);
					zoommore.DoClick = function(self)
						mdl.zoom = mdl.zoom - 2;
						mdl:SetFocus(boneSelected);
					end

					local rotmin = vgui.Create("esIconButton",p)
					rotmin:SetIcon(Material("icon16/arrow_rotate_clockwise.png"));
					rotmin:SetSize(16,16);
					rotmin:SetPos(zoommin.x,zoommin.y + 16+8);
					rotmin.DoClick = function(self)
						mdl.rotate = mdl.rotate + .5;
						mdl:SetFocus(boneSelected);
					end
					local rotmore = vgui.Create("esIconButton",p)
					rotmore:SetIcon(Material("icon16/arrow_rotate_anticlockwise.png"));
					rotmore:SetSize(16,16);
					rotmore:SetPos(rotmin.x - 8 - 16,rotmin.y);
					rotmore.DoClick = function(self)
						mdl.rotate = mdl.rotate - .5;
						mdl:SetFocus(boneSelected);
					end

					local tabpnl = editor:Add("esTabPanel");
					tabpnl:SetSize(p:GetWide() - 10 - 10 - 10 - invpnl:GetWide(),170);
					tabpnl:SetPos(10,editor:GetTall()-10-tabpnl:GetTall()-10-32);
					local pnl = tabpnl:AddTab("Position","icon16/arrow_branch.png");
					local slideX = pnl:Add("esSlider");
					slideX:SetPos(10,10);
					slideX:SetSize(pnl:GetWide() - 20,30);
					slideX.text = "X";
					slideX.min = -8;
					slideX.max = 8;
					slideX:SetValue(slots[slot] and slots[slot].pos and slots[slot].pos.x or 0);
					slideX.Think = function(self) if slots[slot] and slots[slot].pos then
						slots[slot].pos.x = self:GetValue();
					end end
					local slideY = pnl:Add("esSlider");
					slideY:SetPos(10,50);
					slideY:SetSize(pnl:GetWide() - 20,30);
					slideY.text = "Y";
					slideY.min = -8;
					slideY.max = 8;
					slideY:SetValue(slots[slot] and slots[slot].pos and slots[slot].pos.y or 0);
					slideY.Think = function(self) if slots[slot] and slots[slot].pos then
						slots[slot].pos.y = self:GetValue();
					end end
					local slideZ = pnl:Add("esSlider");
					slideZ:SetPos(10,90);
					slideZ:SetSize(pnl:GetWide() - 20,30);
					slideZ.text = "Z";
					slideZ.min = -8;
					slideZ.max = 8;
					slideZ:SetValue(slots[slot] and slots[slot].pos and slots[slot].pos.z or 0);
					slideZ.Think = function(self) if slots[slot] and slots[slot].pos then
						slots[slot].pos.z = self:GetValue();
					end end

					local pnl = tabpnl:AddTab("Angles","icon16/arrow_rotate_clockwise.png");
					local slideP = pnl:Add("esSlider");
					slideP:SetPos(10,10);
					slideP:SetSize(pnl:GetWide() - 20,30);
					slideP.text = "Pitch";
					slideP.min = -180;
					slideP.max = 180;
					slideP:SetValue(slots[slot] and slots[slot].ang and slots[slot].ang.p or 0);
					slideP.Think = function(self) if slots[slot] and slots[slot].ang then
						slots[slot].ang.p = self:GetValue();
					end end
					local slideYa = pnl:Add("esSlider");
					slideYa:SetPos(10,50);
					slideYa:SetSize(pnl:GetWide() - 20,30);
					slideYa.text = "Yaw";
					slideYa.min = -180;
					slideYa.max = 180;
					slideYa:SetValue(slots[slot] and slots[slot].ang and slots[slot].ang.y or 0);
					slideYa.Think = function(self) if slots[slot] and slots[slot].ang then
						slots[slot].ang.y = self:GetValue();
					end end
					local slideR = pnl:Add("esSlider");
					slideR:SetPos(10,90);
					slideR:SetSize(pnl:GetWide() - 20,30);
					slideR.text = "Roll";
					slideR.min = -180;
					slideR.max = 180;
					slideR:SetValue(slots[slot] and slots[slot].ang and slots[slot].ang.r or 0);
					slideR.Think = function(self) if slots[slot] and slots[slot].ang then
						slots[slot].ang.r = self:GetValue();
					end end

					local pnl = tabpnl:AddTab("Scale","icon16/arrow_out.png");
					local slideSX = pnl:Add("esSlider");
					slideSX:SetPos(10,10);
					slideSX:SetSize(pnl:GetWide() - 20,30);
					slideSX.text = "X";
					slideSX.min = -.3;
					slideSX.max = .3;
					slideSX:SetValue(slots[slot] and slots[slot].scale and slots[slot].scale.x or 0);
					slideSX.Think = function(self) if slots[slot] and slots[slot].scale then
						slots[slot].scale.x = self:GetValue();
					end end
					local slideSY = pnl:Add("esSlider");
					slideSY:SetPos(10,50);
					slideSY:SetSize(pnl:GetWide() - 20,30);
					slideSY.text = "Y";
					slideSY.min = -.3;
					slideSY.max = .3;
					slideSY:SetValue(slots[slot] and slots[slot].scale and slots[slot].scale.y or 0);
					slideSY.Think = function(self) if slots[slot] and slots[slot].scale then
						slots[slot].scale.y = self:GetValue();
					end end
					local slideSZ = pnl:Add("esSlider");
					slideSZ:SetPos(10,90);
					slideSZ:SetSize(pnl:GetWide() - 20,30);
					slideSZ.text = "Z";
					slideSZ.min = -.3;
					slideSZ.max = .3;
					slideSZ:SetValue(slots[slot] and slots[slot].scale and slots[slot].scale.z or 0);
					slideSZ.Think = function(self) if slots[slot] and slots[slot].scale then
						slots[slot].scale.z = self:GetValue();
					end end

					local pnl = tabpnl:AddTab("Color","icon16/color_wheel.png");
					local cube = pnl:Add("DColorMixer");
					cube:SetPos(2,2);
					cube:SetSize(256,200);
					cube:SetLabel("")
					cube:SetColor(Color(255,255,255));
					function cube:ValueChanged()
						--ES.PushColorScheme(firstCube:GetColor(),secondCube:GetColor(),thirdCube:GetColor())
					end

					local btnSave = editor:Add("esButton");
					btnSave:SetText("Save changes made to this slot");
					btnSave:SetSize(tabpnl:GetWide(),32);
					btnSave:SetPos(10,editor:GetTall()-10-32);
					btnSave.DoClick = function()
						if slots[slot] and slots[slot].item then
							RunConsoleCommand("es_outfit_customize",slot,slots[slot].item,tostring(slots[slot].pos),tostring(slots[slot].ang),tostring(slots[slot].scale),slots[slot].bone,slots[slot].color.r.." "..slots[slot].color.g.." "..slots[slot].color.b);
						else
							RunConsoleCommand("es_outfit_customize",slot);
						end
					end

					if slots[slot] and slots[slot].item and ES.Items[slots[slot].item] then
						local it = ES.Items[slots[slot].item];
						itemname:SetText(it.name);
						itemname:SizeToContents();
						itemSelected = it.id;
						rm:SetVisible(true);
						spicon:SetModel(it.model);
						spicon:SetVisible(true);
					end
				end
				openEditor(1);
			end},
		})
	end)

	--mm:AddButton("Crafting",Material("icon16/paintbrush.png"),function() mm:CloseChoisePanel(); openWorkingOnIt() end)
	--mm:AddWhitespace();
	mm:AddButton("VIP",Material("icon16/star.png"),function() 
		mm:CloseChoisePanel()
		local p = mm:OpenFrame(600);
		p:SetTitle("VIP");
		local lblVIPHelp = Label("VIPs are special",p)
		lblVIPHelp:SetFont("Coolvetica28");
		lblVIPHelp:SetColor(Color(255,255,255,255));
		lblVIPHelp:SetPos(15,15);
		lblVIPHelp:SizeToContents();
		local lblVIPInfo = Label("",p);
		
		local txt = [[VIP is a special status given to special members. You can buy yourself VIP status for 5000 bananas 
per tier.There are 4 VIP tiers: Bronze, Silver, Gold and Carebear.
Being a VIP gives you special benefits in ExclServer that non-VIPs do not have. 
The gamemode ran by the server may also have implemented VIP benefits.

Not enough bananas? If you donate we will give you a reward in the form of bananas.
Go here to donate: www.CasualBananas.com/forums/donate.php, click anywhere on this 
text to copy this URL to your clipboard (in your browser, press CTRL+V in the URL 
field to paste)
Every $1 you donate will get you 1000 bananas.]];
		if ES:IsCasualFriday() then
			txt = txt..[[
Because today is Casual Friday, bronze VIP is 50% off!]]
		end
		
		lblVIPInfo:SetFont("ESDefaultBold");
		lblVIPInfo:SetText(txt)
		lblVIPInfo:SizeToContents();
		lblVIPInfo:SetPos(15,lblVIPHelp.y + lblVIPHelp:GetTall() + 25);
		lblVIPInfo:SetColor(Color(255,255,255,200))
		function lblVIPInfo:OnMouseReleased()
			SetClipboardText("www.CasualBananas.com/forums/donate.php")
		end

		local curtier = LocalPlayer():ESGetVIPTier();	
		local tbl = vgui.Create("esTable",p);
		tbl:SetPos(15, lblVIPInfo.y + lblVIPInfo:GetTall() + 50)
		tbl:SetSize(p:GetWide()-30,280);
		tbl:SetRows(5,8);
		tbl.headColors[2] = Color(152,101,0);
		tbl.headColors[3] = Color(180,180,180);
		tbl.headColors[4] = Color(245,184,0);
		tbl.headColors[5] = Color(201,53,71);
		tbl.itemPrice[2] = (1 - curtier) * 5000;
		if ES:IsCasualFriday() then
			tbl.itemPrice[2] = math.Round( tbl.itemPrice[2] * 0.5 );
		end
		if tbl.itemPrice[2] < 0 then tbl.itemPrice[2] = 0; end
		tbl.itemPrice[3] = (2 - curtier) * 5000;
		if tbl.itemPrice[3] < 0 then tbl.itemPrice[3] = 0; end
		tbl.itemPrice[4] = (3 - curtier) * 5000;
		if tbl.itemPrice[4] < 0 then tbl.itemPrice[4] = 0; end
		tbl.itemPrice[5] = (4 - curtier) * 5000;
		if tbl.itemPrice[5] < 0 then tbl.itemPrice[5] = 0; end

		tbl.rows[2][1] = "Bronze"
		tbl.rows[3][1] = "Silver"
		tbl.rows[4][1] = "Gold"
		tbl.rows[5][1] = "Carebear"

		tbl.rows[1][2] = "Joke access";
		tbl.rows[2][2] = true;
		tbl.rows[3][2] = true;
		tbl.rows[4][2] = true;
		tbl.rows[5][2] = true;
		tbl.rows[1][3] = "VIP items";
		tbl.rows[2][3] = true;
		tbl.rows[3][3] = true;
		tbl.rows[4][3] = true;
		tbl.rows[5][3] = true;
		tbl.rows[1][4] = "Long trail";
		tbl.rows[3][4] = true;
		tbl.rows[4][4] = true;
		tbl.rows[5][4] = true;
		tbl.rows[1][5] = "Thirdperson";
		tbl.rows[4][5] = true;
		tbl.rows[5][5] = true;
		tbl.rows[1][6] = "Player models";
		tbl.rows[4][6] = true;
		tbl.rows[5][6] = true;
		tbl.rows[1][7] = "Hat particles";
		tbl.rows[5][7] = true;
		tbl.rows[1][8] = "Large trail";
		tbl.rows[2][8] = false;
		tbl.rows[3][8] = false;
		tbl.rows[4][8] = false;
		tbl.rows[5][8] = true;

		tbl.buttons[2]:SetDoClick(function()
			if LocalPlayer():ESGetVIPTier() >= 1 then return end
			RunConsoleCommand("excl","buyvip","1")
			p:GetParent():Remove();
		end)
		tbl.buttons[3]:SetDoClick(function()
			if LocalPlayer():ESGetVIPTier() >= 2 then return end
			RunConsoleCommand("excl","buyvip","2")
			p:GetParent():Remove();
		end)
		tbl.buttons[4]:SetDoClick(function()
			if LocalPlayer():ESGetVIPTier() >= 3 then return end
			RunConsoleCommand("excl","buyvip","3")
			p:GetParent():Remove();
		end)
		tbl.buttons[5]:SetDoClick(function()
			if LocalPlayer():ESGetVIPTier() >= 4 then return end
			RunConsoleCommand("excl","buyvip","4")
			p:GetParent():Remove();
		end)
	end)
	--mm:AddWhitespace();
	mm:AddButton("Achievements",Material("icon16/rosette.png"),function()
		mm:CloseChoisePanel()
		local p = mm:OpenFrame(640)
		p:SetTitle("Achievements");

		local stat = p:Add("esMMPanel");
		stat:SetSize(p:GetWide()-30,60);
		stat:SetPos(15,15);
		stat:SetColor(ES.GetColorScheme(3))

		local cnt = 0;
		for k,v in pairs(ES.Achievements)do
			if LocalPlayer():ESHasCompletedAchievement(k) then
				cnt = cnt+1;
			end
		end
		local lbl = Label(cnt.." / "..table.Count(ES.Achievements).." Unlocked",stat);
		lbl:SetFont("ES.MainMenu.MainElementInfoBnns")
		lbl:SizeToContents();
		lbl:SetPos(12,12);
		lbl:SetColor(COLOR_WHITE);

		local context = p:Add("Panel");
		context:SetSize(p:GetWide()-30,p:GetTall() - (stat:GetTall() + 15 + stat.y + 15));
		context:SetPos(15,stat:GetTall() + 15 + stat.y);
		local y = 0;
		for k,v in pairs(ES.Achievements)do
			local ach = context:Add("esMMPanel");
			ach:SetPos(0,y);
			ach:SetSize(context:GetWide()-15-2,110);

			local ic = ach:Add("DImage");
			ic:SetMaterial(v.icon);
			ic:SetSize(64,64);
			ic:SetPos(8,8);

			local lb2 = Label(v.name,ach);
			lb2:SetFont("ESAchievementFontBig");
			lb2:SetPos(72+6,10);
			lb2:SizeToContents();
			lb2:SetColor(COLOR_WHITE);

			local lbl = Label(v.hidden and !LocalPlayer():ESHasCompletedAchievement(k) and "<secret>" or ES.FormatLine(v.descr,"ESDefault",ach:GetWide() - 80 - 4 - 4) or "Unknown",ach);
			lbl:SetFont("ESDefault");
			lbl:SizeToContents();
			lbl:SetPos(lb2.x+2,lb2.y + lb2:GetTall()+3);
			lbl:SetColor(COLOR_WHITE);

			local dr = vgui.Create("Panel",ach);
			dr:SetPos(5,ach:GetTall()-25);
			dr:SetSize(ach:GetWide() - 10,20);
			local a = ES.GetColorScheme();
			dr.Paint = function(self,w,h)
				draw.RoundedBox(2,0,0,w,h,COLOR_BLACK);

				if (LocalPlayer().excl.achievements and LocalPlayer().excl.achievements[v.id] or 0) > 0 then
					draw.RoundedBox(2,1,1,(w-2)*((LocalPlayer().excl.achievements and LocalPlayer().excl.achievements[v.id] or 0)/ES.Achievements[v.id].progressNeeded),h-2,a);
				end
				draw.SimpleText((LocalPlayer().excl.achievements and LocalPlayer().excl.achievements[v.id] or 0).." / "..ES.Achievements[v.id].progressNeeded,"ESDefaultBoldBlur",w/2,h/2,COLOR_BLACK,1,1);
				--draw.SimpleText(p.excl.achievements[id].." / "..ES.Achievements[id].progressNeeded,"ESDefaultBold",w/2 +1,h/2 +1,COLOR_BLACK,1,1);
				draw.SimpleText((LocalPlayer().excl.achievements and LocalPlayer().excl.achievements[v.id] or 0).." / "..ES.Achievements[v.id].progressNeeded,"ESDefaultBold",w/2,h/2,COLOR_WHITE,1,1);
			end

			y = y + ach:GetTall() + 1;
		end

		local scr = context:Add("esScrollbar");
		scr:SetPos(context:GetWide()-15,0);
		scr:SetSize(15,context:GetTall());
		scr:SetUp()
	end);
	--mm:AddWhitespace();
	mm:AddButton("Server list",Material("icon16/server.png"),function()
		mm:CloseChoisePanel()
		local p = mm:OpenFrame(640)
		p:SetTitle("Servers");
		local page = 1;
		local cbcservers = {};
		local perPage = 4
		local pnls = {};
		local function buildServers()
			for k,v in pairs(pnls)do if v and IsValid(v) then v:Remove() end end
			local c = 0;
			for k,v in pairs(cbcservers)do
				if k > (page-1)*perPage and k <= page*perPage then
					
					local row = vgui.Create("esMMServerRow",p);
					row:SetSize(p:GetWide()-30,130);
					row:SetPos(15,15 + c*(130+10));
					row.name = v.name;
					row.ip = v.ip;
					row.mapname = v.mapname;
					row.password = v.password;
					row.players = v.players
					row.maxplayers = v.maxplayers;
					row.mapicon = v.mapicon;

					c=c+1;
					table.insert(pnls,1,row);
				end
			end
		end

		local lblPage = Label("Page 1/1",p);
		http.Fetch("http://casualbananas.com/forums/inc/servers/cache/servers.gmod.json.php",
			function(rtrn)
				if !IsValid(p) then return end

				cbcservers = util.JSONToTable(rtrn);
				perPage = 0;
				local tall = 15+15+34+15+128;
				while tall < p:GetTall() do
					perPage = perPage+1;
					tall = tall + 138;
				end

				buildServers();

				lblPage:SetText(page.."/"..math.ceil(#cbcservers/perPage))				
			end,
			function()end
		);
		
		lblPage:SetColor(COLOR_WHITE);
		lblPage:SetFont("ESDefaultBold");
		lblPage:SizeToContents();
		lblPage:SetPos(15+32+10+32+15,p:GetTall()-15-25);
		local butPrev = vgui.Create("esIconButton",p)
				butPrev:SetIcon(Material("exclserver/mmarrowicon.png"));
				butPrev:SetSize(32,32);
				butPrev:SetPos(15,p:GetTall()-15-32);
				butPrev.DoClick = function(self)
					page = page - 1;
					if page < 0 then page = 1 return end;

					buildServers();

					
					lblPage:SetText(page.."/"..math.ceil(#cbcservers/perPage))
				end
				butPrev.Paint = function(self,w,h)
					if not self.Mat then return end
					
					surface.SetMaterial(self.Mat)
					if page-1 < 0 then
						surface.SetDrawColor(Color(150,150,150));
					else
						surface.SetDrawColor(COLOR_WHITE);
					end
					
					surface.DrawTexturedRectRotated(w/2,w/2,w,w,180);

				end
			local butNext = vgui.Create("esIconButton",p)
				butNext:SetIcon(Material("exclserver/mmarrowicon.png"));
				butNext:SetSize(32,32);
				butNext:SetPos(butPrev.x+32+10,butPrev.y);
				butNext.DoClick = function(self)
					page = page + 1;
					if page > math.ceil(#cbcservers/perPage) then 
						page = math.ceil(#cbcservers/perPage) 
						return;
					end

					buildServers();

					lblPage:SetText(page.."/"..math.ceil(#cbcservers/perPage))
				end
				butNext.Paint = function(self,w,h)
					if not self.Mat then return end
					
					surface.SetMaterial(self.Mat)
					--if !models[page+1] then
					--	surface.SetDrawColor(Color(150,150,150));
					--else
						surface.SetDrawColor(COLOR_WHITE);
					--end
					surface.DrawTexturedRectRotated(w/2,w/2,w,w,0);

				end
	end)
	mm:AddButton("Player list",Material("icon16/user.png"),function()
		mm:CloseChoisePanel()
		local p = mm:OpenFrame(320+320+5+15+15);
		p:SetTitle("Players");

		local context = p:Add("EditablePanel");
		context:SetSize(p:GetWide()-30,p:GetTall()-60);
		context:SetPos(15,15);

		local max = math.floor(context:GetTall()/57);
		local page = 0;
		local tickskip = 0;
		local oldAll;
		function context:Think()
			if not self.rows then 
				self.rows = {} 
			end
			
				for k,v in pairs(player.GetAll())do
					if not v.esMMPlayerRow or not IsValid(v.esMMPlayerRow) then
						v.esMMPlayerRow = vgui.Create("esMMPlayerRow",self);
						v.esMMPlayerRow:Setup(v);
						v.esMMPlayerRow:PerformLayout();
						v.esMMPlayerRow:SetSize(320,52);
						v.esMMPlayerRow:SetPos(0,0);
						table.insert(self.rows,v.esMMPlayerRow);
					end
				end
				local colomn = 0;
				local row = 0;
				local skip = 0;

				for k,v in pairs(self.rows)do
					if not v or not k or not IsValid(v) then continue end

					if IsValid(v) and IsValid(v.Player) and colomn <= 1 and skip >= (page * max * 2) then
						v:SetVisible(true);
						v:SetPos(5 + 325*colomn,(row)*(57))
						row = row + 1;
						if row >= max then
							row = 0;
							colomn = colomn + 1;
						end
					elseif IsValid(v) and not IsValid(v.Player) then
						v:Remove();
					elseif IsValid(v) then
						v:SetVisible(false);
						skip = skip + 1;
					end
				end

		end
		local butPrev = vgui.Create("esIconButton",p)
		butPrev:SetIcon(Material("exclserver/mmarrowicon.png"));
		butPrev:SetSize(32,32);
		butPrev:SetPos(20,p:GetTall()-32-15);
		butPrev.DoClick = function(self)
			page = page - 1;
			if page < 0 then page = 0 end
		end
		butPrev.Paint = function(self,w,h)
			if not self.Mat then return end
						
			surface.SetMaterial(self.Mat)
			surface.SetDrawColor(COLOR_WHITE);
			surface.DrawTexturedRectRotated(w/2,w/2,w,w,180);
		end

		local butNext = vgui.Create("esIconButton",p)
		butNext:SetIcon(Material("exclserver/mmarrowicon.png"));
		butNext:SetSize(32,32);
		butNext:SetPos(butPrev.x + butPrev:GetWide() + 32/2,butPrev.y);
		butNext.DoClick = function(self)
			page = (page + 1)
			if page+1 >  math.ceil( #player.GetAll() / (max*2) ) then
				page =  math.ceil( #player.GetAll() / (max*2) )-1;
			end
		end
		butNext.Paint = function(self,w,h)
			if not self.Mat then return end
						
			surface.SetMaterial(self.Mat)
			surface.SetDrawColor(COLOR_WHITE);
			surface.DrawTexturedRectRotated(w/2,w/2,w,w,0);
		end

		local lblPg = Label("Page 1/1",p);
		lblPg:SetFont("ESDefaultBold");
		lblPg:SetPos(butNext.x + butNext:GetWide() +32/2, butNext.y+1);
		lblPg:SetColor(COLOR_WHITE);
		lblPg:SizeToContents();
		lblPg.Think = function(self)
			self:SetText("Page "..tostring(page+1).."/".. math.ceil( #player.GetAll() / (max*2) ) )
			self:SizeToContents();
		end
	

		local lblPl = Label("0 active players",p);
		lblPl:SetFont("ESDefaultBold");
		lblPl:SetPos(lblPg.x, lblPg.y + lblPg:GetTall() + 1);
		lblPl:SetColor(COLOR_WHITE);
		lblPl:SizeToContents();
		lblPl.Think = function(self)
			self:SetText(#player.GetAll().." active players")
			self:SizeToContents();
		end

		--[[local muteall = p:Add("esButton");
		muteall:SetText("Mute all");
		muteall:SetSize(90,20);
		muteall:SetPos(p:GetWide()-15-90,p:GetTall()-15-20);
		muteall.DoClick = function()
			for k,v in pairs(player.GetAll())do
				if IsValid(v) then
					v:SetMuted(true);
				end
			end
		end
		local unmuteall = p:Add("esButton");
		unmuteall:SetText("Unmute all");
		unmuteall:SetSize(90,20);
		unmuteall:SetPos(muteall.x-15-90,p:GetTall()-15-20);
		unmuteall.DoClick = function()
			for k,v in pairs(player.GetAll())do
				if IsValid(v) then
					v:SetMuted(false);
				end
			end
		end]]
	end)
--mm:AddWhitespace();
mm:AddButton("Website",Material("icon16/world.png"),function()
		mm:CloseChoisePanel()
		local p = mm:OpenFrame();
		p:SetTitle("Community Website");

		local lbl = Label("Loading...",p);
		lbl:SetFont("ESDefaultBold");
		lbl:SizeToContents();
		lbl:Center();
		lbl:SetColor(COLOR_WHITE);

		local web = vgui.Create("HTML",p);
		web:SetSize(p:GetWide()-2,p:GetTall()-1);
		web:SetPos(1,0);
		web:OpenURL("http://casualbananas.com/")
	end)
	----mm:AddWhitespace();
	--[[mm:AddButton("Music",Material("icon16/sound.png"),function()
		mm:CloseChoisePanel()
		local p = mm:OpenFrame();
		p:SetTitle("Music Player");

		local ply = p:Add("esMMMusicPlayer");
		ply:SetPos(15,15);
		ply:SetSize(p:GetWide()-30,100);
	end)]]

end

net.Receive("ESToggleMenu",function() ES:CreateMainMenu() end);

local was_pressed = false;
hook.Add("Think","exclMMOpenWithF5",function()
	if input.IsKeyDown(KEY_F6) and not was_pressed then
		was_pressed = true;
		ES:CreateMainMenu()
	elseif not input.IsKeyDown(KEY_F6) then
		was_pressed = false;
	end
end)