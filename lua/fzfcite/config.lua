local M = {}

M.defaults = {
  ref_files = { "ref.yml", "~/refs/ref.yml" },
  pdf_dirs = { ".", "~/refs/pdfs" },
  citation = {
    prefix = "@",
    suffix = "",
    grep_pattern = "^[a-zA-Z0-9].*:$",
    extract_key = function(line)
      return line:match("^[^:]+:%d+:(.+):$")
    end,
  },
  opener = nil,
  fzf = {
    prompt = "Citations> ",
    previewer = "builtin",
    winopts = {
      height = 0.85,
      width = 0.80,
      preview = { layout = "vertical" },
    },
    open_pdf_key = "ctrl-e",
    view_ref_key = "ctrl-r",
    fzf_opts = {},
  },
}

M.options = vim.deepcopy(M.defaults)

function M.setup(user_opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, user_opts or {})

  local function expand_list(list)
    local out = {}
    for _, p in ipairs(list) do
      table.insert(out, vim.fn.expand(p))
    end
    return out
  end

  M.options.ref_files = expand_list(M.options.ref_files)
  M.options.pdf_dirs = expand_list(M.options.pdf_dirs)
end

return M
