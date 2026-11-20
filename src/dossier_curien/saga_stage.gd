extends RefCounted

# Overlays are anchored to the stage edges. Their travel is independent from
# the backplate and the floor stays unobstructed between camera stops.
const TINTS := ["517172","5c756d","5a777e","796e64","865e56","967257","86677a","596879"]
const DARKS := ["273b43","293e3a","25383e","3b3834","453437","473a33","4c394d","2b3443"]

static func mid(c, stage: int, drift: float) -> void:
	var t := Color(TINTS[stage-3], 0.62)
	var dark := Color(DARKS[stage-3], 0.72)
	var x := -drift * 31
	match stage:
		3: # Reflected pinpoints move along the sheltered edge of the canal.
			for n in 7:
				var off := fposmod(float(n*193)+x,1280)
				var height := 545.0+sin(c.elapsed*0.025+n)*2
				c.draw_line(Vector2(off,height),Vector2(off+13+n%4,height),Color(t,0.23),1,true)
		4, 6: # Industrial conduit and blinking status lamps
			var side := 95.0 if stage == 4 else 1160.0
			for n in 3:
				c.draw_line(Vector2(side+x+n*11,145),Vector2(side+x+n*11,535),dark,5,true)
			c.draw_rect(Rect2(side+x-8,352,48,60),dark)
			for n in 2:
				c.draw_circle(Vector2(side+x+4+n*17,371),4,Color("b27b4f") if (int(c.elapsed/42.0)+n)%2==0 else t)
		5: # Platform warning strip, receding into the tunnel
			for n in 32:
				c.draw_line(Vector2(x+n*42,566),Vector2(x+n*42+23,566),t,3)
		7: # Balcony ironwork
			for n in 7:
				var off := 14.0+n*22+x
				c.draw_line(Vector2(off,412),Vector2(off,493),dark,4)
				c.draw_circle(Vector2(off,415),4,t)
			c.draw_line(Vector2(x,422),Vector2(161+x,422),dark,6)
		8, 9: # Fairground / game-show bulbs on suspended wires
			for n in 24:
				var off := n*59.0-20+x
				var h := 132+sin(n*0.32)*15
				c.draw_line(Vector2(off,h),Vector2(off+59,132+sin((n+1)*0.32)*15),dark,3,true)
				var warm := Color("ecbe71") if stage == 8 else Color("ed9fbb")
				c.draw_circle(Vector2(off,h+5),3,warm.lerp(t,0.45+0.35*sin(c.elapsed*0.08+n)))
		10: # Traffic barricade at the derelict crossing
			for off in [42.0, 1147.0]:
				c.draw_line(Vector2(off+x,513),Vector2(off+92+x,513),dark,10,true)
				for n in 5: c.draw_line(Vector2(off+x+n*18,516),Vector2(off+8+x+n*18,509),t,4,true)

static func front(c, stage: int, drift: float) -> void:
	var x := -drift*58
	var ink := Color(DARKS[stage-3]).darkened(0.52)
	ink.a = 0.88
	match stage:
		4, 6, 10:
			for edge in [-5.0,1264.0]:
				var y := 594.0
				c.draw_rect(Rect2(edge+x,y,15,160),ink)
				c.draw_line(Vector2(edge+x,y+12),Vector2(edge+x+65,y+64),ink,4,true)
		3:
			for pos in [-29.0,1274.0]:
				c.draw_colored_polygon(PackedVector2Array([Vector2(pos+x,661),Vector2(pos+x+6,617),Vector2(pos+x+26,615),Vector2(pos+x+35,661)]),ink)
		5:
			for x0 in [-35.0,1262.0]:
				c.draw_colored_polygon(PackedVector2Array([Vector2(x0+x,90),Vector2(x0+x+27,90),Vector2(x0+x+45,668),Vector2(x0+x,668)]),ink)
		7, 9:
			for side in [0,1]:
				var edge := x if side == 0 else 1280+x
				var direction := 1 if side == 0 else -1
				c.draw_colored_polygon(PackedVector2Array([Vector2(edge,95),Vector2(edge+64*direction,95),Vector2(edge+36*direction,217),Vector2(edge+7*direction,255)]),ink)
		8:
			for n in 2:
				c.draw_circle(Vector2(23+x+n*37,645),27,ink)
				c.draw_circle(Vector2(23+x+n*37,645),8,Color("614d3c"))
