  local addon, ns = ...
  local cfg = ns.cfg
  local lib = ns.lib
  local lib_raid = CreateFrame("Frame")  
    
  -----------------------------
  -- local variables
  -----------------------------
  if not cfg.RAIDpos then cfg.RAIDpos = cfg.pos end -- compatability with old config files
  
  local _, class = UnitClass("player")
  local backdrop = {
      bgFile = cfg.highlightTex,
      insets = {top = 0, left = 0, bottom = 0, right = 0}}
  local glowBorder = {
      edgeFile = cfg.backdrop_edge_texture, edgeSize = 5,
      insets = {left = 3, right = 3, top = 3, bottom = 3}}
  local border = {
      bgFile = cfg.highlightTex,
      insets = {top = -1, left = -1, bottom = -1, right = -1}}
  local colors = setmetatable({
    power = setmetatable({
      ['MANA'] = {.31,.45,.63},
      ['RAGE'] = {.69,.31,.31},
      ['FOCUS'] = {.71,.43,.27},
      ['ENERGY'] = {.65,.63,.35},
      ['RUNIC_POWER'] = {0,.8,.9},}, 
      {__index = oUF.colors.power}),},
      {__index = oUF.colors})
  -----------------------------
  -- LOCAL FUNCTIONS
  -----------------------------
  local fixStatusbar = function(bar)
    bar:GetStatusBarTexture():SetHorizTile(false)
    bar:GetStatusBarTexture():SetVertTile(false)
  end
  
  local dispellClass = {
    PRIEST = { Magic = true, Disease = true, },
    SHAMAN = { Magic = true, Curse = true, },
    PALADIN = { Magic = true, Poison = true, Disease = true, },
    MAGE = { Curse = true, },
    DRUID = { Magic = true, Curse = true, Poison = true, },}
  local dispellist = dispellClass[class] or {}
  local dispellPriority = {
      Magic = 4,
      Poison = 3,
      Curse = 2,
      Disease = 1,}

  local instDebuffs = {}
  local instances = raid_debuffs.instances
  --local getzone = function(self, event)
  local getZone = CreateFrame"Frame"
  getZone:RegisterEvent"PLAYER_ENTERING_WORLD"
  getZone:RegisterEvent"ZONE_CHANGED_NEW_AREA"
  getZone:SetScript("OnEvent", function(self, event)
	SetMapToCurrentZone()
    local zone = GetCurrentMapAreaID()
    if instances[zone] then
      instDebuffs = instances[zone]
    else
      instDebuffs = {}
    end
	--print(GetInstanceInfo().." "..zone)
	if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
  end)

  local debuffs = raid_debuffs.debuffs
  local CustomFilter = function(icons, ...)
    local _, icon, name, _, _, _, dtype = ...
    if instDebuffs[name] then
      icon.priority = instDebuffs[name]
      return true
    elseif debuffs[name] then
      icon.priority = debuffs[name]
      return true
    elseif dispellist[dtype] then
      icon.priority = dispellPriority[dtype]
      return true
    else
      icon.priority = 0
    end
  end

  local ChangedTarget = function(self)
    if UnitIsUnit('target', self.unit) then
      self.TargetBorder:SetBackdropColor(.8, .8, .8, 1)
      self.TargetBorder:Show()
    else
      self.TargetBorder:Hide()
    end
  end

  local FocusTarget = function(self)
    if UnitIsUnit('focus', self.unit) then
      self.FocusHighlight:SetBackdropColor(cfg.focusHLcol[1], cfg.focusHLcol[2], cfg.focusHLcol[3], cfg.focusHLcol[4])
      self.FocusHighlight:Show()
    else
      self.FocusHighlight:Hide()
    end
  end

  local updateThreat = function(self, event, unit)
    if(unit ~= self.unit) then return end
    local threat = self.Threat
    unit = unit or self.unit
    local status = UnitThreatSituation(unit)
    if(status and status > 1) then
      local r, g, b = GetThreatStatusColor(status)
      threat:SetBackdropBorderColor(r, g, b, 1)
    else
      threat:SetBackdropBorderColor(0, 0, 0, 1)
    end
    threat:Show()
  end
  
  local PostUpdateHealth = function(s, unit)
    local r, g, b, t
    if(UnitIsPlayer(unit)) then
      local _, class = UnitClass(unit)
      t = oUF.colors.class[class]
    else
      r, g, b = .2, .9, .1
    end
    if(t) then
      r, g, b = t[1], t[2], t[3]
    end
    if(b) then
      local bg = s.bg
      if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
        bg:SetVertexColor(r/3, g/3, b/3, 0.8)
      else
        bg:SetVertexColor(r, g, b, 1)
      end
      s:SetStatusBarColor(0, 0, 0, .8)
    end
  end  
  
  local PostUpdatePower = function(power, unit)
    local _, ptype = UnitPowerType(unit)
    local self = power:GetParent()
    if ptype == 'MANA' then
      if(cfg.orientation == "VERTICAL")then
        power:SetPoint"TOP"
        power:SetWidth(cfg.width*cfg.powerbarsize)
        self.Health:SetWidth((1 - cfg.powerbarsize)*cfg.width)
      else
        power:SetPoint"LEFT"
        power:SetHeight(cfg.height*cfg.powerbarsize)
        self.Health:SetHeight((1 - cfg.powerbarsize)*cfg.height)
      end
    else
      if(cfg.orientation == "VERTICAL")then
        power:SetPoint"TOP"
        power:SetWidth(0.0000001) 
        self.Health:SetWidth(cfg.width)
      else
        power:SetPoint"LEFT"
        power:SetHeight(0.0000001) 
        self.Health:SetHeight(cfg.height)
      end
    end
    local r, g, b, t
    t = colors.power[ptype]
    r, g, b = 1, 1, 1
    if(t) then
      r, g, b = t[1], t[2], t[3]
    end
    if(b) then
      local bg = power.bg
      bg:SetVertexColor(r, g, b)
      power:SetStatusBarColor(0, 0, 0, .8)
    end
    local perc = oUF.Tags['perpp'](unit)
    if (perc < 10 and UnitIsConnected(unit) and ptype == 'MANA' and not UnitIsDeadOrGhost(unit)) then
      self.Threat:SetBackdropBorderColor(0, 0, 1, 1)
    else
      -- pass the coloring back to the threat func
      return updateThreat(self, nil, unit)
    end
  end
  -----------------------------
  -- FUNCTIONS
  -----------------------------
  lib_raid.gen_hpbar = function(f)
    --statusbar
    f.colors = colors
    local s = CreateFrame("StatusBar", nil, f)
    s:SetStatusBarTexture(cfg.statusbar_texture)
    fixStatusbar(s)
    s:SetHeight(f.height)
    s:SetWidth(f.width)
    s:SetOrientation(cfg.orientation) 
    s:SetPoint"TOP"
    s:SetPoint"LEFT"
    if cfg.orientation == "VERTICAL" then
      s:SetPoint"BOTTOM"
    else
      s:SetPoint"RIGHT"
    end
    local b = s:CreateTexture(nil, "BACKGROUND")
    b:SetTexture(cfg.statusbar_texture)
    b:SetAllPoints(s)
    f.Health = s
    f.Health.bg = b
    s.PostUpdate = PostUpdateHealth
  end
  
  lib_raid.gen_hpstrings = function(f, unit)
    local h = CreateFrame("Frame", nil, f)
    h:SetAllPoints(f.Health)
    h:SetFrameLevel(10)
    local name = lib.gen_fontstring(h, cfg.font, cfg.fontsize)
    local hpval = lib.gen_fontstring(h, cfg.font, cfg.fontsize-1)
    name:SetPoint("CENTER", f.Health, "CENTER",0,5)
    name:SetShadowOffset(1.25, -1.25)
    name:SetJustifyH("LEFT")
	name.overrideUnit = true
    hpval:SetPoint("CENTER", f.Health, "BOTTOM",0,8)
    hpval:SetShadowOffset(1.25, -1.25)
    f:Tag(name, '[mono:gridcolor][mono:gridname]')
    if f.mystyle == "mtframe" then
      f:Tag(hpval, '[mono:hpperc]')
    else
      f:Tag(hpval, '[mono:hpraid]')
    end
  end
  
  lib_raid.gen_ppbar = function(f)
    if cfg.powerbar then
      local pp = CreateFrame"StatusBar"
      pp:SetStatusBarTexture(cfg.statusbar_texture)
      fixStatusbar(pp)
      pp:SetOrientation(cfg.orientation)
      pp.frequentUpdates = true
      pp:SetParent(f)
      pp:SetPoint"BOTTOM"
      pp:SetPoint"RIGHT"
      local ppbg = pp:CreateTexture(nil, "BORDER")
      ppbg:SetAllPoints(pp)
      ppbg:SetTexture(cfg.statusbar_texture)
      pp.bg = ppbg
      pp.PostUpdate = PostUpdatePower
      f.Power = pp
    end
  end
  
  lib_raid.gen_elements = function(f)
    -- Target tex
    local tB = CreateFrame("Frame", nil, f)
    tB:SetPoint("TOPLEFT", f, "TOPLEFT")
    tB:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
    tB:SetBackdrop(border)
    tB:SetFrameLevel(0)
    tB:Hide()
    f.TargetBorder = tB
    
    -- Focus tex
    local fB = CreateFrame("Frame", nil, f)
    fB:SetPoint("TOPLEFT", f, "TOPLEFT")
    fB:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
    fB:SetBackdrop(border)
    fB:SetFrameLevel(0)
    fB:Hide()
    f.FocusHighlight = fB
    
    -- Debuffs
    local debuffs = CreateFrame("Frame", nil, f)
    debuffs:SetWidth(cfg.debuffsize) debuffs:SetHeight(cfg.debuffsize)
    debuffs:SetPoint("BOTTOMLEFT", 0, 1)
    debuffs.size = cfg.debuffsize
    
    debuffs.CustomFilter = CustomFilter
    f.raidDebuffs = debuffs
    
    -- Threat
    local t = CreateFrame("Frame", nil, f)
    t:SetPoint("TOPLEFT", f, "TOPLEFT", -4, 4)
    t:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 4, -4)
    t:SetFrameStrata("LOW")
    t:SetBackdrop(glowBorder)
    t:SetBackdropColor(0, 0, 0, 0)
    t:SetBackdropBorderColor(0, 0, 0, 1)
    t.Override = updateThreat
    f.Threat = t
	
    -- Leader/Assistant/ML Icons
    if cfg.LeaderIcons then
      li = f.Health:CreateTexture(nil, "OVERLAY")
      li:SetPoint("TOPLEFT", f, 0, 6)
      li:SetHeight(cfg.iconsize)
      li:SetWidth(cfg.iconsize)
      li:SetAlpha(0.75)
      f.Leader = li
      
      ai = f.Health:CreateTexture(nil, "OVERLAY")
      ai:SetPoint("TOPLEFT", f, 0, 6)
      ai:SetHeight(cfg.iconsize)
      ai:SetWidth(cfg.iconsize)
      ai:SetAlpha(0.75)
      f.Assistant = ai
      
      local ml = f.Health:CreateTexture(nil, 'OVERLAY')
      ml:SetHeight(cfg.iconsize)
      ml:SetWidth(cfg.iconsize)
      ml:SetPoint('LEFT', f.Leader, 'RIGHT')
      f.MasterLooter = ml
    end
    
    -- Raid Icon
    if cfg.RaidMark then
      ri = f.Health:CreateTexture(nil, "OVERLAY")
      ri:SetPoint("TOP", f, 0, 5)
      ri:SetHeight(cfg.iconsize)
      ri:SetWidth(cfg.iconsize)
      f.RaidIcon = ri
    end
    
    -- ReadyCheck
    if cfg.RCheckIcon then
	  rci = f.Health:CreateTexture(nil, "OVERLAY")
      rci:SetPoint("BOTTOM", f, 0, 3)
      rci:SetSize(cfg.iconsize+2,cfg.iconsize+2)
	  rci.finishedTimer = 8
	  rci.fadeTimer = 1.5
      --rci.delayTime = 8
      --rci.fadeTime = 1
	  f.ReadyCheck = rci
    end

    -- LFD Icon
    if cfg.lfdIcons then
		local lfdi = lib.gen_fontstring(f.Health, cfg.font, 9)
		lfdi:SetPoint("LEFT", f.Health, "LEFT",0,3)
		lfdi:SetShadowOffset(1.25, -1.25)
		f:Tag(lfdi, '[mono:LFD]')
    end
    
    -- Enable Indicators
    if cfg.indicators then
      f.Indicators = true
    end
	
	-- Healing prediction
	if cfg.healbar then
	  local ohpb = CreateFrame('StatusBar', nil, f.Health)
	  ohpb:SetPoint('TOPLEFT', f.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
	  ohpb:SetPoint('BOTTOMLEFT', f.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
	  ohpb:SetWidth(cfg.width)
	  ohpb:SetStatusBarTexture(cfg.statusbar_texture)
	  ohpb:SetStatusBarColor(1, 0.5, 0, cfg.healalpha)
	  f.ohpb = ohpb
        
	  local mhpb = CreateFrame('StatusBar', nil, f.Health)
	  mhpb:SetPoint('TOPLEFT', ohpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
	  mhpb:SetPoint('BOTTOMLEFT', ohpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
	  mhpb:SetWidth(cfg.width)
	  mhpb:SetStatusBarTexture(cfg.statusbar_texture)
	  mhpb:SetStatusBarColor(0, 1, 0.5, cfg.healalpha)
	  f.mhpb = mhpb

	  f.HealPrediction = { myBar = mhpb, otherBar = ohpb, maxOverflow = cfg.healoverflow }
	end
	
	local h = CreateFrame"Frame" h:SetParent(f.Health) h:SetAllPoints(f.Health) h:SetFrameLevel(20)
	if cfg.healtext then
	  local ht = lib.gen_fontstring(h, cfg.font, cfg.fontsize-2)
	  ht:SetPoint("CENTER", f.Health, "RIGHT",0,1)
	  ht:SetShadowOffset(1.25, -1.25)
	  ht:SetJustifyH("LEFT")
	  f:Tag(ht, '[mono:heal]')
	end
  end
  
  lib_raid.upd_elements = function(f)
    f:RegisterEvent('PLAYER_FOCUS_CHANGED', FocusTarget)
    f:RegisterEvent('RAID_ROSTER_UPDATE', FocusTarget)
    f:RegisterEvent('PLAYER_TARGET_CHANGED', ChangedTarget)
    f:RegisterEvent('RAID_ROSTER_UPDATE', ChangedTarget)
    --f:RegisterEvent('PLAYER_ENTERING_WORLD', getzone)
  end
  
  --hand the lib to the namespace for further usage
  ns.lib_raid = lib_raid