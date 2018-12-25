----// TTT Radio Command Tagging //----
-- Author: Exho
-- Version: 12/24/18

if SERVER then 

	AddCSLuaFile("client/ttt_scoreboardradiocmd.lua") 
	
end

hook.Add("PostGamemodeLoaded", "ttt_sbRadioActivator", function()

	print("Gamemode loaded, initializing Scoreboard Radio Commands for TTT")
	include("client/ttt_scoreboardradiocmd.lua")

end)