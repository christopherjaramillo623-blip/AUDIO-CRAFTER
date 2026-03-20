-- ============================================================
-- AC AudioCrafter  V4.33  by MelodyCrafter
-- !! CLAUDE: EVERY SINGLE EDIT = bump AC_VER + add changelog !!
-- ============================================================
-- CHANGELOG
-- v4.33  (current)
--   FIX: FacBang panel now uses AC purple color scheme (no more red/pink)
--   FIX: FacBang panel no longer flies to top-left; position is clamped on open
--   FIX: Thrust motion now always stays IN FRONT of face, never goes behind
--   FIX: Removed red info text below toggle; kept yellow warning; trimmed panel height
--   FIX: Keybind listener had "" empty string KeyCode error - now fully guarded
-- v3.7
--   REMOVED: Highlight Usernames / ESP feature from Misc tab
--   MOVED:   Infinite Baseplate -> World tab, below Shaders
--   ADDED:   FacBang floating panel (keybind, dist/speed sliders, toggle)
--   FIX:     All InputBegan handlers guard UserInputType==Keyboard before
--            touching KeyCode -- fixes '' not valid Enum.KeyCode errors
-- v3.6.1
--   FIX: Open anim no longer shrinks sidebar/mainPanel (blank home page bug)
--   FIX: Only wrapper animates on open/close, inner panels stay full size
--   FIX: Stagger tweens on navbar/sidebar/mainPanel removed (stutter fix)
-- v3.6
--   FIX: Misc tab do..end block never closed
--   FIX: Duplicate open animation removed (stutter on execute)
--   FIX: rS2 undefined in buildUgcRow renamed to rS
--   FIX: _uiOpen correctly set after open animation completes
-- ============================================================
local AC_VER = "4.33"

_G.__AC_VERSION = (_G.__AC_VERSION or 0) + 1
local __AC_MY_VER = _G.__AC_VERSION
local function __acStopped() return _G.__AC_VERSION ~= __AC_MY_VER end

pcall(function()
    local pg = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
    if pg then local old=pg:FindFirstChild("AC_GUI"); if old then old:Destroy() end end
    local cg = game:GetService("CoreGui")
    local old2=cg:FindFirstChild("AC_GUI"); if old2 then old2:Destroy() end
    for _,p in ipairs(game:GetService("Players"):GetPlayers()) do
        pcall(function()
            if p.Character then
                local h=p.Character:FindFirstChild("Head")
                if h then local bb=h:FindFirstChild("AC_Billboard"); if bb then bb:Destroy() end end
            end
        end)
    end
end)

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "AudioCrafter";
        Text = "v4.33 Attached!  by MelodyCrafter";
        Icon = "rbxassetid://7059067512";
        Duration = 5;
    })
end)

local AC = {}

local _URLS = {
    EMOTE_JSON  = "https://raw.githubusercontent.com/7yd7/sniper-Emote/refs/heads/test/EmoteSniper.json",
    ANIM_JSON   = "https://raw.githubusercontent.com/7yd7/sniper-Emote/refs/heads/test/AnimationSniper.json",
    PSHADE      = "https://raw.githubusercontent.com/randomstring0/pshade-ultimate/refs/heads/main/src/cd.lua",
    INF_YIELD   = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source",
    REANIMATION = "https://raw.githubusercontent.com/Rootleak/Reanimation/refs/heads/main/module.lua",
    VC_BYPASS   = "https://raw.githubusercontent.com/0riginalWarrior/Stalkie/refs/heads/main/vcbypass.lua",
}
local function safeGet(key)
    local url=_URLS[key]; assert(type(url)=="string" and url:sub(1,8)=="https://","[AC] Bad URL: "..tostring(key))
    return game:HttpGet(url)
end
local function safeRun(key)
    local url=_URLS[key]; assert(type(url)=="string" and url:sub(1,8)=="https://","[AC] Bad URL: "..tostring(key))
    return loadstring(game:HttpGet(url))()
end

AC.Players=game:GetService("Players"); AC.UIS=game:GetService("UserInputService"); AC.TS=game:GetService("TweenService")
AC.RS=game:GetService("RunService"); AC.SS=game:GetService("SoundService"); AC.WS=game:GetService("Workspace")
AC.Lighting=game:GetService("Lighting"); AC.Http=game:GetService("HttpService"); AC.Stats=game:GetService("Stats")
AC.player=AC.Players.LocalPlayer; AC.camera=AC.WS.CurrentCamera; AC.gui=AC.player:WaitForChild("PlayerGui")

AC.executorName=(function()
    if identifyexecutor then local ok,n=pcall(identifyexecutor); if ok and n then return tostring(n) end end
    if getexecutorname then local ok,n=pcall(getexecutorname); if ok and n then return tostring(n) end end
    if XENO_VERSION then return "Xeno" end; if SYNAPSE_VERSION then return "Synapse" end; if FLUXUS_VERSION then return "Fluxus" end
    return "Unknown"
end)()

AC.BG_BASE=Color3.fromRGB(8,8,8); AC.BG_PANEL=Color3.fromRGB(14,14,14); AC.BG_CARD=Color3.fromRGB(20,20,20)
AC.BG_NAV=Color3.fromRGB(5,5,5); AC.BG_SIDEBAR=Color3.fromRGB(11,11,11)
AC.PUR_DARK=Color3.fromRGB(55,0,110); AC.PUR_MID=Color3.fromRGB(100,20,180)
AC.PUR_BRIGHT=Color3.fromRGB(160,60,255); AC.PUR_GLOW=Color3.fromRGB(200,120,255)
AC.PUR_STROKE=Color3.fromRGB(80,10,140)
AC.TXT_WHITE=Color3.new(1,1,1); AC.TXT_MAIN=Color3.fromRGB(230,230,230)
AC.TXT_DIM=Color3.fromRGB(110,110,110); AC.TXT_LABEL=Color3.fromRGB(160,80,255)
AC.TXT_BILLBOARD=Color3.fromRGB(210,160,255)
AC.GREEN_OK=Color3.fromRGB(80,255,120); AC.RED_ERR=Color3.fromRGB(255,70,70); AC.ORANGE_W=Color3.fromRGB(255,165,50)
AC.UI_W=660; AC.UI_H=500; AC.NAV_H=40; AC.SIDE_W=150; AC.MAIN_W=AC.UI_W-AC.SIDE_W-6

AC.drawLogo=function(parent,size,color)
    size=size or 28; color=color or AC.PUR_BRIGHT
    local c=size; local lf=Instance.new("Frame",parent); lf.Size=UDim2.new(0,c,0,c); lf.BackgroundTransparency=1; lf.Name="AC_Logo"
    local function bar(w,h,ax,ay,rot,col)
        local f=Instance.new("Frame",lf); f.Size=UDim2.new(0,math.max(1,math.ceil(w)),0,math.max(1,math.ceil(h)))
        f.Position=UDim2.new(0,math.ceil(ax-w/2),0,math.ceil(ay-h/2)); f.BackgroundColor3=col or color; f.BorderSizePixel=0; f.Rotation=rot or 0
        Instance.new("UICorner",f).CornerRadius=UDim.new(0,math.max(1,math.ceil(w*0.3)))
    end
    local s=c/28
    bar(3*s,17*s,8*s,15*s,-32); bar(3*s,17*s,20*s,15*s,32); bar(13*s,2.5*s,14*s,15*s,-8)
    bar(2.5*s,6*s,15*s,7*s,20); bar(2.5*s,8*s,22*s,21*s,42); bar(5*s,2*s,7*s,22*s,12)
    return lf
end

-- ============================================================
-- CONFIG SYSTEM  -- saves per UserID, works across executors
-- All settings stored in:  AC/<userId>/config.json
-- ============================================================
do
    local CFG_DIR  = "AC"
    local CFG_FILE = CFG_DIR.."/"..tostring(AC.player.UserId).."/config.json"

    -- Defaults (what the UI shows before user touches anything)
    local DEFAULTS = {
        toggleKey    = "G",
        walkSpeed    = 16,
        jumpPower    = 50,
        infJump      = false,
        noclip       = false,
        fullbright   = false,
        timeOfDay    = 14,
        gravity      = 196,
        fpsUnlock    = false,
        antiAfk      = false,
        antiVoid     = false,
        clickTp      = false,
        tagsVisible  = true,
    }

    -- Low-level read/write that works on any executor with writefile support
    local function cfgRead()
        local ok,data=pcall(function()
            if not isfile then return nil end
            if not isfile(CFG_FILE) then return nil end
            return AC.Http:JSONDecode(readfile(CFG_FILE))
        end)
        if ok and type(data)=="table" then return data end
        return {}
    end
    local function cfgWrite(data)
        pcall(function()
            if not writefile then return end
            -- ensure folder structure exists
            pcall(function() if not isfolder then return end
                if not isfolder(CFG_DIR) then makefolder(CFG_DIR) end
                local sub=CFG_DIR.."/"..tostring(AC.player.UserId)
                if not isfolder(sub) then makefolder(sub) end
            end)
            writefile(CFG_FILE, AC.Http:JSONEncode(data))
        end)
    end

    -- Load saved config, merge with defaults
    local saved=cfgRead()
    AC.cfg={}
    for k,v in pairs(DEFAULTS) do
        AC.cfg[k]= (saved[k]~=nil) and saved[k] or v
    end

    -- Save function — call this whenever any setting changes
    AC.cfgSave=function()
        cfgWrite(AC.cfg)
    end

    -- Helper: wrap a toggle callback to also save config
    AC.cfgToggle=function(key, onCb)
        return function(v)
            AC.cfg[key]=v; AC.cfgSave(); onCb(v)
        end
    end
    -- Helper: wrap a slider callback to also save config
    AC.cfgSlider=function(key, onCb)
        return function(v)
            AC.cfg[key]=v; AC.cfgSave(); onCb(v)
        end
    end

    print("[AC] Config loaded from: "..CFG_FILE)
end


-- GUI ROOT
do
    local old=AC.gui:FindFirstChild("AC_GUI"); if old then old:Destroy() end
    AC.screenGui=Instance.new("ScreenGui"); AC.screenGui.Name="AC_GUI"; AC.screenGui.ResetOnSpawn=false
    AC.screenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; AC.screenGui.Parent=AC.gui
    local tc=Instance.new("Frame",AC.screenGui); tc.Size=UDim2.new(0,280,1,-110); tc.Position=UDim2.new(1,-290,0,10); tc.BackgroundTransparency=1; tc.ZIndex=200
    local tl=Instance.new("UIListLayout",tc); tl.FillDirection=Enum.FillDirection.Vertical; tl.VerticalAlignment=Enum.VerticalAlignment.Bottom; tl.SortOrder=Enum.SortOrder.LayoutOrder; tl.Padding=UDim.new(0,5)
    local tlPad=Instance.new("UIPadding",tc); tlPad.PaddingBottom=UDim.new(0,70)
    AC.toastContainer=tc
    AC.toast=function(msg,color)
        color=color or AC.PUR_BRIGHT
        local f=Instance.new("Frame",AC.toastContainer); f.Size=UDim2.new(0,280,0,0); f.BackgroundColor3=Color3.fromRGB(16,16,16); f.BorderSizePixel=0; f.ClipsDescendants=true
        Instance.new("UICorner",f).CornerRadius=UDim.new(0,8)
        local st=Instance.new("UIStroke",f); st.Color=color; st.Thickness=1.5; st.Transparency=0.15
        local bar2=Instance.new("Frame",f); bar2.Size=UDim2.new(0,3,1,0); bar2.BackgroundColor3=color; bar2.BorderSizePixel=0; Instance.new("UICorner",bar2).CornerRadius=UDim.new(0,2)
        local lbl=Instance.new("TextLabel",f); lbl.Size=UDim2.new(1,-16,1,0); lbl.Position=UDim2.new(0,10,0,0); lbl.BackgroundTransparency=1; lbl.Text=msg; lbl.TextColor3=AC.TXT_WHITE; lbl.TextSize=12; lbl.Font=Enum.Font.Gotham; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.TextWrapped=true
        AC.TS:Create(f,TweenInfo.new(0.2,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.new(0,280,0,36)}):Play()
        task.delay(3.2,function() if f and f.Parent then AC.TS:Create(f,TweenInfo.new(0.22),{Size=UDim2.new(0,280,0,0)}):Play(); task.delay(0.25,function() if f and f.Parent then f:Destroy() end end) end end)
    end
    local snd=Instance.new("Sound",AC.SS); snd.SoundId="rbxasset://sounds/electronicpingshort.wav"; snd.Volume=0.4; AC.openSound=snd
    local hSnd=Instance.new("Sound",AC.SS); hSnd.SoundId="rbxasset://sounds/electronicpingshort.wav"; hSnd.Volume=0.018; hSnd.RollOffMaxDistance=0; AC.hoverSnd=hSnd
    local cSnd=Instance.new("Sound",AC.SS); cSnd.SoundId="rbxasset://sounds/electronicpingshort.wav"; cSnd.Volume=0.15; cSnd.RollOffMaxDistance=0; AC.clickSnd=cSnd
    local tSnd=Instance.new("Sound",AC.SS); tSnd.SoundId="rbxasset://sounds/electronicpingshort.wav"; tSnd.Volume=0.2; tSnd.RollOffMaxDistance=0; AC.toggleSnd=tSnd
    AC.tabs={}; AC.selectedTarget=nil; AC.tagsVisible=AC.cfg.tagsVisible; AC.allBillboards={}
    AC.focusConn=nil; AC.onHead=false; AC.headConn=nil
    AC.inBp=false; AC.bpConn=nil; AC.flyActive=false; AC.flyBV=nil; AC.flyBG=nil; AC.flyConn=nil; AC._flyAtt=nil
    AC.noclipConn=nil; AC.shadersActive=false; AC.baseplateRef=nil; AC.antiVoidConn=nil; AC.afkThread=nil; AC.ijConn=nil
    AC._uiOpen=false
end
do
    AC.viewDist=12; AC.viewYaw=0; AC.viewPitch=15
    AC.startViewing=function(p)
        if AC.viewConnection then AC.viewConnection:Disconnect() end
        AC.camera.CameraType=Enum.CameraType.Scriptable
        AC.viewMoveConn=AC.UIS.InputChanged:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseMovement and AC.UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                local d=i.Delta; AC.viewYaw=AC.viewYaw-d.X*0.4; AC.viewPitch=math.clamp(AC.viewPitch-d.Y*0.4,-80,80)
            end
            if i.UserInputType==Enum.UserInputType.MouseWheel then AC.viewDist=math.clamp(AC.viewDist-i.Position.Z*2,3,60) end
        end)
        AC.viewConnection=AC.RS.RenderStepped:Connect(function()
            if __acStopped() then AC.viewConnection:Disconnect(); return end
            if p and p.Character then
                local r=p.Character:FindFirstChild("HumanoidRootPart")
                if r then
                    local origin=r.CFrame.Position+Vector3.new(0,2,0)
                    local offset=CFrame.Angles(0,math.rad(AC.viewYaw),0)*CFrame.Angles(math.rad(AC.viewPitch),0,0)*CFrame.new(0,0,AC.viewDist)
                    AC.camera.CFrame=CFrame.new((CFrame.new(origin)*offset).Position,origin)
                end
            end
        end)
    end
    AC.stopViewing=function()
        if AC.viewConnection then AC.viewConnection:Disconnect(); AC.viewConnection=nil end
        if AC.viewMoveConn then AC.viewMoveConn:Disconnect(); AC.viewMoveConn=nil end
        AC.camera.CameraType=Enum.CameraType.Custom
    end
    AC.makeBtn=function(parent,text,posY,h)
        h=h or 40
        local b=Instance.new("TextButton",parent); b.Size=UDim2.new(1,-24,0,h); b.Position=UDim2.new(0,12,0,posY)
        b.BackgroundColor3=AC.BG_CARD; b.Text=text; b.TextColor3=AC.TXT_MAIN; b.TextSize=13; b.Font=Enum.Font.Gotham
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,8); local s=Instance.new("UIStroke",b); s.Color=AC.PUR_STROKE; s.Thickness=1; s.Transparency=0.4
        b.MouseEnter:Connect(function() AC.TS:Create(b,TweenInfo.new(0.15),{BackgroundColor3=AC.PUR_MID,TextColor3=AC.TXT_WHITE}):Play() end)
        b.MouseLeave:Connect(function() AC.TS:Create(b,TweenInfo.new(0.15),{BackgroundColor3=AC.BG_CARD,TextColor3=AC.TXT_MAIN}):Play() end)
        return b
    end
    AC.sectionLbl=function(parent,text,posY)
        local l=Instance.new("TextLabel",parent); l.Size=UDim2.new(1,-24,0,16); l.Position=UDim2.new(0,12,0,posY)
        l.BackgroundTransparency=1; l.Text=text; l.TextColor3=AC.TXT_LABEL; l.TextSize=9; l.Font=Enum.Font.GothamBold; l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=10
        return l
    end
    AC.makeCard=function(parent,posY,h,bg)
        local c=Instance.new("Frame",parent); c.Size=UDim2.new(1,-24,0,h); c.Position=UDim2.new(0,12,0,posY); c.BackgroundColor3=bg or AC.BG_CARD
        Instance.new("UICorner",c).CornerRadius=UDim.new(0,8); local s=Instance.new("UIStroke",c); s.Color=AC.PUR_STROKE; s.Thickness=1; s.Transparency=0.5
        return c
    end
    AC.halfBtn=function(parent,text,col,row,startY)
        local PAD,GAP=12,6; local bW=(AC.MAIN_W-PAD*2-GAP)/2; local bH=42
        local b=Instance.new("TextButton",parent); b.Size=UDim2.new(0,bW,0,bH); b.Position=UDim2.new(0,PAD+col*(bW+GAP),0,(startY or 0)+row*(bH+6)); b.BackgroundColor3=AC.BG_CARD; b.Text=""
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,8); local s=Instance.new("UIStroke",b); s.Color=AC.PUR_STROKE; s.Thickness=1; s.Transparency=0.4
        local dot=Instance.new("Frame",b); dot.Size=UDim2.new(0,7,0,7); dot.Position=UDim2.new(0,12,0.5,-3); dot.BackgroundColor3=AC.PUR_MID; Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
        local lbl=Instance.new("TextLabel",b); lbl.Size=UDim2.new(1,-28,1,0); lbl.Position=UDim2.new(0,26,0,0); lbl.BackgroundTransparency=1; lbl.Text=text; lbl.TextColor3=AC.TXT_MAIN; lbl.TextSize=12; lbl.Font=Enum.Font.Gotham; lbl.TextXAlignment=Enum.TextXAlignment.Left
        b.MouseEnter:Connect(function() AC.TS:Create(b,TweenInfo.new(0.15),{BackgroundColor3=AC.PUR_MID}):Play(); AC.TS:Create(lbl,TweenInfo.new(0.15),{TextColor3=AC.TXT_WHITE}):Play(); pcall(function() AC.hoverSnd:Play() end) end)
        b.MouseLeave:Connect(function() AC.TS:Create(b,TweenInfo.new(0.15),{BackgroundColor3=AC.BG_CARD}):Play(); AC.TS:Create(lbl,TweenInfo.new(0.15),{TextColor3=AC.TXT_MAIN}):Play() end)
        b.MouseButton1Click:Connect(function() pcall(function() AC.clickSnd:Play() end) end)
        return b
    end
    AC.makeToggle=function(parent,label,posY,default)
        local bg=Instance.new("Frame",parent); bg.Size=UDim2.new(1,-24,0,40); bg.Position=UDim2.new(0,12,0,posY); bg.BackgroundColor3=AC.BG_CARD
        Instance.new("UICorner",bg).CornerRadius=UDim.new(0,8); local s=Instance.new("UIStroke",bg); s.Color=AC.PUR_STROKE; s.Thickness=1; s.Transparency=0.5
        local lbl=Instance.new("TextLabel",bg); lbl.Size=UDim2.new(1,-60,1,0); lbl.Position=UDim2.new(0,12,0,0); lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=AC.TXT_MAIN; lbl.TextSize=13; lbl.Font=Enum.Font.Gotham; lbl.TextXAlignment=Enum.TextXAlignment.Left
        local trk=Instance.new("TextButton",bg); trk.Size=UDim2.new(0,44,0,24); trk.Position=UDim2.new(1,-54,0.5,-12); trk.BackgroundColor3=Color3.fromRGB(40,40,40); trk.Text=""; Instance.new("UICorner",trk).CornerRadius=UDim.new(1,0)
        local knob=Instance.new("Frame",trk); knob.Size=UDim2.new(0,18,0,18); knob.Position=UDim2.new(0,3,0.5,-9); knob.BackgroundColor3=AC.TXT_DIM; Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
        local val=default or false; local cbs={}
        local function upd()
            if val then AC.TS:Create(trk,TweenInfo.new(0.2),{BackgroundColor3=AC.PUR_MID}):Play(); AC.TS:Create(knob,TweenInfo.new(0.2),{Position=UDim2.new(1,-21,0.5,-9),BackgroundColor3=AC.PUR_GLOW}):Play()
            else AC.TS:Create(trk,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(40,40,40)}):Play(); AC.TS:Create(knob,TweenInfo.new(0.2),{Position=UDim2.new(0,3,0.5,-9),BackgroundColor3=AC.TXT_DIM}):Play() end
        end; upd()
        local function toggle() pcall(function() AC.toggleSnd:Play() end); val=not val; upd(); for _,cb in ipairs(cbs) do pcall(cb,val) end end
        trk.MouseButton1Click:Connect(toggle)
        return bg, function() return val end, function(cb) table.insert(cbs,cb) end
    end
    AC.makeSlider=function(parent,label,posY,mn,mx,def,sfx)
        mn=mn or 0; mx=mx or 100; def=def or mn; sfx=sfx or ""
        local bg=Instance.new("Frame",parent); bg.Size=UDim2.new(1,-24,0,52); bg.Position=UDim2.new(0,12,0,posY); bg.BackgroundColor3=AC.BG_CARD
        Instance.new("UICorner",bg).CornerRadius=UDim.new(0,8); local s=Instance.new("UIStroke",bg); s.Color=AC.PUR_STROKE; s.Thickness=1; s.Transparency=0.5
        local lbl=Instance.new("TextLabel",bg); lbl.Size=UDim2.new(0,200,0,20); lbl.Position=UDim2.new(0,12,0,6); lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=AC.TXT_MAIN; lbl.TextSize=12; lbl.Font=Enum.Font.Gotham; lbl.TextXAlignment=Enum.TextXAlignment.Left
        local vLbl=Instance.new("TextLabel",bg); vLbl.Size=UDim2.new(0,80,0,20); vLbl.Position=UDim2.new(1,-88,0,6); vLbl.BackgroundTransparency=1; vLbl.Text=tostring(def)..sfx; vLbl.TextColor3=AC.PUR_GLOW; vLbl.TextSize=12; vLbl.Font=Enum.Font.GothamBold; vLbl.TextXAlignment=Enum.TextXAlignment.Right
        local trk=Instance.new("Frame",bg); trk.Size=UDim2.new(1,-24,0,6); trk.Position=UDim2.new(0,12,0,34); trk.BackgroundColor3=Color3.fromRGB(30,30,30); Instance.new("UICorner",trk).CornerRadius=UDim.new(1,0)
        local fill=Instance.new("Frame",trk); fill.Size=UDim2.new((def-mn)/(mx-mn),0,1,0); fill.BackgroundColor3=AC.PUR_MID; Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
        local knob=Instance.new("TextButton",trk); knob.Size=UDim2.new(0,14,0,14); knob.Position=UDim2.new((def-mn)/(mx-mn),0,0.5,-7); knob.BackgroundColor3=AC.PUR_GLOW; knob.Text=""; Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
        local dragging=false; local cbs={}; local vRef={v=def}
        local function setV(r) r=math.clamp(r,0,1); vRef.v=math.floor(mn+r*(mx-mn)+0.5); vLbl.Text=tostring(vRef.v)..sfx; fill.Size=UDim2.new(r,0,1,0); knob.Position=UDim2.new(r,-7,0.5,-7); for _,cb in ipairs(cbs) do pcall(cb,vRef.v) end end
        local dragConn=nil
        knob.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                dragging=true; dragConn=AC.RS.RenderStepped:Connect(function() setV((AC.UIS:GetMouseLocation().X-trk.AbsolutePosition.X)/trk.AbsoluteSize.X) end)
            end
        end)
        trk.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                dragging=true; setV((AC.UIS:GetMouseLocation().X-trk.AbsolutePosition.X)/trk.AbsoluteSize.X)
                if not dragConn then dragConn=AC.RS.RenderStepped:Connect(function() setV((AC.UIS:GetMouseLocation().X-trk.AbsolutePosition.X)/trk.AbsoluteSize.X) end) end
            end
        end)
        AC.UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false; if dragConn then dragConn:Disconnect(); dragConn=nil end end end)
        return bg, function() return vRef.v end, function(cb) table.insert(cbs,cb) end
    end
    AC.createPage=function()
        local p=Instance.new("ScrollingFrame",AC.pageContainer); p.Size=UDim2.new(1,0,1,0); p.BackgroundTransparency=1; p.BorderSizePixel=0
        p.ScrollBarThickness=3; p.ScrollBarImageColor3=AC.PUR_MID; p.Visible=false; p.AutomaticCanvasSize=Enum.AutomaticSize.Y; p.CanvasSize=UDim2.new(0,0,0,0)
        return p
    end
    AC.createTab=function(name,order,isExt)
        AC.tabs[name]=AC.tabs[name] or {active=false}
        local b=Instance.new("TextButton",AC.sideScroll); b.Size=UDim2.new(1,0,0,40); b.BackgroundColor3=AC.BG_CARD; b.BackgroundTransparency=1; b.Text=""; b.LayoutOrder=order
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
        local acc=Instance.new("Frame",b); acc.Size=UDim2.new(0,3,0.6,0); acc.Position=UDim2.new(0,0,0.2,0); acc.BackgroundColor3=isExt and AC.ORANGE_W or AC.PUR_BRIGHT; acc.BackgroundTransparency=1; Instance.new("UICorner",acc).CornerRadius=UDim.new(0,2)
        local dot=Instance.new("Frame",b); dot.Size=UDim2.new(0,7,0,7); dot.Position=UDim2.new(0,10,0.5,-3); dot.BackgroundColor3=isExt and AC.ORANGE_W or AC.TXT_DIM; Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
        local lbl=Instance.new("TextLabel",b); lbl.Size=UDim2.new(1,-26,1,0); lbl.Position=UDim2.new(0,24,0,0); lbl.BackgroundTransparency=1; lbl.Text=name; lbl.TextColor3=isExt and AC.ORANGE_W or AC.TXT_DIM; lbl.TextSize=13; lbl.Font=Enum.Font.Gotham; lbl.TextXAlignment=Enum.TextXAlignment.Left
        AC.tabs[name].acc=acc; AC.tabs[name].dot=dot; AC.tabs[name].lbl=lbl; AC.tabs[name].btn=b; AC.tabs[name].isExt=isExt
        b.MouseEnter:Connect(function() if not AC.tabs[name].active then AC.TS:Create(b,TweenInfo.new(0.15),{BackgroundColor3=isExt and Color3.fromRGB(50,30,0) or AC.PUR_DARK,BackgroundTransparency=0.3}):Play(); AC.TS:Create(lbl,TweenInfo.new(0.15),{TextColor3=isExt and AC.ORANGE_W or AC.PUR_GLOW}):Play() end end)
        b.MouseLeave:Connect(function() if not AC.tabs[name].active then AC.TS:Create(b,TweenInfo.new(0.15),{BackgroundTransparency=1}):Play(); AC.TS:Create(lbl,TweenInfo.new(0.15),{TextColor3=isExt and AC.ORANGE_W or AC.TXT_DIM}):Play() end end)
        return b
    end
    AC.switchTab=function(name)
        for n,d in pairs(AC.tabs) do
            if d.isExt then continue end; d.active=(n==name)
            if d.page then d.page.Visible=d.active end
            if d.acc then AC.TS:Create(d.acc,TweenInfo.new(0.18),{BackgroundTransparency=d.active and 0 or 1}):Play() end
            if d.dot then AC.TS:Create(d.dot,TweenInfo.new(0.18),{BackgroundColor3=d.active and AC.PUR_BRIGHT or AC.TXT_DIM}):Play() end
            if d.btn then AC.TS:Create(d.btn,TweenInfo.new(0.18),{BackgroundColor3=d.active and AC.PUR_DARK or AC.BG_CARD,BackgroundTransparency=d.active and 0 or 1}):Play() end
            if d.lbl then AC.TS:Create(d.lbl,TweenInfo.new(0.18),{TextColor3=d.active and AC.TXT_WHITE or AC.TXT_DIM}):Play() end
        end
    end
