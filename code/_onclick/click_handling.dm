/*
	Custom click handling
*/

/// Populates `click_handlers` with the default handler if not already defined.
#define SETUP_CLICK_HANDLERS \
if(!click_handlers) { \
	click_handlers = new(); \
	click_handlers += new/datum/click_handler/default(src) \
}

/**
 * LAZYLIST (Instances of `/datum/click_handler`). Click handlers for this mob that should intercept and handle click
 * calls.
 *
 * The 'topmost'/'active' click handler for the mob is the handler currently at index `1`. By default, this will be
 * `/datum/click_handler/default`.
 */
/mob/var/list/click_handlers

/mob/Destroy()
	QDEL_NULL_LIST(click_handlers)
	return ..()

/// Removes this click handler on `/mob/Logout()`.
var/global/const/CLICK_HANDLER_REMOVE_ON_MOB_LOGOUT = FLAG_01
/// Removes and prevents creation of the click handler if it is not the active handler for the mob.
var/global/const/CLICK_HANDLER_REMOVE_IF_NOT_TOP    = FLAG_02

/datum/click_handler
	/// The mob this click handler is attached to.
	var/mob/user

	/**
	 * Bitfield (Any of `CLICK_HANDLER_*`). Relevant flags to control the logic flow of this click handler.
	 *
	 * See `code\_onclick\click_handling.dm` for valid options.
	 */
	var/flags = FLAGS_OFF

/datum/click_handler/New(mob/user)
	..()
	src.user = user
	if (HAS_FLAGS(flags, CLICK_HANDLER_REMOVE_ON_MOB_LOGOUT))
		GLOB.logged_out_event.register(user, src, PROC_REF(OnMobLogout))

/datum/click_handler/Destroy()
	if (HAS_FLAGS(flags, CLICK_HANDLER_REMOVE_ON_MOB_LOGOUT))
		GLOB.logged_out_event.unregister(user, src, PROC_REF(OnMobLogout))
	user = null
	. = ..()

/**
 * Called when the click handler becomes the active entry in the mob's click handlers list. Called by
 * `PushClickHandler()` and `RemoveClickHandler()`.
 *
 * Has no return value.
 */
/datum/click_handler/proc/Enter()
	return

/**
 * Called when the click handler was active in the mob's click handler list and has been replaced by another handler or
 * otherwise removed. Called by `PushClickHandler()` and `RemoveClickHandler()`.
 *
 * Has no return value.
 */
/datum/click_handler/proc/Exit()
	return

/**
 * Event proc for `logged_out_event`. Called when the mob logs out and this click handler has the
 * `CLICK_HANDLER_REMOVE_ON_MOB_LOGOUT` flag set.
 *
 * By default, this removes the click handler from the assigned mob.
 *
 * Has no return value.
 */
/datum/click_handler/proc/OnMobLogout()
	user.RemoveClickHandler(src)

/**
 * Called on click by `/atom/Click()` when this is the mob's currently active click handler.
 *
 * **Parameters**:
 * - `A` - The atom clicked on.
 * - `params` (list of strings) - List of click parameters. See BYOND's `CLick()` documentation.
 *
 * Has no return value.
 */
/datum/click_handler/proc/OnClick(atom/A, params)
	return

/**
 * Called on doubleclick by `/atom/DblClick()` when this is the mob's currently active click handler.
 *
 * **Parameters**:
 * - `A` - The atom double clicked on.
 * - `params` (list of strings) - List of click parameters. See BYOND's `CLick()` documentation.
 *
 * Has no return value.
 */
/datum/click_handler/proc/OnDblClick(atom/A, params)
	return

/**
 * Called on MouseDown by `/client/MouseDown()` when this is the mob's currently active click handler.
 *
 * **Parameters**:
 * - `object` - The atom mouse is underneath.
 * - `location` - the turf, stat panel, grid cell, etc. containing the object where it was clicked
 * - `params` (list of strings) - List of click parameters. See BYOND's `CLick()` documentation.
 *
 * Has no return value.
 */
/datum/click_handler/proc/OnMouseDown(object, location, params)
	return

/**
 * Called on MouseUp by `/client/MouseUp()` when this is the mob's currently active click handler.
 *
 * **Parameters**:
 * - `object` - The atom underneath mouse.
 * - `location` - the turf, stat panel, grid cell, etc. containing the object where it was clicked
 * - `params` (list of strings) - List of click parameters. See BYOND's `CLick()` documentation.
 *
 * Has no return value.
 */
/datum/click_handler/proc/OnMouseUp(object, location, params)
	return

