function EchoesProGambler:OnInitialize()
    self:Log("Register Chat say")
    self:RegisterEvent("CHAT_MSG_SAY")
end

function EchoesProGambler:CHAT_MSG_SAY(event, text, playerName, ...)
    self:Log("CHAT SAY %s", playerName)
    if playerName == nil then return end
    if self:CheckForJoinOrLeave(playerName, text) then return end
    if self:CheckForGameMode(text, playerName) then return end
    local session = self:CheckForSession(playerName)
    if session ~= nil then
        if self:CheckForInitRoll(session, text) then return end
        if self:CheckForDraw(session, text) then return end
        if self:CheckForEndOfRound(session, text) then return end
    end
end

-- e.g. Game Mode - NORMAL - 10000g
function EchoesProGambler:CheckForGameMode(text, playerName)
    if string.find(text, "Game Mode - ") then
        local prizeString, _ = string.gsub(text, "[^%d+]", "")
        local prize = tonumber(prizeString)
    
        local session = self:StartSession(playerName, prize)
        if session ~= nil then
            table.insert(self.Sessions, session)
            -- TODO: can do auto-join here
        end

        return true
    end

    return false
end

function EchoesProGambler:CheckForJoinOrLeave(playerName, text)
    self:Log("Check for Join or Leave - %s: %s ", playerName, text)
    if text == "1" then
        for _, session in ipairs(self.Sessions) do
            session:AddPlayer(playerName)
        end

        return true
    elseif text == "-1" then
        for _, session in ipairs(self.Sessions) do
            session:RemovePlayer(playerName)
        end

        return true
    end

    return false
end

function EchoesProGambler:CheckForSession(playerName)
    self:Log("Check for Session of %s", playerName)
    return self.Sessions[playerName]
end

function EchoesProGambler:CheckForCancel(session, text)
    self:Log("Check for cancel - %s: %s ", session.host, text)
    if string.find(text, "Game session has been canceled by") then
        session:Cancel()
        self:EndSession(session)
        return true
    end

    return false
end

function EchoesProGambler:CheckForInitRoll(session, text)
    self:Log("Check for init roll - %s: %s ", session.host, text)
    if string.find(text, "Registration has ended. All players") then
        session:Roll()
        -- TODO: can do auto-roll here
        return true
    end

    return false
end

function EchoesProGambler:CheckForDraw(session, text)
    self:Log("Check for draw - %s: %s ", session.host, text)
    if string.find(text, "Looks like nobody wins this round!") then
        self:Log("Success: Draw")
        session:Cancel()
        return true
    end

    return false
end

function EchoesProGambler:CheckForEndOfRound(session, text)
    self:Log("Check for end of round - %s: %s ", session.host, text)
    if string.find(text, "owes") then
        --find gold value that got won
        local amount, _ = string.gsub(text, "[^%d+]", "")
        --find out loser and winner
        local loserwinner = {}
        for match in (text.." "):gmatch("(.-)".." ") do
            table.insert(loserwinner, match);
        end
        
        local player, _ = UnitName("player")
        -- end the session - TODO: store in PastSessions table
        session:End(player, loserwinner[3], loserwinner[1], tonumber(amount))
        self:Log("Success: End Of Round")
        return true
    end

    return false
end

-- I only retain code that i still haven't implemented yet to remember
-- other functionality already in place i'll delete from this comment
--[[ --Gambler Join
function(event, msg, playerName,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_)
        if aura_env.amount >= aura_env.config.limit then
            return false
        end
end]]

--[[
-- Gambler Trade Untrigger
function(event, ...)
    if not ae.lost then --maybe not needed
        return true
    end
    if event == "UI_INFO_MESSAGE" then
        info_message_type = select(1,...)
        if info_message_type == 231 then
            return true
        end
    end
end
]]