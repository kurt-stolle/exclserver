ExclServer2
-----------

# Requirements
To run ExclServer2, you need the following preliminaries:
- The `gmsv_tmysql4_xxx` module;
- A MySQL compatible database;
- Access to the server filesystem;
- Access to the server console.

# Installation

_1. Installing ExclServer2_
Extract the `exclserver` folder into `~/garrysmod/addons/exclserver`.
There is no need to copy the content to your download server, ExclServer2 is on the Steam Workshop. The content will be downloaded automatically.

_2. Installing tmysql4_
See the documentation that comes with the `gmsv_tmysql4_xxx` module.
Link: https://facepunch.com/showthread.php?t=1442438
This module also requires the libmysql library to be in your garrysmod base address (the same address where srcds is).
Link: http://puu.sh/1fhWu

_3. Installing the ExclServer API (OPTIONAL)_
The ExclServer API allows you to use the NodeBB forum plugin `nodebb-plugin-exclserver` and the loading screen, as well as a fully featured REST-API.
The ExclServer API is easy to install, simply install it as any other Node.JS application in your favorite environment. To configure the ExclServer API, please consult the readme in the API folder.

_4. Configuring the MySQL database connection settings_
The addon has to know to which database to connect. To do this, go to the file `./lua/exclserver/core/sv_data.lua` and fill out the variables found at the top of this file.

```lua
local DATABASE_HOST     = "127.0.0.1";
local DATABASE_PORT     = 3306;
local DATABASE_SCHEMA   = "exclserver";
local DATABASE_USERNAME = "foo";
local DATABASE_PASSWORD = "bar";
```

# Setup

_1. Ranking the server operator_
To make yourself the initial server owner, first connect to your server alone (password your server), then type `lua_run Entity(1):ESSetRank("owner",true)` in console.

# Ranks
These are all ranks from highest to lowest, custom ranks can be added by editing the `es_ranks_config` table in your favorite MySQL editor.
- Owner (owner)
- Operator (operator)
- Super Administrator (superadmin)
- Administrator (admin)
- User (user)

You can promote people in-game with the command `:rank <name/steamid> <rank e.g. superadmin/admin/user/etc...> <global? 1/0>`. For example: `:rank Excl operator 1` will make Excl an operator across all servers.

# Quick commands
_A full list of commands can be found in the in-game menu_
