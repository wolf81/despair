# PROJECT

This document outlines technical choices regarding this project. 

## PROJECT STRUCTURE

```
/dat                data files (csv)
/gen                generated data (lua) files based on csv data files
/doc                documentation related to Dungeon of Doom, Microlite20, ...
/gfx                graphical assets
/lib                third-party libraries (git submodules)
/shd                pixel shaders (GLSL)
/src                game source code
    /actions        actions for the command pattern, such as move, attack ...
    /components     components for entity-component system (ECS)
    /dijkstra       Dijkstra's algorithm, will become lib in future
    /ecs            entity- and system-related classes for ECS
    /generators     generator modules, such as a maze generator
    /helper         helper modules
    /hud            hud related views (UI)
    /input_modes    various input modes: cpu, keyboard, mouse, ...
    /resolvers      modules that resolve various game aspects, such as combat
    /scenes         game scenes (UI)
    /util           utility classes such as fog, camera, animation, ...
    /world          game world related classes: level, map, dungeon, ...
```

## ECS

We make use of a custom ECS system, as I found various third-party libraries problematic for a variety of reasons. This ECS is rather simple.

We have a single `Entity` class. The `Entity` class acts as container for various components. For example, PCs and NPCs make use of a `Control` component to receive input and a `Visual` component for rendering a texture.

We also have various Systems. A `System` manages a single component type for each entity. For example to render all entities we make use of a `System` that manages `Visual` components for each entity in play.

There is no base class for a `Component`. However, to properly use a `Component`with an `Entity` or `System` it should be a class; meaning the object must have a metatable that defines its type.

## COMMAND PATTERN

PCs & NPCs make use of a `Control` component to handle player or CPU input. Input is translated into a command, which we'll call an action in this game. 

## TURN SCHEDULER

In order to generate turns, we make use of the `Scheduler` class. The `Scheduler` generates turns for entities in play. Turns are defined by `Turn` objects.

## OBSERVER PATTERN

In order to show status messages and update level state, we make use of the observer pattern using the `Signal` library. For example, each action will emit a signal just prior to execution. The backpack will emit a signal when and item is picked up or dropped. As such, we can easily update the log and level state without having a direct level reference.
