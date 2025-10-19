# Abcus Chat Cleaner

This project automates the management of Abacus.ai chat deployments and their sessions via the HTTP API. The main features are:

- Fetching projects and storing the projectId
- Fetching deployments and storing the deploymentId of the "ChatLLM Deployment"
- Fetching and deleting sessions (deploymentConversations)
- Deleting chats older than a specified number of days
- Dry-run mode to preview deletions without actually deleting

## Prerequisites

- IntelliJ IDEA with HTTP Client Plugin (for `main.http`)
- Credentials (API Key) for Abacus.ai
- For Bash scripts: `jq` and `curl` (install jq with `brew install jq` on macOS)

## Usage with IntelliJ HTTP Client

The `main.http` file contains all necessary HTTP requests and JavaScript logic to automatically extract IDs and store them as global variables. These variables can be used in further requests.

### Example Workflow

1. Fetch projects and store projectId
2. Fetch deployments and store the deploymentId of the "ChatLLM Deployment"
3. Fetch sessions for the deployment
4. Delete sessions or fetch details

## Usage with Bash Script

The `clean.sh` script provides an automated way to manage and clean up chat sessions.

### Features

- **Automatic API Key handling**: Accepts API key via command line, environment variable, or interactive prompt
- **Age-based filtering**: Delete chats older than a specified number of days with `--older-than`
- **Dry-run mode**: Preview what would be deleted without actually deleting with `--dry-run`
- **Interactive confirmation**: Asks for confirmation before deleting sessions
- **Detailed output**: Shows name, ID, and creation date of sessions to be deleted

### Command Line Options

```bash
./clean.sh [--api-key KEY] [--older-than DAYS] [--dry-run]
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
./clean.sh

# Preview chats older than 30 days (dry run)
./clean.sh --older-than 30 --dry-run

# Delete chats older than 30 days (with confirmation)
./clean.sh --older-than 30

# Delete chats older than 7 days with API key as argument
./clean.sh --api-key "YOUR_KEY" --older-than 7

# Use environment variable for API key
export ABACUS_API_KEY="YOUR_KEY"
./clean.sh --older-than 14

# Dry run with all options
./clean.sh --api-key "YOUR_KEY" --older-than 90 --dry-run
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
