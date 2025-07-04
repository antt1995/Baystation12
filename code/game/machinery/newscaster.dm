//##############################################
//################### NEWSCASTERS BE HERE! ####
//###-Agouri###################################

/datum/feed_message
	var/author =""
	var/body =""
	var/message_type ="Story"
	var/datum/feed_channel/parent_channel
	var/is_admin_message = 0
	var/icon/img = null
	var/icon/caption = ""
	var/time_stamp = ""
	var/backup_body = ""
	var/backup_author = ""
	var/icon/backup_img = null
	var/icon/backup_caption = ""

/datum/feed_channel
	var/channel_name=""
	var/channel_id=0
	var/list/datum/feed_message/messages = list()
	var/locked=0
	var/author=""
	var/backup_author=""
	var/views=0
	var/censored=0
	var/is_admin_channel=0
	var/updated = 0
	var/announcement = ""


/datum/feed_message/proc/clear()
	src.author = ""
	src.body = ""
	src.caption = ""
	src.img = null
	src.time_stamp = ""
	src.backup_body = ""
	src.backup_author = ""
	src.backup_caption = ""
	src.backup_img = null
	parent_channel.update()

/datum/feed_channel/proc/update()
	updated = world.time

/datum/feed_channel/proc/clear()
	src.channel_name = ""
	src.messages = list()
	src.locked = 0
	src.author = ""
	src.backup_author = ""
	src.censored = 0
	src.is_admin_channel = 0
	src.announcement = ""
	update()
/datum/feed_network
	var/list/datum/feed_channel/network_channels = list()
	var/datum/feed_message/wanted_issue
	var/list/newscasters = list()
	var/list/news_programs = list()
	var/list/z_levels = list()

/datum/feed_network/New()
	CreateFeedChannel("Announcements", "SS13", 1, 1, "New Announcement Available")

/datum/feed_network/proc/CreateFeedChannel(channel_name, author, locked, adminChannel = 0, announcement_message)
	var/datum/feed_channel/newChannel = new /datum/feed_channel
	newChannel.channel_name = channel_name
	newChannel.channel_id = length(network_channels)
	newChannel.author = author
	newChannel.locked = locked
	newChannel.is_admin_channel = adminChannel
	if(announcement_message)
		newChannel.announcement = announcement_message
	else
		newChannel.announcement = "Breaking news from [channel_name]!"
	network_channels += newChannel

/datum/feed_network/proc/SubmitArticle(msg, author, channel_name, obj/item/photo/photo, adminMessage = 0, message_type = "")
	var/datum/feed_message/newMsg = new /datum/feed_message
	newMsg.author = author
	newMsg.body = msg
	newMsg.time_stamp = "[stationtime2text()]"
	newMsg.is_admin_message = adminMessage
	if(message_type)
		newMsg.message_type = message_type
	if(photo)
		newMsg.img = photo.img
		newMsg.caption = photo.scribble
	for(var/datum/feed_channel/FC in network_channels)
		if(FC.channel_name == channel_name)
			insert_message_in_channel(FC, newMsg) //Adding message to the network's appropriate feed_channel
			break

/datum/feed_network/proc/insert_message_in_channel(datum/feed_channel/FC, datum/feed_message/newMsg)
	FC.messages += newMsg
	if(newMsg.img)
		register_asset("newscaster_photo_[FC.channel_id]_[length(FC.messages)].png", newMsg.img)
	newMsg.parent_channel = FC
	FC.update()
	alert_readers(FC.announcement)

/datum/feed_network/proc/alert_readers(annoncement)
	for(var/obj/machinery/newscaster/NEWSCASTER in newscasters)
		NEWSCASTER.newsAlert(annoncement)
		NEWSCASTER.update_icon()
	for(var/datum/nano_module/program/newscast/program in news_programs)
		program.news_alert(annoncement)

var/global/list/datum/feed_network/news_network = list()     //The global news-network, which is coincidentally a global list.

var/global/list/obj/machinery/newscaster/allCasters = list() //Global list that will contain reference to all newscasters in existence.


/obj/machinery/newscaster
	name = "newscaster"
	desc = "A standard newsfeed handler. All the news you absolutely have no use for, in one place!"
	icon = 'icons/obj/machines/terminals.dmi'
	icon_state = "newscaster_normal"
	health_max = 80
	health_min_damage = 5
	use_weapon_hitsound = FALSE
	damage_hitsound = 'sound/effects/Glassbr3.ogg'
	obj_flags = OBJ_FLAG_WALL_MOUNTED
	//var/list/datum/feed_channel/channel_list = list() //This list will contain the names of the feed channels. Each name will refer to a data region where the messages of the feed channels are stored.
	var/screen = 0
		// 0 = welcome screen - main menu
		// 1 = view feed channels
		// 2 = create feed channel
		// 3 = create feed story
		// 4 = feed story submited sucessfully
		// 5 = feed channel created successfully
		// 6 = ERROR: Cannot create feed story
		// 7 = ERROR: Cannot create feed channel
		// 8 = print newspaper
		// 9 = viewing channel feeds
		// 10 = censor feed story
		// 11 = censor feed channel
		//Holy shit this is outdated, made this when I was still starting newscasters :3
	var/paper_remaining = 0
	var/securityCaster = 0
		// 0 = Caster cannot be used to issue wanted posters
		// 1 = the opposite
	var/unit_no = 0 //Each newscaster has a unit number
	//var/datum/feed_message/wanted //We're gonna use a feed_message to store data of the wanted person because fields are similar
	//var/wanted_issue = 0          //OBSOLETE
		// 0 = there's no WANTED issued, we don't need a special icon_state
		// 1 = Guess what.
	var/alert_delay = 500
	var/alert = 0
		// 0 = there hasn't been a news/wanted update in the last alert_delay
		// 1 = there has
	var/scanned_user = "Unknown" //Will contain the name of the person who currently uses the newscaster
	var/msg = "" //Feed message
	var/datum/news_photo/photo_data = null
	var/channel_name = "" //the feed channel which will be receiving the feed, or being created
	var/c_locked=0 //Will our new channel be locked to public submissions?
	var/datum/feed_channel/viewing_channel = null
	var/datum/feed_network/connected_group
	light_range = 0
	anchored = TRUE
	layer = ABOVE_WINDOW_LAYER

