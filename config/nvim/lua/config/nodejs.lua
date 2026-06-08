-- Node.js configuration for Neovim
-- This ensures Neovim uses the SYSTEM Node.js, not project-specific versions
-- This prevents issues when working with old projects that use Node < 18

local M = {}

-- Function to get system Node.js path (avoiding project-specific versions)
local function get_system_node()
  -- Priority order for system Node.js (avoiding project overrides)
  --local mise_expanded = vim.fn.glob("~/.local/share/mise/installs/node/latest/bin/node", false, true, true)

  --if type(mise_expanded) == "table" and #mise_expanded > 0 then
    -- Ordenamos de mayor a menor para asegurar que agarre tu Node global
  --  table.sort(mise_expanded, function(a, b)
  --    return a > b
  --  end)
  --  if vim.fn.executable(mise_expanded[1]) == 1 then
  --    return mise_expanded[1] -- Retorna la ruta física absoluta de tu Node v26
  --  end
  --end

  local system_paths = {
    vim.fn.expand("~/.local/share/mise/installs/node/latest/bin/node"),
    vim.fn.expand("~/.nvm/versions/node/*/bin/node"), -- NVM default version
    "/usr/bin/node", -- System default,
  }

  -- First try to find a system Node.js directly
  for _, path in ipairs(system_paths) do
    -- Handle glob patterns (for nvm)
    if path:match("%*") then
      local expanded = vim.fn.glob(path, false, true, true)
      if type(expanded)=="table" and #expanded > 0 then
        -- Get the latest version from nvm
        table.sort(expanded, function(a, b)
          return a > b
        end)
        path = expanded[1]
      else
        goto continue
      end
    end

    if vim.fn.executable(path) == 1 then
      return path
    end

    ::continue::
  end

  -- Fallback to whatever is in PATH (but warn if it might be project-specific)
  return vim.fn.exepath("node")
end

-- Fnction to setup Node.js for Neovim
local function setup_nodejs()
  -- Get system Node.js, avoiding project-specific versions
  local node_path = get_system_node()

  if node_path ~= "" then
    local version_output = vim.fn.system(node_path .. " --version 2>/dev/null")
    if vim.v.shell_error == 0 then
      -- Clean version string: remove newlines, ANSI escape codes, and 'v' prefix
      local version = version_output
        :gsub("\r", "") -- Remove carriage returns
        :gsub("\n", "") -- Remove newlines
        :gsub("\27%[[%d;]*%a", "") -- Remove ANSI escape sequences
        :gsub("^v", "") -- Remove 'v' prefix
        :match("(%d+%.%d+%.%d+)") -- Extract version number pattern

      if version then
        local major_version = tonumber(version:match("^(%d+)"))

        if major_version and major_version >= 18 then
          -- Set the Node.js host program
          vim.g.node_host_prog = node_path

          -- Set npm path
          local npm_path = vim.fn.exepath("npm")
          if npm_path ~= "" then
            vim.g.npm_host_prog = npm_path
          end

          if vim.g.debug_nodejs or vim.env.DEBUG_NODEJS then
            print("✓ Node.js for Neovim: " .. node_path .. " (v" .. version .. ")")

            -- Detect which manager is being used
            if node_path:match("%.nvm/") then
              print("  Using NVM-managed Node.js")
            elseif node_path:match("~/.local/share/mise/installs/node/*/bin/node") then
              print("Using Mise-managed Node.js")
            else
              print("  Using system Node.js")
            end
          end

          return true, version
        else
          -- Provide specific upgrade instructions based on the detected manager
          local upgrade_msg = "⚠️  Node.js version "
            .. version
            .. " is too old. Neovim requires v18+ (v22+ recommended).\n\n"

          if node_path:match("%.nvm/") then
            upgrade_msg = upgrade_msg .. "To upgrade with NVM:\n  nvm install --lts\n  nvm alias default lts/*"
          elseif node_path:match("~/.local/share/mise") then
            upgrade_msg = upgrade_msg .. "To upgrade with Mise:\n  mise use --global node@latest"
          else
            upgrade_msg = upgrade_msg .. "Please upgrade Node.js to v18 or higher using your package manager."
          end

          upgrade_msg = upgrade_msg .. "\n\nNote: Neovim uses the SYSTEM Node.js, not project-specific versions."

          vim.notify(upgrade_msg, vim.log.levels.WARN)
          vim.g.node_host_prog = node_path
          return true, version
        end
      else
        -- Handle case where version parsing failed
        vim.notify(
          "⚠️  Could not parse Node.js version from: "
            .. version_output
            .. "\nPlease ensure Node.js is properly installed.",
          vim.log.levels.ERROR
        )
        return false, nil
      end
    end
  end

  vim.notify(
    "⚠️ Node.js no encontrado! Instálalo usando tu gestor: 'mise use --global node@latest'",
    vim.log.levels.ERROR
  )
  return false, nil
