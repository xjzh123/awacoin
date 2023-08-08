import std/[osproc, strformat, strutils, sugar]

proc brute*(hash, salt, hashcatdir, hashcatexe: string): string =
  let temp = &"{hash}:{salt}"
  discard execProcess(hashcatexe, args = ["-a", "3", "-m", "1710", temp, "?d?d?d?d?d?d?d?d"], workingDir=hashcatdir, options={poStdErrToStdOut})
  return execProcess(hashcatexe, args = ["-a", "3", "-m", "1710", temp, "?d?d?d?d?d?d?d?d", "--show", "--outfile-format", "2"], workingDir=hashcatdir, options={poStdErrToStdOut}).dup(stripLineEnd())
