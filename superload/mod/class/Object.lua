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

-- implementation of string split
function split(self, pat)
  pat = pat or '%s+'
  local st, g = 1, self:gmatch("()("..pat..")")
  local function getter(segs, seps, sep, cap1, ...)
    st = sep and seps + #sep
    return self:sub(segs, (seps or 0) - 1), cap1 or sep, ...
  end
  return function() if st then return getter(st, g()) end end
end

-------------------------------------------------------
--================ VARIABLES ================--

local _M = loadPrevious(...)

-------------------------------------------------------

function _M:evaluatePowerScores(actor)
	-- uses the skoobackpackscoredefs of the actor to evaluate SELF item, returning the set of scores that contribute
	local scores = {}
	for i,ruledef in ipairs(actor.skoobackpackscoredefs) do
		local tmp = self;
		for v in split(ruledef.propstring,"\\") do
			print("Next dest: ","'"..v.."'")
			tmp=tmp[v]
			print("tmp=",tmp)
			table.print(tmp)
			if tmp == nil then break end
		end
		print("[Skoobackpack]","[HIGHLIGHT]","tmp=",tmp)
		
		if tmp then
			if 'number' == type(tmp) and tmp ~= 0 then
				scores[ruledef.label] = tmp * ruledef.multiplier
			else
				scores[ruledef.label] = ruledef.multiplier
			end
		end
	end
	return scores
end

function _M:evaluatePowerLevel(actor)
	-- uses the skoobackpackscoredefs of the actor to evaluate SELF item, returning the set of scores that contribute
	return recSum(self:evaluatePowerScores(actor))
end

local old_getDesc = _M.getDesc
function _M:getDesc(name_param, compare_with, never_compare, use_actor)
	local result = old_getDesc(self, name_param, compare_with, never_compare, use_actor)
	if core.key.modState("alt") then
		local scores = self:evaluatePowerScores(game.player)
		result:add(true, "#FFD700#Power Level#FFFFFF#: "..string.format("%d",recSum(scores)), {"color", "WHITE"})
		for k,v in pairs(scores) do
			if type(v) ~= "table" then
				result:add(true, " #FFD700#"..k.."#FFFFFF#: "..string.format("%1.2f",v))
			else
				for k2,v2 in pairs(v) do
					result:add(true, " #FFD700#Weapon "..k2.."#FFFFFF#: "..string.format("%1.2f",v2))
				end
			end
		end
	else
		result:add(true, "#FFD700#Power Level#FFFFFF#: "..string.format("%d",self:evaluatePowerLevel(game.player)), {"color", "WHITE"})
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