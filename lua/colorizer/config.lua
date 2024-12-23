--- Provides configuration options and utilities for setting up colorizer.
-- @module colorizer.config
local M = {}

--- Defaults for colorizer options
local function user_defaults()
  return vim.deepcopy({
    names = true,
    names_custom = nil,
    RGB = true,
    RRGGBB = true,
    RRGGBBAA = false,
    AARRGGBB = false,
    rgb_fn = false,
    hsl_fn = false,
    css = false,
    css_fn = false,
    mode = "background",
    tailwind = false,
    sass = { enable = false, parsers = { css = true } },
    virtualtext = "■",
    virtualtext_inline = false,
    virtualtext_mode = "foreground",
    always_update = false,
  })
end

--- Default user options for colorizer.
-- This table defines individual options and alias options, allowing configuration of
-- colorizer's behavior for different color formats (e.g., `#RGB`, `#RRGGBB`, `#AARRGGBB`, etc.).
--
-- **Individual Options**: Options like `names`, `RGB`, `RRGGBB`, `RRGGBBAA`, `hsl_fn`, `rgb_fn`,
-- `AARRGGBB`, `tailwind`, and `sass` can be enabled or disabled independently.
--
-- **Alias Options**: `css` and `css_fn` enable multiple options at once.
--   - `css_fn = true` enables `hsl_fn` and `rgb_fn`.
--   - `css = true` enables `names`, `RGB`, `RRGGBB`, `RRGGBBAA`, `hsl_fn`, and `rgb_fn`.
--
-- **Option Priority**: Individual options have higher priority than aliases.
-- If both `css` and `css_fn` are true, `css_fn` has more priority over `css`.
-- @table user_default_options
-- @field RGB boolean: Enables `#RGB` hex codes.
-- @field RRGGBB boolean: Enables `#RRGGBB` hex codes.
-- @field names boolean: Enables named colors (e.g., "Blue").
-- @field names_custom table|function|nil: Extra color name to RGB value mappings
-- should return a table of color names to RGB value pairs
-- @field RRGGBBAA boolean: Enables `#RRGGBBAA` hex codes.
-- @field AARRGGBB boolean: Enables `0xAARRGGBB` hex codes.
-- @field rgb_fn boolean: Enables CSS `rgb()` and `rgba()` functions.
-- @field hsl_fn boolean: Enables CSS `hsl()` and `hsla()` functions.
-- @field css boolean: Enables all CSS features (`rgb_fn`, `hsl_fn`, `names`, `RGB`, `RRGGBB`).
-- @field css_fn boolean: Enables all CSS functions (`rgb_fn`, `hsl_fn`).
-- @field mode 'background'|'foreground'|'virtualtext': Display mode
-- @field tailwind boolean|string: Enables Tailwind CSS colors (e.g., `"normal"`, `"lsp"`, `"both"`).
-- @field sass table: Sass color configuration (`enable` flag and `parsers`).
-- @field virtualtext string: Character used for virtual text display.
-- @field virtualtext_inline boolean: Shows virtual text inline with color.
-- @field virtualtext_mode 'background'|'foreground': Mode for virtual text display.
-- @field always_update boolean: Always update color values, even if buffer is not focused.

-- Configured user options
---@table user_default_options
--@field RGB boolean
--@field RRGGBB boolean
--@field names boolean
--@field names_custom nil
--@field RRGGBBAA boolean
--@field AARRGGBB boolean
--@field rgb_fn boolean
--@field hsl_fn boolean
--@field css boolean
--@field css_fn boolean
--@field mode 'background'|'foreground'|'virtualtext'
--@field tailwind boolean|string
--@field sass table
--@field virtualtext string
--@field virtualtext_inline boolean
--@field virtualtext_mode 'background'|'foreground'
--@field always_update boolean
M.user_default_options = nil

--- Options for colorizer that were passed in to setup function
---@table setup_options
--@field exclusions table
--@field all table
--@field default_options table
--@field user_commands boolean
--@field filetypes table
--@field buftypes table
M.setup_options = nil

--- Plugin default options cache from vim.deepcopy
---@table default_options
local plugin_user_default_options = user_defaults()

-- State for managing buffer and filetype-specific options
local options_cache = { buftype = {}, filetype = {} }

--  TODO: 2024-11-26 - background is being validated in colorizer.attach_to_buffer
--- Validates user options and sets defaults if necessary.
local function validate_opts(settings)
  if
    not vim.tbl_contains(
      { "background", "foreground", "virtualtext" },
      settings.default_options.mode
    )
  then
    settings.default_options.mode = plugin_user_default_options.mode
  end
  if
    not vim.tbl_contains({ "background", "foreground" }, settings.default_options.virtualtext_mode)
  then
    settings.default_options.virtualtext_mode = plugin_user_default_options.virtualtext_mode
  end
  if
    not vim.tbl_contains(
      { true, false, "normal", "lsp", "both" },
      settings.default_options.tailwind
    )
  then
    settings.default_options.tailwind = plugin_user_default_options.tailwind
  end
end

--- Set options for a specific buffer or file type.
---@param bo_type 'buftype'|'filetype': The type of buffer option
---@param value string: The specific value to set.
---@param options table: Options to associate with the value.
function M.set_bo_value(bo_type, value, options)
  options_cache[bo_type][value] = options
