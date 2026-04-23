# fzfcite.nvim

A lightweight citation picker for Neovim, powered by [`fzf-lua`](https://github.com/ibhagwan/fzf-lua).

Keep your bibliography as a plain YAML (or any grep-friendly) file, then insert citation keys and open attached PDFs from Neovim in a couple of keystrokes. No Zotero, no SQLite, no background daemons.

Designed for lightweight Typst / Markdown / plain-text writing workflows.

## Features

- Insert `@citekey` (or any configurable format) via `fzf-lua`.
- Open the PDF associated with a citation key — either from the picker (`ctrl-e` by default) or directly from the citation key under the cursor.
- Jump into the ref file at the selected entry (`ctrl-r` by default) to read the full bibliography block.
- Configurable ref-file and PDF search paths (first match wins).
- Configurable citation prefix/suffix (supports `@key`, `[@key]`, `{key}`, etc.).
- Configurable grep pattern and key extractor for custom bibliography formats.
- Falls back to the system clipboard when the current buffer is not writable (e.g. dashboards).

## Requirements

- Neovim 0.9+
- [`ibhagwan/fzf-lua`](https://github.com/ibhagwan/fzf-lua)
- `grep` (POSIX)
- A PDF viewer invoked via `xdg-open` / `wslview` / `open` (override with `opener`)

## Installation

### lazy.nvim

```lua
{
  "barewalker/fzfcite.nvim",
  dependencies = { "ibhagwan/fzf-lua" },
  ft = { "typst", "markdown", "yaml" },
  config = function()
    require("fzfcite").setup({
      -- your settings
    })
  end,
}
```

## Default configuration

```lua
require("fzfcite").setup({
  -- First readable path wins. Relative paths are resolved against cwd.
  ref_files = { "ref.yml", "~/refs/ref.yml" },

  -- PDFs are looked up as `<key>.pdf` in these directories, in order.
  pdf_dirs  = { ".", "~/refs/pdfs" },

  citation = {
    prefix = "@",    -- inserted before the key
    suffix = "",     -- inserted after the key

    -- grep pattern passed to `grep -H -n` against the ref file.
    -- Default matches top-level YAML keys (e.g. `smith2020:`).
    grep_pattern = "^[a-zA-Z0-9].*:$",

    -- Parse one line of `grep -H -n` output and return the citation key.
    extract_key = function(line)
      return line:match("^[^:]+:%d+:(.+):$")
    end,
  },

  -- nil = auto-detect: `open` on macOS, `wslview` on WSL, else `xdg-open`.
  opener = nil,

  fzf = {
    prompt    = "Citations> ",
    previewer = "builtin",
    winopts   = {
      height  = 0.85,
      width   = 0.80,
      preview = { layout = "vertical" },
    },
    -- Key in the picker that opens the PDF instead of inserting.
    open_pdf_key = "ctrl-e",
    -- Key in the picker that opens the ref file at the selected entry.
    view_ref_key = "ctrl-r",
    -- Forwarded as-is to the underlying fzf binary via fzf-lua.
    -- Useful for custom `--bind` entries, e.g. to make ctrl-h behave as
    -- backspace inside the prompt (otherwise fzf-lua may steal it for
    -- window navigation):
    --   fzf_opts = { ["--bind"] = "ctrl-h:backward-delete-char" },
    fzf_opts = {},
  },
})
```

## Commands

| Command | Description |
|---|---|
| `:FzfciteInsert` | Open the fzf-lua picker to insert a citation. `<Enter>` inserts (falls back to clipboard if the buffer is not writable), `ctrl-e` opens the PDF, `ctrl-r` opens the ref file at the selected entry. |
| `:FzfciteOpenPdf [key]` | Open the PDF for `[key]`, or for the `<cword>` under the cursor if no argument is given. |

## Example keymaps

```lua
vim.keymap.set("n", "<leader>ci", "<cmd>FzfciteInsert<CR>",  { desc = "Citation: Insert" })
vim.keymap.set("n", "<leader>cp", "<cmd>FzfciteOpenPdf<CR>", { desc = "Citation: Open PDF under cursor" })
```

## Ref file format

Out of the box, `fzfcite.nvim` expects a YAML file where each top-level key is a citation key:

```yaml
smith2020:
  title: Example paper
  author: Smith, J.
  year: 2020

doe2021:
  title: Another paper
  author: Doe, J.
```

With the defaults, `smith2020.pdf` is expected under one of the configured `pdf_dirs`.

## Customizing for other bibliography formats

`grep_pattern` + `extract_key` together define "how do we list the keys". A few examples:

### BibTeX (`@article{key, ...}`)

```lua
require("fzfcite").setup({
  ref_files = { "refs.bib", "~/refs/refs.bib" },
  citation = {
    grep_pattern = "^@[a-zA-Z]+{[^,]+,",
    extract_key = function(line)
      return line:match("^[^:]+:%d+:@[a-zA-Z]+{([^,]+),")
    end,
  },
})
```

### Pandoc-style `[@key]` output

```lua
require("fzfcite").setup({
  citation = {
    prefix = "[@",
    suffix = "]",
  },
})
```

## License

MIT. See [LICENSE](LICENSE).
