
/proc/communications_blackout(var/silent = 1)

	if(!silent)
		command_announcement.Announce("Внимание экипажу: Ионосферная аномалия. Ни в коем случ--БЗЗЖТ", new_sound = 'sound/AI/ionospheric.ogg')
	else // AIs will always know if there's a comm blackout, rogue AIs could then lie about comm blackouts in the future while they shutdown comms
		for(var/mob/living/silicon/ai/A in GLOB.player_list)
			to_chat(A, "<br>")
			to_chat(A, "<span class='warning'><b>Ionospheric anomalies detected. Temporary telecommunication failure imminent. Please contact you-BZZT</b></span>")
			to_chat(A, "<br>")
	for(var/obj/machinery/telecomms/T in SSmachinery.all_telecomms)
		T.emp_act(EMP_HEAVY)
