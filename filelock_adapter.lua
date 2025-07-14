-- Dependencies
local FileLock = require("filelock")

-- ANSI Color adapter
local color_codes = {
  reset = "\27[0m", red = "\27[31m", green = "\27[32m",
  yellow = "\27[33m", blue = "\27[34m", cyan = "\27[36m"
}

function colortxt(text, color)
  local code = color_codes[color] or color_codes.reset
  return code .. text .. color_codes.reset
end

-- Lock management
function wait_for_lock(TXPID, TXLOCKFILE)
  local lock = FileLock.new(TXLOCKFILE, {
    timeout = 0,
    staleLockTimeout = 60
  })

  local delay = 1

  while true do
    if lock:isStale() then
      local success, err = lock:removeStale()
      if success then
        print(colortxt(string.format("PID-%s: Stale lock removed", TXPID), "red"))
      end
    end

    local success, err = lock:acquire()
    if success then
      print(colortxt(string.format("PID-%s: Acquired %s", TXPID, TXLOCKFILE), "yellow"))

      local lockInfo = lock:_readLockFile()
      if lockInfo and lockInfo.lockId == lock.lockId then
        return lock
      else
        print(colortxt(string.format("PID-%s: Lock verification failed, retrying", TXPID), "red"))
      end
    end

    print(colortxt(string.format("PID-%s: Waiting for lock for %s secs", TXPID, delay), "red"))
    os.execute("sleep " .. tostring(delay))
    delay = math.min(delay * 2, 10)
  end
end

function release_lock(lock, TXPID, TXLOCKFILE)
  if lock then
    local success, err = lock:release()
    if success then
      print(colortxt(string.format("PID-%s: Released %s", TXPID, TXLOCKFILE), "green"))
    else
      print(colortxt(string.format("PID-%s: Failed to release %s: %s", TXPID, TXLOCKFILE, err), "red"))
    end
  end
end

-- Optional high-level runner
function perform_locked_task(TXPID, TXLOCKFILE)
  local lock = wait_for_lock(TXPID, TXLOCKFILE)

  -- Simulated task
  print(colortxt(string.format("PID-%s: Performing critical operation...", TXPID), "blue"))
  os.execute("sleep 2")

  release_lock(lock, TXPID, TXLOCKFILE)
end

--[[ 
-- Use case:
-- Simulated transactional log update using locking adapter
local TXPID = tostring(os.time())  -- Simulated unique PID
local TXLOCKFILE = "/tmp/txlog.lock"
local TXLOG = "/tmp/txlog.db"

-- Start the locked operation
local lock = wait_for_lock(TXPID, TXLOCKFILE)

-- Critical section: safely write to TXLOG
local f = io.open(TXLOG, "a")
if f then
  local entry = string.format("[%s] PID-%s committed transaction\n", os.date(), TXPID)
  f:write(entry)
  f:close()
  print(colortxt(string.format("PID-%s: Log updated successfully", TXPID), "cyan"))
else
  print(colortxt(string.format("PID-%s: Failed to open log file", TXPID), "red"))
end

-- Release the lock
release_lock(lock, TXPID, TXLOCKFILE)
]]