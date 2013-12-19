options:
#+------------------------------------------------------------------------------+
#| [V]                        Land Claiming                                 [V] |
#+-----------------------------------------------------------------------+------+
#|                                                                       |      
	Max-Land: 10 
#| The max land default players can claim.                               |
#| (Set to -1 for unlimited land claiming for default players)           |
#+-----------------------------------------------------------------------+
#|                                                                       |      
	Max-Land-VIP: 25
#| The max land VIP's can claim. Requires permission node land.claim.vip |
#| (Set to -1 for unlimited land claiming for VIP's)                     |
#+-----------------------------------------------------------------------+
#|                                                                       |      
	Max-Land-OP: -1 
#| The max land staff can claim. Requires permission node land.claim.op  |
#| (Set to -1 for unlimited land claiming for staff)                     |
#+-----------------------------------------------------------------------+
#|                                                                       |      
	Claim-Mode: none
#| none = No claim requirement | time = Able to claim more land the      |
#| longer you play                                                       |
#+-----------------------------------------------------------------------+
#|                                                                       |      
	Starting-Land: 1
#| The amount of land new players start off with. Will only work if      |
#| Claim-Mode is something other than none (For example, time)           |
#+-----------------------------------------------------------------------+
#|                                                                       |      
	Land-Gain-Time: 10
#| The amount of time in minuets when someone earns a new piece of land  |
#| to claim                                                              |
#+-----------------------------------------------------------------------+
#|                                                                       |      
	Refund-Land: true
#| When a player unclaims a land should they get the land back as a      |
#| point or lose it permanantly. Requires claim-mode = time (true/false) |
#+-----------------------------------------------------------------------+------+
#| [V]       Only edit anything below if you know what you're doing         [V] |
#+------------------------------------------------------------------------------+
variables:
	{landclaims.%player%} = 0
	{claimedland.%player%} = 0
on join:
	if {played.%player%} is not set:
		set {landclaims.%player%} to {@Starting-Land}
		set {played.%player%} to true
every 1 minute:
	if {Claim-Mode} is "time":
		loop all players in wolrd "wildtest":
			add 1 to {timeplayed.%loop-player%}
			if {timeplayed.%loop-player%} is greater than {@Land-Gain-Time} -1:
				remove {@Land-Gain-Time} from {timeplayed.%loop-player%}
				if {landclaims.%loop-player%} is greater than {@Max-Land} -1:
					if loop-player has permission "land.claim.vip" or "land.claim.op":
						if {landclaims.%loop-player%} is greater than {@Max-Land-VIP} -1:
							if loop-player has permission "land.claim.op":
								if {landclaims.%loop-player%} is greater than {@Max-Land-OP} -1:
									stop
							else:
								stop
					else:
						stop
				add 1 to {landclaims.%loop-player%}
				send "&6You have earned more land. To claim use /land claim at the land you want to claim." to loop-player
every 1 tick:
	set {Claim-Mode} to "{@Claim-Mode}"
	loop all players in world "wildtest":
		if {chunk.%chunk at location of loop-player%} is set:
			if {landnotify.%loop-player%} is "%chunk at location of loop-player%":
				exit loop
			if {landnotifyowner.%loop-player%} is "%{chunk.%chunk at location of loop-player%}%":
				exit loop
			send "&3--[&a&lClaimed by %{chunk.%chunk at location of loop-player%}%&3]--" to loop-player
			set {landnotifyowner.%loop-player%} to "%{chunk.%chunk at location of loop-player%}%"
			set {landnotify.%loop-player%} to "%chunk at location of loop-player%"
			exit loop
		if {landnotify.%loop-player%} is set:
			clear {landnotify.%loop-player%}
			clear {landnotifyowner.%loop-player%}
			send "&3--[&a&lUnclaimed land&3]--" to loop-player
