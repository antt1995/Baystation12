/obj/structure/roller_rack
	name = "roller bed rack"
	desc = "A standing rack for holding collapsed roller beds."
	icon = 'icons/obj/rollerbedrack.dmi'
	icon_state = "rack_base"
	obj_flags = OBJ_FLAG_ANCHORABLE
	anchored = TRUE
	material = MATERIAL_PLASTIC

	/// The max number of beds this rack can hold
	var/max_beds = 4

	/// For initialization, a count of beds to start with if any. Live, a list of current beds
	var/list/obj/item/roller_bed/beds = 0


/obj/structure/roller_rack/Destroy()
	QDEL_NULL_LIST(beds)
	return ..()


/obj/structure/roller_rack/New(ignored, material)
	if (material)
		src.material = material
	return ..()


/obj/structure/roller_rack/Initialize()
	. = ..()
	if (istext(material))
		material = SSmaterials.get_material_by_name(material)
	var/initial_beds = clamp(beds, 0, max_beds)
	beds = list()
	for (var/i in 1 to initial_beds)
		beds += new /obj/item/roller_bed (src)
	update_icon()


/obj/structure/roller_rack/on_update_icon()
	icon_state = "blank"
	var/image/rack_base = overlay_image(icon, "rack_base")
	if (material.icon_colour)
		rack_base.color = material.icon_colour
	rack_base.alpha = 255 * material.opacity
	var/list/new_overlays = list(rack_base)
	for (var/i in 1 to min(length(beds), max_beds))
		var/image/bed = overlay_image(icon, "bed_[i]")
		var/image/rack = overlay_image(icon, "rack_[i]")
		if (material.icon_colour)
			rack.color = material.icon_colour
		rack.alpha = 255 * material.opacity
		bed.AddOverlays(rack)
		new_overlays += bed
	SetOverlays(new_overlays)
	desc = "[initial(desc)]\nIt holds [length(beds)] beds."


/obj/structure/roller_rack/attack_hand(mob/user)
	if (!length(beds))
		to_chat(user, SPAN_NOTICE("The rack is empty."))
		return
	var/obj/item/roller_bed/bed = beds[length(beds)]
	user.put_in_hands(bed)
	beds -= bed
	to_chat(user, SPAN_NOTICE("You retrieve \the [bed] from the rack."))
	update_icon()


/obj/structure/roller_rack/use_tool(obj/item/tool, mob/user, list/click_params)
	if (istype(tool, /obj/item/roller_bed))
		if (length(beds) >= max_beds)
			to_chat(user, SPAN_NOTICE("The rack has no space for \the [tool]."))
			return TRUE
		user.drop_from_inventory(tool, src)
		beds += tool
		to_chat(user, SPAN_NOTICE("You place \the [tool] on the rack."))
		update_icon()
		return TRUE
	return ..()


/obj/structure/roller_rack/random/Initialize()
	beds = rand(0, max_beds)
	return ..()

/obj/structure/roller_rack/full/Initialize()
	beds = max_beds
	return ..()
