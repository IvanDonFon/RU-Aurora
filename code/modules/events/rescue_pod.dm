/datum/event/rescue_pod
	no_fake = 1
	var/spawner_name = "rescuepodsurv"
	var/datum/ghostspawner/human/rescuepodsurv/spawner

/datum/event/rescue_pod/announce()
	if(prob(66))
		command_announcement.Announce("Внимание экипажу: Зафиксировано прибытие спасательной капсулы на орбиту небесного тела.", new_title="Сенсоры SCCV Горизонт", new_sound = 'sound/AI/commandreport.ogg', zlevels = affecting_z)

/datum/event/rescue_pod/setup()
	for(var/datum/event/E in typesof(src))
		if(is_type_in_list(E, SSevents.finished_events))
			kill(TRUE)
			return
	spawner = SSghostroles.get_spawner(spawner_name)

/datum/event/rescue_pod/start()
	..()

	if(istype(spawner))
		spawner.enable()

/datum/event/rescue_pod/burglar
	no_fake = 1
	spawner_name = "burglarpod"

/datum/event/rescue_pod/burglar/announce()
	if(prob(33)) // Make a silent drop more likely since they're spooky burglar
		..()

/datum/event/rescue_pod/burglar/start()
	..()

	if(istype(spawner))
		spawner.enable()
