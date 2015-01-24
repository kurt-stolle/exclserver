-- sh_inventory_new.lua
ES.Props = {};

function  ES.AddProp(n,d,p,t,vip,scale)
	local tab=ES.Item( ES.ITEM_PROP );
	tab:SetName(n);
	tab:SetDescription(d);
	tab:SetCost(p);
	if file.Exists(t,"GAME") then
		tab:SetModel(t);
	else
		ES.DebugPrint("Prevented unknown model: "..t);
	end
	tab:SetVIP(bVip);

	table.insert(ES.Props,tab);
end

ES.PropBones = {
	"ValveBiped.Bip01_Pelvis",
	"ValveBiped.Bip01_Spine",
	"ValveBiped.Bip01_Spine1",
	"ValveBiped.Bip01_Spine2",
	"ValveBiped.Bip01_Spine4",
	"ValveBiped.Bip01_Neck1",
	"ValveBiped.Bip01_Head1",
	"ValveBiped.Bip01_R_Clavicle",
	"ValveBiped.Bip01_R_UpperArm",
	"ValveBiped.Bip01_R_Forearm",
	"ValveBiped.Bip01_R_Hand",
	"ValveBiped.Bip01_L_Clavicle",
	"ValveBiped.Bip01_L_UpperArm",
	"ValveBiped.Bip01_L_Forearm",
	"ValveBiped.Bip01_L_Hand",
	"ValveBiped.Bip01_R_Clavicle",
	"ValveBiped.Bip01_R_Thigh",
	"ValveBiped.Bip01_R_Calf",
	"ValveBiped.Bip01_R_Foot",
	"ValveBiped.Bip01_R_Toe0",
	"ValveBiped.Bip01_L_Thigh",
	"ValveBiped.Bip01_L_Calf",
	"ValveBiped.Bip01_L_Foot",
	"ValveBiped.Bip01_L_Toe0"
}

ES.AddProp("The hunting prize","An antlion's dismembered head.",800,"models/Gibs/Antlion_gib_Large_2.mdl")
ES.AddProp("Cleaver","Cleaves.\nFor the more hardcore members.",200,"models/props_lab/Cleaver.mdl")
ES.AddProp("Cone","For the classy hobo.",280,"models/props_junk/TrafficCone001a.mdl")
ES.AddProp("Head bowl","Makes you feel like a cat in the water.",250,"models/props/de_nuke/emergency_lighta.mdl",true)
ES.AddProp("Cyclops specs","It's techy so it just has to make you look cool.",170,"models/props_wasteland/light_spotlight01_lamp.mdl")
ES.AddProp("Gman head","...",8000,"models/MaxOfS2D/balloon_gman.mdl")
ES.AddProp("Harmless harpoon","A harmless harpoon. \nYou might get stuck between doors.",130,"models/props_junk/harpoon002a.mdl",true,0.5)
ES.AddProp("Helicopter droppings","A bomb",1300,"models/Combine_Helicopter/helicopter_bomb01.mdl",true,.6)
ES.AddProp("Hula","Excl is lazy",250,"models/props_lab/huladoll.mdl")
ES.AddProp("Lil panny","Creative in many ways",400,"models/props_interiors/pot02a.mdl")
ES.AddProp("Melon afro","Race has nothing to do with this.\nHey Jordan.",500,"models/props_junk/watermelon01.mdl")
ES.AddProp("Mossman head","...",8000,"models/MaxOfS2D/balloon_mossman.mdl")
ES.AddProp("Head monitor","Looks silly",300,"models/props_lab/monitor02.mdl")
ES.AddProp("Plug","For the modern leprichaun..",1800,"models/props_lab/tpplug.mdl")
ES.AddProp("Skeleton head","2spooky4u.",300,"models/Gibs/HGIBS.mdl")
ES.AddProp("Traffic light","Groovy",8000,"models/props_phx/misc/t_light_head.mdl",true,.8)
ES.AddProp("Pothead","The perfect pottery for the perfect hat.",2300,"models/props_c17/pottery_large01a.mdl",false,.6)