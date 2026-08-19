# Simon Says Multiplayer

A Verilog implementation of a four-bit Simon Says-style memory game. The design stores a player pattern, plays it back one entry at a time, and checks the player's repeated pattern before advancing or ending the game.

## Files

- `Simon.v` - Top-level game module.
- `SimonControl.v` - Finite-state controller for input, playback, repeat, and done modes.
- `SimonDatapath.v` - Pattern memory, counters, comparison logic, and LED selection.
- `Memory.v` - Synchronous pattern memory.
- `Simon.t.v` - Top-level simulation testbench.
- `SimonTA.t.v` - Extended top-level testbench.
- `SimonControl.t.v` - Controller testbench.
- `SimonDatapath.t.v` - Datapath testbench.
- `SummerSimon/SummerSimon.xpr` - Vivado project file.

## Game Flow

1. Set the level and four-bit pattern inputs.
2. The game stores the pattern and switches to playback mode.
3. The stored pattern is shown one entry at a time.
4. Repeat the pattern using the pattern inputs.
5. A correct repeat advances the game; an incorrect repeat switches to done mode.

The top-level `Simon` module accepts a clock, reset, level input, and four-bit pattern input. It outputs four pattern LEDs and three mode LEDs.

## Simulation

The testbenches check reset behavior, input mode, playback, successful repeats, invalid repeats, multi-entry sequences, and the done state.