end

-- MAIN FRAME
do
    AC.wrapper=Instance.new("Frame",AC.screenGui); AC.wrapper.Size=UDim2.new(0,AC.UI_W,0,AC.UI_H); AC.wrapper.Position=UDim2.new(0.5,-AC.UI_W/2,0.5,-AC.UI_H/2); AC.wrapper.BackgroundTransparency=1; AC.wrapper.BorderSizePixel=0
    local shadow=Instance.new("Frame",AC.wrapper); shadow.Size=UDim2.new(1,20,1,20); shadow.Position=UDim2.new(0,-10,0,-10); shadow.BackgroundColor3=Color3.fromRGB(0,0,0); shadow.BackgroundTransparency=0.45; shadow.ZIndex=0; Instance.new("UICorner",shadow).CornerRadius=UDim.new(0,20)
    local mainBg=Instance.new("Frame",AC.wrapper); mainBg.Size=UDim2.new(1,0,1,0); mainBg.BackgroundColor3=AC.BG_BASE; mainBg.ZIndex=1; Instance.new("UICorner",mainBg).CornerRadius=UDim.new(0,14)
    AC.navbar=Instance.new("Frame",AC.wrapper); AC.navbar.Size=UDim2.new(1,0,0,AC.NAV_H); AC.navbar.BackgroundColor3=AC.BG_NAV; AC.navbar.ZIndex=5; Instance.new("UICorner",AC.navbar).CornerRadius=UDim.new(0,14); Instance.new("UIStroke",AC.navbar).Color=AC.PUR_STROKE
    local navLogo=AC.drawLogo(AC.navbar,28,AC.PUR_BRIGHT); navLogo.Position=UDim2.new(0,8,0.5,-14); navLogo.ZIndex=6
    local navT=Instance.new("TextLabel",AC.navbar); navT.Size=UDim2.new(0,110,1,0); navT.Position=UDim2.new(0,40,0,0); navT.BackgroundTransparency=1; navT.Text="AudioCrafter"; navT.TextColor3=AC.TXT_WHITE; navT.TextSize=15; navT.Font=Enum.Font.GothamBold; navT.TextXAlignment=Enum.TextXAlignment.Left; navT.ZIndex=6
    local navVer=Instance.new("TextLabel",AC.navbar); navVer.Size=UDim2.new(0,60,1,0); navVer.Position=UDim2.new(0,153,0,0); navVer.BackgroundTransparency=1; navVer.Text="v4.33"; navVer.TextColor3=AC.PUR_BRIGHT; navVer.TextSize=10; navVer.Font=Enum.Font.GothamBold; navVer.TextXAlignment=Enum.TextXAlignment.Left; navVer.ZIndex=6
    local ndot=Instance.new("Frame",AC.navbar); ndot.Size=UDim2.new(0,7,0,7); ndot.Position=UDim2.new(0,194,0.5,-3); ndot.BackgroundColor3=AC.PUR_BRIGHT; ndot.ZIndex=6; Instance.new("UICorner",ndot).CornerRadius=UDim.new(1,0)
    AC.TS:Create(ndot,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{BackgroundColor3=AC.PUR_DARK,BackgroundTransparency=0.4}):Play()
    local navBy=Instance.new("TextLabel",AC.navbar); navBy.Size=UDim2.new(0,160,1,0); navBy.Position=UDim2.new(0,205,0,0); navBy.BackgroundTransparency=1; navBy.Text="by MelodyCrafter"; navBy.TextColor3=AC.TXT_DIM; navBy.TextSize=11; navBy.Font=Enum.Font.Gotham; navBy.TextXAlignment=Enum.TextXAlignment.Left; navBy.ZIndex=6
    AC.minBtn=Instance.new("TextButton",AC.navbar); AC.minBtn.Size=UDim2.new(0,28,0,28); AC.minBtn.Position=UDim2.new(1,-34,0.5,-14); AC.minBtn.BackgroundColor3=Color3.fromRGB(40,40,40); AC.minBtn.Text="-"; AC.minBtn.TextColor3=AC.TXT_WHITE; AC.minBtn.TextSize=18; AC.minBtn.Font=Enum.Font.GothamBold; AC.minBtn.ZIndex=10; AC.minBtn.AutoButtonColor=false
    Instance.new("UICorner",AC.minBtn).CornerRadius=UDim.new(0,6)
    AC.minBtn.MouseEnter:Connect(function() AC.TS:Create(AC.minBtn,TweenInfo.new(0.12),{BackgroundColor3=AC.PUR_DARK}):Play() end)
    AC.minBtn.MouseLeave:Connect(function() AC.TS:Create(AC.minBtn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(40,40,40)}):Play() end)
    local body=Instance.new("Frame",AC.wrapper); body.Size=UDim2.new(1,0,1,-AC.NAV_H-4); body.Position=UDim2.new(0,0,0,AC.NAV_H+4); body.BackgroundTransparency=1; body.ZIndex=2
    AC.sidebar=Instance.new("Frame",body); AC.sidebar.Size=UDim2.new(0,AC.SIDE_W,1,0); AC.sidebar.BackgroundColor3=AC.BG_SIDEBAR; AC.sidebar.ClipsDescendants=true; AC.sidebar.ZIndex=3; Instance.new("UICorner",AC.sidebar).CornerRadius=UDim.new(0,12); local sk=Instance.new("UIStroke",AC.sidebar); sk.Color=AC.PUR_STROKE; sk.Thickness=1; sk.Transparency=0.4
    AC.sideScroll=Instance.new("ScrollingFrame",AC.sidebar); AC.sideScroll.Size=UDim2.new(1,0,1,0); AC.sideScroll.BackgroundTransparency=1; AC.sideScroll.BorderSizePixel=0; AC.sideScroll.ScrollBarThickness=0; AC.sideScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; AC.sideScroll.CanvasSize=UDim2.new(0,0,0,0)
    local sNavLbl=Instance.new("TextLabel",AC.sideScroll); sNavLbl.Size=UDim2.new(1,-16,0,16); sNavLbl.Position=UDim2.new(0,12,0,12); sNavLbl.BackgroundTransparency=1; sNavLbl.Text="NAVIGATION"; sNavLbl.TextColor3=AC.TXT_LABEL; sNavLbl.TextSize=9; sNavLbl.Font=Enum.Font.GothamBold; sNavLbl.TextXAlignment=Enum.TextXAlignment.Left
    local sDiv=Instance.new("Frame",AC.sideScroll); sDiv.Size=UDim2.new(1,-16,0,1); sDiv.Position=UDim2.new(0,8,0,30); sDiv.BackgroundColor3=AC.PUR_STROKE; sDiv.BackgroundTransparency=0.4
    local sLL=Instance.new("UIListLayout",AC.sideScroll); sLL.FillDirection=Enum.FillDirection.Vertical; sLL.SortOrder=Enum.SortOrder.LayoutOrder; sLL.Padding=UDim.new(0,2)
    local sLP=Instance.new("UIPadding",AC.sideScroll); sLP.PaddingTop=UDim.new(0,38); sLP.PaddingLeft=UDim.new(0,8); sLP.PaddingRight=UDim.new(0,8)
    AC.mainPanel=Instance.new("Frame",body); AC.mainPanel.Size=UDim2.new(0,AC.MAIN_W,1,0); AC.mainPanel.Position=UDim2.new(0,AC.SIDE_W+6,0,0); AC.mainPanel.BackgroundColor3=AC.BG_PANEL; AC.mainPanel.ClipsDescendants=true; AC.mainPanel.ZIndex=3; Instance.new("UICorner",AC.mainPanel).CornerRadius=UDim.new(0,12); local mpk=Instance.new("UIStroke",AC.mainPanel); mpk.Color=AC.PUR_STROKE; mpk.Thickness=1; mpk.Transparency=0.4
    AC.pageContainer=Instance.new("Frame",AC.mainPanel); AC.pageContainer.Size=UDim2.new(1,0,1,0); AC.pageContainer.BackgroundTransparency=1; AC.pageContainer.ClipsDescendants=true
    AC.reopenBtn=Instance.new("TextButton",AC.screenGui)
    AC.reopenBtn.Size=UDim2.new(0,46,0,46)
    AC.reopenBtn.Position=UDim2.new(0,10,0.5,-23)  -- left-center, never off-screen
    AC.reopenBtn.BackgroundColor3=AC.BG_PANEL; AC.reopenBtn.Text=""; AC.reopenBtn.Visible=false; AC.reopenBtn.ZIndex=20
    Instance.new("UICorner",AC.reopenBtn).CornerRadius=UDim.new(1,0)
    local rbS=Instance.new("UIStroke",AC.reopenBtn); rbS.Color=AC.PUR_BRIGHT; rbS.Thickness=2
    AC.TS:Create(rbS,TweenInfo.new(1.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Color=AC.PUR_DARK,Transparency=0.3}):Play()
    local rl=AC.drawLogo(AC.reopenBtn,28,AC.PUR_BRIGHT); rl.Position=UDim2.new(0.5,-14,0.5,-14); rl.ZIndex=21
    -- Make reopen btn draggable so user can reposition it
    local rbDrag,rbDS,rbSP=false,nil,nil
    AC.reopenBtn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            rbDrag=true; rbDS=i.Position; rbSP=AC.reopenBtn.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then rbDrag=false end end)
        end
    end)
    AC.UIS.InputChanged:Connect(function(i)
        if rbDrag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-rbDS
            local vp=AC.camera.ViewportSize
            local nx=math.clamp(rbSP.X.Offset+d.X,0,vp.X-46)
            local ny=math.clamp(rbSP.Y.Offset+d.Y,0,vp.Y-46)
            AC.reopenBtn.Position=UDim2.new(0,nx,0,ny)
        end
    end)
    local dragging,dragStart,startPos
    AC.navbar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true; dragStart=i.Position; startPos=AC.wrapper.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end)
        end
    end)
    AC.UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-dragStart; AC.wrapper.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    -- FIX: guard with _tweening flag so rapid keypresses can't orphan the UI
    local _uiTweening=false
    AC.doMin=function()
        if not AC._uiOpen or _uiTweening then return end
        AC._uiOpen=false; _uiTweening=true
        pcall(function() AC.openSound:Play() end)
        AC.TS:Create(AC.wrapper,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)}):Play()
        task.delay(0.32,function()
            AC.wrapper.Visible=false
            AC.reopenBtn.Visible=true
            _uiTweening=false
        end)
    end
    AC.doOpen=function()
        if AC._uiOpen or _uiTweening then return end
        AC._uiOpen=true; _uiTweening=true
        AC.reopenBtn.Visible=false
        AC.wrapper.Visible=true
        AC.wrapper.Size=UDim2.new(0,0,0,0)
        AC.wrapper.Position=UDim2.new(0.5,0,0.5,0)
        pcall(function() AC.openSound:Play() end)
        AC.TS:Create(AC.wrapper,TweenInfo.new(0.42,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,AC.UI_W,0,AC.UI_H),Position=UDim2.new(0.5,-AC.UI_W/2,0.5,-AC.UI_H/2)}):Play()
        task.delay(0.44,function() _uiTweening=false end)
    end
    -- Safety net: if both wrapper and reopenBtn are invisible, restore reopenBtn
    task.spawn(function()
        while true do
            task.wait(3)
            pcall(function()
                if not AC.wrapper.Visible and not AC.reopenBtn.Visible and not _uiTweening then
                    AC.reopenBtn.Visible=true
                    AC._uiOpen=false
                end
            end)
        end
    end)
    AC.minBtn.MouseButton1Click:Connect(AC.doMin)
    AC.reopenBtn.MouseButton1Click:Connect(AC.doOpen)
    AC.UIS.InputBegan:Connect(function(i,gp)
        pcall(function()
            if gp then return end
            if i.UserInputType~=Enum.UserInputType.Keyboard then return end
            local kn=i.KeyCode.Name
            if not kn or kn=="" or kn=="Unknown" then return end
            if kn==(AC._toggleKey or "G") then
                if AC._uiOpen then AC.doMin() else AC.doOpen() end
            end
        end)
    end)
end

