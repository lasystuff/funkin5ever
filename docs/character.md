# Creating Characters

A funkin5ever character is a reusable `Character` scene. It owns its visual sprite, an `AnimationPlayer` that translates gameplay animation names into sprite animation names and offsets, healthbar icon data, and death screen data.

Keep each character self-contained:

```text
gameplay/characters/bf_two/
  character.tscn
  bf_two.png
  bf_two.xml
  icon.png
  dead.tscn                 # optional
```

The character folder is a useful convention, not an automatic loader. Add an instance of `character.tscn` to the relevant `song.tscn` yourself.

## Start from the base character scene

The quickest way is to duplicate `core/gameplay/characters/bf/character.tscn` into your content folder, then replace its art and animations.

The `Character` script registers the node with its selected strumline after the song HUD is ready. Do not manually push normal characters into a strumline’s `characters` array; the class does it for you.

## Import and prepare sprite frames

The project includes the Godot Sparrow importer. Keep a Sparrow atlas PNG and its XML in the same character folder, let Godot import the XML, then assign the resulting `SpriteFrames` resource to the `sprite` node. The existing BF scene uses `AnimatedSprite2DEx`, a small extension that makes its `playing` property work cleanly in AnimationPlayer tracks.

Before creating engine animations, inspect the imported `SpriteFrames` and write down the exact source names. They may be names such as `BF idle`, `BF NOTE LEFT`, and `BF NOTE LEFT miss`. Case, spaces, and punctuation must match the importer output.

Set the sprite’s neutral animation and its visual position. A negative Y position is common because the scene root is normally treated as the character’s ground point. Do the placement in the song scene after the character scene itself looks right at `(0, 0)`.


Gameplay does not request atlas names directly. On a note hit it requests the character animation named by the active `NoteSkin`, normally `sing_left`, `sing_down`, `sing_up`, or `sing_right`. The `AnimationPlayer` converts each of those engine-facing names into a change to `sprite.animation`, `sprite.playing`, and usually `sprite.offset`.

Create these AnimationPlayer animations at minimum:

| Engine animation | SpriteFrames animation | Purpose |
| --- | --- | --- |
| `idle` | Your idle/dance animation | Played on beat when the character can dance. |
| `sing_left` | Left singing animation | Left note. |
| `sing_down` | Down singing animation | Down note. |
| `sing_up` | Up singing animation | Up note. |
| `sing_right` | Right singing animation | Right note. |
| `sing_left_miss` etc. | Matching miss animation | Optional; played when a note is missed. |

For each engine animation, add value tracks targeting the sprite:

```text
sprite:playing   = true
sprite:animation = "BF NOTE LEFT"
sprite:offset    = (-18, 4)
```

Use a short non-looping animation length such as 0.6 seconds for sing poses. `Character` unlocks dancing when an animation finishes and will return to idle based on the beat. Offset keys compensate for different frame bounding boxes without forcing perfectly aligned atlas frames.

The default note skin expects the exact `sing_left`, `sing_down`, `sing_up`, and `sing_right` names. If you intentionally use different engine animation names, create a custom `NoteSkin` and change its **Sing Animations** array in left/down/up/right order.

## Dance and sustain behaviour

With a one-item **Dance Animations** list, the character plays that animation every two beats. With two or more entries, it alternates through them every beat—useful for left/right idle dances.

`sustain_nimble` controls how sustain notes behave. By default, a sustain does not forcibly restart a sing pose on every sustain tick. Enable it when a character’s visual style needs a fresh sing animation for each sustain update.

## Health icon and player death scene

Set **Health Icon** to a two-frame texture if you want the default HUD’s healthy/danger icon states. The HUD switches the player icon at low health and the opponent icon at high player health. Adjust **Health Icon Scale** if the art’s native size differs from the default.

For a playable character, make `dead.tscn` as another `Character` scene and assign it to **Death Character**. Its root should use `Character`, its **Character Type** should be `Extra`, and its **Dance Animations** list should be empty. Supply these AnimationPlayer names:

```text
intro  # played with the death intro audio
loop   # replayed to the death-music beat
retry  # played when the player confirms retry
```

Then assign **Death Music Intro**, **Death Music Loop**, **Death Music Retry**, and **Death Music BPM** on the normal playable character. The default death screen takes all of that data from the first player character in the current song.

## Put the character in a song

Instance `character.tscn` in `song.tscn`, position it on the stage, and set its Character Type in the instance if you need a player/opponent variant. Character order matters to the default HUD: it takes the first character associated with each strumline as its displayed health icon; the death screen takes the first player character.

```text
song_name (Song)
  bf (instance of bf/character.tscn)
    character_type = Player
  opponent (instance of opponent/character.tscn)
    character_type = Opponent
```

Play a song with notes in all four columns, then test a miss. This confirms both the default sing names and optional miss-name convention.