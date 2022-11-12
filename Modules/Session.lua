local sessions = {}

EchoesProGambler.Sessions = sessions
EchoesProGambler.PastSessions = {}

local EPG_SESSION_JOIN = 0
local EPG_SESSION_ROLL = 1
local EPG_SESSION_END = 2

local EPG_RESULT_PENDING = -1
local EPG_RESULT_NONE = 0
local EPG_RESULT_WIN = 1
local EPG_RESULT_LOSE = 2

EpgSession = { host = '', players = {}, prize = 0, money = -1, state = EPG_SESSION_JOIN, result = EPG_RESULT_PENDING }

function EchoesProGambler:StartSession(playerName, prize)
    if self.Sessions[playerName] == nil then
        self:Log("Started Session by %s for %s", playerName, prize)
        local session = { host = playerName, players = {}, state = EPG_SESSION_JOIN, result = EPG_RESULT_PENDING, prize = prize, money = -1}
        self.Sessions[playerName] = setmetatable(session, EpgSession)
    end

    return sessions[playerName]
end

function EchoesProGambler:EndSession(session)
    for k, v in ipairs(self.Sessions) do
        if v == session then
            self:Log("Session by %s was ended", session.host)
            table.remove(self.Sessions, k)
            table.insert(self.PastSessions, session)
            break
        end
    end
end

function EpgSession:AddPlayer(playerName)
    if self.state == EPG_SESSION_JOIN then
        self:Log("%s joined %s session", playerName, self.host)
        for k, v in ipairs(self.players) do
            if v == playerName then
                self:Log("%s already joined the session previously", playerName)
                return
            end
        end
        table.insert(self.players, playerName)
    else
        self:Log("%s wanted to join session by %s but wrong state %s", playerName, self.host, self.state)
    end
end

function EpgSession:RemovePlayer(playerName)
    if self.state == EPG_SESSION_JOIN then
        for k, v in ipairs(self.players) do
            if v == playerName then
                self:Log("%s left %s session", playerName, self.host)
                table.remove(self.players, k)
                break
            end
        end
    else
        self:Log("%s wants to leave %s session but wrong state %s", playerName, self.host, self.state)
    end
end

function EpgSession:Roll()
    if self.state == EPG_SESSION_JOIN then
        self.state = EPG_SESSION_ROLL
    end
end

function EpgSession:End(player, winner, loser)
    if self.state == EPG_SESSION_ROLL then
        self.state = EPG_SESSION_END
        if player == winner then
            self.result = EPG_RESULT_WIN
        elseif player == loser then
            self.result = EPG_RESULT_LOSE
        else
            self.result = EPG_RESULT_NONE
        end
    end
end

function EpgSession:Cancel()
    self.state = EPG_SESSION_END
    self.result = EPG_RESULT_NONE
end