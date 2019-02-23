local class = require "engine.class"
local Textzone = require "engine.ui.Textzone"
local KeyBind = require "engine.KeyBind"
local GetQuantity = require "engine.dialogs.GetQuantity"

class:bindHook("ToME:run", function(self, data)
	KeyBind:load("toggle-skoobackpack")
	game.key:addBinds {
		SKOOBACKPACK_MENU = function()
			local d = require("mod.dialogs.SkoobackpackMenu").new()
		    game.log("#GOLD#SkooBackpack Menu requested!")
			game:registerDialog(d)
		end
	}
end)

dofile("/data-skoobackpack/settings.lua")
--
-- tab=function
class:bindHook("GameOptions:tabs", function(self, data)
	-- *** This makes sure ALL of my Quality of Life packs are in one tab!
	if not self.skoobackpack_optioninit then
		self.skoobackpack_optioninit = true
		--
		data.tab("[Skoobackpack]", function() self.list = { skoobackpack_options=true } end)
	end
end)

local addonTitle = [[SkooBackpack]]
local addonShort = [[skoobckpk]]
-- list=self.list, kind=kind
class:bindHook("GameOptions:generateList", function(self, data)
	if data.list.skoobackpack_options then
		local list = data.list
		--
		-- *** Let's put all the "ugly" stuff in here. (:3)
		local function createOption(option, tabTitle, desc, defaultFunct, defaultStatus)
			defaultFunct = defaultFunct or function(item)
				config.settings.tome.SkooBackpack[option] = not config.settings.tome.SkooBackpack[option]
				--
				game:saveSettings("tome.SkooBackpack."..option, ("tome.SkooBackpack."..option.." = %s\n"):format(tostring(config.settings.tome.SkooBackpack[option])))
				self.c_list:drawItem(item)
			end
			defaultStatus = defaultStatus or function(item)
				return tostring(config.settings.tome.SkooBackpack[option] and "enabled" or "disabled")
			end
			
			list[#list+1] = { zone=Textzone.new{width=self.c_desc.w, height=self.c_desc.h,
			text=string.toTString("#GOLD#"..addonTitle.."\n\n#WHITE#"..desc.."#WHITE#")}, name=string.toTString(("#GOLD##{bold}#[%s] %s#WHITE##{normal}#"):format(addonShort, tabTitle)), status=defaultStatus, fct=defaultFunct,}
		end
		local function createNumericalOption(option, tabTitle, desc, defaultFunct, defaultStatus, minVal, maxVal, prompt)
			minVal = minVal or 0
			maxVal = maxVal or 1000000
			defaultFunct = defaultFunct or function(item)
				game:registerDialog(GetQuantity.new(prompt, "From "..minVal.." to"..maxVal, config.settings.tome.SkooBackpack[option] or minVal, maxVal, function(qty)
					config.settings.tome.SkooBackpack[option] = qty
					game:saveSettings("tome.SkooBackpack."..option, ("tome.SkooBackpack."..option.." = %s\n"):format(tostring(config.settings.tome.SkooBackpack[option])))
					self.c_list:drawItem(item)
				end))
			end
			defaultStatus = defaultStatus or function(item)
				return tostring(config.settings.tome.SkooBackpack[option] or "-")
			end
			
			list[#list+1] = { zone=Textzone.new{width=self.c_desc.w, height=self.c_desc.h,
			text=string.toTString("#GOLD#"..addonTitle.."\n\n#WHITE#"..desc.."#WHITE#")}, name=string.toTString(("#GOLD##{bold}#[%s] %s#WHITE##{normal}#"):format(addonShort, tabTitle)), status=defaultStatus, fct=defaultFunct,}
		end
		--
		--
		
		createNumericalOption("TEST_OPTION", "Test Option",
			"Placeholder so I have a copypasta for future options.")
	end
end)