# TODO

# FEATURES

[x] feat: Add entrance & exit stairs
[x] feat: If player performs an action, turn is advanced for all entities
[X] feat: Allow player to proceed to next level by moving on exit stairs
[X] feat: Allow player to proceed to previous level by moving on entrance stairs
[X] feat: Implement turn-based mechanism with auto-advancing of turns every 4 seconds
[X] feat: Implement smooth level transitions
[X] feat: Implement fade-out animation for Destroy action
[X] feat: Implement line of sight
[X] feat: Sort actor turn order by initiative
[X] feat: Investigate if smoother movement is possible by setting player direction
[X] feat: Add level to attack bonus
[X] feat: Move camera related code to a separate class
[X] feat: Implement ranged attack for player characters
[X] feat: Implement custom mouse cursor
[X] feat: Generate items randomly 
[X] feat: Implement movement speed
[X] feat: Implement health recovery over time
[X] feat: Add proper arrow image for bows 
[X] feat: Move alpha related code from Animation to Visual component
[ ] feat: Prevent stairs from being hidden under fog of war
[ ] feat: Implement hunger
[ ] feat: Generate monsters randomly just outside visible area of player
[ ] feat: Implement level saving and loading
[ ] feat: Improve variety of textures in dungeon
[ ] feat: Use a Dijkstra map for pathfinding
[ ] feat: Implement magic missile spell
[ ] feat: Make generic bar view class that can be used for health, hunger, mana, ...
[ ] feat: MAP_SIZE should use absolute value, e.g. 100, for use with minimap
[ ] feat: For systems, add a draw method and optional sort method, to use for rendering & allow removal of draw method in Entity class
[ ] feat: HealthBar system should not be drawn from Visual system after making above change
[ ] feat: Get experience for killing monsters and level up

## LIB

[ ] Clean-up ndn, using classes similar as in Dungeon of Despair
[ ] Possibly move Dijkstra, ndn and bresenham into a Rogue tools library

## BUGS 

[X] fix: clean-up Visual & Animation classes - should have methods on Visual to change current animation
[X] fix: sometimes a turn is stuck for a full duration when NPC is destroyed
[ ] fix: sometimes monsters stay visible under fog of war
[ ] fix: rendering is buggy if 2 items with same z-index (e.g. tomes) are stacked on top of each other
