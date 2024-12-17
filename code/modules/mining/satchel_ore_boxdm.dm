
/**********************Ore box**************************/
/obj/item/flatpack
	var/deploy_path = null
	var/deploy_time = 2 SECONDS
	var/deploy_sound = 'sound/items/Deconstruct.ogg'
	w_class = ITEM_SIZE_NORMAL

/obj/item/flatpack/ore_box
	name = "packed ore box"
	w_class = ITEM_SIZE_NORMAL
	icon = 'icons/obj/ore_boxes.dmi'
	icon_state = "orebox2stored"
	deploy_path = /obj/structure/ore_box/flatpacked
	matter = list(MATERIAL_STEEL = 15000)

/obj/item/flatpack/use_after(atom/target, mob/living/user, click_parameters)
	if(!deploy_path)
		return
	if (loc != user)
		return
	var/turf/T = get_turf(target)
	if (!user.TurfAdjacent(T))
		return
	if (isspaceturf(T) || isopenspace(T))
		to_chat(user, SPAN_WARNING("You cannot use \the [src] in open space."))
		return TRUE
	var/obstruction = T.get_obstruction()
	if (obstruction)
		to_chat(user, SPAN_WARNING("\The [english_list(obstruction)] is blocking that spot."))
		return TRUE
	user.visible_message(
		SPAN_ITALIC("\The [user] starts assembling \an [src]."),
		SPAN_ITALIC("You start assembling \the [src]."),
		SPAN_ITALIC("You can hear rustling of planks and sheets."),
		range = 5
	)
	if (!do_after(user, deploy_time, target, DO_PUBLIC_UNIQUE) || QDELETED(src))
		return TRUE
	obstruction = T.get_obstruction()
	if (obstruction)
		to_chat(user, SPAN_WARNING("\The [english_list(obstruction)] is blocking that spot."))
		return TRUE
	user.visible_message(
		SPAN_ITALIC("\The [user] finishes assembling \an [src]."),
		SPAN_NOTICE("You assemble \the [src]."),
		range = 5
	)
	playsound(src, deploy_sound, 50, TRUE)
	var/obj/R = new deploy_path(T)
	transfer_fingerprints_to(R)
	R.add_fingerprint(user)
	copy_health(src, R)
	qdel(src)
	return TRUE


/obj/structure/ore_box
	icon = 'icons/obj/ore_boxes.dmi'
	icon_state = "orebox0"
	name = "ore box"
	desc = "A heavy box used for storing ore."
	density = TRUE
	var/last_update = 0
	var/list/stored_ore = list()


/obj/structure/ore_box/flatpacked
	icon_state = "orebox2"

/obj/structure/ore_box/use_tool(obj/item/tool, mob/user, list/click_params)
	// Ore - Insert ore
	if (istype(tool, /obj/item/ore))
		if (!user.unEquip(tool, src))
			FEEDBACK_UNEQUIP_FAILURE(user, tool)
			return TRUE
		update_ore_count()
		user.visible_message(
			SPAN_NOTICE("\The [user] puts \a [tool] in \the [src]."),
			SPAN_NOTICE("You put \the [tool] in \the [src].")
		)
		return TRUE

	// Storage - Bulk insert ore
	if (istype(tool, /obj/item/storage))
		var/obj/item/storage/storage = tool
		storage.hide_from(user)
		for (var/obj/item/ore/ore in storage.contents)
			storage.remove_from_storage(ore, src, TRUE)
		storage.finish_bulk_removal()
		update_ore_count()
		user.visible_message(
			SPAN_NOTICE("\The [user] empties \a [tool] into \the [src]."),
			SPAN_NOTICE("You empty \the [tool] into \the [src].")
		)
		return TRUE

	return ..()


/obj/structure/ore_box/proc/update_ore_count()

	stored_ore = list()

	for(var/obj/item/ore/O in contents)

		if(stored_ore[O.name])
			stored_ore[O.name]++
		else
			stored_ore[O.name] = 1

/obj/structure/ore_box/examine(mob/user)
	. = ..()

	// Borgs can now check contents too.
	if((!istype(user, /mob/living/carbon/human)) && (!istype(user, /mob/living/silicon/robot)))
		return

	if(!Adjacent(user)) //Can only check the contents of ore boxes if you can physically reach them.
		return

	add_fingerprint(user)

	if(!length(contents))
		to_chat(user, "It is empty.")
		return

	if(world.time > last_update + 10)
		update_ore_count()
		last_update = world.time

	to_chat(user, "It holds:")
	for(var/ore in stored_ore)
		to_chat(user, "- [stored_ore[ore]] [ore]")
	return


/obj/structure/ore_box/verb/empty_box()
	set name = "Empty Ore Box"
	set category = "Object"
	set src in view(1)

	if(!istype(usr, /mob/living/carbon/human)) //Only living, intelligent creatures with hands can empty ore boxes.
		to_chat(usr, SPAN_WARNING("You are physically incapable of emptying the ore box."))
		return

	if( usr.stat || usr.restrained() )
		return

	if(!Adjacent(usr)) //You can only empty the box if you can physically reach it
		to_chat(usr, "You cannot reach the ore box.")
		return

	add_fingerprint(usr)

	if(length(contents) < 1)
		to_chat(usr, SPAN_WARNING("The ore box is empty"))
		return

	for (var/obj/item/ore/O in contents)
		O.dropInto(loc)
	to_chat(usr, SPAN_NOTICE("You empty the ore box"))

/obj/structure/ore_box/ex_act(severity)
	if(severity == EX_ACT_DEVASTATING || (severity < EX_ACT_LIGHT && prob(50)))
		for (var/obj/item/ore/O in contents)
			O.dropInto(loc)
			O.ex_act(severity++)
		qdel(src)