command /land [<text>] [<offline player>]:
	description: For all land related commands
	usage: &c/land (claim, unclaim, add, remove)
	trigger:
		world is "wildtest"
		argument 1 is not set:
			message "&3-[&a&lLand Claimed&3]-"
			message "&6 %{claimedland.%player%}%"
			if {Claim-Mode} is "time":
				message "&3-[&a&lLand Claim Points&3]-"
				message "&6 %{landclaims.%player%}%"
			stop
		argument 1 is "help":
			message "&3--[&6&lLand Help&3]--"
			message "&cRequired = [] Optional = ()"
			message "&a * /land"
			message "&7 Shows your land claiming statistics"
			message "&a * /land [Info/Stats]"
			message "&7 Shows information about the land you are standing in"
			message "&a * /land [Claim/Unclaim]"
			message "&7 Claim/Unclaim the land you are standing at"
			message "&a * /land [Add/Remove]"
			message "&7 Add/Remove player from the land you are standing at"
			if player has permission "land.bypass":
				message "&a * /land bypass"
				message "&7 Bypass all claimed land"
			stop
		argument 1 is "stats" or "info":
			if {chunk.%chunk at location of player%} is set:
				message "&3--[&lLand Owner&3]--"
				message "&a * %{chunk.%chunk at location of player%}%"
				message "&3--[&lLand Members&3]--"
				message "&a * %{land.%chunk at location of player%::*}%"
				stop
			message "&6This area is not currently owned by a player."
			stop
		argument 1 is "error":
			if player has permission "land.bypass":
				message "&cIncorrect usage. Try '/land [claim, unclaim, add, remove, bypass] (player)'"
			else:
				message "&cIncorrect usage. Try '/land [claim, unclaim, add, remove, bypass] (player)'"
			message "&7 ()'s = Optional, []'s = Required."
			stop
		argument 1 is "claim":
			if {chunk.%chunk at location of player%} is set:
				message "&cThis land has already been claimed."
				stop	
			loop blocks in radius 50 of player:
				if player cannot build at the loop-block:
					message "&cYou can not claim land in this area."
					stop
			if {@Max-Land} is -1:
				if {Claim-Mode} is "time":
					if {landclaims.%player%} is greater than 0:
						remove 1 from {landclaims.%player%}
					else:
						message "&cYou need to play more before you can claim more land"
						stop
				add name of player to {land.%chunk at location of player%::*}
				set {chunk.%chunk at location of player%} to name of player
				set {chunk.%chunk at location of player%.%player%} to true
				message "&6You now own this land."
				add 1 to {claimedland.%player%}
			else:
				if {@Max-Land} is 0:
					if player has permission "land.claim.vip" or "land.claim.op":
						if {claimedland.%player%} is greater than {@Max-Land-VIP} -1:
							if player has permission "land.claim.op":
								if {claimedland.%player%} is greater than {@Max-Land-OP} -1:
									message "&cYou do not have permission to claim land"
									stop
							else:
								message "&cYou do not have permission to claim land"
								stop
					else:
						message "&cYou do not have permission to claim land"
						stop
				if {claimedland.%player%} is greater than {@Max-Land} -1:
					if player has permission "land.claim.vip" or "land.claim.op":
						if {claimedland.%player%} is greater than {@Max-Land-VIP} -1:
							if player has permission "land.claim.op":
								if {claimedland.%player%} is greater than {@Max-Land-OP} -1:
									message "&cYou have reached your claim limit for land"
									stop
							else:
								message "&cYou have reached your claim limit for land"
								stop
					else:
						message "&cYou have reached your claim limit for land"
						stop
				if {Claim-Mode} is "time":
					if {landclaims.%player%} is greater than 0:
						remove 1 from {landclaims.%player%}
					else:
						message "&cYou need to play more before you can claim more land"
						stop
				add name of player to {land.%chunk at location of player%::*}
				set {chunk.%chunk at location of player%} to name of player
				set {chunk.%chunk at location of player%.%player%} to true
				message "&6You now own this land."
				add 1 to {claimedland.%player%}
			stop
		argument 1 is "unclaim":
			if {chunk.%chunk at location of player%} is not set:
				message "&cThis land has not been claimed."
				stop
			if {chunk.%chunk at location of player%} is not player:
				if {bypassland.%player%} is not true:
					message "&cYou do not own this land."
					stop
			if {Claim-Mode} is "time":
				if {@Refund-Land} is true:
					add 1 to {landclaims.%{chunk.%chunk at location of player%}%}
			remove 1 from {claimedland.%{chunk.%chunk at location of player%}%}
			clear {land.%chunk at location of player%::*}
			clear {chunk.%chunk at location of player%}
			message "&6You have unclaimed this land."
			stop
		argument 1 is "add":
			if argument 2 is not set:
				make player execute command "land error"
				stop
			if {chunk.%chunk at location of player%} is not set:
				message "&cThis land has not been claimed."
				stop
			if {chunk.%chunk at location of player%} is not player:
				message "&cYou do not own this land."
				stop
			if {played.%argument 2%} is not set:
				message "&cThis player does not exist."
				stop
			if {chunk.%chunk at location of player%} is argument 2:
				message "&cYou can not add yourself to your own land."
				stop
			set {_playersearch} to 0
			loop 10000 times:
				if {land.%chunk at location of player%::%{_playersearch}%} is argument 2:
					message "&cThis player is already a member of this land."
					stop
				else:
					add 1 to {_playersearch}
			if {_playersearch} is 10000:
				message "&6%name of argument 2% can now build in this land."
				add "%name of argument 2%" to {land.%chunk at location of player%::*}
				set {chunk.%chunk at location of player%.%argument 2%} to true
				stop
		argument 1 is "remove":
			if argument 2 is not set:
				make player execute command "land error"
				stop
			if {chunk.%chunk at location of player%} is not set:
				message "&cThis land has not been claimed."
				stop
			if {chunk.%chunk at location of player%} is not player:
				message "&cYou do not own this land."
				stop
			if {played.%argument 2%} is not set:
				message "&cThis player does not exist."
				stop
			if {chunk.%chunk at location of player%} is argument 2:
				message "&cYou can not remove yourself from your own land."
				stop
			loop {land.%chunk at location of player%::*}:
				if loop-value is argument 2:
					clear {chunk.%chunk at location of player%.%argument 2%}
					delete {land.%chunk at location of player%::%loop-index%}
					exit loop
				message "&6%name of argument 2% can not build in this land anymore."
			stop
		argument 1 is "bypass":
			player has permission "land.bypass":
				if {bypassland.%player%} is true:
					clear {bypassland.%player%}
					message "&6You have finished bypassing claimed land."
					stop
				set {bypassland.%player%} to true
				message "&6You can now bypass claimed land."
				stop
			message "&cYou do not have permission to use this command."
			stop
		else:
			make player execute command "land error"
			stop
