# DUNGEON OF DESPAIR

## INTRODUCTION

While this game is inspired by *The Dungeon of Doom*, the aim is not to create a 100% carbon copy. There will be many similarities, but also plenty of differences. Most importantly, this version will be more modern, with some animations, more tile variations, ...

The game mechanics are loosely based on the Microlite20 system, but deviates wherever it makes sense. As such, reading the Microlite20 guide will explain much of the underlying combat mechanics.

However, there will be several areas in which this game will differ, some examples:

- No initiative rolls, the player is always first to act
- Movement speed limited to 1 tile per turn
- The game is mostly combat focused, as such, skills will find little use outside of combat.

## MONETIZATION

In order to monotize the game, we'll aim for the following approach:

- Release game on multiple distribution platforms, such as Steam, AppStore & Play Store
- The first 10 dungeon levels will be free to play, but to enter lower levels, an in-app purchase is required
- Level advancement will also be limited, perhaps until level 6, until the dungeon expansion is bought
- An optional class pack can be purchased to unlock the following classes: Ranger, Druid, Bard & Illusionist

## TURNS

The turn-based mechanic will work a bit different than Microlite20, for the sake of gameplay. The most important changes are as follows ...

Every turn the player acts first. We determine how many action points (AP) are required to perform the action.

Afterwards all other actors receive the same amount of action points. The actors either perform an action allowed by the available action points or store the action points for next turn.

This approach allows for different movement speeds. The base move speed is 30, which is the default for most NPCs.

But some creatures & player characters might have a lower speed, e.g. due to race or size.

In order to determine how many action points are required to move, we can make the following calculations, depending on speed:

- **speed 30**: base 30 / speed 30 * 30 AP = 30 AP
- **speed 20**: base 30 / speed 20 * 30 AP = 45 AP
- **speed 45**: base 30 / speed 45 * 30 AP = 20 AP

### EXAMPLE

Let's follow up with an example. We'll have 4 characters:

- Kendrick (PC): 30 movement speed (30 AP per move)
- Bat (NPC):     20 movement speed (45 AP per move)
- Orc (NPC):     30 movement speed (30 AP per move)
- Wolf (NPC):    45 movement speed (20 AP per move)

```
  ABCDEFGHI
1 ·········
2 ·······B·
3 ·K·····O·
4 ·······W·
5 ·········
```

### TURN 1

- Kendrick moves: B3→C3 (30 AP). All NPCs add 30 AP.
- Bat has 30 AP, but needs 45 to move, so Bat waits (30 AP remaining)
- Orc uses 30 AP to move: H3→G3 (0 AP remaining)
- Wolf uses 20 AP to move: H4→G4 (15 AP remaining)

```
  ABCDEFGHI
1 ·········
2 ·······B·
3 ··K···O··
4 ······W··
5 ·········
```

### TURN 2

- Kendrick moves C3→D3 (30 TU). All NPCs add 30 TU.
- Bat uses 45 TU to move: H3→G3 (15 TU remaining)
- Orc uses 30 TU to move: G3→F3 (0 TU remaining)
- Wolf uses 40 TU to move 2 times: H4→G4→F4 (5 TU remaining)

```
  ABCDEFGHI
1 ·········
2 ······B··
3 ···K·O···
4 ····W····
5 ·········
```
