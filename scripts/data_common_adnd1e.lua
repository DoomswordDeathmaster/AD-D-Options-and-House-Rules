-- ability scores
aStrength = {}
aDexterity = {}
aWisdom = {}
aConstitution = {}
aCharisma = {}
aIntelligence = {}

-- required for npcs, base save table
aWarriorSaves = {}

-- osric version of above
aWarriorSavesOsric = {}

-- required for npcs, hit matrix when used
aMatrix = {}

-- class hit matrices
aAssassinToHitMatrix = {}
aClericToHitMatrix = {}
aDruidToHitMatrix = {}
aFighterToHitMatrix = {}
aIllusionistToHitMatrix = {}
aMagicUserToHitMatrix = {}
aPaladinToHitMatrix = {}
aRangerToHitMatrix = {}
aThiefToHitMatrix = {}
aOsricToHitMatrix = {}

-- class saves
aAssassinSaves = {}
aClericSaves = {}
aDruidSaves = {}
aFighterSaves = {}
aIllusionistSaves = {}
aMagicUserSaves = {}
aPaladinSaves = {}
aRangerSaves = {}
aThiefSaves = {}

function onInit()
	bOptAdd1eProperties = (OptionsManager.getOption("add1eProperties") == "on")

	if bOptAdd1eProperties then
		DataCommonADND.coreVersion = "1e"

		-- default coin weight, 10 coins = 1 pound, 1e, ouch
		DataCommonADND.nDefaultCoinWeight = 0.1

		-- aStrength[abilityScore]={hit adj, dam adj, weight allow, max press, open doors, bend bars}
		aStrength[1] = {-3, -1, -350, 0, "1(0)", 0, 2, 3, 4, 5, 7}
		aStrength[2] = {-3, -1, -350, 0, "1(0)", 0, 2, 3, 4, 5, 7}
		aStrength[3] = {-3, -1, -350, 0, "1(0)", 0, 2, 3, 4, 5, 7}
		aStrength[4] = {-2, -1, -250, 0, "1(0)", 0, 11, 14, 17, 20, 25}
		aStrength[5] = {-2, -1, -250, 0, "1(0)", 0, 11, 14, 17, 20, 25}
		aStrength[6] = {-1, 0, -150, 0, "1(0)", 0, 21, 30, 39, 47, 55}
		aStrength[7] = {-1, 0, -150, 0, "1(0)", 0, 21, 30, 39, 47, 55}
		aStrength[8] = {0, 0, 0, 0, "1-2(0)", 1, 36, 51, 66, 81, 90}
		aStrength[9] = {0, 0, 0, 0, "1-2(0)", 1, 36, 51, 66, 81, 90}
		aStrength[10] = {0, 0, 0, 0, "1-2(0)", 2, 41, 59, 77, 97, 110}
		aStrength[11] = {0, 0, 0, 0, "1-2(0)", 2, 41, 59, 77, 97, 110}
		aStrength[12] = {0, 0, 100, 0, "1-2(0)", 4, 46, 70, 94, 118, 140}
		aStrength[13] = {0, 0, 100, 0, "1-2(0)", 4, 46, 70, 94, 118, 140}
		aStrength[14] = {0, 0, 200, 0, "1-2(0)", 7, 56, 86, 116, 146, 170}
		aStrength[15] = {0, 0, 200, 0, "1-2(0)", 7, 56, 86, 116, 146, 170}
		aStrength[16] = {0, 1, 350, 0, "1-3(0)", 10, 71, 101, 131, 161, 195}
		aStrength[17] = {1, 1, 500, 0, "1-3(0)", 13, 71, 101, 131, 161, 195}
		aStrength[18] = {1, 2, 750, 0, "1-3(0)", 16, 111, 150, 189, 228, 255}
		aStrength[19] = {3, 7, 4500, 0, "7 in 8(3)", 50, 486, 500, 550, 600, 640}
		aStrength[20] = {3, 8, 5000, 0, "7 in 8(3)", 60, 536, 580, 610, 670, 700}
		aStrength[21] = {4, 9, 6000, 0, "9 in 10(4)", 70, 636, 680, 720, 790, 810}
		aStrength[22] = {4, 10, 7500, 0, "11 in 12(4)", 80, 786, 830, 870, 900, 970}
		aStrength[23] = {5, 11, 9000, 0, "11 in 12(5)", 90, 936, 960, 1000, 1090, 1130}
		aStrength[24] = {6, 12, 12000, 0, "19 in 20(7in8)", 100, 1236, 1290, 1300, 1380, 1440}
		aStrength[25] = {7, 14, 15000, 0, "23 in 24(9in10)", 100, 1536, 1590, 1600, 1680, 1750}
		-- Deal with 18 01-100 strength
		aStrength[50] = {1, 3, 1000, 0, "1-3(0)", 20, 136, 175, 214, 253, 280}
		aStrength[75] = {2, 3, 1250, 0, "1-4(0)", 25, 161, 200, 239, 278, 305}
		aStrength[90] = {2, 4, 1500, 0, "1-4(0)", 30, 186, 225, 264, 303, 330}
		aStrength[99] = {2, 5, 2000, 0, "1-4(1)", 35, 236, 275, 314, 353, 380}
		aStrength[100] = {3, 6, 3000, 0, "1-5(2)", 40, 336, 375, 414, 453, 480}
		-- make sure the ruleset uses the same
		DataCommonADND.aStrength = aStrength

		-- aDexterity[abilityScore]={reaction, missile, defensive}
		aDexterity[1] = {-3, -3, 4}
		aDexterity[2] = {-3, -3, 4}
		aDexterity[3] = {-3, -3, 4}
		aDexterity[4] = {-2, -2, 3}
		aDexterity[5] = {-1, -1, 2}
		aDexterity[6] = {0, 0, 1}
		aDexterity[7] = {0, 0, 0}
		aDexterity[8] = {0, 0, 0}
		aDexterity[9] = {0, 0, 0}
		aDexterity[10] = {0, 0, 0}
		aDexterity[11] = {0, 0, 0}
		aDexterity[12] = {0, 0, 0}
		aDexterity[13] = {0, 0, 0}
		aDexterity[14] = {0, 0, 0}
		aDexterity[15] = {0, 0, -1}
		aDexterity[16] = {1, 1, -2}
		aDexterity[17] = {2, 2, -3}
		aDexterity[18] = {3, 3, -4}
		aDexterity[19] = {3, 3, -4}
		aDexterity[20] = {3, 3, -4}
		aDexterity[21] = {4, 4, -5}
		aDexterity[22] = {4, 4, -5}
		aDexterity[23] = {4, 4, -5}
		aDexterity[24] = {5, 5, -6}
		aDexterity[25] = {5, 5, -6}
		-- make sure the ruleset uses the same
		DataCommonADND.aDexterity = aDexterity

		-- aWisdom[abilityScore]={magic adj, spell bonuses, spell failure, spell imm. }
		aWisdom[1] = {-3, "None", 20, "None"}
		aWisdom[2] = {-3, "None", 20, "None"}
		aWisdom[3] = {-3, "None", 20, "None"}
		aWisdom[4] = {-2, "None", 20, "None"}
		aWisdom[5] = {-1, "None", 20, "None"}
		aWisdom[6] = {-1, "None", 20, "None"}
		aWisdom[7] = {-1, "None", 20, "None"}
		aWisdom[8] = {0, "None", 20, "None"}
		aWisdom[9] = {0, "None", 20, "None"}
		aWisdom[10] = {0, "None", 15, "None"}
		aWisdom[11] = {0, "None", 10, "None"}
		aWisdom[12] = {0, "None", 5, "None"}
		aWisdom[13] = {0, "1x1", 0, "None"}
		aWisdom[14] = {0, "2x1", 0, "None"}
		aWisdom[15] = {1, "2x1,1x2", 0, "None"}
		aWisdom[16] = {2, "2x1,2x2", 0, "None"}
		aWisdom[17] = {3, "2x1,2x2,1x3", 0, "None"}
		aWisdom[18] = {4, "Various", 0, "None"}
		aWisdom[19] = {4, "Various", 0, "Various"}
		aWisdom[20] = {4, "Various", 0, "Various"}
		aWisdom[21] = {4, "Various", 0, "Various"}
		aWisdom[22] = {4, "Various", 0, "Various"}
		aWisdom[23] = {4, "Various", 0, "Various"}
		aWisdom[24] = {4, "Various", 0, "Various"}
		aWisdom[25] = {4, "Various", 0, "Various"}
		-- deal with long string bonus for tooltip
		aWisdom[117] = {4, "Bonus Spells: 2x1,2x2,1x3", 0, "None"}
		aWisdom[118] = {4, "Bonus Spells: 2x1st, 2x2nd, 1x3rd, 1x4th", 0, "None"}
		aWisdom[119] = {
			4,
			"Bonus Spells: 3x1st, 2x2nd, 1x3rd, 2x4th",
			0,
			"Spells: cause fear,charm person, command, friends, hypnotism"
		}
		aWisdom[120] = {
			4,
			"Bonus Spells: 3x1st, 3x2nd, 1x3rd, 3x4th",
			0,
			"Spells: cause fear,charm person, command, friends, hypnotism, forget, hold person, enfeeble, scare"
		}
		aWisdom[121] = {
			4,
			"Bonus Spells: 3x1st, 3x2nd, 2x3rd, 3x4th, 1x5th",
			0,
			"Spells: cause fear,charm person, command, friends, hypnotism, forget, hold person, enfeeble, scare, fear"
		}
		aWisdom[122] = {
			4,
			"Bonus Spells: 3x1st, 3x2nd, 2x3rd, 4x4th, 2x5th",
			0,
			"Spells: cause fear,charm person, command, friends, hypnotism, forget, hold person, enfeeble, scare, fear, charm monster, confusion, emotion, fumble, suggestion"
		}
		aWisdom[123] = {
			4,
			"Bonus Spells: 3x1st, 3x2nd, 2x3rd, 4x4th, 4x5th",
			0,
			"Spells: cause fear,charm person, command, friends, hypnotism, forget, hold person, enfeeble, scare, fear, charm monster, confusion, emotion, fumble, suggestion, chaos, feeblemind, hold monster,magic jar,quest"
		}
		aWisdom[124] = {
			4,
			"Bonus Spells: 3x1st, 3x2nd, 2x3rd, 4x4th, 4x5th, 2x6th",
			0,
			"Spells: cause fear,charm person, command, friends, hypnotism, forget, hold person, enfeeble, scare, fear, charm monster, confusion, emotion, fumble, suggestion, chaos, feeblemind, hold monster,magic jar,quest, geas, mass suggestion, rod of ruleship"
		}
		aWisdom[125] = {
			4,
			"Bonus Spells: 3x1st, 3x2nd, 2x3rd, 4x4th, 4x5th, 3x6th, 1x7th",
			0,
			"Spells: cause fear,charm person, command, friends, hypnotism, forget, hold person, enfeeble, scare, fear, charm monster, confusion, emotion, fumble, suggestion, chaos, feeblemind, hold monster,magic jar,quest, geas, mass suggestion, rod of ruleship, antipathy/sympath, death spell,mass charm"
		}
		-- make sure the ruleset uses the same
		DataCommonADND.aWisdom = aWisdom

		-- aConstitution[abilityScore]={hp, system shock, resurrection survivial, poison save, regeneration}
		aConstitution[1] = {"-2", 35, 40, 0, "None"}
		aConstitution[2] = {"-2", 35, 40, 0, "None"}
		aConstitution[3] = {"-2", 35, 40, 0, "None"}
		aConstitution[4] = {"-1", 40, 45, 0, "None"}
		aConstitution[5] = {"-1", 45, 50, 0, "None"}
		aConstitution[6] = {"-1", 50, 55, 0, "None"}
		aConstitution[7] = {"0", 55, 60, 0, "None"}
		aConstitution[8] = {"0", 60, 65, 0, "None"}
		aConstitution[9] = {"0", 65, 70, 0, "None"}
		aConstitution[10] = {"0", 70, 75, 0, "None"}
		aConstitution[11] = {"0", 75, 80, 0, "None"}
		aConstitution[12] = {"0", 80, 85, 0, "None"}
		aConstitution[13] = {"0", 85, 90, 0, "None"}
		aConstitution[14] = {"0", 88, 92, 0, "None"}
		aConstitution[15] = {"1", 91, 94, 0, "None"}
		aConstitution[16] = {"2", 95, 96, 0, "None"}
		aConstitution[17] = {"2/3", 97, 98, 0, "None"}
		aConstitution[18] = {"2/4", 99, 100, 0, "None"}
		aConstitution[19] = {"5", 99, 100, 1, "None"}
		aConstitution[20] = {"5", 99, 100, 1, "1/6 turns"}
		aConstitution[21] = {"6", 99, 100, 2, "1/5 turns"}
		aConstitution[22] = {"6", 99, 100, 2, "1/4 turns"}
		aConstitution[23] = {"6", 99, 100, 3, "1/3 turns"}
		aConstitution[24] = {"7", 99, 100, 3, "1/2"}
		aConstitution[25] = {"7", 100, 100, 4, "1 turn"}
		-- make sure the ruleset uses the same
		DataCommonADND.aConstitution = aConstitution

		-- aCharisma[abilityScore]={Max # hench, loyalty, reaction afj}
		aCharisma[1] = {1, -30, -25}
		aCharisma[2] = {1, -30, -25}
		aCharisma[3] = {1, -30, -25}
		aCharisma[4] = {1, -25, -20}
		aCharisma[5] = {2, -20, -15}
		aCharisma[6] = {2, -15, -10}
		aCharisma[7] = {3, -10, -5}
		aCharisma[8] = {3, -5, 0}
		aCharisma[9] = {4, 0, 0}
		aCharisma[10] = {4, 0, 0}
		aCharisma[11] = {4, 0, 0}
		aCharisma[12] = {5, 0, 0}
		aCharisma[13] = {5, 0, 5}
		aCharisma[14] = {6, 5, 10}
		aCharisma[15] = {7, 15, 15}
		aCharisma[16] = {8, 20, 25}
		aCharisma[17] = {10, 30, 30}
		aCharisma[18] = {15, 40, 35}
		aCharisma[19] = {20, 50, 40}
		aCharisma[20] = {25, 60, 45}
		aCharisma[21] = {30, 70, 50}
		aCharisma[22] = {35, 80, 55}
		aCharisma[23] = {40, 90, 60}
		aCharisma[24] = {45, 100, 65}
		aCharisma[25] = {50, 100, 70}
		-- make sure the ruleset uses the same
		DataCommonADND.aCharisma = aCharisma

		-- aIntelligence[abilityScore]={# languages, spelllevel, learn spell, max spells, illusion immunity}
		aIntelligence[1] = {0, 0, 0, 0, "None"}
		aIntelligence[2] = {0, 0, 0, 0, "None"}
		aIntelligence[3] = {0, 0, 0, 0, "None"}
		aIntelligence[4] = {0, 0, 0, 0, "None"}
		aIntelligence[5] = {0, 0, 0, 0, "None"}
		aIntelligence[6] = {0, 0, 0, 0, "None"}
		aIntelligence[7] = {0, 0, 0, 0, "None"}
		aIntelligence[8] = {1, 0, 0, 0, "None"}
		aIntelligence[9] = {1, 4, 35, 6, "None"}
		aIntelligence[10] = {2, 5, 45, 7, "None"}
		aIntelligence[11] = {2, 5, 45, 7, "None"}
		aIntelligence[12] = {3, 5, 45, 7, "None"}
		aIntelligence[13] = {3, 6, 55, 9, "None"}
		aIntelligence[14] = {4, 6, 55, 9, "None"}
		aIntelligence[15] = {4, 7, 65, 11, "None"}
		aIntelligence[16] = {5, 7, 65, 11, "None"}
		aIntelligence[17] = {6, 8, 75, 14, "None"}
		aIntelligence[18] = {7, 9, 85, 18, "None"}
		aIntelligence[19] = {7, 11, 95, "All", "1st"}
		aIntelligence[20] = {7, 12, 96, "All", "1,2"}
		aIntelligence[21] = {7, 13, 97, "All", "1,2,3"}
		aIntelligence[22] = {7, 14, 98, "All", "1,2,3,4"}
		aIntelligence[23] = {7, 15, 99, "All", "1,2,3,4,5"}
		aIntelligence[24] = {7, 16, 100, "All", "1,2,3,4,5,6"}
		aIntelligence[25] = {7, 17, 100, "All", "1,2,3,4,5,6,7"}
		-- these have such long values we stuff them into tooltips instead
		aIntelligence[119] = {7, 11, 95, "All", "Level: 1st"}
		aIntelligence[120] = {7, 12, 96, "All", "Level: 1st, 2nd"}
		aIntelligence[121] = {7, 13, 97, "All", "Level: 1st, 2nd, 3rd"}
		aIntelligence[122] = {7, 14, 98, "All", "Level: 1st, 2nd, 3rd, 4th"}
		aIntelligence[123] = {7, 15, 99, "All", "Level: 1st, 2nd, 3rd, 4th, 5th"}
		aIntelligence[124] = {7, 16, 100, "All", "Level: 1st, 2nd, 3rd, 4th, 5th, 6th"}
		aIntelligence[125] = {7, 17, 100, "All", "Level: 1st, 2nd, 3rd, 4th, 5th, 6th, 7th"}
		-- make sure the ruleset uses the same
		DataCommonADND.aIntelligence = aIntelligence

		-- this needs to stick around for NPC save values
		-- since they use the warrior table
		-- Death, Rod, Poly, Breath, Spell
		aWarriorSaves[0] = {16, 18, 17, 20, 19}
		aWarriorSaves[1] = {14, 16, 15, 17, 17}
		aWarriorSaves[2] = {14, 16, 15, 17, 17}
		aWarriorSaves[3] = {13, 15, 14, 16, 16}
		aWarriorSaves[4] = {13, 15, 14, 16, 16}
		aWarriorSaves[5] = {11, 13, 12, 13, 14}
		aWarriorSaves[6] = {11, 13, 12, 13, 14}
		aWarriorSaves[7] = {10, 12, 11, 12, 13}
		aWarriorSaves[8] = {10, 12, 11, 12, 13}
		aWarriorSaves[9] = {8, 10, 9, 9, 11}
		aWarriorSaves[10] = {8, 10, 9, 9, 11}
		aWarriorSaves[11] = {7, 9, 8, 8, 10}
		aWarriorSaves[12] = {7, 9, 8, 8, 10}
		aWarriorSaves[13] = {5, 7, 6, 5, 8}
		aWarriorSaves[14] = {5, 7, 6, 5, 8}
		aWarriorSaves[15] = {4, 6, 5, 4, 7}
		aWarriorSaves[16] = {4, 6, 5, 4, 7}
		aWarriorSaves[17] = {3, 5, 4, 4, 6}
		aWarriorSaves[18] = {3, 5, 4, 4, 6}
		aWarriorSaves[19] = {3, 5, 4, 4, 6}
		aWarriorSaves[20] = {3, 5, 4, 4, 6}
		aWarriorSaves[21] = {3, 5, 4, 4, 6}
		-- make sure the ruleset uses the same
		DataCommonADND.aWarriorSaves = aWarriorSaves

		-- this needs to stick around for NPC save values
		-- since they use the warrior table
		-- Death, Rod, Poly, Breath, Spell
		-- TODO: implement OSRIC saves in the extension, much like using the 1e/osric combat matrices option
		aWarriorSavesOsric[0] = {16, 18, 17, 20, 19}
		aWarriorSavesOsric[1] = {14, 16, 15, 17, 17}
		aWarriorSavesOsric[2] = {14, 16, 15, 17, 17}
		aWarriorSavesOsric[3] = {13, 15, 14, 16, 16}
		aWarriorSavesOsric[4] = {13, 15, 14, 16, 16}
		aWarriorSavesOsric[5] = {11, 13, 12, 13, 14}
		aWarriorSavesOsric[6] = {11, 13, 12, 13, 14}
		aWarriorSavesOsric[7] = {10, 12, 11, 12, 13}
		aWarriorSavesOsric[8] = {10, 12, 11, 12, 13}
		aWarriorSavesOsric[9] = {8, 10, 9, 9, 11}
		aWarriorSavesOsric[10] = {8, 10, 9, 9, 11}
		aWarriorSavesOsric[11] = {7, 9, 8, 8, 10}
		aWarriorSavesOsric[12] = {7, 9, 8, 8, 10}
		aWarriorSavesOsric[13] = {5, 7, 6, 5, 8}
		aWarriorSavesOsric[14] = {5, 7, 6, 5, 8}
		aWarriorSavesOsric[15] = {4, 6, 5, 4, 7}
		aWarriorSavesOsric[16] = {4, 6, 5, 4, 7}
		aWarriorSavesOsric[17] = {3, 5, 4, 4, 6}
		aWarriorSavesOsric[18] = {3, 5, 4, 4, 6}
		aWarriorSavesOsric[19] = {2, 4, 3, 3, 5}
		aWarriorSavesOsric[20] = {2, 4, 3, 3, 5}
		aWarriorSavesOsric[21] = {2, 4, 3, 3, 5}
		-- make sure the ruleset uses the same
		DataCommonADND.aWarriorSavesOsric = aWarriorSavesOsric

		aAssassinSaves[1] = {13, 14, 12, 16, 15}
		aAssassinSaves[2] = {13, 14, 12, 16, 15}
		aAssassinSaves[3] = {13, 14, 12, 16, 15}
		aAssassinSaves[4] = {13, 14, 12, 16, 15}
		aAssassinSaves[5] = {12, 12, 11, 15, 13}
		aAssassinSaves[6] = {12, 12, 11, 15, 13}
		aAssassinSaves[7] = {12, 12, 11, 15, 13}
		aAssassinSaves[8] = {12, 12, 11, 15, 13}
		aAssassinSaves[9] = {11, 10, 10, 14, 11}
		aAssassinSaves[10] = {11, 10, 10, 14, 11}
		aAssassinSaves[11] = {11, 10, 10, 14, 11}
		aAssassinSaves[12] = {11, 10, 10, 14, 11}
		aAssassinSaves[13] = {10, 8, 9, 13, 9}
		aAssassinSaves[14] = {10, 8, 9, 13, 9}
		aAssassinSaves[15] = {10, 8, 9, 13, 9}
		DataCommonADND.aAssassinSaves = aAssassinSaves

		aClericSaves[1] = {10, 14, 13, 16, 15}
		aClericSaves[2] = {10, 14, 13, 16, 15}
		aClericSaves[3] = {10, 14, 13, 16, 15}
		aClericSaves[4] = {9, 13, 12, 15, 15}
		aClericSaves[5] = {9, 13, 12, 15, 15}
		aClericSaves[6] = {9, 13, 12, 15, 15}
		aClericSaves[7] = {7, 11, 10, 13, 12}
		aClericSaves[8] = {7, 11, 10, 13, 12}
		aClericSaves[9] = {7, 11, 10, 13, 12}
		aClericSaves[10] = {6, 10, 9, 12, 11}
		aClericSaves[11] = {6, 10, 9, 12, 11}
		aClericSaves[12] = {6, 10, 9, 12, 11}
		aClericSaves[13] = {5, 9, 8, 11, 10}
		aClericSaves[14] = {5, 9, 8, 11, 10}
		aClericSaves[15] = {5, 9, 8, 11, 10}
		aClericSaves[16] = {4, 8, 7, 10, 9}
		aClericSaves[17] = {4, 8, 7, 10, 9}
		aClericSaves[18] = {4, 8, 7, 10, 9}
		aClericSaves[19] = {2, 6, 5, 8, 7}
		DataCommonADND.aClericSaves = aClericSaves

		aDruidSaves[1] = {10, 14, 13, 16, 15}
		aDruidSaves[2] = {10, 14, 13, 16, 15}
		aDruidSaves[3] = {10, 14, 13, 16, 15}
		aDruidSaves[4] = {9, 13, 12, 15, 15}
		aDruidSaves[5] = {9, 13, 12, 15, 15}
		aDruidSaves[6] = {9, 13, 12, 15, 15}
		aDruidSaves[7] = {7, 11, 10, 13, 12}
		aDruidSaves[8] = {7, 11, 10, 13, 12}
		aDruidSaves[9] = {7, 11, 10, 13, 12}
		aDruidSaves[10] = {6, 10, 9, 12, 11}
		aDruidSaves[11] = {6, 10, 9, 12, 11}
		aDruidSaves[12] = {6, 10, 9, 12, 11}
		aDruidSaves[13] = {5, 9, 8, 11, 10}
		aDruidSaves[14] = {5, 9, 8, 11, 10}
		DataCommonADND.aDruidSaves = aDruidSaves

		aFighterSaves[0] = {16, 18, 17, 20, 19}
		aFighterSaves[1] = {14, 16, 15, 17, 17}
		aFighterSaves[2] = {14, 16, 15, 17, 17}
		aFighterSaves[3] = {13, 15, 14, 16, 16}
		aFighterSaves[4] = {13, 15, 14, 16, 16}
		aFighterSaves[5] = {11, 13, 12, 13, 14}
		aFighterSaves[6] = {11, 13, 12, 13, 14}
		aFighterSaves[7] = {10, 12, 11, 12, 13}
		aFighterSaves[8] = {10, 12, 11, 12, 13}
		aFighterSaves[9] = {8, 10, 9, 9, 11}
		aFighterSaves[10] = {8, 10, 9, 9, 11}
		aFighterSaves[11] = {7, 9, 8, 8, 10}
		aFighterSaves[12] = {7, 9, 8, 8, 10}
		aFighterSaves[13] = {5, 7, 6, 5, 8}
		aFighterSaves[14] = {5, 7, 6, 5, 8}
		aFighterSaves[15] = {4, 6, 5, 4, 7}
		aFighterSaves[16] = {4, 6, 5, 4, 7}
		aFighterSaves[17] = {3, 5, 4, 4, 6}
		aFighterSaves[18] = {3, 5, 4, 4, 6}
		aFighterSaves[19] = {2, 4, 3, 3, 5}
		DataCommonADND.aFighterSaves = aFighterSaves

		aIllusionistSaves[1] = {14, 11, 13, 15, 12}
		aIllusionistSaves[2] = {14, 11, 13, 15, 12}
		aIllusionistSaves[3] = {14, 11, 13, 15, 12}
		aIllusionistSaves[4] = {14, 11, 13, 15, 12}
		aIllusionistSaves[5] = {14, 11, 13, 15, 12}
		aIllusionistSaves[6] = {13, 9, 11, 13, 10}
		aIllusionistSaves[7] = {13, 9, 11, 13, 10}
		aIllusionistSaves[8] = {13, 9, 11, 13, 10}
		aIllusionistSaves[9] = {13, 9, 11, 13, 10}
		aIllusionistSaves[10] = {13, 9, 11, 13, 10}
		aIllusionistSaves[11] = {11, 7, 9, 11, 8}
		aIllusionistSaves[12] = {11, 7, 9, 11, 8}
		aIllusionistSaves[13] = {11, 7, 9, 11, 8}
		aIllusionistSaves[14] = {11, 7, 9, 11, 8}
		aIllusionistSaves[15] = {11, 7, 9, 11, 8}
		aIllusionistSaves[16] = {10, 5, 7, 9, 6}
		aIllusionistSaves[17] = {10, 5, 7, 9, 6}
		aIllusionistSaves[18] = {10, 5, 7, 9, 6}
		aIllusionistSaves[19] = {10, 5, 7, 9, 6}
		aIllusionistSaves[20] = {10, 5, 7, 9, 6}
		aIllusionistSaves[21] = {8, 3, 5, 7, 4}
		DataCommonADND.aIllusionistSaves = aIllusionistSaves

		aMagicUserSaves[1] = {14, 11, 13, 15, 12}
		aMagicUserSaves[2] = {14, 11, 13, 15, 12}
		aMagicUserSaves[3] = {14, 11, 13, 15, 12}
		aMagicUserSaves[4] = {14, 11, 13, 15, 12}
		aMagicUserSaves[5] = {14, 11, 13, 15, 12}
		aMagicUserSaves[6] = {13, 9, 11, 13, 10}
		aMagicUserSaves[7] = {13, 9, 11, 13, 10}
		aMagicUserSaves[8] = {13, 9, 11, 13, 10}
		aMagicUserSaves[9] = {13, 9, 11, 13, 10}
		aMagicUserSaves[10] = {13, 9, 11, 13, 10}
		aMagicUserSaves[11] = {11, 7, 9, 11, 8}
		aMagicUserSaves[12] = {11, 7, 9, 11, 8}
		aMagicUserSaves[13] = {11, 7, 9, 11, 8}
		aMagicUserSaves[14] = {11, 7, 9, 11, 8}
		aMagicUserSaves[15] = {11, 7, 9, 11, 8}
		aMagicUserSaves[16] = {10, 5, 7, 9, 6}
		aMagicUserSaves[17] = {10, 5, 7, 9, 6}
		aMagicUserSaves[18] = {10, 5, 7, 9, 6}
		aMagicUserSaves[19] = {10, 5, 7, 9, 6}
		aMagicUserSaves[20] = {10, 5, 7, 9, 6}
		aMagicUserSaves[21] = {8, 3, 5, 7, 4}
		DataCommonADND.aMagicUserSaves = aMagicUserSaves

		-- Death, Rod, Poly, Breath, Spell
		aPaladinSaves[1] = {12, 14, 13, 15, 15}
		aPaladinSaves[2] = {12, 14, 13, 15, 15}
		aPaladinSaves[3] = {11, 13, 10, 14, 14}
		aPaladinSaves[4] = {11, 13, 10, 14, 14}
		aPaladinSaves[5] = {9, 11, 10, 11, 12}
		aPaladinSaves[6] = {9, 11, 10, 11, 12}
		aPaladinSaves[7] = {8, 10, 9, 10, 11}
		aPaladinSaves[8] = {8, 10, 9, 10, 11}
		aPaladinSaves[9] = {6, 8, 7, 7, 9}
		aPaladinSaves[10] = {6, 8, 7, 7, 9}
		aPaladinSaves[11] = {5, 7, 6, 6, 8}
		aPaladinSaves[12] = {5, 7, 6, 6, 8}
		aPaladinSaves[13] = {3, 5, 4, 3, 6}
		aPaladinSaves[14] = {3, 5, 4, 3, 6}
		aPaladinSaves[15] = {2, 4, 3, 2, 5}
		aPaladinSaves[16] = {2, 4, 3, 2, 5}
		aPaladinSaves[17] = {2, 3, 2, 2, 4}
		aPaladinSaves[18] = {2, 3, 2, 2, 4}
		aPaladinSaves[19] = {2, 2, 2, 2, 3}
		DataCommonADND.aPaladinSaves = aPaladinSaves

		aRangerSaves[1] = {14, 16, 15, 17, 17}
		aRangerSaves[2] = {14, 16, 15, 17, 17}
		aRangerSaves[3] = {13, 15, 14, 16, 16}
		aRangerSaves[4] = {13, 15, 14, 16, 16}
		aRangerSaves[5] = {11, 13, 12, 13, 14}
		aRangerSaves[6] = {11, 13, 12, 13, 14}
		aRangerSaves[7] = {10, 12, 11, 12, 13}
		aRangerSaves[8] = {10, 12, 11, 12, 13}
		aRangerSaves[9] = {8, 10, 9, 9, 11}
		aRangerSaves[10] = {8, 10, 9, 9, 11}
		aRangerSaves[11] = {7, 9, 8, 8, 10}
		aRangerSaves[12] = {7, 9, 8, 8, 10}
		aRangerSaves[13] = {5, 7, 6, 5, 8}
		aRangerSaves[14] = {5, 7, 6, 5, 8}
		aRangerSaves[15] = {4, 6, 5, 4, 7}
		aRangerSaves[16] = {4, 6, 5, 4, 7}
		aRangerSaves[17] = {3, 5, 4, 4, 6}
		aRangerSaves[18] = {3, 5, 4, 4, 6}
		aRangerSaves[19] = {2, 4, 3, 3, 5}
		DataCommonADND.aRangerSaves = aRangerSaves

		aThiefSaves[1] = {13, 14, 12, 16, 15}
		aThiefSaves[2] = {13, 14, 12, 16, 15}
		aThiefSaves[3] = {13, 14, 12, 16, 15}
		aThiefSaves[4] = {13, 14, 12, 16, 15}
		aThiefSaves[5] = {12, 12, 11, 15, 13}
		aThiefSaves[6] = {12, 12, 11, 15, 13}
		aThiefSaves[7] = {12, 12, 11, 15, 13}
		aThiefSaves[8] = {12, 12, 11, 15, 13}
		aThiefSaves[9] = {11, 10, 10, 14, 11}
		aThiefSaves[10] = {11, 10, 10, 14, 11}
		aThiefSaves[11] = {11, 10, 10, 14, 11}
		aThiefSaves[12] = {11, 10, 10, 14, 11}
		aThiefSaves[13] = {10, 8, 9, 13, 9}
		aThiefSaves[14] = {10, 8, 9, 13, 9}
		aThiefSaves[15] = {10, 8, 9, 13, 9}
		aThiefSaves[16] = {10, 8, 9, 13, 9}
		aThiefSaves[17] = {9, 6, 8, 12, 7}
		aThiefSaves[18] = {9, 6, 8, 12, 7}
		aThiefSaves[19] = {9, 6, 8, 12, 7}
		aThiefSaves[20] = {9, 6, 8, 12, 7}
		aThiefSaves[21] = {8, 4, 7, 11, 5}
		DataCommonADND.aThiefSaves = aThiefSaves

		aIllusionistToHitMatrix[1] = {
			11,
			12,
			13,
			14,
			15,
			16,
			17,
			18,
			19,
			20,
			20,
			20,
			20,
			20,
			20,
			21,
			22,
			23,
			24,
			25,
			26
		}
		aIllusionistToHitMatrix[2] = {
			11,
			12,
			13,
			14,
			15,
			16,
			17,
			18,
			19,
			20,
			20,
			20,
			20,
			20,
			20,
			21,
			22,
			23,
			24,
			25,
			26
		}
		aIllusionistToHitMatrix[3] = {
			11,
			12,
			13,
			14,
			15,
			16,
			17,
			18,
			19,
			20,
			20,
			20,
			20,
			20,
			20,
			21,
			22,
			23,
			24,
			25,
			26
		}
		aIllusionistToHitMatrix[4] = {
			11,
			12,
			13,
			14,
			15,
			16,
			17,
			18,
			19,
			20,
			20,
			20,
			20,
			20,
			20,
			21,
			22,
			23,
			24,
			25,
			26
		}
		aIllusionistToHitMatrix[5] = {
			11,
			12,
			13,
			14,
			15,
			16,
			17,
			18,
			19,
			20,
			20,
			20,
			20,
			20,
			20,
			21,
			22,
			23,
			24,
			25,
			26
		}
		aIllusionistToHitMatrix[6] = {9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24}
		aIllusionistToHitMatrix[7] = {9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24}
		aIllusionistToHitMatrix[8] = {9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24}
		aIllusionistToHitMatrix[9] = {9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24}
		aIllusionistToHitMatrix[10] = {
			9,
			10,
			11,
			12,
			13,
			14,
			15,
			16,
			17,
			18,
			19,
			20,
			20,
			20,
			20,
			20,
			20,
			21,
			22,
			23,
			24
		}
		aIllusionistToHitMatrix[11] = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22}
		aIllusionistToHitMatrix[12] = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22}
		aIllusionistToHitMatrix[13] = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22}
		aIllusionistToHitMatrix[14] = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22}
		aIllusionistToHitMatrix[15] = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22}
		aIllusionistToHitMatrix[16] = {5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20}
		aIllusionistToHitMatrix[17] = {5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20}
		aIllusionistToHitMatrix[18] = {5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20}
		aIllusionistToHitMatrix[19] = {5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20}
		aIllusionistToHitMatrix[20] = {5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20}
		aIllusionistToHitMatrix[21] = {3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20}
		DataCommonADND.aIllusionistToHitMatrix = aIllusionistToHitMatrix

		aMagicUserToHitMatrix[1] = {11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24, 25, 26}
		aMagicUserToHitMatrix[2] = {11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24, 25, 26}
		aMagicUserToHitMatrix[3] = {11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24, 25, 26}
		aMagicUserToHitMatrix[4] = {11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24, 25, 26}
		aMagicUserToHitMatrix[5] = {11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24, 25, 26}
		aMagicUserToHitMatrix[6] = {9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24}
		aMagicUserToHitMatrix[7] = {9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24}
		aMagicUserToHitMatrix[8] = {9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24}
		aMagicUserToHitMatrix[9] = {9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24}
		aMagicUserToHitMatrix[10] = {9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24}
		aMagicUserToHitMatrix[11] = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22}
		aMagicUserToHitMatrix[12] = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22}
		aMagicUserToHitMatrix[13] = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22}
		aMagicUserToHitMatrix[14] = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22}
		aMagicUserToHitMatrix[15] = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22}
		aMagicUserToHitMatrix[16] = {5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20}
		aMagicUserToHitMatrix[17] = {5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20}
		aMagicUserToHitMatrix[18] = {5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20}
		aMagicUserToHitMatrix[19] = {5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20}
		aMagicUserToHitMatrix[20] = {5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20}
		aMagicUserToHitMatrix[21] = {3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20}
		DataCommonADND.aMagicUserToHitMatrix = aMagicUserToHitMatrix

		aPaladinToHitMatrix[0] = {11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24, 25, 26}
		aPaladinToHitMatrix[1] = {10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24, 25}
		aPaladinToHitMatrix[2] = {9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24}
		aPaladinToHitMatrix[3] = {8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23}
		aPaladinToHitMatrix[4] = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22}
		aPaladinToHitMatrix[5] = {6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21}
		aPaladinToHitMatrix[6] = {5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20}
		aPaladinToHitMatrix[7] = {4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20}
		aPaladinToHitMatrix[8] = {3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20}
		aPaladinToHitMatrix[9] = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20}
		aPaladinToHitMatrix[10] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20}
		aPaladinToHitMatrix[11] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}
		aPaladinToHitMatrix[12] = {-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19}
		aPaladinToHitMatrix[13] = {-2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18}
		aPaladinToHitMatrix[14] = {-3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17}
		aPaladinToHitMatrix[15] = {-4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}
		aPaladinToHitMatrix[16] = {-5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}
		aPaladinToHitMatrix[17] = {-6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14}
		aPaladinToHitMatrix[18] = {-7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13}
		aPaladinToHitMatrix[19] = {-8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}
		aPaladinToHitMatrix[20] = {-9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}
		DataCommonADND.aPaladinToHitMatrix = aPaladinToHitMatrix

		aRangerToHitMatrix[0] = {11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24, 25, 26}
		aRangerToHitMatrix[1] = {10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24, 25}
		aRangerToHitMatrix[2] = {9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24}
		aRangerToHitMatrix[3] = {8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23}
		aRangerToHitMatrix[4] = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22}
		aRangerToHitMatrix[5] = {6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21}
		aRangerToHitMatrix[6] = {5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20}
		aRangerToHitMatrix[7] = {4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20}
		aRangerToHitMatrix[8] = {3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20}
		aRangerToHitMatrix[9] = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20}
		aRangerToHitMatrix[10] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20}
		aRangerToHitMatrix[11] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}
		aRangerToHitMatrix[12] = {-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19}
		aRangerToHitMatrix[13] = {-2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18}
		aRangerToHitMatrix[14] = {-3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17}
		aRangerToHitMatrix[15] = {-4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}
		aRangerToHitMatrix[16] = {-5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}
		aRangerToHitMatrix[17] = {-6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14}
		aRangerToHitMatrix[18] = {-7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13}
		aRangerToHitMatrix[19] = {-8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}
		aRangerToHitMatrix[20] = {-9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}
		DataCommonADND.aRangerToHitMatrix = aRangerToHitMatrix

		aThiefToHitMatrix[1] = {11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24, 25, 26}
		aThiefToHitMatrix[2] = {11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24, 25, 26}
		aThiefToHitMatrix[3] = {11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24, 25, 26}
		aThiefToHitMatrix[4] = {11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24, 25, 26}
		aThiefToHitMatrix[5] = {9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24}
		aThiefToHitMatrix[6] = {9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24}
		aThiefToHitMatrix[7] = {9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24}
		aThiefToHitMatrix[8] = {9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24}
		aThiefToHitMatrix[9] = {6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21}
		aThiefToHitMatrix[10] = {6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21}
		aThiefToHitMatrix[11] = {6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21}
		aThiefToHitMatrix[12] = {6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21}
		aThiefToHitMatrix[13] = {4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20}
		aThiefToHitMatrix[14] = {4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20}
		aThiefToHitMatrix[15] = {4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20}
		aThiefToHitMatrix[16] = {4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20}
		aThiefToHitMatrix[17] = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20}
		aThiefToHitMatrix[18] = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20}
		aThiefToHitMatrix[19] = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20}
		aThiefToHitMatrix[20] = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20}
		aThiefToHitMatrix[21] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}
		DataCommonADND.aThiefToHitMatrix = aThiefToHitMatrix

		aMatrix["-1"] = {11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24, 25, 26} -- below 1-1
		aMatrix["1-1"] = {10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24, 25} -- 1-1
		aMatrix["1"] = {9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24}
		aMatrix["1+"] = {8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23} -- 1+X
		aMatrix["2"] = {6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21}
		aMatrix["3"] = {6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21}
		aMatrix["4"] = {5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20}
		aMatrix["5"] = {5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20}
		aMatrix["6"] = {3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20}
		aMatrix["7"] = {3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20}
		aMatrix["8"] = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20}
		aMatrix["9"] = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20}
		aMatrix["10"] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}
		aMatrix["11"] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}
		aMatrix["12"] = {-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19}
		aMatrix["13"] = {-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19}
		aMatrix["14"] = {-2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18}
		aMatrix["15"] = {-2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18}
		aMatrix["16"] = {-3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17}
		DataCommonADND.aMatrix = aMatrix

		aOsricToHitMatrix[0] = {11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24, 25, 26}
		aOsricToHitMatrix[1] = {10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24, 25}
		aOsricToHitMatrix[2] = {9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23, 24}
		aOsricToHitMatrix[3] = {8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22, 23}
		aOsricToHitMatrix[4] = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21, 22}
		aOsricToHitMatrix[5] = {6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 21}
		aOsricToHitMatrix[6] = {5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20}
		aOsricToHitMatrix[7] = {4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20}
		aOsricToHitMatrix[8] = {3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20}
		aOsricToHitMatrix[9] = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20}
		aOsricToHitMatrix[10] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20}
		aOsricToHitMatrix[11] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}
		aOsricToHitMatrix[12] = {-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19}
		aOsricToHitMatrix[13] = {-2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18}
		aOsricToHitMatrix[14] = {-3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17}
		aOsricToHitMatrix[15] = {-4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}
		aOsricToHitMatrix[16] = {-5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}
		aOsricToHitMatrix[17] = {-6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14}
		aOsricToHitMatrix[18] = {-7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13}
		aOsricToHitMatrix[19] = {-8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}
		aOsricToHitMatrix[20] = {-9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}
		DataCommonADND.aOsricToHitMatrix = aOsricToHitMatrix

		CharEncumbranceManager.addCustomCalc(CharManager.calcWeightCarried)
	end
end
