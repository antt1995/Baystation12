/obj/item
	name = "item"
	icon = 'icons/obj/unused.dmi'
	w_class = ITEM_SIZE_NORMAL
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	blocks_emissive = EMISSIVE_BLOCK_GENERIC

	///BYOND sometimes doesn't add an 'es' to make a word plural when it should; pluralname is a workaround. Only use if it doesn't work traditionally. For example match becomes matchs without this.
	var/pluralname = null

	///This saves our blood splatter overlay, which will be processed not to go over the edges of the sprite
	var/image/blood_overlay = null

	var/randpixel = 6
	var/r_speed = 1.0
	var/burn_point = null
	var/burning = null
	var/hitsound = "swing_hit"
	var/slot_flags = 0		//This is used to determine on which slots an item can fit.
	var/no_attack_log = FALSE			//If it's an item we don't want to log attack_logs with, set this to 1
	pass_flags = PASS_FLAG_TABLE
//	causeerrorheresoifixthis
	var/obj/item/master = null
	var/list/origin_tech = null	//Used by R&D to determine what research bonuses it grants.
	///Used in use_weapon() to say how something was attacked "[x] has been [z.attack_verb] by [y] with [z]"
	var/list/attack_verb = list("attacked")
	var/lock_picking_level = 0 //used to determine whether something can pick a lock, and how well.
	var/force = 0
	var/attack_cooldown = DEFAULT_WEAPON_COOLDOWN
	var/melee_accuracy_bonus = 0
	/// Used to determine how fast an item completes a certain action. Lower values are faster.
	var/toolspeed = 1

	var/heat_protection = 0 //flags which determine which body parts are protected from heat. Use the HEAD, UPPER_TORSO, LOWER_TORSO, etc. flags. See setup.dm
	var/cold_protection = 0 //flags which determine which body parts are protected from cold. Use the HEAD, UPPER_TORSO, LOWER_TORSO, etc. flags. See setup.dm
	var/max_heat_protection_temperature //Set this variable to determine up to which temperature (IN KELVIN) the item protects against heat damage. Keep at null to disable protection. Only protects areas set by heat_protection flags
	var/min_cold_protection_temperature //Set this variable to determine down to which temperature (IN KELVIN) the item protects against cold damage. 0 is NOT an acceptable number due to if(varname) tests!! Keep at null to disable protection. Only protects areas set by cold_protection flags
	var/max_pressure_protection // Set this variable if the item protects its wearer against high pressures below an upper bound. Keep at null to disable protection.
	var/min_pressure_protection // Set this variable if the item protects its wearer against low pressures above a lower bound. Keep at null to disable protection. 0 represents protection against hard vacuum.

	var/datum/action/item_action/action = null
	var/action_button_name //It is also the text which gets displayed on the action button. If not set it defaults to 'Use [name]'. If it's not set, there'll be no button.
	var/default_action_type = /datum/action/item_action // Specify the default type and behavior of the action button for this atom.

	/**
	* This flag is used to determine when items in someone's inventory cover others. IE helmets making it so you can't see glasses, etc.
	*
	* It should be used purely for appearance. For gameplay effects caused by items covering body parts, use body_parts_covered.
	*/
	var/flags_inv = 0
	///See items_clothing.dm for appropriate bit flags
	var/body_parts_covered = FLAGS_OFF

	var/item_flags = 0 //Miscellaneous flags pertaining to equippable objects.

	//var/heat_transfer_coefficient = 1 //0 prevents all transfers, 1 is invisible
	var/gas_transfer_coefficient = 1 // for leaking gas from turf to mask and vice-versa (for masks right now, but at some point, i'd like to include space helmets)
	var/permeability_coefficient = 1 // for chemicals/diseases
	var/siemens_coefficient = 1 // for electrical admittance/conductance (electrocution checks and shit)
	var/slowdown_general = 0 // How much clothing is slowing you down. Negative values speeds you up. This is a genera##l slowdown, no matter equipment slot.
	var/slowdown_per_slot[slot_last] // How much clothing is slowing you down. This is an associative list: item slot - slowdown
	var/slowdown_accessory // How much an accessory will slow you down when attached to a worn article of clothing.
	var/canremove = 1 //Mostly for Ninja code at this point but basically will not allow the item to be removed if set to 0. /N
	var/armor_type = /datum/extension/armor
	var/list/armor
	var/armor_degradation_speed //How fast armor will degrade, multiplier to blocked damage to get armor damage value.
	var/list/allowed = null //suit storage stuff.
	var/obj/item/device/uplink/hidden_uplink = null // All items can have an uplink hidden inside, just remember to add the triggers.
	var/zoomdevicename = null //name used for message when binoculars/scope is used
	var/zoom = 0 //1 if item is actively being used to zoom. For scoped guns and binoculars.

	var/base_parry_chance	// Will allow weapon to parry melee attacks if non-zero
	var/icon_override = null  //Used to override hardcoded clothing dmis in human clothing proc.

	var/use_alt_layer = FALSE // Use the slot's alternative layer when rendering on a mob

	//** These specify item/icon overrides for _slots_

	var/list/item_state_slots = list(slot_wear_id_str = "id") //overrides the default item_state for particular slots.

	// Used to specify the icon file to be used when the item is worn. If not set the default icon for that slot will be used.
	// If icon_override or sprite_sheets are set they will take precendence over this, assuming they apply to the slot in question.
	// Only slot_l_hand/slot_r_hand are implemented at the moment. Others to be implemented as needed.
	var/list/item_icons

	//** These specify item/icon overrides for _species_

	/* Species-specific sprites, concept stolen from Paradise//vg/.
	ex:
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/lizard/are/bad'
		)
	If index term exists and icon_override is not set, this sprite sheet will be used.
	*/
	var/list/sprite_sheets = list()

	// Species-specific sprite sheets for inventory sprites
	// Works similarly to worn sprite_sheets, except the alternate sprites are used when the clothing/refit_for_species() proc is called.
	var/list/sprite_sheets_obj = list()

	var/attack_ignore_harm_check = FALSE


