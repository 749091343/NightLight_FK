local extension = Package:new("pokemon")
extension.extensionName = "nightlight"

Fk:loadTranslationTable{
  ["pokemon"] = "夜光-宝可梦",
  ["new"] = "新",
}

local flareon = General:new(extension, "new__flareon", "shu", 3,4,"male")
local new__yanyi = fk.CreateTriggerSkill{
  name = "new__yanyi",
  frequency = Skill.Compulsory,
  events = fk.DamageCaused,
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase < Player.NotActive and player:hasSkill("new__yanyi") and data.damageType == fk.FireDamage
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player:getMark("new__yanyi_firedmgtimes") < player:getLostHp()
    then 
    data.damage = data.damage + 1
    player.room:addPlayerMark(player, "new__yanyi_firedmgtimes", 1)
    end

    room:setPlayerMark(player, "@new__yanyi_damagetimes", {player:getMark("new__yanyi_firedmgtimes")})
  end,
  refresh_events = {fk.EventLoseSkill,fk.TurnEnd,fk.TurnStart},
  can_refresh = function(self, event, target, player, data)
    if player ~= target or (not player:hasSkill(self)) then return false end
    if event == fk.EventLoseSkill then
      return true
    elseif event == fk.TurnStart then
      return true
    elseif event == fk.TurnEnd then
      return true
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventLoseSkill then
      room:setPlayerMark(player, "@new__yanyi_damagetimes", 0)
    elseif event == fk.TurnStart then
      room:setPlayerMark(player, "@new__yanyi_damagetimes", {player:getMark("new__yanyi_firedmgtimes")})
    elseif event == fk.TurnEnd then
      room:setPlayerMark(player, "@new__yanyi_damagetimes", 0)
    end
  end,
}

local new__yanyi_turnend = fk.CreateTriggerSkill{
  name = "#new__yanyi_turnend",
  frequency = Skill.Compulsory,
  events = fk.TurnEnd,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill("new__yanyi") and player:getMark("new__yanyi_firedmgtimes") > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:loseHp(player,player:getMark("new__yanyi_firedmgtimes"))
      --获取的牌table
    local cards = {}
    for _, id in ipairs(room.draw_pile) do
      --从牌堆中检索所有的火杀和火攻，然后放进名为cards的table里
      if Fk:getCardById(id).name == "fire__slash" or Fk:getCardById(id).name == "fire_attack" then
        table.insertIfNeed(cards, id)
      end
    end
    local drawfirecards ={}
      --获得与标记数目一样的指定牌
    while(#drawfirecards < player:getMark("new__yanyi_firedmgtimes"))do
      local randomcard = table.random(cards)
      table.insertIfNeed(drawfirecards, randomcard)
      --说明火伤牌在牌堆已经抽完了 不要再检索了
      if #drawfirecards >= #cards then break end
    end
    if #drawfirecards > 0 then
      room:moveCards({
        ids = drawfirecards,
        to = player.id,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonJustMove,
        proposer = player.id,
        skillName = self.name,
      })
    end

    if player:usedSkillTimes("yeyan", Player.HistoryGame) > 0 then player:addSkillUseHistory("yeyan", -1) end
    player.setMark(player,"new__yanyi_firedmgtimes",0)
  end,
}
new__yanyi:addRelatedSkill(new__yanyi_turnend)

local new__yinhuo = fk.CreateTriggerSkill{
  name = "new__yinhuo",
  events = fk.DamageInflicted,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and (target == player or player:distanceTo(target) == 1) and data.damageType == fk.FireDamage
  end,
  on_cost = function (self, event, target, player, data)
    local prompt = "你可以令 %dest 受到的火焰伤害-1，若该角色为你，则改为取消之。::"..data.to.id
    return player.room:askForSkillInvoke(player, self.name, nil, prompt)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.to
    local immune = 0
    if player == to then immune = data.damage else immune = 1 end
    data.damage = data.damage - immune
    local choices = { "new__yinhuo_Hp", "new__yinhuo_HpMax" }
    local choice = room:askForChoice(player, choices, self.name)
    if choice == "new__yinhuo_Hp" then room:recover{who = player, num = immune,recoverBy = player,skillName = self.name}
    elseif choice == "new__yinhuo_HpMax" then room:changeMaxHp(player, immune) end
  end,
}
flareon:addSkill(new__yanyi)
flareon:addSkill(new__yinhuo)
flareon:addSkill("yeyan")

Fk:loadTranslationTable{
    ["new__flareon"] = "新火伊布",
    ["#new__flareon"] = "火伊布",
    ["designer:new__flareon"] = "相守",
    ["cv:new__flareon"] = "暂无",
    ["illustrator:new__flareon"] = "网图",
    ["new__yanyi"] = "焱毅",
    ["#new__yanyi_turnend"] = "焱毅",
    [":new__yanyi"] = "锁定技，若你已受伤，你于回合内前X次造成的火焰伤害+1。回合结束时，若你发动过该技能，你失去等同于发动次数的体力并从牌堆中获得火【杀】或【火攻】共等量张，然后若你有已发动过的“业炎”，你视为未发动过“业炎”。（X为你已损失的体力值）",
    ['@new__yanyi_damagetimes'] = "焱毅 已加伤",
    ['@new__yanyi_damage_unusable'] = '焱毅 不可用',
    ["new__yinhuo"] = "引火",
    [":new__yinhuo"] = "你距离1以内的角色受到火焰伤害时，你可以令此伤害-1，若受伤角色为你，则改为取消之，然后你选择一项：1.恢复等同于减免伤害量的体力。2.增加等同于减免伤害量的体力上限。",
    ["new__yinhuo_Hp"] = "恢复等量体力",
    ["new__yinhuo_HpMax"] = "增加等量体力上限",
}

local jolteon = General:new(extension, "new__jolteon", "qun", 3,3,"male")
Fk:loadTranslationTable{
    ["new__jolteon"] = "新雷伊布",
    ["#new__jolteon"] = "雷伊布",
    ["designer:new__jolteon"] = "相守",
    ["cv:new__jolteon"] = "暂无",
    ["illustrator:new__jolteon"] = "网图",
  }

return extension