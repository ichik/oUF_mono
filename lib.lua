  local addon, ns = ...
  local cfg = ns.cfg
  local cast = ns.cast
  local lib = CreateFrame("Frame")  

  -----------------------------
  -- local variables
  -----------------------------
  oUF.colors.power['MANA'] = {.3,.45,.65}
  oUF.colors.power['RAGE'] = {.7,.3,.3}
  oUF.colors.power['FOCUS'] = {.7,.45,.25}
  oUF.colors.power['ENERGY'] = {.65,.65,.35}
  oUF.colors.power['RUNIC_POWER'] = {.45,.45,.75}
  local class = select(2, UnitClass("player"))

  -- my config 
  if GetUnitName("player") == "Strigoy" then
	cfg.playerauras = "DEBUFFS"
  end

  -----------------------------
  -- FUNCTIONS
  -----------------------------

  --fontstring func
  lib.gen_fontstring = function(f, name, size, outline)
    local fs = f:CreateFontString(nil, "OVERLAY")
    fs:SetFont(name, size, outline)
    fs:SetShadowColor(0,0,0,1)
--    fs:SetTextColor(1,1,1)
    return fs
  end  
  
  --status bar filling fix
  local fixStatusbar = function(b)
    b:GetStatusBarTexture():SetHorizTile(false)
    b:GetStatusBarTexture():SetVertTile(false)
  end

  --backdrop table
  local mult = 768/string.match(GetCVar("gxResolution"), "%d+x(%d+)")/GetCVar("uiScale")
  local function scale(x) return mult*math.floor(x+.5) end
  local backdrop_tab = { 
    bgFile = cfg.backdrop_texture, 
    edgeFile = cfg.backdrop_edge_texture,
    tile = false, tileSize = 0, edgeSize = scale(1), 
	insets = { left = -scale(1), right = -scale(1), top = -scale(1), bottom = -scale(1)}}
	
  --backdrop func
  lib.gen_backdrop = function(f)
    f:SetBackdrop(backdrop_tab);
    f:SetBackdropColor(.1,.1,.1,1)
    f:SetBackdropBorderColor(.3,.3,.3,1)
  end
  
  --right click menu
  lib.menu = function(self)
    local unit = self.unit:sub(1, -2)
    local cunit = self.unit:gsub("(.)", string.upper, 1)
--[[    if(cunit == 'Vehicle') then
      cunit = 'Player'
    end]]
    if(unit == "party" or unit == "partypet") then
      ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor", 0, 0)
    elseif(_G[cunit.."FrameDropDown"]) then
      ToggleDropDownMenu(1, nil, _G[cunit.."FrameDropDown"], "cursor", 0, 0)
    end
  end
  
  --init func
  lib.init = function(f)
    f.menu = lib.menu
    f:RegisterForClicks("AnyUp")
	f:SetAttribute("*type1", "target")
    f:SetAttribute("*type2", "menu")
    f:SetScript("OnEnter", UnitFrame_OnEnter)
    f:SetScript("OnLeave", UnitFrame_OnLeave)
  end
  
  lib.PostUpdateHealth = function(s, u, min, max)
	if UnitIsDeadOrGhost(u) then s:SetValue(0) end
  end
  local ReverseBar
  do
  -- reposition the status bar texture to fill from the right to left, thx Saiket
	local UpdaterOnUpdate = function(Updater)
		Updater:Hide()
		local b = Updater:GetParent()
		local tex = b:GetStatusBarTexture()
		tex:ClearAllPoints()
		tex:SetPoint("BOTTOMRIGHT")
		tex:SetPoint("TOPLEFT", b, "TOPRIGHT", (b:GetValue()/select(2,b:GetMinMaxValues())-1)*b:GetWidth(), 0)
	end
	local OnChanged = function(bar)
		bar.Updater:Show()
	end
	function ReverseBar(f)
		local bar = CreateFrame("StatusBar", nil, f) --separate frame for OnUpdates
		bar.Updater = CreateFrame("Frame", nil, bar)
		bar.Updater:Hide()
		bar.Updater:SetScript("OnUpdate", UpdaterOnUpdate)
		bar:SetScript("OnSizeChanged", OnChanged)
		bar:SetScript("OnValueChanged", OnChanged)
		bar:SetScript("OnMinMaxChanged", OnChanged)
		return bar;
	end
  end

