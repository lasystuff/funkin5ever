# Skins, Characters, and Presentation

Use the narrowest extension point that expresses the feature. A song scene handles stage art/camera; a SongScript handles reactive logic; a typed skin changes note visuals; a custom HUD is for a genuinely different interface.

## Note types and skins

The note renderer checks this path for a chart note whose type is `hurt`:

```text
gameplay/notes/hurt/skin.tres
```

Create `skin.tres` as `NoteSkin`. It contains strum frames and static/press/confirm animation arrays, note frames and directional animation array, sustain textures/end caps, splash assets, scale, and sing-animation names.

All four directional arrays must share the same order: **left, down, up, right**.

A typed skin is visual/mapping data, not a mechanic. Pair it with [SongScript](song-scripting.md) when it must affect health or scene logic.

## Custom HUDs

Assign a replacement through the Song root’s **HUD Scene**. The replacement root must extend `HUD`, and both `player_strumline` and `opponent_strumline` exports must be assigned. The base class receives conductor and gameplay callbacks.

```gdscript
extends HUD

@export var combo_label: Label

func _ready() -> void:
	if combo_label != null:
		combo_label.text = "0"

func _process(_delta: float) -> void:
	if combo_label != null:
		combo_label.text = str(Song.current.stats.combo)

func _on_note_hit(_note: Note, strumline: Strumline, judge: String = "sick") -> void:
	if strumline == player_strumline and combo_label != null:
		combo_label.modulate = Color.GOLD if judge == "sick" else Color.WHITE
```

The default HUD implements down-scroll and middle-scroll itself. A replacement must deliberately reproduce those preferences if it should support them.

## Countdown and entry presentation

Create `CountdownSkin` to supply ready/set/go textures and audio, then assign it on the Song root. Its scale controls prompt scale.