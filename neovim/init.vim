set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz
call plug#begin()
	Plug 'preservim/nerdtree', {'on': 'NERDTreeToggle'}
	Plug 'morhetz/gruvbox'
	Plug 'ycm-core/YouCompleteMe' "При переустановке системы данный плагин надо докомпелировать с помощью install.py находящайся в каталоге плагина
	Plug 'jiangmiao/auto-pairs'
	Plug 'ctrlpvim/ctrlp.vim'
	Plug 'easymotion/vim-easymotion'
	Plug 'ryanoasis/vim-devicons' "ВСЕГДА ДОЛЖЕН БЫТЬ ПОСЛЕДНИМ!!! (При переустановке системы следует подгрузить зависимости шрифтов по инструкции из офицального репозитория)
call plug#end()

syntax on
colorscheme gruvbox

let g:mapleader=','

set number
set tabstop=2
set shiftwidth=2
set smarttab
set softtabstop=2
set hlsearch
set incsearch

"Мапинг для нормального режима
nnoremap <C-n> :NERDTreeToggle<CR>
nnoremap <Leader> <Plug>(easymotion-prefix)
nnoremap <Up> <Nop>
nnoremap <Down> <Nop>
nnoremap <Left> <Nop>
nnoremap <Right> <Nop>

nnoremap <silent> <C-h> :call WinMove('h')<CR>
nnoremap <silent> <C-j> :call WinMove('j')<CR>
nnoremap <silent> <C-k> :call WinMove('k')<CR>
nnoremap <silent> <C-l> :call WinMove('l')<CR>

function! WinMove(key)
	let t:curwin = winnr()
	exec "wincmd ".a:key
	if(t:curwin == winnr())
		exec "wincmd ".a:key
	endif
endfunction