------ [Building frames]
  --gen healthbar func
  lib.gen_hpbar = function(f)
    --statusbar
	local s
	if cfg.ReverseHPbars then 
		s = ReverseBar(f) 
		s.PostUpdate = lib.PostUpdateHealth  
		s:SetAlpha(0.9)
	else 
		s = CreateFrame("StatusBar", nil, f) 
		s:SetAlpha(0.7)
	end
    --local s = ReverseBar(f)--CreateFrame("StatusBar", nil, f)--
    s:SetStatusBarTexture(cfg.statusbar_texture)
    fixStatusbar(s)
    s:SetHeight(f.height)
    s:SetWidth(f.width)
    s:SetPoint("TOPLEFT",0,0)
    --s:SetAlpha(0.9)
    s:SetOrientation("HORIZONTAL") 
	s:SetFrameLevel(5)
    --shadow backdrop
    local h = CreateFrame("Frame", nil, s)
    h:SetFrameLevel(0)
    h:SetPoint("TOPLEFT",0,0)
    h:SetPoint("BOTTOMRIGHT",0,0)
    lib.gen_backdrop(h)
    --bar bg
	local bg = CreateFrame("Frame", nil, s)
	bg:SetFrameLevel(s:GetFrameLevel()-2)
    bg:SetAllPoints(s)
    local b = bg:CreateTexture(nil, "BACKGROUND")
    b:SetTexture(cfg.statusbar_texture)
    b:SetAllPoints(s)
	
    f.Health = s
    f.Health.bg = b
  end
  --3d portrait behind hp bar
  lib.gen_portrait = function(f)
    s = f.Health
	local p = CreateFrame("PlayerModel", nil, f)
	p:SetFrameLevel(s:GetFrameLevel()-1)
    p:SetWidth(f.width-2)
    p:SetHeight(f.height-2)
    p:SetPoint("TOP", s, "TOP", 0, -2)
	p:SetAlpha(.25)
    f.Portrait = p
  end
  --gen hp strings func
  lib.gen_hpstrings = function(f, unit)
    --creating helper frame here so our font strings don't inherit healthbar parameters
    local h = CreateFrame("Frame", nil, f)
    h:SetAllPoints(f.Health)
    h:SetFrameLevel(15)
    local valsize
    if f.mystyle == "arenatarget" or f.mystyle == "partypet" then valsize = 11 else valsize = 13 end 
    local name = lib.gen_fontstring(h, cfg.font, 13, "THINOUTLINE")
    local hpval = lib.gen_fontstring(h, cfg.font, valsize, "THINOUTLINE")
    if f.mystyle == "target" or f.mystyle == "tot" then
      name:SetPoint("RIGHT", f.Health, "RIGHT",-3,0)
      hpval:SetPoint("LEFT", f.Health, "LEFT",3,0)
      name:SetJustifyH("RIGHT")
      name:SetPoint("LEFT", hpval, "RIGHT", 5, 0)
    elseif f.mystyle == "arenatarget" or f.mystyle == "partypet" then
      name:SetPoint("CENTER", f.Health, "CENTER",0,6)
      name:SetJustifyH("LEFT")
      hpval:SetPoint("CENTER", f.Health, "CENTER",0,-6)
    else
      name:SetPoint("LEFT", f.Health, "LEFT",3,0)
      hpval:SetPoint("RIGHT", f.Health, "RIGHT",-3,0)
      name:SetJustifyH("LEFT")
      name:SetPoint("RIGHT", hpval, "LEFT", -5, 0)
    end
    if f.mystyle == "arenatarget" or f.mystyle == "partypet" then
      f:Tag(name, '[mono:color][mono:shortname]')
      f:Tag(hpval, '[mono:hpraid]')
    else
      f:Tag(name, '[mono:color][mono:longname]')
      f:Tag(hpval, '[mono:hp]')
    end
  end
  
  --gen powerbar func
  lib.gen_ppbar = function(f)
    --statusbar
    local s = CreateFrame("StatusBar", nil, f)
    s:SetStatusBarTexture(cfg.statusbar_texture)
    fixStatusbar(s)
    s:SetHeight(f.height/3)
    s:SetWidth(f.width)
    s:SetPoint("TOP",f,"BOTTOM",0,-2)
    if f.mystyle == "partypet" or f.mystyle == "arenatarget" then
      s:Hide()
    end
    --helper
    local h = CreateFrame("Frame", nil, s)
    h:SetFrameLevel(0)
    h:SetPoint("TOPLEFT",0,0)
    h:SetPoint("BOTTOMRIGHT",0,0)
    lib.gen_backdrop(h)
    --bg
    local b = s:CreateTexture(nil, "BACKGROUND")
    b:SetTexture(cfg.statusbar_texture)
    b:SetAllPoints(s)
    if f.mystyle=="tot" or f.mystyle=="pet" then
      s:SetHeight(f.height/3)
    end
    f.Power = s
    f.Power.bg = b
  end
  --filling up powerbar with text strings
  lib.gen_ppstrings = function(f, unit)
    --helper frame
    local h = CreateFrame("Frame", nil, f)
    h:SetAllPoints(f.Power)
    h:SetFrameLevel(10)
    local fh
    if f.mystyle == "arena" then fh = 9 else fh = 11 end
    local pp = lib.gen_fontstring(h, cfg.font, fh, "THINOUTLINE")
    local info = lib.gen_fontstring(h, cfg.font, fh, "THINOUTLINE")
    if f.mystyle == "target" or f.mystyle == "tot" then
        info:SetPoint("RIGHT", f.Power, "RIGHT",-3,0)
        pp:SetPoint("LEFT", f.Power, "LEFT",3,0)
        info:SetJustifyH("RIGHT")
    else
        info:SetPoint("LEFT", f.Power, "LEFT",3,0)
        pp:SetPoint("RIGHT", f.Power, "RIGHT",-5,0)
        info:SetJustifyH("LEFT")
    end
	--resting indicator for player frame
	if f.mystyle == "player" then
		local ri = lib.gen_fontstring(f.Power, cfg.font, 11, "THINOUTLINE")
		ri:SetPoint("LEFT", info, "RIGHT",2,0)
		ri:SetText("|cff8AFF30Zzz|r")
		f.Resting = ri
	end
	pp.frequentUpdates = 0.2 -- test it!!1
    if class == "DRUID" then
      f:Tag(pp, '[mono:druidpower] [mono:pp]')
    else
      f:Tag(pp, '[mono:pp]')
    end
    f:Tag(info, '[mono:info]')
  end

