import std/[os, strutils, strformat, httpclient, uri, json, parseopt, threadpool, cpuinfo]
import nimcrypto/sha2

proc print(s: string) =
  let s = s & "\n"
  discard stdout.writeBuffer(cstring(s), len(s))

const
  WalletPath = ".awacoin_wallet"
  Host = parseUri("https://coin.awa.ac.cn/")
  ApiRegister = Host / "api/v1/register"
  ApiChunkDiff = Host / "api/v1/get_chunk_diff"
  ApiTransfer = Host / "api/v1/transfer"
  ApiBalance = Host / "api/v1/getbalance"
  ApiHash = Host / "api/v1/mine/create"
  ApiSubmit = Host / "api/v1/mine/finish"

let headers = newHttpHeaders({"Content-Type": "application/x-www-form-urlencoded"})

func sha512_nimcrypto(s: string): string =
  var ctx: sha512
  init(ctx)
  ctx.update(s)
  ctx.finish().`$`

proc minecoin(account, password: string, diff: int) =
  let headers = newHttpHeaders({"Content-Type": "application/x-www-form-urlencoded"}) # For GC-Safety
  let client = newHttpClient(headers = headers)
  let res = client.postContent(ApiHash, body = encodeQuery({"account": account,
      "password": password})).parseJson
  let (id, salt, hash) = (res["id"].getStr, res["salt"].getStr, res["hash"].getStr)
  print &"Mining id: {id}, salt: {salt}, hash: {hash}"
  for i in 0..diff:
    if sha512_nimcrypto($i & salt) == hash:
      print &"Got {i}(value) + {salt}(salt) for hash: {hash}"
      for j in 1..5:
        try:
          let res = client.postContent(ApiSubmit, body = encodeQuery({"id": id,
              "answer": $i})).parseJson
          if res{"error"}.getStr != "":
            print &"""Mine hash: {hash} error: {res["error"].getStr}"""
          else:
            print &"""Mine hash: {hash} success! Balance: {res["balance"].getFloat:.2f}"""
          break
        except ProtocolError as e:
          print &"{e.msg} ({j}/5 retry)"
      break
  client.close()

proc minecoin_thread(account, password: string, diff: int) {.thread.} =
  while true:
    minecoin(account, password, diff)

proc mine(account, password: string, threadcount: Positive) =
  echo &"Mining with {threadcount} threads."
  let client = newHttpClient(headers = headers)
  print "Getting chunk range."
  let diff = client.getContent(ApiChunkDiff).parseJson["diff"].getInt
  client.close()
  print &"Chunk range: {diff}"
  if threadcount == 1:
    while true:
      minecoin(account, password, diff)
  else:
    for i in 1..threadcount:
      spawn minecoin_thread(account, password, diff)
    sync()

type Mode = enum
  mMine
  mInfo
  mTransfer

proc getOptions(): (Mode, seq[string]) =
  var i = 0
  for kind, key, val in getopt():
    case kind
    of cmdArgument:
      if i == 0:
        case key
        of "mine":
          result[0] = mMine
        of "info":
          result[0] = mInfo
        of "transfer":
          result[0] = mTransfer
        else:
          print &"Unknown mode: {key}."
          quit()
        i = 1
      else:
        result[1].add key
    else:
      print &"Unsupported option: {kind}, {key}, {val}"
  if i == 0:
    print "Mode [mine/info/transfer] not found."
    quit()

when isMainModule:
  if not fileExists(WalletPath):
    print "Registering... If you dont want to use registered account, replace the .awacoin_wallet file with yours."
    let client = newHttpClient()
    let res = client.getContent(ApiRegister).parseJson()
    print &"Registered: {res}\nSaving account."
    writeFile(WalletPath, $Host & "+" & res["account"].getStr & "+" & res[
        "password"].getStr)
  let temp = readFile(WalletPath).split('+')
  let (_, account, password) = (temp[0], temp[1], temp[2])
  let (mode, args) = getOptions()
  print &"Awacoin Nim\nMode: {($mode).substr(1)} Account: {account} Arguments: {args}"
  case mode
  of mMine:
    let threadcount =
      if args.len == 1:
        args[0].parseInt
      else:
        countProcessors()
    mine(account, password, threadcount)
  of mInfo:
    let wallets =
      if args.len == 0:
        @[account]
      else:
        args
    let client = newHttpClient()
    for wallet in wallets:
      let res = client.getContent(ApiBalance ? {"account": wallet})
      print (&"""
        Info for account {wallet}: {res.strip()}
        Balance: {res.parseJson["balance"].getFloat:.2f}
      """).dedent
    client.close()
  of mTransfer:
    if args.len != 2:
      print "Target account or amount not given."
      quit()
    let (target, amount) = (args[0], args[1])
    let client = newHttpClient(headers = headers)
    let res = client.postContent(ApiTransfer, body = encodeQuery({
        "account": account, "password": password, "to": target,
        "amount": amount}))
    client.close()
    print &"Response:\n{res}"
