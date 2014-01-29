" writebackupToAdjacentDir.vim: writebackup plugin writes to an adjacent directory if it exists.
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher.
"   - writebackupToAdjacentDir.vim autoload script
"   - writebackupToAdjacentDir/Command.vim autoload script
"   - ingo/err.vim autoload script
"   - writebackup plugin (vimscript #1828), version 1.30 or higher

" Copyright: (C) 2010-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   2.01.007	03-Nov-2013	Compatibility: Fix Funcref errors for Vim 7.0/1.
"   2.00.006	02-Aug-2013	Move :WriteBackupMakeAdjacentDir implementation
"				into a different autoload script.
"   2.00.005	01-Aug-2013	Split off autoload script.
"				Add
"				g:WriteBackupAdjacentDir_IsUpwardsBackupDirSearch
"				configuration and enable the new upwards
"				directory hierarchy search by default.
"				ENH: :WriteBackupMakeAdjacentDir now optionally
"				also takes a target directory.
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

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_writebackupToAdjacentDir') || (v:version < 700)
    finish
endif
let g:loaded_writebackupToAdjacentDir = 1

"- configuration --------------------------------------------------------------

if ! exists('g:WriteBackupAdjacentDir_BackupDirTemplate')
    let g:WriteBackupAdjacentDir_BackupDirTemplate = '%s.backup'
endif
if ! exists('g:WriteBackupAdjacentDir_IsUpwardsBackupDirSearch')
    let g:WriteBackupAdjacentDir_IsUpwardsBackupDirSearch = 1
endif


"- integration ----------------------------------------------------------------

if ! exists('g:WriteBackupAdjacentDir_BackupDir')
    let g:WriteBackupAdjacentDir_BackupDir = g:WriteBackup_BackupDir
endif
unlet g:WriteBackup_BackupDir
if v:version < 702 | runtime autoload/writebackupToAdjacentDir.vim | endif  " The Funcref doesn't trigger the autoload in older Vim versions.
let g:WriteBackup_BackupDir = function('writebackupToAdjacentDir#AdjacentBackupDir')

"- commands -------------------------------------------------------------------

command! -bar -nargs=* -complete=dir WriteBackupMakeAdjacentDir if ! writebackupToAdjacentDir#Command#MakeDir(<q-args>) | echoerr ingo#err#Get() | endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