------ [Castbar, +mirror castbar]
  --gen castbar
  lib.gen_castbar = function(f)
    local s = CreateFrame("StatusBar", "oUF_monoCastbar"..f.mystyle, f)
    s:SetSize(f.width-(f.height/1.5+4),f.height/1.5)
    s:SetStatusBarTexture(cfg.statusbar_texture)
    s:SetStatusBarColor(cfg.cbcolor[1], cfg.cbcolor[2], cfg.cbcolor[3],1)
    s:SetFrameLevel(9)
    --color
    s.CastingColor = {cfg.cbcolor[1], cfg.cbcolor[2], cfg.cbcolor[3]}
    s.CompleteColor = {0.12, 0.86, 0.15}
    s.FailColor = {1.0, 0.09, 0}
    s.ChannelingColor = {cfg.cbcolor[1], cfg.cbcolor[2], cfg.cbcolor[3]}
    --helper
    local h = CreateFrame("Frame", nil, s)
    h:SetFrameLevel(0)
    h:SetPoint("TOPLEFT",0,0)
    h:SetPoint("BOTTOMRIGHT",0,0)
    lib.gen_backdrop(h)
    --backdrop
    local b = s:CreateTexture(nil, "BACKGROUND")
    b:SetTexture(cfg.statusbar_texture)
    b:SetAllPoints(s)
    b:SetVertexColor(cfg.cbcolor[1]*0.2,cfg.cbcolor[2]*0.2,cfg.cbcolor[3]*0.2,0.7)
    --spark
    sp = s:CreateTexture(nil, "OVERLAY")
    sp:SetBlendMode("ADD")
    sp:SetAlpha(0.5)
    sp:SetHeight(s:GetHeight()*2.5)
    --spell text
    local txt = lib.gen_fontstring(s, cfg.font, 11, "THINOUTLINE")
    txt:SetPoint("LEFT", 2, 0)
    txt:SetJustifyH("LEFT")
    --time
    local t = lib.gen_fontstring(s, cfg.font, 12, "THINOUTLINE")
    t:SetPoint("RIGHT", -2, 0)
    txt:SetPoint("RIGHT", t, "LEFT", -5, 0)
    --icon
    local i = s:CreateTexture(nil, "ARTWORK")
    i:SetSize(s:GetHeight()-2,s:GetHeight()-2)
    i:SetPoint("RIGHT", s, "LEFT", -4.5, 0)
    i:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    --helper2 for icon
    local h2 = CreateFrame("Frame", nil, s)
    h2:SetFrameLevel(0)
    h2:SetPoint("TOPLEFT",i,"TOPLEFT",-scale(2),scale(2))
    h2:SetPoint("BOTTOMRIGHT",i,"BOTTOMRIGHT",scale(2),-scale(2))
    lib.gen_backdrop(h2)
    if f.mystyle == "focus" and cfg.focusCBuserplaced then
      s:SetPoint(unpack(cfg.focusCBposition))
      s:SetSize(cfg.focusCBwidth,cfg.focusCBheight)
      i:SetSize(s:GetHeight()-2,s:GetHeight()-2)
      sp:SetHeight(s:GetHeight()*2.5)
    elseif f.mystyle == "pet" then
      s:SetPoint("BOTTOMRIGHT",f.Power,"BOTTOMRIGHT",0,0)
      s:SetScale(f:GetScale())
      s:SetSize(f.width-f.height/2,f.height/2.5)
      i:SetPoint("RIGHT", s, "LEFT", -2, 0)
      h2:SetFrameLevel(9)
      b:Hide() txt:Hide() t:Hide() h:Hide()

    elseif f.mystyle == "arena" then
      s:SetSize(f.width-(f.height/1.4+4),f.height/1.4)
      s:SetPoint("TOPRIGHT",f.Power,"BOTTOMRIGHT",0,-4)
      i:SetPoint("RIGHT", s, "LEFT", -4, 0)
      i:SetSize(s:GetHeight()-2,s:GetHeight()-2)
    elseif f.mystyle == "player" then
	  if cfg.playerCBuserplaced then
		s:SetSize(cfg.playerCBwidth,cfg.playerCBheight)
		s:SetPoint(unpack(cfg.playerCBposition))
		i:SetSize(s:GetHeight()-2,s:GetHeight()-2)
		sp:SetHeight(s:GetHeight()*2.5)
	  else
		s:SetPoint("TOPRIGHT",f.Power,"BOTTOMRIGHT",0,-4)
	  end
      --latency only for player unit
	  local z = s:CreateTexture(nil, "OVERLAY")
	  z:SetBlendMode("ADD")
      z:SetTexture(cfg.statusbar_texture)
      z:SetVertexColor(.8,.31,.45)
      z:SetPoint("TOPRIGHT")
      z:SetPoint("BOTTOMRIGHT")
	  --if UnitInVehicle("player") then z:Hide() end
      s.SafeZone = z
      --custom latency display
      local l = lib.gen_fontstring(s, cfg.font, 10, "THINOUTLINE")
      l:SetPoint("CENTER", -2, 16)
      l:SetJustifyH("RIGHT")
      s.Lag = l
      f:RegisterEvent("UNIT_SPELLCAST_SENT", cast.OnCastSent)
	elseif f.mystyle == "target" and cfg.targetCBuserplaced then
	  s:SetSize(cfg.targetCBwidth,cfg.targetCBheight)
	  s:SetPoint(unpack(cfg.targetCBposition))
	  i:SetSize(s:GetHeight()-2,s:GetHeight()-2)
      sp:SetHeight(s:GetHeight()*2.5)
	else
      s:SetPoint("TOPRIGHT",f.Power,"BOTTOMRIGHT",0,-4)
    end

	s.OnUpdate = cast.OnCastbarUpdate
	s.PostCastStart = cast.PostCastStart
	s.PostChannelStart = cast.PostCastStart
	s.PostCastStop = cast.PostCastStop
	s.PostChannelStop = cast.PostChannelStop
	s.PostCastFailed = cast.PostCastFailed
	s.PostCastInterrupted = cast.PostCastFailed
	
    f.Castbar = s
    f.Castbar.Text = txt
    f.Castbar.Time = t
    f.Castbar.Icon = i
    f.Castbar.Spark = sp
  end
  --gen Mirror Cast Bar
  --/run local t = _G["MirrorTimer1StatusBar"]:GetValue() print(t)
  lib.gen_mirrorcb = function(f)
    for _, bar in pairs({'MirrorTimer1','MirrorTimer2','MirrorTimer3',}) do   
      for i, region in pairs({_G[bar]:GetRegions()}) do
        if (region.GetTexture and region:GetTexture() == 'SolidTexture') then
          region:Hide()
        end
      end
      _G[bar..'Border']:Hide()
      _G[bar]:SetParent(UIParent)
      _G[bar]:SetScale(1)
      _G[bar]:SetHeight(16)
      _G[bar]:SetBackdropColor(.1,.1,.1)
      _G[bar..'Background'] = _G[bar]:CreateTexture(bar..'Background', 'BACKGROUND', _G[bar])
      _G[bar..'Background']:SetTexture(cfg.statusbar_texture)
      _G[bar..'Background']:SetAllPoints(bar)
      _G[bar..'Background']:SetVertexColor(.15,.15,.15,1)
      _G[bar..'Text']:SetFont(cfg.font, 14)
      _G[bar..'Text']:ClearAllPoints()
      _G[bar..'Text']:SetPoint('CENTER', _G[bar..'StatusBar'], 0, 0)
	  _G[bar..'StatusBar']:SetAllPoints(_G[bar])
      --glowing borders
      local h = CreateFrame("Frame", nil, _G[bar])
      h:SetFrameLevel(0)
      h:SetPoint("TOPLEFT",0,0)
      h:SetPoint("BOTTOMRIGHT",0,0)
      lib.gen_backdrop(h)
    end
  end
  
