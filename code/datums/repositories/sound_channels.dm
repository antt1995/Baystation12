GLOBAL_TYPED_NEW_STEP(sound_channels, /repository/sound_channels, 40)
GLOBAL_VAR_AS(lobby_sound_channel, GLOB.sound_channels.RequestChannel("LOBBY"))
GLOBAL_VAR_AS(vote_sound_channel, GLOB.sound_channels.RequestChannel("VOTE"))
GLOBAL_VAR_AS(admin_sound_channel, GLOB.sound_channels.RequestChannel("ADMIN_FUN"))

GLOBAL_VAR_AS(ambience_channel_vents, GLOB.sound_channels.RequestChannel("AMBIENCE_VENTS"))
GLOBAL_VAR_AS(ambience_channel_forced, GLOB.sound_channels.RequestChannel("AMBIENCE_FORCED"))
GLOBAL_VAR_AS(ambience_channel_common, GLOB.sound_channels.RequestChannel("AMBIENCE_COMMON"))

GLOBAL_VAR_AS(weather_channel, GLOB.sound_channels.RequestChannel("WEATHER"))

/repository/sound_channels
	var/datum/stack/available_channels
	var/list/keys_by_channel           // So we know who to blame if we run out
	var/channel_ceiling	= 1024         // Initial value is the current BYOND maximum number of channels

/repository/sound_channels/New()
	..()
	available_channels = new()

/repository/sound_channels/proc/RequestChannel(key)
	. = RequestChannels(key, 1)
	return LAZYLEN(.) && .[1]

/repository/sound_channels/proc/RequestChannels(key, amount)
	if(!key)
		CRASH("Invalid key given.")
	. = list()

	for(var/i = 1 to amount)
		var/channel = available_channels.Pop() // Check if someone else has released their channel.
		if(!channel)
			if(channel_ceiling <= 0) // This basically means we ran out of channels
				break
			channel = channel_ceiling--
		. += channel

	if(length(.) != amount)
		ReleaseChannels(.)
		CRASH("Unable to supply the requested amount of channels: [key] - Expected [amount], was [length(.)]")

	for(var/channel in .)
		LAZYSET(keys_by_channel, "[channel]", key)
	return .

/repository/sound_channels/proc/ReleaseChannel(channel)
	ReleaseChannels(list(channel))

/repository/sound_channels/proc/ReleaseChannels(list/channels)
	for(var/channel in channels)
		LAZYREMOVE(keys_by_channel, "[channel]")
		available_channels.Push(channel)
