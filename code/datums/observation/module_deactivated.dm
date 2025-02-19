//	Observer Pattern Implementation: Module Deactivated
//		Registration type: /mob/living/silicon/robot
//
//		Raised when: A robot deactivates a module.
//
//		Arguments that the called proc should expect:
//			/mob/living/silicon/robot/robot:  The robot that deactivated the module.
//			/obj/item/module:                 The deactivated module.

GLOBAL_TYPED_NEW(module_deactivated_event, /singleton/observ/module_deactivated)

/singleton/observ/module_deactivated
	name = "Module Deactivated"
	expected_type = /mob/living/silicon/robot

/******************************
* Module Deactivated Handling *
******************************/

// Called from /mob/living/silicon/robot/proc/uneq_active
// and /mob/living/silicon/robot/proc/uneq_all
// in code/modules/mob/living/silicon/robot/inventory.dm