/obj/machinery/newscaster/security_unit
	name = "Security Newscaster"
	securityCaster = 1

/obj/machinery/newscaster/Initialize()
	. = ..()

	for (var/datum/feed_network/G in news_network)
		if (src.z in G.z_levels)
			G.newscasters += src
			connected_group = G

			break

	if (!connected_group)
		var/datum/feed_network/G = new /datum/feed_network
		G.newscasters += src
		G.z_levels = GetConnectedZlevels(src.z)

		connected_group = G
		LAZYADD(news_network, G)

	src.paper_remaining = 15            // Will probably change this to something better
	for (var/obj/machinery/newscaster/NEWSCASTER in connected_group.newscasters) // Let's give it an appropriate unit number
		src.unit_no++
	src.update_icon() //for any custom ones on the map...

/obj/machinery/newscaster/Destroy()
	if (connected_group)
		connected_group.newscasters -= src
	..()

/obj/machinery/newscaster/on_update_icon()
	if(inoperable())
		icon_state = "newscaster_off"
		if(MACHINE_IS_BROKEN(src)) //If the thing is smashed, add crack overlay on top of the unpowered sprite.
			ClearOverlays()
			AddOverlays(image(src.icon, "crack3"))
		return

	ClearOverlays()

	if(connected_group.wanted_issue) //wanted icon state, there can be no overlays on it as it's a priority message
		icon_state = "newscaster_wanted"
		return

	if(alert) //new message alert overlay
		AddOverlays("newscaster_alert")

	var/health = get_current_health()
	if(health < health_max) //Cosmetic damage overlay
		var/hitstaken
		switch ((health/health_max) * 100)
			if (0 to 33)
				hitstaken = 3
			if (34 to 66)
				hitstaken = 2
			if (67 to 100)
				hitstaken = 1
		AddOverlays("crack[hitstaken]")

	icon_state = "newscaster_normal"
	return

/obj/machinery/newscaster/interface_interact(mob/user)
	interact(user)
	return TRUE

