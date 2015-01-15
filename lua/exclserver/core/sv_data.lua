-- Edit these variables to configurate MySQL.
-- You can download MySQL server from the official MySQL website.

local DATABASE_HOST 	= "167.114.72.167";						-- (String) IPv4 IP of the mysql server.
local DATABASE_PORT 	= 3306;									-- (Number) mysql server port.
local DATABASE_SCHEMA 	= "exclserver"; 						-- (String) name of the schema that should be used.
local DATABASE_USERNAME = "exclserver";							-- (String) Username
local DATABASE_PASSWORD = "#ExclServer2TestDatabases";   		-- (String) Password

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
end;
db.onConnectionFailed = function(Q,e) 
	ES.DebugPrint("Could not connect to mysql, "..e);
end

local function MySQLError(q,e,sql)
	e = string.gsub(e,"You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near","Syntax error at");
	ES.DebugPrint("MySQL error:")
	ES.DebugPrint("   > "..tostring(sql));
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

	return query
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
ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_settings` (`id` SMALLINT(5) unsigned NOT NULL, value int(10), name varchar(22), serverid tinyint(3) unsigned, PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1;")
ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_player` (`id` int(10) unsigned NOT NULL, steamid varchar(100), inventory varchar(255), models varchar(255), trails varchar(255), meleeweapons varchar(255), auras varchar(255), PRIMARY KEY (`id`), UNIQUE KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;")
ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_player_fields` (`id` int(10) unsigned NOT NULL, PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=InnoDB DEFAULT CHARSET=latin1;")
ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_player_outfit` (`id` int(10) unsigned NOT NULL, slot int(8) unsigned NOT NULL, item varchar(255), x float(8,4), y float(8,4), z float(8,4), pitch float(8,5), yaw float(8,5), roll float(8,5), scale float(8,4), red int(3), green int(3), blue int(3), UNIQUE KEY (`id`, `slot`)) ENGINE=MyISAM DEFAULT CHARSET=latin1;")
ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_ranks` ( `id` int(10) unsigned NOT NULL AUTO_INCREMENT, steamid varchar(50), serverid int(10), rank varchar(100), PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1;" )
ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_bans` (`ban_id` int(10) unsigned NOT NULL AUTO_INCREMENT, steamid varchar(100), steamidAdmin varchar(100), name varchar(100), nameAdmin varchar(100), serverid int(8), unbanned tinyint(1), time int(32), timeStart int(32), reason varchar(255), PRIMARY KEY (`ban_id`), UNIQUE KEY `ban_id` (`ban_id`)) ENGINE=MyISAM DEFAULT CHARSET=utf8;");

ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_ranks_config` ( `id` int(10) unsigned NOT NULL AUTO_INCREMENT, name varchar(100), prettyname varchar(200), power int(16), PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1;"):wait();
ES.DBQuery("SELECT * FROM es_ranks_config;",function(data)
	if not data or not data[1] then return end
	for k,v in pairs(data)do
		ES.SetupRank(v.name,v.prettyname,tonumber(v.power));
	end
end):wait();

ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_servers` ( `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT, ip varchar(100), prettyname varchar(100), PRIMARY KEY (`id`), UNIQUE KEY (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1;"):wait();
ES.DBQuery("SELECT id FROM es_servers WHERE ip = '"..exclGetIP().."' LIMIT 1;",function(r)
	if r and r[1] then
		ES.ServerID = r[1].id;
	else
		ES.DBQuery("INSERT INTO es_servers SET ip = '"..exclGetIP().."';",function()
			ES.DBQuery("SELECT id FROM es_servers WHERE ip = '"..exclGetIP().."' LIMIT 1;",function(r)
				if r and r[1] then
					ES.ServerID = r[1].id;
				end
			end):wait();
		end):wait();
	end
end):wait();