/**
 * Called on MouseUp by `/client/MouseDrag()` when this is the mob's currently active click handler.
 *
 * **Parameters**:
 * - `over_object` - The new atom underneath mouse.
 * - `params` (list of strings) - List of click parameters. See BYOND's `CLick()` documentation.
 *
 * Has no return value.
 */
/datum/click_handler/proc/OnMouseDrag(atom/over_object, params)
	return

/datum/click_handler/proc/CanAutoClick(object, location, params)
	return

/datum/click_handler/default
	/// Holds click params [2] and a reference [1] to the atom under the cursor on MouseDown/Drag
	var/list/selected_target = list(null, null)

/datum/click_handler/default/OnClick(atom/A, params)
	user.ClickOn(A, params)

/datum/click_handler/default/OnDblClick(atom/A, params)
	user.DblClickOn(A, params)

/datum/click_handler/default/OnMouseDown(object, location, params)
	var/delay = CanAutoClick(object, location, params)
	if(delay)
		selected_target[1] = object
		selected_target[2] = params
		while(selected_target[1])
			OnClick(selected_target[1], selected_target[2])
			sleep(delay)

/datum/click_handler/default/OnMouseUp(object, location, params)
	selected_target[1] = null

/datum/click_handler/default/OnMouseDrag(atom/over_object, params)
	if(selected_target[1] && over_object && over_object.IsAutoclickable()) //Over object could be null, for example if dragging over darkness
		selected_target[1] = over_object
		selected_target[2] = params

/datum/click_handler/default/CanAutoClick(object, location, params)
	return user.CanMobAutoclick(object, location, params)

/**
 * Returns the mob's currently active click handler.
 *
 * **Parameters**:
 * - `popped_handler`. Not used, should probably be removed?
 */
/mob/proc/GetClickHandler(datum/click_handler/popped_handler)
	SETUP_CLICK_HANDLERS
	return click_handlers[1]

/**
 * Removes the given click handler from `click_handlers`.
 *
 * This will not remove the protected default handler.
 *
 * **Parameters**:
 * - `click_handler` (Path or instance of `/datum/click_handler`) - The handler to remove. If a path, finds the first
 * matching instance of that type.
 *
 * Returns boolean. Whether or not the click handler was found and removed.
 */
/mob/proc/RemoveClickHandler(datum/click_handler/click_handler)
	if(!click_handlers)
		return FALSE
	if(ispath(click_handler)) // If we were given a path instead of an instance, find the first matching instance by type
		// No removing of the default click handler
		if(click_handler == /datum/click_handler/default)
			return FALSE
		click_handler = get_instance_of_strict_type(click_handlers, click_handler)
	if(!click_handler)
		return FALSE

	. = (click_handler in click_handlers)
	if(!.)
		return

	var/was_top = click_handlers[1] == click_handler

	if(was_top)
		click_handler.Exit()
	click_handlers.Remove(click_handler)
	qdel(click_handler)

	if(!was_top)
		return
	click_handler = click_handlers[1]
	if(click_handler)
		click_handler.Enter()

/**
 * Pushes the given click handler to the top of the `click_handlers` list, making it the active handler.
 *
 * **Parameters**:
 * - `new_click_handler_type` (Type path - Type of `/datum/click_handler`). The click handler to make active.
 *
 * Returns boolean. If `TRUE`, the click handler was successfully pushed to the top. Returns `FALSE` if the handler was
 * already active.
 */
/mob/proc/PushClickHandler(datum/click_handler/new_click_handler_type)
	// No manipulation of the default click handler
	if(new_click_handler_type == /datum/click_handler/default)
		return FALSE
	if (HAS_FLAGS(initial(new_click_handler_type.flags), CLICK_HANDLER_REMOVE_ON_MOB_LOGOUT) && !client)
		return FALSE
	SETUP_CLICK_HANDLERS

	var/datum/click_handler/click_handler = click_handlers[1]
	if(click_handler.type == new_click_handler_type)
		return FALSE // If the top click handler is already the same as the desired one, bow out

	click_handler.Exit()
	if (HAS_FLAGS(click_handler.flags, CLICK_HANDLER_REMOVE_IF_NOT_TOP))
		click_handlers.Remove(click_handler)
		qdel(click_handler)

	click_handler = get_instance_of_strict_type(click_handlers, click_handler)
	if(click_handler)
		click_handlers.Remove(click_handler)
	else
		click_handler = new new_click_handler_type(src)

	click_handlers.Insert(1, click_handler) // Insert new handlers first
	click_handler.Enter()
	return TRUE

#undef SETUP_CLICK_HANDLERS
