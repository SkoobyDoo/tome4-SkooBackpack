
require "engine.class"
local Dialog = require "engine.ui.Dialog"
local ListColumns = require "engine.ui.ListColumns"
local Textzone = require "engine.ui.Textzone"
local TextzoneList = require "engine.ui.TextzoneList"
local Separator = require "engine.ui.Separator"
local GetQuantity = require "engine.dialogs.GetQuantity"
local GetText = require "engine.dialogs.GetText"

local CustomActionDialog = require "mod.dialogs.CustomActionDialog"
local PickOneDialog = require "mod.dialogs.PickOneDialog"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(actor)
	self.actor = actor
	Dialog.init(self, "Define tactical talents usage", math.max(800, game.w * 0.8), math.max(600, game.h * 0.8))

	local vsep = Separator.new{dir="horizontal", size=self.ih - 10}
	local halfwidth = math.floor((self.iw - vsep.w)/2)
	self.c_tut = Textzone.new{width=halfwidth, height=1, auto_height=true, no_color_bleed=true, text=([[
Add item value definitions to this dialog to teach SkooBackpack how to evaluate item scores.

The actual format of item stats is pretty arcane so it's probably not worth tinkering with new entries unless you know what you're doing.
]])}
	self.c_desc = TextzoneList.new{width=halfwidth, height=self.ih, no_color_bleed=true}

	self.c_list = ListColumns.new{width=halfwidth, height=self.ih - 10, sortable=true, scrollbar=true, columns={
		{name="", width={30,"fixed"}, display_prop="char", sort="id"},
		{name="Label", width=20, display_prop="label", sort="label"},
		{name="Property String", width=70, display_prop="propstring", sort="propstring"},
		{name="Multiplier", width=12, display_prop="multiplier", sort="multiplier"},
	}, list={}, fct=function(item) self:use(item) end, select=function(item, sel) self:select(item) end}

	self:generateList()

	self:loadUI{
		{left=0, top=0, ui=self.c_list},
		{right=0, top=self.c_tut.h + 20, ui=self.c_desc},
		{right=0, top=0, ui=self.c_tut},
		{hcenter=0, top=5, ui=vsep},
	}
	self:setFocus(self.c_list)
	self:setupUI()

	self.key:addCommands{
		__TEXTINPUT = function(c)
			if self.list and self.list.chars[c] then
				self:use(self.list[self.list.chars[c]])
			end
		end,
	}
	self.key:addBinds{
		EXIT = function()
			game:unregisterDialog(self)
		end,
	}
end

function _M:on_register()
	game:onTickEnd(function() self.key:unicodeInput(true) end)
end

function _M:use(item)
	if not item then return end
	
	if item.addnew then
		local d = GetText.new("Enter a new property score definition.",'',2,9001,
			function(value)
				self.actor.skoobackpackscoredefs[#self.actor.skoobackpackscoredefs+1] = {propstring=value, label='', multiplier=1}
				self:generateList()
			end )
		game:registerDialog(d)
		return
	else
		local d = CustomActionDialog.new("Rule Label: "..item.label, {
			{name="Modify Rule",action=function(value)
				local d = GetText.new("Enter a new property score definition.",'',2,9001,
					function(value)
						self.actor.skoobackpackscoredefs[item.index].propstring=value
						self:generateList()
					end )
				game:registerDialog(d)
			end},
			{name="Modify Rule Label",action=function(value)
				local d = GetText.new("Enter a new Label.",'',1,50,
					function(value)
						self.actor.skoobackpackscoredefs[item.index].label=value
						self:generateList()
					end )
				game:registerDialog(d)
			end},
			{name="Select Multiplier",action=function(value)
				game:registerDialog(GetQuantity.new("Enter Multiplier value", "Multipliers multiply...", item.multiplier, nil, function(value)
						print("[Skoobackpack] [ItemStatValueDialog] Changing Multiplier for "..item.label.." to "..tostring(value))
						self.actor.skoobackpackscoredefs[item.index].multiplier=value
						self:generateList()
				end), 1)
			end},
			{name="Remove Entry",action=function(value)
				table.remove(self.actor.skoobackpackscoredefs,item.index)
				self:generateList()
			end},
		})
		game:registerDialog(d)
	end
end

function _M:select(item)
	if item then
		self.c_desc:switchItem(item, item.desc)
	end
end

function _M:generateList()
	local list = {}
	if not self.actor.skoobackpackscoredefs then self.actor.skoobackpackscoredefs = {} end
	for index, info in ipairs(self.actor.skoobackpackscoredefs) do
		list[#list+1] = {
			id=#list+1,
			index=index,
			propstring=info.propstring,
			label=info.label,
			multiplier=info.multiplier,
		}
	end
	
	list[#list+1] = {id=#list+1, propstring="#GOLD#Add a new definition...", desc="Select this option to add a new definition to SkooBackpack's repertoire.", label="", multiplier="", addnew=true}

	local chars = {}
	for i, v in ipairs(list) do
		v.char = self:makeKeyChar(i)
		chars[self:makeKeyChar(i)] = i
	end
	list.chars = chars

	self.list = list
	self.c_list:setList(list)
end