/obj/machinery/newscaster/interact(mob/user)            //########### THE MAIN BEEF IS HERE! And in the proc below this...############
	if(istype(user, /mob/living/carbon/human) || istype(user,/mob/living/silicon) )
		var/mob/living/human_or_robot_user = user
		var/dat
		dat = text("<HEAD><TITLE>Newscaster</TITLE></HEAD><H3>Newscaster Unit #[src.unit_no]</H3>")

		src.scan_user(human_or_robot_user) //Newscaster scans you

		switch(screen)
			if(0)
				dat += "Welcome to Newscasting Unit #[src.unit_no].<BR> Interface & News networks Operational."
				dat += "<BR>[FONT_SMALL("Property of Ward-Takahashi GMB")]"
				if(connected_group.wanted_issue)
					dat+= "<HR><A href='byond://?src=\ref[src];view_wanted=1'>Read Wanted Issue</A>"
				dat+= "<HR><BR><A href='byond://?src=\ref[src];create_channel=1'>Create Feed Channel</A>"
				dat+= "<BR><A href='byond://?src=\ref[src];view=1'>View Feed Channels</A>"
				dat+= "<BR><A href='byond://?src=\ref[src];create_feed_story=1'>Submit new Feed story</A>"
				dat+= "<BR><A href='byond://?src=\ref[src];menu_paper=1'>Print newspaper</A>"
				dat+= "<BR><A href='byond://?src=\ref[src];refresh=1'>Re-scan User</A>"
				dat+= "<BR><BR><A href='byond://?src=\ref[human_or_robot_user];mach_close=newscaster_main'>Exit</A>"
				if(src.securityCaster)
					var/wanted_already = 0
					if(connected_group.wanted_issue)
						wanted_already = 1

					dat+="<HR><B>Feed Security functions:</B><BR>"
					dat+="<BR><A href='byond://?src=\ref[src];menu_wanted=1'>[(wanted_already) ? ("Manage") : ("Publish")] \"Wanted\" Issue</A>"
					dat+="<BR><A href='byond://?src=\ref[src];menu_censor_story=1'>Censor Feed Stories</A>"
					dat+="<BR><A href='byond://?src=\ref[src];menu_censor_channel=1'>Mark Feed Channel with [GLOB.using_map.company_name] D-Notice</A>"
				dat+="<BR><HR>The newscaster recognises you as: [SPAN_COLOR("green", src.scanned_user)]"
			if(1)
				dat+= "Local Feed Channels<HR>"
				if( !length(connected_group.network_channels) )
					dat+="<I>No active channels found...</I>"
				else
					for(var/datum/feed_channel/CHANNEL in connected_group.network_channels)
						if(CHANNEL.is_admin_channel)
							dat+="<B>[SPAN_STYLE("background-color: LightGreen", "<A href='byond://?src=\ref[src];show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A>")]</B><BR>"
						else
							dat+="<B><A href='byond://?src=\ref[src];show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? (SPAN_COLOR("red", "***")) : null ]<BR></B>"
				dat+="<BR><HR><A href='byond://?src=\ref[src];refresh=1'>Refresh</A>"
				dat+="<BR><A href='byond://?src=\ref[src];setScreen=[0]'>Back</A>"
			if(2)
				dat+="Creating new Feed Channel..."
				dat+="<HR><B><A href='byond://?src=\ref[src];set_channel_name=1'>Channel Name</A>:</B> [src.channel_name]<BR>"
				dat+="<B>Channel Author:</B> [SPAN_COLOR("green", src.scanned_user)]<BR>"
				dat+="<B><A href='byond://?src=\ref[src];set_channel_lock=1'>Will Accept Public Feeds</A>:</B> [(src.c_locked) ? ("NO") : ("YES")]<BR><BR>"
				dat+="<BR><A href='byond://?src=\ref[src];submit_new_channel=1'>Submit</A><BR><BR><A href='byond://?src=\ref[src];setScreen=[0]'>Cancel</A><BR>"
			if(3)
				dat+="Creating new Feed Message..."
				dat+="<HR><B><A href='byond://?src=\ref[src];set_channel_receiving=1'>Receiving Channel</A>:</B> [src.channel_name]<BR>" //MARK
				dat+="<B>Message Author:</B> [SPAN_COLOR("green", src.scanned_user)]<BR>"
				dat+="<B><A href='byond://?src=\ref[src];set_new_message=1'>Message Body</A>:</B> [src.msg] <BR>"
				dat+="<B>Photo</B>: "
				if(photo_data && photo_data.photo)
					send_rsc(usr, photo_data.photo.img, "tmp_photo.png")
					dat+="<BR><img src='tmp_photo.png' width = '180'>"
					dat+="<BR><B><A href='byond://?src=\ref[src];set_attachment=1'>Delete Photo</A></B></BR>"
				else
					dat+="<A href='byond://?src=\ref[src];set_attachment=1'>Attach Photo</A>"
				dat+="<BR><BR><A href='byond://?src=\ref[src];submit_new_message=1'>Submit</A><BR><BR><A href='byond://?src=\ref[src];setScreen=[0]'>Cancel</A><BR>"
			if(4)
				dat+="Feed story successfully submitted to [src.channel_name].<BR><BR>"
				dat+="<BR><A href='byond://?src=\ref[src];setScreen=[0]'>Return</A><BR>"
			if(5)
				dat+="Feed Channel [src.channel_name] created successfully.<BR><BR>"
				dat+="<BR><A href='byond://?src=\ref[src];setScreen=[0]'>Return</A><BR>"
			if(6)
				dat+="[SPAN_COLOR("maroon", "<B>ERROR: Could not submit Feed story to Network.</B>")]<HR><BR>"
				if(src.channel_name=="")
					dat+="[SPAN_COLOR("maroon", "Invalid receiving channel name.")]<BR>"
				if(src.scanned_user=="Unknown")
					dat+="[SPAN_COLOR("maroon", "Channel author unverified.")]<BR>"
				if(src.msg == "" || src.msg == "\[REDACTED\]")
					dat+="[SPAN_COLOR("maroon", "Invalid message body.")]<BR>"

				dat+="<BR><A href='byond://?src=\ref[src];setScreen=[3]'>Return</A><BR>"
			if(7)
				dat+="[SPAN_COLOR("maroon", "<B>ERROR: Could not submit Feed Channel to Network.</B>")]<HR><BR>"
				var/list/existing_authors = list()
				for(var/datum/feed_channel/FC in connected_group.network_channels)
					if(FC.author == "\[REDACTED\]")
						existing_authors += FC.backup_author
					else
						existing_authors += FC.author
				if(src.scanned_user in existing_authors)
					dat+="[SPAN_COLOR("maroon", "There already exists a Feed channel under your name.")]<BR>"
				if(src.channel_name=="" || src.channel_name == "\[REDACTED\]")
					dat+="[SPAN_COLOR("maroon", "Invalid channel name.")]<BR>"
				var/check = 0
				for(var/datum/feed_channel/FC in connected_group.network_channels)
					if(FC.channel_name == src.channel_name)
						check = 1
						break
				if(check)
					dat+="[SPAN_COLOR("maroon", "Channel name already in use.")]<BR>"
				if(src.scanned_user=="Unknown")
					dat+="[SPAN_COLOR("maroon", "Channel author unverified.")]<BR>"
				dat+="<BR><A href='byond://?src=\ref[src];setScreen=[2]'>Return</A><BR>"
			if(8)
				var/total_num=length(connected_group.network_channels)
				var/active_num=total_num
				var/message_num=0
				for(var/datum/feed_channel/FC in connected_group.network_channels)
					if(!FC.censored)
						message_num += length(FC.messages)    //Dont forget, datum/feed_channel's var messages is a list of datum/feed_message
					else
						active_num--
				dat+="Network currently serves a total of [total_num] Feed channels, [active_num] of which are active, and a total of [message_num] Feed Stories." //TODO: CONTINUE
				dat+="<BR><BR><B>Liquid Paper remaining:</B> [(src.paper_remaining) *100 ] cm^3"
				dat+="<BR><BR><A href='byond://?src=\ref[src];print_paper=[0]'>Print Paper</A>"
				dat+="<BR><A href='byond://?src=\ref[src];setScreen=[0]'>Cancel</A>"
			if(9)
				dat+="<B>[src.viewing_channel.channel_name]: </B>[FONT_SMALL("\[created by: [SPAN_COLOR("maroon", src.viewing_channel.author)]\] \[views: [SPAN_COLOR("maroon", ++src.viewing_channel.views)]\]")]<HR>"
				if(src.viewing_channel.censored)
					dat+=SPAN_COLOR("red", "<B>ATTENTION: </B>This channel has been deemed as threatening to the welfare of the [station_name()], and marked with a [GLOB.using_map.company_name] D-Notice.<BR>\
						No further feed story additions are allowed while the D-Notice is in effect.<BR><BR>")
				else
					if( !length(viewing_channel.messages) )
						dat+="<I>No feed messages found in channel...</I><BR>"
					else
						var/i = 0
						for(var/datum/feed_message/MESSAGE in src.viewing_channel.messages)
							++i
							dat+="-[MESSAGE.body] <BR>"
							if(MESSAGE.img)
								var/resourc_name = "newscaster_photo_[viewing_channel.channel_id]_[i].png"
								send_asset(usr.client, resourc_name)
								dat+="<img src='[resourc_name]' width = '180'><BR>"
								if(MESSAGE.caption)
									dat+="[FONT_SMALL("<B>[MESSAGE.caption]</B>")]<BR>"
								dat+="<BR>"
							dat+="[FONT_SMALL("\[Story by [SPAN_COLOR("maroon", "[MESSAGE.author] - [MESSAGE.time_stamp]")]\]")]<BR>"
				dat+="<BR><HR><A href='byond://?src=\ref[src];refresh=1'>Refresh</A>"
				dat+="<BR><A href='byond://?src=\ref[src];setScreen=[1]'>Back</A>"
			if(10)
				dat+="<B>[GLOB.using_map.company_name] Feed Censorship Tool</B><BR>"
				dat+=FONT_SMALL("NOTE: Due to the nature of news Feeds, total deletion of a Feed Story is not possible.<BR>\
					Keep in mind that users attempting to view a censored feed will instead see the \[REDACTED\] tag above it.")
				dat+="<HR>Select Feed channel to get Stories from:<BR>"
				if(!length(connected_group.network_channels))
					dat+="<I>No feed channels found active...</I><BR>"
				else
					for(var/datum/feed_channel/CHANNEL in connected_group.network_channels)
						dat+="<A href='byond://?src=\ref[src];pick_censor_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? (SPAN_COLOR("red", "***")) : null ]<BR>"
				dat+="<BR><A href='byond://?src=\ref[src];setScreen=[0]'>Cancel</A>"
			if(11)
				dat+="<B>[GLOB.using_map.company_name] D-Notice Handler</B><HR>"
				dat+="[FONT_SMALL("A D-Notice is to be bestowed upon the channel if the handling Authority deems it as harmful for the [station_name()]'s \
					morale, integrity or disciplinary behaviour. A D-Notice will render a channel unable to be updated by anyone, without deleting any feed \
					stories it might contain at the time. You can lift a D-Notice if you have the required access at any time.")]<HR>"
				if(!length(connected_group.network_channels))
					dat+="<I>No feed channels found active...</I><BR>"
				else
					for(var/datum/feed_channel/CHANNEL in connected_group.network_channels)
						dat+="<A href='byond://?src=\ref[src];pick_d_notice=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? (SPAN_COLOR("red", "***")) : null ]<BR>"

				dat+="<BR><A href='byond://?src=\ref[src];setScreen=[0]'>Back</A>"
			if(12)
				dat+="<B>[src.viewing_channel.channel_name]: </B>[FONT_SMALL("\[ created by: [SPAN_COLOR("maroon", src.viewing_channel.author)] \]")]<BR>"
				dat+="[FONT_NORMAL("<A href='byond://?src=\ref[src];censor_channel_author=\ref[src.viewing_channel]'>[(src.viewing_channel.author=="\[REDACTED\]") ? ("Undo Author censorship") : ("Censor channel Author")]</A>")]<HR>"


				if( !length(viewing_channel.messages) )
					dat+="<I>No feed messages found in channel...</I><BR>"
				else
					for(var/datum/feed_message/MESSAGE in src.viewing_channel.messages)
						dat+="-[MESSAGE.body] <BR>[FONT_SMALL("\[[MESSAGE.message_type] by [SPAN_COLOR("maroon", MESSAGE.author)]\]")]<BR>"
						dat+="[FONT_NORMAL("<A href='byond://?src=\ref[src];censor_channel_story_body=\ref[MESSAGE]'>[(MESSAGE.body == "\[REDACTED\]") ? ("Undo story censorship") : ("Censor story")]</A>  -  <A href='byond://?src=\ref[src];censor_channel_story_author=\ref[MESSAGE]'>[(MESSAGE.author == "\[REDACTED\]") ? ("Undo Author Censorship") : ("Censor message Author")]</A>")]<BR>"
				dat+="<BR><A href='byond://?src=\ref[src];setScreen=[10]'>Back</A>"
			if(13)
				dat+="<B>[src.viewing_channel.channel_name]: </B>[FONT_SMALL("\[ created by: [SPAN_COLOR("maroon", src.viewing_channel.author)] \]")]<BR>"
				dat+="Channel messages listed below. If you deem them dangerous to the [station_name()], you can <A href='byond://?src=\ref[src];toggle_d_notice=\ref[src.viewing_channel]'>Bestow a D-Notice upon the channel</A>.<HR>"
				if(src.viewing_channel.censored)
					dat+="[SPAN_COLOR("red", "<B>ATTENTION: </B>")]This channel has been deemed as threatening to the welfare of the [station_name()], and marked with a [GLOB.using_map.company_name] D-Notice.<BR>"
					dat+="No further feed story additions are allowed while the D-Notice is in effect.<BR><BR>"
				else
					if( !length(viewing_channel.messages) )
						dat+="<I>No feed messages found in channel...</I><BR>"
					else
						for(var/datum/feed_message/MESSAGE in src.viewing_channel.messages)
							dat+="-[MESSAGE.body] <BR>[FONT_SMALL("\[[MESSAGE.message_type] by [SPAN_COLOR("maroon", MESSAGE.author)]\]")]<BR>"

				dat+="<BR><A href='byond://?src=\ref[src];setScreen=[11]'>Back</A>"
			if(14)
				dat+="<B>Wanted Issue Handler:</B>"
				var/wanted_already = 0
				var/end_param = 1
				if(connected_group.wanted_issue)
					wanted_already = 1
					end_param = 2

				if(wanted_already)
					dat+="<BR>[FONT_NORMAL("<I>A wanted issue is already in Feed Circulation. You can edit or cancel it below.</I>")]"
				dat+="<HR>"
				dat+="<A href='byond://?src=\ref[src];set_wanted_name=1'>Criminal Name</A>: [src.channel_name] <BR>"
				dat+="<A href='byond://?src=\ref[src];set_wanted_desc=1'>Description</A>: [src.msg] <BR>"
				dat+="<B>Photo</B>: "
				if(photo_data && photo_data.photo)
					send_rsc(usr, photo_data.photo.img, "tmp_photo.png")
					dat+="<BR><img src='tmp_photo.png' width = '180'>"
					dat+="<BR><B><A href='byond://?src=\ref[src];set_attachment=1'>Delete Photo</A></B></BR>"
				else
					dat+="<A href='byond://?src=\ref[src];set_attachment=1'>Attach Photo</A><BR>"
				if(wanted_already)
					dat+="<B>Wanted Issue created by:</B> [SPAN_COLOR("green", connected_group.wanted_issue.backup_author)]<BR>"
				else
					dat+="<B>Wanted Issue will be created under prosecutor:</B> [SPAN_COLOR("green", src.scanned_user)]<BR>"
				dat+="<BR><A href='byond://?src=\ref[src];submit_wanted=[end_param]'>[(wanted_already) ? ("Edit Issue") : ("Submit")]</A>"
				if(wanted_already)
					dat+="<BR><A href='byond://?src=\ref[src];cancel_wanted=1'>Take down Issue</A>"
				dat+="<BR><A href='byond://?src=\ref[src];setScreen=[0]'>Cancel</A>"
			if(15)
				dat+="[SPAN_COLOR("green", "Wanted issue for [src.channel_name] is now in Network Circulation.")]<BR><BR>"
				dat+="<BR><A href='byond://?src=\ref[src];setScreen=[0]'>Return</A><BR>"
			if(16)
				dat+="[SPAN_COLOR("maroon", "<B>ERROR: Wanted Issue rejected by Network.</B>")]<HR><BR>"
				if(src.channel_name=="" || src.channel_name == "\[REDACTED\]")
					dat+="[SPAN_COLOR("maroon", "Invalid name for person wanted.")]<BR>"
				if(src.scanned_user=="Unknown")
					dat+="[SPAN_COLOR("maroon", "Issue author unverified.")]<BR>"
				if(src.msg == "" || src.msg == "\[REDACTED\]")
					dat+="[SPAN_COLOR("maroon", "Invalid description.")]<BR>"
				dat+="<BR><A href='byond://?src=\ref[src];setScreen=[0]'>Return</A><BR>"
			if(17)
				dat+="<B>Wanted Issue successfully deleted from Circulation</B><BR>"
				dat+="<BR><A href='byond://?src=\ref[src];setScreen=[0]'>Return</A><BR>"
			if(18)
				dat+="[SPAN_COLOR("maroon", "<B>-- STATIONWIDE WANTED ISSUE --</B>")]<BR>[FONT_NORMAL("\[Submitted by: [SPAN_COLOR("green", connected_group.wanted_issue.backup_author)]\]")]<HR>"
				dat+="<B>Criminal</B>: [connected_group.wanted_issue.author]<BR>"
				dat+="<B>Description</B>: [connected_group.wanted_issue.body]<BR>"
				dat+="<B>Photo</B>: "
				if(connected_group.wanted_issue.img)
					send_rsc(usr, connected_group.wanted_issue.img, "tmp_photow.png")
					dat+="<BR><img src='tmp_photow.png' width = '180'>"
				else
					dat+="None"
				dat+="<BR><BR><A href='byond://?src=\ref[src];setScreen=[0]'>Back</A><BR>"
			if(19)
				dat+="[SPAN_COLOR("green", "Wanted issue for [src.channel_name] successfully edited.")]<BR><BR>"
				dat+="<BR><A href='byond://?src=\ref[src];setScreen=[0]'>Return</A><BR>"
			if(20)
				dat+="[SPAN_COLOR("green", "Printing successful. Please receive your newspaper from the bottom of the machine.")]<BR><BR>"
				dat+="<A href='byond://?src=\ref[src];setScreen=[0]'>Return</A>"
			if(21)
				dat+="[SPAN_COLOR("maroon", "Unable to print newspaper. Insufficient paper. Please notify maintenance personnel to refill machine storage.")]<BR><BR>"
				dat+="<A href='byond://?src=\ref[src];setScreen=[0]'>Return</A>"
			else
				dat+="I'm sorry to break your immersion. This shit's bugged. Report this bug to Agouri, polyxenitopalidou@gmail.com"


		show_browser(human_or_robot_user, dat, "window=newscaster_main;size=400x600")
		onclose(human_or_robot_user, "newscaster_main")

