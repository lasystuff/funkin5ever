# Content System

The content system allows you to add the main game and mods as separate "contents" under `contents/`.
Contents can add songs, characters, stages, menus, and more without modifying core files.

## Basic Structure

Each content is placed in a folder with a unique ID.

```text
contents/
└── my_mod/
	├── content.tres
	├── autoload/
	│   └── my_mod.gd
	├── gameplay/
	│   ├── characters/
	│   ├── hud/
	│   ├── notes/
	│   ├── songs/
	│   └── stages/
	├── fonts/
	├── shaders/
	└── videos/
```

The `my_mod` part is the content ID. The ID is automatically taken from the folder name,
so do not create multiple folders with the same name.

## Creating Content

1. Create a new folder in `contents/`.
2. Create `content.tres` inside that folder in Godot.
3. Set the resource's script to `ContentMetadata` (`core/classes/resources/content_metadata.gd`).
4. Place the required resources inside the content folder and reference them from `content.tres`.
5. Launch the game and enable the content from the content menu.

At minimum, `content.tres` must use `ContentMetadata` as its script and have a name.
When creating it from the Godot Inspector, select `ContentMetadata` as the resource type.

```text
name = "My Mod"
description = "A description of the content"
```

### ContentMetadata Properties

| Property | Description |
| --- | --- |
| `name` | The name displayed in the content menu |
| `description` | The description displayed in the content menu |
| `initial_scene` | The scene opened first when the content is enabled. The normal title screen is used when unset |
| `window_title` | The window title. The title is unchanged when empty |
| `icon` | The icon used in the content menu and window |
| `freeplay_song_list` | An array of `SongMetadata` resources displayed in Freeplay |

## Adding Songs

Place songs as follows.

```text
gameplay/
└── songs/
	└── my_song/
		├── meta.tres
		├── song.tscn       # optional
		├── charts/
		│   └── normal.*
		├── audio/
		└── ...
```

Make `meta.tres` a `SongMetadata` resource and set `display_name`, `artist`, `charter`,
and `difficulties`. Add the created `meta.tres` to `freeplay_song_list` in `content.tres`
to make the song selectable from Freeplay.

Additional files for a song are resolved relative to that song's folder. Refer to
`gameplay/songs/` in the existing contents for examples.

## File Lookup and Overrides

When the game requests a content-aware path, files are searched in the following order:

1. Search enabled contents in the order shown in the content menu
2. Use the file from the first content where it is found
3. If it is not found, use the file from `core/`

This means that placing a file at the same relative path as a core file allows a content
to override that core resource. If multiple contents provide the same file, the content
higher in the list takes priority. The order can be changed from the content menu.

## Content Scripts

### Autoloads

`.gd` files placed in `autoload/` are automatically loaded when the content is enabled.
The node name is the file name without its extension.

```gdscript
extends Node

var score_multiplier: float = 1.0
```

Use `CustomAutoload.get_autoload("my_mod")` to access an autoload from another script.
Do not define scripts with the same name in multiple contents.

### Getting Content Paths

When loading a content-aware file from a script, use `ContentManager` instead of constructing
paths under `res://contents/` directly.

```gdscript
var character_path := ContentManager.get_content_path(
	"gameplay/characters/my_character/character.tscn"
)
var character_scene: PackedScene = load(character_path)
```

Use `list_content_paths()` when you need a list of files in a directory.

```gdscript
var script_files := ContentManager.list_content_paths("gameplay/scripts/")
for file_name in script_files:
	var script_path := ContentManager.get_content_path(
		"gameplay/scripts/" + file_name
	)
```

## Exporting Content (TBA)