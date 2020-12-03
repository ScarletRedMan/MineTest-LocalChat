-- Methods

local function handleColors(msg)
    local messageParts = string.split("f" .. msg, "&")
    local coloredMsg = ""

    local colors = {
        ["4"] = "#be0000",
        ["c"] = "#fe3f3f",
        ["6"] = "#d9a334",
        ["e"] = "#fefe3f",
        ["2"] = "#00be00",
        ["a"] = "#3ffe3f",
        ["b"] = "#3ffefe",
        ["3"] = "#00bebe",
        ["1"] = "#0000be",
        ["9"] = "#3f3ffe",
        ["d"] = "#fe3ffe",
        ["5"] = "#be00be",
        ["7"] = "#bebebe",
        ["8"] = "#3f3f3f",
        ["f"] = "#ffffff",
        ["0"] = "#000000"
    }

    local foundColor = false
    for count, part in ipairs(messageParts) do
        for color, value in pairs(colors) do
            if part:sub(1, 1) == color then
                coloredMsg = coloredMsg .. minetest.colorize(value, part:sub(2))
                foundColor = true
                break
            end
        end

        if not foundColor then
            coloredMsg = coloredMsg .. part
        end
        foundColor = false
    end

    return coloredMsg
end

local function distance(pos, targetPos)
    return math.sqrt((pos.x - targetPos.x) ^ 2 + (pos.y - targetPos.y) ^ 2 + (pos.z - targetPos.z) ^ 2)
end

local function _if(condition, trueValue, falseValue)
    if condition then
        return trueValue
    end
    return falseValue
end


-- Events

minetest.register_on_chat_message(function(name, message)
    local player = minetest.get_player_by_name(name)

    if not player then
        return true
    end

    local isLocal = message:len() < 2 or message:sub(0, 1) ~= "!"
    local temp = -1
    local format = handleColors(_if(isLocal, "(&3L&f)", "(&6G&f)").." <&e"..name.."&f> &7").._if(isLocal, message, string.sub(message, 2))
    local pos = player:get_pos()

    for _, target in pairs(minetest.get_connected_players()) do
        if isLocal then
            if distance(pos, target:get_pos()) < 100 then
                minetest.chat_send_player(target:get_player_name(), format)
                temp = temp + 1
            end
        else
            minetest.chat_send_player(target:get_player_name(), format)
        end
    end

    if isLocal and temp == 0 then
        minetest.chat_send_player(name, handleColors("&8Nobody saw your message because there is no one next to you. Write &7!&8 before the message to send a message to the global chat."))
    end

    return true
end)
