-- AC AudioCrafter V3.1 — Part 1 of 2
-- See part 2 for qBar, open animation, and command handler completion
-- Paste BOTH parts together in order

-- ╔══════════════════════════════════════════════════════╗
-- ║  AC | AudioCrafter  V3.0                            ║
-- ║  Made by MelodyCrafter                              ║
-- ╚══════════════════════════════════════════════════════╝
-- CHANGES v3.1:
--  FIX: G key + reopenBtn visibility (AC._uiOpen flag)
--  FIX: Enum.KeyCode errors (pcall KeyCode.Name everywhere)
--  FIX: Double tag on reanimate (destroy old before attach)
--  FIX: Ragdoll/freeze (reanimate(false) first, GettingUp state restore)
--  NEW: AC REANIMATION panel (AK-style, semi-transparent)
--       - Top-left toggle, All/Favs tabs, star favs
--       - Per-emote speed 0.1-12 with +/- buttons
--       - Speed slider 0-10, Reset button
--       - Number row 1/3/5/7/9 with key binds
--       - Click emote = highlight+play, click again = stop
--       - Loading text -> "Loaded X animations"
--       - Small "AC" corner label, draggable
--  NEW: UGC Emotes panel (same AK look)
--       - All/Favs/States tabs
--       - States: Idle/Walk/Jump dropdowns (45 anims each)
--       - Per-state speed slider 0.1x-5.0x + Reset
--       - Star favs, keybinds, highlight on click
--       - Loading -> Ready status
--  NEW: Billboard typewriter effect (types AUDIO USER, deletes, loops)
--  NEW: Billboard LOD (logo-only when > 60 studs away)
--  NEW: Lighter purple billboard text (210,160,255)
--  REMOVED: Custom Animation URL section
--  REMOVED: Stop Current Emote button
--  REMOVED: faBtn nil reference (was crashing clear target)
--  Button: "Reanimation" bold text only (no sub-text)
--  Button: "Open Emote Menu" bold text only

local AC = {}

local _URLS = {
    EMOTE_JSON  = "https://raw.githubusercontent.com/7yd7/sniper-Emote/refs/heads/test/EmoteSniper.json",
    ANIM_JSON   = "https://raw.githubusercontent.com/7yd7/sniper-Emote/refs/heads/test/AnimationSniper.json",
    BASEPLATE   = "https://raw.githubusercontent.com/platinumicy/micup/refs/heads/main/allblackmap",
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

-- Palette
AC.BG_BASE=Color3.fromRGB(8,8,8); AC.BG_PANEL=Color3.fromRGB(14,14,14); AC.BG_CARD=Color3.fromRGB(20,20,20)
AC.BG_NAV=Color3.fromRGB(5,5,5); AC.BG_SIDEBAR=Color3.fromRGB(11,11,11)
AC.PUR_DARK=Color3.fromRGB(55,0,110); AC.PUR_MID=Color3.fromRGB(100,20,180)
AC.PUR_BRIGHT=Color3.fromRGB(160,60,255); AC.PUR_GLOW=Color3.fromRGB(200,120,255)
AC.PUR_STROKE=Color3.fromRGB(80,10,140)
AC.TXT_WHITE=Color3.new(1,1,1); AC.TXT_MAIN=Color3.fromRGB(230,230,230)
AC.TXT_DIM=Color3.fromRGB(110,110,110); AC.TXT_LABEL=Color3.fromRGB(160,80,255)
AC.TXT_BILLBOARD=Color3.fromRGB(210,160,255)  -- lighter purple for tags
AC.GREEN_OK=Color3.fromRGB(80,255,120); AC.RED_ERR=Color3.fromRGB(255,70,70); AC.ORANGE_W=Color3.fromRGB(255,165,50)

AC.UI_W=820; AC.UI_H=500; AC.NAV_H=40; AC.SIDE_W=180; AC.MAIN_W=AC.UI_W-AC.SIDE_W-6

-- drawLogo
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

-- ── GUI ROOT ─────────────────────────────────────────────
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

    local snd=Instance.new("Sound",AC.SS); snd.SoundId="rbxassetid://6026984224"; snd.Volume=0.5; AC.openSound=snd
    local hSnd=Instance.new("Sound",AC.SS); hSnd.SoundId="rbxassetid://6026984224"; hSnd.Volume=0.08; hSnd.RollOffMaxDistance=0; AC.hoverSnd=hSnd
    local cSnd=Instance.new("Sound",AC.SS); cSnd.SoundId="rbxassetid://6026984224"; cSnd.Volume=0.3; cSnd.RollOffMaxDistance=0; AC.clickSnd=cSnd
    local tSnd=Instance.new("Sound",AC.SS); tSnd.SoundId="rbxassetid://6026984224"; tSnd.Volume=0.28; tSnd.RollOffMaxDistance=0; AC.toggleSnd=tSnd

    AC.tabs={}; AC.selectedTarget=nil; AC.tagsVisible=true; AC.allBillboards={}
    AC.focusActive=false; AC.focusConn=nil; AC.onHead=false; AC.headConn=nil
    AC.inBp=false; AC.bpConn=nil; AC.flyActive=false; AC.flyBV=nil; AC.flyBG=nil; AC.flyConn=nil; AC._flyAtt=nil
    AC.noclipConn=nil; AC.shadersActive=false; AC.baseplateRef=nil; AC.antiVoidConn=nil; AC.afkThread=nil; AC.ijConn=nil
    AC._uiOpen=true  -- tracks whether main UI is visible (fix for G key)
end

-- ── HELPERS ──────────────────────────────────────────────
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
        knob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
        trk.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; setV((AC.UIS:GetMouseLocation().X-trk.AbsolutePosition.X)/trk.AbsoluteSize.X) end end)
        AC.UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
        AC.RS.RenderStepped:Connect(function() if dragging then setV((AC.UIS:GetMouseLocation().X-trk.AbsolutePosition.X)/trk.AbsoluteSize.X) end end)
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

-- ── MAIN FRAME ───────────────────────────────────────────
do
    AC.wrapper=Instance.new("Frame",AC.screenGui); AC.wrapper.Size=UDim2.new(0,AC.UI_W,0,AC.UI_H); AC.wrapper.Position=UDim2.new(0.5,-AC.UI_W/2,0.5,-AC.UI_H/2); AC.wrapper.BackgroundTransparency=1
    local shadow=Instance.new("Frame",AC.wrapper); shadow.Size=UDim2.new(1,20,1,20); shadow.Position=UDim2.new(0,-10,0,-10); shadow.BackgroundColor3=Color3.fromRGB(0,0,0); shadow.BackgroundTransparency=0.45; shadow.ZIndex=0; Instance.new("UICorner",shadow).CornerRadius=UDim.new(0,20)
    local mainBg=Instance.new("Frame",AC.wrapper); mainBg.Size=UDim2.new(1,0,1,0); mainBg.BackgroundColor3=AC.BG_BASE; mainBg.ZIndex=1; Instance.new("UICorner",mainBg).CornerRadius=UDim.new(0,14)
    AC.navbar=Instance.new("Frame",AC.wrapper); AC.navbar.Size=UDim2.new(1,0,0,AC.NAV_H); AC.navbar.BackgroundColor3=AC.BG_NAV; AC.navbar.ZIndex=5; Instance.new("UICorner",AC.navbar).CornerRadius=UDim.new(0,14); Instance.new("UIStroke",AC.navbar).Color=AC.PUR_STROKE

    local navLogo=AC.drawLogo(AC.navbar,28,AC.PUR_BRIGHT); navLogo.Position=UDim2.new(0,8,0.5,-14); navLogo.ZIndex=6
    local navT=Instance.new("TextLabel",AC.navbar); navT.Size=UDim2.new(0,110,1,0); navT.Position=UDim2.new(0,40,0,0); navT.BackgroundTransparency=1; navT.Text="AudioCrafter"; navT.TextColor3=AC.TXT_WHITE; navT.TextSize=15; navT.Font=Enum.Font.GothamBold; navT.TextXAlignment=Enum.TextXAlignment.Left; navT.ZIndex=6
    local navVer=Instance.new("TextLabel",AC.navbar); navVer.Size=UDim2.new(0,60,1,0); navVer.Position=UDim2.new(0,153,0,0); navVer.BackgroundTransparency=1; navVer.Text="v3.1"; navVer.TextColor3=AC.PUR_BRIGHT; navVer.TextSize=10; navVer.Font=Enum.Font.GothamBold; navVer.TextXAlignment=Enum.TextXAlignment.Left; navVer.ZIndex=6
    local ndot=Instance.new("Frame",AC.navbar); ndot.Size=UDim2.new(0,7,0,7); ndot.Position=UDim2.new(0,194,0.5,-3); ndot.BackgroundColor3=AC.PUR_BRIGHT; ndot.ZIndex=6; Instance.new("UICorner",ndot).CornerRadius=UDim.new(1,0)
    AC.TS:Create(ndot,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{BackgroundColor3=AC.PUR_DARK,BackgroundTransparency=0.4}):Play()
    local navBy=Instance.new("TextLabel",AC.navbar); navBy.Size=UDim2.new(0,160,1,0); navBy.Position=UDim2.new(0,205,0,0); navBy.BackgroundTransparency=1; navBy.Text="by MelodyCrafter"; navBy.TextColor3=AC.TXT_DIM; navBy.TextSize=11; navBy.Font=Enum.Font.Gotham; navBy.TextXAlignment=Enum.TextXAlignment.Left; navBy.ZIndex=6
    AC.minBtn=Instance.new("TextButton",AC.navbar); AC.minBtn.Size=UDim2.new(0,24,0,24); AC.minBtn.Position=UDim2.new(1,-30,0.5,-12); AC.minBtn.BackgroundColor3=Color3.fromRGB(35,35,35); AC.minBtn.Text="—"; AC.minBtn.TextColor3=AC.TXT_DIM; AC.minBtn.TextSize=13; AC.minBtn.Font=Enum.Font.GothamBold; AC.minBtn.ZIndex=6; Instance.new("UICorner",AC.minBtn).CornerRadius=UDim.new(0,6)
    AC.minBtn.MouseEnter:Connect(function() AC.TS:Create(AC.minBtn,TweenInfo.new(0.12),{BackgroundColor3=AC.PUR_DARK,TextColor3=AC.TXT_WHITE}):Play() end)
    AC.minBtn.MouseLeave:Connect(function() AC.TS:Create(AC.minBtn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(35,35,35),TextColor3=AC.TXT_DIM}):Play() end)

    local body=Instance.new("Frame",AC.wrapper); body.Size=UDim2.new(1,0,1,-AC.NAV_H-4); body.Position=UDim2.new(0,0,0,AC.NAV_H+4); body.BackgroundTransparency=1; body.ZIndex=2
    AC.sidebar=Instance.new("Frame",body); AC.sidebar.Size=UDim2.new(0,AC.SIDE_W,1,0); AC.sidebar.BackgroundColor3=AC.BG_SIDEBAR; AC.sidebar.ClipsDescendants=true; AC.sidebar.ZIndex=3; Instance.new("UICorner",AC.sidebar).CornerRadius=UDim.new(0,12); local sk=Instance.new("UIStroke",AC.sidebar); sk.Color=AC.PUR_STROKE; sk.Thickness=1; sk.Transparency=0.4
    AC.sideScroll=Instance.new("ScrollingFrame",AC.sidebar); AC.sideScroll.Size=UDim2.new(1,0,1,0); AC.sideScroll.BackgroundTransparency=1; AC.sideScroll.BorderSizePixel=0; AC.sideScroll.ScrollBarThickness=0; AC.sideScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; AC.sideScroll.CanvasSize=UDim2.new(0,0,0,0)
    local sNavLbl=Instance.new("TextLabel",AC.sideScroll); sNavLbl.Size=UDim2.new(1,-16,0,16); sNavLbl.Position=UDim2.new(0,12,0,12); sNavLbl.BackgroundTransparency=1; sNavLbl.Text="NAVIGATION"; sNavLbl.TextColor3=AC.TXT_LABEL; sNavLbl.TextSize=9; sNavLbl.Font=Enum.Font.GothamBold; sNavLbl.TextXAlignment=Enum.TextXAlignment.Left
    local sDiv=Instance.new("Frame",AC.sideScroll); sDiv.Size=UDim2.new(1,-16,0,1); sDiv.Position=UDim2.new(0,8,0,30); sDiv.BackgroundColor3=AC.PUR_STROKE; sDiv.BackgroundTransparency=0.4
    local sLL=Instance.new("UIListLayout",AC.sideScroll); sLL.FillDirection=Enum.FillDirection.Vertical; sLL.SortOrder=Enum.SortOrder.LayoutOrder; sLL.Padding=UDim.new(0,2)
    local sLP=Instance.new("UIPadding",AC.sideScroll); sLP.PaddingTop=UDim.new(0,38); sLP.PaddingLeft=UDim.new(0,8); sLP.PaddingRight=UDim.new(0,8)
    AC.mainPanel=Instance.new("Frame",body); AC.mainPanel.Size=UDim2.new(0,AC.MAIN_W,1,0); AC.mainPanel.Position=UDim2.new(0,AC.SIDE_W+6,0,0); AC.mainPanel.BackgroundColor3=AC.BG_PANEL; AC.mainPanel.ClipsDescendants=true; AC.mainPanel.ZIndex=3; Instance.new("UICorner",AC.mainPanel).CornerRadius=UDim.new(0,12); local mpk=Instance.new("UIStroke",AC.mainPanel); mpk.Color=AC.PUR_STROKE; mpk.Thickness=1; mpk.Transparency=0.4
    AC.pageContainer=Instance.new("Frame",AC.mainPanel); AC.pageContainer.Size=UDim2.new(1,0,1,0); AC.pageContainer.BackgroundTransparency=1; AC.pageContainer.ClipsDescendants=true

    -- ── Reopen button ── FIX: always visible with pulsing border ──
    AC.reopenBtn=Instance.new("TextButton",AC.screenGui)
    AC.reopenBtn.Size=UDim2.new(0,50,0,50); AC.reopenBtn.Position=UDim2.new(1,-62,0.5,-25)
    AC.reopenBtn.BackgroundColor3=AC.BG_PANEL; AC.reopenBtn.Text=""; AC.reopenBtn.Visible=false; AC.reopenBtn.ZIndex=20
    Instance.new("UICorner",AC.reopenBtn).CornerRadius=UDim.new(1,0)
    local rbS=Instance.new("UIStroke",AC.reopenBtn); rbS.Color=AC.PUR_BRIGHT; rbS.Thickness=2
    AC.TS:Create(rbS,TweenInfo.new(1.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Color=AC.PUR_DARK,Transparency=0.3}):Play()
    local rl=AC.drawLogo(AC.reopenBtn,30,AC.PUR_BRIGHT); rl.Position=UDim2.new(0.5,-15,0.5,-15); rl.ZIndex=21

    -- Drag
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

    -- ── FIX: minimize/reopen using _uiOpen flag ──────────
    AC.doMin=function()
        if not AC._uiOpen then return end; AC._uiOpen=false
        pcall(function() AC.openSound:Play() end)
        AC.TS:Create(AC.wrapper,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)}):Play()
        task.delay(0.28,function() AC.wrapper.Visible=false; AC.reopenBtn.Visible=true end)
    end
    AC.doOpen=function()
        if AC._uiOpen then return end; AC._uiOpen=true
        AC.reopenBtn.Visible=false; AC.wrapper.Visible=true
        AC.wrapper.Size=UDim2.new(0,0,0,0); AC.wrapper.Position=UDim2.new(0.5,0,0.5,0)
        pcall(function() AC.openSound:Play() end)
        AC.TS:Create(AC.wrapper,TweenInfo.new(0.42,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,AC.UI_W,0,AC.UI_H),Position=UDim2.new(0.5,-AC.UI_W/2,0.5,-AC.UI_H/2)}):Play()
    end
    AC.minBtn.MouseButton1Click:Connect(AC.doMin)
    AC.reopenBtn.MouseButton1Click:Connect(AC.doOpen)

    -- ── FIX: G key uses _uiOpen flag, not Visible ────────
    AC.UIS.InputBegan:Connect(function(i,gp)
        if gp then return end
        if i.KeyCode==Enum.KeyCode.G then
            if AC._uiOpen then AC.doMin() else AC.doOpen() end
        end
    end)
end

