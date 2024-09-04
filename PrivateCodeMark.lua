--制作栏以及配方
local Ingredient = GLOBAL.Ingredient
local TECH = GLOBAL.TECH
local RECIPETABS = GLOBAL.RECIPETABS

local function Injectatlas(ingredients,amount)
    local atlas = "images/inventoryimages/"..ingredients..".xml"
    return Ingredient(ingredients,amount,atlas)
end
local function Injectproductimg(product)
    local atlas = "images/inventoryimages/"..product..".xml"
    return atlas
end
local function isShownFn(...)
    for k,v in pairs({...}) do
        if v == "yes" then
            return true
        end
    end
    return false
end

-- 给MOD物品添加一个分类
AddRecipeFilter({
    name = "EXAMPLE_TAB",
    atlas = "images/exampletab.xml",
    image = "exampletab.tex"
})
STRINGS.UI.CRAFTING_FILTERS.EXAMPLE_TAB = "样本制作分类"

local recipe_all = {
    --[[
    {
        recipe_name = "choleknife_recipe_1", --食谱ID
        ingredients = { --配方
            Injectatlas("nekosollyx_pack_gold",1), 
            Ingredient("rope",2), 
            Ingredient("log",2),
        },
        tech = TECH.SCIENCE_ONE, --所需科技
        isOriginalItem = true, --是官方物品,不写则为自定义物品
        isShown = true, --不写或true显示配方, 其他值则不显示
        config ={ --其他的一些配置,可不写
            --制作出来的物品,不写则默认制作出来的预制物为食谱ID
            product = "choleknife", 
            --xml路径,不写则默认路径为,"images/inventoryimages/"..product..".xml" 或 "images/inventoryimages/"..recipe_name..".xml"
            atlas = "images/inventoryimages/choleknife.xml",
            --图片名称,不写则默认名称为 product..".tex" 或 recipe_name..".tex"
            image = "choleknife.tex",
            --制作出的物品数量,不写则为1
            numtogive = 40,
        },
        filters = {"EXAMPLE_TAB"} --将物品添加到这些分类中,不写则默认用提供的TAB
    },
    ]]
------------------------------------------------------------------
--TOOLS-----------------------------------------------------------
------------------------------------------------------------------


------------------------------------------------------------------
--WEAPON----------------------------------------------------------
------------------------------------------------------------------
    {
        recipe_name = "staff_changehat",
        ingredients = {
            Ingredient("twigs", 1), 
        },
        tech = TECH.NONE,
        filters = {"TOOLS"}
    },
------------------------------------------------------------------
--ARMOR-----------------------------------------------------------
------------------------------------------------------------------

--------
--others
--------

}

for k,_r in pairs(recipe_all) do
    if _r.isOriginalItem == nil then
        if _r.config == nil then
            _r.config = {}
        end
        if _r.config.atlas == nil then
            if _r.config.product ~= nil then
                _r.config.atlas = Injectproductimg(_r.config.product)
                _r.config.image = _r.config.product..".tex"
            else
                _r.config.atlas = Injectproductimg(_r.recipe_name)
                _r.config.image = _r.recipe_name..".tex"
            end
        end
    end
    if _r.filters == nil then
        _r.filters = {"EXAMPLE_TAB"}
    end
    if _r.config == nil then
        _r.config = {}
    end
    if _r.isShown == nil or _r.isShown == true then
        AddRecipe2(_r.recipe_name, _r.ingredients, _r.tech, _r.config, _r.filters)
    end
end
------------------------------------------------------------------
--简单生成并抛出预制物
---------------
function bkfn.SpawnSinglePrefab_ThrowOut(tar,item)
    local pt = Vector3(tar.Transform:GetWorldPosition()) + Vector3(0,4.5,0)
    item.Transform:SetPosition(pt:Get())
    local down = TheCamera:GetDownVec()
    local angle = math.atan2(down.z, down.x) + (math.random()*60-30)*DEGREES
    local sp = math.random()*4+2
    item.Physics:SetVel(sp*math.cos(angle), math.random()*2+8, sp*math.sin(angle))
