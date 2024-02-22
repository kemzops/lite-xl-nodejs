-- mod-version:3

-- THIS SCRIPT IS PART OF NODEJS DEVELOPMENT ENVIRONMENT REPO
-- https://github.com/kemzops/lite-xl-nodejs/

-- LSP_QUICKLINTJS
-- LSP/LINTING SUPPORT FOR JAVASCRIPT/TYPESCRIPT VIA QUICK-LINT-JS - INSTALLED & UPDATED USING NODEJS/NPM

local core = require "core"
local lsp = require "plugins.lsp"
local common = require "core.common"
local config = require "core.config"

-- PLUGIN RELATED VARIABLES
local pluginName = "lsp_quicklintjs"
local pluginDirName = "lsp_quicklintjs"
local pluginDirPath = USERDIR .. PATHSEP .. "plugins" .. PATHSEP .. pluginDirName .. PATHSEP

-- NODE/NPM/Package RELATED VARIABLES
local packageName = "quick-lint-js"
local binaryName = "quick-lint-js.exe" -- LINUX & WINDOWS & DARWIN (node_modules/quick-lint-js/preinstall.js)
local nodeModule =  pluginDirPath .. "node_modules" .. PATHSEP .. packageName .. PATHSEP
local executionCommand = { nodeModule .. binaryName, "--lsp-server" }

-- THIS PROCESS WILL RUN EVEN IF THE MODULE IS INSTALLED TO MAKE SURE ITS UP-TO-DATE
-- IF THERE IS A NEW UPDATE FOR THE MODULE, NPM WILL AUTOMATICALLY INSTALL THE NEW VERSION (FOLLOWING THE RULES OF PACKAGE.JSON)
-- IF THERE IS NO NEW UPDATE, NPM WILL SKIP & EXIT WITHOUT INSTALLING THE MODULE AGAIN (NO NEED TO).
core.add_thread(function()
  -- THE MAIN NPM PROCESS (EDIT THE FLAGS TO SUIT THE PACKAGE)
  local proc = process.start ({ "npm", "install", packageName, "--save-dev", "--save-exact", "--prefix", pluginDirPath })
  core.log("[NPM] Installing/Updating " .. packageName)
  while proc:running() do
    coroutine.yield()
  end
  core.log("[NPM] " .. packageName .. " Up to date & Ready to be used.")

  lsp.add_server(common.merge({
    name = pluginName,
    language = "javascript",
    file_patterns = { "%.js$", "%.mjs$", "%.cjs$" },
    command = executionCommand,
    id_not_extension = true,
    verbose = true
  }, config.plugins[pluginName] or {}))

  lsp.start_servers() -- TO MAKE SURE THE LSP WILL BE STARTED IF ITS NOT INSTALLED ON THE FIRST LAUNCH OR FAILED TO START
end)
