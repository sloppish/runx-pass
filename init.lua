if (runx.api_version or 0) < 1 then
  error("Runx plugin API v1 or newer is required")
end

local function trim(value)
  return value:gsub("^%s+", ""):gsub("%s+$", "")
end

local function first_non_flag(parts)
  for _, value in ipairs(parts) do
    if value:sub(1, 1) ~= "-" then
      return value
    end
  end
  return nil
end

local function password_store_dir()
  local config = runx.plugin_config or {}
  local dir = config.store_dir
  if dir and dir ~= "" then
    return dir
  end
  return runx.home_dir() .. "/.password-store"
end

local function list_entries()
  local files = runx.walk_files(password_store_dir())
  local entries = {}

  for _, file in ipairs(files) do
    if file:match("%.gpg$") and not file:match("^%.") then
      local entry = file:gsub("%.gpg$", "")
      table.insert(entries, entry)
    end
  end

  return entries
end

local function pass_show(entry)
  return runx.exec_capture("pass", { "show", entry }, true)
end

local function pass_copy(entry)
  runx.exec_status("pass", { "show", "-c1", entry }, false)
  return "Copied password"
end

local function pass_otp(entry)
  return runx.exec_capture("pass", { "otp", entry }, true)
end

local function pass_otp_copy(entry)
  runx.exec_status("pass", { "otp", "-c", entry }, false)
  return "Copied OTP"
end

local function pass_generate(parts)
  if #parts == 0 then
    error("pass-gen needs arguments")
  end

  local command = { "generate" }
  for _, part in ipairs(parts) do
    table.insert(command, part)
  end

  runx.exec_status("pass", command, false)

  local entry = first_non_flag(parts)
  if not entry then
    error("could not infer generated pass entry")
  end

  return pass_show(entry)
end

local function pass_generate_copy(parts)
  if #parts == 0 then
    error("pass-gen-copy needs arguments")
  end

  local command = { "generate", "-c" }
  for _, part in ipairs(parts) do
    table.insert(command, part)
  end

  runx.exec_status("pass", command, false)
  return "Generated password and copied it"
end

local function result_limit()
  local config = runx.plugin_config or {}
  return tonumber(config.result_limit) or 12
end

local function score_entries(query, action_kind)
  local trimmed = trim(query)
  if trimmed == "" then
    return {}
  end

  local entries = list_entries()
  local matches = {}

  for _, entry in ipairs(entries) do
    local score = runx.fuzzy_score(entry, trimmed)
    if score > 0 then
      table.insert(matches, {
        id = action_kind .. ":" .. entry,
        title = entry,
        score = score,
        payload = {
          kind = action_kind,
          entry = entry,
        },
      })
    end
  end

  table.sort(matches, function(left, right)
    if left.score == right.score then
      return left.title < right.title
    end
    return left.score > right.score
  end)

  local limit = result_limit()
  while #matches > limit do
    table.remove(matches)
  end

  return matches
end

return {
  id = "pass",
  name = "pass",
  badge = "PASS",

  commands = {
    ["pass"] = "search_type_password",
    ["pass-copy"] = "search_copy_password",
    ["pass-otp"] = "search_type_otp",
    ["pass-otp-copy"] = "search_copy_otp",
    ["pass-gen"] = "search_generate_type",
    ["pass-gen-copy"] = "search_generate_copy",
  },

  search_type_password = function(raw)
    return score_entries(raw, "type_password")
  end,

  search_copy_password = function(raw)
    return score_entries(raw, "copy_password")
  end,

  search_type_otp = function(raw)
    return score_entries(raw, "type_otp")
  end,

  search_copy_otp = function(raw)
    return score_entries(raw, "copy_otp")
  end,

  search_generate_type = function(raw, argv)
    local trimmed = trim(raw)
    if trimmed == "" then
      return {
        {
          id = "generate_type:hint",
          title = "pass-gen <args>",
          style = "full",
          subtitle = "Run `pass generate` and type the result",
          badge = "GEN",
          score = 10,
          payload = {
            kind = "noop",
          },
        },
      }
    end

    return {
      {
        id = "generate_type:" .. trimmed,
        title = "pass-gen " .. trimmed,
        style = "full",
        subtitle = "Run `pass generate ...` and type the result",
        badge = "GEN",
        score = 1000,
        payload = {
          kind = "generate_type",
          argv = argv,
        },
      },
    }
  end,

  search_generate_copy = function(raw, argv)
    local trimmed = trim(raw)
    if trimmed == "" then
      return {
        {
          id = "generate_copy:hint",
          title = "pass-gen-copy <args>",
          style = "full",
          subtitle = "Run `pass generate -c ...`",
          badge = "GEN",
          score = 10,
          payload = {
            kind = "noop",
          },
        },
      }
    end

    return {
      {
        id = "generate_copy:" .. trimmed,
        title = "pass-gen-copy " .. trimmed,
        style = "full",
        subtitle = "Run `pass generate -c ...`",
        badge = "GEN",
        score = 1000,
        payload = {
          kind = "generate_copy",
          argv = argv,
        },
      },
    }
  end,

  run = function(payload)
    if payload.kind == "noop" then
      return "Pass generator is ready."
    end

    if payload.kind == "type_password" then
      local text = pass_show(payload.entry)
      return runx.type_text(text)
    end

    if payload.kind == "copy_password" then
      return pass_copy(payload.entry)
    end

    if payload.kind == "type_otp" then
      local text = pass_otp(payload.entry)
      return runx.type_text(text)
    end

    if payload.kind == "copy_otp" then
      return pass_otp_copy(payload.entry)
    end

    if payload.kind == "generate_type" then
      local text = pass_generate(payload.argv or {})
      return runx.type_text(text)
    end

    if payload.kind == "generate_copy" then
      return pass_generate_copy(payload.argv or {})
    end

    error("unknown pass action: " .. tostring(payload.kind))
  end,
}
