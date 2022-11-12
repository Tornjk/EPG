function EchoesProGambler:Log(...)
    if DLAPI then DLAPI.DebugLog("Echoes Pro Gambler", ...) end
end

if EpgSession ~= nil then
    function EpgSession:Log(...)
        if DLAPI then DLAPI.DebugLog("Echoes Pro Gambler", ...) end
    end
end