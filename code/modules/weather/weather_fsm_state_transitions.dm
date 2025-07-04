/singleton/state_transition/weather
	abstract_type = /singleton/state_transition/weather
	var/likelihood_weighting = 100

/singleton/state_transition/weather/is_open(datum/holder)
	var/obj/abstract/weather_system/weather = holder
	return weather.supports_weather_state(target)

/singleton/state_transition/weather/calm
	target = /singleton/state/weather/calm

/singleton/state_transition/weather/cold
	target = /singleton/state/weather/cold
	likelihood_weighting = 50

/singleton/state_transition/weather/snow
	target = /singleton/state/weather/snow
	likelihood_weighting = 30

/singleton/state_transition/weather/rain
	target = /singleton/state/weather/rain
	likelihood_weighting = 30

/singleton/state_transition/weather/snow_medium
	target = /singleton/state/weather/snow/medium
	likelihood_weighting = 20

/singleton/state_transition/weather/snow_heavy
	target = /singleton/state/weather/snow/heavy
	likelihood_weighting = 10

/singleton/state_transition/weather/storm
	target = /singleton/state/weather/rain/storm
	likelihood_weighting = 20

/singleton/state_transition/weather/hail
	target = /singleton/state/weather/rain/hail
	likelihood_weighting = 20
