/obj/structure/diona_gestalt/verb/shape_gestalt()

	set name = "Call Gestalt Vote"
	set category = "IC"
	set src = usr.loc

	if(!is_alien_whitelisted(usr, GLOB.species_by_name[SPECIES_DIONA]))
		to_chat(usr, SPAN_WARNING("You are not whitelisted for control of more complex forms of gestalt."))
		return

	var/vote_type = input(usr, "Select the vote you wish to call.") as null|anything in democracy_bucket
	vote_type = democracy_bucket[vote_type]
	if(ispath(vote_type) && usr.loc == src && !QDELETED(usr) && !QDELETED(src) && !usr.incapacitated())
		start_vote(usr, vote_type)
