--[=[
@c Interaction x Snowflake
@t abc
@d Defines the base methods and properties for all Discord interactions.
]=]

local Snowflake = require('containers/abstract/Snowflake')

local Interaction, get = require('class')('Interaction', Snowflake)

function Interaction:__init(data, parent)
	Snowflake.__init(self, data, parent)

	if data.member then
		data.user = data.member.user
		self._parent._parent._members:_insert(data.member)
	end
	self._user = self.client._users:_insert(data.user)
	self._is_replied = false

	self._data = data.data
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

--[=[@p type number The interaction type. See the `interactionType` enumeration for a human-readable representation.]=]
function get.type(self)
	return self._type
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

--[[
function get.version(self)
	return self._version
end]]

return Interaction