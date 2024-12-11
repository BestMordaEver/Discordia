--[=[
@c Interaction x Snowflake
@t abc
@d Defines the base methods and properties for all Discord interactions.
]=]

local Snowflake = require('containers/abstract/Snowflake')
local enums = require('enums')
local channelType = assert(enums.channelType)
local Permissions = require('utils/Permissions')

--[=[Defines the base methods and properties for all Discord interactions.]=]
---@class Interaction : Snowflake
---@field isReplied boolean
---@field type interactionType
---@field guild? Guild
---@field channel TextChannel
---@field member? Member
---@field user User
---@field token string
---@field locale localeName
---@field guild_locale? localeName
---@field appPermissions Permissions
---@field context interactionContextType
---@field protected _channel TextChannel
---@field private _channel_id nil
---@field protected _guild Guild
---@field private _guild_id nil
---@field protected _data table
---@field protected _user User
---@field protected _is_replied boolean
---@field protected _callback fun(self : Interaction, type : callbackType, content? : table, files? : string) : boolean?, string?
---@field protected __init fun(self : Interaction, data : table, client : Client)
local Interaction, get = require('class')('Interaction', Snowflake)

function Interaction:__init(data, client)
	Snowflake.__init(self, data, client)

	if data.member then
		self._guild = client._guilds:get(data.guild_id)
		self._guild._members:_insert(data.member)
		self._channel = self._guild._text_channels:get(data.channel_id) or self._guild._voice_channels:get(data.channel_id) or self._guild._threads:get(data.channel_id)
		data.user = data.member.user
	else
		self._channel = client._private_channels:get(data.channel_id) or client._group_channels:get(data.channel_id)
		if not self._channel then
			local d = client._api:getChannel(data.channel_id)
			if d.type == channelType.private then
				self._channel = client._private_channels:_insert(d)
			elseif d.type == channelType.group then
				self._channel = client._group_channels:_insert(d)
			end
		end
	end

	self._user = client._users:_insert(data.user)
	self._data = data.data
	self._is_replied = false

	self._guild_id = nil
	self._channel_id = nil
end

function Interaction:_callback(callbackType, content, files)
	assert(not self._is_replied, "interaction is already replied to")
	local data, err = self.client._api:createInteractionResponse(self._id, self._token, {type = callbackType, data = content}, files)

	if data then
		self._is_replied = true
		return true
	else
		return nil, err
	end
end

--[=[@p isReplied boolean Whether the interaction was already replied to.]=]
function get.isReplied(self)
	return self._is_replied
end

--[=[@p type number The interaction type. See the `interactionType` enumeration for a human-readable representation.]=]
function get.type(self)
	return self._type
end

--[=[@p guild Guild/nil The guild in which this interaction happened. This will not exist if the interaction
was not sent in a guild text channel. Equivalent to `Interaction.channel.guild`.]=]
function get.guild(self)
	return self._guild
end

--[=[@p channel TextChannel The channel in which this interaction happened.]=]
function get.channel(self)
	return self._channel
end

--[=[@p member Member/nil The member object of the interaction user. This will not exist if the interaction
was not sent in a guild text channel or if the member object is not cached.
Equivalent to `Interaction.guild.members:get(Interaction.author.id)`.]=]
function get.member(self)
	local guild = self.guild
	return guild and guild._members:get(self._user._id)
end

--[=[@p user User The object of the user that created the interaction.]=]
function get.user(self)
	return self._user
end

--[=[@p token string A continuation token for responding to the interaction.
Valid for 15 minutes.]=]
function get.token(self)
	return self._token
end

--[=[@p locale string The selected language of the invoking user.]=]
function get.locale(self)
	return self._locale
end

--[=[@p guild_locale string/nil The guild's preferred locale, if invoked in a guild.]=]
function get.guild_locale(self)
	return self._guild_locale
end

--[=[@p appPermissions Permissions Set of permissions the app has in the source location of the interaction.]=]
function get.appPermissions(self)
	return Permissions.fromMany(self._app_permissions)
end

--[=[@p context number Context where the interaction was triggered from.
See the `interactionContextType` enumeration for a human-readable representation.]=]
function get.context(self)
	return self._context
end

--[[
function get.version(self)
	return self._version
end]]

return Interaction