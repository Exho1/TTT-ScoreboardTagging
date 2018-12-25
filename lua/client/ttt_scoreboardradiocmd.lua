----// TTT Radio Command Tagging //----
-- Author: Exho
-- Version: 12/24/18

-- If the gamemode isn't initialized yet, wait until we're called upon
if not RADIO then return end

-- This is the scoreboard tags table taken directly from the TTT code
local tags = {
   {txt="sb_tag_friend", color=COLOR_GREEN},
   {txt="sb_tag_susp",   color=COLOR_YELLOW},
   {txt="sb_tag_avoid",  color=Color(255, 150, 0, 255)},
   {txt="sb_tag_kill",   color=COLOR_RED},
   {txt="sb_tag_miss",   color=Color(130, 190, 130, 255)}
};

-- This is my table which links a radio command to a scoreboard tag
local cmdToTag = {
	["innocent"] = {txt="sb_tag_friend", color=COLOR_GREEN},
	["suspect"] = {txt="sb_tag_susp",   color=COLOR_YELLOW},
	--[""] = {txt="sb_tag_avoid",  color=Color(255, 150, 0, 255)},
	["traitor"] = {txt="sb_tag_kill",   color=COLOR_RED}
	--[""] = {txt="sb_tag_miss",   color=Color(130, 190, 130, 255)}
}

-- If the given radio command is one of the ones I track, tag the player on the scoreboard
local function tagPlayer(ply, rCmd)

	if not isstring(ply) then
		if IsValid(ply) and IsPlayer(ply) then
			-- If the radio command is one of the ones I track, tag the player
			if cmdToTag[rCmd] then
				ply.sb_tag = cmdToTag[rCmd]
			end
		end
	end
end

-- This is the TTT SendCommand function overwritten to facilitate this addon
function RADIO:SendCommand(slotidx) 
   local c = self.Commands[slotidx]
   if c then
      RunConsoleCommand("ttt_radio", c.cmd)
	  
	  tagPlayer(self:GetTarget(), c.cmd)
	  
      self:ShowRadioCommands(false)
   end
end

-- This is another TTT function that I'm overwriting
local function RadioCommand(ply, cmd, arg)
   if not IsValid(ply) or #arg != 1 then
      print("ttt_radio failed, too many arguments?")
      return
   end

   if RADIO.LastRadio.t > (CurTime() - 0.5) then return end

   local msg_type = arg[1]
   local target, vague = RADIO:GetTarget()
   local msg_name = nil

   -- this will not be what is shown, but what is stored in case this message
   -- has to be used as last words (which will always be english for now)
   local text = nil

   for _, msg in pairs(RADIO.Commands) do
      if msg.cmd == msg_type then
         local eng = LANG.GetTranslationFromLanguage(msg.text, "english")
         text = msg.format and string.Interp(eng, {player = RADIO.ToPrintable(target)}) or eng

         msg_name = msg.text
         break
      end
   end

   if not text then
      print("ttt_radio failed, argument not valid radiocommand")
      return
   end

   if vague then
      text = util.Capitalize(text)
   end

   RADIO.LastRadio.t = CurTime()
   RADIO.LastRadio.msg = text

   -- target is either a lang string or an entity
   target = type(target) == "string" and target or tostring(target:EntIndex())

   -- Plug my function in there to tag the player even through a console command (ex: bound keys)
   tagPlayer(RADIO:GetTarget(), msg_type)
  
   
   RunConsoleCommand("_ttt_radio_send", msg_name, tostring(target))
end

local function RadioComplete(cmd, arg)
   local c = {}
   for k, cmd in pairs(RADIO.Commands) do
      local rcmd = "ttt_radio " .. cmd.cmd
      table.insert(c, rcmd)
   end
   return c
end
concommand.Add("ttt_radio", RadioCommand, RadioComplete)
