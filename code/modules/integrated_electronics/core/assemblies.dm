#define IC_MAX_SIZE_BASE		25
#define IC_COMPLEXITY_BASE		75

/obj/item/device/electronic_assembly
	name = "electronic assembly"
	desc = "It's a case used for assembling small electronics."
	w_class = ITEM_SIZE_SMALL
	icon = 'icons/obj/assemblies/electronic_setups.dmi'
	icon_state = "setup_small"
	item_flags = ITEM_FLAG_NO_BLUDGEON
	matter = list()		// To be filled later
	var/list/assembly_components = list()
	var/list/ckeys_allowed_to_scan = list() // Players who built the circuit can scan it as a ghost.
	var/max_components = IC_MAX_SIZE_BASE
	var/max_complexity = IC_COMPLEXITY_BASE
	var/opened = TRUE
	var/obj/item/cell/battery // Internal cell which most circuits need to work.
	var/can_charge = TRUE //Can it be charged in a recharger?
	var/circuit_flags = IC_FLAG_ANCHORABLE
	var/charge_sections = 4
	var/charge_delay = 4
	var/ext_next_use = 0
	var/weakref/collw
	var/allowed_circuit_action_flags = IC_ACTION_COMBAT | IC_ACTION_LONG_RANGE //which circuit flags are allowed
	var/creator // circuit creator if any
	var/static/next_assembly_id = 0
	var/interact_page = 0
	var/components_per_page = 10
	/// Spark system used for creating sparks while the assembly is damaged and destroyed.
	var/datum/effect/spark_spread/spark_system
	var/adrone = FALSE
	pass_flags = 0
	anchored = FALSE
	health_max = 30
	var/detail_color = COLOR_ASSEMBLY_BLACK
	var/list/color_whitelist = list( //This is just for checking that hacked colors aren't in the save data.
		COLOR_ASSEMBLY_BLACK,
		COLOR_GRAY40,
		COLOR_ASSEMBLY_BGRAY,
		COLOR_ASSEMBLY_WHITE,
		COLOR_ASSEMBLY_RED,
		COLOR_ASSEMBLY_ORANGE,
		COLOR_ASSEMBLY_BEIGE,
		COLOR_ASSEMBLY_BROWN,
		COLOR_ASSEMBLY_GOLD,
		COLOR_ASSEMBLY_YELLOW,
		COLOR_ASSEMBLY_GURKHA,
		COLOR_ASSEMBLY_LGREEN,
		COLOR_ASSEMBLY_GREEN,
		COLOR_ASSEMBLY_LBLUE,
		COLOR_ASSEMBLY_BLUE,
		COLOR_ASSEMBLY_PURPLE
		)

/obj/item/device/electronic_assembly/examine(mob/user)
	. = ..()
	if(IC_FLAG_ANCHORABLE & circuit_flags)
		to_chat(user, SPAN_NOTICE("The anchoring bolts [anchored ? "are" : "can be"] <b>wrenched</b> in place and the maintenance panel [opened ? "can be" : "is"] <b>screwed</b> in place."))
	else
		to_chat(user, SPAN_NOTICE("The maintenance panel [opened ? "can be" : "is"] <b>screwed</b> in place."))

	if((isobserver(user) && ckeys_allowed_to_scan[user.ckey]) || check_rights(R_ADMIN, 0, user))
		to_chat(user, "You can <a href='byond://?src=\ref[src];ghostscan=1'>scan</a> this circuit.")

/obj/item/device/electronic_assembly/on_death()
	visible_message(SPAN_WARNING("\The [src] falls to pieces!"))
	if(w_class == ITEM_SIZE_HUGE)
		if(adrone)
			new /obj/decal/cleanable/blood/gibs/robot(loc)
		new /obj/item/stack/material/steel(loc, rand(7, 10))
	else if(w_class == ITEM_SIZE_LARGE)
		if(adrone)
			new /obj/decal/cleanable/blood/gibs/robot(loc)
		new /obj/item/stack/material/steel(loc, rand(3, 6))
	else if(w_class == ITEM_SIZE_NORMAL)
		new /obj/item/stack/material/steel(loc, rand(1, 3))
	else
		new /obj/item/stack/material/steel(loc)
	if(battery && battery.charge > 0)
		spark_system.start()
	playsound(loc, 'sound/items/electronic_assembly_empty.ogg', 100, 1)
	icon = 0
	addtimer(new Callback(src, PROC_REF(fall_apart)), 5.1)

