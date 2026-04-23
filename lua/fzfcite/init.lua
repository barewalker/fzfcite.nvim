local M = {}

function M.setup(opts)
  require("fzfcite.config").setup(opts)
end

M.insert_citation = function() require("fzfcite.pickers").insert_citation() end
M.open_pdf = function(key) require("fzfcite.core").open_pdf(key) end
M.open_pdf_under_cursor = function() require("fzfcite.core").open_pdf_under_cursor() end

return M
