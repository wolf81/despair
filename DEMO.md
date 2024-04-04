# DEMO

Highlights for demo.

## ECS 

* Don't use any subclasses anymore, try to avoid in whole project
* Instead using ECS: an Entity is a generic container for components and components inside an entity are added based on "type" property
* EntityFactory adds components when creating a new entity
* Currently we have the following components:
	- Backpack
	- Equipment (paper doll)
	- Control (keyboard, mouse & CPU input)
	- ExpLevel (for player character to handle level up)
	- Health (for all entities that can die when health reaches 0)
	- Item (currently a dummy component to identify items that can be picked up)
	- MoveSpeed (to handle move speed calculations for players and NPCs)
	- Skills (Microlite20 based skills for PC and NPC characters)
	- Stats (Microlite20 based attributes for PC characters)
	- Visual (handle rendering of entity)
	- Weapon (for attack calculations - probably should rename)
	- Armor (for defense calulcations - probably should rename)

## COMBAT & SPELL OUTCOME CALCULATIONS

Will use separate modules, depending on situation.

Currently implemented is a Combat resolver for determining melee and ranged combat outcomes. This module contains most of the Microlite20-based logic to determine if a target was hit and if so, for how much damage.

## OBSERVER PATTERN

To notify on various aspects of game state, the game makes use of the Observer pattern.

This will be very useful to display information in a combat log. 

It's also used to update level state when a player or monster moves, picks up an item, is destroyed, is attacking (to show attack animation), etcetera.

## CORE GAME

* Roguelike will be inspired by Dungeon of Doom (classic macOS game)
* However, game will be real-time (Dungeon of Doom was 'sort-of' real-time with automatic turn progression)
* Of course can pause, so perhaps in this regards a bit like Baldur's Gate
* Mechanics will be based on Microlite20, but deviates where needed (e.g. no initiative rolls at start of turn, due to real-time nature)
* Like Dungeon of Doom, health respawns slowly over time & will have hunger mechanic
* Will probably add a mana mechanic as well (Microlite uses health for mana pool, but might make gameplay tricky? - Dungeon of Doom didn't have mana at all)
* Unlike Dungeon of Doom, will have real classes with different abilities, like Microlite, so rogues will have stealth, mages can cast spells, etc...
* But like in Dungeon of Doom, non-casters and casters alike can use wands and scrolls to cast spells, success will depend on e.g. MIND stat of KNOW skill or combination
* Enemy casters will deal with mana pool and cooldowns when casting spells
* Level design will be inspired by Dungeon of Doom: upper levels of dungeon has large open rooms, while bottom levels have cramped corridors.
* Itemization also similar to Dungeon of Doom (and many roguelikes). If you pick-up an item, it will be initially unidentified. An item can be identified using identification tomes (scrolls) or perhaps with a high "lore" skill or Identify spell. Items will get random enchants which could be positive of negative. A player can try to use an item without identification, but could be risky. However, using an item successfully like a potion will ensure the potion is identified automatically afterwards for the remainder of the game.
* Monster stats will be customized for a good game experience, so monsters not directly based on Microlite20 / DND.
* As a player navigates to lower levels, the monsters will become more dangerous.
* The player can train up on higher levels as monsters will keep respawning.
* Monster respawn mechanism will be similar to Dungeon of Doom which seems to respawn monsters occasionally just out of sight of player.

## COMMAND PATTERN

The game makes use of the Command pattern, though instead of commands, I call it actions. Actions currently are Move, Idle, Attack and Destroy.

Destroy is called automatically on an entity when health reaches 0. Other actions are based on keyboard, mouse or CPU input.

The actions are used by a Control component. A control component has a list of input modes to get actions from.

For computer-based monsters currently just a single input mode: CPU
For player character will have 2 input modes: mouse & keyboard






