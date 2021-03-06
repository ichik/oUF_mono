local _, ns = ...
local oUF = ns.oUF or oUF
if not oUF then return end

local L = {
  ["Prayer of Mending"] = GetSpellInfo(33076),
  ["Renew"] = GetSpellInfo(139),
  ["Power Word: Shield"] = GetSpellInfo(17),
  ["Weakened Soul"] = GetSpellInfo(6788),
  ["Shadow Protection"] = GetSpellInfo(27683),
  ["Power Word: Fortitude"] = GetSpellInfo(21562),
  ["Fear Ward"] = GetSpellInfo(6346),
  ["Lifebloom"] = GetSpellInfo(33763),
  ["Rejuvenation"] = GetSpellInfo(774),
  ["Regrowth"] = GetSpellInfo(8936),
  ["Wild Growth"] = GetSpellInfo(48438),
  ["Mark of the Wild"] = GetSpellInfo(1126),
  ["Horn of Winter"] = GetSpellInfo(57330),
  ["Battle Shout"] = GetSpellInfo(6673),
  ["Commanding Shout"] = GetSpellInfo(469),
  ["Vigilance"] = GetSpellInfo(50720),
  ["Beacon of Light"] = GetSpellInfo(53563),
  ["Hand of Sacrifice"] = GetSpellInfo(6940),
  ["Hand of Freedom"] = GetSpellInfo(1044),
  ["Hand of Protection"] = GetSpellInfo(1022),
  ['Earth Shield'] = GetSpellInfo(974),
  ['Riptide'] = GetSpellInfo(61295),
  ['Shield Wall'] = GetSpellInfo(871),
}
local x = "M"

local getTime = function(expirationTime)
	local expire = -1*(GetTime()-expirationTime)
	local timeleft = format("%.0f", expire)
	if expire > 0.5 then
		local spellTimer = "|cffffff00"..timeleft.."|r"
		return spellTimer
	end
end

local function CalcDebuff(uid, debuff) -- to fill some information gaps of UnitDebuff()
	local name, icon, count, dur, expirationTime, caster, sdur, timeleft, start, dname
	if type(debuff) == "number" then
		dname = GetSpellInfo(debuff);
		if not dname then dname = debuff; end
	else
		dname = debuff;
	end
	name, _, icon, count, _, dur, expirationTime, caster = UnitDebuff(uid, dname);
	if (name == dname) then
		if dur and dur > 0 then
			sdur = dur;
			start = expirationTime - dur;
			timeleft = GetTime() - start;
		else
			sdur = 0;
			ftimeleft = 0;
			start = 0;
		end
	end
	return name, count, icon, start, sdur, caster, timeleft;
end

-----------------[[ GENERAL TAGS ]]-----------------
oUF.Tags['raid:wrack'] = function(u) -- Sinestra's specific debuff
	local name,_,_,_,dur,_,remaining = CalcDebuff(u, GetSpellInfo(92956)) -- 57724 debug
	if not (name and remaining) then return end
	if remaining > 14 then -- FOAD
		return "|cffFF0000"..x.."|r"
	elseif remaining > 10 then -- criticall! dispel now!
		return "|cffFFCC00"..x.."|r"
	elseif remaining > 8 then -- start thinking about dispel!
		return "|cff00FF00"..x.."|r"
	else
		return "|cffB1C4B9"..x.."|r"
	end
end
oUF.TagEvents['raid:wrack'] = "UNIT_AURA"

oUF.Tags['raid:aggro'] = function(u) 
	local s = UnitThreatSituation(u) if s == 2 or s == 3 then return "|cffFF0000"..x.."|r" end end
oUF.TagEvents['raid:aggro'] = "UNIT_THREAT_SITUATION_UPDATE"

-----------------[[ CLASS SPECIFIC TAGS ]]-----------------
--priest
oUF.Tags['raid:rnw'] = function(u)
    local name, _,_,_,_,_, expirationTime, fromwho = UnitAura(u, GetSpellInfo(139))
    if(fromwho == "player") then
        local spellTimer = GetTime()-expirationTime
        if spellTimer > -2 then
            return "|cffFF0000"..x.."|r"
        elseif spellTimer > -4 then
            return "|cffFF9900"..x.."|r"
        else
            return "|cff33FF33"..x.."|r"
        end
    end
end
oUF.TagEvents['raid:rnw'] = "UNIT_AURA"
-- rnwtime
oUF.Tags['raid:rnwTime'] = function(u)
  local name, _,_,_,_,_, expirationTime, fromwho,_ = UnitAura(u, L["Renew"])
  if (fromwho == "player") then return getTime(expirationTime) end 
