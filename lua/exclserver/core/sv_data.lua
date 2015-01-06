-- Edit these variables to configurate MySQL.
-- You can download MySQL server from the official MySQL website.

local DATABASE_HOST 	= "localhost";	-- (String) IPv4 IP of the mysql server.
local DATABASE_PORT 	= 3306;			-- (Number) mysql server port.
local DATABASE_SCHEMA 	= "exclserver"; -- (String) name of the schema that should be used.
local DATABASE_USERNAME = "root";		-- (String) Username
local DATABASE_PASSWORD = "rordrmew";   -- (String) Password

-- Do not edit anything under this line, unless you're a competent Lua developer.

ES.ServerID = 0;

require "mysqloo"

if not mysqloo then 
	ES:DebugPrint("MySQLOO module not found. Please install the MySQLOO module before using ExclServer.");
	return;
end

local db;
local db = mysqloo.connect( DATABASE_HOST, DATABASE_USERNAME, DATABASE_PASSWORD, DATABASE_SCHEMA, DATABASE_PORT );

local function mysqlError(q,e)
	e = string.gsub(e,"You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near","Syntax error at");
	ES:DebugPrint("MySQL error:")
	ES:DebugPrint("   > "..q);
	ES:DebugPrint("   < error: "..e);
end	
function ES.DBQuery(q,c,cError)
	if db:status() != mysqloo.DATABASE_CONNECTED then 
		ES.DebugPrint("Lost connection to MySQL server, reconnecting...");
		db:connect();
	end
		
	local query = db:query(q);
	--query:setOption(mysqloo.OPTION_CACHE,true);
	query.onError = cError or (function(Q,E) 
		 mysqlError(q,E)
	end)
	query.onSuccess = function()
		if not c or type(c) != "function" then return end
		c( query:getData() )
	end
	query:start()
end
function ES.DBEscape(t)
 	return db:escape(t);
end

local esData= {}
local esDataTables = {};
local postSetup = false;
function ES:DefineDataTable(name,lol,vars)
	if vars then
		vars = vars..",";
	end

	table.insert(esDataTables,{name = name,loadOnLoad = (lol or false),vars = (vars or "")});

	ES:CheckDataTablesInDatabase()
end
function ES:CheckDataTablesInDatabase()
	if not postSetup then return end

	for k,v in pairs(esDataTables)do
		ES.DebugPrint("Checking/Creating validation of table "..v.name);
		ES.DBQuery("CREATE TABLE IF NOT EXISTS es_"..v.name.." ( id int(16) NOT NULL AUTO_INCREMENT,"..v.vars.." PRIMARY KEY (id) );",function() end);
	end	
end
hook.Add("InitPostEntity","ESCheckTablesExist",function()
	
end)
function ES:AddPlayerData(p,k,v,nosave)
	v=tostring(v);
	if not p.excl then 
		p.excl = {} 
	end
	p.excl[k] = v;

	if nosave then return end
	
	ES.DBQuery("UPDATE es_player SET "..k.." = '"..ES.DBEscape(v).."' WHERE id = "..tonumber(p:NumSteamID())..";", function() end);
end

db.onConnected = function(database)
	ES:DefineDataTable( "player",false,	"steamid varchar(32), bananas int(32), inventory varchar(255), invmodel char(255), invtrail char(255), invmelee char(255), invtaunt char(255), invaura char(255), activehat varchar(64), activeaura varchar(64), activetrail varchar(64), activemelee varchar(255), activemodel varchar(255), viptier int(8), trailcolor varchar(255), trailscale varchar(255), slot1 varchar(255), slot2 varchar(255), slot3 varchar(255), slot4 varchar(255), slot5 varchar(255), slot6 varchar(255), slot7 varchar(255), slot8 varchar(255)")
	ES:DefineDataTable( "servers_lookup",false,	"ip varchar(100), prettyname varchar(100)")
	hook.Call("ESPreCreateDatatables")
	postSetup = true;
	ES:CheckDataTablesInDatabase()
	db:wait();
	ES.DBQuery("SELECT id FROM es_servers_lookup WHERE ip = '"..exclGetIP().."' LIMIT 1;",function(r)
		if r and r[1] then
			ES.ServerID = r[1].id;
			hook.Call("ESPostGetServerID")
		else
			ES.DBQuery("INSERT INTO es_servers_lookup SET ip = '"..exclGetIP().."';",function()
				ES.DBQuery("SELECT id FROM es_servers_lookup WHERE ip = '"..exclGetIP().."' LIMIT 1;",function(r)
					if r and r[1] then
						ES.ServerID = r[1].id;
						hook.Call("ESPostGetServerID")
					end
				end);
			end)
			db:wait();
		end
	end)
	db:wait();
	hook.Call("ESOnDatabaseConnected")
end;
db.onConnectionFailed = function(Q,e) 
	ES.DebugPrint("Could not connect to mysql, "..e);
end
hook.Add("Initialize","ES.Database.Connect",function()
	db:connect();
	db:wait();
end);
hook.Add("ESPostGetServerID","ES.Database.ServerID",function()
	ES.DebugPrint("Server ID set: "..ES.ServerID);

	for k,v in pairs(esDataTables) do
		if v.loadOnLoad and type(v.loadOnLoad) == "function" then
			v.loadOnLoad(ES.ServerID);
		end
	end
end)
hook.Add("ESPostGetServerID","ES.Database.PrintActive",function()
	ES.DebugPrint("Database connection active");
end)