def on_config(config):
    """
    Conditionally change the navigation depending on the theme.
    Remark: Each time I change something here, I have to restart: mkdocs serve (it won't update automatically)
    """
    theme_name = config.theme.name

    if theme_name == "material": # Navigation for "Material"
        config.nav = [
            {"Introduction": "index.md"}, # this file "index.md" must be in docs/
            {"Tutorials": [  
                {"1: Getting started": "src/start.md"},
                {"2: Installation": "src/installation.md"},
                {"3: Task skeleton": "src/skeleton.md"},
                {"4: Adding cuts": "src/cuts.md"},
                {"5: Access to CCDB": "src/ccdb.md"},
            ]},
            {"Challenges": [  
                {"Challenge 1": "Challenges/Challenge_1.md"},
                {"Challenge 2": "Challenges/Challenge_2.md"},
            ]},
        ]

    elif theme_name == "mkdocs": # Navigation for theme "bootstrap" theme (the default theme, but I have to use "mkdocs", not "bootstrap" as the name here)
        config.nav = [
            {"Introduction": "index.md"}, # this file "index.md" must be in docs/
        ]

    elif theme_name == "readthedocs": # Different structure for "ReadTheDocs" theme
        config.nav = [
            {"Introduction": "index.md"}, # this file "index.md" must be in docs/
        ]

    else: # Optional: fallback for unknown themes
        config.nav = [
            {"Home": "index.md"},
        ]

    return config