end
----------------------------------------------------
-------------武器--击晕
function elucidator_sys:stun(target,attacker,stun_chance,stun_time)
    ------------------------(target,attacker,眩晕几率,眩晕时间)
    if target.brain and target.components.combat and target.components.locomotor and not target:HasTag("elucidator_stun") and math.random(1,100) <= stun_chance*100 then
        target:AddTag("elucidator_stun")
        SpawnPrefab("lightning_rod_fx").Transform:SetPosition(target.Transform:GetWorldPosition())
        target.components.locomotor:Stop()
        target.brain:Stop()
        target:DoTaskInTime(stun_time,function(target)
            target.brain:Start()
            target:RemoveTag("elucidator_stun")
            end)
    end
end
local function onattack(inst, attacker, target)
    inst.components.elucidator_sys:stun(target,attacker,0.08,2)
end
inst.components.weapon.onattack = onattack
------------------------------------------
--对指定怪更容易暴击------------------
local function onattack(inst, attacker, target)
    local nightmaremobs = {
        "crawlinghorror",
        "crawlingnightmare",
        "terrorbeak",
        "nightmarebeak",
        "stalker_atrium",
        "shadow_knight",
        "shadow_bishop",
        "shadow_rook",
        "oceanhorror",
        "shadowthrall_horns",
        "shadowthrall_hands",
        "shadowthrall_wings",
        "fused_shadeling",
    }
    --如果已解锁对影怪更容易打出暴击
    if inst:HasTag("could_dohighcc_to_nightmaremobs") then 
        for k,v in pairs(nightmaremobs) do
            if target.prefab == v and not target:HasTag("elucidator_dohighcc") then
                --给怪物加上容易打出暴击的tag,直接写在onattack里好处是不用考虑读存的问题了
                target:AddTag("elucidator_dohighcc")
            end
        end
        if target:HasTag("elucidator_dohighcc") then
            inst.components.elucidator_sys:atk(inst,attacker,target,35)
        else
            inst.components.elucidator_sys:atk(inst,attacker,target,100)
        end
    else
        inst.components.elucidator_sys:atk(inst,attacker,target,100)
    end
end
inst.components.weapon.onattack = onattack
-------------------------------------------------------

-------添加按键技能------------------------------
TheInput = GLOBAL.TheInput
local mymodhandlers = {}
AddModRPCHandler(modname, "SKILL_A", function(player)
    if not player:HasTag("playerghost") then

    end
end)
AddModRPCHandler(modname, "SKILL_B", function(player)
    if not player:HasTag("playerghost") then

    end
end)
AddPlayerPostInit(function(inst)
    inst:DoTaskInTime(0, function()
        if inst == GLOBAL.ThePlayer then
            --if inst.prefab == "charactor_name" then --只允许某个人物使用技能
                mymodhandlers[0] = TheInput:AddKeyDownHandler(TUNING.CONFIG_SKILL_A, function()
                    local screen = GLOBAL.TheFrontEnd:GetActiveScreen()
                    local IsHUDActive = screen and screen.name == "HUD"
                    if inst:IsValid() and IsHUDActive then
                        SendModRPCToServer(MOD_RPC[modname]["SKILL_A"])
                    end
                end)
                mymodhandlers[1] = TheInput:AddKeyDownHandler(TUNING.CONFIG_SKILL_B, function()
                    local screen = GLOBAL.TheFrontEnd:GetActiveScreen()
                    local IsHUDActive = screen and screen.name == "HUD"
                    if inst:IsValid() and IsHUDActive then
                        SendModRPCToServer(MOD_RPC[modname]["SKILL_B"])
                    end
                end)
            --else
                --for k, v in pairs(mymodhandlers) do
                    --mymodhandlers[k] = nil
                --end
            --end
        end
    end)
end)
------------------------------------------------------------------
---------------------添加动作
STRINGS.MYMOD_ACTION = {
    REPAIRARMORWOOD = "修复护甲",
}

