/obj/item/clothing/suit/solgov
	abstract_type = /obj/item/clothing/suit/solgov
	name = "master solgov suit"
	icon = 'maps/torch/icons/obj/obj_suit_solgov.dmi'
	item_icons = list(slot_wear_suit_str = 'maps/torch/icons/mob/onmob_suit_solgov.dmi')
	sprite_sheets = list(
		SPECIES_UNATHI = 'maps/torch/icons/mob/unathi/onmob_suit_solgov_unathi.dmi'
	)


/obj/item/clothing/suit/storage/solgov
	abstract_type = /obj/item/clothing/suit/storage/solgov
	name = "master solgov suit with pockets"
	icon = 'maps/torch/icons/obj/obj_suit_solgov.dmi'
	item_icons = list(slot_wear_suit_str = 'maps/torch/icons/mob/onmob_suit_solgov.dmi')
	sprite_sheets = list(
		SPECIES_UNATHI = 'maps/torch/icons/mob/unathi/onmob_suit_solgov_unathi.dmi'
	)


//Service

/obj/item/clothing/suit/storage/solgov/service
	name = "service jacket"
	desc = "A uniform service jacket, plain and undecorated."
	icon_state = "blackservice"
	body_parts_covered = UPPER_TORSO|ARMS
	siemens_coefficient = 0.9
	allowed = list(
		/obj/item/tank/oxygen_emergency,
		/obj/item/tank/oxygen_emergency_extended,
		/obj/item/tank/nitrogen_emergency,
		/obj/item/device/flashlight,
		/obj/item/pen,
		/obj/item/clothing/head/soft,
		/obj/item/clothing/head/beret,
		/obj/item/storage/fancy/smokable,
		/obj/item/flame/lighter,
		/obj/item/device/taperecorder,
		/obj/item/device/scanner/gas,
		/obj/item/device/radio,
		/obj/item/taperoll
	)
	valid_accessory_slots = list(
		ACCESSORY_SLOT_ARMBAND,
		ACCESSORY_SLOT_MEDAL,
		ACCESSORY_SLOT_INSIGNIA,
		ACCESSORY_SLOT_RANK,
		ACCESSORY_SLOT_FLASH,
		ACCESSORY_SLOT_DECOR
	)
	restricted_accessory_slots = list(ACCESSORY_SLOT_ARMBAND)

/obj/item/clothing/suit/storage/solgov/service/expeditionary
	name = "expeditionary jacket"
	desc = "A uniform service jacket belonging to the SCG Expeditionary Corps."
	icon_state = "ecservice_crew"

/obj/item/clothing/suit/storage/solgov/service/expeditionary/command
	icon_state = "ecservice_officer"
	item_state = "ecservice_officer"

/obj/item/clothing/suit/storage/solgov/service/expeditionary/medical
	accessories = list(/obj/item/clothing/accessory/solgov/department/medical/service)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/suit/storage/solgov/service/expeditionary/command/medical
	accessories = list(/obj/item/clothing/accessory/solgov/department/medical/service)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/suit/storage/solgov/service/expeditionary/engineering
	accessories = list(/obj/item/clothing/accessory/solgov/department/engineering/service)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/suit/storage/solgov/service/expeditionary/command/engineering
	accessories = list(/obj/item/clothing/accessory/solgov/department/engineering/service)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/suit/storage/solgov/service/expeditionary/supply
	accessories = list(/obj/item/clothing/accessory/solgov/department/supply/service)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/suit/storage/solgov/service/expeditionary/command/supply
	accessories = list(/obj/item/clothing/accessory/solgov/department/supply/service)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/suit/storage/solgov/service/expeditionary/security
	accessories = list(/obj/item/clothing/accessory/solgov/department/security/service)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/suit/storage/solgov/service/expeditionary/command/security
	accessories = list(/obj/item/clothing/accessory/solgov/department/security/service)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/suit/storage/solgov/service/expeditionary/service
	accessories = list(/obj/item/clothing/accessory/solgov/department/service/service)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/suit/storage/solgov/service/expeditionary/command/service
	accessories = list(/obj/item/clothing/accessory/solgov/department/service/service)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/suit/storage/solgov/service/expeditionary/exploration
	accessories = list(/obj/item/clothing/accessory/solgov/department/exploration/service)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/suit/storage/solgov/service/expeditionary/command/exploration
	accessories = list(/obj/item/clothing/accessory/solgov/department/exploration/service)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/suit/storage/solgov/service/expeditionary/research
	accessories = list(/obj/item/clothing/accessory/solgov/department/research/service)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/suit/storage/solgov/service/expeditionary/command/research
	accessories = list(/obj/item/clothing/accessory/solgov/department/research/service)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/suit/storage/solgov/service/expeditionary/command/command
	accessories = list(/obj/item/clothing/accessory/solgov/department/command/service)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/suit/storage/solgov/service/fleet
	name = "fleet service jacket"
	desc = "A navy blue SCG Fleet service jacket."
	icon_state = "blueservice"
	item_state = "blueservice"