/obj/item/Initialize()
	. = ..()
	if(randpixel && (!pixel_x && !pixel_y) && isturf(loc))
		pixel_x = rand(-randpixel, randpixel)
		pixel_y = rand(-randpixel, randpixel)
	if(islist(armor))
		for(var/type in armor)
			if(armor[type]) // Don't set it if it gives no armor anyway, which is many items.
				set_extension(src, armor_type, armor, armor_degradation_speed)
				break
	if (item_flags & ITEM_FLAG_IS_CHAMELEON_ITEM)
		SetupChameleonExtension(CHAMELEON_FLEXIBLE_OPTIONS_EXTENSION, FALSE, TRUE)

/obj/item/Destroy()
	QDEL_NULL(hidden_uplink)
	if(ismob(loc))
		var/mob/m = loc
		m.drop_from_inventory(src)
	var/obj/item/storage/storage = loc
	if(istype(storage))
		// some ui cleanup needs to be done
		storage.on_item_pre_deletion(src) // must be done before deletion
		. = ..()
		storage.on_item_post_deletion(src) // must be done after deletion
	else
		return ..()

//Checks if the item is being held by a mob, and if so, updates the held icons
/obj/item/proc/update_twohanding()
	update_held_icon()

/obj/item/proc/update_held_icon()
	if(ismob(src.loc))
		var/mob/M = src.loc
		if(M.l_hand == src)
			M.update_inv_l_hand()
		else if(M.r_hand == src)
			M.update_inv_r_hand()

/obj/item/proc/is_held_twohanded(mob/living/M)

	if(istype(loc, /obj/item/rig_module) || istype(loc, /obj/item/rig))
		return TRUE

	var/check_hand
	if(M.l_hand == src && !M.r_hand)
		check_hand = BP_R_HAND //item in left hand, check right hand
	else if(M.r_hand == src && !M.l_hand)
		check_hand = BP_L_HAND //item in right hand, check left hand
	else
		return FALSE

	//would check is_broken() and is_malfunctioning() here too but is_malfunctioning()
	//is probabilistic so we can't do that and it would be unfair to just check one.
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/hand = H.organs_by_name[check_hand]
		if(istype(hand) && hand.is_usable())
			return TRUE
	return FALSE


/obj/item/update_icon()
	..()
	update_twohanding()


/obj/item/ex_act(severity)
	..()
	if (get_max_health())
		return
	switch(severity)
		if(EX_ACT_DEVASTATING)
			qdel(src)
		if(EX_ACT_HEAVY)
			if (prob(50))
				qdel(src)
		if(EX_ACT_LIGHT)
			if (prob(5))
				qdel(src)

/obj/item/examine(mob/user, distance, is_adjacent)
	var/size
	switch(src.w_class)
		if(ITEM_SIZE_TINY)
			size = "tiny"
		if(ITEM_SIZE_SMALL)
			size = "small"
		if(ITEM_SIZE_NORMAL)
			size = "normal-sized"
		if(ITEM_SIZE_LARGE)
			size = "large"
		if(ITEM_SIZE_HUGE)
			size = "bulky"
		if(ITEM_SIZE_HUGE + 1 to INFINITY)
			size = "huge"
	var/desc_comp = "" //For "description composite"
	desc_comp += "It is a [size] item."

	if(hasHUD(user, HUD_SCIENCE)) //Mob has a research scanner active.
		desc_comp += "<BR>*--------* <BR>"

		if(origin_tech)
			desc_comp += "[SPAN_NOTICE("Testing potentials:")]<BR>"
			//var/list/techlvls = params2list(origin_tech)
			for(var/T in origin_tech)
				desc_comp += "Tech: Level [origin_tech[T]] [CallTechName(T)] <BR>"
		else
			desc_comp += "No tech origins detected.<BR>"

		if(LAZYLEN(matter))
			desc_comp += "[SPAN_NOTICE("Extractable materials:")]<BR>"
			for(var/mat in matter)
				desc_comp += "[SSmaterials.get_material_by_name(mat)]<BR>"
		else
			desc_comp += "[SPAN_DANGER("No extractable materials detected.")]<BR>"
		desc_comp += "*--------*"

	return ..(user, distance, is_adjacent, "", desc_comp)

