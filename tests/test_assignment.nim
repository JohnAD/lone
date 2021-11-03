import unittest

import lone

suite "assignment (and get)":
  test "simple set/get string at root (index=0) of name":
    var g = newLone()
    g["a"] = "1"
    check ($g["a"] == "\"1\"")
    check (g["a"].getString == "1")
    check (g["a"].getType == nothing)
    check (g["a"] == g["a"])
    #
    # g["b"] = ("int32", "2")
    # check ($g["b"] == "\"2\"")
    # check (g["b"].getString == "2")
    # check (g["b"].getType == "int32")
    # check (g["b"] == g["b"])
    #
    g[nothing] = "3"
    check ($g[nothing] == "\"3\"")
    check (g[nothing].getString == "3")
    check (g[nothing].getType == nothing)
    check (g[nothing] == g[nothing])
    #
    # g["c"] = ("string", "4")
    # check ($g["c"] == "\"4\"")
    # check (g["c"].getString == "4")
    # check (g["c"].getType == "string")
    # check (g["c"] == g["c"])

  # test "simple set/get string at name/index":
  #   var g = newLone()
  #   g[("a", 0)] = "1"
  #   check ($g[("a", 0)] == "\"1\"")
  #   check (g[("a", 0)].getString == "1")
  #   check (g[("a", 0)].getType == nothing)
  #   check (g[("a", 0)] == g["a"])
  #   #
  #   g[("b", 0)] = ("int16", "2a")
  #   g[("b", 1)] = ("int32", "2b")
  #   g[("b", 2)] = ("int64", "2c")
  #   check ($g[("b", 1)] == "\"2b\"")
  #   check (g[("b", 1)].getString == "2b")
  #   check (g[("b", 1)].getString("default") == "2b")
  #   check (g[("b", 0)].getType == "int16")
  #   check (g[("b", 1)].getType == "int32")
  #   check (g[("b", 2)].getType == "int64")
  #   check (g[("b", 0)] == g[("b", 0)])
  #   check (g[("b", 1)] == g[("b", 1)])
  #   check (g[("b", 2)] == g[("b", 2)])
  #   #
  #   g[nothing] = "3a"
  #   g[(nothing, 1)] = "3b"
  #   check ($g[nothing] == "\"3a\"")
  #   check ($g[(nothing, 1)] == "\"3b\"")
  #   check (g[(nothing, 1)].getString == "3b")
  #   check (g[(nothing, 1)].getType == nothing)
  #   check (g[(nothing, 1)] == g[(nothing, 1)])
  #   #
  #   g[("c", 0)] = ("string", "4")
  #   check ($g[("c", 0)] == "\"4\"")
  #   check (g[("c", 0)].getString == "4")
  #   check (g[("c", 0)].getType == "string")
  #   check (g[("c", 0)] == g["c"])

  # test "simple set/get null at root (index=0) of name":
  #   var g = newLone()
  #   g["a"] = null
  #   check ($g["a"] == "null")
  #   check (g["a"].getString("default") == "default")
  #   check (g["a"].getType == nothing)
  #   check (g["a"] == g["a"])
  #   #
  #   g["b"] = ("int32", null)
  #   check ($g["b"] == "null")
  #   check (g["b"].getString("default") == "default")
  #   check (g["b"].getType == "int32")
  #   check (g["b"] == g["b"])
  #   #
  #   g[nothing] = null
  #   check ($g[nothing] == "null")
  #   check (g[nothing].getString("default") == "default")
  #   check (g[nothing].getType == nothing)
  #   check (g[nothing] == g[nothing])
  #   #
  #   g["c"] = ("string", null)
  #   check ($g["c"] == "null")
  #   check (g["c"].getString("default") == "default")
  #   check (g["c"].getType == "string")
  #   check (g["c"] == g["c"])

  # test "simple set/get empty document at root (index=0) of name":
  #   var g = newLone()
  #   g["a"] = newLone()
  #   check $g["a"] == "{*\n*}"
  #   check g["a"].getString("default") == "default"
  #   check not g["a"].isNull
  #   check not g["a"].isString
  #   check g["a"].getType == nothing
  #   check g["a"] == g["a"]
  #   #
  #   g["b"] = ("object", newLone())
  #   check $g["b"] == "{*\n*}"
  #   check g["b"].getString("default") == "default"
  #   check not g["b"].isNull
  #   check not g["b"].isString
  #   check g["b"].getType == "object"
  #   check g["b"] == g["b"]
  #   #
  #   g[nothing] = newLone()
  #   check $g[nothing] == "{*\n*}"
  #   check $g[(nothing, 0)] == "{*\n*}"
  #   check g[nothing].getString("default") == "default"
  #   check not g[nothing].isNull
  #   check not g[nothing].isString
  #   check g[nothing].getType == nothing
  #   check g[nothing] == g[nothing]

  # test "add multiple entries under the same name":
  #   var g = newLone()
  #   g[("foo", 0)] = (nothing, "bar1")
  #   g[("foo", 1)] = "bar2"
  #   g[("foo", 2)] = null
  #   g[("foo", 3)] = ("int", "99")
  #   check g["foo"].getString == "bar1"
  #   check g[("foo", 1)].getString == "bar2"
  #   check g[("foo", 2)].isNull
  #   check g[("foo", 3)].getString == "99"
  #   check g[("foo", 3)].getType == "int"
  #   #
  #   g.addWithKey("bing", "bam1")
  #   g.addWithKey("bing", (nothing, "bam2"))
  #   g.addWithKey("bing", null)
  #   g.addWithKey("bing", ("int", "99"))
  #   check g["bing"].getString == "bam1"
  #   check g[("bing", 1)].getString == "bam2"
  #   check g[("bing", 2)].isNull
  #   check g[("bing", 3)].getString == "99"
  #   check g[("bing", 3)].getType == "int"
  #   #
  #   g.add newNamedEntry("a", nothing, "b1")
  #   g.add newNamedEntry("a", nothing, "b2")
  #   g.add newNamedEntry("a", nothing, null)
  #   g.add newNamedEntry("a", "int", "999")
  #   check g[("a", 0)].getString == "b1"
  #   check g[("a", 1)].getString == "b2"
  #   check g[("a", 2)].isNull
  #   check g[("a", 3)].getString == "999"
  #   check g[("a", 3)].getType == "int"