/obj/item/clothing/suit/storage/solgov/service/fleet/snco
	name = "fleet SNCO service jacket"
	desc = "A navy blue SCG Fleet service jacket with silver cuffs."
	icon_state = "blueservice_snco"
	item_state = "blueservice_snco"

/obj/item/clothing/suit/storage/solgov/service/fleet/officer
	name = "fleet officer's service jacket"
	desc = "A navy blue SCG Fleet dress jacket with silver accents."
	icon_state = "blueservice_off"
	item_state = "blueservice_off"

/obj/item/clothing/suit/storage/solgov/service/fleet/command
	name = "fleet senior officer's service jacket"
	desc = "A navy blue SCG Fleet dress jacket with gold accents."
	icon_state = "blueservice_comm"
	item_state = "blueservice_comm"

/obj/item/clothing/suit/storage/solgov/service/fleet/flag
	name = "fleet flag officer's service jacket"
	desc = "A navy blue SCG Fleet dress jacket with red accents."
	icon_state = "blueservice_flag"
	item_state = "blueservice_flag"

//Fleet Service Sweater

/obj/item/clothing/suit/solgov/fleet_sweater
	name = "fleet service sweater"
	desc = "A navy blue SCG Fleet service sweater."
	icon_state = "fleet_sweater"
	item_state = "fleet_sweater"
	body_parts_covered = UPPER_TORSO|ARMS
	allowed = null
	valid_accessory_slots = list(
		ACCESSORY_SLOT_ARMBAND,
		ACCESSORY_SLOT_MEDAL,
		ACCESSORY_SLOT_INSIGNIA,
		ACCESSORY_SLOT_RANK,
		ACCESSORY_SLOT_FLASH,
		ACCESSORY_SLOT_DECOR
	)
	restricted_accessory_slots = list(
		ACCESSORY_SLOT_ARMBAND,
		ACCESSORY_SLOT_RANK,
		ACCESSORY_SLOT_FLASH
	)

/obj/item/clothing/suit/solgov/fleet_sweater/officer
	name = "fleet officer's service sweater"
	desc = "A navy blue SCG Fleet service sweater with silver accents."
	icon_state = "fleet_sweater_off"
	item_state = "fleet_sweater_off"

/obj/item/clothing/suit/solgov/fleet_sweater/command
	name = "fleet senior officer's service sweater"
	desc = "A navy blue SCG Fleet service sweater with gold accents."
	icon_state = "fleet_sweater_comm"
	item_state = "fleet_sweater_comm"

/obj/item/clothing/suit/solgov/fleet_sweater/flag
	name = "fleet flag officer's service sweater"
	desc = "A navy blue SCG Fleet serivce sweater with red accents."
	icon_state = "fleet_sweater_flag"
	item_state = "fleet_sweater_flag"

//Dress - murder me with a gun why are these 3 different types

/obj/item/clothing/suit/storage/solgov/dress
	name = "dress jacket"
	desc = "A uniform dress jacket, plain and undecorated."
	icon_state = "ecdress_xpl"
	item_state = "ecdress_xpl"
	body_parts_covered = UPPER_TORSO|ARMS
	siemens_coefficient = 0.9
	valid_accessory_slots = list(ACCESSORY_SLOT_MEDAL,ACCESSORY_SLOT_RANK, ACCESSORY_SLOT_INSIGNIA)
	restricted_accessory_slots = list(ACCESSORY_SLOT_ARMBAND)