local function RepairFn(items,target)
    if target.components and target.components.armor then
        target.components.armor:SetPercent(target.components.armor:GetPercent()+.1)
        if items.components.stackable then
            items.components.stackable:Get():Remove()
        else
            items:Remove()
        end
    end
    return true
end

local actions = {
    {
        id = "REPAIRARMORWOOD", --动作ID
        str = STRINGS.MYMOD_ACTION.REPAIRARMORWOOD, --动作显示文字
        fn = function(act)
            if act.doer ~= nil and act.invobject ~= nil and act.target ~= nil and 
            act.invobject.prefab == "boards" and act.target.prefab == "armorwood" then
                return RepairFn(act.invobject,act.target) --动作执行函数:修复护甲耐久
            end
        end,
        state = "give", --绑定sg
        actiondata = {
            priority = 99,
            mount_valid = true,
        },
    },
    --[[
    {
        id = "XXX",
        str = STRINGS.MYMOD_ACTION.XXX,
        fn = function(act)

        end,
        state = "give",
        actiondata = {
            priority = 90,
            mount_valid = true,
        },
    },
    ]]
}
--绑定组件
local component_actions = {
    {
        type = "USEITEM", --动作类型
        component = "inventoryitem",
        tests = { --尝试显示
            {
                action = "REPAIRARMORWOOD",
                testfn = function(inst, doer, target, actions, right)
                    return doer:HasTag("player") and inst.prefab=="boards" and target.prefab=="armorwood"
                end,
            },
            --[[
            {
                action = "XXX",
                testfn = function(inst, doer, target, actions, right)
                    
                end,
            },
            ]]
        },
    },
}

for _,act in pairs(actions) do
    local addaction = AddAction(act.id,act.str,act.fn)
    if act.actiondata then
        for k,v in pairs(act.actiondata) do
            addaction[k] = v
        end
    end
    AddStategraphActionHandler("wilson",GLOBAL.ActionHandler(addaction, act.state))
    AddStategraphActionHandler("wilson_client",GLOBAL.ActionHandler(addaction,act.state))
end

for _,v in pairs(component_actions) do
    local testfn = function(...)
        local actions = GLOBAL.select (-2,...)
        for _,data in pairs(v.tests) do
            if data and data.testfn and data.testfn(...) then
                data.action = string.upper(data.action)
                table.insert(actions,GLOBAL.ACTIONS[data.action])
            end
        end
    end
    AddComponentAction(v.type, v.component, testfn)
end
----------------------------------------------
--简易冷却
if not inst:HasTag("iscooldown") then
    print("施法!")
    inst:AddTag("iscooldown")
end
inst:DoTaskInTime(cooldown_time, function()
    inst:RemoveTag("iscooldown")
end)
----------------------
--自动拾取附近物品
  -- local player
  local pos = Vector3(player.Transform:GetWorldPosition())
  local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, 3)
  for k, v in pairs(ents) do
      if v.components.inventoryitem ~= nil and
      v.components.inventoryitem.canbepickedup and
      v.components.inventoryitem.cangoincontainer and
      not v.components.inventoryitem:IsHeld() and 
      not v:HasTag("trap") and not v:HasTag("light") and not v:HasTag("blowdart") and not v:HasTag("projectile") and not v:HasTag("custom_cantquickpick") and
      player.components.inventory:CanAcceptCount(v, 1) > 0 then
          SpawnPrefab("sand_puff").Transform:SetPosition(v.Transform:GetWorldPosition())

          local v_pos = v:GetPosition()
          player.components.inventory:GiveItem(v, nil, v_pos)
          --return
      end
  end
  --modmain
  --添加一些不可拾取的物品,例如马鞍,骑马时拾取马鞍会报错
local cantquickpicktab = {
    "saddle_basic",
    "saddle_war",
    "saddle_race",
 }
 local function cantquickpick( inst )
     if not inst:HasTag("custom_cantquickpick") then
        inst:AddTag("custom_cantquickpick")
     end
 end
 for k,v in pairs(cantquickpicktab) do
    AddPrefabPostInit(v, cantquickpick) 
 end
  -----------------------------
  ---坐标计算
  -----------------人物面前某处距离坐标
  function tools:calcCoordFront(inst,dist)
    local angle = inst.Transform:GetRotation()
    local x,_,z = inst.Transform:GetWorldPosition()
    local radian_angle = (angle-90) * math.pi / 180
    return x - dist * math.sin(radian_angle), z - dist * math.cos(radian_angle)
