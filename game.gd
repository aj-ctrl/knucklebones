extends Node2D

@onready var nodeP1Board = $P1Board
@onready var nodeP2Board = $P2Board
@onready var turn_tattle = $TurnTattle
@onready var roll_tattle = $RollTattle

@onready var p1_col_1_total = $P1Totals/Col1Total
@onready var p1_col_2_total = $P1Totals/Col2Total
@onready var p1_col_3_total = $P1Totals/Col3Total

@onready var p2_col_1_total = $P2Totals/Col1Total
@onready var p2_col_2_total = $P2Totals/Col2Total
@onready var p2_col_3_total = $P2Totals/Col3Total

#controls whos turn it is p1 or p2
var p1turn = true
#controls if die is rolled when starting a turn
var p1turnInit = true
var p2turnInit = true

var currentRoll
var gameActive = true

#these are the containers for the actual rolls to be used in the game logic
var p1col1 = []
var p1col2 = []
var p1col3 = []

var p2col1 = []
var p2col2 = []
var p2col3 = []

#these are for showing the column values of the actual game board
var p1slots = {
	"1" : 0, 
	"2" : 0, 
	"3" : 0, 
	"4" : 0, 
	"5" : 0, 
	"6" : 0, 
	"7" : 0, 
	"8" : 0, 
	"9" : 0, 
	}

var p2slots = {
	"1" : 0, 
	"2" : 0, 
	"3" : 0, 
	"4" : 0, 
	"5" : 0, 
	"6" : 0, 
	"7" : 0, 
	"8" : 0, 
	"9" : 0, 
	}

func _process(delta):
	process_scores()
	render_board()
	check_gamestate()
	#turn logic
	if gameActive:
		if p1turn:
			turn_tattle.text = "Player 1's Turn"
			roll_tattle.position = Vector2i($P1Board.position.x - 100,$P1Board.position.y + 25)
			p1_turn()
		else:
			turn_tattle.text = "Player 2's Turn"
			roll_tattle.position = Vector2i($P2Board.position.x - 100,$P2Board.position.y + 25)
			p2_turn()

func check_gamestate():
		if p1col1.size() == 3 and p1col2.size() == 3 and p1col3.size() == 3 or p2col1.size() == 3 and p2col2.size() == 3 and p2col3.size() == 3:
			end_game()

func end_game():
	gameActive = false
	$RollTattle.hide()
	$WinTattle.show()

func process_scores():
	process_score(p1col1, p1_col_1_total)
	process_score(p1col2, p1_col_2_total)
	process_score(p1col3, p1_col_3_total)
	process_score(p2col1, p2_col_1_total)
	process_score(p2col2, p2_col_2_total)
	process_score(p2col3, p2_col_3_total)
	var p1score = int(p1_col_1_total.text) + int(p1_col_2_total.text) + int(p1_col_3_total.text)
	var p2score = int(p2_col_1_total.text) + int(p2_col_2_total.text) + int(p2_col_3_total.text)
	if p1score > p2score:
		$WinTattle.text = "Player 1 wins!"
	else:
		if p2score > p1score:
			$WinTattle.text = "Player 2 wins!"
		else:
			$WinTattle.text = "Draw!"
	$P1Totals/GrandTotal.text = "Score: " + str(p1score)
	$P2Totals/GrandTotal.text = "Score: " + str(p2score)

func process_score(column:Array, totalDisplay:Object):
	var total = 0
	match column.size():
		1:
			total = column[0]
		2:
			if column[0] == column[1]:
				total = column[0] * column[1]
			else:
				total = column[0] + column[1]
		3:
			total = column[0] + column[1] + column[2]
			if column[0] == column[1]:
				total = column[0] * column[1] + column[2]
			if column[0] == column[2]:
				total = column[0] * column[2] + column[1]
			if column[1] == column[2]:
				total = column[1] * column[2] + column[0]
			if column[0] == column[1] and column[0] == column[2]:
				total = column[0] * column[1] * column[2]
	totalDisplay.text = str(total)

