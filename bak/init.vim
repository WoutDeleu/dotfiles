set encoding=UTF-8
" Set leader key
let g:mapleader = "\<Space>"
" Disable compatibility with vi which can cause unexpected issues.
set nocompatible
" Set Clipboard to system
set clipboard=unnamedplus
" Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype on
" Enable plugins and load plugin for the detected file type.
filetype plugin on
" Load an indent file for the detected file type.
filetype indent on
" Turn syntax highlighting on.
syntax on
" Add numbers to each line on the left-hand side.
set number
" Highlight cursor line underneath the cursor horizontally.
set cursorline
" Highlight cursor line underneath the cursor vertically.
" set cursorcolumn
set number relativenumber
set nu rnu
" allow quit via single keypress (Q)
map Q :qa<CR>
" Set shift width to 4 spaces.
set shiftwidth=4
" Set tab width to 4 columns.
set tabstop=4
" Use space characters instead of tabs.
set expandtab
" Do not save backup files.
set nobackup
" Do not let cursor scroll below or above N number of lines when scrolling.
set scrolloff=10
" Do not wrap lines. Allow long lines to extend as far as the line goes.
" set linebreak
set nowrap
" While searching though a file incrementally highlight matching characters as you type.
set incsearch
" Ignore capital letters during search.
set ignorecase
" Override the ignorecase option if searching for capital letters.
" This will allow you to search specifically for capital letters.
" set smartcase
" Show partial command you type in the last line of the screen.
set showcmd
" Show the mode you are on the last line.
set showmode
" Show matching words during a search.
set showmatch
" Use highlighting when doing a search.
set hlsearch
" Set the commands to save in history default number is 20.
set history=1000

" Enable auto completion menu after pressing TAB.
set wildmenu
" Make wildmenu behave like similar to Bash completion.
set wildmode=list:longest
" There are certain files that we would never want to edit with Vim.
" Wildmenu will ignore files with these extensions.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" On Startup
let g:auto_save = 1  " enable AutoSave on Vim startup
autocmd VimEnter * Copilot disable
let g:codelens_auto = 1

" PLUGINS ---------------------------------------------------------------- {{{
call plug#begin('~/.vim/plugged')
    Plug 'leafgarland/typescript-vim'
    Plug 'Quramy/vim-js-pretty-template'
    Plug 'pangloss/vim-javascript'
    Plug 'Shougo/vimproc.vim', {'do' : 'make'}
    Plug 'Quramy/tsuquyomi'
    Plug 'frazrepo/vim-rainbow'
    Plug 'akinsho/toggleterm.nvim', {'tag' : '*'}


    Plug 'jmcantrell/vim-virtualenv'
    Plug 'dansomething/vim-eclim'
    Plug 'markwoodhall/vim-codelens'
    Plug 'google/vim-maktaba'
    Plug 'google/vim-codefmt'
    Plug 'google/vim-glaive'
    Plug 'nvimdev/dashboard-nvim'
    Plug 'junegunn/seoul256.vim'
    Plug 'ryanoasis/vim-devicons'
    Plug 'dense-analysis/ale'
    Plug 'preservim/nerdtree'
    Plug '907th/vim-auto-save'
    Plug 'termhn/i3-vim-nav'
    Plug 'dracula/vim', { 'as': 'dracula' }
    Plug 'NLKNguyen/papercolor-theme'
    Plug 'startup-nvim/startup.nvim'
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'github/copilot.vim'
    Plug 'mhinz/vim-startify'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'tpope/vim-rhubarb'
    Plug 'nvim-telescope/telescope.nvim'
    Plug 'nvim-telescope/telescope-file-browser.nvim'
    Plug 'nvim-tree/nvim-web-devicons'
    Plug 'airblade/vim-gitgutter'
    Plug 'liuchengxu/vim-which-key'
    " Plug 'm4xshen/autoclose.nvim'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    " Plug 'beauwilliams/statusline.lua'
    Plug 'pwntester/octo.nvim'
    Plug 'tpope/vim-fugitive'
    Plug 'sodapopcan/vim-twiggy'
    Plug 'Rigellute/rigel'
    Plug 'habamax/vim-asciidoctor'
call plug#end()
" }}}

" CSCOPE -------------------------------------------------------------- {{{
if has('cscope')
  set cscopetag cscopeverbose

  if has('quickfix')
    set cscopequickfix=s-,c-,d-,i-,t-,e-
  endif

  cnoreabbrev csa cs add
  cnoreabbrev csf cs find
  cnoreabbrev csk cs kill
  cnoreabbrev csr cs reset
  cnoreabbrev css cs show
  cnoreabbrev csh cs help

  command -nargs=0 Cscope cs add $VIMSRC/src/cscope.out $VIMSRC/src
