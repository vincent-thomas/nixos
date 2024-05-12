{ config, pkgs, ... }:

{
  home.username = "vt";
  home.homeDirectory = "/home/vt";

  # DO NOT CHANGE
  home.stateVersion = "23.11";

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = "[$time](black) [>>](bright-black) $directory $character";

      add_newline = false;
      
      character.success_symbol = "[λ](yellow)";
      character.error_symbol = "[µ](red)";

      directory.format = "[$path](cyan)";
      directory.disabled = false;
      time.disabled = false;
      time.format = "[$time](dimmed)";
    };
  };

  programs.eza = {
    enable = true;
    icons = false;
  };

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autocd = true;
    enableCompletion = true;
    shellAliases = {
      ls = "eza -al";
      v = "nvim";
      c = "z";
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;
    userName = "Vincent Thomas";
    userEmail = "77443389+vincent-thomas@users.noreply.github.com";

    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
  };

  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      # UI
      {
        plugin = lightline-vim;
        config = ''
          let g:lightline = {
            \ 'colorscheme': 'one',
          \ }
        '';
      }
      {
        plugin = onedarkpro-nvim;
        config = "colorscheme onedark";
      }
 
      # Nice saker
      # Fix comments TODO: .nix filer
      {
        plugin = commentary;
        config = "nnoremap cl <cmd>Commentary<cr>";
      }
      {
        plugin = todo-comments-nvim;
        config = "nnoremap ;t <cmd>TodoTelescope<cr>";
      }

      gitsigns-nvim
      # LSP
      nvim-lspconfig

      # Functional
      auto-pairs
      {
        plugin = telescope-nvim;
        config = ''
          nnoremap ;f <cmd>Telescope find_files<cr>
          nnoremap ;g <cmd>Telescope live_grep<cr>
        '';
      }
      editorconfig-nvim
      conform-nvim
      copilot-cmp
      copilot-lua
      cmp-path

      # Autocomplete
      nvim-cmp
      cmp-nvim-lsp
      luasnip

      # Syntax Highlighting
      (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [ p.rust p.typescript p.javascript p.yaml p.toml p.json ]))
   ];
    extraLuaConfig = ''

      require('todo-comments').setup {
        keywords = {
          FIX = {
            icon = " ", -- icon used for the sign, and in search results
            color = "error", -- can be a hex color, or a named color (see below)
            alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
            -- signs = false, -- configure signs for some keywords individually
          },
          TODO = { icon = " ", color = "info" },
          HACK = { icon = " ", color = "warning" },
        },
        gui_style = {
          fg = "NONE",
          bg = "BOLD",
        },
        colors = {
          error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
          warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
          info = { "DiagnosticInfo", "#2563EB" },
          hint = { "DiagnosticHint", "#10B981" },
          default = { "Identifier", "#7C3AED" },
          test = { "Identifier", "#FF00FF" }
        },
        search = {
          command = "rg",
          args = {
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
          },
        },
      }

      require("conform").setup({
        format_on_save = {
          -- These options will be passed to conform.format()
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })

      require('gitsigns').setup {
        current_line_blame = true
      }

      require("copilot_cmp").setup()
      require('copilot').setup({
        suggestion = { enabled = false },
        panel = { enabled = false }
      })


      vim.opt.tabstop = 2
      vim.opt.softtabstop = 2
      vim.opt.shiftwidth = 2
      vim.opt.expandtab = true
      vim.opt.smartindent = true
      vim.opt.wrap = false

      vim.opt.swapfile = false
      vim.opt.backup = false
      vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
      vim.opt.undofile = true

      vim.opt.hlsearch = false
      vim.opt.incsearch = true

      vim.opt.scrolloff = 8

      vim.opt.termguicolors = true

      vim.g.mapleader = " "

      vim.opt.colorcolumn = "80"

      local cmp = require'cmp'

      cmp.setup {
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<Tab>'] = cmp.mapping.confirm({ select = true }),
        }),

        sources = cmp.config.sources({
          { name = 'copilot' },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        }, { name = 'buffer' }),
      }

      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      require('lspconfig').rust_analyzer.setup {
        capabilities = capabilities,
        settings = {
          ['rust-analyzer'] = {},
        },
      }

      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP Actions',
        callback = function()
          local bufmap = function(mode, lhs, rhs)
            local opts = {buffer = bufnr, remap = false}
            vim.keymap.set(mode, lhs, rhs, opts)
          end

          bufmap("n","gr", vim.lsp.buf.rename)
          bufmap("n","gd", vim.lsp.buf.definition)
          bufmap("n","gD", vim.lsp.buf.declaration)
          bufmap("n","gh", vim.lsp.buf.hover)
        end
      })
    '';
    extraConfig = ''
      filetype plugin indent on
      set number relativenumber
      set noshowmode
    '';
  };

  programs.zellij = {
    enable = true;
  };

  home.packages = with pkgs; [
    htop
    # Required by telescope
    ripgrep
    bacon
    rustup
    nodejs_20
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. jjjIf you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/vt/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
    v = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