-- FPS/PING HUD
do
    local HUD_W=120; local ROW_H=26; local HUD_H=ROW_H*3+8
    local hud=Instance.new("Frame",AC.screenGui); hud.Size=UDim2.new(0,HUD_W,0,HUD_H); hud.Position=UDim2.new(0,10,0,10); hud.BackgroundColor3=Color3.fromRGB(8,8,10); hud.BackgroundTransparency=0.12; hud.ZIndex=300; hud.ClipsDescendants=true; Instance.new("UICorner",hud).CornerRadius=UDim.new(0,12)
    local hudStroke=Instance.new("UIStroke",hud); hudStroke.Color=AC.PUR_STROKE; hudStroke.Thickness=1.2; hudStroke.Transparency=0.15
    local acBar=Instance.new("Frame",hud); acBar.Size=UDim2.new(0,3,1,-8); acBar.Position=UDim2.new(0,4,0,4); acBar.BackgroundColor3=AC.PUR_BRIGHT; acBar.BorderSizePixel=0; Instance.new("UICorner",acBar).CornerRadius=UDim.new(1,0)
    AC.TS:Create(acBar,TweenInfo.new(1.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{BackgroundTransparency=0.5}):Play()
    local function makeRow(yOff,icon,label,iconColor,textColor)
        local row=Instance.new("Frame",hud); row.Size=UDim2.new(1,-10,0,ROW_H); row.Position=UDim2.new(0,10,0,4+yOff); row.BackgroundTransparency=1; row.ZIndex=301
        if yOff>0 then local div=Instance.new("Frame",hud); div.Size=UDim2.new(1,-14,0,1); div.Position=UDim2.new(0,10,0,4+yOff); div.BackgroundColor3=AC.PUR_STROKE; div.BackgroundTransparency=0.5 end
        local dot=Instance.new("Frame",row); dot.Size=UDim2.new(0,7,0,7); dot.Position=UDim2.new(0,0,0.5,-3); dot.BackgroundColor3=iconColor; dot.BorderSizePixel=0; Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
        local lbl=Instance.new("TextLabel",row); lbl.Size=UDim2.new(1,-12,1,0); lbl.Position=UDim2.new(0,12,0,0); lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=textColor; lbl.TextSize=11; lbl.Font=Enum.Font.GothamBold; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=302
        return lbl
    end
    local tagsLbl=makeRow(0,"Tags","Tags",AC.PUR_BRIGHT,AC.PUR_BRIGHT)
    local fpsLbl=makeRow(ROW_H,"FPS","FPS --",AC.GREEN_OK,AC.GREEN_OK)
    local pingLbl=makeRow(ROW_H*2,"PING","PING --",AC.PUR_GLOW,AC.PUR_GLOW)
    local tagsBtn=Instance.new("TextButton",hud); tagsBtn.Size=UDim2.new(1,0,0,ROW_H); tagsBtn.Position=UDim2.new(0,0,0,4); tagsBtn.BackgroundTransparency=1; tagsBtn.Text=""; tagsBtn.ZIndex=303
    tagsBtn.MouseButton1Click:Connect(function()
        AC.tagsVisible=not AC.tagsVisible
        AC.cfg.tagsVisible=AC.tagsVisible; AC.cfgSave()
        local clean={}
        for _,bb in ipairs(AC.allBillboards) do if bb and bb.Parent then bb.Enabled=AC.tagsVisible; clean[#clean+1]=bb end end
        AC.allBillboards=clean
        for _,p in ipairs(AC.Players:GetPlayers()) do if p.Character then local h=p.Character:FindFirstChild("Head"); if h then local bb2=h:FindFirstChild("AC_Billboard"); if bb2 then bb2.Enabled=AC.tagsVisible end end end end
        local onCol=AC.tagsVisible and AC.PUR_BRIGHT or AC.TXT_DIM
        tagsLbl.Text=AC.tagsVisible and "Tags  ON" or "Tags  OFF"; tagsLbl.TextColor3=onCol
        AC.toast("Tags "..(AC.tagsVisible and "visible" or "hidden"),onCol)
    end)
    tagsBtn.MouseEnter:Connect(function() AC.TS:Create(tagsBtn,TweenInfo.new(0.1),{BackgroundTransparency=0.85}):Play() end)
    tagsBtn.MouseLeave:Connect(function() AC.TS:Create(tagsBtn,TweenInfo.new(0.1),{BackgroundTransparency=1}):Play() end)
    local hudDrag,hudDS,hudSP=false,nil,nil
    hud.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then hudDrag=true; hudDS=i.Position; hudSP=hud.Position; i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then hudDrag=false end end) end end)
    AC.UIS.InputChanged:Connect(function(i) if hudDrag and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-hudDS; local nx=math.clamp(hudSP.X.Offset+d.X,0,AC.camera.ViewportSize.X-HUD_W); local ny=math.clamp(hudSP.Y.Offset+d.Y,0,AC.camera.ViewportSize.Y-HUD_H); hud.Position=UDim2.new(0,nx,0,ny) end end)

    -- FPS: rolling 20-frame window of individual frame times, updated every frame.
    -- This matches what AK shows - react instantly to drops rather than smoothing them away.
    local fpsWindow={}; local FPS_WINDOW=20
    local fpsUpdateTimer=0; local FPS_UPDATE_RATE=0.1  -- update display 10x/sec

    -- PING: try multiple sources in priority order every 0.5s
    -- Source 1: PlayerNetwork client ping (most accurate, executor-permitting)
    -- Source 2: Stats.Network "Data Ping" ServerStatsItem
    -- Source 3: Stats.Network "Incoming (KB/s)" as fallback indicator
    local pingUpdateTimer=0; local PING_UPDATE_RATE=0.5
    local lastPing=0

    local function getPing()
        -- Method 1: LocalPlayer network ping via Stats (most reliable)
        local ok1,v1=pcall(function()
            return math.floor(AC.Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        if ok1 and v1 and v1>0 and v1<2000 then return v1 end

        -- Method 2: Try "Incoming (KB/s)" ping field
        local ok2,v2=pcall(function()
            return math.floor(AC.Stats.Network.ServerStatsItem["Data Ping (Samples)"].Value)
        end)
        if ok2 and v2 and v2>0 and v2<2000 then return v2 end

        -- Method 3: workspace:GetServerTimeNow() round-trip estimate
        -- compare local os.clock with server time difference
        local ok3,v3=pcall(function()
            local t0=os.clock()
            local serverT=AC.WS:GetServerTimeNow()
            local t1=os.clock()
            -- round trip estimate = (t1-t0)*500 ms
            local rtt=math.floor((t1-t0)*500)
            return rtt
        end)
        if ok3 and v3 and v3>=0 and v3<2000 then return v3 end

        return nil
    end

    AC.RS.RenderStepped:Connect(function(dt)
        if __acStopped() then return end

        -- FPS: add this frame, trim window, compute from window
        fpsWindow[#fpsWindow+1]=dt
        if #fpsWindow>FPS_WINDOW then table.remove(fpsWindow,1) end

        fpsUpdateTimer=fpsUpdateTimer+dt
        if fpsUpdateTimer>=FPS_UPDATE_RATE and #fpsWindow>0 then
            fpsUpdateTimer=0
            -- Use median frame time from window to reject outlier spikes
            local sorted=table.clone(fpsWindow)
            table.sort(sorted)
            local medDt=sorted[math.ceil(#sorted/2)]
            local fps=medDt>0 and math.floor(1/medDt+0.5) or 0
            fpsLbl.Text="FPS  "..fps
            fpsLbl.TextColor3=fps>=55 and AC.GREEN_OK or fps>=30 and AC.ORANGE_W or AC.RED_ERR
        end

        pingUpdateTimer=pingUpdateTimer+dt
        if pingUpdateTimer>=PING_UPDATE_RATE then
            pingUpdateTimer=0
            local ping=getPing()
            if ping then
                lastPing=ping
                pingLbl.Text="PING  "..ping.."ms"
                pingLbl.TextColor3=ping<80 and AC.PUR_GLOW or ping<150 and AC.ORANGE_W or AC.RED_ERR
            elseif lastPing==0 then
                pingLbl.Text="PING  --"
                pingLbl.TextColor3=AC.TXT_DIM
            end
        end
    end)
end

-- BILLBOARD TAGS
do
    local MARKER="AC_Active"; local OWNER_ID=AC.player.UserId
    local TYPE_SPD=0.09; local HOLD=1.8; local DEL_SPD=0.04; local BLANK=0.35
    local function startTypewriter(tLbl,displayText)
        task.spawn(function()
            while tLbl and tLbl.Parent do
                tLbl.Text="|"
                for i=1,#displayText do if not(tLbl and tLbl.Parent) then return end; tLbl.Text=displayText:sub(1,i).."|"; task.wait(TYPE_SPD) end
                if not(tLbl and tLbl.Parent) then return end; tLbl.Text=displayText.."|"; task.wait(HOLD)
                for i=#displayText,0,-1 do if not(tLbl and tLbl.Parent) then return end; tLbl.Text=displayText:sub(1,i).."|"; task.wait(DEL_SPD) end
                if not(tLbl and tLbl.Parent) then return end; tLbl.Text="|"; task.wait(BLANK)
            end
        end)
    end
    local TAG_W,TAG_H=160,38
    local function attachTag(char,owner)
        local head=char:WaitForChild("Head",10); if not head then return end
        local ex=head:FindFirstChild("AC_Billboard"); if ex then ex:Destroy() end
        local isOwner=(owner and owner.UserId==OWNER_ID)
        local tagColor=isOwner and Color3.fromRGB(255,200,40) or AC.PUR_BRIGHT
        local bgColor=isOwner and Color3.fromRGB(28,18,0) or Color3.fromRGB(8,2,16)
        local titleText=isOwner and "AC OWNER" or "AUDIO USER"
        local titleColor=isOwner and Color3.fromRGB(255,215,60) or AC.TXT_BILLBOARD
        local gradCol0=isOwner and Color3.fromRGB(30,20,0) or Color3.fromRGB(15,4,28)
        local gradCol1=isOwner and Color3.fromRGB(12,8,0) or Color3.fromRGB(6,2,12)
        local bb=Instance.new("BillboardGui"); bb.Name="AC_Billboard"; bb.Size=UDim2.new(0,TAG_W,0,TAG_H); bb.StudsOffset=Vector3.new(0,2.8,0); bb.AlwaysOnTop=true; bb.ResetOnSpawn=false; bb.MaxDistance=0; bb.Adornee=head; bb.Enabled=AC.tagsVisible; bb.Parent=head
        table.insert(AC.allBillboards,bb)
        local pill=Instance.new("Frame",bb); pill.Size=UDim2.new(1,0,1,0); pill.BackgroundColor3=bgColor; pill.BackgroundTransparency=0.2; Instance.new("UICorner",pill).CornerRadius=UDim.new(0,10)
        local pStroke=Instance.new("UIStroke",pill); pStroke.Color=tagColor; pStroke.Thickness=2
        local logoFrame=AC.drawLogo(pill,18,tagColor); logoFrame.Position=UDim2.new(0,6,0.5,-9)
        local titleLbl=Instance.new("TextLabel",pill); titleLbl.Size=UDim2.new(1,-28,0,18); titleLbl.Position=UDim2.new(0,26,0,2); titleLbl.BackgroundTransparency=1; titleLbl.Text=titleText; titleLbl.TextColor3=titleColor; titleLbl.TextSize=13; titleLbl.Font=Enum.Font.GothamBold; titleLbl.TextXAlignment=Enum.TextXAlignment.Center; titleLbl.TextStrokeTransparency=0.6; titleLbl.TextStrokeColor3=isOwner and Color3.fromRGB(80,50,0) or AC.PUR_DARK
        local userLbl=Instance.new("TextLabel",pill); userLbl.Size=UDim2.new(1,-28,0,14); userLbl.Position=UDim2.new(0,26,0,20); userLbl.BackgroundTransparency=1; userLbl.Text="@"..(owner and owner.Name or "AC User"); userLbl.TextColor3=isOwner and Color3.fromRGB(255,200,80) or Color3.fromRGB(200,170,220); userLbl.TextSize=9; userLbl.Font=Enum.Font.Gotham; userLbl.TextXAlignment=Enum.TextXAlignment.Center; userLbl.TextTruncate=Enum.TextTruncate.AtEnd
        local grad=Instance.new("UIGradient",pill); grad.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,gradCol0),ColorSequenceKeypoint.new(1,gradCol1)}; grad.Rotation=135
        if isOwner then AC.TS:Create(pStroke,TweenInfo.new(1.1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Transparency=0.5}):Play() end
        startTypewriter(titleLbl,titleText)
        local click=Instance.new("TextButton",pill); click.Size=UDim2.new(1,0,1,0); click.BackgroundTransparency=1; click.Text=""
        click.MouseButton1Click:Connect(function()
            if owner and owner~=AC.player and owner.Character then
                local r=owner.Character:FindFirstChild("HumanoidRootPart"); local m=AC.player.Character and AC.player.Character:FindFirstChild("HumanoidRootPart")
                if r and m then m.CFrame=r.CFrame*CFrame.new(0,0,-3); AC.toast("TP'd to "..owner.Name) end
            end
        end)
    end
    local function notifyACUser(p)
        local color=Color3.fromRGB(255,200,0)
        local f=Instance.new("Frame",AC.toastContainer); f.Size=UDim2.new(0,280,0,0); f.BackgroundColor3=Color3.fromRGB(20,16,0); f.ClipsDescendants=true; Instance.new("UICorner",f).CornerRadius=UDim.new(0,8)
        local st=Instance.new("UIStroke",f); st.Color=color; st.Thickness=2
        local bar=Instance.new("Frame",f); bar.Size=UDim2.new(0,4,1,0); bar.BackgroundColor3=color; bar.BorderSizePixel=0
        local lbl=Instance.new("TextLabel",f); lbl.Size=UDim2.new(1,-18,1,0); lbl.Position=UDim2.new(0,14,0,0); lbl.BackgroundTransparency=1; lbl.Text="! AC USER: "..p.Name.."  ADMIN IN SERVER"; lbl.TextColor3=color; lbl.TextSize=12; lbl.Font=Enum.Font.GothamBold; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.TextWrapped=true
        AC.TS:Create(f,TweenInfo.new(0.2,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.new(0,280,0,48)}):Play()
        task.delay(6,function() if f and f.Parent then AC.TS:Create(f,TweenInfo.new(0.2),{Size=UDim2.new(0,280,0,0)}):Play(); task.delay(0.25,function() if f and f.Parent then f:Destroy() end end) end end)
    end
    local function checkACUser(p)
        if p==AC.player then return end
        task.spawn(function()
            local char=p.Character or p.CharacterAdded:Wait(); local head=char:WaitForChild("Head",10); if not head then return end
            if head:FindFirstChild(MARKER) then notifyACUser(p); return end
            local cn; cn=head.ChildAdded:Connect(function(c) if c.Name==MARKER then cn:Disconnect(); notifyACUser(p) end end)
            task.delay(5,function() pcall(function() cn:Disconnect() end) end)
        end)
    end
    for _,p in ipairs(AC.Players:GetPlayers()) do checkACUser(p) end
    AC.Players.PlayerAdded:Connect(checkACUser)
    local function plantMarker(char)
        local head=char:WaitForChild("Head",10); if not head then return end
        if not head:FindFirstChild(MARKER) then local m=Instance.new("BillboardGui"); m.Name=MARKER; m.Size=UDim2.new(0,0,0,0); m.Enabled=false; m.Parent=head end
        attachTag(char,AC.player)
    end
    if AC.player.Character then task.spawn(plantMarker,AC.player.Character) end
    AC.player.CharacterAdded:Connect(plantMarker)
    local function watchPlayer(p)
        if p==AC.player then return end
        local function onChar(char) task.spawn(function() local head=char:WaitForChild("Head",10); if not head then return end; attachTag(char,p) end) end
        if p.Character then onChar(p.Character) end
        p.CharacterAdded:Connect(onChar)
    end
    for _,p in ipairs(AC.Players:GetPlayers()) do watchPlayer(p) end
    AC.Players.PlayerAdded:Connect(watchPlayer)
    AC.Players.PlayerRemoving:Connect(function(p) if p.Character then local h=p.Character:FindFirstChild("Head"); if h then local bb=h:FindFirstChild("AC_Billboard"); if bb then bb:Destroy() end end end end)
end

-- HOME TAB
do
    local btn=AC.createTab("Home",1); local pg=AC.createPage(); AC.tabs["Home"].page=pg
    local wCard=AC.makeCard(pg,12,72,Color3.fromRGB(18,5,30)); wCard.Size=UDim2.new(1,-24,0,72)
    local wg=Instance.new("UIGradient",wCard); wg.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(40,8,65)),ColorSequenceKeypoint.new(1,Color3.fromRGB(10,2,18))}; wg.Rotation=135
    local wt=Instance.new("TextLabel",wCard); wt.Size=UDim2.new(1,-20,0,32); wt.Position=UDim2.new(0,14,0,8); wt.BackgroundTransparency=1; wt.Text="Welcome, "..AC.player.Name; wt.TextColor3=AC.TXT_WHITE; wt.TextSize=20; wt.Font=Enum.Font.GothamBold; wt.TextXAlignment=Enum.TextXAlignment.Left
    local ws=Instance.new("TextLabel",wCard); ws.Size=UDim2.new(1,-20,0,20); ws.Position=UDim2.new(0,14,0,44); ws.BackgroundTransparency=1; ws.Text="AC AudioCrafter v4.33  by MelodyCrafter"; ws.TextColor3=AC.PUR_MID; ws.TextSize=12; ws.Font=Enum.Font.Gotham; ws.TextXAlignment=Enum.TextXAlignment.Left
    local cW=math.floor((AC.MAIN_W-24-16)/3)
    local function ic(label,val,col,vc) local c=Instance.new("Frame",pg); c.Size=UDim2.new(0,cW,0,56); c.Position=UDim2.new(0,12+col*(cW+8),0,96); c.BackgroundColor3=AC.BG_CARD; Instance.new("UICorner",c).CornerRadius=UDim.new(0,8); local ll=Instance.new("TextLabel",c); ll.Size=UDim2.new(1,-10,0,16); ll.Position=UDim2.new(0,10,0,8); ll.BackgroundTransparency=1; ll.Text=label; ll.TextColor3=AC.TXT_DIM; ll.TextSize=10; ll.Font=Enum.Font.Gotham; ll.TextXAlignment=Enum.TextXAlignment.Left; local vl=Instance.new("TextLabel",c); vl.Size=UDim2.new(1,-10,0,24); vl.Position=UDim2.new(0,10,0,26); vl.BackgroundTransparency=1; vl.Text=val; vl.TextColor3=vc or AC.TXT_WHITE; vl.TextSize=14; vl.Font=Enum.Font.GothamBold; vl.TextXAlignment=Enum.TextXAlignment.Left end
    ic("Version","v4.33",0); ic("Status","* Active",1,AC.GREEN_OK); ic("Script",AC.executorName,2,AC.PUR_BRIGHT)
    AC.sectionLbl(pg,"CHANGELOG",164)
    local clOuter=Instance.new("Frame",pg); clOuter.Size=UDim2.new(1,-24,0,230); clOuter.Position=UDim2.new(0,12,0,182); clOuter.BackgroundColor3=AC.BG_CARD; clOuter.ClipsDescendants=true; Instance.new("UICorner",clOuter).CornerRadius=UDim.new(0,8); Instance.new("UIStroke",clOuter).Color=AC.PUR_STROKE
    local cl=Instance.new("ScrollingFrame",clOuter); cl.Size=UDim2.new(1,0,1,0); cl.BackgroundTransparency=1; cl.BorderSizePixel=0; cl.ScrollBarThickness=3; cl.ScrollBarImageColor3=AC.PUR_MID; cl.AutomaticCanvasSize=Enum.AutomaticSize.Y; cl.CanvasSize=UDim2.new(0,0,0,0)
    local clLL=Instance.new("UIListLayout",cl); clLL.Padding=UDim.new(0,2); clLL.SortOrder=Enum.SortOrder.LayoutOrder
    local clPP=Instance.new("UIPadding",cl); clPP.PaddingTop=UDim.new(0,6); clPP.PaddingLeft=UDim.new(0,10); clPP.PaddingRight=UDim.new(0,10); clPP.PaddingBottom=UDim.new(0,6)
    local clOrd=0
    local function cll(t,sz,c2,f) clOrd=clOrd+1; local l=Instance.new("TextLabel",cl); l.Size=UDim2.new(1,0,0,sz+6); l.BackgroundTransparency=1; l.Text=t; l.TextColor3=c2; l.TextSize=sz; l.Font=f or Enum.Font.Gotham; l.TextXAlignment=Enum.TextXAlignment.Left; l.TextWrapped=true; l.LayoutOrder=clOrd end
    cll("v4.33  Current",12,AC.PUR_GLOW,Enum.Font.GothamBold)
    cll("FIX: FacBang panel rendering fixed (ClipsDescendants + solid bg).",10,AC.TXT_MAIN)
    cll("CHANGE: Main UI narrowed from 820px to 720px (same height).",10,AC.TXT_MAIN)
    cll("CHANGE: Sidebar narrowed from 180px to 160px to match new width.",10,AC.TXT_MAIN)
    cll("v3.8",12,AC.PUR_MID,Enum.Font.GothamBold)
    cll("FIX: FacBang panel uses AC purple scheme, no more red/pink.",10,AC.TXT_MAIN)
    cll("FIX: Panel no longer glitches to top-left; position clamped on open.",10,AC.TXT_MAIN)
    cll("FIX: Thrust always stays in FRONT of face, never goes behind.",10,AC.TXT_MAIN)
    cll("FIX: Red info text removed, extra blank space trimmed from panel.",10,AC.TXT_MAIN)
    cll("FIX: Empty string KeyCode error fully resolved.",10,AC.TXT_MAIN)
    cll("v3.7",12,AC.PUR_MID,Enum.Font.GothamBold)
    cll("REMOVED: Highlight Usernames / ESP removed from Misc tab.",10,AC.TXT_MAIN)
    cll("MOVED: Infinite Baseplate moved to World tab, right below Shaders.",10,AC.TXT_MAIN)
    cll("ADDED: FacBang panel - keybind, thrust distance + speed sliders, toggle.",10,AC.TXT_MAIN)
    cll("FIX: All InputBegan handlers now check Keyboard type before KeyCode.",10,AC.TXT_MAIN)
    cll("FIX: '' not valid Enum.KeyCode errors fully resolved.",10,AC.TXT_MAIN)
    cll("v3.6.1",12,AC.PUR_MID,Enum.Font.GothamBold)
    cll("FIX: Open anim no longer shrinks sidebar/mainPanel (blank home page bug).",10,AC.TXT_MAIN)
    cll("FIX: Only wrapper animates - inner panels stay full size always (stutter fix).",10,AC.TXT_MAIN)
    cll("FIX: Misc tab do..end block closed. rS2->rS. _uiOpen set correctly.",10,AC.TXT_MAIN)
    cll("FIX: States slider duplicate InputBegan removed. UGC favs tab fixed.",10,AC.TXT_MAIN)
    cll("v3.1",12,AC.PUR_MID,Enum.Font.GothamBold)
    cll("RN panel: fetches ALL animations from Rootleak/Animations via GitHub API.",10,AC.TXT_MAIN)
    cll("Settings saved per-player using writefile (favs, binds, speeds persist).",10,AC.TXT_MAIN)
    cll("v3.0  Major Update",12,AC.PUR_MID,Enum.Font.GothamBold)
    cll("AC REANIMATION panel: All/Favs, star favs, per-emote speed 0.1-12.",10,AC.TXT_MAIN)
    cll("UGC Emotes panel: All/Favs/States, matching bottom bar, async row loading.",10,AC.TXT_MAIN)
    cll("v2.6~2.9  Tags, emotes, VC bypass, Rootleak API, dropdown fixes.",10,AC.TXT_DIM)
    cll("v1.0~2.5  Initial release through Anti-VC, spectate, ESP, FPS/PING HUD.",10,AC.TXT_DIM)
    btn.MouseButton1Click:Connect(function() AC.switchTab("Home") end)
end

-- PLAYER TAB
do
    local btn=AC.createTab("Player",2); local pg=AC.createPage(); AC.tabs["Player"].page=pg
    AC.sectionLbl(pg,"TARGET",10)
    local sc=Instance.new("Frame",pg); sc.Size=UDim2.new(1,-24,0,44); sc.Position=UDim2.new(0,12,0,28); sc.BackgroundColor3=AC.BG_CARD; sc.ClipsDescendants=false; Instance.new("UICorner",sc).CornerRadius=UDim.new(0,8); local scs=Instance.new("UIStroke",sc); scs.Color=AC.PUR_STROKE; scs.Thickness=1; scs.Transparency=0.4
    local sBox=Instance.new("TextBox",sc); sBox.Size=UDim2.new(1,-20,0,30); sBox.Position=UDim2.new(0,10,0.5,-15); sBox.BackgroundTransparency=1; sBox.PlaceholderText="Search or click a player..."; sBox.PlaceholderColor3=AC.TXT_DIM; sBox.Text=""; sBox.TextColor3=AC.TXT_MAIN; sBox.TextSize=13; sBox.Font=Enum.Font.Gotham; sBox.TextXAlignment=Enum.TextXAlignment.Left; sBox.ClearTextOnFocus=false
    local ddFrame=Instance.new("Frame",AC.screenGui); ddFrame.Size=UDim2.new(0,1,0,0); ddFrame.BackgroundColor3=Color3.fromRGB(16,16,16); ddFrame.ClipsDescendants=true; ddFrame.ZIndex=500; ddFrame.Visible=false; Instance.new("UICorner",ddFrame).CornerRadius=UDim.new(0,8); Instance.new("UIStroke",ddFrame).Color=AC.PUR_STROKE
    local ddScroll=Instance.new("ScrollingFrame",ddFrame); ddScroll.Size=UDim2.new(1,0,1,0); ddScroll.BackgroundTransparency=1; ddScroll.BorderSizePixel=0; ddScroll.ScrollBarThickness=3; ddScroll.ScrollBarImageColor3=AC.PUR_MID; ddScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; ddScroll.CanvasSize=UDim2.new(0,0,0,0); ddScroll.ZIndex=501
    Instance.new("UIListLayout",ddScroll).SortOrder=Enum.SortOrder.Name
    local ddSelecting=false
    local function rebuildDropdown(query)
        if ddSelecting then return end
        for _,c in ipairs(ddScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        local q=(query or ""):lower(); local count=0
        for _,p in ipairs(AC.Players:GetPlayers()) do
            if p~=AC.player then
                if q=="" or p.Name:lower():find(q,1,true) or p.DisplayName:lower():find(q,1,true) then
                    count=count+1
                    local row=Instance.new("TextButton",ddScroll); row.Size=UDim2.new(1,0,0,36); row.BackgroundColor3=Color3.fromRGB(22,22,22); row.Text=p.Name; row.Name=p.Name; row.ZIndex=502; row.TextColor3=AC.TXT_WHITE; row.TextSize=13; row.Font=Enum.Font.GothamBold; row.TextXAlignment=Enum.TextXAlignment.Left; row.AutoButtonColor=false
                    local _pad=Instance.new("UIPadding",row); _pad.PaddingLeft=UDim.new(0,10); Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)
                    local pCopy=p
                    row.MouseButton1Click:Connect(function() ddSelecting=true; AC.selectedTarget=pCopy; sBox.Text=pCopy.Name; ddFrame.Visible=false; sBox:ReleaseFocus(); AC.toast("Target: "..pCopy.Name,AC.PUR_BRIGHT); task.delay(0.3,function() ddSelecting=false end) end)
                    row.MouseEnter:Connect(function() AC.TS:Create(row,TweenInfo.new(0.1),{BackgroundColor3=AC.PUR_DARK}):Play() end)
                    row.MouseLeave:Connect(function() AC.TS:Create(row,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(22,22,22)}):Play() end)
                end
            end
        end
        if count==0 then ddFrame.Visible=false; return end
        local ddH=math.min(count*38+8,180); local ap=sc.AbsolutePosition; local as=sc.AbsoluteSize
        ddFrame.Position=UDim2.new(0,ap.X,0,ap.Y+as.Y+2); ddFrame.Size=UDim2.new(0,as.X,0,ddH); ddFrame.Visible=true
    end
    sBox:GetPropertyChangedSignal("Text"):Connect(function() if not ddSelecting then if sBox.Text=="" then AC.selectedTarget=nil end; rebuildDropdown(sBox.Text) end end)
    sBox.Focused:Connect(function() if not ddSelecting then rebuildDropdown(sBox.Text) end end)
    sBox.FocusLost:Connect(function() task.wait(0.18); if not ddSelecting then ddFrame.Visible=false end end)
    AC.Players.PlayerRemoving:Connect(function(p) if AC.selectedTarget==p then AC.selectedTarget=nil; sBox.Text="" end end)
    -- Close dropdown when clicking anywhere outside it
    AC.UIS.InputBegan:Connect(function(i)
        pcall(function()
            if i.UserInputType==Enum.UserInputType.MouseButton1 and ddFrame.Visible then
                task.wait(0.05); if not ddSelecting then ddFrame.Visible=false end
            end
        end)
    end)
    AC.sectionLbl(pg,"ACTIONS",80)
    local S=98
    local vBtn=AC.halfBtn(pg,"View Target",0,0,S); local tBtn=AC.halfBtn(pg,"Teleport To",1,0,S)
    local siBtn=AC.halfBtn(pg,"Sit on Head",0,1,S); local baBtn=AC.halfBtn(pg,"Back-to-Back",1,1,S)
    local clBtn=AC.halfBtn(pg,"Clear Target",0,2,S)
    local PAD2,GAP2=12,6; local bW2=(AC.MAIN_W-PAD2*2-GAP2)/2; local bH2=42
    local kbFrame=Instance.new("Frame",pg); kbFrame.Size=UDim2.new(0,bW2,0,bH2); kbFrame.Position=UDim2.new(0,PAD2+1*(bW2+GAP2),0,S+2*(bH2+6)); kbFrame.BackgroundColor3=AC.BG_CARD; Instance.new("UICorner",kbFrame).CornerRadius=UDim.new(0,8)
    local kbStr=Instance.new("UIStroke",kbFrame); kbStr.Color=AC.PUR_STROKE; kbStr.Thickness=1; kbStr.Transparency=0.4
    local kbDot=Instance.new("Frame",kbFrame); kbDot.Size=UDim2.new(0,7,0,7); kbDot.Position=UDim2.new(0,12,0.5,-3); kbDot.BackgroundColor3=AC.PUR_BRIGHT; Instance.new("UICorner",kbDot).CornerRadius=UDim.new(1,0)
    local kbTopLbl=Instance.new("TextLabel",kbFrame); kbTopLbl.Size=UDim2.new(1,-28,0,14); kbTopLbl.Position=UDim2.new(0,26,0,3); kbTopLbl.BackgroundTransparency=1; kbTopLbl.Text="Toggle UI Key"; kbTopLbl.TextColor3=AC.TXT_DIM; kbTopLbl.TextSize=9; kbTopLbl.Font=Enum.Font.Gotham; kbTopLbl.TextXAlignment=Enum.TextXAlignment.Left
    local kbValLbl=Instance.new("TextLabel",kbFrame); kbValLbl.Size=UDim2.new(1,-28,0,16); kbValLbl.Position=UDim2.new(0,26,0,17); kbValLbl.BackgroundTransparency=1; kbValLbl.Text="[G]"; kbValLbl.TextColor3=AC.PUR_GLOW; kbValLbl.TextSize=12; kbValLbl.Font=Enum.Font.GothamBold; kbValLbl.TextXAlignment=Enum.TextXAlignment.Left
    local kbBtn=Instance.new("TextButton",kbFrame); kbBtn.Size=UDim2.new(1,0,1,0); kbBtn.BackgroundTransparency=1; kbBtn.Text=""; kbBtn.ZIndex=5
    kbBtn.MouseEnter:Connect(function() AC.TS:Create(kbFrame,TweenInfo.new(0.15),{BackgroundColor3=AC.PUR_MID}):Play() end)
    kbBtn.MouseLeave:Connect(function() AC.TS:Create(kbFrame,TweenInfo.new(0.15),{BackgroundColor3=AC.BG_CARD}):Play() end)
    local _kbListening=false; local _kbConn=nil
    -- Restore toggle key from unified config
    if AC.cfg.toggleKey and AC.cfg.toggleKey~="G" then
        AC._toggleKey=AC.cfg.toggleKey; kbValLbl.Text="["..AC.cfg.toggleKey.."]"
    end
    if not AC._toggleKey then AC._toggleKey="G" end
    kbBtn.MouseButton1Click:Connect(function()
        if _kbListening then _kbListening=false; if _kbConn then _kbConn:Disconnect(); _kbConn=nil end; kbValLbl.Text="["..AC._toggleKey.."]"; kbValLbl.TextColor3=AC.PUR_GLOW; kbTopLbl.Text="Toggle UI Key"; kbStr.Color=AC.PUR_STROKE; return end
        _kbListening=true; kbValLbl.Text="..."; kbValLbl.TextColor3=AC.ORANGE_W; kbTopLbl.Text="Press any key"; kbStr.Color=AC.PUR_BRIGHT
        _kbConn=AC.UIS.InputBegan:Connect(function(inp,gp)
            if gp or inp.UserInputType~=Enum.UserInputType.Keyboard then return end
            local ok,kn=pcall(function() return inp.KeyCode.Name end); if not ok or not kn or kn=="Unknown" then return end
            if kn=="Escape" then _kbListening=false; if _kbConn then _kbConn:Disconnect(); _kbConn=nil end; kbValLbl.Text="["..AC._toggleKey.."]"; kbValLbl.TextColor3=AC.PUR_GLOW; kbTopLbl.Text="Toggle UI Key"; kbStr.Color=AC.PUR_STROKE; return end
            AC._toggleKey=kn
            kbValLbl.Text="["..kn.."]"; kbValLbl.TextColor3=AC.GREEN_OK
            kbTopLbl.Text="Toggle UI Key"; kbStr.Color=AC.PUR_STROKE
            _kbListening=false; if _kbConn then _kbConn:Disconnect(); _kbConn=nil end
            AC.cfg.toggleKey=kn; AC.cfgSave()
            AC.toast("Toggle key set to ["..kn.."]",AC.PUR_BRIGHT); task.delay(1.2,function() kbValLbl.TextColor3=AC.PUR_GLOW end)
        end)
    end)
    AC.sitBtn=siBtn; AC.backBtn=baBtn; AC.sBox=sBox
    vBtn.MouseButton1Click:Connect(function() if AC.selectedTarget then AC.startViewing(AC.selectedTarget); AC.toast("Viewing "..AC.selectedTarget.Name) else AC.toast("No target",AC.RED_ERR) end end)
    tBtn.MouseButton1Click:Connect(function() if AC.selectedTarget and AC.selectedTarget.Character then local r=AC.selectedTarget.Character:FindFirstChild("HumanoidRootPart"); local m=AC.player.Character and AC.player.Character:FindFirstChild("HumanoidRootPart"); if r and m then m.CFrame=r.CFrame*CFrame.new(0,0,-3); AC.toast("TP'd to "..AC.selectedTarget.Name) end else AC.toast("No target",AC.RED_ERR) end end)
    siBtn.MouseButton1Click:Connect(function()
        if AC.onHead then AC.onHead=false; if AC.headConn then AC.headConn:Disconnect(); AC.headConn=nil end; local h2=AC.player.Character and AC.player.Character:FindFirstChildOfClass("Humanoid"); if h2 then h2.Sit=false end; siBtn.Text="Sit on Head"; AC.toast("Off head",AC.ORANGE_W); return end
        if not AC.selectedTarget or not AC.selectedTarget.Character then AC.toast("No target",AC.RED_ERR); return end
        AC.onHead=true; siBtn.Text="Get Off"
        AC.headConn=AC.RS.Heartbeat:Connect(function()
            if not AC.onHead then return end
            local mc=AC.player.Character; local mr=mc and mc:FindFirstChild("HumanoidRootPart"); local mh=mc and mc:FindFirstChildOfClass("Humanoid"); local th=AC.selectedTarget.Character and AC.selectedTarget.Character:FindFirstChild("Head")
            if mr and th then if mh then mh.Sit=true end; mr.CFrame=th.CFrame*CFrame.new(0,th.Size.Y+0.8,0) end
        end)
    end)
    baBtn.MouseButton1Click:Connect(function()
        if AC.inBp then
            AC.inBp=false; if AC.bpConn then AC.bpConn:Disconnect(); AC.bpConn=nil end
            local mh=AC.player.Character and AC.player.Character:FindFirstChildOfClass("Humanoid")
            if mh then mh.PlatformStand=false end
            baBtn.Text="Back-to-Back"; AC.toast("Back-to-Back OFF",AC.ORANGE_W); return
        end
        if not AC.selectedTarget or not AC.selectedTarget.Character then AC.toast("No target",AC.RED_ERR); return end
        AC.inBp=true; baBtn.Text="Exit B2B"
        AC.bpConn=AC.RS.Heartbeat:Connect(function()
            if not AC.inBp then return end
            local mr=AC.player.Character and AC.player.Character:FindFirstChild("HumanoidRootPart")
            local mh2=AC.player.Character and AC.player.Character:FindFirstChildOfClass("Humanoid")
            local tr=AC.selectedTarget.Character and AC.selectedTarget.Character:FindFirstChild("HumanoidRootPart")
            if mr and tr then
                if mh2 then mh2.PlatformStand=true end
                local behindPos=tr.CFrame*CFrame.new(0,0.5,1.5)
                mr.CFrame=behindPos*CFrame.Angles(0,math.pi,0)
            end
        end)
    end)
    clBtn.MouseButton1Click:Connect(function() AC.stopViewing(); AC.onHead=false; AC.inBp=false; AC.selectedTarget=nil; sBox.Text=""; siBtn.Text="Sit on Head"; baBtn.Text="Back-to-Back"; AC.toast("Target cleared") end)
    local INFO_Y=258; AC.sectionLbl(pg,"PLAYER INFO",INFO_Y)
    local infoCard=AC.makeCard(pg,INFO_Y+18,AC.BG_CARD); infoCard.Size=UDim2.new(1,-24,0,120)
    Instance.new("UIGradient",infoCard).Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(0,12,0)),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,6,0))}
    local accentBar=Instance.new("Frame",infoCard); accentBar.Size=UDim2.new(0,3,1,-8); accentBar.Position=UDim2.new(0,6,0,4); accentBar.BackgroundColor3=Color3.fromRGB(0,255,80); accentBar.BorderSizePixel=0; Instance.new("UICorner",accentBar).CornerRadius=UDim.new(1,0)
    local infoLbl=Instance.new("TextLabel",infoCard); infoLbl.Size=UDim2.new(1,-26,1,-8); infoLbl.Position=UDim2.new(0,18,0,4); infoLbl.BackgroundTransparency=1; infoLbl.Text="> SELECT A TARGET"; infoLbl.TextColor3=Color3.fromRGB(80,255,80); infoLbl.TextSize=13; infoLbl.Font=Enum.Font.Code; infoLbl.TextXAlignment=Enum.TextXAlignment.Left; infoLbl.TextWrapped=true; infoLbl.RichText=true
    local function updatePlayerInfo(p)
        if not p then infoLbl.Text="> SELECT A TARGET"; infoLbl.TextColor3=Color3.fromRGB(60,160,60); return end
        local acctAge=p.AccountAge; local years=math.floor(acctAge/365); local months=math.floor((acctAge%365)/30); local days2=acctAge%30
        local ageStr=(years>0 and years.."y " or "")..(months>0 and months.."mo " or "")..days2.."d"
        local teamStr="None"; pcall(function() if p.Team then teamStr=p.Team.Name end end)
        infoLbl.Text="> NAME    : "..p.Name.."\n> DISPLAY : "..p.DisplayName.."\n> USER ID : "..tostring(p.UserId).."\n> AGE     : "..ageStr.." ("..acctAge.." days)\n> CHAR    : "..(p.Character and "LOADED" or "NOT LOADED").."  TEAM: "..teamStr
        infoLbl.TextColor3=Color3.fromRGB(0,255,80)
    end
    local _lastTarget=nil
    AC.RS.Heartbeat:Connect(function() if AC.selectedTarget~=_lastTarget then _lastTarget=AC.selectedTarget; updatePlayerInfo(AC.selectedTarget) end end)
    btn.MouseButton1Click:Connect(function() AC.switchTab("Player") end)
end

