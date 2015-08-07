-- Edit these variables to configurate MySQL.

local DATABASE_HOST     = "localhost"--"198.50.146.120"--                                     -- (String) IPv4 IP of the mysql server.
local DATABASE_PORT     = 3306;                                                 -- (Number) mysql server port.
local DATABASE_SCHEMA   = "exclserver";                                         -- (String) name of the schema that shoul$
local DATABASE_USERNAME = "root"-- "exclserver"--                                    -- (String) Username
local DATABASE_PASSWORD = "rordrmew"--"#x6eQ56m593r83b5mky2YvbeP64E2MyQP"--						  		-- (String) Password

-- Do not edit anything under this line, unless you're a competent Lua developer.

--[[

result format;
Results {
	[1] = {
		status = true/false,
		error = the error string,
		affected = number of rows affected by the query,
		lastid = the index of the last row inserted by the query,
		data = {
			{
				somefield = "some shit",
			}
		},
	},
}

]]

require("tmysql4")

ES.ServerID = -1

local conn,err = tmysql.initialize(DATABASE_HOST,DATABASE_USERNAME,DATABASE_PASSWORD,DATABASE_SCHEMA,DATABASE_PORT,nil,CLIENT_MULTI_STATEMENTS)

if err then
	ES.Error("MYSQL_CONNECT_FAILED",err)

	hook.Add("InitPostEntity","exclserver.data.restart",function()
		RunConsoleCommand("changelevel",game.GetMap())
	end)
	return;
end

-- OLD FUNCTIONS, for legacy support
function ES.DBEscape(str)
	return conn:Escape(str);
end

local function cbFailed(...)
	for k,v in ipairs{...}do
		if v then
			ES.DebugPrint("MySQL query failed: ",v)
		end
	end
end
function ES.DBQuery(query,callback,callbackFailed)
	callbackFailed = callbackFailed or cbFailed;

	return conn:Query(query,function(res)
		local retSuccess={}
		local retFail={}

		local failed=false
		for k,v in ipairs(res)do
			if v.error then
				retSuccess[k]={};
				retFail[k]=v.error;
				failed=true
			else
				retSuccess[k]=v.data or {};
				retFail[k]=false;
			end
		end

		if callback then
			callback(unpack(retSuccess))
		end

		if failed then
			callbackFailed(unpack(retFail))
		end
	end);
end

-- Setup tables
conn:Query("CREATE TABLE IF NOT EXISTS `es_restrictions_props` (`id` smallint unsigned not null AUTO_INCREMENT, model varchar(255), serverid smallint unsigned not null default 0, req int(8) unsigned, PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1;CREATE TABLE IF NOT EXISTS `es_restrictions_tools` (`id` smallint unsigned not null AUTO_INCREMENT, toolmode varchar(255), serverid smallint unsigned not null default 0, req int(9) unsigned, PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1;CREATE TABLE IF NOT EXISTS `es_blockades` (`id` smallint unsigned not null AUTO_INCREMENT, mapname varchar(255), startX int(16), startY int(16), startZ int(16), endX int(16), endY int(16), endZ int(16), PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1;CREATE TABLE IF NOT EXISTS `es_settings` (`id` smallint unsigned NOT NULL AUTO_INCREMENT, value varchar(255), name varchar(255), serverid tinyint(3) unsigned, PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1;CREATE TABLE IF NOT EXISTS `es_player_inventory` (`id` int unsigned NOT NULL AUTO_INCREMENT, steamid varchar(100), itemtype tinyint unsigned, name varchar(255), PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=InnoDB DEFAULT CHARSET=latin1;CREATE TABLE IF NOT EXISTS `es_player_fields` (`id` int unsigned NOT NULL AUTO_INCREMENT, steamid varchar(100), PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=InnoDB DEFAULT CHARSET=latin1;CREATE TABLE IF NOT EXISTS `es_player_outfit` (`id` int unsigned NOT NULL AUTO_INCREMENT, steamid varchar(100), slot int(8) unsigned NOT NULL, item varchar(255), bone varchar(255), pos varchar(255), ang varchar(255), scale varchar(255), color varchar(255), UNIQUE KEY (`id`, `slot`)) ENGINE=MyISAM DEFAULT CHARSET=latin1;CREATE TABLE IF NOT EXISTS `es_ranks` ( `id` int unsigned NOT NULL AUTO_INCREMENT, steamid varchar(50), serverid int(10), rank varchar(100), PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1;CREATE TABLE IF NOT EXISTS `es_bans` (`ban_id` int unsigned NOT NULL AUTO_INCREMENT, steamid varchar(100), steamidAdmin varchar(100), name varchar(100), nameAdmin varchar(100), serverid int(8), unbanned tinyint(1), time int(32), timeStart int(32), reason varchar(255), PRIMARY KEY (`ban_id`), UNIQUE KEY `ban_id` (`ban_id`)) ENGINE=MyISAM DEFAULT CHARSET=utf8;CREATE TABLE IF NOT EXISTS `es_ranks_config` ( `id` int(10) unsigned NOT NULL AUTO_INCREMENT, name varchar(100), prettyname varchar(200), power int(16), PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1;CREATE TABLE IF NOT EXISTS `es_logs` (`id` int unsigned NOT NULL AUTO_INCREMENT, text varchar(255), type tinyint unsigned not null, time int unsigned not null, serverid tinyint unsigned not null, PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;CREATE TABLE IF NOT EXISTS `es_servers` ( `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT, ip varchar(100), port int(16) unsigned default 27015, dns varchar(100), name varchar(100), game varchar(100), PRIMARY KEY (`id`), UNIQUE KEY (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1;")

