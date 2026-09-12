# Songs, Audio, and Charts

Every song is a folder containing a `SongMetadata` resource, a `Song` scene, and chart data.

```text
gameplay/songs/song_name/
  meta.tres
  song.tscn
  audio/
    instrumental.ogg
    player.ogg
    opponent.ogg
  charts/
    easy.json
    normal.json
    hard.json
  scripts/
    phase_controller.gd
```

The folder name is the internal song ID used for scores and fallback display text.

## Metadata and difficulty

Create `meta.tres` as `SongMetadata`, set **Display Name**, **Artist**, **Charter**, and **Difficulties**, then add that exact resource to `content.tres` → **Freeplay Song List**.

Difficulty names are functional. For each selected difficulty the loader checks `charts/<difficulty>.json` first and `charts/chart.json` as a fallback. One shared `chart.json` is fine for one difficulty.

If parsing fails, the engine produces an empty chart rather than a friendly chart-format screen. Start every declared difficulty while testing.

## The Song scene and audio clock

The root of `song.tscn` should use `Song` (`res://core/classes/song/song.gd`) and have an assigned `AnimationPlayer`. Create an animation exactly named `song` whose length covers the music. This AnimationPlayer is authoritative: notes, conductor events, and music synchronization all follow its position.

Place each synced `AudioStreamPlayer` directly beneath that AnimationPlayer, assign its audio stream, and attach `SongStreamPlayer` (`res://core/classes/song/song_player.gd`).

```text
song_name (Node2D, Song)
  animation_player (AnimationPlayer)
    instrumental (AudioStreamPlayer, SongStreamPlayer)
    player       (AudioStreamPlayer, SongStreamPlayer)
    opponent     (AudioStreamPlayer, SongStreamPlayer)
  player_character (Character scene)
  opponent_character (Character scene)
  camera_2d (Camera2D)
```

Name player vocals `player` (or `vocal` as fallback). The runtime mutes that stream after player misses and restores it on player hits. Other stems still synchronize but do not get this automatic vocal behaviour.

`intro_cutscene` and `end_cutscene` are optional special animation names: the first runs before countdown, the second runs after music. Use AnimationPlayer property tracks for deterministic camera/stage choreography instead of moving them every frame.

## Supported chart formats

The current parser tries V-Slice, Codename Engine, Nightmare Vision, and Psych Engine formats. It uses the last matching parser.

The engine represents note time and length in **seconds**. Parsers convert typical millisecond JSON data.
custom code must not compare raw milliseconds to `song.conductor.song_position`.


```text
song animation
  0.000s   camera_2d.position = (600, 340)
  16.000s  camera_2d.position = (960, 330)
  16.500s  camera_2d.position = (960, 300)
```

The Song inspector’s **Convert Camera Events To KeyFrame** can seed such a track from imported focus markers. First add `player_camera_position` and `opponent_camera_position` as `Vector2` entries in the Song **Extra Data**, ensure a Camera2D and AnimationPlayer exist.