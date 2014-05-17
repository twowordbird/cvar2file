#define FCVAR_DEVELOPMENTONLY FCVAR_LAUNCHER

public Plugin:myinfo =
{
    name = "cvar2file",
    author = "Originally by MCPAN (mcpan@foxmail.com), modified by twowordbird (chris@twowordbird.com)",
    description = "Write list of commands and cvars in a list format",
    version = "twb-0.2",
    url = "http://twowordbird.com/articles/csgo-console-commands-variable-reference/"
}

public OnMapStart()
{
    decl String:name[256], bool:isCommand, flags, String:description[2048]
    new Handle:cvarIter = FindFirstConCommand(name, sizeof(name), isCommand, flags, description, sizeof(description))
    new Handle:names = CreateArray(ByteCountToCells(sizeof(name)))
    new Handle:descriptions = CreateTrie()
    do
    {
        // don't print development cvars
        if (flags & FCVAR_DEVELOPMENTONLY)
            continue

        // ignore stuff related to SourceMod/Metamod
        if (StrContains(description, "metamod", false) >= 0 || StrContains(description, "sourcemod", false) >= 0)
            continue

        // cvars need extra formatting
        if (!isCommand)
        {
            // prepend min/max values
            new Handle:cvar = FindConVar(name)
            new Float:valueMin, Float:valueMax
            new bool:hasMin, bool:hasMax
            decl String:valueMinStr[32], String:valueMaxStr[32]
            if ((hasMin = GetConVarBounds(cvar, ConVarBound_Lower, valueMin)))
                FloatToStringEx(valueMin, valueMinStr, sizeof(valueMinStr))
            if ((hasMax = GetConVarBounds(cvar, ConVarBound_Upper, valueMax)))
                FloatToStringEx(valueMax, valueMaxStr, sizeof(valueMaxStr))

            if (hasMin && hasMax)
                Format(description, sizeof(description), "Min: %s, Max: %s\n%s", valueMinStr, valueMaxStr, description)
            else if (hasMin)
                Format(description, sizeof(description), "Min: %s\n%s", valueMinStr, description)
            else if (hasMax)
                Format(description, sizeof(description), "Max: %s\n%s", valueMaxStr, description)

            // prepend default value
            decl String:defaultValueString[32]
            GetConVarDefault(cvar, defaultValueString, sizeof(defaultValueString))
            Format(description, sizeof(description), "Default: %s\n%s", defaultValueString, description)
        }

        TrimString(description)
        // add info about flags
        if (flags & FCVAR_CHEAT)
            Format(description, sizeof(description), "%s\nRequires sv_cheats 1", description)
        if (flags & FCVAR_GAMEDLL)
            Format(description, sizeof(description), "%s\nServer only", description)
        if (flags & FCVAR_CLIENTDLL)
            Format(description, sizeof(description), "%s\nClient only", description)
        TrimString(description)

        PushArrayString(names, name)
        SetTrieString(descriptions, name, description)
    }
    while (FindNextConCommand(cvarIter, name, sizeof(name), isCommand, flags, description, sizeof(description)))
    CloseHandle(cvarIter)

    AddRadioCommands(names, descriptions)

    decl String:version[32], String:filename[64]
    GetVersionString(version, sizeof(version))
    Format(filename, sizeof(filename), "cvars-%s.txt", version)
    WriteToFile(names, descriptions, filename)

    CloseHandle(names)
    CloseHandle(descriptions)

    ServerCommand("quit")
}

AddRadioCommands(Handle:names, Handle:descriptions)
{
    // strings bin/client.dylib | less
    new String:radioCommands[][] = { "coverme", "takepoint", "holdpos", "regroup", "followme", "takingfire", "fallback", "sticktog", "getinpos", "stormfront", "report", "roger", "enemyspot", "needbackup", "sectorclear", "inposition", "reportingin", "getout", "enemydown"}
    for (new i = 0; i < sizeof(radioCommands); i++)
    {
        PushArrayString(names, radioCommands[i])
        SetTrieString(descriptions, radioCommands[i], "Radio command")
    }
}

WriteToFile(Handle:names, Handle:descriptions, String:filename[])
{
    new Handle:cvarfile
    cvarfile = OpenFile(filename, "w")

    // write command names and descriptions
    SortADTArrayCustom(names, SortCaseInsensitive)
    new size = GetArraySize(names)
    for (new i = 0; i < size; i++)
    {
        decl String:name[256], String:description[2048]
        GetArrayString(names, i, name, sizeof(name))
        if (GetTrieString(descriptions, name, description, sizeof(description)) && description[0])
            ReplaceString(description, sizeof(description), "\n", "\\n")
        WriteFileLine(cvarfile, "%s, %s", name, description)
    }

    CloseHandle(cvarfile)
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
            TrimString(version)
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
                idx = 1

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
