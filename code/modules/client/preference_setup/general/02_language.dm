/datum/category_item/player_setup_item/general/language
	name = "Language"
	sort_order = 2

/datum/category_item/player_setup_item/general/language/load_character(var/savefile/S)
	S["language"] >> pref.alternate_languages
	S["autohiss"] >> pref.autohiss_setting

/datum/category_item/player_setup_item/general/language/save_character(var/savefile/S)
	S["language"] << pref.alternate_languages
	S["autohiss"] << pref.autohiss_setting

/datum/category_item/player_setup_item/general/language/gather_load_query()
	return list(
		"ss13_characters" = list(
			"vars" = list(
				"language" = "alternate_languages",
				"autohiss" = "autohiss_setting"
			),
			"args" = list("id")
		)
	)

/datum/category_item/player_setup_item/general/language/gather_load_parameters()
	return list("id" = pref.current_character)

/datum/category_item/player_setup_item/general/language/gather_save_query()
	return list(
		"ss13_characters" = list(
			"id" = 1,
			"ckey" = 1,
			"language",
			"autohiss"
		)
	)

/datum/category_item/player_setup_item/general/language/gather_save_parameters()
	return list(
		"language" = list2params(pref.alternate_languages),
		"autohiss" = pref.autohiss_setting,
		"id" = pref.current_character,
		"ckey" = PREF_CLIENT_CKEY
	)

/datum/category_item/player_setup_item/general/language/sanitize_character(var/sql_load = 0)

	if (sql_load)
		pref.alternate_languages = params2list(pref.alternate_languages)
		pref.autohiss_setting = text2num(pref.autohiss_setting)

	if(!islist(pref.alternate_languages))
		pref.alternate_languages = list()
		// Nothing to validate. Leave.
		return

	var/datum/species/S = GLOB.all_species[pref.species] || GLOB.all_species[SPECIES_HUMAN]

	if (pref.alternate_languages.len > S.num_alternate_languages)
		if(pref.client)
			to_chat(pref.client, "<span class='warning'>У вас выбрано слишком много языков для вашей расы.<br><b>Список был обнулён, пожалуйста проверьте его!</b></span>")
		pref.alternate_languages.Cut()
		return

	var/list/langs = S.secondary_langs.Copy()
	for (var/L in GLOB.all_languages)
		var/datum/language/lang = GLOB.all_languages[L]
		if (pref.client && !(lang.flags & RESTRICTED) && (!GLOB.config.usealienwhitelist || is_alien_whitelisted(pref.client.mob, L) || !(lang.flags & WHITELISTED)))
			langs |= L

	var/list/bad_langs = pref.alternate_languages - langs
	if (bad_langs.len)
		if(pref.client)
			to_chat(pref.client, "<span class='warning'>У вас выбраны недоступные языки! Пожалуйста, сохраните персонажа ещё раз чтобы решить проблему!</span>")

		for (var/L in bad_langs)
			if(pref.client)
				to_chat(pref.client, "<span class='notice'>Язык \"[L]\" был удалён.</span>")
			pref.alternate_languages -= L

		var/datum/category_group/player_setup_category/cat = category
		cat.modified = TRUE

/datum/category_item/player_setup_item/general/language/content(var/mob/user)
	var/list/dat = list("<b>Языки</b><br>")
	var/datum/species/S = GLOB.all_species[pref.species]
	if(S.language)
		dat += "- [S.language]<br>"
	if(S.default_language && S.default_language != S.language)
		dat += "- [S.default_language]<br>"
	if(S.num_alternate_languages)
		if(pref.alternate_languages.len)
			for(var/i = 1 to pref.alternate_languages.len)
				var/lang = pref.alternate_languages[i]
				dat += "- [lang] - <a href='?src=\ref[src];remove_language=[i]'>убрать</a><br>"

		if(pref.alternate_languages.len < S.num_alternate_languages)
			dat += "- <a href='?src=\ref[src];add_language=1'>add</a> ([S.num_alternate_languages - pref.alternate_languages.len] осталось)<br>"
	else
		dat += "- ваша раса не может выбирать другие языки.<br>"

	if(S.has_autohiss)
		pref.autohiss_setting = clamp(pref.autohiss_setting, AUTOHISS_OFF, AUTOHISS_NUM - 1)
		var/list/autohiss_to_word = list("Отключён", "Базовый", "Полный")
		dat += "<br><a href='?src=\ref[src];autohiss=1'>Акцент: [autohiss_to_word[pref.autohiss_setting + 1]]</a><br>"

	. = dat.Join()

/datum/category_item/player_setup_item/general/language/OnTopic(var/href,var/list/href_list, var/mob/user)
	if(href_list["remove_language"])
		var/index = text2num(href_list["remove_language"])
		if (index > 0 && index <= pref.alternate_languages.len)
			pref.alternate_languages -= pref.alternate_languages[index]

		return TOPIC_REFRESH
	else if(href_list["add_language"])
		var/datum/species/S = GLOB.all_species[pref.species]
		if(pref.alternate_languages.len >= S.num_alternate_languages)
			alert(user, "У вас выбрано максимальное количество языков для вашей расы!")
		else
			var/list/available_languages = S.secondary_langs.Copy()
			for(var/L in GLOB.all_languages)
				var/datum/language/lang = GLOB.all_languages[L]
				if(!(lang.flags & RESTRICTED) && (!GLOB.config.usealienwhitelist || is_alien_whitelisted(user, L) || !(lang.flags & WHITELISTED)))
					available_languages |= L

			// make sure we don't let them waste slots on the default languages
			available_languages -= S.language
			available_languages -= S.default_language
			available_languages -= pref.alternate_languages

			if(!available_languages.len)
				alert(user, "Вы выбрали все возможные языки.")
			else
				var/new_lang = input(user, "Выберите дополнительный язык", "Настройки", null) as null|anything in available_languages
				if(new_lang)
					if (pref.alternate_languages.len >= S.num_alternate_languages)
						alert(user, "У вас выбрано максимальное количество языков для вашей расы!")
					else
						pref.alternate_languages |= new_lang
					return TOPIC_REFRESH
	else if(href_list["autohiss"])
		pref.autohiss_setting = (pref.autohiss_setting + 1) % AUTOHISS_NUM
		if(isnull(pref.autohiss_setting))
			pref.autohiss_setting = AUTOHISS_OFF
		return TOPIC_REFRESH
	return ..()
