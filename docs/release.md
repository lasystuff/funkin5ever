## Releasing Content

Exported builds load `.pck` and `.zip` resource packs from a `contents/` folder beside the executable. They warn about unpacked package folders, which are intended for editor development.

Start with the project’s **Content Export** preset. The archive must preserve Godot resource paths under `res://contents/<package-id>/`, including `content.tres`, resources/scenes, scripts, charts, audio, textures, and dependencies. Do not flatten the package at archive root.

```text
GameFolder/
  funkin5ever.exe
  contents/
    content_name.pck
```

Use one archive per package. Test it in an empty copied game folder containing no editor imports, old packs, or development folder.