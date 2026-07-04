vim.api.nvim_create_autocmd("User", {
  pattern = "LazyLoad",
  callback = function(args)
    if args.data ~= "nvim-dap" then
      return
    end
    local dap = require("dap")
    dap.adapters.python = {
      type = "server",
      host = "127.0.0.1",
      port = 5678,
    }
    table.insert(dap.configurations.python, {
      type = "python",
      request = "attach",
      name = "Attach to Docker (debugpy)",
      connect = {
        host = "127.0.0.1",
        port = 5678,
      },
      pathMappings = {
        {
          localRoot = vim.fn.getcwd(),
          remoteRoot = "/app",
        },
      },
    })

    dap.adapters.msedge = {
      type = "executable",
      command = "node",
      args = {
        vim.fn.stdpath("data")
          .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
        "9222",
      },
    }

    local windows_host = (function()
      local handle = io.popen("ip route show default 2>/dev/null | awk '{print $3}'")
      local ip = handle:read("*a"):gsub("%s+", "")
      handle:close()
      return ip ~= "" and ip or "host.docker.internal"
    end)()

    local edge_config = {
      type = "msedge",
      request = "attach",
      name = "Attach Edge (Windows) — Frontend",
      address = windows_host,
      port = 9222,
      url = "http://localhost:4700",
      webRoot = vim.fn.getcwd() .. "/fury",
      pathMapping = {
        ["/app"] = vim.fn.getcwd() .. "/fury",
      },
    }

    dap.configurations.typescript = dap.configurations.typescript or {}
    table.insert(dap.configurations.typescript, edge_config)

    dap.configurations.javascript = dap.configurations.javascript or {}
    table.insert(dap.configurations.javascript, edge_config)

    vim.keymap.set("n", "<leader>dd", function()
      dap.run()
    end, { desc = "DAP: Select configuration" })
  end,
})

return {}
