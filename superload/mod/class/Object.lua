-- table reduction helper
function reduce(list, fn) 
    local acc
    for k, v in ipairs(list) do
        if 1 == k then
            acc = v
        else
            acc = fn(acc, v)
        end 
    end 
    return acc 
end

-- recursive object sum helper
function recSum(list)
	local sum = 0;
	for _,v in pairs(list) do
		if type(v) == "table" then
			sum = sum + recSum(v)
		else
			sum = sum + v
		end
	end
	return sum
end

-------------------------------------------------------
--================ VARIABLES ================--

local _M = loadPrevious(...)

-------------------------------------------------------

-- local function offensePowerLevel(power, critChance, critBonus, speed)
	-- return power * (1+critChance or 0) * (critBonus or 0+1.5) * speed or 1
-- end

-- local function weaponPowerLevels(actor)
	-- local attackScores = {}
	-- local temp = {}
	-- temp.o = actor:getInven(actor.INVEN_MAINHAND)
	-- temp.ammo = table.get(actor:getInven("QUIVER"), 1)
	-- temp.archery = temp.o
		-- and temp.o[1]
		-- and temp.o[1].archery
		-- and temp.ammo
		-- and temp.ammo.archery_ammo == temp.o[1].archery
		-- and temp.ammo.combat
		-- and (type ~= "offhand" or actor:attr("can_offshoot"))
		-- and (type ~= "psionic" or actor:attr("psi_focus_combat")) -- ranged combat
	
	-- if temp.archery then
		-- attackScores.ranged = actor:combatDamage(actor.combat, nil, temp.ammo.combat)
	-- end
	-- attackScores.melee = not attackScores.ranged and temp.o and temp.o[1] and temp.o[1].combat.dam or actor:combatDamage(actor.combat)
	-- return attackScores
-- end

-- function _M:evaluatePowerScores()
	-- local scores = {}
	-- scores.survivalScore = self.life/10 * self.life/self.max_life
	-- scores.physScore = offensePowerLevel(self.combat_dam, self.combat_generic_crit or 1+self.combat_physcrit, self.combat_critical_power,self.combat_physspeed)
	-- scores.spellScore = offensePowerLevel(self.combat_spellpower, self.combat_generic_crit or 1+self.combat_spellcrit, self.combat_critical_power,self.combat_spellspeed)
	-- scores.mindScore = offensePowerLevel(self.combat_mindpower, self.combat_generic_crit or 1+self.combat_mindcrit, self.combat_critical_power,self.combat_mindspeed)
	-- scores.defenseScore = self.combat_def/2 + self.combat_armor
	-- scores.statScore = reduce(self.inc_stats, function(a,b) return a+b end)
	
	-- scores.attackScores = weaponPowerLevels(self)
	-- return scores
-- end

-- function _M:evaluatePowerLevel()
	-- return recSum(self:evaluatePowerScores())
-- end

local old_tooltip = _M.tooltip
function _M:tooltip(x, y, use_actor)
	local result = old_tooltip(self, x, y, use_actor)
	print("[SkooBackpack] Object Tooltip Infiltration Successful!")
	if core.key.modState("ctrl") then
		table.print(self)
		-- local scores = self:evaluatePowerScores()
		-- result:add(true, "#FFD700#Power Level#FFFFFF#: "..string.format("%d",recSum(scores)), {"color", "WHITE"})
		-- for k,v in pairs(scores) do
			-- if type(v) ~= "table" then
				-- result:add(true, " #FFD700#"..k.."#FFFFFF#: "..string.format("%1.2f",v))
			-- else
				-- for k2,v2 in pairs(v) do
					-- result:add(true, " #FFD700#Weapon "..k2.."#FFFFFF#: "..string.format("%1.2f",v2))
				-- end
			-- end
		-- end
	else
		--result:add(true, "#FFD700#Power Level#FFFFFF#: "..string.format("%d",self:evaluatePowerLevel()), {"color", "WHITE"})
	end
    return result
end

--(name_param, compare_with, never_compare, use_actor)
local old_getDesc = _M.getDesc
function _M:getDesc(name_param, compare_with, never_compare, use_actor)
	local result = old_getDesc(self, name_param, compare_with, never_compare, use_actor)
	print("[SkooBackpack] Object getDesc Infiltration Successful!")
	if core.key.modState("ctrl") then
		table.print(self)
	end
    return result
end

-- original implementation in game/modules/tome/class/Object.lua. The magic happens in getDesc (which is overridden by better tooltips mod)
-- function _M:tooltip(x, y, use_actor)
	-- local str = self:getDesc({do_color=true}, game.player:getInven(self:wornInven()))
-- --	local str = self:getDesc({do_color=true}, game.player:getInven(self:wornInven()), nil, use_actor)
	-- if config.settings.cheat then str:add(true, "UID: "..self.uid, true, self.image) end
	-- local nb = game.level.map:getObjectTotal(x, y)
	-- if nb == 2 then str:add(true, "---", true, "You see one more object.")
	-- elseif nb > 2 then str:add(true, "---", true, "You see "..(nb-1).." more objects.")
	-- end
	-- return str
-- end