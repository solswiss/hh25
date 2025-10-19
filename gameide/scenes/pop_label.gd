extends Control
class_name PopLabel

# customs
@export var color: Color = Color.WHITE
@export var using_color_grades = false
@export var max_pop: float = 0.5
@export var font_size: int = 16
@export var value: int = 0:
	set = _update_value

var digits: Dictionary[int, String] = {
	0: "0",
}

var digit_effects: Dictionary[String, float] = {
	"0": 0.0,
}

var tweens: Dictionary[int, Tween] = {}

var color_grades = [Color.WHITE, Color.AQUAMARINE, Color.YELLOW_GREEN, Color.YELLOW, Color.DEEP_PINK]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var font = get_theme_default_font()
	var cx = 0
	for i in digits.size():
		var effect = digit_effects[str(i)]
		var scale = 1.0 + effect * max_pop
		var digit_size = font.get_string_size(digits[i],0,-1,font_size)
		var scaled_size = digit_size * scale
		draw_set_transform(
			Vector2(cx,font.get_ascent(font_size)*scale-(scaled_size/2.0)),
			0,
			Vector2(scale,scale)
		)
		var col = Color.WHITE
		if using_color_grades:
			col = _get_grade(value)
		draw_char(
			get_theme_default_font(),
			Vector2.ZERO,
			digits[i],
			font_size,
			lerp(color, col, effect)
		)
		cx += digit_size.x

func _update_value(val):
	if val==value: return
	value = val
	var str_val = "%d"%value
	if str_val.length()>digits.size():
		for i in (digits.size() - str_val.length()):
			digits.erase(digits.size()-1)
			digit_effects.erase(str(digits.size()-1))
		for i in str_val.length():
			if !digits.has(i):
				digits[i] = str_val[i]
				digit_effects[str(i)] = 1.0
				_digit_effect_tween(i)
			else:
				if digits[i] != str_val[i]:
					digits[i] = str_val[i]
					digit_effects[str(i)] = 1.0
					_digit_effect_tween(i)

func _digit_effect_tween(digit:int):
	if tweens.has(digit):
		tweens[digit].kill()
	var tween = create_tween()
	tween.tween_property(self,"digit_effects:%d"%digit,0.0,0.5)
	tweens[digit] = tween


func _get_grade(val:int):
	if val >= Global.COMBO_MIN*12:
		return 4
	elif val >= Global.COMBO_MIN*7:
		return 3
	elif val >= Global.COMBO_MIN*3:
		return 2
	elif val >= Global.COMBO_MIN:
		return 1
	else:
		return 0
