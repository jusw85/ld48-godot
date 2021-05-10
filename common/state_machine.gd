extends Reference


var state = -1
var _enter_funcs = []
var _process_funcs = []


func init_funcs(obj, states) -> void:
	for key in states.keys():
		var state_name = key.to_lower()
		var enter_func = funcref(obj, "_enter_%s" % state_name)
		var process_func = funcref(obj, "_process_%s" % state_name)
		assert(enter_func.is_valid())
		assert(process_func.is_valid())
		_enter_funcs.append(enter_func)
		_process_funcs.append(process_func)


func change_state(new_state, args: Array = [], allow_self_transition = true):
	if not allow_self_transition and state == new_state:
		return
	if args.empty():
		_enter_funcs[new_state].call_func()
	else:
		_enter_funcs[new_state].call_funcv(args)
	state = new_state


func process_state():
	_process_funcs[state].call_func()
