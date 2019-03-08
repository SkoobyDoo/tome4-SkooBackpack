
require "engine.class"
require "engine.ui.Dialog"
local List = require "engine.ui.List"

local PickOneDialog = require "mod.dialogs.PickOneDialog"

module(..., package.seeall, class.inherit(engine.ui.Dialog))

function _M:init()
	self:generateList()
	engine.ui.Dialog.init(self, "SkooBackpack Menu", 1, 1)

	local list = List.new{width=400, nb_items=#self.list, list=self.list, fct=function(item) self:use(item) end}

	self:loadUI{
		{left=0, top=0, ui=list},
	}
	self:setupUI(true, true)

	self.key:addCommands{ __TEXTINPUT = function(c) if self.list and self.list.chars[c] then self:use(self.list[self.list.chars[c]]) end end}
	self.key:addBinds{ EXIT = function() game:unregisterDialog(self) end, }
end

function _M:on_register()
	game:onTickEnd(function() self.key:unicodeInput(true) end)
end

local menuActions = {
	equipitems = function()
		print("[Skoobackpack] [Menu] equipitems menu action chosen.")
		
		-- map to store items by slot as we iterate through the inventory.
		local itembuckets = {}
		-- iterate through items in player's base inventory
		for i,item in ipairs(game.player.inven[game.player.INVEN_INVEN]) do
			if item.slot and game.player:canWearObject(item) then
				if not itembuckets[item.slot] then
					itembuckets[item.slot] = {}
				end
				itembuckets[item.slot][#itembuckets[item.slot]+1] = {item=item, score=item:evaluatePowerLevel(game.player)}
				
				print("[Skoobackpack] player can wear",item.name,"in slot",item.slot)
			end
		end
		-- helper function to find player.INVEN_INVEN index 
		local function findSlotId(toFind)
			local inv = game.player.inven[game.player.INVEN_INVEN]
			for i,item in ipairs(inv) do
				if item == toFind then return i end
			end
			return nil
		end
		for slot,bucket in pairs(itembuckets) do
			table.sort(bucket, function(a,b) return a.score>b.score end)
			local thisslotid = game.player.inven_def[slot].id
			if game.player.inven[thisslotid] then
				local equippeditem = game.player.inven[thisslotid][1]
				if not equippeditem or bucket[1].score > equippeditem:evaluatePowerLevel(game.player) then
					print("[Skoobackpack] equipping item",bucket[1].item.name,
						"score:",bucket[1].score,"in slot",slot, "old score:",equippeditem and equippeditem:evaluatePowerLevel(game.player) or "none")
					local worn = game.player:doWear(game.player.INVEN_INVEN,findSlotId(bucket[1].item),bucket[1].item, game.player)
				else
					print("[Skoobackpack] item not good enough to equip",bucket[1].item.name,
						"score:",bucket[1].score,"in slot",slot, "old score:",equippeditem and equippeditem:evaluatePowerLevel(game.player) or "none")
				end
			end
		end
	end,
	statvalueconfig = function()
		print("[Skoobackpack] [Menu] statvalueconfig menu action chosen.")
		local d = require("mod.dialogs.ItemStatValueDialog").new(game.player)
		
		game:registerDialog(d)
	end,
}

function _M:use(item)
	if not item then return end
	game:unregisterDialog(self)
	print("[Skoobackpack] [Menu] Menu option chosen: '"..item.name.."'	with order code: "..item.order)
	
	if (menuActions[item.order]) then menuActions[item.order]() end
end

function _M:generateList()
	local list = {
		{1,name="Autoequip Best Items",order="equipitems"},
		{2,name="Set Stat Values",order="statvalueconfig"},
		{999,name="Cancel",order="donothing"}
	}

	local chars = {}
	for i, v in ipairs(list) do
		v.name = self:makeKeyChar(i)..") "..v.name
		chars[self:makeKeyChar(i)] = i
	end
	list.chars = chars

	self.list = list
end
