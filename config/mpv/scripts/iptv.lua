-- Configuration
local keybinds = {
    activate = {'\\', 'MOUSE_BTN2'},
    plsup    = {'UP', 'MOUSE_BTN3'},
    plsdown  = {'DOWN', 'MOUSE_BTN4'},
    plsenter = {'ENTER', 'MOUSE_BTN0'}
}
local osd_time = 10
local window = 10 -- Increased for a slightly larger UI box
local fade = true
local plsbrightness = -70
local favorites = {}

-- Internal State
local pattern = ""
local is_active = false
local hide_timer = nil

-- Modern UI Overlay (ASS format)
local overlay = mp.create_osd_overlay("ass-events")

-- Compacted UTF-8 Case Conversion
local utf8_lc_uc = {
    a="A",b="B",c="C",d="D",e="E",f="F",g="G",h="H",i="I",j="J",k="K",l="L",m="M",n="N",o="O",p="P",q="Q",r="R",s="S",t="T",u="U",v="V",w="W",x="X",y="Y",z="Z",
    ["а"]="А",["б"]="Б",["в"]="В",["г"]="Г",["д"]="Д",["е"]="Е",["ж"]="Ж",["з"]="З",["и"]="И",["й"]="Й",["к"]="К",["л"]="Л",["м"]="М",["н"]="Н",["о"]="О",["п"]="П",["р"]="Р",["с"]="С",["т"]="Т",["у"]="У",["ф"]="Ф",["х"]="Х",["ц"]="Ц",["ч"]="Ч",["ш"]="Ш",["щ"]="Щ",["ъ"]="Ъ",["ы"]="Ы",["ь"]="Ь",["э"]="Э",["ю"]="Ю",["я"]="Я",["ё"]="Ё"
}

local utf8_uc_lc = {}
for k, v in pairs(utf8_lc_uc) do utf8_uc_lc[v] = k end

local utf8_char = "[\1-\127\192-\223][\128-\191]*"
local cyr_chars = {'а','б','в','г','д','е','ё','ж','з','и','й','к','л','м','н','о','п','р','с','т','у','ф','х','ц','ч','ш','щ','ъ','ы','ь','э','ю','я'}

local chars = {}
for i = 32, 126 do
    if string.match(string.char(i), "[%w%p ]") then table.insert(chars, i) end
end

local function mylower(s)
    return (string.gsub(s, utf8_char, function(c) return utf8_uc_lc[c] or c end))
end

local function prepat(s)
    return (string.gsub(s, "[%^%$%(%)%%%.%[%]%*%+%-%?]", function(c) return '%'..c end))
end

local fader = {
    saved_brtns = nil,
    on = function(self)
        if fade and not self.saved_brtns then
            self.saved_brtns = mp.get_property("brightness") or 0
            mp.set_property("brightness", plsbrightness)
        end
    end,
    off = function(self)
        if fade and self.saved_brtns then
            mp.set_property("brightness", self.saved_brtns)
            self.saved_brtns = nil
        end
    end
}

