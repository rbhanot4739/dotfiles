#!/bin/zsh

bg_mode=$(cat $HOME/.bg_mode)

# Define color palettes for light and dark modes
dark_theme=(
    --color=bg:#272e33              # Main background
    --color=bg+:#414b50             # Selected item background
    --color=fg:#d3c6aa              # Default text
    --color=hl:#d699b6              # Search highlights
    --color=hl+:#d699b6             # Highlights on selected
    --color=border:#a7c080          # Window borders
    --color=gutter:#414b50          # Left margin
    --color=header:#83c092          # Header text
    --color=info:#9da9a0            # Status info
    --color=label:#9da9a0           # Labels
    --color=marker:#e67e80          # Multi-select markers
    --color=pointer:#e67e80         # Selection arrow
    --color=prompt:#d699b6          # Input prompt
    --color=query:#9da9a0:regular   # Search input text
    --color=scrollbar:#a7c080       # Scrollbar
    --color=separator:#dbbc7f       # Separators
    --color=spinner:#e67e80         # Loading spinner
)

light_theme=(
    --color=bg:#fffbef              # Main background
    --color=bg+:#e8e5d5             # Selected item background
    --color=fg:#5c6a72              # Default text
    --color=fg+:#5c6a72              # Default text
    --color=hl:#d699b6              # Search highlights
    --color=hl+:#d699b6             # Highlights on selected
    --color=border:#93b259          # Window borders
    --color=gutter:#e8e5d5          # Left margin
    --color=header:#35a77c          # Header text
    --color=info:#829181            # Status info
    --color=label:#829181           # Labels
    --color=marker:#f85552          # Multi-select markers
    --color=pointer:#f85552         # Selection arrow
    --color=prompt:#df69ba          # Input prompt
    --color=query:#829181:regular   # Search input text
    --color=scrollbar:#93b259       # Scrollbar
    --color=separator:#dfa000       # Separators
    --color=spinner:#f85552         # Loading spinner
)

# Select the appropriate theme based on bg_mode
if [[ "$bg_mode" == "light" ]]; then
    theme_opts=("${light_theme[@]}")
else
    theme_opts=("${dark_theme[@]}")
fi
