extends RefCounted

const Fighter := preload("res://src/dossier_curien/combatant.gd")
const Arena := preload("res://src/dossier_curien/arena.gd")

static func run(check: Callable) -> void:
	var a := Fighter.new(0, 400, 1)
	var b := Fighter.new(2, 485, -1)
	a.step(0,false,"light",b.x)
	check.call(not a.can_strike(b),"light has a startup")
	for tick in 4: a.step(0,false,"",b.x)
	check.call(a.can_strike(b),"light active at frame 5")
	b.guarding = true
	check.call(not a.hit(b) and b.health == 100,"guard stops light")
	check.call(not a.can_strike(b),"a blocked strike is consumed")
	check.call(not a.begin("heavy"),"guard does not confirm a cancel")
	a = Fighter.new(0,400,1)
	b = Fighter.new(2,485,-1)
	a.begin("throw")
	a.tick = 7
	b.guarding = true
	check.call(a.can_strike(b) and a.hit(b) and b.health == 84,"throw opens the guard")
	a = Fighter.new(0,400,1)
	a.begin("light")
	a.tick = 5
	b.guarding = false
	a.hit(b)
	check.call(a.begin("heavy"),"confirmed light cancels into heavy")
	a = Fighter.new(0,400,1)
	a.begin("special")
	a.tick = 12
	b.crouching = true
	check.call(a.ammo == 5 and not a.can_strike(b),"crouch avoids agent shot")
	a.action = ""
	a.begin("reload")
	for tick in 39: a.step(0,false,"",b.x)
	check.call(a.ammo == 5,"reload commits on completion")
	a.step(0,false,"",b.x)
	check.call(a.ammo == 6 and a.action == "","reload restores six shots")
	var scene := Arena.new()
	var pair := [Fighter.new(0,400,1), Fighter.new(1,490,-1)]
	for f in pair:
		f.begin("light")
		f.tick = 5
	scene.resolve_strikes(pair,false)
	check.call(pair[0].health == 93 and pair[1].health == 93,"simultaneous active strikes trade")
	for id in 4:
		var unique := {}
		for opponent in Fighter.STORY[id]:
			unique[opponent] = true
		check.call(unique.size() == 3 and not unique.has(id),"three distinct opponents in route %s" % id)
	seed(4102)
	var finalist := scene.simulate_semifinal(1,3)
	check.call(finalist in [1,3],"opposite semifinal yields a valid finalist")
	scene.audio_player.free()
	scene.free()
