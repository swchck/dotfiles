local wezterm = require("wezterm")

local config = wezterm.config_builder()

config = {
    automatically_reload_config = true,
    enable_tab_bar = false,
    window_close_confirmation = "NeverPrompt",
    window_decorations = "RESIZE",
    default_cursor_style = "BlinkingBar",
    color_scheme = "Catppuccin Macchiato (Gogh)",
    font = wezterm.font("Monaspace Argon", { weight = "Bold" }),
    font_size = 12.5,
    use_fancy_tab_bar = true,
    window_background_opacity = 0.95,
}

config.keys = {
    { key = "F9", mods = "ALT", action = wezterm.action.ShowTabNavigator },
}

wezterm.on("gui-startup", function(cmd)
    local screen = wezterm.gui.screens().active
    local ratio = 0.7
    local width, height = screen.width * ratio, screen.height * ratio
    local tab, pane, window = wezterm.mux.spawn_window({
        position = {
            x = (screen.width - width) / 2,
            y = (screen.height - height) / 2,
            origin = "ActiveScreen",
        },
    })
    -- window:gui_window():maximize()
    window:gui_window():set_inner_size(width, height)
end)

return config