/obj/item/device/electronic_assembly/post_health_change(health_mod, prior_health, damage_type)
	..()
	if (get_damage_percentage() >= 75)
		if(battery && battery.charge > 0)
			visible_message(SPAN_WARNING("\The [src] sputters and sparks!"))
			spark_system.start()
		opened = TRUE
		queue_icon_update()

/obj/item/device/electronic_assembly/proc/check_interactivity(mob/user)
	return (!user.incapacitated() && CanUseTopic(user))

/obj/item/device/electronic_assembly/GetAccess()
	. = list()
	for(var/obj/item/integrated_circuit/output/O in assembly_components)
		var/o_access = O.GetAccess()
		. |= o_access

/obj/item/device/electronic_assembly/Bump(atom/AM, called)
	collw = weakref(AM)
	.=..()
	if(istype(AM, /obj/machinery/door/airlock) ||  istype(AM, /obj/machinery/door/window))
		var/obj/machinery/door/D = AM
		if(D.check_access(src))
			D.open()

/obj/item/device/electronic_assembly/Initialize()
	.=..()
	START_PROCESSING(SScircuit, src)
	matter[MATERIAL_STEEL] = round((max_complexity + max_components) / 4) * SScircuit.cost_multiplier
	spark_system = new /datum/effect/spark_spread
	spark_system.set_up(7, 0, src)
	spark_system.attach(src)

/obj/item/device/electronic_assembly/Destroy()
	QDEL_NULL(spark_system)
	STOP_PROCESSING(SScircuit, src)
	for(var/circ in assembly_components)
		remove_component(circ)
		qdel(circ)
	return ..()

/obj/item/device/electronic_assembly/proc/fall_apart()
	qdel(src)

/obj/item/device/electronic_assembly/Process()
	// First we generate power.
	for(var/obj/item/integrated_circuit/passive/power/P in assembly_components)
		P.make_energy()

	var/power_failure = FALSE
	if(get_damage_percentage() >= 75 && prob(1))
		if(battery && battery.charge > 0)
			visible_message(SPAN_WARNING("\The [src] sparks violently!"))
			spark_system.start()
		power_failure = TRUE
	// Now spend it.
	for(var/I in assembly_components)
		var/obj/item/integrated_circuit/IC = I
		if(IC.power_draw_idle)
			if(power_failure || !draw_power(IC.power_draw_idle))
				IC.power_fail()

/obj/item/device/electronic_assembly/MouseDrop_T(atom/dropping, mob/user)
	if(user == dropping)
		interact(user)
	else
		..()

/obj/item/device/electronic_assembly/interact(mob/user)
	if(!check_interactivity(user))
		return

	if(opened)
		open_interact(user)
	else
		closed_interact(user)

/obj/item/device/electronic_assembly/proc/closed_interact(mob/user)
	var/HTML = list()
	HTML += "<html><head><title>[src.name]</title></head><body>"
	HTML += "<br><a href='byond://?src=\ref[src];refresh=1'>\[Refresh\]</a>"
	HTML += "<br><br>"

	var/listed_components = FALSE
	for(var/obj/item/integrated_circuit/circuit in contents)
		var/list/topic_data = circuit.get_topic_data(user)
		if(topic_data)
			listed_components = TRUE
			HTML += "<b>[circuit.displayed_name]: </b>"
			if(length(topic_data) != 1)
				HTML += "<br>"
			for(var/entry in topic_data)
				var/href = topic_data[entry]
				if(href)
					HTML += "<a href='byond://?src=\ref[circuit];[href]'>[entry]</a>"
				else
					HTML += entry
				HTML += "<br>"
			HTML += "<br>"
	HTML += "</body></html>"

	if(listed_components)
		show_browser(user, jointext(HTML,null), "window=closed-assembly-\ref[src];size=600x350;border=1;can_resize=1;can_close=1;can_minimize=1")


