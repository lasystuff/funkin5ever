# Song Scripting

Song-local scripts load before global scripts. Both must extend `SongScript`.

```text
gameplay/songs/random-song/scripts/stage_state.gd  # this song only
gameplay/scripts/note_camera_displacement.gd                 # every song while enabled
```

## Callback reference

| Callback | Timing |
| --- | --- |
| `_ready()` | Script created; HUD/countdown setup is not finished yet. |
| `_ready_post()` | Countdown setup; reliable place for HUD/song references. |
| `_on_countdown_beat(step)` | Each countdown step. |
| `_on_song_start()` | As the `song` animation starts. |
| `_on_step_hit(step)` | Each conductor step. |
| `_on_beat_hit(beat)` | Each conductor beat. |
| `_on_note_hit(note, strumline, judge)` | On hit. Player hits carry a real judgement; opponent hits use the default argument. |
| `_on_note_miss(note, strumline)` | On note miss or sustain drop. |
| `_process(delta)` | Each song frame. |
| `_on_song_finish()` | Before the scene exits after music/end cutscene. |

`_on_ghost_tap` is declared by the base class, but the present `Strumline` does not dispatch it. Do not depend on it unless you verify a later engine revision has implemented that call.

`song` is the active `Song`; its conductor uses seconds. `song.conductor.current_beat`/`current_step` are musical integers and `song.conductor.song_position` is fractional seconds.

## Hints

- Use `get_node_or_null()` for optional decorative nodes.
- Use animation tracks for non-interactive choreography.
- Do not free notes or synchronize `SongStreamPlayer` manually.