func handle_pops(p1column, p2column):
	var matchingVal = -1
	var popMatchs = false
	for die in p1column:
		if p2column.has(die):
			popMatchs = true
			matchingVal = die
	if popMatchs:
		print("popping", p1column, p2column)
		while p1column.has(matchingVal):
			var toPop = p1column.find(matchingVal)
			p1column.pop_at(toPop)
		while p2column.has(matchingVal):
			var toPop = p2column.find(matchingVal)
			p2column.pop_at(toPop)
		print("popped", p1column, p2column)
		
		popMatchs = false

func render_board():
	update_slots()
	nodeP1Board.text = "["+str(p1slots["1"])+"]" + "["+str(p1slots["4"])+"]" + "["+str(p1slots["7"])+"]" + "["+str(p1slots["2"])+"]" + "["+str(p1slots["5"])+"]" + "["+str(p1slots["8"])+"]" + "["+str(p1slots["3"])+"]" + "["+str(p1slots["6"])+"]" + "["+str(p1slots["9"])+"]"
	nodeP2Board.text = "["+str(p2slots["3"])+"]" + "["+str(p2slots["6"])+"]" + "["+str(p2slots["9"])+"]" + "["+str(p2slots["2"])+"]" + "["+str(p2slots["5"])+"]" + "["+str(p2slots["8"])+"]" + "["+str(p2slots["1"])+"]" + "["+str(p2slots["4"])+"]" + "["+str(p2slots["7"])+"]"

func p1_turn():
	if p1turnInit:
		currentRoll = roll()
		roll_tattle.text = "Roll: " + str(currentRoll)
		p1turnInit = false
	
	if Input.is_action_just_released("Player1_left"):
		var turnTaken = add_roll_to_col(p1col1, currentRoll)
		handle_pops(p1col1, p2col1)
		if turnTaken:
			p1turn = false
			p1turnInit = true
	
	if Input.is_action_just_released("Player1_middle"):
		var turnTaken = add_roll_to_col(p1col2, currentRoll)
		handle_pops(p1col2, p2col2)
		if turnTaken:
			p1turn = false
			p1turnInit = true
	
	if Input.is_action_just_released("Player1_right"):
		var turnTaken = add_roll_to_col(p1col3, currentRoll)
		handle_pops(p1col3, p2col3)
		if turnTaken:
			p1turn = false
			p1turnInit = true

func p2_turn():
	if p2turnInit:
		currentRoll = roll()
		roll_tattle.text = "Roll: " + str(currentRoll)
		p2turnInit = false
	
	if Input.is_action_just_released("Player2_left"):
		var turnTaken = add_roll_to_col(p2col1, currentRoll)
		handle_pops(p1col1, p2col1)
		if turnTaken:
			p1turn = true
			p2turnInit = true
	
	if Input.is_action_just_released("Player2_middle"):
		var turnTaken = add_roll_to_col(p2col2, currentRoll)
		handle_pops(p1col2, p2col2)
		if turnTaken:
			p1turn = true
			p2turnInit = true
	
	if Input.is_action_just_released("Player2_right"):
		var turnTaken = add_roll_to_col(p2col3, currentRoll)
		handle_pops(p1col3, p2col3)
		if turnTaken:
			p1turn = true
			p2turnInit = true

func add_roll_to_col(col:Array, roll:int):
	if col.size() < 3:
		col.append(roll)
		return true
	else:
		print("error, array already full")
		return false

func update_column(column:Array,slots:Dictionary,colLead:int):
	if column.size() == 0:
		slots[str(colLead)] = 0
		slots[str(colLead + 1)] = 0
		slots[str(colLead + 2)] = 0
	if column.size() == 1:
		slots[str(colLead)] = column[0]
		slots[str(colLead + 1)] = 0
		slots[str(colLead + 2)] = 0
	if column.size() == 2:
		slots[str(colLead)] = column[0]
		slots[str(colLead + 1)] = column[1]
		slots[str(colLead + 2)] = 0
	if column.size() == 3:
		slots[str(colLead)] = column[0]
		slots[str(colLead + 1)] = column[1]
		slots[str(colLead + 2)] = column[2]

func update_slots():
	update_column(p1col1,p1slots,1)
	update_column(p1col2,p1slots,4)
	update_column(p1col3,p1slots,7)
	update_column(p2col1,p2slots,1)
	update_column(p2col2,p2slots,4)
	update_column(p2col3,p2slots,7)

func roll():
	var roll = (randi() % 6) + 1
	print("Rolled a ", roll)
	return roll