/obj/item/attack_hand(mob/user as mob)
	if (!user) return
	if (anchored)
		return ..()
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/temp = H.organs_by_name[BP_R_HAND]
		if (user.hand)
			temp = H.organs_by_name[BP_L_HAND]
		if((MUTATION_FERAL in user.mutations) && (MUTATION_CLUMSY in user.mutations))
			to_chat(user, SPAN_WARNING("You don't have the dexterity to pick up \the [src]!"))
			return TRUE
		if(temp && !temp.is_usable())
			to_chat(user, SPAN_NOTICE("You try to move your [temp.name], but cannot!"))
			return TRUE
		if(!temp)
			to_chat(user, SPAN_NOTICE("You try to use your hand, but realize it is no longer attached!"))
			return TRUE
		var/obj/item/clothing/gloves/gloves = user.get_equipped_item(slot_gloves)
		if(istype(gloves) && gloves.blood_transfer_amount >= 1)
			var/taken = rand(1, gloves.blood_transfer_amount)
			gloves.blood_transfer_amount -= taken
			add_blood_custom(gloves.blood_color, taken, gloves.blood_DNA)
		else if(H.bloody_hands >= 1)
			var/taken = rand(1, H.bloody_hands)
			H.bloody_hands -= taken
			add_blood_custom(H.hand_blood_color, taken, H.hands_blood_DNA)

	var/old_loc = loc

	pickup(user)
	if (istype(loc, /obj/item/storage))
		var/obj/item/storage/S = loc
		S.remove_from_storage(src)

	if(!QDELETED(throwing))
		throwing.finalize(hit=TRUE)

	if (loc == user)
		if(!user.unEquip(src))
			return
	else
		if(isliving(loc))
			return

	if(QDELETED(src))
		return // Unequipping changes our state, so must check here.

	if(user.put_in_active_hand(src))
		if (isturf(old_loc))
			var/obj/temporary/item_pickup_ghost/ghost = new(old_loc, src)
			ghost.animate_towards(user)
		if(randpixel)
			pixel_x = rand(-randpixel, randpixel)
			pixel_y = rand(-randpixel/2, randpixel/2)
			pixel_z = 0
		else if(randpixel == 0)
			pixel_x = 0
			pixel_y = 0

/obj/item/attack_ai(mob/user as mob)
	if (istype(src.loc, /obj/item/robot_module))
		//If the item is part of a cyborg module, equip it
		if(!isrobot(user))
			return
		var/mob/living/silicon/robot/R = user
		R.activate_module(src)
		R.hud_used.update_robot_modules_display()


/obj/item/use_tool(obj/item/item, mob/living/user, list/click_params)
	if (SSfabrication.try_craft_with(src, item, user))
		return TRUE
	if (istype(item, /obj/item/storage) && isturf(loc))
		var/obj/item/storage/storage = item
		if (!storage.allow_quick_gather)
			return ..()
		if (!storage.quick_gather_single)
			storage.gather_all(loc, user)
		else if (storage.can_be_inserted(src, user))
			storage.handle_item_insertion(src)
		return TRUE
	return ..()

/obj/item/can_embed()
	if (!canremove)
		return FALSE
	return ..()

/obj/item/proc/talk_into(mob/M as mob, text)
	return

/obj/item/proc/moved(mob/user as mob, old_loc as turf)
	return


/// Called whenever an item is removed from a slot, container, or anything else.
/obj/item/proc/dropped(mob/user as mob)
	if(randpixel)
		pixel_z = randpixel //an idea borrowed from some of the older pixel_y randomizations. Intended to make items appear to drop at a character
	update_twohanding()
	if(user)
		for (var/obj/item/item as anything in user.GetAllHeld())
			item.update_twohanding()
	GLOB.mob_unequipped_event.raise_event(user, src)
	GLOB.item_unequipped_event.raise_event(src, user)

	if(user && (z_flags & ZMM_MANGLE_PLANES))
		addtimer(new Callback(user, TYPE_PROC_REF(/mob, check_emissive_equipment)), 0, TIMER_UNIQUE)


// called just as an item is picked up (loc is not yet changed)
/obj/item/proc/pickup(mob/user)
	return

// called when this item is removed from a storage item, which is passed on as S. The loc variable is already set to the new destination before this is called.
/obj/item/proc/on_exit_storage(obj/item/storage/S as obj)
	return

// called when this item is added into a storage item, which is passed on as S. The loc variable is already set to the storage item.
/obj/item/proc/on_enter_storage(obj/item/storage/S as obj)
	return

// called when "found" in pockets and storage items. Returns 1 if the search should end.
/obj/item/proc/on_found(mob/finder as mob)
	return


/*
called after an item is placed in an equipment slot
user is mob that equipped it
slot uses the slot_X defines found in setup.dm
for items that can be placed in multiple slots
note this isn't called during the initial dressing of a player
*/
/obj/item/proc/equipped(mob/user, slot)
	hud_layerise()
	if(user.client)	user.client.screen |= src
	if(user.pulling == src)
		user.stop_pulling()
	var/mob/M = loc
	if(!istype(M))
		return
	for (var/obj/item/item as anything in M.GetAllHeld())
		item.update_twohanding()
	GLOB.mob_equipped_event.raise_event(user, src, slot)
	GLOB.item_equipped_event.raise_event(src, user, slot)

	if(user && (z_flags & ZMM_MANGLE_PLANES))
		addtimer(new Callback(user, TYPE_PROC_REF(/mob, check_emissive_equipment)), 0, TIMER_UNIQUE)


