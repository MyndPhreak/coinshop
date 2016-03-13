
local mysql_hostname = 'fi.apex.gs' 
local mysql_username = 'billhackweb' 
local mysql_password = '#^_g4B5djAvCeggAkuG41ejIC46t27ZUc5K8Xy63zkV4wB5hlBwQGPHgQogzBqRwB5hlBwQGPHg' 
local mysql_database = 'billhackweb_inventory' 
local mysql_port = 3306 


require('mysqloo')

local shouldmysql = false

local db = mysqloo.connect(mysql_hostname, mysql_username, mysql_password, mysql_database, mysql_port)
GhettoDB = db
function db:onConnected()
    MsgN('Coinshop MySQL: Connected!')
    shouldmysql = true
end

function db:onConnectionFailed(err)
    MsgN('Coinshop MySQL: Connection Failed, please check your settings: ' .. err)
end

db:connect()

PROVIDER.Fallback = 'playerdata'

function PROVIDER:GetData(ply, callback)
    if not shouldmysql then self:GetFallback():GetData(ply, callback) end
    
    local qs = [[
    SELECT *
    FROM `coinshop_inventory`
    WHERE uniqueid = '%s'
    ]]
    qs = string.format(qs, ply:UniqueID())
    local q = db:query(qs)
     
    function q:onSuccess(data)
        if #data > 0 then
            local row = data[1]
         
            local points = row.points or 0
            local items = util.JSONToTable(row.items or '{}')
 
            callback(points, items)
        else
            callback(0, {})
        end
    end
     
    function q:onError(err, sql)
        if db:status() ~= mysqloo.DATABASE_CONNECTED then
            db:connect()
            db:wait()
        if db:status() ~= mysqloo.DATABASE_CONNECTED then
            ErrorNoHalt("Re-connection to database server failed.")
            callback(0, {})
            return
            end
        end
        MsgN('Coinshop MySQL: Query Failed: ' .. err .. ' (' .. sql .. ')')
        q:start()
    end
     
    q:start()
end

function PROVIDER:SetPoints(ply, points)

    if not shouldmysql then self:GetFallback():SetPoints(ply, points) end
    local qs = [[
    INSERT INTO `coinshop_inventory` (uniqueid, points, items)
    VALUES ('%s', '%s', '[]')
    ON DUPLICATE KEY UPDATE 
        points = VALUES(points)
    ]]
    qs = string.format(qs, ply:UniqueID(), points or 0)
	
    local q = db:query(qs)
     
    function q:onError(err, sql)
        if db:status() ~= mysqloo.DATABASE_CONNECTED then
            db:connect()
            db:wait()
        if db:status() ~= mysqloo.DATABASE_CONNECTED then
            ErrorNoHalt("Re-connection to database server failed.")
            return
            end
        end
        MsgN('Coinshop MySQL: Query Failed: ' .. err .. ' (' .. sql .. ')')
        q:start()
    end
     
    q:start()
	print(q)
end

function PROVIDER:GivePoints(ply, points)
    if not shouldmysql then self:GetFallback():GivePoints(ply, points) end
    local qs = [[
    INSERT INTO `coinshop_inventory` (uniqueid, points, items)
    VALUES ('%s', '%s', '[]')
    ON DUPLICATE KEY UPDATE 
        points = points + VALUES(points)
    ]]
    qs = string.format(qs, ply:UniqueID(), points or 0)
  
   local q = db:query(qs)
     
    function q:onError(err, sql)
        if db:status() ~= mysqloo.DATABASE_CONNECTED then
            db:connect()
            db:wait()
        if db:status() ~= mysqloo.DATABASE_CONNECTED then
            ErrorNoHalt("Re-connection to database server failed.")
            return
            end
        end
        MsgN('Coinshop MySQL: Query Failed: ' .. err .. ' (' .. sql .. ')')
        q:start()
    end
     
    q:start()
end