endif
" }}}

" FRONTEND -------------------------------------------------------------- {{{
    let g:typescript_compiler_binary = 'tsc'
    let g:typescript_compiler_options = ''
    autocmd QuickFixCmdPost [^l]* nested cwindow
    autocmd QuickFixCmdPost l* nested lwindow

    autocmd FileType typescript JsPreTmpl
    autocmd FileType typescript syn clear foldBraces
    autocmd BufNewFile,BufRead *.ts setlocal filetype=typescript
    autocmd BufNewFile,BufRead *.tsx setlocal filetype=typescript


    let g:syntastic_check_on_open = 1
    let g:syntastic_check_on_wq = 0
    let g:tsuquyomi_disable_quickfix = 1
    let g:syntastic_typescript_checkers = ['tsuquyomi']
" }}}


" FORMATTER ---------------------------------------------------------------- {{{
" augroup autoformat_settings
 " autocmd FileType bzl AutoFormatBuffer buildifier
 "  autocmd FileType c,cpp,proto,javascript,arduino AutoFormatBuffer clang-format
 "  autocmd FileType dart AutoFormatBuffer dartfmt
 "  autocmd FileType go AutoFormatBuffer gofmt
 "  autocmd FileType gn AutoFormatBuffer gn
 "  autocmd FileType html,css,sass,scss,less,json AutoFormatBuffer js-beautify
 "  autocmd FileType java AutoFormatBuffer
 "  autocmd FileType python AutoFormatBuffer yapf
 "  " Alternative: autocmd FileType python AutoFormatBuffer autopep8
 "  autocmd FileType rust AutoFormatBuffer rustfmt
 "  autocmd FileType vue AutoFormatBuffer prettier
 "  autocmd FileType swift AutoFormatBuffer swift-format
" agroup END
" }}}


" NERDTREE --------------------------------------------------------------- {{{
    " open NERDTree automatically
    " autocmd StdinReadPre * let s:std_in=1
    " autocmd VimEnter *
    "             \   if !argc()
    "             \ |   Startify
    "             \ |   NERDTree
    "             \ |   wincmd w
    "             \ | endif
    " autocmd BufWinEnter *
    "             \   if !argc()
    "             \ |   NERDTreeMirror
    "             \ | endif

    " "let g:NERDTreeChDirMode = 2
    " autocmd BufWritePost * NERDTreeFocus | execute 'normal R' | wincmd
    map <C-n> :NERDTreeToggle<CR>
    let g:NERDTreeGitStatusWithFlags = 1
    "let g:WebDevIconsUnicodeDecorateFolderNodes = 1
    "let g:NERDTreeGitStatusNodeColorization = 1
    let NERDTreeShowHidden=1
    let g:NERDTreeIgnore = ['^node_modules$']

    " after a re-source, fix syntax matching issues (concealing brackets):
    if exists('g:loaded_webdevicons')
        call webdevicons#refresh()
    endif
" }}}


" COC -------------------------------------------------------------------- {{{
    nmap <silent> gd <Plug>(coc-definition)
    nmap <silent> gy <Plug>(coc-type-definition)
    nmap <silent> gr <Plug>(coc-references)

    nmap <silent> [g <Plug>(coc-diagnostic-prev)
    nmap <silent> ]g <Plug>(coc-diagnostic-next)
    nnoremap <silent> <space>s :<C-u>CocList -I symbols<cr>

    nnoremap <silent> <space>d :<C-u>CocList diagnostics<cr>

    nmap <leader>do <Plug>(coc-codeaction)

    nmap <leader>rn <Plug>(coc-rename)

    let g:coc_global_extensions = [
      \ 'coc-tsserver',
      \ 'coc-json',
      \ 'coc-css',
      \  'coc-eslint',
      \  'coc-prettier'
    \ ]

" }}}


