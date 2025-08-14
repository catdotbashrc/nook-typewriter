# WiFi Sync Module Architecture (Future Enhancement)

## Overview

An **optional** module that enables cloud synchronization while preserving the core offline-first writing experience. WiFi remains OFF by default and only activates for explicit sync operations.

## Design Principles

1. **Offline First**: Device remains offline 99% of the time
2. **Manual Control**: WiFi only enabled by explicit user action
3. **Minimal Impact**: <5MB additional RAM when active
4. **Battery Conscious**: Auto-disable after sync
5. **Security First**: Encrypted connections only
6. **Writer Friendly**: Simple, non-intrusive sync

## Architecture

### Module Structure

```text
WiFi Sync Module (Optional):
┌─────────────────────────────────────────────────┐
│             WiFi Sync Manager                   │
│         (Disabled by Default)                   │
└──────────────────┬──────────────────────────────┘
                   │ User Trigger
                   ▼
┌─────────────────────────────────────────────────┐
│           Sync State Machine                    │
├─────────────────────────────────────────────────┤
│ IDLE → CONNECTING → SYNCING → COMPLETE → IDLE  │
└──────────────────┬──────────────────────────────┘
                   │
    ┌──────────────┼──────────────┬───────────────┐
    ▼              ▼              ▼               ▼
┌────────┐    ┌────────┐    ┌────────┐     ┌────────┐
│  WiFi  │    │  Auth  │    │  Sync  │     │ Power  │
│ Driver │    │ Manager│    │ Engine │     │Manager │
└────────┘    └────────┘    └────────┘     └────────┘
```

### Integration Points

```text
Menu System Integration:
┌──────────────┐
│  Main Menu   │
└──────┬───────┘
       │
       ▼
[S] Sync Notes ──► WiFi Sync Module
                          │
                          ▼
                   ┌──────────────┐
                   │ Sync Options │
                   ├──────────────┤
                   │ [1] Quick Sync│ (Last 24h)
                   │ [2] Full Sync │ (Everything)
                   │ [3] Download  │ (Pull only)
                   │ [4] Upload    │ (Push only)
                   │ [Q] Cancel    │
                   └──────────────┘
```

## Implementation Design

### 1. WiFi Control Layer

```bash
# /usr/local/bin/wifi-control.sh
wifi_enable() {
    # Power on WiFi hardware
    echo 1 > /sys/class/rfkill/rfkill0/state
    
    # Load WiFi driver module
    modprobe libertas_sdio
    
    # Start minimal networking
    /usr/sbin/wpa_supplicant -B -i wlan0 -c /etc/wpa.conf
    dhclient -q wlan0
    
    # Set timeout for auto-disable (5 minutes)
    (sleep 300 && wifi_disable) &
}

wifi_disable() {
    # Kill network services
    killall dhclient wpa_supplicant 2>/dev/null
    
    # Unload driver
    rmmod libertas_sdio
    
    # Power off WiFi hardware
    echo 0 > /sys/class/rfkill/rfkill0/state
}
```

### 2. Sync Engine Architecture

```text
Sync Strategy:
┌─────────────────────────────────────────────────┐
│              Differential Sync                  │
├─────────────────────────────────────────────────┤
│  1. Generate local checksums                    │
│  2. Compare with cloud manifest                 │
│  3. Upload changed files only                   │
│  4. Download new/modified files                 │
│  5. Resolve conflicts (newer wins)              │
└─────────────────────────────────────────────────┘

File Structure:
/root/
├── notes/           (Synced)
│   ├── .sync/       (Metadata)
│   │   ├── manifest.json
│   │   └── checksums.db
│   └── *.md         (Notes)
├── drafts/          (Synced)
└── scrolls/         (Synced)
```

### 3. Cloud Service Integration

```yaml
Supported Services (Planned):
  Primary:
    - Dropbox (via API)
    - Google Drive (via API)
    - WebDAV (self-hosted)
  
  Future:
    - Nextcloud
    - OneDrive
    - Git (for version control)

Authentication:
  - OAuth2 for cloud services
  - Token stored encrypted
  - No passwords stored
```

### 4. Security Architecture

```text
Security Layers:
┌─────────────────────────────────────────────────┐
│           Application Security                  │
│  - OAuth2 tokens only                          │
│  - No password storage                         │
│  - Encrypted config files                      │
└──────────────────┬──────────────────────────────┘
                   ▼
┌─────────────────────────────────────────────────┐
│           Transport Security                    │
│  - TLS 1.3 only                                │
│  - Certificate pinning                         │
│  - No fallback to HTTP                         │
└──────────────────┬──────────────────────────────┘
                   ▼
┌─────────────────────────────────────────────────┐
│            Network Security                     │
│  - Firewall (outbound only)                    │
│  - No listening ports                          │
│  - Auto-disconnect after sync                  │
└─────────────────────────────────────────────────┘
```

## User Experience Design

### Sync Workflow

```text
1. User Selects Sync:
   Menu → [S] Sync Notes

2. WiFi Activation:
   "Awakening the carrier pigeons..." (3s)
   [Progress bar during connection]

3. Sync Progress:
   "Sending scrolls to the cloud castle..."
   Files: 12/47 [████████░░░░░░░] 
   
4. Completion:
   "✓ Thy words are safely stored!"
   "WiFi slumbers again..."
   [Auto-return to menu in 3s]
```