function PROVIDER:TakePoints(ply, points)
    if not shouldmysql then self:GetFallback():TakePoints(ply, points) end
    local qs = [[
    INSERT INTO `coinshop_inventory` (uniqueid, points, items)
    VALUES ('%s', '%s', '[]')
    ON DUPLICATE KEY UPDATE 
        points = points - VALUES(points)
    ]]
    qs = string.format(qs, ply:UniqueID(), points or 0)
    local q = db:query(qs)
     
    function q:onError(err, sql)
        if db:status() ~= mysqloo.DATABASE_CONNECTED then
            db:connect()
            db:wait()
        if db:status() ~= mysqloo.DATABASE_CONNECTED then
            ErrorNoHalt("Re-connection to database server failed.")
            return
            end
        end
        MsgN('Coinshop MySQL: Query Failed: ' .. err .. ' (' .. sql .. ')')
        q:start()
    end
     
    q:start()
end

function PROVIDER:SaveItem(ply, item_id, data)
    self:GiveItem(ply, item_id, data)
end

function PROVIDER:GiveItem(ply, item_id, data)
    if not shouldmysql then self:GetFallback():GiveItem(ply, item_id, data) end
    local tmp = table.Copy(ply.CSItems)
    tmp[item_id] = data

    local qs = [[
    INSERT INTO `coinshop_inventory` (uniqueid, points, items)
    VALUES ('%s', '0', '%s')
    ON DUPLICATE KEY UPDATE 
        items = VALUES(items)
    ]]
    qs = string.format(qs, ply:UniqueID(), db:escape(util.TableToJSON(tmp)))
    local q = db:query(qs)
     
    function q:onError(err, sql)
        if db:status() ~= mysqloo.DATABASE_CONNECTED then
            db:connect()
            db:wait()
        if db:status() ~= mysqloo.DATABASE_CONNECTED then
            ErrorNoHalt("Re-connection to database server failed.")
            return
            end
        end
        MsgN('Coinshop MySQL: Query Failed: ' .. err .. ' (' .. sql .. ')')
        q:start()
    end
     
    q:start()
end

function PROVIDER:TakeItem(ply, item_id)
    if not shouldmysql then self:GetFallback():TakeItem(ply, item_id) end
    local tmp = table.Copy(ply.CSItems)
    tmp[item_id] = nil

    local qs = [[
    INSERT INTO `coinshop_inventory` (uniqueid, points, items)
    VALUES ('%s', '0', '%s')
    ON DUPLICATE KEY UPDATE 
        items = VALUES(items)
    ]]
    qs = string.format(qs, ply:UniqueID(), db:escape(util.TableToJSON(tmp)))
    local q = db:query(qs)
     
    function q:onError(err, sql)
        if db:status() ~= mysqloo.DATABASE_CONNECTED then
            db:connect()
            db:wait()
        if db:status() ~= mysqloo.DATABASE_CONNECTED then
            ErrorNoHalt("Re-connection to database server failed.")
            return
            end
        end
        MsgN('Coinshop MySQL: Query Failed: ' .. err .. ' (' .. sql .. ')')
        q:start()
    end
     
    q:start()
end
 
function PROVIDER:SetData(ply, points, items)
    if not shouldmysql then self:GetFallback():SetData(ply, points, items) end
    local qs = [[
    INSERT INTO `coinshop_inventory` (uniqueid, points, items)
    VALUES ('%s', '%s', '%s')
    ON DUPLICATE KEY UPDATE 
        points = VALUES(points),
        items = VALUES(items)
    ]]
    qs = string.format(qs, ply:UniqueID(), points or 0, db:escape(util.TableToJSON(items)))
    local q = db:query(qs)
     
    function q:onError(err, sql)
        if db:status() ~= mysqloo.DATABASE_CONNECTED then
            db:connect()
            db:wait()
        if db:status() ~= mysqloo.DATABASE_CONNECTED then
            ErrorNoHalt("Re-connection to database server failed.")
            return
            end
        end
        MsgN('Coinshop MySQL: Query Failed: ' .. err .. ' (' .. sql .. ')')
        q:start()
    end
     
    q:start()
end
