hl.config({
  general = { gaps_in = 5, gaps_out = 10, border_size = 0 },
  input = { scroll_method = "on_button_down", scroll_button = 274 },
  decoration = { rounding = 20, shadow = { range = 8 } },
  misc = {
    animate_manual_resizes = true, disable_hyprland_logo = true,
    disable_splash_rendering = true, key_press_enables_dpms = true,
    mouse_move_enables_dpms = true,
  },
  cursor = { hide_on_key_press = true, inactive_timeout = 10, no_warps = true },
  dwindle = { preserve_split = true, smart_resizing = false },
})

for i = 1, 7 do
  hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = i }))
  hl.bind("SUPER + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))  -- VERIFY silent
end

hl.bind("SUPER + SHIFT + m", hl.dsp.window.move({ direction = "l" }))  -- VERIFY direction
hl.bind("SUPER + SHIFT + n", hl.dsp.window.move({ direction = "d" }))
hl.bind("SUPER + SHIFT + e", hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + SHIFT + i", hl.dsp.window.move({ direction = "r" }))

hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + F", hl.dsp.window.fullscreen())
hl.bind("SUPER + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))

hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("pkill fuzzel; fuzzel"))
hl.bind("SUPER + RETURN", hl.dsp.exec_cmd("ghostty --gtk-single-instance=true"))
hl.bind("SUPER + C", hl.dsp.exec_cmd("hyprpicker --autocopy"))

hl.bind("PRINT", hl.dsp.exec_cmd("pkill grim; grim -g \"$(slurp -w 0)\" - | swappy -f - -o - | wl-copy --type image/png"))
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd("pkill grim; grim - | swappy -f - -o - | wl-copy --type image/png"))

hl.bind("SUPER + m", hl.dsp.focus({ direction = "l" }), { repeating = true })
hl.bind("SUPER + n", hl.dsp.focus({ direction = "d" }), { repeating = true })
hl.bind("SUPER + e", hl.dsp.focus({ direction = "u" }), { repeating = true })
hl.bind("SUPER + i", hl.dsp.focus({ direction = "r" }), { repeating = true })

hl.bind("SUPER + CTRL + m", hl.dsp.window.resize({ x = -100, y = 0 }), { repeating = true })  -- VERIFY resize shape
hl.bind("SUPER + CTRL + n", hl.dsp.window.resize({ x = 0, y = 100 }), { repeating = true })
hl.bind("SUPER + CTRL + e", hl.dsp.window.resize({ x = 0, y = -100 }), { repeating = true })
hl.bind("SUPER + CTRL + i", hl.dsp.window.resize({ x = 100, y = 0 }), { repeating = true })

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:274", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
