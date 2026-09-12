class_name TicketSystem
extends Node

## Ticket issuing is intentionally separate from GameState. This keeps the
## ticket-machine interaction small while GameState remains the source of truth.
signal ticket_issued(number: int)

@export var ticket_min := 126
@export var ticket_max := 149

var _rng := RandomNumberGenerator.new()

func _ready():
	_rng.randomize()

func take_ticket() -> int:
	if not GameState.has_ticket():
		GameState.assign_ticket(_rng.randi_range(ticket_min, ticket_max))
		ticket_issued.emit(GameState.get_ticket_number())
	return GameState.get_ticket_number()