end
-----------------------------------------------------
--获取两点距离
function tools:calcDist(x1,z1,x2,z2,do_sqrt)
    -- @param: do_sqrt 是否开平方
    local dist = (x1-x2)^2+(z1-z2)^2
    if do_sqrt then dist = math.sqrt(dist) end
    return dist
end
---
------在给定的一条直线上找到距离起点 (x2, z2) 指定距离 n 的点。这条直线由两点 (x1, z1) 和 (x2, z2) 定义
function tools:findPointOnLine(x1, z1, x2, z2, dist, n)
    local dx,dz = x1-x2,z1-z2
    local unitDX,unitDZ = dx/dist,dz/dist
    local newX, newZ = x2+unitDX*n ,z2+unitDZ*n
    return newX, newZ
end
--------
--获取圆周上的某个点
function tools:findPointOnCircle(x,z,radius,direction,angle)
    -- @param: direction 1:顺时针 -1:逆时针
    -- @param: angle 角度(角度制)
    -- @param: radius 半径
    angle = angle*direction
    local des_x = x + math.cos(math.rad(angle))*radius
    local des_z = z + math.sin(math.rad(angle))*radius
    
    return des_x, des_z
end


--API用法-----------------------------------------------------
-- 定义一个函数，在模拟器初始化后执行
local function CustomSimPostInit()
    -- 自定义代码示例：修改玩家初始属性
    local oldPlayerPostInit = GLOBAL.EntityScript.OnPlayerPostInit

    function GLOBAL.EntityScript:OnPlayerPostInit()
        oldPlayerPostInit(self)

        -- 修改玩家的初始饱食度
        if self.prefab == "wilson" then
            self.components.hunger:SetPercent(0.5)
            print("Player's initial hunger set to 50%")
        end
    end
end

--宣告
TheNet:Announce


-------动画代码
ThePlayer.AnimState:SetPercent("multithrust", 0.5) -- 这样写之后，直接跳到这一帧


-----------多功能工具
local tool = inst:AddComponent("tool")
		tool:SetAction(ACTIONS.CHOP, 15)
		tool:SetAction(ACTIONS.MINE, 15)
		tool:SetAction(ACTIONS.DIG, 15)
		tool:SetAction(ACTIONS.HAMMER, 15)
		tool:SetAction(ACTIONS.NET, 1)
	    -- tool:EnableToughWork(true)
        --耕地
        inst:AddComponent("farmtiller")
  inst.components.farmtiller.Till = function(self,pt, doer)
      local tilling = false
      local tile_x, tile_y, tile_z = TheWorld.Map:GetTileCenterPoint(pt.x, 0, pt.z)
      for x = -1,1 do
          for y = -1,1 do
              local till_x = tile_x + x*1.3
              local till_y = tile_z + y*1.3
              if TheWorld.Map:CanTillSoilAtPoint(till_x, 0, till_y, false) then
                  TheWorld.Map:CollapseSoilAtPoint(till_x, 0, till_y)
                  SpawnPrefab("farm_soil").Transform:SetPosition(till_x, 0, till_y)
                  tilling = true
              end
          end
      end
      if tilling then
          if doer ~= nil then
              doer:PushEvent("tilling")
          end
----------------------------------------------
--简易霸体
AddStategraphPostInit("wilson", function(sg)
    for k, v in pairs(sg.events) do
        if v["name"] == "attacked" then
            local oldAttackedFn = v.fn
            v.fn = function(inst, data)
                if inst:HasTag("misaka_nostiff") then
                    return
                end
                return oldAttackedFn(inst, data)
            end
            break
        end
    end
end)
----------------------------------------------
--射线  按键朝人物方向发射射线,射线覆盖的敌人持续受伤且会被击退,再按一次取消射线

