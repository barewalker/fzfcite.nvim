local M = {}

function M.insert_citation()
  local ok, fzf = pcall(require, "fzf-lua")
  if not ok then
    vim.notify("[fzfcite] fzf-lua is required", vim.log.levels.ERROR)
    return
  end

  local core = require("fzfcite.core")
  local opts = require("fzfcite.config").options

  local ref_file = core.find_ref_file()
  if not ref_file then
    vim.notify("[fzfcite] ref file not found in configured ref_files", vim.log.levels.WARN)
    return
  end

  local cmd = string.format("grep -H -n %s %s",
    vim.fn.shellescape(opts.citation.grep_pattern),
    vim.fn.shellescape(ref_file))

  local extract = opts.citation.extract_key

  local function parse_location(line)
    local file, lnum = line:match("^([^:]+):(%d+):")
    return file, tonumber(lnum)
  end

  local actions = {
    ["default"] = function(selected)
      if selected and selected[1] then
        local key = extract(selected[1])
        if key then
          core.insert_citation(key)
        end
      end
    end,
  }

  if opts.fzf.open_pdf_key and opts.fzf.open_pdf_key ~= "" then
    actions[opts.fzf.open_pdf_key] = function(selected)
      if selected and selected[1] then
        local key = extract(selected[1])
        if key then
          core.open_pdf(key)
        end
      end
    end
  end

  if opts.fzf.view_ref_key and opts.fzf.view_ref_key ~= "" then
    actions[opts.fzf.view_ref_key] = function(selected)
      if selected and selected[1] then
        local file, lnum = parse_location(selected[1])
        core.open_ref_at(file, lnum)
      end
    end
  end

  fzf.fzf_exec(cmd, {
    prompt = opts.fzf.prompt,
    previewer = opts.fzf.previewer,
    actions = actions,
    winopts = opts.fzf.winopts,
  })
end

return M
