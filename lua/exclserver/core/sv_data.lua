-- Edit these variables to configurate MySQL.
-- You can download MySQL server from the official MySQL website.

local DATABASE_HOST 	= "localhost";	-- (String) IPv4 IP of the mysql server.
local DATABASE_PORT 	= 3306;			-- (Number) mysql server port.
local DATABASE_SCHEMA 	= "exclserver"; -- (String) name of the schema that should be used.
local DATABASE_USERNAME = "root";		-- (String) Username
local DATABASE_PASSWORD = "rordrmew";   -- (String) Password

-- Do not edit anything under this line, unless you're a competent Lua developer.

require "mysqloo"

ES.ServerID = 0;

if not mysqloo then 
	ES:DebugPrint("MySQLOO module not found. Please install the MySQLOO module before using ExclServer.");
	return;
end
local esDataTables = {};
local db = mysqloo.connect( DATABASE_HOST, DATABASE_USERNAME, DATABASE_PASSWORD, DATABASE_SCHEMA, DATABASE_PORT );
db.onConnected = function(database)
	ES.DebugPrint("Successfully connected to MySQL database! :)");

	hook.Call("ESDBDefineTables")
	for k,v in pairs(esDataTables)do
		ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_"..v.name.."` ( `id` int(16) unsigned NOT NULL AUTO_INCREMENT,"..v.vars.." PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;",function() end);
		ES.DBWait();
	end
end;
db.onConnectionFailed = function(Q,e) 
	ES.DebugPrint("Could not connect to mysql, "..e);
end

local function MySQLError(q,e)
	e = string.gsub(e,"You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near","Syntax error at");
	ES.DebugPrint("MySQL error:")
	ES.DebugPrint("   > "..tostring(q));
	ES.DebugPrint("   < error: "..e);
end

function ES.DBQuery(request,fn,fnError)
	if db:status() != mysqloo.DATABASE_CONNECTED then 
		ES.DebugPrint("No connection to MySQL server active, (re)connecting.");
		db:connect();
		db:wait();
	end
		
	local query = db:query(request);
	query:setOption(mysqloo.OPTION_CACHE,true);
	query.onError = fnError or (MySQLError)
	query.onSuccess = function(self,dt)
		if not fn or type(fn) != "function" then return end
		fn( dt )
	end
	query:start()
end
function ES.DBEscape(t)
 	return db:escape(t);
end
function ES.DBWait()
	return db:wait();
end

function ES.DBDefineTable(name,onLoad,vars)
	if vars then
		vars = vars..",";
	end

	table.insert(esDataTables,{name = name,onLoad = (onLoad or false),vars = (vars or "")});
end
ES.DBDefineTable( "player",false,	"steamid varchar(32), bananas int(32) unsigned, inventory varchar(255), invmodel char(255), invtrail char(255), invmelee char(255), invtaunt char(255), invaura char(255), activehat varchar(64), activeaura varchar(64), activetrail varchar(64), activemelee varchar(255), activemodel varchar(255), viptier int(8), trailcolor varchar(255), trailscale varchar(255), slot1 varchar(255), slot2 varchar(255), slot3 varchar(255), slot4 varchar(255), slot5 varchar(255), slot6 varchar(255), slot7 varchar(255), slot8 varchar(255)")

function ES:AddPlayerData(p,k,v,nosave)
	v=tostring(v);
	if not p.excl then 
		p.excl = {} 
	end
	p.excl[k] = v;

	if nosave then return end
	
	ES.DBQuery("UPDATE es_player SET "..k.." = '"..ES.DBEscape(v).."' WHERE id = "..tonumber(p:ESID())..";", function() end);
end

hook.Add("Initialize","ES.Data.OnLoadFunctions",function()
	for k,v in pairs(esDataTables) do
		if v.onLoad and type(v.onLoad) == "function" then
			v.onLoad(ES.ServerID);
		end
	end
end)

-- Some important queries.
ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_bans` (`id` int(8) unsigned NOT NULL AUTO_INCREMENT, steamid varchar(100),steamidAdmin varchar(100), name varchar(100), nameAdmin varchar(100), serverid int(8), unbanned tinyint(1), time int(32), timeStart int(32), reason varchar(255), PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=utf8;")
ES.DBWait();
ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_servers` ( `id` int(8) unsigned NOT NULL AUTO_INCREMENT, ip varchar(100), prettyname varchar(100), PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=utf8;")
ES.DBWait();
ES.DBQuery("SELECT id FROM es_servers WHERE ip = '"..exclGetIP().."' LIMIT 1;",function(r)
	if r and r[1] then
		ES.ServerID = r[1].id;
	else
		ES.DBQuery("INSERT INTO es_servers SET ip = '"..exclGetIP().."';",function()
			ES.DBQuery("SELECT id FROM es_servers WHERE ip = '"..exclGetIP().."' LIMIT 1;",function(r)
				if r and r[1] then
					ES.ServerID = r[1].id;
				end
			end);
			ES.DBWait();
		end)
		ES.DBWait()
	end
end)
ES.DBWait() 