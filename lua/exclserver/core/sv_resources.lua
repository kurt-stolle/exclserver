-- sv_resources.lua
function ES.ResourceDir(dir)
	local fils,dirs = file.Find(dir.."/*","GAME")
	for k,v in pairs(fils) do
		resource.AddSingleFile( string.gsub(string.gsub(dir,"addons/exclserver/",""),"//","/").."/"..v )
	end
	for k,v in pairs(dirs)do
		ES.ResourceDir(dir.."/"..v)
	end
end

resource.AddWorkshop("403938948")
/*
ES.ResourceDir("addons/exclserver/materials")
ES.ResourceDir("addons/exclserver/models")
ES.ResourceDir("addons/exclserver/sounds")
ES.ResourceDir("addons/exclserver/resource")
*/
