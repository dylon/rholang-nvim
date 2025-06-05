" Vim syntax file
" Language:  Rholang
" Maintainer:  Alpheus Madsen
" Latest Revision:  2025-06-10

if exists("b:current_syntax")
	finish
endif

" Rholang Keywords
syn keyword rholangLanguageKeywords contract for in if else match new select case bundle bundle0 bundle+ bundle- let true false Nil Bool Int String Uri ByteArray

" Rholang Comments
syn keyword rholangToDo contained TODO FIXME XXX NOTE
syn match rholangLineComment "//.*" contains=rholangToDo
syn region rholangBlockComment start="/\*" end="\*/" contains=rholangToDo

" Rholang Strings and URIs
syn match rholangStringSpecialChar contained "\\\([4-9]\d\|[0-3]\d\d\|[\"\\'ntbrf]\|u\x\{4\}\)"
syn region rholangString start=+"+ end=+"+ contains=rholangStringSpecialChar
syn match rholangURISpecialChar contained "\\\([4-9]\d\|[0-3]\d\d\|[`\\'ntbrf]\|u\x\{4\}\)"
syn region rholangURI start=+`+ end=+`+ contains=rholangURISpecialChar

" Rholang Numbers
syn match rholangNumber "\<\(0[bB][0-1]\+\|0[0-7]*\|0[xX]\x\+\|\d\(\d\|_\d\)*\)[lL]\=\>"
syn match rholangNumber "\(\<\d\(\d\|_\d\)*\.\(\d\(\d\|_\d\)*\)\=\|\.\d\(\d\|_\d\)*\)\([eE][-+]\=\d\(\d\|_\d\)*\)\=[fFdD]\="
syn match rholangNumber "\<\d\(\d\|_\d\)*[eE][-+]\=\d\(\d\|_\d\)*[fFdD]\=\>"
syn match rholangNumber "\<\d\(\d\|_\d\)*\([eE][-+]\=\d\(\d\|_\d\)*\)\=[fFdD]\>"

" Rholang Operators
syn match rholangOperator '+\|-\|\*\|/[^/]\|==\|!=\|<=\|>=\|<\|>\|!\||\|<-\|<<-\|<=\||\||\/\\\|/\\\|\~\|++\|--\|%%\|%\|='
syn match rholangOperator '\<not\>\|\<and\>\|\<or\>\|\<matches\>'

" Rholang Channels
syn match rholangChannel '@'

" Rholang Delimiters
syn match rholangBracket '(\|\[\|{\|}\|\]\|)'

" Rholang Variables
syn match rholangVariable '\<_\?\([a-zA-Z][a-zA-Z0-9_']*\|_[a-zA-Z0-9_']+\)\>'

" Set Rholang Syntax
let b:current_syntax = "rholang"

" Highlighting Links
hi def link rholangLineComment        Comment
hi def link rholangBlockComment       Comment
hi def link rholangNumber             Number
hi def link rholangString             String
hi def link rholangURI                String
hi def link rholangOperator           Operator
hi def link rholangChannel            Function
hi def link rholangToDo               Todo
hi def link rholangLanguageKeywords   Keyword
hi def link rholangBracket            Delimiter
hi def link rholangVariable           Identifier