/obj/machinery/newscaster/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && isturf(loc))) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)
		if(href_list["set_channel_name"])
			src.channel_name = sanitizeSafe(input(usr, "Provide a Feed Channel Name", "Network Channel Handler", ""), MAX_LNAME_LEN)
			src.updateUsrDialog()
			//src.update_icon()

		else if(href_list["set_channel_lock"])
			src.c_locked = !src.c_locked
			src.updateUsrDialog()
			//src.update_icon()

		else if(href_list["submit_new_channel"])
			//var/list/existing_channels = list() //OBSOLETE
			var/list/existing_authors = list()
			for(var/datum/feed_channel/FC in connected_group.network_channels)
				//existing_channels += FC.channel_name
				if(FC.author == "\[REDACTED\]")
					existing_authors += FC.backup_author
				else
					existing_authors  +=FC.author
			var/check = 0
			for(var/datum/feed_channel/FC in connected_group.network_channels)
				if(FC.channel_name == src.channel_name)
					check = 1
					break
			if(src.channel_name == "" || src.channel_name == "\[REDACTED\]" || src.scanned_user == "Unknown" || check || (src.scanned_user in existing_authors) )
				src.screen=7
			else
				var/choice = alert("Please confirm Feed channel creation","Network Channel Handler","Confirm","Cancel")
				if(choice=="Confirm")
					connected_group.CreateFeedChannel(src.channel_name, src.scanned_user, c_locked)
					src.screen=5
			src.updateUsrDialog()
			//src.update_icon()

		else if(href_list["set_channel_receiving"])
			//var/list/datum/feed_channel/available_channels = list()
			var/list/available_channels = list()
			for(var/datum/feed_channel/F in connected_group.network_channels)
				if( (!F.locked || F.author == scanned_user) && !F.censored)
					available_channels += F.channel_name
			src.channel_name = input(usr, "Choose receiving Feed Channel", "Network Channel Handler") in available_channels
			src.updateUsrDialog()

		else if(href_list["set_new_message"])
			src.msg = sanitize(input(usr, "Write your Feed story", "Network Channel Handler", ""))
			src.updateUsrDialog()

		else if(href_list["set_attachment"])
			AttachPhoto(usr)
			src.updateUsrDialog()

		else if(href_list["submit_new_message"])
			if(src.msg =="" || src.msg=="\[REDACTED\]" || src.scanned_user == "Unknown" || src.channel_name == "" )
				src.screen=6
			else
				var/image = photo_data ? photo_data.photo : null
				connected_group.SubmitArticle(src.msg, src.scanned_user, src.channel_name, image, 0)
				if(photo_data)
					qdel(photo_data)
					photo_data = null
				src.screen=4

			src.updateUsrDialog()

		else if(href_list["create_channel"])
			src.screen=2
			src.updateUsrDialog()

		else if(href_list["create_feed_story"])
			src.screen=3
			src.updateUsrDialog()

		else if(href_list["menu_paper"])
			src.screen=8
			src.updateUsrDialog()
		else if(href_list["print_paper"])
			if(!src.paper_remaining)
				src.screen=21
			else
				src.print_paper()
				src.screen = 20
			src.updateUsrDialog()

		else if(href_list["menu_censor_story"])
			src.screen=10
			src.updateUsrDialog()

		else if(href_list["menu_censor_channel"])
			src.screen=11
			src.updateUsrDialog()

		else if(href_list["menu_wanted"])
			var/already_wanted = 0
			if(connected_group.wanted_issue)
				already_wanted = 1

			if(already_wanted)
				src.channel_name = connected_group.wanted_issue.author
				src.msg = connected_group.wanted_issue.body
			src.screen = 14
			src.updateUsrDialog()

		else if(href_list["set_wanted_name"])
			src.channel_name = sanitizeSafe(input(usr, "Provide the name of the Wanted person", "Network Security Handler", ""), MAX_LNAME_LEN)
			src.updateUsrDialog()

		else if(href_list["set_wanted_desc"])
			src.msg = sanitize(input(usr, "Provide the a description of the Wanted person and any other details you deem important", "Network Security Handler", ""))
			src.updateUsrDialog()

		else if(href_list["submit_wanted"])
			var/input_param = text2num(href_list["submit_wanted"])
			if(src.msg == "" || src.channel_name == "" || src.scanned_user == "Unknown")
				src.screen = 16
			else
				var/choice = alert("Please confirm Wanted Issue [(input_param==1) ? ("creation.") : ("edit.")]","Network Security Handler","Confirm","Cancel")
				if(choice=="Confirm")
					if(input_param==1)          //If input_param == 1 we're submitting a new wanted issue. At 2 we're just editing an existing one. See the else below
						var/datum/feed_message/WANTED = new /datum/feed_message
						WANTED.author = src.channel_name
						WANTED.body = src.msg
						WANTED.backup_author = src.scanned_user //I know, a bit wacky
						if(photo_data)
							WANTED.img = photo_data.photo.img
						connected_group.wanted_issue = WANTED
						connected_group.alert_readers()
						src.screen = 15
					else
						if(connected_group.wanted_issue.is_admin_message)
							alert("The wanted issue has been distributed by a [GLOB.using_map.company_name] higherup. You cannot edit it.","Ok")
							return
						connected_group.wanted_issue.author = src.channel_name
						connected_group.wanted_issue.body = src.msg
						connected_group.wanted_issue.backup_author = src.scanned_user
						if(photo_data)
							connected_group.wanted_issue.img = photo_data.photo.img
						src.screen = 19

			src.updateUsrDialog()

		else if(href_list["cancel_wanted"])
			if (!connected_group.wanted_issue)
				alert("There is no wanted issue to cancel.", "Ok")
				return
			if(connected_group.wanted_issue.is_admin_message)
				alert("The wanted issue has been distributed by a [GLOB.using_map.company_name] higherup. You cannot take it down.","Ok")
				return
			var/choice = alert("Please confirm Wanted Issue removal","Network Security Handler","Confirm","Cancel")
			if(choice=="Confirm")
				connected_group.wanted_issue = null
				for(var/obj/machinery/newscaster/NEWSCASTER in connected_group.newscasters)
					NEWSCASTER.update_icon()
				src.screen=17
			src.updateUsrDialog()

		else if(href_list["view_wanted"])
			src.screen=18
			src.updateUsrDialog()
		else if(href_list["censor_channel_author"])
			var/datum/feed_channel/FC = locate(href_list["censor_channel_author"])
			if(FC.is_admin_channel)
				alert("This channel was created by a [GLOB.using_map.company_name] Officer. You cannot censor it.","Ok")
				return
			if(FC.author != "<B>\[REDACTED\]</B>")
				FC.backup_author = FC.author
				FC.author = "<B>\[REDACTED\]</B>"
			else
				FC.author = FC.backup_author
			FC.update()
			src.updateUsrDialog()

		else if(href_list["censor_channel_story_author"])
			var/datum/feed_message/MSG = locate(href_list["censor_channel_story_author"])
			if(MSG.is_admin_message)
				alert("This message was created by a [GLOB.using_map.company_name] Officer. You cannot censor its author.","Ok")
				return
			if(MSG.author != "<B>\[REDACTED\]</B>")
				MSG.backup_author = MSG.author
				MSG.author = "<B>\[REDACTED\]</B>"
			else
				MSG.author = MSG.backup_author
			MSG.parent_channel.update()
			src.updateUsrDialog()

		else if(href_list["censor_channel_story_body"])
			var/datum/feed_message/MSG = locate(href_list["censor_channel_story_body"])
			if(MSG.is_admin_message)
				alert("This channel was created by a [GLOB.using_map.company_name] Officer. You cannot censor it.","Ok")
				return
			if(MSG.body != "<B>\[REDACTED\]</B>")
				MSG.backup_body = MSG.body
				MSG.backup_caption = MSG.caption
				MSG.backup_img = MSG.img
				MSG.body = "<B>\[REDACTED\]</B>"
				MSG.caption = "<B>\[REDACTED\]</B>"
				MSG.img = null
			else
				MSG.body = MSG.backup_body
				MSG.caption = MSG.caption
				MSG.img = MSG.backup_img

			MSG.parent_channel.update()
			src.updateUsrDialog()

		else if(href_list["pick_d_notice"])
			var/datum/feed_channel/FC = locate(href_list["pick_d_notice"])
			src.viewing_channel = FC
			src.screen=13
			src.updateUsrDialog()

		else if(href_list["toggle_d_notice"])
			var/datum/feed_channel/FC = locate(href_list["toggle_d_notice"])
			if(FC.is_admin_channel)
				alert("This channel was created by a [GLOB.using_map.company_name] Officer. You cannot place a D-Notice upon it.","Ok")
				return
			FC.censored = !FC.censored
			FC.update()
			src.updateUsrDialog()

		else if(href_list["view"])
			src.screen=1
			src.updateUsrDialog()

		else if(href_list["setScreen"]) //Brings us to the main menu and resets all fields~
			src.screen = text2num(href_list["setScreen"])
			if (src.screen == 0)
				src.scanned_user = "Unknown"
				msg = ""
				src.c_locked=0
				channel_name=""
				src.viewing_channel = null
				if (photo_data)
					qdel(photo_data)
					photo_data = null
			src.updateUsrDialog()

		else if(href_list["show_channel"])
			var/datum/feed_channel/FC = locate(href_list["show_channel"])
			src.viewing_channel = FC
			src.screen = 9
			src.updateUsrDialog()

		else if(href_list["pick_censor_channel"])
			var/datum/feed_channel/FC = locate(href_list["pick_censor_channel"])
			src.viewing_channel = FC
			src.screen = 12
			src.updateUsrDialog()

		else if(href_list["refresh"])
			src.updateUsrDialog()



