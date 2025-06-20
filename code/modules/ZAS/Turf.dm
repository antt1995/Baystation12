/turf/simulated/var/zone/zone
/turf/simulated/var/open_directions

/turf/var/needs_air_update = 0
/turf/var/datum/gas_mixture/air

/turf/simulated/proc/update_graphic(list/graphic_add = null, list/graphic_remove = null)
	if(graphic_add && length(graphic_add))
		add_vis_contents(graphic_add)
	if(graphic_remove && length(graphic_remove))
		remove_vis_contents(graphic_remove)

/turf/simulated/get_air_graphic()
	if(zone && !zone.invalid)
		return zone.air?.graphic
	if(external_atmosphere_participation && is_outside())
		var/obj/overmap/visitable/E = map_sectors["[z]"]
		if (E)
			return E.exterior_atmosphere.graphic
	var/datum/gas_mixture/environment = return_air()
	return environment?.graphic

/turf/proc/update_air_properties()
	var/s_block
	ATMOS_CANPASS_TURF(s_block, src, src)
	if(s_block & AIR_BLOCKED)
		//dbg(blocked)
		return 1

	#ifdef MULTIZAS
	for(var/d = 1, d < 64, d *= 2)
	#else
	for(var/d = 1, d < 16, d *= 2)
	#endif

		var/turf/unsim = get_step(src, d)

		if(!unsim)
			continue

		var/block
		ATMOS_CANPASS_TURF(block, unsim, src)
		if(block & AIR_BLOCKED)
			//unsim.dbg(air_blocked, turn(180,d))
			continue

		var/r_block
		ATMOS_CANPASS_TURF(r_block, src, unsim)
		if(r_block & AIR_BLOCKED)
			continue

		if(istype(unsim, /turf/simulated))

			var/turf/simulated/sim = unsim
			if(TURF_HAS_VALID_ZONE(sim))
				SSair.connect(sim, src)

// Helper for can_safely_remove_from_zone().
#define GET_ZONE_NEIGHBOURS(T, ret) \
	ret = 0; \
	if (T.zone) { \
		for (var/_gzn_dir in GLOB.gzn_check) { \
			var/turf/simulated/other = get_step(T, _gzn_dir); \
			if (istype(other) && other.zone == T.zone) { \
				var/block; \
				ATMOS_CANPASS_TURF(block, other, T); \
				if (!(block & AIR_BLOCKED)) { \
					ret |= _gzn_dir; \
				} \
			} \
		} \
	}

/*
	Simple heuristic for determining if removing the turf from it's zone will not partition the zone (A very bad thing).
	Instead of analyzing the entire zone, we only check the nearest 3x3 turfs surrounding the src turf.
	This implementation may produce false negatives but it (hopefully) will not produce any false postiives.
*/

/turf/simulated/proc/can_safely_remove_from_zone()
	if(!zone)
		return 1

	var/check_dirs
	GET_ZONE_NEIGHBOURS(src, check_dirs)
	. = check_dirs

	//src is only connected to the zone by a single direction, this is a safe removal.
	if (!(. & (. - 1)))
		return TRUE

	for(var/dir in GLOB.csrfz_check)
		//for each pair of "adjacent" cardinals (e.g. NORTH and WEST, but not NORTH and SOUTH)
		if((dir & check_dirs) == dir)
			//check that they are connected by the corner turf
			var/turf/simulated/T = get_step(src, dir)
			if (!istype(T))
				. &= ~dir
				continue

			var/connected_dirs
			GET_ZONE_NEIGHBOURS(T, connected_dirs)
			if(connected_dirs && (dir & GLOB.reverse_dir[connected_dirs]) == dir)
				. &= ~dir //they are, so unflag the cardinals in question

	//it is safe to remove src from the zone if all cardinals are connected by corner turfs
	. = !.

