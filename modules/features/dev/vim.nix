{ self, inputs, ... }:
{

  flake.homeModules.vim =
    { pkgs, ... }:
    {
      programs.vim = {
        enable = true;

        plugins = with pkgs.vimPlugins; [
          vim-sensible
          onedark-vim
        ];

        settings = {
          background = "dark";
          expandtab = true;
          hidden = true;
          history = 1000;
          ignorecase = true;
          smartcase = true;
          mouse = "a";
          number = true;
          shiftwidth = 4;
          tabstop = 4;
        };

        extraConfig = ''
          set termguicolors
          colorscheme onedark

          set showmatch
          set matchtime=2
          set cursorline
          set hlsearch
          set scrolloff=5
          set splitbelow
          set splitright
          set wildmode=longest:full,full
          set clipboard=unnamedplus
        '';
      };
    };
}