/obj/machinery/newscaster/use_weapon(obj/item/weapon, mob/living/user, list/click_params)
	if (MACHINE_IS_BROKEN(src))
		visible_message(SPAN_WARNING("\The [user] further abuses the shattered [name]."))
		playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 100, 1)
		return TRUE

	if ((. = ..()))
		queue_icon_update()
		return

/datum/news_photo
	var/is_synth = 0
	var/obj/item/photo/photo = null

/datum/news_photo/New(obj/item/photo/p, synth)
	is_synth = synth
	photo = p

/obj/machinery/newscaster/proc/AttachPhoto(mob/user as mob)
	if(photo_data)
		qdel(photo_data)
		photo_data = null
		return

	if(istype(user.get_active_hand(), /obj/item/photo))
		var/obj/item/photo = user.get_active_hand()
		photo_data = new(photo, 0)
	else if(istype(user,/mob/living/silicon))
		var/mob/living/silicon/tempAI = user
		var/obj/item/photo/selection = tempAI.GetPicture()
		if (!selection)
			return

		photo_data = new(selection, 1)


//########################################################################################################################
//###################################### NEWSPAPER! ######################################################################
//########################################################################################################################

/obj/item/newspaper
	name = "newspaper"
	desc = "An issue of The Griffon, the space newspaper."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "newspaper"
	w_class = ITEM_SIZE_SMALL	//Let's make it fit in trashbags!
	attack_verb = list("bapped")
	var/screen = 0
	var/pages = 0
	var/curr_page = 0
	var/list/datum/feed_channel/news_content = list()
	var/datum/feed_message/important_message = null
	var/scribble=""
	var/scribble_page = null

