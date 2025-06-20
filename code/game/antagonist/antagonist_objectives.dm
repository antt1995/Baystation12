/datum/antagonist/proc/create_global_objectives(override=0)
	if(config.objectives_disabled != CONFIG_OBJECTIVE_ALL && !override)
		return 0
	if(global_objectives && length(global_objectives))
		return 0
	return 1

/datum/antagonist/proc/create_objectives(datum/mind/player, override=0)
	if(config.objectives_disabled != CONFIG_OBJECTIVE_ALL && !override)
		return 0
	if(create_global_objectives(override) || length(global_objectives))
		player.objectives |= global_objectives
	return 1

/datum/antagonist/proc/get_special_objective_text()
	return ""

/mob/proc/add_objectives()
	set name = "Get Objectives"
	set desc = "Recieve optional objectives."
	set category = "OOC"

	src.verbs -= /mob/proc/add_objectives

	if(!src.mind)
		return

	var/all_antag_types = GLOB.all_antag_types_
	for(var/tag in all_antag_types) //we do all of them in case an admin adds an antagonist via the PP. Those do not show up in gamemode.
		var/datum/antagonist/antagonist = all_antag_types[tag]
		if(antagonist && antagonist.is_antagonist(src.mind))
			antagonist.create_objectives(src.mind,1)

	to_chat(src, "<b>[FONT_LARGE("These objectives are completely voluntary. You are not required to complete them.")]</b>")
	show_objectives(src.mind)

/mob/living/proc/set_ambition()
	set name = "Set Ambition"
	set category = "IC"
	set src = usr

	if(!mind)
		return
	if(!is_special_character(mind))
		to_chat(src, SPAN_WARNING("While you may perhaps have goals, this verb's meant to only be visible \
		to antagonists.  Please make a bug report!"))
		return

	var/datum/goal/ambition/goal = SSgoals.ambitions[mind]
	var/unsanitized_new_goal = input(src, "Write a short sentence of what your character hopes to accomplish \
	today as an antagonist.  Remember that this is purely optional.  It will be shown at the end of the \
	round for everybody else.  To clear your ambitions, remove all the text in the field.  Pressing cancel \
	will only discard your edits.", "Antagonist Goal", (goal ? html_decode(goal.description) : "")) as null|message
	if(isnull(unsanitized_new_goal))
		to_chat(src, SPAN_NOTICE("You cancel your edits to your ambitions. They remain unchanged."))
		return
	var/new_goal = sanitize(unsanitized_new_goal)
	if(!isnull(new_goal))
		if(!goal)
			goal = new /datum/goal/ambition(mind)
		goal.description = new_goal
		log_and_message_admins("has set their ambitions to now be: [new_goal].")
		to_chat(src, SPAN_NOTICE("You've set your goal to be <b>'[goal.description]'</b>. You can check your goals with the <b>Show Goals</b> verb."))
	else
		if(goal)
			qdel(goal)
		log_and_message_admins("has cleared their ambitions.")
		to_chat(src, SPAN_NOTICE("You leave your ambitions behind."))

//some antagonist datums are not actually antagonists, so we might want to avoid
//sending them the antagonist meet'n'greet messages.
//E.G. ERT
/datum/antagonist/proc/show_objectives_at_creation(datum/mind/player)
	if(src.show_objectives_on_creation)
		show_objectives(player)
