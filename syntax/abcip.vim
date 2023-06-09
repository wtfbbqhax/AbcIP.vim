" Language: ABCIP
" Maintainer: Victor Roemer <victor@badsec.org>
" Last Change: 2023 June 6

" don't do anything if user assigned syntax
if exists("b:current_syntax")
  finish
endif

" Include '.' and ':' as keyword characters for syntax lookups
syn iskeyword @,46,48-57,192-255

" Make sure to ommit : in number check, I don't want to match 3:a=80
syn match abcNumber "\d\+:\@!" contained display
syn match abcNumber "0x\x\+:\@!" contained display
syn match abcNumber "\.\d\+" contained display
syn match abcNumber "\d\+\.\d\+" contained display

" String literals
syn region abcHexEsc contained start='|' end='|'
syn match abcSpecial display contained "\\\(\\\||\|\"\)"
syn region abcString start=+L\="+ skip=+\\\\\|\\"+ end=+"+
  \ contained contains=abcSpecial,abcHexEsc

" ABCIP d(stack="")
syn keyword abcDefineOption stack contained

" Protocol names are used in a,b, and c commands.
syn keyword abcProtoName contained
  \ arp dst6 eth frag6 gre hop6 icmp4 icmp6 ip4 ip6 modbus mpls phy
  \ ppp pppoe raw rte6 tcp udp vlan

" matches the legacy protocol layer syntax
syn match abcProtoIndex "\<\d\+\ze:\w\+" contained

" ABCIP c( ... )
syn keyword abcConfigOption contained
  \ a a.data a.file a.gr a.if a.reset a.rip a.rip6 a.rtp
  \ b b.data b.file b.gr b.if b.reset b.rip b.rip6 b.rtp
  \ as fid sec seed snap

" ABCIP a( ... ) and b( ... )
syn keyword abcProtoOptions contained
  \ ack addr bos cfi cid cks code ctl data df drop dst dt ecn fill
  \ fin frag func head hops hwn hwt id ihl ipn ipt jack jump key
  \ lab len lse m max mf mss next off op opt pay pcp perm pid plen
  \ pro psh r2 res rev rf rst segs seq shw sid sip src sre syn
  \ tail tcl thw tid tip tos tot tse tsv ttl type u32 uid ulen una
  \ urg vcl ver vid win wis

" "user" appears as both a protocol name and option.
" Ex. `a (phy:head="123", user="abc"; user:pay="xyz")`
syn match abcProtoName "user\ze:" contained
syn match abcProtoOptions "\<user\>\ze=" contained

" Comment magic
syn keyword abcTodo TODO FIXME XXX contained
syn region abcComment display oneline start='#' end='$'
  \ contains=abcTodo,@Spell

" ABCIP Regions
syn region abcDefinedRegion start="\<\([A-Za-z0-9]\+:\)\?d\s*(" skip="\n" end=")"
  \ contains=abcString,abcComment,abcDefineOption,abcNumber fold

syn region abcConfigRegion matchgroup=Normal start="\<\([A-Za-z0-9]\+:\)\?c\s*(" skip="\n" end=")"
  \ contains=abcString,abcComment,abcProtoName,abcProtoIndex,abcConfigOption,abcNumber fold

syn region abcABRegion start="(" end=")"
  \ contains=abcString,abcComment,abcProtoIndex,abcProtoOptions,abcProtoName,abcNumber fold

if version >= 508 || !exists("pfmain_syntax_init")
  if version < 508
      let pfmain_syntax_init = 1
      command -nargs=+ HiLink hi link <args>
  else
      command -nargs=+ HiLink hi def link <args>
  endif

  HiLink abcTodo Todo
  HiLink abcComment Comment
  HiLink abcString String
  HiLink abcSpecial Special
  HiLink abcHexEsc Special
  HiLink abcNumber Number

  HiLink abcDefineOption Define
  HiLink abcConfigOption Identifier
  HiLink abcProtoName Identifier
  HiLink abcProtoIndex Identifier
  HiLink abcProtoOptions Keyword

  " This is an attempt to 're-sync' the syntax highlighting
  syntax sync match syncComment grouphere abcComment "#\.*$"

  delcommand HiLink
endif

let b:current_syntax = "abcip"
