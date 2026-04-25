--[[
    AC AudioCrafter UI  v1.8
    Black bg - Purple accent - Card-style UI
]]

local _sl = string.char(47,47)  -- "//" for obfuscator compatibility
local Request = request or (http and http.request) or http_request or (fluxus and fluxus.request)
local Link    = "https:".._sl.."fluxerusercontent.com/attachments/1489726264914649315/1490156145733428320/Desktop_2026.04.04_-_17.54.46.01-AudioTrimmer.com.mp3"
local AKLibrary = loadstring(game:HttpGet("https:".._sl.."yourscoper.vercel.app/scripts/akadmin/commandlibrary.lua"))()
local RequestButtonLinkBody = ""
pcall(function()
    if Request then
        local res = Request({Url = Link, Method = "GET"})
        if res and res.Body then RequestButtonLinkBody = res.Body end
    end
end)

local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")

local lp               = Players.LocalPlayer
local lpgui            = lp:WaitForChild("PlayerGui", 5)

if Request then
    pcall(function()
        Request({
            Url    = "http:".._sl.."127.0.0.1:6463/rpc?v=1",
            Method = "POST",
            Headers = {["Content-Type"]="application/json",["Origin"]="https:".._sl.."discord.com"},
            Body = HttpService:JSONEncode({
                cmd   = "INVITE_BROWSER",
                args  = {code = string.match("https:".._sl.."discord.com/invite/BGwQXse4Mw","discord%.com/invite/(%w+)")},
                nonce = HttpService:GenerateGUID(false)
            })
        })
    end)
end

if not isfile("AudioCrafterButtonSound.mp3") then
    writefile("AudioCrafterButtonSound.mp3", RequestButtonLinkBody)
end

local C = {
    bg        = Color3.fromRGB(8,   8,   10),
    card      = Color3.fromRGB(72,  0,   66),
    cardHov   = Color3.fromRGB(96,  0,   88),
    cardDark  = Color3.fromRGB(18,  18,  22),
    cardBord  = Color3.fromRGB(50,  50,  58),
    purple    = Color3.fromRGB(72,  0,   66),
    purpleDim = Color3.fromRGB(46,  0,   42),
    sep       = Color3.fromRGB(110, 0,   100),
    tabBar    = Color3.fromRGB(8,   8,   10),
    white     = Color3.fromRGB(255, 255, 255),
    black     = Color3.fromRGB(0,   0,   0),
    txtMain   = Color3.fromRGB(255, 255, 255),
    txtDim    = Color3.fromRGB(140, 140, 148),
    green     = Color3.fromRGB(72,  200, 110),
    off       = Color3.fromRGB(28,  28,  34),
    on        = Color3.fromRGB(72,  0,   66),
    sliderBg  = Color3.fromRGB(22,  22,  28),
    sliderFg  = Color3.fromRGB(72,  0,   66),
    togOff    = Color3.fromRGB(50,  50,  58),
    cmdBox    = Color3.fromRGB(14,  14,  18),
}

-- Shared accent color for HUD elements (updated when user changes color preset)
local accentColor = Color3.fromRGB(110, 0, 100)

local OWNER_USERS = {
    ["MelodyCrafter3"]     = true,
    ["LostMelodyCrafter"]  = true,
    ["yourscoperr"]        = true,
    ["Exhalivibes"]        = true,
    ["theunknownperson105"]= true,
    ["meowkixy"]           = true,
    ["Xxsushi_bobax"]      = true,
    ["zxstyzac"]           = true,
    ["interw3b_0"]         = true,
    ["yvngjr2020"]         = true,
    ["biscuit0onyx"]       = true,
    ["lolfearfox"]         = true,
    ["flip1234416"]        = true,
    ["yvngjr2020"]         = true,
}
local IS_OWNER = OWNER_USERS[lp.Name] == true

local THEME_PRESETS = {
    {color=Color3.fromRGB(78,0,72),    hover=Color3.fromRGB(58,0,54),    dim=Color3.fromRGB(50,0,46),    sep=Color3.fromRGB(120,0,110)},
    {color=Color3.fromRGB(100,0,0),    hover=Color3.fromRGB(75,0,0),     dim=Color3.fromRGB(60,0,0),     sep=Color3.fromRGB(150,0,0)},
    {color=Color3.fromRGB(255,182,211), hover=Color3.fromRGB(230,150,185), dim=Color3.fromRGB(200,120,160), sep=Color3.fromRGB(255,200,225)},
}
local function applyTheme(preset)
    local newColors={preset.color,preset.color,preset.hover,preset.dim,preset.sep,preset.color}
    local oldColors={C.purple, C.card, C.cardHov, C.purpleDim, C.sep, C.sliderFg}
    C.purple=preset.color; C.card=preset.color; C.cardHov=preset.hover
    C.purpleDim=preset.dim; C.sep=preset.sep; C.sliderFg=preset.color; C.on=preset.color
    accentColor = preset.sep  -- update shared accent so HUD/tag glows use new color
    task.spawn(function()
        for _,sg in ipairs(game:GetService("CoreGui"):GetDescendants()) do
            if sg.Name~="ThemeCircle" then
                if sg:IsA("Frame") or sg:IsA("TextButton") or sg:IsA("ImageButton") or sg:IsA("ScrollingFrame") then
                    for i=1,#oldColors do if sg.BackgroundColor3==oldColors[i] then sg.BackgroundColor3=newColors[i] end end
                elseif sg:IsA("UIStroke") then
                    for i=1,#oldColors do if sg.Color==oldColors[i] then sg.Color=newColors[i] end end
                    -- Rebuild any rotating gradient inside this stroke with the new sep color
                    local ug=sg:FindFirstChildOfClass("UIGradient")
                    if ug then
                        ug.Color=ColorSequence.new({
                            ColorSequenceKeypoint.new(0,    Color3.fromRGB(255,255,255)),
                            ColorSequenceKeypoint.new(0.25, preset.sep),
                            ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(0,0,0)),
                            ColorSequenceKeypoint.new(0.75, preset.sep),
                            ColorSequenceKeypoint.new(1,    Color3.fromRGB(255,255,255)),
                        })
                    end
                elseif sg:IsA("ImageLabel") then
                    for i=1,#oldColors do if sg.BackgroundColor3==oldColors[i] then sg.BackgroundColor3=newColors[i] end end
                end
            end
        end
    end)
end

local function Shorten(Parameter)
    local PlayerList = {}
    for _, Search in pairs(Players:GetPlayers()) do
        if Search.Name:lower():sub(1,#Parameter)==Parameter:lower()
        or Search.DisplayName:lower():sub(1,#Parameter)==Parameter:lower() then
            table.insert(PlayerList, Search)
        end
    end
    return PlayerList
end

local AC_selectedTarget = nil

local CHANGELOG = {
    { ver="v1.8", title="Card UI Restyle + Admin Tab",
      desc="Full card-style UI. Admin-only panel with exclusive tools. All features intact." },
    { ver="v1.5", title="Purple Theme + Bug Fixes",
      desc="Purple color scheme. UGC Emotes + AC Reanimation panels." },
    { ver="v1.4", title="Target Actions + Misc Tab",
      desc="Player target actions, Misc tab, EmptyTools." },
}

local TABS = {
    {name="Home"},{name="Player"},{name="World"},
    {name="Tools"},{name="Emotes"},{name="Misc"},{name="Admin"},
}

pcall(function()
    local o = CoreGui:FindFirstChild("AudioCrafterUI")
    if o then o:Destroy() end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "AudioCrafterUI"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder   = 10
ScreenGui.IgnoreGuiInset = true
pcall(function() ScreenGui.Parent = CoreGui end)

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end

local function mkFrame(parent, props)
    local f = Instance.new("Frame")
    f.BorderSizePixel  = 0
    f.BackgroundColor3 = C.bg
    f.ClipsDescendants = false
    for k,v in pairs(props or {}) do f[k]=v end
    f.Parent = parent
    return f
end

local function mkLabel(parent, text, props)
    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.BorderSizePixel  = 0
    t.Font             = Enum.Font.GothamBold
    t.TextColor3       = C.white
    t.TextSize         = 13
    t.Text             = text
    t.TextXAlignment   = Enum.TextXAlignment.Left
    t.TextWrapped      = true
    for k,v in pairs(props or {}) do t[k]=v end
    t.Parent = parent
    return t
end

local function mkBtn(parent, text, props)
    local b = Instance.new("TextButton")
    b.BorderSizePixel  = 0
    b.BackgroundColor3 = C.purple
    b.Font             = Enum.Font.GothamBold
    b.TextColor3       = C.white
    b.TextSize         = 13
    b.Text             = text
    b.AutoButtonColor  = false
    b.MouseButton1Click:Connect(function()
        if not (Win and Win.Visible) then return end
        if not b:IsDescendantOf(Win) then return end
        pcall(function()
            local s = Instance.new("Sound", b)
            s.Volume  = 0.08
            s.SoundId = "rbxassetid:".._sl.."6042053626"
            s:Play()
            game:GetService("Debris"):AddItem(s, 1)
        end)
    end)
    for k,v in pairs(props or {}) do b[k]=v end
    b.Parent = parent
    return b
end

local function mkStroke(parent, col, thick)
    local s = Instance.new("UIStroke")
    s.Color           = col or C.sep
    s.Thickness       = thick or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent          = parent
    return s
end

local function hov(b, norm, hi)
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.08), {BackgroundColor3=hi}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.08), {BackgroundColor3=norm}):Play()
    end)
end

-- forward declare nextOrder so card helpers can reference it before tab loop
local nextOrder

-- -- CARD-STYLE HELPERS ---------------------------------------
local function mkFeatureCard(parent, cardDef, xPos, xSzScale, xSzOffset, cardH)
    -- Compact: title only, no cmd box, no desc. Height forced to 42px.
    cardH = 42
    local card = mkFrame(parent, {
        Size=UDim2.new(xSzScale, xSzOffset, 0, cardH),
        Position=UDim2.new(xPos, xPos>0 and 4 or 0, 0, 0),
        BackgroundColor3=C.cardDark, ZIndex=5,
    })
    corner(card, 10)
    local cardStroke=mkStroke(card, C.cardBord, 2)
    do
        local cg=Instance.new("UIGradient"); cg.Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,    Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.25, Color3.fromRGB(120, 0, 110)),
            ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(20,  20,  20)),
            ColorSequenceKeypoint.new(0.75, Color3.fromRGB(120, 0, 110)),
            ColorSequenceKeypoint.new(1,    Color3.fromRGB(255, 255, 255)),
        }); cg.Parent=cardStroke
        RunService.Heartbeat:Connect(function() if cardStroke.Parent then cg.Rotation=(cg.Rotation+1)%360 end end)
    end
    -- Title label, vertically centred
    mkLabel(card, cardDef.label, {
        Size=UDim2.new(1,-52,1,0), Position=UDim2.new(0,12,0,0),
        TextSize=13, Font=Enum.Font.GothamBold, TextColor3=C.white, ZIndex=6,
    })
    if cardDef.toggle then
        local togW,togH=34,18
        local togFrame=mkFrame(card,{Size=UDim2.new(0,togW,0,togH),Position=UDim2.new(1,-44,0.5,-togH/2),
            BackgroundColor3=C.togOff,ZIndex=6})
        corner(togFrame,togH/2)
        local knob=mkFrame(togFrame,{Size=UDim2.new(0,togH-4,0,togH-4),Position=UDim2.new(0,2,0.5,-(togH-4)/2),
            BackgroundColor3=Color3.fromRGB(140,140,140),ZIndex=7})
        corner(knob,(togH-4)/2)
        local active=false
        local sel=Instance.new("TextButton")
        sel.Size=UDim2.new(1,0,1,0); sel.BackgroundTransparency=1; sel.Text=""; sel.ZIndex=8; sel.Parent=togFrame
        sel.Activated:Connect(function()
            active=not active
            TweenService:Create(togFrame,TweenInfo.new(0.15),{BackgroundColor3=active and C.purple or C.togOff}):Play()
            TweenService:Create(knob,TweenInfo.new(0.15),{
                Position=active and UDim2.new(1,-(togH-2),0.5,-(togH-4)/2) or UDim2.new(0,2,0.5,-(togH-4)/2),
                BackgroundColor3=active and C.white or Color3.fromRGB(140,140,140)
            }):Play()
            if cardDef.callback then pcall(cardDef.callback, active) end
        end)
    else
        local act=Instance.new("TextButton")
        act.Size=UDim2.new(1,0,1,0); act.BackgroundTransparency=1; act.Text=""; act.ZIndex=8; act.Parent=card
        act.Activated:Connect(function() if cardDef.callback then pcall(cardDef.callback) end end)
        mkLabel(card,">",{Size=UDim2.new(0,20,1,0),Position=UDim2.new(1,-26,0,0),TextSize=16,
            Font=Enum.Font.GothamBold,TextColor3=C.txtDim,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=6})
    end
    return card
end

local function pageCardRow(s, idx, cards, rowH)
    rowH=42  -- always 42 now -- cards are compact title-only rows
    local row=mkFrame(s,{Size=UDim2.new(1,0,0,rowH),BackgroundTransparency=1,LayoutOrder=nextOrder(idx),ZIndex=4})
    if #cards==1 then
        mkFeatureCard(row,cards[1],0,1,0,rowH)
    elseif #cards==2 then
        mkFeatureCard(row,cards[1],0,0.5,-4,rowH)
        mkFeatureCard(row,cards[2],0.5,0.5,-4,rowH)
    end
    return row
end

local function secLabel(s, text, idx)
    mkLabel(s,text,{Size=UDim2.new(1,0,0,20),TextSize=10,
        TextColor3=Color3.fromRGB(120,120,120),Font=Enum.Font.GothamBold,
        LayoutOrder=nextOrder(idx),ZIndex=4})
end

local function mkSlider(parent, labelText, minVal, maxVal, defaultVal, layoutOrder, onChange)
    local container=mkFrame(parent,{Size=UDim2.new(1,0,0,58),BackgroundColor3=C.cardDark,LayoutOrder=layoutOrder,ZIndex=4})
    corner(container,10); mkStroke(container,C.cardBord,1)
    mkLabel(container,labelText,{Size=UDim2.new(0.35,-8,0,18),Position=UDim2.new(0,12,0,8),
        TextSize=13,Font=Enum.Font.GothamBold,TextColor3=C.white,ZIndex=5})
    local valLbl=mkLabel(container,tostring(defaultVal),{Size=UDim2.new(0,40,0,18),Position=UDim2.new(1,-50,0,8),
        TextSize=13,Font=Enum.Font.GothamBold,TextColor3=C.white,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=5})
    local track=mkFrame(container,{Size=UDim2.new(0.6,0,0,8),Position=UDim2.new(0.3,0,0,34),
        BackgroundColor3=C.sliderBg,ZIndex=5})
    corner(track,4)
    local pct=(defaultVal-minVal)/(maxVal-minVal)
    local fill=mkFrame(track,{Size=UDim2.new(pct,0,1,0),BackgroundColor3=C.sliderFg,ZIndex=6}); corner(fill,4)
    local knob=mkFrame(track,{Size=UDim2.new(0,16,0,16),Position=UDim2.new(pct,-8,0.5,-8),
        BackgroundColor3=C.white,ZIndex=7}); corner(knob,8)
    local dragging=false
    local function update(x)
        local p=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        local v=math.floor(minVal+p*(maxVal-minVal))
        valLbl.Text=tostring(v); fill.Size=UDim2.new(p,0,1,0); knob.Position=UDim2.new(p,-8,0.5,-8)
        if onChange then onChange(v) end
    end
    track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; update(i.Position.X) end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then update(i.Position.X) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
end

local WIN_W=780; local WIN_H=460
local HEADER_H=46; local TABBAR_H=42
local CONTENT_H=WIN_H-HEADER_H-TABBAR_H

local keyValidated   = false
local KEY_API        = "https:".._sl.."yourscoper.vercel.app/api/ackey"
local registerSelf   = function() end
local openClickTP
local openBaseplate
local KEY_LINK       = "https:".._sl.."linkvertise.com/3729101/RKjiVsGqf6ck?o=sharing"
local DISCORD_INVITE = "https:".._sl.."discord.gg/hDReufFgBv"

local settingsFile="AC_Settings_"..tostring(lp.UserId)..".json"
local savedSettings={ugcSpeed=1.0,rnSpeed=1.0}
pcall(function()
    if isfile(settingsFile) then
        local d=HttpService:JSONDecode(readfile(settingsFile)) or {}
        savedSettings.ugcSpeed=d.ugcSpeed or 1.0; savedSettings.rnSpeed=d.rnSpeed or 1.0
    end
end)
local function saveSettings() pcall(function() writefile(settingsFile,HttpService:JSONEncode(savedSettings)) end) end

local activeTags={}
local tagTypeTasks={}
local acUnloaded = false  -- set true on unload to stop all poll loops

-- -- NAMETAG SYSTEM --------------------------------------------
local SPECIAL={
    ["MelodyCrafter3"]  ={tag="AC OWNER",   pfpId="113979242243283",bgId="97099238046338"},
    ["LostMelodyCrafter"]={tag="AC OWNER",  pfpId="113979242243283",bgId="97099238046338"},
    ["Exhalivibes"]     ={tag="TUFF E-CO OWNER",pfpId="102413476661872",bgId="97099238046338"},
    ["theunknownperson105"]={tag="Mommy Crave",pfpId="121891499478693",bgId="87400512362478"},
    ["yourscoperr"]     ={tag="AC ADMIN",   pfpId="113979242243283",bgId="97099238046338"},
    ["meowkixy"]        ={tag="BANANAPIE",  pfpId="87478905777374", bgId="90137674209548"},
    ["zxstyzac"]        ={tag="Unicorn Man",pfpId="85893436596300", bgId="116857939617030"},
    ["interw3b_0"]      ={tag="Skittles",   pfpId="117672713252370",bgId="",bgColor=Color3.fromRGB(255,105,180)},
    ["biscuit0onyx"]   ={tag="ADMIN BISCUIT",pfpId="",bgId="97099238046338"},
    ["lolfearfox"]      ={tag="fearfox",    pfpId="",              bgId="97099238046338"},
    ["flip1234416"]     ={tag="fearfox",    pfpId="",              bgId="97099238046338"},
}

local nameTagsEnabled = true

local function makeTag(plr, char)
    if not nameTagsEnabled then return end
    local head = char:FindFirstChild("Head"); if not head then return end
    -- Remove old tag
    local oldBB = head:FindFirstChild("AC_Tag"); if oldBB then oldBB:Destroy() end
    local info = SPECIAL[plr.Name]; local isSpecial = info ~= nil

    local bb = Instance.new("BillboardGui"); bb.Name="AC_Tag"
    bb.Enabled = true
    bb.Size = isSpecial and UDim2.new(0,220,0,68) or UDim2.new(0,170,0,52)
    bb.StudsOffset = Vector3.new(0,2.5,0)
    bb.AlwaysOnTop = true
    bb.Adornee = head
    bb.Parent = head
    activeTags[plr.UserId] = bb

    local tagStroke = nil

    if isSpecial then
        local bgColor = info.bgColor or C.purple

        -- Solid color base (fallback if bg image fails to load)
        local bgFrame = Instance.new("Frame")
        bgFrame.Size = UDim2.new(1,0,1,0)
        bgFrame.BackgroundColor3 = bgColor
        bgFrame.BackgroundTransparency = 0
        bgFrame.ZIndex = 1
        bgFrame.Parent = bb
        local bgC = Instance.new("UICorner"); bgC.CornerRadius = UDim.new(0.5,0); bgC.Parent = bgFrame
        local bgS = Instance.new("UIStroke"); bgS.ApplyStrokeMode = "Border"
        bgS.Color = Color3.fromRGB(255,255,255); bgS.Thickness = 3; bgS.Parent = bgFrame
        tagStroke = bgS

        -- Background image layer (bgId overlaid on top of solid color)
        if info.bgId and info.bgId ~= "" then
            local bgImg = Instance.new("ImageLabel")
            bgImg.Size = UDim2.new(1,0,1,0)
            bgImg.BackgroundTransparency = 1
            bgImg.Image = "rbxthumb:".._sl.."type=Asset&id=" .. info.bgId .. "&w=420&h=420"
            bgImg.ImageTransparency = 0
            bgImg.ScaleType = Enum.ScaleType.Stretch
            bgImg.ZIndex = 2
            bgImg.Parent = bgFrame
            local bgImgC = Instance.new("UICorner"); bgImgC.CornerRadius = UDim.new(0.5,0); bgImgC.Parent = bgImg
            -- fallback to direct asset id if rbxthumb doesn't load
            task.spawn(function()
                task.wait(1)
                if bgImg.Parent and (bgImg.IsLoaded == false or bgImg.Image == "") then
                    bgImg.Image = "rbxassetid:".._sl.."" .. info.bgId
                end
            end)
        end

        -- Profile picture -- use pfpId custom image asset directly
        local pfpImg = Instance.new("ImageLabel")
        pfpImg.Size = UDim2.new(0,54,0,54)
        pfpImg.Position = UDim2.new(0,4,0.5,-27)
        pfpImg.BackgroundColor3 = Color3.fromRGB(30,30,30)
        pfpImg.BackgroundTransparency = 0
        pfpImg.ZIndex = 5
        pfpImg.ScaleType = Enum.ScaleType.Crop
        pfpImg.Parent = bgFrame
        local pfpC = Instance.new("UICorner"); pfpC.CornerRadius = UDim.new(1,0); pfpC.Parent = pfpImg
        local pfpS = Instance.new("UIStroke"); pfpS.ApplyStrokeMode = "Border"
        pfpS.Color = Color3.fromRGB(255,255,255); pfpS.Thickness = 2; pfpS.Parent = pfpImg
        if info.pfpId and info.pfpId ~= "" then
            -- Try rbxthumb format first (works without game ownership), fallback to rbxassetid
            pfpImg.Image = "rbxthumb:".._sl.."type=Asset&id=" .. info.pfpId .. "&w=150&h=150"
            -- If rbxthumb fails to load, also try direct asset id
            task.spawn(function()
                task.wait(1)
                if pfpImg.Parent and (pfpImg.IsLoaded == false or pfpImg.Image == "") then
                    pfpImg.Image = "rbxassetid:".._sl.."" .. info.pfpId
                end
            end)
        else
            -- No pfpId set -- fall back to Roblox avatar headshot
            task.spawn(function()
                local ok, img = pcall(function()
                    return Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                end)
                if ok and img and pfpImg.Parent then pfpImg.Image = img end
            end)
        end

        -- Custom tag label
        local mainLbl = Instance.new("TextLabel")
        mainLbl.Size = UDim2.new(1,-68,0,24)
        mainLbl.Position = UDim2.new(0,64,0,8)
        mainLbl.BackgroundTransparency = 1
        mainLbl.Text = info.tag
        mainLbl.TextColor3 = Color3.fromRGB(255,255,255)
        mainLbl.TextSize = 14
        mainLbl.Font = Enum.Font.GothamBold
        mainLbl.TextXAlignment = Enum.TextXAlignment.Left
        mainLbl.ZIndex = 3
        mainLbl.Parent = bgFrame

        -- Username label
        local userLbl = Instance.new("TextLabel")
        userLbl.Size = UDim2.new(1,-68,0,14)
        userLbl.Position = UDim2.new(0,64,0,36)
        userLbl.BackgroundTransparency = 1
        userLbl.Text = "@"..plr.Name
        userLbl.TextColor3 = Color3.fromRGB(230,210,255)
        userLbl.TextSize = 10
        userLbl.Font = Enum.Font.GothamBold
        userLbl.TextXAlignment = Enum.TextXAlignment.Left
        userLbl.ZIndex = 3
        userLbl.Parent = bgFrame
    else
        -- Generic AC User tag
        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1,0,1,0)
        bg.BackgroundColor3 = Color3.fromRGB(12,12,16)
        bg.BackgroundTransparency = 0.25
        bg.ZIndex = 1
        bg.Parent = bb
        local bgC = Instance.new("UICorner"); bgC.CornerRadius = UDim.new(0.5,0); bgC.Parent = bg
        local bgS = Instance.new("UIStroke"); bgS.ApplyStrokeMode = "Border"
        bgS.Color = Color3.fromRGB(255,255,255); bgS.Thickness = 3; bgS.Parent = bg
        tagStroke = bgS

        local mainLbl = Instance.new("TextLabel")
        mainLbl.Size = UDim2.new(1,-10,0,22)
        mainLbl.Position = UDim2.new(0,5,0,4)
        mainLbl.BackgroundTransparency = 1
        mainLbl.Text = "AC User"
        mainLbl.TextColor3 = C.white
        mainLbl.TextSize = 13
        mainLbl.Font = Enum.Font.GothamBold
        mainLbl.TextXAlignment = Enum.TextXAlignment.Center
        mainLbl.ZIndex = 2
        mainLbl.Parent = bg

        local userLbl = Instance.new("TextLabel")
        userLbl.Size = UDim2.new(1,-10,0,14)
        userLbl.Position = UDim2.new(0,5,0,28)
        userLbl.BackgroundTransparency = 1
        userLbl.Text = "@"..plr.Name
        userLbl.TextColor3 = Color3.fromRGB(220,180,255)
        userLbl.TextSize = 9
        userLbl.Font = Enum.Font.Gotham
        userLbl.TextXAlignment = Enum.TextXAlignment.Center
        userLbl.ZIndex = 2
        userLbl.Parent = bg
    end

    -- Animated gradient glow on border
    if tagStroke then
        local tg = Instance.new("UIGradient")
        tg.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,    Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(0.25, Color3.fromRGB(120,0,110)),
            ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(0,0,0)),
            ColorSequenceKeypoint.new(0.75, Color3.fromRGB(120,0,110)),
            ColorSequenceKeypoint.new(1,    Color3.fromRGB(255,255,255)),
        })
        tg.Parent = tagStroke
        RunService.Heartbeat:Connect(function()
            if tagStroke.Parent then tg.Rotation = (tg.Rotation+1)%360 end
        end)
    end

    -- Click to teleport: 3 studs behind the target, facing their back
    if plr ~= lp then
        local clickBtn = Instance.new("TextButton")
        clickBtn.Size = UDim2.new(1, 0, 1, 0)
        clickBtn.BackgroundTransparency = 1
        clickBtn.Text = ""
        clickBtn.ZIndex = 20
        clickBtn.Parent = bb
        clickBtn.Activated:Connect(function()
            pcall(function()
                local targetChar = plr.Character
                if not targetChar then return end
                local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
                if not targetHRP then return end
                local myChar = lp.Character
                if not myChar then return end
                local myHRP = myChar:FindFirstChild("HumanoidRootPart")
                if not myHRP then return end
                -- 3 studs directly behind target (behind = negative LookVector)
                local behind = targetHRP.CFrame * CFrame.new(0, 0, 3)
                -- face the same direction as target so we look at their back
                myHRP.CFrame = CFrame.new(behind.Position, behind.Position + targetHRP.CFrame.LookVector)
            end)
        end)
    end
end

-- Poll for script users and create/update their tags
local myWatchVal = Instance.new("StringValue")
myWatchVal.Name = "AC_Watching_"..tostring(lp.UserId)
myWatchVal.Value = ""; myWatchVal.Parent = workspace
local myCmdVal = Instance.new("StringValue")
myCmdVal.Name = "AC_Cmd_"..tostring(lp.UserId)
myCmdVal.Value = ""; myCmdVal.Parent = workspace
local function setWatching(targetUserId)
    pcall(function() myWatchVal.Value = tostring(targetUserId or "") end)
end

-- Poll for AC script users AND special-listed users, tag only them
task.spawn(function()
    while not acUnloaded do
        task.wait(2)
        pcall(function()
            -- Build set of users running AC (have AC_Watching_ value in workspace)
            local scriptUsers={}
            for _,v in pairs(workspace:GetChildren()) do
                if v:IsA("StringValue") and v.Name:sub(1,12)=="AC_Watching_" then
                    local uid=tonumber(v.Name:sub(13)); if uid then scriptUsers[uid]=true end
                end
            end

            for _,plrObj in ipairs(Players:GetPlayers()) do
                if plrObj ~= lp then
                    -- Tag only if running AC script (SPECIAL cosmetics still require script execution)
                    local shouldTag = scriptUsers[plrObj.UserId]
                    if shouldTag then
                        local char=plrObj.Character
                        if char then
                            local head=char:FindFirstChild("Head")
                            local tag=activeTags[plrObj.UserId]
                            if nameTagsEnabled and head and (not tag or not tag.Parent or tag.Adornee~=head) then
                                makeTag(plrObj,char)
                            end
                        end
                    end
                end
            end

            -- Clean up tags for players who left or no longer qualify
            local currentPlayers={}
            for _,plrObj in ipairs(Players:GetPlayers()) do currentPlayers[plrObj.UserId]=true end
            for uid,tag in pairs(activeTags) do
                if not tag or not tag.Parent then
                    activeTags[uid]=nil
                elseif not currentPlayers[uid] then
                    pcall(function() tag:Destroy() end); activeTags[uid]=nil
                elseif uid ~= lp.UserId and not scriptUsers[uid] then
                    -- No longer running AC script — remove tag
                    pcall(function() tag:Destroy() end); activeTags[uid]=nil
                end
            end
        end)
    end
end)

-- Tag local player's own character; store connection so unload can kill it
local acSelfTagConn = nil
task.spawn(function()
    local function tagAndMarkSelf(char)
        if acUnloaded or not char then return end
        char:WaitForChild("HumanoidRootPart", 5)
        if acUnloaded then return end
        -- Mark as AC executor so others running the script can see our tag
        if not char:FindFirstChild("AC_Executor") then
            local marker=Instance.new("StringValue")
            marker.Name="AC_Executor"; marker.Value="1"; marker.Parent=char
        end
        -- Show our own tag above our own head
        task.wait(0.5)
        if not acUnloaded and nameTagsEnabled then pcall(function() makeTag(lp, char) end) end
    end
    tagAndMarkSelf(lp.Character)
    acSelfTagConn = lp.CharacterAdded:Connect(tagAndMarkSelf)
end)

-- -- SPECTATOR HUD ---------------------------------------------
-- Always visible in top-right, slightly below corner
local specHudGui = Instance.new("ScreenGui")
specHudGui.Name="AC_SpecHud"; specHudGui.ResetOnSpawn=false
specHudGui.DisplayOrder=998; specHudGui.IgnoreGuiInset=true
pcall(function() specHudGui.Parent=CoreGui end)

-- Anchor frame for positioning
local specAnchor = Instance.new("Frame")
specAnchor.Name="SpecAnchor"; specAnchor.Size=UDim2.new(0,220,0,36)
specAnchor.Position=UDim2.new(1,-234,0,116)
specAnchor.BackgroundTransparency=1; specAnchor.BorderSizePixel=0; specAnchor.ZIndex=10
specAnchor.Parent=specHudGui

-- Pulse dot (always visible, green when watchers, grey when none)
local specDot=Instance.new("Frame"); specDot.Name="SpecDot"
specDot.Size=UDim2.new(0,12,0,12); specDot.Position=UDim2.new(1,-14,0,12)
specDot.BackgroundColor3=Color3.fromRGB(60,60,70); specDot.BackgroundTransparency=0
specDot.BorderSizePixel=0; specDot.ZIndex=11; specDot.Parent=specAnchor
do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=specDot end

-- Count label
specAnchor.BackgroundColor3=Color3.fromRGB(6,6,8); specAnchor.BackgroundTransparency=0.15
specAnchor.BorderSizePixel=0
do local sac=Instance.new("UICorner"); sac.CornerRadius=UDim.new(0,10); sac.Parent=specAnchor end
do local sas=Instance.new("UIStroke"); sas.Thickness=2.5; sas.Color=accentColor
    local sag=Instance.new("UIGradient"); sag.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(0.25,accentColor),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(0,0,0)),ColorSequenceKeypoint.new(0.75,accentColor),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))}); sag.Parent=sas
    RunService.Heartbeat:Connect(function() if sag.Parent then sag.Rotation=(sag.Rotation+1)%360 end end)
    sas.Parent=specAnchor
end
local specCount=Instance.new("TextLabel"); specCount.Size=UDim2.new(1,-20,1,0)
specCount.Position=UDim2.new(0,10,0,0); specCount.BackgroundTransparency=1
specCount.Text="0 watching"; specCount.TextColor3=Color3.fromRGB(120,120,130)
specCount.TextSize=15; specCount.Font=Enum.Font.GothamBold
specCount.TextXAlignment=Enum.TextXAlignment.Left; specCount.ZIndex=11; specCount.Parent=specAnchor

-- Card container (below anchor)
local specCards=Instance.new("Frame"); specCards.Name="SpecCards"
specCards.Size=UDim2.new(0,220,0,0); specCards.Position=UDim2.new(1,-234,0,160)
specCards.BackgroundTransparency=1; specCards.BorderSizePixel=0; specCards.ZIndex=10
specCards.Parent=specHudGui
local specLayout=Instance.new("UIListLayout"); specLayout.SortOrder=Enum.SortOrder.LayoutOrder
specLayout.Padding=UDim.new(0,4); specLayout.Parent=specCards

-- Pulse tweens
local pulseTween1=TweenService:Create(specDot,TweenInfo.new(0.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Size=UDim2.new(0,18,0,18),BackgroundTransparency=0.2})
local pulseTween2=TweenService:Create(specDot,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{BackgroundTransparency=0.6})
pulseTween2:Play()

local watcherCards={}
local function makeWatcherCard(plrObj,order)
    local card=Instance.new("Frame"); card.Size=UDim2.new(1,0,0,46)
    card.BackgroundColor3=Color3.fromRGB(8,8,12); card.BackgroundTransparency=0.2
    card.BorderSizePixel=0; card.LayoutOrder=order; card.ZIndex=11; card.Parent=specCards
    do local cc=Instance.new("UICorner"); cc.CornerRadius=UDim.new(0,8); cc.Parent=card end
    do local cs=Instance.new("UIStroke"); cs.Thickness=2.5; cs.Color=accentColor
        local cg=Instance.new("UIGradient"); cg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(0.25,accentColor),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(0,0,0)),ColorSequenceKeypoint.new(0.75,accentColor),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))}); cg.Parent=cs
        RunService.Heartbeat:Connect(function() if cg.Parent then cg.Rotation=(cg.Rotation+1)%360 end end)
        cs.Parent=card
    end
    local pfp=Instance.new("ImageLabel"); pfp.Size=UDim2.new(0,32,0,32); pfp.Position=UDim2.new(0,6,0.5,-16)
    pfp.BackgroundColor3=Color3.fromRGB(20,20,20); pfp.BorderSizePixel=0; pfp.ZIndex=12; pfp.Parent=card
    do local pc=Instance.new("UICorner"); pc.CornerRadius=UDim.new(1,0); pc.Parent=pfp end
    pcall(function() pfp.Image=Players:GetUserThumbnailAsync(plrObj.UserId,Enum.ThumbnailType.AvatarBust,Enum.ThumbnailSize.Size48x48) end)
    local nameLbl=Instance.new("TextLabel"); nameLbl.Size=UDim2.new(1,-46,0,20); nameLbl.Position=UDim2.new(0,42,0,4)
    nameLbl.BackgroundTransparency=1; nameLbl.Text="@"..plrObj.Name; nameLbl.TextColor3=Color3.fromRGB(255,255,255)
    nameLbl.TextSize=11; nameLbl.Font=Enum.Font.GothamBold; nameLbl.TextXAlignment=Enum.TextXAlignment.Left; nameLbl.ZIndex=12; nameLbl.Parent=card
    local dispLbl=Instance.new("TextLabel"); dispLbl.Size=UDim2.new(1,-46,0,16); dispLbl.Position=UDim2.new(0,42,0,24)
    dispLbl.BackgroundTransparency=1; dispLbl.Text=plrObj.DisplayName; dispLbl.TextColor3=Color3.fromRGB(160,160,160)
    dispLbl.TextSize=10; dispLbl.Font=Enum.Font.Gotham; dispLbl.TextXAlignment=Enum.TextXAlignment.Left; dispLbl.ZIndex=12; dispLbl.Parent=card
    return card
end

-- Poll workspace for watchers (people viewing us)
local specPollConn1=RunService.Heartbeat:Connect(function()
    local myId=tostring(lp.UserId); local watching={}
    pcall(function()
        for _,v in pairs(workspace:GetChildren()) do
            if v:IsA("StringValue") and v.Name:sub(1,12)=="AC_Watching_" then
                local wId=v.Name:sub(13)
                if v.Value==myId and wId~=myId then watching[wId]=true end
            end
        end
    end)
    for wId in pairs(watching) do
        if not watcherCards[wId] then
            local po=Players:GetPlayerByUserId(tonumber(wId))
            if po then watcherCards[wId]=makeWatcherCard(po,tonumber(wId)) end
        end
    end
    for wId,card in pairs(watcherCards) do
        if not watching[wId] then pcall(function() card:Destroy() end); watcherCards[wId]=nil end
    end
    local count=0; for _ in pairs(watcherCards) do count=count+1 end
    specCards.Size=UDim2.new(0,220,0,count*50)
    if count>0 then
        specDot.BackgroundColor3=Color3.fromRGB(0,220,80); pulseTween1:Play(); pulseTween2:Cancel()
        specCount.Text=tostring(count).." watching "; specCount.TextColor3=Color3.fromRGB(0,220,80)
    else
        pulseTween1:Cancel(); pulseTween2:Play()
        specDot.BackgroundColor3=Color3.fromRGB(60,60,70)
        specCount.Text="0 watching"; specCount.TextColor3=Color3.fromRGB(80,80,90)
    end
end)


-- -- STATS HUD --------------------------------------------------
-- FPS | Script Users | Ping -- draggable, accent-colored
local statsGui=Instance.new("ScreenGui"); statsGui.Name="AC_StatsHud"
statsGui.ResetOnSpawn=false; statsGui.DisplayOrder=997; statsGui.IgnoreGuiInset=true
pcall(function() statsGui.Parent=CoreGui end)

local statsFrame=Instance.new("Frame"); statsFrame.Name="StatsFrame"
statsFrame.Size=UDim2.new(0,256,0,48); statsFrame.Position=UDim2.new(1,-266,0,60)
statsFrame.BackgroundColor3=Color3.fromRGB(6,6,8); statsFrame.BackgroundTransparency=0.15
statsFrame.BorderSizePixel=0; statsFrame.ZIndex=10; statsFrame.Parent=statsGui
do local sc=Instance.new("UICorner"); sc.CornerRadius=UDim.new(0,10); sc.Parent=statsFrame end
do local ss=Instance.new("UIStroke"); ss.Thickness=2.5; ss.Color=accentColor
    local sg=Instance.new("UIGradient")
    sg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(0.25,accentColor),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(0,0,0)),ColorSequenceKeypoint.new(0.75,accentColor),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))})
    sg.Parent=ss; ss.Parent=statsFrame
    RunService.Heartbeat:Connect(function() if sg.Parent then sg.Rotation=(sg.Rotation+1)%360 end end)
end

-- Three stat cells: FPS | Users | Ping
local function mkStatCell(icon, xPos, w)
    local cell=Instance.new("Frame"); cell.Size=UDim2.new(0,w,1,-6); cell.Position=UDim2.new(0,xPos,0,3)
    cell.BackgroundTransparency=1; cell.BorderSizePixel=0; cell.ZIndex=11; cell.Parent=statsFrame
    local ico=Instance.new("TextLabel"); ico.Size=UDim2.new(0,38,1,0); ico.Position=UDim2.new(0,6,0,0)
    ico.BackgroundTransparency=1; ico.Text=icon; ico.TextSize=13; ico.Font=Enum.Font.GothamBold
    ico.TextColor3=accentColor; ico.ZIndex=12; ico.Parent=cell
    local val=Instance.new("TextLabel"); val.Size=UDim2.new(1,-46,1,0); val.Position=UDim2.new(0,44,0,0)
    val.BackgroundTransparency=1; val.Text="--"; val.TextSize=15; val.Font=Enum.Font.GothamBold
    val.TextColor3=Color3.fromRGB(220,220,220); val.TextXAlignment=Enum.TextXAlignment.Left; val.ZIndex=12; val.Parent=cell
    -- Divider line (except last)
    return val, ico
end

local div1=Instance.new("Frame"); div1.Size=UDim2.new(0,1,0,22); div1.Position=UDim2.new(0,85,0.5,-11)
div1.BackgroundColor3=accentColor; div1.BackgroundTransparency=0.3; div1.BorderSizePixel=0; div1.ZIndex=11; div1.Parent=statsFrame
local div2=Instance.new("Frame"); div2.Size=UDim2.new(0,1,0,22); div2.Position=UDim2.new(0,170,0.5,-11)
div2.BackgroundColor3=accentColor; div2.BackgroundTransparency=0.3; div2.BorderSizePixel=0; div2.ZIndex=11; div2.Parent=statsFrame

local fpsVal, fpsIco   = mkStatCell("FPS", 4, 80)
local usrVal, usrIco   = mkStatCell("USR", 88, 80)
local msVal,  msIco    = mkStatCell("MS",  172, 80)

-- Draggable
do
    local drag=false; local dragStart; local startPos
    statsFrame.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=true; dragStart=i.Position; startPos=statsFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-dragStart
            statsFrame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
    end)
end

-- Real-time update loop
local fpsHistory={}; local lastTime=tick()
RunService.Heartbeat:Connect(function()
    local now=tick(); local dt=now-lastTime; lastTime=now
    table.insert(fpsHistory,dt); if #fpsHistory>20 then table.remove(fpsHistory,1) end
    local avg=0; for _,t in ipairs(fpsHistory) do avg=avg+t end
    avg=avg/#fpsHistory
    local fps=math.floor(1/avg+0.5)
    fpsVal.Text=tostring(fps)
    fpsIco.TextColor3=fps>=50 and Color3.fromRGB(0,220,80) or fps>=30 and Color3.fromRGB(255,180,0) or Color3.fromRGB(220,60,60)
end)

-- Script users count (from AC_Watching_ values)
RunService.Heartbeat:Connect(function()
    local count=0
    pcall(function()
        for _,v in pairs(workspace:GetChildren()) do
            if v:IsA("StringValue") and v.Name:sub(1,12)=="AC_Watching_" then count=count+1 end
        end
    end)
    usrVal.Text=tostring(count)
    usrIco.TextColor3=count>1 and accentColor or Color3.fromRGB(100,100,110)
end)

-- Ping (ms) via stats service
local statsService=pcall(function() return game:GetService("Stats") end) and game:GetService("Stats")
RunService.Heartbeat:Connect(function()
    pcall(function()
        local ping=math.floor(statsService.Network.ServerStatsItem["Data Ping"]:GetValue())
        msVal.Text=tostring(ping)
        msIco.TextColor3=ping<100 and Color3.fromRGB(0,220,80) or ping<200 and Color3.fromRGB(255,180,0) or Color3.fromRGB(220,60,60)
    end)
end)

-- Hook: update accent color on all HUD elements when changed
local function updateHudAccent(col)
    accentColor=col
    pcall(function()
        local ss=statsFrame:FindFirstChildOfClass("UIStroke"); if ss then ss.Color=col end
        div1.BackgroundColor3=col; div2.BackgroundColor3=col
        fpsIco.TextColor3=col; usrIco.TextColor3=col; msIco.TextColor3=col
        for _,card in pairs(watcherCards) do
            local cs=card:FindFirstChildOfClass("UIStroke"); if cs then cs.Color=col end
        end
    end)
end


local ARCH_KFS={
{t=0.000,d={["Head"]=CFrame.new(-0.003107, 0.068928, 0.157247, 0.999864, 0.006038, -0.015367, -0.005978, 0.999974, 0.003996, 0.015391, -0.003903, 0.999874),["LeftFoot"]=CFrame.new(-0.000000, -0.142633, -0.000003, 0.987914, -0.118565, -0.099835, 0.142833, 0.946545, 0.289256, 0.060204, -0.299993, 0.952031),["LeftHand"]=CFrame.new(0.000500, 0.000100, -0.000000, 0.998674, 0.033727, 0.038897, -0.034986, 0.998870, 0.032161, -0.037768, -0.033478, 0.998726),["LeftLowerArm"]=CFrame.new(0.005666, -0.027820, 0.010667, 1.000000, -0.000000, -0.000000, 0.000000, 0.998699, -0.050997, 0.000000, 0.050996, 0.998699),["LeftLowerLeg"]=CFrame.new(-0.000000, -0.141746, -0.001778, 1.000000, 0.000000, 0.000000, -0.000000, 1.000000, -0.000007, 0.000000, -0.000010, 1.000000),["LeftUpperArm"]=CFrame.new(0.033615, 0.291015, -0.014617, 0.881603, -0.440807, -0.168714, 0.465370, 0.752146, 0.466591, -0.078779, -0.489863, 0.868233),["LeftUpperLeg"]=CFrame.new(-0.000723, -0.097399, -0.061041, 0.979360, 0.186024, 0.079032, 0.098524, -0.097949, -0.990304, -0.176484, 0.977651, -0.114249),["LowerTorso"]=CFrame.new(-0.101855, 0.262032, 0.676735, 0.999442, 0.014561, -0.030047, 0.026585, 0.197441, 0.979954, 0.020202, -0.980207, 0.196944),["RightFoot"]=CFrame.new(-0.000000, -0.131390, -0.000100, 0.989274, 0.111752, 0.094100, -0.136139, 0.938836, 0.316332, -0.052954, -0.325727, 0.943970),["RightHand"]=CFrame.new(-0.000500, 0.000000, -0.000000, 0.999992, -0.003397, 0.002252, 0.003462, 0.999559, -0.029487, -0.002151, 0.029495, 0.999563),["RightLowerArm"]=CFrame.new(-0.011635, -0.043157, -0.003740, 1.000000, 0.000000, 0.000000, -0.000000, 0.999905, 0.013814, -0.000000, -0.013814, 0.999905),["RightLowerLeg"]=CFrame.new(-0.000000, -0.130538, -0.001687, 1.000000, -0.000000, -0.000000, 0.000000, 1.000000, -0.000001, 0.000000, -0.000005, 1.000000),["RightUpperArm"]=CFrame.new(-0.310806, -3.885396, 1.212890, -0.994719, 0.102592, -0.003102, -0.088838, -0.845436, 0.526636, 0.051406, 0.524130, 0.850085),["RightUpperLeg"]=CFrame.new(-0.016717, -0.066244, -0.093048, 0.996367, -0.084172, -0.013037, -0.019976, -0.082584, -0.996384, 0.082790, 0.993023, -0.083961),["UpperTorso"]=CFrame.new(-0.028552, 0.025395, -0.028906, 0.999058, 0.006402, 0.042925, -0.002019, 0.994846, -0.101379, -0.043352, 0.101197, 0.993921)}},
{t=0.050,d={["Head"]=CFrame.new(-0.003107, 0.068928, 0.157247, 0.999867, 0.005916, -0.015178, -0.006017, 0.999960, -0.006573, 0.015139, 0.006664, 0.999863),["LeftFoot"]=CFrame.new(0.000000, -0.140565, -0.000003, 0.987781, -0.119210, -0.100378, 0.143203, 0.948430, 0.282824, 0.061488, -0.293716, 0.953905),["LeftHand"]=CFrame.new(0.000500, 0.000100, 0.000000, 0.998674, 0.033726, 0.038897, -0.034986, 0.998870, 0.032161, -0.037768, -0.033478, 0.998726),["LeftLowerArm"]=CFrame.new(0.005666, -0.027820, 0.010667, 1.000000, -0.000000, -0.000000, 0.000000, 0.998699, -0.050997, 0.000000, 0.050996, 0.998699),["LeftLowerLeg"]=CFrame.new(-0.000000, -0.139684, -0.001751, 1.000000, 0.000000, -0.000000, -0.000000, 1.000000, -0.000007, -0.000000, -0.000010, 1.000000),["LeftUpperArm"]=CFrame.new(0.035859, 0.291107, -0.014607, 0.886215, -0.432194, -0.166826, 0.456980, 0.756375, 0.468045, -0.076103, -0.491025, 0.867815),["LeftUpperLeg"]=CFrame.new(-0.000723, -0.097399, -0.061041, 0.979187, 0.186261, 0.080600, 0.098929, -0.091268, -0.990901, -0.177215, 0.978252, -0.107789),["LowerTorso"]=CFrame.new(-0.101855, 0.262032, 0.662467, 0.999442, 0.014561, -0.030047, 0.026585, 0.197441, 0.979954, 0.020202, -0.980207, 0.196944),["RightFoot"]=CFrame.new(0.000000, -0.129448, -0.000100, 0.989211, 0.112076, 0.094374, -0.136169, 0.940989, 0.309856, -0.054037, -0.319342, 0.946088),["RightHand"]=CFrame.new(-0.000500, 0.000000, -0.000000, 0.999992, -0.003397, 0.002252, 0.003462, 0.999559, -0.029487, -0.002151, 0.029495, 0.999563),["RightLowerArm"]=CFrame.new(-0.011635, -0.043157, -0.003740, 1.000000, 0.000000, 0.000000, -0.000000, 0.999905, 0.013814, -0.000000, -0.013814, 0.999905),["RightLowerLeg"]=CFrame.new(-0.000000, -0.128603, -0.001661, 1.000000, -0.000000, -0.000000, 0.000000, 1.000000, -0.000002, 0.000000, -0.000005, 1.000000),["RightUpperArm"]=CFrame.new(-0.311915, -3.827722, 1.193507, -0.994719, 0.102592, -0.003102, -0.088838, -0.845436, 0.526636, 0.051406, 0.524130, 0.850085),["RightUpperLeg"]=CFrame.new(-0.016717, -0.066244, -0.093048, 0.996331, -0.084478, -0.013768, -0.020164, -0.075786, -0.996920, 0.083174, 0.993539, -0.077207),["UpperTorso"]=CFrame.new(-0.028263, 0.011410, -0.026096, 0.999058, 0.006402, 0.042925, -0.002019, 0.994846, -0.101379, -0.043352, 0.101197, 0.993921)}},
{t=0.100,d={["Head"]=CFrame.new(-0.003107, 0.068928, 0.157247, 0.999877, 0.005581, -0.014636, -0.006113, 0.999313, -0.036551, 0.014422, 0.036636, 0.999225),["LeftFoot"]=CFrame.new(0.000000, -0.135756, -0.000003, 0.987453, -0.120789, -0.101708, 0.144074, 0.952826, 0.267170, 0.064640, -0.278445, 0.958267),["LeftHand"]=CFrame.new(0.000500, 0.000100, -0.000000, 0.998674, 0.033727, 0.038897, -0.034986, 0.998870, 0.032161, -0.037768, -0.033478, 0.998726),["LeftLowerArm"]=CFrame.new(0.005666, -0.027820, 0.010666, 1.000000, -0.000000, -0.000000, 0.000000, 0.998699, -0.050997, 0.000000, 0.050996, 0.998699),["LeftLowerLeg"]=CFrame.new(-0.000000, -0.134892, -0.001688, 1.000000, -0.000000, 0.000000, -0.000000, 1.000000, -0.000007, 0.000000, -0.000010, 1.000000),["LeftUpperArm"]=CFrame.new(0.041749, 0.290548, -0.014333, 0.898306, -0.408564, -0.161621, 0.433955, 0.767456, 0.471906, -0.068766, -0.494052, 0.866709),["LeftUpperLeg"]=CFrame.new(-0.000723, -0.097399, -0.061041, 0.978761, 0.186801, 0.084439, 0.099921, -0.075044, -0.992162, -0.179005, 0.979527, -0.092109),["LowerTorso"]=CFrame.new(-0.101855, 0.262032, 0.628092, 0.999442, 0.014561, -0.030047, 0.026585, 0.197441, 0.979954, 0.020202, -0.980207, 0.196944),["RightFoot"]=CFrame.new(-0.000000, -0.124962, -0.000100, 0.989057, 0.112870, 0.095042, -0.136215, 0.946027, 0.294093, -0.056678, -0.303799, 0.951040),["RightHand"]=CFrame.new(-0.000500, 0.000000, -0.000000, 0.999992, -0.003397, 0.002252, 0.003462, 0.999559, -0.029487, -0.002151, 0.029495, 0.999563),["RightLowerArm"]=CFrame.new(-0.011635, -0.043157, -0.003740, 1.000000, 0.000000, 0.000000, -0.000000, 0.999905, 0.013814, -0.000000, -0.013814, 0.999905),["RightLowerLeg"]=CFrame.new(-0.000000, -0.124132, -0.001602, 1.000000, -0.000000, -0.000000, 0.000000, 1.000000, -0.000002, 0.000000, -0.000005, 1.000000),["RightUpperArm"]=CFrame.new(-0.314335, -3.683782, 1.146958, -0.994719, 0.102592, -0.003102, -0.088838, -0.845436, 0.526636, 0.051406, 0.524130, 0.850085),["RightUpperLeg"]=CFrame.new(-0.016717, -0.066244, -0.093048, 0.996243, -0.085204, -0.015564, -0.020624, -0.059288, -0.998028, 0.084112, 0.994598, -0.060818),["UpperTorso"]=CFrame.new(-0.027569, -0.022285, -0.019326, 0.999058, 0.006402, 0.042925, -0.002019, 0.994846, -0.101379, -0.043352, 0.101197, 0.993921)}},
{t=0.150,d={["Head"]=CFrame.new(-0.003107, 0.068928, 0.157247, 0.999892, 0.005091, -0.013769, -0.006221, 0.996504, -0.083318, 0.013296, 0.083395, 0.996428),["LeftFoot"]=CFrame.new(0.000000, -0.130273, -0.000003, 0.987037, -0.122762, -0.103370, 0.145093, 0.957886, 0.247822, 0.068594, -0.259583, 0.963275),["LeftHand"]=CFrame.new(0.000500, 0.000100, 0.000000, 0.998674, 0.033727, 0.038897, -0.034986, 0.998870, 0.032161, -0.037768, -0.033478, 0.998726),["LeftLowerArm"]=CFrame.new(0.005666, -0.027820, 0.010667, 1.000000, -0.000000, -0.000000, 0.000000, 0.998699, -0.050997, 0.000000, 0.050996, 0.998699),["LeftLowerLeg"]=CFrame.new(-0.000000, -0.129427, -0.001615, 1.000000, 0.000000, 0.000000, -0.000000, 1.000000, -0.000006, 0.000000, -0.000010, 1.000000),["LeftUpperArm"]=CFrame.new(0.049865, 0.288028, -0.013414, 0.914960, -0.373113, -0.153739, 0.399388, 0.782699, 0.477360, -0.057777, -0.498167, 0.865154),["LeftUpperLeg"]=CFrame.new(-0.000723, -0.097399, -0.061041, 0.978222, 0.187396, 0.089229, 0.101161, -0.055066, -0.993346, -0.181241, 0.980740, -0.072817),["LowerTorso"]=CFrame.new(-0.101855, 0.262032, 0.586254, 0.999442, 0.014561, -0.030047, 0.026585, 0.197441, 0.979954, 0.020202, -0.980207, 0.196944),["RightFoot"]=CFrame.new(0.000000, -0.119860, -0.000100, 0.988863, 0.113861, 0.095876, -0.136221, 0.951863, 0.274609, -0.059953, -0.284591, 0.956764),["RightHand"]=CFrame.new(-0.000500, 0.000000, -0.000000, 0.999992, -0.003397, 0.002252, 0.003462, 0.999559, -0.029487, -0.002151, 0.029495, 0.999563),["RightLowerArm"]=CFrame.new(-0.011635, -0.043158, -0.003740, 1.000000, 0.000000, 0.000000, -0.000000, 0.999905, 0.013814, -0.000000, -0.013814, 0.999905),["RightLowerLeg"]=CFrame.new(-0.000000, -0.119048, -0.001535, 1.000000, -0.000000, -0.000000, 0.000000, 1.000000, -0.000002, 0.000000, -0.000005, 1.000000),["RightUpperArm"]=CFrame.new(-0.316711, -3.497203, 1.090646, -0.994719, 0.102592, -0.003102, -0.088838, -0.845436, 0.526636, 0.051406, 0.524130, 0.850085),["RightUpperLeg"]=CFrame.new(-0.016717, -0.066244, -0.093048, 0.996131, -0.086065, -0.017816, -0.021198, -0.038989, -0.999014, 0.085283, 0.995526, -0.040657),["UpperTorso"]=CFrame.new(-0.026724, -0.063295, -0.011086, 0.999058, 0.006402, 0.042925, -0.002019, 0.994846, -0.101379, -0.043352, 0.101197, 0.993921)}},
{t=0.200,d={["Head"]=CFrame.new(-0.003107, 0.068928, 0.157247, 0.999910, 0.004512, -0.012603, -0.006282, 0.989542, -0.144111, 0.011821, 0.144177, 0.989481),["LeftFoot"]=CFrame.new(-0.000000, -0.125753, -0.000003, 0.986651, -0.124566, -0.104889, 0.145958, 0.962105, 0.230354, 0.072221, -0.242564, 0.967438),["LeftHand"]=CFrame.new(0.000500, 0.000100, 0.000000, 0.998674, 0.033727, 0.038897, -0.034986, 0.998870, 0.032161, -0.037768, -0.033478, 0.998726),["LeftLowerArm"]=CFrame.new(0.005666, -0.027820, 0.010667, 1.000000, -0.000000, -0.000000, 0.000000, 0.998699, -0.050997, 0.000000, 0.050996, 0.998699),["LeftLowerLeg"]=CFrame.new(-0.000000, -0.124921, -0.001555, 1.000000, -0.000000, 0.000000, -0.000000, 1.000000, -0.000006, 0.000000, -0.000010, 1.000000),["LeftUpperArm"]=CFrame.new(0.058786, 0.282299, -0.011487, 0.933251, -0.329165, -0.143851, 0.356497, 0.799409, 0.483586, -0.044183, -0.502590, 0.863395),["LeftUpperLeg"]=CFrame.new(-0.000723, -0.097399, -0.061041, 0.977723, 0.187867, 0.093598, 0.102294, -0.037097, -0.994063, -0.183285, 0.981494, -0.055482),["LowerTorso"]=CFrame.new(-0.101855, 0.262032, 0.549038, 0.999442, 0.014561, -0.030047, 0.026585, 0.197441, 0.979954, 0.020202, -0.980207, 0.196944),["RightFoot"]=CFrame.new(0.000000, -0.115686, -0.000100, 0.988684, 0.114765, 0.096638, -0.136178, 0.956769, 0.257017, -0.062923, -0.267250, 0.961563),["RightHand"]=CFrame.new(-0.000500, 0.000000, -0.000000, 0.999992, -0.003397, 0.002252, 0.003462, 0.999559, -0.029487, -0.002151, 0.029495, 0.999563),["RightLowerArm"]=CFrame.new(-0.011635, -0.043157, -0.003740, 1.000000, 0.000000, 0.000000, -0.000000, 0.999905, 0.013814, -0.000000, -0.013814, 0.999905),["RightLowerLeg"]=CFrame.new(-0.000000, -0.114888, -0.001479, 1.000000, -0.000000, -0.000000, 0.000000, 1.000000, -0.000002, 0.000000, -0.000005, 1.000000),["RightUpperArm"]=CFrame.new(-0.317854, -3.309828, 1.040656, -0.994719, 0.102592, -0.003102, -0.088838, -0.845436, 0.526636, 0.051406, 0.524130, 0.850085),["RightUpperLeg"]=CFrame.new(-0.016717, -0.066244, -0.093048, 0.996028, -0.086807, -0.019882, -0.021723, -0.020748, -0.999548, 0.086352, 0.996009, -0.022546),["UpperTorso"]=CFrame.new(-0.025972, -0.099774, -0.003757, 0.999058, 0.006402, 0.042925, -0.002019, 0.994846, -0.101379, -0.043352, 0.101197, 0.993921)}},
{t=0.250,d={["Head"]=CFrame.new(-0.003107, 0.068928, 0.157247, 0.999930, 0.003917, -0.011170, -0.006237, 0.976392, -0.215918, 0.010061, 0.215972, 0.976348),["LeftFoot"]=CFrame.new(0.000000, -0.122680, -0.000003, 0.986361, -0.125903, -0.106015, 0.146560, 0.964990, 0.217546, 0.074914, -0.230093, 0.970275),["LeftHand"]=CFrame.new(0.000500, 0.000100, 0.000000, 0.998674, 0.033727, 0.038897, -0.034986, 0.998870, 0.032161, -0.037768, -0.033478, 0.998726),["LeftLowerArm"]=CFrame.new(0.005666, -0.027820, 0.010667, 1.000000, -0.000000, -0.000000, 0.000000, 0.998699, -0.050997, 0.000000, 0.050996, 0.998699),["LeftLowerLeg"]=CFrame.new(-0.000000, -0.121859, -0.001515, 1.000000, 0.000000, 0.000000, 0.000000, 1.000000, -0.000006, 0.000000, -0.000010, 1.000000),["LeftUpperArm"]=CFrame.new(0.067297, 0.272283, -0.008240, 0.950667, -0.280383, -0.132733, 0.308843, 0.815274, 0.489841, -0.029129, -0.506669, 0.861648),["LeftUpperLeg"]=CFrame.new(-0.000723, -0.097399, -0.061041, 0.977350, 0.188173, 0.096830, 0.103134, -0.023963, -0.994379, -0.184800, 0.981844, -0.042821),["LowerTorso"]=CFrame.new(-0.101855, 0.262032, 0.522060, 0.999442, 0.014561, -0.030047, 0.026585, 0.197441, 0.979954, 0.020202, -0.980207, 0.196944),["RightFoot"]=CFrame.new(-0.000000, -0.112852, -0.000100, 0.988551, 0.115435, 0.097202, -0.136118, 0.960149, 0.244120, -0.065108, -0.254538, 0.964861),["RightHand"]=CFrame.new(-0.000500, 0.000000, -0.000000, 0.999992, -0.003397, 0.002252, 0.003462, 0.999559, -0.029487, -0.002151, 0.029495, 0.999563),["RightLowerArm"]=CFrame.new(-0.011635, -0.043158, -0.003740, 1.000000, 0.000000, 0.000000, -0.000000, 0.999905, 0.013814, -0.000000, -0.013814, 0.999905),["RightLowerLeg"]=CFrame.new(-0.000000, -0.112064, -0.001442, 1.000000, -0.000000, -0.000000, 0.000000, 1.000000, -0.000002, 0.000000, -0.000005, 1.000000),["RightUpperArm"]=CFrame.new(-0.318562, -3.142798, 0.997738, -0.994719, 0.102592, -0.003102, -0.088838, -0.845436, 0.526636, 0.051406, 0.524130, 0.850085),["RightUpperLeg"]=CFrame.new(-0.016717, -0.066244, -0.093048, 0.995950, -0.087330, -0.021416, -0.022111, -0.007426, -0.999727, 0.087144, 0.996152, -0.009321),["UpperTorso"]=CFrame.new(-0.025427, -0.126218, 0.001557, 0.999058, 0.006402, 0.042925, -0.002019, 0.994846, -0.101379, -0.043352, 0.101197, 0.993921)}},
{t=0.300,d={["Head"]=CFrame.new(-0.003107, 0.068928, 0.157247, 0.999949, 0.003373, -0.009507, -0.006032, 0.955338, -0.295455, 0.008086, 0.295497, 0.955309),["LeftFoot"]=CFrame.new(0.000000, -0.120999, -0.000003, 0.986193, -0.126673, -0.106663, 0.146891, 0.966559, 0.210231, 0.076466, -0.222973, 0.971816),["LeftHand"]=CFrame.new(0.000500, 0.000100, 0.000000, 0.998674, 0.033727, 0.038897, -0.034986, 0.998870, 0.032161, -0.037768, -0.033478, 0.998726),["LeftLowerArm"]=CFrame.new(0.005666, -0.027820, 0.010666, 1.000000, -0.000000, -0.000000, 0.000000, 0.998699, -0.050997, 0.000000, 0.050996, 0.998699),["LeftLowerLeg"]=CFrame.new(-0.000000, -0.120183, -0.001492, 1.000000, -0.000000, 0.000000, -0.000000, 1.000000, -0.000006, 0.000000, -0.000010, 1.000000),["LeftUpperArm"]=CFrame.new(0.074540, 0.257091, -0.003412, 0.965412, -0.230803, -0.121286, 0.260362, 0.828653, 0.495526, -0.013865, -0.509965, 0.860084),["LeftUpperLeg"]=CFrame.new(-0.000723, -0.097399, -0.061041, 0.977133, 0.188332, 0.098686, 0.103618, -0.016477, -0.994481, -0.185672, 0.981967, -0.035608),["LowerTorso"]=CFrame.new(-0.101855, 0.262032, 0.506760, 0.999442, 0.014561, -0.030047, 0.026585, 0.197441, 0.979954, 0.020202, -0.980207, 0.196944),["RightFoot"]=CFrame.new(-0.000000, -0.111333, -0.000100, 0.988474, 0.115820, 0.097526, -0.136073, 0.961998, 0.236753, -0.066359, -0.247277, 0.966663),["RightHand"]=CFrame.new(-0.000500, 0.000000, -0.000000, 0.999992, -0.003397, 0.002252, 0.003462, 0.999559, -0.029487, -0.002151, 0.029495, 0.999563),["RightLowerArm"]=CFrame.new(-0.011635, -0.043157, -0.003739, 1.000000, 0.000000, 0.000000, -0.000000, 0.999905, 0.013814, -0.000000, -0.013814, 0.999905),["RightLowerLeg"]=CFrame.new(-0.000000, -0.110551, -0.001422, 1.000000, -0.000000, -0.000000, 0.000000, 1.000000, -0.000002, 0.000000, -0.000005, 1.000000),["RightUpperArm"]=CFrame.new(-0.320911, -3.003898, 0.952751, -0.994719, 0.102592, -0.003102, -0.088838, -0.845436, 0.526636, 0.051406, 0.524130, 0.850085),["RightUpperLeg"]=CFrame.new(-0.016717, -0.066244, -0.093048, 0.995905, -0.087621, -0.022300, -0.022334, 0.000163, -0.999750, 0.087600, 0.996154, -0.001788),["UpperTorso"]=CFrame.new(-0.025118, -0.141215, 0.004570, 0.999058, 0.006402, 0.042925, -0.002019, 0.994846, -0.101379, -0.043352, 0.101197, 0.993921)}},
{t=0.350,d={["Head"]=CFrame.new(-0.003107, 0.068928, 0.157247, 0.999966, 0.002941, -0.007664, -0.005628, 0.925274, -0.379257, 0.005976, 0.379288, 0.925260),["LeftFoot"]=CFrame.new(0.000000, -0.120675, -0.000003, 0.986159, -0.126826, -0.106792, 0.146956, 0.966865, 0.208775, 0.076776, -0.221557, 0.972115),["LeftHand"]=CFrame.new(0.000500, 0.000100, 0.000000, 0.998674, 0.033727, 0.038897, -0.034986, 0.998870, 0.032161, -0.037768, -0.033478, 0.998726),["LeftLowerArm"]=CFrame.new(0.005666, -0.027820, 0.010666, 1.000000, -0.000000, -0.000000, 0.000000, 0.998699, -0.050997, 0.000000, 0.050996, 0.998699),["LeftLowerLeg"]=CFrame.new(-0.000000, -0.119861, -0.001488, 1.000000, -0.000000, 0.000000, -0.000000, 1.000000, -0.000006, 0.000000, -0.000010, 1.000000),["LeftUpperArm"]=CFrame.new(0.080085, 0.236514, 0.003054, 0.976557, -0.184720, -0.110521, 0.215259, 0.838711, 0.500228, 0.000293, -0.512292, 0.858811),["LeftUpperLeg"]=CFrame.new(-0.000723, -0.097399, -0.061041, 0.977090, 0.188363, 0.099057, 0.103714, -0.014989, -0.994495, -0.185846, 0.981985, -0.034174),["LowerTorso"]=CFrame.new(-0.101855, 0.262032, 0.503725, 0.999442, 0.014561, -0.030047, 0.026585, 0.197441, 0.979954, 0.020202, -0.980207, 0.196944),["RightFoot"]=CFrame.new(0.000000, -0.111038, -0.000100, 0.988459, 0.115897, 0.097591, -0.136063, 0.962359, 0.235287, -0.066608, -0.245833, 0.967014),["RightHand"]=CFrame.new(-0.000500, 0.000000, 0.000000, 0.999992, -0.003397, 0.002252, 0.003462, 0.999559, -0.029487, -0.002151, 0.029495, 0.999563),["RightLowerArm"]=CFrame.new(-0.011635, -0.043157, -0.003739, 1.000000, 0.000000, 0.000000, -0.000000, 0.999905, 0.013814, -0.000000, -0.013814, 0.999905),["RightLowerLeg"]=CFrame.new(-0.000000, -0.110257, -0.001418, 1.000000, -0.000000, -0.000000, 0.000000, 1.000000, -0.000002, 0.000000, -0.000005, 1.000000),["RightUpperArm"]=CFrame.new(-0.326426, -2.899615, 0.897087, -0.994719, 0.102592, -0.003102, -0.088838, -0.845436, 0.526636, 0.051406, 0.524130, 0.850085),["RightUpperLeg"]=CFrame.new(-0.016717, -0.066244, -0.093048, 0.995896, -0.087678, -0.022477, -0.022379, 0.001671, -0.999747, 0.087691, 0.996147, -0.000291),["UpperTorso"]=CFrame.new(-0.025057, -0.144190, 0.005167, 0.999058, 0.006402, 0.042925, -0.002019, 0.994846, -0.101379, -0.043352, 0.101197, 0.993921)}},
{t=0.400,d={["Head"]=CFrame.new(-0.003107, 0.068928, 0.157247, 0.999980, 0.002666, -0.005699, -0.005005, 0.885890, -0.463868, 0.003812, 0.463887, 0.885886),["LeftFoot"]=CFrame.new(0.000000, -0.120675, -0.000003, 0.986159, -0.126826, -0.106792, 0.146956, 0.966865, 0.208775, 0.076776, -0.221557, 0.972115),["LeftHand"]=CFrame.new(0.000500, 0.000100, 0.000000, 0.998674, 0.033727, 0.038897, -0.034986, 0.998870, 0.032161, -0.037768, -0.033478, 0.998726),["LeftLowerArm"]=CFrame.new(0.005666, -0.027820, 0.010667, 1.000000, -0.000000, -0.000000, 0.000000, 0.998699, -0.050997, 0.000000, 0.050996, 0.998699),["LeftLowerLeg"]=CFrame.new(-0.000000, -0.119861, -0.001488, 1.000000, -0.000000, 0.000000, -0.000000, 1.000000, -0.000006, 0.000000, -0.000010, 1.000000),["LeftUpperArm"]=CFrame.new(0.083800, 0.217803, 0.008912, 0.983987, -0.146513, -0.101505, 0.177835, 0.845367, 0.503715, 0.012008, -0.513700, 0.857886),["LeftUpperLeg"]=CFrame.new(-0.000723, -0.097399, -0.061041, 0.977090, 0.188363, 0.099057, 0.103714, -0.014989, -0.994495, -0.185846, 0.981985, -0.034174),["LowerTorso"]=CFrame.new(-0.101855, 0.262032, 0.503725, 0.999442, 0.014561, -0.030047, 0.026585, 0.197441, 0.979954, 0.020202, -0.980207, 0.196944),["RightFoot"]=CFrame.new(0.000000, -0.111038, -0.000100, 0.988459, 0.115897, 0.097591, -0.136063, 0.962359, 0.235287, -0.066608, -0.245833, 0.967014),["RightHand"]=CFrame.new(-0.000500, 0.000000, 0.000000, 0.999992, -0.003397, 0.002252, 0.003462, 0.999559, -0.029487, -0.002151, 0.029495, 0.999563),["RightLowerArm"]=CFrame.new(-0.011635, -0.043157, -0.003740, 1.000000, 0.000000, 0.000000, -0.000000, 0.999905, 0.013814, -0.000000, -0.013814, 0.999905),["RightLowerLeg"]=CFrame.new(-0.000000, -0.110257, -0.001418, 1.000000, -0.000000, -0.000000, 0.000000, 1.000000, -0.000002, 0.000000, -0.000005, 1.000000),["RightUpperArm"]=CFrame.new(-0.329583, -2.820942, 0.835479, -0.994719, 0.102592, -0.003102, -0.088838, -0.845436, 0.526636, 0.051406, 0.524130, 0.850085),["RightUpperLeg"]=CFrame.new(-0.016717, -0.066244, -0.093048, 0.995896, -0.087678, -0.022477, -0.022379, 0.001671, -0.999747, 0.087691, 0.996147, -0.000291),["UpperTorso"]=CFrame.new(-0.025057, -0.144190, 0.005167, 0.999058, 0.006402, 0.042925, -0.002019, 0.994846, -0.101379, -0.043352, 0.101197, 0.993921)}},
{t=0.450,d={["Head"]=CFrame.new(-0.003107, 0.068928, 0.157247, 0.999990, 0.002575, -0.003675, -0.004164, 0.837719, -0.546086, 0.001672, 0.546095, 0.837721),["LeftFoot"]=CFrame.new(0.000000, -0.120675, -0.000003, 0.986159, -0.126826, -0.106792, 0.146956, 0.966865, 0.208775, 0.076776, -0.221557, 0.972115),["LeftHand"]=CFrame.new(0.000500, 0.000100, 0.000000, 0.998674, 0.033727, 0.038897, -0.034986, 0.998870, 0.032161, -0.037768, -0.033478, 0.998726),["LeftLowerArm"]=CFrame.new(0.005666, -0.027820, 0.010667, 1.000000, -0.000000, -0.000000, 0.000000, 0.998699, -0.050997, 0.000000, 0.050996, 0.998699),["LeftLowerLeg"]=CFrame.new(-0.000000, -0.119861, -0.001488, 1.000000, -0.000000, 0.000000, -0.000000, 1.000000, -0.000006, 0.000000, -0.000010, 1.000000),["LeftUpperArm"]=CFrame.new(0.085869, 0.205059, 0.012894, 0.988125, -0.120507, -0.095323, 0.152347, 0.849044, 0.505879, 0.019972, -0.514394, 0.857321),["LeftUpperLeg"]=CFrame.new(-0.000723, -0.097399, -0.061041, 0.977090, 0.188363, 0.099057, 0.103714, -0.014989, -0.994495, -0.185846, 0.981985, -0.034174),["LowerTorso"]=CFrame.new(-0.101855, 0.262032, 0.503725, 0.999442, 0.014561, -0.030047, 0.026585, 0.197441, 0.979954, 0.020202, -0.980207, 0.196944),["RightFoot"]=CFrame.new(0.000000, -0.111038, -0.000100, 0.988459, 0.115897, 0.097591, -0.136063, 0.962359, 0.235287, -0.066608, -0.245833, 0.967014),["RightHand"]=CFrame.new(-0.000500, 0.000000, -0.000000, 0.999992, -0.003397, 0.002252, 0.003462, 0.999559, -0.029487, -0.002151, 0.029495, 0.999563),["RightLowerArm"]=CFrame.new(-0.011635, -0.043157, -0.003740, 1.000000, 0.000000, 0.000000, -0.000000, 0.999905, 0.013814, -0.000000, -0.013814, 0.999905),["RightLowerLeg"]=CFrame.new(-0.000000, -0.110257, -0.001418, 1.000000, -0.000000, -0.000000, 0.000000, 1.000000, -0.000002, 0.000000, -0.000005, 1.000000),["RightUpperArm"]=CFrame.new(-0.329632, -2.763033, 0.776931, -0.994719, 0.102592, -0.003102, -0.088838, -0.845436, 0.526636, 0.051406, 0.524130, 0.850085),["RightUpperLeg"]=CFrame.new(-0.016717, -0.066244, -0.093048, 0.995896, -0.087678, -0.022477, -0.022379, 0.001671, -0.999747, 0.087691, 0.996147, -0.000291),["UpperTorso"]=CFrame.new(-0.025057, -0.144190, 0.005167, 0.999058, 0.006402, 0.042925, -0.002019, 0.994846, -0.101379, -0.043352, 0.101197, 0.993921)}},
{t=0.500,d={["Head"]=CFrame.new(-0.003107, 0.068928, 0.157247, 0.999995, 0.002677, -0.001655, -0.003125, 0.782055, -0.623202, -0.000374, 0.623204, 0.782059),["LeftFoot"]=CFrame.new(0.000000, -0.120675, -0.000003, 0.986159, -0.126826, -0.106792, 0.146956, 0.966865, 0.208775, 0.076776, -0.221557, 0.972115),["LeftHand"]=CFrame.new(0.000500, 0.000100, 0.000000, 0.998674, 0.033727, 0.038897, -0.034986, 0.998870, 0.032161, -0.037768, -0.033478, 0.998726),["LeftLowerArm"]=CFrame.new(0.005666, -0.027820, 0.010667, 1.000000, -0.000000, -0.000000, 0.000000, 0.998699, -0.050997, 0.000000, 0.050996, 0.998699),["LeftLowerLeg"]=CFrame.new(-0.000000, -0.119861, -0.001488, 1.000000, -0.000000, 0.000000, -0.000000, 1.000000, -0.000006, 0.000000, -0.000010, 1.000000),["LeftUpperArm"]=CFrame.new(0.086539, 0.200357, 0.014361, 0.989466, -0.110916, -0.093034, 0.142944, 0.850228, 0.506635, 0.022906, -0.514597, 0.857126),["LeftUpperLeg"]=CFrame.new(-0.000723, -0.097399, -0.061041, 0.977090, 0.188363, 0.099057, 0.103714, -0.014989, -0.994495, -0.185846, 0.981985, -0.034174),["LowerTorso"]=CFrame.new(-0.101855, 0.262032, 0.503725, 0.999442, 0.014561, -0.030047, 0.026585, 0.197441, 0.979954, 0.020202, -0.980207, 0.196944),["RightFoot"]=CFrame.new(0.000000, -0.111038, -0.000100, 0.988459, 0.115897, 0.097591, -0.136063, 0.962359, 0.235287, -0.066608, -0.245833, 0.967014),["RightHand"]=CFrame.new(-0.000500, 0.000000, -0.000000, 0.999992, -0.003397, 0.002252, 0.003462, 0.999559, -0.029487, -0.002151, 0.029495, 0.999563),["RightLowerArm"]=CFrame.new(-0.011635, -0.043157, -0.003740, 1.000000, 0.000000, 0.000000, -0.000000, 0.999905, 0.013814, -0.000000, -0.013814, 0.999905),["RightLowerLeg"]=CFrame.new(-0.000000, -0.110257, -0.001418, 1.000000, -0.000000, -0.000000, 0.000000, 1.000000, -0.000002, 0.000000, -0.000005, 1.000000),["RightUpperArm"]=CFrame.new(-0.328066, -2.724691, 0.728896, -0.994719, 0.102592, -0.003102, -0.088838, -0.845436, 0.526636, 0.051406, 0.524130, 0.850085),["RightUpperLeg"]=CFrame.new(-0.016717, -0.066244, -0.093048, 0.995896, -0.087678, -0.022477, -0.022379, 0.001671, -0.999747, 0.087691, 0.996147, -0.000291),["UpperTorso"]=CFrame.new(-0.025057, -0.144190, 0.005167, 0.999058, 0.006402, 0.042925, -0.002019, 0.994846, -0.101379, -0.043352, 0.101197, 0.993921)}},
{t=0.550,d={["Head"]=CFrame.new(-0.003107, 0.068928, 0.157247, 0.999996, 0.002920, 0.000082, -0.002070, 0.728065, -0.685506, -0.002061, 0.685502, 0.728067),["LeftFoot"]=CFrame.new(0.000000, -0.120675, -0.000003, 0.986159, -0.126826, -0.106792, 0.146956, 0.966865, 0.208775, 0.076776, -0.221557, 0.972115),["LeftHand"]=CFrame.new(0.000500, 0.000100, 0.000000, 0.998674, 0.033727, 0.038897, -0.034986, 0.998870, 0.032161, -0.037768, -0.033478, 0.998726),["LeftLowerArm"]=CFrame.new(0.005666, -0.027820, 0.010667, 1.000000, -0.000000, -0.000000, 0.000000, 0.998699, -0.050997, 0.000000, 0.050996, 0.998699),["LeftLowerLeg"]=CFrame.new(-0.000000, -0.119861, -0.001488, 1.000000, -0.000000, 0.000000, -0.000000, 1.000000, -0.000006, 0.000000, -0.000010, 1.000000),["LeftUpperArm"]=CFrame.new(0.086539, 0.200357, 0.014361, 0.989466, -0.110916, -0.093034, 0.142944, 0.850228, 0.506635, 0.022906, -0.514597, 0.857126),["LeftUpperLeg"]=CFrame.new(-0.000723, -0.097399, -0.061041, 0.977090, 0.188363, 0.099057, 0.103714, -0.014989, -0.994495, -0.185846, 0.981985, -0.034174),["LowerTorso"]=CFrame.new(-0.101855, 0.262032, 0.503725, 0.999442, 0.014561, -0.030047, 0.026585, 0.197441, 0.979954, 0.020202, -0.980207, 0.196944),["RightFoot"]=CFrame.new(0.000000, -0.111038, -0.000100, 0.988459, 0.115897, 0.097591, -0.136063, 0.962359, 0.235287, -0.066608, -0.245833, 0.967014),["RightHand"]=CFrame.new(-0.000500, 0.000000, -0.000000, 0.999992, -0.003397, 0.002252, 0.003462, 0.999559, -0.029487, -0.002151, 0.029495, 0.999563),["RightLowerArm"]=CFrame.new(-0.011635, -0.043157, -0.003740, 1.000000, 0.000000, 0.000000, -0.000000, 0.999905, 0.013814, -0.000000, -0.013814, 0.999905),["RightLowerLeg"]=CFrame.new(-0.000000, -0.110257, -0.001418, 1.000000, -0.000000, -0.000000, 0.000000, 1.000000, -0.000002, 0.000000, -0.000005, 1.000000),["RightUpperArm"]=CFrame.new(-0.326380, -2.704720, 0.698826, -0.994719, 0.102592, -0.003102, -0.088838, -0.845436, 0.526636, 0.051406, 0.524130, 0.850085),["RightUpperLeg"]=CFrame.new(-0.016717, -0.066244, -0.093048, 0.995896, -0.087678, -0.022477, -0.022379, 0.001671, -0.999747, 0.087691, 0.996147, -0.000291),["UpperTorso"]=CFrame.new(-0.025057, -0.144190, 0.005167, 0.999058, 0.006402, 0.042925, -0.002019, 0.994846, -0.101379, -0.043352, 0.101197, 0.993921)}},
{t=0.600,d={["Head"]=CFrame.new(-0.003107, 0.068928, 0.157247, 0.999995, 0.003006, 0.000526, -0.001776, 0.713308, -0.700849, -0.002482, 0.700845, 0.713310),["LeftFoot"]=CFrame.new(0.000000, -0.120675, -0.000003, 0.986159, -0.126826, -0.106792, 0.146956, 0.966865, 0.208775, 0.076776, -0.221557, 0.972115),["LeftHand"]=CFrame.new(0.000500, 0.000100, 0.000000, 0.998674, 0.033727, 0.038897, -0.034986, 0.998870, 0.032161, -0.037768, -0.033478, 0.998726),["LeftLowerArm"]=CFrame.new(0.005666, -0.027820, 0.010667, 1.000000, -0.000000, -0.000000, 0.000000, 0.998699, -0.050997, 0.000000, 0.050996, 0.998699),["LeftLowerLeg"]=CFrame.new(-0.000000, -0.119861, -0.001488, 1.000000, -0.000000, 0.000000, -0.000000, 1.000000, -0.000006, 0.000000, -0.000010, 1.000000),["LeftUpperArm"]=CFrame.new(0.086539, 0.200357, 0.014361, 0.989466, -0.110916, -0.093034, 0.142944, 0.850228, 0.506635, 0.022906, -0.514597, 0.857126),["LeftUpperLeg"]=CFrame.new(-0.000723, -0.097399, -0.061041, 0.977090, 0.188363, 0.099057, 0.103714, -0.014989, -0.994495, -0.185846, 0.981985, -0.034174),["LowerTorso"]=CFrame.new(-0.101855, 0.262032, 0.503725, 0.999442, 0.014561, -0.030047, 0.026585, 0.197441, 0.979954, 0.020202, -0.980207, 0.196944),["RightFoot"]=CFrame.new(0.000000, -0.111038, -0.000100, 0.988459, 0.115897, 0.097591, -0.136063, 0.962359, 0.235287, -0.066608, -0.245833, 0.967014),["RightHand"]=CFrame.new(-0.000500, 0.000000, -0.000000, 0.999992, -0.003397, 0.002252, 0.003462, 0.999559, -0.029487, -0.002151, 0.029495, 0.999563),["RightLowerArm"]=CFrame.new(-0.011635, -0.043157, -0.003739, 1.000000, 0.000000, 0.000000, -0.000000, 0.999905, 0.013814, -0.000000, -0.013814, 0.999905),["RightLowerLeg"]=CFrame.new(-0.000000, -0.110257, -0.001418, 1.000000, -0.000000, -0.000000, 0.000000, 1.000000, -0.000002, 0.000000, -0.000005, 1.000000),["RightUpperArm"]=CFrame.new(-0.326136, -2.701092, 0.692752, -0.994719, 0.102592, -0.003102, -0.088838, -0.845436, 0.526636, 0.051406, 0.524130, 0.850085),["RightUpperLeg"]=CFrame.new(-0.016717, -0.066244, -0.093048, 0.995896, -0.087678, -0.022477, -0.022379, 0.001671, -0.999747, 0.087691, 0.996147, -0.000291),["UpperTorso"]=CFrame.new(-0.025057, -0.144190, 0.005167, 0.999058, 0.006402, 0.042925, -0.002019, 0.994846, -0.101379, -0.043352, 0.101197, 0.993921)}},
{t=0.650,d={["Head"]=CFrame.new(-0.003107, 0.068928, 0.157247, 0.999995, 0.002989, 0.000442, -0.001832, 0.716124, -0.697971, -0.002403, 0.697967, 0.716126),["LeftFoot"]=CFrame.new(0.000000, -0.120675, -0.000003, 0.986159, -0.126826, -0.106792, 0.146956, 0.966865, 0.208775, 0.076776, -0.221557, 0.972115),["LeftHand"]=CFrame.new(0.000500, 0.000100, 0.000000, 0.998674, 0.033727, 0.038897, -0.034986, 0.998870, 0.032161, -0.037768, -0.033478, 0.998726),["LeftLowerArm"]=CFrame.new(0.005666, -0.027820, 0.010667, 1.000000, -0.000000, -0.000000, 0.000000, 0.998699, -0.050997, 0.000000, 0.050996, 0.998699),["LeftLowerLeg"]=CFrame.new(-0.000000, -0.119861, -0.001488, 1.000000, -0.000000, 0.000000, -0.000000, 1.000000, -0.000006, 0.000000, -0.000010, 1.000000),["LeftUpperArm"]=CFrame.new(0.086539, 0.200357, 0.014361, 0.989466, -0.110916, -0.093034, 0.142944, 0.850228, 0.506635, 0.022906, -0.514597, 0.857126),["LeftUpperLeg"]=CFrame.new(-0.000723, -0.097399, -0.061041, 0.977090, 0.188363, 0.099057, 0.103714, -0.014989, -0.994495, -0.185846, 0.981985, -0.034174),["LowerTorso"]=CFrame.new(-0.101855, 0.262032, 0.503725, 0.999442, 0.014561, -0.030047, 0.026585, 0.197441, 0.979954, 0.020202, -0.980207, 0.196944),["RightFoot"]=CFrame.new(0.000000, -0.111038, -0.000100, 0.988459, 0.115897, 0.097591, -0.136063, 0.962359, 0.235287, -0.066608, -0.245833, 0.967014),["RightHand"]=CFrame.new(-0.000500, 0.000000, -0.000000, 0.999992, -0.003397, 0.002252, 0.003462, 0.999559, -0.029487, -0.002151, 0.029495, 0.999563),["RightLowerArm"]=CFrame.new(-0.011635, -0.043157, -0.003740, 1.000000, 0.000000, 0.000000, -0.000000, 0.999905, 0.013814, -0.000000, -0.013814, 0.999905),["RightLowerLeg"]=CFrame.new(-0.000000, -0.110257, -0.001418, 1.000000, -0.000000, -0.000000, 0.000000, 1.000000, -0.000002, 0.000000, -0.000005, 1.000000),["RightUpperArm"]=CFrame.new(-0.328848, -2.702747, 0.697510, -0.994719, 0.102592, -0.003102, -0.088838, -0.845436, 0.526636, 0.051406, 0.524130, 0.850085),["RightUpperLeg"]=CFrame.new(-0.016717, -0.066244, -0.093048, 0.995896, -0.087678, -0.022477, -0.022379, 0.001671, -0.999747, 0.087691, 0.996147, -0.000291),["UpperTorso"]=CFrame.new(-0.025057, -0.144190, 0.005167, 0.999058, 0.006402, 0.042925, -0.002019, 0.994846, -0.101379, -0.043352, 0.101197, 0.993921)}},
{t=0.700,d={["Head"]=CFrame.new(-0.003107, 0.068928, 0.157247, 0.999996, 0.002943, 0.000205, -0.001989, 0.724003, -0.689794, -0.002179, 0.689791, 0.724005),["LeftFoot"]=CFrame.new(0.000000, -0.120675, -0.000003, 0.986159, -0.126826, -0.106792, 0.146956, 0.966865, 0.208775, 0.076776, -0.221557, 0.972115),["LeftHand"]=CFrame.new(0.000500, 0.000100, 0.000000, 0.998674, 0.033727, 0.038897, -0.034986, 0.998870, 0.032161, -0.037768, -0.033478, 0.998726),["LeftLowerArm"]=CFrame.new(0.005666, -0.027820, 0.010667, 1.000000, -0.000000, -0.000000, 0.000000, 0.998699, -0.050997, 0.000000, 0.050996, 0.998699),["LeftLowerLeg"]=CFrame.new(-0.000000, -0.119861, -0.001488, 1.000000, -0.000000, 0.000000, -0.000000, 1.000000, -0.000006, 0.000000, -0.000010, 1.000000),["LeftUpperArm"]=CFrame.new(0.086539, 0.200357, 0.014361, 0.989466, -0.110916, -0.093034, 0.142944, 0.850228, 0.506635, 0.022906, -0.514597, 0.857126),["LeftUpperLeg"]=CFrame.new(-0.000723, -0.097399, -0.061041, 0.977090, 0.188363, 0.099057, 0.103714, -0.014989, -0.994495, -0.185846, 0.981985, -0.034174),["LowerTorso"]=CFrame.new(-0.101855, 0.262032, 0.503725, 0.999442, 0.014561, -0.030047, 0.026585, 0.197441, 0.979954, 0.020202, -0.980207, 0.196944),["RightFoot"]=CFrame.new(0.000000, -0.111038, -0.000100, 0.988459, 0.115897, 0.097591, -0.136063, 0.962359, 0.235287, -0.066608, -0.245833, 0.967014),["RightHand"]=CFrame.new(-0.000500, 0.000000, -0.000000, 0.999992, -0.003397, 0.002252, 0.003462, 0.999559, -0.029487, -0.002151, 0.029495, 0.999563),["RightLowerArm"]=CFrame.new(-0.011635, -0.043157, -0.003739, 1.000000, 0.000000, 0.000000, -0.000000, 0.999905, 0.013814, -0.000000, -0.013814, 0.999905),["RightLowerLeg"]=CFrame.new(-0.000000, -0.110257, -0.001418, 1.000000, -0.000000, -0.000000, 0.000000, 1.000000, -0.000002, 0.000000, -0.000005, 1.000000),["RightUpperArm"]=CFrame.new(-0.333579, -2.708123, 0.708262, -0.994719, 0.102592, -0.003102, -0.088838, -0.845436, 0.526636, 0.051406, 0.524130, 0.850085),["RightUpperLeg"]=CFrame.new(-0.016717, -0.066244, -0.093048, 0.995896, -0.087678, -0.022477, -0.022379, 0.001671, -0.999747, 0.087691, 0.996147, -0.000291),["UpperTorso"]=CFrame.new(-0.025057, -0.144190, 0.005167, 0.999058, 0.006402, 0.042925, -0.002019, 0.994846, -0.101379, -0.043352, 0.101197, 0.993921)}},
{t=0.750,d={["Head"]=CFrame.new(-0.003107, 0.068928, 0.157247, 0.999996, 0.002863, -0.000247, -0.002281, 0.738714, -0.674015, -0.001748, 0.674013, 0.738717),["LeftFoot"]=CFrame.new(0.000000, -0.120675, -0.000003, 0.986159, -0.126826, -0.106792, 0.146956, 0.966865, 0.208775, 0.076776, -0.221557, 0.972115),["LeftHand"]=CFrame.new(0.000500, 0.000100, 0.000000, 0.998674, 0.033727, 0.038897, -0.034986, 0.998870, 0.032161, -0.037768, -0.033478, 0.998726),["LeftLowerArm"]=CFrame.new(0.005666, -0.027820, 0.010667, 1.000000, -0.000000, -0.000000, 0.000000, 0.998699, -0.050997, 0.000000, 0.050996, 0.998699),["LeftLowerLeg"]=CFrame.new(-0.000000, -0.119861, -0.001488, 1.000000, -0.000000, 0.000000, -0.000000, 1.000000, -0.000006, 0.000000, -0.000010, 1.000000),["LeftUpperArm"]=CFrame.new(0.086539, 0.200357, 0.014361, 0.989466, -0.110916, -0.093034, 0.142944, 0.850228, 0.506635, 0.022906, -0.514597, 0.857126),["LeftUpperLeg"]=CFrame.new(-0.000723, -0.097399, -0.061041, 0.977090, 0.188363, 0.099057, 0.103714, -0.014989, -0.994495, -0.185846, 0.981985, -0.034174),["LowerTorso"]=CFrame.new(-0.101855, 0.262032, 0.503725, 0.999442, 0.014561, -0.030047, 0.026585, 0.197441, 0.979954, 0.020202, -0.980207, 0.196944),["RightFoot"]=CFrame.new(0.000000, -0.111038, -0.000100, 0.988459, 0.115897, 0.097591, -0.136063, 0.962359, 0.235287, -0.066608, -0.245833, 0.967014),["RightHand"]=CFrame.new(-0.000500, 0.000000, -0.000000, 0.999992, -0.003397, 0.002252, 0.003462, 0.999559, -0.029487, -0.002151, 0.029495, 0.999563),["RightLowerArm"]=CFrame.new(-0.011635, -0.043157, -0.003739, 1.000000, 0.000000, 0.000000, -0.000000, 0.999905, 0.013814, -0.000000, -0.013814, 0.999905),["RightLowerLeg"]=CFrame.new(-0.000000, -0.110257, -0.001418, 1.000000, -0.000000, -0.000000, 0.000000, 1.000000, -0.000002, 0.000000, -0.000005, 1.000000),["RightUpperArm"]=CFrame.new(-0.338902, -2.719222, 0.725335, -0.994719, 0.102592, -0.003102, -0.088838, -0.845436, 0.526636, 0.051406, 0.524130, 0.850085),["RightUpperLeg"]=CFrame.new(-0.016717, -0.066244, -0.093048, 0.995896, -0.087678, -0.022477, -0.022379, 0.001671, -0.999747, 0.087691, 0.996147, -0.000291),["UpperTorso"]=CFrame.new(-0.025057, -0.144190, 0.005167, 0.999058, 0.006402, 0.042925, -0.002019, 0.994846, -0.101379, -0.043352, 0.101197, 0.993921)}},
{t=0.800,d={["Head"]=CFrame.new(-0.003107, 0.068928, 0.157247, 0.999996, 0.002754, -0.000978, -0.002732, 0.761691, -0.647934, -0.001040, 0.647934, 0.761696),["LeftFoot"]=CFrame.new(0.000000, -0.120675, -0.000003, 0.986159, -0.126826, -0.106792, 0.146956, 0.966865, 0.208775, 0.076776, -0.221557, 0.972115),["LeftHand"]=CFrame.new(0.000500, 0.000100, 0.000000, 0.998674, 0.033727, 0.038897, -0.034986, 0.998870, 0.032161, -0.037768, -0.033478, 0.998726),["LeftLowerArm"]=CFrame.new(0.005666, -0.027820, 0.010667, 1.000000, -0.000000, -0.000000, 0.000000, 0.998699, -0.050997, 0.000000, 0.050996, 0.998699),["LeftLowerLeg"]=CFrame.new(-0.000000, -0.119861, -0.001488, 1.000000, -0.000000, 0.000000, -0.000000, 1.000000, -0.000006, 0.000000, -0.000010, 1.000000),["LeftUpperArm"]=CFrame.new(0.086539, 0.200357, 0.014361, 0.989466, -0.110916, -0.093034, 0.142944, 0.850228, 0.506635, 0.022906, -0.514597, 0.857126),["LeftUpperLeg"]=CFrame.new(-0.000723, -0.097399, -0.061041, 0.977090, 0.188363, 0.099057, 0.103714, -0.014989, -0.994495, -0.185846, 0.981985, -0.034174),["LowerTorso"]=CFrame.new(-0.101855, 0.262032, 0.503725, 0.999442, 0.014561, -0.030047, 0.026585, 0.197441, 0.979954, 0.020202, -0.980207, 0.196944),["RightFoot"]=CFrame.new(0.000000, -0.111038, -0.000100, 0.988459, 0.115897, 0.097591, -0.136063, 0.962359, 0.235287, -0.066608, -0.245833, 0.967014),["RightHand"]=CFrame.new(-0.000500, 0.000000, 0.000000, 0.999992, -0.003397, 0.002252, 0.003462, 0.999559, -0.029487, -0.002151, 0.029495, 0.999563),["RightLowerArm"]=CFrame.new(-0.011635, -0.043157, -0.003740, 1.000000, 0.000000, 0.000000, -0.000000, 0.999905, 0.013814, -0.000000, -0.013814, 0.999905),["RightLowerLeg"]=CFrame.new(-0.000000, -0.110257, -0.001418, 1.000000, -0.000000, -0.000000, 0.000000, 1.000000, -0.000002, 0.000000, -0.000005, 1.000000),["RightUpperArm"]=CFrame.new(-0.343387, -2.738048, 0.749059, -0.994719, 0.102592, -0.003102, -0.088838, -0.845436, 0.526636, 0.051406, 0.524130, 0.850085),["RightUpperLeg"]=CFrame.new(-0.016717, -0.066244, -0.093048, 0.995896, -0.087678, -0.022477, -0.022379, 0.001671, -0.999747, 0.087691, 0.996147, -0.000291),["UpperTorso"]=CFrame.new(-0.025057, -0.144190, 0.005167, 0.999058, 0.006402, 0.042925, -0.002019, 0.994846, -0.101379, -0.043352, 0.101197, 0.993921)}},
{t=0.850,d={["Head"]=CFrame.new(-0.003107, 0.068928, 0.157247, 0.999994, 0.002641, -0.002057, -0.003348, 0.793751, -0.608234, 0.000026, 0.608237, 0.793755),["LeftFoot"]=CFrame.new(0.000000, -0.120675, -0.000003, 0.986159, -0.126826, -0.106792, 0.146956, 0.966865, 0.208775, 0.076776, -0.221557, 0.972115),["LeftHand"]=CFrame.new(0.000500, 0.000100, 0.000000, 0.998674, 0.033727, 0.038897, -0.034986, 0.998870, 0.032161, -0.037768, -0.033478, 0.998726),["LeftLowerArm"]=CFrame.new(0.005666, -0.027820, 0.010667, 1.000000, -0.000000, -0.000000, 0.000000, 0.998699, -0.050997, 0.000000, 0.050996, 0.998699),["LeftLowerLeg"]=CFrame.new(-0.000000, -0.119861, -0.001488, 1.000000, -0.000000, 0.000000, -0.000000, 1.000000, -0.000006, 0.000000, -0.000010, 1.000000),["LeftUpperArm"]=CFrame.new(0.086464, 0.200905, 0.014190, 0.989315, -0.112033, -0.093301, 0.144039, 0.850095, 0.506549, 0.022565, -0.514575, 0.857148),["LeftUpperLeg"]=CFrame.new(-0.000723, -0.097399, -0.061041, 0.977090, 0.188363, 0.099057, 0.103714, -0.014989, -0.994495, -0.185846, 0.981985, -0.034174),["LowerTorso"]=CFrame.new(-0.101855, 0.262032, 0.503725, 0.999442, 0.014561, -0.030047, 0.026585, 0.197441, 0.979954, 0.020202, -0.980207, 0.196944),["RightFoot"]=CFrame.new(0.000000, -0.111038, -0.000100, 0.988459, 0.115897, 0.097591, -0.136063, 0.962359, 0.235287, -0.066608, -0.245833, 0.967014),["RightHand"]=CFrame.new(-0.000500, 0.000000, -0.000000, 0.999992, -0.003397, 0.002252, 0.003462, 0.999559, -0.029487, -0.002151, 0.029495, 0.999563),["RightLowerArm"]=CFrame.new(-0.011635, -0.043157, -0.003740, 1.000000, 0.000000, 0.000000, -0.000000, 0.999905, 0.013814, -0.000000, -0.013814, 0.999905),["RightLowerLeg"]=CFrame.new(-0.000000, -0.110257, -0.001418, 1.000000, -0.000000, -0.000000, 0.000000, 1.000000, -0.000002, 0.000000, -0.000005, 1.000000),["RightUpperArm"]=CFrame.new(-0.345610, -2.766602, 0.779760, -0.994719, 0.102592, -0.003102, -0.088838, -0.845436, 0.526636, 0.051406, 0.524130, 0.850085),["RightUpperLeg"]=CFrame.new(-0.016717, -0.066244, -0.093048, 0.995896, -0.087678, -0.022477, -0.022379, 0.001671, -0.999747, 0.087691, 0.996147, -0.000291),["UpperTorso"]=CFrame.new(-0.025057, -0.144190, 0.005167, 0.999058, 0.006402, 0.042925, -0.002019, 0.994846, -0.101379, -0.043352, 0.101197, 0.993921)}},
{t=0.900,d={["Head"]=CFrame.new(-0.003107, 0.068928, 0.157247, 0.999991, 0.002576, -0.003496, -0.004080, 0.833096, -0.553113, 0.001487, 0.553122, 0.833099),["LeftFoot"]=CFrame.new(0.000000, -0.120675, -0.000003, 0.986159, -0.126826, -0.106792, 0.146956, 0.966865, 0.208775, 0.076776, -0.221557, 0.972115),["LeftHand"]=CFrame.new(0.000500, 0.000100, 0.000000, 0.998674, 0.033727, 0.038897, -0.034986, 0.998870, 0.032161, -0.037768, -0.033478, 0.998726),["LeftLowerArm"]=CFrame.new(0.005665, -0.027820, 0.010667, 1.000000, -0.000000, -0.000000, 0.000000, 0.998699, -0.050997, 0.000000, 0.050996, 0.998699),["LeftLowerLeg"]=CFrame.new(-0.000000, -0.119861, -0.001488, 1.000000, -0.000000, 0.000000, -0.000000, 1.000000, -0.000006, 0.000000, -0.000010, 1.000000),["LeftUpperArm"]=CFrame.new(0.085344, 0.208515, 0.011814, 0.987076, -0.127558, -0.097003, 0.159259, 0.848115, 0.505309, 0.017813, -0.514227, 0.857469),["LeftUpperLeg"]=CFrame.new(-0.000723, -0.097399, -0.061041, 0.977090, 0.188363, 0.099057, 0.103714, -0.014989, -0.994495, -0.185846, 0.981985, -0.034174),["LowerTorso"]=CFrame.new(-0.101855, 0.262032, 0.503725, 0.999442, 0.014561, -0.030047, 0.026585, 0.197441, 0.979954, 0.020202, -0.980207, 0.196944),["RightFoot"]=CFrame.new(0.000000, -0.111038, -0.000100, 0.988459, 0.115897, 0.097591, -0.136063, 0.962359, 0.235287, -0.066608, -0.245833, 0.967014),["RightHand"]=CFrame.new(-0.000500, 0.000000, -0.000000, 0.999992, -0.003397, 0.002252, 0.003462, 0.999559, -0.029487, -0.002151, 0.029495, 0.999563),["RightLowerArm"]=CFrame.new(-0.011635, -0.043158, -0.003740, 1.000000, 0.000000, 0.000000, -0.000000, 0.999905, 0.013814, -0.000000, -0.013814, 0.999905),["RightLowerLeg"]=CFrame.new(-0.000000, -0.110257, -0.001418, 1.000000, -0.000000, -0.000000, 0.000000, 1.000000, -0.000002, 0.000000, -0.000005, 1.000000),["RightUpperArm"]=CFrame.new(-0.344142, -2.806887, 0.817768, -0.994719, 0.102592, -0.003102, -0.088838, -0.845436, 0.526636, 0.051406, 0.524130, 0.850085),["RightUpperLeg"]=CFrame.new(-0.016717, -0.066244, -0.093048, 0.995896, -0.087678, -0.022477, -0.022379, 0.001671, -0.999747, 0.087691, 0.996147, -0.000291),["UpperTorso"]=CFrame.new(-0.025057, -0.144190, 0.005167, 0.999058, 0.006402, 0.042925, -0.002019, 0.994846, -0.101379, -0.043352, 0.101197, 0.993921)}},
{t=0.950,d={["Head"]=CFrame.new(-0.003107, 0.068928, 0.157247, 0.999983, 0.002626, -0.005204, -0.004818, 0.874820, -0.484424, 0.003281, 0.484441, 0.874818),["LeftFoot"]=CFrame.new(0.000000, -0.120675, -0.000003, 0.986159, -0.126826, -0.106792, 0.146956, 0.966865, 0.208775, 0.076776, -0.221557, 0.972115),["LeftHand"]=CFrame.new(0.000500, 0.000100, -0.000000, 0.998674, 0.033727, 0.038897, -0.034986, 0.998870, 0.032161, -0.037768, -0.033478, 0.998726),["LeftLowerArm"]=CFrame.new(0.005666, -0.027820, 0.010666, 1.000000, -0.000000, -0.000000, 0.000000, 0.998699, -0.050997, 0.000000, 0.050996, 0.998699),["LeftLowerLeg"]=CFrame.new(-0.000000, -0.119861, -0.001488, 1.000000, -0.000000, 0.000000, -0.000000, 1.000000, -0.000006, 0.000000, -0.000010, 1.000000),["LeftUpperArm"]=CFrame.new(0.082758, 0.223481, 0.007136, 0.981904, -0.158105, -0.104249, 0.189191, 0.843507, 0.502696, 0.008456, -0.513322, 0.858154),["LeftUpperLeg"]=CFrame.new(-0.000723, -0.097399, -0.061041, 0.977090, 0.188363, 0.099057, 0.103714, -0.014989, -0.994495, -0.185846, 0.981985, -0.034174),["LowerTorso"]=CFrame.new(-0.101855, 0.262032, 0.503725, 0.999442, 0.014561, -0.030047, 0.026585, 0.197441, 0.979954, 0.020202, -0.980207, 0.196944),["RightFoot"]=CFrame.new(0.000000, -0.111038, -0.000100, 0.988459, 0.115897, 0.097591, -0.136063, 0.962359, 0.235287, -0.066608, -0.245833, 0.967014),["RightHand"]=CFrame.new(-0.000500, 0.000000, -0.000000, 0.999992, -0.003397, 0.002252, 0.003462, 0.999559, -0.029487, -0.002151, 0.029495, 0.999563),["RightLowerArm"]=CFrame.new(-0.011635, -0.043158, -0.003739, 1.000000, 0.000000, 0.000000, -0.000000, 0.999905, 0.013814, -0.000000, -0.013814, 0.999905),["RightLowerLeg"]=CFrame.new(-0.000000, -0.110257, -0.001418, 1.000000, -0.000000, -0.000000, 0.000000, 1.000000, -0.000002, 0.000000, -0.000005, 1.000000),["RightUpperArm"]=CFrame.new(-0.337556, -2.860906, 0.863410, -0.994719, 0.102592, -0.003102, -0.088838, -0.845436, 0.526636, 0.051406, 0.524130, 0.850085),["RightUpperLeg"]=CFrame.new(-0.016717, -0.066244, -0.093048, 0.995896, -0.087678, -0.022477, -0.022379, 0.001671, -0.999747, 0.087691, 0.996147, -0.000291),["UpperTorso"]=CFrame.new(-0.025057, -0.144190, 0.005167, 0.999058, 0.006402, 0.042925, -0.002019, 0.994846, -0.101379, -0.043352, 0.101197, 0.993921)}},
{t=1.000,d={["Head"]=CFrame.new(-0.003107, 0.068928, 0.157247, 0.999971, 0.002838, -0.007070, -0.005460, 0.914146, -0.405347, 0.005313, 0.405374, 0.914135),["LeftFoot"]=CFrame.new(0.000000, -0.120675, -0.000003, 0.986159, -0.126826, -0.106792, 0.146956, 0.966865, 0.208775, 0.076776, -0.221557, 0.972115),["LeftHand"]=CFrame.new(0.000500, 0.000100, 0.000000, 0.998674, 0.033727, 0.038897, -0.034986, 0.998870, 0.032161, -0.037768, -0.033478, 0.998726),["LeftLowerArm"]=CFrame.new(0.005666, -0.027820, 0.010667, 1.000000, -0.000000, -0.000000, 0.000000, 0.998699, -0.050997, 0.000000, 0.050996, 0.998699),["LeftLowerLeg"]=CFrame.new(-0.000000, -0.119861, -0.001488, 1.000000, -0.000000, 0.000000, -0.000000, 1.000000, -0.000006, 0.000000, -0.000010, 1.000000),["LeftUpperArm"]=CFrame.new(0.078438, 0.243711, 0.000797, 0.973264, -0.199422, -0.113968, 0.229652, 0.835746, 0.498788, -0.004221, -0.511625, 0.859199),["LeftUpperLeg"]=CFrame.new(-0.000723, -0.097399, -0.061041, 0.977090, 0.188363, 0.099057, 0.103714, -0.014989, -0.994495, -0.185846, 0.981985, -0.034174),["LowerTorso"]=CFrame.new(-0.101855, 0.262032, 0.503725, 0.999442, 0.014561, -0.030047, 0.026585, 0.197441, 0.979954, 0.020202, -0.980207, 0.196944),["RightFoot"]=CFrame.new(0.000000, -0.111038, -0.000100, 0.988459, 0.115897, 0.097591, -0.136063, 0.962359, 0.235287, -0.066608, -0.245833, 0.967014),["RightHand"]=CFrame.new(-0.000500, 0.000000, -0.000000, 0.999992, -0.003397, 0.002252, 0.003462, 0.999559, -0.029487, -0.002151, 0.029495, 0.999563),["RightLowerArm"]=CFrame.new(-0.011635, -0.043157, -0.003739, 1.000000, 0.000000, 0.000000, -0.000000, 0.999905, 0.013814, -0.000000, -0.013814, 0.999905),["RightLowerLeg"]=CFrame.new(-0.000000, -0.110257, -0.001418, 1.000000, -0.000000, -0.000000, 0.000000, 1.000000, -0.000002, 0.000000, -0.000005, 1.000000),["RightUpperArm"]=CFrame.new(-0.324425, -2.930660, 0.917015, -0.994719, 0.102592, -0.003102, -0.088838, -0.845436, 0.526636, 0.051406, 0.524130, 0.850085),["RightUpperLeg"]=CFrame.new(-0.016717, -0.066244, -0.093048, 0.995896, -0.087678, -0.022477, -0.022379, 0.001671, -0.999747, 0.087691, 0.996147, -0.000291),["UpperTorso"]=CFrame.new(-0.025057, -0.144190, 0.005167, 0.999058, 0.006402, 0.042925, -0.002019, 0.994846, -0.101379, -0.043352, 0.101197, 0.993921)}},
{t=1.050,d={["Head"]=CFrame.new(-0.003107, 0.068928, 0.157247, 0.999955, 0.003230, -0.008971, -0.005933, 0.947300, -0.320291, 0.007464, 0.320330, 0.947277),["LeftFoot"]=CFrame.new(0.000000, -0.121399, -0.000003, 0.986234, -0.126485, -0.106505, 0.146812, 0.966183, 0.212012, 0.076087, -0.224706, 0.971446),["LeftHand"]=CFrame.new(0.000500, 0.000100, 0.000000, 0.998674, 0.033727, 0.038897, -0.034986, 0.998870, 0.032161, -0.037768, -0.033478, 0.998726),["LeftLowerArm"]=CFrame.new(0.005666, -0.027820, 0.010667, 1.000000, -0.000000, -0.000000, 0.000000, 0.998699, -0.050997, 0.000000, 0.050996, 0.998699),["LeftLowerLeg"]=CFrame.new(-0.000000, -0.120582, -0.001498, 1.000000, 0.000000, 0.000000, 0.000000, 1.000000, -0.000006, 0.000000, -0.000010, 1.000000),["LeftUpperArm"]=CFrame.new(0.072302, 0.262778, -0.005212, 0.960869, -0.247157, -0.125078, 0.276359, 0.824538, 0.493724, -0.018896, -0.508970, 0.860577),["LeftUpperLeg"]=CFrame.new(-0.000723, -0.097399, -0.061041, 0.977186, 0.188294, 0.098234, 0.103500, -0.018299, -0.994462, -0.185459, 0.981942, -0.037363),["LowerTorso"]=CFrame.new(-0.101855, 0.262032, 0.510478, 0.999442, 0.014561, -0.030047, 0.026585, 0.197441, 0.979954, 0.020202, -0.980207, 0.196944),["RightFoot"]=CFrame.new(0.000000, -0.111697, -0.000100, 0.988493, 0.115726, 0.097447, -0.136084, 0.961553, 0.238546, -0.066054, -0.249045, 0.966230),["RightHand"]=CFrame.new(-0.000500, 0.000000, -0.000000, 0.999992, -0.003397, 0.002252, 0.003462, 0.999559, -0.029487, -0.002151, 0.029495, 0.999563),["RightLowerArm"]=CFrame.new(-0.011635, -0.043157, -0.003739, 1.000000, 0.000000, 0.000000, -0.000000, 0.999905, 0.013814, -0.000000, -0.013814, 0.999905),["RightLowerLeg"]=CFrame.new(0.000000, -0.110913, -0.001427, 1.000000, -0.000000, -0.000000, 0.000000, 1.000000, -0.000002, 0.000000, -0.000005, 1.000000),["RightUpperArm"]=CFrame.new(-0.314363, -3.036543, 0.967965, -0.994719, 0.102592, -0.003102, -0.088838, -0.845436, 0.526636, 0.051406, 0.524130, 0.850085),["RightUpperLeg"]=CFrame.new(-0.016717, -0.066244, -0.093048, 0.995916, -0.087551, -0.022085, -0.022280, -0.001683, -0.999750, 0.087489, 0.996159, -0.003620),["UpperTorso"]=CFrame.new(-0.025193, -0.137571, 0.003837, 0.999058, 0.006402, 0.042925, -0.002019, 0.994846, -0.101379, -0.043352, 0.101197, 0.993921)}},
{t=1.100,d={["Head"]=CFrame.new(-0.003107, 0.068928, 0.157247, 0.999935, 0.003778, -0.010785, -0.006203, 0.972053, -0.234681, 0.009597, 0.234733, 0.972013),["LeftFoot"]=CFrame.new(-0.000000, -0.123547, -0.000003, 0.986445, -0.125515, -0.105688, 0.146389, 0.964175, 0.221244, 0.074133, -0.233693, 0.969475),["LeftHand"]=CFrame.new(0.000500, 0.000100, 0.000000, 0.998674, 0.033727, 0.038897, -0.034986, 0.998870, 0.032161, -0.037768, -0.033478, 0.998726),["LeftLowerArm"]=CFrame.new(0.005666, -0.027820, 0.010667, 1.000000, -0.000000, -0.000000, 0.000000, 0.998699, -0.050997, 0.000000, 0.050996, 0.998699),["LeftLowerLeg"]=CFrame.new(-0.000000, -0.122723, -0.001526, 1.000000, -0.000000, 0.000000, -0.000000, 1.000000, -0.000006, 0.000000, -0.000010, 1.000000),["LeftUpperArm"]=CFrame.new(0.064567, 0.276156, -0.009486, 0.945087, -0.296938, -0.136523, 0.325021, 0.810197, 0.487793, -0.034234, -0.505380, 0.862218),["LeftUpperLeg"]=CFrame.new(-0.000723, -0.097399, -0.061041, 0.977458, 0.188088, 0.095894, 0.102891, -0.027751, -0.994306, -0.184361, 0.981760, -0.046471),["LowerTorso"]=CFrame.new(-0.101855, 0.262032, 0.529823, 0.999442, 0.014561, -0.030047, 0.026585, 0.197441, 0.979954, 0.020202, -0.980207, 0.196944),["RightFoot"]=CFrame.new(-0.000000, -0.113645, -0.000100, 0.988590, 0.115241, 0.097038, -0.136137, 0.959192, 0.247843, -0.064476, -0.258207, 0.963928),["RightHand"]=CFrame.new(-0.000500, -0.000000, -0.000000, 0.999992, -0.003397, 0.002252, 0.003462, 0.999559, -0.029487, -0.002151, 0.029495, 0.999563),["RightLowerArm"]=CFrame.new(-0.011635, -0.043158, -0.003740, 1.000000, 0.000000, 0.000000, -0.000000, 0.999905, 0.013814, -0.000000, -0.013814, 0.999905),["RightLowerLeg"]=CFrame.new(-0.000000, -0.112854, -0.001452, 1.000000, -0.000000, -0.000000, 0.000000, 1.000000, -0.000002, 0.000000, -0.000005, 1.000000),["RightUpperArm"]=CFrame.new(-0.313825, -3.187561, 1.011340, -0.994719, 0.102592, -0.003102, -0.088838, -0.845436, 0.526636, 0.051406, 0.524130, 0.850085),["RightUpperLeg"]=CFrame.new(-0.016717, -0.066244, -0.093048, 0.995973, -0.087181, -0.020972, -0.021998, -0.011268, -0.999694, 0.086915, 0.996129, -0.013134),["UpperTorso"]=CFrame.new(-0.025584, -0.118609, 0.000028, 0.999058, 0.006402, 0.042925, -0.002019, 0.994846, -0.101379, -0.043352, 0.101197, 0.993921)}},
{t=1.150,d={["Head"]=CFrame.new(-0.003107, 0.068928, 0.157247, 0.999913, 0.004421, -0.012401, -0.006284, 0.987981, -0.154447, 0.011569, 0.154512, 0.987923),["LeftFoot"]=CFrame.new(-0.000000, -0.127097, -0.000003, 0.986771, -0.124011, -0.104421, 0.145698, 0.960847, 0.235707, 0.071104, -0.247778, 0.966198),["LeftHand"]=CFrame.new(0.000500, 0.000100, 0.000000, 0.998674, 0.033727, 0.038897, -0.034986, 0.998870, 0.032161, -0.037768, -0.033478, 0.998726),["LeftLowerArm"]=CFrame.new(0.005666, -0.027820, 0.010667, 1.000000, -0.000000, -0.000000, -0.000000, 0.998699, -0.050997, 0.000000, 0.050996, 0.998699),["LeftLowerLeg"]=CFrame.new(-0.000000, -0.126261, -0.001573, 1.000000, -0.000000, -0.000000, -0.000000, 1.000000, -0.000006, 0.000000, -0.000010, 1.000000),["LeftUpperArm"]=CFrame.new(0.055804, 0.284635, -0.012262, 0.927139, -0.344540, -0.147325, 0.371508, 0.793830, 0.481473, -0.048936, -0.501125, 0.863990),["LeftUpperLeg"]=CFrame.new(-0.000723, -0.097399, -0.061041, 0.977877, 0.187730, 0.092255, 0.101945, -0.042597, -0.993878, -0.182656, 0.981297, -0.060786),["LowerTorso"]=CFrame.new(-0.101855, 0.262032, 0.560389, 0.999442, 0.014561, -0.030047, 0.026585, 0.197441, 0.979954, 0.020202, -0.980207, 0.196944),["RightFoot"]=CFrame.new(-0.000000, -0.116924, -0.000100, 0.988739, 0.114487, 0.096404, -0.136196, 0.955302, 0.262408, -0.062012, -0.272564, 0.960129),["RightHand"]=CFrame.new(-0.000500, 0.000000, -0.000000, 0.999992, -0.003397, 0.002252, 0.003462, 0.999559, -0.029487, -0.002151, 0.029495, 0.999563),["RightLowerArm"]=CFrame.new(-0.011635, -0.043157, -0.003739, 1.000000, 0.000000, 0.000000, -0.000000, 0.999905, 0.013814, -0.000000, -0.013814, 0.999905),["RightLowerLeg"]=CFrame.new(-0.000000, -0.116121, -0.001496, 1.000000, -0.000000, -0.000000, 0.000000, 1.000000, -0.000002, 0.000000, -0.000005, 1.000000),["RightUpperArm"]=CFrame.new(-0.316640, -3.368639, 1.056006, -0.994719, 0.102592, -0.003102, -0.088838, -0.845436, 0.526636, 0.051406, 0.524130, 0.850085),["RightUpperLeg"]=CFrame.new(-0.016717, -0.066244, -0.093048, 0.996060, -0.086583, -0.019246, -0.021561, -0.026329, -0.999420, 0.086023, 0.995897, -0.028087),["UpperTorso"]=CFrame.new(-0.026201, -0.088648, -0.005992, 0.999058, 0.006402, 0.042925, -0.002019, 0.994846, -0.101379, -0.043352, 0.101197, 0.993921)}},
{t=1.200,d={["Head"]=CFrame.new(-0.003107, 0.068928, 0.157247, 0.999893, 0.005070, -0.013729, -0.006225, 0.996323, -0.085450, 0.013245, 0.085526, 0.996248),["LeftFoot"]=CFrame.new(-0.000000, -0.132073, -0.000003, 0.987179, -0.122096, -0.102809, 0.144757, 0.956230, 0.254329, 0.067257, -0.265925, 0.961638),["LeftHand"]=CFrame.new(0.000500, 0.000100, 0.000000, 0.998674, 0.033727, 0.038897, -0.034986, 0.998870, 0.032161, -0.037768, -0.033478, 0.998726),["LeftLowerArm"]=CFrame.new(0.005666, -0.027820, 0.010666, 1.000000, -0.000000, -0.000000, 0.000000, 0.998699, -0.050997, 0.000000, 0.050996, 0.998699),["LeftLowerLeg"]=CFrame.new(-0.000000, -0.131220, -0.001639, 1.000000, 0.000000, 0.000000, -0.000000, 1.000000, -0.000006, 0.000000, -0.000010, 1.000000),["LeftUpperArm"]=CFrame.new(0.047002, 0.289166, -0.013815, 0.909087, -0.386044, -0.156624, 0.412000, 0.777326, 0.475416, -0.061783, -0.496724, 0.865707),["LeftUpperLeg"]=CFrame.new(-0.000723, -0.097399, -0.061041, 0.978405, 0.187205, 0.087613, 0.100742, -0.061776, -0.992994, -0.180486, 0.980376, -0.079295),["LowerTorso"]=CFrame.new(-0.101855, 0.262032, 0.600249, 0.999442, 0.014561, -0.030047, 0.026585, 0.197441, 0.979954, 0.020202, -0.980207, 0.196944),["RightFoot"]=CFrame.new(-0.000000, -0.121515, -0.000100, 0.988928, 0.113526, 0.095595, -0.136225, 0.949948, 0.281162, -0.058850, -0.291051, 0.954887),["RightHand"]=CFrame.new(-0.000500, 0.000000, 0.000000, 0.999992, -0.003397, 0.002252, 0.003462, 0.999559, -0.029487, -0.002151, 0.029495, 0.999563),["RightLowerArm"]=CFrame.new(-0.011635, -0.043157, -0.003740, 1.000000, 0.000000, 0.000000, -0.000000, 0.999905, 0.013814, -0.000000, -0.013814, 0.999905),["RightLowerLeg"]=CFrame.new(-0.000000, -0.120698, -0.001556, 1.000000, -0.000000, -0.000000, 0.000000, 1.000000, -0.000002, 0.000000, -0.000005, 1.000000),["RightUpperArm"]=CFrame.new(-0.317080, -3.563419, 1.109543, -0.994719, 0.102592, -0.003102, -0.088838, -0.845436, 0.526636, 0.051406, 0.524130, 0.850085),["RightUpperLeg"]=CFrame.new(-0.016717, -0.066244, -0.093048, 0.996169, -0.085780, -0.017054, -0.021005, -0.045804, -0.998729, 0.084888, 0.995261, -0.047426),["UpperTorso"]=CFrame.new(-0.027006, -0.049577, -0.013842, 0.999058, 0.006402, 0.042925, -0.002019, 0.994846, -0.101379, -0.043352, 0.101197, 0.993921)}},
{t=1.250,d={["Head"]=CFrame.new(-0.003107, 0.068928, 0.157247, 0.999876, 0.005619, -0.014699, -0.006103, 0.999434, -0.033095, 0.014505, 0.033181, 0.999344),["LeftFoot"]=CFrame.new(0.000000, -0.137525, -0.000003, 0.987578, -0.120191, -0.101205, 0.143751, 0.951200, 0.273076, 0.063446, -0.284206, 0.956654),["LeftHand"]=CFrame.new(0.000500, 0.000100, 0.000000, 0.998674, 0.033727, 0.038897, -0.034986, 0.998870, 0.032161, -0.037768, -0.033478, 0.998726),["LeftLowerArm"]=CFrame.new(0.005666, -0.027820, 0.010667, 1.000000, -0.000000, -0.000000, 0.000000, 0.998699, -0.050997, 0.000000, 0.050996, 0.998699),["LeftLowerLeg"]=CFrame.new(-0.000000, -0.136654, -0.001711, 1.000000, -0.000000, 0.000000, -0.000000, 1.000000, -0.000006, 0.000000, -0.000010, 1.000000),["LeftUpperArm"]=CFrame.new(0.039466, 0.290887, -0.014477, 0.893620, -0.417911, -0.163685, 0.443065, 0.763162, 0.470400, -0.071667, -0.492883, 0.867139),["LeftUpperLeg"]=CFrame.new(-0.000723, -0.097399, -0.061041, 0.978923, 0.186603, 0.082987, 0.099546, -0.081159, -0.991719, -0.178328, 0.979077, -0.098017),["LowerTorso"]=CFrame.new(-0.101855, 0.262032, 0.641004, 0.999442, 0.014561, -0.030047, 0.026585, 0.197441, 0.979954, 0.020202, -0.980207, 0.196944),["RightFoot"]=CFrame.new(-0.000000, -0.126615, -0.000100, 0.989115, 0.112570, 0.094789, -0.136202, 0.944159, 0.300040, -0.055680, -0.309663, 0.949205),["RightHand"]=CFrame.new(-0.000500, 0.000000, -0.000000, 0.999992, -0.003397, 0.002252, 0.003462, 0.999559, -0.029487, -0.002151, 0.029495, 0.999563),["RightLowerArm"]=CFrame.new(-0.011635, -0.043157, -0.003740, 1.000000, 0.000000, 0.000000, -0.000000, 0.999905, 0.013814, -0.000000, -0.013814, 0.999905),["RightLowerLeg"]=CFrame.new(-0.000000, -0.125779, -0.001624, 1.000000, -0.000000, -0.000000, 0.000000, 1.000000, -0.000002, 0.000000, -0.000005, 1.000000),["RightUpperArm"]=CFrame.new(-0.314513, -3.740587, 1.164531, -0.994719, 0.102592, -0.003102, -0.088838, -0.845436, 0.526636, 0.051406, 0.524130, 0.850085),["RightUpperLeg"]=CFrame.new(-0.016717, -0.066244, -0.093048, 0.996276, -0.084933, -0.014884, -0.020450, -0.065504, -0.997642, 0.083757, 0.994231, -0.066993),["UpperTorso"]=CFrame.new(-0.027830, -0.009629, -0.021869, 0.999058, 0.006402, 0.042925, -0.002019, 0.994846, -0.101379, -0.043352, 0.101197, 0.993921)}},
{t=1.300,d={["Head"]=CFrame.new(-0.003107, 0.068928, 0.157247, 0.999866, 0.005966, -0.015255, -0.006001, 0.999979, -0.002284, 0.015241, 0.002375, 0.999881),["LeftFoot"]=CFrame.new(-0.000000, -0.141663, -0.000003, 0.987852, -0.118865, -0.100088, 0.143006, 0.947428, 0.286261, 0.060801, -0.297071, 0.952910),["LeftHand"]=CFrame.new(0.000500, 0.000100, -0.000000, 0.998674, 0.033727, 0.038897, -0.034986, 0.998870, 0.032161, -0.037768, -0.033478, 0.998726),["LeftLowerArm"]=CFrame.new(0.005665, -0.027820, 0.010666, 1.000000, 0.000000, -0.000000, 0.000000, 0.998699, -0.050997, 0.000000, 0.050996, 0.998699),["LeftLowerLeg"]=CFrame.new(0.000000, -0.140779, -0.001766, 1.000000, -0.000000, 0.000000, -0.000000, 1.000000, -0.000007, 0.000000, -0.000010, 1.000000),["LeftUpperArm"]=CFrame.new(0.034641, 0.291085, -0.014621, 0.883712, -0.436894, -0.167857, 0.461559, 0.754080, 0.467255, -0.077563, -0.490394, 0.868042),["LeftUpperLeg"]=CFrame.new(-0.000723, -0.097399, -0.061041, 0.979280, 0.186136, 0.079762, 0.098712, -0.094838, -0.990588, -0.176824, 0.977936, -0.111240),["LowerTorso"]=CFrame.new(-0.101855, 0.262032, 0.670081, 0.999442, 0.014561, -0.030047, 0.026585, 0.197441, 0.979954, 0.020202, -0.980207, 0.196944),["RightFoot"]=CFrame.new(0.000000, -0.130479, -0.000100, 0.989244, 0.111903, 0.094227, -0.136153, 0.939844, 0.313317, -0.053458, -0.322754, 0.944962),["RightHand"]=CFrame.new(-0.000500, -0.000000, -0.000000, 0.999992, -0.003397, 0.002252, 0.003462, 0.999559, -0.029487, -0.002151, 0.029495, 0.999563),["RightLowerArm"]=CFrame.new(-0.011635, -0.043157, -0.003740, 1.000000, 0.000000, 0.000000, -0.000000, 0.999905, 0.013814, -0.000000, -0.013814, 0.999905),["RightLowerLeg"]=CFrame.new(-0.000000, -0.129630, -0.001675, 1.000000, -0.000000, -0.000000, 0.000000, 1.000000, -0.000002, 0.000000, -0.000005, 1.000000),["RightUpperArm"]=CFrame.new(-0.311600, -3.859180, 1.203874, -0.994719, 0.102592, -0.003102, -0.088838, -0.845436, 0.526636, 0.051406, 0.524130, 0.850085),["RightUpperLeg"]=CFrame.new(-0.016717, -0.066244, -0.093048, 0.996350, -0.084315, -0.013377, -0.020064, -0.079418, -0.996639, 0.082969, 0.993269, -0.080815),["UpperTorso"]=CFrame.new(-0.028417, 0.018873, -0.027596, 0.999058, 0.006402, 0.042925, -0.002019, 0.994846, -0.101379, -0.043352, 0.101197, 0.993921)}},
{t=1.333,d={["Head"]=CFrame.new(-0.003107, 0.068928, 0.157247, 0.999864, 0.006038, -0.015367, -0.005978, 0.999974, 0.003996, 0.015391, -0.003903, 0.999874),["LeftFoot"]=CFrame.new(-0.000000, -0.142633, -0.000003, 0.987914, -0.118565, -0.099835, 0.142833, 0.946545, 0.289256, 0.060204, -0.299993, 0.952031),["LeftHand"]=CFrame.new(0.000500, 0.000100, -0.000000, 0.998674, 0.033727, 0.038897, -0.034986, 0.998870, 0.032161, -0.037768, -0.033478, 0.998726),["LeftLowerArm"]=CFrame.new(0.005666, -0.027820, 0.010667, 1.000000, -0.000000, -0.000000, 0.000000, 0.998699, -0.050997, 0.000000, 0.050996, 0.998699),["LeftLowerLeg"]=CFrame.new(-0.000000, -0.141746, -0.001778, 1.000000, 0.000000, 0.000000, -0.000000, 1.000000, -0.000007, 0.000000, -0.000010, 1.000000),["LeftUpperArm"]=CFrame.new(0.033615, 0.291015, -0.014617, 0.881603, -0.440807, -0.168714, 0.465370, 0.752146, 0.466591, -0.078779, -0.489863, 0.868233),["LeftUpperLeg"]=CFrame.new(-0.000723, -0.097399, -0.061041, 0.979360, 0.186024, 0.079032, 0.098524, -0.097949, -0.990304, -0.176484, 0.977651, -0.114249),["LowerTorso"]=CFrame.new(-0.101855, 0.262032, 0.676735, 0.999442, 0.014561, -0.030047, 0.026585, 0.197441, 0.979954, 0.020202, -0.980207, 0.196944),["RightFoot"]=CFrame.new(-0.000000, -0.131390, -0.000100, 0.989274, 0.111752, 0.094100, -0.136139, 0.938836, 0.316332, -0.052954, -0.325727, 0.943970),["RightHand"]=CFrame.new(-0.000500, 0.000000, -0.000000, 0.999992, -0.003397, 0.002252, 0.003462, 0.999559, -0.029487, -0.002151, 0.029495, 0.999563),["RightLowerArm"]=CFrame.new(-0.011635, -0.043157, -0.003740, 1.000000, 0.000000, 0.000000, -0.000000, 0.999905, 0.013814, -0.000000, -0.013814, 0.999905),["RightLowerLeg"]=CFrame.new(-0.000000, -0.130538, -0.001687, 1.000000, -0.000000, -0.000000, 0.000000, 1.000000, -0.000001, 0.000000, -0.000005, 1.000000),["RightUpperArm"]=CFrame.new(-0.310806, -3.885396, 1.212890, -0.994719, 0.102592, -0.003102, -0.088838, -0.845436, 0.526636, 0.051406, 0.524130, 0.850085),["RightUpperLeg"]=CFrame.new(-0.016717, -0.066244, -0.093048, 0.996367, -0.084172, -0.013037, -0.019976, -0.082584, -0.996384, 0.082790, 0.993023, -0.083961),["UpperTorso"]=CFrame.new(-0.028552, 0.025395, -0.028906, 0.999058, 0.006402, 0.042925, -0.002019, 0.994846, -0.101379, -0.043352, 0.101197, 0.993921)}}
}

local function playArchAnim(char, duration)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    -- Disable animate script
    local animScript = char:FindFirstChild("Animate")
    if animScript then animScript.Disabled = true end
    -- Stop all playing tracks
    pcall(function()
        for _,t in pairs(hum:GetPlayingAnimationTracks()) do t:Stop(0) end
    end)
    hum.PlatformStand = true

    -- Map bone names to Motor6D joints
    local function getJoint(boneName)
        for _,d in pairs(char:GetDescendants()) do
            if d:IsA("Motor6D") and d.Name == boneName then return d end
        end
        return nil
    end

    local startTime = tick()
    local totalDur = ARCH_KFS[#ARCH_KFS].t  -- animation duration from keyframes
    local loops = math.max(1, math.floor(duration / totalDur))
    local conn
    conn = RunService.RenderStepped:Connect(function()
        local elapsed = (tick() - startTime) % totalDur
        -- Find surrounding keyframes
        local kfA, kfB = ARCH_KFS[1], ARCH_KFS[#ARCH_KFS]
        for i = 1, #ARCH_KFS - 1 do
            if ARCH_KFS[i].t <= elapsed and ARCH_KFS[i+1].t >= elapsed then
                kfA = ARCH_KFS[i]; kfB = ARCH_KFS[i+1]; break
            end
        end
        -- Interpolation factor
        local span = kfB.t - kfA.t
        local alpha = span > 0 and ((elapsed - kfA.t) / span) or 0
        -- Apply to joints
        for boneName, cfA in pairs(kfA.d) do
            local cfB = kfB.d[boneName]
            if cfB then
                local j = getJoint(boneName)
                if j then
                    j.Transform = cfA:Lerp(cfB, alpha)
                end
            end
        end
        -- Stop after duration
        if tick() - startTime >= duration then
            conn:Disconnect()
            pcall(function()
                hum.PlatformStand = false
                if animScript then animScript.Disabled = false end
                for _,t in pairs(hum:GetPlayingAnimationTracks()) do t:Stop(0) end
                -- Reset all joint transforms
                for _,d in pairs(char:GetDescendants()) do
                    if d:IsA("Motor6D") then d.Transform = CFrame.new() end
                end
            end)
        end
    end)
end

-- Admin command receiver (other owners write to this to control us)


-- Listen for admin commands sent to us
local _freezeConn2 = nil
myCmdVal.Changed:Connect(function(val)
    if val == "" then return end
    myCmdVal.Value = ""  -- consume immediately
    task.spawn(function()
        if val == "freeze" then
            -- Freeze ourselves in place
            local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end
            local frozenCF = hrp.CFrame
            hum.WalkSpeed = 0; hum.JumpPower = 0
            if _freezeConn2 then _freezeConn2:Disconnect() end
            _freezeConn2 = RunService.Heartbeat:Connect(function()
                pcall(function()
                    hrp.CFrame = frozenCF
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end)
            end)
        elseif val == "unfreeze" then
            if _freezeConn2 then _freezeConn2:Disconnect(); _freezeConn2=nil end
            pcall(function()
                local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed=16; hum.JumpPower=50 end
            end)
        elseif val:sub(1,4) == "msg:" then
            local msg = val:sub(5)
            pcall(function()
                local TCS = game:GetService("TextChatService")
                local ch = TCS:FindFirstChild("TextChannels") and TCS.TextChannels:FindFirstChildOfClass("TextChannel")
                if ch then ch:SendAsync(msg)
                else game:GetService("Players").LocalPlayer:Chat(msg) end
            end)
        elseif val == "flashbang" then
            pcall(function()
                local flash=Instance.new("Frame"); flash.Size=UDim2.new(1,0,1,0)
                flash.Position=UDim2.new(0,0,0,0); flash.BackgroundColor3=Color3.fromRGB(255,255,255)
                flash.BackgroundTransparency=0; flash.ZIndex=999; flash.BorderSizePixel=0
                flash.Parent=ScreenGui
                TweenService:Create(flash,TweenInfo.new(1.8,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=1}):Play()
                task.delay(1.9,function() if flash and flash.Parent then flash:Destroy() end end)
            end)
        elseif val == "fakeban_on" then
            pcall(function()
                local fbg=Instance.new("ScreenGui"); fbg.Name="ACFakeBan2"; fbg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
                fbg.DisplayOrder=9998; fbg.IgnoreGuiInset=true; fbg.ResetOnSpawn=false
                pcall(function() fbg.Parent=CoreGui end)
                local bg=Instance.new("Frame"); bg.Size=UDim2.new(1,0,1,0); bg.BackgroundColor3=Color3.fromRGB(8,8,12); bg.BorderSizePixel=0; bg.ZIndex=1; bg.Parent=fbg
                mkLabel(bg,"X",{Size=UDim2.new(0,80,0,80),Position=UDim2.new(0.5,-40,0.28,0),TextSize=60,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(220,50,50),TextXAlignment=Enum.TextXAlignment.Center,ZIndex=2})
                mkLabel(bg,"You have been banned from Roblox",{Size=UDim2.new(0.8,0,0,44),Position=UDim2.new(0.1,0,0.42,0),TextSize=26,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(230,230,230),TextXAlignment=Enum.TextXAlignment.Center,ZIndex=2})
                mkLabel(bg,"Reason: Exploiting / Terms of Service Violation",{Size=UDim2.new(0.7,0,0,26),Position=UDim2.new(0.15,0,0.52,0),TextSize=14,Font=Enum.Font.Gotham,TextColor3=Color3.fromRGB(180,80,80),TextXAlignment=Enum.TextXAlignment.Center,ZIndex=2})
                mkLabel(bg,"Ban ID: #"..math.random(100000000,999999999).."  |  Error Code: 403",{Size=UDim2.new(0.6,0,0,18),Position=UDim2.new(0.2,0,0.60,0),TextSize=11,Font=Enum.Font.Gotham,TextColor3=Color3.fromRGB(100,100,100),TextXAlignment=Enum.TextXAlignment.Center,ZIndex=2})
                task.delay(5,function() if fbg and fbg.Parent then fbg:Destroy() end end)
            end)
        elseif val == "drunk_on" then
            local t=0; local dc=RunService.RenderStepped:Connect(function(dt)
                t=t+dt; pcall(function() local cam=workspace.CurrentCamera; cam.CFrame=cam.CFrame*CFrame.Angles(math.sin(t*1.1)*0.04,math.sin(t*0.75)*0.07,math.sin(t*1.6)*0.025) end)
            end)
            task.delay(3,function() dc:Disconnect() end)
        elseif val == "flip_on" then
            local t=0; local fc=RunService.RenderStepped:Connect(function(dt)
                t=t+dt; pcall(function() local cam=workspace.CurrentCamera; cam.CFrame=cam.CFrame*CFrame.Angles(0,0,math.sin(t*12)*math.pi*0.9) end)
            end)
            task.delay(3,function() fc:Disconnect() end)
        elseif val == "arch" then
            pcall(function()
                local char=lp.Character; if not char then return end
                -- Play custom keyframe animation
                task.spawn(function() playArchAnim(char, 8) end)
                -- Send chat message after brief delay
                task.delay(0.5, function()
                    pcall(function()
                        local TCS=game:GetService("TextChatService")
                        local ch=TCS:FindFirstChild("TextChannels") and TCS.TextChannels:FindFirstChildOfClass("TextChannel")
                        if ch then ch:SendAsync("Help me")
                        else lp:Chat("Help me") end
                    end)
                end)
            end)
        end
    end)
end)

-- Update what we're watching
-- Active watcher cards table
local watcherCards = {}

local function makeWatcherCard(plrObj, order)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1,0,0,44); card.BackgroundColor3 = Color3.fromRGB(8,8,12)
    card.BackgroundTransparency = 0.25; card.BorderSizePixel = 0
    card.LayoutOrder = order; card.ZIndex = 11; card.Parent = specCards
    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0,8); cc.Parent = card
    local cs = Instance.new("UIStroke"); cs.Thickness = 1.2
    cs.Color = Color3.fromRGB(0,200,70); cs.Parent = card
    -- Avatar pfp
    local pfp = Instance.new("ImageLabel")
    pfp.Size = UDim2.new(0,34,0,34); pfp.Position = UDim2.new(0,5,0.5,-17)
    pfp.BackgroundColor3 = Color3.fromRGB(20,20,20); pfp.BorderSizePixel = 0
    pfp.ZIndex = 12; pfp.Parent = card
    local pfpCorner = Instance.new("UICorner"); pfpCorner.CornerRadius = UDim.new(1,0); pfpCorner.Parent = pfp
    pcall(function()
        pfp.Image = Players:GetUserThumbnailAsync(plrObj.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size48x48)
    end)
    -- Name label
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1,-48,0,20); nameLbl.Position = UDim2.new(0,44,0,4)
    nameLbl.BackgroundTransparency = 1; nameLbl.ZIndex = 12
    nameLbl.Text = "@"..plrObj.Name; nameLbl.TextColor3 = Color3.fromRGB(255,255,255)
    nameLbl.TextSize = 11; nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd; nameLbl.Parent = card
    -- Display name label
    local dispLbl = Instance.new("TextLabel")
    dispLbl.Size = UDim2.new(1,-48,0,16); dispLbl.Position = UDim2.new(0,44,0,24)
    dispLbl.BackgroundTransparency = 1; dispLbl.ZIndex = 12
    dispLbl.Text = plrObj.DisplayName; dispLbl.TextColor3 = Color3.fromRGB(160,160,160)
    dispLbl.TextSize = 10; dispLbl.Font = Enum.Font.Gotham
    dispLbl.TextXAlignment = Enum.TextXAlignment.Left
    dispLbl.TextTruncate = Enum.TextTruncate.AtEnd; dispLbl.Parent = card
    -- Live indicator dot
    local liveDot = Instance.new("Frame")
    liveDot.Size = UDim2.new(0,7,0,7); liveDot.Position = UDim2.new(1,-12,0,8)
    liveDot.BackgroundColor3 = Color3.fromRGB(0,220,80); liveDot.BorderSizePixel = 0
    liveDot.ZIndex = 12; liveDot.Parent = card
    local ldc = Instance.new("UICorner"); ldc.CornerRadius = UDim.new(1,0); ldc.Parent = liveDot
    return card
end

-- Pulse animation on main dot
local pulseTween1 = TweenService:Create(specDot, TweenInfo.new(0.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,math.huge,true),
    {Size=UDim2.new(0,24,0,24), BackgroundTransparency=0.3})
local pulseTween2 = TweenService:Create(specDot, TweenInfo.new(0.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,math.huge,true),
    {BackgroundTransparency=1})
pulseTween2:Play()

-- Poll loop: scan workspace for AC_Watching_* values targeting us
local specPollConn = RunService.Heartbeat:Connect(function()
    local myId = tostring(lp.UserId)
    local watching = {}
    pcall(function()
        for _,v in pairs(workspace:GetChildren()) do
            if v:IsA("StringValue") and v.Name:sub(1,12)=="AC_Watching_" then
                local watcherId = v.Name:sub(13)
                if v.Value == myId and watcherId ~= myId then
                    watching[watcherId] = true
                end
            end
        end
    end)
    -- Add new watchers
    for wId in pairs(watching) do
        if not watcherCards[wId] then
            local plrObj = Players:GetPlayerByUserId(tonumber(wId))
            if plrObj then
                watcherCards[wId] = makeWatcherCard(plrObj, tonumber(wId))
            end
        end
    end
    -- Remove gone watchers
    for wId, card in pairs(watcherCards) do
        if not watching[wId] then
            pcall(function() card:Destroy() end)
            watcherCards[wId] = nil
        end
    end
    -- Update count + dot visibility
    local count = 0; for _ in pairs(watcherCards) do count=count+1 end
    specCards.Size = UDim2.new(0,220,0,count*48)
    if count > 0 then
        specDot.BackgroundTransparency = 0
        specDot.BackgroundColor3 = Color3.fromRGB(0,220,80)
        pulseTween1:Play(); pulseTween2:Cancel()
        specCount.Text = tostring(count).." "
    else
        pulseTween1:Cancel(); pulseTween2:Play()
        specDot.BackgroundTransparency = 1
        specCount.Text = ""
    end
end)

-- Hook doView to broadcast our target
local Win=Instance.new("Frame")
Win.Name="Window"; Win.Size=UDim2.new(0,WIN_W,0,WIN_H); Win.Position=UDim2.new(0,16,0.5,-WIN_H/2)
Win.BackgroundColor3=Color3.fromRGB(0,0,0); Win.BackgroundTransparency=0.18; Win.BorderSizePixel=0; Win.ZIndex=2; Win.Parent=ScreenGui; Win.Visible=false
corner(Win,14); mkStroke(Win,C.sep,3)
do local _wst=Win:FindFirstChildOfClass("UIStroke"); if _wst then local _wg=Instance.new("UIGradient"); _wg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(0.25,Color3.fromRGB(120,0,110)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(0,0,0)),ColorSequenceKeypoint.new(0.75,Color3.fromRGB(120,0,110)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))}); _wg.Parent=_wst; RunService.Heartbeat:Connect(function() if _wg.Parent then _wg.Rotation=(_wg.Rotation+1)%360 end end) end end

local _acSubPanelDragging=false

do
    local dragging,ds,sp,moved=false,nil,nil,false
    local DZ=mkFrame(Win,{Size=UDim2.new(1,0,0,HEADER_H),BackgroundTransparency=1,ZIndex=30})
    DZ.InputBegan:Connect(function(i)
        if _acSubPanelDragging then return end
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true; moved=false; ds=i.Position; sp=Win.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and not _acSubPanelDragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-ds
            if not moved and (math.abs(d.X)>4 or math.abs(d.Y)>4) then moved=true end
            if moved then Win.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end
        end
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
end

local Header=mkFrame(Win,{Name="Header",Size=UDim2.new(1,0,0,HEADER_H),BackgroundColor3=Color3.fromRGB(0,0,0),BackgroundTransparency=1,ZIndex=5})
mkLabel(Header,"AudioCrafter",{Size=UDim2.new(0,160,0,22),Position=UDim2.new(0,16,0,6),TextSize=15,Font=Enum.Font.GothamBlack,TextColor3=C.white,ZIndex=6})
mkLabel(Header,"by MelodyCrafter",{Size=UDim2.new(0,160,0,14),Position=UDim2.new(0,16,0,28),TextSize=10,Font=Enum.Font.Gotham,TextColor3=C.txtDim,ZIndex=6})
mkFrame(Header,{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=C.sep,ZIndex=6})

do
    local cxBase=175
    for i,preset in ipairs(THEME_PRESETS) do
        local circle=Instance.new("TextButton")
        circle.Name="ThemeCircle"; circle.Size=UDim2.new(0,18,0,18); circle.Position=UDim2.new(0,cxBase+(i-1)*24,0.5,-9)
        circle.BackgroundColor3=preset.color; circle.BorderSizePixel=0; circle.Text=""; circle.AutoButtonColor=false; circle.ZIndex=7; circle.Parent=Header
        local uc=Instance.new("UICorner"); uc.CornerRadius=UDim.new(1,0); uc.Parent=circle
        local us=Instance.new("UIStroke"); us.Color=Color3.fromRGB(255,255,255); us.Thickness=1.5; us.Parent=circle
        local pt=preset; circle.Activated:Connect(function() applyTheme(pt) end)
    end
end

local UnloadBtn=mkBtn(Header,"Unload",{Size=UDim2.new(0,54,0,22),Position=UDim2.new(1,-257,0.5,-11),TextSize=10,Font=Enum.Font.GothamBold,ZIndex=6})
corner(UnloadBtn,5); hov(UnloadBtn,C.purple,Color3.fromRGB(120,20,20))
do local _s=mkStroke(UnloadBtn,C.sep,2); local _g=Instance.new("UIGradient"); _g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(0.25,Color3.fromRGB(120,0,110)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(10,10,10)),ColorSequenceKeypoint.new(0.75,Color3.fromRGB(120,0,110)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))}); _g.Parent=_s; RunService.Heartbeat:Connect(function() if _s.Parent then _g.Rotation=(_g.Rotation+1)%360 end end) end
UnloadBtn.Activated:Connect(function()
    acUnloaded = true  -- stops poll loop and blocks any new tags
    -- 1. Disconnect all persistent RunService/event connections
    pcall(function() if acSelfTagConn then acSelfTagConn:Disconnect(); acSelfTagConn=nil end end)
    pcall(function() if specPollConn1 then specPollConn1:Disconnect(); specPollConn1=nil end end)
    pcall(function() if specPollConn then specPollConn:Disconnect() end end)
    pcall(function() if antiFlingConn then antiFlingConn:Disconnect(); antiFlingConn=nil end end)
    pcall(function() if akUpdateConn then akUpdateConn:Disconnect(); akUpdateConn=nil end end)
    pcall(function() if _freezeConn2 then _freezeConn2:Disconnect(); _freezeConn2=nil end end)
    pcall(function() if clickTPConn then clickTPConn:Disconnect(); clickTPConn=nil end end)
    -- 2. Destroy workspace presence/command values
    pcall(function() myWatchVal:Destroy() end)
    pcall(function() myCmdVal:Destroy() end)
    -- 3. Remove all AC_Tag BillboardGuis from every player
    pcall(function()
        for _,plr in ipairs(Players:GetPlayers()) do
            local char=plr.Character
            if char then
                local head=char:FindFirstChild("Head")
                if head then
                    local tag=head:FindFirstChild("AC_Tag")
                    if tag then tag:Destroy() end
                end
            end
        end
    end)
    -- 4. Clean up baseplate part if active
    pcall(function() if basePart then basePart:Destroy(); basePart=nil end end)
    -- 5. Stop anim copier ghost clone
    pcall(function() if akGhostClone then akGhostClone:Destroy(); akGhostClone=nil end end)
    -- 6. Destroy all ScreenGuis
    pcall(function() specHudGui:Destroy() end)
    pcall(function() statsGui:Destroy() end)
    pcall(function() local kg=CoreGui:FindFirstChild("AC_KeyGui"); if kg then kg:Destroy() end end)
    pcall(function() local wg=CoreGui:FindFirstChild("AC_OwnerWelcome"); if wg then wg:Destroy() end end)
    pcall(function() Win:Destroy() end)
    pcall(function() ScreenGui:Destroy() end)
    -- 7. Clear shared globals
    pcall(function() _G.__AC_REGISTRY=nil end)
    pcall(function() _G.__AK_ADMIN_EXECUTED=nil end)
    pcall(function() _G.VERIFIED_VALUES=nil end)
    pcall(function() _G.bp=nil end)
end)

local NTagBtn=mkBtn(Header,"Tags: ON",{Size=UDim2.new(0,58,0,22),Position=UDim2.new(1,-195,0.5,-11),TextSize=10,Font=Enum.Font.GothamBold,ZIndex=6})
corner(NTagBtn,5); hov(NTagBtn,C.purple,C.purpleDim)
do local _s=mkStroke(NTagBtn,C.sep,2); local _g=Instance.new("UIGradient"); _g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(0.25,Color3.fromRGB(120,0,110)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(10,10,10)),ColorSequenceKeypoint.new(0.75,Color3.fromRGB(120,0,110)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))}); _g.Parent=_s; RunService.Heartbeat:Connect(function() if _s.Parent then _g.Rotation=(_g.Rotation+1)%360 end end) end
NTagBtn.Activated:Connect(function()
    nameTagsEnabled=not nameTagsEnabled
    NTagBtn.Text=nameTagsEnabled and "Tags: ON" or "Tags: OFF"
    NTagBtn.BackgroundColor3=nameTagsEnabled and C.purple or C.off
    -- Show/hide all existing tags
    pcall(function()
        for _,bb in pairs(activeTags or {}) do
            if bb and bb.Parent then bb.Enabled=nameTagsEnabled end
        end
    end)
end)

local openKey=Enum.KeyCode.G; local listeningKey=false
local function keyName(kc) return (tostring(kc):match("KeyCode%.(.+)") or tostring(kc)) end

local KeyBtn=mkBtn(Header,"Key: G",{Size=UDim2.new(0,62,0,22),Position=UDim2.new(1,-130,0.5,-11),TextSize=10,Font=Enum.Font.Gotham,ZIndex=6})
corner(KeyBtn,5); hov(KeyBtn,C.purple,C.purpleDim)
do local _s=mkStroke(KeyBtn,C.sep,2); local _g=Instance.new("UIGradient"); _g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(0.25,Color3.fromRGB(120,0,110)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(10,10,10)),ColorSequenceKeypoint.new(0.75,Color3.fromRGB(120,0,110)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))}); _g.Parent=_s; RunService.Heartbeat:Connect(function() if _s.Parent then _g.Rotation=(_g.Rotation+1)%360 end end) end

local CloseBtn=mkBtn(Header,"x",{Size=UDim2.new(0,24,0,22),Position=UDim2.new(1,-56,0.5,-11),TextSize=13,Font=Enum.Font.GothamBold,ZIndex=6})
corner(CloseBtn,5); hov(CloseBtn,C.purple,Color3.fromRGB(160,30,30))
do local _s=mkStroke(CloseBtn,C.sep,2); local _g=Instance.new("UIGradient"); _g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(0.25,Color3.fromRGB(120,0,110)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(10,10,10)),ColorSequenceKeypoint.new(0.75,Color3.fromRGB(120,0,110)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))}); _g.Parent=_s; RunService.Heartbeat:Connect(function() if _s.Parent then _g.Rotation=(_g.Rotation+1)%360 end end) end
CloseBtn.Activated:Connect(function() Win.Visible=false end)
KeyBtn.Activated:Connect(function() if listeningKey then return end; listeningKey=true; KeyBtn.Text="..."; KeyBtn.BackgroundColor3=C.purpleDim end)
UserInputService.InputBegan:Connect(function(inp,gp)
    if gp then return end
    if listeningKey and inp.UserInputType==Enum.UserInputType.Keyboard then
        openKey=inp.KeyCode; KeyBtn.Text="Key: "..keyName(inp.KeyCode); KeyBtn.BackgroundColor3=C.purple; listeningKey=false
    elseif not listeningKey and inp.UserInputType==Enum.UserInputType.Keyboard and inp.KeyCode==openKey then
        if keyValidated then Win.Visible=not Win.Visible end
    end
end)

local ContentArea=mkFrame(Win,{Name="Content",Size=UDim2.new(1,0,0,CONTENT_H),Position=UDim2.new(0,0,0,HEADER_H),BackgroundColor3=Color3.fromRGB(0,0,0),BackgroundTransparency=1,ZIndex=2})
mkFrame(Win,{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-(TABBAR_H+1)),BackgroundColor3=C.sep,ZIndex=6})
local TabBar=mkFrame(Win,{Name="TabBar",BackgroundTransparency=1,Size=UDim2.new(1,0,0,TABBAR_H),Position=UDim2.new(0,0,1,-TABBAR_H),BackgroundColor3=Color3.fromRGB(0,0,0),ZIndex=5})
do
    local tl=Instance.new("UIListLayout"); tl.FillDirection=Enum.FillDirection.Horizontal; tl.HorizontalAlignment=Enum.HorizontalAlignment.Center; tl.VerticalAlignment=Enum.VerticalAlignment.Center; tl.SortOrder=Enum.SortOrder.LayoutOrder; tl.Padding=UDim.new(0,4); tl.Parent=TabBar
    local tp=Instance.new("UIPadding"); tp.PaddingLeft=UDim.new(0,6); tp.PaddingRight=UDim.new(0,6); tp.Parent=TabBar
end

local pages={}; local pageData={}; local tabBtns={}
local TAB_W=math.floor(WIN_W/#TABS)

local function switchPage(index)
    for i,pg in pairs(pages) do pg.Visible=(i==index) end
    for i,tb in pairs(tabBtns) do tb.TextColor3=(i==index) and C.white or C.txtDim; tb.BackgroundColor3=(i==index) and C.purple or C.tabBar end
end

for i,tabData in ipairs(TABS) do
    local tabBtn=mkBtn(TabBar,tabData.name,{Name="Tab_"..tabData.name,Size=UDim2.new(0,TAB_W-8,0,28),BackgroundColor3=C.tabBar,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=C.txtDim,LayoutOrder=i,ZIndex=6})
    corner(tabBtn,14); mkStroke(tabBtn,C.sep,3); tabBtns[i]=tabBtn
    do local _ts=mkStroke(tabBtn,C.sep,2); local _tg=Instance.new("UIGradient"); _tg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(0.25,Color3.fromRGB(120,0,110)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(10,10,10)),ColorSequenceKeypoint.new(0.75,Color3.fromRGB(120,0,110)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))}); _tg.Parent=_ts; RunService.Heartbeat:Connect(function() if _ts.Parent then _tg.Rotation=(_tg.Rotation+1)%360 end end) end
    local page=mkFrame(ContentArea,{Name="Page_"..tabData.name,Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(0,0,0),BackgroundTransparency=1,Visible=false,ZIndex=2})
    pages[i]=page
    local scroll=Instance.new("ScrollingFrame"); scroll.Name="Scroll"; scroll.Size=UDim2.new(1,-4,1,0)
    scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0; scroll.ScrollBarThickness=3; scroll.ScrollBarImageColor3=C.purple
    scroll.CanvasSize=UDim2.new(0,0,0,0); scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; scroll.ZIndex=3; scroll.Parent=page
    local rl=Instance.new("UIListLayout"); rl.FillDirection=Enum.FillDirection.Vertical; rl.HorizontalAlignment=Enum.HorizontalAlignment.Left; rl.SortOrder=Enum.SortOrder.LayoutOrder; rl.Padding=UDim.new(0,6); rl.Parent=scroll
    local rp=Instance.new("UIPadding"); rp.PaddingTop=UDim.new(0,14); rp.PaddingLeft=UDim.new(0,14); rp.PaddingRight=UDim.new(0,14); rp.PaddingBottom=UDim.new(0,14); rp.Parent=scroll
    pageData[i]={scroll=scroll,nextOrder=1}
    tabBtn.Activated:Connect(function() switchPage(i) end)
end

nextOrder = function(pi) local n=pageData[pi].nextOrder; pageData[pi].nextOrder=n+1; return n end

-- -- HOME TAB -------------------------------------------------
do
    local s=pageData[1].scroll; local idx=1
    local topRow=mkFrame(s,{Size=UDim2.new(1,0,0,180),BackgroundTransparency=1,LayoutOrder=nextOrder(idx),ZIndex=4})
    local wCard=mkFrame(topRow,{Size=UDim2.new(1,-214,1,0),BackgroundColor3=C.cardDark,ZIndex=4})
    corner(wCard,10); mkStroke(wCard,C.sep,3)
    mkLabel(wCard,"Welcome, "..lp.Name.."!",{Size=UDim2.new(1,-16,0,28),Position=UDim2.new(0,14,0,14),TextSize=18,Font=Enum.Font.GothamBlack,TextColor3=C.white,ZIndex=5})
    mkLabel(wCard,"AC AudioCrafter is loaded and ready.",{Size=UDim2.new(1,-16,0,20),Position=UDim2.new(0,14,0,50),TextSize=11,Font=Enum.Font.Gotham,TextColor3=Color3.fromRGB(180,180,180),ZIndex=5})
    if IS_OWNER then mkLabel(wCard,"Owner Access Granted",{Size=UDim2.new(1,-16,0,18),Position=UDim2.new(0,14,0,76),TextSize=11,Font=Enum.Font.GothamBold,TextColor3=C.green,ZIndex=5}) end
    local infoCol=mkFrame(topRow,{Size=UDim2.new(0,200,1,0),Position=UDim2.new(1,-200,0,0),BackgroundTransparency=1,ZIndex=4})
    local execName="Unknown"
    pcall(function() execName=(identifyexecutor and identifyexecutor()) or (getexecutorname and getexecutorname()) or "Executor" end)
    local function infoCard(lbl,val,vc,slot)
        local yy=(slot-1)*62
        local card=mkFrame(infoCol,{Size=UDim2.new(1,0,0,56),Position=UDim2.new(0,0,0,yy),BackgroundColor3=C.cardDark,ZIndex=5})
        corner(card,10); mkStroke(card,C.sep,3)
        mkLabel(card,lbl,{Size=UDim2.new(1,-12,0,14),Position=UDim2.new(0,10,0,6),TextSize=10,TextColor3=C.txtDim,Font=Enum.Font.Gotham,ZIndex=6})
        mkLabel(card,val,{Size=UDim2.new(1,-12,0,24),Position=UDim2.new(0,10,0,24),TextSize=15,Font=Enum.Font.GothamBold,TextColor3=vc or C.white,ZIndex=6})
    end
    infoCard("Version","v1.8",C.white,1); infoCard("Status","Loaded",C.green,2); infoCard("Executor",execName,C.white,3)
    secLabel(s,"CHANGELOG",idx)
    for _,entry in ipairs(CHANGELOG) do
        local eCard=mkFrame(s,{Size=UDim2.new(1,0,0,76),BackgroundColor3=C.cardDark,LayoutOrder=nextOrder(idx),ZIndex=4})
        corner(eCard,10); mkStroke(eCard,C.sep,3)
        mkLabel(eCard,entry.ver,{Size=UDim2.new(1,-12,0,16),Position=UDim2.new(0,12,0,8),TextSize=11,TextColor3=C.txtDim,Font=Enum.Font.GothamBold,ZIndex=5})
        mkLabel(eCard,entry.title,{Size=UDim2.new(1,-12,0,18),Position=UDim2.new(0,12,0,26),TextSize=14,Font=Enum.Font.GothamBold,TextColor3=C.white,ZIndex=5})
        mkLabel(eCard,entry.desc,{Size=UDim2.new(1,-12,0,18),Position=UDim2.new(0,12,0,48),TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.txtDim,ZIndex=5})
    end
end

-- -- PLAYER TAB -----------------------------------------------
do
    local s=pageData[2].scroll; local idx=2
    local wsConn=nil; local currentWS=16; local currentJP=50
    -- SB-style velocity asset for position locks
    local _sbVelAsset=Instance.new("BodyAngularVelocity")
    _sbVelAsset.AngularVelocity=Vector3.new(0,0,0); _sbVelAsset.MaxTorque=Vector3.new(50000,50000,50000); _sbVelAsset.P=1250

    -- Toggle states
    local _viewOn=false; local _focusOn=false; local _flingOn=false
    local _sitOn=false; local _bpOn=false; local _doggyOn=false; local _dragOn=false; local _bangOn=false; local _standOn=false
    local _loopConns={}
    local function killLoop(k) if _loopConns[k] then _loopConns[k]:Disconnect(); _loopConns[k]=nil end end
    local function killAllLoops()
        setWatching(nil)  -- clear spectator broadcast
        for k in pairs(_loopConns) do killLoop(k) end
        _viewOn=false; _focusOn=false; _flingOn=false; _sitOn=false; _bpOn=false; _doggyOn=false; _dragOn=false; _bangOn=false; _standOn=false
        pcall(function() workspace.CurrentCamera.CameraSubject=lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") end)
        pcall(function() local mc=lp.Character; if mc then local h=mc:FindFirstChildOfClass("Humanoid"); if h then h.Sit=false; h.PlatformStand=false end end end)
        pcall(function() local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart"); if hrp then local v=hrp:FindFirstChild("AC_BreakVel"); if v then v:Destroy() end end end)
    end

    local function getTargetRoot() return AC_selectedTarget and AC_selectedTarget.Character and AC_selectedTarget.Character:FindFirstChild("HumanoidRootPart") end
    local function getMyRoot()     return lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") end
    local function getMyHum()      return lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") end
    local function getPing()       return pcall(function() return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()/1000 end) and 0 or 0 end

    local function ensureBreakVel(hrp)
        if not hrp:FindFirstChild("AC_BreakVel") then
            local v=_sbVelAsset:Clone(); v.Name="AC_BreakVel"; v.Parent=hrp
        end
    end

    -- VIEW -- exact SB ViewTarget_Button logic
    local function doView(on)
        _viewOn=on; killLoop("view")
        if on then
            if not AC_selectedTarget then _viewOn=false; return end
            setWatching(AC_selectedTarget.UserId)  -- broadcast to spectator HUD
            _loopConns["view"]=RunService.Heartbeat:Connect(function()
                if not _viewOn then killLoop("view"); return end
                pcall(function() workspace.CurrentCamera.CameraSubject=AC_selectedTarget.Character.Humanoid end)
            end)
        else
            setWatching(nil)  -- clear broadcast
            pcall(function() workspace.CurrentCamera.CameraSubject=lp.Character:FindFirstChildOfClass("Humanoid") end)
        end
    end

    -- FOCUS -- exact SB FocusTarget_Button (TP + Push loop)
    local function doFocus(on)
        _focusOn=on; killLoop("focus")
        if on then
            if not AC_selectedTarget then _focusOn=false; return end
            _loopConns["focus"]=RunService.Heartbeat:Connect(function()
                if not _focusOn then killLoop("focus"); return end
                pcall(function()
                    local tr=getTargetRoot(); if not tr then return end
                    getMyRoot().CFrame=CFrame.new(tr.Position)+Vector3.new(0,2,0)
                end)
            end)
        end
    end

    -- TELEPORT TO -- exact SB TeleportTarget_Button
    local function doTP()
        if not AC_selectedTarget then return end
        pcall(function() getMyRoot().CFrame=CFrame.new(getTargetRoot().Position)+Vector3.new(0,2,0) end)
    end

    -- BRING -- teleport target to us
    local function doBring()
        if not AC_selectedTarget then return end
        pcall(function() local tr=getTargetRoot(); local mr=getMyRoot(); if tr and mr then tr.CFrame=mr.CFrame*CFrame.new(3,0,0) end end)
    end

    -- BANG -- exact SB BenxTarget_Button
    local function doBang(on)
        _bangOn=on; killLoop("bang")
        if on then
            if not AC_selectedTarget then _bangOn=false; return end
            pcall(function()
                local hum=getMyHum()
                if hum then
                    local Anim=Instance.new("Animation"); Anim.AnimationId="rbxassetid:".._sl.."5918726674"
                    hum:LoadAnimation(Anim):Play()
                end
            end)
            _loopConns["bang"]=RunService.Heartbeat:Connect(function()
                if not _bangOn then killLoop("bang"); return end
                pcall(function()
                    local mr=getMyRoot(); local tr=getTargetRoot(); if not mr or not tr then return end
                    ensureBreakVel(mr)
                    mr.CFrame=tr.CFrame*CFrame.new(0,0,1.1)
                    mr.AssemblyLinearVelocity=Vector3.new(0,0,0)
                end)
            end)
        else
            pcall(function() local hum=getMyHum(); if hum then for _,t in pairs(hum:GetPlayingAnimationTracks()) do t:Stop() end end end)
            pcall(function() local hrp=getMyRoot(); if hrp then local v=hrp:FindFirstChild("AC_BreakVel"); if v then v:Destroy() end end end)
        end
    end

    -- HEADSIT -- exact SB HeadsitTarget_Button
    local function doSit(on)
        _sitOn=on; killLoop("sit")
        if on then
            if not AC_selectedTarget then _sitOn=false; return end
            _loopConns["sit"]=RunService.Heartbeat:Connect(function()
                if not _sitOn then killLoop("sit"); return end
                pcall(function()
                    local mr=getMyRoot(); local head=AC_selectedTarget.Character and AC_selectedTarget.Character:FindFirstChild("Head")
                    if not mr or not head then return end
                    ensureBreakVel(mr)
                    getMyHum().Sit=true
                    mr.CFrame=head.CFrame*CFrame.new(0,2,0)
                    mr.AssemblyLinearVelocity=Vector3.new(0,0,0)
                end)
            end)
        else
            pcall(function() local hum=getMyHum(); if hum then hum.Sit=false end end)
            pcall(function() local hrp=getMyRoot(); if hrp then local v=hrp:FindFirstChild("AC_BreakVel"); if v then v:Destroy() end end end)
        end
    end

    -- STAND -- exact SB StandTarget_Button
    local function doStand(on)
        _standOn=on; killLoop("stand")
        if on then
            if not AC_selectedTarget then _standOn=false; return end
            pcall(function()
                local hum=getMyHum()
                if hum then
                    local Anim=Instance.new("Animation"); Anim.AnimationId="rbxassetid:".._sl.."13823324057"
                    hum:LoadAnimation(Anim):Play()
                end
            end)
            _loopConns["stand"]=RunService.Heartbeat:Connect(function()
                if not _standOn then killLoop("stand"); return end
                pcall(function()
                    local mr=getMyRoot(); local tr=getTargetRoot(); if not mr or not tr then return end
                    ensureBreakVel(mr)
                    mr.CFrame=tr.CFrame*CFrame.new(-3,1,0)
                    mr.AssemblyLinearVelocity=Vector3.new(0,0,0)
                end)
            end)
        else
            pcall(function() local hum=getMyHum(); if hum then for _,t in pairs(hum:GetPlayingAnimationTracks()) do t:Stop() end end end)
            pcall(function() local hrp=getMyRoot(); if hrp then local v=hrp:FindFirstChild("AC_BreakVel"); if v then v:Destroy() end end end)
        end
    end

    -- BACKPACK -- exact SB BackpackTarget_Button
    local function doBP(on)
        _bpOn=on; killLoop("bp")
        if on then
            if not AC_selectedTarget then _bpOn=false; return end
            _loopConns["bp"]=RunService.Heartbeat:Connect(function()
                if not _bpOn then killLoop("bp"); return end
                pcall(function()
                    local mr=getMyRoot(); local tr=getTargetRoot(); if not mr or not tr then return end
                    ensureBreakVel(mr)
                    getMyHum().Sit=true
                    mr.CFrame=tr.CFrame*CFrame.new(0,0,1.2)*CFrame.Angles(0,-3,0)
                    mr.AssemblyLinearVelocity=Vector3.new(0,0,0)
                end)
            end)
        else
            pcall(function() local hum=getMyHum(); if hum then hum.Sit=false end end)
            pcall(function() local hrp=getMyRoot(); if hrp then local v=hrp:FindFirstChild("AC_BreakVel"); if v then v:Destroy() end end end)
        end
    end

    -- DOGGY -- exact SB DoggyTarget_Button
    local function doDoggy(on)
        _doggyOn=on; killLoop("doggy")
        if on then
            if not AC_selectedTarget then _doggyOn=false; return end
            pcall(function()
                local hum=getMyHum()
                if hum then
                    local Anim=Instance.new("Animation"); Anim.AnimationId="rbxassetid:".._sl.."13694096724"
                    hum:LoadAnimation(Anim):Play()
                end
            end)
            _loopConns["doggy"]=RunService.Heartbeat:Connect(function()
                if not _doggyOn then killLoop("doggy"); return end
                pcall(function()
                    local mr=getMyRoot()
                    local tLower=AC_selectedTarget.Character and AC_selectedTarget.Character:FindFirstChild("LowerTorso")
                    if not mr or not tLower then return end
                    ensureBreakVel(mr)
                    mr.CFrame=tLower.CFrame*CFrame.new(0,0.23,0)
                    mr.AssemblyLinearVelocity=Vector3.new(0,0,0)
                end)
            end)
        else
            pcall(function() local hum=getMyHum(); if hum then for _,t in pairs(hum:GetPlayingAnimationTracks()) do t:Stop() end end end)
            pcall(function() local hrp=getMyRoot(); if hrp then local v=hrp:FindFirstChild("AC_BreakVel"); if v then v:Destroy() end end end)
        end
    end

    -- DRAG -- exact SB DragTarget_Button
    local function doDrag(on)
        _dragOn=on; killLoop("drag")
        if on then
            if not AC_selectedTarget then _dragOn=false; return end
            pcall(function()
                local hum=getMyHum()
                if hum then
                    local Anim=Instance.new("Animation"); Anim.AnimationId="rbxassetid:".._sl.."10714360343"
                    local t=hum:LoadAnimation(Anim); t:Play(); t.TimePosition=0.5
                end
            end)
            _loopConns["drag"]=RunService.Heartbeat:Connect(function()
                if not _dragOn then killLoop("drag"); return end
                pcall(function()
                    local mr=getMyRoot()
                    local tRH=AC_selectedTarget.Character and AC_selectedTarget.Character:FindFirstChild("RightHand")
                    if not mr or not tRH then return end
                    ensureBreakVel(mr)
                    mr.CFrame=tRH.CFrame*CFrame.new(0,-2.5,1)*CFrame.Angles(-2,-3,0)
                    mr.AssemblyLinearVelocity=Vector3.new(0,0,0)
                end)
            end)
        else
            pcall(function() local hum=getMyHum(); if hum then for _,t in pairs(hum:GetPlayingAnimationTracks()) do t:Stop() end end end)
            pcall(function() local hrp=getMyRoot(); if hrp then local v=hrp:FindFirstChild("AC_BreakVel"); if v then v:Destroy() end end end)
        end
    end

    secLabel(s,"PLAYER SEARCH",idx)
    local searchBox=Instance.new("TextBox"); searchBox.Size=UDim2.new(1,0,0,38); searchBox.BackgroundColor3=C.cardDark; searchBox.BorderSizePixel=0; searchBox.Font=Enum.Font.Gotham; searchBox.TextColor3=C.white; searchBox.PlaceholderText="Type player name..."; searchBox.PlaceholderColor3=C.txtDim; searchBox.TextSize=13; searchBox.Text=""; searchBox.ClearTextOnFocus=false; searchBox.LayoutOrder=nextOrder(idx); searchBox.ZIndex=4; searchBox.TextXAlignment=Enum.TextXAlignment.Left; searchBox.Parent=s; corner(searchBox,8); mkStroke(searchBox,C.cardBord,1)
    do local p=Instance.new("UIPadding"); p.PaddingLeft=UDim.new(0,12); p.Parent=searchBox end
    local resultFrame=mkFrame(s,{Size=UDim2.new(1,0,0,0),BackgroundColor3=C.cardDark,LayoutOrder=nextOrder(idx),ZIndex=4,AutomaticSize=Enum.AutomaticSize.Y})
    corner(resultFrame,8); mkStroke(resultFrame,C.cardBord,1)
    do local rl2=Instance.new("UIListLayout"); rl2.FillDirection=Enum.FillDirection.Vertical; rl2.SortOrder=Enum.SortOrder.LayoutOrder; rl2.Padding=UDim.new(0,0); rl2.Parent=resultFrame end
    resultFrame.Visible=false
    local targetLbl=mkLabel(s,"No target selected",{Size=UDim2.new(1,0,0,22),TextSize=11,TextColor3=C.txtDim,Font=Enum.Font.Gotham,LayoutOrder=nextOrder(idx),ZIndex=4,TextXAlignment=Enum.TextXAlignment.Center})
    local _ptAutoFilling = false
    local function selectTarget(plr)
        AC_selectedTarget = plr
        targetLbl.Text = "Target: "..plr.Name
        targetLbl.TextColor3 = C.white
        resultFrame.Visible = false
        _ptAutoFilling = true
        task.defer(function()
            searchBox.Text = ""
            _ptAutoFilling = false
        end)
    end
    local function rebuildResults(query)
        for _,c in ipairs(resultFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        if #query==0 then resultFrame.Visible=false; return {} end
        local results=Shorten(query); if #results==0 then resultFrame.Visible=false; return {} end
        resultFrame.Visible=true
        for ri,plr in ipairs(results) do
            local row=Instance.new("TextButton"); row.Size=UDim2.new(1,0,0,36); row.BackgroundColor3=(AC_selectedTarget==plr) and C.purpleDim or C.cardDark; row.BorderSizePixel=0; row.Font=Enum.Font.GothamBold; row.TextColor3=C.white; row.TextSize=13; row.Text=""; row.AutoButtonColor=false; row.LayoutOrder=ri; row.ZIndex=5; row.Parent=resultFrame
            mkLabel(row,plr.Name,{Size=UDim2.new(0.55,-8,1,0),Position=UDim2.new(0,12,0,0),TextSize=13,Font=Enum.Font.GothamBold,TextColor3=C.white,ZIndex=6})
            mkLabel(row,"@"..plr.DisplayName,{Size=UDim2.new(0.45,-8,1,0),Position=UDim2.new(0.55,0,0,0),TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.txtDim,ZIndex=6})
            row.Activated:Connect(function() selectTarget(plr) end)
        end
        return results
    end
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        if _ptAutoFilling then return end
        local results = rebuildResults(searchBox.Text)
        if #results == 1 then
            selectTarget(results[1])
        end
    end)
    searchBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and not _ptAutoFilling then
            local results = Shorten(searchBox.Text)
            if #results >= 1 then selectTarget(results[1]) end
        end
    end)
    secLabel(s,"TARGET ACTIONS",idx)
    pageCardRow(s,idx,{
        {label="View",       cmd="+view",    desc="Spectate target camera. SB: ViewTarget_Button.",  toggle=true, callback=doView},
        {label="Focus",      cmd="+focus",   desc="Loop TP on top of target. SB: FocusTarget_Button.",toggle=true,callback=doFocus},
    })
    pageCardRow(s,idx,{
        {label="Teleport",   cmd="+tp",      desc="TP to target once. SB: TeleportTarget_Button.",   callback=doTP},
        {label="Bring",      cmd="+bring",   desc="Pull target to you. SB: BringTarget.",            callback=doBring},
    })
    pageCardRow(s,idx,{
        {label="Bang",       cmd="+bang",    desc="Lock behind target with anim. SB: BenxTarget.",   toggle=true,callback=doBang},
        {label="Stand",      cmd="+stand",   desc="Stand beside target with anim. SB: StandTarget.", toggle=true,callback=doStand},
    })
    pageCardRow(s,idx,{
        {label="Sit on Head",cmd="+headsit", desc="Sit on target head loop. SB: HeadsitTarget.",     toggle=true,callback=doSit},
        {label="Backpack",   cmd="+backpack",desc="Lock behind target. SB: BackpackTarget.",          toggle=true,callback=doBP},
    })
    pageCardRow(s,idx,{
        {label="Doggy",      cmd="+doggy",   desc="Doggy position on target. SB: DoggyTarget.",      toggle=true,callback=doDoggy},
        {label="Drag",       cmd="+drag",    desc="Drag target by hand. SB: DragTarget.",            toggle=true,callback=doDrag},
    })
    local clearCard=mkFrame(s,{Size=UDim2.new(1,0,0,46),BackgroundColor3=C.cardDark,LayoutOrder=nextOrder(idx),ZIndex=4})
    corner(clearCard,10); mkStroke(clearCard,C.cardBord,1)
    mkLabel(clearCard,"Clear Target",{Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,14,0,0),TextSize=13,Font=Enum.Font.GothamBold,TextColor3=C.txtDim,ZIndex=5})
    local clearAct=Instance.new("TextButton"); clearAct.Size=UDim2.new(1,0,1,0); clearAct.BackgroundTransparency=1; clearAct.Text=""; clearAct.ZIndex=6; clearAct.Parent=clearCard
    clearAct.Activated:Connect(function()
        AC_selectedTarget=nil; targetLbl.Text="No target selected"; targetLbl.TextColor3=C.txtDim; searchBox.Text=""; resultFrame.Visible=false; killAllLoops()
    end)
    secLabel(s,"SPEED & MOVEMENT",idx)
    mkSlider(s,"WalkSpeed",0,300,16,nextOrder(idx),function(v)
        currentWS=v
        pcall(function() local char=lp.Character; if not char then return end; local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed=v end end)
        if wsConn then wsConn:Disconnect(); wsConn=nil end
        if v>20 then
            wsConn=RunService.Heartbeat:Connect(function()
                pcall(function()
                    local char=lp.Character; if not char then return end
                    local hrp=char:FindFirstChild("HumanoidRootPart"); local hum=char:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.MoveDirection.Magnitude<0.01 then hrp.AssemblyLinearVelocity=Vector3.new(0,hrp.AssemblyLinearVelocity.Y,0) end
                end)
            end)
        end
    end)
    mkSlider(s,"JumpPower",0,500,50,nextOrder(idx),function(v)
        currentJP=v
        pcall(function() local char=lp.Character; if not char then return end; local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.UseJumpPower=true; hum.JumpPower=v end end)
    end)
    lp.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        pcall(function() local hum=char:FindFirstChildOfClass("Humanoid"); if hum then if currentWS~=16 then hum.WalkSpeed=currentWS end; if currentJP~=50 then hum.UseJumpPower=true; hum.JumpPower=currentJP end end end)
    end)
end

local timePanelInstance=nil; local openTimePanel  -- forward declared, defined after mkStdPanel

-- -- WORLD TAB ------------------------------------------------
do
    local s=pageData[3].scroll; local idx=3
    secLabel(s,"VISUAL",idx)
    pageCardRow(s,idx,{
        {label="P-Shaders",cmd="+shaders",desc="Loads the P-Shader ultimate visual enhancement script.",callback=function() loadstring(game:HttpGet("https:".._sl.."raw.githubusercontent.com/randomstring0/pshade-ultimate/refs/heads/main/src/cd.lua"))() end},
        {label="RTX Shaders",cmd="+rtx",desc="Applies RTX-style night/day lighting shaders.",callback=function() loadstring(game:HttpGet("https:".._sl.."raw.githubusercontent.com/CludeHub/RTX-Night-Day/refs/heads/main/RTX-Like-Never-Before.lua"))() end},
    })
    secLabel(s,"TIME CONTROL",idx)
    pageCardRow(s,idx,{{label="Time Panel",cmd="+time",desc="Opens a draggable slider to control the in-game time of day.",callback=function() openTimePanel() end}},70)
    secLabel(s,"TELEPORT",idx)
    pageCardRow(s,idx,{{label="Click TP",cmd="+clicktp",desc="Opens a keybind panel -- press your key wherever your cursor points to teleport there.",callback=function() openClickTP() end}},75)
    secLabel(s,"WORLD",idx)
    pageCardRow(s,idx,{{label="Infinite Baseplate",cmd="+baseplate",desc="Spawns a massive invisible floor beneath you that follows your character.",callback=function() openBaseplate() end}},80)
end

-- -- TOOLS TAB ------------------------------------------------
do
    local s=pageData[4].scroll; local idx=4
    secLabel(s,"EXTERNAL SCRIPTS",idx)
    pageCardRow(s,idx,{
        {label="Infinite Yield",cmd="+iy",desc="Loads the Infinite Yield admin command script.",callback=function() loadstring(game:HttpGet("https:".._sl.."raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end},
        {label="SystemBroken",cmd="+sb",desc="Loads the SystemBroken Ragdoll Engine script.",callback=function() loadstring(game:HttpGet("https:".._sl.."rawscripts.net/raw/Ragdoll-Engine-BEST-SCRIPT-WORKING-SystemBroken-7544"))() end},
    })
    pageCardRow(s,idx,{{label="EmptyTools",cmd="+et",desc="Loads the EmptyTools utility script for tool manipulation.",callback=function() loadstring(game:HttpGet("https:".._sl.."raw.githubusercontent.com/likelysmith/EmptyTools/main/script"))() end}},80)
end

-- -- UGC / REANIM LOGIC (unchanged) ---------------------------
local ugcEmoteData=nil; local ugcFavs={}; local ugcCustom={}
local function loadUGCFavs() pcall(function() if isfile("AC_UGCFavs.json") then ugcFavs=HttpService:JSONDecode(readfile("AC_UGCFavs.json")) or {} end end) end
local function saveUGCFavs() pcall(function() writefile("AC_UGCFavs.json",HttpService:JSONEncode(ugcFavs)) end) end
local function loadUGCCustom() pcall(function() if isfile("AC_UGCCustom.json") then ugcCustom=HttpService:JSONDecode(readfile("AC_UGCCustom.json")) or {} end end) end
local function saveUGCCustom() pcall(function() writefile("AC_UGCCustom.json",HttpService:JSONEncode(ugcCustom)) end) end
loadUGCFavs(); loadUGCCustom()

local function loadAnimOnChar(id, speedVal)
    local char=lp.Character; if not char then return nil end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return nil end
    local animator=hum:FindFirstChildOfClass("Animator")
    if not animator then animator=Instance.new("Animator"); animator.Parent=hum end
    pcall(function() setthreadidentity(6) end)
    local function applyTrack(t)
        if not t then return nil end
        t.Priority=Enum.AnimationPriority.Action; t.Looped=true; t:AdjustSpeed(speedVal or 1); t:Play(); return t
    end
    local idStr=tostring(id)
    if idStr:match("^https?:\/\/") then return nil end
    local numId=tonumber(idStr); if not numId then return nil end
    local KSP=game:GetService("KeyframeSequenceProvider")
    local ok0,ks=pcall(function() return KSP:GetKeyframeSequenceAsync("rbxassetid:".._sl..""..numId) end)
    if ok0 and ks then
        local ok0b,localId=pcall(function() return KSP:RegisterKeyframeSequence(ks) end)
        if ok0b and localId then local la=Instance.new("Animation"); la.AnimationId=localId; local ok0c,t0=pcall(function() return animator:LoadAnimation(la) end); if ok0c and t0 then return applyTrack(t0) end end
    end
    local anim=Instance.new("Animation"); anim.AnimationId="rbxassetid:".._sl..""..numId
    local ok,t=pcall(function() return animator:LoadAnimation(anim) end); if ok and t then return applyTrack(t) end
    local ok2,objs=pcall(function() return game:GetObjects("rbxassetid:".._sl..""..tostring(id)) end)
    if ok2 and objs then for _,obj in ipairs(objs) do if obj:IsA("Animation") then local ok3,t3=pcall(function() return animator:LoadAnimation(obj) end); if ok3 and t3 then return applyTrack(t3) end end end end
    local ok4,model=pcall(function() return game:GetService("InsertService"):LoadAsset(id) end)
    if ok4 and model then local animObj=model:FindFirstChildOfClass("Animation",true); if animObj then local ok5,t5=pcall(function() return animator:LoadAnimation(animObj) end); model:Destroy(); if ok5 and t5 then return applyTrack(t5) end else model:Destroy() end end
    return nil
end

local ugcPanelOpen=false
local function openUGCPanel()
    if ugcPanelOpen then return end; ugcPanelOpen=true
    local PW,PH=360,480
    local panel=Instance.new("Frame"); panel.Name="UGCEmotesPanel"; panel.Size=UDim2.new(0,PW,0,PH); panel.Position=UDim2.new(0.3,-PW/2,0.2,0); panel.BackgroundColor3=C.bg; panel.BorderSizePixel=0; panel.ClipsDescendants=false; panel.ZIndex=60; panel.Parent=ScreenGui; corner(panel,10); mkStroke(panel,C.sep,3); addPanelGlow(panel,10)
    local titleH=36
    local tBar=mkFrame(panel,{Size=UDim2.new(1,0,0,titleH),BackgroundColor3=C.card,ZIndex=61}); corner(tBar,10)
    mkLabel(tBar,"AC Emotes",{Size=UDim2.new(1,-40,1,0),Position=UDim2.new(0,12,0,0),TextSize=14,Font=Enum.Font.GothamBold,TextColor3=C.white,ZIndex=62})
    local readyLbl=mkLabel(tBar,"Loading...",{Size=UDim2.new(0,80,1,0),Position=UDim2.new(1,-120,0,0),TextSize=10,Font=Enum.Font.Gotham,TextColor3=C.txtDim,ZIndex=62,TextXAlignment=Enum.TextXAlignment.Right})
    local closeU=mkBtn(tBar,"x",{Size=UDim2.new(0,26,0,24),Position=UDim2.new(1,-30,0.5,-12),TextSize=12,Font=Enum.Font.GothamBold,ZIndex=62}); corner(closeU,5); hov(closeU,C.purple,Color3.fromRGB(160,30,30))
    closeU.Activated:Connect(function() panel:Destroy(); ugcPanelOpen=false end)
    local speedVal=savedSettings.ugcSpeed; local currentTrack=nil
    local speedBar=mkFrame(panel,{Size=UDim2.new(1,-20,0,28),Position=UDim2.new(0,10,0,titleH+4),BackgroundColor3=C.card,ZIndex=61}); corner(speedBar,6)
    mkLabel(speedBar,"Speed",{Size=UDim2.new(0,44,1,0),Position=UDim2.new(0,8,0,0),TextSize=11,Font=Enum.Font.GothamBold,TextColor3=C.white,ZIndex=62})
    local spdTrack=mkFrame(speedBar,{Size=UDim2.new(1,-100,0,6),Position=UDim2.new(0,56,0.5,-3),BackgroundColor3=C.sliderBg,ZIndex=62}); corner(spdTrack,3)
    local initPctU=math.clamp((speedVal-0.1)/9.9,0,1)
    local spdFill=mkFrame(spdTrack,{Size=UDim2.new(initPctU,0,1,0),BackgroundColor3=C.sliderFg,ZIndex=63}); corner(spdFill,3)
    local spdKnob=mkFrame(spdTrack,{Size=UDim2.new(0,12,0,12),Position=UDim2.new(initPctU,-6,0.5,-6),BackgroundColor3=C.white,ZIndex=64}); corner(spdKnob,6)
    local spdLbl=mkLabel(speedBar,tostring(speedVal).."x",{Size=UDim2.new(0,36,1,0),Position=UDim2.new(1,-40,0,0),TextSize=11,Font=Enum.Font.GothamBold,TextColor3=C.white,ZIndex=62,TextXAlignment=Enum.TextXAlignment.Center})
    local spdDragging=false
    local function updateSpd(x)
        local p=math.clamp((x-spdTrack.AbsolutePosition.X)/spdTrack.AbsoluteSize.X,0,1); speedVal=math.floor((0.1+p*9.9)*10)/10
        spdFill.Size=UDim2.new(p,0,1,0); spdKnob.Position=UDim2.new(p,-6,0.5,-6); spdLbl.Text=tostring(speedVal).."x"
        if currentTrack then pcall(function() currentTrack:AdjustSpeed(speedVal) end) end
        savedSettings.ugcSpeed=speedVal; saveSettings()
    end
    spdTrack.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then spdDragging=true; updateSpd(i.Position.X) end end)
    UserInputService.InputChanged:Connect(function(i) if spdDragging and i.UserInputType==Enum.UserInputType.MouseMovement then updateSpd(i.Position.X) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then spdDragging=false end end)
    local TAB_NAMES={"All","Favs","Custom"}; local currentTab="All"
    local tabBarU=mkFrame(panel,{Size=UDim2.new(1,0,0,36),Position=UDim2.new(0,0,1,-36),BackgroundColor3=C.card,ZIndex=62})
    local tabLL=Instance.new("UIListLayout"); tabLL.FillDirection=Enum.FillDirection.Horizontal; tabLL.HorizontalAlignment=Enum.HorizontalAlignment.Center; tabLL.VerticalAlignment=Enum.VerticalAlignment.Center; tabLL.SortOrder=Enum.SortOrder.LayoutOrder; tabLL.Padding=UDim.new(0,4); tabLL.Parent=tabBarU
    local tabBtnsU={}
    for ti,tn in ipairs(TAB_NAMES) do local tb=mkBtn(tabBarU,tn,{Size=UDim2.new(0,88,0,26),BackgroundColor3=(tn=="All") and C.purple or Color3.fromRGB(15,15,15),TextSize=12,Font=Enum.Font.GothamBold,LayoutOrder=ti,ZIndex=63}); corner(tb,12); tabBtnsU[tn]=tb end
    local searchU=Instance.new("TextBox"); searchU.Size=UDim2.new(1,-20,0,30); searchU.Position=UDim2.new(0,10,0,titleH+36); searchU.BackgroundColor3=C.card; searchU.BorderSizePixel=0; searchU.Font=Enum.Font.Gotham; searchU.TextColor3=C.white; searchU.PlaceholderText="Search emotes..."; searchU.PlaceholderColor3=C.txtDim; searchU.TextSize=12; searchU.Text=""; searchU.ClearTextOnFocus=false; searchU.ZIndex=61; searchU.TextXAlignment=Enum.TextXAlignment.Left; searchU.Parent=panel; corner(searchU,6)
    do local p2=Instance.new("UIPadding"); p2.PaddingLeft=UDim.new(0,10); p2.Parent=searchU end
    local customAddFrame=mkFrame(panel,{Size=UDim2.new(1,-20,0,62),Position=UDim2.new(0,10,0,titleH+70),BackgroundColor3=C.card,ZIndex=61}); corner(customAddFrame,6); customAddFrame.Visible=false
    local nameBox=Instance.new("TextBox"); nameBox.Size=UDim2.new(0.6,-4,0,26); nameBox.Position=UDim2.new(0,8,0,4); nameBox.BackgroundColor3=Color3.fromRGB(15,15,15); nameBox.BorderSizePixel=0; nameBox.Font=Enum.Font.Gotham; nameBox.TextColor3=C.white; nameBox.PlaceholderText="Animation name..."; nameBox.PlaceholderColor3=C.txtDim; nameBox.TextSize=12; nameBox.Text=""; nameBox.ClearTextOnFocus=false; nameBox.ZIndex=62; nameBox.TextXAlignment=Enum.TextXAlignment.Left; nameBox.Parent=customAddFrame; corner(nameBox,4)
    local idBox=Instance.new("TextBox"); idBox.Size=UDim2.new(0.6,-4,0,26); idBox.Position=UDim2.new(0,8,0,32); idBox.BackgroundColor3=Color3.fromRGB(15,15,15); idBox.BorderSizePixel=0; idBox.Font=Enum.Font.Gotham; idBox.TextColor3=C.white; idBox.PlaceholderText="Animation ID..."; idBox.PlaceholderColor3=C.txtDim; idBox.TextSize=12; idBox.Text=""; idBox.ClearTextOnFocus=false; idBox.ZIndex=62; idBox.TextXAlignment=Enum.TextXAlignment.Left; idBox.Parent=customAddFrame; corner(idBox,4)
    local addBtn=mkBtn(customAddFrame,"Add",{Size=UDim2.new(0.38,-4,0,56),Position=UDim2.new(0.62,4,0,4),TextSize=13,ZIndex=62}); corner(addBtn,4); hov(addBtn,C.purple,C.purpleDim)
    local listY=titleH+72
    local listScroll=Instance.new("ScrollingFrame"); listScroll.Size=UDim2.new(1,-4,0,PH-listY-40); listScroll.Position=UDim2.new(0,0,0,listY); listScroll.BackgroundTransparency=1; listScroll.BorderSizePixel=0; listScroll.ScrollBarThickness=3; listScroll.ScrollBarImageColor3=C.purple; listScroll.CanvasSize=UDim2.new(0,0,0,0); listScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; listScroll.ZIndex=61; listScroll.Parent=panel
    local listLL=Instance.new("UIListLayout"); listLL.FillDirection=Enum.FillDirection.Vertical; listLL.SortOrder=Enum.SortOrder.LayoutOrder; listLL.Padding=UDim.new(0,2); listLL.Parent=listScroll
    local listPad=Instance.new("UIPadding"); listPad.PaddingLeft=UDim.new(0,8); listPad.PaddingRight=UDim.new(0,8); listPad.PaddingTop=UDim.new(0,4); listPad.Parent=listScroll
    local loadingLbl=mkLabel(listScroll,"Loading emotes...",{Size=UDim2.new(1,0,0,30),TextColor3=C.txtDim,Font=Enum.Font.Gotham,TextSize=12,ZIndex=62,TextXAlignment=Enum.TextXAlignment.Center,LayoutOrder=1})
    local PAGE_SIZE=50
    local function buildList(items,offset)
        if offset==0 then
            for _,c in ipairs(listScroll:GetChildren()) do if c:IsA("TextButton") or (c:IsA("Frame") and c.Name~="LoadMore") then c:Destroy() end end
            local old=listScroll:FindFirstChild("LoadMore"); if old then old:Destroy() end; loadingLbl.Visible=false
        end
        if #items==0 then loadingLbl.Text="No results"; loadingLbl.Visible=true; return end
        local shown=0
        for ri=offset+1,math.min(offset+PAGE_SIZE,#items) do
            local item=items[ri]
            local row=Instance.new("TextButton"); row.Size=UDim2.new(1,0,0,34); row.BackgroundColor3=C.card; row.BorderSizePixel=0; row.Font=Enum.Font.GothamBold; row.TextColor3=C.white; row.TextSize=12; row.Text=""; row.AutoButtonColor=false; row.LayoutOrder=ri; row.ZIndex=62; row.Parent=listScroll; corner(row,6)
            mkLabel(row,item.name,{Size=UDim2.new(1,-50,1,0),Position=UDim2.new(0,10,0,0),TextSize=12,Font=Enum.Font.GothamBold,TextColor3=C.white,ZIndex=63})
            local isFav=false; for _,fid in ipairs(ugcFavs) do if fid==item.id then isFav=true; break end end
            local starBtn=Instance.new("TextButton"); starBtn.Size=UDim2.new(0,34,0,34); starBtn.Position=UDim2.new(1,-38,0.5,-17); starBtn.BackgroundTransparency=1; starBtn.BorderSizePixel=0; starBtn.Font=Enum.Font.GothamBold; starBtn.TextSize=22; starBtn.Text=isFav and "*" or "*"; starBtn.AutoButtonColor=false; starBtn.TextColor3=isFav and Color3.fromRGB(255,200,50) or C.txtDim; starBtn.ZIndex=63; starBtn.Parent=row
            starBtn.Activated:Connect(function()
                local favNow=false; local found=false
                for i2,fid in ipairs(ugcFavs) do if fid==item.id then table.remove(ugcFavs,i2); found=true; break end end
                if not found then table.insert(ugcFavs,item.id); favNow=true end; saveUGCFavs(); starBtn.Text=favNow and "*" or "*"; starBtn.TextColor3=favNow and Color3.fromRGB(255,200,50) or C.txtDim
            end)
            hov(row,C.card,C.cardHov)
            row.Activated:Connect(function() if currentTrack then pcall(function() currentTrack:Stop() end) end; local t=loadAnimOnChar(item.id,speedVal); if t then currentTrack=t end end)
            shown=shown+1
        end
        local nextOffset=offset+shown
        if nextOffset<#items then
            local lm=Instance.new("TextButton"); lm.Name="LoadMore"; lm.Size=UDim2.new(1,0,0,32); lm.BackgroundColor3=C.purpleDim; lm.BorderSizePixel=0; lm.Font=Enum.Font.GothamBold; lm.TextColor3=C.white; lm.TextSize=12; lm.Text="Load More ("..tostring(#items-nextOffset).." left)"; lm.AutoButtonColor=false; lm.LayoutOrder=nextOffset+1; lm.ZIndex=62; lm.Parent=listScroll; corner(lm,6); hov(lm,C.purpleDim,C.purple)
            lm.Activated:Connect(function() lm:Destroy(); buildList(items,nextOffset) end)
        end
    end
    local function refreshList()
        local src={}
        if currentTab=="All" then src=ugcEmoteData or {}
        elseif currentTab=="Favs" then for _,item in ipairs(ugcEmoteData or {}) do for _,fid in ipairs(ugcFavs) do if fid==item.id then table.insert(src,item); break end end end
        elseif currentTab=="Custom" then src=ugcCustom end
        local q=(searchU.Text or ""):lower(); local filtered={}
        if q=="" then filtered=src else for _,item in ipairs(src) do if item.name:lower():find(q,1,true) then table.insert(filtered,item) end end end
        local showCustomAdd=(currentTab=="Custom"); customAddFrame.Visible=showCustomAdd
        listScroll.Position=UDim2.new(0,0,0,showCustomAdd and (listY+66) or listY); listScroll.Size=UDim2.new(1,-4,0,PH-(showCustomAdd and listY+66 or listY)-40)
        buildList(filtered,0)
        for _,tn in ipairs(TAB_NAMES) do tabBtnsU[tn].BackgroundColor3=(tn==currentTab) and C.purple or Color3.fromRGB(15,15,15) end
    end
    for _,tn in ipairs(TAB_NAMES) do tabBtnsU[tn].Activated:Connect(function() currentTab=tn; refreshList() end) end
    searchU:GetPropertyChangedSignal("Text"):Connect(function() refreshList() end)
    addBtn.Activated:Connect(function() local n=nameBox.Text; local id=tonumber(idBox.Text); if n~="" and id then table.insert(ugcCustom,{id=id,name=n}); saveUGCCustom(); nameBox.Text=""; idBox.Text=""; refreshList() end end)
    do
        local dd,dds,dsp,dm=false,nil,nil,false
        tBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dd=true; dm=false; dds=i.Position; dsp=panel.Position; _acSubPanelDragging=true; i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dd=false; _acSubPanelDragging=false end end) end end)
        UserInputService.InputChanged:Connect(function(i) if dd and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-dds; if not dm and (math.abs(d.X)>4 or math.abs(d.Y)>4) then dm=true end; if dm then panel.Position=UDim2.new(dsp.X.Scale,dsp.X.Offset+d.X,dsp.Y.Scale,dsp.Y.Offset+d.Y) end end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dd=false; _acSubPanelDragging=false end end)
    end
    task.spawn(function()
        if not ugcEmoteData then
            local ok,res=pcall(function() return game:HttpGet("https:".._sl.."raw.githubusercontent.com/7yd7/sniper-Emote/refs/heads/test/EmoteSniper.json") end)
            if ok and res and res~="" then pcall(function() local data=HttpService:JSONDecode(res); ugcEmoteData={}; for _,item in ipairs(data.data or {}) do if tonumber(item.id) and tonumber(item.id)>0 then table.insert(ugcEmoteData,{id=tonumber(item.id),name=item.name or ("Emote_"..item.id)}) end end end) end
        end
        if panel.Parent then readyLbl.Text="Ready"; refreshList() end
    end)
end

local rnPanelOpen=false

local akGhostEnabled=false
local akOrigChar,akGhostClone,akOrigCF,akOrigAnim,akUpdateConn,akOrigHipH
local akOrigSizes={}; local akMotorCFs={}; local akOrigNeckC0=nil
local akBodyParts={"Head","UpperTorso","LowerTorso","LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot","Torso","Left Arm","Right Arm","Left Leg","Right Leg"}
local akPreservedGuis={}
local function akPreserveGuis() local pg=lp:FindFirstChildWhichIsA("PlayerGui"); if pg then for _,g in ipairs(pg:GetChildren()) do if g:IsA("ScreenGui") and g.ResetOnSpawn then table.insert(akPreservedGuis,g); g.ResetOnSpawn=false end end end end
local function akRestoreGuis() for _,g in ipairs(akPreservedGuis) do g.ResetOnSpawn=true end; table.clear(akPreservedGuis) end

-- Backpack dedup: snapshot tool names before swap, remove extras after
local akBackpackSnapshot={}
local function akSnapshotBackpack()
    akBackpackSnapshot={}
    local bp=lp:FindFirstChildOfClass("Backpack"); if not bp then return end
    for _,t in ipairs(bp:GetChildren()) do
        if t:IsA("Tool") or t:IsA("HopperBin") then
            akBackpackSnapshot[t.Name]=(akBackpackSnapshot[t.Name] or 0)+1
        end
    end
end
local function akDedupeBackpack()
    task.wait(0.2) -- let the swap settle
    local bp=lp:FindFirstChildOfClass("Backpack"); if not bp then return end
    local seen={}
    for _,t in ipairs(bp:GetChildren()) do
        if t:IsA("Tool") or t:IsA("HopperBin") then
            local n=t.Name
            seen[n]=(seen[n] or 0)+1
            -- Remove any copy beyond the count we had before the swap
            local allowed=akBackpackSnapshot[n] or 0
            if seen[n]>allowed and seen[n]>1 then
                pcall(function() t:Destroy() end)
            end
        end
    end
    akBackpackSnapshot={}
end
local function akUpdateCloneTransp() if not akGhostClone then return end; for _,p in pairs(akGhostClone:GetDescendants()) do if p:IsA("BasePart") then p.Transparency=1 end end; local h=akGhostClone:FindFirstChild("Head"); if h then for _,c in ipairs(h:GetChildren()) do if c:IsA("Decal") then c.Transparency=1 end end end end
local function akUpdateRagParts()
    if not akGhostEnabled or not akOrigChar or not akGhostClone then return end
    for _,pn in ipairs(akBodyParts) do local op=akOrigChar:FindFirstChild(pn); local cp=akGhostClone:FindFirstChild(pn); if op and cp then op.CFrame=cp.CFrame; op.AssemblyLinearVelocity=Vector3.new(0,0,0); op.AssemblyAngularVelocity=Vector3.new(0,0,0) end end
    local on2=akOrigChar:FindFirstChild("Head") and akOrigChar.Head:FindFirstChild("Neck"); local cn2=akGhostClone:FindFirstChild("Head") and akGhostClone.Head:FindFirstChild("Neck"); if on2 and cn2 then on2.C0=cn2.C0 end
end
local function akAdjustToGround(clone) if not clone then return end; local ly=math.huge; for _,p in ipairs(clone:GetDescendants()) do if p:IsA("BasePart") then local by=p.Position.Y-(p.Size.Y/2); if by<ly then ly=by end end end; local off=0-ly; if off>0 then if clone.PrimaryPart then clone:SetPrimaryPartCFrame(clone.PrimaryPart.CFrame+Vector3.new(0,off,0)) else clone:TranslateBy(Vector3.new(0,off,0)) end end end
local function akDetectRemotes()
    local RS=game:GetService("ReplicatedStorage"); local micup=RS:FindFirstChild("Ragdoll"); local micupnew=RS:FindFirstChild("event_rag"); local lm=RS:FindFirstChild("LocalModules"); local be=lm and lm:FindFirstChild("Backend"); local pk=be and be:FindFirstChild("Packets"); local pkt=pk and pk:FindFirstChild("Packet"); local meetacross=pkt and pkt:FindFirstChild("RemoteEvent"); local evts=RS:FindFirstChild("Events"); local rag1=evts and evts:FindFirstChild("RagdollState")
    if micup then getgenv().rem=RS:FindFirstChild("Ragdoll"); getgenv().unrem=RS:FindFirstChild("Unragdoll"); getgenv().args={"Hinge"}; getgenv().unargs={}
    elseif micupnew then getgenv().rem=RS:FindFirstChild("event_rag"); getgenv().unrem=RS:FindFirstChild("event_rag"); getgenv().args={"Hinge"}; getgenv().unargs={"Hinge"}
    elseif rag1 then getgenv().rem=rag1; getgenv().unrem=rag1; getgenv().args={true}; getgenv().unargs={false}
    elseif meetacross then getgenv().rem=meetacross; getgenv().unrem=meetacross; getgenv().args={buffer.fromstring("U\001")}; getgenv().unargs={buffer.fromstring("U\000")} end
end
local function setGhostEnabled(newState)
    akGhostEnabled=newState
    if akGhostEnabled then
        akDetectRemotes(); local char=lp.Character; if not char then return end
        local hum=char:FindFirstChildWhichIsA("Humanoid"); local root=char:FindFirstChild("HumanoidRootPart"); if not hum or not root then return end
        akOrigChar=char; akOrigCF=root.CFrame
        local neck=(hum.RigType==Enum.HumanoidRigType.R15) and char:WaitForChild("Head"):FindFirstChild("Neck") or (hum.RigType==Enum.HumanoidRigType.R6 and char:WaitForChild("Torso"):FindFirstChild("Neck"))
        if neck then akOrigNeckC0=neck.C0 end
        char.Archivable=true; akGhostClone=char:Clone(); char.Archivable=false
        -- Strip copied AC_Tag off ghost clone so it doesn't inherit the nametag
        pcall(function()
            local gh=akGhostClone:FindFirstChild("Head")
            if gh then local t=gh:FindFirstChild("AC_Tag"); if t then t:Destroy() end end
        end)
        local origName=akOrigChar.Name; akGhostClone.Name=origName.."Celeste"
        local gh=akGhostClone:FindFirstChildWhichIsA("Humanoid")
        if gh then gh.DisplayName=origName.."Celeste"; akOrigHipH=gh.HipHeight; gh.WalkSpeed=hum.WalkSpeed; gh.JumpPower=hum.JumpPower end
        if not akGhostClone.PrimaryPart then local hrp2=akGhostClone:FindFirstChild("HumanoidRootPart"); if hrp2 then akGhostClone.PrimaryPart=hrp2 end end
        akUpdateCloneTransp(); akOrigSizes={}; akMotorCFs={}
        for _,d in ipairs(akGhostClone:GetDescendants()) do if d:IsA("BasePart") then akOrigSizes[d]=d.Size elseif d:IsA("Motor6D") then akMotorCFs[d]={C0=d.C0,C1=d.C1} end end
        local anim=akOrigChar:FindFirstChild("Animate"); if anim then akOrigAnim=anim:Clone(); akOrigAnim.Parent=akGhostClone; akOrigAnim.Disabled=true end
        akSnapshotBackpack(); akPreserveGuis(); akGhostClone.Parent=workspace; akAdjustToGround(akGhostClone); lp.Character=akGhostClone
        if gh then workspace.CurrentCamera.CameraSubject=gh end; akRestoreGuis(); task.spawn(akDedupeBackpack)
        task.delay(0.1,function() if not akGhostEnabled or not akGhostClone then return end; if akOrigAnim then akOrigAnim.Disabled=false end; if gh then gh:ChangeState(Enum.HumanoidStateType.Running) end end)
        task.delay(0,function()
            if not akGhostEnabled then return end
            if getgenv().rem then pcall(function() lp.Character.Humanoid.HipHeight=lp.Character.Humanoid.HipHeight; getgenv().rem:FireServer(unpack(getgenv().args)) end) end
            task.delay(0,function() if not akGhostEnabled then return end; if akUpdateConn then akUpdateConn:Disconnect() end; akUpdateConn=RunService.Heartbeat:Connect(akUpdateRagParts) end)
        end)
    else
        if akUpdateConn then akUpdateConn:Disconnect(); akUpdateConn=nil end
        if not akOrigChar or not akGhostClone then return end
        if getgenv().unrem then for i=1,3 do pcall(function() getgenv().unrem:FireServer(unpack(getgenv().unargs)) end); task.wait(0.1) end end
        local origRoot=akOrigChar:FindFirstChild("HumanoidRootPart"); local ghostRoot=akGhostClone:FindFirstChild("HumanoidRootPart"); local targetCF=ghostRoot and ghostRoot.CFrame or akOrigCF
        local anim=akGhostClone:FindFirstChild("Animate"); if anim then anim.Parent=akOrigChar; anim.Disabled=true end
        akGhostClone:Destroy(); if origRoot then origRoot.CFrame=targetCF end
        local origHum=akOrigChar:FindFirstChildWhichIsA("Humanoid"); akSnapshotBackpack(); akPreserveGuis(); lp.Character=akOrigChar
        if origHum then workspace.CurrentCamera.CameraSubject=origHum end; akRestoreGuis(); task.spawn(akDedupeBackpack)
        if anim then task.wait(0.1); anim.Disabled=false end
        -- Re-sync nametag state: remove stale cloned tag entry, re-apply enabled state
        pcall(function()
            activeTags[lp.UserId]=nil
            local head=akOrigChar:FindFirstChild("Head")
            if head then
                local t=head:FindFirstChild("AC_Tag"); if t then t.Enabled=nameTagsEnabled end
                activeTags[lp.UserId]=t or nil
            end
        end)
        akOrigNeckC0=nil; akOrigChar=nil; akGhostClone=nil
    end
end

local rnFavs={}; local rnCustom={}
pcall(function() if isfile("AC_RNFavs.json") then rnFavs=HttpService:JSONDecode(readfile("AC_RNFavs.json")) or {} end end)
pcall(function() if isfile("AC_RNCustom.json") then rnCustom=HttpService:JSONDecode(readfile("AC_RNCustom.json")) or {} end end)
local function saveRNFavs() pcall(function() writefile("AC_RNFavs.json",HttpService:JSONEncode(rnFavs)) end) end
local function saveRNCustom() pcall(function() writefile("AC_RNCustom.json",HttpService:JSONEncode(rnCustom)) end) end

local function openRNPanel()
    if rnPanelOpen then return end; rnPanelOpen=true
    local PW,PH=360,500
    local panel=Instance.new("Frame"); panel.Name="RNPanel"; panel.Size=UDim2.new(0,PW,0,PH); panel.Position=UDim2.new(0.55,-PW/2,0.2,0); panel.BackgroundColor3=C.bg; panel.BorderSizePixel=0; panel.ClipsDescendants=false; panel.ZIndex=60; panel.Parent=ScreenGui; corner(panel,10); mkStroke(panel,C.sep,1)
    local titleH=36; local tBar=mkFrame(panel,{Size=UDim2.new(1,0,0,titleH),BackgroundColor3=C.card,ZIndex=61}); corner(tBar,10)
    mkLabel(tBar,"AC Reanimation",{Size=UDim2.new(1,-110,1,0),Position=UDim2.new(0,12,0,0),TextSize=14,Font=Enum.Font.GothamBold,TextColor3=C.white,ZIndex=62})
    local rnActive=false
    local toggleBtn=Instance.new("TextButton"); toggleBtn.Size=UDim2.new(0,40,0,22); toggleBtn.Position=UDim2.new(1,-70,0.5,-11); toggleBtn.BackgroundColor3=C.purpleDim; toggleBtn.BorderSizePixel=0; toggleBtn.Font=Enum.Font.GothamBold; toggleBtn.TextColor3=C.white; toggleBtn.TextSize=11; toggleBtn.Text="OFF"; toggleBtn.AutoButtonColor=false; toggleBtn.ZIndex=62; toggleBtn.Parent=tBar; corner(toggleBtn,5)
    toggleBtn.Activated:Connect(function() rnActive=not rnActive; toggleBtn.Text=rnActive and "ON" or "OFF"; toggleBtn.BackgroundColor3=rnActive and C.purple or C.purpleDim; task.spawn(function() pcall(setGhostEnabled,rnActive) end) end)
    local closeR=mkBtn(tBar,"x",{Size=UDim2.new(0,26,0,24),Position=UDim2.new(1,-30,0.5,-12),TextSize=12,Font=Enum.Font.GothamBold,ZIndex=62}); corner(closeR,5); hov(closeR,C.purple,Color3.fromRGB(160,30,30))
    closeR.Activated:Connect(function() if rnActive then pcall(setGhostEnabled,false) end; panel:Destroy(); rnPanelOpen=false end)
    local rnSpeedVal=savedSettings.rnSpeed; local rnCurrentTrack=nil
    local spdBarR=mkFrame(panel,{Size=UDim2.new(1,-20,0,28),Position=UDim2.new(0,10,0,titleH+4),BackgroundColor3=C.card,ZIndex=61}); corner(spdBarR,6)
    mkLabel(spdBarR,"Speed",{Size=UDim2.new(0,44,1,0),Position=UDim2.new(0,8,0,0),TextSize=11,Font=Enum.Font.GothamBold,TextColor3=C.white,ZIndex=62})
    local spdTrackR=mkFrame(spdBarR,{Size=UDim2.new(1,-100,0,6),Position=UDim2.new(0,56,0.5,-3),BackgroundColor3=C.sliderBg,ZIndex=62}); corner(spdTrackR,3)
    local ip=math.clamp((rnSpeedVal-0.1)/9.9,0,1)
    local spdFillR=mkFrame(spdTrackR,{Size=UDim2.new(ip,0,1,0),BackgroundColor3=C.sliderFg,ZIndex=63}); corner(spdFillR,3)
    local spdKnobR=mkFrame(spdTrackR,{Size=UDim2.new(0,12,0,12),Position=UDim2.new(ip,-6,0.5,-6),BackgroundColor3=C.white,ZIndex=64}); corner(spdKnobR,6)
    local spdLblR=mkLabel(spdBarR,tostring(rnSpeedVal).."x",{Size=UDim2.new(0,36,1,0),Position=UDim2.new(1,-40,0,0),TextSize=11,Font=Enum.Font.GothamBold,TextColor3=C.white,ZIndex=62,TextXAlignment=Enum.TextXAlignment.Center})
    local spdDR=false
    local function updateSpdR(x) local p=math.clamp((x-spdTrackR.AbsolutePosition.X)/spdTrackR.AbsoluteSize.X,0,1); rnSpeedVal=math.floor((0.1+p*9.9)*10)/10; spdFillR.Size=UDim2.new(p,0,1,0); spdKnobR.Position=UDim2.new(p,-6,0.5,-6); spdLblR.Text=tostring(rnSpeedVal).."x"; if rnCurrentTrack then pcall(function() rnCurrentTrack:AdjustSpeed(rnSpeedVal) end) end; savedSettings.rnSpeed=rnSpeedVal; saveSettings() end
    spdTrackR.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then spdDR=true; updateSpdR(i.Position.X) end end)
    UserInputService.InputChanged:Connect(function(i) if spdDR and i.UserInputType==Enum.UserInputType.MouseMovement then updateSpdR(i.Position.X) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then spdDR=false end end)
    local presetsY=titleH+36; local presetsFrame=mkFrame(panel,{Size=UDim2.new(1,-20,0,48),Position=UDim2.new(0,10,0,presetsY),BackgroundColor3=C.card,ZIndex=61}); corner(presetsFrame,6)
    local presets={{v=5,k=nil},{v=5,k=nil},{v=5,k=nil},{v=5,k=nil},{v=5,k=nil}}; local slotW=(PW-20-16)/5-2
    for pi=1,5 do
        local xOff=8+(pi-1)*(slotW+2)
        local vBox=Instance.new("TextBox"); vBox.Size=UDim2.new(0,slotW,0,20); vBox.Position=UDim2.new(0,xOff,0,4); vBox.BackgroundColor3=C.purpleDim; vBox.BorderSizePixel=0; vBox.Font=Enum.Font.GothamBold; vBox.TextColor3=C.white; vBox.TextSize=11; vBox.Text=tostring(presets[pi].v); vBox.ClearTextOnFocus=false; vBox.ZIndex=62; vBox.TextXAlignment=Enum.TextXAlignment.Center; vBox.Parent=presetsFrame; corner(vBox,4)
        vBox:GetPropertyChangedSignal("Text"):Connect(function() local n=tonumber(vBox.Text); if n then presets[pi].v=math.clamp(n,0.1,10) end end)
        local kBtn=mkBtn(presetsFrame,"Key",{Size=UDim2.new(0,slotW,0,18),Position=UDim2.new(0,xOff,0,26),TextSize=10,Font=Enum.Font.Gotham,ZIndex=62}); corner(kBtn,4); kBtn.BackgroundColor3=C.purpleDim
        local listening2=false; kBtn.Activated:Connect(function() if listening2 then return end; listening2=true; kBtn.Text="..."; local conn2; conn2=UserInputService.InputBegan:Connect(function(inp2,gp2) if gp2 then return end; if inp2.UserInputType==Enum.UserInputType.Keyboard then presets[pi].k=inp2.KeyCode; kBtn.Text=inp2.KeyCode.Name:sub(1,4); listening2=false; conn2:Disconnect() end end) end)
    end
    UserInputService.InputBegan:Connect(function(inp,gp) if gp or not rnPanelOpen then return end; if inp.UserInputType~=Enum.UserInputType.Keyboard then return end; for _,pr in ipairs(presets) do if pr.k and inp.KeyCode==pr.k and rnCurrentTrack then pcall(function() rnCurrentTrack:AdjustSpeed(pr.v); rnSpeedVal=pr.v end) end end end)
    local RN_TABS={"All","Favs","Custom"}; local rnCurrentTab="All"; local rnTabBarY=PH-36
    local rnTabBar=mkFrame(panel,{Size=UDim2.new(1,0,0,36),Position=UDim2.new(0,0,0,rnTabBarY),BackgroundColor3=C.card,ZIndex=62})
    local rnTabLL=Instance.new("UIListLayout"); rnTabLL.FillDirection=Enum.FillDirection.Horizontal; rnTabLL.HorizontalAlignment=Enum.HorizontalAlignment.Center; rnTabLL.VerticalAlignment=Enum.VerticalAlignment.Center; rnTabLL.SortOrder=Enum.SortOrder.LayoutOrder; rnTabLL.Padding=UDim.new(0,4); rnTabLL.Parent=rnTabBar
    local rnTabBtns={}; local rnTabW=math.floor((PW-20)/#RN_TABS)
    for ti,tn in ipairs(RN_TABS) do local tb=mkBtn(rnTabBar,tn,{Size=UDim2.new(0,rnTabW-4,0,26),BackgroundColor3=(tn==rnCurrentTab) and C.purple or C.purpleDim,TextSize=11,Font=Enum.Font.GothamBold,LayoutOrder=ti,ZIndex=63}); corner(tb,12); mkStroke(tb,C.sep,2); rnTabBtns[tn]=tb end
    local searchR=Instance.new("TextBox"); searchR.Size=UDim2.new(1,-20,0,28); searchR.Position=UDim2.new(0,10,0,presetsY+52); searchR.BackgroundColor3=C.card; searchR.BorderSizePixel=0; searchR.Font=Enum.Font.Gotham; searchR.TextColor3=C.white; searchR.PlaceholderText="Search animations..."; searchR.PlaceholderColor3=C.txtDim; searchR.TextSize=12; searchR.Text=""; searchR.ClearTextOnFocus=false; searchR.ZIndex=61; searchR.TextXAlignment=Enum.TextXAlignment.Left; searchR.Parent=panel; corner(searchR,6)
    do local p3=Instance.new("UIPadding"); p3.PaddingLeft=UDim.new(0,10); p3.Parent=searchR end
    local listStartY=presetsY+52+36; local listHeight=rnTabBarY-listStartY-4
    local customAddR=mkFrame(panel,{Size=UDim2.new(1,-20,0,72),Position=UDim2.new(0,10,0,listStartY),BackgroundColor3=C.card,ZIndex=61}); corner(customAddR,6); customAddR.Visible=false
    local rnNameBox=Instance.new("TextBox"); rnNameBox.Size=UDim2.new(0.65,-4,0,26); rnNameBox.Position=UDim2.new(0,8,0,4); rnNameBox.BackgroundColor3=C.purpleDim; rnNameBox.BorderSizePixel=0; rnNameBox.Font=Enum.Font.Gotham; rnNameBox.TextColor3=C.white; rnNameBox.PlaceholderText="Animation name..."; rnNameBox.PlaceholderColor3=C.txtDim; rnNameBox.TextSize=12; rnNameBox.Text=""; rnNameBox.ClearTextOnFocus=false; rnNameBox.ZIndex=62; rnNameBox.TextXAlignment=Enum.TextXAlignment.Left; rnNameBox.Parent=customAddR; corner(rnNameBox,4)
    local rnIdBox=Instance.new("TextBox"); rnIdBox.Size=UDim2.new(0.65,-4,0,26); rnIdBox.Position=UDim2.new(0,8,0,32); rnIdBox.BackgroundColor3=C.purpleDim; rnIdBox.BorderSizePixel=0; rnIdBox.Font=Enum.Font.Gotham; rnIdBox.TextColor3=C.white; rnIdBox.PlaceholderText="Animation ID..."; rnIdBox.PlaceholderColor3=C.txtDim; rnIdBox.TextSize=12; rnIdBox.Text=""; rnIdBox.ClearTextOnFocus=false; rnIdBox.ZIndex=62; rnIdBox.TextXAlignment=Enum.TextXAlignment.Left; rnIdBox.Parent=customAddR; corner(rnIdBox,4)
    local rnAddBtn=mkBtn(customAddR,"Save",{Size=UDim2.new(0.33,-4,0,56),Position=UDim2.new(0.67,4,0,4),TextSize=13,ZIndex=62}); corner(rnAddBtn,4); mkStroke(rnAddBtn,C.sep,2); hov(rnAddBtn,C.purple,C.purpleDim)
    local rnListScroll=Instance.new("ScrollingFrame"); rnListScroll.Size=UDim2.new(1,-4,0,listHeight); rnListScroll.Position=UDim2.new(0,0,0,listStartY); rnListScroll.BackgroundTransparency=1; rnListScroll.BorderSizePixel=0; rnListScroll.ScrollBarThickness=3; rnListScroll.ScrollBarImageColor3=C.purple; rnListScroll.CanvasSize=UDim2.new(0,0,0,0); rnListScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; rnListScroll.ZIndex=61; rnListScroll.Parent=panel
    local rnListLL=Instance.new("UIListLayout"); rnListLL.FillDirection=Enum.FillDirection.Vertical; rnListLL.SortOrder=Enum.SortOrder.LayoutOrder; rnListLL.Padding=UDim.new(0,2); rnListLL.Parent=rnListScroll
    local rnListPad=Instance.new("UIPadding"); rnListPad.PaddingLeft=UDim.new(0,8); rnListPad.PaddingRight=UDim.new(0,8); rnListPad.PaddingTop=UDim.new(0,4); rnListPad.Parent=rnListScroll
    local rnLoadingLbl=mkLabel(rnListScroll,"Loading...",{Size=UDim2.new(1,0,0,30),TextColor3=C.txtDim,Font=Enum.Font.Gotham,TextSize=12,ZIndex=62,TextXAlignment=Enum.TextXAlignment.Center,LayoutOrder=1})
    local PAGE_SIZE_RN=50; local rnAnimData=nil
    local function buildRNList(items,offset)
        if offset==0 then for _,c in ipairs(rnListScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end; local old=rnListScroll:FindFirstChild("LoadMoreRN"); if old then old:Destroy() end; rnLoadingLbl.Visible=false end
        if #items==0 then rnLoadingLbl.Text="No results"; rnLoadingLbl.Visible=true; return end
        local shown=0
        for ri=offset+1,math.min(offset+PAGE_SIZE_RN,#items) do
            local item=items[ri]; local row=Instance.new("TextButton"); row.Size=UDim2.new(1,0,0,34); row.BackgroundColor3=C.card; row.BorderSizePixel=0; row.Font=Enum.Font.GothamBold; row.TextColor3=C.white; row.TextSize=12; row.Text=""; row.AutoButtonColor=false; row.LayoutOrder=ri; row.ZIndex=62; row.Parent=rnListScroll; corner(row,6)
            mkLabel(row,item.name,{Size=UDim2.new(1,-50,1,0),Position=UDim2.new(0,10,0,0),TextSize=12,Font=Enum.Font.GothamBold,TextColor3=C.white,ZIndex=63})
            local isFav=false; for _,fid in ipairs(rnFavs) do if fid==item.id then isFav=true; break end end
            local starBtn=Instance.new("TextButton"); starBtn.Size=UDim2.new(0,34,0,34); starBtn.Position=UDim2.new(1,-38,0.5,-17); starBtn.BackgroundTransparency=1; starBtn.BorderSizePixel=0; starBtn.Font=Enum.Font.GothamBold; starBtn.TextSize=22; starBtn.Text=isFav and "" or ""; starBtn.AutoButtonColor=false; starBtn.TextColor3=isFav and Color3.fromRGB(255,200,50) or C.txtDim; starBtn.ZIndex=63; starBtn.Parent=row
            starBtn.Activated:Connect(function() local found=false; for i2,fid in ipairs(rnFavs) do if fid==item.id then table.remove(rnFavs,i2); found=true; break end end; if not found then table.insert(rnFavs,item.id) end; saveRNFavs(); starBtn.Text=(not found) and "" or ""; starBtn.TextColor3=(not found) and Color3.fromRGB(255,200,50) or C.txtDim end)
            hov(row,C.card,C.cardHov); row.Activated:Connect(function() if rnCurrentTrack then pcall(function() rnCurrentTrack:Stop() end) end; local t=loadAnimOnChar(item.id,rnSpeedVal); if t then rnCurrentTrack=t end end)
            shown=shown+1
        end
        local nextOffset=offset+shown
        if nextOffset<#items then local lm=Instance.new("TextButton"); lm.Name="LoadMoreRN"; lm.Size=UDim2.new(1,0,0,32); lm.BackgroundColor3=C.purpleDim; lm.BorderSizePixel=0; lm.Font=Enum.Font.GothamBold; lm.TextColor3=C.white; lm.TextSize=12; lm.Text="Load More ("..tostring(#items-nextOffset).." left)"; lm.AutoButtonColor=false; lm.LayoutOrder=nextOffset+1; lm.ZIndex=62; lm.Parent=rnListScroll; corner(lm,6); hov(lm,C.purpleDim,C.purple); lm.Activated:Connect(function() lm:Destroy(); buildRNList(items,nextOffset) end) end
    end
    local function refreshRNList()
        local src={}
        if rnCurrentTab=="All" then src=rnAnimData or {} elseif rnCurrentTab=="Favs" then for _,item in ipairs(rnAnimData or {}) do for _,fid in ipairs(rnFavs) do if fid==item.id then table.insert(src,item); break end end end elseif rnCurrentTab=="Custom" then src=rnCustom end
        local q=(searchR.Text or ""):lower(); local filtered={}; if q=="" then filtered=src else for _,item in ipairs(src) do if item.name:lower():find(q,1,true) then table.insert(filtered,item) end end end
        local showCustom=(rnCurrentTab=="Custom"); customAddR.Visible=showCustom; local extraH=showCustom and 76 or 0; rnListScroll.Position=UDim2.new(0,0,0,listStartY+extraH); rnListScroll.Size=UDim2.new(1,-4,0,listHeight-extraH)
        buildRNList(filtered,0); for _,tn in ipairs(RN_TABS) do rnTabBtns[tn].BackgroundColor3=(tn==rnCurrentTab) and C.purple or C.purpleDim end
    end
    for _,tn in ipairs(RN_TABS) do rnTabBtns[tn].Activated:Connect(function() rnCurrentTab=tn; refreshRNList() end) end
    searchR:GetPropertyChangedSignal("Text"):Connect(function() refreshRNList() end)
    rnAddBtn.Activated:Connect(function() local n=rnNameBox.Text; local id=tonumber(rnIdBox.Text); if n~="" and id then table.insert(rnCustom,{id=id,name=n}); saveRNCustom(); rnNameBox.Text=""; rnIdBox.Text=""; refreshRNList() end end)
    do local dd2,dds2,dsp2,dm2=false,nil,nil,false; tBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dd2=true; dm2=false; dds2=i.Position; dsp2=panel.Position; _acSubPanelDragging=true; i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dd2=false; _acSubPanelDragging=false end end) end end); UserInputService.InputChanged:Connect(function(i) if dd2 and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-dds2; if not dm2 and (math.abs(d.X)>4 or math.abs(d.Y)>4) then dm2=true end; if dm2 then panel.Position=UDim2.new(dsp2.X.Scale,dsp2.X.Offset+d.X,dsp2.Y.Scale,dsp2.Y.Offset+d.Y) end end end); UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dd2=false; _acSubPanelDragging=false end end) end
    task.spawn(function()
        if not rnAnimData then
            rnLoadingLbl.Text="Loading..."; rnLoadingLbl.Visible=true
            local ok,res=pcall(function() return game:HttpGet("https:".._sl.."astrx.cc/animlist.lua") end)
            if ok and res and #res>50 then local ok2,tbl=pcall(loadstring(res)); if ok2 and type(tbl)=="table" then rnAnimData={}; for name,id in pairs(tbl) do local idStr=tostring(id); local entry={name=name,id=idStr}; if idStr:match("^https?:\/\/") or tonumber(idStr) then table.insert(rnAnimData,entry) end end; table.sort(rnAnimData,function(a,b) return a.name<b.name end) end end
            if not rnAnimData or #rnAnimData==0 then rnAnimData=ugcEmoteData or {} end
        end
        if panel.Parent then refreshRNList() end
    end)
end

-- EMOTES TAB
do
    local s=pageData[5].scroll; local idx=5
    secLabel(s,"EMOTE PANELS",idx)
    pageCardRow(s,idx,{
        {label="UGC Emotes",cmd="+ugcemotes",desc="Opens the UGC emotes panel with paginated animation list and favourites.",
         callback=function()
            task.spawn(function()
                _G.__AK_ADMIN_EXECUTED=true; _G.bp=true; _G.VERIFIED_VALUES={7382,4921,6154,8293,1047,5621,9384,2047,6831,4502}
                local function applyACStyle(gui) local frame=gui:WaitForChild("Frame",5); if not frame then return end; gui.Enabled=false; frame.BackgroundColor3=Color3.fromRGB(0,0,0); frame.BackgroundTransparency=0.15; local uc=frame:FindFirstChildOfClass("UICorner"); if uc then uc.CornerRadius=UDim.new(0.05,0) end; local ex=frame:FindFirstChildOfClass("UIStroke"); if ex then ex:Destroy() end; local st=Instance.new("UIStroke",frame); st.ApplyStrokeMode="Border"; st.Color=Color3.fromRGB(120,0,110); st.Thickness=4; do local sg=Instance.new("UIGradient"); sg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(0.25,Color3.fromRGB(120,0,110)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(0,0,0)),ColorSequenceKeypoint.new(0.75,Color3.fromRGB(120,0,110)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))}); sg.Parent=st; RunService.Heartbeat:Connect(function() if sg.Parent then sg.Rotation=(sg.Rotation+1)%360 end end) end; for _,v in next,gui:GetDescendants() do if (v:IsA("TextLabel") or v:IsA("TextButton")) and v.Text:find("AK") then v.Text=v.Text:gsub("AK","AC") end; if v:IsA("TextButton") and v.BackgroundTransparency<1 then v.BackgroundColor3=Color3.fromRGB(18,18,22); if not v:FindFirstChildOfClass("UICorner") then local uc2=Instance.new("UICorner"); uc2.CornerRadius=UDim.new(0,6); uc2.Parent=v end; if not v:FindFirstChildOfClass("UIStroke") then local st2=Instance.new("UIStroke"); st2.Color=Color3.fromRGB(110,0,100); st2.Thickness=1.5; local sg2=Instance.new("UIGradient"); sg2.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(0.25,Color3.fromRGB(110,0,100)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(0,0,0)),ColorSequenceKeypoint.new(0.75,Color3.fromRGB(110,0,100)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))}); sg2.Parent=st2; RunService.Heartbeat:Connect(function() if sg2.Parent then sg2.Rotation=(sg2.Rotation+1)%360 end end); st2.Parent=v end end end; gui.Enabled=true end
                local conn; conn=lpgui.ChildAdded:Connect(function(child) if child:IsA("ScreenGui") then conn:Disconnect(); conn=nil; task.spawn(function() applyACStyle(child) end) end end)
                loadstring(game:HttpGet("https:".._sl.."yourscoper.vercel.app/scripts/akadmin/scripts/ugcemotes.lua"))()
                task.delay(5,function() if conn then conn:Disconnect(); conn=nil; for _,g in ipairs(lpgui:GetChildren()) do if g:IsA("ScreenGui") and (g.Name:lower():find("ugc") or g.Name:lower():find("emote") or g.Name:lower():find("ak")) then task.spawn(function() applyACStyle(g) end); break end end end end)
            end)
        end},
        {label="AC Reanimation",cmd="+reanim",desc="Opens the AC Reanimation panel for ghost-mode animation control.",
         callback=function()
            local AKReanimationWarn
            local AKReanimationPrint

            local UITheme = {
                Primary = Color3.fromRGB(120, 0, 110),
                Secondary = Color3.fromRGB(250, 240, 100),
                Shadow = Color3.fromRGB(50, 50, 50),
                Button = Color3.fromRGB(125, 125, 125)
            }

            AKReanimationWarn = hookfunction(warn, function(reason, ...)
                if tostring(reason):find("Reanimate first!") then
                    return
                end

                return AKReanimationWarn(reason, ...)
            end)

            AKReanimationPrint = hookfunction(print, function(reason, ...)
                if tostring(reason):find("AK Reanim loaded!") or tostring(reason):find("Deleted old animation cache") then
                    return
                end

                return AKReanimationPrint(reason, ...)
            end)

            AKLibrary:Execute("!reanim")

            local AKReanimation = lpgui:WaitForChild("AKReanimGUI", 5)

            if AKReanimation then
                local AKMainFrame = AKReanimation:FindFirstChildOfClass("Frame")
                local AKGradient = Instance.new("UIGradient")

                AKMainFrame.BackgroundTransparency = 0.15
                AKMainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                -- Apply our glow style to all RN panel elements
                task.defer(function()
                    pcall(function()
                        local function applyGlow(inst)
                            for _,v in ipairs(inst:GetDescendants()) do
                                if v:IsA("Frame") or v:IsA("TextButton") or v:IsA("TextLabel") then
                                    if not v:FindFirstChildOfClass("UICorner") then
                                        local uc=Instance.new("UICorner"); uc.CornerRadius=UDim.new(0,6); uc.Parent=v
                                    end
                                    if not v:FindFirstChildOfClass("UIStroke") then
                                        local us=Instance.new("UIStroke"); us.Thickness=1.5; us.Color=Color3.fromRGB(110,0,100); us.Parent=v
                                    end
                                    local us=v:FindFirstChildOfClass("UIStroke")
                                    if us and not us:FindFirstChildOfClass("UIGradient") then
                                        local ug=Instance.new("UIGradient")
                                        ug.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(0.25,Color3.fromRGB(110,0,100)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(0,0,0)),ColorSequenceKeypoint.new(0.75,Color3.fromRGB(110,0,100)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))})
                                        ug.Parent=us
                                        RunService.Heartbeat:Connect(function() if ug.Parent then ug.Rotation=(ug.Rotation+1)%360 end end)
                                    end
                                end
                            end
                        end
                        applyGlow(AKMainFrame)
                    end)
                end)

                if AKMainFrame:FindFirstChildOfClass("UIStroke") then
                    AKMainFrame:FindFirstChildOfClass("UIStroke"):Destroy()
                end

                AKGradient.Parent = AKMainFrame
                AKGradient.Offset = Vector2.new(-1, 0)

                AKGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(50, 50, 50)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(125, 125, 125)),
                    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(50, 50, 50)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
                })

                local AKStroke = Instance.new("UIStroke")
                
                AKStroke.Parent = AKMainFrame
                AKStroke.ApplyStrokeMode = "Border"
                AKStroke.Thickness = 4
                AKStroke.Color = Color3.fromRGB(255, 255, 255)

                local AKStrokeGradient = Instance.new("UIGradient")

                AKStrokeGradient.Name = "UIGradient"
                AKStrokeGradient.Parent = AKStroke
                AKStrokeGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, UITheme.Primary),
                    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(50, 50, 50)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(50, 50, 50)),
                    ColorSequenceKeypoint.new(1, UITheme.Primary),
                })            

                if AKMainFrame then
                    local AKMainCorner = AKMainFrame:FindFirstChildOfClass("UICorner")

                    AKMainCorner.CornerRadius = UDim.new(0.025, 0)

                    for _, GetAKTItle in next, AKMainFrame:GetDescendants() do
                        if GetAKTItle:IsA("TextLabel") or GetAKTItle:IsA("TextButton") then
                            if string.match(GetAKTItle.Text, "AK REANIMATION") then
                                GetAKTItle.Text = "AC Reanimation"
                                GetAKTItle.TextSize = 16
                                GetAKTItle.FontFace = Font.new("rbxasset:".._sl.."fonts/families/Cartoon.json", Enum.FontWeight.Bold)
                            else
                                GetAKTItle.TextSize = 14
                                GetAKTItle.FontFace = Font.new("rbxasset:".._sl.."fonts/families/Cartoon.json", Enum.FontWeight.Regular)
                            end
                        end
                    end
                    
                    for _, FindToggleFrame in next, AKMainFrame:GetDescendants() do
                        if FindToggleFrame:IsA("Frame") and FindToggleFrame.Size == UDim2.new(0, 40, 0, 18) then
                            local GetToggle = FindToggleFrame:FindFirstChild("Frame")

                            FindToggleFrame:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
                                if GetToggle.Position == UDim2.new(1, -16, 0, 2) then
                                    FindToggleFrame.BackgroundColor3 = UITheme.Primary
                                elseif GetToggle.Position == UDim2.new(0, 2, 0, 2) then
                                    FindToggleFrame.BackgroundColor3 = UITheme.Shadow
                                end

                            if FindToggleFrame.BackgroundColor3 == Color3.fromRGB(0, 150, 255) then
                                FindToggleFrame.BackgroundColor3 = UITheme.Primary
                            elseif FindToggleFrame.BackgroundColor3 == Color3.fromRGB(10, 150, 255) then
                                    FindToggleFrame.BackgroundColor3 = UITheme.Primary
                                end
                            end)

                            if GetToggle then
                                GetToggle:GetPropertyChangedSignal("Position"):Connect(function()
                                    if GetToggle.Position == UDim2.new(1, -16, 0, 2) then
                                        FindToggleFrame.BackgroundColor3 = UITheme.Primary
                                    elseif GetToggle.Position == UDim2.new(0, 2, 0, 2) then
                                        FindToggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                                    end
                                end)
                            end

                            for _, GetCorners in next, FindToggleFrame.Parent:GetDescendants() do
                                if GetCorners:IsA("UICorner") then
                                    GetCorners.CornerRadius = UDim.new(1, 0)
                                end
                            end

                            AKMainFrame.DescendantAdded:Connect(function(Descendant)
                                if Descendant:IsA("TextButton") then
                                    Descendant:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
                                        if Descendant.BackgroundColor3 == Color3.fromRGB(0, 150, 255) then
                                            Descendant.BackgroundColor3 = UITheme.Primary
                                        end
                                    end)
                                end
                            end)

                            RunService.Heartbeat:Connect(function(Delta)
                                local XOffset = AKGradient.Offset.X + 0.5 * Delta * 1.8
                                
                                if XOffset >= 1 then
                                    XOffset = -1 + (XOffset - 1)
                                end
                                
                                AKGradient.Offset = Vector2.new(XOffset, 0)
                            end)

                            while task.wait() do
                                if AKStrokeGradient.Rotation > 360 then
                                    AKStrokeGradient.Rotation = 0
                                elseif AKStrokeGradient.Rotation < 0 then
                                    AKStrokeGradient.Rotation = 0
                                end
                                
                                AKStrokeGradient.Rotation += 1
                            end
                        end
                    end
                end
            end
        end},
    })
    pageCardRow(s,idx,{{label="Anim Copier",cmd="+animcopier",desc="Opens the animation copier -- mirror another player's animations.",callback=function() if openAnimCopier then openAnimCopier() end end}},80)

    -- -- IDLE ANIMATIONS --------------------------------------
    secLabel(s,"IDLE ANIMATIONS",idx)

    -- All idle packs (original AC + ET extras)
    local idleAnims = {
        {"Vampire",    {idle1="1083445855",idle2="1083450166",walk="1083473930",run="1083462077",jump="1083455352",climb="1083439238",fall="1083443587",swim="1083462077",swimidle="1083445855"}},
        {"Hero",       {idle1="616111295", idle2="616113536", walk="616122287", run="616117076", jump="616115533", climb="616104706", fall="616108001", swim="616119360",  swimidle="616120861"}},
        {"Zombie",     {idle1="616158929", idle2="616160636", walk="616168032", run="616163682", jump="616161997", climb="616156119", fall="616157476", swim="616165109",  swimidle="616166655"}},
        {"Mage",       {idle1="707742142", idle2="707855907", walk="707897309", run="707861613", jump="707853694", climb="707826056", fall="707829716", swim="707876443",  swimidle="707894699"}},
        {"Ghost",      {idle1="616006778", idle2="616008087", walk="616010382", run="616013216", jump="616008936", climb="616003713", fall="616005863", swim="616006778",  swimidle="616008087"}},
        {"Elder",      {idle1="845397899", idle2="845400520", walk="845403856", run="845386501", jump="845398858", climb="845392038", fall="845396048", swim="845401742",  swimidle="845403127"}},
        {"Levitation", {idle1="616006778", idle2="616008087", walk="616013216", run="616010382", jump="616008936", climb="616003713", fall="616005863", swim="616006778",  swimidle="616008087"}},
        {"Astronaut",  {idle1="891621366", idle2="891633237", walk="891667138", run="891636393", jump="891627522", climb="891609353", fall="891617961", swim="891639666",  swimidle="891663592"}},
        {"Ninja",      {idle1="656117400", idle2="656118341", walk="656121766", run="656118852", jump="656117878", climb="656114359", fall="656115606", swim="656117400",  swimidle="656118341"}},
        {"Werewolf",   {idle1="1083195517",idle2="1083214717",walk="1083178339",run="1083216690",jump="1083218792",climb="1083182000",fall="1083189019",swim="1083222527", swimidle="1083225406"}},
        {"Cartoon",    {idle1="742637544", idle2="742638445", walk="742640026", run="742638842", jump="742637942", climb="742636889", fall="742637151", swim="742637544",  swimidle="742638445"}},
        {"Pirate",     {idle1="750781874", idle2="750782770", walk="750785693", run="750783738", jump="750782230", climb="750779899", fall="750780242", swim="750784579",  swimidle="750785176"}},
        {"Sneaky",     {idle1="1132473842",idle2="1132477671",walk="1132510133",run="1132494274",jump="1132489853",climb="1132461372",fall="1132469004",swim="1132473842", swimidle="1132477671"}},
        {"Toy",        {idle1="782841498", idle2="782845736", walk="782843345", run="782842708", jump="782847020", climb="782843869", fall="782846423", swim="782844582",  swimidle="782845186"}},
        {"Knight",     {idle1="657595757", idle2="657568135", walk="657552124", run="657564596", jump="658409194", climb="658360781", fall="657600338", swim="657560551",  swimidle="657557095"}},
        {"Confident",  {idle1="1069977950",idle2="1069987858",walk="1070017263",run="1070001516",jump="1069984524",climb="1069946257",fall="1069973677",swim="1069977950", swimidle="1069987858"}},
        {"Popstar",    {idle1="1212900985",idle2="1212900985",walk="1212980338",run="1212980348",jump="1212954642",climb="1213044953",fall="1212900995",swim="1212900985", swimidle="1212900985"}},
        {"Princess",   {idle1="941003647", idle2="941013098", walk="941028902", run="941015281", jump="941008832", climb="940996062", fall="941000007", swim="941003647",  swimidle="941013098"}},
        {"Cowboy",     {idle1="1014390418",idle2="1014398616",walk="1014421541",run="1014401683",jump="1014394726",climb="1014380606",fall="1014384571",swim="1014390418", swimidle="1014398616"}},
        {"Patrol",     {idle1="1149612882",idle2="1150842221",walk="1151231493",run="1150967949",jump="1150944216",climb="1148811837",fall="1148863382",swim="1149612882", swimidle="1150842221"}},
        {"FE Zombie",  {idle1="3489171152",idle2="3489171152",walk="3489174223",run="3489173414",jump="616161997", climb="616156119", fall="616157476", swim="616165109",  swimidle="616166655"}},
        -- EmptyTools extras
        {"Bubbly",     {idle1="910004836", idle2="910009958", walk="910034870", run="910025107", jump="910016857", climb="909997997",fall="910001910", swim="910028158",   swimidle="910030921"}},
        {"Superhero",  {idle1="616111295", idle2="616113536", walk="616122287", run="616117076", jump="616115533", climb="616104706",fall="616108001", swim="616119360",   swimidle="616120861"}},
        {"Rthro",      {idle1="2510197257",idle2="2510196951",walk="2510202577",run="2510198475",jump="2510197830",climb="2510192778",fall="2510195892",swim="2510199791", swimidle="2510201162"}},
        {"Oldschool",  {idle1="10921230744",idle2="10921230744",walk="10921244891",run="10921240218",jump="10921242013",climb="10921229866",fall="10921241244",swim="10921243048",swimidle="10921230744"}},
        {"Bold",       {idle1="16738333868",idle2="16738334710",walk="16738340646",run="16738337225",jump="10921263860",climb="16738332169",fall="16738333171",swim="16738339158",swimidle="16738339817"}},
        {"Robot",      {idle1="616088211", idle2="616089559", walk="616095330", run="616091570", jump="616090535", climb="616086039",fall="616087089", swim="616092998",   swimidle="616094091"}},
    }

    local function applyIdleAnim(anims)
        pcall(function()
            local char=lp.Character; if not char then return end
            local Animate=char:FindFirstChild("Animate"); if not Animate then return end
            Animate.Disabled=true
            local hum=char:FindFirstChildOfClass("Humanoid")
            if hum then for _,tr in pairs(hum:GetPlayingAnimationTracks()) do tr:Stop() end end
            local base="http:".._sl.."www.roblox.com/asset/?id="
            Animate.idle.Animation1.AnimationId=  base..anims.idle1
            Animate.idle.Animation2.AnimationId=  base..anims.idle2
            Animate.walk.WalkAnim.AnimationId=    base..anims.walk
            Animate.run.RunAnim.AnimationId=      base..anims.run
            Animate.jump.JumpAnim.AnimationId=    base..anims.jump
            Animate.climb.ClimbAnim.AnimationId=  base..anims.climb
            Animate.fall.FallAnim.AnimationId=    base..anims.fall
            -- swim support (from ET)
            pcall(function()
                if anims.swim and Animate:FindFirstChild("swim") and Animate.swim:FindFirstChild("Swim") then
                    Animate.swim.Swim.AnimationId=base..anims.swim
                end
                if anims.swimidle and Animate:FindFirstChild("swimidle") and Animate.swimidle:FindFirstChild("SwimIdle") then
                    Animate.swimidle.SwimIdle.AnimationId=base..anims.swimidle
                end
            end)
            if hum then hum:ChangeState(3) end
            Animate.Disabled=false
        end)
    end

    -- Search bar row (search box left, Reset Idle button right -- matches screenshot layout)
    local idleSearchRow = mkFrame(s,{Size=UDim2.new(1,0,0,36),BackgroundTransparency=1,LayoutOrder=nextOrder(idx),ZIndex=4})
    local idleSearchBox = Instance.new("TextBox")
    idleSearchBox.Size=UDim2.new(1,-100,1,0)
    idleSearchBox.BackgroundColor3=C.cardDark; idleSearchBox.BorderSizePixel=0
    idleSearchBox.Font=Enum.Font.Gotham; idleSearchBox.TextColor3=C.white
    idleSearchBox.PlaceholderText=" Search idle..."; idleSearchBox.PlaceholderColor3=C.txtDim
    idleSearchBox.TextSize=12; idleSearchBox.Text=""; idleSearchBox.ClearTextOnFocus=false
    idleSearchBox.ZIndex=5; idleSearchBox.TextXAlignment=Enum.TextXAlignment.Left
    idleSearchBox.Parent=idleSearchRow; corner(idleSearchBox,8); mkStroke(idleSearchBox,C.cardBord,1)
    do local p=Instance.new("UIPadding"); p.PaddingLeft=UDim.new(0,10); p.Parent=idleSearchBox end

    local resetIdleBtn=mkBtn(idleSearchRow,"Reset Idle",{
        Size=UDim2.new(0,90,1,0),Position=UDim2.new(1,-90,0,0),
        BackgroundColor3=C.purpleDim,TextSize=10,Font=Enum.Font.GothamBold,ZIndex=5
    })
    corner(resetIdleBtn,8); mkStroke(resetIdleBtn,C.cardBord,1)
    resetIdleBtn.MouseEnter:Connect(function() TweenService:Create(resetIdleBtn,TweenInfo.new(0.08),{BackgroundColor3=C.purple}):Play() end)
    resetIdleBtn.MouseLeave:Connect(function() TweenService:Create(resetIdleBtn,TweenInfo.new(0.08),{BackgroundColor3=C.purpleDim}):Play() end)
    resetIdleBtn.Activated:Connect(function()
        pcall(function()
            local char=lp.Character; if not char then return end
            local A=char:FindFirstChild("Animate"); if not A then return end
            A.Disabled=true
            local hum=char:FindFirstChildOfClass("Humanoid")
            if hum then for _,tr in pairs(hum:GetPlayingAnimationTracks()) do tr:Stop() end end
            A.idle.Animation1.AnimationId="rbxassetid:".._sl.."507766388"; A.idle.Animation2.AnimationId="rbxassetid:".._sl.."507776680"
            A.walk.WalkAnim.AnimationId="rbxassetid:".._sl.."507777826"; A.run.RunAnim.AnimationId="rbxassetid:".._sl.."507767714"
            A.jump.JumpAnim.AnimationId="rbxassetid:".._sl.."507765644"; A.climb.ClimbAnim.AnimationId="rbxassetid:".._sl.."507765644"
            A.fall.FallAnim.AnimationId="rbxassetid:".._sl.."507767990"
            pcall(function()
                if A:FindFirstChild("swim") and A.swim:FindFirstChild("Swim") then A.swim.Swim.AnimationId="rbxassetid:".._sl.."616092998" end
                if A:FindFirstChild("swimidle") and A.swimidle:FindFirstChild("SwimIdle") then A.swimidle.SwimIdle.AnimationId="rbxassetid:".._sl.."616094091" end
            end)
            if hum then hum:ChangeState(3) end; A.Disabled=false
        end)
        resetIdleBtn.Text="+ Reset"; resetIdleBtn.BackgroundColor3=C.green
        task.delay(1.5,function() if resetIdleBtn.Parent then resetIdleBtn.Text="Reset Idle"; resetIdleBtn.BackgroundColor3=C.purpleDim end end)
    end)

    -- Build idle card rows, stored for search filtering
    local idleCardRows = {}
    for i=1,#idleAnims,2 do
        local a1=idleAnims[i]; local a2=idleAnims[i+1]
        local cards={}
        table.insert(cards,{label=a1[1],desc="Apply "..a1[1].." idle set.",callback=function() applyIdleAnim(a1[2]) end})
        if a2 then table.insert(cards,{label=a2[1],desc="Apply "..a2[1].." idle set.",callback=function() applyIdleAnim(a2[2]) end}) end
        local row=pageCardRow(s,idx,cards)
        -- store names for search
        table.insert(idleCardRows,{row=row, names={(a1[1]:lower()), (a2 and a2[1]:lower() or "")}})
    end

    -- Wire up idle search bar
    idleSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q=idleSearchBox.Text:lower()
        for _,entry in ipairs(idleCardRows) do
            if q=="" then
                entry.row.Visible=true
            else
                local match=false
                for _,name in ipairs(entry.names) do if name:find(q,1,true) then match=true; break end end
                entry.row.Visible=match
            end
        end
    end)
end

-- SUB-PANEL FUNCTIONS
-- Helper: attaches an external glow strokeWrap to any panel that uses ClipsDescendants
local function addPanelGlow(panel, radius)
    radius = radius or 12
    local sw=Instance.new("Frame"); sw.Size=panel.Size; sw.Position=panel.Position
    sw.BackgroundTransparency=1; sw.BorderSizePixel=0; sw.ZIndex=panel.ZIndex-1; sw.Parent=ScreenGui
    corner(sw, radius)
    -- Use thickness=3 BUT pre-bake the gradient so patcher never sees it fresh at rotation=0
    local _st=mkStroke(sw, C.sep, 3)
    local _pg=Instance.new("UIGradient")
    _pg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(0.25,Color3.fromRGB(120,0,110)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(0,0,0)),ColorSequenceKeypoint.new(0.75,Color3.fromRGB(120,0,110)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))})
    _pg.Rotation = 45 + math.random(0,270); _pg.Parent=_st
    RunService.Heartbeat:Connect(function() if _st.Parent then _pg.Rotation=(_pg.Rotation+1)%360 end end)
    RunService.RenderStepped:Connect(function()
        if panel.Parent then sw.Position=panel.Position; sw.Size=panel.Size
        else sw:Destroy() end
    end)
    return sw
end
local animLoggerOpen=false

local function openAnimLogger()
    if animLoggerOpen then return end; animLoggerOpen=true
    local MW,MH=250,320; local panel=Instance.new("Frame"); panel.Name="AnimLogger"; panel.Size=UDim2.new(0,MW,0,MH); panel.Position=UDim2.new(0.8,-MW/2,0.5,-MH/2); panel.BackgroundColor3=C.bg; panel.BorderSizePixel=0; panel.ClipsDescendants=false; panel.ZIndex=60; panel.Parent=ScreenGui; corner(panel,12); addPanelGlow(panel,12)
    local tBar2=mkFrame(panel,{Size=UDim2.new(1,0,0,35),BackgroundColor3=C.card,ZIndex=61}); corner(tBar2,12)
    mkLabel(tBar2,"Animation Logger",{Size=UDim2.new(1,-90,1,0),Position=UDim2.new(0,10,0,0),TextSize=13,Font=Enum.Font.GothamBold,TextColor3=C.white,ZIndex=62})
    local clrBtn=mkBtn(tBar2,"Clear",{Size=UDim2.new(0,38,0,22),Position=UDim2.new(1,-90,0.5,-11),TextSize=10,Font=Enum.Font.Gotham,ZIndex=62}); corner(clrBtn,6)
    local clsBtn=mkBtn(tBar2,"x",{Size=UDim2.new(0,24,0,22),Position=UDim2.new(1,-28,0.5,-11),TextSize=11,Font=Enum.Font.GothamBold,ZIndex=62}); corner(clsBtn,5); hov(clsBtn,C.purple,Color3.fromRGB(160,30,30))
    clsBtn.Activated:Connect(function() panel:Destroy(); animLoggerOpen=false end)
    local logScroll=Instance.new("ScrollingFrame"); logScroll.Position=UDim2.new(0,8,0,42); logScroll.Size=UDim2.new(1,-16,1,-50); logScroll.BackgroundTransparency=1; logScroll.BorderSizePixel=0; logScroll.ScrollBarThickness=3; logScroll.ScrollBarImageColor3=C.sep; logScroll.CanvasSize=UDim2.new(0,0,0,0); logScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; logScroll.ZIndex=61; logScroll.Parent=panel
    local logLL=Instance.new("UIListLayout"); logLL.Padding=UDim.new(0,4); logLL.SortOrder=Enum.SortOrder.LayoutOrder; logLL.Parent=logScroll
    local logged={}; local eCount=0
    local function addEntry(track) local animId=track.Animation.AnimationId; if logged[animId] then return end; logged[animId]=true; eCount=eCount+1; local numId=animId:match("rbxassetid:".._sl.."(%d+)") or animId:match("(%d+)") or animId; local entry=mkFrame(logScroll,{Size=UDim2.new(1,0,0,50),BackgroundColor3=C.cardDark,LayoutOrder=eCount,ZIndex=62}); corner(entry,8); mkStroke(entry,C.sep,2); local topLbl=mkLabel(entry,"rbxassetid:".._sl..""..numId,{Size=UDim2.new(1,-50,0,20),Position=UDim2.new(0,8,0,6),TextSize=11,Font=Enum.Font.GothamBold,TextColor3=C.white,ZIndex=63,TextTruncate=Enum.TextTruncate.AtEnd}); mkLabel(entry,"ID: "..numId,{Size=UDim2.new(1,-50,0,16),Position=UDim2.new(0,8,1,-22),TextSize=9,Font=Enum.Font.Gotham,TextColor3=C.txtDim,ZIndex=63,TextTruncate=Enum.TextTruncate.AtEnd}); task.spawn(function() local ok,info=pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(tonumber(numId),Enum.InfoType.Asset) end); if ok and info and info.Name and entry.Parent then topLbl.Text=info.Name end end); local cpBtn=mkBtn(entry,"Copy",{Size=UDim2.new(0,38,0,28),Position=UDim2.new(1,-44,0.5,-14),TextSize=10,Font=Enum.Font.Gotham,ZIndex=63}); corner(cpBtn,6); hov(cpBtn,C.purple,C.purpleDim); cpBtn.Activated:Connect(function() pcall(function() setclipboard(numId) end); cpBtn.Text="OK"; cpBtn.BackgroundColor3=C.green; task.delay(1,function() if cpBtn.Parent then cpBtn.Text="Copy"; cpBtn.BackgroundColor3=C.purple end end) end); logScroll.CanvasSize=UDim2.new(0,0,0,logLL.AbsoluteContentSize.Y) end
    clrBtn.Activated:Connect(function() for _,c in ipairs(logScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end; logged={}; eCount=0; logScroll.CanvasSize=UDim2.new(0,0,0,0) end)
    local function hookAnim(char) local hum=char:WaitForChild("Humanoid"); local anim2=hum:WaitForChild("Animator"); anim2.AnimationPlayed:Connect(addEntry) end
    if lp.Character then task.spawn(hookAnim,lp.Character) end; lp.CharacterAdded:Connect(function(c) task.spawn(hookAnim,c) end)
    do local dd3,dds3,dsp3,dm3=false,nil,nil,false; tBar2.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dd3=true; dm3=false; dds3=i.Position; dsp3=panel.Position; _acSubPanelDragging=true; i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dd3=false; _acSubPanelDragging=false end end) end end); UserInputService.InputChanged:Connect(function(i) if dd3 and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-dds3; if not dm3 and (math.abs(d.X)>4 or math.abs(d.Y)>4) then dm3=true end; if dm3 then panel.Position=UDim2.new(dsp3.X.Scale,dsp3.X.Offset+d.X,dsp3.Y.Scale,dsp3.Y.Offset+d.Y) end end end); UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dd3=false; _acSubPanelDragging=false end end) end
end

local autoClickerOpen=false
local function openAutoClicker()
    if autoClickerOpen then return end; autoClickerOpen=true
    local PW,PH=220,100; local panel=Instance.new("Frame"); panel.Name="AutoClicker"; panel.Size=UDim2.new(0,PW,0,PH); panel.Position=UDim2.new(0.5,-PW/2,0.3,-PH/2); panel.BackgroundColor3=C.bg; panel.BorderSizePixel=0; panel.ClipsDescendants=false; panel.ZIndex=60; panel.Parent=ScreenGui; corner(panel,12); addPanelGlow(panel,12)
    local tBar3=mkFrame(panel,{Size=UDim2.new(1,0,0,30),BackgroundColor3=C.card,ZIndex=61}); corner(tBar3,12); mkLabel(tBar3,"Auto Clicker",{Size=UDim2.new(1,-26,1,0),Position=UDim2.new(0,0,0,0),TextSize=13,Font=Enum.Font.GothamBold,TextColor3=C.white,ZIndex=62,TextXAlignment=Enum.TextXAlignment.Center})
    local clsBtn3=mkBtn(tBar3,"x",{Size=UDim2.new(0,22,0,22),Position=UDim2.new(1,-24,0.5,-11),TextSize=11,Font=Enum.Font.GothamBold,ZIndex=62}); corner(clsBtn3,5); hov(clsBtn3,C.purple,Color3.fromRGB(160,30,30)); clsBtn3.Activated:Connect(function() panel:Destroy(); autoClickerOpen=false end)
    local ctFrame=mkFrame(panel,{Size=UDim2.new(1,0,1,-30),Position=UDim2.new(0,0,0,30),BackgroundTransparency=1,ZIndex=61})
    mkBtn(ctFrame,"Auto Clicker -- Coming Soon",{Size=UDim2.new(1,-20,0,34),Position=UDim2.new(0,10,0,10),BackgroundColor3=Color3.fromRGB(25,25,25),TextSize=11,Font=Enum.Font.GothamBold,TextColor3=C.txtDim,ZIndex=62}); corner(ctFrame:FindFirstChildOfClass("TextButton"),8)
    do local dd4,dds4,dsp4,dm4=false,nil,nil,false; tBar3.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dd4=true; dm4=false; dds4=i.Position; dsp4=panel.Position; _acSubPanelDragging=true; i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dd4=false; _acSubPanelDragging=false end end) end end); UserInputService.InputChanged:Connect(function(i) if dd4 and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-dds4; if not dm4 and (math.abs(d.X)>4 or math.abs(d.Y)>4) then dm4=true end; if dm4 then panel.Position=UDim2.new(dsp4.X.Scale,dsp4.X.Offset+d.X,dsp4.Y.Scale,dsp4.Y.Offset+d.Y) end end end); UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dd4=false; _acSubPanelDragging=false end end) end
end

local function mkStdPanel(name,w,h,title)
    -- Outer shell: ClipsDescendants=true + UICorner = children get masked to
    -- the rounded shape, fixing both the tBar corner bleed AND the minimize crop.
    local panel=Instance.new("Frame")
    panel.Name=name; panel.Size=UDim2.new(0,w,0,h); panel.Position=UDim2.new(0.5,-w/2,0.5,-h/2)
    panel.BackgroundColor3=C.bg; panel.BorderSizePixel=0
    panel.ClipsDescendants=true  -- clips children to rounded shape
    panel.ZIndex=70; panel.Parent=ScreenGui
    corner(panel,12)
    -- Stroke goes on a separate wrapper so it isn't clipped by the parent
    local strokeWrap=Instance.new("Frame")
    strokeWrap.Size=UDim2.new(1,0,1,0); strokeWrap.BackgroundTransparency=1
    strokeWrap.BorderSizePixel=0; strokeWrap.ZIndex=69; strokeWrap.Parent=ScreenGui
    strokeWrap.Position=panel.Position
    corner(strokeWrap,12); mkStroke(strokeWrap,C.sep,3)
    -- Keep stroke wrapper in sync with panel position (direct sync, no frame delay)
    local function syncStroke()
        if panel.Parent then strokeWrap.Position=panel.Position; strokeWrap.Size=panel.Size
        else strokeWrap:Destroy() end
    end
    RunService.RenderStepped:Connect(syncStroke)
    local tBar=mkFrame(panel,{Size=UDim2.new(1,0,0,36),BackgroundColor3=C.card,ZIndex=71}); corner(tBar,10)
    -- No UICorner on tBar -- panel's ClipsDescendants masks it cleanly
    mkLabel(tBar,title,{Size=UDim2.new(1,-70,1,0),Position=UDim2.new(0,12,0,0),TextSize=13,Font=Enum.Font.GothamBold,TextColor3=C.white,ZIndex=72})
    local minB=mkBtn(tBar,"--",{Size=UDim2.new(0,24,0,22),Position=UDim2.new(1,-54,0.5,-11),TextSize=11,Font=Enum.Font.GothamBold,ZIndex=72}); corner(minB,5); hov(minB,C.purple,C.purpleDim)
    local clsB=mkBtn(tBar,"x",{Size=UDim2.new(0,24,0,22),Position=UDim2.new(1,-28,0.5,-11),TextSize=11,Font=Enum.Font.GothamBold,ZIndex=72}); corner(clsB,5); hov(clsB,C.purple,Color3.fromRGB(160,30,30))
    local minimized=false
    minB.Activated:Connect(function()
        minimized=not minimized
        if minimized then
            TweenService:Create(panel,TweenInfo.new(0.18,Enum.EasingStyle.Quint),{Size=UDim2.new(0,w,0,36)}):Play()
            minB.Text="+"
        else
            TweenService:Create(panel,TweenInfo.new(0.18,Enum.EasingStyle.Quint),{Size=UDim2.new(0,w,0,h)}):Play()
            minB.Text="--"
        end
    end)
    local content=mkFrame(panel,{Size=UDim2.new(1,-16,1,-44),Position=UDim2.new(0,8,0,40),BackgroundTransparency=1,ZIndex=71})
    do local dd,dds,dsp,dm=false,nil,nil,false
        tBar.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                dd=true; dm=false; dds=i.Position; dsp=panel.Position; _acSubPanelDragging=true
                i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dd=false; _acSubPanelDragging=false end end)
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dd and i.UserInputType==Enum.UserInputType.MouseMovement then
                local d=i.Position-dds
                if not dm and (math.abs(d.X)>4 or math.abs(d.Y)>4) then dm=true end
                if dm then
                    panel.Position=UDim2.new(dsp.X.Scale,dsp.X.Offset+d.X,dsp.Y.Scale,dsp.Y.Offset+d.Y)
                    syncStroke()
                end
            end
        end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dd=false; _acSubPanelDragging=false end end)
    end
    return panel,content,clsB
end

-- -- TIME PANEL ----------------------------------------------
openTimePanel = function()
    if timePanelInstance and timePanelInstance.Parent then
        timePanelInstance.Visible=not timePanelInstance.Visible; return
    end
    local PW,PH=240,95
    local panel,content,clsB=mkStdPanel("TimePanel",PW,PH,"Time of Day")
    timePanelInstance=panel
    clsB.Activated:Connect(function() panel:Destroy(); timePanelInstance=nil end)
    local timeLbl=mkLabel(content,"14:00",{Size=UDim2.new(1,0,0,18),Position=UDim2.new(0,0,0,0),TextSize=13,Font=Enum.Font.GothamBold,TextColor3=C.white,ZIndex=72,TextXAlignment=Enum.TextXAlignment.Center})
    local track=mkFrame(content,{Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,0,26),BackgroundColor3=C.sliderBg,ZIndex=72}); corner(track,5)
    local pct=(Lighting.ClockTime or 14)/24
    local fill=mkFrame(track,{Size=UDim2.new(pct,0,1,0),BackgroundColor3=C.sliderFg,ZIndex=73}); corner(fill,5)
    local knob=mkFrame(track,{Size=UDim2.new(0,18,0,18),Position=UDim2.new(pct,-9,0.5,-9),BackgroundColor3=C.white,ZIndex=74}); corner(knob,9)
    local ih=math.floor(pct*24); local im=math.floor((pct*24-ih)*60); timeLbl.Text=string.format("%02d:%02d",ih,im)
    local function updateTime(x)
        local p=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1); local v=p*24
        fill.Size=UDim2.new(p,0,1,0); knob.Position=UDim2.new(p,-9,0.5,-9)
        local h2=math.floor(v); local m2=math.floor((v-h2)*60)
        timeLbl.Text=string.format("%02d:%02d",h2,m2)
        pcall(function() Lighting.ClockTime=v end)
    end
    local dragging=false
    track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; updateTime(i.Position.X) end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then updateTime(i.Position.X) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
end


local function mkActivateBtn(parent,yPos)
    local b=mkBtn(parent,"Activate",{Size=UDim2.new(1,0,0,34),Position=UDim2.new(0,0,0,yPos),BackgroundColor3=C.cardDark,TextSize=13,Font=Enum.Font.GothamBold,ZIndex=72}); corner(b,8); mkStroke(b,C.cardBord,1)
    b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.05),{BackgroundColor3=C.card}):Play() end); b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.05),{BackgroundColor3=C.cardDark}):Play() end); return b
end

local animCopierOpen=false
local openAnimCopier
openAnimCopier=function()
    if animCopierOpen then return end; animCopierOpen=true
    local CW,CH=300,340; local panel,ct,cls=mkStdPanel("AnimCopier",CW,CH,"Animation Copier"); cls.Activated:Connect(function() panel:Destroy(); animCopierOpen=false end)
    local copyTarget=nil; local copyActive=false; local copySide="Right"; local copyDist=4.0; local copyConn=nil
    local statusLblAC=mkLabel(ct,"No player selected",{Size=UDim2.new(1,0,0,16),TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.txtDim,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=72})
    local searchRow=mkFrame(ct,{Size=UDim2.new(1,0,0,28),Position=UDim2.new(0,0,0,22),BackgroundTransparency=1,ZIndex=72})
    local searchBoxAC=Instance.new("TextBox"); searchBoxAC.Size=UDim2.new(1,-68,1,0); searchBoxAC.BackgroundColor3=Color3.fromRGB(10,0,10); searchBoxAC.BorderSizePixel=0; searchBoxAC.Font=Enum.Font.Gotham; searchBoxAC.TextSize=11; searchBoxAC.TextColor3=C.white; searchBoxAC.PlaceholderText="Search players..."; searchBoxAC.PlaceholderColor3=C.txtDim; searchBoxAC.Text=""; searchBoxAC.ClearTextOnFocus=false; searchBoxAC.ZIndex=72; searchBoxAC.Parent=searchRow; corner(searchBoxAC,6); mkStroke(searchBoxAC,C.sep,1)
    do local kp=Instance.new("UIPadding"); kp.PaddingLeft=UDim.new(0,8); kp.Parent=searchBoxAC end
    local refreshBtn=mkBtn(searchRow,"Refresh",{Size=UDim2.new(0,62,1,0),Position=UDim2.new(1,-62,0,0),BackgroundColor3=C.purple,TextSize=11,Font=Enum.Font.GothamBold,ZIndex=72}); corner(refreshBtn,6)
    local pListScroll=Instance.new("ScrollingFrame"); pListScroll.Size=UDim2.new(1,0,0,130); pListScroll.Position=UDim2.new(0,0,0,56); pListScroll.BackgroundTransparency=1; pListScroll.BorderSizePixel=0; pListScroll.ScrollBarThickness=3; pListScroll.ScrollBarImageColor3=C.purple; pListScroll.CanvasSize=UDim2.new(0,0,0,0); pListScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; pListScroll.ZIndex=72; pListScroll.Parent=ct
    local pLL2=Instance.new("UIListLayout"); pLL2.Padding=UDim.new(0,3); pLL2.Parent=pListScroll
    local function buildPlayerList() for _,c in ipairs(pListScroll:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end; local filter=searchBoxAC.Text:lower(); for _,plr in ipairs(Players:GetPlayers()) do if plr~=lp and (filter=="" or plr.Name:lower():find(filter,1,true)) then local row=mkFrame(pListScroll,{Size=UDim2.new(1,0,0,30),BackgroundColor3=copyTarget==plr and C.purple or C.cardDark,ZIndex=73}); corner(row,8); mkStroke(row,C.cardBord,1); mkLabel(row,plr.Name,{Size=UDim2.new(1,-10,1,0),Position=UDim2.new(0,8,0,0),TextSize=11,Font=Enum.Font.GothamBold,TextColor3=C.white,ZIndex=74}); local sel=Instance.new("TextButton"); sel.Size=UDim2.new(1,0,1,0); sel.BackgroundTransparency=1; sel.Text=""; sel.ZIndex=74; sel.Parent=row; local pr=plr; sel.Activated:Connect(function() copyTarget=pr; statusLblAC.Text=pr.Name; buildPlayerList() end) end end end
    buildPlayerList(); refreshBtn.Activated:Connect(buildPlayerList); searchBoxAC:GetPropertyChangedSignal("Text"):Connect(buildPlayerList)
    mkLabel(ct,"CONTROLS",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,192),TextSize=9,Font=Enum.Font.GothamBold,TextColor3=C.txtDim,ZIndex=72})
    local activateBtn=mkBtn(ct,"Activate Copy",{Size=UDim2.new(1,0,0,32),Position=UDim2.new(0,0,0,210),BackgroundColor3=C.cardDark,TextSize=12,Font=Enum.Font.GothamBold,ZIndex=72}); corner(activateBtn,8); mkStroke(activateBtn,C.cardBord,1)
    activateBtn.MouseEnter:Connect(function() TweenService:Create(activateBtn,TweenInfo.new(0.05),{BackgroundColor3=C.card}):Play() end); activateBtn.MouseLeave:Connect(function() TweenService:Create(activateBtn,TweenInfo.new(0.05),{BackgroundColor3=C.cardDark}):Play() end)
    mkLabel(ct,"Distance",{Size=UDim2.new(0,60,0,14),Position=UDim2.new(0,0,0,250),TextSize=10,Font=Enum.Font.GothamBold,TextColor3=C.txtDim,ZIndex=72}); local distLbl=mkLabel(ct,tostring(copyDist).." st",{Size=UDim2.new(0,36,0,14),Position=UDim2.new(1,-36,0,250),TextSize=10,Font=Enum.Font.GothamBold,TextColor3=C.white,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=72})
    local distTrack=mkFrame(ct,{Size=UDim2.new(1,0,0,8),Position=UDim2.new(0,0,0,266),BackgroundColor3=C.sliderBg,ZIndex=72}); corner(distTrack,4); local distFill=mkFrame(distTrack,{Size=UDim2.new(copyDist/20,0,1,0),BackgroundColor3=C.sliderFg,ZIndex=73}); corner(distFill,4); local distKnob=mkFrame(distTrack,{Size=UDim2.new(0,14,0,14),Position=UDim2.new(copyDist/20,-7,0.5,-7),BackgroundColor3=C.white,ZIndex=74}); corner(distKnob,7)
    local distDrag=false
    distTrack.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then distDrag=true; local p=math.clamp((i.Position.X-distTrack.AbsolutePosition.X)/distTrack.AbsoluteSize.X,0,1); copyDist=math.floor(p*20*10)/10; distFill.Size=UDim2.new(p,0,1,0); distKnob.Position=UDim2.new(p,-7,0.5,-7); distLbl.Text=tostring(copyDist).." st" end end)
    UserInputService.InputChanged:Connect(function(i) if distDrag and i.UserInputType==Enum.UserInputType.MouseMovement then local p=math.clamp((i.Position.X-distTrack.AbsolutePosition.X)/distTrack.AbsoluteSize.X,0,1); copyDist=math.floor(p*20*10)/10; distFill.Size=UDim2.new(p,0,1,0); distKnob.Position=UDim2.new(p,-7,0.5,-7); distLbl.Text=tostring(copyDist).." st" end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then distDrag=false end end)
    local sideRow=mkFrame(ct,{Size=UDim2.new(1,0,0,28),Position=UDim2.new(0,0,0,282),BackgroundTransparency=1,ZIndex=72}); mkLabel(sideRow,"Side",{Size=UDim2.new(0,40,1,0),TextSize=11,Font=Enum.Font.GothamBold,TextColor3=C.txtDim,ZIndex=72})
    local leftBtn=mkBtn(sideRow,"Left",{Size=UDim2.new(0,80,1,0),Position=UDim2.new(0,44,0,0),BackgroundColor3=C.cardDark,TextSize=11,Font=Enum.Font.GothamBold,ZIndex=72}); corner(leftBtn,6)
    local rightBtn=mkBtn(sideRow,"Right",{Size=UDim2.new(0,80,1,0),Position=UDim2.new(0,130,0,0),BackgroundColor3=C.purple,TextSize=11,Font=Enum.Font.GothamBold,ZIndex=72}); corner(rightBtn,6)
    leftBtn.Activated:Connect(function() copySide="Left"; leftBtn.BackgroundColor3=C.purple; rightBtn.BackgroundColor3=C.cardDark end)
    rightBtn.Activated:Connect(function() copySide="Right"; rightBtn.BackgroundColor3=C.purple; leftBtn.BackgroundColor3=C.cardDark end)
    activateBtn.Activated:Connect(function()
        copyActive=not copyActive
        if copyActive then
            activateBtn.Text="Stop Copy"; activateBtn.BackgroundColor3=C.green
            copyConn=RunService.Heartbeat:Connect(function()
                if not copyActive then copyConn:Disconnect(); return end
                if not copyTarget or not copyTarget.Character then return end
                local tChar=copyTarget.Character; local tHum=tChar:FindFirstChildOfClass("Humanoid"); local tAnim=tHum and tHum:FindFirstChildOfClass("Animator")
                local mc=lp.Character; if not mc then return end
                local mHum=mc:FindFirstChildOfClass("Humanoid"); local mAnim=mHum and mHum:FindFirstChildOfClass("Animator")
                local tHRP=tChar:FindFirstChild("HumanoidRootPart"); local mHRP=mc:FindFirstChild("HumanoidRootPart")
                if tHRP and mHRP then local offset=copySide=="Left" and CFrame.new(-copyDist,0,0) or CFrame.new(copyDist,0,0); mHRP.CFrame=tHRP.CFrame*offset; mHRP.AssemblyLinearVelocity=tHRP.AssemblyLinearVelocity end
                if tAnim and mAnim then
                    local playing={}; for _,tr in ipairs(tAnim:GetPlayingAnimationTracks()) do playing[tr.Animation.AnimationId]=tr end
                    for _,tr in ipairs(mAnim:GetPlayingAnimationTracks()) do if not playing[tr.Animation.AnimationId] then tr:Stop(0) end end
                    for id,tr in pairs(playing) do local found=false; for _,myTr in ipairs(mAnim:GetPlayingAnimationTracks()) do if myTr.Animation.AnimationId==id then found=true; break end end; if not found then pcall(function() local anim=Instance.new("Animation"); anim.AnimationId=id; local newTr=mAnim:LoadAnimation(anim); newTr:Play(0); newTr.TimePosition=tr.TimePosition end) end end
                end
            end)
        else
            activateBtn.Text="Activate Copy"; activateBtn.BackgroundColor3=C.cardDark; if copyConn then copyConn:Disconnect(); copyConn=nil end
            pcall(function() local mc=lp.Character; if not mc then return end; local mHum=mc:FindFirstChildOfClass("Humanoid"); local mAnim=mHum and mHum:FindFirstChildOfClass("Animator"); if mAnim then for _,tr in ipairs(mAnim:GetPlayingAnimationTracks()) do tr:Stop(0) end end; if mHum then mHum.AutoRotate=true end; local animate=mc:FindFirstChild("Animate"); if animate then animate.Disabled=false end end)
        end
    end)
end

local antiBangOpen=false
local function openAntiBang()
    if antiBangOpen then return end; antiBangOpen=true; local panel,ct,cls=mkStdPanel("AntiBang",260,140,"Anti Bang"); cls.Activated:Connect(function() panel:Destroy(); antiBangOpen=false end)
    local enabled=true; local strict=false
    mkLabel(ct,"Press N in-game to toggle on/off",{Size=UDim2.new(1,0,0,16),TextSize=9,Font=Enum.Font.Gotham,TextColor3=C.txtDim,ZIndex=72})
    local row=mkFrame(ct,{Size=UDim2.new(1,0,0,34),Position=UDim2.new(0,0,0,22),BackgroundTransparency=1,ZIndex=72})
    local onBtn=mkBtn(row,"ON",{Size=UDim2.new(0.48,0,1,0),BackgroundColor3=C.purple,TextSize=12,Font=Enum.Font.GothamBold,ZIndex=72}); corner(onBtn,8)
    local strictBtn=mkBtn(row,"STRICT: OFF",{Size=UDim2.new(0.48,0,1,0),Position=UDim2.new(0.52,0,0,0),BackgroundColor3=C.cardDark,TextSize=11,Font=Enum.Font.GothamBold,ZIndex=72}); corner(strictBtn,8)
    mkLabel(ct,"Detects players doing animations near you",{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,0,0,62),TextSize=9,Font=Enum.Font.Gotham,TextColor3=C.txtDim,ZIndex=72})
    onBtn.Activated:Connect(function() enabled=not enabled; onBtn.Text=enabled and "ON" or "OFF"; onBtn.BackgroundColor3=enabled and C.purple or C.cardDark end)
    strictBtn.Activated:Connect(function() strict=not strict; strictBtn.Text=strict and "STRICT: ON" or "STRICT: OFF"; strictBtn.BackgroundColor3=strict and C.purple or C.cardDark end)
    local bangConn; local lastBang=0
    bangConn=RunService.Heartbeat:Connect(function()
        if not panel.Parent then bangConn:Disconnect(); return end; if not enabled then return end
        local char=lp.Character; if not char then return end; local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        for _,plr in ipairs(Players:GetPlayers()) do if plr~=lp and plr.Character then local h=plr.Character:FindFirstChildOfClass("Humanoid"); local rp2=h and h.RootPart; if rp2 and (hrp.Position-rp2.Position).Magnitude<2 then for _,tr in ipairs(h:GetPlayingAnimationTracks()) do if tr.Animation then local id=tr.Animation.AnimationId; local bang=strict or id:match("148840371") or id:match("5918726674"); if bang and (tick()-lastBang)>=0.5 then lastBang=tick(); pcall(function() workspace.Camera.CameraType=Enum.CameraType.Fixed; local h2=char:FindFirstChild("HumanoidRootPart"); local cf=h2.CFrame; h2.CFrame=cf+Vector3.new(0,-1e3,0); task.wait(0.1); h2.CFrame=cf; workspace.Camera.CameraType=Enum.CameraType.Custom end) end end end end end end
    end)
    UserInputService.InputBegan:Connect(function(i,gp) if not gp and i.KeyCode==Enum.KeyCode.N and panel.Parent then enabled=not enabled; onBtn.Text=enabled and "ON" or "OFF"; onBtn.BackgroundColor3=enabled and C.purple or C.cardDark end end)
end

local antiFlingConn=nil; local antiFlingOpen=false
local function openAntiFling()
    if antiFlingOpen then return end; antiFlingOpen=true; local panel,ct,cls=mkStdPanel("AntiFling",240,110,"Anti Fling")
    cls.Activated:Connect(function() if antiFlingConn then antiFlingConn:Disconnect(); antiFlingConn=nil end; panel:Destroy(); antiFlingOpen=false end)
    local active=false; local aBtn=mkActivateBtn(ct,0)
    mkLabel(ct,"Disables collisions and clears velocity",{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,0,0,40),TextSize=9,Font=Enum.Font.Gotham,TextColor3=C.txtDim,ZIndex=72})
    aBtn.Activated:Connect(function()
        active=not active
        if active then aBtn.Text="Activated"; aBtn.BackgroundColor3=C.green; antiFlingConn=RunService.Stepped:Connect(function() for _,plr in ipairs(Players:GetPlayers()) do if plr~=lp and plr.Character then pcall(function() for _,p in ipairs(plr.Character:GetChildren()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide=false; if p.Name=="Torso" then p.Massless=true end; p.Velocity=Vector3.new(0,0,0); p.RotVelocity=Vector3.new(0,0,0) end end end) end end end)
        else aBtn.Text="Activate"; aBtn.BackgroundColor3=C.cardDark; if antiFlingConn then antiFlingConn:Disconnect(); antiFlingConn=nil end end
    end)
end

local antiAFKOpen=false
local function openBpColor()
    if bpColorOpen then return end; bpColorOpen=true
    local PW,PH=280,310
    local panel,ct,cls=mkStdPanel("BpColor",PW,PH,"Baseplate Color")
    cls.Activated:Connect(function() panel:Destroy(); bpColorOpen=false end)

    -- Find ALL baseplates (game may have multiple separated flat parts)
    local function getAllBaseplates()
        local list={}
        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                local name=v.Name:lower()
                local isBig=v.Size.X>100 and v.Size.Z>100 and v.Size.Y<=10
                if name=="baseplate" or (isBig and v.Anchored) then
                    table.insert(list,v)
                end
            end
        end
        return list
    end

    local hu=0; local sa=1; local va=1
    local previewFrame=mkFrame(ct,{Size=UDim2.new(1,0,0,32),Position=UDim2.new(0,0,0,0),BackgroundColor3=Color3.fromRGB(255,0,0),ZIndex=72}); corner(previewFrame,6)
    mkLabel(ct,"Preview",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,0),TextSize=9,Font=Enum.Font.Gotham,TextColor3=C.white,ZIndex=73,TextXAlignment=Enum.TextXAlignment.Center})

    local function applyColor()
        local col=Color3.fromHSV(hu,sa,va)
        previewFrame.BackgroundColor3=col
        pcall(function()
            for _,bp in ipairs(getAllBaseplates()) do
                bp.Color=col; bp.Material=Enum.Material.SmoothPlastic
            end
        end)
    end

    local function mkBar(yPos,lbl)
        mkLabel(ct,lbl,{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,yPos),TextSize=10,Font=Enum.Font.GothamBold,TextColor3=C.txtDim,ZIndex=72})
        local bar=mkFrame(ct,{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,0,0,yPos+16),BackgroundColor3=Color3.fromRGB(40,40,40),ZIndex=72}); corner(bar,4)
        local knob=mkFrame(bar,{Size=UDim2.new(0,14,0,14),Position=UDim2.new(1,-7,0.5,-7),BackgroundColor3=C.white,ZIndex=73}); corner(knob,7)
        return bar,knob
    end

    -- Hue bar
    local hBar,hKnob=mkBar(40,"Hue")
    local hg=Instance.new("UIGradient"); hg.Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(255,0,0)),
        ColorSequenceKeypoint.new(0.17,Color3.fromRGB(255,255,0)),
        ColorSequenceKeypoint.new(0.33,Color3.fromRGB(0,255,0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
        ColorSequenceKeypoint.new(0.67,Color3.fromRGB(0,0,255)),
        ColorSequenceKeypoint.new(0.83,Color3.fromRGB(255,0,255)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(255,0,0)),
    }; hg.Parent=hBar

    -- Saturation bar
    local sBar,sKnob=mkBar(80,"Saturation")
    local sg=Instance.new("UIGradient"); sg.Parent=sBar

    -- Value/brightness bar
    local vBar,vKnob=mkBar(120,"Brightness")
    local vg=Instance.new("UIGradient"); vg.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))}; vg.Parent=vBar

    local function updateGradients()
        local hCol=Color3.fromHSV(hu,1,1)
        sg.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(1,hCol)}
    end
    updateGradients()

    -- Hex input
    mkLabel(ct,"Hex",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,160),TextSize=10,Font=Enum.Font.GothamBold,TextColor3=C.txtDim,ZIndex=72})
    local hexBox=Instance.new("TextBox"); hexBox.Size=UDim2.new(1,0,0,26); hexBox.Position=UDim2.new(0,0,0,176)
    hexBox.BackgroundColor3=C.cardDark; hexBox.BorderSizePixel=0; hexBox.PlaceholderText="#RRGGBB"
    hexBox.Text=""; hexBox.TextColor3=C.white; hexBox.PlaceholderColor3=C.txtDim
    hexBox.TextSize=12; hexBox.Font=Enum.Font.GothamBold; hexBox.ClearTextOnFocus=false; hexBox.ZIndex=72; hexBox.Parent=ct
    corner(hexBox,5); mkStroke(hexBox,C.sep,1)

    local function updateHex()
        local col=Color3.fromHSV(hu,sa,va)
        local r,g,b=math.floor(col.R*255),math.floor(col.G*255),math.floor(col.B*255)
        hexBox.Text=string.format("#%02X%02X%02X",r,g,b)
    end

    local function updateAll()
        updateGradients(); applyColor(); updateHex()
    end
    updateAll()

    -- Preset color buttons
    mkLabel(ct,"Presets",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,212),TextSize=10,Font=Enum.Font.GothamBold,TextColor3=C.txtDim,ZIndex=72})
    local presets={
        {Color3.fromRGB(128,128,128),"Gray"},
        {Color3.fromRGB(106,127,63), "Green"},
        {Color3.fromRGB(163,162,165),"Light"},
        {Color3.fromRGB(255,255,255),"White"},
        {Color3.fromRGB(26,84,144),  "Blue"},
        {Color3.fromRGB(196,40,28),  "Red"},
    }
    local pRow=mkFrame(ct,{Size=UDim2.new(1,0,0,28),Position=UDim2.new(0,0,0,228),BackgroundTransparency=1,ZIndex=72})
    for i,p in ipairs(presets) do
        local pb=mkFrame(pRow,{Size=UDim2.new(0,36,0,24),Position=UDim2.new(0,(i-1)*40,0.5,-12),BackgroundColor3=p[1],ZIndex=73}); corner(pb,5); mkStroke(pb,C.sep,1)
        local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.ZIndex=74; btn.Parent=pb
        local pc=p[1]; btn.Activated:Connect(function()
            hu,sa,va=Color3.toHSV(pc); hKnob.Position=UDim2.new(hu,-7,0.5,-7); sKnob.Position=UDim2.new(sa,-7,0.5,-7); vKnob.Position=UDim2.new(va,-7,0.5,-7); updateAll()
        end)
    end

    -- Reset button
    local resetBtn=mkBtn(ct,"Reset to Default",{Size=UDim2.new(1,0,0,28),Position=UDim2.new(0,0,0,264),TextSize=11,Font=Enum.Font.GothamBold,ZIndex=72}); corner(resetBtn,6); hov(resetBtn,C.purple,C.purpleDim)
    resetBtn.Activated:Connect(function()
        pcall(function()
            for _,bp in ipairs(getAllBaseplates()) do
                bp.Color=Color3.fromRGB(106,127,63); bp.Material=Enum.Material.Grass
            end
        end)
        hu,sa,va=Color3.toHSV(Color3.fromRGB(106,127,63)); hKnob.Position=UDim2.new(hu,-7,0.5,-7); sKnob.Position=UDim2.new(sa,-7,0.5,-7); vKnob.Position=UDim2.new(va,-7,0.5,-7); updateAll()
    end)

    -- Drag logic for all 3 bars
    local function makeDraggable(bar,knob,onDrag)
        local drag=false
        local function upd(x) local p=math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1); knob.Position=UDim2.new(p,-7,0.5,-7); onDrag(p); updateAll() end
        bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true; upd(i.Position.X) end end)
        UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i.Position.X) end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
    end
    makeDraggable(hBar,hKnob,function(p) hu=p end)
    makeDraggable(sBar,sKnob,function(p) sa=p end)
    makeDraggable(vBar,vKnob,function(p) va=p end)

    -- Hex input apply
    hexBox.FocusLost:Connect(function()
        local h=hexBox.Text:gsub("#",""):gsub("%s","")
        if #h==6 then
            local r=tonumber(h:sub(1,2),16); local g=tonumber(h:sub(3,4),16); local b=tonumber(h:sub(5,6),16)
            if r and g and b then
                local col=Color3.fromRGB(r,g,b); hu,sa,va=Color3.toHSV(col)
                hKnob.Position=UDim2.new(hu,-7,0.5,-7); sKnob.Position=UDim2.new(sa,-7,0.5,-7); vKnob.Position=UDim2.new(va,-7,0.5,-7); updateAll()
            end
        end
    end)
end
local function openAntiAFK()
    if antiAFKOpen then return end; antiAFKOpen=true; local panel,ct,cls=mkStdPanel("AntiAFK",220,110,"Anti AFK"); cls.Activated:Connect(function() panel:Destroy(); antiAFKOpen=false end)
    local active=false; local aBtn=mkActivateBtn(ct,0)
    mkLabel(ct,"Keeps you active to prevent AFK kicks",{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,0,0,40),TextSize=9,Font=Enum.Font.Gotham,TextColor3=C.txtDim,ZIndex=72})
    aBtn.Activated:Connect(function()
        active=not active
        if active then aBtn.Text="Activated"; aBtn.BackgroundColor3=C.green; task.spawn(function() local VU=game:GetService("VirtualUser"); while active and panel.Parent do pcall(function() VU:CaptureController(); VU:ClickButton2(Vector2.new(0,0)) end); task.wait(55) end end)
        else aBtn.Text="Activate"; aBtn.BackgroundColor3=C.cardDark; active=false end
    end)
end

local chatColorOpen=false
local bpColorOpen=false
local function openChatColor()
    if chatColorOpen then return end; chatColorOpen=true
    local PW,PH=280,310; local panel,ct,cls=mkStdPanel("ChatColor",PW,PH,"Chat Color Picker"); cls.Activated:Connect(function() panel:Destroy(); chatColorOpen=false end)
    local TCS2=game:GetService("TextChatService"); local bc2=TCS2:FindFirstChild("BubbleChatConfiguration"); if not bc2 then bc2=Instance.new("BubbleChatConfiguration"); bc2.Parent=TCS2 end
    bc2.BackgroundColor3=Color3.fromRGB(0,0,0); bc2.BackgroundTransparency=0.45; bc2.TextColor3=Color3.fromRGB(255,255,255)
    pcall(function() if isfile("chatcolors.txt") then local sv2=readfile("chatcolors.txt"); for ln in sv2:gmatch("[^\r\n]+") do local ky,vl=ln:match("([^:]+):([^:]+)"); if ky=="bg" then local r,g,b=vl:match("(%d+),(%d+),(%d+)"); if r then bc2.BackgroundColor3=Color3.fromRGB(tonumber(r),tonumber(g),tonumber(b)) end end; if ky=="tx" then local r,g,b=vl:match("(%d+),(%d+),(%d+)"); if r then bc2.TextColor3=Color3.fromRGB(tonumber(r),tonumber(g),tonumber(b)) end end end end end)
    local bgC=bc2.BackgroundColor3; local txC=bc2.TextColor3; local md2=1; local hu2=0; local sa2=1; local va2=1
    local function mkBar(yPos,lbl) mkLabel(ct,lbl,{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,yPos),TextSize=10,Font=Enum.Font.GothamBold,TextColor3=C.txtDim,ZIndex=72}); local bar=mkFrame(ct,{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,0,0,yPos+16),BackgroundColor3=Color3.fromRGB(40,40,40),ZIndex=72}); corner(bar,4); local knob=mkFrame(bar,{Size=UDim2.new(0,14,0,14),Position=UDim2.new(1,-7,0.5,-7),BackgroundColor3=C.white,ZIndex=73}); corner(knob,7); return bar,knob end
    local hBar,hKnob=mkBar(0,"Hue"); local hg=Instance.new("UIGradient"); hg.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),ColorSequenceKeypoint.new(0.17,Color3.fromRGB(255,255,0)),ColorSequenceKeypoint.new(0.33,Color3.fromRGB(0,255,0)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(0,255,255)),ColorSequenceKeypoint.new(0.67,Color3.fromRGB(0,0,255)),ColorSequenceKeypoint.new(0.83,Color3.fromRGB(255,0,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))}; hg.Parent=hBar
    local sBar,sKnob=mkBar(40,"Saturation"); local vBar,vKnob=mkBar(80,"Brightness")
    local preview=mkFrame(ct,{Size=UDim2.new(1,0,0,40),Position=UDim2.new(0,0,0,108),BackgroundColor3=bc2.BackgroundColor3,ZIndex=72}); corner(preview,8); mkLabel(preview,"Preview",{Size=UDim2.new(1,0,1,0),TextSize=12,Font=Enum.Font.Gotham,TextColor3=C.white,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=73})
    local bRow=mkFrame(ct,{Size=UDim2.new(1,0,0,28),Position=UDim2.new(0,0,0,156),BackgroundTransparency=1,ZIndex=72})
    local bgBtn=mkBtn(bRow,"Background",{Size=UDim2.new(0.48,0,1,0),BackgroundColor3=bc2.BackgroundColor3,TextSize=10,Font=Enum.Font.GothamBold,ZIndex=72}); corner(bgBtn,6)
    local txBtn=mkBtn(bRow,"Text",{Size=UDim2.new(0.48,0,1,0),Position=UDim2.new(0.52,0,0,0),BackgroundColor3=bc2.TextColor3,TextSize=10,Font=Enum.Font.GothamBold,ZIndex=72}); corner(txBtn,6)
    local saveBtn=mkBtn(ct,"Save Colors",{Size=UDim2.new(1,0,0,28),Position=UDim2.new(0,0,0,192),TextSize=12,Font=Enum.Font.GothamBold,ZIndex=72}); corner(saveBtn,8); hov(saveBtn,C.purple,C.purpleDim)
    local function applyColor() local fc=Color3.fromHSV(hu2,sa2,va2); preview.BackgroundColor3=fc; if md2==1 then bgC=fc; bc2.BackgroundColor3=fc; bgBtn.BackgroundColor3=fc else txC=fc; bc2.TextColor3=fc; txBtn.BackgroundColor3=fc end; local hCol=Color3.fromHSV(hu2,1,1); local sg2=sBar:FindFirstChildOfClass("UIGradient"); if not sg2 then sg2=Instance.new("UIGradient"); sg2.Parent=sBar end; sg2.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(1,hCol)}; local vg2=vBar:FindFirstChildOfClass("UIGradient"); if not vg2 then vg2=Instance.new("UIGradient"); vg2.Parent=vBar end; vg2.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),ColorSequenceKeypoint.new(1,Color3.fromHSV(hu2,sa2,1))} end
    local function sliderSetup(bar,knob,onChange) local drag=false; bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true; local p=math.clamp((i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1); knob.Position=UDim2.new(p,-7,0.5,-7); onChange(p) end end); UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType==Enum.UserInputType.MouseMovement then local p=math.clamp((i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1); knob.Position=UDim2.new(p,-7,0.5,-7); onChange(p) end end); UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end) end
    sliderSetup(hBar,hKnob,function(p) hu2=p; applyColor() end); sliderSetup(sBar,sKnob,function(p) sa2=p; applyColor() end); sliderSetup(vBar,vKnob,function(p) va2=p; applyColor() end)
    bgBtn.Activated:Connect(function() md2=1; local h,s,v=bgC:ToHSV(); hu2,sa2,va2=h,s,v; hKnob.Position=UDim2.new(hu2,-7,0.5,-7); sKnob.Position=UDim2.new(sa2,-7,0.5,-7); vKnob.Position=UDim2.new(va2,-7,0.5,-7); applyColor() end)
    txBtn.Activated:Connect(function() md2=2; local h,s,v=txC:ToHSV(); hu2,sa2,va2=h,s,v; hKnob.Position=UDim2.new(hu2,-7,0.5,-7); sKnob.Position=UDim2.new(sa2,-7,0.5,-7); vKnob.Position=UDim2.new(va2,-7,0.5,-7); applyColor() end)
    saveBtn.Activated:Connect(function() local r1,g1,b1=math.floor(bgC.R*255),math.floor(bgC.G*255),math.floor(bgC.B*255); local r2,g2,b2=math.floor(txC.R*255),math.floor(txC.G*255),math.floor(txC.B*255); pcall(function() writefile("chatcolors.txt","bg:"..r1..","..g1..","..b1.."\ntx:"..r2..","..g2..","..b2) end); saveBtn.Text="Saved!"; saveBtn.BackgroundColor3=C.green; task.delay(1.5,function() if saveBtn.Parent then saveBtn.Text="Save Colors"; saveBtn.BackgroundColor3=C.purple end end) end)
    applyColor()
end

local faceBangOpen=false
local function openFaceBang()
    if faceBangOpen then return end; faceBangOpen=true; local panel,ct,cls=mkStdPanel("FaceBang",260,290,"Face Bang")
    cls.Activated:Connect(function() getgenv().facefuckactive=false; panel:Destroy(); faceBangOpen=false end)
    getgenv().facefuckactive=false; getgenv().currentKeybind=Enum.KeyCode.Z
    local fd=-0.7; local ho=0.8; local td=1.9; local ft=0.1; local bt=0.1; local th=nil; local tp2=nil
    local function da(cr) if not cr then return end; local an=cr:FindFirstChild("Animate"); if an then an.Disabled=true end; local hm=cr:FindFirstChild("Humanoid"); if hm then for _,tr in ipairs(hm:GetPlayingAnimationTracks()) do tr:Stop(); tr:Destroy() end; hm.PlatformStand=true; hm.AutoRotate=false; hm:ChangeState(Enum.HumanoidStateType.Physics) end; workspace.Gravity=0 end
    local function ea2(cr) if not cr then return end; local an=cr:FindFirstChild("Animate"); if an then an.Disabled=false end; local hm=cr:FindFirstChild("Humanoid"); if hm then hm.PlatformStand=false; hm.AutoRotate=true; hm:ChangeState(Enum.HumanoidStateType.GettingUp) end; workspace.Gravity=192.2 end
    local function ei2(t) return -(math.cos(math.pi*t)-1)/2 end
    local function fn2() if tp2 and tp2.Character and tp2.Character:FindFirstChild("Head") then return tp2.Character.Head end; local np=nil; local sd=math.huge; for _,pr in ipairs(Players:GetPlayers()) do if pr~=lp and pr.Character then local hm=pr.Character:FindFirstChild("Humanoid"); local hd=hm and pr.Character:FindFirstChild("Head"); if hd and hm and hm.Health>0 then local hrp2=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart"); if hrp2 then local ds2=(hrp2.Position-hd.Position).Magnitude; if ds2<sd then sd=ds2; np=hd; tp2=pr end end end end end; return np end
    local function fb2(hd)
        while getgenv().facefuckactive do
            if not hd or not hd:IsDescendantOf(workspace) then if tp2 and tp2.Character then hd=tp2.Character:WaitForChild("Head"); th=hd else hd=fn2(); if not hd then task.wait(1) end end end
            local chr=lp.Character; if not chr then task.wait(0.5) end; local rp3=chr and chr:FindFirstChild("HumanoidRootPart"); if not rp3 then task.wait(0.5) end
            da(chr); local dt2=(hd.Position-rp3.Position).Magnitude
            if dt2>10 then rp3.CFrame=hd.CFrame*CFrame.new(0,ho,fd+1)*CFrame.Angles(0,math.rad(180),0); RunService.RenderStepped:Wait()
            else
                local bpos=hd.CFrame*CFrame.new(0,ho,fd)*CFrame.Angles(0,math.rad(180),0); local tpos=hd.CFrame*CFrame.new(0,ho,fd-td)*CFrame.Angles(0,math.rad(180),0)
                local ts2=tick(); local dr=ft
                while (tick()-ts2)<dr and getgenv().facefuckactive do bpos=hd.CFrame*CFrame.new(0,ho,fd)*CFrame.Angles(0,math.rad(180),0); tpos=hd.CFrame*CFrame.new(0,ho,fd-td)*CFrame.Angles(0,math.rad(180),0); local pg2=math.min((tick()-ts2)/dr,1); rp3.CFrame=bpos:Lerp(tpos,ei2(pg2)); RunService.RenderStepped:Wait() end
                local rt=tick(); local rd=bt
                while (tick()-rt)<rd and getgenv().facefuckactive do bpos=hd.CFrame*CFrame.new(0,ho,fd)*CFrame.Angles(0,math.rad(180),0); tpos=hd.CFrame*CFrame.new(0,ho,fd-td)*CFrame.Angles(0,math.rad(180),0); local pg2=math.min((tick()-rt)/rd,1); rp3.CFrame=tpos:Lerp(bpos,ei2(pg2)); RunService.RenderStepped:Wait() end
            end
        end; ea2(lp.Character)
    end
    local function tm2() if not getgenv().facefuckactive then tp2=nil; th=fn2(); if th then getgenv().facefuckactive=true; da(lp.Character); task.spawn(function() fb2(th) end) end else getgenv().facefuckactive=false; tp2=nil; th=nil; ea2(lp.Character) end end
    local statusLbl2=mkLabel(ct,"Status: OFF",{Size=UDim2.new(1,0,0,18),TextSize=12,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(220,60,60),ZIndex=72})
    local togBtn=mkBtn(ct,"Toggle (OFF)",{Size=UDim2.new(1,0,0,32),Position=UDim2.new(0,0,0,22),BackgroundColor3=C.cardDark,TextSize=12,Font=Enum.Font.GothamBold,ZIndex=72}); corner(togBtn,8); mkStroke(togBtn,C.cardBord,1)
    togBtn.MouseEnter:Connect(function() TweenService:Create(togBtn,TweenInfo.new(0.05),{BackgroundColor3=C.card}):Play() end); togBtn.MouseLeave:Connect(function() TweenService:Create(togBtn,TweenInfo.new(0.05),{BackgroundColor3=C.cardDark}):Play() end)
    togBtn.Activated:Connect(function() tm2(); if getgenv().facefuckactive then togBtn.Text="Toggle (ON)"; togBtn.BackgroundColor3=C.green; statusLbl2.Text="Status: ON"; statusLbl2.TextColor3=C.green else togBtn.Text="Toggle (OFF)"; togBtn.BackgroundColor3=C.cardDark; statusLbl2.Text="Status: OFF"; statusLbl2.TextColor3=Color3.fromRGB(220,60,60) end end)
    local bindBtn=mkBtn(ct,"Bind: Z",{Size=UDim2.new(1,0,0,30),Position=UDim2.new(0,0,0,60),BackgroundColor3=C.cardDark,TextSize=12,Font=Enum.Font.GothamBold,ZIndex=72}); corner(bindBtn,8); mkStroke(bindBtn,C.cardBord,1)
    bindBtn.MouseEnter:Connect(function() TweenService:Create(bindBtn,TweenInfo.new(0.05),{BackgroundColor3=C.card}):Play() end); bindBtn.MouseLeave:Connect(function() TweenService:Create(bindBtn,TweenInfo.new(0.05),{BackgroundColor3=C.cardDark}):Play() end)
    local listeningBind=false; bindBtn.Activated:Connect(function() if listeningBind then return end; listeningBind=true; bindBtn.Text="Press a key..."; local bc2; bc2=UserInputService.InputBegan:Connect(function(i,gp) if gp then return end; if i.UserInputType==Enum.UserInputType.Keyboard then getgenv().currentKeybind=i.KeyCode; bindBtn.Text="Bind: "..i.KeyCode.Name; listeningBind=false; bc2:Disconnect() end end) end)
    local function mkFBSlider(yPos,labelText,initVal,minVal,maxVal,fmt,onChange) local lbl=mkLabel(ct,labelText..": "..string.format(fmt,initVal),{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,yPos),TextSize=10,Font=Enum.Font.GothamBold,TextColor3=C.txtDim,ZIndex=72}); local track=mkFrame(ct,{Size=UDim2.new(1,0,0,8),Position=UDim2.new(0,0,0,yPos+16),BackgroundColor3=C.sliderBg,ZIndex=72}); corner(track,4); local fill=mkFrame(track,{Size=UDim2.new((initVal-minVal)/(maxVal-minVal),0,1,0),BackgroundColor3=C.sliderFg,ZIndex=73}); corner(fill,4); local knob=mkFrame(track,{Size=UDim2.new(0,14,0,14),Position=UDim2.new((initVal-minVal)/(maxVal-minVal),-7,0.5,-7),BackgroundColor3=C.white,ZIndex=74}); corner(knob,7); local drag=false; local function update(x) local p=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1); local v=minVal+(maxVal-minVal)*p; fill.Size=UDim2.new(p,0,1,0); knob.Position=UDim2.new(p,-7,0.5,-7); lbl.Text=labelText..": "..string.format(fmt,v); onChange(v) end; track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true; update(i.Position.X) end end); UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType==Enum.UserInputType.MouseMovement then update(i.Position.X) end end); UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end) end
    mkFBSlider(96,"Speed",ft,0.01,0.5,"%.2f",function(v) ft=v; bt=v end); mkFBSlider(140,"Distance",td,0.5,5.0,"%.1f",function(v) td=v end)
    UserInputService.InputBegan:Connect(function(i,gp) if gp or not panel.Parent then return end; if i.KeyCode==getgenv().currentKeybind then tm2(); if getgenv().facefuckactive then togBtn.Text="Toggle (ON)"; togBtn.BackgroundColor3=C.green; statusLbl2.Text="Status: ON"; statusLbl2.TextColor3=C.green else togBtn.Text="Toggle (OFF)"; togBtn.BackgroundColor3=C.cardDark; statusLbl2.Text="Status: OFF"; statusLbl2.TextColor3=Color3.fromRGB(220,60,60) end end end)
end

local hugOpen=false
local function openHug()
    if hugOpen then return end; hugOpen=true; local panel,ct,cls=mkStdPanel("Hug",240,180,"Hug"); cls.Activated:Connect(function() panel:Destroy(); hugOpen=false end)
    local hugState={isHugging=false,targetPlayer=nil,defaultGravity=workspace.Gravity}
    local function cleanupHug() workspace.Gravity=hugState.defaultGravity; local chr=lp.Character; if not chr then return end; local rp4=chr:FindFirstChild("HumanoidRootPart"); if not rp4 then return end; for _,c in ipairs(rp4:GetChildren()) do if c:IsA("Attachment") or c:IsA("AlignPosition") or c:IsA("AlignOrientation") then c:Destroy() end end end
    local hugConn=nil
    local function doHug(target)
        hugState.isHugging=not hugState.isHugging
        if hugState.isHugging then
            hugState.targetPlayer=target or hugState.targetPlayer; local tgt=hugState.targetPlayer; if not tgt then hugState.isHugging=false; return end
            if hugConn then hugConn:Disconnect() end
            hugConn=RunService.RenderStepped:Connect(function()
                if not hugState.isHugging then hugConn:Disconnect(); hugConn=nil; return end
                local chr=lp.Character; if not chr then return end; local rp4=chr:FindFirstChild("HumanoidRootPart"); if not rp4 then return end
                local tc=tgt.Character; if not tc then return end; local tHRP=tc:FindFirstChild("HumanoidRootPart"); if not tHRP then return end
                for _,p in ipairs(chr:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
                rp4.CFrame=tHRP.CFrame*CFrame.new(0,0,1.2); rp4.AssemblyLinearVelocity=tHRP.AssemblyLinearVelocity
            end)
        else hugState.isHugging=false; if hugConn then hugConn:Disconnect(); hugConn=nil end; cleanupHug(); pcall(function() local chr=lp.Character; if not chr then return end; for _,p in ipairs(chr:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end) end
    end
    local statusLbl3=mkLabel(ct,"Status: OFF",{Size=UDim2.new(1,0,0,16),TextSize=12,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(220,60,60),ZIndex=72})
    local nearBtn=mkBtn(ct,"Hug Nearest",{Size=UDim2.new(1,0,0,32),Position=UDim2.new(0,0,0,22),BackgroundColor3=C.cardDark,TextSize=12,Font=Enum.Font.GothamBold,ZIndex=72}); corner(nearBtn,8); mkStroke(nearBtn,C.cardBord,1)
    nearBtn.MouseEnter:Connect(function() TweenService:Create(nearBtn,TweenInfo.new(0.05),{BackgroundColor3=C.card}):Play() end); nearBtn.MouseLeave:Connect(function() TweenService:Create(nearBtn,TweenInfo.new(0.05),{BackgroundColor3=hugState.isHugging and C.green or C.cardDark}):Play() end)
    local bindBtn2=mkBtn(ct,"Bind: H",{Size=UDim2.new(1,0,0,32),Position=UDim2.new(0,0,0,60),BackgroundColor3=C.cardDark,TextSize=12,Font=Enum.Font.GothamBold,ZIndex=72}); corner(bindBtn2,8); mkStroke(bindBtn2,C.cardBord,1)
    bindBtn2.MouseEnter:Connect(function() TweenService:Create(bindBtn2,TweenInfo.new(0.05),{BackgroundColor3=C.card}):Play() end); bindBtn2.MouseLeave:Connect(function() TweenService:Create(bindBtn2,TweenInfo.new(0.05),{BackgroundColor3=C.cardDark}):Play() end)
    local hugKey=Enum.KeyCode.H; local listeningHug=false
    bindBtn2.Activated:Connect(function() if listeningHug then return end; listeningHug=true; bindBtn2.Text="Press a key..."; local hc; hc=UserInputService.InputBegan:Connect(function(i,gp) if gp then return end; if i.UserInputType==Enum.UserInputType.Keyboard then hugKey=i.KeyCode; bindBtn2.Text="Bind: "..i.KeyCode.Name; listeningHug=false; hc:Disconnect() end end) end)
    local function findNearest() local chr=lp.Character; if not chr then return end; local rp4=chr:FindFirstChild("HumanoidRootPart"); if not rp4 then return end; local best=nil; local bd=math.huge; for _,plr in ipairs(Players:GetPlayers()) do if plr~=lp and plr.Character then local tHRP=plr.Character:FindFirstChild("HumanoidRootPart"); if tHRP then local d=(rp4.Position-tHRP.Position).Magnitude; if d<bd then bd=d; best=plr end end end end; return best end
    local function updateHugStatus() if hugState.isHugging then statusLbl3.Text="Status: ON"; statusLbl3.TextColor3=C.green; nearBtn.BackgroundColor3=C.green else statusLbl3.Text="Status: OFF"; statusLbl3.TextColor3=Color3.fromRGB(220,60,60); nearBtn.BackgroundColor3=C.cardDark end end
    nearBtn.Activated:Connect(function() local tgt=findNearest(); doHug(tgt); updateHugStatus() end)
    UserInputService.InputBegan:Connect(function(i,gp) if gp or not panel.Parent then return end; if i.KeyCode==hugKey then doHug(findNearest()); updateHugStatus() end end)
end

local flingUIOpen=false
local function openFlingUI()
    if flingUIOpen then return end; flingUIOpen=true; local panel,ct,cls=mkStdPanel("FlingUI",260,320,"Fling"); cls.Activated:Connect(function() panel:Destroy(); flingUIOpen=false end)
    local fState={FlingAll=false,Targets={},SavedPosition=nil,running=false}
    local function flingPlayer2(target) local chr=lp.Character; if not chr then return end; local hum=chr:FindFirstChildOfClass("Humanoid"); if not hum then return end; local root=hum.RootPart; if not root then return end; local tChar=target.Character; if not tChar then return end; local tHum=tChar:FindFirstChildOfClass("Humanoid"); if not tHum then return end; local tRoot=tHum.RootPart or tChar:FindFirstChild("Head"); if not tRoot then return end; workspace.FallenPartsDestroyHeight=0/0; local bv=Instance.new("BodyVelocity"); bv.Velocity=Vector3.new(-9e9,9e9,-9e9); bv.MaxForce=Vector3.new(9e9,9e9,9e9); bv.Parent=root; local start=tick(); repeat if tRoot and tRoot.Parent and root and root.Parent then if tRoot.Velocity.Magnitude<30 then root.CFrame=CFrame.new(tRoot.Position)+Vector3.new(0,1.5,0); root.RotVelocity=Vector3.new(9e8,9e8,9e8) end; RunService.Heartbeat:Wait() else break end until tRoot.Velocity.Magnitude>1000 or tick()>start+0.134 or not fState.running or not tChar.Parent or not chr.Parent; bv:Destroy(); if fState.SavedPosition and root then root.CFrame=fState.SavedPosition end end
    local function startFling() if fState.running then return end; fState.running=true; coroutine.wrap(function() while fState.running and (#fState.Targets>0 or fState.FlingAll) do task.wait(); pcall(function() local targets=fState.FlingAll and Players:GetPlayers() or fState.Targets; for _,tgt in ipairs(targets) do if tgt~=lp and tgt.Character then local h2=tgt.Character:FindFirstChildOfClass("Humanoid"); local r2=h2 and h2.RootPart; if r2 and not h2.Sit and r2.Velocity.Magnitude<30 then flingPlayer2(tgt) end end end end) end; fState.running=false end)() end
    local function stopFling() fState.running=false; fState.FlingAll=false; fState.Targets={} end
    local fAllBtn=mkBtn(ct,"Fling All: OFF",{Size=UDim2.new(1,0,0,30),BackgroundColor3=C.cardDark,TextSize=12,Font=Enum.Font.GothamBold,ZIndex=72}); corner(fAllBtn,8); mkStroke(fAllBtn,C.cardBord,1)
    fAllBtn.MouseEnter:Connect(function() TweenService:Create(fAllBtn,TweenInfo.new(0.05),{BackgroundColor3=C.card}):Play() end); fAllBtn.MouseLeave:Connect(function() TweenService:Create(fAllBtn,TweenInfo.new(0.05),{BackgroundColor3=fState.FlingAll and C.green or C.cardDark}):Play() end)
    fAllBtn.Activated:Connect(function() fState.FlingAll=not fState.FlingAll; if fState.FlingAll then fState.Targets={}; local chr=lp.Character; if chr then local rp5=chr:FindFirstChild("HumanoidRootPart"); if rp5 then fState.SavedPosition=rp5.CFrame end end; fAllBtn.Text="Fling All: ON"; fAllBtn.BackgroundColor3=C.green; startFling() else stopFling(); fAllBtn.Text="Fling All: OFF"; fAllBtn.BackgroundColor3=C.cardDark end end)
    mkLabel(ct,"Players (click to target):",{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,0,0,38),TextSize=10,Font=Enum.Font.Gotham,TextColor3=C.txtDim,ZIndex=72})
    local pScroll=Instance.new("ScrollingFrame"); pScroll.Size=UDim2.new(1,0,1,-60); pScroll.Position=UDim2.new(0,0,0,56); pScroll.BackgroundTransparency=1; pScroll.BorderSizePixel=0; pScroll.ScrollBarThickness=3; pScroll.ScrollBarImageColor3=C.purple; pScroll.CanvasSize=UDim2.new(0,0,0,0); pScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; pScroll.ZIndex=72; pScroll.Parent=ct
    local pLL=Instance.new("UIListLayout"); pLL.Padding=UDim.new(0,4); pLL.Parent=pScroll; local entries={}
    local function addPlayer(plr) if entries[plr] then return end; local row=mkFrame(pScroll,{Size=UDim2.new(1,0,0,32),BackgroundColor3=C.cardDark,ZIndex=73}); corner(row,8); mkStroke(row,C.cardBord,1); mkLabel(row,plr.Name,{Size=UDim2.new(1,-12,1,0),Position=UDim2.new(0,8,0,0),TextSize=11,Font=Enum.Font.GothamBold,TextColor3=C.white,ZIndex=74}); local sel=Instance.new("TextButton"); sel.Size=UDim2.new(1,0,1,0); sel.BackgroundTransparency=1; sel.Text=""; sel.ZIndex=74; sel.Parent=row; sel.Activated:Connect(function() local idx=table.find(fState.Targets,plr); if idx then table.remove(fState.Targets,idx); row.BackgroundColor3=C.cardDark; if #fState.Targets==0 then stopFling() end else table.insert(fState.Targets,plr); row.BackgroundColor3=C.purple; if #fState.Targets==1 then local chr=lp.Character; if chr then local rp5=chr:FindFirstChild("HumanoidRootPart"); if rp5 then fState.SavedPosition=rp5.CFrame end end; startFling() end end end); entries[plr]=row end
    for _,plr in ipairs(Players:GetPlayers()) do if plr~=lp then addPlayer(plr) end end
    Players.PlayerAdded:Connect(function(plr) task.wait(1); if panel.Parent then addPlayer(plr) end end)
    Players.PlayerRemoving:Connect(function(plr) if entries[plr] then entries[plr]:Destroy(); entries[plr]=nil end; local idx=table.find(fState.Targets,plr); if idx then table.remove(fState.Targets,idx) end end)
end

local shiftLockOpen=false
local function openShiftLock()
    if shiftLockOpen then return end; shiftLockOpen=true; local panel,ct,cls=mkStdPanel("ShiftLock",220,110,"Shift Lock")
    local locked=false; local slConn=nil
    local function stopSL()
        if slConn then slConn:Disconnect(); slConn=nil end
        locked=false
    end
    cls.Activated:Connect(function() stopSL(); panel:Destroy(); shiftLockOpen=false end)
    local statusLbl4=mkLabel(ct,"Status: OFF",{Size=UDim2.new(1,0,0,16),TextSize=12,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(220,60,60),ZIndex=72})
    local aBtn2=mkActivateBtn(ct,22)
    local function toggleSL() locked=not locked; if locked then aBtn2.Text="Activated"; aBtn2.BackgroundColor3=C.green; statusLbl4.Text="Status: ON"; statusLbl4.TextColor3=C.green; slConn=RunService.RenderStepped:Connect(function() local chr=lp.Character; if not chr then return end; local hrp=chr:FindFirstChild("HumanoidRootPart"); if not hrp then return end; local look=workspace.CurrentCamera.CFrame.LookVector; local flat=Vector3.new(look.X,0,look.Z).Unit; hrp.CFrame=CFrame.new(hrp.Position,hrp.Position+flat) end) else aBtn2.Text="Activate"; aBtn2.BackgroundColor3=C.cardDark; statusLbl4.Text="Status: OFF"; statusLbl4.TextColor3=Color3.fromRGB(220,60,60); if slConn then slConn:Disconnect(); slConn=nil end end end
    aBtn2.Activated:Connect(toggleSL); UserInputService.InputBegan:Connect(function(i,gp) if gp or not panel.Parent then return end; if i.KeyCode==Enum.KeyCode.LeftShift then toggleSL() end end)
end

local touchFlingOpen=false
local function openTouchFling()
    if touchFlingOpen then return end; touchFlingOpen=true; local panel,ct,cls=mkStdPanel("TouchFling",220,140,"Touch Fling"); cls.Activated:Connect(function() panel:Destroy(); touchFlingOpen=false end)
    local fEnabled=false; local nEnabled=false; local fConn=nil; local nConn=nil
    local statusLbl5=mkLabel(ct,"Fling: OFF  |  No-Clip: OFF",{Size=UDim2.new(1,0,0,16),TextSize=10,Font=Enum.Font.Gotham,TextColor3=C.txtDim,ZIndex=72})
    local bRow2=mkFrame(ct,{Size=UDim2.new(1,0,0,34),Position=UDim2.new(0,0,0,22),BackgroundTransparency=1,ZIndex=72})
    local fBtn2=mkBtn(bRow2,"Fling: OFF",{Size=UDim2.new(0.48,0,1,0),BackgroundColor3=C.cardDark,TextSize=11,Font=Enum.Font.GothamBold,ZIndex=72}); corner(fBtn2,8); mkStroke(fBtn2,C.cardBord,1)
    local nBtn=mkBtn(bRow2,"No-Clip: OFF",{Size=UDim2.new(0.48,0,1,0),Position=UDim2.new(0.52,0,0,0),BackgroundColor3=C.cardDark,TextSize=10,Font=Enum.Font.GothamBold,ZIndex=72}); corner(nBtn,8); mkStroke(nBtn,C.cardBord,1)
    mkLabel(ct,"Flings you upward / disables player collisions",{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,0,0,62),TextSize=9,Font=Enum.Font.Gotham,TextColor3=C.txtDim,ZIndex=72})
    local vel=nil
    fBtn2.Activated:Connect(function() fEnabled=not fEnabled; if fEnabled then fBtn2.Text="Fling: ON"; fBtn2.BackgroundColor3=C.green; fConn=RunService.Heartbeat:Connect(function() if not fEnabled then return end; local chr=lp.Character; if not chr then return end; local rp6=chr:FindFirstChild("HumanoidRootPart"); if not rp6 then return end; vel=rp6.Velocity; rp6.Velocity=vel*500000+Vector3.new(0,500000,0); RunService.RenderStepped:Wait(); if rp6 and rp6.Parent then rp6.Velocity=vel end end) else fBtn2.Text="Fling: OFF"; fBtn2.BackgroundColor3=C.cardDark; if fConn then fConn:Disconnect(); fConn=nil end end; statusLbl5.Text="Fling: "..(fEnabled and "ON" or "OFF").."  |  No-Clip: "..(nEnabled and "ON" or "OFF") end)
    nBtn.Activated:Connect(function() nEnabled=not nEnabled; if nEnabled then nBtn.Text="No-Clip: ON"; nBtn.BackgroundColor3=C.green; nConn=RunService.Stepped:Connect(function() for _,plr in ipairs(Players:GetPlayers()) do if plr~=lp and plr.Character then pcall(function() for _,p in ipairs(plr.Character:GetChildren()) do if p:IsA("BasePart") then p.CanCollide=false end end end) end end end) else nBtn.Text="No-Clip: OFF"; nBtn.BackgroundColor3=C.cardDark; if nConn then nConn:Disconnect(); nConn=nil end end; statusLbl5.Text="Fling: "..(fEnabled and "ON" or "OFF").."  |  No-Clip: "..(nEnabled and "ON" or "OFF") end)
end

local baseplateOpen=false; local basePart=nil
openBaseplate=function()
    if baseplateOpen then return end; baseplateOpen=true; local panel,ct,cls=mkStdPanel("Baseplate",240,120,"Infinite Baseplate")
    cls.Activated:Connect(function() if basePart then basePart:Destroy(); basePart=nil end; panel:Destroy(); baseplateOpen=false end)
    local active=false; local statusLbl6=mkLabel(ct,"Baseplate: Inactive",{Size=UDim2.new(1,0,0,16),TextSize=11,Font=Enum.Font.GothamBold,TextColor3=C.txtDim,ZIndex=72})
    local aBtn3=mkBtn(ct,"Click to Activate",{Size=UDim2.new(1,0,0,34),Position=UDim2.new(0,0,0,22),BackgroundColor3=C.cardDark,TextSize=12,Font=Enum.Font.GothamBold,ZIndex=72}); corner(aBtn3,8); mkStroke(aBtn3,C.cardBord,1)
    aBtn3.MouseEnter:Connect(function() TweenService:Create(aBtn3,TweenInfo.new(0.05),{BackgroundColor3=C.card}):Play() end); aBtn3.MouseLeave:Connect(function() TweenService:Create(aBtn3,TweenInfo.new(0.05),{BackgroundColor3=active and C.green or C.cardDark}):Play() end)
    aBtn3.Activated:Connect(function()
        active=not active
        if active then
            aBtn3.Text="Activated"; aBtn3.BackgroundColor3=C.green; statusLbl6.Text="Baseplate: Active"; statusLbl6.TextColor3=C.green
            if basePart then basePart:Destroy() end; basePart=Instance.new("Part"); basePart.Name="ACBaseplate"; basePart.Size=Vector3.new(20000,10,20000); basePart.Transparency=1; basePart.Anchored=true; basePart.CanCollide=true; basePart.CastShadow=false; basePart.Material=Enum.Material.SmoothPlastic; basePart.Parent=workspace
            local chr0=lp.Character; local rp0=chr0 and chr0:FindFirstChild("HumanoidRootPart"); local fixedY=rp0 and (rp0.Position.Y-8) or -5
            basePart.CFrame=CFrame.new(rp0 and rp0.Position.X or 0,fixedY,rp0 and rp0.Position.Z or 0)
            RunService.RenderStepped:Connect(function() if not basePart or not basePart.Parent or not active then return end; local chr=lp.Character; if not chr then return end; local rp7=chr:FindFirstChild("HumanoidRootPart"); if not rp7 then return end; basePart.CFrame=CFrame.new(rp7.Position.X,fixedY,rp7.Position.Z) end)
        else aBtn3.Text="Click to Activate"; aBtn3.BackgroundColor3=C.cardDark; statusLbl6.Text="Baseplate: Inactive"; statusLbl6.TextColor3=C.txtDim; if basePart then basePart:Destroy(); basePart=nil end end
    end)
end


-- -- MISC TAB CONTENT -----------------------------------------
do
    local s=pageData[6].scroll; local idx=6
    local invisActive=false; local invisParts={}; local invisConn=nil
    local function cacheInvis()
        invisParts={}; local char=lp.Character; if not char then return end
        for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") and p.Transparency==0 then table.insert(invisParts,p) end end
    end
    cacheInvis(); lp.CharacterAdded:Connect(function() task.wait(1); invisActive=false; cacheInvis() end)

    -- Two-per-row card helper -- accumulates pairs then flushes as rows
    local miscRowQueue={}
    local function flushMiscRow()
        if #miscRowQueue==0 then return end
        local row=mkFrame(s,{Size=UDim2.new(1,0,0,42),BackgroundTransparency=1,LayoutOrder=nextOrder(idx),ZIndex=4})
        for qi,item in ipairs(miscRowQueue) do
            local xPos = (qi==1) and 0 or 0.5
            local card=mkFrame(row,{Size=UDim2.new(0.5,-4,1,0),Position=UDim2.new(xPos, xPos>0 and 4 or 0, 0,0),BackgroundColor3=C.cardDark,ZIndex=5})
            corner(card,10)
            local cs=mkStroke(card,C.cardBord,2)
            do local cg=Instance.new("UIGradient"); cg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(0.25,Color3.fromRGB(120,0,110)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(20,20,20)),ColorSequenceKeypoint.new(0.75,Color3.fromRGB(120,0,110)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))}); cg.Parent=cs; RunService.Heartbeat:Connect(function() if cs.Parent then cg.Rotation=(cg.Rotation+1)%360 end end) end
            mkLabel(card,item.lbl,{Size=UDim2.new(1,-44,1,0),Position=UDim2.new(0,10,0,0),TextSize=12,Font=Enum.Font.GothamBold,TextColor3=C.white,ZIndex=6})
            if item.isTog then
                local togW,togH=30,16
                local togFrame=mkFrame(card,{Size=UDim2.new(0,togW,0,togH),Position=UDim2.new(1,-36,0.5,-togH/2),BackgroundColor3=C.togOff,ZIndex=6}); corner(togFrame,togH/2)
                local knob=mkFrame(togFrame,{Size=UDim2.new(0,togH-4,0,togH-4),Position=UDim2.new(0,2,0.5,-(togH-4)/2),BackgroundColor3=Color3.fromRGB(140,140,140),ZIndex=7}); corner(knob,(togH-4)/2)
                local active=false; local sel=Instance.new("TextButton"); sel.Size=UDim2.new(1,0,1,0); sel.BackgroundTransparency=1; sel.Text=""; sel.ZIndex=8; sel.Parent=togFrame
                local cb=item.cb
                sel.Activated:Connect(function() active=not active; TweenService:Create(togFrame,TweenInfo.new(0.15),{BackgroundColor3=active and C.purple or C.togOff}):Play(); TweenService:Create(knob,TweenInfo.new(0.15),{Position=active and UDim2.new(1,-(togH-2),0.5,-(togH-4)/2) or UDim2.new(0,2,0.5,-(togH-4)/2),BackgroundColor3=active and C.white or Color3.fromRGB(140,140,140)}):Play(); if cb then pcall(cb,active) end end)
            else
                local act=Instance.new("TextButton"); act.Size=UDim2.new(1,0,1,0); act.BackgroundTransparency=1; act.Text=""; act.ZIndex=8; act.Parent=card
                local cb=item.cb
                act.Activated:Connect(function() if cb then pcall(cb) end end)
                mkLabel(card,">",{Size=UDim2.new(0,18,1,0),Position=UDim2.new(1,-22,0,0),TextSize=14,Font=Enum.Font.GothamBold,TextColor3=C.txtDim,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=6})
            end
        end
        miscRowQueue={}
    end
    local function mkMiscCard(lbl, cb, isTog)
        table.insert(miscRowQueue,{lbl=lbl,cb=cb,isTog=isTog})
        if #miscRowQueue==2 then flushMiscRow() end
    end
    -- sentinel to flush odd remainder at end
    local function finishMiscCards() if #miscRowQueue>0 then flushMiscRow() end end

    -- A-Z sorted:
    mkMiscCard("Anim Logger",   function() openAnimLogger() end)
    mkMiscCard("Anti AFK",      function() openAntiAFK() end)
    mkMiscCard("Anti Bang",     function() openAntiBang() end)
    mkMiscCard("Anti Fling",    function() openAntiFling() end)
    mkMiscCard("Anti-VC Ban",   function()
        local Code = 'game:GetService("VoiceChatService"):rejoinVoice()\n'
            ..'task.wait(0.02)\n'
            ..'for _, Connections in getconnections(game:GetService("VoiceChatInternal").StateChanged) do\n'
            ..'    Connections:Disable()\n'
            ..'end'
        loadstring(Code)()
    end)
    mkMiscCard("Auto Clicker",  function() openAutoClicker() end)
    mkMiscCard("Baseplate",     function() openBaseplate() end)
    mkMiscCard("Baseplate Color",function() openBpColor() end)
    mkMiscCard("Chat Color",    function() openChatColor() end)
    mkMiscCard("Command List",  function() openCmdList() end)
    mkMiscCard("Face Bang",     function() openFaceBang() end)
    mkMiscCard("Fling",         function() openFlingUI() end)
    mkMiscCard("Hug",           function() openHug() end)
    mkMiscCard("Invisible",     function(state)
        invisActive=state
        local char=lp.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); local hrp=char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end
        for _,p in ipairs(invisParts) do pcall(function() p.Transparency=invisActive and 0.5 or 0 end) end
        if invisActive then
            if invisConn then invisConn:Disconnect() end
            invisConn=RunService.Heartbeat:Connect(function()
                if not invisActive then invisConn:Disconnect(); return end
                pcall(function()
                    local cf=hrp.CFrame; local off=hum.CameraOffset
                    hrp.CFrame=cf*CFrame.new(0,-200,0)
                    hum.CameraOffset=(cf*CFrame.new(0,-200,0)):ToObjectSpace(CFrame.new(cf.Position)).Position
                    RunService.RenderStepped:Wait(); hrp.CFrame=cf; hum.CameraOffset=off
                end)
            end)
        else if invisConn then invisConn:Disconnect(); invisConn=nil end end
    end, true)
    mkMiscCard("Jerk",          function()
        local char=lp.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.RigType==Enum.HumanoidRigType.R6 then loadstring(game:HttpGet("https:".._sl.."pastefy.app/wa3v2Vgm/raw"))()
        elseif hum then loadstring(game:HttpGet("https:".._sl.."pastefy.app/YZoglOyJ/raw"))() end
    end)
    mkMiscCard("Shift Lock",    function() openShiftLock() end)
    local _flyActive=false; local _flyBG=nil; local _flyBV=nil; local _flyKD=nil; local _flyKU=nil; local _flyHB=nil
    mkMiscCard("Anti Lag",     function()
        pcall(function()
            -- Destroy unnecessary decals, particles, scripts in workspace
            for _,v in pairs(workspace:GetDescendants()) do
                pcall(function()
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke")
                    or v:IsA("Fire") or v:IsA("Sparkles") then v.Enabled=false end
                end)
            end
            -- Reduce render fidelity
            -- Clear unused sounds
            for _,v in pairs(workspace:GetDescendants()) do
                pcall(function() if v:IsA("Sound") and not v.IsPlaying then v:Destroy() end end)
            end
        end)
    end)
    mkMiscCard("Superman Fly", function()
        if _flyActive then
            -- TOGGLE OFF
            _flyActive=false
            pcall(function()
                local char=lp.Character; if char then
                    local hum=char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.PlatformStand=false
                        -- SB StopAnim on fly off
                        pcall(function()
                            char.Animate.Disabled=false
                            for _,t in pairs(hum:GetPlayingAnimationTracks()) do t:Stop() end
                        end)
                    end
                end
                if _flyBG then _flyBG:Destroy(); _flyBG=nil end
                if _flyBV then _flyBV:Destroy(); _flyBV=nil end
                if _flyKD then _flyKD:Disconnect(); _flyKD=nil end
                if _flyKU then _flyKU:Disconnect(); _flyKU=nil end
            end)
            return
        end
        -- TOGGLE ON -- exact SystemBroken Fly code
        local char=lp.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); local hrp=char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end
        _flyActive=true
        local FlySpeed=50
        local ctrl={f=0,b=0,l=0,r=0}; local lastctrl={f=0,b=0,l=0,r=0}; local speed=0
        -- SB PlayAnim helper (exact copy)
        local function SBPlayAnim(id,time,spd)
            pcall(function()
                char.Animate.Disabled=false
                local animtrack=hum:GetPlayingAnimationTracks()
                for _,t in pairs(animtrack) do t:Stop() end
                char.Animate.Disabled=true
                local Anim=Instance.new("Animation"); Anim.AnimationId="rbxassetid:".._sl..""..id
                local la=hum:LoadAnimation(Anim); la:Play(); la.TimePosition=time; la:AdjustSpeed(spd)
                la.Stopped:Connect(function()
                    char.Animate.Disabled=false
                    for _,t in pairs(hum:GetPlayingAnimationTracks()) do t:Stop() end
                end)
            end)
        end
        local bg=Instance.new("BodyGyro",hrp); bg.P=9e4; bg.MaxTorque=Vector3.new(9e9,9e9,9e9); bg.CFrame=hrp.CFrame; _flyBG=bg
        local bv=Instance.new("BodyVelocity",hrp); bv.Velocity=Vector3.new(0,0.1,0); bv.MaxForce=Vector3.new(9e9,9e9,9e9); _flyBV=bv
        local _lastAnim=""; local _lastTrack=nil
        local function playFlyAnim(id,t,s)
            if _lastAnim==id then return end  -- already playing this anim
            _lastAnim=id
            pcall(function()
                char.Animate.Disabled=false
                local tracks=hum:GetPlayingAnimationTracks()
                for _,tr in pairs(tracks) do tr:Stop(0) end
                char.Animate.Disabled=true
                local Anim=Instance.new("Animation"); Anim.AnimationId="rbxassetid:".._sl..""..id
                _lastTrack=hum:LoadAnimation(Anim)
                _lastTrack:Play(); _lastTrack.TimePosition=t; _lastTrack:AdjustSpeed(s)
                _lastTrack.Stopped:Connect(function()
                    char.Animate.Disabled=false
                end)
            end)
        end
        playFlyAnim("10714347256",4,0)  -- hover idle on start
        _flyKD=lp:GetMouse().KeyDown:connect(function(key)
            if key:lower()=="w" then ctrl.f=1
            elseif key:lower()=="s" then ctrl.b=-1
            elseif key:lower()=="a" then ctrl.l=-1
            elseif key:lower()=="d" then ctrl.r=1 end
        end)
        _flyKU=lp:GetMouse().KeyUp:connect(function(key)
            if key:lower()=="w" then ctrl.f=0
            elseif key:lower()=="s" then ctrl.b=0
            elseif key:lower()=="a" then ctrl.l=0
            elseif key:lower()=="d" then ctrl.r=0 end
        end)
        _flyHB=RunService.Heartbeat:Connect(function()
            if not _flyActive then _flyHB:Disconnect(); _flyHB=nil; return end
            hum.PlatformStand=true
            -- Play correct anim based on active ctrl keys (matches SB)
            if ctrl.f~=0 then playFlyAnim("10714177846",4.65,0)
            elseif ctrl.b~=0 then playFlyAnim("10147823318",4.11,0)
            elseif ctrl.l~=0 then playFlyAnim("10147823318",3.55,0)
            elseif ctrl.r~=0 then playFlyAnim("10147823318",4.81,0)
            else playFlyAnim("10714347256",4,0) end
            if ctrl.l+ctrl.r~=0 or ctrl.f+ctrl.b~=0 then
                speed=speed+FlySpeed*0.10; if speed>FlySpeed then speed=FlySpeed end
            elseif speed~=0 then
                speed=speed-FlySpeed*0.10; if speed<0 then speed=0 end
            end
            if (ctrl.l+ctrl.r)~=0 or (ctrl.f+ctrl.b)~=0 then
                bv.Velocity=((workspace.CurrentCamera.CoordinateFrame.lookVector*(ctrl.f+ctrl.b))+((workspace.CurrentCamera.CoordinateFrame*CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p)-workspace.CurrentCamera.CoordinateFrame.p))*speed
                lastctrl={f=ctrl.f,b=ctrl.b,l=ctrl.l,r=ctrl.r}
            elseif (ctrl.l+ctrl.r)==0 and (ctrl.f+ctrl.b)==0 and speed~=0 then
                bv.Velocity=((workspace.CurrentCamera.CoordinateFrame.lookVector*(lastctrl.f+lastctrl.b))+((workspace.CurrentCamera.CoordinateFrame*CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p)-workspace.CurrentCamera.CoordinateFrame.p))*speed
            else bv.Velocity=Vector3.new(0,0.1,0) end
            bg.CFrame=workspace.CurrentCamera.CoordinateFrame*CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/FlySpeed),0,0)
        end)
    end)
    mkMiscCard("Touch Fling",   function() openTouchFling() end)
    finishMiscCards()  -- flush any remaining odd card
end
-- -- ADMIN TAB ------------------------------------------------
-- Admin-only tools (owner list only)
local function _buildAdminTab()
    local s=pageData[7].scroll; local idx=7

    if not IS_OWNER then
        local lockCard=mkFrame(s,{Size=UDim2.new(1,0,0,120),BackgroundColor3=C.cardDark,LayoutOrder=nextOrder(idx),ZIndex=4})
        corner(lockCard,12); mkStroke(lockCard,C.cardBord,1)
        mkLabel(lockCard,"\xF0\x9F\x94\x92  Admin Access Restricted",{Size=UDim2.new(1,-24,0,26),Position=UDim2.new(0,14,0,18),TextSize=15,Font=Enum.Font.GothamBold,TextColor3=C.white,ZIndex=5})
        mkLabel(lockCard,"This tab is only accessible to AudioCrafter owners.",{Size=UDim2.new(1,-24,0,18),Position=UDim2.new(0,14,0,50),TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.txtDim,ZIndex=5})
        mkLabel(lockCard,"MelodyCrafter3 \xC2\xB7 LostMelodyCrafter \xC2\xB7 Exhalivibes \xC2\xB7 yourscoperr",{Size=UDim2.new(1,-24,0,18),Position=UDim2.new(0,14,0,72),TextSize=10,Font=Enum.Font.Gotham,TextColor3=Color3.fromRGB(80,80,80),ZIndex=5})
    else
        -- -- ADMIN TARGET: search any player in server --------------
        local adminTarget = nil  -- separate from AC_selectedTarget

        -- Search bar card
        local searchCard = mkFrame(s,{Size=UDim2.new(1,0,0,90),BackgroundColor3=C.cardDark,LayoutOrder=nextOrder(idx),ZIndex=4})
        corner(searchCard,10); mkStroke(searchCard,C.sep,1)
        mkLabel(searchCard,"TARGET SEARCH",{Size=UDim2.new(1,-16,0,16),Position=UDim2.new(0,10,0,6),TextSize=9,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(120,120,120),ZIndex=5})

        local searchBoxA = Instance.new("TextBox")
        searchBoxA.Size=UDim2.new(1,-16,0,30); searchBoxA.Position=UDim2.new(0,8,0,24)
        searchBoxA.BackgroundColor3=C.cmdBox; searchBoxA.BorderSizePixel=0
        searchBoxA.Font=Enum.Font.Gotham; searchBoxA.TextColor3=C.white
        searchBoxA.PlaceholderText="Search player in server..."; searchBoxA.PlaceholderColor3=C.txtDim
        searchBoxA.TextSize=12; searchBoxA.Text=""; searchBoxA.ClearTextOnFocus=false
        searchBoxA.ZIndex=5; searchBoxA.TextXAlignment=Enum.TextXAlignment.Left; searchBoxA.Parent=searchCard
        corner(searchBoxA,6); mkStroke(searchBoxA,C.cardBord,1)
        do local kpa=Instance.new("UIPadding"); kpa.PaddingLeft=UDim.new(0,10); kpa.Parent=searchBoxA end

        local adminTargetLbl = mkLabel(searchCard,"No target selected",{
            Size=UDim2.new(1,-16,0,16),Position=UDim2.new(0,10,0,58),
            TextSize=10,Font=Enum.Font.Gotham,TextColor3=C.txtDim,ZIndex=5,
            TextXAlignment=Enum.TextXAlignment.Left})

        -- Dropdown result frame (overlays on top)
        local adminDropdown = mkFrame(ScreenGui,{
            Size=UDim2.new(0,0,0,0),BackgroundColor3=C.cardDark,
            ZIndex=200,AutomaticSize=Enum.AutomaticSize.Y})
        mkStroke(adminDropdown,C.sep,1); corner(adminDropdown,6); adminDropdown.Visible=false
        do local dll=Instance.new("UIListLayout"); dll.SortOrder=Enum.SortOrder.LayoutOrder; dll.Padding=UDim.new(0,0); dll.Parent=adminDropdown end

        -- Only show players actively running the script (have AC_Watching_ value)
        local function getScriptUsers()
            local users = {}
            for _,v in pairs(workspace:GetChildren()) do
                if v:IsA("StringValue") and v.Name:sub(1,12)=="AC_Watching_" then
                    local uid = tonumber(v.Name:sub(13))
                    if uid and uid ~= lp.UserId then
                        local plrObj = Players:GetPlayerByUserId(uid)
                        if plrObj then table.insert(users, plrObj) end
                    end
                end
            end
            return users
        end

        local function rebuildAdminDrop(query)
            for _,c in ipairs(adminDropdown:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
            -- Get only script users, filter by query
            local allUsers = getScriptUsers()
            local results = {}
            if #query == 0 then
                results = allUsers
            else
                local q = query:lower()
                for _,p in ipairs(allUsers) do
                    if p.Name:lower():find(q,1,true) or p.DisplayName:lower():find(q,1,true) then
                        table.insert(results, p)
                    end
                end
            end
            if #results==0 then adminDropdown.Visible=false; return results end
            adminDropdown.Visible=true
            -- position dropdown below search box
            local absPos = searchBoxA.AbsolutePosition
            local absSize = searchBoxA.AbsoluteSize
            adminDropdown.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 2)
            adminDropdown.Size = UDim2.new(0, absSize.X, 0, 0)
            for ri,plr in ipairs(results) do
                local row = Instance.new("TextButton")
                row.Size=UDim2.new(1,0,0,32); row.BackgroundColor3=(adminTarget==plr) and C.purple or C.cardDark
                row.BorderSizePixel=0; row.Font=Enum.Font.GothamBold; row.TextColor3=C.white
                row.TextSize=12; row.Text=""; row.AutoButtonColor=false; row.LayoutOrder=ri; row.ZIndex=201; row.Parent=adminDropdown
                mkLabel(row,plr.Name,{Size=UDim2.new(0.6,-8,1,0),Position=UDim2.new(0,10,0,0),TextSize=12,Font=Enum.Font.GothamBold,TextColor3=C.white,ZIndex=202})
                mkLabel(row,"@"..plr.DisplayName,{Size=UDim2.new(0.4,-8,1,0),Position=UDim2.new(0.6,0,0,0),TextSize=10,Font=Enum.Font.Gotham,TextColor3=C.txtDim,ZIndex=202})
                row.Activated:Connect(function()
                    adminTarget=plr
                    adminTargetLbl.Text="\xE2\x96\xBA Target: "..plr.Name
                    adminTargetLbl.TextColor3=C.green
                    searchBoxA.Text=""; adminDropdown.Visible=false
                    rebuildAdminDrop("")
                end)
                row.MouseEnter:Connect(function() TweenService:Create(row,TweenInfo.new(0.05),{BackgroundColor3=adminTarget==plr and C.purple or C.card}):Play() end)
                row.MouseLeave:Connect(function() TweenService:Create(row,TweenInfo.new(0.05),{BackgroundColor3=adminTarget==plr and C.purple or C.cardDark}):Play() end)
            end
            return results
        end
        local _acAutoFilling = false
        local function doAutoSelect(plr)
            adminTarget = plr
            adminTargetLbl.Text = "\xE2\x96\xBA Target: "..plr.Name
            adminTargetLbl.TextColor3 = C.green
            adminDropdown.Visible = false
            _acAutoFilling = true
            task.defer(function()
                searchBoxA.Text = ""
                _acAutoFilling = false
            end)
        end
        searchBoxA:GetPropertyChangedSignal("Text"):Connect(function()
            if _acAutoFilling then return end
            local q = searchBoxA.Text
            if #q == 0 then adminDropdown.Visible = false; return end
            -- rebuildAdminDrop now returns the filtered script-user results
            local results = rebuildAdminDrop(q)
            -- Auto-select: exactly 1 script user matches -> pick them instantly
            if results and #results == 1 then
                doAutoSelect(results[1])
            end
        end)
        searchBoxA.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                -- Enter pressed: auto-select first matching script user
                local q = searchBoxA.Text
                if #q > 0 and not _acAutoFilling then
                    local results = getScriptUsers()
                    local ql = q:lower()
                    for _,p in ipairs(results) do
                        if p.Name:lower():find(ql,1,true) or p.DisplayName:lower():find(ql,1,true) then
                            doAutoSelect(p); return
                        end
                    end
                end
            else
                task.delay(0.15, function() adminDropdown.Visible=false end)
            end
        end)
        searchBoxA.Focused:Connect(function() if #searchBoxA.Text>0 then rebuildAdminDrop(searchBoxA.Text) end end)

        -- clear target button
        local clearAdminCard=mkFrame(s,{Size=UDim2.new(1,0,0,32),BackgroundColor3=Color3.fromRGB(25,5,22),LayoutOrder=nextOrder(idx),ZIndex=4})
        corner(clearAdminCard,8); mkStroke(clearAdminCard,Color3.fromRGB(60,0,55),1)
        mkLabel(clearAdminCard,"Clear Admin Target",{Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,10,0,0),TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.txtDim,ZIndex=5})
        local clearAdminAct=Instance.new("TextButton"); clearAdminAct.Size=UDim2.new(1,0,1,0); clearAdminAct.BackgroundTransparency=1; clearAdminAct.Text=""; clearAdminAct.ZIndex=6; clearAdminAct.Parent=clearAdminCard
        clearAdminAct.Activated:Connect(function()
            adminTarget=nil
            adminTargetLbl.Text="No target selected"; adminTargetLbl.TextColor3=C.txtDim
        end)

        -- -- ADMIN FEATURE IMPLEMENTATIONS ------------------------
        local AUTO_DURATION = 5  -- seconds each toggle stays on

        -- helper: wraps a toggle callback so it auto-disables after 10s
        -- returns a modified callback that auto-flips the toggle back
        -- togFrame/knob refs are passed in so we can animate them back
        local function makeTimedToggle(onFn, offFn)
            local timer = nil
            return function(active, togFrame, knob, togH)
                if active then
                    if timer then task.cancel(timer) end
                    onFn()
                    timer = task.delay(AUTO_DURATION, function()
                        offFn()
                        -- flip toggle visual back
                        if togFrame and togFrame.Parent then
                            TweenService:Create(togFrame,TweenInfo.new(0.15),{BackgroundColor3=C.togOff}):Play()
                            if knob and knob.Parent then
                                TweenService:Create(knob,TweenInfo.new(0.15),{
                                    Position=UDim2.new(0,2,0.5,-(togH-4)/2),
                                    BackgroundColor3=Color3.fromRGB(140,140,140)
                                }):Play()
                            end
                        end
                    end)
                else
                    if timer then task.cancel(timer); timer=nil end
                    offFn()
                end
            end
        end

        -- Flashbang
        local function doFlashbang()
            if not adminTarget or adminTarget==lp then return end
            sendCmd(adminTarget,"flashbang")
        end

        -- Fakeban
        local function fakeBanOn()
            if not adminTarget or adminTarget==lp then return end
            sendCmd(adminTarget,"fakeban_on")
        end
        local fakeBanOff=function() end

        -- Drunk
        local function drunkOn()
            if not adminTarget or adminTarget==lp then return end
            sendCmd(adminTarget,"drunk_on")
        end
        local drunkOff=function() end

        -- Freeze
        local freezeConn=nil
        local function sendCmd(target, cmd)
            -- Self-block: never act on yourself
            if not target or target == lp then return end
            -- Send via workspace signal
            pcall(function()
                local cv = workspace:FindFirstChild("AC_Cmd_"..tostring(target.UserId))
                if cv then cv.Value = cmd end
            end)
        end

        local function freezeOn()
            if not adminTarget or adminTarget == lp then return end
            sendCmd(adminTarget, "freeze")
            -- Also locally lock their HRP for non-script users as fallback
            freezeConn=RunService.Heartbeat:Connect(function()
                pcall(function()
                    local tc=adminTarget and adminTarget.Character
                    local tH=tc and tc:FindFirstChild("HumanoidRootPart")
                    if tH then tH.AssemblyLinearVelocity=Vector3.zero; tH.AssemblyAngularVelocity=Vector3.zero end
                end)
            end)
        end
        local function freezeOff()
            if freezeConn then freezeConn:Disconnect(); freezeConn=nil end
            sendCmd(adminTarget, "unfreeze")
        end

        -- Flip
        local function flipOn()
            if not adminTarget or adminTarget==lp then return end
            sendCmd(adminTarget,"flip_on")
        end
        local flipOff=function() end

        -- Bring
        local function adminBring()
            local tgt = adminTarget
            if not tgt or tgt == lp then return end
            local mc = lp.Character
            local mH = mc and mc:FindFirstChild("HumanoidRootPart")
            if not mH then return end
            -- Place target 3 studs in front, facing back at us
            local targetCF = mH.CFrame * CFrame.new(0,0,-3) * CFrame.Angles(0,math.pi,0)
            local tc=tgt.Character
            if tc then
                local tH=tc:FindFirstChild("HumanoidRootPart")
                if tH then tH.CFrame=targetCF end
            end
        end

        -- -- Build admin card rows with 10s auto-toggle -----------
        -- Custom timed card builder (embeds 10s countdown into toggle)
        local function adminTimedCard(parent, cardDef, xPos, xSzScale, xSzOffset, cardH)
            cardH = cardH or 118
            local card = mkFrame(parent, {Size=UDim2.new(xSzScale,xSzOffset,0,cardH),Position=UDim2.new(xPos,xPos>0 and 4 or 0,0,0),BackgroundColor3=C.cardDark,ZIndex=5})
            corner(card,10); mkStroke(card,C.cardBord,1)
            mkLabel(card,cardDef.label,{Size=UDim2.new(1,-60,0,20),Position=UDim2.new(0,12,0,10),TextSize=13,Font=Enum.Font.GothamBold,TextColor3=C.white,ZIndex=6})
            if cardDef.badgeText then
                local badge=mkFrame(card,{Size=UDim2.new(0,36,0,16),Position=UDim2.new(1,-84,0,12),BackgroundColor3=Color3.fromRGB(30,30,30),ZIndex=6}); corner(badge,4)
                mkLabel(badge,cardDef.badgeText,{Size=UDim2.new(1,0,1,0),TextSize=9,Font=Enum.Font.GothamBold,TextColor3=C.txtDim,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=7})
            end
            local cmdY=36
            if cardDef.cmd then
                local cmdBox2=mkFrame(card,{Size=UDim2.new(1,-16,0,22),Position=UDim2.new(0,8,0,cmdY),BackgroundColor3=C.cmdBox,ZIndex=6}); corner(cmdBox2,5)
                mkLabel(cmdBox2,cardDef.cmd,{Size=UDim2.new(1,-10,1,0),Position=UDim2.new(0,6,0,0),TextSize=10,Font=Enum.Font.Code,TextColor3=Color3.fromRGB(185,185,185),ZIndex=7})
                cmdY=cmdY+26
            end
            if cardDef.desc then
                mkLabel(card,cardDef.desc,{Size=UDim2.new(1,-16,0,cardH-cmdY-10),Position=UDim2.new(0,8,0,cmdY+2),TextSize=10,Font=Enum.Font.Gotham,TextColor3=C.txtDim,ZIndex=6,TextWrapped=true})
            end
            if cardDef.toggle and cardDef.onFn and cardDef.offFn then
                local actBtn=mkBtn(card,"Activate",{Size=UDim2.new(1,-16,0,26),Position=UDim2.new(0,8,0,cardH-34),TextSize=11,Font=Enum.Font.GothamBold,ZIndex=6})
                corner(actBtn,6); hov(actBtn,C.purple,C.purpleDim)
                local active=false; local timer=nil
                local function turnOff()
                    active=false; if actBtn.Parent then actBtn.Text="Activate"; actBtn.BackgroundColor3=C.purple end
                    pcall(cardDef.offFn)
                end
                actBtn.Activated:Connect(function()
                    if active then
                        if timer then task.cancel(timer); timer=nil end; turnOff()
                    else
                        active=true; actBtn.Text="Active"; actBtn.BackgroundColor3=C.green
                        pcall(cardDef.onFn)
                        if timer then task.cancel(timer) end
                        timer=task.delay(AUTO_DURATION,function() if active then turnOff() end end)
                    end
                end)
            elseif not cardDef.toggle then
                local act=Instance.new("TextButton"); act.Size=UDim2.new(1,0,1,0); act.BackgroundTransparency=1; act.Text=""; act.ZIndex=8; act.Parent=card
                act.Activated:Connect(function() if cardDef.callback then pcall(cardDef.callback) end end)
                
            end
            return card
        end

        local function adminCardRow(cards, rowH)
            rowH=rowH or 118
            local row=mkFrame(s,{Size=UDim2.new(1,0,0,rowH),BackgroundTransparency=1,LayoutOrder=nextOrder(idx),ZIndex=4})
            if #cards==1 then adminTimedCard(row,cards[1],0,1,0,rowH)
            elseif #cards==2 then adminTimedCard(row,cards[1],0,0.5,-4,rowH); adminTimedCard(row,cards[2],0.5,0.5,-4,rowH) end
        end

        -- -- OWNER BANNER ------------------------------------------
        local ownerBanner=mkFrame(s,{Size=UDim2.new(1,0,0,50),BackgroundColor3=C.cardDark,LayoutOrder=nextOrder(idx),ZIndex=4})
        corner(ownerBanner,10); mkStroke(ownerBanner,C.sep,1)
        mkLabel(ownerBanner,"Owner Panel \xE2\x80\x94 AC AudioCrafter",{Size=UDim2.new(1,-120,0,22),Position=UDim2.new(0,14,0,8),TextSize=14,Font=Enum.Font.GothamBold,TextColor3=C.white,ZIndex=5})
        mkLabel(ownerBanner,"Access granted: "..lp.Name.." \xE2\x80\x83\xE2\x8F\xB1 10s auto-off",{Size=UDim2.new(1,-120,0,16),Position=UDim2.new(0,14,0,30),TextSize=10,Font=Enum.Font.Gotham,TextColor3=C.green,ZIndex=5})
        local ownerBadge=mkFrame(ownerBanner,{Size=UDim2.new(0,90,0,26),Position=UDim2.new(1,-100,0.5,-13),BackgroundColor3=C.purple,ZIndex=5}); corner(ownerBadge,6)
        mkLabel(ownerBadge,"AC OWNER",{Size=UDim2.new(1,0,1,0),TextSize=10,Font=Enum.Font.GothamBold,TextColor3=C.white,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=6})

        secLabel(s,"VISUAL ATTACKS",idx)
        adminCardRow({
            {label="flashbang",  cmd="+flashbang",  badgeText="ADMIN", toggle=false,
             desc="Full white flash across the screen. Instant and disorienting.",
             callback=function() doFlashbang() end},
            {label="fakeban",    cmd="+fakeban",     badgeText="ADMIN", toggle=true,
             desc="Convincing ban screen overlay. Auto-removes after 10 seconds.",
             onFn=fakeBanOn, offFn=fakeBanOff},
        })
        adminCardRow({
            {label="drunk",      cmd="+drunk",       badgeText="ADMIN", toggle=true,
             desc="Camera sways and distorts in a loop. Auto-stops after 10 seconds.",
             onFn=drunkOn, offFn=drunkOff},
            {label="flip",       cmd="+flip",        badgeText="ADMIN", toggle=true,
             desc="Rapid camera spin effect. Auto-stops after 10 seconds.",
             onFn=flipOn, offFn=flipOff},
        })
        secLabel(s,"TARGET CONTROL",idx)
        adminCardRow({
            {label="freeze",     cmd="+freeze",      badgeText="ADMIN", toggle=true,
             desc="Locks admin target in place. Auto-releases after 10 seconds.",
             onFn=freezeOn, offFn=freezeOff},
            {label="bring",      cmd="+bring",       badgeText="ADMIN", toggle=false,
             desc="Teleports admin target to your position instantly.",
             callback=function() adminBring() end},
        })
        -- -- PLAYER MESSAGE ----------------------------------------
        secLabel(s,"ARCH / DADDY",idx)
        adminCardRow({
            {label="Arch / Daddy", cmd="+arch", badgeText="ADMIN", toggle=false,
             desc="Forces arch animation + makes them say 'Help me' in chat.",
             callback=function()
                if not adminTarget or adminTarget==lp then return end
                sendCmd(adminTarget,"arch")
             end},
        })
        do -- pm scope
        secLabel(s,"PLAYER MESSAGE",idx)
        local msgCard=mkFrame(s,{Size=UDim2.new(1,0,0,130),BackgroundColor3=C.cardDark,LayoutOrder=nextOrder(idx),ZIndex=4})
        corner(msgCard,10); mkStroke(msgCard,C.sep,1)

        mkLabel(msgCard,"Target (script users only)",{Size=UDim2.new(1,-16,0,14),Position=UDim2.new(0,10,0,6),TextSize=9,Font=Enum.Font.GothamBold,TextColor3=C.txtDim,ZIndex=5})

        -- Script user search box
        local msgTargetBox=Instance.new("TextBox")
        msgTargetBox.Size=UDim2.new(1,-16,0,26); msgTargetBox.Position=UDim2.new(0,8,0,22)
        msgTargetBox.BackgroundColor3=C.cmdBox; msgTargetBox.BorderSizePixel=0
        msgTargetBox.Font=Enum.Font.Gotham; msgTargetBox.TextColor3=C.white
        msgTargetBox.PlaceholderText="Search script user..."; msgTargetBox.PlaceholderColor3=C.txtDim
        msgTargetBox.TextSize=11; msgTargetBox.Text=""; msgTargetBox.ClearTextOnFocus=false
        msgTargetBox.ZIndex=5; msgTargetBox.TextXAlignment=Enum.TextXAlignment.Left; msgTargetBox.Parent=msgCard
        corner(msgTargetBox,5); mkStroke(msgTargetBox,C.cardBord,1)
        do local kp=Instance.new("UIPadding"); kp.PaddingLeft=UDim.new(0,8); kp.Parent=msgTargetBox end

        local msgTargetLbl=mkLabel(msgCard,"No target",{Size=UDim2.new(1,-16,0,14),Position=UDim2.new(0,10,0,50),TextSize=9,Font=Enum.Font.Gotham,TextColor3=C.txtDim,ZIndex=5,TextXAlignment=Enum.TextXAlignment.Left})
        local msgTarget=nil

        -- Dropdown for msg target
        local msgDrop=mkFrame(ScreenGui,{Size=UDim2.new(0,0,0,0),BackgroundColor3=C.cardDark,ZIndex=210,AutomaticSize=Enum.AutomaticSize.Y})
        mkStroke(msgDrop,C.sep,1); corner(msgDrop,6); msgDrop.Visible=false
        do local dl=Instance.new("UIListLayout"); dl.SortOrder=Enum.SortOrder.LayoutOrder; dl.Padding=UDim.new(0,0); dl.Parent=msgDrop end
        local function rebuildMsgDrop(query)
            for _,c in ipairs(msgDrop:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
            local allUsers=getScriptUsers()
            local results={}
            local q=query:lower()
            for _,p in ipairs(allUsers) do
                if #query==0 or p.Name:lower():find(q,1,true) or p.DisplayName:lower():find(q,1,true) then
                    table.insert(results,p)
                end
            end
            if #results==0 then msgDrop.Visible=false; return end
            msgDrop.Visible=true
            local absPos=msgTargetBox.AbsolutePosition; local absSize=msgTargetBox.AbsoluteSize
            msgDrop.Position=UDim2.new(0,absPos.X,0,absPos.Y+absSize.Y+2)
            msgDrop.Size=UDim2.new(0,absSize.X,0,0)
            for ri,p in ipairs(results) do
                local row=Instance.new("TextButton")
                row.Size=UDim2.new(1,0,0,30); row.BackgroundColor3=C.cardDark; row.BorderSizePixel=0
                row.Font=Enum.Font.GothamBold; row.TextColor3=C.white; row.TextSize=11; row.Text=""
                row.AutoButtonColor=false; row.LayoutOrder=ri; row.ZIndex=211; row.Parent=msgDrop
                mkLabel(row,p.Name,{Size=UDim2.new(0.55,-8,1,0),Position=UDim2.new(0,8,0,0),TextSize=11,Font=Enum.Font.GothamBold,TextColor3=C.white,ZIndex=212})
                mkLabel(row,p.DisplayName,{Size=UDim2.new(0.45,-4,1,0),Position=UDim2.new(0.55,0,0,0),TextSize=10,Font=Enum.Font.Gotham,TextColor3=C.txtDim,ZIndex=212})
                row.Activated:Connect(function()
                    msgTarget=p; msgTargetLbl.Text="> "..p.Name; msgTargetLbl.TextColor3=C.green
                    msgTargetBox.Text=""; msgDrop.Visible=false
                end)
                row.MouseEnter:Connect(function() TweenService:Create(row,TweenInfo.new(0.05),{BackgroundColor3=C.card}):Play() end)
                row.MouseLeave:Connect(function() TweenService:Create(row,TweenInfo.new(0.05),{BackgroundColor3=C.cardDark}):Play() end)
            end
        end
        msgTargetBox:GetPropertyChangedSignal("Text"):Connect(function() rebuildMsgDrop(msgTargetBox.Text) end)
        msgTargetBox.FocusLost:Connect(function() task.delay(0.15,function() msgDrop.Visible=false end) end)
        msgTargetBox.Focused:Connect(function() rebuildMsgDrop(msgTargetBox.Text) end)

        -- Message input box
        mkLabel(msgCard,"Message",{Size=UDim2.new(1,-16,0,14),Position=UDim2.new(0,10,0,66),TextSize=9,Font=Enum.Font.GothamBold,TextColor3=C.txtDim,ZIndex=5})
        local msgInput=Instance.new("TextBox")
        msgInput.Size=UDim2.new(1,-16,0,26); msgInput.Position=UDim2.new(0,8,0,82)
        msgInput.BackgroundColor3=C.cmdBox; msgInput.BorderSizePixel=0
        msgInput.Font=Enum.Font.Gotham; msgInput.TextColor3=C.white
        msgInput.PlaceholderText="Type message..."; msgInput.PlaceholderColor3=C.txtDim
        msgInput.TextSize=11; msgInput.Text=""; msgInput.ClearTextOnFocus=false
        msgInput.ZIndex=5; msgInput.TextXAlignment=Enum.TextXAlignment.Left; msgInput.Parent=msgCard
        corner(msgInput,5); mkStroke(msgInput,C.cardBord,1)
        do local kp=Instance.new("UIPadding"); kp.PaddingLeft=UDim.new(0,8); kp.Parent=msgInput end

        -- Send button
        local sendMsgBtn=mkBtn(msgCard,"Send",{Size=UDim2.new(0,60,0,22),Position=UDim2.new(1,-68,0,86),TextSize=11,Font=Enum.Font.GothamBold,ZIndex=6})
        corner(sendMsgBtn,5); hov(sendMsgBtn,C.purple,C.purpleDim)
        sendMsgBtn.Activated:Connect(function()
            local msg=msgInput.Text
            if not msgTarget or msgTarget==lp or msg=="" then return end
            sendCmd(msgTarget,"msg:"..msg)
            msgInput.Text=""
            sendMsgBtn.Text="Sent!"; sendMsgBtn.BackgroundColor3=C.green
            task.delay(1.5,function() if sendMsgBtn.Parent then sendMsgBtn.Text="Send"; sendMsgBtn.BackgroundColor3=C.purple end end)
        end)

        end -- end pm scope
        secLabel(s,"NOTICE",idx)
        local noticeCard=mkFrame(s,{Size=UDim2.new(1,0,0,52),BackgroundColor3=C.cardDark,LayoutOrder=nextOrder(idx),ZIndex=4})
        corner(noticeCard,10); mkStroke(noticeCard,Color3.fromRGB(80,0,70),1)
        mkLabel(noticeCard,"All toggle tools auto-disable after 10 seconds.",{Size=UDim2.new(1,-16,0,16),Position=UDim2.new(0,10,0,8),TextSize=10,Font=Enum.Font.Gotham,TextColor3=C.txtDim,ZIndex=5})
        mkLabel(noticeCard,"freeze/bring use the admin target from the search bar above.",{Size=UDim2.new(1,-16,0,16),Position=UDim2.new(0,10,0,24),TextSize=10,Font=Enum.Font.Gotham,TextColor3=Color3.fromRGB(100,100,100),ZIndex=5})
        mkLabel(noticeCard,"Sharing access will result in blacklist.",{Size=UDim2.new(1,-16,0,14),Position=UDim2.new(0,10,0,38),TextSize=9,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(180,60,60),ZIndex=5})
    end
end
_buildAdminTab()
-- -- COMMAND SYSTEM --------------------------------------------
local TS = game:GetService("TeleportService")
local cmdListOpen = false
local openBaseplateCmd = function() if openBaseplate then openBaseplate() end end

local COMMANDS = {
    {cmd=".rj", desc="Rejoin same server", run=function()
        task.spawn(function()
            pcall(function()
                local TS2 = game:GetService("TeleportService")
                local jobId = game.JobId
                if jobId and jobId ~= "" then TS2:TeleportToPlaceInstance(game.PlaceId, jobId, lp)
                else TS2:Teleport(game.PlaceId, lp) end
            end)
        end)
    end},
    {cmd=".sh", desc="Server hop", run=function()
        task.spawn(function()
            local ok,reserved=pcall(function() return TS:ReserveServer(game.PlaceId) end)
            if ok and reserved then pcall(function() TS:TeleportToPrivateServer(game.PlaceId,reserved,{lp}) end)
            else pcall(function() TS:Teleport(game.PlaceId, lp) end) end
        end)
    end},
    {cmd=".re", desc="Respawn in place", run=function()
        pcall(function()
            local chr=lp.Character; if not chr then return end
            local hrp=chr:FindFirstChild("HumanoidRootPart"); local cf=hrp and hrp.CFrame
            chr:BreakJoints()
            if cf then lp.CharacterAdded:Wait(); task.wait(0.3)
                local newHRP=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                if newHRP then newHRP.CFrame=cf end
            end
        end)
    end},
    {cmd=".ws [n]", desc="Set WalkSpeed", run=function(args)
        local v=tonumber(args); if v then pcall(function()
            local h=lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed=math.clamp(v,0,300) end end) end
    end},
    {cmd=".jp [n]", desc="Set JumpPower", run=function(args)
        local v=tonumber(args); if v then pcall(function()
            local h=lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
            if h then h.UseJumpPower=true; h.JumpPower=math.clamp(v,0,500) end end) end
    end},
    {cmd=".speed", desc="Show WalkSpeed", run=function()
        local h=lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if h then print("[AC] WalkSpeed: "..tostring(h.WalkSpeed)) end
    end},
    {cmd=".tp [name]", desc="Teleport to target", run=function(args)
        local tgt=AC_selectedTarget
        if args and args~="" then local r=Shorten(args); tgt=r[1] end
        if not tgt or tgt==lp then return end
        local tc=tgt.Character; local mc=lp.Character
        if tc and mc then
            local tH=tc:FindFirstChild("HumanoidRootPart"); local mH=mc:FindFirstChild("HumanoidRootPart")
            if tH and mH then mH.CFrame=tH.CFrame*CFrame.new(3,0,3) end
        end
    end},
    {cmd=".view", desc="View target", run=function()
        if not AC_selectedTarget then return end
        local char=AC_selectedTarget.Character
        if char then local h=char:FindFirstChildOfClass("Humanoid")
            if h then workspace.CurrentCamera.CameraSubject=h end end
    end},
    {cmd=".bring", desc="Bring target", run=function()
        if not AC_selectedTarget then return end
        local tc=AC_selectedTarget.Character; local mc=lp.Character
        if tc and mc then
            local tH=tc:FindFirstChild("HumanoidRootPart"); local mH=mc:FindFirstChild("HumanoidRootPart")
            if tH and mH then tH.CFrame=mH.CFrame*CFrame.new(3,0,0) end
        end
    end},
    {cmd=".spectate", desc="Spectate target", run=function()
        if not AC_selectedTarget then return end
        local char=AC_selectedTarget.Character
        if char then local h=char:FindFirstChildOfClass("Humanoid")
            if h then workspace.CurrentCamera.CameraSubject=h end end
    end},
    {cmd=".focus", desc="Loop TP to target", run=function()
        if not AC_selectedTarget then return end
        task.spawn(function()
            for _=1,300 do
                local tc=AC_selectedTarget and AC_selectedTarget.Character; local mc=lp.Character
                if tc and mc then
                    local tH=tc:FindFirstChild("HumanoidRootPart"); local mH=mc:FindFirstChild("HumanoidRootPart")
                    if tH and mH then mH.CFrame=tH.CFrame*CFrame.new(3,0,3) end
                end
                task.wait(0.1)
            end
        end)
    end},
    {cmd=".headsit", desc="Sit on head", run=function()
        if not AC_selectedTarget then return end
        local tc=AC_selectedTarget.Character; local mc=lp.Character
        if not tc or not mc then return end
        local head=tc:FindFirstChild("Head"); local mH=mc:FindFirstChild("HumanoidRootPart")
        local mHum=mc:FindFirstChildOfClass("Humanoid"); local tHRP=tc:FindFirstChild("HumanoidRootPart")
        if head and mH and tHRP then
            mHum.AutoRotate=false; mHum.Sit=true
            local _,y,_=tHRP.CFrame:ToEulerAnglesYXZ()
            mH.CFrame=CFrame.new(head.Position+Vector3.new(0,head.Size.Y/2+1.8,0))*CFrame.Angles(0,y,0)
        end
    end},
    {cmd=".unheadsit", desc="Stop HeadSit", run=function()
        local mc=lp.Character; if not mc then return end
        local h=mc:FindFirstChildOfClass("Humanoid"); if h then h.AutoRotate=true; h.Sit=false end
    end},
    {cmd=".backpack", desc="Backpack mode", run=function()
        if not AC_selectedTarget then return end
        local tc=AC_selectedTarget.Character; local mc=lp.Character
        if not tc or not mc then return end
        local tH=tc:FindFirstChild("HumanoidRootPart"); local mH=mc:FindFirstChild("HumanoidRootPart")
        local mHum=mc:FindFirstChildOfClass("Humanoid")
        if tH and mH and mHum then
            mHum.AutoRotate=false
            RunService.Heartbeat:Connect(function()
                if not AC_selectedTarget then return end
                local t2=AC_selectedTarget.Character and AC_selectedTarget.Character:FindFirstChild("HumanoidRootPart")
                if t2 and mH and mH.Parent then
                    mH.CFrame=t2.CFrame*CFrame.new(0,0,2.2); mH.AssemblyLinearVelocity=t2.AssemblyLinearVelocity
                end
            end)
        end
    end},
    {cmd=".unbackpack", desc="Stop Backpack", run=function()
        local mc=lp.Character; if not mc then return end
        local h=mc:FindFirstChildOfClass("Humanoid"); if h then h.AutoRotate=true end
    end},
    {cmd=".cleartarget", desc="Clear target", run=function()
        AC_selectedTarget=nil
        local mc=lp.Character
        if mc then local h=mc:FindFirstChildOfClass("Humanoid")
            if h then workspace.CurrentCamera.CameraSubject=h end end
    end},
    {cmd=".antiafk", desc="Toggle Anti-AFK", run=function() openAntiAFK() end},
    {cmd=".facebang", desc="Open Face Bang", run=function() openFaceBang() end},
    {cmd=".baseplate", desc="Infinite Baseplate", run=function() openBaseplateCmd() end},
    {cmd=".antivcb", desc="Anti VC Ban", run=function()
        if getgenv().AC_antiVCBan then pcall(getgenv().AC_antiVCBan) end
    end},
    {cmd=".shaders", desc="Load P-Shaders", run=function()
        task.spawn(function() pcall(function()
            loadstring(game:HttpGet("https:".._sl.."raw.githubusercontent.com/randomstring0/pshade-ultimate/refs/heads/main/src/cd.lua"))()
        end) end)
    end},
    {cmd=".hide [name]", desc="Hide player", run=function(args)
        local targets=args and args~="" and Shorten(args) or (AC_selectedTarget and {AC_selectedTarget} or {})
        for _,plr in ipairs(targets) do
            if plr~=lp and plr.Character then
                for _,p in ipairs(plr.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.Transparency=1
                    elseif p:IsA("Decal") then p.Transparency=1
                    elseif p:IsA("Sound") then p.Volume=0 end
                end
            end
        end
    end},
    {cmd=".unhide [name]", desc="Unhide player", run=function(args)
        local targets=args and args~="" and Shorten(args) or (AC_selectedTarget and {AC_selectedTarget} or {})
        for _,plr in ipairs(targets) do
            if plr~=lp and plr.Character then
                for _,p in ipairs(plr.Character:GetDescendants()) do
                    if p:IsA("Sound") then p.Volume=0.5 end
                end
                pcall(function()
                    local hd=plr.Character:FindFirstChild("Head")
                    if hd then for _,pp in ipairs(plr.Character:GetDescendants()) do
                        if pp:IsA("BasePart") then pp.Transparency=0
                        elseif pp:IsA("Decal") then pp.Transparency=0 end
                    end end
                end)
            end
        end
    end},
    -- -- NEW COMMANDS ------------------------------------------
    {cmd=".nc", desc="Toggle No-Clip (walk through walls)", run=function()
        getgenv().AC_noClip = not getgenv().AC_noClip
        if getgenv().AC_noClip then
            if getgenv().AC_noClipConn then getgenv().AC_noClipConn:Disconnect() end
            getgenv().AC_noClipConn = RunService.Stepped:Connect(function()
                local char=lp.Character; if not char then return end
                for _,p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide=false end
                end
            end)
        else
            if getgenv().AC_noClipConn then getgenv().AC_noClipConn:Disconnect(); getgenv().AC_noClipConn=nil end
            local char=lp.Character; if not char then return end
            for _,p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide=true end
            end
        end
    end},
    {cmd=".noclip", desc="Toggle No-Clip (alias)", run=function()
        getgenv().AC_noClip = not getgenv().AC_noClip
        if getgenv().AC_noClip then
            if getgenv().AC_noClipConn then getgenv().AC_noClipConn:Disconnect() end
            getgenv().AC_noClipConn = RunService.Stepped:Connect(function()
                local char=lp.Character; if not char then return end
                for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
            end)
        else
            if getgenv().AC_noClipConn then getgenv().AC_noClipConn:Disconnect(); getgenv().AC_noClipConn=nil end
            local char=lp.Character; if not char then return end
            for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end
        end
    end},
    {cmd=".fly", desc="Toggle superman fly mode", run=function()
        getgenv().AC_flyActive = not getgenv().AC_flyActive
        if getgenv().AC_flyActive then
            local char=lp.Character; if not char then return end
            local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
            hum.PlatformStand=true
            local bv=Instance.new("BodyVelocity"); bv.Name="AC_FlyVel"; bv.MaxForce=Vector3.new(1e6,1e6,1e6); bv.Velocity=Vector3.zero; bv.Parent=hrp
            local bg=Instance.new("BodyGyro"); bg.Name="AC_FlyGyro"; bg.MaxTorque=Vector3.new(1e6,1e6,1e6); bg.CFrame=hrp.CFrame; bg.D=50; bg.P=1e4; bg.Parent=hrp
            local spd=50
            if getgenv().AC_flyConn then getgenv().AC_flyConn:Disconnect() end
            getgenv().AC_flyConn = RunService.RenderStepped:Connect(function()
                if not getgenv().AC_flyActive then return end
                local char2=lp.Character; if not char2 then return end
                local hrp2=char2:FindFirstChild("HumanoidRootPart"); if not hrp2 then return end
                local bv2=hrp2:FindFirstChild("AC_FlyVel"); local bg2=hrp2:FindFirstChild("AC_FlyGyro"); if not bv2 or not bg2 then return end
                local cam=workspace.CurrentCamera
                local fwd=UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or (UserInputService:IsKeyDown(Enum.KeyCode.S) and -1 or 0)
                local side=UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or (UserInputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0)
                local up=UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and -1 or 0)
                local dir=cam.CFrame.LookVector*fwd + cam.CFrame.RightVector*side + Vector3.new(0,up,0)
                bv2.Velocity = dir.Magnitude > 0 and dir.Unit*spd or Vector3.zero
                bg2.CFrame = cam.CFrame
            end)
        else
            if getgenv().AC_flyConn then getgenv().AC_flyConn:Disconnect(); getgenv().AC_flyConn=nil end
            local char=lp.Character; if not char then return end
            local hrp=char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bv=hrp:FindFirstChild("AC_FlyVel"); if bv then bv:Destroy() end
                local bg=hrp:FindFirstChild("AC_FlyGyro"); if bg then bg:Destroy() end
            end
            local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.PlatformStand=false end
        end
    end},
    {cmd=".invis", desc="Toggle character invisibility", run=function()
        getgenv().AC_invis = not getgenv().AC_invis
        local char=lp.Character; if not char then return end
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.Transparency = getgenv().AC_invis and 1 or 0
            elseif p:IsA("Decal") then p.Transparency = getgenv().AC_invis and 1 or 0 end
        end
    end},
    {cmd=".freeze", desc="Freeze your character in place", run=function()
        local char=lp.Character; if not char then return end
        local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed=0; hum.JumpPower=0 end
        local ba=Instance.new("BodyAngularVelocity"); ba.Name="AC_Freeze"; ba.MaxTorque=Vector3.new(1e9,1e9,1e9); ba.AngularVelocity=Vector3.zero; ba.Parent=hrp
        local bv=Instance.new("BodyVelocity"); bv.Name="AC_FreezeV"; bv.MaxForce=Vector3.new(1e9,1e9,1e9); bv.Velocity=Vector3.zero; bv.Parent=hrp
    end},
    {cmd=".unfreeze", desc="Unfreeze your character", run=function()
        local char=lp.Character; if not char then return end
        local hrp=char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local ba=hrp:FindFirstChild("AC_Freeze"); if ba then ba:Destroy() end
            local bv=hrp:FindFirstChild("AC_FreezeV"); if bv then bv:Destroy() end
        end
        local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed=currentWS or 16; hum.JumpPower=currentJP or 50 end
    end},
    {cmd=".kill", desc="Break your character joints (self-kill)", run=function()
        local char=lp.Character; if char then char:BreakJoints() end
    end},
    {cmd=".god", desc="Toggle god mode (max health loop)", run=function()
        getgenv().AC_godActive = not getgenv().AC_godActive
        if getgenv().AC_godActive then
            if getgenv().AC_godConn then getgenv().AC_godConn:Disconnect() end
            getgenv().AC_godConn = RunService.Heartbeat:Connect(function()
                if not getgenv().AC_godActive then getgenv().AC_godConn:Disconnect(); getgenv().AC_godConn=nil; return end
                local char=lp.Character; if not char then return end
                local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
                hum.MaxHealth=math.huge; hum.Health=math.huge
            end)
        else
            if getgenv().AC_godConn then getgenv().AC_godConn:Disconnect(); getgenv().AC_godConn=nil end
            local char=lp.Character; if not char then return end
            local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.MaxHealth=100; hum.Health=100 end
        end
    end},
    {cmd=".ungod", desc="Disable god mode", run=function()
        getgenv().AC_godActive=false
        if getgenv().AC_godConn then getgenv().AC_godConn:Disconnect(); getgenv().AC_godConn=nil end
        local char=lp.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.MaxHealth=100; hum.Health=100 end
    end},
    {cmd=".size [n]", desc="Scale character size (e.g. .size 2)", run=function(args)
        local v=tonumber(args); if not v then return end
        v=math.clamp(v,0.1,10)
        pcall(function()
            local char=lp.Character; if not char then return end
            local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
            hum.BodyDepthScale.Value=v; hum.BodyHeightScale.Value=v; hum.BodyWidthScale.Value=v; hum.HeadScale.Value=v
        end)
    end},
    {cmd=".tp [x y z]", desc="Teleport to coordinates (e.g. .tp 0 50 0)", run=function(args)
        if not args or args=="" then return end
        local x,y,z=args:match("(%-?%d+%.?%d*)%s+(%-?%d+%.?%d*)%s+(%-?%d+%.?%d*)")
        if x and y and z then
            pcall(function()
                local char=lp.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame=CFrame.new(tonumber(x),tonumber(y),tonumber(z)) end
            end)
        else
            -- fallback: player name
            local tgt=Shorten(args); if tgt[1] then
                local tc=tgt[1].Character; local mc=lp.Character
                if tc and mc then local tH=tc:FindFirstChild("HumanoidRootPart"); local mH=mc:FindFirstChild("HumanoidRootPart"); if tH and mH then mH.CFrame=tH.CFrame*CFrame.new(3,0,3) end end
            end
        end
    end},
    {cmd=".fps", desc="Print current FPS to console", run=function()
        local fps=math.floor(1/RunService.RenderStepped:Wait()+0.5)
        print("[AC] FPS: "..tostring(fps))
    end},
    {cmd=".ping", desc="Print current ping to console", run=function()
        pcall(function()
            local stats=game:GetService("Stats"); local ping=stats.Network.ServerStatsItem["Data Ping"]:GetValue()
            print("[AC] Ping: "..tostring(math.floor(ping)).."ms")
        end)
    end},
    {cmd=".clear", desc="Clear all tools from backpack", run=function()
        local bp=lp:FindFirstChild("Backpack"); if bp then for _,t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then t:Destroy() end end end
    end},
    {cmd=".looptp", desc="Loop TP to selected target (300 iters)", run=function()
        if not AC_selectedTarget then return end
        task.spawn(function()
            for _=1,300 do
                local tc=AC_selectedTarget and AC_selectedTarget.Character; local mc=lp.Character
                if tc and mc then local tH=tc:FindFirstChild("HumanoidRootPart"); local mH=mc:FindFirstChild("HumanoidRootPart"); if tH and mH then mH.CFrame=tH.CFrame*CFrame.new(3,0,3) end end
                task.wait(0.1)
            end
        end)
    end},
}

local function execCommand(msg)
    if not msg or msg:sub(1,1)~="." then return end
    local cmd,args=msg:match("^%.(%S+)%s*(.*)")
    if not cmd then return end
    cmd=cmd:lower()
    for _,c in ipairs(COMMANDS) do
        local cBase=c.cmd:match("^%.(%S+)") or ""
        if cBase:lower()==cmd then pcall(c.run, args~="" and args or nil); return end
    end
end

pcall(function() lp.Chatted:Connect(execCommand) end)
pcall(function()
    local TCS=game:GetService("TextChatService")
    if TCS.MessageReceived then
        TCS.MessageReceived:Connect(function(msg)
            if msg.TextSource and msg.TextSource.UserId==lp.UserId then
                execCommand(msg.Text or "")
            end
        end)
    end
end)

-- COMMAND LIST PANEL
openCmdList = function()
    if cmdListOpen then return end; cmdListOpen=true
    local ALL_CMDS={
        -- Chat commands
        {cmd=".view",         desc="Spectate/view target"},
        {cmd=".tp [name]",    desc="Teleport to target or named player"},
        {cmd=".bring",        desc="Bring target to you"},
        {cmd=".spectate",     desc="Spectate target"},
        {cmd=".focus",        desc="Loop TP to target"},
        {cmd=".headsit",      desc="Sit on target head"},
        {cmd=".backpack",     desc="Backpack mode on target"},
        {cmd=".cleartarget",  desc="Clear current target"},
        {cmd=".emotes",       desc="Open Emote Menu"},
        {cmd=".shaders",      desc="Load Shaders"},
        {cmd=".antivcb",      desc="Anti VC Ban"},
        {cmd=".facebang",     desc="Open Face Bang"},
        {cmd=".teleport",     desc="Toggle Click Teleport"},
        {cmd=".baseplate",    desc="Toggle Infinite Baseplate"},
        {cmd=".antiafk",      desc="Toggle Anti-AFK"},
        {cmd=".antilag",      desc="Toggle Anti Lag"},
        {cmd=".bpcolor",     desc="Open Baseplate Color picker"},
        {cmd=".clicktp",     desc="Toggle Click-to-Teleport with keybind"},
        {cmd=".hide [name]",  desc="Hide player visuals/audio"},
        {cmd=".unhide [p]",   desc="Unhide player"},
        {cmd=".re",           desc="Respawn in place"},
        {cmd=".unheadsit",    desc="Stop HeadSit mode"},
        {cmd=".unbackpack",   desc="Stop Backpack mode"},
        {cmd=".rj",           desc="Rejoin same server"},
        {cmd=".sh",           desc="Server hop"},
        {cmd=".ws [n]",       desc="Set WalkSpeed"},
        {cmd=".jp [n]",       desc="Set JumpPower"},
        {cmd=".bang",         desc="Bang target"},
        {cmd=".stand",        desc="Stand on target"},
        {cmd=".doggy",        desc="Doggy position on target"},
        {cmd=".drag",         desc="Drag target"},
        {cmd=".fling",        desc="Fling target"},
        {cmd=".fly",          desc="Superman Fly toggle"},
        {cmd=".jerk",         desc="Open Jerk panel"},
        {cmd=".hug",          desc="Open Hug panel"},
        {cmd=".invisible",    desc="Toggle Invisible"},
        {cmd=".antifling",    desc="Toggle Anti Fling"},
        {cmd=".antifacebang", desc="Toggle Anti Bang"},
        {cmd=".chatcolor",    desc="Open Chat Color panel"},
        {cmd=".animlogger",   desc="Open Anim Logger"},
        {cmd=".reani",        desc="Open AC Reanimation"},
        {cmd=".ugc",          desc="Open UGC Emotes"},
        {cmd=".autoclik",     desc="Open Auto Clicker"},
        -- New commands
        {cmd=".nc",           desc="Toggle No-Clip (walk through walls)"},
        {cmd=".noclip",       desc="Toggle No-Clip (alias for .nc)"},
        {cmd=".invis",        desc="Toggle character invisibility"},
        {cmd=".freeze",       desc="Freeze your character in place"},
        {cmd=".unfreeze",     desc="Unfreeze your character"},
        {cmd=".kill",         desc="Break your character joints"},
        {cmd=".god",          desc="Toggle god mode (infinite health)"},
        {cmd=".ungod",        desc="Disable god mode"},
        {cmd=".size [n]",     desc="Scale character size (0.1-10)"},
        {cmd=".tp [x y z]",  desc="Teleport to coordinates"},
        {cmd=".fps",          desc="Print current FPS to console"},
        {cmd=".ping",         desc="Print current ping to console"},
        {cmd=".clear",        desc="Clear all tools from backpack"},
        {cmd=".looptp",       desc="Loop TP to selected target"},
    }

    local PW,PH=420,500
    local panel,content,clsB=mkStdPanel("CmdListPanel",PW,PH,"AC AudioCrafter -- Commands")
    clsB.Activated:Connect(function() panel:Destroy(); cmdListOpen=false end)

    -- Search bar at top of content
    local searchBox=Instance.new("TextBox")
    searchBox.Size=UDim2.new(1,0,0,30)
    searchBox.Position=UDim2.new(0,0,0,0)
    searchBox.BackgroundColor3=C.cardDark
    searchBox.BorderSizePixel=0
    searchBox.PlaceholderText="  Search commands..."
    searchBox.Text=""
    searchBox.TextColor3=C.white
    searchBox.PlaceholderColor3=C.txtDim
    searchBox.TextSize=12
    searchBox.Font=Enum.Font.Gotham
    searchBox.ClearTextOnFocus=false
    searchBox.ZIndex=72
    searchBox.Parent=content
    corner(searchBox,6)
    mkStroke(searchBox,C.sep,1)

    -- Scroll frame for results below search bar
    local listScroll=Instance.new("ScrollingFrame")
    listScroll.Size=UDim2.new(1,0,1,-38)
    listScroll.Position=UDim2.new(0,0,0,38)
    listScroll.BackgroundTransparency=1
    listScroll.BorderSizePixel=0
    listScroll.ScrollBarThickness=4
    listScroll.ScrollBarImageColor3=C.purple
    listScroll.CanvasSize=UDim2.new(0,0,0,0)
    listScroll.ZIndex=72
    listScroll.Parent=content
    local listLayout=Instance.new("UIListLayout")
    listLayout.SortOrder=Enum.SortOrder.LayoutOrder
    listLayout.Padding=UDim.new(0,4)
    listLayout.Parent=listScroll
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        listScroll.CanvasSize=UDim2.new(0,0,0,listLayout.AbsoluteContentSize.Y+8)
    end)
    listScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

    -- Build a row for each command
    local rows={}
    local function buildRow(entry, order)
        local row=Instance.new("Frame")
        row.Size=UDim2.new(1,-8,0,46)
        row.BackgroundColor3=C.cardDark
        row.BorderSizePixel=0
        row.LayoutOrder=order
        row.ZIndex=73
        row.Parent=listScroll
        corner(row,8)
        local cs=mkStroke(row,C.cardBord,1.5)
        do
            local cg=Instance.new("UIGradient")
            cg.Color=ColorSequence.new({
                ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
                ColorSequenceKeypoint.new(0.25,Color3.fromRGB(120,0,110)),
                ColorSequenceKeypoint.new(0.5,Color3.fromRGB(10,10,10)),
                ColorSequenceKeypoint.new(0.75,Color3.fromRGB(120,0,110)),
                ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255)),
            }); cg.Parent=cs
            RunService.Heartbeat:Connect(function() if cs.Parent then cg.Rotation=(cg.Rotation+1)%360 end end)
        end
        -- Command label (left, bold, purple)
        local cmdLbl=Instance.new("TextLabel")
        cmdLbl.Size=UDim2.new(0.42,0,1,0)
        cmdLbl.Position=UDim2.new(0,10,0,0)
        cmdLbl.BackgroundTransparency=1
        cmdLbl.Text=entry.cmd
        cmdLbl.TextColor3=Color3.fromRGB(200,140,255)
        cmdLbl.TextSize=12
        cmdLbl.Font=Enum.Font.GothamBold
        cmdLbl.TextXAlignment=Enum.TextXAlignment.Left
        cmdLbl.TextTruncate=Enum.TextTruncate.AtEnd
        cmdLbl.ZIndex=74
        cmdLbl.Parent=row
        -- Description label (right, dim)
        local descLbl=Instance.new("TextLabel")
        descLbl.Size=UDim2.new(0.56,0,1,0)
        descLbl.Position=UDim2.new(0.44,0,0,0)
        descLbl.BackgroundTransparency=1
        descLbl.Text=entry.desc
        descLbl.TextColor3=C.txtDim
        descLbl.TextSize=11
        descLbl.Font=Enum.Font.Gotham
        descLbl.TextXAlignment=Enum.TextXAlignment.Left
        descLbl.TextWrapped=true
        descLbl.ZIndex=74
        descLbl.Parent=row
        -- Divider line
        local div=Instance.new("Frame")
        div.Size=UDim2.new(0,1,0.6,0)
        div.Position=UDim2.new(0.43,0,0.2,0)
        div.BackgroundColor3=C.sep
        div.BorderSizePixel=0
        div.ZIndex=74
        div.Parent=row
        -- Flash purple on click and run the command
        row.Activated:Connect(function()
            TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=C.purple}):Play()
            task.delay(0.3,function() if row.Parent then TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=C.cardDark}):Play() end end)
            local key=entry.cmd:lower():match("^([^%s%.]+%.?[^%s]*)")
            for _,c in ipairs(COMMANDS) do
                if c.cmd:lower() == key or c.cmd:lower():match("^"..key:gsub("%.","%%%.")) then
                    pcall(c.run); break
                end
            end
        end)
        return row
    end

    for i,entry in ipairs(ALL_CMDS) do
        local r=buildRow(entry,i)
        -- Click to run the command
        local clickBtn=Instance.new("TextButton"); clickBtn.Size=UDim2.new(1,0,1,0)
        clickBtn.BackgroundTransparency=1; clickBtn.Text=""; clickBtn.ZIndex=76; clickBtn.Parent=r
        clickBtn.Activated:Connect(function()
            -- Find matching command in COMMANDS table and run it
            local cmdKey=entry.cmd:lower()
            for _,c in ipairs(COMMANDS) do
                if c.cmd:lower()==cmdKey and c.run then
                    pcall(c.run); return
                end
            end
            -- Fallback: run via execCommand
            pcall(function() execCommand(entry.cmd) end)
        end)
        table.insert(rows,{row=r,cmd=entry.cmd:lower(),desc=entry.desc:lower()})
    end

    -- Search filter
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q=searchBox.Text:lower()
        for _,r in ipairs(rows) do
            r.row.Visible=(q=="" or r.cmd:find(q,1,true) or r.desc:find(q,1,true)) and true or false
        end
    end)
end

-- -- KEY SYSTEM (restyled) ------------------------------------
local function _buildKeySystem()
    local KW,KH=480,310; local KEY_CACHE_FILE="AC_KeyCache_"..tostring(lp.UserId)..".json"; local KEY_EXPIRE_SECS=12*3600
    local keyGui=Instance.new("ScreenGui"); keyGui.Name="AC_KeyGui"; keyGui.ResetOnSpawn=false; keyGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; keyGui.DisplayOrder=999; keyGui.IgnoreGuiInset=true; pcall(function() keyGui.Parent=CoreGui end)

    local kPanel=Instance.new("Frame"); kPanel.Name="KeyPanel"; kPanel.Size=UDim2.new(0,KW,0,KH)
    kPanel.Position=UDim2.new(0.5,-KW/2,0,-KH-10); kPanel.BackgroundColor3=Color3.fromRGB(6,6,8)
    kPanel.BorderSizePixel=0; kPanel.ZIndex=100; kPanel.Parent=keyGui; corner(kPanel,16)
    mkStroke(kPanel,C.sep,2)

    -- top accent bar
    local accentBar=mkFrame(kPanel,{Size=UDim2.new(1,0,0,4),BackgroundColor3=C.purple,ZIndex=101})
    corner(accentBar,2)
    mkFrame(kPanel,{Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,0,2),BackgroundColor3=C.purple,ZIndex=100})

    -- logo area
    local logoRow=mkFrame(kPanel,{Size=UDim2.new(1,0,0,70),Position=UDim2.new(0,0,0,12),
        BackgroundTransparency=1,ZIndex=101})
    mkLabel(logoRow,"AudioCrafter",{Size=UDim2.new(1,0,0,32),Position=UDim2.new(0,28,0,10),
        TextSize=24,Font=Enum.Font.GothamBlack,TextColor3=C.white,ZIndex=102,
        TextXAlignment=Enum.TextXAlignment.Left})
    mkLabel(logoRow,"v1.8  -  Key Authentication Required",{Size=UDim2.new(1,0,0,18),Position=UDim2.new(0,28,0,42),
        TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.txtDim,ZIndex=102,
        TextXAlignment=Enum.TextXAlignment.Left})

    -- status row
    local statusRow=mkFrame(kPanel,{Size=UDim2.new(1,-28,0,34),Position=UDim2.new(0,14,0,86),
        BackgroundColor3=C.cardDark,ZIndex=101})
    corner(statusRow,8); mkStroke(statusRow,C.cardBord,1)
    local statusDot=mkFrame(statusRow,{Size=UDim2.new(0,10,0,10),Position=UDim2.new(0,12,0.5,-5),
        BackgroundColor3=C.txtDim,ZIndex=102}); corner(statusDot,5)
    local statusLblK=mkLabel(statusRow,"Enter your key to unlock AC AudioCrafter",{
        Size=UDim2.new(1,-34,1,0),Position=UDim2.new(0,28,0,0),
        TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.txtDim,ZIndex=102,
        TextXAlignment=Enum.TextXAlignment.Left})

    -- input row
    local inputRow=mkFrame(kPanel,{Size=UDim2.new(1,-28,0,42),Position=UDim2.new(0,14,0,128),
        BackgroundTransparency=1,ZIndex=101})
    local keyBox=Instance.new("TextBox"); keyBox.Size=UDim2.new(1,-100,1,0)
    keyBox.BackgroundColor3=C.cardDark; keyBox.BorderSizePixel=0
    keyBox.Font=Enum.Font.Gotham; keyBox.TextColor3=C.white
    keyBox.PlaceholderText="Paste your key here..."; keyBox.PlaceholderColor3=Color3.fromRGB(70,70,70)
    keyBox.TextSize=13; keyBox.Text=""; keyBox.ClearTextOnFocus=false
    keyBox.ZIndex=102; keyBox.TextXAlignment=Enum.TextXAlignment.Left; keyBox.Parent=inputRow
    corner(keyBox,8); mkStroke(keyBox,C.cardBord,1)
    do local kp=Instance.new("UIPadding"); kp.PaddingLeft=UDim.new(0,12); kp.Parent=keyBox end
    local enterBtn=mkBtn(inputRow,"UNLOCK",{Size=UDim2.new(0,90,1,0),Position=UDim2.new(1,-90,0,0),
        BackgroundColor3=C.purple,TextSize=12,Font=Enum.Font.GothamBold,ZIndex=102})
    corner(enterBtn,8)

    -- separator
    mkFrame(kPanel,{Size=UDim2.new(1,-28,0,1),Position=UDim2.new(0,14,0,180),BackgroundColor3=C.cardBord,ZIndex=101})

    -- action buttons grid
    local discordBtn=mkBtn(kPanel,"Discord Server",{Size=UDim2.new(0.5,-21,0,40),Position=UDim2.new(0,14,0,192),
        BackgroundColor3=C.cardDark,TextSize=12,Font=Enum.Font.GothamBold,ZIndex=101})
    corner(discordBtn,8); mkStroke(discordBtn,C.cardBord,1)
    discordBtn.MouseEnter:Connect(function() TweenService:Create(discordBtn,TweenInfo.new(0.05),{BackgroundColor3=C.card}):Play() end)
    discordBtn.MouseLeave:Connect(function() TweenService:Create(discordBtn,TweenInfo.new(0.05),{BackgroundColor3=C.cardDark}):Play() end)

    local getKeyBtn=mkBtn(kPanel,"Get Key",{Size=UDim2.new(0.5,-21,0,40),Position=UDim2.new(0.5,7,0,192),
        BackgroundColor3=C.purple,TextSize=12,Font=Enum.Font.GothamBold,ZIndex=101})
    corner(getKeyBtn,8)
    getKeyBtn.MouseEnter:Connect(function() TweenService:Create(getKeyBtn,TweenInfo.new(0.05),{BackgroundColor3=C.purpleDim}):Play() end)
    getKeyBtn.MouseLeave:Connect(function() TweenService:Create(getKeyBtn,TweenInfo.new(0.05),{BackgroundColor3=C.purple}):Play() end)

    -- warning
    local warnCard=mkFrame(kPanel,{Size=UDim2.new(1,-28,0,36),Position=UDim2.new(0,14,0,244),
        BackgroundColor3=Color3.fromRGB(30,5,5),ZIndex=101})
    corner(warnCard,8); mkStroke(warnCard,Color3.fromRGB(80,20,20),1)
    mkLabel(warnCard,"!  Sharing your key will result in a permanent blacklist.",{
        Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,10,0,0),
        TextSize=11,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(200,80,80),ZIndex=102})

    mkLabel(kPanel,"AC AudioCrafter v1.8  -  by MelodyCrafter3",{Size=UDim2.new(1,0,0,14),
        Position=UDim2.new(0,0,1,-18),TextSize=9,Font=Enum.Font.Gotham,
        TextColor3=Color3.fromRGB(45,45,45),TextXAlignment=Enum.TextXAlignment.Center,ZIndex=101})

    local function setStatus(state,msg)
        if state=="idle" then statusDot.BackgroundColor3=C.txtDim; statusLblK.Text=msg or "Enter your key to unlock AC AudioCrafter"; statusLblK.TextColor3=C.txtDim; statusRow.BackgroundColor3=C.cardDark
        elseif state=="checking" then statusDot.BackgroundColor3=Color3.fromRGB(245,180,0); statusLblK.Text="Checking key..."; statusLblK.TextColor3=Color3.fromRGB(245,180,0); statusRow.BackgroundColor3=Color3.fromRGB(20,15,5)
        elseif state=="valid" then statusDot.BackgroundColor3=C.green; statusLblK.Text="Key valid  -  Access Granted!"; statusLblK.TextColor3=C.green; statusRow.BackgroundColor3=Color3.fromRGB(5,18,8)
        elseif state=="invalid" then statusDot.BackgroundColor3=Color3.fromRGB(220,60,60); statusLblK.Text=msg or "Access Denied  -  Invalid Key"; statusLblK.TextColor3=Color3.fromRGB(220,60,60); statusRow.BackgroundColor3=Color3.fromRGB(18,5,5) end
    end

    local function grantAccess(cachedKey)
        pcall(function() writefile(KEY_CACHE_FILE,HttpService:JSONEncode({key=cachedKey,t=os.time()})) end)
        keyValidated=true; setStatus("valid"); registerSelf(); task.wait(1.0)
        TweenService:Create(kPanel,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.In),
            {Position=UDim2.new(0.5,-KW/2,0,-KH-10)}):Play()
        task.wait(0.4); keyGui:Destroy(); Win.Visible=true; switchPage(1)
    end

    local checking=false
    local function doValidate(enteredKey)
        if checking then return end
        local entered=(enteredKey or keyBox.Text or ""):match("^%s*(.-)%s*$")
        if #entered==0 then setStatus("invalid","Please enter a key first"); return end
        checking=true; setStatus("checking"); enterBtn.Text="..."; enterBtn.BackgroundColor3=C.purpleDim
        task.spawn(function()
            local ok,res=pcall(function() return game:HttpGet(KEY_API) end); local validKey=""
            if ok and res then validKey=(res:match("^%s*(.-)%s*$") or "") end
            if ok and validKey~="" and entered==validKey then grantAccess(entered)
            else setStatus("invalid","Access Denied  -  Key not valid"); enterBtn.Text="UNLOCK"; enterBtn.BackgroundColor3=C.purple; checking=false end
        end)
    end

    enterBtn.Activated:Connect(function() doValidate(nil) end)
    keyBox.FocusLost:Connect(function(entered) if entered then doValidate(nil) end end)

    getKeyBtn.Activated:Connect(function()
        pcall(function() setclipboard(KEY_LINK) end); getKeyBtn.Text="Copied! Paste in browser"
        getKeyBtn.BackgroundColor3=C.green
        task.delay(2.5,function() if getKeyBtn and getKeyBtn.Parent then getKeyBtn.Text="Get Key"; getKeyBtn.BackgroundColor3=C.purple end end)
    end)
    discordBtn.Activated:Connect(function()
        pcall(function() setclipboard(DISCORD_INVITE) end); discordBtn.Text="Invite Copied!"
        discordBtn.BackgroundColor3=C.green
        task.delay(2.5,function() if discordBtn and discordBtn.Parent then discordBtn.Text="Discord Server"; discordBtn.BackgroundColor3=C.cardDark end end)
    end)

    if OWNER_USERS[lp.Name] then
        pcall(function() if isfile(KEY_CACHE_FILE) then delfile(KEY_CACHE_FILE) end end)
        keyGui:Destroy(); keyValidated=true; registerSelf(); Win.Visible=true; switchPage(1)
        task.spawn(function()
            local notif=Instance.new("ScreenGui"); notif.Name="AC_OwnerWelcome"; notif.ResetOnSpawn=false; notif.Parent=CoreGui; notif.DisplayOrder=999
            local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(0,420,0,50); lbl.Position=UDim2.new(0.5,-210,0,-60)
            lbl.BackgroundColor3=C.purple; lbl.BorderSizePixel=0; lbl.Font=Enum.Font.GothamBold; lbl.TextColor3=C.white; lbl.TextSize=18; lbl.Text="*  Welcome, AudioCrafter Owner  *"; lbl.BackgroundTransparency=0.15; lbl.ZIndex=10; lbl.Parent=notif
            local co=Instance.new("UICorner"); co.CornerRadius=UDim.new(0,12); co.Parent=lbl
            local st=Instance.new("UIStroke"); st.Thickness=2; st.Color=C.white; st.Transparency=0.6; st.Parent=lbl
            TweenService:Create(lbl,TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(0.5,-210,0,18)}):Play()
            task.wait(3.5)
            TweenService:Create(lbl,TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=UDim2.new(0.5,-210,0,-70),BackgroundTransparency=1,TextTransparency=1}):Play()
            task.wait(0.5); notif:Destroy()
        end)
    else
        TweenService:Create(kPanel,TweenInfo.new(0.45,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
            {Position=UDim2.new(0.5,-KW/2,0.5,-KH/2)}):Play()
        task.spawn(function()
            task.wait(0.5); local cached=nil
            pcall(function()
                if isfile(KEY_CACHE_FILE) then
                    local d=HttpService:JSONDecode(readfile(KEY_CACHE_FILE))
                    if d and d.key and d.t and (os.time()-d.t)<KEY_EXPIRE_SECS then cached=d.key end
                end
            end)
            if cached then
                setStatus("checking"); task.wait(0.8)
                local ok,res=pcall(function() return game:HttpGet(KEY_API) end); local validKey=""
                if ok and res then validKey=(res:match("^%s*(.-)%s*$") or "") end
                if ok and validKey~="" and cached==validKey then grantAccess(cached)
                else pcall(function() if isfile(KEY_CACHE_FILE) then delfile(KEY_CACHE_FILE) end end); setStatus("invalid","Key changed or expired  -  Please re-enter") end
            end
        end)
    end
end
_buildKeySystem()

switchPage(1)

task.delay(1,function()
    pcall(function()
        -- Only add hover sound to buttons inside Win (not sub-panels or other GUIs)
        for _,v in next, Win:GetDescendants() do
            if v:IsA("TextButton") then
                v.MouseEnter:Connect(function()
                    if not (Win and Win.Visible) then return end
                    pcall(function()
                        local s=Instance.new("Sound",v)
                        s.Volume=0.03; s.SoundId="rbxassetid:".._sl.."6042053626"; s:Play()
                        game:GetService("Debris"):AddItem(s,1)
                    end)
                end)
            end
        end
    end)
end)

print("AC AudioCrafter")

--[[
    AC AudioCrafter -- Animated Border Patcher
    Run this AFTER your main AC AudioCrafter script.
    Adds rotating gradient glow to every panel border.
]]

local function _acBottomScope() -- border patcher + clickTP in own scope to stay under Luau 200-register limit
-- Use already-declared RunService, CoreGui, ScreenGui from top of script
local _bp_gradients = {}

-- Heartbeat loop -- rotates all gradients, cleans up dead ones
RunService.Heartbeat:Connect(function()
    for i = #_bp_gradients, 1, -1 do
        local g = _bp_gradients[i]
        if g and g.Parent then
            g.Rotation = (g.Rotation + 1) % 360
        else
            table.remove(_bp_gradients, i)
        end
    end
end)

local _bp_SEP = Color3.fromRGB(120, 0, 110)

local function _bp_addGradient(stroke)
    if stroke:FindFirstChildOfClass("UIGradient") then return end
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,    Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.25, _bp_SEP),
        ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(0,   0,   0)),
        ColorSequenceKeypoint.new(0.75, _bp_SEP),
        ColorSequenceKeypoint.new(1,    Color3.fromRGB(255, 255, 255)),
    })
    g.Parent = stroke
    table.insert(_bp_gradients, g)
end

-- Apply to all existing UIStrokes with thickness >= 2
for _, v in ipairs(ScreenGui:GetDescendants()) do
    if v:IsA("UIStroke") and v.Thickness >= 2 then
        _bp_addGradient(v)
    end
end

-- Watch for sub-panels spawned later
ScreenGui.DescendantAdded:Connect(function(v)
    if v:IsA("UIStroke") and v.Thickness >= 2 then
        task.wait()
        _bp_addGradient(v)
    end
end)

-- Watch for external AK GUIs spawned into PlayerGui
--[[local lp = game:GetService("Players").LocalPlayer
local lpgui = lp:WaitForChild("PlayerGui", 5)
if lpgui then
    lpgui.ChildAdded:Connect(function(child)
        task.wait(0.5)
        if child:IsA("ScreenGui") then
            for _, v in ipairs(child:GetDescendants()) do
                if v:IsA("UIStroke") and v.Thickness >= 2 then
                    addGradient(v)
                end
            end
            child.DescendantAdded:Connect(function(v2)
                if v2:IsA("UIStroke") and v2.Thickness >= 3 then
                    task.wait(); addGradient(v2)
                end
            end)
        end
    end)
end]]

-- -- CLICK TP PANEL -------------------------------------------
local clickTPOpen = false
local clickTPActive = false
local clickTPKey = Enum.KeyCode.E  -- default key
local clickTPConn = nil

openClickTP = function()
    if clickTPOpen then return end; clickTPOpen = true
    local PW, PH = 240, 160
    local panel, ct, cls = mkStdPanel("ClickTPPanel", PW, PH, "Click TP")
    cls.Activated:Connect(function()
        -- Disable on close
        if clickTPActive then
            clickTPActive = false
            if clickTPConn then clickTPConn:Disconnect(); clickTPConn = nil end
        end
        panel:Destroy(); clickTPOpen = false
    end)

    -- Status label
    local statusLbl = mkLabel(ct, "Status: OFF", {
        Size = UDim2.new(1,0,0,16), Position = UDim2.new(0,0,0,0),
        TextSize = 11, Font = Enum.Font.GothamBold,
        TextColor3 = C.txtDim, ZIndex = 72,
        TextXAlignment = Enum.TextXAlignment.Center
    })

    -- Keybind display
    mkLabel(ct, "Keybind", {
        Size = UDim2.new(1,0,0,14), Position = UDim2.new(0,0,0,22),
        TextSize = 10, Font = Enum.Font.GothamBold,
        TextColor3 = C.txtDim, ZIndex = 72,
        TextXAlignment = Enum.TextXAlignment.Center
    })

    local keyBtn = mkBtn(ct, clickTPKey.Name, {
        Size = UDim2.new(0.6,0,0,30), Position = UDim2.new(0.2,0,0,38),
        TextSize = 13, Font = Enum.Font.GothamBold, ZIndex = 72
    })
    corner(keyBtn, 8); hov(keyBtn, C.purple, C.purpleDim)

    local listening = false
    keyBtn.Activated:Connect(function()
        if listening then return end
        listening = true
        keyBtn.Text = "Press a key..."
        keyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        local kconn
        kconn = UserInputService.InputBegan:Connect(function(inp, gp)
            if not gp and inp.UserInputType == Enum.UserInputType.Keyboard then
                clickTPKey = inp.KeyCode
                keyBtn.Text = inp.KeyCode.Name
                keyBtn.BackgroundColor3 = C.purple
                listening = false
                kconn:Disconnect()
            end
        end)
    end)

    -- Toggle button
    local toggleBtn = mkBtn(ct, "Enable", {
        Size = UDim2.new(1,0,0,30), Position = UDim2.new(0,0,0,80),
        TextSize = 13, Font = Enum.Font.GothamBold, ZIndex = 72
    })
    corner(toggleBtn, 8); hov(toggleBtn, C.purple, C.purpleDim)

    toggleBtn.Activated:Connect(function()
        clickTPActive = not clickTPActive
        if clickTPActive then
            toggleBtn.Text = "Disable"
            toggleBtn.BackgroundColor3 = C.green
            statusLbl.Text = "Status: ON  [ "..clickTPKey.Name.." ]"
            statusLbl.TextColor3 = C.green
            -- Start listening for keypress
            if clickTPConn then clickTPConn:Disconnect() end
            clickTPConn = UserInputService.InputBegan:Connect(function(inp, gp)
                if gp then return end
                if inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == clickTPKey then
                    pcall(function()
                        local char = lp.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if not hrp then return end
                        local mouse = lp:GetMouse()
                        local target = mouse.Hit
                        if target then
                            -- Offset slightly upward so we land on top of surface
                            hrp.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
                        end
                    end)
                end
            end)
        else
            toggleBtn.Text = "Enable"
            toggleBtn.BackgroundColor3 = C.purple
            statusLbl.Text = "Status: OFF"
            statusLbl.TextColor3 = C.txtDim
            if clickTPConn then clickTPConn:Disconnect(); clickTPConn = nil end
        end
    end)

    -- Hint label
    mkLabel(ct, "Aim cursor at a surface then press key", {
        Size = UDim2.new(1,0,0,14), Position = UDim2.new(0,0,0,116),
        TextSize = 9, Font = Enum.Font.Gotham,
        TextColor3 = C.txtDim, ZIndex = 72,
        TextXAlignment = Enum.TextXAlignment.Center
    })
end -- openClickTP
end -- border patcher + clickTP scope
_acBottomScope()
