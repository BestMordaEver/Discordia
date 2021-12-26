--[=[
@c Interaction x Snowflake
@t abc
@d Defines the base methods and properties for all Discord interactions.
]=]

local Snowflake = require('containers/abstract/Snowflake')
local MessageContainer = require('utils/MessageContainer')
local Cache = require('iterables/Cache')
local User = require('containers/User')
local Role = require('containers/Role')
local Channel = require('containers/abstract/Channel')
local Message = require('containers/Message')
local Resolver = require('client/Resolver')

local Interaction, get = require('class')('Interaction', Snowflake)

function Interaction:__init(data, parent)
	Snowflake.__init(self, data, parent)

	if data.member then
		data.user = data.member.user
		self._parent._parent._members:_insert(data.member)
	end
	self._user = self.client._users:_insert(data.user)

	if data.resolved then
		self._users = Cache({}, User, self)
		for snowflake, _ in pairs(data.resolved.users) do
			self._users:_insert(Resolver.userId(snowflake.id))
		end

		self._roles = Cache(data.resolved.roles, Role, self)
		for snowflake, _ in pairs(data.resolved.roles) do
			self._roles:_insert(Resolver.roleId(snowflake.id))
		end

		self._channels = Cache(data.resolved.channels, Channel, self)
		for snowflake, _ in pairs(data.resolved.channels) do
			self._channels:_insert(Resolver.channelId(snowflake.id))
		end

		self._messages = Cache(data.resolved.messages, Message, self)
		for snowflake, _ in pairs(data.resolved.messages) do
			self._messages:_insert(Resolver.messageId(snowflake.id))
		end
	end
end

function Interaction:_callback(callbackType, content)

	local data, err

	content, err = MessageContainer.parseContent(content)
	if not content then
		return nil, err
	end

	data, err = self.client._api:createInteractionResponse(self._id, self._token, {type = callbackType, data = content}, err)

	if data then
		return self._messages:_insert(data)
	else
		return nil, err
	end
end

function get.applicationId(self)
	return self._application_id
end


function get.type(self)
	return self._type
end


function get.data(self)
	return self._data
end

--[=[@p guild Guild/nil The guild in which this interaction happened. This will not exist if the interaction
was not sent in a guild text channel. Equivalent to `Interaction.channel.guild`.]=]
function get.guild(self)
	return self._parent.guild
end

--[=[@p channel TextChannel The channel in which this interaction happened.]=]
function get.channel(self)
	return self._parent
end

--[=[@p member Member/nil The member object of the interaction user. This will not exist if the interaction
was not sent in a guild text channel or if the member object is not cached.
Equivalent to `Interaction.guild.members:get(Interaction.author.id)`.]=]
function get.member(self)
	local guild = self.guild
	return guild and guild._members:get(self._user._id)
end

--[=[@p author User The object of the user that created the interaction.]=]
function get.user(self)
	return self._user
end


function get.token(self)
	return self._token
end


function get.version(self)
	return self._version
end

return Interaction
