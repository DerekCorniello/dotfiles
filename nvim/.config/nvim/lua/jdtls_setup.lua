local M = {}

local function mason_path(...)
  return vim.fn.stdpath("data") .. "/mason/packages/" .. table.concat({ ... }, "/")
end

local function project_name(root_dir)
  return vim.fn.fnamemodify(root_dir, ":p:h:t")
end

local function jdk_major_version(home)
  local f = io.open(home .. "/release", "r")
  if not f then
    return nil
  end
  local content = f:read("*a")
  f:close()
  local ver = content:match('JAVA_VERSION="([%d.]+)"')
  if not ver then
    return nil
  end
  return tonumber(ver:match("^1%.(%d+)") or ver:match("^(%d+)"))
end

local function jdtls_runtime_name(major)
  return major <= 8 and "JavaSE-1.8" or ("JavaSE-" .. major)
end

local function discover_java_runtimes()
  local seen_home, seen_name, runtimes = {}, {}, {}

  local function add(home)
    if not home or home == "" or seen_home[home] then
      return
    end
    seen_home[home] = true
    local major = jdk_major_version(home)
    if not major then
      return
    end
    local name = jdtls_runtime_name(major)
    if not seen_name[name] then
      seen_name[name] = true
      table.insert(runtimes, { name = name, path = home, major = major })
    end
  end

  local sdkman_java = vim.fn.expand("~/.sdkman/candidates/java")
  if vim.fn.isdirectory(sdkman_java) == 1 then
    for _, dir in ipairs(vim.fn.readdir(sdkman_java)) do
      if dir ~= "current" then
        add(sdkman_java .. "/" .. dir)
      end
    end
  end

  for _, dir in ipairs(vim.fn.glob("/usr/lib/jvm/*", false, true)) do
    if vim.fn.isdirectory(dir) == 1 then
      add(dir)
    end
  end

  table.sort(runtimes, function(a, b) return a.major < b.major end)
  for i, rt in ipairs(runtimes) do
    rt.major = nil
    rt.default = i == #runtimes
  end
  return runtimes
end

function M.setup()
  local has_spotbugs, spotbugs = pcall(require, "spotbugs")
  if has_spotbugs then
    spotbugs.setup()
  end

  local jdtls = require("jdtls")

  local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "build.gradle.kts" }
  local root_dir = require("jdtls.setup").find_root(root_markers)
  if root_dir == "" then
    return
  end

  local name = project_name(root_dir)
  local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. name

  local bundles = {}
  vim.list_extend(bundles, vim.split(
    vim.fn.glob(mason_path("java-debug-adapter", "extension", "server", "com.microsoft.java.debug.plugin-*.jar")),
    "\n"
  ))
  vim.list_extend(bundles, vim.split(
    vim.fn.glob(mason_path("java-test", "extension", "server", "*.jar")),
    "\n"
  ))
  bundles = vim.tbl_filter(function(p) return p ~= "" end, bundles)

  local capabilities = require("cmp_nvim_lsp").default_capabilities()

  local config = {
    cmd = {
      vim.fn.exepath("jdtls") ~= "" and vim.fn.exepath("jdtls") or mason_path("jdtls", "bin", "jdtls"),
      "-data", workspace_dir,
    },
    root_dir = root_dir,
    capabilities = capabilities,

    settings = {
      java = {
        eclipse = { downloadSources = true },
        maven = { downloadSources = true },
        implementationsCodeLens = { enabled = true },
        referencesCodeLens = { enabled = true },
        references = { includeDecompiledSources = true },
        inlayHints = { parameterNames = { enabled = "all" } },
        format = { enabled = true },
        signatureHelp = { enabled = true },
        completion = {
          favoriteStaticMembers = {
            "org.junit.jupiter.api.Assertions.*",
            "org.mockito.Mockito.*",
            "org.mockito.ArgumentMatchers.*",
          },
        },
        saveActions = { organizeImports = true },
        configuration = {
          runtimes = discover_java_runtimes(),
        },
      },
    },

    init_options = {
      bundles = bundles,
      extendedClientCapabilities = jdtls.extendedClientCapabilities,
    },

    on_attach = function(_, bufnr)
      local map = function(keys, func, desc)
        vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
      end

      map("<leader>jo", jdtls.organize_imports, "[J]ava [O]rganize imports")
      map("<leader>jv", jdtls.extract_variable, "[J]ava extract [V]ariable")
      map("<leader>jc", jdtls.extract_constant, "[J]ava extract [C]onstant")
      map("<leader>jm", jdtls.extract_method, "[J]ava extract [M]ethod")
      vim.keymap.set("v", "<leader>jm", function() jdtls.extract_method(true) end,
        { buffer = bufnr, desc = "[J]ava extract [M]ethod" })
      vim.keymap.set("v", "<leader>jv", function() jdtls.extract_variable(true) end,
        { buffer = bufnr, desc = "[J]ava extract [V]ariable" })
      vim.keymap.set("v", "<leader>jc", function() jdtls.extract_constant(true) end,
        { buffer = bufnr, desc = "[J]ava extract [C]onstant" })
      map("<leader>jt", jdtls.test_class, "[J]ava [T]est class")
      map("<leader>jn", jdtls.test_nearest_method, "[J]ava test [N]earest method")

      local has_spotbugs, spotbugs = pcall(require, "spotbugs")
      if has_spotbugs then
        map("<leader>js", spotbugs.run, "[J]ava [S]potBugs analysis")
      end

      jdtls.setup_dap({ hotcodereplace = "auto" })
      require("jdtls.dap").setup_dap_main_class_configs()
    end,
  }

  jdtls.start_or_attach(config)
end

return M