" MAPPINGS --------------------------------------------------------------- {{{
    " Map Ctrl-Backspace to delete the previous word in insert mode.
    imap <C-BS> <C-W>

    " Tab to select
    vmap <Tab> >gv
    vmap <S-Tab> <gv

    " I3 keymaps navigation
    nnoremap <c-l> :m .+0<CR>==
    nnoremap <c-k> :m .-2<CR>==
    inoremap <c-l> <Esc>:m .+1<CR>==gi
    inoremap <c-k> <Esc>:m .-2<CR>==gi
    vnoremap <c-l> :m '>+1<CR>gv=gv
    vnoremap <c-k> :m '<-2<CR>gv=gv

    inoremap " ""<left>
    inoremap ' ''<left>
    inoremap ( ()<left>
    inoremap [ []<left>
    inoremap { {}<left>
    inoremap {<CR> {<CR>}<ESC>O
    inoremap {;<CR> {<CR>};<ESC>O


" }}}


" VIMSCRIPT -------------------------------------------------------------- {{{

" This will enable code folding.
" Use the marker method of folding.

augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END

augroup no_extension
    autocmd!
    autocmd BufRead,BufNewFile * if expand('%:e') == '' | setlocal wrap linebreak | endif
    autocmd FileType markdown setlocal wrap linebreak
augroup END

" More Vimscripts code goes here.

" }}}


" STATUS LINE ------------------------------------------------------------ {{{
    let g:rigel_airline = 1
    let g:airline_theme = 'rigel'

    set statusline+=%#warningmsg#
    set statusline+=%*
" }}}


" THEME -------------------------------------------------------------------- {{{
    set termguicolors
    colorscheme PaperColor
    set background=dark
" }}}


" STARTUP ------------------------------------------------------------------ {{{
    let g:startify_fortune_use_unicode = 0

" }}}


" RAINBOW_BRACKETS ------------------------------------------------------------------ {{{
    let g:rainbow_active = 1

    let g:rainbow_load_separately = [
    \ [ '*' , [['(', ')'], ['\[', '\]'], ['{', '}']] ],
    \ [ '*.tex' , [['(', ')'], ['\[', '\]']] ],
    \ [ '*.cpp' , [['(', ')'], ['\[', '\]'], ['{', '}']] ],
    \ [ '*.{html,htm}' , [['(', ')'], ['\[', '\]'], ['{', '}'], ['<\a[^>]*>', '</[^>]*>']] ],
    \ ]

    let g:rainbow_guifgs = ['RoyalBlue3', 'DarkOrange3', 'DarkOrchid3', 'FireBrick']
    let g:rainbow_ctermfgs = ['lightblue', 'lightgreen', 'yellow', 'red', 'magenta']
" }}}


" CLAUDE CODE --------------------------------------------------------------- {{{

lua << EOF
local status_ok, toggleterm = pcall(require, "toggleterm")
if status_ok then
    local Terminal = require('toggleterm.terminal').Terminal
    local claude = Terminal:new({
        cmd = "claude",
        direction = "float",
        close_on_exit = false,
        float_opts = {
            border = "curved",
        },
    })

    function _CLAUDE_TOGGLE()
        claude:toggle()
    end
end
EOF

nnoremap <C-\> <cmd>lua _CLAUDE_TOGGLE()<CR>
tnoremap <C-\> <cmd>lua _CLAUDE_TOGGLE()<CR>

" }}}


" TELESCOPE --------------------------------------------------------------- {{{
    " Find files using Telescope command-line sugar.
    nnoremap <leader>ff <cmd>Telescope find_files<cr>
    nnoremap <leader>fg <cmd>Telescope live_grep<cr>
    nnoremap <leader>fb <cmd>Telescope buffers<cr>
    nnoremap <leader>fh <cmd>Telescope help_tags<cr>

lua << EOF
    local status_ok, telescope = pcall(require, "telescope")
    if not status_ok then
      return
    end


    local actions = require("telescope.actions")

    require('telescope').setup{
        defaults = {
        -- Default configuration for telescope goes here:
        -- config_key = value,
        mappings = {
          i = {
            -- map actions.which_key to <C-h> (default: <C-/>)
            -- actions.which_key shows the mappings for your picker,
            -- e.g. git_{create, delete, ...}_branch for the git_branches picker
            ["<C-h>"] = "which_key"
          }
        }
      },
      pickers = {
        -- Default configuration for builtin pickers goes here:
        -- picker_name = {
        --   picker_config_key = value,
        --   ...
        -- }
        -- Now the picker_config_key will be applied every time you call this
        -- builtin picker
      },
      extensions = {
        -- Your extension configuration goes here:
        -- extension_name = {
        --   extension_config_key = value,
        -- }
        -- please take a look at the readme of the extension you want to configure
      }
    }

EOF
" }}}


" ASCIIDOCTOR --------------------------------------------------------------- {{{
    "" What to use for HTML, default `asciidoctor`.
    let g:asciidoctor_executable = 'asciidoctor'
    " What to use for PDF, default `asciidoctor-pdf`.
    let g:asciidoctor_pdf_executable = 'asciidoctor-pdf'

    " List of filetypes to highlight, default `[]`
    let g:asciidoctor_fenced_languages = ['python', 'c', 'javascript']

    " Conceal *bold*, _italic_, `code` and urls in lists and paragraphs, default `0`.
    " See limitations in end of the README
    let g:asciidoctor_syntax_conceal = 1

    " Highlight indented text, default `1`.
    let g:asciidoctor_syntax_indented = 0
" }}}
