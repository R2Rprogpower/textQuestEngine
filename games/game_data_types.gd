extends Node
# game_data_types.gd
class_name GameData

class EventDefinition:
	var id: String
	var type: String                    # "modify_stats", "give_items", "set_flags", "jump_node", "custom"
	var params: Dictionary = {}         # type-specific payload
	
class InteractionDefinition:
	var id: String
	var name: String

	# Where it belongs / what it's for:
	# { kind = "interactable"|"node"|"global", id = "locked_door"|"intro"|null }
	var target: Dictionary = {}

	# Standard condition block
	var conditions: Dictionary = {}      # { requires_stats = {...}, requires_items = [...], requires_flags = {...} }

	var on_success_events: Array[String] = []
	var on_failure_events: Array[String] = []

	var tags: Array[String] = []        # optional, e.g. ["world", "context_action"]

	
	
	
class StatDefinition:
	var id: String
	var name: String
	var type: String            # "int", "float", "bool"
	var min_value: float
	var max_value: float
	var description: String


class ItemDefinition:
	var id: String
	var name: String
	var category: String        # "clothing", "weapon", "quest", "consumable", etc.
	var slot: String            # "head", "body", "legs", "feet", "hands", "accessory" or "" for non-equip
	var stackable: bool
	var max_stack: int
	var base_modifiers: Dictionary = {}       # stat_id -> delta
	var tags: Array[String] = []
	var description: String


class ItemStack:
	var item_id: String
	var quantity: int = 1
	var durability: float = 1.0               # 0..1 if you want, or just ignore
	var custom_state: Dictionary = {}         # for quest flags bound to item


class CharacterTemplate:
	var id: String
	var name: String
	var allowed_slots: Array[String] = []     # ["head","body","legs"...]
	var base_stats: Dictionary = {}           # stat_id -> default value
	var tags: Array[String] = []


class CharacterState:
	var id: String
	var template_id: String
	var name: String
	var stats: Dictionary = {}                # stat_id -> current value
	var inventory: Array[ItemStack] = []
	var equipment: Dictionary = {}            # slot_name -> ItemStack or null
	var flags: Dictionary = {}                # "seen_intro" -> true/false


class InteractableDefinition:
	var id: String
	var name: String
	var type: String                  # "door", "container", "npc", "terminal", etc.
	var node_id: String               # story node where it appears (optional for later)
	var requires_items: Array[String] = []
	var requires_flags: Dictionary = {}      # flag_id -> required value
	var effects_on_interact: Dictionary = {} # e.g. { stats = {...}, flags_set = {...}, items_add = [...] }
	var description: String
	var tags: Array[String] = []


# Main game data container
var id: String
var title: String
var description: String
var version: int = 1

var stat_definitions: Dictionary = {}        # stat_id -> StatDefinition
var item_definitions: Dictionary = {}        # item_id -> ItemDefinition
var character_templates: Dictionary = {}     # template_id -> CharacterTemplate
var interactable_definitions: Dictionary = {}# interactable_id -> InteractableDefinition

var player_initial: CharacterState           # starting player state


static func from_dict(root: Dictionary) -> GameData:
	var gd := GameData.new()

	gd.id = String(root.get("id", ""))
	gd.title = String(root.get("title", gd.id))
	gd.description = String(root.get("description", ""))
	gd.version = int(root.get("version", 1))

	# --- stats ---
	var stats_dict: Dictionary = root.get("stat_definitions", {})
	for stat_id in stats_dict.keys():
		var d: Dictionary = stats_dict[stat_id]
		var sd := StatDefinition.new()
		sd.id = String(stat_id)
		sd.name = String(d.get("name", stat_id))
		sd.type = String(d.get("type", "int"))
		sd.min_value = float(d.get("min", 0))
		sd.max_value = float(d.get("max", 100))
		sd.description = String(d.get("description", ""))
		gd.stat_definitions[stat_id] = sd

	# --- items ---
	var items_dict: Dictionary = root.get("item_definitions", {})
	for item_id in items_dict.keys():
		var d: Dictionary = items_dict[item_id]
		var it := ItemDefinition.new()
		it.id = String(item_id)
		it.name = String(d.get("name", item_id))
		it.category = String(d.get("category", "misc"))
		it.slot = String(d.get("slot", ""))   # "" or null means not equipable
		it.stackable = bool(d.get("stackable", false))
		it.max_stack = int(d.get("max_stack", 1))
		it.base_modifiers = d.get("base_modifiers", {})
		it.tags = d.get("tags", [])
		it.description = String(d.get("description", ""))
		gd.item_definitions[item_id] = it

	# --- character templates ---
	var char_tmpls: Dictionary = root.get("character_templates", {})
	for tmpl_id in char_tmpls.keys():
		var d: Dictionary = char_tmpls[tmpl_id]
		var ct := CharacterTemplate.new()
		ct.id = String(tmpl_id)
		ct.name = String(d.get("name", tmpl_id))
		ct.allowed_slots = d.get("allowed_slots", [])
		ct.base_stats = d.get("base_stats", {})
		ct.tags = d.get("tags", [])
		gd.character_templates[tmpl_id] = ct
		
  # --- events ---
	var ev_dict: Dictionary = root.get("event_definitions", {})
	for ev_id in ev_dict.keys():
		var d: Dictionary = ev_dict[ev_id]
		var ev := EventDefinition.new()
		ev.id = String(ev_id)
		ev.type = String(d.get("type", "custom"))
		ev.params = d.get("params", {})
		gd.event_definitions[ev_id] = ev

	# --- interactions ---
	var inter_dict: Dictionary = root.get("interaction_definitions", {})
	for intr_id in inter_dict.keys():
		var d: Dictionary = inter_dict[intr_id]
		var intr := InteractionDefinition.new()
		intr.id = String(intr_id)
		intr.name = String(d.get("name", intr_id))
		intr.target = d.get("target", {})              # { kind, id }
		intr.conditions = d.get("conditions", {})
		intr.on_success_events = d.get("on_success_events", [])
		intr.on_failure_events = d.get("on_failure_events", [])
		intr.tags = d.get("tags", [])
		gd.interaction_definitions[intr_id] = intr


	# --- player initial state ---
	var player_root: Dictionary = root.get("player", {})
	var tmpl_id: String = String(player_root.get("character_template_id", "player_default"))
	var init_state: Dictionary = player_root.get("initial_state", {})
	var event_definitions: Dictionary = {}       # id -> EventDefinition
	var interaction_definitions: Dictionary = {} # id -> InteractionDefinition

	var cs := CharacterState.new()
	cs.id = "player"
	cs.template_id = tmpl_id
	if gd.character_templates.has(tmpl_id):
		cs.name = gd.character_templates[tmpl_id].name
	else:
		cs.name = "Player"

	cs.stats = init_state.get("stats", {})
	cs.flags = init_state.get("flags", {})

	# inventory
	cs.inventory = []
	var inv_arr: Array = init_state.get("inventory", [])
	for entry in inv_arr:
		var stack := ItemStack.new()
		stack.item_id = String(entry.get("item_id", ""))
		stack.quantity = int(entry.get("qty", 1))
		cs.inventory.append(stack)

	# equipment
	cs.equipment = {}
	var eq_dict: Dictionary = init_state.get("equipment", {})
	for slot_name in eq_dict.keys():
		var eq_item_id = eq_dict[slot_name]
		if eq_item_id == null:
			cs.equipment[slot_name] = null
		else:
			var st := ItemStack.new()
			st.item_id = String(eq_item_id)
			st.quantity = 1
			cs.equipment[slot_name] = st

	gd.player_initial = cs


	return gd
