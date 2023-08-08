## Simple benchmark

import std/[times, strutils]
import checksums/sha2
import hashlib//mhash/sha512
import hashlib/rhash/sha512
import hashlib/sph/sha512
import hashlib/misc/crypto
import nimcrypto/sha2

template timeit(body: untyped) =
  let a = cpuTime()
  body
  let b = cpuTime()
  echo b - a

proc sha512_checksums(s: string): string =
  # ~15s/Mhash Too slow.
  var hasher = initSha_512()
  hasher.update(s)
  hasher.digest.`$`

proc sha512_rhash(s: string): string =
  ## ~1.1s/Mhash
  count[RHASH_SHA512](s).`$`

proc sha512_mhash(s: string): string =
  ## ~1.2s/Mhash
  count[MHASH_SHA512](s).`$`

proc sha512_sph(s: string): string =
  ## ~1.1s/Mhash
  count[SPH_SHA512](s).`$`

proc sha512_nimcrypto2(s: string): string =
  ## ~1.1s/Mhash Much slower than sha512_nimcrypto
  count[NIMCRYPTO_SHA512](s).`$`

proc sha512_nimcrypto(s: string): string =
  ## ~0.77s/Mhash
  var ctx: sha512
  init(ctx)
  ctx.update(s)
  ctx.finish().`$`

for fun in [sha512_rhash, sha512_mhash, sha512_sph, sha512_nimcrypto2, sha512_nimcrypto]:
  timeit:
    for i in 1..1000000:
      discard fun($i & "FSEnBSUSusdHf5sd9eS5thkpMVLb_TIUuoNKm1gbq0Y")
