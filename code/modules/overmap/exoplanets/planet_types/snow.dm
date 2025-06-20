/obj/overmap/visitable/sector/exoplanet/snow
	name = "snow exoplanet"
	desc = "Cold planet with limited plant life."
	color = "#dcdcdc"
	planetary_area = /area/exoplanet/snow
	rock_colors = list(COLOR_DARK_BLUE_GRAY, COLOR_GUNMETAL, COLOR_GRAY80, COLOR_DARK_GRAY)
	plant_colors = list("#d0fef5","#93e1d8","#93e1d8", "#b2abbf", "#3590f3", "#4b4e6d")
	map_generators = list(/datum/random_map/noise/exoplanet/snow, /datum/random_map/noise/ore/poor)
	surface_color = "#e8faff"
	water_color = "#b5dfeb"
	habitability_weight = HABITABILITY_BAD
	fauna_types = list(
		/mob/living/simple_animal/hostile/retaliate/beast/samak,
		/mob/living/simple_animal/hostile/retaliate/beast/diyaab,
		/mob/living/simple_animal/hostile/retaliate/beast/shantak
	)
	megafauna_types = list(/mob/living/simple_animal/hostile/retaliate/giant_crab)
	banned_weather_conditions = list(/singleton/state/weather/rain)

/obj/overmap/visitable/sector/exoplanet/snow/generate_atmosphere()
	..()
	var/singleton/species/H = GLOB.species_by_name[SPECIES_HUMAN]
	var/generator/new_temp = generator("num", H.cold_level_1 - 50, H.cold_level_3, NORMAL_RAND)
	exterior_atmosphere.temperature = new_temp.Rand()
	exterior_atmosphere.update_values()
	exterior_atmosphere.check_tile_graphic()

/datum/random_map/noise/exoplanet/snow
	descriptor = "snow exoplanet"
	smoothing_iterations = 1
	flora_prob = 5
	large_flora_prob = 10
	water_level_max = 3
	land_type = /turf/simulated/floor/exoplanet/snow
	water_type = /turf/simulated/floor/exoplanet/ice

/area/exoplanet/snow
	ambience = list('sound/effects/wind/tundra0.ogg','sound/effects/wind/tundra1.ogg','sound/effects/wind/tundra2.ogg','sound/effects/wind/spooky0.ogg','sound/effects/wind/spooky1.ogg')
	base_turf = /turf/simulated/floor/exoplanet/snow
