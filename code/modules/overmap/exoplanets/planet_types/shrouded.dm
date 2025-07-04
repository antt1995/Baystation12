/obj/overmap/visitable/sector/exoplanet/shrouded
	name = "shrouded exoplanet"
	desc = "An exoplanet shrouded in a perpetual storm of bizzare, light absorbing particles."
	color = "#783ca4"
	planetary_area = /area/exoplanet/shrouded
	rock_colors = list(COLOR_INDIGO, COLOR_DARK_BLUE_GRAY, COLOR_NAVY_BLUE)
	plant_colors = list("#3c5434", "#2f6655", "#0e703f", "#495139", "#394c66", "#1a3b77", "#3e3166", "#52457c", "#402d56", "#580d6d")
	map_generators = list(/datum/random_map/noise/exoplanet/shrouded, /datum/random_map/noise/ore/poor)
	ruin_tags_blacklist = RUIN_HABITAT
	sun_brightness_modifier = -0.5
	surface_color = "#3e3960"
	water_color = "#2b2840"
	fauna_types = list(
		/mob/living/simple_animal/hostile/retaliate/royalcrab,
		/mob/living/simple_animal/hostile/retaliate/jelly/alt,
		/mob/living/simple_animal/hostile/retaliate/beast/shantak/alt,
		/mob/living/simple_animal/hostile/leech
	)


/obj/overmap/visitable/sector/exoplanet/shrouded/generate_atmosphere()
	..()
	if (exterior_atmosphere)
		exterior_atmosphere.temperature = rand(T0C, T20C)
		exterior_atmosphere.update_values()
		exterior_atmosphere.check_tile_graphic()

/obj/overmap/visitable/sector/exoplanet/shrouded/get_atmosphere_color()
	var/air_color = ..()
	return MixColors(list(COLOR_BLACK, air_color))

/datum/random_map/noise/exoplanet/shrouded
	descriptor = "shrouded exoplanet"
	smoothing_iterations = 2
	flora_prob = 5
	large_flora_prob = 20
	megafauna_spawn_prob = 2 //Remember to change this if more types are added.
	water_level_max = 3
	water_level_min = 2
	land_type = /turf/simulated/floor/exoplanet/shrouded
	water_type = /turf/simulated/floor/exoplanet/water/shallow/tar

/datum/random_map/noise/exoplanet/shrouded/get_additional_spawns(value, turf/T)
	..()

	if (prob(0.1))
		new/obj/structure/leech_spawner(T)

/area/exoplanet/shrouded
	forced_ambience = list("sound/ambience/spookyspace1.ogg", "sound/ambience/spookyspace2.ogg")
	base_turf = /turf/simulated/floor/exoplanet/shrouded

/turf/simulated/floor/exoplanet/water/shallow/tar
	name = "tar"
	icon = 'icons/turf/shrouded.dmi'
	icon_state = "shrouded_tar"
	desc = "A pool of viscous and sticky tar."
	movement_delay = 12
	reagent_type = /datum/reagent/toxin/tar
	dirt_color = "#3e3960"

/turf/simulated/floor/exoplanet/water/shallow/tar/get_footstep_sound(mob/caller)
	return get_footstep(/singleton/footsteps/water, caller)


/turf/simulated/floor/exoplanet/shrouded
	name = "packed sand"
	icon = 'icons/turf/shrouded.dmi'
	icon_state = "shrouded"
	desc = "Sand that has been packed in to solid earth."
	dirt_color = "#3e3960"

/turf/simulated/floor/exoplanet/shrouded/New()
	icon_state = "shrouded[rand(0,8)]"
	..()