end
oUF.TagEvents['raid:rnwTime'] = "UNIT_AURA"
oUF.Tags['raid:pws'] = function(u) if UnitAura(u, L["Power Word: Shield"]) then return "|cff33FF33"..x.."|r" end end
oUF.TagEvents['raid:pws'] = "UNIT_AURA"
oUF.Tags['raid:ws'] = function(u) if UnitDebuff(u, L["Weakened Soul"]) then return "|cffFF9900"..x.."|r" end end
oUF.TagEvents['raid:ws'] = "UNIT_AURA"
oUF.Tags['raid:fw'] = function(u) if UnitAura(u, L["Fear Ward"]) then return "|cff8B4513"..x.."|r" end end
oUF.TagEvents['raid:fw'] = "UNIT_AURA"
oUF.Tags['raid:sp'] = function(u) local c = UnitAura(u, L["Shadow Protection"]) if not c then return "|cff9900FF"..x.."|r" end end
oUF.TagEvents['raid:sp'] = "UNIT_AURA"
oUF.Tags['raid:fort'] = function(u) local c = UnitAura(u, L["Power Word: Fortitude"]) if not c then return "|cff00A1DE"..x.."|r" end end
oUF.TagEvents['raid:fort'] = "UNIT_AURA"
oUF.Tags['raid:wsTime'] = function(u)
  local name, _,_,_,_,_, expirationTime = UnitDebuff(u, L["Weakened Soul"])
  if UnitDebuff(u, L["Weakened Soul"]) then return getTime(expirationTime) end
end
oUF.TagEvents['raid:wsTime'] = "UNIT_AURA"

--druid
oUF.Tags['raid:rejuv'] = function(u) 
  local name, _,_,_,_,_,_, fromwho,_ = UnitAura(u, L["Rejuvenation"])
  if not (fromwho == "player") then return end
  if UnitAura(u, L["Rejuvenation"]) then return "|cff00FEBF"..x.."|r" end end
oUF.TagEvents['raid:rejuv'] = "UNIT_AURA"
-- rejuvtime
oUF.Tags['raid:rejuvTime'] = function(u)
  local name, _,_,_,_,_, expirationTime, fromwho,_ = UnitAura(u, L["Rejuvenation"])
  if (fromwho == "player") then return getTime(expirationTime) end 
end
oUF.TagEvents['raid:rejuvTime'] = "UNIT_AURA"
oUF.Tags['raid:regrow'] = function(u) if UnitAura(u, L["Regrowth"]) then return "|cff00FF10"..x.."|r" end end
oUF.TagEvents['raid:regrow'] = "UNIT_AURA"
oUF.Tags['raid:wg'] = function(u) if UnitAura(u, L["Wild Growth"]) then return "|cff33FF33"..x.."|r" end end
oUF.TagEvents['raid:wg'] = "UNIT_AURA"
oUF.Tags['raid:motw'] = function(u) if not(UnitAura(u, GetSpellInfo(79060)) or UnitAura(u,GetSpellInfo(79063))) then return "|cff00A1DE"..x.."|r" end end
oUF.TagEvents['raid:motw'] = "UNIT_AURA"

--warrior
oUF.Tags['raid:Bsh'] = function(u) if UnitAura(u, L["Battle Shout"]) then return "|cffff0000"..x.."|r" end end
oUF.TagEvents['raid:Bsh'] = "UNIT_AURA"
oUF.Tags['raid:Csh'] = function(u) if UnitAura(u, L["Commanding Shout"]) then return "|cffffff00"..x.."|r" end end
oUF.TagEvents['raid:Csh'] = "UNIT_AURA"
oUF.Tags['raid:vigil'] = function(u)
  local name, _,_,_,_,_,_, fromwho,_ = UnitAura(u, L["Vigilance"])
  if not (fromwho == "player") then return end
  if UnitAura(u, L["Vigilance"]) then return "|cffDEB887"..x.."|r" end end
oUF.TagEvents['raid:vigil'] = "UNIT_AURA"
oUF.Tags['raid:SW'] = function(u) if UnitAura(u, L['Shield Wall']) then return "|cff9900FF"..x.."|r" end end
oUF.TagEvents['raid:SW'] = "UNIT_AURA"

--deathknight
oUF.Tags['raid:how'] = function(u) if UnitAura(u, L["Horn of Winter"]) then return "|cffffff10"..x.."|r" end end
oUF.TagEvents['raid:how'] = "UNIT_AURA"

