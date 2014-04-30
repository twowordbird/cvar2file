#define FCVAR_DEVELOPMENTONLY FCVAR_LAUNCHER

public Plugin:myinfo =
{
	name = "cvar2html",
	author = "Originally by MCPAN (mcpan@foxmail.com), modified by twowordbird (chris@twowordbird.com)",
	description = "Write list of commands and cvars in a bloggable format",
	version = "twb-0.1",
	url = "http://twowordbird.com/articles/csgo-console-commands-variable-reference/"
}

public OnMapStart()
{
	decl String:name[256], bool:isCommand, flags, String:description[1024];
	new Handle:cvarIter = FindFirstConCommand(name, sizeof(name), isCommand, flags, description, sizeof(description));
	new Handle:names = CreateArray(ByteCountToCells(sizeof(name)));
	new Handle:descriptions = CreateTrie();
	do
	{
		// don't print development cvars
		if (flags & FCVAR_DEVELOPMENTONLY)
			continue;

		// cvars need extra formatting
		if (!isCommand)
		{
			// prepend min/max values
			new Handle:cvar = FindConVar(name);
			new Float:valueMin, Float:valueMax;
			new bool:hasMin, bool:hasMax;
			decl String:valueMinStr[32], String:valueMaxStr[32]
			if ((hasMin = GetConVarBounds(cvar, ConVarBound_Lower, valueMin)))
				FloatToStringEx(valueMin, valueMinStr, sizeof(valueMinStr));
			if ((hasMax = GetConVarBounds(cvar, ConVarBound_Upper, valueMax)))
				FloatToStringEx(valueMax, valueMaxStr, sizeof(valueMaxStr));

			if (hasMin && hasMax)
				Format(description, sizeof(description), "Min: %s, Max: %s\n%s", valueMinStr, valueMaxStr, description);
			else if (hasMin)
				Format(description, sizeof(description), "Min: %s\n%s", valueMinStr, description);
			else if (hasMax)
				Format(description, sizeof(description), "Max: %s\n%s", valueMaxStr, description);

			// prepend default value
			decl String:defaultValueString[32];
			GetConVarDefault(cvar, defaultValueString, sizeof(defaultValueString));
			Format(description, sizeof(description), "Default: %s\n%s", defaultValueString, description);

			PushArrayString(names, name);
			SetTrieString(descriptions, name, description);
		}

		PushArrayString(names, name);
		SetTrieString(descriptions, name, description);
	}
	while (FindNextConCommand(cvarIter, name, sizeof(name), isCommand, flags, description, sizeof(description)));
	CloseHandle(cvarIter);
	
	WriteToHtml(names, descriptions, "cvar.html")

	CloseHandle(names)
	CloseHandle(descriptions)

	ServerCommand("quit")
}

WriteToHtml(Handle:names, Handle:descriptions, String:filename[])
{
	new Handle:cvarhtml
	cvarhtml = OpenFile(filename, "w")

	decl String:version[32];
	GetVersionString(version, sizeof(version));
	// remove extra characters from version string
	ReplaceString(version, sizeof(version), "\n", "");
	ReplaceString(version, sizeof(version), "\r", "");

	// write header
	WriteFileLine(cvarhtml, "<p>Below is a list of all console commands and cvars in the current release build of Counter-Strike: Global Offensive (v%s). <a href=\"http://twowordbird.com/live-updated-csgo-cvar-list/\" title=\"Live Updated CS:GO Cvar List\">More info here</a>. Filter using the search box below.</p>", version);
	WriteFileLine(cvarhtml, "<div id=\"cvarlist\">");
	WriteFileLine(cvarhtml, "<input class=\"search\" placeholder=\"Search\" />");
	WriteFileLine(cvarhtml, "<ul class=\"list\">");

	// write list of commands
	SortADTArrayCustom(names, SortCaseInsensitive)
	new size = GetArraySize(names);
	for (new i = 0; i < size; i++)
	{
		decl String:name[256];
		GetArrayString(names, i, name, sizeof(name));
		WriteFileLine(cvarhtml, "<li>");
		WriteFileLine(cvarhtml, "  <h3 class=\"name\">%s</h3>", name);

		decl String:description[1024];
		if (GetTrieString(descriptions, name, description, sizeof(description)) && description[0])
		{
			ReplaceString(description, sizeof(description), "\n", "&#10;");
			ReplaceString(description, sizeof(description), "<", "&lt;");
			ReplaceString(description, sizeof(description), ">", "&gt;");
			WriteFileLine(cvarhtml, "  <pre class=\"desc\">%s</pre>", description);
		}

		WriteFileLine(cvarhtml, "</li>");
	}

	// write footer
	WriteFileLine(cvarhtml, "</ul>");
	WriteFileLine(cvarhtml, "</div>");

	CloseHandle(cvarhtml);
}

bool:GetVersionString(String:version[], versionLen)
{
	new Handle:steaminf = OpenFile("steam.inf", "r")
	if (steaminf == INVALID_HANDLE)
		return false
	
	decl String:line[128]
	decl String:parts[2][128]
	while (ReadFileLine(steaminf, line, sizeof(line)))
	{
		ExplodeString(line, "=", parts, sizeof(parts), sizeof(parts[]), true)
		if (StrEqual(parts[0], "PatchVersion"))
		{
			strcopy(version, versionLen, parts[1])
			break
		}
	}

	CloseHandle(steaminf)
	return true
}

// like FloatToString, but also removes redundant zeros
FloatToStringEx(Float:num, String:str[], maxlength)
{
	new len = FloatToString(num, str, maxlength)
	for (new i = len - 1; i >= 0; i--)
	{
		if (str[i] != '0')
		{
			new idx
			if (str[i] == '.')
				idx = 1;

			len = i - idx + 1
			str[len] = 0
			break
		}
	}
	return len
}

public SortCaseInsensitive(i, j, Handle:array, Handle:h)
{
    decl String:stri[32], String:strj[32]
    GetArrayString(array, i, stri, sizeof(stri))
    GetArrayString(array, j, strj, sizeof(strj))
    return strcmp(stri, strj, false)
}