/obj/item/device/electronic_assembly/proc/open_interact(mob/user)
	var/total_part_size = return_total_size()
	var/total_complexity = return_total_complexity()
	var/list/HTML = list()

	HTML += "<html><head><title>[name]</title></head><body>"

	HTML += "<a href='byond://?src=\ref[src]'>\[Refresh\]</a>  |  <a href='byond://?src=\ref[src];rename=1'>\[Rename\]</a><br>"
	HTML += "[total_part_size]/[max_components] space taken up in the assembly.<br>"
	HTML += "[total_complexity]/[max_complexity] complexity in the assembly.<br>"
	if(battery)
		HTML += "[round(battery.charge, 0.1)]/[battery.maxcharge] ([round(battery.percent(), 0.1)]%) cell charge. <a href='byond://?src=\ref[src];remove_cell=1'>\[Remove\]</a>"
	else
		HTML += SPAN_DANGER("No power cell detected!")

	if(length(assembly_components))
		HTML += "<br><br>"
		HTML += "Components:<br>"

		var/start_index = ((components_per_page * interact_page) + 1)
		for(var/i = start_index to min(length(assembly_components), start_index + (components_per_page - 1)))
			var/obj/item/integrated_circuit/circuit = assembly_components[i]
			HTML += "\[ <a href='byond://?src=\ref[src];component=\ref[circuit];set_slot=1'>[i]</a> \] | "
			HTML += "<a href='byond://?src=\ref[src];component=\ref[circuit];rename_component=1'>\[R\]</a> | "
			if(circuit.removable)
				HTML += "<a href='byond://?src=\ref[src];component=\ref[circuit];remove=1'>\[-\]</a> | "
			else
				HTML += "\[-\] | "
			HTML += "<a href='byond://?src=\ref[src];component=\ref[circuit];examine_component=1'>[circuit.displayed_name]</a>"
			HTML += "<br>"

		if(length(assembly_components) > components_per_page)
			HTML += "<br>\["
			for(var/i = 1 to ceil(length(assembly_components)/components_per_page))
				if((i-1) == interact_page)
					HTML += " [i]"
				else
					HTML += " <a href='byond://?src=\ref[src];select_page=[i-1]'>[i]</a>"
			HTML += " \]"

	HTML += "</body></html>"
	show_browser(user, jointext(HTML, null), "window=assembly-\ref[src];size=655x350;border=1;can_resize=1;can_close=1;can_minimize=1")

/obj/item/device/electronic_assembly/Topic(href, href_list)
	if(href_list["ghostscan"])
		if((isobserver(usr) && ckeys_allowed_to_scan[usr.ckey]) || check_rights(R_ADMIN,0,usr))
			if(length(assembly_components))
				var/saved = "On circuit printers with cloning enabled, you may use the code below to clone the circuit:<br><br><code>[SScircuit.save_electronic_assembly(src)]</code>"
				show_browser(usr, saved, "window=circuit_scan;size=500x600;border=1;can_resize=1;can_close=1;can_minimize=1")
			else
				to_chat(usr, SPAN_DANGER("The circuit is empty!"))
		return 0

	if(isobserver(usr))
		return

	if(!check_interactivity(usr))
		return 0

	if(href_list["select_page"])
		interact_page = text2num(href_list["select_page"])

	if(href_list["rename"])
		rename(usr)

	if(href_list["remove_cell"])
		if(!battery)
			to_chat(usr, SPAN_DANGER("There's no power cell to remove from \the [src]."))
		else
			battery.dropInto(loc)
			playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
			to_chat(usr, SPAN_NOTICE("You pull \the [battery] out of \the [src]'s power supplier."))
			battery = null

	if(href_list["component"])
		var/obj/item/integrated_circuit/component = locate(href_list["component"]) in assembly_components
		if(component)
			// Builtin components are not supposed to be removed or rearranged
			if(!component.removable)
				return 0

			add_allowed_scanner(usr.ckey)

			var/current_pos = assembly_components.Find(component)

			if(href_list["remove"])
				try_remove_component(component, usr)

			else if (href_list["rename_component"])
				component.rename_component()

			else if(href_list["set_slot"])
				var/selected_slot = input("Select a new slot", "Select slot", current_pos) as null|num
				if(!check_interactivity(usr))
					return 0
				if(selected_slot < 1 || selected_slot > length(assembly_components))
					return 0

				assembly_components.Remove(component)
				assembly_components.Insert(selected_slot, component)

			else if (href_list["examine_component"])
				component.interact(usr)
				return


	interact(usr) // To refresh the UI.

/obj/item/device/electronic_assembly/proc/rename()
	var/mob/M = usr
	if(!check_interactivity(M))
		return
	var/input = input("What do you want to name this?", "Rename", src.name) as null|text
	input = sanitizeName(input,allow_numbers = 1)
	if(!check_interactivity(M))
		return
	if(!QDELETED(src) && input)
		to_chat(M, SPAN_NOTICE("The machine now has a label reading '[input]'."))
		name = input

/obj/item/device/electronic_assembly/proc/add_allowed_scanner(ckey)
	ckeys_allowed_to_scan[ckey] = TRUE

/obj/item/device/electronic_assembly/proc/can_move()
	return FALSE

