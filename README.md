# DUNGEON OF DESPAIR

## INTRODUCTION

While this game is inspired by *The Dungeon of Doom*, the aim is not to create a 100% carbon copy. There will be many similarities, but also plenty of differences. Most importantly, this version will be more modern, with some animations, more tile variations, ...

The game mechanics are loosely based on the Microlite20 system, but deviates wherever it makes sense. As such, reading the Microlite20 guide will explain much of the underlying combat mechanics.

However, there will be several areas in which this game will differ, some examples:

- No initiative rolls, the player is always first to act
- Movement speed limited to 1 tile per turn
- There is no sleep mechanic in the game, instead the player heals slowly over time
- The game is mostly combat focused, as such, skills will find little use outside of combat.

## MONETIZATION

In order to monotize the game, we'll aim for the following approach:

- Release game on multiple distribution platforms, such as Steam, AppStore & Play Store
- The first 10 dungeon levels will be free to play, but to enter lower levels, an in-app purchase is required
- Level advancement will also be limited, perhaps until level 6, until the dungeon expansion is bought
- An optional class pack can be purchased to unlock the following classes: Ranger, Druid, Bard & Illusionist

## TURNS

The turn-based mechanic will work a bit different than Microlite20, for the sake of gameplay. The most important changes are as follows ...

Every turn the player acts first. We determine how many time units are required to perform the action.

Afterwards all other actors receive the time units. The actors either perform an action allowed by the available time units or store the time units for next turn.

This approach allows for different movement speeds. The base move speed is 30, which is the default for most NPCs.

But some creatures, player characters might have a lower speed, e.g. due to size.

In order to determine how many time units (TU) are required to move, we can make the following calculations, depending on speed:

- **speed 30**: base 30 / speed 30 * 30 TU = 30 TU
- **speed 20**: base 30 / speed 20 * 30 TU = 45 TU
- **speed 40**: base 30 / speed 45 * 30 TU = 20 TU

Let's follow up with an example. We'll have 4 characters:

- Kendrick (PC): 30 movement speed (30 TU per move)
- Bat (NPC):     20 movement speed (45 TU per move)
- Orc (NPC):     30 movement speed (30 TU per move)
- Wolf (NPC):    45 movement speed (20 TU per move)

  ABCDEFGHI
1 ·········
2 ·······B·
3 ·K·····O·
4 ·······W·
5 ·········

Turn 1:

- Kendrick moves: B3→C3 (30 TU). All NPCs add 30 TU.
- Bat has 30 TU, but needs 45 to move, so Bat waits (30 TU remaining)
- Orc uses 30 TU to move: H3→G3 (0 TU remaining)
- Wolf uses 20 TU to move: H4→G4 (15 TU remaining)
 
-## TURN-BASED SYSTEM
  ABCDEFGHI
1 ·········
2 ·······B·
3 ··K···O··
4 ······W··
5 ·········
 
-The game advances a turn in 2 situations:
Turn 2:
 
-- every couple of seconds if the player has not made a move
-- if the player made a move, immediately
- Kendrink moves C3→D3 (30 TU). All NPCs add 30 TU.
- Bat uses 45 TU to move: H3→G3 (15 TU remaining)
- Orc uses 30 TU to move: G3→F3 (0 TU remaining)
- Wolf uses 40 TU to move 2 times: H4→G4→F4 (5 TU remaining)
 
  ABCDEFGHI
1 ·········
2 ······B··
3 ···K·O···
4 ····W····
5 ·········
 
Turn 3: