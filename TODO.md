# TODO

# FEATURES

* feat: Prevent stairs from being hidden under fog of war
* feat: Generate monsters randomly just outside visible area of player
* feat: Implement level saving and loading
* feat: Improve variety of textures in dungeon
* feat: Implement magic missile spell
* feat: Make generic bar view class that can be used for health, hunger, mana, ...
* feat: For systems, add a draw method and optional sort method, to use for rendering & allow removal of draw method in Entity class
* feat: HealthBar system should not be drawn from Visual system after making above change
* feat: Get experience for killing monsters and level up
* feat: Implement dual-wield attacks
* feat: Implement sleep & health recovery over sleep, remove automatic health recovery
* feat: Perhaps food should recover a small amount of health (?)
* feat: consuming a potion should assign a "use" action to player
* feat: consuming food should assign a "use" action to player
* feat: override Gamestate.push() & Gamestate.pop() to always call Gamestate.update(0)
* feat: setters in components should return self, so builder pattern can be used, see Visual setRotation, setOffset
* feat: implement ChangeLevel scene, this scene could keep player visible while making area around player dark, to provide a smooth transition between levels

## BUGS 

* fix: sometimes monsters stay visible under fog of war
* fix: rendering is buggy if 2 items with same z-index (e.g. tomes) are stacked on top of each other
* fix: when using keyboard for movement and pressing action buttons, sometimes the mouse pointer disappears
* fix: sometimes NPCs walk away, if NPCs are horizontally aligned with player and 1 empty tile in between, why?

## LIB

* Clean-up ndn, using classes similar as in Dungeon of Despair
* Possibly move Dijkstra, ndn and bresenham into a Rogue tools library

# DONE

* feat: Implement food, food should increase energy
* feat: Backpack should be a fixed size array, so we can make a proper inventory UI
* feat: Add entrance & exit stairs
* feat: If player performs an action, turn is advanced for all entities
* feat: Allow player to proceed to next level by moving on exit stairs
* feat: Allow player to proceed to previous level by moving on entrance stairs
* feat: Implement turn-based mechanism
* feat: Implement smooth level transitions
* feat: Implement fade-out animation for Destroy action
* feat: Implement line of sight
* feat: Sort actor turn order by initiative
* feat: Investigate if smoother movement is possible by setting player direction
* feat: Add level to attack bonus
* feat: Move camera related code to a separate class
* feat: Implement ranged attack for player characters
* feat: Implement custom mouse cursor
* feat: Generate items randomly 
* feat: Implement health recovery over time
* feat: Add proper arrow image for bows 
* feat: Move alpha related code from Animation to Visual component
* feat: Implement hunger
* feat: Use a Dijkstra map for pathfinding
* feat: MAP_SIZE should use absolute value, e.g. 100, for use with minimap
* feat: Implement energy system, so we can properly implement movement speed for scheduler. The system should work as follows: all actions the player does, use some energy. Other entities gain this energy and use it to perform an action. In case of a move action, can move multiple times until energy is gone. 
* feat: In Dijkstra Map should change ordinal distance to be more a higher value perhaps, in line with ordinal move cost in game (?)

* fix: clean-up Visual & Animation classes - should have methods on Visual to change current animation
* fix: sometimes a turn is stuck for a full duration when NPC is destroyed
* fix: mouse pointer positioning / coord calculations due to addition of side panel
