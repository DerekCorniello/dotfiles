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

local function parse_spotbugs_xml(xml_file, root)
  local entries = {}
  local f = io.open(xml_file, "r")
  if not f then
    return entries
  end
  local content = f:read("*a")
  f:close()

  -- SpotBugs (XStream) single-quotes attribute values, so accept both
  -- quote styles. Attrs live on the <BugInstance ...> open tag, therefore
  -- match the whole element including the tag, not just its inner XML.
  local function attr(s, name)
    return s:match(name .. '="([^"]*)"') or s:match(name .. "='([^']*)'")
  end

  for bug in content:gmatch('(<BugInstance[^>]*>.-</BugInstance>)') do
    local category = attr(bug, "category") or "UNKNOWN"
    local type = attr(bug, "type") or "Unknown"
    local priority = attr(bug, "priority") or "3"
    local line = bug:match('<SourceLine[^>]-start=["\'](%d+)') or "1"
    -- Real reports carry sourcepath=/sourcefile=, not filename=.
    local file = attr(bug, "filename") or attr(bug, "sourcepath") or ""
    local msg = bug:match('<ShortMessage>(.-)</ShortMessage>')
      or bug:match('<LongMessage>(.-)</LongMessage>')
      or (category .. ": " .. type)

    if file ~= "" then
      -- Resolve sourcepath (e.g. com/example/.../Doctor.java) against the
      -- project so :copen jumps to the right file.
      if root then
        local rel = file:gsub("^/", "")
        for _, c in ipairs({ root .. "/" .. rel, root .. "/src/main/java/" .. rel, root .. "/src/" .. rel }) do
          if vim.fn.filereadable(c) == 1 then
            file = c
            break
          end
        end
      end
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

  -- Preflight: exit 127 from jobstart just means "command not found".
  -- Surface it directly instead of a cryptic "Build failed (exit 127)".
  -- NOTE: ./mvnw and ./gradlew are resolved relative to the project root
  -- (jobstart runs with cwd=root), so check the absolute wrapper path.
  local exe_ok = false
  if tool_cmd:sub(1, 2) == "./" then
    exe_ok = vim.fn.executable(root .. "/" .. tool_cmd:sub(3)) == 1
  else
    exe_ok = vim.fn.executable(tool_cmd) == 1
  end
  if not exe_ok then
    local hint = tool_name == "mvn" and "install Maven (Arch: sudo pacman -S maven)"
      or tool_name == "mvnw" and "run: chmod +x mvnw (or install Maven)"
      or tool_name == "gradlew" and "run: chmod +x gradlew (or install Gradle)"
      or "install Gradle (Arch: sudo pacman -S gradle)"
    vim.notify(string.format("SpotBugs: '%s' not executable/found -- %s", tool_cmd, hint), vim.log.levels.ERROR)
    return
  end

  local qf_entries = {}

  if tool_name == "mvn" or tool_name == "mvnw" then
    -- NOTE: `spotbugs:spotbugs` alone does NOT compile first: on a fresh
    -- checkout target/ is empty, analysis runs against zero classes, exits 0,
    -- and the missing XML parses as "No bugs found!" (false negative).
    -- Always compile in the same invocation.
    local cmd = tool_cmd .. " compile spotbugs:spotbugs -Dspotbugs.xmlOutput=true"
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
          qf_entries = parse_spotbugs_xml(xml_path, root)
        else
          -- Build passed but no report: do NOT report "No bugs found!",
          -- the analysis likely never ran (e.g. nothing compiled).
          vim.schedule(function()
            vim.notify("SpotBugs: build passed but no report at " .. xml_path, vim.log.levels.WARN)
          end)
          return
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
          qf_entries = parse_spotbugs_xml(xml_path, root)
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
