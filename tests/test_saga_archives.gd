extends SceneTree

const Archives := preload("res://src/dossier_curien/saga_archives.gd")
const Fighter := preload("res://src/dossier_curien/combatant.gd")

class Table:
	var fighters := [Fighter.new(5, 340, 1), Fighter.new(2, 560, -1)]
	var clock_ticks := 3600
	var route := 0
	var wins := [0, 0]
	var stage := 0
	func sound(_cue: String): pass

var failures := 0

func require(value: bool, detail: String) -> void:
	if not value:
		push_error(detail)
		failures += 1

func key_input(service, board, id: String, key: int) -> void:
	var event := InputEventKey.new()
	event.keycode = key as Key
	event.unicode = key
	event.pressed = true
	service.handle_key(board, id, event)

func strike(service, board, id: String, action: String) -> void:
	board.fighters[1].health -= 1
	board.fighters[0].action = action
	board.fighters[0].confirmed = true
	service.tick(board, id)

func _initialize() -> void:
	var rules := Archives.new()
	var seen := {}
	for item in rules.entries():
		var board := Table.new()
		var id: String = item.id
		require(not seen.has(id), "Duplicate archive "+id)
		seen[id] = true
		rules.start_round(board, id)
		require(not rules.hud_line(board, id).is_empty(), id+" briefing")
		match item.rule:
			"word","translation":
				key_input(rules,board,id,KEY_TAB)
				require(rules.terminal, id+" opens")
				board.clock_ticks = 2620
				for letter in rules.target_word(): key_input(rules,board,id,letter.unicode_at(0))
				key_input(rules,board,id,KEY_ENTER)
				require(not rules.terminal, id+" closes")
				if id == "typing_budget": require(board.clock_ticks == 2680, "PC 2005 restores one second")
				if id == "lariat_win": require(board.fighters[1].stun == 32, "Windows Lariat throw opening")
			"flick":
				key_input(rules,board,id,KEY_TAB)
				for direction in [KEY_LEFT,KEY_UP,KEY_RIGHT]: key_input(rules,board,id,direction)
			"darts","locks":
				for j in (3 if item.rule == "locks" else 1):
					while absf(rules.meter()-50) > 10 or rules.age < rules.next_award: rules.tick(board,id)
					key_input(rules,board,id,KEY_TAB)
			"pinball":
				for j in 3:
					for t in 400:
						rules.tick(board,id)
						if rules.ball.y >= 46 and rules.velocity.y > 0: break
					key_input(rules,board,id,KEY_TAB)
			"battery": strike(rules,board,id,"special")
			"lab","reel":
				for a in (["light","heavy","throw"] if item.rule == "lab" else ["light","heavy","special"]):
					strike(rules,board,id,a)
			"relay":
				require(board.stage == 3, "Canal in opening round")
				board.wins[0] = 1
				rules.start_round(board,id)
				require(board.stage == 4, "EFI in second round")
				strike(rules,board,id,"heavy")
			"sector":
				for p in [340,930,340]:
					board.fighters[0].x = p
					for t in 47: rules.tick(board,id)
			"rescue": strike(rules,board,id,"heavy")
			"openings":
				for signal_tick in [48, 168, 288]:
					while rules.age < signal_tick: rules.tick(board,id)
					key_input(rules,board,id,KEY_TAB)
				require(board.fighters[1].health == 88, id+" three openings deal 12 damage")
			_: require(false,id+" unknown rule")
		require(rules.score == 1,id+" scores once")
		require(board.fighters[1].health < 100,id+" affects the match")
		rules.start_round(board,id)
		require(rules.score == 0 and not rules.terminal,id+" resets")
	print("%d archives exercised, %d failures" % [seen.size(),failures])
	quit(1 if failures else 0)
