--[[
Example script demonstrating stale lock detection and removal

This script shows how to detect and remove stale locks using the FileLock module.
]]

local FileLock = require("filelock")

-- Path to the lock file
local lockFile = "./stale_example.lock"

-- Create a fake stale lock file
local function createStaleLock()
    print("Creating a fake stale lock file...")
    local file = io.open(lockFile, "w")
    if file then
        -- Use a non-existent PID
        file:write("999999999\n")
        -- Use a timestamp from an hour ago
        file:write(tostring(os.time() - 3600) .. "\n")
        file:close()
        print("Fake stale lock created")
    else
        print("Failed to create fake stale lock file")
    end
end

-- Create a new lock instance with a short stale lock timeout
local lock = FileLock.new(lockFile, {staleLockTimeout = 10})

-- Create a fake stale lock
createStaleLock()

-- Check if the lock is stale
print("\nChecking if lock is stale...")
if lock:isStale() then
    print("Lock is correctly detected as stale")
else
    print("Lock is not detected as stale (unexpected)")
    os.exit(1)
end

-- Remove the stale lock
print("\nRemoving stale lock...")
local success, err = lock:removeStale()
if success then
    print("Stale lock removed successfully")
else
    print("Failed to remove stale lock: " .. (err or "unknown error"))
    os.exit(1)
end

-- Acquire the lock after removing the stale lock
print("\nAttempting to acquire lock after removing stale lock...")
success, err = lock:acquire()
if success then
    print("Lock acquired successfully")
    
    -- Release the lock
    print("\nReleasing lock...")
    success, err = lock:release()
    if success then
        print("Lock released successfully")
    else
        print("Failed to release lock: " .. (err or "unknown error"))
    end
else
    print("Failed to acquire lock: " .. (err or "unknown error"))
end

print("Done")