/turf/simulated/update_air_properties()

	if(zone && zone.invalid) //this turf's zone is in the process of being rebuilt
		c_copy_air() //not very efficient :(
		zone = null //Easier than iterating through the list at the zone.

	var/s_block
	ATMOS_CANPASS_TURF(s_block, src, src)
	if(s_block & AIR_BLOCKED)
		#ifdef ZASDBG
		if(verbose) log_debug("Self-blocked.")
		//dbg(blocked)
		#endif
		if(zone)
			var/zone/z = zone

			if(can_safely_remove_from_zone()) //Helps normal airlocks avoid rebuilding zones all the time
				c_copy_air() //we aren't rebuilding, but hold onto the old air so it can be readded
				z.remove(src)
			else
				z.rebuild()

		return 1

	var/zas_participation = SHOULD_PARTICIPATE_IN_ZONES(src)
	var/previously_open = open_directions
	open_directions = 0

	var/list/postponed
	#ifdef MULTIZAS
	for(var/d = 1, d < 64, d *= 2)
	#else
	for(var/d = 1, d < 16, d *= 2)
	#endif

		var/turf/unsim = get_step(src, d)

		if(!unsim) //edge of map
			continue

		var/block = unsim.c_airblock(src)
		if(block & AIR_BLOCKED)

			#ifdef ZASDBG
			if(verbose) log_debug("[d] is blocked.")
			//unsim.dbg(air_blocked, turn(180,d))
			#endif

			continue

		var/r_block = c_airblock(unsim)
		if(r_block & AIR_BLOCKED)

			#ifdef ZASDBG
			if(verbose) log_debug("[d] is blocked.")
			//dbg(air_blocked, d)
			#endif

			//Check that our zone hasn't been cut off recently.
			//This happens when windows move or are constructed. We need to rebuild.
			if((previously_open & d) && istype(unsim, /turf/simulated))
				var/turf/simulated/sim = unsim
				if(zone && sim.zone == zone)
					zone.rebuild()
					return

			continue

		open_directions |= d

		if(istype(unsim, /turf/simulated) && SHOULD_PARTICIPATE_IN_ZONES(unsim))

			var/turf/simulated/sim = unsim
			sim.open_directions |= GLOB.reverse_dir[d]

			if(TURF_HAS_VALID_ZONE(sim))
				if(zas_participation)
					//Might have assigned a zone, since this happens for each direction.
					if(!zone)

						//We do not merge if
						//    they are blocking us and we are not blocking them, or if
						//    we are blocking them and not blocking ourselves - this prevents tiny zones from forming on doorways.
						if(((block & ZONE_BLOCKED) && !(r_block & ZONE_BLOCKED)) || ((r_block & ZONE_BLOCKED) && !(s_block & ZONE_BLOCKED)))
							#ifdef ZASDBG
							if(verbose) log_debug("[d] is zone blocked.")

							//dbg(zone_blocked, d)
							#endif

							//Postpone this tile rather than exit, since a connection can still be made.
							if(!postponed) postponed = list()
							postponed.Add(sim)

						else

							sim.zone.add(src)

							#ifdef ZASDBG
							dbg(assigned)
							if(verbose) log_debug("Added to [zone]")
							#endif

					else if(sim.zone != zone)

						#ifdef ZASDBG
						if(verbose) log_debug("Connecting to [sim.zone]")
						#endif

						SSair.connect(src, sim)
				#ifdef ZASDBG
					else if(verbose)
						log_debug("[dir2text(d)] has same zone.")
				#endif


				else
					#ifdef ZASDBG
					if(verbose)
						log_debug("Connecting non-ZAS turf to [unsim.zone]")
					#endif

					SSair.connect(unsim, src)
			#ifdef ZASDBG
				else if(verbose) log_debug("[d] has same zone.")

			else if(verbose) log_debug("[d] has invalid or rebuilding zone.")
			#endif

		else if(zas_participation)

			//Postponing connections to tiles until a zone is assured.
			if(!postponed) postponed = list()
			postponed.Add(unsim)

	if(zas_participation && !TURF_HAS_VALID_ZONE(src)) //Still no zone, make a new one.
		var/zone/newzone = new/zone()
		newzone.add(src)

	#ifdef ZASDBG
		dbg(created)

	ASSERT(!zas_participation || zone)
	#endif

	//At this point, a zone should have happened. If it hasn't, don't add more checks, fix the bug.

	for(var/turf/T in postponed)
		SSair.connect(src, T)

/turf/proc/post_update_air_properties()
	if(connections) connections.update_all()

/turf/assume_air(datum/gas_mixture/giver) //use this for machines to adjust air
	return 0

/turf/proc/assume_gas(gasid, moles, temp = 0)
	return 0

/turf/return_air()
	//Create gas mixture to hold data for passing
	var/datum/gas_mixture/GM = new

	if (initial_gas)
		GM.gas = initial_gas.Copy()
	GM.temperature = temperature
	GM.update_values()

	return GM

/turf/remove_air(amount as num)
	var/datum/gas_mixture/GM = return_air()
	return GM.remove(amount)

/turf/simulated/assume_air(datum/gas_mixture/giver)
	var/datum/gas_mixture/my_air = return_air()
	my_air.merge(giver)

/turf/simulated/assume_gas(gasid, moles, temp = null)
	var/datum/gas_mixture/my_air = return_air()

	if (isnull(temp))
		my_air.adjust_gas(gasid, moles)
	else
		my_air.adjust_gas_temp(gasid, moles, temp)

	return 1

/turf/simulated/return_air()
	// ZAS participation
	if (zone && !zone.invalid)
		SSair.mark_zone_update(zone)
		return zone.air

	// Exterior turf global atmosphere
	if ((!air && isnull(initial_gas)) || (external_atmosphere_participation && is_outside()))
		. = get_external_air()

	// Base behavior
	if (!.)
		. = air || make_air()
		if (zone)
			c_copy_air()
			zone = null

// Returns the external air if this turf is outside, modified by weather and heat sources. Outside checks do not occur in this proc!
/turf/proc/get_external_air(include_heat_sources = TRUE)
	var/obj/overmap/visitable/E = map_sectors["[z]"]
	if (!E)
		return null
	var/datum/gas_mixture/gas = E.get_exterior_atmosphere()
	if (!include_heat_sources)
		return gas

	if (weather)
		gas.temperature = weather.adjust_temperature(gas.temperature)
	//TODO: port heat sources from nebula
	//var/initial_temperature = gas.temperature
	// if(length(affecting_heat_sources))
	// 	for(var/obj/structure/fire_source/heat_source as anything in affecting_heat_sources)
	// 		gas.temperature = gas.temperature + heat_source.exterior_temperature / max(1, get_dist(src, get_turf(heat_source)))
	// 		if(abs(gas.temperature - initial_temperature) >= 100)
	// 			break
	gas.update_values()
	return gas

/turf/proc/make_air()
	air = new/datum/gas_mixture
	air.temperature = temperature
	if(initial_gas)
		air.gas = initial_gas.Copy()
	air.update_values()
	return air

/turf/simulated/proc/c_copy_air()
	if(!air) air = new/datum/gas_mixture
	air.copy_from(zone.air)
	air.group_multiplier = 1