/obj/item/device/electronic_assembly/on_update_icon()
	if(opened)
		icon_state = initial(icon_state) + "-open"
	else
		icon_state = initial(icon_state)
	ClearOverlays()
	if(detail_color == COLOR_ASSEMBLY_BLACK) //Black colored overlay looks almost but not exactly like the base sprite, so just cut the overlay and avoid it looking kinda off.
		return
	var/image/detail_overlay = image('icons/obj/assemblies/electronic_setups.dmi', src,"[icon_state]-color")
	detail_overlay.color = detail_color
	AddOverlays(detail_overlay)

/obj/item/device/electronic_assembly/examine(mob/user)
	. = ..()
	for(var/I in assembly_components)
		var/obj/item/integrated_circuit/IC = I
		IC.external_examine(user)
		if(opened)
			IC.internal_examine(user)
	if(opened)
		interact(user)

//This only happens when this EA is loaded via the printer
/obj/item/device/electronic_assembly/proc/post_load()
	for(var/I in assembly_components)
		var/obj/item/integrated_circuit/IC = I
		IC.on_data_written()

/obj/item/device/electronic_assembly/proc/return_total_complexity()
	. = 0
	var/obj/item/integrated_circuit/part
	for(var/p in assembly_components)
		part = p
		. += part.complexity

/obj/item/device/electronic_assembly/proc/return_total_size()
	. = 0
	var/obj/item/integrated_circuit/part
	for(var/p in assembly_components)
		part = p
		. += part.size

// Returns true if the circuit made it inside.
/obj/item/device/electronic_assembly/proc/try_add_component(obj/item/integrated_circuit/IC, mob/user)
	if(!opened)
		to_chat(user, SPAN_DANGER("\The [src]'s hatch is closed, you can't put anything inside."))
		return FALSE

	if(IC.w_class > w_class)
		to_chat(user, SPAN_DANGER("\The [IC] is way too big to fit into \the [src]."))
		return FALSE

	var/total_part_size = return_total_size()
	var/total_complexity = return_total_complexity()

	if((total_part_size + IC.size) > max_components)
		to_chat(user, SPAN_DANGER("You can't seem to add the '[IC]', as there is insufficient space."))
		return FALSE
	if((total_complexity + IC.complexity) > max_complexity)
		to_chat(user, SPAN_DANGER("You can't seem to add the '[IC]', since this setup is too complicated for the case."))
		return FALSE
	if((allowed_circuit_action_flags & IC.action_flags) != IC.action_flags)
		to_chat(user, SPAN_DANGER("You can't seem to add the '[IC]', since the case doesn't support the circuit type."))
		return FALSE

	if(!user.unEquip(IC,src))
		return FALSE

	to_chat(user, SPAN_NOTICE("You slide [IC] inside [src]."))
	playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
	add_allowed_scanner(user.ckey)

	add_component(IC)
	return TRUE


// Actually puts the circuit inside, doesn't perform any checks.
/obj/item/device/electronic_assembly/proc/add_component(obj/item/integrated_circuit/component)
	component.forceMove(get_object())
	component.assembly = src
	assembly_components |= component


/obj/item/device/electronic_assembly/proc/try_remove_component(obj/item/integrated_circuit/IC, mob/user, silent)
	if(!opened)
		if(!silent)
			to_chat(user, SPAN_DANGER("\The [src]'s hatch is closed, so you can't fiddle with the internal components."))
		return FALSE

	if(!IC.removable)
		if(!silent)
			to_chat(user, SPAN_DANGER("\The [src] is permanently attached to the case."))
		return FALSE

	remove_component(IC)
	if(!silent)
		to_chat(user, SPAN_NOTICE("You pop \the [IC] out of the case, and slide it out."))
		playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
		user.put_in_hands(IC)
	add_allowed_scanner(user.ckey)

	// Make sure we're not on an invalid page
	interact_page = clamp(interact_page, 0, ceil(length(assembly_components)/components_per_page)-1)

	return TRUE

// Actually removes the component, doesn't perform any checks.
/obj/item/device/electronic_assembly/proc/remove_component(obj/item/integrated_circuit/component)
	component.disconnect_all()
	component.dropInto(loc)
	component.assembly = null
	assembly_components.Remove(component)


/obj/item/device/electronic_assembly/afterattack(atom/target, mob/user, proximity)
	. = ..()
	for(var/obj/item/integrated_circuit/input/S in assembly_components)
		if(S.sense(target,user,proximity))
			if(proximity)
				visible_message(SPAN_NOTICE("\The [user] waves \the [src] around \the [target]."))
			else
				visible_message(SPAN_NOTICE("\The [user] points \the [src] towards \the [target]."))