/obj/item/newspaper/attack_self(mob/user)
	user.update_personal_goal(/datum/goal/achievement/newshound, TRUE)
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		var/dat
		src.pages = 0
		switch(screen)
			if(0) //Cover
				dat+="<DIV ALIGN='center'><B>[SPAN_SIZE(6, "The Griffon")]</B></div>"
				dat+="<DIV ALIGN='center'>[FONT_NORMAL("[GLOB.using_map.company_name]-standard newspaper, for use on [GLOB.using_map.company_name] Space Facilities")]</div><HR>"
				if(!length(news_content))
					if(src.important_message)
						dat+="Contents:<BR><ul><B>[SPAN_COLOR("red", "**")]Important Security Announcement[SPAN_COLOR("red", "**")]</B> [FONT_NORMAL("\[page [src.pages+2]\]")]<BR></ul>"
					else
						dat+="<I>Other than the title, the rest of the newspaper is unprinted...</I>"
				else
					dat+="Contents:<BR><ul>"
					for(var/datum/feed_channel/NP in src.news_content)
						src.pages++
					if(src.important_message)
						dat+="<B>[SPAN_COLOR("red", "**")]Important Security Announcement[SPAN_COLOR("red", "**")]</B> [FONT_NORMAL("\[page [src.pages+2]\]")]<BR>"
					var/temp_page=0
					for(var/datum/feed_channel/NP in src.news_content)
						temp_page++
						dat+="<B>[NP.channel_name]</B> [FONT_NORMAL("\[page [temp_page+1]\]")]<BR>"
					dat+="</ul>"
				if(scribble_page==curr_page)
					dat+="<BR><I>There is a small scribble near the end of this page... It reads: \"[src.scribble]\"</I>"
				dat+= "<HR><DIV STYLE='float:right;'><A href='byond://?src=\ref[src];next_page=1'>Next Page</A></DIV> <div style='float:left;'><A href='byond://?src=\ref[human_user];mach_close=newspaper_main'>Done reading</A></DIV>"
			if(1) // X channel pages inbetween.
				for(var/datum/feed_channel/NP in src.news_content)
					src.pages++ //Let's get it right again.
				var/datum/feed_channel/C = src.news_content[src.curr_page]
				dat+="[FONT_HUGE("<B>[C.channel_name]</B>")][FONT_SMALL(" \[created by: [SPAN_COLOR("maroon", C.author)]\]")]<BR><BR>"
				if(C.censored)
					dat+="This channel was deemed dangerous to the general welfare of the [station_name()] and therefore marked with a [SPAN_COLOR("red", "<B>D-Notice</B>")]. Its contents were not transferred to the newspaper at the time of printing."
				else
					if(!length(C.messages))
						dat+="No Feed stories stem from this channel..."
					else
						dat+="<ul>"
						var/i = 0
						for(var/datum/feed_message/MESSAGE in C.messages)
							++i
							dat+="-[MESSAGE.body] <BR>"
							if(MESSAGE.img)
								var/resourc_name = "newscaster_photo_[C.channel_id]_[i].png"
								send_asset(user.client, resourc_name)
								dat+="<img src='[resourc_name]' width = '180'><BR>"
							dat+="[FONT_SMALL("\[[MESSAGE.message_type] by [SPAN_COLOR("maroon", MESSAGE.author)]\]")]<BR><BR>"
						dat+="</ul>"
				if(scribble_page==curr_page)
					dat+="<BR><I>There is a small scribble near the end of this page... It reads: \"[src.scribble]\"</I>"
				dat+= "<BR><HR><DIV STYLE='float:left;'><A href='byond://?src=\ref[src];prev_page=1'>Previous Page</A></DIV> <DIV STYLE='float:right;'><A href='byond://?src=\ref[src];next_page=1'>Next Page</A></DIV>"
			if(2) //Last page
				for(var/datum/feed_channel/NP in src.news_content)
					src.pages++
				if(src.important_message!=null)
					dat+="<DIV STYLE='float:center;'>[FONT_HUGE("<B>Wanted Issue:</B>")]</DIV><BR><BR>"
					dat+="<B>Criminal name</B>: [SPAN_COLOR("maroon", important_message.author)]<BR>"
					dat+="<B>Description</B>: [important_message.body]<BR>"
					dat+="<B>Photo:</B>: "
					if(important_message.img)
						send_rsc(user, important_message.img, "tmp_photow.png")
						dat+="<BR><img src='tmp_photow.png' width = '180'>"
					else
						dat+="None"
				else
					dat+="<I>Apart from some uninteresting Classified ads, there's nothing on this page...</I>"
				if(scribble_page==curr_page)
					dat+="<BR><I>There is a small scribble near the end of this page... It reads: \"[src.scribble]\"</I>"
				dat+= "<HR><DIV STYLE='float:left;'><A href='byond://?src=\ref[src];prev_page=1'>Previous Page</A></DIV>"
			else
				dat+="I'm sorry to break your immersion. This shit's bugged. Report this bug to Agouri, polyxenitopalidou@gmail.com"

		dat+="<BR><HR><div align='center'>[src.curr_page+1]</div>"
		show_browser(human_user, dat, "window=newspaper_main;size=300x400")
		onclose(human_user, "newspaper_main")
	else
		to_chat(user, "The paper is full of intelligible symbols!")