------ [Auras, all of them!]
-- Creating our own timers with blackjack and hookers!
  lib.FormatTime = function(s)
    local day, hour, minute = 86400, 3600, 60
    if s >= day then
      return format("%dd", floor(s/day + 0.5)), s % day
    elseif s >= hour then
      return format("%dh", floor(s/hour + 0.5)), s % hour
    elseif s >= minute then
      if s <= minute * 5 then
        return format('%d:%02d', floor(s/60), s % minute), s - floor(s)
      end
      return format("%dm", floor(s/minute + 0.5)), s % minute
    elseif s >= minute / 12 then
      return floor(s + 0.5), (s * 100 - floor(s * 100))/100
    end
    return format("%.1f", s), (s * 100 - floor(s * 100))/100
  end
  lib.CreateAuraTimer = function(self,elapsed)
    if self.timeLeft then
      self.elapsed = (self.elapsed or 0) + elapsed
      local w = self:GetWidth()
      if self.elapsed >= 0.1 then
        if not self.first then
          self.timeLeft = self.timeLeft - self.elapsed
        else
          self.timeLeft = self.timeLeft - GetTime()
          self.first = false
        end
        if self.timeLeft > 0 and w > cfg.ATIconSizeThreshold then
          local time = lib.FormatTime(self.timeLeft)
          self.remaining:SetText(time)
          if self.timeLeft < 5 then
            self.remaining:SetTextColor(1, .3, .2)
          else
            self.remaining:SetTextColor(.9, .7, .2)
          end
        else
          self.remaining:Hide()
          self:SetScript("OnUpdate", nil)
        end
        self.elapsed = 0
      end
    end
  end
  lib.PostUpdateIcon = function(self, unit, icon, index, offset)
  local _, _, _, _, _, duration, expirationTime, unitCaster, _ = UnitAura(unit, index, icon.filter)
    -- Debuff desaturation
    if unitCaster ~= 'player' and unitCaster ~= 'vehicle' and not UnitIsFriend('player', unit) and icon.debuff then
      icon.icon:SetDesaturated(true)
    else
      icon.icon:SetDesaturated(false)
    end
    -- Creating aura timers
    if duration and duration > 0 and cfg.auratimers then
      if cfg.PlayerTimersOnly and unitCaster ~= 'player' then 
		if unit=='player' and icon.debuff then icon.remaining:Show() else icon.remaining:Hide() end
	  else 
		icon.remaining:Show() 
	  end
    else
      icon.remaining:Hide()
    end
    --if unit == 'player' or unit == 'target' then
      icon.duration = duration
      icon.timeLeft = expirationTime
      icon.first = true
      icon:SetScript("OnUpdate", lib.CreateAuraTimer)
    --end
  end
  -- creating aura icons
  lib.PostCreateIcon = function(self, button)
    button.cd:SetReverse()
    button.cd.noOCC = true
    button.cd.noCooldownCount = true
    button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    button.icon:SetDrawLayer("BACKGROUND")
    --count
    button.count:ClearAllPoints()
    button.count:SetJustifyH("RIGHT")
    button.count:SetPoint("TOPRIGHT", 2, 2)
    button.count:SetTextColor(1,1,1)
    --helper
    local h = CreateFrame("Frame", nil, button)
    h:SetFrameLevel(0)
    h:SetPoint("TOPLEFT",-scale(2),scale(2))
    h:SetPoint("BOTTOMRIGHT",scale(2),-scale(2))
    lib.gen_backdrop(h)
    --another helper frame for our fontstring to overlap the cd frame
    local h2 = CreateFrame("Frame", nil, button)
    h2:SetAllPoints(button)
    h2:SetFrameLevel(10)
    button.remaining = lib.gen_fontstring(h2, cfg.font, cfg.ATSize, "THINOUTLINE")
	--button.remaining:SetShadowColor(0, 0, 0)--button.remaining:SetShadowOffset(2, -1)
    button.remaining:SetPoint("BOTTOM", 0, -1)
    --overlay texture for debuff types display
    button.overlay:SetTexture(cfg.auratex)
    button.overlay:SetPoint("TOPLEFT", button, "TOPLEFT", -scale(2), scale(2))
    button.overlay:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", scale(2), -scale(2))
    button.overlay:SetTexCoord(0.04, 0.96, 0.04, 0.96)
    button.overlay.Hide = function(self) self:SetVertexColor(0, 0, 0, 0) end
  end
  -- position update for certain class/specs
  lib.PreSetPosition = function(self, num)
	local f = self:GetParent()
	local pttree = GetPrimaryTalentTree(false, false, GetActiveTalentGroup())
	if f.mystyle=="player" and ((class=="DRUID" and pttree == 1) or class == "DEATHKNIGHT" or (class == "SHAMAN" and IsAddOnLoaded("oUF_boring_totembar"))) then
		self:SetPoint('BOTTOMLEFT', f, 'TOPLEFT', 1, 6+f.height/3)
	else
		self:SetPoint('BOTTOMLEFT', f, 'TOPLEFT', 1.5, 4)
	end
  end
  --auras for certain frames
  lib.createAuras = function(f)
    a = CreateFrame('Frame', nil, f)
    a:SetPoint('BOTTOMLEFT', f, 'TOPLEFT', scale(2), scale(6))
    a['growth-x'] = 'RIGHT'
    a['growth-y'] = 'UP' 
    a.initialAnchor = 'BOTTOMLEFT'
    a.gap = true
    a.spacing = scale(8)
    a.size = scale(22)
    a.showDebuffType = true
    if f.mystyle=="target" or (f.mystyle=="player" and cfg.playerauras=="AURAS") then
      if not f.mystyle=="target" then 
		a.PreSetPosition = lib.PreSetPosition
      end
      a:SetHeight((a.size+a.spacing)*2)
      a:SetWidth((a.size+a.spacing)*8)
      a.numBuffs = 16
      a.numDebuffs = 16
    elseif f.mystyle=="focus" then
      a:SetHeight((a.size+a.spacing)*2)
      a:SetWidth((a.size+a.spacing)*4)
      a.numBuffs = 8
      a.numDebuffs = 8
    end
    f.Auras = a
    a.PostCreateIcon = lib.PostCreateIcon
    a.PostUpdateIcon = lib.PostUpdateIcon
  end
  -- buffs
  lib.createBuffs = function(f)
    b = CreateFrame("Frame", nil, f)
    b.initialAnchor = "TOPLEFT"
    b["growth-y"] = "DOWN"
    b.num = 5
    b.size = scale(20)
    b.spacing = scale(8)
    b:SetHeight((b.size+b.spacing)*2)
    b:SetWidth((b.size+b.spacing)*12)
    if f.mystyle=="tot" then
      b.initialAnchor = "TOPRIGHT"
      b:SetPoint("TOPRIGHT", f, "TOPLEFT", -b.spacing, -scale(2))
      b["growth-x"] = "LEFT"
    elseif f.mystyle=="pet" then
      b:SetPoint("TOPLEFT", f, "TOPRIGHT", b.spacing, -scale(2))
    elseif f.mystyle=="arena" then
      b.showBuffType = true
      b:SetPoint("TOPLEFT", f, "TOPRIGHT", b.spacing, -scale(2))
	  b.size = 18
      b.num = 4
      b:SetWidth((b.size+b.spacing)*4)
    elseif f.mystyle=='party' then
      b:SetPoint("TOPLEFT", f.Power, "BOTTOMLEFT", scale(2), -b.spacing)
	  b.spacing = scale(8)
      b.num = 8
	elseif f.mystyle=="player" and cfg.playerauras=="BUFFS" then
	  b['growth-x'] = 'RIGHT'
      b['growth-y'] = 'UP' 
      b.initialAnchor = 'BOTTOMLEFT'
	  b.num = 15
	  b.size = 23
      b:SetHeight((b.size+b.spacing)*2)
      b:SetWidth((b.size+b.spacing)*9)
	  b.PreSetPosition = lib.PreSetPosition
    end
    b.PostCreateIcon = lib.PostCreateIcon
    b.PostUpdateIcon = lib.PostUpdateIcon
    f.Buffs = b
  end
  --debuffs
  lib.createDebuffs = function(f)
    d = CreateFrame("Frame", nil, f)
    d.initialAnchor = "TOPRIGHT"
    d["growth-y"] = "DOWN"
    d.num = 4
    d.size = scale(2)
    d.spacing = scale(8)
    d:SetHeight((d.size+d.spacing)*2)
    d:SetWidth((d.size+d.spacing)*5)
    d.showDebuffType = true
    if f.mystyle=="tot" then
      d:SetPoint("TOPLEFT", f, "TOPRIGHT", d.spacing, -scale(2))
      d.initialAnchor = "TOPLEFT"
    elseif f.mystyle=="pet" then
      d:SetPoint("TOPRIGHT", f, "TOPLEFT", -d.spacing, -scale(2))
      d["growth-x"] = "LEFT"
    elseif f.mystyle=="arena" then
      d.showDebuffType = false
      d.initialAnchor = "TOPLEFT"
      d.num = 4
	  d.size = 18
	  d:SetPoint("TOPLEFT", f, "TOPRIGHT", d.spacing, -d.size-d.spacing*2)
      d:SetWidth((d.size+d.spacing)*4)
    elseif f.mystyle=='party' then
      d:SetPoint("TOPRIGHT", f, "TOPLEFT", -d.spacing, -2)
	  d.num = 8
	  d.size = 18
      d["growth-x"] = "LEFT"
      d:SetWidth((d.size+d.spacing)*4)
	elseif f.mystyle=="player" and cfg.playerauras=="DEBUFFS" then
	  d['growth-x'] = 'RIGHT'
      d['growth-y'] = 'UP' 
      d.initialAnchor = 'BOTTOMLEFT'
	  d.num = 15
	  d.size = 23
      d:SetHeight((d.size+d.spacing)*2)
      d:SetWidth((d.size+d.spacing)*9)
	  d.PreSetPosition = lib.PreSetPosition
    end
    d.PostCreateIcon = lib.PostCreateIcon
    d.PostUpdateIcon = lib.PostUpdateIcon
    f.Debuffs = d
  end

