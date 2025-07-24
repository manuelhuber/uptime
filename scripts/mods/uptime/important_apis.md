[UIWidget](https://github.com/Aussiemon/Darktide-Source-Code/blob/72cde1c088677d22b3830d9681d015167782b10a/scripts/managers/ui/ui_widget.lua#L4)
test
```lua
UIWidget.create_definition = function (pass_definitions, scenegraph_id, content_overrides, optional_size,
style_overrides)
end
```

[UiManager](https://github.com/Aussiemon/Darktide-Source-Code/blob/72cde1c088677d22b3830d9681d015167782b10a/scripts/managers/ui/ui_manager.lua)

````lua
UIManager.open_view = function(self, view_name, transition_time, close_previous, close_all, close_transition_time, context, settings_override)
end

UIManager.close_view = function(self, view_name, force_close)
end

UIManager.close_all_views = function(self, force_close, optional_excepted_views)
end
````

[BaseView](https://github.com/Aussiemon/Darktide-Source-Code/blob/72cde1c088677d22b3830d9681d015167782b10a/scripts/ui/views/base_view.lua)
```lua
BaseView._create_widget = function (self, name, definition, widgets_by_name)
    
end
BaseView.draw = function (self, dt, t, input_service, layer)
    
end

BaseView._draw_widgets = function (self, dt, t, input_service, ui_renderer, render_settings)
-- draws self._widgets
end 
```

[StateGameplay](https://github.com/Aussiemon/Darktide-Source-Code/blob/72cde1c088677d22b3830d9681d015167782b10a/scripts/game_states/game/state_gameplay.lua#L79)
````lua
StateGameplay.on_enter = function (self, parent, params, creation_context)
````