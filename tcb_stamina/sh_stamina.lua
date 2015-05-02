/*---------------------------------------------------------------------------
	
	Creator: TheCodingBeast - TheCodingBeast.com
	This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
	To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/
	
---------------------------------------------------------------------------*/

local ShouldDrawHUD			= true	-- true/false

local DefaultRunSpeed		= 240	-- If you change this value you need to change it in garrysmod\addons\darkrpmodification\lua\darkrp_config\settings.lua too
local DefaultWalkSpeed		= 160	-- If you change this value you need to change it in garrysmod\addons\darkrpmodification\lua\darkrp_config\settings.lua too
local DefaultJumpPower		= 200

local DisableLevel			= 10	-- (0 - 100) When should Run & Jump get disabled

local StaminaDrainSpeed 	= 0.25	-- Time in seconds
local StaminaRestoreSpeed 	= 0.75	-- Time in seconds


-- Server
if (SERVER) then
	
	-- PlayerSpawn
	function tcb_StaminaStart( ply )
		timer.Destroy( "tcb_StaminaTimer" )
		ply:SetRunSpeed( DefaultRunSpeed )
		ply:SetNWInt( "tcb_Stamina", 100 )
		
		tcb_StaminaRestore( ply )
	end
	hook.Add( "PlayerSpawn", "tcb_StaminaStart", tcb_StaminaStart )
	
	-- KeyPress
	function tcb_StaminaPress( ply, key )
		if key == IN_SPEED or ply:KeyDown(IN_SPEED) then
			if ply:InVehicle() then return end
			if ply:GetMoveType() == MOVETYPE_NOCLIP then return end
			if ply:GetMoveType() ==  MOVETYPE_LADDER then return end
			if ply:GetNWInt( "tcb_Stamina" ) >= DisableLevel then
				ply:SetRunSpeed( DefaultRunSpeed )
				timer.Destroy( "tcb_StaminaGain" )
				timer.Create( "tcb_StaminaTimer", StaminaDrainSpeed, 0, function( )
					if ply:GetNWInt( "tcb_Stamina" ) <= 0 then
						ply:SetRunSpeed( DefaultWalkSpeed )
						timer.Destroy( "tcb_StaminaTimer" )
						return false
					end
					ply:SetNWInt( "tcb_Stamina", ply:GetNWInt( "tcb_Stamina" ) - 1 )
				end)
			else
				ply:SetRunSpeed( DefaultWalkSpeed )
				timer.Destroy( "tcb_StaminaTimer" )
			end
		end
		if key == IN_JUMP or ply:KeyDown(IN_JUMP) then
			if ply:GetNWInt( "tcb_Stamina" ) >= DisableLevel then
				ply:SetJumpPower( DefaultJumpPower )
				ply:SetNWInt( "tcb_Stamina", ply:GetNWInt( "tcb_Stamina" ) - 1 )
			else
				ply:SetJumpPower( 0 )
			end
		end
	end
	hook.Add( "KeyPress", "tcb_StaminaPress", tcb_StaminaPress ) 

	-- KeyRelease
	function tcb_StaminaRelease( ply, key )
		if key == IN_SPEED and !ply:KeyDown(IN_SPEED) then
			timer.Destroy( "tcb_StaminaTimer" )
			tcb_StaminaRestore( ply )
		end
	end
	hook.Add( "KeyRelease", "tcb_StaminaRelease", tcb_StaminaRelease ) 
	
	-- StaminaRestore
	function tcb_StaminaRestore( ply )
		timer.Create( "tcb_StaminaGain", StaminaRestoreSpeed, 0, function( ) 
			if ply:GetNWInt( "tcb_Stamina" ) >= 100 then
				return false
			else
				ply:SetNWInt( "tcb_Stamina", ply:GetNWInt( "tcb_Stamina" ) + 1 )
			end
		end)
	end

end

-- Client
if (CLIENT) then

	-- HUDPaint
	function tcb_StaminaDraw( )
		if ShouldDrawHUD == true then 
			if LocalPlayer():GetNWInt( "tcb_Stamina" ) <= DisableLevel then
				StaminaDrawColor = Color( 255, 0, 0, 255)
			else
				StaminaDrawColor = Color( 255, 255, 255, 255)
			end
			draw.DrawText( "Stamina: "..LocalPlayer():GetNWInt( "tcb_Stamina" ), "TargetID", 11, 11, Color(0, 0, 0, 255) )
			draw.DrawText( "Stamina: "..LocalPlayer():GetNWInt( "tcb_Stamina" ), "TargetID", 10, 10, StaminaDrawColor )
		end
	end
	hook.Add( "HUDPaint", "tcb_StaminaDraw", tcb_StaminaDraw )

end

-- Welcome Message
print("\n")
MsgC(Color(0,255,0), "---->\n")
print("\n")
MsgC(Color(255, 0, 0), " > ") MsgC(Color(255,255,255), "TCB Stamina Loaded ...\n")
MsgC(Color(255, 0, 0), " > ") MsgC(Color(255,255,255), "Version: 1.0\n")
print("\n")
MsgC(Color(255, 0, 0), " > ") MsgC(Color(255,255,255), "Updates can be found on my website\n")
MsgC(Color(255, 0, 0), " > ") MsgC(Color(255,255,255), "http://www.thecodingbeast.com/products\n")
print("\n")
MsgC(Color(0,255,0), "---->\n")
print("\n")