--预制物方面:
-- MakeInventoryPhysics(inst) -- 这句可以注释掉

inst.AnimState:PlayAnimation('idle',true) -- 循环播放
inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround) -- 设置为俯视角,这样就可以360度转了
inst.AnimState:SetSortOrder(5) -- 设置覆盖优先度 1为地面
--生成射线:

local Tools = require 'tools' -- 把模块加载进来     

TheInput:AddKeyDownHandler(GLOBAL.KEY_H, function() 
    if TheFrontEnd:GetActiveScreen() and TheFrontEnd:GetActiveScreen().name == 'HUD' then 
        local inst = ThePlayer

        if inst.fx_laser == nil then 
        inst.components.playercontroller:Enable(false) -- 射线发射中,取消玩家控制移动
            inst.fx_laser = SpawnPrefab("fx_laserbeem") -- 给inst挂一个属性用来存储特效

            local angle = inst.Transform:GetRotation() -- 获取玩家当前角度
            local x,y,z = inst.Transform:GetWorldPosition() -- 获取玩家当前位置
            local radian_angle = (angle-90) * math.pi / 180 -- 将角度转换为弧度

            
            inst.fx_laser.Transform:SetPosition(x,y+1.5,z) -- 给纵轴一个偏移量，使特效在玩家头部
            inst.fx_laser.Transform:SetRotation(angle) -- 特效角度和人物角度保持一致
            inst.fx_laser.Transform:SetScale(2,2,2) -- 给特效一个缩放看起来更大

            local fx_len = 28 -- 特效在世界中的实际长度(自行测试)
            local iter_range = 2 -- 每次迭代半径,以刚好能覆盖特效宽度为佳

            local pos_inline = {} -- 存储需要进行迭代的圆心坐标
            for dist=iter_range,fx_len,iter_range*2 do -- 生成圆心坐标
                local x2,z2 = x - dist * math.sin(radian_angle), z - dist * math.cos(radian_angle)
                table.insert(pos_inline,{x2,z2})
            end
            
            -- 
            inst.task_period_beem = inst:DoPeriodicTask(0.5,function(inst)
                for _,pos in pairs(pos_inline) do
                    local ents = TheSim:FindEntities(pos[1],0,pos[2],iter_range)
                    for _,v in pairs(ents) do
                        if v and not v:HasTag('player') and v.prefab and v.components and v.components.health and not v.components.health:IsDead() and v.components.combat then 
                            -- 已筛选出范围内的目标
                            local v_x,_,v_z = v.Transform:GetWorldPosition() -- 获取目标位置
                            local dist_btw_v_and_p = Tools:calc_dist(x,z,v_x,v_z,true) -- 计算目标与玩家的距离
                            local des_x,des_z = Tools:findPointOnLine(v_x,v_z,x,z,dist_btw_v_and_p,dist_btw_v_and_p+2) -- 计算目标被击退后的坐标
                            v.Physics:Teleport(des_x,0,des_z)

                            v.components.combat:GetAttacked(inst,20) -- 造成伤害
                        end
                    end
                end
            end)
        else
            inst.components.playercontroller:Enable(true)
            inst.fx_laser:Remove()
            inst.fx_laser = nil
            if inst.task_period_beem then inst.task_period_beem:Cancel()inst.task_period_beem=nil end
        end

    end
end)
--彩虹变色
--注意返回的值r,g,b还要/255!

local function hsv_to_rgb(h, s, v)
    local r, g, b = 0, 0, 0
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)

    local rgb_map = {
        [0] = {v, t, p},
        [1] = {q, v, p},
        [2] = {p, v, t},
        [3] = {p, q, v},
        [4] = {t, p, v},
        [5] = {v, p, q},
    }

    local r, g, b = unpack(rgb_map[i % 6])

    return r, g, b
end

