Very serious game jam

res://
├── entities/
│   ├── player/
│   │   ├── player.tscn
│   │   ├── player.gd
│   │   └── sprites/
│   │       ├── face.png
│   │       ├── profil.png
│   │       └── ...
│   └── enemies/
│       ├── slime/
│       │   ├── slime.tscn
│       │   ├── slime.gd
│       │   └── sprites/
│       └── bat/
│           ├── bat.tscn
│           ├── bat.gd
│           └── sprites/
│
├── items/
│   ├── item_data.gd          (classe ItemData partagée)
│   ├── item_pickup.tscn      (scène générique)
│   ├── item_pickup.gd
│   └── definitions/
│       ├── key.tres
│       └── sword.tres
│
├── ui/
│   ├── components/
│   │   ├── custom_button/
│   │   │   ├── custom_button.tscn
│   │   │   └── custom_button.gd
│   │   ├── inventory_slot/
│   │   │   ├── inventory_slot.tscn
│   │   │   └── inventory_slot.gd
│   │   └── settings_button/
│   ├── menus/
│   │   ├── pause_menu/
│   │   │   ├── pause_menu.tscn
│   │   │   └── pause_menu.gd
│   │   └── main_menu/
│   └── hud/
│       └── inventory_bar/
│           ├── inventory_bar.tscn
│           └── inventory_bar.gd
│
├── levels/
│   ├── test_level/
│   │   ├── test_level.tscn
│   │   └── test_level.gd
│   └── level_01/
│
├── autoload/
│   ├── audio_manager.gd
│   ├── inventory.gd
│   ├── settings_manager.gd
│   └── globals.gd
│
├── shared/
│   ├── colors/
│   │   └── game_colors.gd
│   ├── themes/
│   │   └── global_theme.tres
│   └── enums/
│       └── music_enums.gd
│
├── audio/
│   ├── music/
│   │   ├── theme_calm.mp3
│   │   └── theme_tense.mp3
│   └── sfx/
│       ├── click.wav
│       └── hover.wav
│
└── tools/
	└── generate_theme.gd
