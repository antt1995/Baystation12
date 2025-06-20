//Dionaea regenerate health and nutrition in light.
/mob/living/carbon/alien/diona/handle_environment(datum/gas_mixture/environment)
	..()
	if(health <= 0 || stat == DEAD)
		return

	var/turf/checking = get_turf(src)
	if(!checking)
		return

	var/light_amount = checking.get_lumcount() * 5

	if(radiation <= 20)
		if(last_glow)
			set_light(0)
			last_glow = 0
	else
		var/mult = clamp(radiation/200, 0.5, 1)
		if(last_glow != mult)
			set_light((5*mult), mult, "#55ff55")
			last_glow = mult

	set_nutrition(clamp(nutrition + floor(radiation/100) + light_amount, 0, 500))

	if(radiation >= 50 || light_amount > 2) //if there's enough light, heal
		adjustBruteLoss(-1)
		adjustFireLoss(-1)
		adjustToxLoss(-1)
		adjustOxyLoss(-1)