-- Load the server ID
hook.Add("InitPostEntity","exclrp.db.loadserverid",function()
	local serverIP,serverPort = ES.GetServerIP(),ES.GetServerPort();
	conn:Query("SELECT id FROM es_servers WHERE ip = '"..serverIP.."' AND port = "..serverPort.." AND game = 'garrysmod' LIMIT 1;",function(res)
		if res[1].data and res[1].data[1] then
			ES.ServerID = res[1].data[1].id

			hook.Call("ESDatabaseReady",GM or GAMEMODE,ES.ServerID,serverIP,serverPort)
		else
			conn:Query("INSERT INTO es_servers SET ip = '"..serverIP.."', port = "..serverPort..", game = 'garrysmod';",function(res)
				ES.ServerID = res[1].lastid

				hook.Call("ESDatabaseReady",GM or GAMEMODE,ES.ServerID,serverIP,serverPort)
			end)
		end
	end)
end)

-- Alter fields tables
hook.Add("Initialize","exclrp.db.alterfields",function()
	local query=""
	for k,v in pairs(ES.NetworkedVariables)do
		if v.save then
			query=query.."ALTER TABLE `es_player_fields` ADD "..ES.DBEscape(k).." "..v.save..";";
		end
	end
	conn:Query(query)
end)

-- Ranks configuration
hook.Add("Initialize","exclrp.db.loadranks",function()
	conn:Query("SELECT * FROM es_ranks_config LIMIT 100;",function(res)
		for k,v in ipairs(res[1].data)do
			ES.SetupRank(v.name,v.prettyname,tonumber(v.power))
		end
	end)
end)