-- ── FPS/PING HUD + TAGS ──────────────────────────────────
do
    local pill=Instance.new("Frame",AC.screenGui); pill.Size=UDim2.new(0,200,0,28); pill.Position=UDim2.new(0.5,-100,0,2); pill.BackgroundColor3=Color3.fromRGB(10,10,10); pill.ZIndex=300; Instance.new("UICorner",pill).CornerRadius=UDim.new(0,14); local ps=Instance.new("UIStroke",pill); ps.Color=AC.PUR_STROKE; ps.Thickness=1.2; ps.Transparency=0.2
    local tagsDot=Instance.new("Frame",pill); tagsDot.Size=UDim2.new(0,9,0,9); tagsDot.Position=UDim2.new(0,8,0.5,-4); tagsDot.BackgroundColor3=AC.PUR_BRIGHT; tagsDot.ZIndex=301; Instance.new("UICorner",tagsDot).CornerRadius=UDim.new(1,0)
    AC.TS:Create(tagsDot,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{BackgroundTransparency=0.5}):Play()
    local tagsBtn=Instance.new("TextButton",pill); tagsBtn.Size=UDim2.new(0,38,1,0); tagsBtn.Position=UDim2.new(0,20,0,0); tagsBtn.BackgroundTransparency=1; tagsBtn.Text="Tags"; tagsBtn.TextColor3=AC.PUR_BRIGHT; tagsBtn.TextSize=11; tagsBtn.Font=Enum.Font.GothamBold; tagsBtn.ZIndex=301
    tagsBtn.MouseButton1Click:Connect(function()
        AC.tagsVisible=not AC.tagsVisible
        local clean={}
        for _,bb in ipairs(AC.allBillboards) do if bb and bb.Parent then bb.Enabled=AC.tagsVisible; clean[#clean+1]=bb end end
        AC.allBillboards=clean
        for _,p in ipairs(AC.Players:GetPlayers()) do if p.Character then local h=p.Character:FindFirstChild("Head"); if h then local bb2=h:FindFirstChild("AC_Billboard"); if bb2 then bb2.Enabled=AC.tagsVisible end end end end
        tagsDot.BackgroundColor3=AC.tagsVisible and AC.PUR_BRIGHT or AC.TXT_DIM; tagsBtn.TextColor3=AC.tagsVisible and AC.PUR_BRIGHT or AC.TXT_DIM
        AC.toast("Tags "..(AC.tagsVisible and "visible" or "hidden"),AC.tagsVisible and AC.PUR_BRIGHT or AC.TXT_DIM)
    end)
    local div1=Instance.new("Frame",pill); div1.Size=UDim2.new(0,1,0.6,0); div1.Position=UDim2.new(0,60,0.2,0); div1.BackgroundColor3=AC.TXT_DIM; div1.BackgroundTransparency=0.5
    local fpsLbl=Instance.new("TextLabel",pill); fpsLbl.Size=UDim2.new(0,60,1,0); fpsLbl.Position=UDim2.new(0,66,0,0); fpsLbl.BackgroundTransparency=1; fpsLbl.Text="FPS  60"; fpsLbl.TextColor3=AC.GREEN_OK; fpsLbl.TextSize=11; fpsLbl.Font=Enum.Font.GothamBold; fpsLbl.ZIndex=301
    local div2=Instance.new("Frame",pill); div2.Size=UDim2.new(0,1,0.6,0); div2.Position=UDim2.new(0,128,0.2,0); div2.BackgroundColor3=AC.TXT_DIM; div2.BackgroundTransparency=0.5
    local pingLbl=Instance.new("TextLabel",pill); pingLbl.Size=UDim2.new(0,68,1,0); pingLbl.Position=UDim2.new(0,132,0,0); pingLbl.BackgroundTransparency=1; pingLbl.Text="PING  5ms"; pingLbl.TextColor3=AC.PUR_GLOW; pingLbl.TextSize=11; pingLbl.Font=Enum.Font.GothamBold; pingLbl.ZIndex=301
    local fpsF,fpsT={},0
    AC.RS.RenderStepped:Connect(function(dt)
        fpsF[#fpsF+1]=dt; fpsT=fpsT+dt
        if fpsT>=0.5 and #fpsF>0 then
            local sum=0; for _,v in ipairs(fpsF) do sum=sum+v end
            local avg=sum/#fpsF; local fps=avg>0 and math.floor(1/avg+0.5) or 0
            fpsLbl.Text="FPS  "..fps; fpsLbl.TextColor3=fps>=55 and AC.GREEN_OK or fps>=30 and AC.ORANGE_W or AC.RED_ERR
            fpsF={}; fpsT=0
            local ok,ping=pcall(function() return math.floor(AC.Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            if ok then pingLbl.Text="PING  "..ping.."ms"; pingLbl.TextColor3=ping<80 and AC.PUR_GLOW or ping<150 and AC.ORANGE_W or AC.RED_ERR end
        end
    end)
end

-- ── BILLBOARD TAGS (typewriter, LOD, lighter purple) ─────
do
    local MARKER="AC_Active"
    local DISPLAY_TEXT="AUDIO USER"
    local TYPE_SPD=0.07; local HOLD=1.8; local DEL_SPD=0.04; local BLANK=0.35
    local LOD_TEXT=60  -- studs: show text below this, logo-only above

    local function startTypewriter(tLbl)
        task.spawn(function()
            while tLbl and tLbl.Parent do
                local built=""
                tLbl.Text="|"
                for i=1,#DISPLAY_TEXT do
                    if not tLbl.Parent then return end
                    built=DISPLAY_TEXT:sub(1,i); tLbl.Text=built.."|"; task.wait(TYPE_SPD)
                end
                tLbl.Text=DISPLAY_TEXT.."|"; task.wait(HOLD)
                for i=#DISPLAY_TEXT,0,-1 do
                    if not tLbl.Parent then return end
                    tLbl.Text=DISPLAY_TEXT:sub(1,i).."|"; task.wait(DEL_SPD)
                end
                tLbl.Text="|"; task.wait(BLANK)
            end
        end)
    end

    local TAG_W,TAG_H=220,46
    local function attachTag(char,owner)
        local head=char:WaitForChild("Head",10); if not head then return end
        -- FIX: destroy any existing tag first to prevent doubles
        local ex=head:FindFirstChild("AC_Billboard"); if ex then ex:Destroy() end

        local bb=Instance.new("BillboardGui"); bb.Name="AC_Billboard"; bb.Size=UDim2.new(0,TAG_W,0,TAG_H)
        bb.StudsOffset=Vector3.new(0,2.8,0); bb.AlwaysOnTop=true; bb.ResetOnSpawn=false; bb.MaxDistance=0
        bb.Adornee=head; bb.Enabled=AC.tagsVisible; bb.Parent=head
        table.insert(AC.allBillboards,bb)

        local pill=Instance.new("Frame",bb); pill.Size=UDim2.new(1,0,1,0); pill.BackgroundColor3=Color3.fromRGB(8,2,16); pill.BackgroundTransparency=0.25
        Instance.new("UICorner",pill).CornerRadius=UDim.new(0,23)
        local pStroke=Instance.new("UIStroke",pill); pStroke.Color=AC.PUR_BRIGHT; pStroke.Thickness=2

        -- Logo icon (small, left side)
        local logoFrame=AC.drawLogo(pill,22,Color3.fromRGB(210,160,255))
        logoFrame.Position=UDim2.new(0,6,0.5,-11)

        -- title: lighter purple (AC.TXT_BILLBOARD), typewriter
        local titleLbl=Instance.new("TextLabel",pill); titleLbl.Size=UDim2.new(1,-40,0,20); titleLbl.Position=UDim2.new(0,32,0,4)
        titleLbl.BackgroundTransparency=1; titleLbl.Text="AUDIO USER"; titleLbl.TextColor3=AC.TXT_BILLBOARD
        titleLbl.TextSize=15; titleLbl.Font=Enum.Font.GothamBold; titleLbl.TextXAlignment=Enum.TextXAlignment.Left
        titleLbl.TextStrokeTransparency=0.5; titleLbl.TextStrokeColor3=AC.PUR_DARK

        local userLbl=Instance.new("TextLabel",pill); userLbl.Size=UDim2.new(1,-40,0,16); userLbl.Position=UDim2.new(0,32,0,24)
        userLbl.BackgroundTransparency=1; userLbl.Text="@"..(owner and owner.Name or "AC User")
        userLbl.TextColor3=Color3.fromRGB(200,170,220); userLbl.TextSize=10; userLbl.Font=Enum.Font.Gotham
        userLbl.TextXAlignment=Enum.TextXAlignment.Left; userLbl.TextTruncate=Enum.TextTruncate.AtEnd

        local grad=Instance.new("UIGradient",pill); grad.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(15,4,28)),ColorSequenceKeypoint.new(1,Color3.fromRGB(6,2,12))}; grad.Rotation=135

        -- Start typewriter
        startTypewriter(titleLbl)

        -- Distance LOD + scale
        local sc; sc=AC.RS.RenderStepped:Connect(function()
            if not head or not head.Parent then sc:Disconnect(); return end
            local d=(AC.camera.CFrame.Position-head.Position).Magnitude
            local f=math.clamp(20/math.max(d,1),0.3,1.4)
            bb.Size=UDim2.new(0,TAG_W*f,0,TAG_H*f)
            -- LOD: hide text labels when far, show logo only
            local showText=(d<=LOD_TEXT)
            titleLbl.Visible=showText; userLbl.Visible=showText
        end)

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
        local f=Instance.new("Frame",AC.toastContainer); f.Size=UDim2.new(0,280,0,0); f.BackgroundColor3=Color3.fromRGB(20,16,0); f.ClipsDescendants=true
        Instance.new("UICorner",f).CornerRadius=UDim.new(0,8); local st=Instance.new("UIStroke",f); st.Color=color; st.Thickness=2
        local bar=Instance.new("Frame",f); bar.Size=UDim2.new(0,4,1,0); bar.BackgroundColor3=color; bar.BorderSizePixel=0
        local lbl=Instance.new("TextLabel",f); lbl.Size=UDim2.new(1,-18,1,0); lbl.Position=UDim2.new(0,14,0,0); lbl.BackgroundTransparency=1; lbl.Text="⚡ AC USER: "..p.Name.." — ADMIN IN SERVER"; lbl.TextColor3=color; lbl.TextSize=12; lbl.Font=Enum.Font.GothamBold; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.TextWrapped=true
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
        local function onChar(char)
            task.spawn(function()
                local head=char:WaitForChild("Head",10); if not head then return end
                if head:FindFirstChild(MARKER) then attachTag(char,p); return end
                local cn; cn=head.ChildAdded:Connect(function(child) if child.Name==MARKER then cn:Disconnect(); attachTag(char,p) end end)
                char.AncestryChanged:Connect(function() if not char.Parent then pcall(function() cn:Disconnect() end) end end)
            end)
        end
        if p.Character then onChar(p.Character) end
        p.CharacterAdded:Connect(onChar)
    end
    for _,p in ipairs(AC.Players:GetPlayers()) do watchPlayer(p) end
    AC.Players.PlayerAdded:Connect(watchPlayer)
    AC.Players.PlayerRemoving:Connect(function(p) if p.Character then local h=p.Character:FindFirstChild("Head"); if h then local bb=h:FindFirstChild("AC_Billboard"); if bb then bb:Destroy() end end end end)
end


-- ─────────────────────────────────────────────────────────
-- HOME TAB
-- ─────────────────────────────────────────────────────────
do
    local btn=AC.createTab("Home",1); local pg=AC.createPage(); AC.tabs["Home"].page=pg
    local wCard=AC.makeCard(pg,12,72,Color3.fromRGB(18,5,30)); wCard.Size=UDim2.new(1,-24,0,72)
    local wg=Instance.new("UIGradient",wCard); wg.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(40,8,65)),ColorSequenceKeypoint.new(1,Color3.fromRGB(10,2,18))}; wg.Rotation=135
    local wt=Instance.new("TextLabel",wCard); wt.Size=UDim2.new(1,-20,0,32); wt.Position=UDim2.new(0,14,0,8); wt.BackgroundTransparency=1; wt.Text="Welcome, "..AC.player.Name; wt.TextColor3=AC.TXT_WHITE; wt.TextSize=20; wt.Font=Enum.Font.GothamBold; wt.TextXAlignment=Enum.TextXAlignment.Left
    local ws=Instance.new("TextLabel",wCard); ws.Size=UDim2.new(1,-20,0,20); ws.Position=UDim2.new(0,14,0,44); ws.BackgroundTransparency=1; ws.Text="AC AudioCrafter v3.1 — by MelodyCrafter"; ws.TextColor3=AC.PUR_MID; ws.TextSize=12; ws.Font=Enum.Font.Gotham; ws.TextXAlignment=Enum.TextXAlignment.Left
    local cW=math.floor((AC.MAIN_W-24-16)/3)
    local function ic(label,val,col,vc) local c=Instance.new("Frame",pg); c.Size=UDim2.new(0,cW,0,56); c.Position=UDim2.new(0,12+col*(cW+8),0,96); c.BackgroundColor3=AC.BG_CARD; Instance.new("UICorner",c).CornerRadius=UDim.new(0,8); local ll=Instance.new("TextLabel",c); ll.Size=UDim2.new(1,-10,0,16); ll.Position=UDim2.new(0,10,0,8); ll.BackgroundTransparency=1; ll.Text=label; ll.TextColor3=AC.TXT_DIM; ll.TextSize=10; ll.Font=Enum.Font.Gotham; ll.TextXAlignment=Enum.TextXAlignment.Left; local vl=Instance.new("TextLabel",c); vl.Size=UDim2.new(1,-10,0,24); vl.Position=UDim2.new(0,10,0,26); vl.BackgroundTransparency=1; vl.Text=val; vl.TextColor3=vc or AC.TXT_WHITE; vl.TextSize=14; vl.Font=Enum.Font.GothamBold; vl.TextXAlignment=Enum.TextXAlignment.Left end
    ic("Version","v3.1",0); ic("Status","● Active",1,AC.GREEN_OK); ic("Script",AC.executorName,2,AC.PUR_BRIGHT)

    AC.sectionLbl(pg,"CHANGELOG",164)
    local clOuter=Instance.new("Frame",pg); clOuter.Size=UDim2.new(1,-24,0,230); clOuter.Position=UDim2.new(0,12,0,182)
    clOuter.BackgroundColor3=AC.BG_CARD; clOuter.ClipsDescendants=true
    Instance.new("UICorner",clOuter).CornerRadius=UDim.new(0,8); Instance.new("UIStroke",clOuter).Color=AC.PUR_STROKE
    local cl=Instance.new("ScrollingFrame",clOuter); cl.Size=UDim2.new(1,0,1,0); cl.BackgroundTransparency=1
    cl.BorderSizePixel=0; cl.ScrollBarThickness=3; cl.ScrollBarImageColor3=AC.PUR_MID
    cl.AutomaticCanvasSize=Enum.AutomaticSize.Y; cl.CanvasSize=UDim2.new(0,0,0,0)
    local clLL=Instance.new("UIListLayout",cl); clLL.Padding=UDim.new(0,2); clLL.SortOrder=Enum.SortOrder.LayoutOrder
    local clPP=Instance.new("UIPadding",cl); clPP.PaddingTop=UDim.new(0,6); clPP.PaddingLeft=UDim.new(0,10); clPP.PaddingRight=UDim.new(0,10); clPP.PaddingBottom=UDim.new(0,6)
    local clOrd=0
    local function cll(t,sz,c2,f)
        clOrd=clOrd+1; local l=Instance.new("TextLabel",cl); l.Size=UDim2.new(1,0,0,sz+6)
        l.BackgroundTransparency=1; l.Text=t; l.TextColor3=c2; l.TextSize=sz
        l.Font=f or Enum.Font.Gotham; l.TextXAlignment=Enum.TextXAlignment.Left; l.TextWrapped=true; l.LayoutOrder=clOrd
    end
    cll("v3.1 — Current Update",12,AC.PUR_GLOW,Enum.Font.GothamBold)
    cll("RN panel: fetches ALL animations from Rootleak/Animations (~1000+) via GitHub API.",10,AC.TXT_MAIN)
    cll("Settings saved per-player using writefile (favs, binds, speeds persist across executions).",10,AC.TXT_MAIN)
    cll("Bind slots: Delete/Backspace exits bind mode + X button clears individual bind.",10,AC.TXT_MAIN)
    cll("Stop emote fix: api.stop_animation() called correctly; second click reliably stops.",10,AC.TXT_MAIN)
    cll("UGC Emotes panel: now identical layout to AC REANIMATION (speed slider + bind row).",10,AC.TXT_MAIN)
    cll("Sound ID fixed. Changelog restored. FPS calc fixed. UGC lag fixed.",10,AC.TXT_MAIN)
    cll("v3.0 — Major Update",12,AC.PUR_MID,Enum.Font.GothamBold)
    cll("AC REANIMATION panel (AK-style): All/Favs, star favs, per-emote speed 0.1-12,",10,AC.TXT_MAIN)
    cll("speed slider 0-10, number row Bind slots, highlight toggle, semi-transparent.",10,AC.TXT_MAIN)
    cll("UGC Emotes panel: All/Favs/States, matching bottom bar, async row loading.",10,AC.TXT_MAIN)
    cll("Billboard: typewriter loop, lighter purple, distance LOD (logo-only far).",10,AC.TXT_MAIN)
    cll("FIX: G key + reopenBtn. FIX: KeyCode errors. FIX: double tag. FIX: ragdoll.",10,AC.TXT_MAIN)
    cll("FIX: Sound IDs corrected. FIX: Changelog restored. FIX: UGC panel lag.",10,AC.TXT_MAIN)
    cll("v2.9 — Rootleak Reanimation API integrated.",12,AC.PUR_MID,Enum.Font.GothamBold)
    cll("v2.6~2.8 — Tags, emotes, VC bypass, dropdown, glowing button fixes.",10,AC.TXT_DIM)
    cll("v2.0~2.5 — PShade shaders, executor detect, hover/click sounds, fly fixes.",10,AC.TXT_DIM)
    cll("v1.0~1.9 — Initial release through Anti-VC, spectate, ESP, FPS/PING HUD.",10,AC.TXT_DIM)

    btn.MouseButton1Click:Connect(function() AC.switchTab("Home") end)
end

