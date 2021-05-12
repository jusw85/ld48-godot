extends Reference

var state = -1
var _states
var _enter_funcs = []
var _process_funcs = []


func init_funcs(p_obj, p_states) -> void:
	_states = p_states
	for key in p_states.keys():
		var state_name = key.to_lower()
		var enter_func = funcref(p_obj, "_enter_%s" % state_name)
		var process_func = funcref(p_obj, "_process_%s" % state_name)
		assert(enter_func.is_valid())
		assert(process_func.is_valid())
		_enter_funcs.append(enter_func)
		_process_funcs.append(process_func)


func change_state(p_new_state, p_args: Array = [], p_allow_self_transition = true):
	if not p_allow_self_transition and state == p_new_state:
		return
#	if state >= 0:
#		print("[" + _states.keys()[state] + "] TO [" + _states.keys()[p_new_state] + "]")
	if p_args.empty():
		_enter_funcs[p_new_state].call_func()
	else:
		_enter_funcs[p_new_state].call_funcv(p_args)
	state = p_new_state


func process_state():
	_process_funcs[state].call_func()
