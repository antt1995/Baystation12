/*
	apply_damage() args
	damage - How much damage to take
	damage_type - What type of damage to take, brute, burn
	def_zone - Where to take the damage if its brute or burn

	Returns
	standard 0 if fail
*/
/mob/living/proc/apply_damage(damage = 0, damagetype = DAMAGE_BRUTE, def_zone = null, damage_flags = FLAGS_OFF, used_weapon, armor_pen, silent = FALSE)
	if(!damage)
		return FALSE

	var/list/after_armor = modify_damage_by_armor(def_zone, damage, damagetype, damage_flags, src, armor_pen, silent)
	damage = after_armor[1]
	damagetype = after_armor[2]
	damage_flags = after_armor[3] // args modifications in case of parent calls
	if(!damage)
		return FALSE

	switch (damagetype)
		if (DAMAGE_EMP, DAMAGE_FIRE)
			return FALSE // These damages are handled separately by existing legacy code
		if (DAMAGE_BIO)
			damagetype = DAMAGE_TOXIN
		if (DAMAGE_EXPLODE, DAMAGE_PSIONIC)
			damagetype = DAMAGE_BRUTE

	switch(damagetype)
		if (DAMAGE_BRUTE)
			adjustBruteLoss(damage)
		if (DAMAGE_BURN)
			if(MUTATION_COLD_RESISTANCE in mutations)
				damage = 0
			adjustFireLoss(damage)
		if (DAMAGE_TOXIN)
			adjustToxLoss(damage)
		if (DAMAGE_OXY)
			adjustOxyLoss(damage)
		if (DAMAGE_GENETIC)
			adjustCloneLoss(damage)
		if (DAMAGE_STUN, DAMAGE_PAIN)
			adjustHalLoss(damage)
		if (DAMAGE_SHOCK)
			electrocute_act(damage, used_weapon, 1, def_zone)
		if (DAMAGE_RADIATION)
			apply_radiation(damage)
		if (DAMAGE_BRAIN)
			adjustBrainLoss(damage)

	updatehealth()
	return TRUE


/mob/living/proc/apply_radiation(damage = 0)
	if(!damage)
		return FALSE

	radiation += damage
	return TRUE


/mob/living/proc/apply_damages(brute = 0, burn = 0, tox = 0, oxy = 0, clone = 0, halloss = 0, def_zone = null, damage_flags = 0)
	if (brute)
		apply_damage(brute, DAMAGE_BRUTE, def_zone)
	if(burn)
		apply_damage(burn, DAMAGE_BURN, def_zone)
	if(tox)
		apply_damage(tox, DAMAGE_TOXIN, def_zone)
	if (oxy)
		apply_damage(oxy, DAMAGE_OXY, def_zone)
	if (clone)
		apply_damage(clone, DAMAGE_GENETIC, def_zone)
	if (halloss)
		apply_damage(halloss, DAMAGE_PAIN, def_zone)
	return TRUE


/mob/living/proc/apply_effect(effect = 0, effecttype = EFFECT_STUN, blocked = 0)
	if(!effect || (blocked >= 100))	return FALSE

	switch(effecttype)
		if (EFFECT_STUN)
			Stun(effect * blocked_mult(blocked))
		if (EFFECT_WEAKEN)
			Weaken(effect * blocked_mult(blocked))
		if (EFFECT_PARALYZE)
			Paralyse(effect * blocked_mult(blocked))
		if (EFFECT_PAIN)
			adjustHalLoss(effect * blocked_mult(blocked))
		if (EFFECT_STUTTER)
			if(status_flags & CANSTUN) // stun is usually associated with stutter - TODO CANSTUTTER flag?
				stuttering = max(stuttering, effect * blocked_mult(blocked))
		if (EFFECT_EYE_BLUR)
			eye_blurry = max(eye_blurry, effect * blocked_mult(blocked))
		if (EFFECT_DROWSY)
			drowsyness = max(drowsyness, effect * blocked_mult(blocked))
	updatehealth()
	return TRUE

/mob/living/proc/apply_effects(stun = 0, weaken = 0, paralyze = 0, stutter = 0, eyeblur = 0, drowsy = 0, agony = 0, blocked = 0)
	if (stun)
		apply_effect(stun, EFFECT_STUN, blocked)
	if (weaken)
		apply_effect(weaken, EFFECT_WEAKEN, blocked)
	if (paralyze)
		apply_effect(paralyze, EFFECT_PARALYZE, blocked)
	if (stutter)
		apply_effect(stutter, EFFECT_STUTTER, blocked)
	if (eyeblur)
		apply_effect(eyeblur, EFFECT_EYE_BLUR, blocked)
	if (drowsy)
		apply_effect(drowsy, EFFECT_DROWSY, blocked)
	if (agony)
		apply_effect(agony, EFFECT_PAIN, blocked)
	return TRUE
