extends Node

#Functions to establish the Law Structure


#COW LATIN
#Some made up, random genned language that's supposed to look like latin
var latin_syls = ["est","ius","onos","el","ia","ium","eri","itus","us",
	"tum","um","en","eno","er","era","a","e","i","o","u","y"]

var latin_cons = ["b","c","d","f","g","h","j","k","l","m","n","p",
"q","r","t","v","w","x","y","z","pl","th","ca","pa"]

#Function that generates COW LATIN
func gen_latin_word():
	
	randomize()
	
	var word = "" #the word we'll return
	var num_syllables = randi()%4+1 #Decide how many syables
	
	#POSSIBLY START WITH A CONSONANT
	if randi()%2 == 0:
		word = word + latin_cons[randi()%latin_cons.size()] #Add a consonant
		
	#Loop through all of the syllables (but not the last since it won't have a consonant
	for i in range(num_syllables-1):
		word = word + latin_syls[randi()%latin_syls.size()] #Add a syllable(vowel)
		word = word + latin_cons[randi()%latin_cons.size()] #add a consonant
		
	#Add final vowel/syllable
	word = word + latin_syls[randi()%latin_syls.size()] #Add a syllable(vowel)
		
	return(word)
	
#Function that generate a COW LATIN sentence
func gen_latin_sentence():
	
	randomize()
	
	var num_words = randi()%9 + 1
	var sentence = "" #The sentence we'll be returning
	
	for i in range(num_words):
		sentence = sentence + " " + gen_latin_word()
	
	return(sentence)
	
	

#Generaate EXTENDED ROMAN NUMERAL -> LATIN NUMERAL
#Extend ROMAN NUMERAL system beyond the digit M...
# I,
# V, X
# L, C
# D, M
#New Extended System: J, W, Y, K, B, E, N 
#(letter afterwards (unless taken, then you go backwards (L->M->K instead) )
# J
# W, Y
# K, B
# E, N
#Based off input numba
func gen_latin_numerals(number):
	
	var numerals = "" #The string we'll be returning
	
	var magnitude #temporary magnitude variable
	
	#MAGNITUDE 100,000's
	#DETERMIN B's and E's (MAYBE BN/BE)
	magnitude = 100000
	var num_b = number / magnitude
	number = number - ( num_b * magnitude )
	#Now, what specific letters does that number of characters refer to?
	#9's
	if(num_b == 9):
		numerals = numerals + "BN"
		num_b = 0
	#Above 5's
	if(num_b >= 5):
		numerals = numerals + "E"
		num_b = num_b - 5
	#4's
	if(num_b == 4):
		numerals = numerals + "BE"
		num_b = 0
	#Anything left above 0
	for i in range(num_b):
		numerals = numerals + "B"

	
	#MAGNITUDE 10,000's
	#DETERMINE Y's and K's (MAYBE YB/YK)
	magnitude = 10000
	var num_y = number / magnitude
	number = number - ( num_y * magnitude )
	#Now, what specific letters does that number of characters refer to?
	#9's
	if(num_y == 9):
		numerals = numerals + "YB"
		num_y = 0
	#Above 5's
	if(num_y >= 5):
		numerals = numerals + "K"
		num_y = num_y - 5
	#4's
	if(num_y == 4):
		numerals = numerals + "YK"
		num_y = 0
	#Anything left above 0
	for i in range(num_y):
		numerals = numerals + "Y"
	
	#MAGNITUDE 1,000's
	#DETERMINE M's and W's (MAYBE MY/MW)
	magnitude = 1000
	var num_m = number / magnitude
	number = number - ( num_m * magnitude )
	#Now, what specific letters does that number of characters refer to?
	#9's
	if(num_m == 9):
		numerals = numerals + "MY"
		num_m = 0
	#Above 5's
	if(num_m >= 5):
		numerals = numerals + "W"
		num_m = num_m - 5
	#4's
	if(num_m == 4):
		numerals = numerals + "MW"
		num_m = 0
	#Anything left above 0
	for i in range(num_m):
		numerals = numerals + "M"	

	#MAGNITUDE 100's
	#DETERMINE C's and D's (MAYBE CM/CD)
	magnitude = 100
	var num_c = number / magnitude
	number = number - ( num_c * magnitude )
	#Now, what specific letters does that number of characters refer to?
	#9's
	if(num_c == 9):
		numerals = numerals + "CM"
		num_c = 0
	#Above 5's
	if(num_c >= 5):
		numerals = numerals + "D"
		num_c = num_c - 5
	#4's
	if(num_c == 4):
		numerals = numerals + "CD"
		num_c = 0
	#Anything left above 0
	for i in range(num_c):
		numerals = numerals + "C"	

	#MAGNITUDE 10's
	#DETERMINE X's and L's (MAYBE XC/XL)
	magnitude = 10
	var num_x = number / magnitude
	number = number - ( num_x * magnitude )
	#Now, what specific letters does that number of characters refer to?
	#9's
	if(num_x == 9):
		numerals = numerals + "XC"
		num_x = 0
	#Above 5's
	if(num_x >= 5):
		numerals = numerals + "L"
		num_x = num_x - 5
	#4's
	if(num_x == 4):
		numerals = numerals + "XL"
		num_x = 0
	#Anything left above 0
	for i in range(num_x):
		numerals = numerals + "X"	

	#MAGNITUDE 1's
	#DETERMINE I's and V's (MAYBE IX/IV)
	magnitude = 1
	var num_i = number / magnitude
	number = number - ( num_i * magnitude )
	#Now, what specific letters does that number of characters refer to?
	#9's
	if(num_i == 9):
		numerals = numerals + "IX"
		num_i = 0
	#Above 5's
	if(num_i >= 5):
		numerals = numerals + "V"
		num_i = num_i - 5
	#4's
	if(num_i == 4):
		numerals = numerals + "IV"
		num_i = 0
	#Anything left above 0
	for i in range(num_i):
		numerals = numerals + "I"	


	return(numerals)

#
#
	
	