import std/[strutils, strformat, httpclient, uri, json]
import hashcat

proc print(s: string) =
  let s = s & "\n"
  discard stdout.writeBuffer(cstring(s), len(s))

const
  WalletPath = ".awacoin_wallet"
  Host = parseUri("https://coin.awa.ac.cn/")
  ApiChunkDiff = Host / "api/v1/get_chunk_diff"
  ApiHash = Host / "api/v1/mine/create"
  ApiSubmit = Host / "api/v1/mine/finish"

let headers = newHttpHeaders({"Content-Type": "application/x-www-form-urlencoded"})

proc minecoin(account, password, hashcatdir: string, diff: int) =
  let headers = newHttpHeaders({"Content-Type": "application/x-www-form-urlencoded"}) # For GC-Safety
  let client = newHttpClient(headers = headers)
  let res = client.postContent(ApiHash, body = encodeQuery({"account": account,
      "password": password})).parseJson
  let (id, salt, hash) = (res["id"].getStr, res["salt"].getStr, res["hash"].getStr)
  print &"Mining id: {id}, salt: {salt}, hash: {hash}"
  let i = brute(hash, salt, hashcatdir)
  print &"Got {i}(value) + {salt}(salt) for hash: {hash}"
  for j in 1..5:
    try:
      let res = client.postContent(ApiSubmit, body = encodeQuery({"id": id,
          "answer": i})).parseJson
      if res{"error"}.getStr != "":
        print &"""Mine hash: {hash} error: {res["error"].getStr}"""
      else:
        print &"""Mine hash: {hash} success! Balance: {res["balance"].getFloat:.2f}"""
      break
    except ProtocolError as e:
      print &"{e.msg} ({j}/5 retry)"
  client.close()

proc mine(account, password, hashcatdir: string) =
  let client = newHttpClient(headers = headers)
  print "Getting chunk range."
  let diff = client.getContent(ApiChunkDiff).parseJson["diff"].getInt
  client.close()
  print &"Chunk range: {diff}"
  while true:
    minecoin(account, password, hashcatdir, diff)

when isMainModule:
  let temp = readFile(WalletPath).split('+')
  let (_, account, password) = (temp[0], temp[1], temp[2])
  let hashcatdir = readFile(".hashcatdir")
  print &"Awacoin Nim Hashcat Miner\nAccount: {account} Hashcat Dir: {hashcatdir}"
  mine(account, password, hashcatdir)
