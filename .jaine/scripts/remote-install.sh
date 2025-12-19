#!/bin/bash
# JAINE Plugins Installer
# Usage: curl -sSL https://raw.githubusercontent.com/whatrwewaitingf0r/claude-plugins-official/jaine/.jaine/scripts/remote-install.sh | bash

set -e

REPO="whatrwewaitingf0r/claude-plugins-official"
BRANCH="jaine"
MARKETPLACE_NAME="jaine-plugins"
INSTALL_DIR="$HOME/.claude/plugins/marketplaces/jaine-plugins"
KNOWN_MARKETPLACES="$HOME/.claude/plugins/known_marketplaces.json"

echo "🚀 Installing JAINE Plugins..."

# Check if Claude Code is installed
if [ ! -d "$HOME/.claude" ]; then
    echo "❌ Claude Code not found. Install Claude Code first."
    exit 1
fi

# Create plugins directory if needed
mkdir -p "$HOME/.claude/plugins/marketplaces"

# Clone or update repository
if [ -d "$INSTALL_DIR" ]; then
    echo "📦 Updating existing installation..."
    cd "$INSTALL_DIR"
    git fetch origin
    git checkout "$BRANCH"
    git pull origin "$BRANCH"
else
    echo "📦 Cloning repository..."
    git clone -b "$BRANCH" "https://github.com/$REPO.git" "$INSTALL_DIR"
fi

# Update known_marketplaces.json
echo "📝 Registering marketplace..."

if [ -f "$KNOWN_MARKETPLACES" ]; then
    # Check if jaine-plugins already exists
    if grep -q "jaine-plugins" "$KNOWN_MARKETPLACES"; then
        echo "✅ Marketplace already registered"
    else
        # Add to existing file (requires jq)
        if command -v jq &> /dev/null; then
            jq --arg name "$MARKETPLACE_NAME" \
               --arg path "$INSTALL_DIR" \
               --arg date "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)" \
               '. + {($name): {"source": {"source": "directory", "path": $path}, "installLocation": $path, "lastUpdated": $date}}' \
               "$KNOWN_MARKETPLACES" > "${KNOWN_MARKETPLACES}.tmp" && mv "${KNOWN_MARKETPLACES}.tmp" "$KNOWN_MARKETPLACES"
        else
            echo "⚠️  jq not found. Please add marketplace manually:"
            echo "   /plugin → Marketplaces → Add → $INSTALL_DIR"
        fi
    fi
else
    # Create new file
    cat > "$KNOWN_MARKETPLACES" << EOF
{
  "jaine-plugins": {
    "source": {
      "source": "directory",
      "path": "$INSTALL_DIR"
    },
    "installLocation": "$INSTALL_DIR",
    "lastUpdated": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"
  }
}
EOF
fi

echo ""
echo "✅ JAINE Plugins installed successfully!"
echo ""
echo "Next steps:"
echo "  1. Restart Claude Code"
echo "  2. Run /plugin to see available plugins"
echo "  3. Install plugins from 'jaine-plugins' marketplace"
echo ""
echo "To update later: cd $INSTALL_DIR && git pull"
