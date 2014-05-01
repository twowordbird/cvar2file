Source Engine CVar Exporter
================

This project builds a master list of console commands and variables in CS:GO. It consists of two parts: a SourceMod plugin that exports all server variables and commands, and a script that incorporates extra variables and commands that exist only in the client. Currently, the command to get client varibles returns their default values as integers, even if they are floats, so information that can be obtained from the server is preferred.

# Exporting cvars

[SourceMod][sourcemod] plugin that exports all cvars in an HTML format on server start, and then quits. Cvars are exported to csgo/cvar.html. Based on [a plugin by MCPAN][tools_cvarlist].

## Compiling

Edit the path to your CS:GO installation at the top of the Makefile, then simply make && make install.

[sourcemod]: http://www.sourcemod.net/
[tools_cvarlist]: https://forums.alliedmods.net/showthread.php?t=201768
