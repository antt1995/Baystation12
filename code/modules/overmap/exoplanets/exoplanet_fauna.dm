/obj/overmap/visitable/sector/exoplanet/proc/adapt_animal(mob/living/simple_animal/A, setname = TRUE)
	if (setname)
		if (species[A.type])
			A.SetName(species[A.type])
			A.real_name = species[A.type]
		else
			A.SetName("alien creature")
			A.real_name = "alien creature"
			A.verbs |= /mob/living/simple_animal/proc/name_species

		A.minbodytemp = exterior_atmosphere.temperature - 20
		A.maxbodytemp = exterior_atmosphere.temperature + 30
		A.bodytemperature = (A.maxbodytemp+A.minbodytemp)/2
		if (A.min_gas)
			A.min_gas = breathgas.Copy()
		if (A.max_gas)
			A.max_gas = list()
			A.max_gas[badgas] = 5
	else
		A.min_gas = null
		A.max_gas = null

/obj/overmap/visitable/sector/exoplanet/proc/remove_animal(mob/M)
	animals -= M
	GLOB.death_event.unregister(M, src)
	GLOB.destroyed_event.unregister(M, src)
	repopulate_types |= M.type

/obj/overmap/visitable/sector/exoplanet/proc/handle_repopulation()
	for (var/i = 1 to round(max_animal_count - length(animals)))
		if (prob(10))
			var/turf/simulated/T = pick_area_turf(planetary_area, list(
				GLOBAL_PROC_REF(not_turf_contains_dense_objects)
			))
			var/mob_type = pick(repopulate_types)
			var/mob/S = new mob_type(T)
			track_animal(S)
			adapt_animal(S)
	if (length(animals) >= max_animal_count)
		repopulating = 0

/obj/overmap/visitable/sector/exoplanet/proc/track_animal(mob/A)
	animals += A
	GLOB.death_event.register(A, src, PROC_REF(remove_animal))
	GLOB.destroyed_event.register(A, src, PROC_REF(remove_animal))

/obj/overmap/visitable/sector/exoplanet/proc/get_random_species_name()
	return pick("nol","shan","can","fel","xor")+pick("a","e","o","t","ar")+pick("ian","oid","ac","ese","inian","rd")

/obj/overmap/visitable/sector/exoplanet/proc/rename_species(species_type, newname, force = FALSE)
	if (species[species_type] && !force)
		return FALSE

	species[species_type] = newname
	log_and_message_admins("renamed [species_type] to [newname]")
	for (var/mob/living/simple_animal/A in animals)
		if (istype(A,species_type))
			A.SetName(newname)
			A.real_name = newname
			A.verbs -= /mob/living/simple_animal/proc/name_species
	return TRUE

/obj/landmark/exoplanet_spawn
	name = "spawn exoplanet animal"

/obj/landmark/exoplanet_spawn/proc/do_spawn(obj/overmap/visitable/sector/exoplanet/planet)
	if (LAZYLEN(planet.fauna_types))
		var/beastie = pick(planet.fauna_types)
		var/mob/M = new beastie(get_turf(src))
		planet.adapt_animal(M)
		planet.track_animal(M)

/obj/landmark/exoplanet_spawn/megafauna
	name = "spawn exoplanet megafauna"

/obj/landmark/exoplanet_spawn/megafauna/do_spawn(obj/overmap/visitable/sector/exoplanet/planet)
	if (LAZYLEN(planet.megafauna_types))
		var/beastie = pick(planet.megafauna_types)
		var/mob/M = new beastie(get_turf(src))
		planet.adapt_animal(M)
		planet.track_animal(M)
