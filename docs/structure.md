# funkin5ever Content Development

## Content package structure

```text
contents/
  my_first_mod/
    content.tres
    gameplay/
      songs/
        first_song/
          meta.tres
          song.tscn
          audio/
            instrumental.ogg
            player.ogg              # optional
            opponent.ogg            # optional
          charts/
            chart.json
            meta.json               # required by V-Slice/Codename charts
          scripts/                  # optional, only for this song
            stage_events.gd
      scripts/                      # optional, loaded for every song
        mod_rules.gd
    autoload/                       # optional, loaded globally
      mod_state.gd
```

`contents/my_first_mod/` is saved as the ID `my_first_mod`, so renaming it after users have enabled the mod will make the engine treat it as a different package.

## Content Metadata

In the Godot FileSystem dock, right-click the mod root and create a **Resource** using the `ContentMetadata` class. Save it as exactly `content.tres`.

`ContentMetadata` provides these useful fields:

| Field | What it does |
| --- | --- |
| **Name** | The name shown in the content manager. |
| **Description** | The text shown below the name. |
| **Initial Scene** | An optional scene to launch instead of the normal title screen while this content is enabled. |
| **Window Title** / **Icon** | Optional branding. The first enabled content with a window title establishes the window branding; its icon is applied when supplied. |
| **Freeplay Song List** | The `SongMetadata` resources that this package contributes to Freeplay. |

For a first mod, set the name and add one `meta.tres` resource to **Freeplay Song List**. Leave **Initial Scene** empty. The game will then use its usual menus and show your song in Freeplay whenever the package is enabled.

The content manager is also an ordering system. Enabled packages are searched in their listed order. Whenever the engine asks `ContentManager` for an overridable path, the first enabled package that contains that path wins; otherwise the copy in `core/` is used. This makes content order significant when two packages provide the same script or asset path.