function tools:smoothRainbowColor(t)
    -- @param t: 1,2,3,4,5,...步长可以适当增加
    local h = t % 360 / 360  -- 将时间t映射到0到1之间的值，360度是一个完整的色轮周期
    local s, v = 1, 1        -- 固定饱和度和明度为最大值，以获得鲜艳的颜色

    -- 调用HSV到RGB转换函数
    local r, g, b = hsv_to_rgb(h, s, v)

    -- 将RGB值从[0,1]范围转换到[0,255]范围
    r = math.floor(r * 255 + 0.5)
    g = math.floor(g * 255 + 0.5)
    b = math.floor(b * 255 + 0.5)

    return r, g, b
end
----------------------屏幕特效
local Image = require 'widgets/image'
local UIAnim = require 'widgets/uianim'

AddClassPostConstruct('screens/playerhud',function(self) 
    -- self.filterimg = self:AddChild(Image('images/fx_0001.xml', 'fx_0001.tex','fx_0001.tex'))
    -- local maxw,maxh = TheSim:GetScreenSize()    
    -- self.filterimg:SetVAnchor(ANCHOR_MIDDLE)
    -- self.filterimg:SetHAnchor(ANCHOR_MIDDLE)
    -- self.filterimg:SetSize(maxw,maxh)
    -- self.filterimg:MoveToBack() -- 一定要置底,否则会遮挡控制HUD
    -- self.filterimg:SetClickable(false) -- 一定要设置不可点击,否则会点击不了地面
    -- self.filterimg:Hide()

    self.filter_uianim = self:AddChild(UIAnim())
    self.filter_uianim:SetVAnchor(ANCHOR_MIDDLE)
    self.filter_uianim:SetHAnchor(ANCHOR_MIDDLE)
    local maxw,maxh = TheSim:GetScreenSize()    
    local scalew,scaleh = maxw/64,maxh/64
    self.filter_uianim:SetScale(scalew,scaleh)
    self.filter_uianim:MoveToBack() -- 一定要置底,否则会遮挡控制HUD
    self.filter_uianim:SetClickable(false) -- 一定要设置不可点击,否则会点击不了地面

    self.animstate = self.filter_uianim:GetAnimState()
    self.animstate:SetBuild('fx_img1_1720748813')
    self.animstate:SetBank('fx_img1_1720748813')
    self.animstate:PlayAnimation('idle', true) -- 设置动画循环
    self.animstate:AnimateWhilePaused(false) -- 暂停时停止动画
    
end)
--configuration_options = {} --mod设置
configuration_options = {
    -----------------------------------
    {name = "Title", label = L and "Language setup" or "语言设置", options = {{description = "", data = ""},}, default = "",},
    L and {
        name = "wuyi_lambris_Language_setting",
        label = "󰀮  Language",
        hover = "Choose your language.", --这个是鼠标指向选项时会显示更详细的信息
        options =
        {
            -- {description = "Auto", data = "auto"},
            {description = "English", data = 2},
            {description = "Chinese", data = 1},
        },
        default = 2 ,
    } or {
        name = "wuyi_lambris_Language_setting",
        label = "󰀮  语言设置",
        hover = "设置模组语言。",
        options =
        {
            -- {description = "自动", data = "auto"},
            {description = "英文", data = 2},
            {description = "中文", data = 1},
        },
        default = 1 ,
    },}
    TUNING.WUYI_LAMBRIS_HEALTH = GetModConfigData('wuyi_lambris_health_setting')--读取config

    -------------ui拖拉
    local TEMPLATES = require 'widgets/redux/templates'
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
AddClassPostConstruct('screens/playerhud', function(self)
    self.btn_reset = self:AddChild(TEMPLATES.StandardButton(function()
        c_reset()
    end, "重载", { 50, 50 }))
    self.btn_reset:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.btn_reset:SetHAnchor(ANCHOR_LEFT)
    self.btn_reset:SetVAnchor(ANCHOR_BOTTOM)
    self.btn_reset:SetMaxPropUpscale(MAX_HUD_SCALE)
    self.btn_reset:SetPosition(40, 300)
    self.btn_reset:SetScale(1, 1)
    --以下才是拖拉内容
    self.btn_reset:SetOnLoseFocus(function() self.btn_reset:SetText('重载') end)

    self.btn_reset:SetOnGainFocus(function() self.btn_reset:SetText('确定重载') end)
    self.btn_reset.OnMouseButton = function(text, button, down, x, y, z, a, b, c)
        if button == MOUSEBUTTON_RIGHT and down then
            self.btn_reset:FollowMouse()
        else
            self.btn_reset:StopFollowMouse()
            self.btn_reset:SetPosition(TheInput:GetScreenPosition())
        end
    end
end)
-----按下H键，拖动鼠标拖拉UI
local state = false 
local tar 
local valid = false