/obj/item/device/electronic_assembly/use_tool(obj/item/tool, mob/user, list/click_params)
	// Assembly Detailer - Set color
	if (istype(tool, /obj/item/device/integrated_electronics/detailer))
		var/obj/item/device/integrated_electronics/detailer/detailer = tool
		detail_color = detailer.detail_color
		update_icon()
		user.visible_message(
			SPAN_NOTICE("\The [user] re-colors \a [src] with \a [tool]."),
			SPAN_NOTICE("You re-color \the [src] with \the [tool].")
		)
		return TRUE

	// Integrated Circuit - Install circuit
	if (istype(tool, /obj/item/integrated_circuit))
		if (!user.canUnEquip(tool))
			FEEDBACK_UNEQUIP_FAILURE(user, tool)
			return TRUE
		if (try_add_component(tool, user))
			return TRUE
		return ..()

	// Multitool, wirer, debugger - Interact
	if (isMultitool(tool) || istype(tool, /obj/item/device/integrated_electronics/wirer) || istype(tool, /obj/item/device/integrated_electronics/debugger))
		if (!opened)
			USE_FEEDBACK_FAILURE("\The [src]'s hatch needs to be opened before you can access the internal components.")
			return TRUE
		interact(user)
		return TRUE

	// Power Cell - Install battery
	if (istype(tool, /obj/item/cell))
		if (!opened)
			USE_FEEDBACK_FAILURE("\The [src]'s hatch needs to be opened before you can install \the [tool].")
			return TRUE
		if (battery)
			USE_FEEDBACK_FAILURE("\The [src] already has \a [battery] installed.")
			return TRUE
		if (!user.unEquip(tool, src))
			FEEDBACK_UNEQUIP_FAILURE(user, tool)
			return TRUE
		battery = tool
		playsound(src, 'sound/items/Deconstruct.ogg', 50, TRUE)
		user.visible_message(
			SPAN_NOTICE("\The [user] installs \a [tool] into \a [src]."),
			SPAN_NOTICE("You install \the [tool] into \the [src].")
		)
		return TRUE

	// Screwdriver - Toggle panel
	if (isScrewdriver(tool))
		for (var/obj/item/integrated_circuit/manipulation/hatchlock/hatchlock in assembly_components)
			if (hatchlock.lock_enabled)
				USE_FEEDBACK_FAILURE("\The [src]'s [hatchlock.name] is locked and prevents you from opening the panel.")
				return TRUE
		playsound(src, 'sound/items/Screwdriver.ogg', 50, TRUE)
		opened = !opened
		update_icon()
		user.visible_message(
			SPAN_NOTICE("\The [user] [opened ? "opens" : "closes"] \a [src]'s panel with \a [tool]."),
			SPAN_NOTICE("You [opened ? "open" : "close"] \the [src]'s panel with \the [tool].")
		)
		return TRUE

	// Wrench - Toggle anchoring bolts
	if (isWrench(tool))
		if (!HAS_FLAGS(circuit_flags, IC_FLAG_ANCHORABLE))
			USE_FEEDBACK_FAILURE("\The [src] can't be anchored.")
			return TRUE
		if (!isturf(loc))
			USE_FEEDBACK_FAILURE("\The [src] needs to be on the floor to be anchored.")
			return TRUE
		playsound(src, 'sound/items/Ratchet.ogg', 50, TRUE)
		user.visible_message(
			SPAN_NOTICE("\The [user] starts wrenching \a [src] [anchored ? "from" : "to"] the floor with \a [tool]."),
			SPAN_NOTICE("You start wrenching \the [src] [anchored ? "from" : "to"] the floor with \the [tool].")
		)
		if (!user.do_skilled(tool.toolspeed, SKILL_CONSTRUCTION, src, do_flags = DO_REPAIR_CONSTRUCT) || !user.use_sanity_check(src, tool))
			return TRUE
		if (!HAS_FLAGS(circuit_flags, IC_FLAG_ANCHORABLE))
			USE_FEEDBACK_FAILURE("\The [src] can't be anchored.")
			return TRUE
		if (!isturf(loc))
			USE_FEEDBACK_FAILURE("\The [src] needs to be on the floor to be anchored.")
			return TRUE
		user.visible_message(
			SPAN_NOTICE("\The [user] wrenches \a [src] [anchored ? "from" : "to"] the floor with \a [tool]."),
			SPAN_NOTICE("You wrenches \the [src] [anchored ? "from" : "to"] the floor with \the [tool].")
		)
		anchored = !anchored
		return TRUE

	// Cable Coil - Repair damage
	if (isCoil(tool))
		if (!health_damaged())
			USE_FEEDBACK_FAILURE("\The [src] doesn't need repair.")
			return TRUE
		var/obj/item/stack/cable_coil/cable = tool
		if (!cable.can_use(5))
			USE_FEEDBACK_STACK_NOT_ENOUGH(cable, 5, "to repair \the [src].")
			return TRUE
		user.visible_message(
			SPAN_NOTICE("\The [user] starts repairing some of \a [src]'s damage with [cable.get_vague_name(TRUE)]."),
			SPAN_NOTICE("You start repairing some of \the [src]'s damage with [cable.get_exact_name(5)].")
		)
		if (!user.do_skilled(1 SECOND, SKILL_DEVICES, src) || !user.use_sanity_check(src, tool))
			return TRUE
		if (!health_damaged())
			USE_FEEDBACK_FAILURE("\The [src] doesn't need repair.")
			return TRUE
		if (!cable.use(5))
			USE_FEEDBACK_STACK_NOT_ENOUGH(cable, 5, "to repair \the [src].")
			return TRUE
		restore_health(5)
		user.visible_message(
			SPAN_NOTICE("\The [user] repairs some of \a [src]'s damage with [cable.get_vague_name(TRUE)]."),
			SPAN_NOTICE("You repair some of \the [src]'s damage with [cable.get_exact_name(5)].")
		)
		return TRUE

	// Everything else - Handle component reactions
	var/result = FALSE
	for (var/obj/item/integrated_circuit/component in assembly_components)
		if (component.attackby_react(tool, user, user.a_intent))
			result = TRUE
	if (result)
		return TRUE

	return ..()