/obj/item/proc/equipped_robot(mob/user)
	return

//Defines which slots correspond to which slot flags
var/global/list/slot_flags_enumeration = list(
	"[slot_wear_mask]" = SLOT_MASK,
	"[slot_back]" = SLOT_BACK,
	"[slot_wear_suit]" = SLOT_OCLOTHING,
	"[slot_gloves]" = SLOT_GLOVES,
	"[slot_shoes]" = SLOT_FEET,
	"[slot_belt]" = SLOT_BELT,
	"[slot_glasses]" = SLOT_EYES,
	"[slot_head]" = SLOT_HEAD,
	"[slot_l_ear]" = SLOT_EARS|SLOT_TWOEARS,
	"[slot_r_ear]" = SLOT_EARS|SLOT_TWOEARS,
	"[slot_w_uniform]" = SLOT_ICLOTHING,
	"[slot_wear_id]" = SLOT_ID,
	"[slot_tie]" = SLOT_TIE,
	)

//the mob M is attempting to equip this item into the slot passed through as 'slot'. Return 1 if it can do this and 0 if it can't.
//If you are making custom procs but would like to retain partial or complete functionality of this one, include a 'return ..()' to where you want this to happen.
//Set disable_warning to 1 if you wish it to not give you outputs.
//Should probably move the bulk of this into mob code some time, as most of it is related to the definition of slots and not item-specific
//set force to ignore blocking overwear and occupied slots
/obj/item/proc/mob_can_equip(M as mob, slot, disable_warning = FALSE, force = FALSE)
	if(!slot) return 0
	if(!M) return 0

	if(!ishuman(M)) return 0

	var/mob/living/carbon/human/H = M
	var/list/mob_equip = list()
	if(H.species.hud && H.species.hud.equip_slots)
		mob_equip = H.species.hud.equip_slots

	if(H.species && !(slot in mob_equip))
		return 0

	//First check if the item can be equipped to the desired slot.
	if("[slot]" in slot_flags_enumeration)
		var/req_flags = slot_flags_enumeration["[slot]"]
		if(!(req_flags & slot_flags))
			return 0

	if(!force)
		//Next check that the slot is free
		if(H.get_equipped_item(slot))
			return 0

		//Next check if the slot is accessible.
		var/mob/_user = disable_warning? null : H
		if(!H.slot_is_accessible(slot, src, _user))
			return 0


	if (!force && istype(src, /obj/item/clothing))
		var/obj/item/clothing/SC = src
		var/bulky = SC.get_bulky_coverage() //disallow bulky things from covering one another
		if (bulky)
			for (var/obj/item/clothing/C in H.get_equipped_items())
				if (C.get_bulky_coverage() & bulky)
					if (!disable_warning)
						to_chat(H, SPAN_WARNING("\The [SC] is too bulky to wear with \the [C]."))
					return FALSE

	//Lastly, check special rules for the desired slot.
	switch(slot)
		if(slot_l_ear, slot_r_ear)
			var/slot_other_ear = (slot == slot_l_ear)? slot_r_ear : slot_l_ear
			if( (w_class > ITEM_SIZE_TINY) && !(slot_flags & SLOT_EARS) )
				return 0
			if( (slot_flags & SLOT_TWOEARS) && H.get_equipped_item(slot_other_ear) )
				return 0
		if(slot_belt, slot_wear_id)
			if(slot == slot_belt && (item_flags & ITEM_FLAG_IS_BELT))
				return 1
			else if(!H.w_uniform && (slot_w_uniform in mob_equip))
				if(!disable_warning)
					to_chat(H, SPAN_WARNING("You need a jumpsuit before you can attach this [name]."))
				return 0
		if(slot_l_store, slot_r_store)
			if(!H.w_uniform && (slot_w_uniform in mob_equip))
				if(!disable_warning)
					to_chat(H, SPAN_WARNING("You need a jumpsuit before you can attach this [name]."))
				return 0
			if(slot_flags & SLOT_DENYPOCKET)
				return 0
			if( w_class > ITEM_SIZE_SMALL && !(slot_flags & SLOT_POCKET) )
				return 0
			if(get_storage_cost() == ITEM_SIZE_NO_CONTAINER)
				return 0 //pockets act like storage and should respect ITEM_SIZE_NO_CONTAINER. Suit storage might be fine as is
		if(slot_s_store)
			if(!H.wear_suit && (slot_wear_suit in mob_equip))
				if(!disable_warning)
					to_chat(H, SPAN_WARNING("You need a suit before you can attach this [name]."))
				return 0
			if(!H.wear_suit.allowed)
				if(!disable_warning)
					to_chat(usr, SPAN_WARNING("You somehow have a suit with no defined allowed items for suit storage, stop that."))
				return 0
			if( !(istype(src, /obj/item/modular_computer/pda) || istype(src, /obj/item/pen) || is_type_in_list(src, H.wear_suit.allowed)) )
				return 0
		if(slot_handcuffed)
			if(!istype(src, /obj/item/handcuffs))
				return 0
		if(slot_in_backpack) //used entirely for equipping spawned mobs or at round start
			var/allow = 0
			if(H.back && istype(H.back, /obj/item/storage/backpack))
				var/obj/item/storage/backpack/B = H.back
				if(B.can_be_inserted(src,M,1))
					allow = 1
			if(!allow)
				return 0
		if(slot_tie)
			if((!H.w_uniform && (slot_w_uniform in mob_equip)) && (!H.wear_suit && (slot_wear_suit in mob_equip)))
				if(!disable_warning)
					to_chat(H, SPAN_WARNING("You need something you can attach \the [src] to."))
				return 0
			if(H.w_uniform && (slot_w_uniform in mob_equip))
				var/obj/item/clothing/under/uniform = H.w_uniform
				if(uniform && !uniform.can_attach_accessory(src, disable_warning ? null : H))
					return 0
				else return 1
			if(H.wear_suit && (slot_wear_suit in mob_equip))
				var/obj/item/clothing/suit/suit = H.wear_suit
				if(suit && !suit.can_attach_accessory(src, disable_warning ? null : H))
					return 0

	return 1

