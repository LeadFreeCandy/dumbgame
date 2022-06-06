extends Node

onready var listUI = $ItemList
onready var partsUI = $Gun

var itemList = [
	
]

var gunParts = {
	"Body" : -1,
	"Grip" : -1,
	"Stock" : -1
}

func _ready():
	pass
	

func addItem(item):
	itemList.push_back(item)
	listUI.add_item(item.name)

func removeItem(index):
	return itemList.pop_at(index)

func addPart(item):
	gunParts[item.id] = item
	partsUI.add_item(item.name)

func setPart(index, item):
	gunParts[index] = item
	partsUI.set_item_text(index, item.name)

func setItem(index, item):
	itemList[index] = item
	listUI.set_item_text(index, item.name)
