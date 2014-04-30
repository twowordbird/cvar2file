CSGODIR=/home/chris/Steam/games/csgo_ds
PLUGINDIR=bin
SCRIPTDIR=src

BIN=$(PLUGINDIR)/cvar2html.smx

all: $(BIN)

install: all
	cp $(BIN) $(CSGODIR)/csgo/addons/sourcemod/plugins

clean:
	rm -f $(BIN)

$(PLUGINDIR)/%.smx: $(SCRIPTDIR)/%.sp
	mkdir -p $(PLUGINDIR)
	$(CSGODIR)/csgo/addons/sourcemod/scripting/spcomp $(SPFLAGS) -o$@ $<