local ui_pos
local mouse_pos
local scale


TheInput:AddKeyDownHandler(KEY_H,function()

    if not state then 
        state = true
        -- print('已按下!')
        tar = TheInput:GetHUDEntityUnderMouse()
        if tar and tar.widget then 
            valid = true 
            ui_pos = tar.widget:GetPosition()
            mouse_pos = TheInput:GetScreenPosition()
            scale = tar.widget.parent:GetScale()
        end
    end
    if state and valid then 
        -- print('执行中...')
        local new_pos = TheInput:GetScreenPosition()
        local mouse_delta = new_pos-mouse_pos
        tar.widget:SetPosition(ui_pos.x+mouse_delta.x/scale.x, ui_pos.y+mouse_delta.y/scale.y, 0)
    end
end)

TheInput:AddKeyUpHandler(KEY_H,function()
    state = false
    -- print('已弹起!')
    -- local ents = TheSim:GetEntitiesAtScreenPoint(TheSim:GetPosition())
    -- for _, v in ipairs(ents) do
    --     if v and v.Transform == nil then
    --         -- print(v, v.name, v.widget, v.widget.parent, v.UITransform)
    --         -- print(v.UITransform:GetWorldPosition())
    --         print('---------------------------')
    --         -- print(v.UITransform:GetWorldPosition())
    --         print(v.UITransform:GetLocalPosition())
    --     end
    -- end
end)
 SoundEmitter：声音组件，控制Prefab的声音集合和播放
	inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/abigail/attack_LP", "angry")	--播放声音
	inst.SoundEmitter:KillSound("angry")		--停止声音

---闪电特效
local BOUNCE_MUST_TAGS = { "_combat" }
local BOUNCE_NO_TAGS = { "INLIMBO", "wall", "notarget", "player", "companion", "flight", "invisible", "noattack", "electricdamageimmune" }

local function TryElectricChain(inst,attacker,target,targets,count)
    if count<1 then
        targets = nil
        return
    end
    local x,y,z = target.Transform:GetWorldPosition()
    for i, v in ipairs(TheSim:FindEntities(x, 0, z, 5, BOUNCE_MUST_TAGS, BOUNCE_NO_TAGS)) do
        if v ~= target and v.entity:IsVisible() and not targets[v] and 
            not (v.components.health ~= nil and v.components.health:IsDead()) and
            attacker.components.combat:CanTarget(v) and not attacker.components.combat:IsAlly(v) then
            local fx = SpawnPrefab("electricchargedfx")
            fx:SetTarget(target)
            targets[v] = true
            fx:DoTaskInTime(0.3,function ()
                if v.entity:IsValid() and not (v.components.health ~= nil and v.components.health:IsDead()) then
                    
                    local mult = 1
                    if not (v:HasTag("electricdamageimmune") 
                    or (v.components.inventory ~= nil and v.components.inventory:IsInsulated())) then
                        mult = 1.5 + (v:GetIsWet() and 1 or 0)
                    end
                    v.components.combat:GetAttacked(attacker,(10+2*count)*mult,inst,"electric")
                    TryElectricChain(inst,attacker,v,targets,count-1)
                end
            end)
            break
        end
    end    
end

local function onattack(inst, attacker, target)
    if target ~= nil and target:IsValid() and attacker ~= nil and attacker:IsValid() then
        SpawnPrefab("electrichitsparks"):AlignToTarget(target, attacker, true)
        TryElectricChain(inst,attacker,target,{},5)
    end
end