local playlister = {
    pls = nil,
    plsfiltered = nil,
    plspos = nil,
    wndstart = 1,
    cursor = 0,

    init = function(self)
        self.pls = mp.get_property_native("playlist") or {}
        pattern = ""
        self.plsfiltered = {}
        for i, _ in ipairs(self.pls) do table.insert(self.plsfiltered, i) end
        self.wndstart = 1
        self.cursor = 0
    end,

    show = function(self)
        -- Auto-initialize playlist if it hasn't been loaded yet
        if not self.plsfiltered then
            self:init()
        end
        if #self.plsfiltered == 0 then
            self:init() -- Retry fetch in case playlist loaded late
        end

        -- UI Styling (ASS Tags)
        local ass = "{\\an7}{\\fs24}{\\bord1.5}{\\3c&H111111&}"

        -- Header & Search Bar
        ass = ass .. "{\\c&Hd19317&}{\\b1}╭─ IPTV Channels ─────────────────────────────╮{\\b0}\n"
        ass = ass .. string.format("{\\c&HFFFFFF&}  Search: {\\c&Hffff00&}%s{\\c&HAAAAAA&}_\n", pattern)
        ass = ass .. "{\\c&Hd19317&}{\\b1}├─────────────────────────────────────────┤{\\b0}\n"

        if #self.plsfiltered == 0 then
            ass = ass .. "{\\c&H888888&}  (No channels found / Playlist empty)\n"
        else
            if self.wndstart > 1 then
                ass = ass .. "{\\c&H888888&}      ↑ ...\n"
            else
                ass = ass .. "\n"
            end

            local i = self.wndstart
            while self.plsfiltered[i] and i <= self.wndstart + window - 1 do
                local idx = self.plsfiltered[i]
                local item = self.pls[idx] or {}
                local title = item.title or item.filename or "Unknown Channel"

                -- Truncate long names to keep the UI clean
                if string.len(title) > 45 then title = string.sub(title, 1, 42) .. "..." end

                if item.current then
                    ass = ass .. "{\\c&H00ff00&}  ★ " .. title .. "\n"  -- Playing (Green)
                elseif i == self.wndstart + self.cursor then
                    ass = ass .. "{\\c&Hffff00&}  ▶ {\\b1}" .. title .. "{\\b0}\n" -- Selected (Cyan/Accent)
                else
                    ass = ass .. "{\\c&HCCCCCC&}      " .. title .. "\n" -- Normal (Light Gray)
                end
                i = i + 1
            end

            if self.wndstart + window - 1 < #self.plsfiltered then
                ass = ass .. "{\\c&H888888&}      ↓ ...\n"
            else
                ass = ass .. "\n"
            end
        end

        ass = ass .. "{\\c&Hd19317&}{\\b1}╰─────────────────────────────────────────╯{\\b0}"

        overlay.data = ass
        overlay:update()
    end,

    filter = function(self)
        self.plsfiltered = {}
        for i, v in ipairs(self.pls or {}) do
            local title = v.title or v.filename or ""
            if string.match(mylower(title), '.*' .. prepat(pattern) .. '.*') then
                table.insert(self.plsfiltered, i)
            end
        end
        self.wndstart = 1
        self.cursor = 0
    end,

    down = function(self)
        if not self.plsfiltered or self.cursor >= #self.plsfiltered - 1 then return end
        if self.cursor < window - 1 then
            self.cursor = self.cursor + 1
        else
            if self.wndstart < #self.plsfiltered - window + 1 then
                self.wndstart = self.wndstart + 1
            end
        end
        self:show()
    end,

    up = function(self)
        if not self.plsfiltered then return end
        if self.cursor > 0 then
            self.cursor = self.cursor - 1
            self:show()
        else
            if self.wndstart > 1 then
                self.wndstart = self.wndstart - 1
                self:show()
            end
        end
    end,

    play = function(self)
        if not self.plsfiltered then return end
        local target = self.plsfiltered[self.wndstart + self.cursor]
        if target and self.pls[target] then
            mp.commandv("playlist-play-index", target - 1)
            if self.plspos and self.pls[self.plspos] then self.pls[self.plspos].current = false end
            self.plspos = target
            self.pls[self.plspos].current = true
        end
    end
}

local function reset_timer()
    if hide_timer then
        hide_timer:kill()
        hide_timer:resume()
    end
end

local function shutdown()
    fader:off()
    overlay:remove()
    is_active = false
    -- Remove temporary search bindings
    for _, v in ipairs(chars) do mp.remove_key_binding('search' .. v) end
    for i, _ in ipairs(cyr_chars) do mp.remove_key_binding('search' .. (i + 1000)) end
    mp.remove_key_binding('searchbs')
    mp.remove_key_binding('searchspace')
end

local function typing(char)
    return function()
        pattern = pattern .. mylower(char)
        playlister:filter()
        playlister:show()
        reset_timer()
    end
end

local function backspace()
    if string.len(pattern) > 0 then
        pattern = string.match(pattern, "(.*)" .. utf8_char .. "$") or ""
        playlister:filter()
        playlister:show()
        reset_timer()
    end
end

local function bind_keys()
    for _, v in ipairs(chars) do
        local c = string.char(v)
        mp.add_forced_key_binding(c, 'search' .. v, typing(c), "repeatable")
    end
    for i, v in ipairs(cyr_chars) do
        mp.add_forced_key_binding(v, 'search' .. (i + 1000), typing(v), "repeatable")
    end
    mp.add_forced_key_binding('SPACE', 'searchspace', typing(' '), "repeatable")
    mp.add_forced_key_binding('BS', 'searchbs', backspace, "repeatable")
end

local function activate()
    if is_active then
        shutdown()
    else
        is_active = true
        fader:on()
        playlister:show()
        bind_keys()
        if not hide_timer then
            hide_timer = mp.add_timeout(osd_time, shutdown)
        else
            reset_timer()
        end
    end
end

-- Permanent Bindings
for i, key in ipairs(keybinds.activate) do mp.add_forced_key_binding(key, "activate" .. i, activate) end
for i, key in ipairs(keybinds.plsup) do mp.add_forced_key_binding(key, "plsup" .. i, function() if is_active then playlister:up(); reset_timer() end end, "repeatable") end
for i, key in ipairs(keybinds.plsdown) do mp.add_forced_key_binding(key, "plsdown" .. i, function() if is_active then playlister:down(); reset_timer() end end, "repeatable") end
for i, key in ipairs(keybinds.plsenter) do mp.add_forced_key_binding(key, "plsenter" .. i, function() if is_active then fader:off(); playlister:play(); playlister:show(); reset_timer() end end) end

-- Re-populate playlist automatically when loaded or changed by mpv
mp.register_event("file-loaded", function()
    playlister:init()
end)
