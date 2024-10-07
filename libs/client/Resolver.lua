local fs = require('fs')
local ffi = require('ffi')
local ssl = require('openssl')
local class = require('class')
local enums = require('enums')

local permission = assert(enums.permission)
local gatewayIntent = assert(enums.gatewayIntent)
local actionType = assert(enums.actionType)
local messageFlag = assert(enums.messageFlag)
local base64 = ssl.base64
local readFileSync = fs.readFileSync
local classes = class.classes
local isInstance = class.isInstance
local isObject = class.isObject
local insert = table.insert
local format = string.format

---@class Resolver
local Resolver = {}

local istype = ffi.istype
local int64_t = ffi.typeof('int64_t')
local uint64_t = ffi.typeof('uint64_t')

---@alias Snowflake-ID-Resolvable string | number | Date
---@param obj Snowflake-ID-Resolvable if this is Date, equivalent to obj:toSnowflake()
---@return string?
local function int(obj)
	local t = type(obj)
	if t == 'string' then
		if tonumber(obj) then
			return obj
		end
	elseif t == 'cdata' then
		if istype(int64_t, obj) or istype(uint64_t, obj) then
			return tostring(obj):match('%d*')
		end
	elseif t == 'number' then
		return format('%i', obj)
	elseif isInstance(obj, classes.Date) then
		return obj:toSnowflake()
	end
end

---@alias User-ID-Resolvable User | Member | Message | Guild | Snowflake-ID-Resolvable
---@param obj User-ID-Resolvable if this is Message, equivalent to obj.author.id; if this is Guild, equivalent to obj.ownerId
---@return string?
function Resolver.userId(obj)
	if isObject(obj) then
		if isInstance(obj, classes.User) then
			return obj.id
		elseif isInstance(obj, classes.Member) then
			return obj.user.id
		elseif isInstance(obj, classes.Message) then
			return obj.author.id
		elseif isInstance(obj, classes.Guild) then
			return obj.ownerId
		end
	end
	return int(obj)
end

---@alias Message-ID-Resolvable Message | Snowflake-ID-Resolvable
---@param obj Message-ID-Resolvable
---@return string?
function Resolver.messageId(obj)
	if isInstance(obj, classes.Message) then
		return obj.id
	end
	return int(obj)
end

---@alias Channel-ID-Resolvable Channel | Snowflake-ID-Resolvable
---@param obj Channel-ID-Resolvable
---@return string?
function Resolver.channelId(obj)
	if isInstance(obj, classes.Channel) then
		return obj.id
	end
	return int(obj)
end

---@alias Role-ID-Resolvable Role | Snowflake-ID-Resolvable
---@param obj Role-ID-Resolvable
---@return string?
function Resolver.roleId(obj)
	if isInstance(obj, classes.Role) then
		return obj.id
	end
	return int(obj)
end

---@alias Emoji-ID-Resolvable Emoji | Reaction | Activity | Snowflake-ID-Resolvable
---@param obj Emoji-ID-Resolvable if this is Reaction or Activity, equivalent to obj.emojiId
---@return string?
function Resolver.emojiId(obj)
	if isInstance(obj, classes.Emoji) then
		return obj.id
	elseif isInstance(obj, classes.Reaction) then
		return obj.emojiId
	elseif isInstance(obj, classes.Activity) then
		return obj.emojiId
	end
	return int(obj)
end

---@alias Sticker-ID-Resolvable Sticker | Snowflake-ID-Resolvable
---@param obj Sticker-ID-Resolvable
---@return string?
function Resolver.stickerId(obj)
	if isInstance(obj, classes.Sticker) then
		return obj.id
	end
	return int(obj)
end

---@alias Guild-ID-Resolvable Guild | Snowflake-ID-Resolvable
---@param obj Guild-ID-Resolvable
---@return string?
function Resolver.guildId(obj)
	if isInstance(obj, classes.Guild) then
		return obj.id
	end
	return int(obj)
end

---@alias AuditLogEntry-ID-Resolvable AuditLogEntry | Snowflake-ID-Resolvable
---@param obj AuditLogEntry-ID-Resolvable
---@return string?
function Resolver.entryId(obj)
	if isInstance(obj, classes.AuditLogEntry) then
		return obj.id
	end
	return int(obj)
