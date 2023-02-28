-- Menu stuff for a different version of the mod
-- None of this is actually required to play bad apple
if PreplanImages then
    return
end
PreplanImages = {}
PreplanImages.modpath = ModPath
PreplanImages.savepath = SavePath.."PreplanImagesData.txt"
PreplanImages.datapath = ModPath.."data/"
PreplanImages.menu_id = "preplan_images_menu_id"
PreplanImages.items = {}
PreplanImages.indexes = {}
PreplanImages.select = "Amogus.txt"
function PreplanImages:Save()
    local save = io.open(self.savepath, 'w+')
    if save then
        save:write(self.select)
        save:close()
    end
end
function PreplanImages:Load()
    local save = io.open(self.savepath, 'r')
    if save then
        self.select = save:read()
        save:close()
    end
    self.items = self:scandir(self.datapath)
    self.indexes = self:table_invert(self.items)
end
-- Taken from Bobby Oster at
-- https://stackoverflow.com/questions/5303174/how-to-get-list-of-directories-in-lua
function PreplanImages:scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('dir "'..directory..'" /b')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end
function PreplanImages:table_invert(t)
    local s={}
    for k,v in pairs(t) do
        s[v]=k
    end
    return s
end
local save_exists = io.open(PreplanImages.savepath, "r")
if save_exists ~= nil then
    save_exists:close()
    PreplanImages:Load()
else
    PreplanImages:Save()
end
Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_PreplanImages",
function(loc)
    loc:load_localization_file(PreplanImages.modpath.."menu/en.txt")
end)
Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_PreplanImages",
function(menu_manager, nodes)
    MenuHelper:NewMenu(PreplanImages.menu_id)
end)
Hooks:Add("MenuManagerPopulateCustomMenus", "MenuManagerPopulateCustomMenus_PreplanImages",
function(menu_manager, nodes)
    local control_config = { menu_id = PreplanImages.menu_id }
    local placeholder = {"placeholder"}
    do
		control_config.localized = true
		local tmp = "preplanimages_set_image"
		control_config.id = tmp
		control_config.title = tmp .. "_title"
		control_config.desc = tmp .. "_desc"
		control_config.callback = "PreplanImages_set_image"
		control_config.items = placeholder
		control_config.value = PreplanImages.indexes[PreplanImages.select]
	end
	MenuHelper:AddMultipleChoice(control_config)
end)
Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_PreplanImages",
function(menu_manager, nodes)
    local menu = MenuHelper:BuildMenu(PreplanImages.menu_id, { back_callback = "PreplanImages_save" })
    nodes[PreplanImages.menu_id] = menu
    MenuHelper:AddMenuItem(nodes.blt_options or nodes.options, PreplanImages.menu_id, "preplan_images_menu_title", "preplan_images_menu_desc")
    for _,control in ipairs(menu._items_list) do
        control:clear_options()
        local config = {
            _meta = "option",
            localize = false
        }
        for k,v in pairs(PreplanImages.items) do
            config.text_id = tostring(v):sub(1, -5)
            config.value = k
            local option = CoreMenuItemOption.ItemOption:new(config)
            control:add_option(option)
            control:_show_options(nil)
            control:set_value(PreplanImages.indexes[PreplanImages.select])
        end
    end
end)
function MenuCallbackHandler.PreplanImages_save(node)
    PreplanImages:Save()
end
function MenuCallbackHandler:PreplanImages_set_image(item)
    PreplanImages.select = PreplanImages.items[item:value()]
end