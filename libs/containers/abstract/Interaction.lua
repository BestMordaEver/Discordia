--[=[
@c Interaction x Snowflake
@d Represents a message that your application receives when a user uses
an application command or a message component. Messages can contain
simple content strings, rich embeds, attachments, or reactions.
]=]

local json = require('json')
local enums = require('enums')
local constants = require('constants')
local Cache = require('iterables/Cache')
local ArrayIterable = require('iterables/ArrayIterable')
local Snowflake = require('containers/abstract/Snowflake')
local Reaction = require('containers/Reaction')
local Resolver = require('client/Resolver')
local insert = table.insert
local null = json.null
local format = string.format
local messageFlag, callbackType = enums.messageFlag, enums.callbackType
local band, bor, bnot = bit.band, bit.bor, bit.bnot

local Interaction, get = require('class')('Interaction', Snowflake)

function Interaction:__init(data, parent)
	Snowflake.__init(self, data, parent)
	if data.member then
		data.user = data.member.user
		self._parent._parent._members:_insert(data.member)
	end
	self._user = self.client._users:_insert(data.user)
end

function Interaction:_modify(payload)
	local data, err = self.client._api:editMessage(self._parent._id, self._id, payload)
	if data then
		self:_setOldContent(data)
		self:_load(data)
		return true
	else
		return false, err
	end
end

--[=[
@m setContent
@t http
@p content string
@r boolean
@d Sets the message's content. The message must be authored by the current user
(ie: you cannot change the content of messages sent by other users). The content
must be from 1 to 2000 characters in length.
]=]
function Interaction:setContent(content)
	return self:_modify({content = content or null})
end

--[=[
@m setEmbed
@t http
@p embed table
@r boolean
@d Sets the message's embed. The message must be authored by the current user.
(ie: you cannot change the embed of messages sent by other users).
]=]
function Interaction:setEmbed(embed)
	return self:_modify({embed = embed or null})
end

--[=[
@m hideEmbeds
@t http
@r boolean
@d Hides all embeds for this message.
]=]
function Interaction:hideEmbeds()
	local flags = bor(self._flags or 0, messageFlag.suppressEmbeds)
	return self:_modify({flags = flags})
end

--[=[
@m showEmbeds
@t http
@r boolean
@d Shows all embeds for this message.
]=]
function Interaction:showEmbeds()
	local flags = band(self._flags or 0, bnot(messageFlag.suppressEmbeds))
	return self:_modify({flags = flags})
end

--[=[
@m hasFlag
@t mem
@p flag Interaction-Flag-Resolvable
@r boolean
@d Indicates whether the message has a particular flag set.
]=]
function Interaction:hasFlag(flag)
	flag = Resolver.messageFlag(flag)
	return band(self._flags or 0, flag) > 0
end

--[=[
@m update
@t http
@p data table
@r boolean
@d Sets multiple properties of the message at the same time using a table similar
to the one supported by `TextChannel.send`, except only `content` and `embed`
are valid fields; `mention(s)`, `file(s)`, etc are not supported. The message
must be authored by the current user. (ie: you cannot change the embed of messages
sent by other users).
]=]
function Interaction:update(data)
	return self:_modify({
		content = data.content or null,
		embed = data.embed or null,
	})
end

--[=[
@m pin
@t http
@r boolean
@d Pins the message in the channel.
]=]
function Interaction:pin()
	local data, err = self.client._api:addPinnedChannelMessage(self._parent._id, self._id)
	if data then
		self._pinned = true
		return true
	else
		return false, err
	end
end

--[=[
@m unpin
@t http
@r boolean
@d Unpins the message in the channel.
]=]
function Interaction:unpin()
	local data, err = self.client._api:deletePinnedChannelMessage(self._parent._id, self._id)
	if data then
		self._pinned = false
		return true
	else
		return false, err
	end
end

--[=[
@m addReaction
@t http
@p emoji Emoji-Resolvable
@r boolean
@d Adds a reaction to the message. Note that this does not return the new reaction
object; wait for the `reactionAdd` event instead.
]=]
function Interaction:addReaction(emoji)
	emoji = Resolver.emoji(emoji)
	local data, err = self.client._api:createReaction(self._parent._id, self._id, emoji)
	if data then
		return true
	else
		return false, err
	end
end

--[=[
@m removeReaction
@t http
@p emoji Emoji-Resolvable
@op id User-ID-Resolvable
@r boolean
@d Removes a reaction from the message. Note that this does not return the old
reaction object; wait for the `reactionRemove` event instead. If no user is
indicated, then this will remove the current user's reaction.
]=]
function Interaction:removeReaction(emoji, id)
	emoji = Resolver.emoji(emoji)
	local data, err
	if id then
		id = Resolver.userId(id)
		data, err = self.client._api:deleteUserReaction(self._parent._id, self._id, emoji, id)
	else
		data, err = self.client._api:deleteOwnReaction(self._parent._id, self._id, emoji)
	end
	if data then
		return true
	else
		return false, err
	end
end

--[=[
@m clearReactions
@t http
@r boolean
@d Removes all reactions from the message.
]=]
function Interaction:clearReactions()
	local data, err = self.client._api:deleteAllReactions(self._parent._id, self._id)
	if data then
		return true
	else
		return false, err
	end
end

--[=[
@m delete
@t http
@r boolean
@d Permanently deletes the message. This cannot be undone!
]=]
function Interaction:delete()
	local data, err = self.client._api:deleteMessage(self._parent._id, self._id)
	if data then
		local cache = self._parent._messages
		if cache then
			cache:_delete(self._id)
		end
		return true
	else
		return false, err
	end
end

--[=[
@m reply
@t http
@p content string/table
@r Message
@d Equivalent to `Message.channel:send(content)`.

function Interaction:reply(content)
	return self._parent:send(content)
end]=]

--[=[@p reactions Cache An iterable cache of all reactions that exist for this message.]=]
function get.applicationId(self)
	return self._application_id
end

--[=[@p mentionedUsers ArrayIterable An iterable array of all users that are mentioned in this message.]=]
function get.type(self)
	return self._type
end

--[=[@p mentionedRoles ArrayIterable An iterable array of known roles that are mentioned in this message, excluding
the default everyone role. The message must be in a guild text channel and the
roles must be cached in that channel's guild for them to appear here.]=]
function get.data(self)
	return self._data
end

--[=[@p guild Guild/nil The guild in which this message was sent. This will not exist if the message
was not sent in a guild text channel. Equivalent to `Message.channel.guild`.]=]
function get.guild(self)
	return self._parent.guild
end

--[=[@p channel TextChannel The channel in which this message was sent.]=]
function get.channel(self)
	return self._parent
end

--[=[@p member Member/nil The member object of the message's author. This will not exist if the message
is not sent in a guild text channel or if the member object is not cached.
Equivalent to `Message.guild.members:get(Message.author.id)`.]=]
function get.member(self)
	local guild = self.guild
	return guild and guild._members:get(self._user._id)
end

--[=[@p author User The object of the user that created the message.]=]
function get.user(self)
	return self._user
end

--[=[@p mentionsEveryone boolean Whether this message mentions @everyone or @here.]=]
function get.token(self)
	return self._token
end

--[=[@p pinned boolean Whether this message belongs to its channel's pinned messages.]=]
function get.version(self)
	return self._version
end

--[=[@p tts boolean Whether this message is a text-to-speech message.]=]
function get.message(self)
	return self._message
end

return Interaction
