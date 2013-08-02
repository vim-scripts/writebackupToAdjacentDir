" writebackupToAdjacentDir/Command.vim: Implementation of the :WriteBackupMakeAdjacentDir command.
"
" DEPENDENCIES:
"   - writebackupToAdjacentDir.vim autoload script
"   - ingo/err.vim autoload script
"   - ingo/fs/path.vim autoload script
"   - ingo/msg.vim autoload script

" Copyright: (C) 2010-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   2.00.006	02-Aug-2013	Move :WriteBackupMakeAdjacentDir implementation
"				into a different autoload script.
"   2.00.005	01-Aug-2013	Split off autoload script.
"				ENH: Implement upwards directory hierarchy
"				search for backup directories, and then
"				re-create the path to the current file inside
"				that parallel backup directory hierarchy.
"				ENH: :WriteBackupMakeAdjacentDir now optionally
"				also takes a target directory to better support
"				the new upwards directory hierarchy search.
"   1.11.004	27-Jun-2013	Implement abort on error for
"				:WriteBackupMakeAdjacentDir.
"   1.10.003	17-Feb-2012	ENH: Save configured g:WriteBackup_BackupDir and
"				use that as a fallback instead of always
"				defaulting to '.', thereby allowing absolute and
"				dynamic backup directories as a fallback.
"				Suggested by Geoffrey Nimal.
"   1.00.002	02-Jun-2010	Finished, polished and added
"				:WriteBackupMakeAdjacentDir command.
"	001	01-Jun-2010	file creation
let s:save_cpo = &cpo
set cpo&vim

function! writebackupToAdjacentDir#Command#MakeDir( arguments )
    if a:arguments =~# '^\d\{1,4}$'
	let [l:dirArgument, l:prot] = ['', a:arguments]
    else
	let [l:dirArgument, l:prot] = matchlist(a:arguments, '^\(.\{-}\)\%(\s\+\(\d\{1,4}\)\)\?$')[1:2]
    endif
    if empty(l:dirArgument)
	let l:backupDir = writebackupToAdjacentDir#GetAdjacentBackupDir(expand('%'))
    else
	" Environment variables are not automatically expanded, and the
	" whitespace escaping also is still there.
	let l:dir = expand(l:dirArgument)

	if l:dir =~# '^\.'
	    " Determine the backup target directory relative to the current
	    " buffer's dirspec.
	    " Note: On Linux, fnamemodify(..., ':p') only simplifies a ".." at
	    " the end when it ends with a path separator: "../", so make sure it
	    " does.
	    let l:targetDir = fnamemodify(
	    \   ingo#fs#path#Combine(expand('%:p:h'),
	    \       ingo#fs#path#Combine(l:dir, '')
	    \   ),
	    \   ':p'
	    \)
	else
	    " An absolute target has been passed; just canonicalize it.
	    let l:targetDir = fnamemodify(l:dir, ':p')
	endif
	let l:targetDirname = fnamemodify(l:targetDir, ':h:t')
	let l:targetParentDirspec = fnamemodify(l:targetDir, ':h:h')
	let l:backupDir = writebackupToAdjacentDir#CombineToBackupDir(l:targetParentDirspec, l:targetDirname)
"****D echomsg '****' l:targetDir l:backupDir
    endif

    if isdirectory(l:backupDir)
	call ingo#msg#WarningMsg('Backup directory already exists: ' . fnamemodify(l:backupDir, ':~:.'))
	return 1
    elseif filereadable(l:backupDir)
	call ingo#err#Set('Cannot create backup directory; file exists: ' . fnamemodify(l:backupDir, ':~:.'))
	return 0
    endif

    try
	call call('mkdir', [l:backupDir, 'p'] + (empty(l:prot) ? [] : [l:prot]))
	return 1
    catch /^Vim\%((\a\+)\)\=:E739/	" E739: Cannot create directory
	call ingo#err#SetVimException()
	return 0
    endtry
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
