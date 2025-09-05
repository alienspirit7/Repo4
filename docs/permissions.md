# File Permission Standards

## Permission Model
- Executable scripts: 755 (rwxr-xr-x)
- Log files: 644 (rw-r--r--)
- Config files: 644 (rw-r--r--)
- Directories: 755 (rwxr-xr-x)

## Ownership
- User: $(whoami)
- Group: staff (macOS)

## Security Requirements
- Program A: read/write access to log file
- Program B: read-only access to log file  
- Other users: read access only, no write access
- Files owned by: $(whoami):staff