------ [Extra functionality]
  --gen DK runes
  lib.gen_Runes = function(f)
    if class ~= "DEATHKNIGHT" then return
    else
      local runeloadcolors = {
      [1] = {0.59, 0.31, 0.31},
      [2] = {0.59, 0.31, 0.31},
      [3] = {0.33, 0.51, 0.33},
      [4] = {0.33, 0.51, 0.33},
      [5] = {0.31, 0.45, 0.53},
      [6] = {0.31, 0.45, 0.53},}
      f.Runes = CreateFrame("Frame", nil, f)
      for i = 1, 6 do
        r = CreateFrame("StatusBar", f:GetName().."_Runes"..i, f)
        r:SetSize(f.width/6 - 2, f.height/3)
        if (i == 1) then
          r:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 1, 3)
        else
          r:SetPoint("TOPLEFT", f.Runes[i-1], "TOPRIGHT", 2, 0)
        end
        r:SetStatusBarTexture(cfg.statusbar_texture)
        r:GetStatusBarTexture():SetHorizTile(false)
        r:SetStatusBarColor(unpack(runeloadcolors[i]))
        r.bd = r:CreateTexture(nil, "BORDER")
        r.bd:SetAllPoints()
        r.bd:SetTexture(cfg.statusbar_texture)
        r.bd:SetVertexColor(0.15, 0.15, 0.15)
        f.b = CreateFrame("Frame", nil, r)
        f.b:SetPoint("TOPLEFT", r, "TOPLEFT", -4, 4)
        f.b:SetPoint("BOTTOMRIGHT", r, "BOTTOMRIGHT", 4, -5)
        f.b:SetBackdrop(backdrop_tab)
        f.b:SetBackdropColor(0, 0, 0, 0)
        f.b:SetBackdropBorderColor(0,0,0,1)
        f.Runes[i] = r
      end
    end
  end
  --gen eclipse bar
  lib.gen_EclipseBar = function(f)
	if class ~= "DRUID" then return end
	local eb = CreateFrame('Frame', nil, f)
	eb:SetPoint('BOTTOMLEFT', f, 'TOPLEFT', -3, -1)
	eb:SetSize(f.width+7, 20)
	lib.gen_backdrop(eb)
	local lb = CreateFrame('StatusBar', nil, eb)
	lb:SetPoint('LEFT', eb, 'LEFT', 4, 0)
	lb:SetSize(f.width-2, 10)
	lb:SetStatusBarTexture(cfg.statusbar_texture)
	lb:SetStatusBarColor(0.27, 0.47, 0.74)
	eb.LunarBar = lb
	local sb = CreateFrame('StatusBar', nil, eb)
	sb:SetPoint('LEFT', lb:GetStatusBarTexture(), 'RIGHT', 0, 0)
	sb:SetSize(f.width-2, 10)
	sb:SetStatusBarTexture(cfg.statusbar_texture)
	sb:SetStatusBarColor(0.9, 0.6, 0.3)
	eb.SolarBar = sb
  	local h = CreateFrame("Frame", nil, eb)
	h:SetAllPoints(eb)
	h:SetFrameLevel(30)
 	--[[local ebText = lib.gen_fontstring(h, cfg.font, 20, "THINOUTLINE")
	ebText:SetPoint('CENTER', eb, 'CENTER', 0, 0)
	eb.Text = ebText]]
	f.EclipseBar = eb
	
	local ebInd = lib.gen_fontstring(h, cfg.font, 16, "THINOUTLINE")
	ebInd:SetPoint('CENTER', eb, 'CENTER', 0, 0)
	f.EclipseBar.PostDirectionChange = function(element, unit)
	if(element.directionIsLunar) then
		ebInd:SetText("|cff4478BC>>>|r")
	else
		ebInd:SetText("|cffE5994C<<<|r")
	end