-- MOVEMENT TAB
do
    local btn=AC.createTab("Movement",3); local pg=AC.createPage(); AC.tabs["Movement"].page=pg
    AC.sectionLbl(pg,"LOCOMOTION",10)
    local _,getSpd,onSpd=AC.makeSlider(pg,"Walk Speed",28,16,200,AC.cfg.walkSpeed,"")
    onSpd(AC.cfgSlider("walkSpeed",function(v) local h=AC.player.Character and AC.player.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed=v end end))
    local _,getJmp,onJmp=AC.makeSlider(pg,"Jump Power",90,7,300,AC.cfg.jumpPower,"")
    onJmp(AC.cfgSlider("jumpPower",function(v) local h=AC.player.Character and AC.player.Character:FindFirstChildOfClass("Humanoid"); if h then h.JumpPower=v end end))
    AC.sectionLbl(pg,"ABILITIES",154)
    local _,_,onIJ=AC.makeToggle(pg,"Infinite Jump",172,AC.cfg.infJump)
    onIJ(AC.cfgToggle("infJump",function(v) if v then AC.ijConn=AC.UIS.JumpRequest:Connect(function() local h=AC.player.Character and AC.player.Character:FindFirstChildOfClass("Humanoid"); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end) else if AC.ijConn then AC.ijConn:Disconnect(); AC.ijConn=nil end end end))
    local _,_,onNC=AC.makeToggle(pg,"Noclip",218,AC.cfg.noclip)
    onNC(AC.cfgToggle("noclip",function(v)
        if v then AC.noclipConn=AC.RS.Stepped:Connect(function() local char=AC.player.Character; if not char then return end; for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end)
        else if AC.noclipConn then AC.noclipConn:Disconnect(); AC.noclipConn=nil end; if AC.player.Character then for _,p in ipairs(AC.player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end end
    end))
    local _,_,onFly=AC.makeToggle(pg,"Fly  (WASD + Q/E)",264,false)
    onFly(function(v)
        AC.flyActive=v; local char=AC.player.Character; if not char then return end
        local root=char:FindFirstChild("HumanoidRootPart"); local hum=char:FindFirstChildOfClass("Humanoid")
        if v then
            if hum then hum.PlatformStand=true end
            local att0=Instance.new("Attachment",root); AC.flyBV=Instance.new("LinearVelocity"); AC.flyBV.Attachment0=att0; AC.flyBV.VelocityConstraintMode=Enum.VelocityConstraintMode.Vector; AC.flyBV.MaxForce=1e5; AC.flyBV.RelativeTo=Enum.ActuatorRelativeTo.World; AC.flyBV.VectorVelocity=Vector3.zero; AC.flyBV.Parent=root
            AC.flyBG=Instance.new("AlignOrientation"); AC.flyBG.Attachment0=att0; AC.flyBG.Mode=Enum.OrientationAlignmentMode.OneAttachment; AC.flyBG.MaxTorque=1e5; AC.flyBG.MaxAngularVelocity=math.huge; AC.flyBG.Responsiveness=50; AC.flyBG.Parent=root; AC._flyAtt=att0
            AC.flyConn=AC.RS.RenderStepped:Connect(function() if not AC.flyActive then return end; local cf=AC.camera.CFrame; local dir=Vector3.zero; if AC.UIS:IsKeyDown(Enum.KeyCode.W) then dir=dir+cf.LookVector end; if AC.UIS:IsKeyDown(Enum.KeyCode.S) then dir=dir-cf.LookVector end; if AC.UIS:IsKeyDown(Enum.KeyCode.A) then dir=dir-cf.RightVector end; if AC.UIS:IsKeyDown(Enum.KeyCode.D) then dir=dir+cf.RightVector end; if AC.UIS:IsKeyDown(Enum.KeyCode.E) then dir=dir+Vector3.new(0,1,0) end; if AC.UIS:IsKeyDown(Enum.KeyCode.Q) then dir=dir-Vector3.new(0,1,0) end; if dir.Magnitude>0 then dir=dir.Unit end; AC.flyBV.VectorVelocity=dir*60; AC.flyBG.CFrame=cf end)
            AC.toast("Fly ON")
        else
            if AC.flyConn then AC.flyConn:Disconnect(); AC.flyConn=nil end; if AC.flyBV then AC.flyBV:Destroy(); AC.flyBV=nil end; if AC.flyBG then AC.flyBG:Destroy(); AC.flyBG=nil end; if AC._flyAtt then AC._flyAtt:Destroy(); AC._flyAtt=nil end
            if hum then hum.PlatformStand=false end; AC.toast("Fly OFF",AC.ORANGE_W)
        end
    end)
    btn.MouseButton1Click:Connect(function() AC.switchTab("Movement") end)
end

-- WORLD TAB
do
    local btn=AC.createTab("World",4); local pg=AC.createPage(); AC.tabs["World"].page=pg
    AC.sectionLbl(pg,"ENVIRONMENT",10)
    local _,_,onFB=AC.makeToggle(pg,"Fullbright",28,AC.cfg.fullbright)
    onFB(AC.cfgToggle("fullbright",function(v) AC.Lighting.Brightness=v and 2 or 1; AC.Lighting.GlobalShadows=not v; AC.Lighting.Ambient=v and Color3.new(1,1,1) or Color3.fromRGB(127,127,127); AC.Lighting.OutdoorAmbient=v and Color3.new(1,1,1) or Color3.fromRGB(127,127,127) end))
    local _,_,onTm=AC.makeSlider(pg,"Time of Day",74,0,24,AC.cfg.timeOfDay,"h")
    onTm(AC.cfgSlider("timeOfDay",function(v) AC.Lighting.ClockTime=v end))
    local _,_,onGv=AC.makeSlider(pg,"Gravity",136,0,200,AC.cfg.gravity,"")
    onGv(AC.cfgSlider("gravity",function(v) AC.WS.Gravity=v end))
    AC.sectionLbl(pg,"POST PROCESSING",200)
    local _,_,onSh=AC.makeToggle(pg,"Shaders (PShade Ultimate)",218,false); onSh(function(v) if v then task.spawn(function() pcall(function() safeRun("PSHADE") end) end); AC.toast("Shaders ON") else AC.toast("Rejoin to disable",AC.ORANGE_W) end end)
    local _,_,onBP=AC.makeToggle(pg,"Infinite Baseplate",264,false)
    onBP(function(v)
        if v then
            local function findFloor()
                local names={"Baseplate","Base","Floor","Ground","Map","Terrain",
                              "baseplate","base","floor","ground","map"}
                for _,n in ipairs(names) do
                    local p=AC.WS:FindFirstChild(n,true)
                    if p and p:IsA("BasePart") and p.Size.X>50 then
                        return p, p.Position.Y+(p.Size.Y/2)
                    end
                end
                local bestPart=nil; local bestArea=0
                for _,obj in ipairs(AC.WS:GetDescendants()) do
                    if obj:IsA("BasePart") and obj.Anchored and obj.Size.Y<=8 then
                        local area=obj.Size.X*obj.Size.Z
                        if area>bestArea then bestArea=area; bestPart=obj end
                    end
                end
                if bestPart then return bestPart, bestPart.Position.Y+(bestPart.Size.Y/2) end
                local params=RaycastParams.new()
                params.FilterType=Enum.RaycastFilterType.Exclude
                if AC.player.Character then params.FilterDescendantsInstances={AC.player.Character} end
                local hits={}
                for _,pt in ipairs({{0,0},{200,0},{-200,0},{0,200},{0,-200}}) do
                    local res=AC.WS:Raycast(Vector3.new(pt[1],500,pt[2]),Vector3.new(0,-700,0),params)
                    if res then hits[#hits+1]=res.Position.Y end
                end
                if #hits>0 then table.sort(hits); return nil, hits[math.ceil(#hits/2)] end
                local root=AC.player.Character and AC.player.Character:FindFirstChild("HumanoidRootPart")
                return nil, root and root.Position.Y-3 or 0
            end

            -- Clean up old tiles
            for _,p in ipairs(AC.WS:GetChildren()) do
                if p.Name=="AC_InfiniteBaseplate" then pcall(function() p:Destroy() end) end
            end

            local _, floorY = findFloor()

            -- Roblox max part size = 2048 studs
            -- Tile a 41x41 grid = 82,000 x 82,000 studs total (~50 miles each direction)
            local TILE=2048
            local GRID=21  -- 21x21 = 441 tiles, 42,000 studs each direction, no lag
            local HALF=math.floor(GRID/2)
            local tileY=floorY-0.5
            local totalTiles=GRID*GRID
            local built=0

            -- Use a folder to keep workspace clean
            local folder=Instance.new("Folder",AC.WS); folder.Name="AC_InfiniteBaseplate"

            task.spawn(function()
                for gx=-HALF,HALF do
                    for gz=-HALF,HALF do
                        local bp=Instance.new("Part")
                        bp.Name="tile"
                        bp.Size=Vector3.new(TILE,1,TILE)
                        bp.CFrame=CFrame.new(gx*TILE, tileY, gz*TILE)
                        bp.Anchored=true
                        bp.CanCollide=true
                        bp.CastShadow=false
                        bp.Locked=true
                        bp.Material=Enum.Material.SmoothPlastic
                        bp.Transparency=0.92
                        bp.TopSurface=Enum.SurfaceType.Smooth
                        bp.BottomSurface=Enum.SurfaceType.Smooth
                        bp.Parent=folder
                        built=built+1
                        if built%50==0 then task.wait() end
                    end
                end
                AC.toast("Baseplate ON ("..totalTiles.." tiles, ~42k studs)",AC.PUR_BRIGHT)
            end)
            AC.baseplateRef=folder
            AC.toast("Building baseplate...",AC.ORANGE_W)
        else
            if AC.baseplateRef then
                pcall(function() AC.baseplateRef:Destroy() end)
                AC.baseplateRef=nil
            end
            for _,p in ipairs(AC.WS:GetChildren()) do
                if p.Name=="AC_InfiniteBaseplate" then pcall(function() p:Destroy() end) end
            end
            AC.toast("Baseplate OFF",AC.ORANGE_W)
        end
    end)
    local _,_,onFU=AC.makeToggle(pg,"FPS Unlocker + GPU Boost",334,AC.cfg.fpsUnlock)
    onFU(AC.cfgToggle("fpsUnlock",function(v)
        if v then
            -- Remove executor FPS cap first
            pcall(function() setfpscap(0) end)
            -- Only touch things that actually reduce GPU cost without causing re-renders:
            -- 1. Kill shadows - biggest single GPU saving in Roblox
            pcall(function() AC.Lighting.GlobalShadows=false end)
            -- 2. Disable post-processing effects (bloom, blur, color correction etc.)
            pcall(function()
                for _,e in ipairs(AC.Lighting:GetChildren()) do
                    if e:IsA("PostEffect") then
                        pcall(function() e.Enabled=false end)
                    end
                end
            end)
            -- 3. Remove sky (saves skybox render pass)
            pcall(function()
                for _,e in ipairs(AC.Lighting:GetChildren()) do
                    if e:IsA("Sky") then pcall(function() e.Enabled=false end) end
                end
            end)
            -- NOTE: Do NOT touch QualityLevel, particles, streaming or scene graph --
            -- those trigger full re-renders and spike GPU usage instead of reducing it
            AC.toast("FPS Boost ON",AC.GREEN_OK)
        else
            pcall(function() setfpscap(60) end)
            pcall(function() AC.Lighting.GlobalShadows=true end)
            pcall(function()
                for _,e in ipairs(AC.Lighting:GetChildren()) do
                    if e:IsA("PostEffect") or e:IsA("Sky") then
                        pcall(function() e.Enabled=true end)
                    end
                end
            end)
            AC.toast("FPS Boost OFF - restored",AC.ORANGE_W)
        end
    end))
    local _,_,onAFK=AC.makeToggle(pg,"Anti-AFK",380,AC.cfg.antiAfk)
    onAFK(AC.cfgToggle("antiAfk",function(v) if v then local vu=game:GetService("VirtualUser"); AC.afkThread=task.spawn(function() while true do pcall(function() vu:Button2Down(Vector2.new(0,0),CFrame.new()); task.wait(0.1); vu:Button2Up(Vector2.new(0,0),CFrame.new()) end); task.wait(55) end end) else if AC.afkThread then task.cancel(AC.afkThread); AC.afkThread=nil end end end))
    btn.MouseButton1Click:Connect(function() AC.switchTab("World") end)
end

-- EMOTES TAB
do
    local btn=AC.createTab("Emotes",5); local pg=AC.createPage(); AC.tabs["Emotes"].page=pg
    local rnAPI=nil; local rnLoading=false; local rnActive=false
    local function ensureAPI(cb)
        if rnAPI then cb(rnAPI); return end
        if rnLoading then AC.toast("Still loading...",AC.ORANGE_W); return end
        rnLoading=true; AC.toast("Loading Reanimation API...",AC.ORANGE_W)
        task.spawn(function()
            local ok,result=pcall(function() return loadstring(game:HttpGet(_URLS.REANIMATION))() end)
            rnLoading=false
            if ok and result then rnAPI=result; AC.rnAPI=result; AC.toast("Reanimation ready!",AC.GREEN_OK); cb(rnAPI)
            else AC.toast("API load failed",AC.RED_ERR) end
        end)
    end
    local _uid=tostring(AC.player.UserId); local _saveDir="BLEED/".._uid
    local function readData(key,fallback) local ok,r=pcall(function() if not isfile then return nil end; local fp=_saveDir.."/"..key; if isfile(fp) then return AC.Http:JSONDecode(readfile(fp)) end; return nil end); return (ok and r) or fallback end
    local function writeData(key,data) pcall(function() if not writefile then return end; pcall(function() if not isfolder("BLEED") then makefolder("BLEED") end end); pcall(function() if not isfolder(_saveDir) then makefolder(_saveDir) end end); writefile(_saveDir.."/"..key,AC.Http:JSONEncode(data)) end) end
    local RN_ANIMS={}
    local RN_BASE_URL="https://raw.githubusercontent.com/Rootleak/Animations/main/"
    local RN_API_URL="https://api.github.com/repos/Rootleak/Animations/contents/"
    local function fetchRnAnimList(cb)
        task.spawn(function()
            local ok,res=pcall(function() return game:HttpGet(RN_API_URL) end)
            if ok and res and res~="" and res:sub(1,1)=="[" then
                local pOk,parsed=pcall(function() return AC.Http:JSONDecode(res) end)
                if pOk and parsed and type(parsed)=="table" then
                    local list={}
                    for _,entry in ipairs(parsed) do
                        if type(entry)=="table" and type(entry.name)=="string" and entry.name:sub(-4)==".lua" and entry.type=="file" then
                            local name=entry.name:sub(1,-5)
                            local encoded=entry.name:gsub("%%","%%25"):gsub(" ","%%20"):gsub("'","%%27"):gsub("%(","%%28"):gsub("%)","%%29"):gsub("!","%%21"):gsub("#","%%23")
                            list[#list+1]={name,RN_BASE_URL..encoded}
                        end
                    end
                    if #list>0 then RN_ANIMS=list; cb(list); return end
                end
            end
            RN_ANIMS={{"7 Rings Dance","https://raw.githubusercontent.com/Rootleak/Animations/main/7%20Rings%20Dance%2Elua"},{"Backflip","https://raw.githubusercontent.com/Rootleak/Animations/main/Backflip%2Elua"},{"Carlton","https://raw.githubusercontent.com/Rootleak/Animations/main/Carlton%2Elua"},{"Chicken Dance","https://raw.githubusercontent.com/Rootleak/Animations/main/Chicken%20Dance%2Elua"},{"Dab","https://raw.githubusercontent.com/Rootleak/Animations/main/Dab%2Elua"},{"Electro Shuffle","https://raw.githubusercontent.com/Rootleak/Animations/main/Electro%20Shuffle%2Elua"},{"Floss","https://raw.githubusercontent.com/Rootleak/Animations/main/Floss%2Elua"},{"Gangnam Style","https://raw.githubusercontent.com/Rootleak/Animations/main/Gangnam%20Style%2Elua"},{"Griddy","https://raw.githubusercontent.com/Rootleak/Animations/main/Griddy%2Elua"},{"Headbang","https://raw.githubusercontent.com/Rootleak/Animations/main/Headbang%2Elua"},{"L Dance","https://raw.githubusercontent.com/Rootleak/Animations/main/L%20Dance%2Elua"},{"Moon Walk","https://raw.githubusercontent.com/Rootleak/Animations/main/Moon%20Walk%2Elua"},{"Orange Justice","https://raw.githubusercontent.com/Rootleak/Animations/main/Orange%20Justice%2Elua"},{"Robot","https://raw.githubusercontent.com/Rootleak/Animations/main/Robot%2Elua"},{"Running Man","https://raw.githubusercontent.com/Rootleak/Animations/main/Running%20Man%2Elua"},{"Shuffle","https://raw.githubusercontent.com/Rootleak/Animations/main/Shuffle%2Elua"},{"Take The L","https://raw.githubusercontent.com/Rootleak/Animations/main/Take%20The%20L%2Elua"},{"Thriller","https://raw.githubusercontent.com/Rootleak/Animations/main/Thriller%2Elua"},{"Wave","https://raw.githubusercontent.com/Rootleak/Animations/main/Wave%2Elua"},{"Wiggle","https://raw.githubusercontent.com/Rootleak/Animations/main/Wiggle%2Elua"}}
            cb(RN_ANIMS)
        end)
    end
    -- RN PANEL
    local RN_W,RN_H=340,520
    local rnPanel=Instance.new("Frame",AC.screenGui); rnPanel.Size=UDim2.new(0,RN_W,0,RN_H); rnPanel.Position=UDim2.new(0, math.floor(AC.camera.ViewportSize.X/2)-170, 0, math.floor(AC.camera.ViewportSize.Y/2)-260); rnPanel.BackgroundColor3=Color3.fromRGB(12,12,14); rnPanel.BackgroundTransparency=0.18; rnPanel.ZIndex=70; rnPanel.Visible=false; rnPanel.ClipsDescendants=true; Instance.new("UICorner",rnPanel).CornerRadius=UDim.new(0,10); Instance.new("UIStroke",rnPanel).Color=AC.PUR_STROKE
    local rnHdr=Instance.new("Frame",rnPanel); rnHdr.Size=UDim2.new(1,0,0,40); rnHdr.BackgroundColor3=Color3.fromRGB(8,8,10); rnHdr.BackgroundTransparency=0.2; rnHdr.ZIndex=71; Instance.new("UICorner",rnHdr).CornerRadius=UDim.new(0,10)
    local rnEnTog=Instance.new("TextButton",rnHdr); rnEnTog.Size=UDim2.new(0,36,0,20); rnEnTog.Position=UDim2.new(0,8,0.5,-10); rnEnTog.BackgroundColor3=Color3.fromRGB(40,40,40); rnEnTog.Text=""; rnEnTog.ZIndex=72; Instance.new("UICorner",rnEnTog).CornerRadius=UDim.new(1,0)
    local rnEnKnob=Instance.new("Frame",rnEnTog); rnEnKnob.Size=UDim2.new(0,16,0,16); rnEnKnob.Position=UDim2.new(0,2,0.5,-8); rnEnKnob.BackgroundColor3=AC.TXT_DIM; Instance.new("UICorner",rnEnKnob).CornerRadius=UDim.new(1,0)
    local rnTitleLbl=Instance.new("TextLabel",rnHdr); rnTitleLbl.Size=UDim2.new(1,-110,1,0); rnTitleLbl.Position=UDim2.new(0,52,0,0); rnTitleLbl.BackgroundTransparency=1; rnTitleLbl.Text="AC REANIMATION"; rnTitleLbl.TextColor3=AC.TXT_WHITE; rnTitleLbl.TextSize=14; rnTitleLbl.Font=Enum.Font.GothamBold; rnTitleLbl.TextXAlignment=Enum.TextXAlignment.Left; rnTitleLbl.ZIndex=72
    local rnStatusLbl=Instance.new("TextLabel",rnHdr); rnStatusLbl.Size=UDim2.new(1,-110,1,0); rnStatusLbl.Position=UDim2.new(0,52,0,14); rnStatusLbl.BackgroundTransparency=1; rnStatusLbl.Text="Loading animations..."; rnStatusLbl.TextColor3=AC.TXT_DIM; rnStatusLbl.TextSize=10; rnStatusLbl.Font=Enum.Font.Gotham; rnStatusLbl.TextXAlignment=Enum.TextXAlignment.Left; rnStatusLbl.ZIndex=72
    local rnClsBtn=Instance.new("TextButton",rnHdr); rnClsBtn.Size=UDim2.new(0,20,0,20); rnClsBtn.Position=UDim2.new(1,-24,0.5,-10); rnClsBtn.BackgroundColor3=Color3.fromRGB(35,35,35); rnClsBtn.Text="X"; rnClsBtn.TextColor3=AC.TXT_DIM; rnClsBtn.TextSize=11; rnClsBtn.Font=Enum.Font.GothamBold; rnClsBtn.ZIndex=72; Instance.new("UICorner",rnClsBtn).CornerRadius=UDim.new(0,5); rnClsBtn.MouseButton1Click:Connect(function() rnPanel.Visible=false end)
    local rnTabBar=Instance.new("Frame",rnPanel); rnTabBar.Size=UDim2.new(1,-16,0,28); rnTabBar.Position=UDim2.new(0,8,0,44); rnTabBar.BackgroundColor3=Color3.fromRGB(20,20,24); rnTabBar.BackgroundTransparency=0.3; rnTabBar.ZIndex=71; Instance.new("UICorner",rnTabBar).CornerRadius=UDim.new(0,7)
    local rnTabAll=Instance.new("TextButton",rnTabBar); rnTabAll.Size=UDim2.new(0.5,0,1,0); rnTabAll.BackgroundColor3=AC.PUR_DARK; rnTabAll.Text="All"; rnTabAll.TextColor3=AC.TXT_WHITE; rnTabAll.TextSize=12; rnTabAll.Font=Enum.Font.GothamBold; rnTabAll.ZIndex=72; Instance.new("UICorner",rnTabAll).CornerRadius=UDim.new(0,6)
    local rnTabFav=Instance.new("TextButton",rnTabBar); rnTabFav.Size=UDim2.new(0.5,0,1,0); rnTabFav.Position=UDim2.new(0.5,0,0,0); rnTabFav.BackgroundColor3=Color3.fromRGB(22,22,22); rnTabFav.BackgroundTransparency=0.5; rnTabFav.Text="Favs"; rnTabFav.TextColor3=AC.TXT_DIM; rnTabFav.TextSize=12; rnTabFav.Font=Enum.Font.Gotham; rnTabFav.ZIndex=72; Instance.new("UICorner",rnTabFav).CornerRadius=UDim.new(0,6)
    local rnSearch=Instance.new("TextBox",rnPanel); rnSearch.Size=UDim2.new(1,-16,0,26); rnSearch.Position=UDim2.new(0,8,0,76); rnSearch.BackgroundColor3=Color3.fromRGB(20,20,24); rnSearch.BackgroundTransparency=0.3; rnSearch.PlaceholderText="Search..."; rnSearch.PlaceholderColor3=AC.TXT_DIM; rnSearch.Text=""; rnSearch.TextColor3=AC.TXT_MAIN; rnSearch.TextSize=12; rnSearch.Font=Enum.Font.Gotham; rnSearch.ClearTextOnFocus=false; rnSearch.ZIndex=71; Instance.new("UICorner",rnSearch).CornerRadius=UDim.new(0,7); Instance.new("UIStroke",rnSearch).Color=AC.PUR_STROKE; Instance.new("UIPadding",rnSearch).PaddingLeft=UDim.new(0,8)
    local rnScroll=Instance.new("ScrollingFrame",rnPanel); rnScroll.Size=UDim2.new(1,-16,0,248); rnScroll.Position=UDim2.new(0,8,0,108); rnScroll.BackgroundTransparency=1; rnScroll.BorderSizePixel=0; rnScroll.ScrollBarThickness=3; rnScroll.ScrollBarImageColor3=AC.PUR_MID; rnScroll.AutomaticCanvasSize=Enum.AutomaticSize.None; rnScroll.CanvasSize=UDim2.new(0,0,0,0); rnScroll.ZIndex=71
    local rnListLay=Instance.new("UIListLayout",rnScroll); rnListLay.FillDirection=Enum.FillDirection.Vertical; rnListLay.Padding=UDim.new(0,2); rnListLay.SortOrder=Enum.SortOrder.LayoutOrder
    local rnSpdLbl=Instance.new("TextLabel",rnPanel); rnSpdLbl.Size=UDim2.new(0,55,0,14); rnSpdLbl.Position=UDim2.new(0,8,0,362); rnSpdLbl.BackgroundTransparency=1; rnSpdLbl.Text="Speed:"; rnSpdLbl.TextColor3=AC.TXT_DIM; rnSpdLbl.TextSize=10; rnSpdLbl.Font=Enum.Font.GothamBold; rnSpdLbl.ZIndex=71
    local rnSpdVal=Instance.new("TextLabel",rnPanel); rnSpdVal.Size=UDim2.new(0,30,0,14); rnSpdVal.Position=UDim2.new(1,-68,0,362); rnSpdVal.BackgroundTransparency=1; rnSpdVal.Text="5"; rnSpdVal.TextColor3=AC.TXT_WHITE; rnSpdVal.TextSize=10; rnSpdVal.Font=Enum.Font.GothamBold; rnSpdVal.ZIndex=71
    local rnRstSpd=Instance.new("TextButton",rnPanel); rnRstSpd.Size=UDim2.new(0,40,0,14); rnRstSpd.Position=UDim2.new(1,-8,0,362); rnRstSpd.BackgroundTransparency=1; rnRstSpd.Text="Reset"; rnRstSpd.TextColor3=AC.TXT_DIM; rnRstSpd.TextSize=9; rnRstSpd.Font=Enum.Font.Gotham; rnRstSpd.ZIndex=71
    local rnSpdTrack=Instance.new("Frame",rnPanel); rnSpdTrack.Size=UDim2.new(1,-16,0,6); rnSpdTrack.Position=UDim2.new(0,8,0,380); rnSpdTrack.BackgroundColor3=Color3.fromRGB(30,30,35); rnSpdTrack.ZIndex=71; Instance.new("UICorner",rnSpdTrack).CornerRadius=UDim.new(1,0)
    local rnSpdFill=Instance.new("Frame",rnSpdTrack); rnSpdFill.Size=UDim2.new(0.5,0,1,0); rnSpdFill.BackgroundColor3=AC.PUR_MID; rnSpdFill.ZIndex=72; Instance.new("UICorner",rnSpdFill).CornerRadius=UDim.new(1,0)
    local rnSpdKnob=Instance.new("TextButton",rnSpdTrack); rnSpdKnob.Size=UDim2.new(0,14,0,14); rnSpdKnob.Position=UDim2.new(0.5,-7,0.5,-7); rnSpdKnob.BackgroundColor3=AC.PUR_GLOW; rnSpdKnob.Text=""; rnSpdKnob.ZIndex=73; Instance.new("UICorner",rnSpdKnob).CornerRadius=UDim.new(1,0)
    local rnSpdCur=5.0
    local function setRnSpd(v)
        v=math.clamp(math.floor(v*10+0.5)/10,0,10); rnSpdCur=v; rnSpdVal.Text=tostring(v); local r=v/10; rnSpdFill.Size=UDim2.new(r,0,1,0); rnSpdKnob.Position=UDim2.new(r,-7,0.5,-7)
        if rnAPI and rnActive then pcall(function() rnAPI.set_animation_speed(v) end) end
    end
    local _rnSpdConn=nil
    rnSpdKnob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then _rnSpdConn=AC.RS.RenderStepped:Connect(function() setRnSpd((AC.UIS:GetMouseLocation().X-rnSpdTrack.AbsolutePosition.X)/rnSpdTrack.AbsoluteSize.X*10) end) end end)
    rnSpdTrack.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then setRnSpd((AC.UIS:GetMouseLocation().X-rnSpdTrack.AbsolutePosition.X)/rnSpdTrack.AbsoluteSize.X*10); if not _rnSpdConn then _rnSpdConn=AC.RS.RenderStepped:Connect(function() setRnSpd((AC.UIS:GetMouseLocation().X-rnSpdTrack.AbsolutePosition.X)/rnSpdTrack.AbsoluteSize.X*10) end) end end end)
    AC.UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 and _rnSpdConn then _rnSpdConn:Disconnect(); _rnSpdConn=nil end end)
    rnRstSpd.MouseButton1Click:Connect(function() setRnSpd(5) end); setRnSpd(5)

    -- Number speed bind row (like AK) - 5 boxes with preset speeds + keybind each
    local RN_NUM_VALS={1,3,5,7,9}; local rnNumBinds={}
    local rnNumSaved=readData("rn_numBinds.json",{})
    local rnNBW=math.floor((RN_W-16-4*4)/5)
    local rnNumRowF=Instance.new("Frame",rnPanel); rnNumRowF.Size=UDim2.new(1,-16,0,52); rnNumRowF.Position=UDim2.new(0,8,0,392); rnNumRowF.BackgroundTransparency=1; rnNumRowF.ZIndex=71
    for i,nv in ipairs(RN_NUM_VALS) do
        local xOff=(i-1)*(rnNBW+4)
        -- Speed value box (editable)
        local nb=Instance.new("TextBox",rnNumRowF); nb.Size=UDim2.new(0,rnNBW,0,22); nb.Position=UDim2.new(0,xOff,0,0); nb.BackgroundColor3=Color3.fromRGB(20,20,24); nb.BackgroundTransparency=0.2; nb.Text=""; nb.PlaceholderText=tostring(nv); nb.PlaceholderColor3=Color3.fromRGB(80,80,100); nb.TextColor3=AC.TXT_WHITE; nb.TextSize=11; nb.Font=Enum.Font.GothamBold; nb.ZIndex=72; nb.ClearTextOnFocus=false; Instance.new("UICorner",nb).CornerRadius=UDim.new(0,5); Instance.new("UIStroke",nb).Color=AC.PUR_STROKE
        nb.FocusLost:Connect(function(enter) if enter and nb.Text~="" then local v=tonumber(nb.Text); if v and v>0 then setRnSpd(math.clamp(v,0.1,12)) end end end)
        -- Keybind button
        local kb=Instance.new("TextButton",rnNumRowF); kb.Size=UDim2.new(0,rnNBW,0,22); kb.Position=UDim2.new(0,xOff,0,26); kb.BackgroundColor3=Color3.fromRGB(20,20,24); kb.BackgroundTransparency=0.2; kb.Text="Bind"; kb.TextColor3=AC.TXT_DIM; kb.TextSize=10; kb.Font=Enum.Font.Gotham; kb.ZIndex=72; Instance.new("UICorner",kb).CornerRadius=UDim.new(0,5); Instance.new("UIStroke",kb).Color=AC.PUR_STROKE
        local savedKey=rnNumSaved[tostring(i)]
        rnNumBinds[i]={savedKey=savedKey,val=nv,kb=kb}
        if savedKey then kb.Text=savedKey:sub(1,4); kb.TextColor3=AC.TXT_WHITE end
        local kL=false; local kC=nil; local idx=i
        kb.MouseButton1Click:Connect(function()
            if kL then kL=false; if kC then kC:Disconnect(); kC=nil end; kb.Text=rnNumBinds[idx].savedKey and rnNumBinds[idx].savedKey:sub(1,4) or "Bind"; kb.TextColor3=rnNumBinds[idx].savedKey and AC.TXT_WHITE or AC.TXT_DIM; return end
            kL=true; kb.Text="..."; kb.TextColor3=AC.PUR_GLOW
            kC=AC.UIS.InputBegan:Connect(function(inp,gp)
                pcall(function()
                    if gp or inp.UserInputType~=Enum.UserInputType.Keyboard then return end
                    local kn=inp.KeyCode.Name; if not kn or kn=="" or kn=="Unknown" then return end
                    if kn=="Escape" then kL=false; if kC then kC:Disconnect(); kC=nil end; kb.Text=rnNumBinds[idx].savedKey and rnNumBinds[idx].savedKey:sub(1,4) or "Bind"; kb.TextColor3=rnNumBinds[idx].savedKey and AC.TXT_WHITE or AC.TXT_DIM; return end
                    rnNumBinds[idx].savedKey=kn; kb.Text=kn:sub(1,4); kb.TextColor3=AC.TXT_WHITE
                    kL=false; if kC then kC:Disconnect(); kC=nil end
                    -- save all num binds
                    local sv={}; for si,slot in ipairs(rnNumBinds) do if slot.savedKey then sv[tostring(si)]=slot.savedKey end end
                    writeData("rn_numBinds.json",sv)
                    AC.toast("Speed "..nv.." → ["..kn.."]",AC.PUR_BRIGHT)
                end)
            end)
        end)
    end
    -- Global handler for RN number speed binds
    AC.UIS.InputBegan:Connect(function(inp,gp)
        pcall(function()
            if gp or inp.UserInputType~=Enum.UserInputType.Keyboard then return end
            local kn=inp.KeyCode.Name; if not kn or kn=="" or kn=="Unknown" then return end
            for _,slot in ipairs(rnNumBinds) do if slot.savedKey==kn then setRnSpd(slot.val) end end
        end)
    end) local rnAllRows={}; local rnFavOnly=false; local rnFavs={}; local rnBinds={}; local rnSpeeds={}; local rnNowUrl=nil; local rnHighRow=nil
    do local fl=readData("rn_favs.json",{}); if type(fl)=="table" then for _,id in ipairs(fl) do rnFavs[tostring(id)]=true end end; local bl=readData("rn_binds.json",{}); if type(bl)=="table" then for k,v in pairs(bl) do rnBinds[k]=v end end; local sl=readData("rn_speeds.json",{}); if type(sl)=="table" then for k,v in pairs(sl) do rnSpeeds[k]=v end end end
    local function saveRnFavs() local l={}; for k in pairs(rnFavs) do l[#l+1]=k end; writeData("rn_favs.json",l) end
    local function saveRnBinds() writeData("rn_binds.json",rnBinds) end
    local function saveRnSpeeds() writeData("rn_speeds.json",rnSpeeds) end
    local function setRnTogUI(active)
        rnActive=active; AC.rnActive=active
        if active then AC.TS:Create(rnEnTog,TweenInfo.new(0.2),{BackgroundColor3=AC.PUR_MID}):Play(); AC.TS:Create(rnEnKnob,TweenInfo.new(0.2),{Position=UDim2.new(1,-18,0.5,-8),BackgroundColor3=AC.PUR_GLOW}):Play()
        else AC.TS:Create(rnEnTog,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(40,40,40)}):Play(); AC.TS:Create(rnEnKnob,TweenInfo.new(0.2),{Position=UDim2.new(0,2,0.5,-8),BackgroundColor3=AC.TXT_DIM}):Play() end
    end
    rnEnTog.MouseButton1Click:Connect(function()
        ensureAPI(function(api)
            if not rnActive then
                -- Shield health so reanimate can't kill us
                local char=AC.player.Character
                local hum=char and char:FindFirstChildOfClass("Humanoid")
                local oldMaxHealth=hum and hum.MaxHealth or 100
                if hum then
                    hum.MaxHealth=math.huge
                    hum.Health=math.huge
                end
                local ok,err=pcall(function() api.reanimate(true) end)
                -- Restore health after a safe delay
                task.delay(0.5,function()
                    pcall(function()
                        local c=AC.player.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
                        if h then h.MaxHealth=oldMaxHealth; h.Health=oldMaxHealth end
                    end)
                end)
                if ok then
                    setRnTogUI(true); rnStatusLbl.Text="Ready"; AC.toast("Reanimation ON",AC.GREEN_OK)
                else
                    -- Restore immediately on failure
                    pcall(function() if hum then hum.MaxHealth=oldMaxHealth; hum.Health=oldMaxHealth end end)
                    AC.toast("Reanimate failed",AC.RED_ERR)
                end
            else
                if rnNowUrl then pcall(function() api.stop_animation() end) end
                -- Shield health for reanimate(false) too
                local char=AC.player.Character
                local hum=char and char:FindFirstChildOfClass("Humanoid")
                local oldMaxHealth=hum and hum.MaxHealth or 100
                if hum then hum.MaxHealth=math.huge; hum.Health=math.huge end
                pcall(function() api.reanimate(false) end)
                task.delay(0.3,function()
                    pcall(function()
                        local c=AC.player.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
                        if h then
                            h.MaxHealth=oldMaxHealth; h.Health=oldMaxHealth
                            pcall(function() h:ChangeState(Enum.HumanoidStateType.GettingUp) end)
                            h.PlatformStand=false
                        end
                    end)
                end)
                setRnTogUI(false); rnNowUrl=nil
                if rnHighRow then pcall(function() rnHighRow.BackgroundColor3=Color3.fromRGB(14,14,18) end); rnHighRow=nil end
                rnStatusLbl.Text="Ready"; AC.toast("Reanimation OFF",AC.ORANGE_W)
            end
        end)
    end)
    local function buildRnRow(name,url,idx)
        if not name or not url or not idx then return nil end
        local row=Instance.new("TextButton",rnScroll); row.Size=UDim2.new(1,0,0,34); row.BackgroundColor3=Color3.fromRGB(14,14,18); row.BackgroundTransparency=0.1; row.Text=""; row.LayoutOrder=idx; row.ZIndex=72; Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
        local rS=Instance.new("UIStroke",row); rS.Color=AC.PUR_STROKE; rS.Thickness=1; rS.Transparency=0.7
        local idxStr=tostring(idx)
        local star=Instance.new("TextButton",row); star.Size=UDim2.new(0,26,0,26); star.Position=UDim2.new(0,6,0.5,-13); star.BackgroundTransparency=1; star.Text=rnFavs[idxStr] and "[*]" or "[ ]"; star.TextColor3=rnFavs[idxStr] and Color3.fromRGB(255,210,60) or AC.TXT_DIM; star.TextSize=13; star.Font=Enum.Font.Gotham; star.ZIndex=73
        local nLbl=Instance.new("TextLabel",row); nLbl.Size=UDim2.new(1,-120,1,0); nLbl.Position=UDim2.new(0,32,0,0); nLbl.BackgroundTransparency=1; nLbl.Text=name; nLbl.TextColor3=AC.TXT_MAIN; nLbl.TextSize=12; nLbl.Font=Enum.Font.Gotham; nLbl.TextXAlignment=Enum.TextXAlignment.Left; nLbl.TextTruncate=Enum.TextTruncate.AtEnd; nLbl.ZIndex=73
        local emoteSpd=rnSpeeds[idxStr] or 1.0
        local spdDn=Instance.new("TextButton",row); spdDn.Size=UDim2.new(0,14,0,14); spdDn.Position=UDim2.new(1,-60,0.5,-7); spdDn.BackgroundColor3=Color3.fromRGB(30,30,36); spdDn.Text="-"; spdDn.TextColor3=AC.TXT_DIM; spdDn.TextSize=11; spdDn.Font=Enum.Font.GothamBold; spdDn.ZIndex=73; Instance.new("UICorner",spdDn).CornerRadius=UDim.new(0,4)
        local spdTag=Instance.new("TextLabel",row); spdTag.Size=UDim2.new(0,26,0,14); spdTag.Position=UDim2.new(1,-44,0.5,-7); spdTag.BackgroundColor3=Color3.fromRGB(20,20,26); spdTag.Text=tostring(emoteSpd); spdTag.TextColor3=AC.TXT_DIM; spdTag.TextSize=9; spdTag.Font=Enum.Font.Gotham; spdTag.ZIndex=73; spdTag.BackgroundTransparency=0.3; Instance.new("UICorner",spdTag).CornerRadius=UDim.new(0,4)
        local spdUp=Instance.new("TextButton",row); spdUp.Size=UDim2.new(0,14,0,14); spdUp.Position=UDim2.new(1,-16,0.5,-7); spdUp.BackgroundColor3=Color3.fromRGB(30,30,36); spdUp.Text="+"; spdUp.TextColor3=AC.TXT_DIM; spdUp.TextSize=11; spdUp.Font=Enum.Font.GothamBold; spdUp.ZIndex=73; Instance.new("UICorner",spdUp).CornerRadius=UDim.new(0,4)
        local bLbl=Instance.new("TextButton",row); bLbl.Size=UDim2.new(0,28,0,14); bLbl.Position=UDim2.new(1,-90,0.5,-7); bLbl.BackgroundColor3=Color3.fromRGB(26,26,32); bLbl.Text=rnBinds[idxStr] and rnBinds[idxStr]:sub(1,3) or "Bind"; bLbl.TextColor3=rnBinds[idxStr] and AC.TXT_WHITE or AC.TXT_DIM; bLbl.TextSize=8; bLbl.Font=Enum.Font.Gotham; bLbl.ZIndex=73; bLbl.BackgroundTransparency=0.3; Instance.new("UICorner",bLbl).CornerRadius=UDim.new(0,4)
        local urlC,nameC=url,name
        star.MouseButton1Click:Connect(function() if rnFavs[idxStr] then rnFavs[idxStr]=nil; star.Text="[ ]"; star.TextColor3=AC.TXT_DIM else rnFavs[idxStr]=true; star.Text="[*]"; AC.TS:Create(star,TweenInfo.new(0.15),{TextColor3=Color3.fromRGB(255,210,60)}):Play() end; saveRnFavs(); if rnFavOnly then row.Visible=rnFavs[idxStr]~=nil end end)
        spdDn.MouseButton1Click:Connect(function() emoteSpd=math.clamp(math.floor((emoteSpd-0.1)*10+0.5)/10,0.1,12); spdTag.Text=tostring(emoteSpd); rnSpeeds[idxStr]=emoteSpd; saveRnSpeeds(); if rnNowUrl==urlC and rnAPI then pcall(function() rnAPI.set_animation_speed(emoteSpd) end) end end)
        spdUp.MouseButton1Click:Connect(function() emoteSpd=math.clamp(math.floor((emoteSpd+0.1)*10+0.5)/10,0.1,12); spdTag.Text=tostring(emoteSpd); rnSpeeds[idxStr]=emoteSpd; saveRnSpeeds(); if rnNowUrl==urlC and rnAPI then pcall(function() rnAPI.set_animation_speed(emoteSpd) end) end end)
        local bListen=false; local bConn=nil
        bLbl.MouseButton1Click:Connect(function()
            if bListen then bListen=false; if bConn then bConn:Disconnect(); bConn=nil end; bLbl.Text=rnBinds[idxStr] and rnBinds[idxStr]:sub(1,3) or "Bind"; return end
            bListen=true; bLbl.Text="..."; bLbl.TextColor3=AC.PUR_GLOW
            bConn=AC.UIS.InputBegan:Connect(function(inp,gp)
                if gp or inp.UserInputType~=Enum.UserInputType.Keyboard then return end
                local ok2,kn=pcall(function() return inp.KeyCode.Name end); if not ok2 or not kn or kn=="Unknown" then return end
                if kn=="Escape" or kn=="Delete" or kn=="Backspace" then bListen=false; if bConn then bConn:Disconnect(); bConn=nil end; if kn~="Escape" then rnBinds[idxStr]=nil; saveRnBinds(); bLbl.Text="Bind"; bLbl.TextColor3=AC.TXT_DIM; AC.toast("Bind cleared",AC.ORANGE_W) else bLbl.Text=rnBinds[idxStr] and rnBinds[idxStr]:sub(1,3) or "Bind"; bLbl.TextColor3=rnBinds[idxStr] and AC.TXT_WHITE or AC.TXT_DIM end; return end
                rnBinds[idxStr]=kn; saveRnBinds(); bLbl.Text=kn:sub(1,3); bLbl.TextColor3=AC.TXT_WHITE; bListen=false; if bConn then bConn:Disconnect(); bConn=nil end; AC.toast("Bound "..kn.." -> "..nameC,AC.PUR_BRIGHT)
            end)
        end)
        local highlighted=false
        row.MouseButton1Click:Connect(function()
            if not rnActive then AC.toast("Enable Reanimation first!",AC.ORANGE_W); return end
            ensureAPI(function(api)
                if highlighted then
                    pcall(function() api.stop_animation() end); rnNowUrl=nil; highlighted=false
                    AC.TS:Create(row,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(14,14,18)}):Play(); rS.Color=AC.PUR_STROKE; rnHighRow=nil; AC.toast("Stopped: "..nameC,AC.ORANGE_W); return
                end
                if rnHighRow then pcall(function() AC.TS:Create(rnHighRow,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(14,14,18)}):Play(); local ps=rnHighRow:FindFirstChildOfClass("UIStroke"); if ps then ps.Color=AC.PUR_STROKE end end) end
                pcall(function() api.play_animation(urlC,emoteSpd) end); rnNowUrl=urlC; highlighted=true; rnHighRow=row
                AC.TS:Create(row,TweenInfo.new(0.15),{BackgroundColor3=AC.PUR_DARK}):Play(); rS.Color=AC.PUR_BRIGHT; AC.toast("* "..nameC,AC.PUR_BRIGHT)
            end)
        end)
        row.MouseEnter:Connect(function() if not highlighted then AC.TS:Create(row,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(22,22,28)}):Play() end end)
        row.MouseLeave:Connect(function() if not highlighted then AC.TS:Create(row,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(14,14,18)}):Play() end end)
        return {row=row,nameLower=name:lower(),url=url,index=idx}
    end
    task.spawn(function()
        fetchRnAnimList(function(list)
            for i,a in ipairs(list) do
                if a and a[1] and a[2] then local rnBuilt=buildRnRow(a[1],a[2],i); if rnBuilt then rnAllRows[i]=rnBuilt end end
                if i%20==0 then rnScroll.CanvasSize=UDim2.new(0,0,0,i*36+8); task.wait() end
            end
            rnScroll.CanvasSize=UDim2.new(0,0,0,#list*36+8); rnStatusLbl.Text="Loaded "..#list.." animations"; AC.toast("Loaded "..#list.." animations",AC.GREEN_OK)
        end)
    end)
    local function rnSwitchTab(favOnly)
        rnFavOnly=favOnly
        if favOnly then AC.TS:Create(rnTabFav,TweenInfo.new(0.15),{BackgroundColor3=AC.PUR_DARK,BackgroundTransparency=0}):Play(); rnTabFav.TextColor3=AC.TXT_WHITE; AC.TS:Create(rnTabAll,TweenInfo.new(0.15),{BackgroundTransparency=0.5,BackgroundColor3=Color3.fromRGB(22,22,22)}):Play(); rnTabAll.TextColor3=AC.TXT_DIM
        else AC.TS:Create(rnTabAll,TweenInfo.new(0.15),{BackgroundColor3=AC.PUR_DARK,BackgroundTransparency=0}):Play(); rnTabAll.TextColor3=AC.TXT_WHITE; AC.TS:Create(rnTabFav,TweenInfo.new(0.15),{BackgroundTransparency=0.5,BackgroundColor3=Color3.fromRGB(22,22,22)}):Play(); rnTabFav.TextColor3=AC.TXT_DIM end
        local q=rnSearch.Text:lower(); for _,r in ipairs(rnAllRows) do if r then local sf=(not favOnly) or rnFavs[tostring(r.index)]; r.row.Visible=sf and (q=="" or r.nameLower:find(q,1,true)~=nil) end end
    end
    rnTabAll.MouseButton1Click:Connect(function() rnSwitchTab(false) end); rnTabFav.MouseButton1Click:Connect(function() rnSwitchTab(true) end)
    rnSearch:GetPropertyChangedSignal("Text"):Connect(function() local q=rnSearch.Text:lower(); for _,r in ipairs(rnAllRows) do if r then local sf=(not rnFavOnly) or rnFavs[tostring(r.index)]; r.row.Visible=sf and (q=="" or r.nameLower:find(q,1,true)~=nil) end end end)
    AC.UIS.InputBegan:Connect(function(inp,gp)
        pcall(function()
            if gp or inp.UserInputType~=Enum.UserInputType.Keyboard then return end
            local kn=inp.KeyCode.Name; if not kn or kn=="" or kn=="Unknown" then return end
            if rnActive then
                for idxStr,bk in pairs(rnBinds) do
                    if bk==kn then
                        for _,r in ipairs(rnAllRows) do
                            if r and tostring(r.index)==idxStr then
                                ensureAPI(function(api)
                                    pcall(function() api.play_animation(r.url,rnSpeeds[idxStr] or 1.0) end)
                                    AC.toast("* "..r.nameLower,AC.PUR_BRIGHT)
                                end)
                                break
                            end
                        end
                    end
                end
            end
        end)
    end)
    local rnDrag,rnDS,rnSP=false,nil,nil
    rnHdr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then rnDrag=true; rnDS=i.Position; rnSP=rnPanel.Position; i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then rnDrag=false end end) end end)
    AC.UIS.InputChanged:Connect(function(i) if rnDrag and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-rnDS; rnPanel.Position=UDim2.new(0,math.clamp(rnSP.X.Offset+d.X,0,AC.camera.ViewportSize.X-RN_W),0,math.clamp(rnSP.Y.Offset+d.Y,0,AC.camera.ViewportSize.Y-RN_H)) end end)

    -- UGC PANEL
    local UGC_W,UGC_H=360,520
    local ugcPanel=Instance.new("Frame",AC.screenGui); ugcPanel.Size=UDim2.new(0,UGC_W,0,UGC_H); ugcPanel.Position=UDim2.new(0, math.floor(AC.camera.ViewportSize.X/2)-UGC_W/2, 0, math.floor(AC.camera.ViewportSize.Y*0.15)); ugcPanel.BackgroundColor3=Color3.fromRGB(12,12,14); ugcPanel.BackgroundTransparency=0.18; ugcPanel.ZIndex=65; ugcPanel.Visible=false; ugcPanel.ClipsDescendants=true; Instance.new("UICorner",ugcPanel).CornerRadius=UDim.new(0,10); Instance.new("UIStroke",ugcPanel).Color=AC.PUR_STROKE
    local ugcHdr=Instance.new("Frame",ugcPanel); ugcHdr.Size=UDim2.new(1,0,0,40); ugcHdr.BackgroundColor3=Color3.fromRGB(8,8,10); ugcHdr.BackgroundTransparency=0.2; ugcHdr.ZIndex=66; Instance.new("UICorner",ugcHdr).CornerRadius=UDim.new(0,10)
    local ugcTitleLbl=Instance.new("TextLabel",ugcHdr); ugcTitleLbl.Size=UDim2.new(1,-80,1,0); ugcTitleLbl.Position=UDim2.new(0,14,0,0); ugcTitleLbl.BackgroundTransparency=1; ugcTitleLbl.Text="UGC EMOTES"; ugcTitleLbl.TextColor3=AC.TXT_WHITE; ugcTitleLbl.TextSize=14; ugcTitleLbl.Font=Enum.Font.GothamBold; ugcTitleLbl.TextXAlignment=Enum.TextXAlignment.Left; ugcTitleLbl.ZIndex=67
    local ugcStatusLbl=Instance.new("TextLabel",ugcHdr); ugcStatusLbl.Size=UDim2.new(1,-80,1,0); ugcStatusLbl.Position=UDim2.new(0,14,0,14); ugcStatusLbl.BackgroundTransparency=1; ugcStatusLbl.Text="Loading..."; ugcStatusLbl.TextColor3=AC.TXT_DIM; ugcStatusLbl.TextSize=10; ugcStatusLbl.Font=Enum.Font.Gotham; ugcStatusLbl.TextXAlignment=Enum.TextXAlignment.Left; ugcStatusLbl.ZIndex=67
    local ugcClsBtn=Instance.new("TextButton",ugcHdr); ugcClsBtn.Size=UDim2.new(0,20,0,20); ugcClsBtn.Position=UDim2.new(1,-24,0.5,-10); ugcClsBtn.BackgroundColor3=Color3.fromRGB(35,35,35); ugcClsBtn.Text="X"; ugcClsBtn.TextColor3=AC.TXT_DIM; ugcClsBtn.TextSize=11; ugcClsBtn.Font=Enum.Font.GothamBold; ugcClsBtn.ZIndex=67; Instance.new("UICorner",ugcClsBtn).CornerRadius=UDim.new(0,5); ugcClsBtn.MouseButton1Click:Connect(function() ugcPanel.Visible=false end)
    local ugcTabBar=Instance.new("Frame",ugcPanel); ugcTabBar.Size=UDim2.new(1,-16,0,28); ugcTabBar.Position=UDim2.new(0,8,0,44); ugcTabBar.BackgroundColor3=Color3.fromRGB(20,20,24); ugcTabBar.BackgroundTransparency=0.3; ugcTabBar.ZIndex=66; Instance.new("UICorner",ugcTabBar).CornerRadius=UDim.new(0,7)
    local UGC_TAB_NAMES={"All","Favs","States"}; local ugcTabBtns={}; local ugcActiveTab="All"
    for i,tn in ipairs(UGC_TAB_NAMES) do local tb=Instance.new("TextButton",ugcTabBar); tb.Size=UDim2.new(1/3,0,1,0); tb.Position=UDim2.new((i-1)/3,0,0,0); tb.BackgroundColor3=i==1 and AC.PUR_DARK or Color3.fromRGB(22,22,22); tb.BackgroundTransparency=i==1 and 0 or 0.5; tb.Text=tn; tb.TextColor3=i==1 and AC.TXT_WHITE or AC.TXT_DIM; tb.TextSize=12; tb.Font=i==1 and Enum.Font.GothamBold or Enum.Font.Gotham; tb.ZIndex=67; Instance.new("UICorner",tb).CornerRadius=UDim.new(0,6); ugcTabBtns[tn]=tb end
    local ugcSrch=Instance.new("TextBox",ugcPanel); ugcSrch.Size=UDim2.new(1,-16,0,26); ugcSrch.Position=UDim2.new(0,8,0,76); ugcSrch.BackgroundColor3=Color3.fromRGB(20,20,24); ugcSrch.BackgroundTransparency=0.3; ugcSrch.PlaceholderText="Search emotes..."; ugcSrch.PlaceholderColor3=AC.TXT_DIM; ugcSrch.Text=""; ugcSrch.TextColor3=AC.TXT_MAIN; ugcSrch.TextSize=12; ugcSrch.Font=Enum.Font.Gotham; ugcSrch.ClearTextOnFocus=false; ugcSrch.ZIndex=66; Instance.new("UICorner",ugcSrch).CornerRadius=UDim.new(0,7); Instance.new("UIStroke",ugcSrch).Color=AC.PUR_STROKE; Instance.new("UIPadding",ugcSrch).PaddingLeft=UDim.new(0,8)
    local ugcListPage=Instance.new("Frame",ugcPanel); ugcListPage.Size=UDim2.new(1,-16,0,258); ugcListPage.Position=UDim2.new(0,8,0,108); ugcListPage.BackgroundTransparency=1; ugcListPage.ZIndex=66
    local ugcScroll=Instance.new("ScrollingFrame",ugcListPage); ugcScroll.Size=UDim2.new(1,0,1,0); ugcScroll.BackgroundTransparency=1; ugcScroll.BorderSizePixel=0; ugcScroll.ScrollBarThickness=3; ugcScroll.ScrollBarImageColor3=AC.PUR_MID; ugcScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; ugcScroll.CanvasSize=UDim2.new(0,0,0,0); ugcScroll.ZIndex=67; Instance.new("UIListLayout",ugcScroll).Padding=UDim.new(0,2)
    local ugcStatesPage=Instance.new("Frame",ugcPanel); ugcStatesPage.Size=UDim2.new(1,-16,0,258); ugcStatesPage.Position=UDim2.new(0,8,0,108); ugcStatesPage.BackgroundTransparency=1; ugcStatesPage.Visible=false; ugcStatesPage.ZIndex=66
    local ugcStatesSF=Instance.new("ScrollingFrame",ugcStatesPage); ugcStatesSF.Size=UDim2.new(1,0,1,0); ugcStatesSF.BackgroundTransparency=1; ugcStatesSF.BorderSizePixel=0; ugcStatesSF.ScrollBarThickness=3; ugcStatesSF.ScrollBarImageColor3=AC.PUR_MID; ugcStatesSF.AutomaticCanvasSize=Enum.AutomaticSize.Y; ugcStatesSF.CanvasSize=UDim2.new(0,0,0,0); ugcStatesSF.ZIndex=67
    local ugcStatesLL=Instance.new("UIListLayout",ugcStatesSF); ugcStatesLL.Padding=UDim.new(0,6)
    local ugcBottomBar=Instance.new("Frame",ugcPanel); ugcBottomBar.Size=UDim2.new(1,-16,0,68); ugcBottomBar.Position=UDim2.new(0,8,1,-76); ugcBottomBar.BackgroundColor3=Color3.fromRGB(14,14,18); ugcBottomBar.BackgroundTransparency=0.3; ugcBottomBar.ZIndex=66; Instance.new("UICorner",ugcBottomBar).CornerRadius=UDim.new(0,7)
    local ugcSpLbl=Instance.new("TextLabel",ugcBottomBar); ugcSpLbl.Size=UDim2.new(0,55,0,14); ugcSpLbl.Position=UDim2.new(0,8,0,4); ugcSpLbl.BackgroundTransparency=1; ugcSpLbl.Text="Speed:"; ugcSpLbl.TextColor3=AC.TXT_DIM; ugcSpLbl.TextSize=10; ugcSpLbl.Font=Enum.Font.GothamBold; ugcSpLbl.TextXAlignment=Enum.TextXAlignment.Left; ugcSpLbl.ZIndex=67
    local ugcSpVal=Instance.new("TextLabel",ugcBottomBar); ugcSpVal.Size=UDim2.new(0,30,0,14); ugcSpVal.Position=UDim2.new(1,-72,0,4); ugcSpVal.BackgroundTransparency=1; ugcSpVal.Text="5"; ugcSpVal.TextColor3=AC.TXT_WHITE; ugcSpVal.TextSize=10; ugcSpVal.Font=Enum.Font.GothamBold; ugcSpVal.ZIndex=67
    local ugcSpRst=Instance.new("TextButton",ugcBottomBar); ugcSpRst.Size=UDim2.new(0,40,0,14); ugcSpRst.Position=UDim2.new(1,-40,0,4); ugcSpRst.BackgroundTransparency=1; ugcSpRst.Text="Reset"; ugcSpRst.TextColor3=AC.TXT_DIM; ugcSpRst.TextSize=9; ugcSpRst.Font=Enum.Font.Gotham; ugcSpRst.ZIndex=67
    local ugcSpTrk=Instance.new("Frame",ugcBottomBar); ugcSpTrk.Size=UDim2.new(1,-16,0,6); ugcSpTrk.Position=UDim2.new(0,8,0,22); ugcSpTrk.BackgroundColor3=Color3.fromRGB(30,30,35); ugcSpTrk.ZIndex=67; Instance.new("UICorner",ugcSpTrk).CornerRadius=UDim.new(1,0)
    local ugcSpFl=Instance.new("Frame",ugcSpTrk); ugcSpFl.Size=UDim2.new(0.5,0,1,0); ugcSpFl.BackgroundColor3=AC.PUR_MID; ugcSpFl.ZIndex=68; Instance.new("UICorner",ugcSpFl).CornerRadius=UDim.new(1,0)
    local ugcSpKn=Instance.new("TextButton",ugcSpTrk); ugcSpKn.Size=UDim2.new(0,14,0,14); ugcSpKn.Position=UDim2.new(0.5,-7,0.5,-7); ugcSpKn.BackgroundColor3=AC.PUR_GLOW; ugcSpKn.Text=""; ugcSpKn.ZIndex=69; Instance.new("UICorner",ugcSpKn).CornerRadius=UDim.new(1,0)
    local ugcActiveTrack=nil; local ugcSpdCur=5.0; local ugcLoadedTracks={}
    local function setUgcSpd(v) v=math.clamp(math.floor(v*10+0.5)/10,0,10); ugcSpdCur=v; local r=v/10; ugcSpVal.Text=tostring(v); ugcSpFl.Size=UDim2.new(r,0,1,0); ugcSpKn.Position=UDim2.new(r,-7,0.5,-7); if ugcActiveTrack then pcall(function() ugcActiveTrack:AdjustSpeed(v) end) end end
    local _ugcDC=nil
    ugcSpKn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then _ugcDC=AC.RS.RenderStepped:Connect(function() setUgcSpd((AC.UIS:GetMouseLocation().X-ugcSpTrk.AbsolutePosition.X)/ugcSpTrk.AbsoluteSize.X*10) end) end end)
    ugcSpTrk.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then setUgcSpd((AC.UIS:GetMouseLocation().X-ugcSpTrk.AbsolutePosition.X)/ugcSpTrk.AbsoluteSize.X*10); if not _ugcDC then _ugcDC=AC.RS.RenderStepped:Connect(function() setUgcSpd((AC.UIS:GetMouseLocation().X-ugcSpTrk.AbsolutePosition.X)/ugcSpTrk.AbsoluteSize.X*10) end) end end end)
    AC.UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 and _ugcDC then _ugcDC:Disconnect(); _ugcDC=nil end end)
    ugcSpRst.MouseButton1Click:Connect(function() setUgcSpd(5) end); setUgcSpd(5)
    local ugcFavs={}; local ugcBinds={}
    do local fl=readData("ugc_favs.json",{}); for _,id in ipairs(fl) do ugcFavs[tostring(id)]=true end; local bl=readData("ugc_binds.json",{}); for k,v in pairs(bl) do ugcBinds[k]=v end end
    local function saveUgcFavs() local l={}; for k in pairs(ugcFavs) do l[#l+1]=k end; writeData("ugc_favs.json",l) end
    local function saveUgcBinds() writeData("ugc_binds.json",ugcBinds) end
    local ugcAllRows={}; local ugcFavOnly=false; local ugcHighRow=nil

    local function stopUgcTrack()
        if ugcActiveTrack then pcall(function() ugcActiveTrack:Stop(0.3) end); ugcActiveTrack=nil end
        for _,t in ipairs(ugcLoadedTracks) do pcall(function() if t then t:Stop(0.3) end end) end
        ugcLoadedTracks={}
    end

    local function playUgcEmote(id)
        stopUgcTrack()
        local char=AC.player.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        local animator=hum:FindFirstChildOfClass("Animator")
        if not animator then animator=hum:FindFirstChildWhichIsA("Animator") end
        if not animator then return end
        local anim=Instance.new("Animation")
        anim.AnimationId="rbxassetid://"..tostring(id)
        local ok,track=pcall(function() return animator:LoadAnimation(anim) end)
        if not ok or not track then AC.toast("Failed to load emote",AC.RED_ERR); return end
        track.Priority=Enum.AnimationPriority.Action4
        track.Looped=true
        track:Play(0.3)
        pcall(function() track:AdjustSpeed(ugcSpdCur) end)
        ugcActiveTrack=track
        track.Stopped:Connect(function() pcall(function() track:Destroy() end) end)
    end

    -- Simple row builder - reliable, no virtual scroll complexity
    local function buildUgcRow(item,idx)
        local idxStr=tostring(item.id)
        local row=Instance.new("TextButton",ugcScroll)
        row.Size=UDim2.new(1,0,0,34); row.BackgroundColor3=Color3.fromRGB(14,14,18)
        row.BackgroundTransparency=0.1; row.Text=""; row.LayoutOrder=idx; row.ZIndex=68
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)
        local star=Instance.new("TextButton",row); star.Size=UDim2.new(0,26,0,26); star.Position=UDim2.new(0,6,0.5,-13); star.BackgroundTransparency=1; star.Text=ugcFavs[idxStr] and "[*]" or "[ ]"; star.TextColor3=ugcFavs[idxStr] and Color3.fromRGB(255,210,60) or AC.TXT_DIM; star.TextSize=13; star.Font=Enum.Font.Gotham; star.ZIndex=69
        local nLbl=Instance.new("TextLabel",row); nLbl.Size=UDim2.new(1,-70,1,0); nLbl.Position=UDim2.new(0,32,0,0); nLbl.BackgroundTransparency=1; nLbl.Text=item.name; nLbl.TextColor3=AC.TXT_MAIN; nLbl.TextSize=12; nLbl.Font=Enum.Font.Gotham; nLbl.TextXAlignment=Enum.TextXAlignment.Left; nLbl.TextTruncate=Enum.TextTruncate.AtEnd; nLbl.ZIndex=69
        local bLbl=Instance.new("TextButton",row); bLbl.Size=UDim2.new(0,28,0,14); bLbl.Position=UDim2.new(1,-34,0.5,-7); bLbl.BackgroundColor3=Color3.fromRGB(26,26,32); bLbl.Text=ugcBinds[idxStr] and ugcBinds[idxStr]:sub(1,3) or "Bind"; bLbl.TextColor3=ugcBinds[idxStr] and AC.TXT_WHITE or AC.TXT_DIM; bLbl.TextSize=8; bLbl.Font=Enum.Font.Gotham; bLbl.ZIndex=69; bLbl.BackgroundTransparency=0.3; Instance.new("UICorner",bLbl).CornerRadius=UDim.new(0,4)
        star.MouseButton1Click:Connect(function()
            if ugcFavs[idxStr] then ugcFavs[idxStr]=nil; star.Text="[ ]"; star.TextColor3=AC.TXT_DIM
            else ugcFavs[idxStr]=true; star.Text="[*]"; star.TextColor3=Color3.fromRGB(255,210,60) end
            saveUgcFavs()
        end)
        local bL=false; local bC=nil
        bLbl.MouseButton1Click:Connect(function()
            if bL then bL=false; if bC then bC:Disconnect(); bC=nil end; bLbl.Text=ugcBinds[idxStr] and ugcBinds[idxStr]:sub(1,3) or "Bind"; return end
            bL=true; bLbl.Text="..."; bLbl.TextColor3=AC.PUR_GLOW
            bC=AC.UIS.InputBegan:Connect(function(inp,gp)
                pcall(function()
                    if gp or inp.UserInputType~=Enum.UserInputType.Keyboard then return end
                    local kn=inp.KeyCode.Name; if not kn or kn=="" or kn=="Unknown" then return end
                    ugcBinds[idxStr]=kn; saveUgcBinds(); bLbl.Text=kn:sub(1,3); bLbl.TextColor3=AC.TXT_WHITE
                    bL=false; if bC then bC:Disconnect(); bC=nil end
                end)
            end)
        end)
        local highlighted=false
        row.MouseButton1Click:Connect(function()
            if highlighted then
                stopUgcTrack(); highlighted=false; ugcHighRow=nil
                row.BackgroundColor3=Color3.fromRGB(14,14,18)
                AC.toast("Stopped",AC.ORANGE_W); return
            end
            if ugcHighRow then
                -- unhighlight previous
                for _,r in ipairs(ugcAllRows) do
                    if r and r.id==ugcHighRow then
                        if r.row and r.row.Parent then r.row.BackgroundColor3=Color3.fromRGB(14,14,18) end
                        break
                    end
                end
            end
            stopUgcTrack(); highlighted=true; ugcHighRow=item.id
            row.BackgroundColor3=AC.PUR_DARK
            playUgcEmote(item.id)
            AC.toast("* "..item.name,AC.PUR_BRIGHT)
        end)
        return {row=row, nameLower=item.name:lower(), id=item.id, index=idx, highlighted=function() return highlighted end, setHL=function(v) highlighted=v end}
    end
    -- States
    local STATE_CATS={"Idle","Walk","Jump"}
    for _,cat in ipairs(STATE_CATS) do
        local sec=Instance.new("Frame",ugcStatesSF); sec.Size=UDim2.new(1,0,0,96); sec.BackgroundColor3=Color3.fromRGB(16,16,20); sec.BackgroundTransparency=0.3; sec.ZIndex=68; Instance.new("UICorner",sec).CornerRadius=UDim.new(0,8); Instance.new("UIStroke",sec).Color=AC.PUR_STROKE
        local cLbl=Instance.new("TextLabel",sec); cLbl.Size=UDim2.new(1,-80,0,22); cLbl.Position=UDim2.new(0,10,0,6); cLbl.BackgroundTransparency=1; cLbl.Text=cat; cLbl.TextColor3=AC.PUR_GLOW; cLbl.TextSize=13; cLbl.Font=Enum.Font.GothamBold; cLbl.TextXAlignment=Enum.TextXAlignment.Left; cLbl.ZIndex=69
        local ddBtn=Instance.new("TextButton",sec); ddBtn.Size=UDim2.new(1,-20,0,24); ddBtn.Position=UDim2.new(0,10,0,30); ddBtn.BackgroundColor3=Color3.fromRGB(22,22,28); ddBtn.BackgroundTransparency=0.2; ddBtn.Text="Select animation "; ddBtn.TextColor3=AC.TXT_MAIN; ddBtn.TextSize=11; ddBtn.Font=Enum.Font.Gotham; ddBtn.ZIndex=69; Instance.new("UICorner",ddBtn).CornerRadius=UDim.new(0,6); Instance.new("UIStroke",ddBtn).Color=AC.PUR_STROKE
        local sTrk=Instance.new("Frame",sec); sTrk.Size=UDim2.new(1,-110,0,5); sTrk.Position=UDim2.new(0,10,0,72); sTrk.BackgroundColor3=Color3.fromRGB(30,30,35); sTrk.ZIndex=69; Instance.new("UICorner",sTrk).CornerRadius=UDim.new(1,0)
        local sFil=Instance.new("Frame",sTrk); sFil.Size=UDim2.new(0.18,0,1,0); sFil.BackgroundColor3=AC.PUR_MID; sFil.ZIndex=70; Instance.new("UICorner",sFil).CornerRadius=UDim.new(1,0)
        local sKnb=Instance.new("TextButton",sTrk); sKnb.Size=UDim2.new(0,12,0,12); sKnb.Position=UDim2.new(0.18,-6,0.5,-6); sKnb.BackgroundColor3=AC.PUR_GLOW; sKnb.Text=""; sKnb.ZIndex=71; Instance.new("UICorner",sKnb).CornerRadius=UDim.new(1,0)
        local stSpd=1.0; local function setStSpd(v) v=math.clamp(math.floor(v*10+0.5)/10,0.1,5.0); stSpd=v; local r=(v-0.1)/4.9; sFil.Size=UDim2.new(r,0,1,0); sKnb.Position=UDim2.new(r,-6,0.5,-6) end
        local _sDC=nil
        sKnb.InputBegan:Connect(function(i) if i.UserInputType~=Enum.UserInputType.MouseButton1 then return end; _sDC=AC.RS.RenderStepped:Connect(function() setStSpd(0.1+(AC.UIS:GetMouseLocation().X-sTrk.AbsolutePosition.X)/sTrk.AbsoluteSize.X*4.9) end) end)
        sTrk.InputBegan:Connect(function(i) if i.UserInputType~=Enum.UserInputType.MouseButton1 then return end; setStSpd(0.1+(AC.UIS:GetMouseLocation().X-sTrk.AbsolutePosition.X)/sTrk.AbsoluteSize.X*4.9); if not _sDC then _sDC=AC.RS.RenderStepped:Connect(function() setStSpd(0.1+(AC.UIS:GetMouseLocation().X-sTrk.AbsolutePosition.X)/sTrk.AbsoluteSize.X*4.9) end) end end)
        AC.UIS.InputEnded:Connect(function(i) if i.UserInputType~=Enum.UserInputType.MouseButton1 then return end; if _sDC then _sDC:Disconnect(); _sDC=nil end end)
        setStSpd(1.0)
        local ddPop=Instance.new("Frame",AC.screenGui); ddPop.Size=UDim2.new(0,220,0,0); ddPop.BackgroundColor3=Color3.fromRGB(30,30,38); ddPop.BorderSizePixel=0; ddPop.ClipsDescendants=true; ddPop.ZIndex=600; ddPop.Visible=false; Instance.new("UICorner",ddPop).CornerRadius=UDim.new(0,8); Instance.new("UIStroke",ddPop).Color=AC.PUR_STROKE
        local ddSF=Instance.new("ScrollingFrame",ddPop); ddSF.Size=UDim2.new(1,0,1,0); ddSF.BackgroundTransparency=0; ddSF.BackgroundColor3=Color3.fromRGB(30,30,38); ddSF.BorderSizePixel=0; ddSF.ScrollBarThickness=3; ddSF.ScrollBarImageColor3=AC.PUR_MID; ddSF.AutomaticCanvasSize=Enum.AutomaticSize.Y; ddSF.CanvasSize=UDim2.new(0,0,0,0); ddSF.ZIndex=601
        Instance.new("UIListLayout",ddSF).Padding=UDim.new(0,2)
        for ai,aData in ipairs(RN_ANIMS) do
            local aC=aData; local opt=Instance.new("TextButton",ddSF); opt.Size=UDim2.new(1,0,0,30); opt.BackgroundColor3=Color3.fromRGB(30,30,38); opt.BorderSizePixel=0; opt.Text=aData[1]; opt.TextColor3=AC.TXT_WHITE; opt.TextSize=11; opt.Font=Enum.Font.Gotham; opt.LayoutOrder=ai; opt.ZIndex=602; Instance.new("UICorner",opt).CornerRadius=UDim.new(0,6)
            opt.MouseButton1Click:Connect(function() ddBtn.Text=aC[1].." "; ddPop.Visible=false; if rnAPI then pcall(function() rnAPI.play_animation(aC[2],stSpd) end); AC.toast("* "..cat..": "..aC[1],AC.PUR_BRIGHT) else AC.toast("Enable Reanimation first!",AC.ORANGE_W) end end)
            opt.MouseEnter:Connect(function() AC.TS:Create(opt,TweenInfo.new(0.1),{BackgroundColor3=AC.PUR_DARK}):Play() end); opt.MouseLeave:Connect(function() AC.TS:Create(opt,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(30,30,36)}):Play() end)
        end
        ddBtn.MouseButton1Click:Connect(function()
            if ddPop.Visible then ddPop.Visible=false; return end
            local ap=ddBtn.AbsolutePosition; local as=ddBtn.AbsoluteSize
            ddPop.Position=UDim2.new(0,ap.X,0,ap.Y+as.Y+2); ddPop.Size=UDim2.new(0,as.X,0,0)
            AC.TS:Create(ddPop,TweenInfo.new(0.14,Enum.EasingStyle.Quint),{Size=UDim2.new(0,as.X,0,math.min(#RN_ANIMS*30,200))}):Play(); ddPop.Visible=true
        end)
    end
    local function ugcApplyFilter()
        local q=ugcSrch.Text:lower()
        for _,r in ipairs(ugcAllRows) do
            if r and r.row and r.row.Parent then
                local favOk=(not ugcFavOnly) or ugcFavs[tostring(r.id)]
                local searchOk=q=="" or r.nameLower:find(q,1,true)
                r.row.Visible=favOk and searchOk
            end
        end
    end
    local function ugcSwitchTab(tabName)
        ugcActiveTab=tabName
        for tn,tb in pairs(ugcTabBtns) do local active=(tn==tabName); AC.TS:Create(tb,TweenInfo.new(0.15),{BackgroundColor3=active and AC.PUR_DARK or Color3.fromRGB(22,22,22),BackgroundTransparency=active and 0 or 0.5}):Play(); tb.TextColor3=active and AC.TXT_WHITE or AC.TXT_DIM; tb.Font=active and Enum.Font.GothamBold or Enum.Font.Gotham end
        ugcListPage.Visible=(tabName~="States"); ugcStatesPage.Visible=(tabName=="States"); ugcSrch.Visible=(tabName~="States")
        if tabName~="States" then ugcFavOnly=(tabName=="Favs"); ugcApplyFilter() end
    end
    for tn,tb in pairs(ugcTabBtns) do local n=tn; tb.MouseButton1Click:Connect(function() ugcSwitchTab(n) end) end
    ugcSrch:GetPropertyChangedSignal("Text"):Connect(function()
        if ugcActiveTab=="States" then return end
        ugcFavOnly=(ugcActiveTab=="Favs"); ugcApplyFilter()
    end)
    AC.UIS.InputBegan:Connect(function(inp,gp)
        pcall(function()
            if gp or inp.UserInputType~=Enum.UserInputType.Keyboard then return end
            local kn=inp.KeyCode.Name; if not kn or kn=="" or kn=="Unknown" then return end
            for idStr,bk in pairs(ugcBinds) do if bk==kn then local idNum=tonumber(idStr); if idNum then playUgcEmote(idNum) end end end
        end)
    end)
    local ugcDrag,ugcDS,ugcSP=false,nil,nil
    ugcHdr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then ugcDrag=true; ugcDS=i.Position; ugcSP=ugcPanel.Position; i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then ugcDrag=false end end) end end)
    AC.UIS.InputChanged:Connect(function(i) if ugcDrag and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-ugcDS; ugcPanel.Position=UDim2.new(0,math.clamp(ugcSP.X.Offset+d.X,0,AC.camera.ViewportSize.X-UGC_W),0,math.clamp(ugcSP.Y.Offset+d.Y,0,AC.camera.ViewportSize.Y-UGC_H)) end end)
    local ugcLoaded=false
    local function loadUgcData()
        if ugcLoaded then return end; ugcLoaded=true; ugcStatusLbl.Text="Loading..."
        task.spawn(function()
            local ok,res=pcall(function() return game:HttpGet(_URLS.EMOTE_JSON) end)
            local emotes={}
            if ok and res and res~="" then
                local parsed=AC.Http:JSONDecode(res)
                for _,item in ipairs(parsed.data or {}) do
                    if tonumber(item.id) and tonumber(item.id)>0 then
                        emotes[#emotes+1]={id=tonumber(item.id),name=item.name or ("Emote_"..item.id)}
                    end
                end
            end
            ugcStatusLbl.Text="Building ("..#emotes..")"
            -- Build rows in small chunks spread over many frames so FPS never dips
            -- 20 rows per frame = barely noticeable, full list builds in ~85 frames
            local CHUNK=20
            for i=1,#emotes do
                local built=buildUgcRow(emotes[i],i)
                ugcAllRows[i]=built
                if i%CHUNK==0 then
                    ugcScroll.CanvasSize=UDim2.new(0,0,0,i*36+4)
                    task.wait()  -- yield every 20 rows
                end
            end
            ugcScroll.CanvasSize=UDim2.new(0,0,0,#emotes*36+4)
            ugcStatusLbl.Text="Ready ("..#emotes..")"
            if #emotes==0 then ugcStatusLbl.Text="No emotes found" end
        end)
    end
    -- NO pre-load on execute - only load when panel is actually opened

    ugcClsBtn.MouseButton1Click:Connect(function()
        ugcPanel.Visible=false
        stopUgcTrack()
        -- Destroy all rows to free GPU - will rebuild on next open
        for _,r in ipairs(ugcAllRows) do if r and r.row then pcall(function() r.row:Destroy() end) end end
        ugcAllRows={}
        ugcScroll.CanvasSize=UDim2.new(0,0,0,0)
        ugcLoaded=false
        ugcHighRow=nil
    end)
    AC.sectionLbl(pg,"REANIMATION",10)
    local rnMainBtn=Instance.new("TextButton",pg); rnMainBtn.Size=UDim2.new(1,-24,0,40); rnMainBtn.Position=UDim2.new(0,12,0,28); rnMainBtn.BackgroundColor3=AC.BG_CARD; rnMainBtn.Text="Reanimation"; rnMainBtn.TextColor3=AC.PUR_GLOW; rnMainBtn.TextSize=14; rnMainBtn.Font=Enum.Font.GothamBold; Instance.new("UICorner",rnMainBtn).CornerRadius=UDim.new(0,8); local rnMS=Instance.new("UIStroke",rnMainBtn); rnMS.Color=AC.PUR_STROKE; rnMS.Thickness=1.5; rnMS.Transparency=0.3
    rnMainBtn.MouseEnter:Connect(function() AC.TS:Create(rnMainBtn,TweenInfo.new(0.15),{BackgroundColor3=AC.PUR_MID}):Play() end); rnMainBtn.MouseLeave:Connect(function() AC.TS:Create(rnMainBtn,TweenInfo.new(0.15),{BackgroundColor3=AC.BG_CARD}):Play() end)
    rnMainBtn.MouseButton1Click:Connect(function() pcall(function() AC.clickSnd:Play() end); rnPanel.Visible=not rnPanel.Visible; if rnPanel.Visible then local vp=AC.camera.ViewportSize; local pos=rnPanel.Position; if pos.X.Offset<0 or pos.X.Offset>vp.X-RN_W or pos.Y.Offset<0 or pos.Y.Offset>vp.Y-RN_H then rnPanel.Position=UDim2.new(0,math.floor(vp.X/2)-RN_W/2,0,math.floor(vp.Y/2)-RN_H/2) end end end)
    AC.sectionLbl(pg,"UGC EMOTES",78)
    local ugcMainBtn=Instance.new("TextButton",pg); ugcMainBtn.Size=UDim2.new(1,-24,0,40); ugcMainBtn.Position=UDim2.new(0,12,0,96); ugcMainBtn.BackgroundColor3=AC.BG_CARD; ugcMainBtn.Text="Open Emote Menu"; ugcMainBtn.TextColor3=AC.PUR_GLOW; ugcMainBtn.TextSize=14; ugcMainBtn.Font=Enum.Font.GothamBold; Instance.new("UICorner",ugcMainBtn).CornerRadius=UDim.new(0,8); local ugcMS=Instance.new("UIStroke",ugcMainBtn); ugcMS.Color=AC.PUR_STROKE; ugcMS.Thickness=1.5; ugcMS.Transparency=0.3
    ugcMainBtn.MouseEnter:Connect(function() AC.TS:Create(ugcMainBtn,TweenInfo.new(0.15),{BackgroundColor3=AC.PUR_MID}):Play() end); ugcMainBtn.MouseLeave:Connect(function() AC.TS:Create(ugcMainBtn,TweenInfo.new(0.15),{BackgroundColor3=AC.BG_CARD}):Play() end)
    ugcMainBtn.MouseButton1Click:Connect(function()
        pcall(function() AC.clickSnd:Play() end)
        ugcPanel.Visible=not ugcPanel.Visible
        if ugcPanel.Visible then
            local vp=AC.camera.ViewportSize; local pos=ugcPanel.Position
            if pos.X.Offset<0 or pos.X.Offset>vp.X-UGC_W or pos.Y.Offset<0 or pos.Y.Offset>vp.Y-UGC_H then ugcPanel.Position=UDim2.new(0,math.floor(vp.X/2)-UGC_W/2,0,math.floor(vp.Y*0.15)) end
            if not ugcLoaded then loadUgcData() end
        end
    end)
    btn.MouseButton1Click:Connect(function() AC.switchTab("Emotes") end)
end

-- MISC TAB
do
    local btn=AC.createTab("Misc",6); local pg=AC.createPage(); AC.tabs["Misc"].page=pg
    AC.sectionLbl(pg,"MOVEMENT",10)
    local ctConn=nil
    local _,_,onCTP=AC.makeToggle(pg,"Click Teleport",28,AC.cfg.clickTp)
    onCTP(AC.cfgToggle("clickTp",function(v) if v then ctConn=AC.UIS.InputBegan:Connect(function(inp,gp) if gp then return end; if inp.UserInputType==Enum.UserInputType.MouseButton1 then local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={AC.player.Character}; local ur=AC.camera:ScreenPointToRay(inp.Position.X,inp.Position.Y); local res=AC.WS:Raycast(ur.Origin,ur.Direction*1000,params); if res then local mr=AC.player.Character and AC.player.Character:FindFirstChild("HumanoidRootPart"); if mr then mr.CFrame=CFrame.new(res.Position+Vector3.new(0,3,0)) end end end end) else if ctConn then ctConn:Disconnect(); ctConn=nil end end end))
    local _,_,onAV=AC.makeToggle(pg,"Anti-Void",74,AC.cfg.antiVoid)
    onAV(AC.cfgToggle("antiVoid",function(v) if v then AC.antiVoidConn=AC.RS.Heartbeat:Connect(function() local mr=AC.player.Character and AC.player.Character:FindFirstChild("HumanoidRootPart"); if mr and mr.Position.Y<-200 then local sp=AC.WS:FindFirstChildOfClass("SpawnLocation"); mr.CFrame=sp and sp.CFrame+Vector3.new(0,5,0) or CFrame.new(0,10,0) end end) else if AC.antiVoidConn then AC.antiVoidConn:Disconnect(); AC.antiVoidConn=nil end end end))
    AC.sectionLbl(pg,"TOOLS",128)
    AC.makeBtn(pg,"Reset Character",146,40).MouseButton1Click:Connect(function() local h=AC.player.Character and AC.player.Character:FindFirstChildOfClass("Humanoid"); if h then h.Health=0 end end)
    AC.makeBtn(pg,"Respawn in Place (.re)",192,40).MouseButton1Click:Connect(function()
        local mr=AC.player.Character and AC.player.Character:FindFirstChild("HumanoidRootPart"); local sv=mr and mr.CFrame; if not sv then return end
        local conn; conn=AC.player.CharacterAdded:Connect(function(nc) conn:Disconnect(); task.wait(0.5); local mr2=nc:WaitForChild("HumanoidRootPart",5); if mr2 then mr2.CFrame=sv; AC.toast("Respawned!",AC.GREEN_OK) end end)
        local h=AC.player.Character:FindFirstChildOfClass("Humanoid"); if h then h.Health=0 end
    end)
    -- Anti VC Ban button - opens mini panel like AK Admin style
    local vcMainBtn=Instance.new("TextButton",pg); vcMainBtn.Size=UDim2.new(1,-24,0,40); vcMainBtn.Position=UDim2.new(0,12,0,242); vcMainBtn.BackgroundColor3=AC.BG_CARD; vcMainBtn.Text="Anti-VC Ban"; vcMainBtn.TextColor3=AC.PUR_GLOW; vcMainBtn.TextSize=14; vcMainBtn.Font=Enum.Font.GothamBold; Instance.new("UICorner",vcMainBtn).CornerRadius=UDim.new(0,8); local vcMS=Instance.new("UIStroke",vcMainBtn); vcMS.Color=AC.PUR_STROKE; vcMS.Thickness=1.5; vcMS.Transparency=0.3
    vcMainBtn.MouseEnter:Connect(function() AC.TS:Create(vcMainBtn,TweenInfo.new(0.15),{BackgroundColor3=AC.PUR_MID}):Play() end)
    vcMainBtn.MouseLeave:Connect(function() AC.TS:Create(vcMainBtn,TweenInfo.new(0.15),{BackgroundColor3=AC.BG_CARD}):Play() end)

    -- Mini floating panel (AK Admin style)
    local VC_W,VC_H=260,120
    local vcPanel=Instance.new("Frame",AC.screenGui); vcPanel.Size=UDim2.new(0,VC_W,0,VC_H); vcPanel.Position=UDim2.new(0, math.floor(AC.camera.ViewportSize.X/2)-VC_W/2, 0, math.floor(AC.camera.ViewportSize.Y/2)-VC_H/2); vcPanel.BackgroundColor3=AC.BG_PANEL; vcPanel.BackgroundTransparency=0; vcPanel.ZIndex=90; vcPanel.Visible=false; vcPanel.ClipsDescendants=true; Instance.new("UICorner",vcPanel).CornerRadius=UDim.new(0,12); Instance.new("UIStroke",vcPanel).Color=AC.PUR_STROKE
    -- Header bar
    local vcHdr=Instance.new("Frame",vcPanel); vcHdr.Size=UDim2.new(1,0,0,32); vcHdr.BackgroundColor3=AC.BG_CARD; vcHdr.ZIndex=91; Instance.new("UICorner",vcHdr).CornerRadius=UDim.new(0,10)
    local vcBadge=Instance.new("TextLabel",vcHdr); vcBadge.Size=UDim2.new(0,22,0,14); vcBadge.Position=UDim2.new(0,8,0.5,-7); vcBadge.BackgroundColor3=AC.PUR_DARK; vcBadge.Text="AC"; vcBadge.TextColor3=AC.PUR_GLOW; vcBadge.TextSize=8; vcBadge.Font=Enum.Font.GothamBold; vcBadge.ZIndex=92; Instance.new("UICorner",vcBadge).CornerRadius=UDim.new(0,4)
    local vcTitleLbl=Instance.new("TextLabel",vcHdr); vcTitleLbl.Size=UDim2.new(1,-90,1,0); vcTitleLbl.Position=UDim2.new(0,34,0,0); vcTitleLbl.BackgroundTransparency=1; vcTitleLbl.Text="ANTI VC BAN"; vcTitleLbl.TextColor3=AC.TXT_WHITE; vcTitleLbl.TextSize=12; vcTitleLbl.Font=Enum.Font.GothamBold; vcTitleLbl.TextXAlignment=Enum.TextXAlignment.Left; vcTitleLbl.ZIndex=92
    -- Minimize button (makes panel tiny like AK)
    local vcMinBtn=Instance.new("TextButton",vcHdr); vcMinBtn.Size=UDim2.new(0,22,0,20); vcMinBtn.Position=UDim2.new(1,-52,0.5,-10); vcMinBtn.BackgroundColor3=Color3.fromRGB(40,40,40); vcMinBtn.Text="-"; vcMinBtn.TextColor3=AC.TXT_WHITE; vcMinBtn.TextSize=14; vcMinBtn.Font=Enum.Font.GothamBold; vcMinBtn.ZIndex=92; Instance.new("UICorner",vcMinBtn).CornerRadius=UDim.new(0,5)
    local vcClsBtn=Instance.new("TextButton",vcHdr); vcClsBtn.Size=UDim2.new(0,22,0,20); vcClsBtn.Position=UDim2.new(1,-26,0.5,-10); vcClsBtn.BackgroundColor3=Color3.fromRGB(40,40,40); vcClsBtn.Text="X"; vcClsBtn.TextColor3=AC.TXT_WHITE; vcClsBtn.TextSize=11; vcClsBtn.Font=Enum.Font.GothamBold; vcClsBtn.ZIndex=92; Instance.new("UICorner",vcClsBtn).CornerRadius=UDim.new(0,5)
    -- Activate button (the main action)
    local vcActBtn=Instance.new("TextButton",vcPanel); vcActBtn.Size=UDim2.new(1,-20,0,42); vcActBtn.Position=UDim2.new(0,10,0,40); vcActBtn.BackgroundColor3=AC.BG_CARD; vcActBtn.Text="Activate"; vcActBtn.TextColor3=AC.PUR_GLOW; vcActBtn.TextSize=14; vcActBtn.Font=Enum.Font.GothamBold; vcActBtn.ZIndex=91; Instance.new("UICorner",vcActBtn).CornerRadius=UDim.new(0,8); Instance.new("UIStroke",vcActBtn).Color=AC.PUR_STROKE
    vcActBtn.MouseEnter:Connect(function() AC.TS:Create(vcActBtn,TweenInfo.new(0.1),{BackgroundColor3=AC.PUR_DARK}):Play() end)
    vcActBtn.MouseLeave:Connect(function() AC.TS:Create(vcActBtn,TweenInfo.new(0.1),{BackgroundColor3=AC.BG_CARD}):Play() end)
    -- Draggable header
    local vcDrag,vcDS,vcSP=false,nil,nil
    vcHdr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then vcDrag=true; vcDS=i.Position; vcSP=vcPanel.Position; i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then vcDrag=false end end) end end)
    AC.UIS.InputChanged:Connect(function(i) if vcDrag and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-vcDS; local vp=AC.camera.ViewportSize; vcPanel.Position=UDim2.new(0,math.clamp(vcSP.X.Offset+d.X,0,vp.X-VC_W),0,math.clamp(vcSP.Y.Offset+d.Y,0,vp.Y-VC_H)) end end)
    -- Minimize to header-only (like AK Admin shrink)
    local vcMinimized=false
    vcMinBtn.MouseButton1Click:Connect(function()
        vcMinimized=not vcMinimized
        if vcMinimized then
            AC.TS:Create(vcPanel,TweenInfo.new(0.2,Enum.EasingStyle.Quint),{Size=UDim2.new(0,VC_W,0,32)}):Play()
        else
            AC.TS:Create(vcPanel,TweenInfo.new(0.2,Enum.EasingStyle.Quint),{Size=UDim2.new(0,VC_W,0,VC_H)}):Play()
        end
    end)
    vcClsBtn.MouseButton1Click:Connect(function() vcPanel.Visible=false; vcMinimized=false; vcPanel.Size=UDim2.new(0,VC_W,0,VC_H) end)
    -- Velocity-only warning label
    local vcWarnLbl=Instance.new("TextLabel",vcPanel); vcWarnLbl.Size=UDim2.new(1,-16,0,14); vcWarnLbl.Position=UDim2.new(0,8,0,90); vcWarnLbl.BackgroundTransparency=1; vcWarnLbl.Text="! Only works on Velocity executor"; vcWarnLbl.TextColor3=AC.RED_ERR; vcWarnLbl.TextSize=9; vcWarnLbl.Font=Enum.Font.GothamBold; vcWarnLbl.TextXAlignment=Enum.TextXAlignment.Center; vcWarnLbl.ZIndex=91
    -- Simple 3-line Velocity bypass
    vcActBtn.MouseButton1Click:Connect(function()
        vcActBtn.Text="..."; vcActBtn.TextColor3=AC.TXT_DIM
        task.spawn(function()
            local ok,err=pcall(function()
                local vin=game:GetService("VoiceChatInternal")
                firesignal(vin.TempSetMicMutedToggleMic)
                vin:PublishPause(false)
            end)
            if ok then
                vcActBtn.Text="Done!"; vcActBtn.TextColor3=AC.GREEN_OK
                AC.toast("VC bypass activated!",AC.GREEN_OK)
            else
                vcActBtn.Text="Failed"; vcActBtn.TextColor3=AC.RED_ERR
                AC.toast("VC bypass failed",AC.RED_ERR)
            end
            task.delay(2.5,function()
                vcActBtn.Text="Activate"; vcActBtn.TextColor3=AC.PUR_GLOW
            end)
        end)
    end)
    vcMainBtn.MouseButton1Click:Connect(function()
        pcall(function() AC.clickSnd:Play() end)
        vcPanel.Visible=not vcPanel.Visible
        if vcPanel.Visible then
            local vp=AC.camera.ViewportSize; local pos=vcPanel.Position
            local cx=math.clamp(pos.X.Offset,0,vp.X-VC_W); local cy=math.clamp(pos.Y.Offset,0,vp.Y-VC_H)
            vcPanel.Position=UDim2.new(0,cx,0,cy)
        end
    end)
    AC.sectionLbl(pg,"SYSTEM",314); AC.cmdListBtn=AC.makeBtn(pg,"Command List",332,40)
    AC.sectionLbl(pg,"CREDITS",384)
    local crd=AC.makeCard(pg,402,66,AC.BG_CARD)
    local cr1=Instance.new("TextLabel",crd); cr1.Size=UDim2.new(1,-16,0,20); cr1.Position=UDim2.new(0,12,0,6); cr1.BackgroundTransparency=1; cr1.Text="AC AudioCrafter V4.33  by MelodyCrafter"; cr1.TextColor3=AC.PUR_BRIGHT; cr1.TextSize=13; cr1.Font=Enum.Font.GothamBold; cr1.TextXAlignment=Enum.TextXAlignment.Left
    local cr2=Instance.new("TextLabel",crd); cr2.Size=UDim2.new(1,-16,0,14); cr2.Position=UDim2.new(0,12,0,28); cr2.BackgroundTransparency=1; cr2.Text="Inspired by IY, SystemBroken, Empty Tools, Onyx V2, AKADMIN, Bleed"; cr2.TextColor3=AC.TXT_DIM; cr2.TextSize=10; cr2.Font=Enum.Font.Gotham; cr2.TextXAlignment=Enum.TextXAlignment.Left
    btn.MouseButton1Click:Connect(function() AC.switchTab("Misc") end)
end

-- EXTERNAL + COMMAND LIST
do
    local extSep=Instance.new("Frame",AC.sideScroll); extSep.Size=UDim2.new(1,-16,0,1); extSep.BackgroundColor3=AC.PUR_STROKE; extSep.BackgroundTransparency=0.4; extSep.LayoutOrder=90
    local extLbl=Instance.new("TextLabel",AC.sideScroll); extLbl.Size=UDim2.new(1,-16,0,16); extLbl.BackgroundTransparency=1; extLbl.Text="EXTERNAL"; extLbl.TextColor3=AC.ORANGE_W; extLbl.TextSize=9; extLbl.Font=Enum.Font.GothamBold; extLbl.TextXAlignment=Enum.TextXAlignment.Left; extLbl.LayoutOrder=91
    local iyBtn=AC.createTab("Infinite Yield",92,true)
    iyBtn.MouseButton1Click:Connect(function() AC.toast("Loading IY...",AC.ORANGE_W); task.spawn(function() pcall(function() safeRun("INF_YIELD") end) end) end)
    local CMDS={{".view","Spectate target"},{".tp [name]","TP to player"},{".cleartarget","Clear target"},{".esp","Toggle ESP"},{".fly","Toggle Fly"},{".noclip","Toggle Noclip"},{".fullbright","Toggle Fullbright"},{".shaders","Toggle Shaders"},{".baseplate","Toggle Baseplate"},{".antivoid","Toggle Anti-Void"},{".antiafk","Toggle Anti-AFK"},{".re","Respawn in place"},{".reset","Reset character"},{".minimize","Toggle GUI"},{".cmds","Command List"},{".hide [n]","Hide player"},{".unhide [n]","Unhide player"},{".rj","Rejoin server"}}
    local cp=Instance.new("Frame",AC.screenGui); cp.Size=UDim2.new(0,340,0,480); cp.Position=UDim2.new(0, math.floor(AC.camera.ViewportSize.X/2)-170, 0, math.floor(AC.camera.ViewportSize.Y/2)-240); cp.BackgroundColor3=Color3.fromRGB(10,10,10); cp.ZIndex=50; cp.Visible=false; cp.ClipsDescendants=true; Instance.new("UICorner",cp).CornerRadius=UDim.new(0,12); Instance.new("UIStroke",cp).Color=AC.PUR_STROKE
    local cph=Instance.new("Frame",cp); cph.Size=UDim2.new(1,0,0,40); cph.BackgroundColor3=Color3.fromRGB(6,6,6); cph.ZIndex=51; Instance.new("UICorner",cph).CornerRadius=UDim.new(0,12)
    local cpt=Instance.new("TextLabel",cph); cpt.Size=UDim2.new(1,-50,1,0); cpt.Position=UDim2.new(0,14,0,0); cpt.BackgroundTransparency=1; cpt.Text="  Command List"; cpt.TextColor3=AC.TXT_WHITE; cpt.TextSize=14; cpt.Font=Enum.Font.GothamBold; cpt.TextXAlignment=Enum.TextXAlignment.Left; cpt.ZIndex=52
    local cpX=Instance.new("TextButton",cph); cpX.Size=UDim2.new(0,26,0,26); cpX.Position=UDim2.new(1,-32,0.5,-13); cpX.BackgroundColor3=AC.PUR_MID; cpX.Text="X"; cpX.TextColor3=AC.TXT_WHITE; cpX.TextSize=12; cpX.Font=Enum.Font.GothamBold; cpX.ZIndex=52; Instance.new("UICorner",cpX).CornerRadius=UDim.new(1,0); cpX.MouseButton1Click:Connect(function() cp.Visible=false end)
    local cps=Instance.new("ScrollingFrame",cp); cps.Size=UDim2.new(1,-8,1,-48); cps.Position=UDim2.new(0,4,0,44); cps.BackgroundTransparency=1; cps.BorderSizePixel=0; cps.ScrollBarThickness=3; cps.ScrollBarImageColor3=AC.PUR_MID; cps.AutomaticCanvasSize=Enum.AutomaticSize.Y; cps.CanvasSize=UDim2.new(0,0,0,0); cps.ZIndex=51
    local cpl=Instance.new("UIListLayout",cps); cpl.Padding=UDim.new(0,2); local cpp=Instance.new("UIPadding",cps); cpp.PaddingTop=UDim.new(0,4); cpp.PaddingLeft=UDim.new(0,4); cpp.PaddingRight=UDim.new(0,4)
    for i,cd in ipairs(CMDS) do
        local row=Instance.new("TextButton",cps); row.Size=UDim2.new(1,0,0,42); row.BackgroundColor3=Color3.fromRGB(16,16,16); row.Text=""; row.LayoutOrder=i; row.ZIndex=52; Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
        local cl=Instance.new("TextLabel",row); cl.Size=UDim2.new(1,-16,0,18); cl.Position=UDim2.new(0,12,0,4); cl.BackgroundTransparency=1; cl.Text=cd[1]; cl.TextColor3=AC.PUR_BRIGHT; cl.TextSize=13; cl.Font=Enum.Font.GothamBold; cl.TextXAlignment=Enum.TextXAlignment.Left; cl.ZIndex=53
        local dl=Instance.new("TextLabel",row); dl.Size=UDim2.new(1,-16,0,14); dl.Position=UDim2.new(0,12,0,22); dl.BackgroundTransparency=1; dl.Text=cd[2]; dl.TextColor3=AC.TXT_DIM; dl.TextSize=11; dl.Font=Enum.Font.Gotham; dl.TextXAlignment=Enum.TextXAlignment.Left; dl.ZIndex=53
        row.MouseEnter:Connect(function() AC.TS:Create(row,TweenInfo.new(0.12),{BackgroundColor3=AC.PUR_DARK}):Play() end); row.MouseLeave:Connect(function() AC.TS:Create(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(16,16,16)}):Play() end)
    end
    local cpDrag,cpDS,cpSP=false,nil,nil
    cph.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then cpDrag=true; cpDS=i.Position; cpSP=cp.Position; i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then cpDrag=false end end) end end)
    AC.UIS.InputChanged:Connect(function(i) if cpDrag and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-cpDS; cp.Position=UDim2.new(cpSP.X.Scale,cpSP.X.Offset+d.X,cpSP.Y.Scale,cpSP.Y.Offset+d.Y) end end)
    AC.cmdListBtn.MouseButton1Click:Connect(function() cp.Visible=not cp.Visible end)
    local hiddenChars={}
    local function handleChat(msg)
        msg=msg:lower():gsub("^%s+",""); local args={}; for w in msg:gmatch("%S+") do args[#args+1]=w end
        local cmd=args[1]; if not cmd or cmd:sub(1,1)~="." then return end
        if cmd==".view" then if AC.selectedTarget then AC.startViewing(AC.selectedTarget) end
        elseif cmd==".tp" then local n=args[2]; local tgt=AC.selectedTarget; if n then for _,p in ipairs(AC.Players:GetPlayers()) do if p.Name:lower():find(n,1,true) then tgt=p; break end end end; if tgt and tgt.Character then local r=tgt.Character:FindFirstChild("HumanoidRootPart"); local m=AC.player.Character and AC.player.Character:FindFirstChild("HumanoidRootPart"); if r and m then m.CFrame=r.CFrame*CFrame.new(0,0,-3); AC.toast("TP'd to "..tgt.Name) end end
        elseif cmd==".cleartarget" then AC.stopViewing(); AC.onHead=false; AC.inBp=false; AC.selectedTarget=nil; if AC.sBox then AC.sBox.Text="" end
        elseif cmd==".fly" then if AC.flyActive then AC.flyActive=false; if AC.flyConn then AC.flyConn:Disconnect(); AC.flyConn=nil end; if AC.flyBV then AC.flyBV:Destroy(); AC.flyBV=nil end; if AC.flyBG then AC.flyBG:Destroy(); AC.flyBG=nil end; if AC._flyAtt then AC._flyAtt:Destroy(); AC._flyAtt=nil end; local h=AC.player.Character and AC.player.Character:FindFirstChildOfClass("Humanoid"); if h then h.PlatformStand=false end else AC.flyActive=true end
        elseif cmd==".noclip" then if AC.noclipConn then AC.noclipConn:Disconnect(); AC.noclipConn=nil; if AC.player.Character then for _,p in ipairs(AC.player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end else AC.noclipConn=AC.RS.Stepped:Connect(function() local char=AC.player.Character; if not char then return end; for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end) end
        elseif cmd==".fullbright" then local v=not(AC.Lighting.Brightness>1); AC.Lighting.Brightness=v and 2 or 1; AC.Lighting.GlobalShadows=not v; AC.Lighting.Ambient=v and Color3.new(1,1,1) or Color3.fromRGB(127,127,127); AC.Lighting.OutdoorAmbient=v and Color3.new(1,1,1) or Color3.fromRGB(127,127,127)
        elseif cmd==".re" then local mr=AC.player.Character and AC.player.Character:FindFirstChild("HumanoidRootPart"); local sv=mr and mr.CFrame; if sv then local conn2; conn2=AC.player.CharacterAdded:Connect(function(nc) conn2:Disconnect(); task.wait(0.5); local mr3=nc:WaitForChild("HumanoidRootPart",5); if mr3 then mr3.CFrame=sv; AC.toast("Respawned!",AC.GREEN_OK) end end); local hh=AC.player.Character:FindFirstChildOfClass("Humanoid"); if hh then hh.Health=0 end end
        elseif cmd==".reset" then local h=AC.player.Character and AC.player.Character:FindFirstChildOfClass("Humanoid"); if h then h.Health=0 end
        elseif cmd==".minimize" then if AC._uiOpen then AC.doMin() else AC.doOpen() end
        elseif cmd==".cmds" then cp.Visible=not cp.Visible
        elseif cmd==".hide" then local n=args[2]; if n then for _,p in ipairs(AC.Players:GetPlayers()) do if p.Name:lower()==n and p.Character then for _,part in ipairs(p.Character:GetDescendants()) do if part:IsA("BasePart") or part:IsA("Decal") then part.LocalTransparencyModifier=1 end end; hiddenChars[p.UserId]=true end end end
        elseif cmd==".unhide" then local n=args[2]; if n then for _,p in ipairs(AC.Players:GetPlayers()) do if p.Name:lower()==n and p.Character then for _,part in ipairs(p.Character:GetDescendants()) do if part:IsA("BasePart") or part:IsA("Decal") then part.LocalTransparencyModifier=0 end end; hiddenChars[p.UserId]=nil end end end
        elseif cmd==".rj" then AC.toast("Rejoining..."); task.spawn(function() task.wait(0.5); game:GetService("TeleportService"):Teleport(game.PlaceId) end)
        elseif cmd==".antivoid" then if AC.antiVoidConn then AC.antiVoidConn:Disconnect(); AC.antiVoidConn=nil else AC.antiVoidConn=AC.RS.Heartbeat:Connect(function() local mr=AC.player.Character and AC.player.Character:FindFirstChild("HumanoidRootPart"); if mr and mr.Position.Y<-200 then mr.CFrame=CFrame.new(0,10,0) end end) end
        elseif cmd==".antiafk" then if AC.afkThread then task.cancel(AC.afkThread); AC.afkThread=nil else local vu=game:GetService("VirtualUser"); AC.afkThread=task.spawn(function() while true do pcall(function() vu:Button2Down(Vector2.new(0,0),CFrame.new()); task.wait(0.1); vu:Button2Up(Vector2.new(0,0),CFrame.new()) end); task.wait(55) end end) end
        end
    end
    AC.player.Chatted:Connect(function(msg) if msg:sub(1,1)=="." then handleChat(msg) end end)
    pcall(function() local TCS=game:GetService("TextChatService"); if TCS.ChatVersion==Enum.ChatVersion.TextChatService then TCS.SendingMessage:Connect(function(msg) if msg.Text:sub(1,1)=="." then handleChat(msg.Text) end end) end end)
end

-- FACBANG PANEL  (v3.8)
do
    local fbSep=Instance.new("Frame",AC.sideScroll); fbSep.Size=UDim2.new(1,-16,0,1); fbSep.BackgroundColor3=AC.PUR_STROKE; fbSep.BackgroundTransparency=0.4; fbSep.LayoutOrder=93
    local fbBtn=AC.createTab("FaceBang",94,true)
    if AC.tabs["FaceBang"] then
        if AC.tabs["FaceBang"].dot then AC.tabs["FaceBang"].dot.BackgroundColor3=AC.PUR_BRIGHT end
        if AC.tabs["FaceBang"].lbl then AC.tabs["FaceBang"].lbl.TextColor3=AC.PUR_GLOW end
        if AC.tabs["FaceBang"].acc then AC.tabs["FaceBang"].acc.BackgroundColor3=AC.PUR_BRIGHT end
    end

    local FB_W,FB_H=280,258
    local fbPanel=Instance.new("Frame",AC.screenGui)
    fbPanel.Size=UDim2.new(0,FB_W,0,FB_H)
    fbPanel.Position=UDim2.new(0, math.floor(AC.camera.ViewportSize.X/2)-FB_W/2, 0, math.floor(AC.camera.ViewportSize.Y/2)-FB_H/2)
    fbPanel.BackgroundColor3=AC.BG_PANEL; fbPanel.BackgroundTransparency=0
    fbPanel.ZIndex=80; fbPanel.Visible=false; fbPanel.ClipsDescendants=true
    Instance.new("UICorner",fbPanel).CornerRadius=UDim.new(0,12)
    local fbStroke=Instance.new("UIStroke",fbPanel); fbStroke.Color=AC.PUR_STROKE; fbStroke.Thickness=1.5; fbStroke.Transparency=0.2
    AC.TS:Create(fbStroke,TweenInfo.new(1.4,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Color=AC.PUR_DARK,Transparency=0.5}):Play()

    -- Header bar
    local fbHdr=Instance.new("Frame",fbPanel); fbHdr.Size=UDim2.new(1,0,0,38); fbHdr.BackgroundColor3=AC.BG_CARD; fbHdr.BackgroundTransparency=0; fbHdr.ZIndex=81; Instance.new("UICorner",fbHdr).CornerRadius=UDim.new(0,10)
    local fbHdrLine=Instance.new("Frame",fbHdr); fbHdrLine.Size=UDim2.new(1,0,0,1); fbHdrLine.Position=UDim2.new(0,0,1,-1); fbHdrLine.BackgroundColor3=AC.PUR_STROKE; fbHdrLine.BorderSizePixel=0
    local fbTitle=Instance.new("TextLabel",fbHdr); fbTitle.Size=UDim2.new(1,-50,1,0); fbTitle.Position=UDim2.new(0,14,0,0); fbTitle.BackgroundTransparency=1; fbTitle.Text="★  FaceBang"; fbTitle.TextColor3=AC.TXT_WHITE; fbTitle.TextSize=15; fbTitle.Font=Enum.Font.GothamBold; fbTitle.TextXAlignment=Enum.TextXAlignment.Left; fbTitle.ZIndex=82
    local fbMin=Instance.new("TextButton",fbHdr); fbMin.Size=UDim2.new(0,24,0,24); fbMin.Position=UDim2.new(1,-30,0.5,-12); fbMin.BackgroundColor3=Color3.fromRGB(40,40,40); fbMin.Text="-"; fbMin.TextColor3=AC.TXT_WHITE; fbMin.TextSize=16; fbMin.Font=Enum.Font.GothamBold; fbMin.ZIndex=82; Instance.new("UICorner",fbMin).CornerRadius=UDim.new(0,6)
    fbMin.MouseEnter:Connect(function() AC.TS:Create(fbMin,TweenInfo.new(0.1),{BackgroundColor3=AC.PUR_DARK}):Play() end)
    fbMin.MouseLeave:Connect(function() AC.TS:Create(fbMin,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(40,40,40)}):Play() end)
    fbMin.MouseButton1Click:Connect(function() fbPanel.Visible=false end)

    -- Draggable header - clamp so it never flies off screen
    local fbDrag,fbDS,fbSP=false,nil,nil
    fbHdr.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            fbDrag=true; fbDS=i.Position; fbSP=fbPanel.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then fbDrag=false end end)
        end
    end)
    AC.UIS.InputChanged:Connect(function(i)
        if fbDrag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-fbDS
            local vp=AC.camera.ViewportSize
            local nx=math.clamp(fbSP.X.Offset+d.X, 0, vp.X-FB_W)
            local ny=math.clamp(fbSP.Y.Offset+d.Y, 0, vp.Y-FB_H)
            fbPanel.Position=UDim2.new(0,nx,0,ny)
        end
    end)

    -- Status line
    local fbStatus=Instance.new("TextLabel",fbPanel); fbStatus.Size=UDim2.new(1,-16,0,14); fbStatus.Position=UDim2.new(0,8,0,44); fbStatus.BackgroundTransparency=1; fbStatus.Text="Target: none  |  Status: OFF"; fbStatus.TextColor3=AC.TXT_DIM; fbStatus.TextSize=10; fbStatus.Font=Enum.Font.GothamBold; fbStatus.TextXAlignment=Enum.TextXAlignment.Left; fbStatus.ZIndex=81

    -- Keybind card
    local fbBindCard=Instance.new("Frame",fbPanel); fbBindCard.Size=UDim2.new(1,-16,0,36); fbBindCard.Position=UDim2.new(0,8,0,62); fbBindCard.BackgroundColor3=AC.BG_CARD; fbBindCard.ZIndex=81; Instance.new("UICorner",fbBindCard).CornerRadius=UDim.new(0,8); Instance.new("UIStroke",fbBindCard).Color=AC.PUR_STROKE
    local fbBindLbl=Instance.new("TextLabel",fbBindCard); fbBindLbl.Size=UDim2.new(0,80,1,0); fbBindLbl.Position=UDim2.new(0,10,0,0); fbBindLbl.BackgroundTransparency=1; fbBindLbl.Text="Keybind:"; fbBindLbl.TextColor3=AC.TXT_MAIN; fbBindLbl.TextSize=12; fbBindLbl.Font=Enum.Font.GothamBold; fbBindLbl.TextXAlignment=Enum.TextXAlignment.Left; fbBindLbl.ZIndex=82
    local fbBindBtn=Instance.new("TextButton",fbBindCard); fbBindBtn.Size=UDim2.new(0,80,0,26); fbBindBtn.Position=UDim2.new(1,-88,0.5,-13); fbBindBtn.BackgroundColor3=AC.BG_PANEL; fbBindBtn.Text="Bind"; fbBindBtn.TextColor3=AC.PUR_GLOW; fbBindBtn.TextSize=12; fbBindBtn.Font=Enum.Font.GothamBold; fbBindBtn.ZIndex=82; Instance.new("UICorner",fbBindBtn).CornerRadius=UDim.new(0,6); Instance.new("UIStroke",fbBindBtn).Color=AC.PUR_STROKE
    fbBindBtn.MouseEnter:Connect(function() AC.TS:Create(fbBindBtn,TweenInfo.new(0.1),{BackgroundColor3=AC.PUR_DARK}):Play() end)
    fbBindBtn.MouseLeave:Connect(function() AC.TS:Create(fbBindBtn,TweenInfo.new(0.1),{BackgroundColor3=AC.BG_PANEL}):Play() end)

    local fbKey=nil; local fbBindListening=false; local fbBindConn=nil
    fbBindBtn.MouseButton1Click:Connect(function()
        if fbBindListening then
            fbBindListening=false; if fbBindConn then fbBindConn:Disconnect(); fbBindConn=nil end
            fbBindBtn.Text=fbKey and "["..fbKey:sub(1,4).."]" or "Bind"
            fbBindBtn.TextColor3=fbKey and AC.TXT_WHITE or AC.PUR_GLOW; return
        end
        fbBindListening=true; fbBindBtn.Text="..."; fbBindBtn.TextColor3=AC.ORANGE_W
        fbBindConn=AC.UIS.InputBegan:Connect(function(inp,gp)
            if gp or inp.UserInputType~=Enum.UserInputType.Keyboard then return end
            local ok2,kn=pcall(function() return inp.KeyCode.Name end)
            if not ok2 or not kn or kn=="" or kn=="Unknown" then return end
            if kn=="Escape" then
                fbBindListening=false; if fbBindConn then fbBindConn:Disconnect(); fbBindConn=nil end
                fbBindBtn.Text=fbKey and "["..fbKey:sub(1,4).."]" or "Bind"
                fbBindBtn.TextColor3=fbKey and AC.TXT_WHITE or AC.PUR_GLOW; return
            end
            fbKey=kn; fbBindBtn.Text="["..kn:sub(1,4).."]"; fbBindBtn.TextColor3=AC.TXT_WHITE
            fbBindListening=false; if fbBindConn then fbBindConn:Disconnect(); fbBindConn=nil end
            AC.toast("FaceBang bound to ["..kn.."]",AC.PUR_BRIGHT)
        end)
    end)

    -- Distance slider
    local fbDistLbl=Instance.new("TextLabel",fbPanel); fbDistLbl.Size=UDim2.new(0,140,0,14); fbDistLbl.Position=UDim2.new(0,10,0,108); fbDistLbl.BackgroundTransparency=1; fbDistLbl.Text="Thrust Distance:"; fbDistLbl.TextColor3=AC.TXT_MAIN; fbDistLbl.TextSize=11; fbDistLbl.Font=Enum.Font.GothamBold; fbDistLbl.ZIndex=81
    local fbDistVal=Instance.new("TextLabel",fbPanel); fbDistVal.Size=UDim2.new(0,30,0,14); fbDistVal.Position=UDim2.new(1,-40,0,108); fbDistVal.BackgroundTransparency=1; fbDistVal.Text="3"; fbDistVal.TextColor3=AC.PUR_GLOW; fbDistVal.TextSize=11; fbDistVal.Font=Enum.Font.GothamBold; fbDistVal.ZIndex=81
    local fbDistTrk=Instance.new("Frame",fbPanel); fbDistTrk.Size=UDim2.new(1,-16,0,6); fbDistTrk.Position=UDim2.new(0,8,0,126); fbDistTrk.BackgroundColor3=Color3.fromRGB(30,30,30); fbDistTrk.ZIndex=81; Instance.new("UICorner",fbDistTrk).CornerRadius=UDim.new(1,0)
    local fbDistFil=Instance.new("Frame",fbDistTrk); fbDistFil.Size=UDim2.new(0.18,0,1,0); fbDistFil.BackgroundColor3=AC.PUR_MID; fbDistFil.ZIndex=82; Instance.new("UICorner",fbDistFil).CornerRadius=UDim.new(1,0)
    local fbDistKnob=Instance.new("TextButton",fbDistTrk); fbDistKnob.Size=UDim2.new(0,14,0,14); fbDistKnob.Position=UDim2.new(0.18,-7,0.5,-7); fbDistKnob.BackgroundColor3=AC.PUR_GLOW; fbDistKnob.Text=""; fbDistKnob.ZIndex=83; Instance.new("UICorner",fbDistKnob).CornerRadius=UDim.new(1,0)
    local fbDist=3; local _fbDDC=nil
    local function setFbDist(v) v=math.clamp(math.floor(v+0.5),1,8); fbDist=v; fbDistVal.Text=tostring(v); local r=(v-1)/7; fbDistFil.Size=UDim2.new(r,0,1,0); fbDistKnob.Position=UDim2.new(r,-7,0.5,-7) end
    fbDistKnob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then _fbDDC=AC.RS.RenderStepped:Connect(function() setFbDist(1+(AC.UIS:GetMouseLocation().X-fbDistTrk.AbsolutePosition.X)/fbDistTrk.AbsoluteSize.X*7) end) end end)
    fbDistTrk.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then setFbDist(1+(AC.UIS:GetMouseLocation().X-fbDistTrk.AbsolutePosition.X)/fbDistTrk.AbsoluteSize.X*7); if not _fbDDC then _fbDDC=AC.RS.RenderStepped:Connect(function() setFbDist(1+(AC.UIS:GetMouseLocation().X-fbDistTrk.AbsolutePosition.X)/fbDistTrk.AbsoluteSize.X*7) end) end end end)
    AC.UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 and _fbDDC then _fbDDC:Disconnect(); _fbDDC=nil end end)
    setFbDist(3)

    -- Speed slider
    local fbSpdLbl=Instance.new("TextLabel",fbPanel); fbSpdLbl.Size=UDim2.new(0,140,0,14); fbSpdLbl.Position=UDim2.new(0,10,0,148); fbSpdLbl.BackgroundTransparency=1; fbSpdLbl.Text="Thrust Speed:"; fbSpdLbl.TextColor3=AC.TXT_MAIN; fbSpdLbl.TextSize=11; fbSpdLbl.Font=Enum.Font.GothamBold; fbSpdLbl.ZIndex=81
    local fbSpdVal=Instance.new("TextLabel",fbPanel); fbSpdVal.Size=UDim2.new(0,30,0,14); fbSpdVal.Position=UDim2.new(1,-40,0,148); fbSpdVal.BackgroundTransparency=1; fbSpdVal.Text="5"; fbSpdVal.TextColor3=AC.PUR_GLOW; fbSpdVal.TextSize=11; fbSpdVal.Font=Enum.Font.GothamBold; fbSpdVal.ZIndex=81
    local fbSpdTrk=Instance.new("Frame",fbPanel); fbSpdTrk.Size=UDim2.new(1,-16,0,6); fbSpdTrk.Position=UDim2.new(0,8,0,166); fbSpdTrk.BackgroundColor3=Color3.fromRGB(30,30,30); fbSpdTrk.ZIndex=81; Instance.new("UICorner",fbSpdTrk).CornerRadius=UDim.new(1,0)
    local fbSpdFil=Instance.new("Frame",fbSpdTrk); fbSpdFil.Size=UDim2.new(0.33,0,1,0); fbSpdFil.BackgroundColor3=AC.PUR_MID; fbSpdFil.ZIndex=82; Instance.new("UICorner",fbSpdFil).CornerRadius=UDim.new(1,0)
    local fbSpdKnob=Instance.new("TextButton",fbSpdTrk); fbSpdKnob.Size=UDim2.new(0,14,0,14); fbSpdKnob.Position=UDim2.new(0.33,-7,0.5,-7); fbSpdKnob.BackgroundColor3=AC.PUR_GLOW; fbSpdKnob.Text=""; fbSpdKnob.ZIndex=83; Instance.new("UICorner",fbSpdKnob).CornerRadius=UDim.new(1,0)
    local fbSpd=5; local _fbSDC=nil
    local function setFbSpd(v) v=math.clamp(math.floor(v+0.5),1,16); fbSpd=v; fbSpdVal.Text=tostring(v); local r=(v-1)/15; fbSpdFil.Size=UDim2.new(r,0,1,0); fbSpdKnob.Position=UDim2.new(r,-7,0.5,-7) end
    fbSpdKnob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then _fbSDC=AC.RS.RenderStepped:Connect(function() setFbSpd(1+(AC.UIS:GetMouseLocation().X-fbSpdTrk.AbsolutePosition.X)/fbSpdTrk.AbsoluteSize.X*15) end) end end)
    fbSpdTrk.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then setFbSpd(1+(AC.UIS:GetMouseLocation().X-fbSpdTrk.AbsolutePosition.X)/fbSpdTrk.AbsoluteSize.X*15); if not _fbSDC then _fbSDC=AC.RS.RenderStepped:Connect(function() setFbSpd(1+(AC.UIS:GetMouseLocation().X-fbSpdTrk.AbsolutePosition.X)/fbSpdTrk.AbsoluteSize.X*15) end) end end end)
    AC.UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 and _fbSDC then _fbSDC:Disconnect(); _fbSDC=nil end end)
    setFbSpd(5)

    -- Active toggle card
    local fbActiveBg=Instance.new("Frame",fbPanel); fbActiveBg.Size=UDim2.new(1,-16,0,40); fbActiveBg.Position=UDim2.new(0,8,0,186); fbActiveBg.BackgroundColor3=AC.BG_CARD; fbActiveBg.ZIndex=81; Instance.new("UICorner",fbActiveBg).CornerRadius=UDim.new(0,8); Instance.new("UIStroke",fbActiveBg).Color=AC.PUR_STROKE
    local fbActiveLbl=Instance.new("TextLabel",fbActiveBg); fbActiveLbl.Size=UDim2.new(1,-60,1,0); fbActiveLbl.Position=UDim2.new(0,12,0,0); fbActiveLbl.BackgroundTransparency=1; fbActiveLbl.Text="FaceBang Active"; fbActiveLbl.TextColor3=AC.TXT_MAIN; fbActiveLbl.TextSize=13; fbActiveLbl.Font=Enum.Font.GothamBold; fbActiveLbl.TextXAlignment=Enum.TextXAlignment.Left; fbActiveLbl.ZIndex=82
    local fbTrk=Instance.new("TextButton",fbActiveBg); fbTrk.Size=UDim2.new(0,44,0,24); fbTrk.Position=UDim2.new(1,-54,0.5,-12); fbTrk.BackgroundColor3=Color3.fromRGB(40,40,40); fbTrk.Text=""; fbTrk.ZIndex=82; Instance.new("UICorner",fbTrk).CornerRadius=UDim.new(1,0)
    local fbKnob=Instance.new("Frame",fbTrk); fbKnob.Size=UDim2.new(0,18,0,18); fbKnob.Position=UDim2.new(0,3,0.5,-9); fbKnob.BackgroundColor3=AC.TXT_DIM; Instance.new("UICorner",fbKnob).CornerRadius=UDim.new(1,0)

    -- Yellow warning (kept, red info removed)
    local fbWarn=Instance.new("TextLabel",fbPanel); fbWarn.Size=UDim2.new(1,-16,0,14); fbWarn.Position=UDim2.new(0,8,0,234); fbWarn.BackgroundTransparency=1; fbWarn.Text="! Disable noclip for best results"; fbWarn.TextColor3=AC.ORANGE_W; fbWarn.TextSize=9; fbWarn.Font=Enum.Font.GothamBold; fbWarn.TextXAlignment=Enum.TextXAlignment.Left; fbWarn.ZIndex=81

    -- Core FacBang logic
    -- FIX: oscillation is clamped so t never exceeds pi/2 each direction.
    -- We track a "phase" that goes 0->1->0 using math.abs(math.sin(t)) but
    -- clamp the full multiplier to [0, fbDist] so the player ALWAYS stays
    -- IN FRONT of the face (never behind). The facing direction is forced
    -- via CFrame.new(pos, lookAt) so we always look at the target head.
    local fbActive=false; local fbConn=nil; local fbLastTarget=nil
    local function fbGetNearestPlayer()
        local myChar=AC.player.Character; if not myChar then return nil end
        local myRoot=myChar:FindFirstChild("HumanoidRootPart"); if not myRoot then return nil end
        local best=nil; local bestDist=math.huge
        for _,p in ipairs(AC.Players:GetPlayers()) do
            if p~=AC.player and p.Character then
                local r=p.Character:FindFirstChild("HumanoidRootPart"); if r then
                    local d=(r.Position-myRoot.Position).Magnitude
                    if d<bestDist then bestDist=d; best=p end
                end
            end
        end
        return best
    end
    local function fbStop()
        fbActive=false
        if fbConn then fbConn:Disconnect(); fbConn=nil end
        local myChar=AC.player.Character
        if myChar then
            local mr=myChar:FindFirstChild("HumanoidRootPart")
            local hum=myChar:FindFirstChildOfClass("Humanoid")
            if mr then
                -- Zero out all velocity BEFORE releasing PlatformStand
                -- This prevents the fling from accumulated CFrame movement
                pcall(function() mr.AssemblyLinearVelocity=Vector3.zero end)
                pcall(function() mr.AssemblyAngularVelocity=Vector3.zero end)
                -- Snap upright so physics resumes from a clean standing pose
                local safePos=mr.CFrame.Position
                mr.CFrame=CFrame.new(safePos)*CFrame.Angles(0,select(2,mr.CFrame:ToEulerAnglesYXZ()),0)
            end
            -- Small delay so velocity zeroing takes effect before physics resumes
            task.defer(function()
                pcall(function()
                    if myChar and myChar.Parent then
                        local h2=myChar:FindFirstChildOfClass("Humanoid")
                        if h2 then
                            h2.PlatformStand=false
                            pcall(function() h2:ChangeState(Enum.HumanoidStateType.GettingUp) end)
                        end
                        local mr2=myChar:FindFirstChild("HumanoidRootPart")
                        if mr2 then
                            pcall(function() mr2.AssemblyLinearVelocity=Vector3.zero end)
                        end
                    end
                end)
            end)
        end
        AC.TS:Create(fbTrk,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(40,40,40)}):Play()
        AC.TS:Create(fbKnob,TweenInfo.new(0.2),{Position=UDim2.new(0,3,0.5,-9),BackgroundColor3=AC.TXT_DIM}):Play()
        fbStatus.Text="Target: none  |  Status: OFF"; fbLastTarget=nil
        AC.toast("FaceBang OFF",AC.ORANGE_W)
    end
    local function fbStart()
        local tgt=fbGetNearestPlayer(); if not tgt or not tgt.Character then AC.toast("No nearby player!",AC.RED_ERR); return end
        local tHead=tgt.Character:FindFirstChild("Head"); if not tHead then AC.toast("Target has no head",AC.RED_ERR); return end
        local myChar=AC.player.Character; if not myChar then return end
        local myRoot=myChar:FindFirstChild("HumanoidRootPart"); if not myRoot then return end
        local myHum=myChar:FindFirstChildOfClass("Humanoid"); if myHum then myHum.PlatformStand=true end
        fbActive=true; fbLastTarget=tgt
        AC.TS:Create(fbTrk,TweenInfo.new(0.2),{BackgroundColor3=AC.PUR_MID}):Play()
        AC.TS:Create(fbKnob,TweenInfo.new(0.2),{Position=UDim2.new(1,-21,0.5,-9),BackgroundColor3=AC.PUR_GLOW}):Play()
        fbStatus.Text="Target: "..tgt.Name.."  |  Status: ON"
        AC.toast("FaceBang ON  ->  "..tgt.Name,AC.PUR_BRIGHT)
        local t=0
        fbConn=AC.RS.Heartbeat:Connect(function(dt)
            if not fbActive then return end
            if not fbLastTarget or not fbLastTarget.Character then fbStop(); return end
            local th=fbLastTarget.Character:FindFirstChild("Head")
            local mr=myChar:FindFirstChild("HumanoidRootPart")
            if not th or not mr then fbStop(); return end
            t=t+dt*fbSpd
            -- math.abs(math.sin) produces 0->1->0, multiply by fbDist
            -- FIX: offset is POSITIVE (in front of face), never negative.
            -- faceFwd points OUT from the face. We start AT facePos and
            -- step back toward the face by osc*fbDist studs, clamped >= 0.
            local osc=math.abs(math.sin(t))           -- always 0..1
            local pull=math.clamp(osc*fbDist, 0, fbDist) -- always 0..fbDist (in front)
            local headPos=th.CFrame.Position
            local faceFwd=th.CFrame.LookVector         -- direction face points
            -- stand in front of face at distance pull (0=touching, fbDist=far)
            -- "in front" means along +LookVector from head
            local targetPos=headPos + faceFwd*(1.8 + pull)
            mr.CFrame=CFrame.new(targetPos, headPos)
        end)
    end
    fbTrk.MouseButton1Click:Connect(function()
        pcall(function() AC.clickSnd:Play() end)
        if fbActive then fbStop() else fbStart() end
    end)
    -- Global keybind
    AC.UIS.InputBegan:Connect(function(inp,gp)
        pcall(function()
            if gp or inp.UserInputType~=Enum.UserInputType.Keyboard then return end
            if not fbKey then return end
            local kn=inp.KeyCode.Name
            if not kn or kn=="" or kn=="Unknown" then return end
            if kn==fbKey then if fbActive then fbStop() else fbStart() end end
        end)
    end)
    -- Open panel via sidebar
    fbBtn.MouseButton1Click:Connect(function()
        fbPanel.Visible=not fbPanel.Visible
        if fbPanel.Visible then
            local vp=AC.camera.ViewportSize
            local pos=fbPanel.Position
            local cx=math.clamp(pos.X.Offset, 0, vp.X-FB_W)
            local cy=math.clamp(pos.Y.Offset, 0, vp.Y-FB_H)
            fbPanel.Position=UDim2.new(0,cx,0,cy)
        end
    end)