end

--- Parse and apply alias options to the user options.
---@param options table: user_default_options
---@return table
function M.apply_alias_options(options)
  local aliases = {
    ["css"] = { "names", "RGB", "RRGGBB", "RRGGBBAA", "hsl_fn", "rgb_fn" },
    ["css_fn"] = { "hsl_fn", "rgb_fn" },
  }
  local function handle_alias(name, opts)
    if not aliases[name] then
      return
    end
    for _, option in ipairs(aliases[name]) do
      if opts[option] == nil then
        opts[option] = options[name]
      end
    end
  end

  for alias, _ in pairs(aliases) do
    handle_alias(alias, options)
  end
  if options.sass and options.sass.enable then
    for child, _ in pairs(options.sass.parsers) do
      --  TODO: 2024-12-23 - This is probably not correct ;o
      handle_alias(child, options)
    end
  end

  return options
end

--- Configuration options for the `setup` function.
-- @table opts
-- @field filetypes table A list of file types where colorizer should be enabled. Use `"*"` for all file types.
-- @field user_default_options table Default options for color handling.
--   - `RGB` (boolean): Enables support for `#RGB` hex codes.
--   - `RRGGBB` (boolean): Enables support for `#RRGGBB` hex codes.
--   - `names` (boolean): Enables named color codes like `"Blue"`.
--   - `names_custom` (table|function): Extra color name to RGB value mappings
--   - `RRGGBBAA` (boolean): Enables support for `#RRGGBBAA` hex codes.
--   - `AARRGGBB` (boolean): Enables support for `0xAARRGGBB` hex codes.
--   - `rgb_fn` (boolean): Enables CSS `rgb()` and `rgba()` functions.
--   - `hsl_fn` (boolean): Enables CSS `hsl()` and `hsla()` functions.
--   - `css` (boolean): Enables all CSS-related features (e.g., `names`, `RGB`, `RRGGBB`, `hsl_fn`, `rgb_fn`).
--   - `css_fn` (boolean): Enables all CSS function-related features (e.g., `rgb_fn`, `hsl_fn`).
--   - `mode` (string): Determines the display mode for highlights. Options are `"background"`, `"foreground"`, and `"virtualtext"`.
--   - `tailwind` (boolean|string): Enables Tailwind CSS colors. Accepts `true`, `"normal"`, `"lsp"`, or `"both"`.
--   - `sass` (table): Configures Sass color support.
--      - `enable` (boolean): Enables Sass color parsing.
--      - `parsers` (table): A list of parsers to use, typically includes `"css"`.
--   - `virtualtext` (string): Character used for virtual text display of colors (default is `"■"`).
--   - `virtualtext_inline` (boolean): If true, shows the virtual text inline with the color.
-- - `virtualtext_mode` ('background'|'foreground'): Determines the display mode for virtual text.
--   - `always_update` (boolean): If true, updates color values even if the buffer is not focused.
-- @field buftypes table|nil Optional. A list of buffer types where colorizer should be enabled. Defaults to all buffer types if not provided.
-- @field user_commands boolean|table If true, enables all user commands for colorizer. If `false`, disables user commands. Alternatively, provide a table of specific commands to enable:
--   - `"ColorizerAttachToBuffer"`
--   - `"ColorizerDetachFromBuffer"`
--   - `"ColorizerReloadAllBuffers"`
--   - `"ColorizerToggle"`

--- Initializes colorizer with user-provided options.
-- Merges default settings with any user-specified options, setting up `filetypes`,
-- `user_default_options`, and `user_commands`.
-- @param opts opts User-provided configuration options.
-- @return table Final settings after merging user and default options.
function M.get_setup_options(opts)
  opts = opts or {}
  local default_opts = {
    filetypes = { "*" },
    buftypes = {},
    user_commands = true,
    user_default_options = plugin_user_default_options,
  }
  opts.user_default_options = M.apply_alias_options(opts.user_default_options)
  opts = vim.tbl_deep_extend("force", default_opts, opts)

  M.setup_options = {
    exclusions = { buftype = {}, filetype = {} },
    all = { buftype = false, filetype = false },
    default_options = opts.user_default_options,
    user_commands = opts.user_commands,
    filetypes = opts.filetypes,
    buftypes = opts.buftypes,
  }
  validate_opts(M.setup_options)
  M.user_default_options = M.setup_options.default_options
  return M.setup_options
end

--- Retrieve buffer-specific options or user_default_options defined when setup() was called.
---@param bufnr number: The buffer number.
---@param bo_type 'buftype'|'filetype': The type of buffer option
function M.new_buffer_options(bufnr, bo_type)
  local value = vim.api.nvim_get_option_value(bo_type, { buf = bufnr })
  return options_cache.filetype[value] or M.user_default_options
end

--- Retrieve options based on buffer type and file type.  Prefer filetype.
---@param bo_type 'buftype'|'filetype': The type of buffer option
---@param buftype string: Buffer type.
---@param filetype string: File type.
---@return table
function M.get_options(bo_type, buftype, filetype)
  local fo, bo = options_cache[bo_type][filetype], options_cache[bo_type][buftype]
  return fo or bo
end

function M.reset_cache()
  options_cache = { buftype = {}, filetype = {} }
end

return M