-- ─────────────────────────────────────────────────────────
-- PLAYER TAB
-- ─────────────────────────────────────────────────────────
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
                    local row=Instance.new("TextButton",ddScroll); row.Size=UDim2.new(1,0,0,36); row.BackgroundColor3=Color3.fromRGB(22,22,22); row.Text=""; row.Name=p.Name; row.ZIndex=502; Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)
                    local nl=Instance.new("TextLabel",row); nl.Size=UDim2.new(1,-16,1,0); nl.Position=UDim2.new(0,10,0,0); nl.BackgroundTransparency=1; nl.Text=p.Name; nl.TextColor3=AC.TXT_WHITE; nl.TextSize=13; nl.Font=Enum.Font.GothamBold; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.ZIndex=503
                    local pCopy=p
                    row.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then ddSelecting=true end end)
                    row.MouseButton1Click:Connect(function()
                        AC.selectedTarget=pCopy; ddSelecting=true; sBox.Text=pCopy.Name; ddFrame.Visible=false; sBox:ReleaseFocus(); AC.toast("Target: "..pCopy.Name,AC.PUR_BRIGHT)
                        task.defer(function() task.defer(function() task.defer(function() ddSelecting=false end) end) end)
                    end)
                    row.MouseEnter:Connect(function() AC.TS:Create(row,TweenInfo.new(0.1),{BackgroundColor3=AC.PUR_DARK}):Play() end)
                    row.MouseLeave:Connect(function() AC.TS:Create(row,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(22,22,22)}):Play() end)
                end
            end
        end
        if count==0 then ddFrame.Visible=false; return end
        local ddH=math.min(count*38+8,180); local ap=sc.AbsolutePosition; local as=sc.AbsoluteSize
        ddFrame.Position=UDim2.new(0,ap.X,0,ap.Y+as.Y+2); ddFrame.Size=UDim2.new(0,as.X,0,0)
        AC.TS:Create(ddFrame,TweenInfo.new(0.12,Enum.EasingStyle.Quint),{Size=UDim2.new(0,as.X,0,ddH)}):Play(); ddFrame.Visible=true
    end
    sBox:GetPropertyChangedSignal("Text"):Connect(function() if not ddSelecting then if sBox.Text=="" then AC.selectedTarget=nil end; rebuildDropdown(sBox.Text) end end)
    sBox.Focused:Connect(function() if not ddSelecting then rebuildDropdown(sBox.Text) end end)
    sBox.FocusLost:Connect(function() task.defer(function() task.defer(function() if not ddSelecting then ddFrame.Visible=false end end) end) end)
    AC.Players.PlayerRemoving:Connect(function(p) if AC.selectedTarget==p then AC.selectedTarget=nil; sBox.Text="" end end)

    AC.sectionLbl(pg,"ACTIONS",80)
    local S=98
    local vBtn=AC.halfBtn(pg,"View Target",0,0,S); local tBtn=AC.halfBtn(pg,"Teleport To",1,0,S)
    local brBtn=AC.halfBtn(pg,"Bring Here",0,1,S); local foBtn=AC.halfBtn(pg,"Focus Loop TP",1,1,S)
    local siBtn=AC.halfBtn(pg,"Sit on Head",0,2,S); local baBtn=AC.halfBtn(pg,"Backpack Mode",1,2,S)
    local clBtn=AC.halfBtn(pg,"Clear Target",0,3,S)
    AC.focusBtn=foBtn; AC.sitBtn=siBtn; AC.backBtn=baBtn; AC.sBox=sBox

    vBtn.MouseButton1Click:Connect(function() if AC.selectedTarget then AC.startViewing(AC.selectedTarget); AC.toast("Viewing "..AC.selectedTarget.Name) else AC.toast("No target",AC.RED_ERR) end end)
    tBtn.MouseButton1Click:Connect(function() if AC.selectedTarget and AC.selectedTarget.Character then local r=AC.selectedTarget.Character:FindFirstChild("HumanoidRootPart"); local m=AC.player.Character and AC.player.Character:FindFirstChild("HumanoidRootPart"); if r and m then m.CFrame=r.CFrame*CFrame.new(0,0,-3); AC.toast("TP'd to "..AC.selectedTarget.Name) end else AC.toast("No target",AC.RED_ERR) end end)
    brBtn.MouseButton1Click:Connect(function() if AC.selectedTarget and AC.selectedTarget.Character then local r=AC.selectedTarget.Character:FindFirstChild("HumanoidRootPart"); local m=AC.player.Character and AC.player.Character:FindFirstChild("HumanoidRootPart"); if r and m then r.CFrame=m.CFrame*CFrame.new(0,0,-3); AC.toast("Brought "..AC.selectedTarget.Name) end else AC.toast("No target",AC.RED_ERR) end end)
    foBtn.MouseButton1Click:Connect(function() if AC.focusActive then AC.focusActive=false; if AC.focusConn then AC.focusConn:Disconnect(); AC.focusConn=nil end; foBtn.Text="Focus Loop TP"; AC.toast("Focus OFF",AC.ORANGE_W); return end; if not AC.selectedTarget then AC.toast("No target",AC.RED_ERR); return end; AC.focusActive=true; foBtn.Text="Stop Focus"; AC.toast("Focus ON → "..AC.selectedTarget.Name); AC.focusConn=AC.RS.Heartbeat:Connect(function() if not AC.focusActive then return end; if AC.selectedTarget and AC.selectedTarget.Character then local r=AC.selectedTarget.Character:FindFirstChild("HumanoidRootPart"); local m=AC.player.Character and AC.player.Character:FindFirstChild("HumanoidRootPart"); if r and m then m.CFrame=r.CFrame*CFrame.new(0,0,-2) end end end) end)
    siBtn.MouseButton1Click:Connect(function() if AC.onHead then AC.onHead=false; if AC.headConn then AC.headConn:Disconnect(); AC.headConn=nil end; local h2=AC.player.Character and AC.player.Character:FindFirstChildOfClass("Humanoid"); if h2 then h2.Sit=false end; siBtn.Text="Sit on Head"; AC.toast("Off head",AC.ORANGE_W); return end; if not AC.selectedTarget or not AC.selectedTarget.Character then AC.toast("No target",AC.RED_ERR); return end; AC.onHead=true; siBtn.Text="Get Off"; AC.headConn=AC.RS.Heartbeat:Connect(function() if not AC.onHead then return end; local mc=AC.player.Character; local mr=mc and mc:FindFirstChild("HumanoidRootPart"); local mh=mc and mc:FindFirstChildOfClass("Humanoid"); local th=AC.selectedTarget.Character and AC.selectedTarget.Character:FindFirstChild("Head"); if mr and th then if mh then mh.Sit=true end; mr.CFrame=th.CFrame*CFrame.new(0,th.Size.Y+0.8,0) end end) end)
    baBtn.MouseButton1Click:Connect(function() if AC.inBp then AC.inBp=false; if AC.bpConn then AC.bpConn:Disconnect(); AC.bpConn=nil end; local mh=AC.player.Character and AC.player.Character:FindFirstChildOfClass("Humanoid"); if mh then mh.Sit=false end; baBtn.Text="Backpack Mode"; AC.toast("Backpack OFF",AC.ORANGE_W); return end; if not AC.selectedTarget or not AC.selectedTarget.Character then AC.toast("No target",AC.RED_ERR); return end; AC.inBp=true; baBtn.Text="Exit Backpack"; AC.bpConn=AC.RS.Heartbeat:Connect(function() if not AC.inBp then return end; local mr=AC.player.Character and AC.player.Character:FindFirstChild("HumanoidRootPart"); local mh2=AC.player.Character and AC.player.Character:FindFirstChildOfClass("Humanoid"); local tr=AC.selectedTarget.Character and AC.selectedTarget.Character:FindFirstChild("HumanoidRootPart"); if mr and tr then if mh2 then mh2.Sit=true end; mr.CFrame=tr.CFrame*CFrame.new(0,1,1.8) end end) end)
    clBtn.MouseButton1Click:Connect(function() AC.stopViewing(); AC.focusActive=false; AC.onHead=false; AC.inBp=false; AC.selectedTarget=nil; sBox.Text=""; foBtn.Text="Focus Loop TP"; siBtn.Text="Sit on Head"; baBtn.Text="Backpack Mode"; AC.toast("Target cleared") end)
    btn.MouseButton1Click:Connect(function() AC.switchTab("Player") end)
end

