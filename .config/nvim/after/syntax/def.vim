" --- .def syntax: Register + Address + Triplets + Comments + hiaddress ---

syntax clear
syntax case match

" 1) Comments: anywhere on the line
syntax match defComment /\/\/.*/ contains=@Spell
highlight link defComment Comment

" 2) Code fence: from BOL up to just before //,
"    but SKIP lines that start with '//' or 'hiaddress'
"    (so hiaddress lines don't get positional coloring).
syntax region defCode start=/^\s*\%(\c\%(\%(hiaddress\)\>\)\|\/\/\)\@!/ end=/\ze\/\/\|$/ oneline keepend

" 3) REGISTER (token #1)
syntax match defRegister /^\s*\zs\S\+/ contained containedin=defCode
highlight link defRegister Identifier

" 4) ADDRESS (token #2) — your color 1
syntax match defAddress /^\s*\S\+\s\+\zs\S\+/ contained containedin=defCode
highlight link defAddress Type

" 5) Triplets after address:
"    token #3, #6, #9, ...  → defTriplet3  (color A)
"    token #4, #5, #7, #8…  → defTriplet45 (color B)
syntax match defTriplet3 /\(\s\+\S\+\)\{2}\s\+\zs\S\+/ contained containedin=defCode
highlight link defTriplet3 Constant

syntax match defTriplet4 /\(\s\+\S\+\)\{3}\s\+\zs\S\+/ contained containedin=defCode
highlight link defTriplet4 Number

syntax match defTriplet5 /\(\s\+\S\+\)\{4}\s\+\zs\S\+/ contained containedin=defCode
highlight link defTriplet5 Number

" 6) hiaddress directive — ONLY when alone on a line (optional trailing // comment)
"    Example:  hiaddress C9FE
"              hiaddress C9FE // note
syntax match defHiAddress /^\s*\chiaddress\>\s\+\x\+\s*\%(\/\/.*\)\?$/ contains=defHiAddressNum,defComment
highlight link defHiAddress Statement

" emphasize just the numeric payload (inside the directive)
syntax match defHiAddressNum /\c^\s*hiaddress\>\s\+\zs\x\+/ contained
highlight link defHiAddressNum Special

