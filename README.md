# Abcus Chat Cleaner

This project automates the management of Abacus.ai chat deployments and their sessions via the HTTP API. The main features are:

- Fetching projects and storing the projectId
- Fetching deployments and storing the deploymentId of the "ChatLLM Deployment"
- Fetching and deleting sessions (deploymentConversations)
- Deleting chats older than a specified number of days
- Dry-run mode to preview deletions without actually deleting

## Installation

### Quick Install (Recommended)

Install the script with a single command:

```bash
curl -fsSL https://raw.githubusercontent.com/rdoering/abcus_chat_cleaner/main/install.sh | bash
```

This will:
- Clone the repository to `$XDG_DATA_HOME/abcus_chat_cleaner` (defaults to `~/.local/share/abcus_chat_cleaner`)
- Create a symlink at `~/.local/bin/abacus_clean_chat.sh`
- Make the script executable
- Check for required dependencies (git, jq)

### Manual Installation

1. Clone the repository:
```bash
git clone git@github.com:rdoering/abcus_chat_cleaner.git ~/.local/share/abcus_chat_cleaner
```

2. Create a symlink:
```bash
mkdir -p ~/.local/bin
ln -s ~/.local/share/abcus_chat_cleaner/abacus_clean_chat.sh ~/.local/bin/abacus_clean_chat.sh
chmod +x ~/.local/share/abcus_chat_cleaner/abacus_clean_chat.sh
chmod +x ~/.local/bin/abacus_clean_chat.sh
```

3. Add `~/.local/bin` to your PATH (if not already present):
```bash
# Add to ~/.zshrc or ~/.bashrc
export PATH="$HOME/.local/bin:$PATH"
```

### Update

To update an existing installation, run the install script again or:

```bash
cd ~/.local/share/abcus_chat_cleaner
git pull
```

## Prerequisites

- IntelliJ IDEA with HTTP Client Plugin (for `main.http`)
- Credentials (API Key) for Abacus.ai
- For Bash scripts: `jq` and `curl` (install jq with `brew install jq` on macOS)
- Git (for installation)

## Usage with IntelliJ HTTP Client

The `main.http` file contains all necessary HTTP requests and JavaScript logic to automatically extract IDs and store them as global variables. These variables can be used in further requests.

### Example Workflow

1. Fetch projects and store projectId
2. Fetch deployments and store the deploymentId of the "ChatLLM Deployment"
3. Fetch sessions for the deployment
4. Delete sessions or fetch details

## Usage with Bash Script

The `abacus_clean_chat.sh` script provides an automated way to manage and clean up chat sessions.

### Features

- **Automatic API Key handling**: Accepts API key via command line, environment variable, or interactive prompt
- **Age-based filtering**: Delete chats older than a specified number of days with `--older-than`
- **Dry-run mode**: Preview what would be deleted without actually deleting with `--dry-run`
- **Interactive confirmation**: Asks for confirmation before deleting sessions
- **Detailed output**: Shows name, ID, and creation date of sessions to be deleted

### Command Line Options

```bash
abacus_clean_chat.sh [--api-key KEY] [--older-than DAYS] [--dry-run]
```

**Options:**
- `--api-key KEY`: Specify the Abacus API key (optional if set as environment variable)
- `--older-than DAYS`: Delete chats older than the specified number of days
- `--dry-run`: Show what would be deleted without actually deleting

### API Key Configuration

The script accepts the API key in three ways (in order of priority):

1. **Command line argument**: `--api-key "YOUR_KEY"`
2. **Environment variable**: `export ABACUS_API_KEY="YOUR_KEY"`
3. **Interactive prompt**: Enter when prompted (if not provided by other methods)

### Examples

```bash
# List all sessions (no deletion)
abacus_clean_chat.sh

# Preview chats older than 30 days (dry run)
abacus_clean_chat.sh --older-than 30 --dry-run

# Delete chats older than 30 days (with confirmation)
abacus_clean_chat.sh --older-than 30

# Delete chats older than 7 days with API key as argument
abacus_clean_chat.sh --api-key "YOUR_KEY" --older-than 7

# Use environment variable for API key
export ABACUS_API_KEY="YOUR_KEY"
abacus_clean_chat.sh --older-than 14

# Dry run with all options
abacus_clean_chat.sh --api-key "YOUR_KEY" --older-than 90 --dry-run
```

### Example Output

```
Fetching projects...
projectId: 12679030fc
Fetching deployments...
chatLLMDeploymentId: 15aab63144
Fetching sessions...
Filtering chats older than 30 days...
Cutoff date: 2025-09-19T12:00:00
Found 5 session(s) to delete:
  - Old Chat 1 (ID: abc123, Created: 2025-08-15T10:30:00+00:00)
  - Old Chat 2 (ID: def456, Created: 2025-08-20T14:22:00+00:00)
  - Old Chat 3 (ID: ghi789, Created: 2025-09-01T08:15:00+00:00)

Do you want to delete these 5 session(s)? (yes/no): yes
Deleting sessions...
Deleting session: Old Chat 1 (ID: abc123)
  ✓ Successfully deleted
Deleting session: Old Chat 2 (ID: def456)
  ✓ Successfully deleted
Deleting session: Old Chat 3 (ID: ghi789)
  ✓ Successfully deleted
Deletion complete.
```

## Security Notes

- Never commit your API key to version control
- Use environment variables or interactive prompts for production use
- The `main.http` file contains a hardcoded API key for development - replace or remove it before sharing

## License

This project is proprietary and for internal use only.
