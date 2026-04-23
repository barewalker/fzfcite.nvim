local cmd = vim.api.nvim_create_user_command

cmd("FzfciteInsert", function()
  require("fzfcite").insert_citation()
end, { desc = "Fzfcite: Insert citation key via fzf-lua" })

cmd("FzfciteOpenPdf", function(args)
  if args.args and args.args ~= "" then
    require("fzfcite").open_pdf(args.args)
  else
    require("fzfcite").open_pdf_under_cursor()
  end
end, { nargs = "?", desc = "Fzfcite: Open PDF (arg or <cword>)" })