/obj/item/newspaper/Topic(href, href_list)
	var/mob/living/U = usr
	..()
	if ((src in U.contents) || ( isturf(loc) && in_range(src, U) ))
		U.set_machine(src)
		if(href_list["next_page"])
			if(curr_page==src.pages+1)
				return //Don't need that at all, but anyway.
			if(src.curr_page == src.pages) //We're at the middle, get to the end
				src.screen = 2
			else
				if(curr_page == 0) //We're at the start, get to the middle
					src.screen=1
			src.curr_page++
			playsound(src.loc, "pageturn", 50, 1)

		else if(href_list["prev_page"])
			if(curr_page == 0)
				return
			if(curr_page == 1)
				src.screen = 0

			else
				if(curr_page == src.pages+1) //we're at the end, let's go back to the middle.
					src.screen = 1
			src.curr_page--
			playsound(src.loc, "pageturn", 50, 1)

		if (ismob(loc))
			src.attack_self(src.loc)


/obj/item/newspaper/use_tool(obj/item/W, mob/living/user, list/click_params)
	if(istype(W, /obj/item/pen))
		if(scribble_page == curr_page)
			to_chat(user, SPAN_COLOR("blue", "There's already a scribble in this page... You wouldn't want to make things too cluttered, would you?"))
		else
			var/s = sanitize(input(user, "Write something", "Newspaper", ""))
			s = sanitize(s)
			if (!s)
				return TRUE
			if (!in_range(src, usr) && loc != usr)
				return TRUE
			scribble_page = curr_page
			scribble = s
			attack_self(user)
		return TRUE
	return ..()


