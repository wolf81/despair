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

## CLASSES

This project doesn't make use a class library. Instead we create our own classes. The main reason here is to keep the project as maintainable as possible and I believe that having real privacy inside classes can help in this regard.

So classes follow this general pattern

```lua
local MyClass = {} -- class name

-- this is a private class method; no reference to `self`
local privateMethod1 = function(value) return 2 * value end

-- this is a public class method; no reference to `self`
MyClass.publicMethod = function() end

-- constructor
MyClass.new = function(...)
    -- private property, will not be added to public interface
    local private_prop = 1
    -- public property, will be added to public interface
    local public_prop = 5

    -- a private method is not added to interface
    -- can use self to call other public methods
    local privateMethod2 = function(self) 
        return private_prop + privateMethod1(public_prop)   -- returns: 11
    end

    -- a public method is defined same as private, but also added to interface
    local publicMethod = function(self) 
        -- use `self` reference to access public methods internally
        return private_prop + self:privateMethod2()         -- returns: 12
    end
    
    -- public interface
    return setmetatable({
        public_prop     = public_prop,
        publicMethod    = publicMethod,             
    }, MyClass)
end

return setmetatable(MyClass, {
    -- automatically call constructor when instantiating as such: MyClass()
    __call = function(_, ...) return MyClass.new(...) end, 
})
```

I do try to avoid exposing public properties as much as possible, as I suspect this could result in unexpected behavior. 

Calling methods will always result in a clear error of a method does not exist, but properties can be assigned to freely, without an error being raised if the property does not exist. Hence it is safer to modify internal state of an object by calling methods.

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