### Configuration

```bash
# /etc/nook-sync.conf
SYNC_SERVICE="dropbox"              # dropbox|gdrive|webdav
SYNC_TOKEN="encrypted_token_here"   # Encrypted OAuth token
SYNC_INTERVAL="manual"              # manual|daily|hourly
WIFI_TIMEOUT="300"                   # Seconds before auto-disable
SYNC_DIRECTION="bidirectional"      # upload|download|bidirectional

# Selective Sync
SYNC_NOTES="true"
SYNC_DRAFTS="true"
SYNC_SCROLLS="false"                # Complete works, rarely change
```

## Memory & Performance Impact

### Memory Budget

```text
Component               Idle    Active
─────────────────────────────────────
WiFi Driver             0MB     3MB
WPA Supplicant          0MB     1MB
DHCP Client             0MB     0.5MB
Sync Engine             0MB     2MB
TLS Library             0MB     1MB
─────────────────────────────────────
Total                   0MB     7.5MB

Note: All components unloaded when idle
```

### Performance Targets

- WiFi Enable: <5 seconds
- Connection: <10 seconds
- Sync 100 files: <30 seconds
- WiFi Disable: <2 seconds
- Battery Impact: <5% per sync session

## Implementation Phases

### Phase 1: Basic Sync (MVP)
- Manual WiFi control
- Dropbox integration only
- Simple file upload/download
- No conflict resolution

### Phase 2: Enhanced Sync
- Multiple cloud services
- Differential sync
- Basic conflict resolution
- Sync status display

### Phase 3: Advanced Features
- Selective sync
- Version history
- Encrypted backups
- Scheduled sync (optional)

## Technical Requirements

### Kernel Modules Needed
```bash
# WiFi Support
libertas_sdio.ko    # Marvel 8686 WiFi driver
cfg80211.ko         # Wireless configuration API
mac80211.ko         # IEEE 802.11 stack
```

### Additional Packages
```bash
# Minimal networking stack (5MB total)
wpa_supplicant      # WiFi authentication
dhclient            # DHCP client
curl                # HTTP/HTTPS client
jq                  # JSON parsing
openssl             # Encryption/TLS
```

## Medieval Theme Integration

### Status Messages
```text
Connecting:    "Summoning the aether spirits..."
Authenticating: "Presenting thy royal seal..."
Syncing:       "Dispatching carrier pigeons..."
Complete:      "The scrolls have traveled safely!"
Error:         "Alas! The pigeons have lost their way!"
```

### Visual Feedback
```text
     .~"~.~"~.
    /  @   @  \     "Syncing thy manuscripts..."
   |  >  ◡  <  | >>>
    \  ___  /       [████████████░░░░] 75%
     |~|♦|~|        
    d|  ↟  |b       ↟ = scrolls ascending
```

## Error Handling

### Failure Modes
1. **No WiFi Hardware**: Graceful message, disable menu option
2. **Connection Failed**: Retry 3x, then give up
3. **Auth Failed**: Clear token, request re-auth
4. **Sync Conflict**: Keep both versions with timestamps
5. **Out of Space**: Warn user, selective sync

### Recovery Strategy
```bash
# Auto-recovery on failure
sync_with_recovery() {
    wifi_enable || return 1
    
    # Try sync with exponential backoff
    for attempt in 1 2 3; do
        if perform_sync; then
            wifi_disable
            return 0
        fi
        sleep $((attempt * 5))
    done
    
    # Ensure WiFi disabled on failure
    wifi_disable
    return 1
}
```

## Privacy Considerations

1. **No Analytics**: Zero tracking or telemetry
2. **Local First**: All processing done locally
3. **Minimal Metadata**: Only sync necessary file info
4. **User Control**: Easy to completely disable
5. **Data Ownership**: User owns all data

## Testing Strategy

### Test Scenarios
1. Sync with no network
2. Sync with poor connection
3. Large file sync (>10MB)
4. Conflict resolution
5. Power loss during sync
6. Token expiration

### Mock Testing
```bash
# Docker test environment
docker run -it nook-writer-wifi \
    --env MOCK_WIFI=true \
    --env MOCK_SYNC=dropbox \
    /usr/local/bin/test-sync.sh
```

## Future Enhancements

### Potential Features
- P2P sync between devices
- Local network sync (no internet)
- Encryption at rest
- Collaborative editing (simple merge)
- Email documents to self

### Explicitly Not Planned
- Real-time sync (battery drain)
- Background sync (distraction)
- Web browser (scope creep)
- Cloud editing (not offline-first)
- Social features (distraction)

---

*"Even hermit scribes sometimes send letters to distant monasteries"* 📡📜

## Summary

This WiFi sync module design:
- Preserves the offline-first philosophy
- Adds optional cloud backup/sync
- Minimal RAM impact (0MB when off)
- Security and privacy focused
- Simple, writer-friendly UX
- Medieval theme consistent

The module can be developed independently and added without disrupting the core writing experience.