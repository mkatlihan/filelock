--[[
Example script demonstrating concurrent access with multiple processes

This script shows how to use the FileLock module to handle concurrent access
from multiple processes. Run multiple instances of this script simultaneously
to see how the locking mechanism prevents concurrent access.
]]

local FileLock = require("filelock")

-- Path to the lock file
local lockFile = "./concurrent_example.lock"

-- Path to the shared resource (a simple counter file in this example)
local counterFile = "./concurrent_counter.txt"

-- Create a new lock instance with a 3-second timeout
local lock = FileLock.new(lockFile, {timeout = 3})

-- Function to read the current counter value
local function readCounter()
    local file = io.open(counterFile, "r")
    if not file then
        return 0
    end
    
    local value = tonumber(file:read("*a")) or 0
    file:close()
    return value
end

-- Function to write a new counter value
local function writeCounter(value)
    local file = io.open(counterFile, "w")
    if not file then
        error("Could not open counter file for writing")
    end
    
    file:write(tostring(value))
    file:close()
end

-- Get process ID for logging
local pid = lock:getPid()
print("[Process " .. pid .. "] Starting...")

-- Attempt to acquire the lock
print("[Process " .. pid .. "] Attempting to acquire lock...")
local success, err = lock:acquire()

if success then
    print("[Process " .. pid .. "] Lock acquired successfully")
    
    -- Read the current counter value
    local counter = readCounter()
    print("[Process " .. pid .. "] Current counter value: " .. counter)
    
    -- Increment the counter
    counter = counter + 1
    print("[Process " .. pid .. "] Incrementing counter to: " .. counter)
    
    -- Simulate some work
    print("[Process " .. pid .. "] Working...")
    os.execute("sleep 2")
    
    -- Write the new counter value
    writeCounter(counter)
    print("[Process " .. pid .. "] Counter updated")
    
    -- Release the lock
    print("[Process " .. pid .. "] Releasing lock...")
    success, err = lock:release()
    if success then
        print("[Process " .. pid .. "] Lock released successfully")
    else
        print("[Process " .. pid .. "] Failed to release lock: " .. (err or "unknown error"))
    end
else
    print("[Process " .. pid .. "] Failed to acquire lock: " .. (err or "unknown error"))
end

print("[Process " .. pid .. "] Done")
