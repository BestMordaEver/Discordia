local function enum(tbl)
	local call = {}
	for k, v in pairs(tbl) do
		if call[v] then
			return error(string.format('enum clash for %q and %q', k, call[v]))
		end
		call[v] = k
	end
	return setmetatable({}, {
		__call = function(_, k)
			if call[k] then
				return call[k]
			else
				return error('invalid enumeration: ' .. tostring(k))
			end
		end,
		__index = function(_, k)
			if tbl[k] then
				return tbl[k]
			else
				return error('invalid enumeration: ' .. tostring(k))
			end
		end,
		__pairs = function()
			return next, tbl
		end,
		__newindex = function()
			return error('cannot overwrite enumeration')
		end,
	})
end

---@type table<string, table <string, number|string> | function>
local enums = {enum = enum}


---@enum defaultAvatar
enums.defaultAvatar = {
	blurple = 0,
	gray    = 1,
	green   = 2,
	orange  = 3,
	red     = 4,
	pink    = 5,
}

---@enum notificationSetting
enums.notificationSetting = {
	allMessages  = 0,
	onlyMentions = 1,
}

---@enum channelType
enums.channelType = {
	text          = 0,
	private       = 1,
	voice         = 2,
	group         = 3,
	category      = 4,
	news          = 5,
	store         = 6,
	-- unused     = 7,
	-- unused     = 8,
	-- unused     = 9,
	newsThread    = 10,
	publicThread  = 11,
	privateThread = 12,
	stageVoice    = 13,
	directory     = 14,
	forum         = 15,
	media         = 16,
}

---@enum webhookType
enums.webhookType = {
	incoming        = 1,
	channelFollower = 2,
	application     = 3,
}

---@enum messageType
enums.messageType = {
	default                        = 0,
	recipientAdd                   = 1,
	recipientRemove                = 2,
	call                           = 3,
	channelNameChange              = 4,
	channelIconchange              = 5,
	pinnedMessage                  = 6,
	memberJoin                     = 7,
	premiumGuildSubscription       = 8,
	premiumGuildSubscriptionTier1  = 9,
	premiumGuildSubscriptionTier2  = 10,
	premiumGuildSubscriptionTier3  = 11,
	channelFollowAdd               = 12,
	-- unused (guildStream)        = 13,
	guildDiscoveryDisqualified     = 14,
	guildDiscoveryRequalified      = 15,
	guildDiscoveryInitialWarning   = 16,
	guildDiscoveryFinalWarning     = 17,
	threadCreated                  = 18,
	reply                          = 19,
	chatInputCommand               = 20,
	threadStarterMessage           = 21,
	guildInviteReminder            = 22,
	contextMenuCommand             = 23,
	autoModerationAction           = 24,
	roleSubscriptionPurchase       = 25,
	interactionPremiumUpsell       = 26,
	stageStart                     = 27,
	stageEnd                       = 28,
	stageSpeaker                   = 29,
	-- unused                      = 30,
	stageTopic                     = 31,
	applicationPremiumSubscription = 32,
	guildIncidentAlertModeEnabled  = 36,
	guildIncidentAlertModeDisabled = 37,
	guildIncidentReportRaid        = 38,
	guildIncidentReportFalseAlarm  = 39,
	purchaseNotification           = 44,
	pollResult                     = 46,
}

---@enum relationshipType
enums.relationshipType = {
	none            = 0,
	friend          = 1,
	blocked         = 2,
	pendingIncoming = 3,
	pendingOutgoing = 4,
	implicit        = 5,
}

---@enum activityType
enums.activityType = {
	game      = 0,
	streaming = 1,
	listening = 2,
	watching  = 3,
	custom    = 4,
	competing = 5,
}

---@enum status
enums.status = {
	online       = 'online',
	idle         = 'idle',
	doNotDisturb = 'dnd',
	invisible    = 'invisible', -- only sent?
	offline      = 'offline', -- only received?
}

