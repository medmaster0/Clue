extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	
	#DISABLE creature button
	$Creature/SelectButton.visible = false

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

#Populate the fields with the input creatures
func setDisplayInfo(creature):
	$NameLabel.text = "Name: " + creature.creature_name
	$Creature.SetPrimColor(creature.primColor)
	SetZodiacLabel(creature.zodiac_sign)
	$ZodiacTile.change_symbol(creature.zodiac_sign)
	$Creature/Clothes.copy_clothes(creature.find_node("Clothes")) #also copy hat
	$Creature/MajorArcWeapon.copy_weapon(creature.find_node("MajorArcWeapon")) #also copy weapon
	$Creature/MajorArcWeapon.position.x = 16 #position it to the right
	$WeaponLabel.text = "Equipped Item: " + $Creature/MajorArcWeapon.item_name

func SetZodiacLabel(zodiac_symbol):
	#Choos a string based on zodiac symbol number
	var z_string = "" #the name we write out to the label
	match zodiac_symbol:
		0:
			z_string = "Aries"
		1:
			z_string = "Taurus"
		2:
			z_string = "Gemini"
		3:
			z_string = "Cancer"
		4:
			z_string = "Leo"
		5:
			z_string = "Virgo"
		6:
			z_string = "Libra"
		7:
			z_string = "Scorpio"
		8:
			z_string = "Sagittarius"
		9:
			z_string = "Capricorn"
		10:
			z_string = "Aquarius"
		11:
			z_string = "Pisces"
	
	$ZodiacLabel.text = "Sign: " + z_string