end

-- Function to check if we're using a recent Node.js version
local function check_node_version()
  if not vim.g.node_host_prog then
    return
  end

  local version_output = vim.fn.system(vim.g.node_host_prog .. " --version 2>/dev/null")
  if vim.v.shell_error ~= 0 then
    return
  end

  local version = version_output:gsub("\n", ""):gsub("v", "")
  local major_version = tonumber(version:match("^(%d+)"))

  if major_version then
    if major_version >= 18 and major_version < 22 then
      if vim.g.debug_nodejs then
        vim.notify(
          "ℹ️  Node.js v" .. version .. " works but v22+ is recommended for optimal performance.",
          vim.log.levels.INFO
        )
      end
    elseif major_version < 18 then
      vim.notify(
        "⚠️  Node.js version " .. version .. " is too old. Neovim requires v18+ (v22+ recommended).",
        vim.log.levels.WARN
      )
    end
  end
end

-- Main setup function
function M.setup(opts)
  opts = opts or {}

  -- Setup Node.js
  local success, version = setup_nodejs()

  if success and not opts.silent then
    check_node_version()
  end

  return success
end

-- Function to get current Node.js info
function M.info()
  if not vim.g.node_host_prog then
    print("Node.js: Not configured")
    return
  end

  local version_output = vim.fn.system(vim.g.node_host_prog .. " --version 2>/dev/null")
  if vim.v.shell_error ~= 0 then
    print("Node.js: Error getting version")
    return
  end

  local version = version_output:gsub("\n", ""):gsub("v", "")
  print("Node.js for Neovim: " .. vim.g.node_host_prog .. " (v" .. version .. ")")

  -- Detect source
  if vim.g.node_host_prog:match("%.nvm/") then
    print("Source: NVM-managed")
  elseif vim.g.node_host_prog:match("%.local/share/mise/") then
    print("Source: Mise-managed")
  else
    print("Source: System")
  end

  if vim.g.npm_host_prog then
    print("npm: " .. vim.g.npm_host_prog)
  end

  if vim.g.debug_nodejs then
    print("\nPATH: " .. (vim.env.PATH or "not set"))
  end
end

-- Command to manually refresh Node.js configuration
vim.api.nvim_create_user_command("NodeRefresh", function()
  M.setup({ silent = false })
  M.info()
end, { desc = "Refresh Node.js configuration" })

-- Command to show Node.js info
vim.api.nvim_create_user_command("NodeInfo", function()
  M.info()
end, { desc = "Show Node.js configuration info" })

-- Command to debug Node.js PATH issues
vim.api.nvim_create_user_command("NodeDebug", function()
  vim.g.debug_nodejs = true
  print("=== Node.js Debug Mode Enabled ===")
  M.setup({ silent = false })
  M.info()
  print("=== End Debug Info ===")
  vim.g.debug_nodejs = false
end, { desc = "Debug Node.js configuration and PATH" })

return M