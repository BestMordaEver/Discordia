--[=[
@c UserPresence x Container
@t abc
@d Defines the base methods and/or properties for classes that represent a
user's current presence information. Note that any method or property that
exists for the User class is also available in the UserPresence class and its
subclasses.
]=]

local User = require('containers/User')
local Activity = require('containers/Activity')
local Container = require('containers/abstract/Container')

local activityType = require('enums').activityType

--[=[Defines the base methods and/or properties for classes that represent a
user's current presence information. Note that any method or property that
exists for the User class is also available in the UserPresence class and its
subclasses.]=]
---@class UserPresence : Container, User
---@field gameName string
---@field gameType activityType
---@field gameURL string
---@field status "online" | "dnd" | "idle" | "offline"
---@field webStatus "online" | "dnd" | "idle" | "offline"
---@field mobileStatus "online" | "dnd" | "idle" | "offline"
---@field desktopStatus "online" | "dnd" | "idle" | "offline"
---@field user User
---@field playing? Activity
---@field streaming? Activity
---@field listening? Activity
---@field watching? Activity
---@field custom? Activity
---@field competing? Activity
---@field protected _activity table<activityType, Activity>
---@field protected _status "online" | "dnd" | "idle" | "offline"
---@field _user User
---@field protected _loadPresence fun(self : self, presence : table)
---@field protected __hash fun(self : self) : string
---@field protected __init fun(self : self, data : table, parent : Container | Client)
local UserPresence, get = require('class')('UserPresence', Container)

function UserPresence:__init(data, parent)
	Container.__init(self, data, parent)
	self._user = self.client._users:_insert(data.user)
	self._activity = {}
end

--[=[
@m __hash
@r string
@d Returns `UserPresence.user.id`
]=]
--[=[Returns `UserPresence.user.id`]=]
function UserPresence:__hash()
	return self._user._id
end

function UserPresence:_loadPresence(presence)
	self._status = presence.status

	if next(presence.activities) then
		local activities = {}
		for i, activity in pairs(presence.activities) do
			activities[activity.type] = activity
		end

		for _, type in pairs(activityType) do
			if activities[type] then
				if self._activity[type] then
					self._activity[type]:_load(activities[type])
				else
					self._activity[type] = Activity(activities[type], self)
				end
			else
				self._activity[type] = nil
			end
		end
	else
		for k,_ in pairs(self._activity) do
			self._activity[k] = nil
		end
	end
end

function get.gameName(self)
	self.client:_deprecated(self.__name, 'gameName', 'activity.name')
	return self._activity[activityType.game] and self._activity[activityType.game]._name
end

function get.gameType(self)
	self.client:_deprecated(self.__name, 'gameType', 'activity.type')
	return self._activity[activityType.game] and self._activity[activityType.game]._type
end

function get.gameURL(self)
	self.client:_deprecated(self.__name, 'gameURL', 'activity.url')
	return self._activity[activityType.game] and self._activity[activityType.game]._url
end

--[=[@p status string The user's overall status (online, dnd, idle, offline).]=]
function get.status(self)
	return self._status or 'offline'
end

--[=[@p webStatus string The user's web status (online, dnd, idle, offline).]=]
function get.webStatus(self)
	return self._web_status or 'offline'
end

--[=[@p mobileStatus string The user's mobile status (online, dnd, idle, offline).]=]
function get.mobileStatus(self)
	return self._mobile_status or 'offline'
end

--[=[@p desktopStatus string The user's desktop status (online, dnd, idle, offline).]=]
function get.desktopStatus(self)
	return self._desktop_status or 'offline'
end

--[=[@p user User The user that this presence represents.]=]
function get.user(self)
	return self._user
end

--[=[@p playing Activity/nil The game Activity that this presence represents.]=]
function get.playing(self)
	return self._activity[activityType.game]
end

--[=[@p streaming Activity/nil The streaming Activity that this presence represents.]=]
function get.streaming(self)
	return self._activity[activityType.streaming]
end

--[=[@p listening Activity/nil The listening Activity that this presence represents.]=]
function get.listening(self)
	return self._activity[activityType.listening]
end

--[=[@p watching Activity/nil The watching Activity that this presence represents.]=]
function get.watching(self)
	return self._activity[activityType.watching]
end

--[=[@p custom Activity/nil The custom status Activity that this presence represents.]=]
function get.custom(self)
	return self._activity[activityType.custom]
end

--[=[@p competing Activity/nil The competing Activity that this presence represents.]=]
function get.competing(self)
	return self._activity[activityType.competing]
end

-- user shortcuts

for k, v in pairs(User) do
	UserPresence[k] = UserPresence[k] or function(self, ...)
		return v(self._user, ...)
	end
end

for k, v in pairs(User.__getters) do
	get[k] = get[k] or function(self)
		return v(self._user)
	end
end

return UserPresence