---@enum gameType
enums.gameType = { -- NOTE: deprecated; use activityType
	default   = 0,
	streaming = 1,
	listening = 2,
	watching  = 3,
	custom    = 4,
	competing = 5,
}

---@enum verificationLevel
enums.verificationLevel = {
	none     = 0,
	low      = 1,
	medium   = 2,
	high     = 3, -- (╯°□°）╯︵ ┻━┻
	veryHigh = 4, -- ┻━┻ ﾐヽ(ಠ益ಠ)ノ彡┻━┻
}

---@enum explicitContentLevel
enums.explicitContentLevel = {
	none   = 0,
	medium = 1,
	high   = 2,
}

---@enum premiumTier
enums.premiumTier = {
	none  = 0,
	tier1 = 1,
	tier2 = 2,
	tier3 = 3,
}

---@enum permission
enums.permission = {
	createInstantInvite   = 0x0000000000000001,	-- 0
	kickMembers           = 0x0000000000000002, -- 1
	banMembers            = 0x0000000000000004, -- 2
	administrator         = 0x0000000000000008, -- 3
	manageChannels        = 0x0000000000000010, -- 4
	manageGuild           = 0x0000000000000020, -- 5
	addReactions          = 0x0000000000000040, -- 6
	viewAuditLog          = 0x0000000000000080, -- 7
	prioritySpeaker       = 0x0000000000000100, -- 8
	stream                = 0x0000000000000200, -- 9
	readMessages          = 0x0000000000000400, -- 10
	sendMessages          = 0x0000000000000800, -- 11
	sendTextToSpeech      = 0x0000000000001000, -- 12
	manageMessages        = 0x0000000000002000, -- 13
	embedLinks            = 0x0000000000004000, -- 14
	attachFiles           = 0x0000000000008000, -- 15
	readMessageHistory    = 0x0000000000010000, -- 16
	mentionEveryone       = 0x0000000000020000, -- 17
	useExternalEmojis     = 0x0000000000040000, -- 18
	viewGuildInsights     = 0x0000000000080000, -- 19
	connect               = 0x0000000000100000, -- 20
	speak                 = 0x0000000000200000, -- 21
	muteMembers           = 0x0000000000400000, -- 22
	deafenMembers         = 0x0000000000800000, -- 23
	moveMembers           = 0x0000000001000000, -- 24
	useVoiceActivity      = 0x0000000002000000, -- 25
	changeNickname        = 0x0000000004000000, -- 26
	manageNicknames       = 0x0000000008000000, -- 27
	manageRoles           = 0x0000000010000000, -- 28
	manageWebhooks        = 0x0000000020000000, -- 29
	manageEmojis          = 0x0000000040000000, -- 30
	useSlashCommands      = 0x0000000080000000, -- 31
	requestToSpeak        = 0x0000000100000000, -- 32
	manageEvents          = 0x0000000200000000, -- 33
	manageThreads         = 0x0000000400000000, -- 34
	usePublicThreads      = 0x0000000800000000, -- 35
	usePrivateThreads     = 0x0000001000000000, -- 36
	useExternalStickers   = 0x0000002000000000, -- 37
	sendMessagesInThreads = 0x0000004000000000, -- 38
	useEmbeddedActivities = 0x0000008000000000, -- 39
	moderateMembers       = 0x0000010000000000, -- 40
	monetizationAnalytics = 0x0000020000000000, -- 41
	useSoundboard         = 0x0000040000000000, -- 42
	createExpressions     = 0x0000080000000000, -- 43
	createEvents          = 0x0000100000000000, -- 44
	useExternalSounds     = 0x0000200000000000, -- 45
	sendVoiceMessages     = 0x0000400000000000, -- 46
	sendPolls             = 0x0000800000000000, -- 47
	useExternalApps       = 0x0001000000000000, -- 48
}

---@enum overwriteType
enums.overwriteType = {
	role   = 0,
	member = 1,
}

---@enum forumSortOrder
enums.forumSortOrder = {
	latestActivity = 0,
	creationDate   = 1,
}

---@enum forumLayout
enums.forumLayout = {
	notSet      = 0,
	listView    = 1,
	galleryView = 2,
}

---@enum messageFlag
enums.messageFlag = {
	crossposted                = 0x0001, -- 0
	isCrosspost                = 0x0002, -- 1
	suppressEmbeds             = 0x0004, -- 2
	sourceMessageDeleted       = 0x0008, -- 3
	urgent                     = 0x0010, -- 4
	hasThread                  = 0x0020, -- 5
	ephemeral                  = 0x0040, -- 6
	loading                    = 0x0080, -- 7
	threadFailedToMentionRoles = 0x0100, -- 8
	-- unused                  = 0x0200, -- 9
	-- unused                  = 0x0400, -- 10
	-- unused                  = 0x0800, -- 11
	suppressNotification       = 0x1000, -- 12
	isVoiceMessage             = 0x2000, -- 13
	hasSnapshot                = 0x4000, -- 14
	is_components_v2           = 0x8000, -- 15
}

---@enum gatewayIntent
enums.gatewayIntent = {
	guilds                = 0x00000001,	-- 0
	guildMembers          = 0x00000002, -- 1 privileged
	guildModeration       = 0x00000004, -- 2
	guildEmojis           = 0x00000008, -- 3
	guildIntegrations     = 0x00000010, -- 4
	guildWebhooks         = 0x00000020, -- 5
	guildInvites          = 0x00000040, -- 6
	guildVoiceStates      = 0x00000080, -- 7
	guildPresences        = 0x00000100, -- 8 privileged
	guildMessages         = 0x00000200, -- 9
	guildMessageReactions = 0x00000400, -- 10
	guildMessageTyping    = 0x00000800, -- 11
	directMessage         = 0x00001000, -- 12
	directMessageRections = 0x00002000, -- 13
	directMessageTyping   = 0x00004000, -- 14
	messageContent        = 0x00008000, -- 15 privileged
	guildScheduledEvents  = 0x00010000, -- 16
	-- unused             = 0x00020000, -- 17
	-- unused             = 0x00040000, -- 18
	-- unused             = 0x00080000, -- 19
	autoModConfiguration  = 0x00100000, -- 20
	autoModExecution      = 0x00200000, -- 21
}

---@enum actionType
enums.actionType = {
	guildUpdate            = 1,
	channelCreate          = 10,
	channelUpdate          = 11,
	channelDelete          = 12,
	channelOverwriteCreate = 13,
	channelOverwriteUpdate = 14,
	channelOverwriteDelete = 15,
	memberKick             = 20,
	memberPrune            = 21,
	memberBanAdd           = 22,
	memberBanRemove        = 23,
	memberUpdate           = 24,
	memberRoleUpdate       = 25,
	memberMove             = 26,
	memberDisconnect       = 27,
	botAdd                 = 28,
	roleCreate             = 30,
	roleUpdate             = 31,
	roleDelete             = 32,
	inviteCreate           = 40,
	inviteUpdate           = 41,
	inviteDelete           = 42,
	webhookCreate          = 50,
	webhookUpdate          = 51,
	webhookDelete          = 52,
	emojiCreate            = 60,
	emojiUpdate            = 61,
	emojiDelete            = 62,
	messageDelete          = 72,
	messageBulkDelete      = 73,
	messagePin             = 74,
	messageUnpin           = 75,
	integrationCreate      = 80,
	integrationUpdate      = 81,
	integrationDelete      = 82,
	stageInstanceCreate    = 83,
	stageInstanceUpdate    = 84,
	stageInstanceDelete    = 85,
	stickerCreate          = 90,
	stickerUpdate          = 91,
	stickerDelete          = 92,
	eventCreate            = 100,
	eventUpdate            = 101,
	eventDelete            = 102,
	threadCreate           = 110,
	threadUpdate           = 111,
	threadDelete           = 112,
	autoModRuleCreate      = 140,
	autoModRuleUpdate      = 141,
	autoModRuleDelete      = 142,
	autoModMessageBlock    = 143,
	autoModMessageFlag     = 144,
	autoModUserTimeout     = 145,
}

---@enum localeName
enums.locale = {
	danish      = "da",
	german      = "de",
	englishUK   = "en-GB",
	englishUS   = "en-US",
	spanish     = "es-ES",
	french      = "fr",
	croatian    = "hr",
	italian     = "it",
	lithuanian  = "lt",
	hungarian   = "hu",
	dutch       = "nl",
	norwegian   = "no",
	polish      = "pl",
	portugeseBR = "pt-BR",
	romanian    = "ro",
	finnish     = "fi",
	swedish     = "sv-SE",
	vietnamese  = "vi",
	turkish     = "tr",
	czech       = "cs",
	greek       = "el",
	bulgarian   = "bg",
	russian     = "ru",
	ukrainian   = "uk",
	hindi       = "hi",
	thai        = "th",
	chineseCN   = "zh-CN",
	chineseTW   = "zh-TW",
	japanese    = "ja",
	korean      = "ko",
}

---@enum logLevel
enums.logLevel = {
	none    = 0,
	error   = 1,
	warning = 2,
	info    = 3,
	debug   = 4,
}

---@enum timestampStyle
enums.timestampStyle = {
	shortTime      = 't',
	longTime       = 'T',
	shortDate      = 'd',
	longDate       = 'D',
	shortDateTime  = 'f',
	longDateTime   = 'F',
	relativeTime   = 'R',
}

---@enum interactionType
enums.interactionType = {
	ping               = 1,
	applicationCommand = 2,
	messageComponent   = 3,
	autocomplete       = 4,
	modalSubmit        = 5,
}

---@enum callbackType
enums.callbackType = {
	pong         = 1,
	reply        = 4,
	deferReply   = 5,
	deferUpdate  = 6,
	update       = 7,
	autocomplete = 8,
	modal        = 9,
}

---@enum applicationCommandType
enums.applicationCommandType = {
	chatInput = 1,
	user      = 2,
	message   = 3,
}

---@enum interactionContextType
enums.interactionContextType = {
	guild          = 0,
	dm             = 1,
	privateChannel = 2,
}

---@enum applicationCommandOptionType
enums.applicationCommandOptionType = {
	subcommand      = 1,
	subcommandGroup = 2,
	string          = 3,
	integer         = 4,
	boolean         = 5,
	user            = 6,
	channel         = 7,
	role            = 8,
	mentionable     = 9,
	number          = 10,
	attachment      = 11,
}

---@enum componentType
enums.componentType = {
	row               = 1,
	button            = 2,
	stringSelect      = 3,
	textInput         = 4,
	userSelect        = 5,
	roleSelect        = 6,
	mentionableSelect = 7,
	channelSelect     = 8,
	section           = 9,	-- requires IS_COMPONENTS_V2
	textDisplay       = 10,	-- requires IS_COMPONENTS_V2
	thumbnail         = 11,	-- requires IS_COMPONENTS_V2
	mediaGallery      = 12,	-- requires IS_COMPONENTS_V2
	file              = 13,	-- requires IS_COMPONENTS_V2
	separator         = 14,	-- requires IS_COMPONENTS_V2
	-- unused         = 15,
	-- unused         = 16,
	container         = 17,	-- requires IS_COMPONENTS_V2
	label             = 18,
}

---@enum buttonStyle
enums.buttonStyle = {
	primary   = 1,
	secondary = 2,
	success   = 3,
	danger    = 4,
	link      = 5,
	premium   = 6,
}

---@enum inputStyle
enums.inputStyle = {
	short     = 1,
	paragraph = 2,
}

---@enum separatorSpacing
enums.separatorSpacing = {
	small = 1,
	large = 2,
}

for name, t in pairs(enums) do
	if t ~= enum then
		enums[name] = enum(t)
	end
end

return enums