--[[
require "mysqloo"

ES.ServerID = -1

if not mysqloo then
	ES.DebugPrint("MySQLOO module not found. Please install the MySQLOO module before using ExclServer.")
	return
end
local esDataTables = {}

local initialized=false

ES.DebugPrint("Connecting to MySQL...")
local db = mysqloo.connect( DATABASE_HOST, DATABASE_USERNAME, DATABASE_PASSWORD, DATABASE_SCHEMA, DATABASE_PORT )
db.onConnected = function(database)
	ES.DebugPrint("Successfully connected to MySQL database :)")

	-- Make sure we don't call this twice.
	if initialized then return end
	initialized=true

	-- Get the server's IP.
	local serverIP=ES.GetServerIP()
	local serverPort=ES.GetServerPort()

	ES.DebugPrint("Setting up db tables..")
	ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_restrictions_props` (`id` smallint unsigned not null AUTO_INCREMENT, model varchar(255), serverid smallint unsigned not null default 0, req int(8) unsigned, PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1")
	ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_restrictions_tools` (`id` smallint unsigned not null AUTO_INCREMENT, toolmode varchar(255), serverid smallint unsigned not null default 0, req int(9) unsigned, PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1")
	ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_blockades` (`id` smallint unsigned not null AUTO_INCREMENT, mapname varchar(255), startX int(16), startY int(16), startZ int(16), endX int(16), endY int(16), endZ int(16), PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1")
	ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_settings` (`id` smallint unsigned NOT NULL AUTO_INCREMENT, value varchar(255), name varchar(255), serverid tinyint(3) unsigned, PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1")
	ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_player_inventory` (`id` int unsigned NOT NULL AUTO_INCREMENT, steamid varchar(100), itemtype tinyint unsigned, name varchar(255), PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=InnoDB DEFAULT CHARSET=latin1")
	ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_player_fields` (`id` int unsigned NOT NULL AUTO_INCREMENT, steamid varchar(100), PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=InnoDB DEFAULT CHARSET=latin1")
	ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_player_outfit` (`id` int unsigned NOT NULL AUTO_INCREMENT, steamid varchar(100), slot int(8) unsigned NOT NULL, item varchar(255), bone varchar(255), pos varchar(255), ang varchar(255), scale varchar(255), color varchar(255), UNIQUE KEY (`id`, `slot`)) ENGINE=MyISAM DEFAULT CHARSET=latin1")
	ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_ranks` ( `id` int unsigned NOT NULL AUTO_INCREMENT, steamid varchar(50), serverid int(10), rank varchar(100), PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1" )
	ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_bans` (`ban_id` int unsigned NOT NULL AUTO_INCREMENT, steamid varchar(100), steamidAdmin varchar(100), name varchar(100), nameAdmin varchar(100), serverid int(8), unbanned tinyint(1), time int(32), timeStart int(32), reason varchar(255), PRIMARY KEY (`ban_id`), UNIQUE KEY `ban_id` (`ban_id`)) ENGINE=MyISAM DEFAULT CHARSET=utf8")
	ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_ranks_config` ( `id` int(10) unsigned NOT NULL AUTO_INCREMENT, name varchar(100), prettyname varchar(200), power int(16), PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1")
	ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_logs` (`id` int unsigned NOT NULL AUTO_INCREMENT, text varchar(255), type tinyint unsigned not null, time int unsigned not null, serverid tinyint unsigned not null, PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8")
	ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_servers` ( `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT, ip varchar(100), port int(16) unsigned default 27015, dns varchar(100), name varchar(100), game varchar(100), PRIMARY KEY (`id`), UNIQUE KEY (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1")

	ES.DebugPrint("Setting up server ID...")
	ES.DBQuery("SELECT id FROM es_servers WHERE ip = '"..serverIP.."' AND port = "..serverPort.." AND game = 'garrysmod' LIMIT 1",function(r)
				if r and r[1] then
					ES.DebugPrint("Server ID found: "..r[1].id)
					ES.ServerID = r[1].id
					hook.Call("ESDatabaseReady",GM or GAMEMODE,ES.ServerID)
				else
					ES.DebugPrint("No server ID found! Registering server...")
					ES.DBQuery("INSERT INTO es_servers SET ip = '"..serverIP.."', port = "..serverPort..", game = 'garrysmod';",function()
						ES.DebugPrint("Reloading server to finalise data setup...")
						game.ConsoleCommand("map "..game.GetMap().."\n")
					end)
				end
			end)

			ES.DebugPrint("Checking player fields...")

			for k,v in pairs(ES.NetworkedVariables)do
				if v.save then
					ES.DebugPrint("Checking player field: "..k)
					ES.DBQuery("ALTER TABLE `es_player_fields` ADD "..ES.DBEscape(k).." "..v.save.."",function()
						ES.DebugPrint("Added column.")
					end,function()
						ES.DebugPrint("Column already exists.")
					end)
				end
			end

			ES.DebugPrint("Loading custom ranks...")

			ES.DBQuery("SELECT * FROM es_ranks_config",function(data)
				if not data or not data[1] then return end
				for k,v in pairs(data)do
					ES.SetupRank(v.name,v.prettyname,tonumber(v.power))
				end
			end)
		end
	end)
end
db.onConnectionFailed = function(Q,e)
	ES.DebugPrint("Could not connect to mysql, "..e)

	timer.Simple(3,ES.DBConnect)
end

local isConnecting = false
function ES.DBConnect()
	if isConnecting then return end
	db:connect()
end

local void=true
hook.Add("InitPostEntity","ES.InitDatabase",ES.DBConnect)

local function MySQLError(q,e,sql)
	ES.DebugPrint("MySQL error:")
	ES.DebugPrint("   > "..tostring(sql))
	ES.DebugPrint("   < error: "..e)
end

function ES.DBQuery(request,fn,fnError)
	if ES.debug then
		ES.DebugPrint("MySQL > "..request)
	end

	local query = db:query(request)

	if not query then
		if void then
			Error("Voided MySQL call - called too early!")
			return
		end

		if db:status() ~= DATABASE_CONNECTED then
			db:connect()
			db

			query=db:query(request)
		end
	end

	query:setOption(mysqloo.OPTION_CACHE,true)
	query.onError = fnError or (MySQLError)
	query.onSuccess = function(self,dt)
		if not fn or type(fn) ~= "function" then return end
		fn( dt )
	end
	query:start()

	return query
end
function ES.DBEscape(t)
 	return db:escape(t)
end]]