end
  end
  --gen TotemBar for shamans
  lib.gen_TotemBar = function(f)
    if class ~= "SHAMAN" then return
    elseif IsAddOnLoaded("oUF_boring_TotemBar") then
		local width = (f.width + 4) / 4 - 4
		local height = f.height/3
		local TotemBar = CreateFrame("Frame", nil, f)
		TotemBar:SetSize(width,height)
		TotemBar:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 1, 3)
		TotemBar.Destroy = true
		TotemBar.UpdateColors = true
		TotemBar.AbbreviateNames = true
		for i = 1, 4 do
			local t = CreateFrame("Frame", nil, TotemBar)
			t:SetPoint("LEFT", (i - 1) * (width + 3.5), 0)
			t:SetWidth(width)
			t:SetHeight(height)
			local bar = CreateFrame("StatusBar", nil, t)
			bar:SetWidth(width)
			bar:SetPoint"BOTTOM"
			bar:SetHeight(8)
			t.StatusBar = bar
			local h = CreateFrame("Frame",nil,t)
			h:SetFrameLevel(10)
			local time = lib.gen_fontstring(h, cfg.font, 11, "THINOUTLINE")
			time:SetPoint("BOTTOMRIGHT",t,"TOPRIGHT", 0, -1)
			time:SetFontObject"GameFontNormal"
			t.Time = time
			local text = lib.gen_fontstring(h, cfg.font, 11, "THINOUTLINE")
			text:SetPoint("BOTTOMLEFT", t, "TOPLEFT", 0, -1)
			--text:SetFontObject"GameFontNormal"
			t.Text = text
	        t.bg = CreateFrame("Frame", nil, t)
			t.bg:SetPoint("TOPLEFT", t, "TOPLEFT", -4, 5)
			t.bg:SetPoint("BOTTOMRIGHT", t, "BOTTOMRIGHT", 4, -5)
			t.bg:SetBackdrop(backdrop_tab)
			t.bg:SetBackdropColor(0,0,0,0)
			t.bg:SetBackdropBorderColor(0,0,0,1)
			t.bg = t:CreateTexture(nil, "BACKGROUND")
			t.bg:SetAllPoints()
			t.bg:SetTexture(1, 1, 1)
			t.bg.multiplier = 0.2
			TotemBar[i] = t
		end
		f.TotemBar = TotemBar
    end
  end
  --gen class specific power display
  lib.gen_specificpower = function(f, unit)
    local h = CreateFrame("Frame", nil, f)
    h:SetAllPoints(f.Health)
    h:SetFrameLevel(10)
	if f.mystyle == "party" then
		local es = lib.gen_fontstring(h, cfg.font, 14, "THINOUTLINE")
		es:SetPoint("CENTER", f.Power, "BOTTOMRIGHT",0,0)	
		if class == "SHAMAN" then
			f:Tag(es, '[raid:earth]')
		elseif class == "DRUID" then
			f:Tag(es, '[raid:lb]')
		elseif class == "PRIEST" then
			f:Tag(es, '[raid:pom]')
		end
	end
	if f.mystyle == "player" then
		local sp = lib.gen_fontstring(h, cfg.font, 30, "MONOCHROMEOUTLINE")
		sp:SetPoint("CENTER", f.Health, "CENTER",0,3)
		if class == "DRUID" then
			f:Tag(sp, '[mono:wm1][mono:wm2][mono:wm3]')
		elseif class == "PRIEST" then
			f:Tag(sp, '[mono:sp][mono:orbs]')
		elseif class == "SHAMAN" then
			f:Tag(sp, '[mono:ws][mono:ls]')
		end
	end
  end
  --gen combo points
  lib.gen_cp = function(f)
    local h = CreateFrame("Frame", nil, f)
    h:SetAllPoints(f.Health)
    h:SetFrameLevel(10)
    local cp = lib.gen_fontstring(h, cfg.font, 30, "THINOUTLINE")
    cp:SetPoint("CENTER", f.Health, "CENTER",0,3)
    f:Tag(cp, '[mono:cp]')
  end
  --gen LFD role indicator
  lib.gen_LFDindicator = function(f)
    local lfdi = lib.gen_fontstring(f.Power, cfg.font, 11, "THINOUTLINE")
    lfdi:SetPoint("LEFT", f.Power, "LEFT",1,0)
    f:Tag(lfdi, '[mono:LFD]')
  end
  --gen combat and leader icons
  lib.gen_InfoIcons = function(f)
    local h = CreateFrame("Frame",nil,f)
    h:SetAllPoints(f.Health)
    h:SetFrameLevel(10)
    --combat icon
    if f.mystyle == 'player' then
		f.Combat = h:CreateTexture(nil, 'OVERLAY')
		f.Combat:SetSize(20,20)
		f.Combat:SetPoint('TOPRIGHT', 3, 9)
    end
    --Leader icon
    li = h:CreateTexture(nil, "OVERLAY")
    li:SetPoint("TOPLEFT", f, 0, 6)
    li:SetSize(12,12)
    f.Leader = li
    --Assist icon
    ai = h:CreateTexture(nil, "OVERLAY")
    ai:SetPoint("TOPLEFT", f, 0, 6)
    ai:SetSize(12,12)
    f.Assistant = ai
    --ML icon
    local ml = h:CreateTexture(nil, 'OVERLAY')
    ml:SetSize(12,12)
    ml:SetPoint('LEFT', f.Leader, 'RIGHT')
    f.MasterLooter = ml
  end
  --gen raid mark icons
  lib.gen_RaidMark = function(f)
    local h = CreateFrame("Frame", nil, f)
    h:SetAllPoints(f)
    h:SetFrameLevel(10)
    h:SetAlpha(cfg.RMalpha)
    local ri = h:CreateTexture(nil,'OVERLAY',h)
    ri:SetPoint("CENTER", f, "CENTER", 0, 0)
    ri:SetSize(cfg.RMsize, cfg.RMsize)
    f.RaidIcon = ri
  end
  --gen hilight texture
  lib.gen_highlight = function(f)
    local OnEnter = function(f)
      UnitFrame_OnEnter(f)
      f.Highlight:Show()
    end
    local OnLeave = function(f)
      UnitFrame_OnLeave(f)
      f.Highlight:Hide()
    end
    f:SetScript("OnEnter", OnEnter)
    f:SetScript("OnLeave", OnLeave)
    local hl = f.Health:CreateTexture(nil, "OVERLAY")
    hl:SetAllPoints(f.Health)
    hl:SetTexture(cfg.backdrop_texture)
    hl:SetVertexColor(.5,.5,.5,.1)
    hl:SetBlendMode("ADD")
    hl:Hide()
    f.Highlight = hl
  end
  --gen trinket
  lib.gen_arenatracker = function(f)
    t = CreateFrame("Frame", nil, f)
    t:SetSize(20,20)
    t:SetPoint("TOP", f, "BOTTOM", 1, 4)
    t:SetFrameLevel(30)
    t:SetAlpha(0.8)
    t.trinketUseAnnounce = true
    t.bg = CreateFrame("Frame", nil, t)
	t.bg:SetFrameLevel(5)
    t.bg:SetPoint("TOPLEFT",-scale(2),scale(2))
    t.bg:SetPoint("BOTTOMRIGHT",scale(2),-scale(2))
    t.bg:SetBackdrop(backdrop_tab);
    t.bg:SetBackdropColor(0,0,0,0)
    t.bg:SetBackdropBorderColor(.3,.3,.3,1)
	t.remaining = lib.gen_fontstring(t, cfg.font, cfg.ATSize-2, "THINOUTLINE")
	t.remaining:SetPoint('BOTTOM', t, 0, 0)
    t:SetScript("OnUpdate", lib.CreateAuraTimer)
    f.Trinket = t
  end
  --gen current target indicator
  lib.gen_targeticon = function(f)
    local h = CreateFrame("Frame", nil, f)
    h:SetAllPoints(f.Health)
    h:SetFrameLevel(10)
    local ti = lib.gen_fontstring(h, cfg.font, 12, "THINOUTLINE")
    ti:SetPoint("LEFT", f.Health, "BOTTOMLEFT",-5,0)
    ti:SetJustifyH("LEFT")
    f:Tag(ti, '[mono:targeticon]')
  end
  --gen fake target bars
  lib.gen_faketarget = function(f)
    local fhp = CreateFrame("frame","FakeHealthBar",UIParent) 
    fhp:SetAlpha(.6)
    fhp:SetSize(f.width,f.height)
    fhp:SetPoint("TOPLEFT",oUF_monoTargetFrame,"TOPLEFT",0,0)
    fhp.bg = fhp:CreateTexture(nil, "PARENT")
    fhp.bg:SetTexture(cfg.statusbar_texture)
    fhp.bg:ClearAllPoints()
    fhp.bg:SetAllPoints(fhp)
    fhp.bg:SetVertexColor(.3,.3,.3)
    local h = CreateFrame("Frame",nil,fhp)
    h:SetBackdrop(backdrop_tab)
    h:SetPoint("TOPLEFT",-scale(1),scale(1))
    h:SetPoint("BOTTOMRIGHT",scale(1),-scale(1))
    h:SetBackdropColor(0,0,0,0)
    h:SetBackdropBorderColor(0,0,0,.7)

    local fpp = CreateFrame("frame","FakeManaBar",fhp)
    fpp:SetWidth(fhp:GetWidth())
    fpp:SetHeight(f.height/3)
    fpp:SetPoint("TOPLEFT",FakeHealthBar,"BOTTOMLEFT",0,-2)
    fpp.bg = fpp:CreateTexture(nil, "PARENT")
    fpp.bg:SetTexture(cfg.statusbar_texture)
    fpp.bg:ClearAllPoints()
    fpp.bg:SetAllPoints(fpp)
    fpp.bg:SetVertexColor(.30,.45,.65)
    local h2 = CreateFrame("Frame",nil,fpp)
    h2:SetBackdrop(backdrop_tab)
    h2:SetPoint("TOPLEFT",-scale(1),scale(1))
    h2:SetPoint("BOTTOMRIGHT",scale(1),-scale(1))
    h2:SetBackdropColor(0,0,0,0)
    h2:SetBackdropBorderColor(0,0,0,1)

    fhp:RegisterEvent('PLAYER_TARGET_CHANGED')
    fhp:SetScript('OnEvent', function(self)
      if UnitExists("target") then
        self:Hide()
      else
        self:Show()
      end
    end)
  end
  -- oUF_CombatFeedback
  lib.gen_combat_feedback = function(f)
	if cfg.EnableCombatFeedback then
		local h = CreateFrame("Frame", nil, f.Health)
		h:SetAllPoints(f.Health)
		h:SetFrameLevel(30)
		local cfbt = lib.gen_fontstring(h, cfg.font, 18, "THINOUTLINE")
		cfbt:SetPoint("CENTER", f.Health, "BOTTOM", 0, -1)
		cfbt.maxAlpha = 0.75
		cfbt.ignoreEnergize = true
		f.CombatFeedbackText = cfbt
	end
  end
  -- alt power bar
  lib.gen_alt_powerbar = function(f)
	local apb = CreateFrame("StatusBar", nil, f)
	apb:SetFrameLevel(f.Health:GetFrameLevel() + 2)
	apb:SetSize(f.width/2.2, f.height/3)
	apb:SetStatusBarTexture(cfg.statusbar_texture)
	apb:GetStatusBarTexture():SetHorizTile(false)
	apb:SetStatusBarColor(1, 0, 0)
	apb:SetPoint("BOTTOM", f, "TOP", 0, -f.height/6)

	apb.bg = apb:CreateTexture(nil, "BORDER")
	apb.bg:SetAllPoints(apb)
	apb.bg:SetTexture(cfg.statusbar_texture)
	apb.bg:SetVertexColor(.18, .18, .18, 1)
	f.AltPowerBar = apb
	
	apb.b = CreateFrame("Frame", nil, apb)
	apb.b:SetFrameLevel(f.Health:GetFrameLevel() + 1)
	apb.b:SetPoint("TOPLEFT", apb, "TOPLEFT", -4, 4)
	apb.b:SetPoint("BOTTOMRIGHT", apb, "BOTTOMRIGHT", 4, -5)
	apb.b:SetBackdrop(backdrop_tab)
	apb.b:SetBackdropColor(0, 0, 0, 0)
	apb.b:SetBackdropBorderColor(0,0,0,1)
	
	apb.v = lib.gen_fontstring(apb, cfg.font, 10, "THINOUTLINE")
	apb.v:SetPoint("CENTER", apb, "CENTER", 0, 0)
	f:Tag(apb.v, '[mono:altpower]')
  end
  --hand the lib to the namespace for further usage
  ns.lib = lib