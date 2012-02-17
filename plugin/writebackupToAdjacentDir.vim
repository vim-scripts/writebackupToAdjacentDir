" writebackupToAdjacentDir.vim: writebackup plugin writes to an adjacent
" directory if it exists. 
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher. 
"   - writebackup plugin (vimscript #1828), version 1.30 or higher. 

" Copyright: (C) 2010-2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"   1.10.003	17-Feb-2012	ENH: Save configured g:WriteBackup_BackupDir and
"				use that as a fallback instead of always
"				defaulting to '.', thereby allowing absolute and
"				dynamic backup directories as a fallback.
"				Suggested by Geoffrey Nimal. 
"   1.00.002	02-Jun-2010	Finished, polished and added
"				:WriteBackupMakeAdjacentDir command. 
"	001	01-Jun-2010	file creation

" Avoid installing twice or when in unsupported Vim version. 
if exists('g:loaded_writebackupToAdjacentDir') || (v:version < 700)
    finish
endif
let g:loaded_writebackupToAdjacentDir = 1
let s:save_cpo = &cpo
set cpo&vim

"- configuration --------------------------------------------------------------

if ! exists('g:WriteBackupAdjacentDir_BackupDirTemplate')
    let g:WriteBackupAdjacentDir_BackupDirTemplate = '%s.backup'
endif


"- functions ------------------------------------------------------------------

function! s:GetAdjacentBackupDir(originalFilespec)
    let l:originalDirname = fnamemodify(a:originalFilespec, ':p:h:t')
    let l:originalParentDirspec = fnamemodify(a:originalFilespec, ':p:h:h')
"****D echomsg '****' l:originalDirname l:originalParentDirspec

    " Use path separator as exemplified by the resolved dirspec. 
    let l:pathSeparator = (l:originalParentDirspec =~# '\' && l:originalParentDirspec !~# '/' ? '\' : '/') 

    let l:adjacentBackupDir =
    \	(l:originalParentDirspec ==# l:pathSeparator ? '' : l:originalParentDirspec) .
    \	l:pathSeparator .
    \	printf(g:WriteBackupAdjacentDir_BackupDirTemplate, l:originalDirname)

    return l:adjacentBackupDir
endfunction

function! s:GetFallbackBackupDir( originalFilespec, isQueryOnly )
    let l:BackupDir = g:WriteBackupAdjacentDir_BackupDir
    if type(l:BackupDir) == type('')
	return l:BackupDir
    else
	return call(l:BackupDir, [a:originalFilespec, a:isQueryOnly])
    endif
endfunction
function! writebackupToAdjacentDir#AdjacentBackupDir( originalFilespec, isQueryOnly )
    let l:adjacentBackupDir = s:GetAdjacentBackupDir(a:originalFilespec)

    " If there is an adjacent backup directory, use it. 
    return (isdirectory(l:adjacentBackupDir) ? l:adjacentBackupDir : s:GetFallbackBackupDir(a:originalFilespec, a:isQueryOnly))
endfunction

function! s:WriteBackupMakeAdjacentDir( ... )
    let l:adjacentBackupDir = s:GetAdjacentBackupDir(expand('%'))

    if isdirectory(l:adjacentBackupDir)
	let v:warningmsg = 'Backup directory already exists: ' . fnamemodify(l:adjacentBackupDir, ':~:.')
	echohl WarningMsg
	echomsg v:warningmsg
	echohl None
	return
    elseif filereadable(l:adjacentBackupDir)
	let v:errmsg = 'Cannot create backup directory; file exists: ' . fnamemodify(l:adjacentBackupDir, ':~:.')
	echohl ErrorMsg
	echomsg v:errmsg
	echohl None
	return
    endif

    try
	call call('mkdir', [l:adjacentBackupDir, ''] + a:000)
    catch /^Vim\%((\a\+)\)\=:E739/	" E739: Cannot create directory
	" v:exception contains what is normally in v:errmsg, but with extra
	" exception source info prepended, which we cut away. 
	let v:errmsg = substitute(v:exception, '^Vim\%((\a\+)\)\=:', '', '')
	echohl ErrorMsg
	echomsg v:errmsg
	echohl None
    endtry
endfunction

"- integration ----------------------------------------------------------------

if ! exists('g:WriteBackupAdjacentDir_BackupDir')
    let g:WriteBackupAdjacentDir_BackupDir = g:WriteBackup_BackupDir
endif
unlet g:WriteBackup_BackupDir
let g:WriteBackup_BackupDir = function('writebackupToAdjacentDir#AdjacentBackupDir')

"- commands -------------------------------------------------------------------

command! -bar -nargs=? WriteBackupMakeAdjacentDir call <SID>WriteBackupMakeAdjacentDir(<f-args>)

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
