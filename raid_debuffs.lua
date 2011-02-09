local L = {
    ["Baradin Hold"] = 752,
    ["Blackwing Descent"] = 754,
    ["The Bastion of Twilight"] = 758,
    ["Throne of the Four Winds"] = 773,
}

raid_debuffs = {
	debuffs = {
		-- Any Zone
		--["Weakened Soul"] = 12, -- testing purpposes only
		--["Sated"] = 12, -- testing purpposes only

		["Wound Poison"] = 9, -- Wound Poison
		["Mortal Strike"] = 8, -- Mortal Strike
		["Furious Attacks"] = 8, -- Furious Attacks
		["Aimed Shot"] = 8, -- Aimed Shot
		["Counterspell"] = 10, -- Counterspell
		["Blind"] = 10, -- Blind
		["Cyclone"] = 10, -- Cyclone
		["Polymorph"] = 7, -- Polymorph
		["Entangling Roots"] = 7, -- Entangling Roots
		["Freezing Trap"] = 7, -- Freezing Trap
		["Crippling Poison"] = 6, -- Crippling Poison
		["Hamstring"] = 5, -- Hamstring
		["Wing Clip"] = 5, -- Wing Clip
		["Fear"] = 3, -- Fear
		["Psychic Scream"] = 3, -- Psychic Scream
		["Howl of Terror"] = 3 -- Howl of Terror
	},
	instances = {
        [L["Baradin Hold"]] = {
            [GetSpellInfo(88954)] = 6, -- Consuming Darkness
        },
        
        [L["Blackwing Descent"]] = {
            --Magmaw
            [GetSpellInfo(78941)] = 6, -- Parasitic Infection
            [GetSpellInfo(89773)] = 7, -- Mangle
            --Omnitron Defense System
            [GetSpellInfo(79888)] = 6, -- Lightning Conductor
            [GetSpellInfo(79505)] = 8, -- Flamethrower
            [GetSpellInfo(80161)] = 7, -- Chemical Cloud
            [GetSpellInfo(79501)] = 8, -- Acquiring Target
            [GetSpellInfo(80011)] = 7, -- Soaked in Poison
            [GetSpellInfo(80094)] = 7, -- Fixate
            --Maloriak
            [GetSpellInfo(92973)] = 8, -- Consuming Flames
            [GetSpellInfo(92978)] = 8, -- Flash Freeze
            --[GetSpellInfo(92976)] = 7, -- Biting Chill
            [GetSpellInfo(91829)] = 7, -- Fixate
            --Atramedes
            [GetSpellInfo(78092)] = 7, -- Tracking
            [GetSpellInfo(78897)] = 8, -- Noisy
            [GetSpellInfo(78023)] = 7, -- Roaring Flame
            --Chimaeron
            [GetSpellInfo(89084)] = 8, -- Low Health
            [GetSpellInfo(82881)] = 7, -- Break
            [GetSpellInfo(82890)] = 9, -- Mortality
            --Nefarian
            [GetSpellInfo(94128)] = 7, -- Tail Lash
            [GetSpellInfo(94075)] = 8, -- Magma
        },

        [L["The Bastion of Twilight"]] = {
            --Halfus
            [GetSpellInfo(39171)] = 7, -- Malevolent Strikes
            [GetSpellInfo(86169)] = 8, -- Furious Roar
            --Valiona & Theralion
            [GetSpellInfo(86788)] = 6, -- Blackout
            [GetSpellInfo(86622)] = 7, -- Engulfing Magic
            [GetSpellInfo(86202)] = 7, -- Twilight Shift
            --Council
            [GetSpellInfo(82665)] = 7, -- Heart of Ice
            [GetSpellInfo(82660)] = 7, -- Burning Blood
            [GetSpellInfo(82762)] = 7, -- Waterlogged
            [GetSpellInfo(83099)] = 7, -- Lightning Rod
            [GetSpellInfo(82285)] = 7, -- Elemental Stasis
            [GetSpellInfo(92488)] = 8, -- Gravity Well
            --Cho'gall
            [GetSpellInfo(86028)] = 6, -- Cho's Blast
            [GetSpellInfo(86029)] = 6, -- Gall's Blast
            [GetSpellInfo(93189)] = 7, -- Corrupted Blood
            [GetSpellInfo(93133)] = 7, -- Debilitating Beam
            [GetSpellInfo(81836)] = 8, -- Corruption: Accelerated
            [GetSpellInfo(81831)] = 8, -- Corruption: Sickness
            [GetSpellInfo(82125)] = 8, -- Corruption: Malformation
            [GetSpellInfo(82170)] = 8, -- Corruption: Absolute 
        },

        [L["Throne of the Four Winds"]] = {
            --Conclave
            [GetSpellInfo(85576)] = 9, -- Withering Winds
            [GetSpellInfo(85573)] = 9, -- Deafening Winds
            [GetSpellInfo(93057)] = 7, -- Slicing Gale
            [GetSpellInfo(86481)] = 8, -- Hurricane
            [GetSpellInfo(93123)] = 7, -- Wind Chill
            [GetSpellInfo(93121)] = 8, -- Toxic Spores
            --Al'Akir
            --[GetSpellInfo(93281)] = 7, -- Acid Rain
            [GetSpellInfo(87873)] = 7, -- Static Shock
            [GetSpellInfo(88427)] = 7, -- Electrocute
            [GetSpellInfo(93294)] = 8, -- Lightning Rod
            [GetSpellInfo(93284)] = 9, -- Squall Line
        },
-------------------- WOTLK CONTENT --------------------
------enGB
		["Naxxramas"] = {
			["Locust Swarm"] = 12,
			["Necrotic Poison"] = 12,
			["Web Wrap"] = 12,
			["Jagged Knife"] = 12,
			["Mutating Injection"] = 12,
			["Detonate Mana"] = 12,
			["Frost Blast"] = 12,
			["Chains of Kel'Thuzad"] = 12,
		},
		["Ulduar"] = {
			["Slag Pot"] = 12,
			["Gravity Bomb"] = 12,
			["Light Bomb"] = 12,
			["Fusion Punch"] = 12,
			["Static Disruption"] = 12,
			["Stone Grip"] = 12,
			["Crunch Armor"] = 12,
			["Flash Freeze"] = 12,
			["Unbalancing Strike"] = 12,
			["Iron Roots"] = 12,
			["Nature's Fury"] = 12,
			["Napalm Shell"] = 12,
			["Mark of the Faceless"] = 12,
			["Sara's Fevor"] = 12,
			["Squeeze"] = 12,
			["Phase Punch"] = 12,
		},
		["Trial of the Crusader"] = {
			-- Beasts
			["Impale"] = 12,
			["Snobolled!"] = 12,
			["Paralytic Toxin"] = 12,
			["Burning Bile"] = 12,
			["Arctic Breathe"] = 12,
			-- Jaraxxus
			["Mistress' Kiss"] = 12,
			["Legion Flame"] = 12,
			["Incinerate Flesh"] = 11,
			-- Twins
			["Touch of Darkness"] = 12,
			["Touch of Light"] = 12,
			-- Anub
			["Pursued by Anub'arak"] = 12,
			["Penetrating Cold"] = 12,
		},
		["Trial of the Grand Crusader"] = {
			-- Beasts
			["Impale"] = 12,
			["Snobolled!"] = 12,
			["Paralytic Toxin"] = 12,
			["Burning Bile"] = 12,
			["Arctic Breathe"] = 12,
			-- Jaraxxus
			["Mistress' Kiss"] = 12,
			["Legion Flame"] = 12,
			["Incinerate Flesh"] = 11,
			-- Twins
			["Touch of Darkness"] = 12,
			["Touch of Light"] = 12,
			-- Anub
			["Pursued by Anub'arak"] = 12,
			["Penetrating Cold"] = 12,
		},
		["Icecrown Citadel"] = {
			-- Lord Marrowgar
			["Impaled"] = 12,
			-- Gunship Battle
			["Wounding Strike"] = 12,
			-- Saurfang
			["Boiling Blood"] = 12,
			["Mark of the Fallen Champion"] = 12,
			-- Festergut
			["Gas Spore"] = 12,
			["Vile Gas"] = 12,
			-- Rotface
			["Mutated Infection"] = 12,
			-- Putricide
			["Gaseous Bloat"] = 12,
			["Volatile Ooze Adhesive"] = 12,
			-- Lana'thel
			["Pact of the Darkfallen"] = 12,
			["Essence of the Blood Queen"] = 10,
			-- Sindragosa
			["Frost Beacon"] = 12,
	--		["Unchained Magic"] = 10,
			["Instability"] = 12,
			-- Lich King
			["Necrotic Plague"] = 12,
			["Pain and Suffering"] = 12,
			["Infest"] = 11,
		},
		["Ruby Sanctum"] = {
			["Enervating Brand"] = 12, -- Enervating Brand 
			["Blazing Aura"] = 12, -- Blazing Aura
			["Fiery Combustion"] = 12, -- Fiery Combustion
			["Mark of Combustion"] = 12, -- Mark of Combustion (Fire) 
			["Soul Consumption"] = 12, -- Soul Consumption
			["Mark Of Consumption"] = 12, -- Mark Of Consumption (Soul)
		},
		["The Bastion of Twilight"] = {
			 ["Lightning Rod"] = 12,
		},
		["Blackwing Descent"] = {
			["Lightning Conductor"] = 12,
			["Tracking"] = 12,
			["Low Health"] = 12,
		},

------ ruRU
		["Наксрамас"] = {
			["Рой саранчи"] = 12,
			["Кокон"] = 12,
			["Некротический яд"] = 12,
			["Мутагенный укол"] = 12,
			["Зазубренный нож"] = 12,
			["Морозная стрела"] = 12,
			["Взрыв маны"] = 11,
			["Ледяной взрыв"] = 12,
			["Цепи Кел'Тузада"] = 12,
		},
		["Ульдуар"] = {
			["Благословение Сары"] = 12,
			["Воспламенение"] = 12,
			["Гнев природы"] = 12,
			["Каменная хватка"] = 12,
			["Ледяной взрыв"] = 12,
			["Метка безликого"] = 12,
			["Опаляющий свет"] = 12,
			["Взрыв плазмы"] = 12,
			["Палящее пламя"] = 12,
			["Статический сбой"] = 12,
			["Шлаковый ковш"] = 12,
			["Заряд напалма"] = 12,
			["Железные корни"] = 12,
			["Нестабильная энергия"] = 11,
			["Выдавливание"] = 12,
			["Энергетическое ошеломление"] = 11,
		},
		["Испытание крестоносца"] = {
			-- Beasts
			["Прокалывание"] = 12,
			["Получи снобольда!"] = 12,
			["Паралитический токсин"] = 12,
			["Горящая желчь"] = 12,
			["Арктическое дыхание"] = 12,
			-- Jaraxxus
			["Поцелуй госпожи"] = 12,
			["Пламя легиона"] = 12,
			["Испепеление плоти"] = 11,
			-- Twins
			["Касание тьмы"] = 12,
			["Касание Света"] = 12,
			-- Anub
			["Вас преследует Ануб'арак"] = 12,
			["Пронизывающий холод"] = 12,
		},
		["Испытание великого крестоносца"] = {
			-- Beasts
			["Прокалывание"] = 12,
			["Получи снобольда!"] = 12,
			["Паралитический токсин"] = 12,
			["Горящая желчь"] = 12,
			["Арктическое дыхание"] = 12,
			-- Jaraxxus
			["Поцелуй госпожи"] = 12,
			["Пламя легиона"] = 12,
			["Испепеление плоти"] = 11,
			-- Twins
			["Касание тьмы"] = 12,
			["Касание Света"] = 12,
			-- Anub
			["Вас преследует Ануб'арак"] = 12,
			["Пронизывающий холод"] = 12,
		},
		["Цитадель Ледяной Короны"] = {
			-- Марровар
			["Прокалывание"] = 12,
			-- Воздушная битва
			["Ранящий удар"] = 12,
			-- Саурфанг
			["Метка падшего воителя"] = 12,
			["Кипящая кровь"] = 12,
			-- Гниломорд	
			["Мутировавшая инфекция"] = 12,
			-- Тухлопуз
			["Газообразные споры"] = 12,
			["Губительный газ"] = 12,
			-- Профессор Путрицид
			["Газовое вздутие"] = 12,
			["Выделения неустойчивого слизнюка"] = 12,
			-- Королева Лана'Тель
			["Пакт Омраченных"] = 12,
			["Сущность Кровавой королевы"] = 10,
		},
		["Рубиновое святилище"] = {

		},
		--[[
		["Zone"] = {
			[Name or GetSpellInfo(#)] = PRIORITY,
		},
		]]--
		
	},
}