/obj/item/device/electronic_assembly/attack_self(mob/user)
	interact(user)

/obj/item/device/electronic_assembly/bullet_act(obj/item/projectile/P)
	if(istype(P,/obj/item/projectile/beam))
		playsound(loc, SOUNDS_LASER_METAL, 100, 1)
	else if(istype(P,/obj/item/projectile/bullet))
		playsound(loc, SOUNDS_BULLET_METAL, 100, 1)
	..()

/obj/item/device/electronic_assembly/emp_act(severity)
	for(var/I in src)
		var/atom/movable/AM = I
		AM.emp_act(severity)
	. = ..()

// Returns true if power was successfully drawn.
/obj/item/device/electronic_assembly/proc/draw_power(amount)
	if(battery && battery.use(amount * CELLRATE))
		return TRUE
	return FALSE

// Ditto for giving.
/obj/item/device/electronic_assembly/proc/give_power(amount)
	if(battery && battery.give(amount * CELLRATE))
		return TRUE
	return FALSE


// Returns the object that is supposed to be used in attack messages, location checks, etc.
// Override in children for special behavior.
/obj/item/device/electronic_assembly/proc/get_object()
	return src

/obj/item/device/electronic_assembly/attack_hand(mob/user)
	if(anchored)
		attack_self(user)
		return
	..()

/obj/item/device/electronic_assembly/default //The /default electronic_assemblys are to allow the introduction of the new naming scheme without breaking old saves.
  name = "type-a electronic assembly"

/obj/item/device/electronic_assembly/calc
	name = "type-b electronic assembly"
	icon_state = "setup_small_calc"
	desc = "It's a case used for assembling small electronics. This one resembles a pocket calculator."

/obj/item/device/electronic_assembly/clam
	name = "type-c electronic assembly"
	icon_state = "setup_small_clam"
	desc = "It's a case used for assembling small electronics. This one has a clamshell design."

/obj/item/device/electronic_assembly/simple
	name = "type-d electronic assembly"
	icon_state = "setup_small_simple"
	desc = "It's a case used for assembling small electronics. This one has a simple design."

/obj/item/device/electronic_assembly/hook
	name = "type-e electronic assembly"
	icon_state = "setup_small_hook"
	desc = "It's a case used for assembling small electronics. This one looks like it has a belt clip."
	slot_flags = SLOT_BELT

/obj/item/device/electronic_assembly/pda
	name = "type-f electronic assembly"
	icon_state = "setup_small_pda"
	desc = "It's a case used for assembling small electronics. This one resembles a PDA."
	slot_flags = SLOT_BELT | SLOT_ID

