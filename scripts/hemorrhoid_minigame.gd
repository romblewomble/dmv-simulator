extends CanvasLayer

## Self-contained first minigame. It only reports a result; Main/GameState
## decide how the DMV world pauses and resumes.
signal minigame_finished(minigame_id: String, risk: float, result: String)

const MINIGAME_ID := "hemorrhoid_prevention"
const DURATION := 24.0

var elapsed := 0.0
var risk := 24.0
var stretch_count := 0
var _stretch_cooldown := 0.0
var _finished := false

@onready var timer_label: Label = $Panel/Timer
@onready var risk_label: Label = $Panel/RiskLabel
@onready var risk_fill: ColorRect = $Panel/RiskMeter/RiskFill
@onready var instruction: Label = $Panel/Instruction

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_update_ui()

func _process(delta):
	if _finished:
		return
	elapsed += delta
	_stretch_cooldown = maxf(0.0, _stretch_cooldown - delta)
	risk = minf(100.0, risk + delta * 3.1)
	if Input.is_action_just_pressed("stretch") and _stretch_cooldown <= 0.0:
		stretch_count += 1
		risk = maxf(0.0, risk - 16.0)
		_stretch_cooldown = 0.8
		instruction.text = "EXCELLENT POSTURAL AWARENESS. KEEP IT UP."
	_update_ui()
	if elapsed >= DURATION:
		_finish()

func _update_ui():
	timer_label.text = "TIME REMAINING: %02d" % maxi(0, ceili(DURATION - elapsed))
	risk_label.text = "HEMORRHOID RISK: %03d%%" % roundi(risk)
	risk_fill.size.x = 470.0 * risk / 100.0
	if risk < 35.0:
		risk_fill.color = Color("5c9c71")
	elif risk < 65.0:
		risk_fill.color = Color("d1a84b")
	else:
		risk_fill.color = Color("b94e48")

func _finish():
	_finished = true
	var result: String
	var message: String
	if risk < 35.0:
		result = "LOW RISK"
		message = "Congratulations. Your posterior has survived another bureaucratic ordeal."
	elif risk < 65.0:
		result = "MODERATE RISK"
		message = "You should probably stand up more often."
	else:
		result = "HIGH RISK"
		message = "Please consult a medical professional."
	$Panel/Result.text = "%s\n%s\n\nPRESS SPACE TO RETURN TO THE DMV" % [result, message]
	instruction.text = "STRETCHES COMPLETED: %d" % stretch_count
	# Let the result breathe, then accept one clear SPACE press to return.
	await get_tree().create_timer(0.7, true).timeout
	while not Input.is_action_just_pressed("stretch"):
		await get_tree().process_frame
	minigame_finished.emit(MINIGAME_ID, risk, result)