-- ─────────────────────────────────────────────────────────
-- MOVEMENT TAB
-- ─────────────────────────────────────────────────────────
do
    local btn=AC.createTab("Movement",3); local pg=AC.createPage(); AC.tabs["Movement"].page=pg
    AC.sectionLbl(pg,"LOCOMOTION",10)
    local _,_,onSpd=AC.makeSlider(pg,"Walk Speed",28,16,200,16,""); onSpd(function(v) local h=AC.player.Character and AC.player.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed=v end end)
    local _,_,onJmp=AC.makeSlider(pg,"Jump Power",90,7,300,50,""); onJmp(function(v) local h=AC.player.Character and AC.player.Character:FindFirstChildOfClass("Humanoid"); if h then h.JumpPower=v end end)
    AC.sectionLbl(pg,"ABILITIES",154)
    local _,_,onIJ=AC.makeToggle(pg,"Infinite Jump",172,false)
    onIJ(function(v) if v then AC.ijConn=AC.UIS.JumpRequest:Connect(function() local h=AC.player.Character and AC.player.Character:FindFirstChildOfClass("Humanoid"); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end) else if AC.ijConn then AC.ijConn:Disconnect(); AC.ijConn=nil end end end)
    local _,_,onNC=AC.makeToggle(pg,"Noclip",218,false)
    onNC(function(v) if v then AC.noclipConn=AC.RS.Stepped:Connect(function() if AC.player.Character then for _,p in ipairs(AC.player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end) else if AC.noclipConn then AC.noclipConn:Disconnect(); AC.noclipConn=nil end; if AC.player.Character then for _,p in ipairs(AC.player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end end end)
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

-- ─────────────────────────────────────────────────────────
-- WORLD TAB
-- ─────────────────────────────────────────────────────────
do
    local btn=AC.createTab("World",4); local pg=AC.createPage(); AC.tabs["World"].page=pg
    AC.sectionLbl(pg,"ENVIRONMENT",10)
    local _,_,onFB=AC.makeToggle(pg,"Fullbright",28,false); onFB(function(v) AC.Lighting.Brightness=v and 2 or 1; AC.Lighting.GlobalShadows=not v; AC.Lighting.Ambient=v and Color3.new(1,1,1) or Color3.fromRGB(127,127,127); AC.Lighting.OutdoorAmbient=v and Color3.new(1,1,1) or Color3.fromRGB(127,127,127) end)
    local _,_,onTm=AC.makeSlider(pg,"Time of Day",74,0,24,14,"h"); onTm(function(v) AC.Lighting.ClockTime=v end)
    local _,_,onGv=AC.makeSlider(pg,"Gravity",136,0,200,196,""); onGv(function(v) AC.WS.Gravity=v end)
    AC.sectionLbl(pg,"POST PROCESSING",200)
    local _,_,onSh=AC.makeToggle(pg,"Shaders (PShade Ultimate)",218,false); onSh(function(v) if v then task.spawn(function() pcall(function() safeRun("PSHADE") end) end); AC.toast("Shaders ON") else AC.toast("Rejoin to disable",AC.ORANGE_W) end end)
    AC.sectionLbl(pg,"PERFORMANCE",270)
    local _,_,onFU=AC.makeToggle(pg,"FPS Unlocker",288,false); onFU(function(v) if v then pcall(function() setfpscap(0) end) else pcall(function() setfpscap(60) end) end end)
    local _,_,onAFK=AC.makeToggle(pg,"Anti-AFK",334,false); onAFK(function(v) if v then local vu=game:GetService("VirtualUser"); AC.afkThread=task.spawn(function() while true do pcall(function() vu:Button2Down(Vector2.new(0,0),CFrame.new()); task.wait(0.1); vu:Button2Up(Vector2.new(0,0),CFrame.new()) end); task.wait(55) end end) else if AC.afkThread then task.cancel(AC.afkThread); AC.afkThread=nil end end end)
    btn.MouseButton1Click:Connect(function() AC.switchTab("World") end)
end

-- ─────────────────────────────────────────────────────────
-- EMOTES TAB
-- ─────────────────────────────────────────────────────────
do
    local btn=AC.createTab("Emotes",5); local pg=AC.createPage(); AC.tabs["Emotes"].page=pg

    -- Shared reanimation API
    local rnAPI=nil; local rnLoading=false; local rnActive=false

    local function ensureAPI(cb)
        if rnAPI then cb(rnAPI); return end
        if rnLoading then AC.toast("Still loading…",AC.ORANGE_W); return end
        rnLoading=true; AC.toast("Loading Reanimation API…",AC.ORANGE_W)
        task.spawn(function()
            local ok,result=pcall(function() return loadstring(game:HttpGet(_URLS.REANIMATION))() end)
            rnLoading=false
            if ok and result then rnAPI=result; AC.rnAPI=result; AC.toast("Reanimation ready!",AC.GREEN_OK); cb(rnAPI)
            else AC.toast("API load failed",AC.RED_ERR) end
        end)
    end

    -- Storage helpers
    local function readData(key,fallback)
        local ok,r=pcall(function() if isfile and isfile(key) then return AC.Http:JSONDecode(readfile(key)) end end)
        return (ok and r) or fallback
    end
    local function writeData(key,data)
        pcall(function() if not isfolder("BLEED") then makefolder("BLEED") end; writefile(key,AC.Http:JSONEncode(data)) end)
    end

    local rnFavs={}; local rnBinds={}; local rnSpeeds={}
    do
        local fl=readData("BLEED/rn_favs.json",{}); for _,id in ipairs(fl) do rnFavs[tostring(id)]=true end
        local bl=readData("BLEED/rn_binds.json",{}); for k,v in pairs(bl) do rnBinds[k]=v end
        local sl=readData("BLEED/rn_speeds.json",{}); for k,v in pairs(sl) do rnSpeeds[k]=v end
    end
    local function saveRnFavs() local l={}; for k in pairs(rnFavs) do l[#l+1]=k end; writeData("BLEED/rn_favs.json",l) end
    local function saveRnBinds() writeData("BLEED/rn_binds.json",rnBinds) end
    local function saveRnSpeeds() writeData("BLEED/rn_speeds.json",rnSpeeds) end

    -- Dynamic animation list: fetched from Rootleak/Animations via GitHub Contents API
    -- Falls back to hardcoded list if fetch fails
    local RN_ANIMS = {}  -- populated async on panel open
    local RN_BASE_URL = "https://raw.githubusercontent.com/Rootleak/Animations/main/"
    local RN_API_URL  = "https://api.github.com/repos/Rootleak/Animations/contents/"

    local function fetchRnAnimList(cb)
        task.spawn(function()
            local ok, res = pcall(function() return game:HttpGet(RN_API_URL) end)
            if ok and res and res ~= "" then
                local parsed = AC.Http:JSONDecode(res)
                local list = {}
                for _, entry in ipairs(parsed) do
                    if type(entry.name) == "string" and entry.name:sub(-4)==".lua" then
                        local name = entry.name:sub(1, -5)  -- strip .lua
                        -- URL-encode spaces → %20
                        local encoded = entry.name:gsub(" ", "%%20"):gsub("'", "%%27")
                        list[#list+1] = {name, RN_BASE_URL .. encoded}
                    end
                end
                if #list > 0 then RN_ANIMS = list; cb(list); return end
            end
            -- Fallback: hardcoded popular 50 from the repo
            RN_ANIMS = {
                {"7 Rings Dance","https://raw.githubusercontent.com/Rootleak/Animations/main/7%20Rings%20Dance%2Elua"},
                {"8-Bit Shuffle","https://raw.githubusercontent.com/Rootleak/Animations/main/8-Bit%20Shuffle%2Elua"},
                {"APT Dance","https://raw.githubusercontent.com/Rootleak/Animations/main/APT%20Dance%2Elua"},
                {"APT","https://raw.githubusercontent.com/Rootleak/Animations/main/APT%2Elua"},
                {"Abracadabra","https://raw.githubusercontent.com/Rootleak/Animations/main/Abracadabra%2Elua"},
                {"Aerostep","https://raw.githubusercontent.com/Rootleak/Animations/main/Aerostep%2Elua"},
                {"Air Guitar","https://raw.githubusercontent.com/Rootleak/Animations/main/Air%20Guitar%2Elua"},
                {"Alive","https://raw.githubusercontent.com/Rootleak/Animations/main/Alive%2Elua"},
                {"All About That Bass","https://raw.githubusercontent.com/Rootleak/Animations/main/All%20About%20That%20Bass%2Elua"},
                {"Americano","https://raw.githubusercontent.com/Rootleak/Animations/main/Americano%2Elua"},
                {"Arm Wiggle","https://raw.githubusercontent.com/Rootleak/Animations/main/Arm%20Wiggle%2Elua"},
                {"Awesome Strut","https://raw.githubusercontent.com/Rootleak/Animations/main/Awesome%20Strut%2Elua"},
                {"Backflip","https://raw.githubusercontent.com/Rootleak/Animations/main/Backflip%2Elua"},
                {"Bad Romance","https://raw.githubusercontent.com/Rootleak/Animations/main/Bad%20Romance%2Elua"},
                {"Ballerina","https://raw.githubusercontent.com/Rootleak/Animations/main/Ballerina%2Elua"},
                {"Beat It","https://raw.githubusercontent.com/Rootleak/Animations/main/Beat%20It%2Elua"},
                {"Billy Bounce","https://raw.githubusercontent.com/Rootleak/Animations/main/Billy%20Bounce%2Elua"},
                {"Boneless","https://raw.githubusercontent.com/Rootleak/Animations/main/Boneless%2Elua"},
                {"Carlton","https://raw.githubusercontent.com/Rootleak/Animations/main/Carlton%2Elua"},
                {"Chicken Dance","https://raw.githubusercontent.com/Rootleak/Animations/main/Chicken%20Dance%2Elua"},
                {"Dab","https://raw.githubusercontent.com/Rootleak/Animations/main/Dab%2Elua"},
                {"Drake","https://raw.githubusercontent.com/Rootleak/Animations/main/Drake%2Elua"},
                {"Electro Shuffle","https://raw.githubusercontent.com/Rootleak/Animations/main/Electro%20Shuffle%2Elua"},
                {"Floss","https://raw.githubusercontent.com/Rootleak/Animations/main/Floss%2Elua"},
                {"Gangnam Style","https://raw.githubusercontent.com/Rootleak/Animations/main/Gangnam%20Style%2Elua"},
                {"Griddy","https://raw.githubusercontent.com/Rootleak/Animations/main/Griddy%2Elua"},
                {"Headbang","https://raw.githubusercontent.com/Rootleak/Animations/main/Headbang%2Elua"},
                {"Hype","https://raw.githubusercontent.com/Rootleak/Animations/main/Hype%2Elua"},
                {"Infinite Dab","https://raw.githubusercontent.com/Rootleak/Animations/main/Infinite%20Dab%2Elua"},
                {"Jubilation","https://raw.githubusercontent.com/Rootleak/Animations/main/Jubilation%2Elua"},
                {"Jump Jive","https://raw.githubusercontent.com/Rootleak/Animations/main/Jump%20Jive%2Elua"},
                {"Kick It","https://raw.githubusercontent.com/Rootleak/Animations/main/Kick%20It%2Elua"},
                {"L Dance","https://raw.githubusercontent.com/Rootleak/Animations/main/L%20Dance%2Elua"},
                {"Moon Walk","https://raw.githubusercontent.com/Rootleak/Animations/main/Moon%20Walk%2Elua"},
                {"Ninja","https://raw.githubusercontent.com/Rootleak/Animations/main/Ninja%2Elua"},
                {"Orange Justice","https://raw.githubusercontent.com/Rootleak/Animations/main/Orange%20Justice%2Elua"},
                {"Phone It In","https://raw.githubusercontent.com/Rootleak/Animations/main/Phone%20It%20In%2Elua"},
                {"Pop Lock","https://raw.githubusercontent.com/Rootleak/Animations/main/Pop%20Lock%2Elua"},
                {"Ride The Pony","https://raw.githubusercontent.com/Rootleak/Animations/main/Ride%20The%20Pony%2Elua"},
                {"Robot","https://raw.githubusercontent.com/Rootleak/Animations/main/Robot%2Elua"},
                {"Running Man","https://raw.githubusercontent.com/Rootleak/Animations/main/Running%20Man%2Elua"},
                {"Salsa","https://raw.githubusercontent.com/Rootleak/Animations/main/Salsa%2Elua"},
                {"Samba","https://raw.githubusercontent.com/Rootleak/Animations/main/Samba%2Elua"},
                {"Scenario","https://raw.githubusercontent.com/Rootleak/Animations/main/Scenario%2Elua"},
                {"Shuffle","https://raw.githubusercontent.com/Rootleak/Animations/main/Shuffle%2Elua"},
                {"Snap","https://raw.githubusercontent.com/Rootleak/Animations/main/Snap%2Elua"},
                {"Squat Kick","https://raw.githubusercontent.com/Rootleak/Animations/main/Squat%20Kick%2Elua"},
                {"Take The L","https://raw.githubusercontent.com/Rootleak/Animations/main/Take%20The%20L%2Elua"},
                {"Thriller","https://raw.githubusercontent.com/Rootleak/Animations/main/Thriller%2Elua"},
                {"Tidy","https://raw.githubusercontent.com/Rootleak/Animations/main/Tidy%2Elua"},
                {"True Heart","https://raw.githubusercontent.com/Rootleak/Animations/main/True%20Heart%2Elua"},
                {"Turk Dance","https://raw.githubusercontent.com/Rootleak/Animations/main/Turk%20Dance%2Elua"},
                {"Twist","https://raw.githubusercontent.com/Rootleak/Animations/main/Twist%2Elua"},
                {"Wave","https://raw.githubusercontent.com/Rootleak/Animations/main/Wave%2Elua"},
                {"Wiggle","https://raw.githubusercontent.com/Rootleak/Animations/main/Wiggle%2Elua"},
                {"Worm","https://raw.githubusercontent.com/Rootleak/Animations/main/Worm%2Elua"},
            }
            cb(RN_ANIMS)
        end)
    end



    -- ── AC REANIMATION PANEL ──────────────────────────────
    local RN_W,RN_H=340,520
    local rnPanel=Instance.new("Frame",AC.screenGui)
    rnPanel.Size=UDim2.new(0,RN_W,0,RN_H); rnPanel.Position=UDim2.new(0.5,-170,0.5,-260)
    rnPanel.BackgroundColor3=Color3.fromRGB(12,12,14); rnPanel.BackgroundTransparency=0.18
    rnPanel.ZIndex=70; rnPanel.Visible=false; rnPanel.ClipsDescendants=true
    Instance.new("UICorner",rnPanel).CornerRadius=UDim.new(0,10)
    Instance.new("UIStroke",rnPanel).Color=AC.PUR_STROKE

    local rnHdr=Instance.new("Frame",rnPanel); rnHdr.Size=UDim2.new(1,0,0,40); rnHdr.BackgroundColor3=Color3.fromRGB(8,8,10); rnHdr.BackgroundTransparency=0.2; rnHdr.ZIndex=71; Instance.new("UICorner",rnHdr).CornerRadius=UDim.new(0,10)

    -- Top-left enable toggle
    local rnEnTog=Instance.new("TextButton",rnHdr); rnEnTog.Size=UDim2.new(0,36,0,20); rnEnTog.Position=UDim2.new(0,8,0.5,-10); rnEnTog.BackgroundColor3=Color3.fromRGB(40,40,40); rnEnTog.Text=""; rnEnTog.ZIndex=72; Instance.new("UICorner",rnEnTog).CornerRadius=UDim.new(1,0)
    local rnEnKnob=Instance.new("Frame",rnEnTog); rnEnKnob.Size=UDim2.new(0,16,0,16); rnEnKnob.Position=UDim2.new(0,2,0.5,-8); rnEnKnob.BackgroundColor3=AC.TXT_DIM; Instance.new("UICorner",rnEnKnob).CornerRadius=UDim.new(1,0)

    local rnTitleLbl=Instance.new("TextLabel",rnHdr); rnTitleLbl.Size=UDim2.new(1,-110,1,0); rnTitleLbl.Position=UDim2.new(0,52,0,0); rnTitleLbl.BackgroundTransparency=1; rnTitleLbl.Text="AC REANIMATION"; rnTitleLbl.TextColor3=AC.TXT_WHITE; rnTitleLbl.TextSize=14; rnTitleLbl.Font=Enum.Font.GothamBold; rnTitleLbl.TextXAlignment=Enum.TextXAlignment.Left; rnTitleLbl.ZIndex=72
    local rnStatusLbl=Instance.new("TextLabel",rnHdr); rnStatusLbl.Size=UDim2.new(1,-110,1,0); rnStatusLbl.Position=UDim2.new(0,52,0,14); rnStatusLbl.BackgroundTransparency=1; rnStatusLbl.Text="Loading animations..."; rnStatusLbl.TextColor3=AC.TXT_DIM; rnStatusLbl.TextSize=10; rnStatusLbl.Font=Enum.Font.Gotham; rnStatusLbl.TextXAlignment=Enum.TextXAlignment.Left; rnStatusLbl.ZIndex=72
    local rnCornerLbl=Instance.new("TextLabel",rnHdr); rnCornerLbl.Size=UDim2.new(0,24,1,0); rnCornerLbl.Position=UDim2.new(1,-30,0,0); rnCornerLbl.BackgroundTransparency=1; rnCornerLbl.Text="AC"; rnCornerLbl.TextColor3=AC.PUR_MID; rnCornerLbl.TextSize=9; rnCornerLbl.Font=Enum.Font.GothamBold; rnCornerLbl.TextXAlignment=Enum.TextXAlignment.Right; rnCornerLbl.ZIndex=72
    local rnClsBtn=Instance.new("TextButton",rnHdr); rnClsBtn.Size=UDim2.new(0,20,0,20); rnClsBtn.Position=UDim2.new(1,-24,0.5,-10); rnClsBtn.BackgroundColor3=Color3.fromRGB(35,35,35); rnClsBtn.Text="✕"; rnClsBtn.TextColor3=AC.TXT_DIM; rnClsBtn.TextSize=11; rnClsBtn.Font=Enum.Font.GothamBold; rnClsBtn.ZIndex=72; Instance.new("UICorner",rnClsBtn).CornerRadius=UDim.new(0,5)
    rnClsBtn.MouseButton1Click:Connect(function() rnPanel.Visible=false end)

    -- All | Favs tabs
    local rnTabBar=Instance.new("Frame",rnPanel); rnTabBar.Size=UDim2.new(1,-16,0,28); rnTabBar.Position=UDim2.new(0,8,0,44); rnTabBar.BackgroundColor3=Color3.fromRGB(20,20,24); rnTabBar.BackgroundTransparency=0.3; rnTabBar.ZIndex=71; Instance.new("UICorner",rnTabBar).CornerRadius=UDim.new(0,7)
    local rnTabAll=Instance.new("TextButton",rnTabBar); rnTabAll.Size=UDim2.new(0.5,0,1,0); rnTabAll.BackgroundColor3=AC.PUR_DARK; rnTabAll.Text="All"; rnTabAll.TextColor3=AC.TXT_WHITE; rnTabAll.TextSize=12; rnTabAll.Font=Enum.Font.GothamBold; rnTabAll.ZIndex=72; Instance.new("UICorner",rnTabAll).CornerRadius=UDim.new(0,6)
    local rnTabFav=Instance.new("TextButton",rnTabBar); rnTabFav.Size=UDim2.new(0.5,0,1,0); rnTabFav.Position=UDim2.new(0.5,0,0,0); rnTabFav.BackgroundColor3=Color3.fromRGB(22,22,22); rnTabFav.BackgroundTransparency=0.5; rnTabFav.Text="Favs"; rnTabFav.TextColor3=AC.TXT_DIM; rnTabFav.TextSize=12; rnTabFav.Font=Enum.Font.Gotham; rnTabFav.ZIndex=72; Instance.new("UICorner",rnTabFav).CornerRadius=UDim.new(0,6)

    local rnSearch=Instance.new("TextBox",rnPanel); rnSearch.Size=UDim2.new(1,-16,0,26); rnSearch.Position=UDim2.new(0,8,0,76); rnSearch.BackgroundColor3=Color3.fromRGB(20,20,24); rnSearch.BackgroundTransparency=0.3; rnSearch.PlaceholderText="Search..."; rnSearch.PlaceholderColor3=AC.TXT_DIM; rnSearch.Text=""; rnSearch.TextColor3=AC.TXT_MAIN; rnSearch.TextSize=12; rnSearch.Font=Enum.Font.Gotham; rnSearch.ClearTextOnFocus=false; rnSearch.ZIndex=71; Instance.new("UICorner",rnSearch).CornerRadius=UDim.new(0,7); Instance.new("UIStroke",rnSearch).Color=AC.PUR_STROKE; Instance.new("UIPadding",rnSearch).PaddingLeft=UDim.new(0,8)

    local rnScroll=Instance.new("ScrollingFrame",rnPanel); rnScroll.Size=UDim2.new(1,-16,0,248); rnScroll.Position=UDim2.new(0,8,0,108); rnScroll.BackgroundTransparency=1; rnScroll.BorderSizePixel=0; rnScroll.ScrollBarThickness=3; rnScroll.ScrollBarImageColor3=AC.PUR_MID; rnScroll.AutomaticCanvasSize=Enum.AutomaticSize.None; rnScroll.CanvasSize=UDim2.new(0,0,0,0); rnScroll.ZIndex=71
    local rnListLay=Instance.new("UIListLayout",rnScroll); rnListLay.FillDirection=Enum.FillDirection.Vertical; rnListLay.Padding=UDim.new(0,2); rnListLay.SortOrder=Enum.SortOrder.LayoutOrder

    -- Speed slider 0-10
    local rnSpdLbl=Instance.new("TextLabel",rnPanel); rnSpdLbl.Size=UDim2.new(0,55,0,14); rnSpdLbl.Position=UDim2.new(0,8,0,362); rnSpdLbl.BackgroundTransparency=1; rnSpdLbl.Text="Speed:"; rnSpdLbl.TextColor3=AC.TXT_DIM; rnSpdLbl.TextSize=10; rnSpdLbl.Font=Enum.Font.GothamBold; rnSpdLbl.ZIndex=71
    local rnSpdVal=Instance.new("TextLabel",rnPanel); rnSpdVal.Size=UDim2.new(0,30,0,14); rnSpdVal.Position=UDim2.new(1,-68,0,362); rnSpdVal.BackgroundTransparency=1; rnSpdVal.Text="5"; rnSpdVal.TextColor3=AC.TXT_WHITE; rnSpdVal.TextSize=10; rnSpdVal.Font=Enum.Font.GothamBold; rnSpdVal.ZIndex=71
    local rnRstSpd=Instance.new("TextButton",rnPanel); rnRstSpd.Size=UDim2.new(0,40,0,14); rnRstSpd.Position=UDim2.new(1,-8,0,362); rnRstSpd.BackgroundTransparency=1; rnRstSpd.Text="Reset"; rnRstSpd.TextColor3=AC.TXT_DIM; rnRstSpd.TextSize=9; rnRstSpd.Font=Enum.Font.Gotham; rnRstSpd.ZIndex=71
    local rnSpdTrack=Instance.new("Frame",rnPanel); rnSpdTrack.Size=UDim2.new(1,-16,0,6); rnSpdTrack.Position=UDim2.new(0,8,0,380); rnSpdTrack.BackgroundColor3=Color3.fromRGB(30,30,35); rnSpdTrack.ZIndex=71; Instance.new("UICorner",rnSpdTrack).CornerRadius=UDim.new(1,0)
    local rnSpdFill=Instance.new("Frame",rnSpdTrack); rnSpdFill.Size=UDim2.new(0.5,0,1,0); rnSpdFill.BackgroundColor3=AC.PUR_MID; rnSpdFill.ZIndex=72; Instance.new("UICorner",rnSpdFill).CornerRadius=UDim.new(1,0)
    local rnSpdKnob=Instance.new("TextButton",rnSpdTrack); rnSpdKnob.Size=UDim2.new(0,14,0,14); rnSpdKnob.Position=UDim2.new(0.5,-7,0.5,-7); rnSpdKnob.BackgroundColor3=AC.PUR_GLOW; rnSpdKnob.Text=""; rnSpdKnob.ZIndex=73; Instance.new("UICorner",rnSpdKnob).CornerRadius=UDim.new(1,0)

    local rnSpdCur=5.0; local rnSpdDrag=false
    local function setRnSpd(v)
        v=math.clamp(math.floor(v*10+0.5)/10,0,10); rnSpdCur=v
        rnSpdVal.Text=tostring(v); local r=v/10; rnSpdFill.Size=UDim2.new(r,0,1,0); rnSpdKnob.Position=UDim2.new(r,-7,0.5,-7)
        if rnAPI and rnActive then pcall(function() rnAPI.set_animation_speed(v) end) end
    end
    rnSpdKnob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then rnSpdDrag=true end end)
    rnSpdTrack.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then rnSpdDrag=true; setRnSpd((AC.UIS:GetMouseLocation().X-rnSpdTrack.AbsolutePosition.X)/rnSpdTrack.AbsoluteSize.X*10) end end)
    AC.UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then rnSpdDrag=false end end)
    AC.RS.RenderStepped:Connect(function() if rnSpdDrag then setRnSpd((AC.UIS:GetMouseLocation().X-rnSpdTrack.AbsolutePosition.X)/rnSpdTrack.AbsoluteSize.X*10) end end)
    rnRstSpd.MouseButton1Click:Connect(function() setRnSpd(5) end)
    setRnSpd(5)

    -- Number row 1,3,5,7,9
    local NUM_VALS={1,3,5,7,9}; local numBtnBinds={}
    local numRowF=Instance.new("Frame",rnPanel); numRowF.Size=UDim2.new(1,-16,0,52); numRowF.Position=UDim2.new(0,8,0,392); numRowF.BackgroundTransparency=1; numRowF.ZIndex=71
    local bW2=math.floor((RN_W-16-8*4)/5)
    for i,nv in ipairs(NUM_VALS) do
        local xOff=(i-1)*(bW2+8)
        -- Top slot: shows "Bind" until a key is bound, clicking captures keybind
        -- Bound key triggers speed preset (nv = 1,3,5,7,9)
        local nb=Instance.new("TextButton",numRowF)
        nb.Size=UDim2.new(0,bW2,0,22); nb.Position=UDim2.new(0,xOff,0,0)
        nb.BackgroundColor3=Color3.fromRGB(20,20,24); nb.BackgroundTransparency=0.2
        nb.Text=tostring(nv); nb.TextColor3=AC.PUR_GLOW; nb.TextSize=13; nb.Font=Enum.Font.GothamBold; nb.ZIndex=72
        Instance.new("UICorner",nb).CornerRadius=UDim.new(0,5); Instance.new("UIStroke",nb).Color=AC.PUR_STROKE
        -- Bottom slot: keybind capture — shows "Bind" until bound
        local kb=Instance.new("TextButton",numRowF)
        kb.Size=UDim2.new(0,bW2,0,22); kb.Position=UDim2.new(0,xOff,0,26)
        kb.BackgroundColor3=Color3.fromRGB(20,20,24); kb.BackgroundTransparency=0.2
        kb.Text="Bind"; kb.TextColor3=AC.TXT_DIM; kb.TextSize=10; kb.Font=Enum.Font.Gotham; kb.ZIndex=72
        Instance.new("UICorner",kb).CornerRadius=UDim.new(0,5); Instance.new("UIStroke",kb).Color=AC.PUR_STROKE
        numBtnBinds[i]={numBtn=nb,keyBtn=kb,savedKey=nil,val=nv}
        local nvCopy=nv; local kbCopy=kb; local idx=i
        nb.MouseButton1Click:Connect(function() setRnSpd(nvCopy) end)
        local kListen=false; local kConn=nil
        -- clicking the Bind slot opens keybind capture
        local function startBindListen()
            if kListen then
                kListen=false; if kConn then kConn:Disconnect(); kConn=nil end
                kb.Text=numBtnBinds[idx].savedKey and numBtnBinds[idx].savedKey:sub(1,4) or "Bind"
                kb.TextColor3=numBtnBinds[idx].savedKey and AC.TXT_WHITE or AC.TXT_DIM
                return
            end
            kListen=true; kb.Text="..."; kb.TextColor3=AC.PUR_GLOW
            kConn=AC.UIS.InputBegan:Connect(function(inp,gp)
                if gp or inp.UserInputType~=Enum.UserInputType.Keyboard then return end
                local ok2,kn=pcall(function() return inp.KeyCode.Name end)
                local cancelKeys = {Escape=true, Delete=true, Backspace=true}
                if not ok2 or not kn or kn=="Unknown" or cancelKeys[kn] then
                    -- Cancel bind capture
                    kListen=false; if kConn then kConn:Disconnect(); kConn=nil end
                    kb.Text=numBtnBinds[idx].savedKey and numBtnBinds[idx].savedKey:sub(1,4) or "Bind"
                    kb.TextColor3=numBtnBinds[idx].savedKey and AC.TXT_WHITE or AC.TXT_DIM
                    return
                end
                numBtnBinds[idx].savedKey=kn
                kb.Text=kn:sub(1,4); kb.TextColor3=AC.TXT_WHITE
                kListen=false; if kConn then kConn:Disconnect(); kConn=nil end
                AC.toast("Speed "..nv.." bound to "..kn,AC.PUR_BRIGHT)
            end)
        end
        kb.MouseButton1Click:Connect(startBindListen)
    end
    -- Listen for number-row keybinds to trigger speed presets
    AC.UIS.InputBegan:Connect(function(inp,gp)
        if gp or inp.UserInputType~=Enum.UserInputType.Keyboard then return end
        local ok2,kn=pcall(function() return inp.KeyCode.Name end); if not ok2 or not kn then return end
        for _,slot in ipairs(numBtnBinds) do if slot.savedKey==kn then setRnSpd(slot.val) end end
    end)

    -- Reanimation toggle logic
    local rnNowUrl=nil; local rnHighRow=nil
    local function setRnTogUI(active)
        rnActive=active; AC.rnActive=active
        if active then AC.TS:Create(rnEnTog,TweenInfo.new(0.2),{BackgroundColor3=AC.PUR_MID}):Play(); AC.TS:Create(rnEnKnob,TweenInfo.new(0.2),{Position=UDim2.new(1,-18,0.5,-8),BackgroundColor3=AC.PUR_GLOW}):Play()
        else AC.TS:Create(rnEnTog,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(40,40,40)}):Play(); AC.TS:Create(rnEnKnob,TweenInfo.new(0.2),{Position=UDim2.new(0,2,0.5,-8),BackgroundColor3=AC.TXT_DIM}):Play() end
    end
    rnEnTog.MouseButton1Click:Connect(function()
        ensureAPI(function(api)
            if not rnActive then
                -- FIX: reset first to prevent double-reanimate ragdoll
                pcall(function() api.reanimate(false) end); task.wait(0.05)
                local ok,err=pcall(function() api.reanimate(true) end)
                if ok then setRnTogUI(true); rnStatusLbl.Text="Ready"; AC.toast("Reanimation ON",AC.GREEN_OK)
                else AC.toast("Reanimate failed",AC.RED_ERR); print("[AC]",tostring(err)) end
            else
                if rnNowUrl then pcall(function() api.stop_animation() end) end
                pcall(function() api.reanimate(false) end)
                -- FIX: restore humanoid state to prevent freeze/ragdoll
                local char=AC.player.Character
                if char then
                    local hum=char:FindFirstChildOfClass("Humanoid")
                    if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end); hum.PlatformStand=false end
                end
                setRnTogUI(false); rnNowUrl=nil
                if rnHighRow then pcall(function() rnHighRow.BackgroundColor3=Color3.fromRGB(14,14,18) end); rnHighRow=nil end
                rnStatusLbl.Text="Ready"; AC.toast("Reanimation OFF",AC.ORANGE_W)
            end
        end)
    end)

    -- Build emote rows
    local rnAllRows={}; local rnFavOnly=false

    local function buildRnRow(name,url,idx)
        local row=Instance.new("TextButton",rnScroll); row.Size=UDim2.new(1,0,0,34); row.BackgroundColor3=Color3.fromRGB(14,14,18); row.BackgroundTransparency=0.1; row.Text=""; row.LayoutOrder=idx; row.ZIndex=72; Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
        local rS=Instance.new("UIStroke",row); rS.Color=AC.PUR_STROKE; rS.Thickness=1; rS.Transparency=0.7
        local idxStr=tostring(idx)
        local star=Instance.new("TextButton",row); star.Size=UDim2.new(0,22,0,22); star.Position=UDim2.new(0,6,0.5,-11); star.BackgroundTransparency=1; star.Text=rnFavs[idxStr] and "★" or "☆"; star.TextColor3=rnFavs[idxStr] and Color3.fromRGB(255,210,60) or AC.TXT_DIM; star.TextSize=14; star.Font=Enum.Font.Gotham; star.ZIndex=73
        local nLbl=Instance.new("TextLabel",row); nLbl.Size=UDim2.new(1,-120,1,0); nLbl.Position=UDim2.new(0,32,0,0); nLbl.BackgroundTransparency=1; nLbl.Text=name; nLbl.TextColor3=AC.TXT_MAIN; nLbl.TextSize=12; nLbl.Font=Enum.Font.Gotham; nLbl.TextXAlignment=Enum.TextXAlignment.Left; nLbl.TextTruncate=Enum.TextTruncate.AtEnd; nLbl.ZIndex=73
        local emoteSpd=rnSpeeds[idxStr] or 1.0
        local spdDn=Instance.new("TextButton",row); spdDn.Size=UDim2.new(0,14,0,14); spdDn.Position=UDim2.new(1,-60,0.5,-7); spdDn.BackgroundColor3=Color3.fromRGB(30,30,36); spdDn.Text="-"; spdDn.TextColor3=AC.TXT_DIM; spdDn.TextSize=11; spdDn.Font=Enum.Font.GothamBold; spdDn.ZIndex=73; Instance.new("UICorner",spdDn).CornerRadius=UDim.new(0,4)
        local spdTag=Instance.new("TextLabel",row); spdTag.Size=UDim2.new(0,26,0,14); spdTag.Position=UDim2.new(1,-44,0.5,-7); spdTag.BackgroundColor3=Color3.fromRGB(20,20,26); spdTag.Text=tostring(emoteSpd); spdTag.TextColor3=AC.TXT_DIM; spdTag.TextSize=9; spdTag.Font=Enum.Font.Gotham; spdTag.ZIndex=73; spdTag.BackgroundTransparency=0.3; Instance.new("UICorner",spdTag).CornerRadius=UDim.new(0,4)
        local spdUp=Instance.new("TextButton",row); spdUp.Size=UDim2.new(0,14,0,14); spdUp.Position=UDim2.new(1,-16,0.5,-7); spdUp.BackgroundColor3=Color3.fromRGB(30,30,36); spdUp.Text="+"; spdUp.TextColor3=AC.TXT_DIM; spdUp.TextSize=11; spdUp.Font=Enum.Font.GothamBold; spdUp.ZIndex=73; Instance.new("UICorner",spdUp).CornerRadius=UDim.new(0,4)
        local bLbl=Instance.new("TextButton",row); bLbl.Size=UDim2.new(0,28,0,14); bLbl.Position=UDim2.new(1,-90,0.5,-7); bLbl.BackgroundColor3=Color3.fromRGB(26,26,32); bLbl.Text=rnBinds[idxStr] and rnBinds[idxStr]:sub(1,3) or "Bind"; bLbl.TextColor3=rnBinds[idxStr] and AC.TXT_WHITE or AC.TXT_DIM; bLbl.TextSize=8; bLbl.Font=Enum.Font.Gotham; bLbl.ZIndex=73; bLbl.BackgroundTransparency=0.3; Instance.new("UICorner",bLbl).CornerRadius=UDim.new(0,4)
        local urlC,nameC=url,name

        star.MouseButton1Click:Connect(function()
            if rnFavs[idxStr] then rnFavs[idxStr]=nil; star.Text="☆"; star.TextColor3=AC.TXT_DIM
            else rnFavs[idxStr]=true; star.Text="★"; AC.TS:Create(star,TweenInfo.new(0.15),{TextColor3=Color3.fromRGB(255,210,60)}):Play() end
            saveRnFavs(); if rnFavOnly then row.Visible=rnFavs[idxStr]~=nil end
        end)
        spdDn.MouseButton1Click:Connect(function()
            emoteSpd=math.clamp(math.floor((emoteSpd-0.1)*10+0.5)/10,0.1,12); spdTag.Text=tostring(emoteSpd); rnSpeeds[idxStr]=emoteSpd; saveRnSpeeds()
            if rnNowUrl==urlC and rnAPI then pcall(function() rnAPI.set_animation_speed(emoteSpd) end) end
        end)
        spdUp.MouseButton1Click:Connect(function()
            emoteSpd=math.clamp(math.floor((emoteSpd+0.1)*10+0.5)/10,0.1,12); spdTag.Text=tostring(emoteSpd); rnSpeeds[idxStr]=emoteSpd; saveRnSpeeds()
            if rnNowUrl==urlC and rnAPI then pcall(function() rnAPI.set_animation_speed(emoteSpd) end) end
        end)

        local bListen=false; local bConn=nil
        bLbl.MouseButton1Click:Connect(function()
            if bListen then bListen=false; if bConn then bConn:Disconnect(); bConn=nil end; bLbl.Text=rnBinds[idxStr] and rnBinds[idxStr]:sub(1,3) or "Bind"; return end
            bListen=true; bLbl.Text="..."; bLbl.TextColor3=AC.PUR_GLOW
            bConn=AC.UIS.InputBegan:Connect(function(inp,gp)
                if gp or inp.UserInputType~=Enum.UserInputType.Keyboard then return end
                local ok2,kn=pcall(function() return inp.KeyCode.Name end); if not ok2 or not kn or kn=="Unknown" then return end
                -- Delete/Backspace clears the bind; Escape cancels without clearing
                if kn=="Escape" or kn=="Delete" or kn=="Backspace" then
                    bListen=false; if bConn then bConn:Disconnect(); bConn=nil end
                    if kn=="Delete" or kn=="Backspace" then
                        rnBinds[idxStr]=nil; saveRnBinds()
                        bLbl.Text="Bind"; bLbl.TextColor3=AC.TXT_DIM
                        AC.toast("Bind cleared",AC.ORANGE_W)
                    else
                        bLbl.Text=rnBinds[idxStr] and rnBinds[idxStr]:sub(1,3) or "Bind"
                        bLbl.TextColor3=rnBinds[idxStr] and AC.TXT_WHITE or AC.TXT_DIM
                    end
                    return
                end
                rnBinds[idxStr]=kn; saveRnBinds(); bLbl.Text=kn:sub(1,3); bLbl.TextColor3=AC.TXT_WHITE
                bListen=false; if bConn then bConn:Disconnect(); bConn=nil end; AC.toast("Bound "..kn.." → "..nameC,AC.PUR_BRIGHT)
            end)
        end)

        local highlighted=false
        row.MouseButton1Click:Connect(function()
            if not rnActive then AC.toast("Enable Reanimation first!",AC.ORANGE_W); return end
            ensureAPI(function(api)
                if highlighted then
                    -- Per README: calling play_animation with same URL stops it,
                    -- but we explicitly call stop_animation for reliability
                    local stopOk = pcall(function() api.stop_animation() end)
                    if not stopOk then
                        -- Fallback: play same url again (README says it stops if same url)
                        pcall(function() api.play_animation(urlC, emoteSpd) end)
                    end
                    rnNowUrl=nil; highlighted=false
                    AC.TS:Create(row,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(14,14,18)}):Play()
                    rS.Color=AC.PUR_STROKE; rnHighRow=nil
                    AC.toast("Stopped: "..nameC,AC.ORANGE_W); return
                end
                if rnHighRow then
                    pcall(function() AC.TS:Create(rnHighRow,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(14,14,18)}):Play(); local ps=rnHighRow:FindFirstChildOfClass("UIStroke"); if ps then ps.Color=AC.PUR_STROKE end end)
                end
                pcall(function() api.play_animation(urlC,emoteSpd) end); rnNowUrl=urlC; highlighted=true; rnHighRow=row
                AC.TS:Create(row,TweenInfo.new(0.15),{BackgroundColor3=AC.PUR_DARK}):Play(); rS.Color=AC.PUR_BRIGHT
                AC.toast("♪ "..nameC,AC.PUR_BRIGHT)
            end)
        end)
        row.MouseEnter:Connect(function() if not highlighted then AC.TS:Create(row,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(22,22,28)}):Play() end end)
        row.MouseLeave:Connect(function() if not highlighted then AC.TS:Create(row,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(14,14,18)}):Play() end end)
        return {row=row,nameLower=name:lower(),url=url,index=idx}
    end

    task.spawn(function()
        fetchRnAnimList(function(list)
            for i,a in ipairs(list) do
                rnAllRows[i]=buildRnRow(a[1],a[2],i)
                if i%20==0 then
                    rnScroll.CanvasSize=UDim2.new(0,0,0,i*36+8)
                    task.wait()
                end
            end
            rnScroll.CanvasSize=UDim2.new(0,0,0,#list*36+8)
            rnStatusLbl.Text="Loaded "..#list.." animations"
            AC.toast("Loaded "..#list.." animations",AC.GREEN_OK)
        end)
    end)

    local function rnSwitchTab(favOnly)
        rnFavOnly=favOnly
        if favOnly then AC.TS:Create(rnTabFav,TweenInfo.new(0.15),{BackgroundColor3=AC.PUR_DARK,BackgroundTransparency=0}):Play(); rnTabFav.TextColor3=AC.TXT_WHITE; AC.TS:Create(rnTabAll,TweenInfo.new(0.15),{BackgroundTransparency=0.5,BackgroundColor3=Color3.fromRGB(22,22,22)}):Play(); rnTabAll.TextColor3=AC.TXT_DIM
        else AC.TS:Create(rnTabAll,TweenInfo.new(0.15),{BackgroundColor3=AC.PUR_DARK,BackgroundTransparency=0}):Play(); rnTabAll.TextColor3=AC.TXT_WHITE; AC.TS:Create(rnTabFav,TweenInfo.new(0.15),{BackgroundTransparency=0.5,BackgroundColor3=Color3.fromRGB(22,22,22)}):Play(); rnTabFav.TextColor3=AC.TXT_DIM end
        local q=rnSearch.Text:lower()
        for _,r in ipairs(rnAllRows) do local sf=(not favOnly) or rnFavs[tostring(r.index)]; r.row.Visible=sf and (q=="" or r.nameLower:find(q,1,true)~=nil) end
    end
    rnTabAll.MouseButton1Click:Connect(function() rnSwitchTab(false) end)
    rnTabFav.MouseButton1Click:Connect(function() rnSwitchTab(true) end)
    rnSearch:GetPropertyChangedSignal("Text"):Connect(function()
        local q=rnSearch.Text:lower()
        for _,r in ipairs(rnAllRows) do local sf=(not rnFavOnly) or rnFavs[tostring(r.index)]; r.row.Visible=sf and (q=="" or r.nameLower:find(q,1,true)~=nil) end
    end)

    -- Global keybind listener for RN emote binds
    AC.UIS.InputBegan:Connect(function(inp,gp)
        if gp or inp.UserInputType~=Enum.UserInputType.Keyboard then return end
        local ok2,kn=pcall(function() return inp.KeyCode.Name end); if not ok2 or not kn then return end
        if rnActive then
            for idxStr,bk in pairs(rnBinds) do
                if bk==kn then local idx=tonumber(idxStr); if idx and RN_ANIMS[idx] then ensureAPI(function(api) pcall(function() api.play_animation(RN_ANIMS[idx][2],rnSpeeds[idxStr] or 1.0) end); AC.toast("♪ "..RN_ANIMS[idx][1],AC.PUR_BRIGHT) end) end end end
        end
    end)

    local rnDrag,rnDS,rnSP=false,nil,nil
    rnHdr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then rnDrag=true; rnDS=i.Position; rnSP=rnPanel.Position; i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then rnDrag=false end end) end end)
    AC.UIS.InputChanged:Connect(function(i) if rnDrag and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-rnDS; rnPanel.Position=UDim2.new(rnSP.X.Scale,rnSP.X.Offset+d.X,rnSP.Y.Scale,rnSP.Y.Offset+d.Y) end end)

    -- ── UGC EMOTES PANEL ─────────────────────────────────
    local UGC_W,UGC_H=360,500
    local ugcPanel=Instance.new("Frame",AC.screenGui)
    ugcPanel.Size=UDim2.new(0,UGC_W,0,UGC_H+44); ugcPanel.Position=UDim2.new(0.5,-180,0.5,-250)
    ugcPanel.BackgroundColor3=Color3.fromRGB(12,12,14); ugcPanel.BackgroundTransparency=0.18
    ugcPanel.ZIndex=65; ugcPanel.Visible=false; ugcPanel.ClipsDescendants=true
    Instance.new("UICorner",ugcPanel).CornerRadius=UDim.new(0,10); Instance.new("UIStroke",ugcPanel).Color=AC.PUR_STROKE

    local ugcHdr=Instance.new("Frame",ugcPanel); ugcHdr.Size=UDim2.new(1,0,0,40); ugcHdr.BackgroundColor3=Color3.fromRGB(8,8,10); ugcHdr.BackgroundTransparency=0.2; ugcHdr.ZIndex=66; Instance.new("UICorner",ugcHdr).CornerRadius=UDim.new(0,10)
    local ugcTitleLbl=Instance.new("TextLabel",ugcHdr); ugcTitleLbl.Size=UDim2.new(1,-80,1,0); ugcTitleLbl.Position=UDim2.new(0,14,0,0); ugcTitleLbl.BackgroundTransparency=1; ugcTitleLbl.Text="UGC EMOTES"; ugcTitleLbl.TextColor3=AC.TXT_WHITE; ugcTitleLbl.TextSize=14; ugcTitleLbl.Font=Enum.Font.GothamBold; ugcTitleLbl.TextXAlignment=Enum.TextXAlignment.Left; ugcTitleLbl.ZIndex=67
    local ugcStatusLbl=Instance.new("TextLabel",ugcHdr); ugcStatusLbl.Size=UDim2.new(1,-80,1,0); ugcStatusLbl.Position=UDim2.new(0,14,0,14); ugcStatusLbl.BackgroundTransparency=1; ugcStatusLbl.Text="Loading..."; ugcStatusLbl.TextColor3=AC.TXT_DIM; ugcStatusLbl.TextSize=10; ugcStatusLbl.Font=Enum.Font.Gotham; ugcStatusLbl.TextXAlignment=Enum.TextXAlignment.Left; ugcStatusLbl.ZIndex=67
    local ugcAcLbl=Instance.new("TextLabel",ugcHdr); ugcAcLbl.Size=UDim2.new(0,24,1,0); ugcAcLbl.Position=UDim2.new(1,-30,0,0); ugcAcLbl.BackgroundTransparency=1; ugcAcLbl.Text="AC"; ugcAcLbl.TextColor3=AC.PUR_MID; ugcAcLbl.TextSize=9; ugcAcLbl.Font=Enum.Font.GothamBold; ugcAcLbl.TextXAlignment=Enum.TextXAlignment.Right; ugcAcLbl.ZIndex=67
    local ugcClsBtn=Instance.new("TextButton",ugcHdr); ugcClsBtn.Size=UDim2.new(0,20,0,20); ugcClsBtn.Position=UDim2.new(1,-24,0.5,-10); ugcClsBtn.BackgroundColor3=Color3.fromRGB(35,35,35); ugcClsBtn.Text="✕"; ugcClsBtn.TextColor3=AC.TXT_DIM; ugcClsBtn.TextSize=11; ugcClsBtn.Font=Enum.Font.GothamBold; ugcClsBtn.ZIndex=67; Instance.new("UICorner",ugcClsBtn).CornerRadius=UDim.new(0,5)
    ugcClsBtn.MouseButton1Click:Connect(function() ugcPanel.Visible=false end)

    -- Tabs: All | Favs | States
    local ugcTabBar=Instance.new("Frame",ugcPanel); ugcTabBar.Size=UDim2.new(1,-16,0,28); ugcTabBar.Position=UDim2.new(0,8,0,44); ugcTabBar.BackgroundColor3=Color3.fromRGB(20,20,24); ugcTabBar.BackgroundTransparency=0.3; ugcTabBar.ZIndex=66; Instance.new("UICorner",ugcTabBar).CornerRadius=UDim.new(0,7)
    local UGC_TAB_NAMES={"All","Favs","States"}; local ugcTabBtns={}; local ugcActiveTab="All"
    for i,tn in ipairs(UGC_TAB_NAMES) do
        local tb=Instance.new("TextButton",ugcTabBar); tb.Size=UDim2.new(1/3,0,1,0); tb.Position=UDim2.new((i-1)/3,0,0,0); tb.BackgroundColor3=i==1 and AC.PUR_DARK or Color3.fromRGB(22,22,22); tb.BackgroundTransparency=i==1 and 0 or 0.5; tb.Text=tn; tb.TextColor3=i==1 and AC.TXT_WHITE or AC.TXT_DIM; tb.TextSize=12; tb.Font=i==1 and Enum.Font.GothamBold or Enum.Font.Gotham; tb.ZIndex=67; Instance.new("UICorner",tb).CornerRadius=UDim.new(0,6); ugcTabBtns[tn]=tb
    end

    local ugcSrch=Instance.new("TextBox",ugcPanel); ugcSrch.Size=UDim2.new(1,-16,0,26); ugcSrch.Position=UDim2.new(0,8,0,76); ugcSrch.BackgroundColor3=Color3.fromRGB(20,20,24); ugcSrch.BackgroundTransparency=0.3; ugcSrch.PlaceholderText="Search emotes..."; ugcSrch.PlaceholderColor3=AC.TXT_DIM; ugcSrch.Text=""; ugcSrch.TextColor3=AC.TXT_MAIN; ugcSrch.TextSize=12; ugcSrch.Font=Enum.Font.Gotham; ugcSrch.ClearTextOnFocus=false; ugcSrch.ZIndex=66; Instance.new("UICorner",ugcSrch).CornerRadius=UDim.new(0,7); Instance.new("UIStroke",ugcSrch).Color=AC.PUR_STROKE; Instance.new("UIPadding",ugcSrch).PaddingLeft=UDim.new(0,8)

    -- List page (All/Favs)
    local ugcListPage=Instance.new("Frame",ugcPanel); ugcListPage.Size=UDim2.new(1,-16,0,250); ugcListPage.Position=UDim2.new(0,8,0,108); ugcListPage.BackgroundTransparency=1; ugcListPage.ZIndex=66
    local ugcScroll=Instance.new("ScrollingFrame",ugcListPage); ugcScroll.Size=UDim2.new(1,0,1,0); ugcScroll.BackgroundTransparency=1; ugcScroll.BorderSizePixel=0; ugcScroll.ScrollBarThickness=3; ugcScroll.ScrollBarImageColor3=AC.PUR_MID; ugcScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; ugcScroll.CanvasSize=UDim2.new(0,0,0,0); ugcScroll.ZIndex=67
    Instance.new("UIListLayout",ugcScroll).Padding=UDim.new(0,2)

    -- States page
    local ugcStatesPage=Instance.new("Frame",ugcPanel); ugcStatesPage.Size=UDim2.new(1,-16,0,250); ugcStatesPage.Position=UDim2.new(0,8,0,108); ugcStatesPage.BackgroundTransparency=1; ugcStatesPage.Visible=false; ugcStatesPage.ZIndex=66
    local ugcStatesSF=Instance.new("ScrollingFrame",ugcStatesPage); ugcStatesSF.Size=UDim2.new(1,0,1,0); ugcStatesSF.BackgroundTransparency=1; ugcStatesSF.BorderSizePixel=0; ugcStatesSF.ScrollBarThickness=3; ugcStatesSF.ScrollBarImageColor3=AC.PUR_MID; ugcStatesSF.AutomaticCanvasSize=Enum.AutomaticSize.Y; ugcStatesSF.CanvasSize=UDim2.new(0,0,0,0); ugcStatesSF.ZIndex=67
    local ugcStatesLL=Instance.new("UIListLayout",ugcStatesSF); ugcStatesLL.Padding=UDim.new(0,6)

    -- Speed row at bottom
    -- UGC Bottom bar: Speed slider 0-10 + keybind number row (matches AC REANIMATION style)
    local ugcBottomBar=Instance.new("Frame",ugcPanel)
    ugcBottomBar.Size=UDim2.new(1,-16,0,92); ugcBottomBar.Position=UDim2.new(0,8,1,-100)
    ugcBottomBar.BackgroundColor3=Color3.fromRGB(14,14,18); ugcBottomBar.BackgroundTransparency=0.3
    ugcBottomBar.ZIndex=66; Instance.new("UICorner",ugcBottomBar).CornerRadius=UDim.new(0,7)
    -- Speed label + value + Reset
    local ugcSpLbl=Instance.new("TextLabel",ugcBottomBar); ugcSpLbl.Size=UDim2.new(0,55,0,14); ugcSpLbl.Position=UDim2.new(0,8,0,4); ugcSpLbl.BackgroundTransparency=1; ugcSpLbl.Text="Speed:"; ugcSpLbl.TextColor3=AC.TXT_DIM; ugcSpLbl.TextSize=10; ugcSpLbl.Font=Enum.Font.GothamBold; ugcSpLbl.TextXAlignment=Enum.TextXAlignment.Left; ugcSpLbl.ZIndex=67
    local ugcSpVal=Instance.new("TextLabel",ugcBottomBar); ugcSpVal.Size=UDim2.new(0,30,0,14); ugcSpVal.Position=UDim2.new(1,-72,0,4); ugcSpVal.BackgroundTransparency=1; ugcSpVal.Text="5"; ugcSpVal.TextColor3=AC.TXT_WHITE; ugcSpVal.TextSize=10; ugcSpVal.Font=Enum.Font.GothamBold; ugcSpVal.TextXAlignment=Enum.TextXAlignment.Right; ugcSpVal.ZIndex=67
    local ugcSpRst=Instance.new("TextButton",ugcBottomBar); ugcSpRst.Size=UDim2.new(0,40,0,14); ugcSpRst.Position=UDim2.new(1,-40,0,4); ugcSpRst.BackgroundTransparency=1; ugcSpRst.Text="Reset"; ugcSpRst.TextColor3=AC.TXT_DIM; ugcSpRst.TextSize=9; ugcSpRst.Font=Enum.Font.Gotham; ugcSpRst.ZIndex=67
    -- Speed slider track (0-10)
    local ugcSpTrk=Instance.new("Frame",ugcBottomBar); ugcSpTrk.Size=UDim2.new(1,-16,0,6); ugcSpTrk.Position=UDim2.new(0,8,0,22); ugcSpTrk.BackgroundColor3=Color3.fromRGB(30,30,35); ugcSpTrk.ZIndex=67; Instance.new("UICorner",ugcSpTrk).CornerRadius=UDim.new(1,0)
    local ugcSpFl=Instance.new("Frame",ugcSpTrk); ugcSpFl.Size=UDim2.new(0.5,0,1,0); ugcSpFl.BackgroundColor3=AC.PUR_MID; ugcSpFl.ZIndex=68; Instance.new("UICorner",ugcSpFl).CornerRadius=UDim.new(1,0)
    local ugcSpKn=Instance.new("TextButton",ugcSpTrk); ugcSpKn.Size=UDim2.new(0,14,0,14); ugcSpKn.Position=UDim2.new(0.5,-7,0.5,-7); ugcSpKn.BackgroundColor3=AC.PUR_GLOW; ugcSpKn.Text=""; ugcSpKn.ZIndex=69; Instance.new("UICorner",ugcSpKn).CornerRadius=UDim.new(1,0)
    -- Number row (1/3/5/7/9 + Bind slots)
    local ugcNumRowF=Instance.new("Frame",ugcBottomBar); ugcNumRowF.Size=UDim2.new(1,-16,0,52); ugcNumRowF.Position=UDim2.new(0,8,0,34); ugcNumRowF.BackgroundTransparency=1; ugcNumRowF.ZIndex=67
    local UGC_NUM_VALS={1,3,5,7,9}
    local ugcNumBinds={}
    local ugcNBW=math.floor((UGC_W-16-8*4)/5)

    local ugcSpdCur=5.0; local ugcSpdDrag=false; local ugcActiveTrack=nil
    local function setUgcSpd(v)
        v=math.clamp(math.floor(v*10+0.5)/10,0,10); ugcSpdCur=v
        local r=v/10; ugcSpVal.Text=tostring(v); ugcSpFl.Size=UDim2.new(r,0,1,0); ugcSpKn.Position=UDim2.new(r,-7,0.5,-7)
        if ugcActiveTrack then pcall(function() ugcActiveTrack:AdjustSpeed(v) end) end
    end
    ugcSpKn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then ugcSpdDrag=true end end)
    ugcSpTrk.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then ugcSpdDrag=true; setUgcSpd((AC.UIS:GetMouseLocation().X-ugcSpTrk.AbsolutePosition.X)/ugcSpTrk.AbsoluteSize.X*10) end end)
    AC.UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then ugcSpdDrag=false end end)
    AC.RS.RenderStepped:Connect(function() if ugcSpdDrag then setUgcSpd((AC.UIS:GetMouseLocation().X-ugcSpTrk.AbsolutePosition.X)/ugcSpTrk.AbsoluteSize.X*10) end end)
    ugcSpRst.MouseButton1Click:Connect(function() setUgcSpd(5) end); setUgcSpd(5)

    for i,nv in ipairs(UGC_NUM_VALS) do
        local xOff=(i-1)*(ugcNBW+8)
        local nb=Instance.new("TextButton",ugcNumRowF); nb.Size=UDim2.new(0,ugcNBW,0,22); nb.Position=UDim2.new(0,xOff,0,0); nb.BackgroundColor3=Color3.fromRGB(20,20,24); nb.BackgroundTransparency=0.2; nb.Text=tostring(nv); nb.TextColor3=AC.PUR_GLOW; nb.TextSize=13; nb.Font=Enum.Font.GothamBold; nb.ZIndex=68; Instance.new("UICorner",nb).CornerRadius=UDim.new(0,5); Instance.new("UIStroke",nb).Color=AC.PUR_STROKE
        local kb=Instance.new("TextButton",ugcNumRowF); kb.Size=UDim2.new(0,ugcNBW,0,22); kb.Position=UDim2.new(0,xOff,0,26); kb.BackgroundColor3=Color3.fromRGB(20,20,24); kb.BackgroundTransparency=0.2; kb.Text="Bind"; kb.TextColor3=AC.TXT_DIM; kb.TextSize=10; kb.Font=Enum.Font.Gotham; kb.ZIndex=68; Instance.new("UICorner",kb).CornerRadius=UDim.new(0,5); Instance.new("UIStroke",kb).Color=AC.PUR_STROKE
        ugcNumBinds[i]={savedKey=nil,val=nv,kb=kb}
        local nvC=nv; local kbC=kb; local idxC=i
        nb.MouseButton1Click:Connect(function() setUgcSpd(nvC) end)
        local kL=false; local kC=nil
        kb.MouseButton1Click:Connect(function()
            if kL then kL=false; if kC then kC:Disconnect(); kC=nil end; kb.Text=ugcNumBinds[idxC].savedKey and ugcNumBinds[idxC].savedKey:sub(1,4) or "Bind"; kb.TextColor3=ugcNumBinds[idxC].savedKey and AC.TXT_WHITE or AC.TXT_DIM; return end
            kL=true; kb.Text="..."; kb.TextColor3=AC.PUR_GLOW
            kC=AC.UIS.InputBegan:Connect(function(inp,gp)
                if gp or inp.UserInputType~=Enum.UserInputType.Keyboard then return end
                local ok2,kn=pcall(function() return inp.KeyCode.Name end); if not ok2 or not kn or kn=="Unknown" then return end
                local cancelK2={Escape=true,Delete=true,Backspace=true}
                if cancelK2[kn] then
                    kL=false; if kC then kC:Disconnect(); kC=nil end
                    if kn=="Delete" or kn=="Backspace" then
                        ugcNumBinds[idxC].savedKey=nil; kb.Text="Bind"; kb.TextColor3=AC.TXT_DIM
                        AC.toast("UGC bind cleared",AC.ORANGE_W)
                    else
                        kb.Text=ugcNumBinds[idxC].savedKey and ugcNumBinds[idxC].savedKey:sub(1,4) or "Bind"
                        kb.TextColor3=ugcNumBinds[idxC].savedKey and AC.TXT_WHITE or AC.TXT_DIM
                    end
                    return
                end
                ugcNumBinds[idxC].savedKey=kn; kb.Text=kn:sub(1,4); kb.TextColor3=AC.TXT_WHITE
                kL=false; if kC then kC:Disconnect(); kC=nil end; AC.toast("UGC Speed "..nvC.." → "..kn,AC.PUR_BRIGHT)
            end)
        end)
    end
    AC.UIS.InputBegan:Connect(function(inp,gp)
        if gp or inp.UserInputType~=Enum.UserInputType.Keyboard then return end
        local ok2,kn=pcall(function() return inp.KeyCode.Name end); if not ok2 or not kn then return end
        for _,slot in ipairs(ugcNumBinds) do if slot.savedKey==kn then setUgcSpd(slot.val) end end
    end)

    local ugcFavs={}; local ugcBinds={}
    do
        local fl=readData("BLEED/ugc_favs.json",{}); for _,id in ipairs(fl) do ugcFavs[tostring(id)]=true end
        local bl=readData("BLEED/ugc_binds.json",{}); for k,v in pairs(bl) do ugcBinds[k]=v end
    end
    local function saveUgcFavs() local l={}; for k in pairs(ugcFavs) do l[#l+1]=k end; writeData("BLEED/ugc_favs.json",l) end
    local function saveUgcBinds() writeData("BLEED/ugc_binds.json",ugcBinds) end

    local ugcAllRows={}; local ugcFavOnly=false; local ugcHighRow=nil

    local function stopUgcTrack() if ugcActiveTrack then pcall(function() ugcActiveTrack:Stop() end); ugcActiveTrack=nil end end

    local function playUgcEmote(id)
        stopUgcTrack()
        local char=AC.player.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        local ok,track=pcall(function() return hum:PlayEmoteAndGetAnimTrackById(id) end)
        if ok and track and typeof(track)=="Instance" and track:IsA("AnimationTrack") then ugcActiveTrack=track; track.Looped=true; pcall(function() track:AdjustSpeed(ugcSpdCur) end); return end
        local animator=hum:FindFirstChildOfClass("Animator"); if not animator then return end
        local anim=Instance.new("Animation"); anim.AnimationId="rbxassetid://"..tostring(id)
        local ok2,t2=pcall(function() return animator:LoadAnimation(anim) end)
        if ok2 and t2 then t2.Priority=Enum.AnimationPriority.Action; t2.Looped=true; t2:Play(); pcall(function() t2:AdjustSpeed(ugcSpdCur) end); ugcActiveTrack=t2 end
    end


    local function buildUgcRow(item,idx)
        local row=Instance.new("TextButton",ugcScroll); row.Size=UDim2.new(1,0,0,34); row.BackgroundColor3=Color3.fromRGB(14,14,18); row.BackgroundTransparency=0.1; row.Text=""; row.LayoutOrder=idx; row.ZIndex=68; Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
        local rS=Instance.new("UIStroke",row); rS.Color=AC.PUR_STROKE; rS.Thickness=1; rS.Transparency=0.7
        local idxStr=tostring(item.id)
        local star=Instance.new("TextButton",row); star.Size=UDim2.new(0,22,0,22); star.Position=UDim2.new(0,6,0.5,-11); star.BackgroundTransparency=1; star.Text=ugcFavs[idxStr] and "★" or "☆"; star.TextColor3=ugcFavs[idxStr] and Color3.fromRGB(255,210,60) or AC.TXT_DIM; star.TextSize=14; star.Font=Enum.Font.Gotham; star.ZIndex=69
        local nLbl=Instance.new("TextLabel",row); nLbl.Size=UDim2.new(1,-70,1,0); nLbl.Position=UDim2.new(0,32,0,0); nLbl.BackgroundTransparency=1; nLbl.Text=item.name; nLbl.TextColor3=AC.TXT_MAIN; nLbl.TextSize=12; nLbl.Font=Enum.Font.Gotham; nLbl.TextXAlignment=Enum.TextXAlignment.Left; nLbl.TextTruncate=Enum.TextTruncate.AtEnd; nLbl.ZIndex=69
        local bLbl=Instance.new("TextButton",row); bLbl.Size=UDim2.new(0,28,0,14); bLbl.Position=UDim2.new(1,-34,0.5,-7); bLbl.BackgroundColor3=Color3.fromRGB(26,26,32); bLbl.Text=ugcBinds[idxStr] and ugcBinds[idxStr]:sub(1,3) or "Bind"; bLbl.TextColor3=ugcBinds[idxStr] and AC.TXT_WHITE or AC.TXT_DIM; bLbl.TextSize=8; bLbl.Font=Enum.Font.Gotham; bLbl.ZIndex=69; bLbl.BackgroundTransparency=0.3; Instance.new("UICorner",bLbl).CornerRadius=UDim.new(0,4)
        star.MouseButton1Click:Connect(function()
            if ugcFavs[idxStr] then ugcFavs[idxStr]=nil; star.Text="☆"; star.TextColor3=AC.TXT_DIM
            else ugcFavs[idxStr]=true; star.Text="★"; AC.TS:Create(star,TweenInfo.new(0.15),{TextColor3=Color3.fromRGB(255,210,60)}):Play() end
            saveUgcFavs(); if ugcFavOnly then row.Visible=ugcFavs[idxStr]~=nil end
        end)
        local bL=false; local bC=nil
        bLbl.MouseButton1Click:Connect(function()
            if bL then bL=false; if bC then bC:Disconnect(); bC=nil end; bLbl.Text=ugcBinds[idxStr] and ugcBinds[idxStr]:sub(1,3) or "Bind"; return end
            bL=true; bLbl.Text="..."; bLbl.TextColor3=AC.PUR_GLOW
            bC=AC.UIS.InputBegan:Connect(function(inp,gp)
                if gp or inp.UserInputType~=Enum.UserInputType.Keyboard then return end
                local ok2,kn=pcall(function() return inp.KeyCode.Name end); if not ok2 or not kn or kn=="Unknown" then return end
                ugcBinds[idxStr]=kn; saveUgcBinds(); bLbl.Text=kn:sub(1,3); bLbl.TextColor3=AC.TXT_WHITE
                bL=false; if bC then bC:Disconnect(); bC=nil end
            end)
        end)
        local highlighted=false
        row.MouseButton1Click:Connect(function()
            if highlighted then
                stopUgcTrack(); highlighted=false; AC.TS:Create(row,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(14,14,18)}):Play(); rS.Color=AC.PUR_STROKE; ugcHighRow=nil
                AC.toast("Stopped: "..item.name,AC.ORANGE_W); return
            end
            if ugcHighRow then pcall(function() AC.TS:Create(ugcHighRow,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(14,14,18)}):Play(); local ps=ugcHighRow:FindFirstChildOfClass("UIStroke"); if ps then ps.Color=AC.PUR_STROKE end end) end
            playUgcEmote(item.id); highlighted=true; ugcHighRow=row
            AC.TS:Create(row,TweenInfo.new(0.15),{BackgroundColor3=AC.PUR_DARK}):Play(); rS.Color=AC.PUR_BRIGHT
            AC.toast("♪ "..item.name,AC.PUR_BRIGHT)
        end)
        row.MouseEnter:Connect(function() if not highlighted then AC.TS:Create(row,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(22,22,28)}):Play() end end)
        row.MouseLeave:Connect(function() if not highlighted then AC.TS:Create(row,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(14,14,18)}):Play() end end)
        return {row=row,nameLower=item.name:lower(),id=item.id,index=idx}
    end

    -- States: Idle/Walk/Jump dropdowns
    local STATE_CATS={"Idle","Walk","Jump"}
    for _,cat in ipairs(STATE_CATS) do
        local sec=Instance.new("Frame",ugcStatesSF); sec.Size=UDim2.new(1,0,0,96); sec.BackgroundColor3=Color3.fromRGB(16,16,20); sec.BackgroundTransparency=0.3; sec.ZIndex=68; Instance.new("UICorner",sec).CornerRadius=UDim.new(0,8); Instance.new("UIStroke",sec).Color=AC.PUR_STROKE
        local cLbl=Instance.new("TextLabel",sec); cLbl.Size=UDim2.new(1,-80,0,22); cLbl.Position=UDim2.new(0,10,0,6); cLbl.BackgroundTransparency=1; cLbl.Text=cat; cLbl.TextColor3=AC.PUR_GLOW; cLbl.TextSize=13; cLbl.Font=Enum.Font.GothamBold; cLbl.TextXAlignment=Enum.TextXAlignment.Left; cLbl.ZIndex=69
        local ddBtn=Instance.new("TextButton",sec); ddBtn.Size=UDim2.new(1,-20,0,24); ddBtn.Position=UDim2.new(0,10,0,30); ddBtn.BackgroundColor3=Color3.fromRGB(22,22,28); ddBtn.BackgroundTransparency=0.2; ddBtn.Text="Select animation ▾"; ddBtn.TextColor3=AC.TXT_MAIN; ddBtn.TextSize=11; ddBtn.Font=Enum.Font.Gotham; ddBtn.ZIndex=69; Instance.new("UICorner",ddBtn).CornerRadius=UDim.new(0,6); Instance.new("UIStroke",ddBtn).Color=AC.PUR_STROKE
        local sLbl=Instance.new("TextLabel",sec); sLbl.Size=UDim2.new(0,50,0,14); sLbl.Position=UDim2.new(0,10,0,60); sLbl.BackgroundTransparency=1; sLbl.Text="Speed:"; sLbl.TextColor3=AC.TXT_DIM; sLbl.TextSize=9; sLbl.Font=Enum.Font.GothamBold; sLbl.ZIndex=69
        local sVLbl=Instance.new("TextLabel",sec); sVLbl.Size=UDim2.new(0,32,0,14); sVLbl.Position=UDim2.new(0,58,0,60); sVLbl.BackgroundTransparency=1; sVLbl.Text="1.0x"; sVLbl.TextColor3=AC.PUR_GLOW; sVLbl.TextSize=9; sVLbl.Font=Enum.Font.GothamBold; sVLbl.ZIndex=69
        local sTrk=Instance.new("Frame",sec); sTrk.Size=UDim2.new(1,-110,0,5); sTrk.Position=UDim2.new(0,10,0,78); sTrk.BackgroundColor3=Color3.fromRGB(30,30,35); sTrk.ZIndex=69; Instance.new("UICorner",sTrk).CornerRadius=UDim.new(1,0)
        local sFil=Instance.new("Frame",sTrk); sFil.Size=UDim2.new(0.18,0,1,0); sFil.BackgroundColor3=AC.PUR_MID; sFil.ZIndex=70; Instance.new("UICorner",sFil).CornerRadius=UDim.new(1,0)
        local sKnb=Instance.new("TextButton",sTrk); sKnb.Size=UDim2.new(0,12,0,12); sKnb.Position=UDim2.new(0.18,-6,0.5,-6); sKnb.BackgroundColor3=AC.PUR_GLOW; sKnb.Text=""; sKnb.ZIndex=71; Instance.new("UICorner",sKnb).CornerRadius=UDim.new(1,0)
        local sRst=Instance.new("TextButton",sec); sRst.Size=UDim2.new(0,36,0,14); sRst.Position=UDim2.new(1,-46,0,60); sRst.BackgroundColor3=Color3.fromRGB(26,26,32); sRst.Text="Reset"; sRst.TextColor3=AC.TXT_DIM; sRst.TextSize=9; sRst.Font=Enum.Font.Gotham; sRst.ZIndex=69; Instance.new("UICorner",sRst).CornerRadius=UDim.new(0,4)
        local stSpd=1.0; local stDrag=false
        local function setStSpd(v) v=math.clamp(math.floor(v*10+0.5)/10,0.1,5.0); stSpd=v; local r=(v-0.1)/4.9; sVLbl.Text=v.."x"; sFil.Size=UDim2.new(r,0,1,0); sKnb.Position=UDim2.new(r,-6,0.5,-6) end
        sKnb.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then stDrag=true end end)
        sTrk.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then stDrag=true; setStSpd(0.1+(AC.UIS:GetMouseLocation().X-sTrk.AbsolutePosition.X)/sTrk.AbsoluteSize.X*4.9) end end)
        AC.UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then stDrag=false end end)
        AC.RS.RenderStepped:Connect(function() if stDrag then setStSpd(0.1+(AC.UIS:GetMouseLocation().X-sTrk.AbsolutePosition.X)/sTrk.AbsoluteSize.X*4.9) end end)
        sRst.MouseButton1Click:Connect(function() setStSpd(1.0) end)
        setStSpd(1.0)

        -- Dropdown popup
        local ddPop=Instance.new("Frame",AC.screenGui); ddPop.Size=UDim2.new(0,220,0,0); ddPop.BackgroundColor3=Color3.fromRGB(16,16,20); ddPop.ClipsDescendants=true; ddPop.ZIndex=600; ddPop.Visible=false; Instance.new("UICorner",ddPop).CornerRadius=UDim.new(0,8); Instance.new("UIStroke",ddPop).Color=AC.PUR_STROKE
        local ddSF=Instance.new("ScrollingFrame",ddPop); ddSF.Size=UDim2.new(1,0,1,0); ddSF.BackgroundTransparency=1; ddSF.BorderSizePixel=0; ddSF.ScrollBarThickness=3; ddSF.ScrollBarImageColor3=AC.PUR_MID; ddSF.AutomaticCanvasSize=Enum.AutomaticSize.Y; ddSF.CanvasSize=UDim2.new(0,0,0,0); ddSF.ZIndex=601
        local ddLL=Instance.new("UIListLayout",ddSF); ddLL.Padding=UDim.new(0,2); Instance.new("UIPadding",ddSF).PaddingTop=UDim.new(0,4); Instance.new("UIPadding",ddSF).PaddingLeft=UDim.new(0,4); Instance.new("UIPadding",ddSF).PaddingRight=UDim.new(0,4)
        for ai,aData in ipairs(RN_ANIMS) do
            local aC=aData; local opt=Instance.new("TextButton",ddSF); opt.Size=UDim2.new(1,0,0,28); opt.BackgroundColor3=Color3.fromRGB(22,22,28); opt.Text=aData[1]; opt.TextColor3=AC.TXT_MAIN; opt.TextSize=11; opt.Font=Enum.Font.Gotham; opt.LayoutOrder=ai; opt.ZIndex=602; Instance.new("UICorner",opt).CornerRadius=UDim.new(0,6)
            opt.MouseButton1Click:Connect(function()
                ddBtn.Text=aC[1].." ▾"; ddPop.Visible=false
                if rnAPI then pcall(function() rnAPI.play_animation(aC[2],stSpd) end); AC.toast("♪ "..cat..": "..aC[1],AC.PUR_BRIGHT)
                else AC.toast("Enable Reanimation first!",AC.ORANGE_W) end
            end)
            opt.MouseEnter:Connect(function() AC.TS:Create(opt,TweenInfo.new(0.1),{BackgroundColor3=AC.PUR_DARK}):Play() end)
            opt.MouseLeave:Connect(function() AC.TS:Create(opt,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(22,22,28)}):Play() end)
        end
        ddBtn.MouseButton1Click:Connect(function()
            if ddPop.Visible then ddPop.Visible=false; return end
            local ap=ddBtn.AbsolutePosition; local as=ddBtn.AbsoluteSize
            ddPop.Position=UDim2.new(0,ap.X,0,ap.Y+as.Y+2); ddPop.Size=UDim2.new(0,as.X,0,0)
            AC.TS:Create(ddPop,TweenInfo.new(0.14,Enum.EasingStyle.Quint),{Size=UDim2.new(0,as.X,0,math.min(#RN_ANIMS*30,200))}):Play(); ddPop.Visible=true
        end)
    end

    -- Tab switching
    local function ugcSwitchTab(tabName)
        ugcActiveTab=tabName
        for tn,tb in pairs(ugcTabBtns) do
            local active=(tn==tabName)
            AC.TS:Create(tb,TweenInfo.new(0.15),{BackgroundColor3=active and AC.PUR_DARK or Color3.fromRGB(22,22,22),BackgroundTransparency=active and 0 or 0.5}):Play()
            tb.TextColor3=active and AC.TXT_WHITE or AC.TXT_DIM; tb.Font=active and Enum.Font.GothamBold or Enum.Font.Gotham
        end
        ugcListPage.Visible=(tabName~="States"); ugcStatesPage.Visible=(tabName=="States"); ugcSrch.Visible=(tabName~="States")
        if tabName~="States" then
            ugcFavOnly=(tabName=="Favs"); local q=ugcSrch.Text:lower()
            for _,r in ipairs(ugcAllRows) do local sf=(not ugcFavOnly) or ugcFavs[tostring(r.id)]; r.row.Visible=sf and (q=="" or r.nameLower:find(q,1,true)~=nil) end
        end
    end
    for tn,tb in pairs(ugcTabBtns) do local n=tn; tb.MouseButton1Click:Connect(function() ugcSwitchTab(n) end) end
    ugcSrch:GetPropertyChangedSignal("Text"):Connect(function()
        if ugcActiveTab=="States" then return end; ugcFavOnly=(ugcActiveTab=="Favs"); local q=ugcSrch.Text:lower()
        for _,r in ipairs(ugcAllRows) do local sf=(not ugcFavOnly) or ugcFavs[tostring(r.id)]; r.row.Visible=sf and (q=="" or r.nameLower:find(q,1,true)~=nil) end
    end)

    -- Keybind listener for UGC
    AC.UIS.InputBegan:Connect(function(inp,gp)
        if gp or inp.UserInputType~=Enum.UserInputType.Keyboard then return end
        local ok2,kn=pcall(function() return inp.KeyCode.Name end); if not ok2 or not kn then return end
        for idStr,bk in pairs(ugcBinds) do if bk==kn then local idNum=tonumber(idStr); if idNum then playUgcEmote(idNum) end end end
    end)

    -- Drag UGC panel
    local ugcDrag,ugcDS,ugcSP=false,nil,nil
    ugcHdr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then ugcDrag=true; ugcDS=i.Position; ugcSP=ugcPanel.Position; i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then ugcDrag=false end end) end end)
    AC.UIS.InputChanged:Connect(function(i) if ugcDrag and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-ugcDS; ugcPanel.Position=UDim2.new(ugcSP.X.Scale,ugcSP.X.Offset+d.X,ugcSP.Y.Scale,ugcSP.Y.Offset+d.Y) end end)

    -- Fetch UGC emotes
    local ugcLoaded=false
    local function loadUgcData()
        if ugcLoaded then return end; ugcLoaded=true; ugcStatusLbl.Text="Loading..."
        task.spawn(function()
            local ok,res=pcall(function() return game:HttpGet(_URLS.EMOTE_JSON) end)
            local emotes={}
            if ok and res and res~="" then
                local parsed=AC.Http:JSONDecode(res)
                for _,item in ipairs(parsed.data or {}) do
                    if tonumber(item.id) and tonumber(item.id)>0 then emotes[#emotes+1]={id=tonumber(item.id),name=item.name or ("Emote_"..item.id)} end
                end
            end
            ugcStatusLbl.Text="Ready"
            -- Build rows in small chunks to prevent frame drops
            local CHUNK=10
            for i=1,#emotes do
                ugcAllRows[i]=buildUgcRow(emotes[i],i)
                if i%CHUNK==0 then
                    -- Update canvas size after each chunk
                    ugcScroll.CanvasSize=UDim2.new(0,0,0,i*36+8)
                    task.wait()
                end
            end
            ugcScroll.CanvasSize=UDim2.new(0,0,0,#emotes*36+8)
            if #emotes==0 then ugcStatusLbl.Text="No emotes found" end
        end)
    end

    -- Emotes page buttons
    AC.sectionLbl(pg,"REANIMATION",10)
    local rnMainBtn=Instance.new("TextButton",pg); rnMainBtn.Size=UDim2.new(1,-24,0,40); rnMainBtn.Position=UDim2.new(0,12,0,28); rnMainBtn.BackgroundColor3=AC.BG_CARD; rnMainBtn.Text="Reanimation"; rnMainBtn.TextColor3=AC.PUR_GLOW; rnMainBtn.TextSize=14; rnMainBtn.Font=Enum.Font.GothamBold; Instance.new("UICorner",rnMainBtn).CornerRadius=UDim.new(0,8); local rnMS=Instance.new("UIStroke",rnMainBtn); rnMS.Color=AC.PUR_STROKE; rnMS.Thickness=1.5; rnMS.Transparency=0.3
    rnMainBtn.MouseEnter:Connect(function() AC.TS:Create(rnMainBtn,TweenInfo.new(0.15),{BackgroundColor3=AC.PUR_MID}):Play() end)
    rnMainBtn.MouseLeave:Connect(function() AC.TS:Create(rnMainBtn,TweenInfo.new(0.15),{BackgroundColor3=AC.BG_CARD}):Play() end)
    rnMainBtn.MouseButton1Click:Connect(function() pcall(function() AC.clickSnd:Play() end); rnPanel.Visible=not rnPanel.Visible end)

    AC.sectionLbl(pg,"UGC EMOTES",78)
    local ugcMainBtn=Instance.new("TextButton",pg); ugcMainBtn.Size=UDim2.new(1,-24,0,40); ugcMainBtn.Position=UDim2.new(0,12,0,96); ugcMainBtn.BackgroundColor3=AC.BG_CARD; ugcMainBtn.Text="Open Emote Menu"; ugcMainBtn.TextColor3=AC.PUR_GLOW; ugcMainBtn.TextSize=14; ugcMainBtn.Font=Enum.Font.GothamBold; Instance.new("UICorner",ugcMainBtn).CornerRadius=UDim.new(0,8); local ugcMS=Instance.new("UIStroke",ugcMainBtn); ugcMS.Color=AC.PUR_STROKE; ugcMS.Thickness=1.5; ugcMS.Transparency=0.3
    ugcMainBtn.MouseEnter:Connect(function() AC.TS:Create(ugcMainBtn,TweenInfo.new(0.15),{BackgroundColor3=AC.PUR_MID}):Play() end)
    ugcMainBtn.MouseLeave:Connect(function() AC.TS:Create(ugcMainBtn,TweenInfo.new(0.15),{BackgroundColor3=AC.BG_CARD}):Play() end)
    ugcMainBtn.MouseButton1Click:Connect(function() pcall(function() AC.clickSnd:Play() end); ugcPanel.Visible=not ugcPanel.Visible; if ugcPanel.Visible then loadUgcData() end end)

    btn.MouseButton1Click:Connect(function() AC.switchTab("Emotes") end)
end

-- ─────────────────────────────────────────────────────────
-- MISC TAB
-- ─────────────────────────────────────────────────────────
do
    local btn=AC.createTab("Misc",6); local pg=AC.createPage(); AC.tabs["Misc"].page=pg
    AC.sectionLbl(pg,"VISUAL",10)
    local espHL={}; local espConns={}
    local JOINT_PAIRS={{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}
    local ESP_RED=Color3.fromRGB(220,30,30)
    local function removeESP(uid) local d=espHL[uid]; if not d then return end; pcall(function() if d.nbb then d.nbb:Destroy() end; for _,bd in ipairs(d.beams or {}) do bd.beam:Destroy(); bd.att0:Destroy(); bd.att1:Destroy() end end); espHL[uid]=nil end
    local function addESP(p)
        if not p.Character then return end; removeESP(p.UserId)
        local char=p.Character; local beams={}; espHL[p.UserId]={beams=beams}
        for _,pair in ipairs(JOINT_PAIRS) do
            local pA=char:FindFirstChild(pair[1]); local pB=char:FindFirstChild(pair[2])
            if pA and pA:IsA("BasePart") and pB and pB:IsA("BasePart") then
                local a0=Instance.new("Attachment",pA); local a1=Instance.new("Attachment",pB)
                local beam=Instance.new("Beam"); beam.Attachment0=a0; beam.Attachment1=a1; beam.Color=ColorSequence.new(ESP_RED); beam.Width0=0.06; beam.Width1=0.06; beam.FaceCamera=true; beam.Segments=1; beam.Transparency=NumberSequence.new(0); beam.LightEmission=0.5; beam.Parent=char
                table.insert(beams,{beam=beam,att0=a0,att1=a1})
            end
        end
        local head=char:FindFirstChild("Head"); if head then
            local nbb=Instance.new("BillboardGui"); nbb.Size=UDim2.new(0,120,0,22); nbb.StudsOffset=Vector3.new(0,2.5,0); nbb.AlwaysOnTop=true; nbb.Adornee=head; nbb.Parent=char
            local nl=Instance.new("TextLabel",nbb); nl.Size=UDim2.new(1,0,1,0); nl.BackgroundTransparency=1; nl.Text=p.Name; nl.TextColor3=ESP_RED; nl.TextSize=12; nl.Font=Enum.Font.GothamBold; nl.TextStrokeTransparency=0.3
            espHL[p.UserId].nbb=nbb
        end
    end
    local espOn=false
    local _,_,onESP=AC.makeToggle(pg,"Player ESP (skeleton)",28,false)
    onESP(function(v) espOn=v
        if v then for _,p in ipairs(AC.Players:GetPlayers()) do if p~=AC.player then addESP(p) end end; AC.Players.PlayerAdded:Connect(function(np) if espOn then np.CharacterAdded:Connect(function() task.wait(1); if espOn then addESP(np) end end) end end); AC.toast("ESP ON")
        else for uid in pairs(espHL) do removeESP(uid) end; espHL={}; AC.toast("ESP OFF",AC.ORANGE_W) end
    end)

    AC.sectionLbl(pg,"MOVEMENT",80)
    local ctConn=nil
    local _,_,onCTP=AC.makeToggle(pg,"Click Teleport",98,false)
    onCTP(function(v) if v then ctConn=AC.UIS.InputBegan:Connect(function(inp,gp) if gp then return end; if inp.UserInputType==Enum.UserInputType.MouseButton1 then local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={AC.player.Character}; local ur=AC.camera:ScreenPointToRay(inp.Position.X,inp.Position.Y); local res=AC.WS:Raycast(ur.Origin,ur.Direction*1000,params); if res then local mr=AC.player.Character and AC.player.Character:FindFirstChild("HumanoidRootPart"); if mr then mr.CFrame=CFrame.new(res.Position+Vector3.new(0,3,0)) end end end end) else if ctConn then ctConn:Disconnect(); ctConn=nil end end end)
    local _,_,onAV=AC.makeToggle(pg,"Anti-Void",144,false)
    onAV(function(v) if v then AC.antiVoidConn=AC.RS.Heartbeat:Connect(function() local mr=AC.player.Character and AC.player.Character:FindFirstChild("HumanoidRootPart"); if mr and mr.Position.Y<-200 then local sp=AC.WS:FindFirstChildOfClass("SpawnLocation"); mr.CFrame=sp and sp.CFrame+Vector3.new(0,5,0) or CFrame.new(0,10,0) end end) else if AC.antiVoidConn then AC.antiVoidConn:Disconnect(); AC.antiVoidConn=nil end end end)
    local _,_,onBP=AC.makeToggle(pg,"Infinite Baseplate",190,false)
    onBP(function(v) if v then task.spawn(function() pcall(function() safeRun("BASEPLATE") end) end); AC.toast("Baseplate loading...",AC.ORANGE_W) else if AC.baseplateRef then pcall(function() AC.baseplateRef:Destroy() end); AC.baseplateRef=nil end end end)

    AC.sectionLbl(pg,"TOOLS",244)
    AC.makeBtn(pg,"Reset Character",262,40).MouseButton1Click:Connect(function() local h=AC.player.Character and AC.player.Character:FindFirstChildOfClass("Humanoid"); if h then h.Health=0 end end)
    AC.makeBtn(pg,"Respawn in Place (.re)",308,40).MouseButton1Click:Connect(function()
        local mr=AC.player.Character and AC.player.Character:FindFirstChild("HumanoidRootPart"); local sv=mr and mr.CFrame; if not sv then return end
        local conn; conn=AC.player.CharacterAdded:Connect(function(nc) conn:Disconnect(); task.wait(0.5); local mr2=nc:WaitForChild("HumanoidRootPart",5); if mr2 then mr2.CFrame=sv; AC.toast("Respawned!",AC.GREEN_OK) end end)
        local h=AC.player.Character:FindFirstChildOfClass("Humanoid"); if h then h.Health=0 end
    end)

    local vcOuter=Instance.new("Frame",pg); vcOuter.Size=UDim2.new(1,-24,0,62); vcOuter.Position=UDim2.new(0,12,0,358); vcOuter.BackgroundTransparency=1
    local vcBtn=Instance.new("TextButton",vcOuter); vcBtn.Size=UDim2.new(1,0,0,40); vcBtn.BackgroundColor3=Color3.fromRGB(10,35,10); vcBtn.Text="Anti-VC Ban Protection"; vcBtn.TextColor3=Color3.fromRGB(80,255,80); vcBtn.TextSize=13; vcBtn.Font=Enum.Font.GothamBold; Instance.new("UICorner",vcBtn).CornerRadius=UDim.new(0,8)
    local vcS=Instance.new("UIStroke",vcBtn); vcS.Color=Color3.fromRGB(0,200,0); vcS.Thickness=1.5
    AC.TS:Create(vcS,TweenInfo.new(1.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Color=Color3.fromRGB(0,80,0),Transparency=0.4}):Play()
    local vcW=Instance.new("TextLabel",vcOuter); vcW.Size=UDim2.new(1,0,0,18); vcW.Position=UDim2.new(0,0,0,43); vcW.BackgroundTransparency=1; vcW.Text="⚠  NOT COMPATIBLE WITH XENO AND SOLARA"; vcW.TextColor3=Color3.fromRGB(255,60,60); vcW.TextSize=10; vcW.Font=Enum.Font.GothamBold; vcW.TextXAlignment=Enum.TextXAlignment.Center
    vcBtn.MouseButton1Click:Connect(function() AC.toast("Loading VC Bypass...",AC.ORANGE_W); task.spawn(function() local ok,err=pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/0riginalWarrior/Stalkie/refs/heads/main/vcbypass.lua"))() end); if ok then AC.toast("VC Bypass loaded!",AC.GREEN_OK) else AC.toast("VC Bypass failed",AC.RED_ERR) end end) end)

    AC.sectionLbl(pg,"SYSTEM",420)
    AC.cmdListBtn=AC.makeBtn(pg,"Command List",438,40)
    AC.sectionLbl(pg,"CREDITS",490)
    local crd=AC.makeCard(pg,508,66,AC.BG_CARD)
    local cr1=Instance.new("TextLabel",crd); cr1.Size=UDim2.new(1,-16,0,20); cr1.Position=UDim2.new(0,12,0,6); cr1.BackgroundTransparency=1; cr1.Text="AC AudioCrafter V3.1 — by MelodyCrafter"; cr1.TextColor3=AC.PUR_BRIGHT; cr1.TextSize=13; cr1.Font=Enum.Font.GothamBold; cr1.TextXAlignment=Enum.TextXAlignment.Left
    local cr2=Instance.new("TextLabel",crd); cr2.Size=UDim2.new(1,-16,0,14); cr2.Position=UDim2.new(0,12,0,28); cr2.BackgroundTransparency=1; cr2.Text="Inspired by IY, SystemBroken, Empty Tools, Onyx V2, AKADMIN, Bleed"; cr2.TextColor3=AC.TXT_DIM; cr2.TextSize=10; cr2.Font=Enum.Font.Gotham; cr2.TextXAlignment=Enum.TextXAlignment.Left
    btn.MouseButton1Click:Connect(function() AC.switchTab("Misc") end)
end

-- ─────────────────────────────────────────────────────────
-- EXTERNAL + COMMAND LIST
-- ─────────────────────────────────────────────────────────
do
    local extSep=Instance.new("Frame",AC.sideScroll); extSep.Size=UDim2.new(1,-16,0,1); extSep.BackgroundColor3=AC.PUR_STROKE; extSep.BackgroundTransparency=0.4; extSep.LayoutOrder=90
    local extLbl=Instance.new("TextLabel",AC.sideScroll); extLbl.Size=UDim2.new(1,-16,0,16); extLbl.BackgroundTransparency=1; extLbl.Text="EXTERNAL"; extLbl.TextColor3=AC.ORANGE_W; extLbl.TextSize=9; extLbl.Font=Enum.Font.GothamBold; extLbl.TextXAlignment=Enum.TextXAlignment.Left; extLbl.LayoutOrder=91
    local iyBtn=AC.createTab("Infinite Yield",92,true)
    iyBtn.MouseButton1Click:Connect(function() AC.toast("Loading IY...",AC.ORANGE_W); task.spawn(function() pcall(function() safeRun("INF_YIELD") end) end) end)

    local CMDS={{".view","Spectate target"},{".tp [name]","TP to player"},{".bring","Bring target"},{".focus","Focus loop TP"},{".headsit","Sit on head"},{".backpack","Backpack mode"},{".cleartarget","Clear target"},{".esp","Toggle ESP"},{".fly","Toggle Fly"},{".noclip","Toggle Noclip"},{".fullbright","Toggle Fullbright"},{".shaders","Toggle Shaders"},{".baseplate","Toggle Baseplate"},{".antivoid","Toggle Anti-Void"},{".antiafk","Toggle Anti-AFK"},{".re","Respawn in place"},{".reset","Reset character"},{".minimize","Toggle GUI"},{".cmds","Command List"},{".hide [n]","Hide player"},{".unhide [n]","Unhide player"},{".rj","Rejoin server"}}
    local cp=Instance.new("Frame",AC.screenGui); cp.Size=UDim2.new(0,340,0,480); cp.Position=UDim2.new(0.5,-170,0.5,-240); cp.BackgroundColor3=Color3.fromRGB(10,10,10); cp.ZIndex=50; cp.Visible=false; cp.ClipsDescendants=true; Instance.new("UICorner",cp).CornerRadius=UDim.new(0,12); Instance.new("UIStroke",cp).Color=AC.PUR_STROKE
    local cph=Instance.new("Frame",cp); cph.Size=UDim2.new(1,0,0,40); cph.BackgroundColor3=Color3.fromRGB(6,6,6); cph.ZIndex=51; Instance.new("UICorner",cph).CornerRadius=UDim.new(0,12)
    local cpt=Instance.new("TextLabel",cph); cpt.Size=UDim2.new(1,-50,1,0); cpt.Position=UDim2.new(0,14,0,0); cpt.BackgroundTransparency=1; cpt.Text="⌨  Command List"; cpt.TextColor3=AC.TXT_WHITE; cpt.TextSize=14; cpt.Font=Enum.Font.GothamBold; cpt.TextXAlignment=Enum.TextXAlignment.Left; cpt.ZIndex=52
    local cpX=Instance.new("TextButton",cph); cpX.Size=UDim2.new(0,26,0,26); cpX.Position=UDim2.new(1,-32,0.5,-13); cpX.BackgroundColor3=AC.PUR_MID; cpX.Text="✕"; cpX.TextColor3=AC.TXT_WHITE; cpX.TextSize=12; cpX.Font=Enum.Font.GothamBold; cpX.ZIndex=52; Instance.new("UICorner",cpX).CornerRadius=UDim.new(1,0); cpX.MouseButton1Click:Connect(function() cp.Visible=false end)
    local cps=Instance.new("ScrollingFrame",cp); cps.Size=UDim2.new(1,-8,1,-48); cps.Position=UDim2.new(0,4,0,44); cps.BackgroundTransparency=1; cps.BorderSizePixel=0; cps.ScrollBarThickness=3; cps.ScrollBarImageColor3=AC.PUR_MID; cps.AutomaticCanvasSize=Enum.AutomaticSize.Y; cps.CanvasSize=UDim2.new(0,0,0,0); cps.ZIndex=51
    local cpl=Instance.new("UIListLayout",cps); cpl.Padding=UDim.new(0,2)
    local cpp=Instance.new("UIPadding",cps); cpp.PaddingTop=UDim.new(0,4); cpp.PaddingLeft=UDim.new(0,4); cpp.PaddingRight=UDim.new(0,4)
    for i,cd in ipairs(CMDS) do
        local row=Instance.new("TextButton",cps); row.Size=UDim2.new(1,0,0,42); row.BackgroundColor3=Color3.fromRGB(16,16,16); row.Text=""; row.LayoutOrder=i; row.ZIndex=52; Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
        local cl=Instance.new("TextLabel",row); cl.Size=UDim2.new(1,-16,0,18); cl.Position=UDim2.new(0,12,0,4); cl.BackgroundTransparency=1; cl.Text=cd[1]; cl.TextColor3=AC.PUR_BRIGHT; cl.TextSize=13; cl.Font=Enum.Font.GothamBold; cl.TextXAlignment=Enum.TextXAlignment.Left; cl.ZIndex=53
        local dl=Instance.new("TextLabel",row); dl.Size=UDim2.new(1,-16,0,14); dl.Position=UDim2.new(0,12,0,22); dl.BackgroundTransparency=1; dl.Text=cd[2]; dl.TextColor3=AC.TXT_DIM; dl.TextSize=11; dl.Font=Enum.Font.Gotham; dl.TextXAlignment=Enum.TextXAlignment.Left; dl.ZIndex=53
        row.MouseEnter:Connect(function() AC.TS:Create(row,TweenInfo.new(0.12),{BackgroundColor3=AC.PUR_DARK}):Play() end)
        row.MouseLeave:Connect(function() AC.TS:Create(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(16,16,16)}):Play() end)
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
        elseif cmd==".bring" then if AC.selectedTarget and AC.selectedTarget.Character then local r=AC.selectedTarget.Character:FindFirstChild("HumanoidRootPart"); local m=AC.player.Character and AC.player.Character:FindFirstChild("HumanoidRootPart"); if r and m then r.CFrame=m.CFrame*CFrame.new(0,0,-3) end end
        elseif cmd==".cleartarget" then AC.stopViewing(); AC.focusActive=false; AC.onHead=false; AC.inBp=false; AC.selectedTarget=nil; if AC.sBox then AC.sBox.Text="" end
        elseif cmd==".fly" then if AC.flyActive then AC.flyActive=false; if AC.flyConn then AC.flyConn:Disconnect(); AC.flyConn=nil end; if AC.flyBV then AC.flyBV:Destroy(); AC.flyBV=nil end; if AC.flyBG then AC.flyBG:Destroy(); AC.flyBG=nil end; if AC._flyAtt then AC._flyAtt:Destroy(); AC._flyAtt=nil end; local h=AC.player.Character and AC.player.Character:FindFirstChildOfClass("Humanoid"); if h then h.PlatformStand=false end else AC.flyActive=true end
        elseif cmd==".noclip" then if AC.noclipConn then AC.noclipConn:Disconnect(); AC.noclipConn=nil; if AC.player.Character then for _,p in ipairs(AC.player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end else AC.noclipConn=AC.RS.Stepped:Connect(function() if AC.player.Character then for _,p in ipairs(AC.player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end) end
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

-- ─────────────────────────────────────────────────────────
-- QUICK BAR
-- ─────────────────────────────────────────────────────────
do
    local qBar=Instance.new("Frame",AC.screenGui); qBar.Size=UDim2.new(0,186,0,44); qBar.Position=UDim2.new(1,-200,1,-110); qBar.BackgroundColor3=Color3.fromRGB(8,8,8); qBar.BackgroundTransparency=0.15; qBar.ZIndex=400; qBar.ClipsDescendants=false; Instance.new("UICorner",qBar).CornerRadius=UDim.new(1,0); Instance.new("UIStroke",qBar).Color=AC.PUR_STROKE
    local qDrag,qDS,qSP=false,nil,nil
    qBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then qDrag=true; qDS=i.Position; qSP=qBar.Position; i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then qDrag=false end end) end end)
    AC.UIS.InputChanged:Connect(function(i) if qDrag and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-qDS; qBar.Position=UDim2.new(qSP.X.Scale,qSP.X.Offset+d.X,qSP.Y.Scale,qSP.Y.Offset+d.Y) end end)
    local qL=Instance.new("TextLabel",qBar); qL.Size=UDim2.new(0,28,1,0); qL.Position=UDim2.new(0,8,0,0); qL.BackgroundTransparency=1; qL.Text="AC"; qL.TextColor3=AC.PUR_GLOW; qL.TextSize=11; qL.Font=Enum.Font.GothamBold; qL.ZIndex=401
    local function makeChip(label,xOff,onColor,onToggle)
        local chip=Instance.new("TextButton",qBar); chip.Size=UDim2.new(0,44,0,30); chip.Position=UDim2.new(0,xOff,0.5,-15); chip.BackgroundColor3=Color3.fromRGB(22,22,22); chip.Text=label; chip.TextColor3=AC.TXT_DIM; chip.TextSize=10; chip.Font=Enum.Font.GothamBold; chip.ZIndex=401; Instance.new("UICorner",chip).CornerRadius=UDim.new(1,0); local cs=Instance.new("UIStroke",chip); cs.Color=AC.PUR_STROKE; cs.Thickness=1; cs.Transparency=0.5
        local active=false
        chip.MouseButton1Click:Connect(function()
            active=not active
            if active then AC.TS:Create(chip,TweenInfo.new(0.15),{BackgroundColor3=onColor,TextColor3=AC.TXT_WHITE}):Play(); cs.Transparency=1
            else AC.TS:Create(chip,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(22,22,22),TextColor3=AC.TXT_DIM}):Play(); cs.Transparency=0.5 end
            pcall(function() AC.clickSnd:Play() end); onToggle(active)
        end)
    end
    makeChip("SPD",42,Color3.fromRGB(30,160,60),function(v) local h=AC.player.Character and AC.player.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed=v and 50 or 16 end end)
    makeChip("FLY",92,Color3.fromRGB(20,100,220),function(v)
        AC.flyActive=v; local char=AC.player.Character; if not char then return end; local root=char:FindFirstChild("HumanoidRootPart"); if not root then return end; local hum=char:FindFirstChildOfClass("Humanoid")
        if v then if hum then hum.PlatformStand=true end; local att=Instance.new("Attachment",root); AC._flyAtt=att; AC.flyBV=Instance.new("LinearVelocity"); AC.flyBV.Attachment0=att; AC.flyBV.VelocityConstraintMode=Enum.VelocityConstraintMode.Vector; AC.flyBV.MaxForce=1e5; AC.flyBV.RelativeTo=Enum.ActuatorRelativeTo.World; AC.flyBV.VectorVelocity=Vector3.zero; AC.flyBV.Parent=root; AC.flyBG=Instance.new("AlignOrientation"); AC.flyBG.Attachment0=att; AC.flyBG.Mode=Enum.OrientationAlignmentMode.OneAttachment; AC.flyBG.MaxTorque=1e5; AC.flyBG.MaxAngularVelocity=math.huge; AC.flyBG.Responsiveness=50; AC.flyBG.Parent=root; AC.flyConn=AC.RS.RenderStepped:Connect(function() if not AC.flyActive then return end; local cf=AC.camera.CFrame; local dir=Vector3.zero; if AC.UIS:IsKeyDown(Enum.KeyCode.W) then dir=dir+cf.LookVector end; if AC.UIS:IsKeyDown(Enum.KeyCode.S) then dir=dir-cf.LookVector end; if AC.UIS:IsKeyDown(Enum.KeyCode.A) then dir=dir-cf.RightVector end; if AC.UIS:IsKeyDown(Enum.KeyCode.D) then dir=dir+cf.RightVector end; if AC.UIS:IsKeyDown(Enum.KeyCode.E) then dir=dir+Vector3.new(0,1,0) end; if AC.UIS:IsKeyDown(Enum.KeyCode.Q) then dir=dir-Vector3.new(0,1,0) end; if dir.Magnitude>0 then dir=dir.Unit end; AC.flyBV.VectorVelocity=dir*60; AC.flyBG.CFrame=cf end)
        else if AC.flyConn then AC.flyConn:Disconnect(); AC.flyConn=nil end; if AC.flyBV then AC.flyBV:Destroy(); AC.flyBV=nil end; if AC.flyBG then AC.flyBG:Destroy(); AC.flyBG=nil end; if AC._flyAtt then AC._flyAtt:Destroy(); AC._flyAtt=nil end; if hum then hum.PlatformStand=false end end
    end)
    makeChip("NC",140,Color3.fromRGB(200,100,10),function(v)
        if v then AC.noclipConn=AC.RS.Stepped:Connect(function() if AC.player.Character then for _,p in ipairs(AC.player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end)
        else if AC.noclipConn then AC.noclipConn:Disconnect(); AC.noclipConn=nil end; if AC.player.Character then for _,p in ipairs(AC.player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end end
    end)
end

-- ─────────────────────────────────────────────────────────
-- OPEN ANIMATION
-- ─────────────────────────────────────────────────────────
do
    AC.wrapper.Size=UDim2.new(0,0,0,0); AC.wrapper.Position=UDim2.new(0.5,0,1.5,0)
    AC.sidebar.Size=UDim2.new(0,0,1,0); AC.mainPanel.Size=UDim2.new(0,0,1,0); AC.navbar.Size=UDim2.new(1,0,0,0)
    task.delay(0.1,function()
        pcall(function() AC.openSound:Play() end)
        AC.TS:Create(AC.wrapper,TweenInfo.new(0.52,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,AC.UI_W,0,AC.UI_H),Position=UDim2.new(0.5,-AC.UI_W/2,0.5,-AC.UI_H/2)}):Play()
        task.delay(0.25,function() AC.TS:Create(AC.navbar,TweenInfo.new(0.22,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,0,AC.NAV_H)}):Play() end)
        task.delay(0.36,function() AC.TS:Create(AC.sidebar,TweenInfo.new(0.28,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.new(0,AC.SIDE_W,1,0)}):Play() end)
        task.delay(0.48,function()
            AC.TS:Create(AC.mainPanel,TweenInfo.new(0.28,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.new(0,AC.MAIN_W,1,0)}):Play()
            task.delay(0.18,function() AC.switchTab("Home") end)
        end)
        task.delay(0.7,function() AC._uiOpen=true end)
    end)
end

-- ── OPEN ANIMATION ───────────────────────────────────────
do
    AC.wrapper.Size=UDim2.new(0,0,0,0); AC.wrapper.Position=UDim2.new(0.5,0,1.5,0)
    AC.sidebar.Size=UDim2.new(0,0,1,0); AC.mainPanel.Size=UDim2.new(0,0,1,0); AC.navbar.Size=UDim2.new(1,0,0,0)
    task.delay(0.1,function()
        pcall(function() AC.openSound:Play() end)
        AC.TS:Create(AC.wrapper,TweenInfo.new(0.52,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Size=UDim2.new(0,AC.UI_W,0,AC.UI_H),
            Position=UDim2.new(0.5,-AC.UI_W/2,0.5,-AC.UI_H/2)
        }):Play()
        task.delay(0.25,function() AC.TS:Create(AC.navbar,TweenInfo.new(0.22,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,0,AC.NAV_H)}):Play() end)
        task.delay(0.36,function() AC.TS:Create(AC.sidebar,TweenInfo.new(0.28,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.new(0,AC.SIDE_W,1,0)}):Play() end)
        task.delay(0.48,function()
            AC.TS:Create(AC.mainPanel,TweenInfo.new(0.28,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.new(0,AC.MAIN_W,1,0)}):Play()
            task.delay(0.18,function() AC.switchTab("Home") end)
        end)
    end)
    task.delay(1.5,function() AC.toast("AC AudioCrafter v3.1 loaded! Press G to toggle.") end)
    print("AC AudioCrafter V3.1 — by MelodyCrafter")
    print("  G = toggle UI | Emotes tab: Reanimation + Open Emote Menu")
    print("  All KeyCode errors fixed | Double tag fixed | Ragdoll fix")
end