on quit:
	if {bypassland.%player%} is true:
		clear {bypassland.%player%}
on place:
	block is not tnt
	if {bypassland.%player%} is true:
		stop
	if {chunk.%chunk at location of block%} is set:
		if {chunk.%chunk at location of block%.%player%} is true:
			stop
		message "&cThis land is owned by %{chunk.%chunk at location of block%}%."
		cancel event
on break:
	if {bypassland.%player%} is true:
		stop
	if {chunk.%chunk at location of block%} is set:
		if {chunk.%chunk at location of block%.%player%} is true:
			stop
		message "&cThis land is owned by %{chunk.%chunk at location of block%}%."
		cancel event
on right click on chest:
	if {bypassland.%player%} is true:
		stop
	if {chunk.%chunk at location of block%} is set:
		if {chunk.%chunk at location of block%.%player%} is true:
			stop
		message "&cThis land is owned by %{chunk.%chunk at location of block%}%."
		cancel event
on right click on furnace:
	if {bypassland.%player%} is true:
		stop
	if {chunk.%chunk at location of block%} is set:
		if {chunk.%chunk at location of block%.%player%} is true:
			stop
		message "&cThis land is owned by %{chunk.%chunk at location of block%}%."
		cancel event
on right click on dropper:
	if {bypassland.%player%} is true:
		stop
	if {chunk.%chunk at location of block%} is set:
		if {chunk.%chunk at location of block%.%player%} is true:
			stop
		message "&cThis land is owned by %{chunk.%chunk at location of block%}%."
		cancel event
on right click on dispenser:
	if {bypassland.%player%} is true:
		stop
	if {chunk.%chunk at location of block%} is set:
		if {chunk.%chunk at location of block%.%player%} is true:
			stop
		message "&cThis land is owned by %{chunk.%chunk at location of block%}%."
		cancel event
on right click on hopper:
	if {bypassland.%player%} is true:
		stop
	if {chunk.%chunk at location of block%} is set:
		if {chunk.%chunk at location of block%.%player%} is true:
			stop
		message "&cThis land is owned by %{chunk.%chunk at location of block%}%."
		cancel event
on right click on hopper minecart:
	if {bypassland.%player%} is true:
		stop
	if {chunk.%chunk at location of block%} is set:
		if {chunk.%chunk at location of block%.%player%} is true:
			stop
		message "&cThis land is owned by %{chunk.%chunk at location of block%}%."
		cancel event
on right click on storage minecart:
	if {bypassland.%player%} is true:
		stop
	if {chunk.%chunk at location of block%} is set:
		if {chunk.%chunk at location of block%.%player%} is true:
			stop
		message "&cThis land is owned by %{chunk.%chunk at location of block%}%."
		cancel event
on place of tnt:
	if {bypassland.%player%} is true:
		stop
	loop blocks in radius 10 of block:
		if {chunk.%chunk at location of loop-block%} is set:
			if {chunk.%chunk at location of loop-block%.%player%} is true:
				exit loop
			else:
				cancel event
				message "&cYou can not use explosives here."
				stop
on explode:
	entity is creeper
	loop blocks in radius 10 of entity:
		if {chunk.%chunk at location of loop-block%} is set:
			cancel event