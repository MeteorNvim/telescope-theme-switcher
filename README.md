# Telescope Switcher Theme for MeteorNvim
```lua
{
    "MeteorNvim/telescope-theme-switcher",
    config = function ()
        require('telescope').load_extension('theme_switcher')
    end
}
```

# if you are not using MeteorNvim
you must create the following file: `~/.config/nvim/settings.json`
and add the following lines:
```json
{
    "theme": "default"
}
```
