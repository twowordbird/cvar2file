Source Engine CVar Exporter
================

This project builds a master list of console commands and variables in CS:GO. It consists a SourceMod plugin that, on map load, exports all server variables and commands and then exits.

# Exporting cvars

[SourceMod][sourcemod] plugin that exports all cvars in an HTML format on server start, and then quits. Cvars are exported to csgo/cvars-$VERSION.txt. Based on [a plugin by MCPAN][tools_cvarlist].

## Compiling

Edit the path to your CS:GO installation at the top of the Makefile, then simply make && make install.

[sourcemod]: http://www.sourcemod.net/
[tools_cvarlist]: https://forums.alliedmods.net/showthread.php?t=201768
