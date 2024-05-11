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
      lightline-vim
      {
        plugin = onedarkpro-nvim;
        config = "colorscheme onedark";
      }
 
      # Nice saker
      # Fix comments TODO: .nix filer
      commentary

      # LSP
      nvim-lspconfig

      # Functional
      {
        plugin = telescope-nvim;
        config = ''
          nnoremap ;f <cmd>Telescope find_files<cr>
          nnoremap ;g <cmd>Telescope live_grep<cr>
        '';
      }
      editorconfig-nvim

      # Autocomplete
      nvim-cmp

      cmp-nvim-lsp

      # Syntax Highlighting
      (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [ p.rust p.typescript p.javascript ]))
   ];
    extraLuaConfig = ''
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
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = {
          { name = 'nvim_lsp' }
        },
      }
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      require('lspconfig')
      require('lspconfig').rust_analyzer.setup {
        capabilities = capabilities,
        on_attach = (function(client, bufnr)
          local opts = {buffer = bufnr, remap = false}

          vim.keymap.set("n","rr", vim.lsp.buf.rename, opts)
        end),
        settings = {
          ['rust-analyzer'] = {},
        },
      }
    '';
    extraConfig = ''
      filetype plugin indent on
      set number relativenumber
      set noshowmode
    '';
  };

  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
  };

  home.packages = with pkgs; [
    htop
    # Required by telescope
    ripgrep
    bacon
    rustup
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