/obj/item/proc/mob_can_unequip(mob/M, slot, disable_warning = 0)
	if(!slot) return 0
	if(!M) return 0

	if(!canremove)
		return 0
	if(!M.slot_is_accessible(slot, src, disable_warning? null : M))
		return 0
	return 1

/obj/item/proc/can_be_dropped_by_client(mob/M)
	return M.canUnEquip(src)

/obj/item/verb/verb_pickup()
	set src in oview(1)
	set category = "Object"
	set name = "Pick up"

	if(!(usr)) //BS12 EDIT
		return
	if(!CanPhysicallyInteract(usr))
		return
	if((!istype(usr, /mob/living/carbon)) || (istype(usr, /mob/living/carbon/brain)))//Is humanoid, and is not a brain
		to_chat(usr, SPAN_WARNING("You can't pick things up!"))
		return
	if( usr.stat || usr.restrained() )//Is not asleep/dead and is not restrained
		to_chat(usr, SPAN_WARNING("You can't pick things up!"))
		return
	if(src.anchored) //Object isn't anchored
		to_chat(usr, SPAN_WARNING("You can't pick that up!"))
		return
	if (!usr.HasFreeHand())
		to_chat(usr, SPAN_WARNING("Your hands are full."))
		return
	if(!isturf(loc)) //Object is on a turf
		to_chat(usr, SPAN_WARNING("You can't pick that up!"))
		return
	//All checks are done, time to pick it up!
	usr.UnarmedAttack(src)
	return


//This proc is executed when someone clicks the on-screen UI button. To make the UI button show, set the 'icon_action_button' to the icon_state of the image of the button in screen1_action.dmi
//The default action is attack_self().
//Checks before we get to here are: mob is alive, mob is not restrained, paralyzed, asleep, resting, laying, item is on the mob.
/obj/item/proc/ui_action_click(mob/living/user)
	attack_self(usr)

//RETURN VALUES
//handle_shield should return a positive value to indicate that the attack is blocked and should be prevented.
//If a negative value is returned, it should be treated as a special return value for bullet_act() and handled appropriately.
//For non-projectile attacks this usually means the attack is blocked.
//Otherwise should return 0 to indicate that the attack is not affected in any way.
/obj/item/proc/handle_shield(mob/user, damage, atom/damage_source = null, mob/attacker = null, def_zone = null, attack_text = "the attack")
	var/parry_chance = get_parry_chance(user, attacker)
	if(parry_chance)
		if(default_parry_check(user, attacker, damage_source) && prob(parry_chance))
			user.visible_message(SPAN_DANGER("\The [user] parries [attack_text] with \the [src]!"))
			admin_attack_log(attacker, user, "Attempted to attack with \a [damage_source] but was parried", "Was targeted with \a [damage_source] but parried the attack", "attmpted to use \a [damage_source] to attack but was parried by")
			playsound(user.loc, 'sound/weapons/punchmiss.ogg', 50, 1)
			on_parry(damage_source)
			return 1
	return 0

/obj/item/proc/on_parry(damage_source)
	return

/obj/item/proc/get_parry_chance(mob/user, mob/attacker)
	. = base_parry_chance
	if (!istype(user) || !istype(attacker))
		return
	if (user.a_intent == I_HELP)
		. = 0
	if (.)
		. += (user.get_skill_difference(SKILL_COMBAT, attacker) * 5)
		. = clamp(., 0, 75)

