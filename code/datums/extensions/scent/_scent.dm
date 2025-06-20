#define SCENT_DESC_ODOR        "odour"
#define SCENT_DESC_SMELL       "smell"
#define SCENT_DESC_FRAGRANCE   "fragrance"
#define SCENT_DESC_HAZE        "haze"
#define SCENT_DESC_PLUME       "plume"

/*****
Scent intensity
*****/

/singleton/scent_intensity
	var/cooldown = 5 MINUTES
	var/intensity = 1

/singleton/scent_intensity/proc/can_smell(mob/living/carbon/human/user)
	return TRUE

/singleton/scent_intensity/proc/PrintMessage(mob/living/carbon/human/user, descriptor, scent)
	if(!can_smell(user))
		return
	if(!user.isSynthetic())
		to_chat(user, SPAN_SUBTLE("The subtle [descriptor] of [scent] tickles your nose..."))
	else
		to_chat(user, SPAN_NOTICE("Your sensors detect trace amounts of [scent] in the air."))


/singleton/scent_intensity/normal
	cooldown = 4 MINUTES
	intensity = 2

/singleton/scent_intensity/normal/PrintMessage(mob/living/carbon/human/user, descriptor, scent)
	if(!can_smell(user))
		return
	if(!user.isSynthetic())
		to_chat(user, SPAN_NOTICE("The [descriptor] of [scent] fills the air."))
	else
		to_chat(user, SPAN_NOTICE("Your sensors pick up the presence of [scent] in the air."))

/singleton/scent_intensity/strong
	cooldown = 3 MINUTES
	intensity = 3

/singleton/scent_intensity/strong/PrintMessage(mob/living/carbon/human/user, descriptor, scent)
	if(!can_smell(user))
		return
	if(!user.isSynthetic())
		to_chat(user, SPAN_WARNING("The unmistakable [descriptor] of [scent] bombards your nostrils."))
	else
		to_chat(user, SPAN_WARNING("Your sensors pick up an intense concentration of [scent]."))

/singleton/scent_intensity/overpowering
	cooldown = 1 MINUTES
	intensity = 4

/singleton/scent_intensity/overpowering/PrintMessage(mob/living/carbon/human/user, descriptor, scent)
	if(!can_smell(user))
		return
	if(!user.isSynthetic())
		to_chat(user, SPAN_WARNING("The overwhelming [descriptor] of [scent] assaults your senses. You stifle a gag."))
	else
		to_chat(user, SPAN_WARNING("ALERT! Your sensors pick up an overwhelming concentration of [scent]."))
/*****
 Scent extensions
 Usage:
	To add:
		set_extension(atom, /datum/extension/scent/PATH/TO/SPECIFIC/SCENT)
		This will set up the extension and will make it begin to emit_scent.
	To remove:
		remove_extension(atom, /datum/extension/scent)
*****/

/datum/extension/scent
	base_type = /datum/extension/scent
	expected_type = /atom
	flags = EXTENSION_FLAG_IMMEDIATE

	var/scent = "something"
	var/singleton/scent_intensity/intensity = /singleton/scent_intensity
	var/descriptor = SCENT_DESC_SMELL //unambiguous descriptor of smell; food is generally good, sewage is generally bad. how 'nice' the scent is
	var/range = 1 //range in tiles

/datum/extension/scent/New()
	..()
	if(ispath(intensity))
		intensity = GET_SINGLETON(intensity)
	START_PROCESSING(SSscents, src)

/datum/extension/scent/Destroy()
	STOP_PROCESSING(SSscents, src)
	. = ..()

/datum/extension/scent/Process()
	if(!holder)
		crash_with("Scent extension with scent '[scent]', intensity '[intensity]', descriptor '[descriptor]' and range of '[range]' attempted to emit_scent() without a holder.")
		qdel(src)
		return PROCESS_KILL
	emit_scent()

/datum/extension/scent/proc/emit_scent()
	for(var/mob/living/carbon/human/H in all_hearers(holder, range))
		var/turf/T = get_turf(H.loc)
		if(!T)
			continue
		if(H.stat != CONSCIOUS || H.failed_last_breath || H.wear_mask || H.head && H.head.permeability_coefficient < 1 || !T.return_air())
			continue
		if(H.last_smelt < world.time)
			intensity.PrintMessage(H, descriptor, scent)
			H.last_smelt = world.time + intensity.cooldown

/*****
Custom subtype
	set_extension(atom, /datum/extension/scent/custom, scent = "scent", intensity = SCENT_INTENSITY_, ... etc)
This will let you set an extension without needing to define it beforehand. Note that all vars are required if generating.
*****/
/datum/extension/scent/custom/New(datum/holder, provided_scent, provided_intensity, provided_descriptor, provided_range)
	..()
	if(provided_scent && provided_intensity && provided_descriptor && provided_range)
		scent = provided_scent
		if(ispath(provided_intensity))
			intensity = GET_SINGLETON(provided_intensity)
		descriptor = provided_descriptor
		range = provided_range
	else
		CRASH("Attempted to generate a scent extension on [holder], but at least one of the required vars was not provided.")

/*****
Reagents have the following vars, which coorelate to the vars on the standard scent extension:
	scent,
	scent_intensity,
	scent_descriptor,
	scent_range
To add a scent extension to an atom using a reagent's info, where R. is the reagent, use set_scent_by_reagents().
*****/

/proc/set_scent_by_reagents(atom/smelly_atom)
	var/datum/reagent/smelliest
	var/datum/reagent/scent_intensity
	if(!smelly_atom.reagents || !smelly_atom.reagents.total_volume)
		return
	for(var/datum/reagent/reagent_to_compare in smelly_atom.reagents.reagent_list)
		var/datum/reagent/R = reagent_to_compare
		if(!R.scent)
			continue
		var/singleton/scent_intensity/SI = GET_SINGLETON(R.scent_intensity)
		var/r_scent_intensity = R.volume * SI.intensity
		if(r_scent_intensity > scent_intensity)
			smelliest = R
			scent_intensity = r_scent_intensity
	if(smelliest)
		set_extension(smelly_atom, /datum/extension/scent/custom, smelliest.scent, smelliest.scent_intensity, smelliest.scent_descriptor, smelliest.scent_range)
