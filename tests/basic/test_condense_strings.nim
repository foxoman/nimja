discard """
  joinable: false
"""
# see  #12

include ../../src/nimja/parser
import sequtils, unittest

block:
  var beforeCondens = @[
    NwtNode(kind: NStr, strBody: "foo"),
    NwtNode(kind: NComment, commentBody: "comment"),
    NwtNode(kind: NStr, strBody: "foo"),
    NwtNode(kind: NComment, commentBody: "comment"),
    NwtNode(kind: NStr, strBody: "foo")
  ]

  var beforeCondens2 = @[
    NwtNode(kind: NStr, strBody: "foo"),
    NwtNode(kind: NStr, strBody: "foo"),
    NwtNode(kind: NStr, strBody: "foo")
  ]

  var afterCondense = @[
    NwtNode(kind: NStr, strBody: "foofoofoo")
  ]

  # Cannot compare directly because of:
  # Error: parallel 'fields' iterator does not work for 'case' objects
  check toSeq(condenseStrings(beforeCondens))[0].kind == afterCondense[0].kind
  check toSeq(condenseStrings(beforeCondens))[0].strBody == afterCondense[0].strBody

  check toSeq(condenseStrings(beforeCondens2))[0].kind == afterCondense[0].kind
  check toSeq(condenseStrings(beforeCondens2))[0].strBody == afterCondense[0].strBody

  const val = toSeq(compile("""foo{#comment#}foo{#comment#}foo""").condenseStrings)
  check val[0].kind == afterCondense[0].kind
  check val[0].strBody == afterCondense[0].strBody

block:
  var beforeCondens = @[
    NwtNode(kind: NStr, strBody: "foo"),
    NwtNode(kind: NStr, strBody: "foo"),
    NwtNode(kind: NVariable, variableBody: "varBody"),
    NwtNode(kind: NStr, strBody: "foo"),
    NwtNode(kind: NStr, strBody: "foo")
  ]
  var afterCondense = @[
    NwtNode(kind: NStr, strBody: "foofoo"),
    NwtNode(kind: NVariable, variableBody: "varBody"),
    NwtNode(kind: NStr, strBody: "foofoo")
  ]

  for idx in 0 .. 2:
    check toSeq(condenseStrings(beforeCondens))[idx].kind == afterCondense[idx].kind

    case toSeq(condenseStrings(beforeCondens))[idx].kind
    of NVariable:
      check toSeq(condenseStrings(beforeCondens))[idx].variableBody == afterCondense[idx].variableBody
    of NStr:
      check toSeq(condenseStrings(beforeCondens))[idx].strBody == afterCondense[idx].strBody
    else:
      discard

# block:
#   var foo = condenseStrings(beforeCondens2)
#   foo == afterCondense

# template maybeYieldString() =
#   if curStr.len != 0:
#     result.add NwtNode(kind: NStr, strBody: curStr)
#     curStr = ""

# proc condenseStrings(nodess: seq[NwtNode]): seq[NwtNode] =
#   var curStr = ""
#   for node in nodes:
#     # case node.kind
#     if node.kind == NStr:
#       curStr &= node.strBody
#     # elif node.kind == NComment:
#     #   continue
#     # else:
#     #   if curStr.len != 0:
#     #     result.add NwtNode(kind: NStr, strBody: curStr)
#     #     curStr = ""
#   # maybeYieldString # something to yield after for loop

# assert beforeCondens.condenseStrings() == afterCondense

# assert toSeq(beforeCondens.condenseStrings()) == afterCondense
# assert toSeq(beforeCondens2.condenseStrings()) == afterCondense
# assert toSeq(compile("""foo{#comment#}foo{#comment#}foo""").condenseStrings()) == afterCondense