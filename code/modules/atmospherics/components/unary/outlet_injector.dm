/obj/machinery/atmospherics/unary/outlet_injector
	icon = 'icons/atmos/injector.dmi'
	icon_state = "map_injector"

	name = "injector"
	desc = "Passively injects air into its surroundings. Has a valve attached to it that can control flow rate."

	use_power = POWER_USE_OFF
	idle_power_usage = 150		//internal circuitry, friction losses and stuff
	power_rating = 45000	//45000 W ~ 60 HP

	var/injecting = 0

	var/volume_rate = 50	//flow rate limit

	var/frequency = 1439
	var/id = null
	var/datum/radio_frequency/radio_connection


	level = ATOM_LEVEL_UNDER_TILE

	connect_types = CONNECT_TYPE_REGULAR|CONNECT_TYPE_FUEL

	build_icon = 'icons/atmos/injector.dmi'
	build_icon_state = "map_injector"

/obj/machinery/atmospherics/unary/outlet_injector/Initialize()
	. = ..()
	//Give it a small reservoir for injecting. Also allows it to have a higher flow rate limit than vent pumps, to differentiate injectors a bit more.
	air_contents.volume = ATMOS_DEFAULT_VOLUME_PUMP + 500

	set_frequency(frequency)
	broadcast_status()


/obj/machinery/atmospherics/unary/outlet_injector/Destroy()
	unregister_radio(src, frequency)
	. = ..()

/obj/machinery/atmospherics/unary/outlet_injector/on_update_icon()
	if (!node)
		update_use_power(POWER_USE_OFF)

	if(!is_powered())
		icon_state = "off"
	else
		icon_state = "[use_power ? "on" : "off"]"

/obj/machinery/atmospherics/unary/outlet_injector/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		if(!T.is_plating() && node && node.level == ATOM_LEVEL_UNDER_TILE && istype(node, /obj/machinery/atmospherics/pipe))
			return
		else
			if(node)
				add_underlay(T, node, dir, node.icon_connect_type)
			else
				add_underlay(T,, dir)

/obj/machinery/atmospherics/unary/outlet_injector/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	if(inoperable())
		return

	var/data[0]

	data = list(
		"on" = use_power,
		"id" = id,
		"frequency" = frequency,
		"flow_rate" = volume_rate,
		"last_flow_rate" = round(last_flow_rate*10),
	)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "injector.tmpl", name, 480, 240)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/atmospherics/unary/outlet_injector/Topic(href,href_list)
	if((. = ..())) return

	if(href_list["power"])
		update_use_power(!use_power)
		. = 1

	if(href_list["settag"])
		var/t = sanitizeSafe(input(usr, "Enter the ID tag for [src.name]", src.name, id), MAX_NAME_LEN)
		id = t
		. = 1

	if(href_list["setfreq"])
		var/freq = input(usr, "Enter the Frequency for [src.name]. Decimal will automatically be inserted", src.name, frequency) as num|null
		set_frequency(freq)
		. = 1

	switch(href_list["set_flow_rate"])
		if ("max")
			volume_rate = air_contents.volume
			. = 1
		if ("set")
			var/new_rate = input(usr,"Enter maximum flow rate (0-[air_contents.volume]L/s)", src.name, src.volume_rate) as num
			src.volume_rate = clamp(new_rate, 0, air_contents.volume)
			. = 1

	if(.)
		src.update_icon()

/obj/machinery/atmospherics/unary/outlet_injector/interface_interact(mob/user)
	ui_interact(user)
	return TRUE

/obj/machinery/atmospherics/unary/outlet_injector/Process()
	..()

	last_power_draw = 0
	last_flow_rate = 0

	if((inoperable()) || !use_power)
		return

	var/power_draw = -1
	var/datum/gas_mixture/environment = loc.return_air()

	if(environment && air_contents.temperature > 0)
		var/transfer_moles = (volume_rate/air_contents.volume)*air_contents.total_moles //apply flow rate limit
		power_draw = pump_gas(src, air_contents, environment, transfer_moles, power_rating)

	if (power_draw >= 0)
		last_power_draw = power_draw
		use_power_oneoff(power_draw)

		if(network)
			network.update = 1

	return 1

// This proc seems to only exist for compatibility
/obj/machinery/atmospherics/unary/outlet_injector/proc/inject()
	set waitfor = 0

	if(injecting || (!is_powered()))
		return 0

	var/datum/gas_mixture/environment = loc.return_air()
	if (!environment)
		return 0

	injecting = 1

	if(air_contents.temperature > 0)
		var/power_used = pump_gas(src, air_contents, environment, air_contents.total_moles, power_rating)
		use_power_oneoff(power_used)

		if(network)
			network.update = 1

	flick("inject", src)

/obj/machinery/atmospherics/unary/outlet_injector/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/atmospherics/unary/outlet_injector/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = list(
		"tag" = id,
		"device" = "AO",
		"power" = use_power,
		"volume_rate" = volume_rate,
		"sigtype" = "status"
	 )

	radio_connection.post_signal(src, signal)

	return 1

/obj/machinery/atmospherics/unary/outlet_injector/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || signal.data["tag"] != id || signal.data["sigtype"]!="command")
		return 0

	if(signal.data["power"])
		update_use_power(sanitize_integer(text2num(signal.data["power"]), POWER_USE_OFF, POWER_USE_ACTIVE, use_power))
		queue_icon_update()

	if(signal.data["power_toggle"] || signal.data["command"] == "valve_toggle") // some atmos buttons use "valve_toggle" as a command
		update_use_power(!use_power)
		queue_icon_update()

	if(signal.data["inject"])
		inject()
		return

	if(signal.data["set_volume_rate"])
		var/number = text2num(signal.data["set_volume_rate"])
		volume_rate = clamp(number, 0, air_contents.volume)

	if(signal.data["status"])
		addtimer(new Callback(src, PROC_REF(broadcast_status)), 2, TIMER_UNIQUE)
		return

	addtimer(new Callback(src, PROC_REF(broadcast_status)), 2, TIMER_UNIQUE)

/obj/machinery/atmospherics/unary/outlet_injector/hide(i)
	update_underlays()

/obj/machinery/atmospherics/unary/outlet_injector/use_tool(obj/item/O, mob/living/user, list/click_params)
	if(isWrench(O))
		new /obj/item/pipe(loc, src)
		qdel(src)
		return TRUE

	return ..()
