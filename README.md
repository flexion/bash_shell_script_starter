# bash\_shell\_script\_starter

This is a starter / template for writing Bash scripts.  It includes a
few things:

1. some Doxygen-style comments to start things off
2. flags to protect us from undefined variables and failed commands
3. a `SCRIPT_PATH` variable so we can reference where the script lives
4. an error trap that prints the line where an error happens
5. a stack dump when errors do happen
6. a wrapper to allow us to source this script as if it was a library
7. CLI parameter handling
8. automagic help / usage generation

The goal is to help write scripts that are safer, cleaner, more usable,
more testable, and easier to debug.
