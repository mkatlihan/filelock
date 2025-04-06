# FileLock - Pure Lua 5.1 File Locking Mechanism

A portable file locking mechanism for Lua 5.1 that prevents different processes or threads from reading from a shared data source simultaneously. This implementation is written in pure Lua 5.1 with no external dependencies.

## Features

- Pure Lua 5.1 implementation with no external dependencies
- Portable across different operating systems (Linux, macOS, Windows)
- Simple API for acquiring and releasing locks
- Automatic stale lock detection and removal
- Configurable timeout and retry behavior
- Comprehensive documentation and examples

## Installation

Simply copy the `filelock.lua` file to your project or to your Lua modules directory.

## Usage

### Basic Usage

```lua
local FileLock = require("filelock")

-- Create a new lock instance
local lock = FileLock.new("/path/to/lockfile")

-- Attempt to acquire the lock
local success, err = lock:acquire()
if success then
    -- Lock acquired, perform operations on shared resource
    print("Lock acquired, performing operations...")
    
    -- Release the lock when done
    lock:release()
else
    -- Failed to acquire lock
    print("Could not acquire lock: " .. (err or "unknown error"))
end
```

### With Timeout

```lua
local FileLock = require("filelock")

-- Create a new lock instance with a 5-second timeout
local lock = FileLock.new("/path/to/lockfile", {timeout = 5})

-- Attempt to acquire the lock (will wait up to 5 seconds)
local success, err = lock:acquire()
if success then
    -- Lock acquired, perform operations on shared resource
    print("Lock acquired, performing operations...")
    
    -- Release the lock when done
    lock:release()
else
    -- Failed to acquire lock after waiting
    print("Could not acquire lock after waiting: " .. (err or "unknown error"))
end
```

### Stale Lock Detection

```lua
local FileLock = require("filelock")

-- Create a new lock instance with custom stale lock timeout (30 seconds)
local lock = FileLock.new("/path/to/lockfile", {staleLockTimeout = 30})

-- Check if a lock is stale
if lock:isStale() then
    print("Lock is stale, removing...")
    lock:removeStale()
end

-- Attempt to acquire the lock
local success, err = lock:acquire()
if success then
    -- Lock acquired, perform operations on shared resource
    print("Lock acquired, performing operations...")
    
    -- Release the lock when done
    lock:release()
end
```

## API Reference

### FileLock.new(lockFile, options)

Creates a new FileLock instance.

**Parameters:**
- `lockFile` (string): Path to the lock file
- `options` (table, optional): Configuration options:
  - `timeout` (number): Maximum time to wait for a lock in seconds (0 = no wait, default)
  - `staleLockTimeout` (number): Time after which a lock is considered stale in seconds (default: 60)
  - `retryDelay` (number): Delay between retry attempts in seconds (default: 0.1)

**Returns:**
- A new FileLock instance

### lock:acquire()

Attempts to acquire the lock. If the lock is already held by another process, this method will:
1. Check if the lock is stale and remove it if it is
2. Wait up to the configured timeout to acquire the lock
3. Return false if the lock cannot be acquired

**Returns:**
- `success` (boolean): Whether the lock was acquired successfully
- `error` (string, optional): Error message if the lock could not be acquired

### lock:release()

Releases the lock if it is held by the current process.

**Returns:**
- `success` (boolean): Whether the lock was released successfully
- `error` (string, optional): Error message if the lock could not be released

### lock:isLocked()

Checks if the lock is currently held by any process.

**Returns:**
- `locked` (boolean): Whether the lock is currently held

### lock:isStale()

Checks if the lock is stale. A lock is considered stale if:
1. The process ID in the lock file no longer exists, or
2. The lock has been held for longer than the configured stale lock timeout

**Returns:**
- `stale` (boolean): Whether the lock is stale

### lock:removeStale()

Removes a stale lock.

**Returns:**
- `success` (boolean): Whether the stale lock was removed successfully
- `error` (string, optional): Error message if the stale lock could not be removed

### lock:getPid()

Gets the process ID of the current process.

**Returns:**
- `pid` (string): Process ID

## How It Works

The FileLock module uses a lock file to coordinate access to shared resources. When a process wants to acquire a lock, it:

1. Checks if the lock file exists
2. If it exists, reads the process ID and timestamp from the file
3. Checks if the lock is stale (process no longer exists or timeout exceeded)
4. If the lock is stale, removes it and creates a new lock file
5. If the lock is not stale, waits or returns failure depending on configuration
6. If the lock file doesn't exist, creates it with the current process ID and timestamp

The lock file contains:
- The process ID of the locking process
- The timestamp when the lock was acquired

## Platform Compatibility

The FileLock module is designed to work on:
- Linux
- macOS
- Windows

It uses platform-specific commands to get the process ID and check if a process is running, with fallbacks for cross-platform compatibility.

## License

MIT License

## Author

Manus AI (2025)