/obj/item/clothing/suit/storage/solgov/dress/expedition
	name = "expeditionary dress coat"
	desc = "A silver and black dress peacoat belonging to the SCG Expeditionary Corps. Fashionable, for the 25th century at least."
	icon_state = "ecdress_xpl"
	item_state = "ecdress_xpl"

/obj/item/clothing/suit/storage/solgov/dress/expedition/senior
	name = "expeditionary senior's dress coat"
	icon_state = "ecdress_sxpl"
	item_state = "ecdress_sxpl"

/obj/item/clothing/suit/storage/solgov/dress/expedition/chief
	name = "expeditionary chief's dress coat"
	icon_state = "ecdress_cxpl"
	item_state = "ecdress_cxpl"

/obj/item/clothing/suit/storage/solgov/dress/expedition/command
	name = "expeditionary officer's dress coat"
	desc = "A gold and black dress peacoat belonging to the SCG Expeditionary Corps. The height of fashion."
	icon_state = "ecdress_ofcr"
	item_state = "ecdress_ofcr"

/obj/item/clothing/suit/storage/solgov/dress/expedition/command/cdr
	name = "expeditionary commander's dress coat"
	icon_state = "ecdress_cdr"
	item_state = "ecdress_cdr"

/obj/item/clothing/suit/storage/solgov/dress/expedition/command/capt
	name = "expeditionary captain's dress coat"
	icon_state = "ecdress_capt"
	item_state = "ecdress_capt"

/obj/item/clothing/suit/storage/solgov/dress/expedition/command/adm
	name = "expeditionary admiral's dress coat"
	icon_state = "ecdress_adm"
	item_state = "ecdress_adm"

/obj/item/clothing/suit/storage/solgov/dress/fleet
	name = "fleet dress jacket"
	desc = "A navy blue SCG Fleet dress jacket. Don't get near pasta sauce or vox."
	icon_state = "whitedress"
	item_state = "whitedress"

/obj/item/clothing/suit/storage/solgov/dress/fleet/snco
	name = "fleet dress SNCO jacket"
	desc = "A navy blue SCG Fleet dress jacket with silver cuffs. Don't get near pasta sauce or vox."
	icon_state = "whitedress_snco"
	item_state = "whitedress_snco"

/obj/item/clothing/suit/storage/solgov/dress/fleet/officer
	name = "fleet officer's dress jacket"
	desc = "A navy blue SCG Fleet dress jacket with silver accents. Don't get near pasta sauce or vox."
	icon_state = "whitedress_off"
	item_state = "whitedress_off"

/obj/item/clothing/suit/storage/solgov/dress/fleet/command
	name = "fleet senior officer's dress jacket"
	desc = "A navy blue SCG Fleet dress jacket with gold accents. Don't get near pasta sauce or vox."
	icon_state = "whitedress_comm"
	item_state = "whitedress_comm"

/obj/item/clothing/suit/storage/solgov/dress/fleet/flag
	name = "fleet flag officer's dress jacket"
	desc = "A navy blue SCG Fleet dress jacket with red accents. Don't get near pasta sauce or vox."
	icon_state = "whitedress_flag"
	item_state = "whitedress_flag"

/obj/item/clothing/suit/dress/solgov
	name = "dress jacket"
	desc = "A uniform dress jacket, fancy."
	icon_state = "blackdress"
	item_state = "blackdress"
	icon = 'maps/torch/icons/obj/obj_suit_solgov.dmi'
	item_icons = list(slot_wear_suit_str = 'maps/torch/icons/mob/onmob_suit_solgov.dmi')
	body_parts_covered = UPPER_TORSO|ARMS
	siemens_coefficient = 0.9
	allowed = list(
		/obj/item/tank/oxygen_emergency,
		/obj/item/tank/oxygen_emergency_extended,
		/obj/item/tank/nitrogen_emergency,
		/obj/item/device/flashlight,
		/obj/item/clothing/head/soft,
		/obj/item/clothing/head/beret,
		/obj/item/device/radio,
		/obj/item/pen
	)
	valid_accessory_slots = list(ACCESSORY_SLOT_MEDAL,ACCESSORY_SLOT_RANK,ACCESSORY_SLOT_INSIGNIA)

