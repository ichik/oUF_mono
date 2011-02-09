  local addon, ns = ...
  local cfg = CreateFrame("Frame")

  -----------------------------
  -- MEDIA
  -----------------------------
  local MediaPath = "Interface\\Addons\\oUF_mono\\media\\"
  cfg.statusbar_texture = MediaPath.."statusbar"
  cfg.auratex = MediaPath.."iconborder" 
  cfg.font = MediaPath.."font.ttf"
  cfg.backdrop_texture = MediaPath.."backdrop"
  cfg.backdrop_edge_texture = MediaPath.."backdrop_edge"
  -- raid specific stuff
  cfg.aurafont = MediaPath.."auras.ttf"
  cfg.debuffborder = MediaPath.."iconborder"
  cfg.highlightTex = "Interface\\Buttons\\WHITE8x8"
  cfg.symbols = cfg.font
  
  -----------------------------
  -- CONFIG
  -----------------------------
  
  --config variables
  cfg.showtot = true
  cfg.showpet = true
  cfg.showfocus = true
  cfg.showparty = true
  cfg.showboss = true
  cfg.showarena = true
  cfg.allow_frame_movement = false -- allow alt+shift dragging for player, target, focus and pet frames
  cfg.frames_locked = true 
  cfg.playerauras = false -- small aura frame for player
  cfg.auratimers = false -- aura timers
    cfg.ATIconSizeThreshold = 19 -- how big some icon should be to display the custom timer
    cfg.ATSize = 12 -- aura timer font size
  cfg.showfaketarget = true -- fake target bars that spawn if you don't have anything targeted
  cfg.RMalpha = 0.6 -- raid mark alpha
  cfg.RMsize = 16 -- raid mark size
  cfg.EnableCombatFeedback = true -- enables CombatFeedback on player and target unit frames
  
  -- Cast bars settings
  cfg.focusCBuserplaced = true -- false to lock focus cast bar to the focus frame
    cfg.focusCBposition = {"CENTER",UIParent,"BOTTOM",10,410} -- focus cb position
    cfg.focusCBwidth = 280 -- focus cb width
    cfg.focusCBheight = 15 -- focus cb height
  cfg.playerCBuserplaced = false -- false to lock player cast bar to the player frame
    cfg.playerCBposition = {"CENTER",UIParent,"BOTTOM",10,320} -- player cb position
    cfg.playerCBwidth = 210 -- player cb width
    cfg.playerCBheight = 17 -- player cb height
  cfg.targetCBuserplaced = false -- false to lock target cast bar to the target frame
    cfg.targetCBposition = {"CENTER",UIParent,"BOTTOM",10,360} -- target cb position
    cfg.targetCBwidth = 210 -- target cb width
    cfg.targetCBheight = 17 -- target cb height
  cfg.cbcolor = {.3,.45,.65} -- castbar color
  cfg.interruptcb = {1, 0.49, 0} -- color setting for uninterruptable casts

  -- Frames position
  cfg.Ppos = {"TOP","UIParent","BOTTOM", -235, 275} -- player
  cfg.Tpos = {"TOP","UIParent","BOTTOM", 235, 275} -- target
  cfg.PEpos = {"TOPLEFT", "oUF_monoPlayerFrame", "BOTTOMLEFT", 0, -37} -- pet
  cfg.TTpos = {"TOPRIGHT", "oUF_monoTargetFrame", "BOTTOMRIGHT", 0, -37} -- ToT
  cfg.Fpos = {"TOPLEFT", "oUF_monoTargetFrame", "TOPRIGHT", 3, 0} -- focus
  cfg.PApos = {"BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 95, 352} -- party
    cfg.PAspacing = 40 -- spacing between party units
  cfg.ARpos = {"BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -117, 392} -- arena
  cfg.BOpos = {"BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -117, 392} -- boss
    cfg.ABspacing = 56 -- spacing between arena and boss units
  
  -- Size and scale
  cfg.Pwidth = 232 		-- Player frame
  cfg.Pheight = 25
  cfg.Pscale = 1
  
  cfg.Twidth = 232 		-- Target frame
  cfg.Theight = 25
  cfg.Tscale = 1
  
  cfg.PTTwidth = 133 	-- Pet and ToT frames
  cfg.PTTheight = 20
  cfg.PTTscale = 0.9
  
  cfg.Fwidth = 123 		-- Focus frame
  cfg.Fheight = 25
  cfg.Fscale = 1
  
  cfg.PABwidth = 196 	-- Party (+partypet), Arena (+arenatargets) and Boss frames
  cfg.PABheight = 22
  cfg.PABscale = 1
  
  --raid config
  cfg.showraid = true 								-- enable raid frames
  cfg.DisableBlizzRaidManager = true 				-- disable default compact Raid Manager button
  cfg.width = 59 									-- raid unit width
  cfg.height = 27 									-- raid unit height
  cfg.spacing = 4 									-- spacing between units
  cfg.namelength = 4 								-- number of letters to display
  cfg.fontsize = 12 								-- font size
  cfg.iconsize = 10 								-- informative icon size (aka RL,ML,A etc.)
  cfg.symbolsize = 11 								-- bottom right corner counter size
  cfg.indicatorsize = 5 							-- square indicator size
  cfg.debuffsize = 11 								-- debuff icon size
  cfg.focusHLcol = {.8, .8, .2, .7} 				-- focus border color
  cfg.orientation = "HORIZONTAL" 					-- hp/mp bar direction
  cfg.pos = {"TOPLEFT", "UIParent", "BOTTOM", -156, 177} 				-- raid frame (group 1-5) position
  cfg.MTframes = true 													-- toggle MT frames
    cfg.MTpos = {"BOTTOMLEFT", "UIParent", "BOTTOMRIGHT", -163, 233}	-- MTs frame position
    cfg.MTsize = 1.5 								-- MT size relatively to unit size
  cfg.frequent = true 								-- Enhances update rate for indicators (can be cpu intensive)
  cfg.indicators = true 							-- enable/disable raid frames indicators
  cfg.LeaderIcons = true 							-- toggle leader/assistant/master looter icons visibility on raid units
  cfg.RaidMark = true 								-- toggle raid mark visibility on raid units
  cfg.RCheckIcon = true 							-- ready check icon
  cfg.raid40swap = true 							-- allow raid frames to change their size if there are more than 30 players in the group
  cfg.raid5ON = false 								-- show raid frame for 5 (or less) men raid group
  cfg.partyON = false 								-- show party as 5 men raid group
    cfg.lfdIcons = true 							-- toggle group role indication on/off
  cfg.powerbar = true 								-- toggle display of tiny power bars on raid frames
    cfg.powerbarsize = 0.09 						-- power bar thickness relatively to unit size
  cfg.healbar = true 								-- healing prediction bar
	cfg.healalpha = 0.25 							-- heal prediction bar alpha
	cfg.healoverflow = 1 							-- overhealing display (1 = disabled, may take values higher than 1)
  cfg.healtext = false 								-- show/hide heal prediction text
  cfg.ShowRaidBG = false 							-- show background frame for raid frames
	
  -- HANDOVER
  ns.cfg = cfg
