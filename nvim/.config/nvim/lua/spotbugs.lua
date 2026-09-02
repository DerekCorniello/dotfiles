local M = {}

local function find_project_root()
  local markers = { "pom.xml", "build.gradle", "build.gradle.kts", ".git", "mvnw", "gradlew" }
  return vim.fs.root(0, markers) or vim.fn.getcwd()
end

local function detect_build_tool(root)
  if vim.fn.filereadable(root .. "/mvnw") == 1 then
    return "mvnw", "./mvnw"
  end
  if vim.fn.filereadable(root .. "/gradlew") == 1 then
    return "gradlew", "./gradlew"
  end
  if vim.fn.filereadable(root .. "/pom.xml") == 1 then
    return "mvn", "mvn"
  end
  if vim.fn.filereadable(root .. "/build.gradle") == 1 or vim.fn.filereadable(root .. "/build.gradle.kts") == 1 then
    return "gradle", "gradle"
  end
  return nil, nil
end

local function parse_spotbugs_xml(xml_file)
  local entries = {}
  local f = io.open(xml_file, "r")
  if not f then
    return entries
  end
  local content = f:read("*a")
  f:close()

  for bug in content:gmatch('<BugInstance[^>]*>(.-)</BugInstance>') do
    local category = bug:match('category="([^"]*)"') or "UNKNOWN"
    local type = bug:match('type="([^"]*)"') or "Unknown"
    local priority = bug:match('priority="([^"]*)"') or "3"
    local line = bug:match('<SourceLine[^>]*start="(%d+)"') or "1"
    local file = bug:match('<SourceLine[^>]*([^>]* filename="([^"]*)")') or ""
    if file == "" then
      file = bug:match('filename="([^"]*)"') or ""
    end
    local msg = bug:match('<ShortMessage>(.-)</ShortMessage>')
      or bug:match('<LongMessage>(.-)</LongMessage>')
      or (category .. ": " .. type)

    if file ~= "" then
      table.insert(entries, {
        filename = file,
        lnum = tonumber(line) or 1,
        text = string.format("[%s] %s (priority: %s)", category, msg, priority),
        type = "W",
      })
    end
  end

  return entries
end

function M.run()
  local root = find_project_root()
  local tool_name, tool_cmd = detect_build_tool(root)

  if not tool_name then
    vim.notify("SpotBugs: No Maven or Gradle project found", vim.log.levels.ERROR)
    return
  end

  local qf_entries = {}

  if tool_name == "mvn" or tool_name == "mvnw" then
    local cmd = tool_cmd .. " spotbugs:spotbugs -Dspotbugs.xmlOutput=true"
    vim.notify("SpotBugs: Running via " .. tool_name .. "...", vim.log.levels.INFO)
    vim.fn.jobstart(cmd, {
      cwd = root,
      on_exit = function(_, exit_code)
        if exit_code ~= 0 then
          vim.schedule(function()
            vim.notify("SpotBugs: Build failed (exit " .. exit_code .. ")", vim.log.levels.ERROR)
          end)
          return
        end
        local xml_path = root .. "/target/spotbugsXml.xml"
        if vim.fn.filereadable(xml_path) == 1 then
          qf_entries = parse_spotbugs_xml(xml_path)
        end
        vim.schedule(function()
          if #qf_entries == 0 then
            vim.notify("SpotBugs: No bugs found!", vim.log.levels.INFO)
          else
            vim.fn.setqflist(qf_entries, "r")
            vim.cmd("copen")
            vim.notify(string.format("SpotBugs: Found %d issue(s)", #qf_entries), vim.log.levels.WARN)
          end
        end)
      end,
    })
  elseif tool_name == "gradle" or tool_name == "gradlew" then
    local task = "spotbugsMain"
    if vim.fn.isdirectory(root .. "/src/test/java") == 1 then
      task = "spotbugsTest"
    end
    vim.notify("SpotBugs: Running via " .. tool_name .. "...", vim.log.levels.INFO)
    vim.fn.jobstart(tool_cmd .. " " .. task, {
      cwd = root,
      on_exit = function(_, exit_code)
        local report_dir = root .. "/build/reports/spotbugs"
        local xml_path = report_dir .. "/main.xml"
        if vim.fn.filereadable(xml_path) == 1 then
          qf_entries = parse_spotbugs_xml(xml_path)
        end
        vim.schedule(function()
          if #qf_entries == 0 then
            vim.notify("SpotBugs: No bugs found!", vim.log.levels.INFO)
          else
            vim.fn.setqflist(qf_entries, "r")
            vim.cmd("copen")
            vim.notify(string.format("SpotBugs: Found %d issue(s)", #qf_entries), vim.log.levels.WARN)
          end
        end)
      end,
    })
  end
end

function M.setup()
  vim.api.nvim_create_user_command("SpotBugs", function()
    M.run()
  end, { desc = "Run SpotBugs on current project" })
end

return M
