-- Wait for lock with exponential backoff using FileLock module
function wait_for_lock()
  local FileLock = require("filelock")
  
  -- Create a lock instance with a long timeout to allow for exponential backoff
  local lock = FileLock.new(TXLOCKFILE, {
    -- We'll handle the timeout manually with exponential backoff
    timeout = 0,
    -- Use the same stale lock detection as the original system
    staleLockTimeout = 60 -- Adjust this value as needed
  })
  
  local delay = 1  -- Initial delay in seconds
  
  while true do
    -- Check if lock is stale and remove it if necessary
    if lock:isStale() then
      local success, err = lock:removeStale()
      if success then
        printf("%s\n", colortxt(sprintf("PID-%s: Stale lock removed", TXPID), "red"))
      end
    end
    
    -- Try to acquire the lock
    local success, err = lock:acquire()
    
    if success then
      local cmd = colortxt(sprintf("PID-%s: Acquired %s", TXPID, TXLOCKFILE), "yellow")
      printf2("%s\n", cmd)
      return lock -- Return the lock object instead of file pointer
    else
      -- Failed to acquire lock, wait with exponential backoff
      printf2("%s\n", colortxt(sprintf("PID-%s: Waiting for lock for %s secs", TXPID, delay), "red"))
      sleep(delay)
      delay = math.min(delay * 2, 10)  -- Exponential backoff, capped at 10 seconds
    end
  end
end

-- Function to release the lock
function release_lock(lock)
  if lock then
    local success, err = lock:release()
    if success then
      printf2("%s\n", colortxt(sprintf("PID-%s: Released %s", TXPID, TXLOCKFILE), "green"))
    else
      printf2("%s\n", colortxt(sprintf("PID-%s: Failed to release %s: %s", TXPID, TXLOCKFILE, err), "red"))
    end
  end
end

--[[
Usage example:

-- Acquire lock with exponential backoff
local lock = wait_for_lock()

-- Do your work with the shared resource
-- ...

-- Release the lock when done
release_lock(lock)
]]