/obj/item/clothing/suit/dress/solgov/fleet/sailor
	name = "fleet dress overwear"
	desc = "A navy blue SCG Fleet dress suit. Almost looks like a school-girl outfit."
	icon_state = "sailordress"
	item_state = "sailordress"


//Misc

/obj/item/clothing/suit/storage/hooded/wintercoat/solgov
	name = "expeditionary winter coat"
	icon_state = "coatec"
	icon = 'maps/torch/icons/obj/obj_suit_solgov.dmi'
	item_icons = list(slot_wear_suit_str = 'maps/torch/icons/mob/onmob_suit_solgov.dmi')
	valid_accessory_slots = list(ACCESSORY_SLOT_INSIGNIA,ACCESSORY_SLOT_RANK)


/obj/item/clothing/suit/storage/hooded/wintercoat/solgov/fleet
	name = "fleet winter coat"
	icon_state = "coatfl"
	valid_accessory_slots = list(ACCESSORY_SLOT_INSIGNIA)


//SolGov Hardsuits

/obj/item/clothing/suit/space/void/engineering/alt/sol
	icon = 'maps/torch/icons/obj/obj_suit_solgov.dmi'
	item_icons = list(slot_wear_suit_str = 'maps/torch/icons/mob/onmob_suit_solgov.dmi')
	sprite_sheets = list(
		SPECIES_UNATHI = 'maps/torch/icons/mob/unathi/onmob_suit_spacesuits_solgov_unathi.dmi',
		SPECIES_SKRELL = 'maps/torch/icons/mob/skrell/onmob_suit_solgov_skrell.dmi',
		)
	sprite_sheets_obj = list(
		SPECIES_UNATHI = 'maps/torch/icons/obj/unathi/obj_suit_solgov_unathi.dmi',
		SPECIES_SKRELL = 'maps/torch/icons/obj/skrell/obj_suit_solgov_skrell.dmi',
		)

/obj/item/clothing/suit/space/void/engineering/alt/sol/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/engineering/alt/sol
	boots = /obj/item/clothing/shoes/magboots
	item_flags = ITEM_FLAG_THICKMATERIAL | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/suit/space/void/atmos/alt/sol
	icon = 'maps/torch/icons/obj/obj_suit_solgov.dmi'
	item_icons = list(slot_wear_suit_str = 'maps/torch/icons/mob/onmob_suit_solgov.dmi')
	sprite_sheets = list(
		SPECIES_UNATHI = 'maps/torch/icons/mob/unathi/onmob_suit_spacesuits_solgov_unathi.dmi',
		SPECIES_SKRELL = 'maps/torch/icons/mob/skrell/onmob_suit_solgov_skrell.dmi',
		)
	sprite_sheets_obj = list(
		SPECIES_UNATHI = 'maps/torch/icons/obj/unathi/obj_suit_solgov_unathi.dmi',
		SPECIES_SKRELL = 'maps/torch/icons/obj/skrell/obj_suit_solgov_skrell.dmi',
		)

/obj/item/clothing/suit/space/void/atmos/alt/sol/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/atmos/alt/sol
	boots = /obj/item/clothing/shoes/magboots
	item_flags = ITEM_FLAG_THICKMATERIAL | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/suit/space/void/pilot/sol
	icon = 'maps/torch/icons/obj/obj_suit_solgov.dmi'
	item_icons = list(slot_wear_suit_str = 'maps/torch/icons/mob/onmob_suit_solgov.dmi')
	sprite_sheets = list(
		SPECIES_UNATHI = 'maps/torch/icons/mob/unathi/onmob_suit_spacesuits_solgov_unathi.dmi',
		SPECIES_SKRELL = 'maps/torch/icons/mob/skrell/onmob_suit_solgov_skrell.dmi',
		)
	sprite_sheets_obj = list(
		SPECIES_UNATHI = 'maps/torch/icons/obj/unathi/obj_suit_solgov_unathi.dmi',
		SPECIES_SKRELL = 'maps/torch/icons/obj/skrell/obj_suit_solgov_skrell.dmi',
		)