/obj/item/proc/on_disarm_attempt(mob/target, mob/living/attacker)
	if(force < 1)
		return 0
	if(!istype(attacker))
		return 0
	attacker.apply_damage(force, damtype, attacker.hand ? BP_L_HAND : BP_R_HAND, used_weapon = src)
	var/datum/pronouns/pronouns = attacker.choose_from_pronouns()
	attacker.visible_message(SPAN_DANGER("[attacker] hurts [pronouns.his] hand on \the [src]!"))
	admin_attack_log(attacker, target, "Attempted to disarm but was blocked", "Was targeted with a disarm but blocked the attack", "attmpted to disarm but was blocked by")
	playsound(target, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
	playsound(target, hitsound, 50, 1, -1)
	return 1

/obj/item/proc/get_loc_turf()
	var/atom/L = loc
	while(L && !isturf(L))
		L = L.loc
	return loc

/obj/item/proc/eyestab(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if (user.a_intent == I_HELP)
		return FALSE

	var/mob/living/carbon/human/H = M
	if (!istype(H))
		return FALSE

	if (!M.has_eyes())
		to_chat(user, SPAN_WARNING("You cannot locate any eyes on [M]!"))
		return TRUE

	admin_attack_log(user, M, "Attacked using \a [src]", "Was attacked with \a [src]", "used \a [src] to attack")
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	user.do_attack_animation(M) //Addition of fingerprints is handled in post_use_item, since this is called by use_weapon. By returning TRUE is goes to post_use item.
	playsound(loc, hitsound, 50, TRUE, -1)

	for (var/obj/item/protection in list(H.head, H.wear_mask, H.glasses)) //Order in list is important, it will check head first. If protective hat covers masks/eyes; they can't be destroyed.
		var/breakcover =  force * user.get_skill_value(SKILL_COMBAT) //Make it impossible to break glasses with screwdrivers/pens (force 2-3); no matter how skilled.
		if (protection != H.head && (protection.body_parts_covered & EYES) && breakcover > 20) //Only make eye/mask items destroyable; else riot helmets can be destroyed with eye stabbing.
			H.visible_message(SPAN_DANGER("\The [M]'s [protection.name] has been damaged with by \the [src] by \the [user]."))
			CLEAR_FLAGS(protection.body_parts_covered, EYES)
			protection.name = "damaged [protection.name]"
			protection.desc += "<br>[SPAN_NOTICE("It looks damaged.")]"
			H.unEquip(protection, H.loc)
			return TRUE
		if (protection && (protection.body_parts_covered & EYES))
			M.visible_message(SPAN_DANGER("\The [user] lunges at \the [H]'s eyes with \the [src], but the attack was deflected by \the [protection]."))
			return TRUE

	var/obj/item/organ/internal/eyes/eyes = H.internal_organs_by_name[BP_EYES]
	if (H != user)
		for (var/mob/O in (viewers(M) - user - M))
			O.show_message(SPAN_DANGER("[M] has been stabbed in the eye with [src] by [user]."), 1)
		to_chat(M, SPAN_DANGER("[user] stabs you in the eye with [src]!"))
		to_chat(user, SPAN_DANGER("You stab [M] in the eye with [src]!"))
	else
		user.visible_message( \
			SPAN_DANGER("[user] has stabbed themself with [src]!"), \
			SPAN_DANGER("You stab yourself in the eyes with [src]!") \
		)

	eyes.damage += rand(3,4)
	if (eyes.damage >= eyes.min_bruised_damage)
		if (M.stat != 2)
			if (!BP_IS_ROBOTIC(eyes)) //robot eyes bleeding might be a bit silly
				to_chat(M, SPAN_DANGER("Your eyes start to bleed profusely!"))
		if (prob(50))
			if (M.stat != 2)
				to_chat(M, SPAN_WARNING("You drop what you're holding and clutch at your eyes!"))
				M.unequip_item()
			M.eye_blurry += 10
			M.Paralyse(1)
			M.Weaken(4)
		if (eyes.damage >= eyes.min_broken_damage)
			if (M.stat != 2)
				to_chat(M, SPAN_WARNING("You go blind!"))

		var/obj/item/organ/external/affecting = H.get_organ(eyes.parent_organ)
		affecting.take_external_damage(7)
	else
		M.take_organ_damage(7, 0)

	M.eye_blurry += rand(3,4)
	return TRUE

/obj/item/clean_blood()
	. = ..()
	if(blood_overlay)
		CutOverlays(blood_overlay)
	if(istype(src, /obj/item/clothing/gloves))
		var/obj/item/clothing/gloves/G = src
		G.blood_transfer_amount = 0
	trace_DNA = null

/obj/item/reveal_blood()
	if(was_bloodied && !fluorescent)
		fluorescent = ATOM_FLOURESCENCE_INACTIVE
		blood_color = COLOR_LUMINOL
		blood_overlay.color = COLOR_LUMINOL
		update_icon()

/obj/item/add_blood_custom(source_blood_color = COLOR_BLOOD_HUMAN, amount = 3, list/source_blood_DNA = list())
	if (!..())
		return 0

	if(istype(src, /obj/item/melee/energy))
		return

	//if we haven't made our blood_overlay already
	if( !blood_overlay )
		generate_blood_overlay()

	//apply the blood-splatter overlay if it isn't already in there
	if(blood_overlay.color != blood_color)
		blood_overlay.color = blood_color
		AddOverlays(blood_overlay)

	blood_transfer_amount = max(amount, blood_transfer_amount)

	//if this blood isn't already in the list, add it
	var/added_blood = 0
	for(var/datum/dna/dna in source_blood_DNA)
		if(blood_DNA[dna.unique_enzymes])
			continue //already bloodied with this blood. Cannot add more.
		blood_DNA[dna.unique_enzymes] = dna.b_type
		added_blood = 1
	return added_blood

GLOBAL_LIST_EMPTY(blood_overlay_cache)
#define BLOOD_OVERLAY_CACHE_INDEX "[icon]" + icon_state + blood_color

/obj/item/proc/generate_blood_overlay(force = FALSE)
	if(blood_overlay && !force)
		return
	if(GLOB.blood_overlay_cache[BLOOD_OVERLAY_CACHE_INDEX])
		blood_overlay = GLOB.blood_overlay_cache[BLOOD_OVERLAY_CACHE_INDEX]
		return
	var/icon/I = new /icon(icon, icon_state)
	I.Blend(new /icon('icons/effects/blood.dmi', rgb(255,255,255)),ICON_ADD) //fills the icon_state with white (except where it's transparent)
	I.Blend(new /icon('icons/effects/blood.dmi', "itemblood"),ICON_MULTIPLY) //adds blood and the remaining white areas become transparant
	blood_overlay = image(I)
	blood_overlay.appearance_flags |= NO_CLIENT_COLOR
	GLOB.blood_overlay_cache[BLOOD_OVERLAY_CACHE_INDEX] = blood_overlay

#undef BLOOD_OVERLAY_CACHE_INDEX

/obj/item/proc/showoff(mob/user)
	for (var/mob/M in view(user))
		M.show_message("[user] holds up [src]. <a HREF='byond://?src=\ref[M];lookitem=\ref[src]'>Take a closer look.</a>",1)

/mob/living/carbon/verb/showoff()
	set name = "Show Held Item"
	set category = "Object"

	var/obj/item/I = get_active_hand()
	if(I && I.simulated)
		I.showoff(src)

/*
For zooming with scope or binoculars. This is called from
modules/mob/mob_movement.dm if you move you will be zoomed out
modules/mob/living/carbon/human/life.dm if you die, you will be zoomed out.
*/
//Looking through a scope or binoculars should /not/ improve your periphereal vision. Still, increase viewsize a tiny bit so that sniping isn't as restricted to NSEW
/obj/item/proc/zoom(mob/user, tileoffset = 14,viewsize = 9) //tileoffset is client view offset in the direction the user is facing. viewsize is how far out this thing zooms. 7 is normal view
	if(!user.client)
		return
	if(zoom)
		return

	if(!user.loc?.MayZoom())
		return

	var/devicename = zoomdevicename || name
	var/is_distracted = FALSE
	var/mob/living/carbon/human/H = user

	if(user.incapacitated(INCAPACITATION_DISABLED))
		to_chat(user, SPAN_WARNING("You are unable to focus through the [devicename]."))
		return
	else if(!zoom && istype(H) && H.equipment_tint_total >= TINT_MODERATE)
		to_chat(user, SPAN_WARNING("Your eyewear gets in the way of looking through the [devicename]."))
		return
	if (H) // Humans can zoom through items they wear on their eyes
		is_distracted = !zoom && H.get_active_hand() != src && H.get_equipped_item(slot_glasses) != src
	else
		is_distracted = !zoom && user.get_active_hand() != src
	if(is_distracted)
		to_chat(user, SPAN_WARNING("You are too distracted to look through the [devicename]. Perhaps if it was in your active hand this might work better."))
		return

	var/viewoffset = WORLD_ICON_SIZE * tileoffset
	switch(user.dir)
		if (NORTH)
			user.client.pixel_x = 0
			user.client.pixel_y = viewoffset
		if (SOUTH)
			user.client.pixel_x = 0
			user.client.pixel_y = -viewoffset
		if (EAST)
			user.client.pixel_x = viewoffset
			user.client.pixel_y = 0
		if (WEST)
			user.client.pixel_x = -viewoffset
			user.client.pixel_y = 0

	if(user.hud_used.hud_shown)
		user.toggle_zoom_hud()	// If the user has already limited their HUD this avoids them having a HUD when they zoom in
	if(istype(H))
		H.handle_vision()

	user.client.view = viewsize
	zoom = 1

	GLOB.destroyed_event.register(src, src, PROC_REF(unzoom))
	GLOB.moved_event.register(user, src, PROC_REF(unzoom))
	GLOB.dir_set_event.register(user, src, PROC_REF(unzoom))
	GLOB.item_unequipped_event.register(src, user, TYPE_PROC_REF(/mob/living, unzoom))

	GLOB.stat_set_event.register(user, src, PROC_REF(unzoom))

	user.visible_message("\The [user] peers through [zoomdevicename ? "the [zoomdevicename] of [src]" : "[src]"].")

/mob/living/proc/unzoom(obj/item/I)
	if(I)
		I.unzoom(src)

/obj/item/proc/unzoom(mob/user)
	if(!zoom)
		return
	zoom = 0

	GLOB.destroyed_event.unregister(src, src, PROC_REF(unzoom))
	GLOB.moved_event.unregister(user, src, PROC_REF(unzoom))
	GLOB.dir_set_event.unregister(user, src, PROC_REF(unzoom))
	GLOB.item_unequipped_event.unregister(src, user, TYPE_PROC_REF(/mob/living, unzoom))

	user = user == src ? loc : (user || loc)
	if(!istype(user))
		crash_with("[log_info_line(src)]: Zoom user lost]")
		return

	GLOB.stat_set_event.unregister(user, src, PROC_REF(unzoom))

	if(!user.client)
		return

	user.client.view = world.view
	if(!user.hud_used.hud_shown)
		user.toggle_zoom_hud()

	user.client.pixel_x = 0
	user.client.pixel_y = 0

	var/mob/living/carbon/human/H = user
	if(istype(H))
		H.handle_vision()
	user.visible_message("[zoomdevicename ? "\The [user] looks up from [src]" : "\The [user] lowers [src]"].")

/obj/item/proc/pwr_drain()
	return 0 // Process Kill

/obj/item/proc/use_spritesheet(bodytype, slot, icon_state)
	if(!sprite_sheets || !sprite_sheets[bodytype])
		return 0
	if(slot == slot_r_hand_str || slot == slot_l_hand_str)
		return 0

	if(icon_state in icon_states(sprite_sheets[bodytype]))
		return 1

	return (slot != slot_wear_suit_str && slot != slot_head_str)

/obj/item/proc/get_icon_state(mob/user_mob, slot)
	var/mob_state
	if(item_state_slots && item_state_slots[slot])
		mob_state = item_state_slots[slot]
	else if (item_state)
		mob_state = item_state
	else
		mob_state = icon_state
	return mob_state


/obj/item/proc/get_mob_overlay(mob/user_mob, slot)
	var/bodytype = "Default"
	var/mob/living/carbon/human/user_human
	if(ishuman(user_mob))
		user_human = user_mob
		bodytype = user_human.species.get_bodytype(user_human)

	var/mob_state = get_icon_state(user_mob, slot)

	var/mob_icon
	var/spritesheet = FALSE
	if(icon_override)
		mob_icon = icon_override
		if(slot == 	slot_l_hand_str || slot == slot_l_ear_str)
			mob_state = "[mob_state]_l"
		if(slot == 	slot_r_hand_str || slot == slot_r_ear_str)
			mob_state = "[mob_state]_r"
	else if(use_spritesheet(bodytype, slot, mob_state))
		if(slot == slot_l_ear)
			mob_state = "[mob_state]_l"
		if(slot == slot_r_ear)
			mob_state = "[mob_state]_r"
		spritesheet = TRUE
		mob_icon = sprite_sheets[bodytype]
	else if(item_icons && item_icons[slot])
		mob_icon = item_icons[slot]
	else
		mob_icon = GLOB.default_onmob_icons[slot]

	if(user_human)
		return user_human.species.get_offset_overlay_image(spritesheet, mob_icon, mob_state, color, slot)
	return overlay_image(mob_icon, mob_state, color, RESET_COLOR)

/obj/item/proc/get_examine_line()
	if(blood_color)
		. = SPAN_WARNING("[icon2html(src, viewers(get_turf(src)))] [gender==PLURAL?"some":"a"] [SPAN_COLOR(blood_color, "stained")] [src]")
	else
		. = "[icon2html(src, viewers(get_turf(src)))] \a [src]"
	var/ID = GetIdCard()
	if(ID)
		. += "  <a href='byond://?src=\ref[ID];look_at_id=1'>\[Look at ID\]</a>"
	else
		. += "  <a href='byond://?src=\ref[src];examine=1'>\[?\]</a>"

/obj/item/proc/on_active_hand(mob/M)

/obj/item/is_burnable()
	return simulated

/obj/item/lava_act()
	. = (!throwing) ? ..() : FALSE

/obj/item/proc/has_embedded()
	return

/obj/item/proc/get_pressure_weakness(pressure,zone)
	. = 1
	if(pressure > ONE_ATMOSPHERE)
		if(max_pressure_protection != null)
			if(max_pressure_protection < pressure)
				return min(1, round((pressure - max_pressure_protection) / max_pressure_protection, 0.01))
			else
				return 0
	if(pressure < ONE_ATMOSPHERE)
		if(min_pressure_protection != null)
			if(min_pressure_protection > pressure)
				return min(1, round((min_pressure_protection - pressure) / min_pressure_protection, 0.01))
			else
				return 0

/obj/item/do_simple_ranged_interaction(mob/user)
	if(user)
		attack_self(user)
	return TRUE

/obj/item/proc/inherit_custom_item_data(datum/custom_item/citem)
	. = src
	if(citem.item_name)
		SetName(citem.item_name)
	if(citem.item_desc)
		desc = citem.item_desc
	if(citem.item_icon_state)
		item_state_slots = null
		item_icons = null
		icon = CUSTOM_ITEM_OBJ
		set_icon_state(citem.item_icon_state)
		item_state = null
		icon_override = CUSTOM_ITEM_MOB

/obj/item/proc/attack_message_name()
	return "\a [src]"


/// Optional delay for /mob/living/carbon/human/equip_to_slot_if_possible to do_after before succeeding
/obj/item/var/equip_delay


/// Flags to use for do_after when equip_delay is set
/obj/item/var/equip_delay_flags = DO_DEFAULT | DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS | DO_BAR_OVER_USER


/// Virtual for behavior to do before do_after if equip_delay is set
/obj/item/proc/equip_delay_before(mob/user, slot, equip_flags)
	return


/// Virtual for behavior to do after successful do_after if equip_delay is set
/obj/item/proc/equip_delay_after(mob/user, slot, equip_flags)
	return


/// Proc called when when the item has been equipped. Unlike `equip_delay_*`, this is always called.
/obj/item/proc/post_equip_item(mob/user, slot, equip_flags)
	return


/obj/item/OnTopic(href, href_list, datum/topic_state/state)
	. = ..()

	if (href_list["examine"])
		examinate(usr, src)
		return TOPIC_HANDLED
