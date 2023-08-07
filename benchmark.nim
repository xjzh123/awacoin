import std/[times, strutils]
import checksums/sha2
import hashlib
import nimcrypto

template timeit(body: untyped) =
  let a = cpuTime()
  body
  let b = cpuTime()
  echo b - a

proc sha512_checksums(s: string): string =
  var hasher = initSha_512()
  hasher.update(s)
  hasher.digest.`$`

proc sha512_rhash(s: string): string =
  count[RHASH_SHA512](s).`$`

proc sha512_mhash(s: string): string =
  count[MHASH_SHA512](s).`$`

proc sha512_nimcrypto(s: string): string =
  var ctx: sha512
  init(ctx)
  ctx.update(s)
  ctx.finish().`$`
  
for fun in [sha512_checksums, sha512_rhash, sha512_mhash, sha512_nimcrypto]:
  timeit:
    for i in 1..1000000:
      discard fun($i & "FSEnBSUSusdHf5sd9eS5thkpMVLb_TIUuoNKm1gbq0Y")