--paladin
oUF.TagEvents['raid:beaconTime'] = "UNIT_AURA"
oUF.Tags['raid:HoS'] = function(u) if UnitAura(u, L["Hand of Sacrifice"]) then return "|cffEB2175"..x.."|r" end end
oUF.TagEvents['raid:HoS'] = "UNIT_AURA"
oUF.Tags['raid:HoF'] = function(u) if UnitAura(u, L["Hand of Freedom"]) then return "|cffA7EB21"..x.."|r" end end
oUF.TagEvents['raid:HoF'] = "UNIT_AURA"
oUF.Tags['raid:HoP'] = function(u) if UnitAura(u, L["Hand of Protection"]) then return "|cff96470F"..x.."|r" end end
oUF.TagEvents['raid:HoP'] = "UNIT_AURA"
oUF.Tags['raid:might'] = function(u) if not UnitAura(u, GetSpellInfo(79102)) then return "|cffFF0000"..x.."|r" end end
oUF.TagEvents['raid:might'] = "UNIT_AURA"
oUF.Tags['raid:beacon'] = function(u)
    local name, _,_,_,_,_, expirationTime, fromwho = UnitAura(u, GetSpellInfo(53563))
    if not name then return end
    if(fromwho == "player") then
        local spellTimer = GetTime()-expirationTime
        if spellTimer > -30 then
            return "|cffFF0000"..x.."|r"
        else
            return "|cffFFCC00"..x.."|r"
        end
    else
        return "|cff996600"..x.."|r" -- other pally's beacon
    end
end
oUF.TagEvents['raid:beacon'] = "UNIT_AURA"

--shaman
oUF.Tags['raid:rip'] = function(u) 
	local name, _,_,_,_,_,_, fromwho,_ = UnitAura(u, L['Riptide'])
	if not (fromwho == 'player') then return end
	if UnitAura(u, L['Riptide']) then return '|cff00FEBF'..x..'|r' end end
oUF.TagEvents['raid:rip'] = 'UNIT_AURA'
oUF.Tags['raid:ripTime'] = function(u)
	local name, _,_,_,_,_, expirationTime, fromwho,_ = UnitAura(u, L['Riptide'])
	if (fromwho == "player") then return getTime(expirationTime) end 
end
oUF.TagEvents['raid:ripTime'] = 'UNIT_AURA'

--DK
oUF.Tags['raid:abomight'] = function(u) if not(UnitAura(u, GetSpellInfo(53138)) or UnitAura(u, GetSpellInfo(79102))) then return "|cffFF0000"..x.."|r" end end
oUF.TagEvents['raid:abomight'] = "UNIT_AURA"

oUF.classIndicators={
		["DRUID"] = {
				["TL"] = "[raid:regrow][raid:wg]",
				["TR"] = "[raid:lb]",
				["BL"] = "[raid:wrack]",
				["BR"] = "[raid:motw]",
				["Cen"] = "[raid:rejuvTime]",
		},
		["PRIEST"] = {
				["TL"] = "[raid:pws][raid:ws]",
				["TR"] = "[raid:pom]",
				["BL"] = "[raid:fw][raid:wrack]",
				["BR"] = "[raid:sp][raid:fort]",
				["Cen"] = "[raid:rnwTime]",
		},
		["PALADIN"] = {
				["TL"] = "[raid:HoS][raid:HoF][raid:HoP]",
				["TR"] = "[raid:beacon]",
				["BL"] = "[raid:wrack]",
				["BR"] = "[raid:might][raid:motw]",
				["Cen"] = "",
				
		},
		["WARLOCK"] = {
				["TL"] = "",
				["TR"] = "",
				["BL"] = "[raid:wrack]",
				["BR"] = "",
				["Cen"] = "",
		},
		["WARRIOR"] = {
				["TL"] = "[raid:vigil]",
				["TR"] = "",
				["BL"] = "[raid:wrack]",
				["BR"] = "",
				["Cen"] = "",
		},
		["DEATHKNIGHT"] = {
				["TL"] = "[raid:abomight]",
				["TR"] = "",
				["BL"] = "[raid:wrack]",
				["BR"] = "[raid:how]",
				["Cen"] = "",
		},
		["SHAMAN"] = {
				["TL"] = "",
				["TR"] = "[raid:earth]",
				["BL"] = "[raid:wrack]",
				["BR"] = "",
				["Cen"] = "[raid:ripTime]",
		},
		["HUNTER"] = {
				["TL"] = "",
				["TR"] = "",
				["BL"] = "[raid:wrack]",
				["BR"] = "",
				["Cen"] = "",
		},
		["ROGUE"] = {
				["TL"] = "",
				["TR"] = "",
				["BL"] = "[raid:wrack]",
				["BR"] = "",
				["Cen"] = "",
		},
		["MAGE"] = {
				["TL"] = "",
				["TR"] = "",
				["BL"] = "[raid:wrack]",
				["BR"] = "",
				["Cen"] = "",
		}
}