end

---@param objs table<any, Message-ID-Resolvable> | Iterable<Message-ID-Resolvable>
---@return string[]
function Resolver.messageIds(objs)
	local ret = {}
	if isInstance(objs, classes.Iterable) then
		for obj in objs:iter() do
			insert(ret, Resolver.messageId(obj))
		end
	elseif type(objs) == 'table' then
		for _, obj in pairs(objs) do
			insert(ret, Resolver.messageId(obj))
		end
	end
	return ret
end

---@param objs table<any, Role-ID-Resolvable> | Iterable<Message-ID-Resolvable>
---@return string[]
function Resolver.roleIds(objs)
	local ret = {}
	if isInstance(objs, classes.Iterable) then
		for obj in objs:iter() do
			insert(ret, Resolver.roleId(obj))
		end
	elseif type(objs) == 'table' then
		for _, obj in pairs(objs) do
			insert(ret, Resolver.roleId(obj))
		end
	end
	return ret
end

---@alias Emoji-Resolvable Emoji | Reaction | Activity | number | string
---@param obj Emoji-Resolvable
---@return string
function Resolver.emoji(obj)
	if isInstance(obj, classes.Emoji) then
		return obj.hash
	elseif isInstance(obj, classes.Reaction) then
		return obj.emojiHash
	elseif isInstance(obj, classes.Activity) then
		return obj.emojiHash
	end
	return tostring(obj)
end

---@alias Sticker-Resolvable Sticker | number | string
---@param obj Sticker-Resolvable
---@return string
function Resolver.sticker(obj)
	if isInstance(obj, classes.Sticker) then
		return obj.hash
	end
	return tostring(obj)
end

---@alias Color-Resolvable Color | number | string
---@param obj Color-Resolvable
---@return number?
function Resolver.color(obj)
	if isInstance(obj, classes.Color) then
		return obj.value
	end
	return tonumber(obj)
end

---@alias Permissions-Resolvable Permissions | permission | number
---@param obj Permissions-Resolvable
---@return number?
function Resolver.permissions(obj)
	if isInstance(obj, classes.Permissions) then
		return obj.value
	end
	return tonumber(obj)
end

---@alias Permission-Resolvable permission | number
---@param obj Permission-Resolvable
---@return number?
function Resolver.permission(obj)
	local t = type(obj)
	local n = nil
	if t == 'string' then
		n = permission[obj]
	elseif t == 'number' then
		n = permission(obj) and obj
	end
	return n --[=[@as number]=]
end

---@alias Intent-Resolvable gatewayIntent | number
---@param obj Intent-Resolvable
---@return number?
function Resolver.gatewayIntent(obj)
	local t = type(obj)
	local n = nil
	if t == 'string' then
		n = gatewayIntent[obj]
	elseif t == 'number' then
		n = gatewayIntent(obj) and obj
	end
	return n --[=[@as number]=]
end

---@alias ActionType-Resolvable actionType | number
---@param obj ActionType-Resolvable
---@return number?
function Resolver.actionType(obj)
	local t = type(obj)
	local n = nil
	if t == 'string' then
		n = actionType[obj]
	elseif t == 'number' then
		n = actionType(obj) and obj
	end
	return n --[=[@as number]=]
end

---@alias MessageFlag-Resolvable messageFlag | number
---@param obj MessageFlag-Resolvable
---@return number?
function Resolver.messageFlag(obj)
	local t = type(obj)
	local n = nil
	if t == 'string' then
		n = messageFlag[obj]
	elseif t == 'number' then
		n = messageFlag(obj) and obj
	end
	return n --[=[@as number]=]
end

---@alias Base64-Resolvable string
---@param obj Base64-Resolvable
---@return string? 
---@return string? error
function Resolver.base64(obj)
	if type(obj) == 'string' then
		if obj:find('data:.*;base64,') == 1 then
			return obj
		end
		local data, err = readFileSync(obj)
		if not data then
			return nil, err
		end
		return 'data:;base64,' .. base64(data)
	end
	return nil
end

return Resolver