////////////////////////////////////helper procs


/obj/machinery/newscaster/proc/scan_user(mob/living/user as mob)
	if(istype(user,/mob/living/carbon/human))                       //User is a human
		var/mob/living/carbon/human/human_user = user
		var/obj/item/card/id/id = human_user.GetIdCard()
		if(istype(id))                                      //Newscaster scans you
			src.scanned_user = GetNameAndAssignmentFromId(id)
		else
			src.scanned_user = "Unknown"
	else
		var/mob/living/silicon/ai_user = user
		src.scanned_user = "[ai_user.name] ([ai_user.job])"


/obj/machinery/newscaster/proc/print_paper()
	var/obj/item/newspaper/NEWSPAPER = new /obj/item/newspaper
	for(var/datum/feed_channel/FC in connected_group.network_channels)
		NEWSPAPER.news_content += FC
	if(connected_group.wanted_issue)
		NEWSPAPER.important_message = connected_group.wanted_issue
	NEWSPAPER.dropInto(loc)
	src.paper_remaining--
	return

//Removed for now so these aren't even checked every tick. Left this here in-case Agouri needs it later.
///obj/machinery/newscaster/process()       //Was thinking of doing the icon update through process, but multiple iterations per second does not
//	return                                  //bode well with a newscaster network of 10+ machines. Let's just return it, as it's added in the machines list.

/obj/machinery/newscaster/proc/newsAlert(news_call)   //This isn't Agouri's work, for it is ugly and vile.
	if(news_call)
		audible_message(SPAN_CLASS("newscaster", "<EM>[name]</EM> beeps, \"[news_call]\""))
		src.alert = 1
		src.update_icon()
		spawn(300)
			src.alert = 0
			src.update_icon()
		playsound(src.loc, 'sound/machines/twobeep.ogg', 75, 1)
	else
		audible_message("newscaster", "<EM>[src.name]</EM> beeps, \"Attention! Wanted issue distributed!\"")
		playsound(src.loc, 'sound/machines/warning-buzzer.ogg', 75, 1)
	return