end

-- QUICK BAR
do
    local qBar=Instance.new("Frame",AC.screenGui); qBar.Size=UDim2.new(0,186,0,44); qBar.Position=UDim2.new(0,10,1,-62); qBar.BackgroundColor3=Color3.fromRGB(8,8,8); qBar.BackgroundTransparency=0.15; qBar.ZIndex=400; qBar.ClipsDescendants=false; Instance.new("UICorner",qBar).CornerRadius=UDim.new(1,0); Instance.new("UIStroke",qBar).Color=AC.PUR_STROKE
    local qDrag,qDS,qSP=false,nil,nil
    qBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then qDrag=true; qDS=i.Position; qSP=qBar.Position; i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then qDrag=false end end) end end)
    AC.UIS.InputChanged:Connect(function(i) if qDrag and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-qDS; qBar.Position=UDim2.new(qSP.X.Scale,qSP.X.Offset+d.X,qSP.Y.Scale,qSP.Y.Offset+d.Y) end end)
    local qL=Instance.new("TextLabel",qBar); qL.Size=UDim2.new(0,28,1,0); qL.Position=UDim2.new(0,8,0,0); qL.BackgroundTransparency=1; qL.Text="AC"; qL.TextColor3=AC.PUR_GLOW; qL.TextSize=11; qL.Font=Enum.Font.GothamBold; qL.ZIndex=401
    local function makeChip(label,xOff,onColor,onToggle)
        local chip=Instance.new("TextButton",qBar); chip.Size=UDim2.new(0,44,0,30); chip.Position=UDim2.new(0,xOff,0.5,-15); chip.BackgroundColor3=Color3.fromRGB(22,22,22); chip.Text=label; chip.TextColor3=AC.TXT_DIM; chip.TextSize=10; chip.Font=Enum.Font.GothamBold; chip.ZIndex=401; Instance.new("UICorner",chip).CornerRadius=UDim.new(1,0); local cs=Instance.new("UIStroke",chip); cs.Color=AC.PUR_STROKE; cs.Thickness=1; cs.Transparency=0.5
        local active=false
        chip.MouseButton1Click:Connect(function() active=not active; if active then AC.TS:Create(chip,TweenInfo.new(0.15),{BackgroundColor3=onColor,TextColor3=AC.TXT_WHITE}):Play(); cs.Transparency=1 else AC.TS:Create(chip,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(22,22,22),TextColor3=AC.TXT_DIM}):Play(); cs.Transparency=0.5 end; pcall(function() AC.clickSnd:Play() end); onToggle(active) end)
    end
    makeChip("SPD",42,Color3.fromRGB(30,160,60),function(v) local h=AC.player.Character and AC.player.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed=v and 50 or 16 end end)
    makeChip("FLY",92,Color3.fromRGB(20,100,220),function(v)
        AC.flyActive=v; local char=AC.player.Character; if not char then return end; local root=char:FindFirstChild("HumanoidRootPart"); if not root then return end; local hum=char:FindFirstChildOfClass("Humanoid")
        if v then if hum then hum.PlatformStand=true end; local att=Instance.new("Attachment",root); AC._flyAtt=att; AC.flyBV=Instance.new("LinearVelocity"); AC.flyBV.Attachment0=att; AC.flyBV.VelocityConstraintMode=Enum.VelocityConstraintMode.Vector; AC.flyBV.MaxForce=1e5; AC.flyBV.RelativeTo=Enum.ActuatorRelativeTo.World; AC.flyBV.VectorVelocity=Vector3.zero; AC.flyBV.Parent=root; AC.flyBG=Instance.new("AlignOrientation"); AC.flyBG.Attachment0=att; AC.flyBG.Mode=Enum.OrientationAlignmentMode.OneAttachment; AC.flyBG.MaxTorque=1e5; AC.flyBG.MaxAngularVelocity=math.huge; AC.flyBG.Responsiveness=50; AC.flyBG.Parent=root; AC.flyConn=AC.RS.RenderStepped:Connect(function() if not AC.flyActive then return end; local cf=AC.camera.CFrame; local dir=Vector3.zero; if AC.UIS:IsKeyDown(Enum.KeyCode.W) then dir=dir+cf.LookVector end; if AC.UIS:IsKeyDown(Enum.KeyCode.S) then dir=dir-cf.LookVector end; if AC.UIS:IsKeyDown(Enum.KeyCode.A) then dir=dir-cf.RightVector end; if AC.UIS:IsKeyDown(Enum.KeyCode.D) then dir=dir+cf.RightVector end; if AC.UIS:IsKeyDown(Enum.KeyCode.E) then dir=dir+Vector3.new(0,1,0) end; if AC.UIS:IsKeyDown(Enum.KeyCode.Q) then dir=dir-Vector3.new(0,1,0) end; if dir.Magnitude>0 then dir=dir.Unit end; AC.flyBV.VectorVelocity=dir*60; AC.flyBG.CFrame=cf end)
        else if AC.flyConn then AC.flyConn:Disconnect(); AC.flyConn=nil end; if AC.flyBV then AC.flyBV:Destroy(); AC.flyBV=nil end; if AC.flyBG then AC.flyBG:Destroy(); AC.flyBG=nil end; if AC._flyAtt then AC._flyAtt:Destroy(); AC._flyAtt=nil end; if hum then hum.PlatformStand=false end end
    end)
    makeChip("NC",140,Color3.fromRGB(200,100,10),function(v)
        if v then AC.noclipConn=AC.RS.Stepped:Connect(function() local char=AC.player.Character; if not char then return end; for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end)
        else if AC.noclipConn then AC.noclipConn:Disconnect(); AC.noclipConn=nil end; if AC.player.Character then for _,p in ipairs(AC.player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end end
    end)
end

-- OPEN ANIMATION
-- FIX: Only the wrapper animates. Inner panels (sidebar/mainPanel/navbar) are NEVER
-- resized because they have ClipsDescendants=true - shrinking them to 0 kills rendering.
do
    AC.switchTab("Home")
    AC.wrapper.Visible=false
    AC.wrapper.Size=UDim2.new(0,0,0,0)
    AC.wrapper.Position=UDim2.new(0.5,0,0.5,0)
    task.delay(0.08,function()
        AC.wrapper.Visible=true
        pcall(function() AC.openSound:Play() end)
        AC.TS:Create(AC.wrapper,TweenInfo.new(0.45,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Size=UDim2.new(0,AC.UI_W,0,AC.UI_H),
            Position=UDim2.new(0.5,-AC.UI_W/2,0.5,-AC.UI_H/2)
        }):Play()
        task.delay(0.5,function() AC._uiOpen=true end)
    end)
    task.delay(1.4,function() AC.toast("AC AudioCrafter v4.33 loaded!  G = toggle") end)
    print("AC AudioCrafter V4.33  by MelodyCrafter")
    print("  G = toggle UI | Emotes tab: Reanimation + Open Emote Menu")
end

-- AUTO RE-EXECUTE ON SERVER CHANGE
-- When you teleport or join a new server, re-run the script automatically.
-- Works by watching for the LocalPlayer leaving and the game changing PlaceId,
-- then using the executor's loadstring to reload from the saved source.
-- Since we can't store the script source inside itself, we write a loader
-- to the executor's workspace that re-executes on next join.
pcall(function()
    -- Store script identity so we can detect fresh runs vs re-runs
    _G.__AC_AUTORUN_VER = AC_VER

    -- Listen for the player being teleported (Roblox fires this before actual TP)
    local TS=game:GetService("TeleportService")

    -- Method 1: TeleportService.TeleportInitFailed / game.Players.LocalPlayer.OnTeleport
    pcall(function()
        AC.player.OnTeleport:Connect(function(teleportState)
            if teleportState==Enum.TeleportState.InProgress then
                -- Save a flag so on next execute we know to auto-open
                pcall(function()
                    if writefile and isfolder then
                        writefile("AC/__autorejoin.json", game:GetService("HttpService"):JSONEncode({
                            placeId=game.PlaceId,
                            ver=AC_VER,
                            time=os.time()
                        }))
                    end
                end)
                AC.toast("Teleporting — AC will reload on join",AC.PUR_BRIGHT)
            end
        end)
    end)

    -- Method 2: detect if we just came from a teleport (file written above)
    -- If the autorejoin file exists and is recent (<30s), show a toast
    pcall(function()
        if not isfile then return end
        if not isfile("AC/__autorejoin.json") then return end
        local ok,data=pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile("AC/__autorejoin.json"))
        end)
        if ok and data and type(data)=="table" then
            local age = os.time() - (data.time or 0)
            if age < 30 then
                task.delay(2, function()
                    AC.toast("Auto-reloaded after server change!",AC.GREEN_OK)
                end)
            end
        end
        -- Clean up the flag
        pcall(function() writefile("AC/__autorejoin.json","{}") end)
    end)
end)
