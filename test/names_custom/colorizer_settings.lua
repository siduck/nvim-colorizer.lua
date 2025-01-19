local opts = {
  filetypes = {
    "*",
    html = {
      names = true,
      names_opts = {
        lowercase = true,
        uppercase = true,
        camelcase = true,
        strip_digits = false,
      },
      names_custom = {
        html1 = "#0000ff",
        html2 = "#00ff00",
        html3 = "#ff0000",
        html4 = "#0eae90",
        html5 = "#f0f000",
        html6 = "#fa0ce0",
      },
      tailwind = true,
    },
    lua = {
      names = true,
      names_opts = {
        lowercase = true,
        uppercase = true,
        camelcase = true,
        strip_digits = false,
      },
      names_custom = {
        lua1 = "#ffefaf",
        lua2 = "#3f0fb0",
        lua3 = "#f000f0",
        lua4 = "#902f00",
      },
      tailwind = false,
    },
    css = {
      names = true,
      names_custom = {
        css1 = "#fac00e",
        css2 = "#f0c0ae",
      },
    },
    javascript = { names = true },
    javascriptreact = { names = true },
  },
  user_default_options = {
    names = true,
    names_custom = {
      html1 = "#000000",
      html2 = "#000000",
      lua1 = "#000000",
      lua2 = "#000000",
      css1 = "#000000",
    },
    RGB = true,
    RRGGBB = true,
    RRGGBBAA = true,
    AARRGGBB = true,
    rgb_fn = true,
    hsl_fn = true,
    css = true,
    css_fn = true,
    mode = "background",
    sass = { enable = false, parsers = { "css" } },
    virtualtext = "",
    virtualtext_inline = true,
    virtualtext_mode = "foreground",
    always_update = false,
  },
  buftypes = {},
  user_commands = true,
  lazy_load = false,
}
