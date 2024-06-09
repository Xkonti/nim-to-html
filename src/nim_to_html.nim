import std/[strutils, sequtils, macros]

# template withFile(f: untyped, filename: string, mode: FileMode,
#                   body: untyped) =
#   let fn = filename
#   var f: File
#   if open(f, fn, mode):
#     try:
#       body
#     finally:
#       close(f)
#   else:
#     quit("cannot open: " & fn)

proc formatArgument(name: string, value: string): string =
  name & "=\"" & value & "\""

proc combineArgs(args: varargs[string]): string =
  args.join(" ")

template defineArgumentsProc(arg: untyped, argName: string, argType: untyped) =
  proc arg(args: seq[string],value: argType): seq[string] =
    return args & formatArgument(argName, $value)

  proc arg(value: argType): seq[string] =
    return @[].arg(value)

defineArgumentsProc(hidden, "hidden", bool)

proc class(args: seq[string], classes: varargs[string]): seq[string] =
  return args & formatArgument("class", classes.join(" "))

proc class(classes: varargs[string]): seq[string] =
  return @[].class(classes)

proc style(args: seq[string], styles: varargs[string]): seq[string] =
  return args & formatArgument("style", styles.join(";"))

proc style(styles: varargs[string]): seq[string] =
  return @[].style(styles)

macro buttonMacro(body: untyped): untyped =
  body.expectKind nnkStmtList
  var bodyNode: NimNode = newLit("")
  for statement in body:
    bodyNode = quote do:
      `bodyNode` & `statement`
  quote do:
    "<button>" & `bodyNode` & "</button>"

macro combineStatements(body: untyped): untyped =
  body.expectKind nnkStmtList
  var bodyNode: NimNode = newLit("")
  for statement in body:
    bodyNode = quote do:
      `bodyNode` & `statement`
  return bodyNode


template defineTagWithBody(tagDef: untyped, tagName: string) =
  macro tagDef(body: untyped): string =
    #body.expectKind nnkStmtList
    result = newLit("")
    for statement in body:
      result = newCall("&", result, statement)
    result = quote do:
      "<" & tagName & ">" & `result` & "</" & tagName & ">"

  # macro tagDef(args: seq[string], body: untyped): untyped =
  #   body.expectKind nnkStmtList
  #   var bodyNode: NimNode = newLit("")
  #   for statement in body:
  #     bodyNode = quote do:
  #       `bodyNode` & `statement`
  #   quote do:
  #     "<" & tagName & " " & args.combineArgs & ">" & `bodyNode` & "</" & tagName & ">"

  # template tagDef(args: seq[string], body: untyped): string =
  #   const bodyString = myMacro:
  #     body
  #   "<" & tagName & " " & args.combineArgs & ">" & bodyString & "</" & tagName & ">"

defineTagWithBody(button, "button")
defineTagWithBody(bDiv, "div")
defineTagWithBody(span, "span")
defineTagWithBody(p, "p")
defineTagWithBody(article, "article")
defineTagWithBody(main, "main")
defineTagWithBody(a, "a")
defineTagWithBody(body, "body")
defineTagWithBody(head, "head")
defineTagWithBody(html, "html")
defineTagWithBody(nav, "nav")


const htmlString = html:
  body:
    main:
      button:
        "Home"
      button:
        "About"
    article:
      p:
        "Hello There!"

echo htmlString