/obj/item/device/electronic_assembly/augment
	name = "augment electronic assembly"
	icon_state = "setup_augment"
	desc = "It's a case used for assembling small electronics. This one is designed to go inside a cybernetic augment."
	circuit_flags = IC_FLAG_CAN_FIRE

/obj/item/device/electronic_assembly/medium
	name = "electronic mechanism"
	icon_state = "setup_medium"
	desc = "It's a case used for assembling electronics."
	w_class = ITEM_SIZE_NORMAL
	max_components = IC_MAX_SIZE_BASE * 2
	max_complexity = IC_COMPLEXITY_BASE * 2
	health_max = 45

/obj/item/device/electronic_assembly/medium/default
	name = "type-a electronic mechanism"

/obj/item/device/electronic_assembly/medium/box
	name = "type-b electronic mechanism"
	icon_state = "setup_medium_box"
	desc = "It's a case used for assembling electronics. This one has a boxy design."

/obj/item/device/electronic_assembly/medium/clam
	name = "type-c electronic mechanism"
	icon_state = "setup_medium_clam"
	desc = "It's a case used for assembling electronics. This one has a clamshell design."

/obj/item/device/electronic_assembly/medium/medical
	name = "type-d electronic mechanism"
	icon_state = "setup_medium_med"
	desc = "It's a case used for assembling electronics. This one resembles some type of medical apparatus."

/obj/item/device/electronic_assembly/medium/gun
	name = "type-e electronic mechanism"
	icon_state = "setup_medium_gun"
	item_state = "circuitgun"
	desc = "It's a case used for assembling electronics. This one resembles a gun, or some type of tool, if you're feeling optimistic. It can fire guns and throw items while the user is holding it."
	item_icons = list(
		icon_l_hand = 'icons/mob/onmob/items/lefthand_guns.dmi',
		icon_r_hand = 'icons/mob/onmob/items/righthand_guns.dmi'
		)
	circuit_flags = IC_FLAG_CAN_FIRE | IC_FLAG_ANCHORABLE

/obj/item/device/electronic_assembly/medium/radio
	name = "type-f electronic mechanism"
	icon_state = "setup_medium_radio"
	desc = "It's a case used for assembling electronics. This one resembles an old radio."

/obj/item/device/electronic_assembly/large
	name = "electronic machine"
	icon_state = "setup_large"
	desc = "It's a case used for assembling large electronics."
	w_class = ITEM_SIZE_LARGE
	max_components = IC_MAX_SIZE_BASE * 4
	max_complexity = IC_COMPLEXITY_BASE * 4
	randpixel = 0
	health_max = 50

/obj/item/device/electronic_assembly/large/default
	name = "type-a electronic machine"

/obj/item/device/electronic_assembly/large/scope
	name = "type-b electronic machine"
	icon_state = "setup_large_scope"
	desc = "It's a case used for assembling large electronics. This one resembles an oscilloscope."

/obj/item/device/electronic_assembly/large/terminal
	name = "type-c electronic machine"
	icon_state = "setup_large_terminal"
	desc = "It's a case used for assembling large electronics. This one resembles a computer terminal."

/obj/item/device/electronic_assembly/large/arm
	name = "type-d electronic machine"
	icon_state = "setup_large_arm"
	desc = "It's a case used for assembling large electronics. This one resembles a robotic arm."

/obj/item/device/electronic_assembly/large/tall
	name = "type-e electronic machine"
	icon_state = "setup_large_tall"
	desc = "It's a case used for assembling large electronics. This one has a tall design."

/obj/item/device/electronic_assembly/large/industrial
	name = "type-f electronic machine"
	icon_state = "setup_large_industrial"
	desc = "It's a case used for assembling large electronics. This one resembles some kind of industrial machinery."

/obj/item/device/electronic_assembly/drone
	name = "electronic drone"
	icon_state = "setup_drone"
	desc = "It's a case used for assembling mobile electronics."
	w_class = ITEM_SIZE_LARGE
	max_components = IC_MAX_SIZE_BASE * 3
	max_complexity = IC_COMPLEXITY_BASE * 3
	allowed_circuit_action_flags = IC_ACTION_MOVEMENT | IC_ACTION_COMBAT | IC_ACTION_LONG_RANGE
	circuit_flags = 0
	randpixel = 0
	adrone = TRUE
	health_max = 60

/obj/item/device/electronic_assembly/drone/can_move()
	return TRUE

/obj/item/device/electronic_assembly/drone/default
	name = "type-a electronic drone"

