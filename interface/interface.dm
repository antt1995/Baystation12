/client/proc/link_url(url, name, skip_confirmation)
	if (!url)
		to_chat(src, SPAN_WARNING("The server configuration does not include \a [name] URL."))
		return
	if (!skip_confirmation)
		var/cancel = alert("You will open [url]. Are you sure?", "Visit [name]", "Yes", "No") != "Yes"
		if (cancel)
			return
	send_link(src, url)


/client/verb/link_wiki()
	set name = "link wiki"
	set hidden = TRUE
	link_url(config.wiki_url, "Wiki", TRUE)


/client/verb/link_source()
	set name = "link source"
	set hidden = TRUE
	link_url(config.source_url, "Source", TRUE)


/client/verb/link_issue()
	set name = "link issue"
	set hidden = TRUE
	link_url(config.issue_url, "Issue", TRUE)


/client/verb/link_forum()
	set name = "link forum"
	set hidden = TRUE
	link_url(config.forum_url, "Forum", TRUE)


/client/verb/link_rules()
	set name = "link rules"
	set hidden = TRUE
	link_url(config.rules_url, "Rules", TRUE)


/client/verb/link_lore()
	set name = "link lore"
	set hidden = TRUE
	link_url(config.lore_url, "Lore", TRUE)

/client/verb/link_discord()
	set name = "link discord"
	set hidden = TRUE
	link_url(config.discord_url, "Discord", TRUE)

/client/verb/hotkeys_help()
	set name = "Hotkeys Help"
	set category = "OOC"

	var/admin = SPAN_COLOR("purple", {"Admin:
\tF5 = Aghost (admin-ghost)
\tF6 = player-panel-new
\tF7 = admin-pm
\tF8 = Invisimin"})

	var/hotkey_mode = SPAN_COLOR("purple", {"Hotkey-Mode: (hotkey-mode must be on)
\tTAB = toggle hotkey-mode
\ta = left
\ts = down
\td = right
\tw = up
\t, = move-upwards
\t. = move-down
\tq = drop
\te = equip
\tr = throw
\tt = say
\t5 = emote
\tx = swap-hand
\tz = activate held object (or y)
\tj = toggle-aiming-mode
\tf = cycle-intents-left
\tg = cycle-intents-right
\t1 = help-intent
\t2 = disarm-intent
\t3 = grab-intent
\t4 = harm-intent"})

	var/other = SPAN_COLOR("purple", {"Any-Mode: (hotkey doesn't need to be on)
\tCtrl+a = left
\tCtrl+s = down
\tCtrl+d = right
\tCtrl+w = up
\tCtrl+q = drop
\tCtrl+e = equip
\tCtrl+r = throw
\tCtrl+x or Middle Mouse = swap-hand
\tCtrl+z = activate held object (or Ctrl+y)
\tCtrl+f = cycle-intents-left
\tCtrl+g = cycle-intents-right
\tCtrl+1 = help-intent
\tCtrl+2 = disarm-intent
\tCtrl+3 = grab-intent
\tCtrl+4 = harm-intent
\tESC = cancel current timed action
\tF1 = adminhelp
\tF2 = ooc
\tF3 = say
\tF4 = emote
\tDEL = pull
\tINS = cycle-intents-right
\tHOME = drop
\tPGUP or Middle Mouse = swap-hand
\tPGDN = activate held object
\tEND = throw
\tCtrl + Click = drag
\tShift + Click = examine
\tAlt + Click = show entities on turf
\tCtrl + Alt + Click = point"})

	var/robot_hotkey_mode = SPAN_COLOR("purple", {"Hotkey-Mode: (hotkey-mode must be on)
\tTAB = toggle hotkey-mode
\ta = left
\ts = down
\td = right
\tw = up
\tq = unequip active module
\tt = say
\tx = cycle active modules
\tz = activate held object (or y)
\tf = cycle-intents-left
\tg = cycle-intents-right
\t1 = activate module 1
\t2 = activate module 2
\t3 = activate module 3
\t4 = toggle intents
\t5 = emote"})

	var/robot_other = SPAN_COLOR("purple", {"Any-Mode: (hotkey doesn't need to be on)
\tCtrl+a = left
\tCtrl+s = down
\tCtrl+d = right
\tCtrl+w = up
\tCtrl+q = unequip active module
\tCtrl+x = cycle active modules
\tCtrl+z = activate held object (or Ctrl+y)
\tCtrl+f = cycle-intents-left
\tCtrl+g = cycle-intents-right
\tCtrl+1 = activate module 1
\tCtrl+2 = activate module 2
\tCtrl+3 = activate module 3
\tCtrl+4 = toggle intents
\tESC = cancel current timed action
\tF1 = adminhelp
\tF2 = ooc
\tF3 = say
\tF4 = emote
\tDEL = pull
\tINS = toggle intents
\tPGUP = cycle active modules
\tPGDN = activate held object
\tCtrl + Click = drag or bolt doors
\tShift + Click = examine or open doors
\tAlt + Click = show entities on turf
\tCtrl + Shift + Click = electrify doors
\tCtrl + Alt + Click = point"})

	if(isrobot(src.mob))
		to_chat(src, robot_hotkey_mode)
		to_chat(src, robot_other)
	else
		to_chat(src, hotkey_mode)
		to_chat(src, other)
	if(holder)
		to_chat(src, admin)
