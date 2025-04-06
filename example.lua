--[[
Example script demonstrating the usage of FileLock module

This script shows how to use the FileLock module to safely access a shared resource.
]]

local FileLock = require("filelock")

-- Path to the lock file
local lockFile = "./example.lock"

-- Path to the shared resource (a simple counter file in this example)
local counterFile = "./counter.txt"

-- Create a new lock instance with a 5-second timeout
local lock = FileLock.new(lockFile, {timeout = 5})

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

-- Attempt to acquire the lock
print("Attempting to acquire lock...")
local success, err = lock:acquire()

if success then
    print("Lock acquired successfully")
    
    -- Read the current counter value
    local counter = readCounter()
    print("Current counter value: " .. counter)
    
    -- Increment the counter
    counter = counter + 1
    print("Incrementing counter to: " .. counter)
    
    -- Simulate some work
    print("Working...")
    os.execute("sleep 2")
    
    -- Write the new counter value
    writeCounter(counter)
    print("Counter updated")
    
    -- Release the lock
    print("Releasing lock...")
    success, err = lock:release()
    if success then
        print("Lock released successfully")
    else
        print("Failed to release lock: " .. (err or "unknown error"))
    end
else
    print("Failed to acquire lock: " .. (err or "unknown error"))
end

local pid = lock:getPid()
if pid then
    print("Process Id: " .. pid)
else
    print("Failed to get process Id")
end
print("Done")
