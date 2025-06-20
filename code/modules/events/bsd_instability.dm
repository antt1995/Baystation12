/datum/event/bsd_instability
	endWhen	= 350

	var/list/obj/machinery/tele_pad/pads = list()
	var/list/obj/machinery/bluespacedrive/drives = list()
	var/list/obj/structure/stairs/stairs = list()
	var/list/obj/structure/ladders = list()
	var/list/mob/living/simple_animal/hostile/bluespace/mobs = list()
	var/effects_per_tick = 5
	var/maximum_mobs = 10
	var/mob_spawn_chance = 3
	var/turf_conversion_range = 5
	var/next_zap = 0
	var/flush_running = FALSE


/datum/event/bsd_instability/setup()
	if (severity <= EVENT_LEVEL_MODERATE)
		return

/datum/event/bsd_instability/announce()
	switch (severity)
		if (EVENT_LEVEL_MODERATE)
			command_announcement.Announce(
				"Warning: Bluespace Drive instability detected. Navigation and teleportation systems may be compromised.",
				"[location_name()] Bluespace Drive Monitoring",
				zlevels = affecting_z
			)
		if (EVENT_LEVEL_MAJOR)
			command_announcement.Announce(
				"WARNING: BLUESPACE DRIVE CONTAINMENT FAILURE IMMINENT. ENGAGING REPAIR MODULES. AVOID ALL AN#*!&A#%!!_ ZZZT ----  ",
				"[location_name()] Bluespace Drive Monitoring",
				zlevels = affecting_z
			)


/datum/event/bsd_instability/start()
	for (var/obj/machinery/tele_pad/pad in SSmachines.machinery)
		if (!(pad.z in affecting_z))
			continue
		pads += pad
		pad.interference = TRUE
		pad.interlude_chance = 30 * severity
	for (var/obj/machinery/bluespacedrive/drive in SSmachines.machinery)
		if (!(drive.z in affecting_z))
			continue
		drives += drive
		drive.instability_event_active = TRUE
		drive.set_light(1, 8, 25, 15, COLOR_CYAN_BLUE)
		if (severity <= EVENT_LEVEL_MODERATE)
			continue
		addtimer(new Callback(drive, TYPE_PROC_REF(/obj/machinery/bluespacedrive, create_flash), TRUE, turf_conversion_range), 2 SECONDS)
	if (severity <= EVENT_LEVEL_MODERATE)
		return
	for (var/obj/structure/stairs/stair in world)
		if (!(stair.z in affecting_z))
			continue
		stairs += stair
		stair.bluespace_affected = TRUE
	for (var/obj/structure/ladder/ladder in world)
		if (!(ladder.z in affecting_z))
			continue
		ladders += ladder
		ladder.bluespace_affected = TRUE


/datum/event/bsd_instability/tick()
	set waitfor = FALSE
	if (severity > EVENT_LEVEL_MODERATE)
		for (var/i = 1 to effects_per_tick)
			var/turf/turf = pick_area_turf_in_single_z_level(
				list(GLOBAL_PROC_REF(is_not_space_area)),
				z_level = pick(affecting_z)
			)
			var/effect_state = pick("cyan_sparkles", "blue_electricity_constant", "shieldsparkles", "empdisabled")
			var/obj/temporary/temp_effect = new (turf, 1 SECONDS, 'icons/effects/effects.dmi', effect_state)
			temp_effect.set_light(1, 1, 2, 3, COLOR_CYAN_BLUE)
			if (prob(mob_spawn_chance) && length(mobs) < maximum_mobs && !turf.is_dense())
				turf.visible_message(SPAN_DANGER("A sudden burst of energy gives birth to some sort of ghost-like entity!"))
				playsound(turf, "sound/effects/supermatter.ogg", 75, TRUE)
				var/mob/living/simple_animal/hostile/bluespace/bluespace_ghost = new (turf)
				mobs += bluespace_ghost
		if (next_zap <= world.time)
			for (var/obj/machinery/bluespacedrive/drive in drives)

				var/turf/turf = get_random_turf_in_range(drive, 5)
				var/simple_vector/start = new (drive.x * world.icon_size, drive.y * world.icon_size)
				var/simple_vector/dest  = new (turf.x * world.icon_size, turf.y * world.icon_size)
				turf.damage_health(10, DAMAGE_BURN)

				for (var/atom/object in turf.contents)
					object.damage_health(10, DAMAGE_BURN)
				playsound(drive, pick('sound/effects/bsd_zap_2.ogg'), 75)
				if (prob(30))
					turf.damage_health(20, DAMAGE_BURN)
					for (var/atom/object in turf)
						object.damage_health(20, DAMAGE_BURN)
					turf.ex_act(EX_ACT_HEAVY)
					playsound(drive, pick('sound/effects/bsd_zap_1.ogg'), 75)
				for (var/i = 1 to 8)
					var/datum/bolt/b = new(start, dest, 90)
					b.Draw(drive.z, color = "#01c4ff", thickness = 1)
					sleep(1)

				for (var/atom/object in turf)
					object.damage_health(20, DAMAGE_BURN, null, 1)


				next_zap = world.time + rand(5, 20) SECONDS
	if (activeFor != (endWhen - 30))
		return
	if (flush_running)
		return
	flush_running = TRUE
	command_announcement.Announce(
		"PRIORITY ALERT: System flush required to disperse esoteric hyper-particle buildup. Brace for chrono-phasic sweep.",
		"[location_name()] Bluespace Drive Monitoring",
		zlevels = affecting_z
	)
	for (var/obj/machinery/bluespacedrive/drive in drives)
		addtimer(new Callback(drive, TYPE_PROC_REF(/obj/machinery/bluespacedrive, do_pulse)), 20 SECONDS)
	for (var/mob/mob in GLOB.player_list)
		if (istype(mob, /mob/new_player))
			continue
		if (isdeaf(mob))
			continue
		if (!(get_z(mob) in affecting_z))
			continue
		sound_to(mob, 'sound/ambience/bsd_alarm.ogg')


/datum/event/bsd_instability/end()
	for (var/obj/machinery/tele_pad/pad in pads)
		pad.interference = FALSE
		pad.interlude_chance = 0
	for (var/obj/machinery/bluespacedrive/drive in drives)
		drive.instability_event_active = FALSE
		drive.set_light(1, 5, 15, 10, COLOR_CYAN)
		for (var/turf/simulated/floor/floor in range(turf_conversion_range, drive))
			if (istype(floor.flooring, /singleton/flooring/bluespace))
				floor.ChangeTurf(/turf/simulated/floor/plating)
	for (var/obj/structure/stairs/stair in stairs)
		stair.bluespace_affected = FALSE
	for (var/obj/structure/ladder/ladder in ladders)
		ladder.bluespace_affected = FALSE
	command_announcement.Announce(
		"Particle flush complete, containment fields restablished. All systems nominal.",
		"[location_name()] Bluespace Drive Monitoring"
	)

	LAZYCLEARLIST(pads)
	LAZYCLEARLIST(drives)
	LAZYCLEARLIST(stairs)
	LAZYCLEARLIST(ladders)
	QDEL_NULL_LIST(mobs)
