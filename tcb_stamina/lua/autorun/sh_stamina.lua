/*---------------------------------------------------------------------------
	
	Creator: TheCodingBeast - TheCodingBeast.com
	This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
	To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/
	
---------------------------------------------------------------------------*/

//Config start.

//local DontDrawHUD = true	-- true/false
//local StaminaOnAllClients = true

local StaminaDrainSpeed = 0.25	-- Time in seconds
local StaminaRestoreSpeed = 0.75	-- Time in seconds

//Config end.


-- bad code incoming
-- i warned you

Stamina = Stamina or {}

local _mvdata = FindMetaTable( "CMoveData" )

// thx gmod wiki
function _mvdata:RemoveKeys( keys )
	-- Using bitwise operations to clear the key bits.
	local newbuttons = bit.band( self:GetButtons(), bit.bnot(keys) )
	self:SetButtons( newbuttons )
end

//PlayerSpawn
hook.Add( "PlayerSpawn", "StaminaPSpawn", function( ply )
	if ply.SteamID then
		timer.Destroy( ply:SteamID() .. "_StaminaTimer" )
	end
	ply.__Stamina = 100
	ply._pRunSpeed = nil
	ply.STAM_RunBlock = nil
end)

//SetupMove
hook.Add( "SetupMove", "StaminaPress", function( ply, mvd, ucmd )
	if !IsValid( ply ) then return end

	if !ply:Alive() or ply:GetMoveType() ==  MOVETYPE_LADDER or ply:GetMoveType() == MOVETYPE_NOCLIP or ply:InVehicle() then return end

	local IsMoving = ply:GetVelocity():Length2DSqr() > 0

	local function IsRunning()
		local vel = ply:GetVelocity()

		if ( vel.x > ply:GetWalkSpeed() and vel.x <= ply:GetRunSpeed() ) or ( vel.x < -ply:GetWalkSpeed() and vel.x >= -ply:GetRunSpeed() ) or ( vel.y > ply:GetWalkSpeed() and vel.y <= ply:GetRunSpeed() ) or ( vel.y < -ply:GetWalkSpeed() and vel.y >= -ply:GetRunSpeed() ) then
			--if CLIENT then print( "You're running!" ) end
			return true
		end
		return false
	end

	if !IsMoving then return end

	if /*mvd:KeyDown( IN_SPEED )*/ IsRunning() then
		if ply.__Stamina > 1 and !ply.STAM_RunBlock then
			timer.Destroy( ply:SteamID() .. "_StaminaGain" )

			if !timer.Exists(ply:SteamID() .. "_StaminaTimer") then
				timer.Create( ply:SteamID() .. "_StaminaTimer", StaminaDrainSpeed, 0, function()
					if !IsValid(ply) then return end

					if ply.__Stamina <= 0 then
						ply._pRunSpeed = math.max(ply._pRunSpeed or 0, ply:GetRunSpeed())
						ply:SetRunSpeed(ply:GetWalkSpeed())
						mvd:RemoveKeys( IN_SPEED )
						ucmd:RemoveKey(IN_SPEED)
						mvd:SetMaxSpeed(ply:GetWalkSpeed())
						mvd:SetMaxClientSpeed(ply:GetWalkSpeed())
						ply.STAM_RunBlock = true
						timer.Destroy( ply:SteamID() .. "_StaminaTimer"..CurTime() )
					elseif IsRunning() then
						ply.__Stamina = ply.__Stamina - 1
					end
				end)
			end
		else
			ply._pRunSpeed = math.max(ply._pRunSpeed or 0, ply:GetRunSpeed())
			ply:SetRunSpeed(ply:GetWalkSpeed())
			mvd:RemoveKeys( IN_SPEED )
			ucmd:RemoveKey(IN_SPEED)
			mvd:SetMaxSpeed(ply:GetWalkSpeed())
			mvd:SetMaxClientSpeed(ply:GetWalkSpeed())
			timer.Destroy( ply:SteamID() .. "_StaminaTimer" )
			StaminaRestore( ply )
		end
	else
		timer.Destroy( ply:SteamID() .. "_StaminaTimer" )
		StaminaRestore( ply )
	end

	if mvd:KeyReleased( IN_SPEED ) then
		timer.Destroy( ply:SteamID() .. "_StaminaTimer" )
		StaminaRestore( ply )
		if ply.__Stamina <= 1 then
			ply.STAM_RunBlock = true
		end
	end
end)

//PlayerTick
/*hook.Add( "PlayerTick", "StaminaThink", function( ply, mvd )
	if !mvd:KeyDown( IN_SPEED ) then
		timer.Destroy( ply:SteamID() .. "_StaminaTimer" )
		StaminaRestore( ply )
	end
end)*/

//StaminaRestore
function StaminaRestore( ply )
	if !timer.Exists( ply:SteamID() .. "_StaminaGain" ) then
		timer.Create( ply:SteamID() .. "_StaminaGain", StaminaRestoreSpeed, 0, function() 
			if ply.__Stamina >= 100 then
				ply.STAM_RunBlock = nil
				timer.Destroy( ply:SteamID() .. "_StaminaGain" )
				if ply._pRunSpeed then ply:SetRunSpeed(ply._pRunSpeed) end
				ply._pRunSpeed = nil
			else
				ply.__Stamina = ply.__Stamina + 1
			end
		end)
	end
end


//Serverside part
if SERVER then
	hook.Add( "PlayerSpawn", "SharedPSpawn", function( ply ) 
		timer.Simple( 0.15, function() ply:SendLua( [[hook.Call( "PlayerSpawn", nil, LocalPlayer() )]] ) end)
	end)

	print("____________")
	MsgC(Color(0,255,0), "---->\n")
	MsgC(Color(255, 0, 0), " > ") MsgC(Color(255,255,255), "tcb's Stamina Mod Loaded ...\n")
	MsgC(Color(255, 0, 0), " > ") MsgC(Color(255,255,255), "		Version: 1.0\n")
	MsgC(Color(0,255,0), "---->\n")
	print("____________")
end

//Clientside part (HUD)
if CLIENT then
	-- HUDPaint
	--[[hook.Add( "HUDPaint", "StaminaDrawHUD", function()
		if LocalPlayer():Alive() then
			if LocalPlayer().RunBlock then
				StaminaDrawColor = Color( 255, 0, 0, 255)
			else
				StaminaDrawColor = Color( 255, 255, 255, 255)
			end
			draw.DrawText( "Stamina: "..LocalPlayer().__Stamina, "TargetID", 11, 11, Color(0, 0, 0, 255) )
			draw.DrawText( "Stamina: "..LocalPlayer().__Stamina, "TargetID", 10, 10, StaminaDrawColor )
		end
	end)]]
end
