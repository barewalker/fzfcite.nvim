local M = {}

local function resolve_path(p)
  if p:sub(1, 1) == "/" or p:sub(1, 1) == "~" then
    return vim.fn.expand(p)
  end
  return vim.fn.getcwd() .. "/" .. p
end

function M.find_ref_file()
  local opts = require("fzfcite.config").options
  for _, candidate in ipairs(opts.ref_files) do
    local path = resolve_path(candidate)
    if vim.fn.filereadable(path) == 1 then
      return path
    end
  end
  return nil
end

function M.find_pdf(filename)
  local opts = require("fzfcite.config").options
  for _, dir in ipairs(opts.pdf_dirs) do
    local base = resolve_path(dir)
    local path = base .. "/" .. filename
    if vim.fn.filereadable(path) == 1 then
      return path
    end
  end
  return nil
end

function M.default_opener()
  if vim.fn.has("mac") == 1 then
    return "open"
  elseif vim.fn.has("wsl") == 1 then
    return "wslview"
  else
    return "xdg-open"
  end
end

function M.strip_prefix(key)
  local opts = require("fzfcite.config").options
  local prefix = opts.citation.prefix or ""
  local suffix = opts.citation.suffix or ""
  if prefix ~= "" and key:sub(1, #prefix) == prefix then
    key = key:sub(#prefix + 1)
  end
  if suffix ~= "" and key:sub(-#suffix) == suffix then
    key = key:sub(1, -#suffix - 1)
  end
  return key
end

function M.open_pdf(key)
  if not key or key == "" then
    return
  end
  key = M.strip_prefix(key)
  local filename = key .. ".pdf"
  local found = M.find_pdf(filename)
  if not found then
    vim.notify("[fzfcite] PDF not found: " .. filename, vim.log.levels.ERROR)
    return
  end
  local opts = require("fzfcite.config").options
  local cmd = opts.opener or M.default_opener()
  vim.notify("[fzfcite] Opening: " .. filename, vim.log.levels.INFO)
  vim.fn.jobstart({ cmd, found }, { detach = true })
end

function M.open_pdf_under_cursor()
  local word = vim.fn.expand("<cword>")
  M.open_pdf(word)
end

function M.insert_citation(key)
  local opts = require("fzfcite.config").options
  local prefix = opts.citation.prefix or ""
  local suffix = opts.citation.suffix or ""
  local text = prefix .. key .. suffix

  local ok = pcall(vim.api.nvim_put, { text }, "c", true, true)
  if not ok then
    vim.fn.setreg("+", text)
    vim.fn.setreg('"', text)
    vim.notify("[fzfcite] Buffer not writable — copied to clipboard: " .. text,
      vim.log.levels.INFO)
  end
end

function M.open_ref_at(ref_file, lnum)
  if not ref_file or not lnum then
    return
  end
  vim.cmd(string.format("edit +%d %s", lnum, vim.fn.fnameescape(ref_file)))
end

return M
