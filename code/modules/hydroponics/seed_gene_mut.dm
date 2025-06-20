/datum/seed/proc/diverge_mutate_gene(singleton/plantgene/G, turf/T)
	if(!istype(G))
		log_debug("Attempted to mutate [src] with a non-plantgene var.")
		return src

	var/datum/seed/S = diverge()	//Let's not modify all of the seeds.
	T.visible_message(SPAN_NOTICE("\The [S.display_name] quivers!"))	//Mimicks the normal mutation.
	G.mutate(S, T)

	return S

/singleton/plantgene
	var/gene_tag

/singleton/plantgene/biochem
	gene_tag = GENE_BIOCHEMISTRY

/singleton/plantgene/hardiness
	gene_tag = GENE_HARDINESS

/singleton/plantgene/environment
	gene_tag = GENE_ENVIRONMENT

/singleton/plantgene/metabolism
	gene_tag = GENE_METABOLISM

/singleton/plantgene/structure
	gene_tag = GENE_STRUCTURE

/singleton/plantgene/diet
	gene_tag = GENE_DIET

/singleton/plantgene/pigment
	gene_tag = GENE_PIGMENT

/singleton/plantgene/output
	gene_tag = GENE_OUTPUT

/singleton/plantgene/atmosphere
	gene_tag = GENE_ATMOSPHERE

/singleton/plantgene/vigour
	gene_tag = GENE_VIGOUR

/singleton/plantgene/fruit
	gene_tag = GENE_FRUIT

/singleton/plantgene/special
	gene_tag = GENE_SPECIAL

/singleton/plantgene/proc/mutate(datum/seed/S)
	return

/singleton/plantgene/biochem/mutate(datum/seed/S)
	S.set_trait(TRAIT_POTENCY, S.get_trait(TRAIT_POTENCY)+rand(-20,20),200, 0)

/singleton/plantgene/hardiness/mutate(datum/seed/S)
	if(prob(60))
		S.set_trait(TRAIT_TOXINS_TOLERANCE, S.get_trait(TRAIT_TOXINS_TOLERANCE)+rand(-2,2),10,0)
	if(prob(60))
		S.set_trait(TRAIT_PEST_TOLERANCE, S.get_trait(TRAIT_PEST_TOLERANCE)+rand(-2,2),10,0)
	if(prob(60))
		S.set_trait(TRAIT_WEED_TOLERANCE, S.get_trait(TRAIT_WEED_TOLERANCE)+rand(-2,2),10,0)
	if(prob(60))
		S.set_trait(TRAIT_ENDURANCE, S.get_trait(TRAIT_ENDURANCE)+rand(-5,5),100,0)

/singleton/plantgene/environment/mutate(datum/seed/S)
	if(prob(60))
		S.set_trait(TRAIT_IDEAL_HEAT, S.get_trait(TRAIT_IDEAL_HEAT)+rand(-2,2),10,0)
	if(prob(60))
		S.set_trait(TRAIT_IDEAL_LIGHT, S.get_trait(TRAIT_IDEAL_LIGHT)+rand(-2,2),10,0)
	if(prob(60))
		S.set_trait(TRAIT_LIGHT_TOLERANCE, S.get_trait(TRAIT_LIGHT_TOLERANCE)+rand(-5,5),100,0)

/singleton/plantgene/metabolism/mutate(datum/seed/S)
	if(prob(65))
		S.set_trait(TRAIT_REQUIRES_NUTRIENTS, S.get_trait(TRAIT_REQUIRES_NUTRIENTS)+rand(-2,2),10,0)
	if(prob(65))
		S.set_trait(TRAIT_REQUIRES_WATER, S.get_trait(TRAIT_REQUIRES_WATER)+rand(-2,2),10,0)
	if(prob(40))
		S.set_trait(TRAIT_ALTER_TEMP, S.get_trait(TRAIT_ALTER_TEMP)+rand(-5,5),100,0)

/singleton/plantgene/diet/mutate(datum/seed/S)
	if(prob(60))
		S.set_trait(TRAIT_CARNIVOROUS, S.get_trait(TRAIT_CARNIVOROUS)+rand(-1,1),2,0)
	if(prob(60))
		S.set_trait(TRAIT_PARASITE, !S.get_trait(TRAIT_PARASITE))
	if(prob(65))
		S.set_trait(TRAIT_NUTRIENT_CONSUMPTION, S.get_trait(TRAIT_NUTRIENT_CONSUMPTION)+Frand(-0.1,0.1),5,0)
	if(prob(65))
		S.set_trait(TRAIT_WATER_CONSUMPTION, S.get_trait(TRAIT_WATER_CONSUMPTION)+rand(-1,1),50,0)

/singleton/plantgene/output/mutate(datum/seed/S, turf/T)
	if(prob(50))
		S.set_trait(TRAIT_BIOLUM,         !S.get_trait(TRAIT_BIOLUM))
		if(S.get_trait(TRAIT_BIOLUM))
			T.visible_message(SPAN_NOTICE("\The [S.display_name] begins to glow!"))
			if(prob(50))
				S.set_trait(TRAIT_BIOLUM_COLOUR,get_random_colour(75, 190))
				T.visible_message("[SPAN_NOTICE("\The [S.display_name]'s glow ")][SPAN_COLOR(S.get_trait(TRAIT_BIOLUM_COLOUR), "changes colour")]!")
			else
				T.visible_message(SPAN_NOTICE("\The [S.display_name]'s glow dims..."))
	if(prob(60))
		S.set_trait(TRAIT_PRODUCES_POWER, !S.get_trait(TRAIT_PRODUCES_POWER))

/singleton/plantgene/atmosphere/mutate(datum/seed/S)
	if(prob(60))
		S.set_trait(TRAIT_HEAT_TOLERANCE, S.get_trait(TRAIT_HEAT_TOLERANCE)+rand(-5,5),800,70)
	if(prob(60))
		S.set_trait(TRAIT_LOWKPA_TOLERANCE, S.get_trait(TRAIT_LOWKPA_TOLERANCE)+rand(-5,5),80,0)
	if(prob(60))
		S.set_trait(TRAIT_HIGHKPA_TOLERANCE, S.get_trait(TRAIT_HIGHKPA_TOLERANCE)+rand(-5,5),500,110)

/singleton/plantgene/vigour/mutate(datum/seed/S, turf/T)
	if(prob(65))
		S.set_trait(TRAIT_PRODUCTION, S.get_trait(TRAIT_PRODUCTION)+rand(-1,1),10,0)
	if(prob(65))
		S.set_trait(TRAIT_MATURATION, S.get_trait(TRAIT_MATURATION)+rand(-1,1),30,0)
	if(prob(55))
		S.set_trait(TRAIT_SPREAD, S.get_trait(TRAIT_SPREAD)+rand(-1,1),2,0)
		T.visible_message(SPAN_NOTICE("\The [S.display_name] spasms visibly, shifting in the tray."))

/singleton/plantgene/fruit/mutate(datum/seed/S)
	if(prob(65))
		S.set_trait(TRAIT_STINGS, !S.get_trait(TRAIT_STINGS))
	if(prob(65))
		S.set_trait(TRAIT_EXPLOSIVE, !S.get_trait(TRAIT_EXPLOSIVE))
	if(prob(65))
		S.set_trait(TRAIT_JUICY, !S.get_trait(TRAIT_JUICY))

/singleton/plantgene/special/mutate(datum/seed/S)
	if(prob(65))
		S.set_trait(TRAIT_TELEPORTING, !S.get_trait(TRAIT_TELEPORTING))
