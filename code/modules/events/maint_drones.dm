/datum/event/rogue_maint_drones/start()
	..()

	var/drons = severity * 2 - 1
	var/groups = rand(3, 8)

	for(var/i = 0 to groups)
		var/list/spots = get_infestation_turfs()
		if(!LAZYLEN(spots))
			break
		var/turf/T = pick(spots)
		for(var/j = 0 to drons)
			new /mob/living/simple_animal/hostile/rogue_drone(T)

/datum/event/rogue_maint_drones/announce()
	var/stealth_chance = 70 - 20*severity
	if(prob(stealth_chance))
		return
	var/naming
	switch(severity)
		if(EVENT_LEVEL_MUNDANE)
			naming = "незначительный"
		if(EVENT_LEVEL_MODERATE)
			naming = "серьёзный"
		if(EVENT_LEVEL_MAJOR)
			naming = "беспрецедентный"
	command_announcement.Announce("Внимание экипажу: [naming] сбой в работе дронов. Фиксирую агрессивное поведение среди сбойных единиц. Избегайте перемещения по техническим тоннелям.", "Мониторинг дронов", zlevels = affecting_z)

/datum/event/rogue_maint_drones/proc/get_infestation_turfs()
	var/area/location = pick_area(list(/proc/is_not_space_area, /proc/is_station_area, /proc/is_maint_area))
	if(!location)
		LOG_DEBUG("Drone infestation failed to find a viable area. Aborting.")
		kill()
		return

	var/list/dron_turfs = get_area_turfs(location, list(/proc/not_turf_contains_dense_objects))
	if(!dron_turfs.len)
		LOG_DEBUG("Drone infestation failed to find viable turfs in \the [location].")
		kill()
		return
	return dron_turfs