/obj/item/clothing/suit/space/void/pilot/sol/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/pilot/sol
	boots = /obj/item/clothing/shoes/magboots
	item_flags = ITEM_FLAG_THICKMATERIAL | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/suit/space/void/medical/alt/sol
	icon = 'maps/torch/icons/obj/obj_suit_solgov.dmi'
	item_icons = list(slot_wear_suit_str = 'maps/torch/icons/mob/onmob_suit_solgov.dmi')
	sprite_sheets = list(
		SPECIES_UNATHI = 'maps/torch/icons/mob/unathi/onmob_suit_spacesuits_solgov_unathi.dmi',
		SPECIES_SKRELL = 'maps/torch/icons/mob/skrell/onmob_suit_solgov_skrell.dmi',
		)
	sprite_sheets_obj = list(
		SPECIES_UNATHI = 'maps/torch/icons/obj/unathi/obj_suit_solgov_unathi.dmi',
		SPECIES_SKRELL = 'maps/torch/icons/obj/skrell/obj_suit_solgov_skrell.dmi',
		)

/obj/item/clothing/suit/space/void/medical/alt/sol/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/medical/alt/sol
	boots = /obj/item/clothing/shoes/magboots
	item_flags = ITEM_FLAG_THICKMATERIAL | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/suit/space/void/command
	name = "command voidsuit"
	desc = "A light, radiation resistant voidsuit commonly used among SCG uniformed services. This one has an EC seal on its chest plate and command department markings."
	icon = 'maps/torch/icons/obj/obj_suit_solgov.dmi'
	item_icons = list(slot_wear_suit_str = 'maps/torch/icons/mob/onmob_suit_solgov.dmi')
	icon_state = "rig_command"
	item_state = "rig_command"
	sprite_sheets = list(
		SPECIES_UNATHI = 'maps/torch/icons/mob/unathi/onmob_suit_spacesuits_solgov_unathi.dmi',
		SPECIES_SKRELL = 'maps/torch/icons/mob/skrell/onmob_suit_solgov_skrell.dmi',
		)
	sprite_sheets_obj = list(
		SPECIES_UNATHI = 'maps/torch/icons/obj/unathi/obj_suit_solgov_unathi.dmi',
		SPECIES_SKRELL = 'maps/torch/icons/obj/skrell/obj_suit_solgov_skrell.dmi',
		)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/storage/briefcase/inflatable)

/obj/item/clothing/suit/space/void/command/Initialize()
	. = ..()
	slowdown_per_slot[slot_wear_suit] = 0.75

/obj/item/clothing/suit/space/void/command/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/command
	boots = /obj/item/clothing/shoes/magboots
	item_flags = ITEM_FLAG_THICKMATERIAL | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/suit/space/void/exploration
	name = "exploration voidsuit"
	icon = 'maps/torch/icons/obj/obj_suit_solgov.dmi'
	item_icons = list(slot_wear_suit_str = 'maps/torch/icons/mob/onmob_suit_solgov.dmi')
	desc = "The bulky Exoplanet Exploration Unit is a standard voidsuit for Expeditionary Corps field operations. It features extra padding and respectable radiation-resistant lining."
	icon_state = "rig_explorer"
	item_state = "rig_explorer"
	sprite_sheets = list(
		SPECIES_UNATHI = 'maps/torch/icons/mob/unathi/onmob_suit_spacesuits_solgov_unathi.dmi',
		SPECIES_SKRELL = 'maps/torch/icons/mob/skrell/onmob_suit_solgov_skrell.dmi',
		)
	sprite_sheets_obj = list(
		SPECIES_UNATHI = 'maps/torch/icons/obj/unathi/obj_suit_solgov_unathi.dmi',
		SPECIES_SKRELL = 'maps/torch/icons/obj/skrell/obj_suit_solgov_skrell.dmi',
		)
	armor = list(
		melee = ARMOR_MELEE_RESISTANT,
		bullet = ARMOR_BALLISTIC_MINOR,
		laser = ARMOR_LASER_MINOR,
		energy = ARMOR_ENERGY_RESISTANT,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
		)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/stack/flag,/obj/item/device/scanner/health,/obj/item/device/gps,/obj/item/pinpointer/radio,/obj/item/material/hatchet/machete,/obj/item/shovel)

/obj/item/clothing/suit/space/void/exploration/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/exploration
	boots = /obj/item/clothing/shoes/magboots
	item_flags = ITEM_FLAG_THICKMATERIAL | ITEM_FLAG_INVALID_FOR_CHAMELEON
