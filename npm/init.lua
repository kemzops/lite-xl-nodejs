-- mod-version:3

-----------------------------------------------------------------------
-- NODE JS PACKAGE MANAGER - NPM
-----------------------------------------------------------------------
-- NAME       : NPM
-- DESCRIPTION: SIMPLE NPM MODULE TO BE USED BY OTHER PLUGINS
-- AUTHOR     : Aziz Jaber (KemzoPS)
-----------------------------------------------------------------------
-- THIS FILE IS PART OF LITE-XL NODEJS DEVELOPMENT ENVIRONMENT REPO
-- https://github.com/kemzops/lite-xl-nodejs/
-----------------------------------------------------------------------
-- Note: Annotations syntax documentation which is supported by
-- https://github.com/sumneko/lua-language-server can be read here:
-- https://emmylua.github.io/annotation.html

local core = require "core"
local common = require "core.common"
local config = require "core.config"

local npm = {}

config.plugins.npm = common.merge({
    executable = "npm",
}, config.plugins.npm)

---@type string|nil
npm.version = nil
---@type string
npm.executable = config.plugins.npm.executable
---@type boolean
npm.versionCheckFailed = false

--- Check the version of npm.
local function versionCheck()
    core.add_thread(function()
        local proc = process.start({ config.plugins.npm.executable, "--version" })
        while proc:running() do
            coroutine.yield(0)
        end

        -- Check if proc:returncode() exists and is a number
        if not proc:returncode() or type(proc:returncode()) ~= "number" then
            core.error("[NPM] Error getting return code.")
            npm.versionCheckFailed = true
            return
        end

        -- Check the return code
        if proc:returncode() == 0 then
            local stdout = proc:read_stdout():gsub("\n", "")
            if not stdout or type(stdout) ~= "string" then
                core.error("[NPM] Error reading stdout.")
                npm.versionCheckFailed = true
                return
            end
            npm.version = stdout
            core.log("[NPM] v" .. npm.version)
        else
            -- Handle all cases as version check failed
            core.error("[NPM] Version check failed with exit code: " .. proc:returncode())
            npm.versionCheckFailed = true
        end
    end)
end

-- Ensures that npm is available and ready to be used by checking its version.
versionCheck()

--- Install npm packages.
--- @param params table A table containing parameters for the installation.
--- @class npm.install.params
---   @field pkgs string[] An array of package names to install.
---   @field installPath string The path where packages will be installed.
---   @field flags string[]|nil (optional) An array of flags to pass to the npm install command.
---   @field callback table|nil (optional) A table containing callback functions for success and failure events.
---     @field onSuccess function|nil (optional) A function to execute after successful installation.
---     @field onFailure function|nil (optional) A function to execute if installation fails.
function npm.install(params)
    core.add_thread(function()
        -- Extract parameters from the provided table
        local pkgs = params.pkgs
        local installPath = params.installPath
        local flags = params.flags
        local callback = params.callback

        -- Wait until npm.version is available or version check fails
        while npm.version == nil do
            if npm.versionCheckFailed == true then
                core.error("[NPM] Version is not available. Installation aborted.")

                if callback and callback.onFailure then
                    callback.onFailure()
                end

                return
            end
            coroutine.yield(0)
        end

        if not pkgs or #pkgs == 0 then
            core.error("[NPM] No packages provided. Installation aborted.")
            if callback and callback.onFailure and type(callback.onFailure) == "function" then
                callback.onFailure()
            end
            return
        end

        if not installPath then
            core.error("[NPM] Installation path is required. Installation aborted.")
            if callback and callback.onFailure and type(callback.onFailure) == "function" then
                callback.onFailure()
            end
            return
        end

        -- Construct the npm install command
        local install_cmd = { npm.executable, "install" }
        for _, pkg in ipairs(pkgs) do
            table.insert(install_cmd, pkg)
        end

        -- Add flags if provided
        if flags and #flags > 0 then
            for _, flag in ipairs(flags) do
                table.insert(install_cmd, flag)
            end
        end

        -- The path where packages will be installed (node_modules).
        table.insert(install_cmd, "--prefix")
        table.insert(install_cmd, installPath)

        -- Start the installation process
        core.log("[NPM] Installing/Updating packages: [" .. table.concat(pkgs, ", ") .. "]")
        local proc = process.start(install_cmd)
        while proc:running() do
            coroutine.yield(0)
        end

        -- Check the return code
        if proc:returncode() == 0 then
            core.log("[NPM] Packages installed/updated successfully.")
            if callback and callback.onSuccess then
                callback.onSuccess()
            end
        else
            core.error("[NPM] Package installation failed.")
            -- Log detailed error message if available
            local stderr = proc:read_stderr()
            if stderr and #stderr > 0 then
                core.error("[NPM] Error details: " .. stderr)
            end
            if callback and callback.onFailure then
                callback.onFailure()
            end
        end
    end)
end

--- Execute an npm package with the provided flags with npx
--- @param params table A table containing parameters for the execution.
--- @class npm.exec.params
---   @field pkg string The name of the package to execute.
---   @field flags string[]|nil (optional) An array of flags to pass to the npm package.
---   @field callback table|nil (optional) A table containing callback functions for success and failure.
---     @field onSuccess function|nil (optional) A function to execute if the package execution succeeds.
---     @field onFailure function|nil (optional) A function to execute if the package execution fails.
function npm.exec(params)
    core.add_thread(function()
        -- Extract parameters from the provided table
        local pkg = params.pkg
        local flags = params.flags
        local callback = params.callback

        -- WORK ON PROGRESS

    end)
end

return npm
