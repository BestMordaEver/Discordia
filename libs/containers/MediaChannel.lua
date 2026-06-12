--[=[
@c MediaChannel x ForumChannel
@d Represents a guild media channel that can only contain threads.
]=]

local ForumChannel = require('containers/ForumChannel')

local bor, band, bnot = bit.bor, bit.band, bit.bnot

--[=[Represents a guild media channel that can only contain threads.]=]
---@class MediaChannel : ForumChannel
---@field downloadOptionsHidden boolean
---@field isMedia boolean
local MediaChannel, get = require('class')('MediaChannel', ForumChannel)

function MediaChannel:__init(data, parent)
	ForumChannel.__init(self, data, parent)
end

function MediaChannel:_load(data)
	ForumChannel._load(self, data)
end

--[=[
@m hideDownloadOptions
@t http
@r boolean
@d Hides media download options for this media channel.
]=]
--[=[Hides media download options for this media channel.]=]
---@return boolean success
---@return string? error
function MediaChannel:hideDownloadOptions()
	return self:_modify({flags = bor(self._flags or 0, 0x8000)})
end

--[=[
@m showDownloadOptions
@t http
@r boolean
@d Shows media download options for this media channel.
]=]
--[=[Shows media download options for this media channel.]=]
---@return boolean success
---@return string? error
function MediaChannel:showDownloadOptions()
	return self:_modify({flags = band(self._flags or 0, bnot(0x8000))})
end

--[=[@p downloadOptionsHidden boolean Whether media download options are hidden in this media channel.]=]
function get.downloadOptionsHidden(self)
	return band(self._flags or 0, 0x8000) ~= 0
end

--[=[@p isMedia boolean Whether this channel is a media channel of type 16.]=]
function get.isMedia(self)
	return true
end

return MediaChannel