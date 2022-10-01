#include "includes\multiplayer_core.inc" 
//Script made by Goodman. For any inquries use discord and address questions to Goodman#4723

//Just to mention, ik its easier just to change the player's role to their proper reinforcement role and update their position.
//But then it doesn't count as an escape which may screw some functions up in other server scripts or updates. Might as well do it the hard way.
//So instead, the script takes the player (after they died from escaping) update their role back to what it was, teleport them to their gates actual escape coordinates.
//This makes the game think they escape and update their roles (and the other neccessary stuff) for us. 
//After the game places them at their gate, the script simply teleports them back to the gate they actually escaped at.
//If you're escaping through the enemy's spawn point, you should already be prepared for hostile activity.

global exit1 = [3, SE_FLOAT]
global escape1 = [3, SE_FLOAT]
global exit2 = [3, SE_FLOAT] // Gate A has fixed coords but better to prepare
global escape2 = [3, SE_FLOAT] //coords
global escapedplrs = [65,SE_INT]  //database of escaped plrs, more detail later on
global escape1cuff = [3, SE_FLOAT] //coords for gate b's escape. Gate A is always fixed, gate b isn't.

def escapecoords()
	local exit1entity = 0
	local exit2entity = 0
	local escape2entity = 0
	for i = 1; i < 70;i++ //theres bout 60-70 rooms max in a seed, for some reason each room id changes for each seed. 
		select GetRoomName(i) //make sure we have right room
			case "exit1"
				exit1entity = GetRoomObjectEntity(i,26)
				exit1[0] = EntityX(exit1entity)
				exit1[1] = EntityY(exit1entity)
				exit1[2] = EntityZ(exit1entity) // get x,y,z of gateb spawn
				escape1entity = GetRoomObjectEntity(i,27)
				escape1[0] = EntityX(escape1entity)
				escape1[1] = EntityY(escape1entity)
				escape1[2] = EntityZ(escape1entity) // get x,y,z of gateb escape
			case "gatea"
				exit2entity = GetRoomObjectEntity(i,27)
				exit2[0] = EntityX(exit2entity)
				exit2[1] = EntityY(exit2entity)
				exit2[2] = EntityZ(exit2entity) // get x,y,z of gate a spawn
				escape2entity = GetRoomObjectEntity(i,11)
				escape2[0] = EntityX(escape2entity)
				escape2[1] = EntityY(escape2entity)
				escape2[2] = EntityZ(escape2entity) // get x,y,z of gate a escape
			case "gateaentrance"
				local debounce = true
		end
		if debounce and exit2entity != 0 and exit1entity != 0 then break// check both gates exist
	end
	if exit1entity == 0 or debounce == 0 then RestartServer()//if not exist even if the server went tho every room,one of the gate is not present. RESTART THE DANG SERVER		
end

public def OnPlayerConsole(plr,txt)
	select txt
		case "handcuff"
			if GetPlayerHandcuff(plr) then
				SetPlayerHandcuff(plr,0)
			else
				SetPlayerHandcuff(plr,1)
				OnPlayerCuffPlayer(0,plr) //Call cuff callback. Assume player 0 == server
			end
		case "escape"
			select GetPlayerType(plr)
				case 3 
					SetPlayerPosition(plr,"gatea", escape2[0], escape2[1], escape2[2])
				case 4,8
					SetPlayerPosition(plr,"exit1", escape1[0], escape1[1], escape1[2])
				else
					SendMessage(plr,"You are not an Escape Class Role")
			end
	end
end

//

def capture(plr,role) //script to handle handcuffed players (They still should join the opposing team even if they escape tho their gatea)
	print("lego")
	if GetPlayerHandcuff(plr) == 0 then	return
	local room = GetPlayerRoomID(plr)
	room = GetRoomName(room)
	local plrentity = GetPlayerEntity(plr)
	local plrposition = [3, SE_FLOAT]
	plrposition[0] = EntityX(plrentity)
	plrposition[1] = EntityY(plrentity)
	plrposition[2] = EntityZ(plrentity)
	if room == "exit1" and role != 3 and plrposition[0] >= (escape1[0] - 2) and plrposition[2] <= (escape1[2] + 10) then //if handcuffed SCPF staff then be sure to become CI
		escapedplrs[plr] = true
		SetPlayerPosition(plr,"gatea", escape2[0], escape2[1], escape2[2])
	end
	if room == "gatea" and role == 3 and plrposition[0] >= 118 and plrposition[1] <= 496 and plrposition[2] <= 20 then //if handcuffed CD then MTF
		escapedplrs[plr] = true
		SetPlayerPosition(plr,"exit1", escape1[0], escape1[1], escape1[2])
	end
	CreateTimer("capture",1000,0,plr,role) //script needs to run every 1 second to detect. It takes >1 second from the beginning of new escape coords to reach proper
end

public def OnPlayerCuffPlayer(_,plr) //get ready to cause a lot of lag for a handcuffed plr
	capture(plr,GetPlayerType(plr))
end

public def OnServerStart()
	for i = 1; i < 10; i++;CreateFakePlayer(i); end //bots for debugging
	escapecoords()
end

public def OnServerRestart()
	escapecoords()
end

public def OnPlayerEscapeButDead(plr,_,before) //make them actually escape
	SetPlayerType(plr,before)
	escapedplrs[plr] = true
	if before == 3 then
		SetPlayerPosition(plr,"gatea", escape2[0], escape2[1], escape2[2])
	else
		SetPlayerPosition(plr,"exit1", escape1[0], escape1[1], escape1[2])
	end
end

def escaped(plr,before) //make them spawn where they escaped
	if escapedplrs[plr] == true then
		escapedplrs[plr] = false //delete em from database of escaped players, don't need em
		if before == 7 then //If this happens and they're chaos, they surely must have escaped tho gate b
			SetPlayerPosition(plr,"exit1", exit1[0], exit1[1], exit1[2]) //gate b spawn
		else 
			SetPlayerPosition(plr,"gatea", exit2[0], exit2[1], exit2[2]) //gate a spawn
		end		
	end
end

public def OnPlayerEscape(plr,before)	//execute escaped function after 100 milliseconds to make room for the natural (delayed) spawn position change	
	CreateTimer("escaped",100,0,plr,before)
end