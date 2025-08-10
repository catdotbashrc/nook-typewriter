# Setting Up Cloud Sync

Keep your writing safe with automatic cloud backups. This tutorial shows you how to connect your Nook typewriter to Google Drive or Dropbox.

## Why Cloud Sync?

- **Automatic backups** - Never lose your work
- **Access anywhere** - Read on phone, edit on computer
- **Version history** - Recover previous drafts
- **Peace of mind** - Hardware failure won't lose months of writing

## Prerequisites

Before starting, you need:

1. A Google or Dropbox account
2. Your Nook connected to WiFi
3. About 10 minutes for setup

## Part 1: Connect to WiFi

### Step 1: Access WiFi Settings

1. From the main menu, press **6** (Settings)
2. Select **2** (WiFi Setup)
3. You'll see available networks

### Step 2: Connect to Your Network

1. Use arrow keys to select your network
2. Press Enter
3. Type your WiFi password carefully
4. Press Enter to connect

✅ You'll see "Connected to [YourNetwork]"

### Troubleshooting WiFi

**Can't see your network?**
- Make sure WiFi is enabled on router
- Try moving closer to router
- 2.4GHz networks work best (not 5GHz)

**Connection fails?**
- Double-check password (case sensitive!)
- Try WPA2 security (not WPA3)
- Disable MAC filtering temporarily

## Part 2: Configure Cloud Storage

### Option A: Google Drive Setup

#### Step 1: Generate App Password

On your computer:

1. Go to [Google Account Settings](https://myaccount.google.com/security)
2. Enable 2-Step Verification (if not already)
3. Click "App passwords"
4. Select "Other" and name it "Nook"
5. Copy the 16-character password

#### Step 2: Configure on Nook

1. From main menu, press **3** (Sync)
2. Select **Configure Sync**
3. Choose **Google Drive**
4. Enter your email
5. Paste the app password
6. Select sync folder (default: `/NookWriting`)

### Option B: Dropbox Setup

#### Step 1: Create App Token

On your computer:

1. Visit [Dropbox App Console](https://www.dropbox.com/developers/apps)
2. Click "Create app"
3. Choose "Scoped access" and "Full Dropbox"
4. Name it "NookTypewriter"
5. Generate access token
6. Copy the long token string

#### Step 2: Configure on Nook

1. From main menu, press **3** (Sync)
2. Select **Configure Sync**
3. Choose **Dropbox**
4. Paste the access token
5. Select sync folder (default: `/Apps/NookWriting`)

## Part 3: Your First Sync

### Manual Sync

1. Write something in Vim first:
   ```
   :e test-sync.txt
   i
   This is my first cloud sync test!
   [Esc]
   :w
   ```

2. Exit Vim (`:q`)
3. From menu, press **3** (Sync)
4. Watch the progress

✅ Check your phone/computer - the file appears!

### Automatic Sync

By default, auto-sync runs every 30 minutes when idle.

To change settings:
1. Press **6** (Settings)
2. Select **3** (Sync Settings)
3. Adjust interval (5-60 minutes)
4. Toggle auto-sync on/off

## Understanding Sync Behavior

### What Gets Synced?

| Synced | Not Synced |
|--------|------------|
| `~/writing/*` | System files |
| `.txt` files | Vim swap files |
| `.md` files | Temporary files |
| `.org` files | Config files |

### Sync Direction

- **Upload**: Local → Cloud (default)
- **Download**: Cloud → Local (manual)
- **Bidirectional**: Both ways (advanced)

For safety, default is upload-only to prevent accidental overwrites.

### Conflict Resolution

If a file exists in both places:
- Newer version is kept
- Older version renamed with timestamp
- Example: `story.txt.backup-20231116`

## Organizing Your Cloud Files

### Recommended Structure

```
/NookWriting/
├── journal/
│   ├── 2023/
│   │   ├── 11-november/
│   │   │   ├── 2023-11-16.txt
│   │   │   └── 2023-11-17.txt
├── projects/
│   ├── novel/
│   │   ├── chapter01.txt
│   │   ├── chapter02.txt
│   │   └── outline.txt
│   └── poetry/
│       └── collection.txt
└── quick-notes/
    └── ideas.txt
```

### Creating Folders

In Vim:
```vim
:!mkdir -p ~/writing/journal/2023/11-november
:e ~/writing/journal/2023/11-november/today.txt
```

## Advanced Sync Options

### Selective Sync

Only sync certain folders:

1. Edit sync config: Settings → Sync Settings
2. Add folder patterns:
   ```
   +journal/*
   +projects/novel/*
   -projects/drafts/*
   ```

### Sync Notifications

Enable/disable sync notifications:
- Success: Brief message
- Errors: Detailed alert
- Progress: Transfer speed

### Manual Backup

Create local backup before sync:
```bash
# From menu option 7 (Terminal)
cd ~
tar -czf backup-$(date +%Y%m%d).tar.gz writing/
```

## Troubleshooting Sync

### Common Issues

**"Authentication failed"**
- Regenerate app password/token
- Check internet connection
- Verify credentials carefully

**"No files to sync"**
- Check file location (`~/writing/`)
- Ensure files are saved
- Verify file extensions

**"Sync timeout"**
- Large files take time on slow connection
- Try syncing fewer files
- Check WiFi signal strength

### Checking Sync Status

From the menu:
1. Press **4** (System Info)
2. Look for "Last sync"
3. Check error log if needed

### Manual Sync via Terminal

If menu sync fails:
```bash
# From terminal (menu option 7)
rclone sync ~/writing remote:NookWriting -v
```

## Best Practices

### Daily Workflow

1. **Morning**: Check sync status
2. **Writing**: Save frequently (`:w`)
3. **Breaks**: Manual sync after sessions
4. **Evening**: Verify cloud backup

### File Naming

Good names for cloud organization:
```
2023-11-16-morning-pages.txt
novel-chapter-03-draft2.txt
poem-untitled-autumn.txt
```

Avoid:
```
document1.txt
aaaaa.txt
temp.txt
```

### Security Tips

1. Use strong, unique passwords
2. Enable 2FA on cloud accounts
3. Don't sync sensitive information
4. Regularly check access logs

## Testing Your Setup

### Verification Steps

1. Create test file on Nook
2. Sync to cloud
3. Edit on computer
4. Sync back to Nook
5. Verify changes appear

### What Success Looks Like

- Files appear in cloud within minutes
- No duplicate files created
- Timestamps match
- No data loss

## Next Steps

Your writing is now safely backed up! Continue with:

1. **[Organizing Your Writing](../how-to/organize-writing-projects.md)** - File management
2. **[Sync Automation](../how-to/automate-sync.md)** - Advanced workflows
3. **[Multi-Device Writing](../how-to/multi-device-workflow.md)** - Phone + Nook

## Quick Reference

```
CLOUD SYNC COMMANDS
==================
Menu Options:
3 - Sync Now
6 → 3 - Sync Settings

Intervals:
Every 5 min - Heavy writing
Every 30 min - Normal (default)
Every 60 min - Light use

Manual Sync:
rclone sync ~/writing remote: -v
rclone ls remote:
```

---

☁️ **Tip**: Set up sync before starting any serious writing project. Better safe than sorry!