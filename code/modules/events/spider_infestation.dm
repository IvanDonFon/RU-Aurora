/var/global/sent_spiders_to_station = 0

/datum/event/spider_infestation
	announceWhen	= 90
	var/spawncount = 1
	ic_name = "неопознанные организмы"
	var/list/possible_spiders

/datum/event/spider_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 60)
	spawncount = rand(4 * severity, 6 * severity)	//spiderlings only have a 50% chance to grow big and strong
	sent_spiders_to_station = 0
	possible_spiders = typesof(/mob/living/simple_animal/hostile/giant_spider)

/datum/event/spider_infestation/announce()
	command_announcement.Announce("Внимание экипажу: обнаружены инородные организмы. Избегайте распространение во вне.", "Биологические сенсоры", new_sound = 'sound/AI/aliens.ogg', zlevels = affecting_z)

/datum/event/spider_infestation/start()
	..()

	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in SSmachinery.processing)
		if(!temp_vent.welded && temp_vent.network && isStationLevel(temp_vent.loc.z))
			if(temp_vent.network.normal_members.len > 50)
				vents += temp_vent

	while(spawncount && vents.len)
		var/obj/vent = pick(vents)
		new /obj/effect/spider/spiderling(vent.loc, null, 1, possible_spiders)
		vents -= vent
		spawncount--

// Moderate event cannot spawn nurses, ergo, they only terrorize but do not replicate.
/datum/event/spider_infestation/moderate/setup()
	..()
	possible_spiders -= /mob/living/simple_animal/hostile/giant_spider/nurse