/obj/item/device/electronic_assembly/drone/arms
	name = "type-b electronic drone"
	icon_state = "setup_drone_arms"
	desc = "It's a case used for assembling mobile electronics. This one is armed and dangerous."
	health_max = 70

/obj/item/device/electronic_assembly/drone/secbot
	name = "type-c electronic drone"
	icon_state = "setup_drone_secbot"
	desc = "It's a case used for assembling mobile electronics. This one resembles a Securitron."
	health_max = 70

/obj/item/device/electronic_assembly/drone/medbot
	name = "type-d electronic drone"
	icon_state = "setup_drone_medbot"
	desc = "It's a case used for assembling mobile electronics. This one resembles a Medibot."
	health_max = 50

/obj/item/device/electronic_assembly/drone/genbot
	name = "type-e electronic drone"
	icon_state = "setup_drone_genbot"
	desc = "It's a case used for assembling mobile electronics. This one has a generic bot design."

/obj/item/device/electronic_assembly/drone/android
	name = "type-f electronic drone"
	icon_state = "setup_drone_android"
	desc = "It's a huge, bipedal case used for assembling hominid-esque mobile electronics and effigies."
	w_class = ITEM_SIZE_HUGE
	max_components = IC_MAX_SIZE_BASE * 5
	max_complexity = IC_COMPLEXITY_BASE * 5
	health_max = 100

/obj/item/device/electronic_assembly/wallmount
	name = "wall-mounted electronic assembly"
	icon_state = "setup_wallmount_medium"
	desc = "It's a case used for assembling electronics. It has a magnetized backing to allow it to stick to walls, but you'll still need to wrench the anchoring bolts in place to keep it on."
	w_class = ITEM_SIZE_NORMAL
	max_components = IC_MAX_SIZE_BASE * 2
	max_complexity = IC_COMPLEXITY_BASE * 2
	health_max = 40

/obj/item/device/electronic_assembly/wallmount/use_after(atom/target, mob/living/user, click_parameters)
	if(isturf(target) && target.density)
		mount_assembly(target,user)
		return TRUE

/obj/item/device/electronic_assembly/wallmount/heavy
	name = "heavy wall-mounted electronic assembly"
	icon_state = "setup_wallmount_large"
	desc = "It's a case used for assembling large electronics. It has a magnetized backing to allow it to stick to walls, but you'll still need to wrench the anchoring bolts in place to keep it on."
	w_class = ITEM_SIZE_LARGE
	max_components = IC_MAX_SIZE_BASE * 4
	max_complexity = IC_COMPLEXITY_BASE * 4
	health_max = 80

/obj/item/device/electronic_assembly/wallmount/light
	name = "light wall-mounted electronic assembly"
	icon_state = "setup_wallmount_small"
	desc = "It's a case used for assembling small electronics. It has a magnetized backing to allow it to stick to walls, but you'll still need to wrench the anchoring bolts in place to keep it on."
	w_class = ITEM_SIZE_SMALL
	max_components = IC_MAX_SIZE_BASE
	max_complexity = IC_COMPLEXITY_BASE

/obj/item/device/electronic_assembly/pickup()
	ClearTransform()

/obj/item/device/electronic_assembly/wallmount/proc/mount_assembly(turf/on_wall, mob/user) //Yeah, this is admittedly just an abridged and kitbashed version of the wallframe attach procs.
	var/ndir = get_dir(on_wall, user)
	if(!(ndir in GLOB.cardinal))
		return
	var/turf/T = get_turf(user)
	if(T.density)
		to_chat(user, SPAN_DANGER("You cannot place \the [src] on this spot!"))
		return
	var/wall_item = get_wall_item(T, ndir)
	if(wall_item)
		to_chat(user, SPAN_DANGER("There's already \a [wall_item] on this wall!"))
		return
	playsound(loc, 'sound/machines/click.ogg', 75, 1)
	user.visible_message("[user.name] attaches [src] to the wall.",
		SPAN_NOTICE("You attach [src] to the wall."),
		SPAN_CLASS("italics", "You hear clicking."))
	if(user.unEquip(src,T))
		var/rotation = 0
		switch(ndir)
			if(NORTH)
				rotation = 180
				pixel_y = -32
				pixel_x = 0
			if(SOUTH)
				pixel_y = 21
				pixel_x = 0
			if(EAST)
				rotation = 90
				pixel_x = -27
				pixel_y = 0
			if(WEST)
				rotation = 270
				pixel_x = 27
				pixel_y = 0
		SetTransform(rotation = rotation)

#undef IC_MAX_SIZE_BASE
#undef IC_COMPLEXITY_BASE
