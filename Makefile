CSGODIR=/Users/chrisevans/Library/Application\ Support/Steam/SteamApps/common/Counter-Strike\ Global\ Offensive
PLUGINDIR=bin
SCRIPTDIR=src

BIN=$(PLUGINDIR)/cvar2file.smx

all: $(BIN)

install: all
	cp $(BIN) $(CSGODIR)/csgo/addons/sourcemod/plugins

clean:
	rm -f $(BIN)

$(PLUGINDIR)/%.smx: $(SCRIPTDIR)/%.sp
	mkdir -p $(PLUGINDIR)
	$(CSGODIR)/csgo/addons/sourcemod/scripting/spcomp $(SPFLAGS) -o$@ $<

