# LONE: List of Ordered Named Elements
#
# Think: an ordered dictionary but with non-unique keys

## Code to create:
##
## .. code:: slone
##
##     #! SLONE 1.0
##     _ = (person) {*
##       "full_name" : "name" = "Larry Smith"
##       "main home" : "building" = {
##         "mailing address" : address = {
##           "street" : string_array = {
##             _ : string = "1234 Main St"
##             _ : string = "Unit 3"
##           }
##           "postal code" = "90210"
##         }
##       }
##     }
##
## .. code:: nim
##
##     # test.nim
##     #
##     import lone
##     
##     # first way (to x):
##     #
##     var x = Lone()
##     x[nothing] = ("person", Lone())
##     x[nothing]["full_name"] = ("name", "Larry Smith")
##     x[nothing]["main home"] = ("building", Lone())
##     x[nothing]["main home"]["mailing address"] = ("address", Lone())
##     x[nothing]["main home"]["mailing address"]["street"] = ("string_array", Lone())
##     x[nothing]["main_home"]["mailing address"]["street"].add (nothing, "string", "1234 Main St")
##     x[nothing]["main_home"]["mailing address"]["street"].add (nothing, "string", "Unit 3")
##     x[nothing]["main_home"]["mailing address"]["postal code"] = "90210"
##     
##     # another way (to y):
##     #
##     var streetAddress = @["1234 Main St", "Unit 3"]
##     var mailingAddress = Lone()
##     mailingAddress["street"] = streetAddress.toLone("string_array")
##     mailingAddress["postal code"] = "90210"
##     var mainHome = Lone()
##     mainHome["mailing address"] = mailingAddress
##     var person = Lone()
##     person["full_name"] = ("name", "Larry Smith")
##     person["main home"] = ("building", mainHome)     
##     var y = Lone()
##     y[nothing] = ("person", person)
##
##     # using a type schema (to z):
##     #
##     var z = newLoan()
##     var person = Lone()(personSchema)   # see section on schema support
##     person["full_name"] = "Larry Smith"
##     person["main_home"]["mailing address"]["street"].addItem "1234 Main St"  # 'addItem' adds an entry with name of nothing and a default type
##     person["main_home"]["mailing address"]["street"].addItem "Unit 3"
##     person["main_home"]["mailing address"]["postal code"] = "90210"
##     z.addItem person   # z does not have a schema, so the attrType defaults to nothing
##     

#
# type declarations
#

import
  Options,
  strformat,
  std/strutils

type
  LoneNothing = object
    nil

type
  LoneNull = object
    nil

type
  LoneKind* = enum
    LvNull,
    LvNothing,
    LvString,
    LvLone
  Lone* = ref LoneObj
  LoneObj = object
    name*: Option[string]
    attrType*: Option[string]
    case kind*: LoneKind
    of LvNull:
      nil
    of LvNothing:
      nil
    of LvString:
      str*: string
    of LvLone:
      entries*: seq[Lone]

type
  NameIndexTuple = tuple[name: string, index: int]
  NothingIndexTuple = tuple[name: LoneNothing, index: int]

type
  TypeValueStringStringTuple = tuple[attrType: string, value: string]
  TypeValueNothingStringTuple = tuple[attrType: LoneNothing, value: string]
  TypeValueStringNullTuple = tuple[attrType: string, value: LoneNull]
  TypeValueNothingNullTuple = tuple[attrType: LoneNothing, value: LoneNull]
  TypeValueStringLoneTuple = tuple[attrType: string, value: Lone]
  TypeValueNothingLoneTuple = tuple[attrType: LoneNothing, value: Lone]

const
  nothing* = LoneNothing()
  null* = LoneNull()

#
# internal utility
#
proc findEntry(this: Lone, name: Option[string], nameIndex: int): int =
  result = -1
  case this.kind:
  of LvNull:
    discard
  of LvNothing:
    discard
  of LvString:
    discard
  of LvLone:
    var indexTrack: int = -1
    for loneIndex, entry in this.entries.pairs:
      if entry.name == name:
        indexTrack += 1
        if nameIndex  == indexTrack:
          result = loneIndex
          break

proc countOf(this: Lone, name: Option[string]): int =
  # this procedure presumes `this` is of type LvLone
  result = 0
  for entry in this.entries:
    if entry.name == name:
      result += 1

# recursively create a clean deep copy of a lone.
proc deepCopy*(this: Lone): Lone =
  case this.kind:
  of LvNull:
    result = Lone(kind: LvNull)
    result.name = this.name
    result.attrType = this.attrType
  of LvNothing:
    result = this
  of LvString:
    result = Lone(kind: LvString)
    result.name = this.name
    result.attrType = this.attrType
    result.str = this.str
  of LvLone:
    result = Lone(kind: LvLone)
    result.name = this.name
    result.attrType = this.attrType
    result.entries = newSeq[Lone]()
    for entry in this.entries:
      result.entries.add deepCopy(entry)

#
# entry creation
#

proc newLone*(name: Option[string], attrType: Option[string], value: Lone): Lone =
  var cleanType = none(string)
  if attrType.isSome:
    cleanType = some(attrType.get().strip())
  result = Lone(
    name: name,
    attrType: cleanType,
    kind: LvLone,
    entries: newSeq[Lone]()
  )
  for entry in value.entries:
    result.entries.add deepCopy(entry)

proc newLone*(): Lone =
  result = Lone(
    name: none(string),
    attrType: none(string),
    kind: LvLone,
    entries: newSeq[Lone]()
  )

proc newNull(name: Option[string], attrType: Option[string]): Lone =
  var cleanType = none(string)
  if attrType.isSome:
    cleanType = some(attrType.get().strip())
  result = Lone(
    name: name,
    attrType: cleanType,
    kind: LvNull
  )

proc newNothing(name: Option[string], attrType: Option[string]): Lone =
  var cleanType = none(string)
  if attrType.isSome:
    cleanType = some(attrType.get().strip())
  result = Lone(
    name: name,
    attrType: cleanType,
    kind: LvNothing
  )

proc newString(name: Option[string], attrType: Option[string], value: string): Lone =
  var cleanType = none(string)
  if attrType.isSome:
    cleanType = some(attrType.get().strip())
  result = Lone(
    name: name,
    attrType: cleanType,
    kind: LvString,
    str: value
  )

proc retrieveRef(this: var Lone, key: Option[string], index: int): Lone =
  let foundIndex = findEntry(this, key, index)
  if foundIndex < -1:
    result = newNothing(key, none(string))
  else:
    result = this.entries[foundIndex]

#
# bracketed read at presumed-index-0
#
proc `[]`*(this: var Lone, key: string): Lone = this.retrieveRef(some(key), 0)
proc `[]`*(this: var Lone, key: LoneNothing): Lone = this.retrieveRef(none(string), 0)
proc `[]`*(this: var Lone, key: LoneNull): Lone = raise newException(IndexDefect, "(Lone) A name cannot be null.")
#
# bracketed read with name/index tuple
#

proc assign(this: var Lone, index: int, value: Lone) =
  case this.kind:
  of LvNull:
    raise newException(IndexDefect, "(Lone) Attempted to add a field to null. You cannot treat a null as a document.")
  of LvNothing:
    raise newException(IndexDefect, "(Lone) Attempted to add a field to nothing. You cannot treat nothing as a document.")
  of LvString:
    raise newException(IndexDefect, "(Lone) Attempted to add a field to a string. You cannot treat a string as a document.")
  of LvLone:
    let key = value.name
    let attrType = value.attrType
    let foundIndex = findEntry(this, key, index)
    if foundIndex < 0:
      if (0 == index) and (0 == this.countOf(key)):
        this.entries.add value
      else:
        raise newException(IndexDefect, fmt"Name `{key}` with index {index} not found.")
    else:
      this.entries[foundIndex] = value

#######################################################
#
# bracketed assignments at presumed-index-0
#
#######################################################

# TODO: chaining a["1"]["2"] = "3" does not work. Look at making proc {.inline.} and making 'assign' a template

proc `[]=`*(this: var Lone, key: string, value: Lone) = this.assign 0, newLone(some(key), none(string), value)
proc `[]=`*(this: var Lone, key: string, value: string) = this.assign 0, newString(some(key), none(string), value)
# proc `[]=`*(this: var Lone, key: string, value: LoneNothing) = means delete
proc `[]=`*(this: var Lone, key: string, value: LoneNull) = this.assign 0, newNull(some(key), none(string))
#
proc `[]=`*(this: var Lone, key: LoneNothing, value: Lone) = this.assign 0, newLone(none(string), none(string), value)
proc `[]=`*(this: var Lone, key: LoneNothing, value: string) = this.assign 0, newString(none(string), none(string), value)
# proc `[]=`*(this: var Lone, key: LoneNothing, value: LoneNothing) = means delete
proc `[]=`*(this: var Lone, key: LoneNothing, value: LoneNull) = this.assign 0, newNull(none(string), none(string))
#
#  THE FOLLOWING IS BETTER SERVED AS A COMPILER ERROR
# proc `[]=`*(this: var Lone, key: LoneNull, value: Lone) = raise newException(IndexDefect, "(Lone) A name cannot be null.")
# proc `[]=`*(this: var Lone, key: LoneNull, value: string) = raise newException(IndexDefect, "(Lone) A name cannot be null.")
# proc `[]=`*(this: var Lone, key: LoneNull, value: LoneNothing) = raise newException(IndexDefect, "(Lone) A name cannot be null.")
# proc `[]=`*(this: var Lone, key: LoneNull, value: LoneNull) = raise newException(IndexDefect, "(Lone) A name cannot be null.")

proc `[]=`*(this: var Lone, key: string, tup: (string, Lone) ) = this.assign 0, newLone(some(key), some(tup[0]), tup[1])
proc `[]=`*(this: var Lone, key: string, tup: (string, string) ) = this.assign 0, newString(some(key), some(tup[0]), tup[1])
proc `[]=`*(this: var Lone, key: string, tup: (string, LoneNull) ) = this.assign 0, newNull(some(key), some(tup[0]))
#
proc `[]=`*(this: var Lone, key: LoneNothing, tup: (string, Lone) ) = this.assign 0, newLone(none(string), some(tup[0]), tup[1])
proc `[]=`*(this: var Lone, key: LoneNothing, tup: (string, string) ) = this.assign 0, newString(none(string), some(tup[0]), tup[1])
proc `[]=`*(this: var Lone, key: LoneNothing, tup: (string, LoneNull) ) = this.assign 0, newNull(none(string), some(tup[0]))

#
# bracketed assignment with name/index tuple
#
# TBD


# assignment of a string without a attrType (type is nothing)


proc getType*(this: Lone): Option[string] =
  result = this.attrType

proc getString*(this: Lone): string =
  case this.kind:
  of LvString:
    result = this.str
  of LvNull:
    raise newException(FieldDefect, "Cannot `getString` on a null value. There is a version of `getString` that supports a default on non-strings.")
  of LvNothing:
    raise newException(FieldDefect, "Cannot `getString` on a missing value. There is a version of `getString` that supports a default on non-strings.")
  of LvLone:
    raise newException(FieldDefect, "Cannot `getString` on subtending LONE. There is a version of `getString` that supports a default on non-strings.")

proc getString*(this: Lone, default: string): string =
  if this.kind == LvString:
    result = this.str
  else:
    result = default

proc `$`*(this: Lone): string =
  result = "Lone("
  case this.kind:
  of LvNull:
    result &= "null"
  of LvNothing:
    result &= "nothing"
  of LvString:
    result &= "string=\"" & this.str & "\""
  of LvLone:
    result &= "object"
  result &= ")"

# # ---------------------------------------------------------
# #
# # comparisons
# #
# #

# proc isNull*(this: LoneEntryReference): bool =
#   case this.value.kind:
#   of LvNull:
#     result = true
#   of LvString:
#     result = false
#   of LvLone:
#     result = false

# proc isString*(this: LoneEntryReference): bool =
#   case this.value.kind:
#   of LvNull:
#     result = false
#   of LvString:
#     result = true
#   of LvLone:
#     result = false

# proc isLone*(this: LoneEntryReference): bool =
#   case this.value.kind:
#   of LvNull:
#     result = false
#   of LvString:
#     result = false
#   of LvLone:
#     result = true

# proc `==`*(this: LoneEntryReference, other: LoneEntryReference): bool =
#   if this.value.kind != other.value.kind:
#     return false
#   if this.attrType != other.attrType:
#     return false
#   case this.value.kind:
#   of LvNull:
#     discard
#   of LvString:
#     if this.value.str != other.value.str:
#       return false
#   of LvLone:
#     if this.value.entries.len == other.value.entries.len:
#       if this.value.entries.len == 0:
#         return true
#       else:
#         raise newException(IndexDefect, "TBD not ready for this yet.")
#     else:
#       return false
#   return true

proc `==`*(this: LoneNothing, other: Option[string]): bool =
  result = other.isNone

proc `==`*(this: Option[string], other: LoneNothing): bool =
  result = this.isNone

proc `==`*(this: string, other: Option[string]): bool =
  if other.isSome:
    result = other.get == this

proc `==`*(this: Option[string], other: string): bool =
  if this.isSome:
    result = this.get == other


iterator items*(this: Lone): Lone =
  case this.kind:
  of LvNull:
    discard
  of LvNothing:
    discard
  of LvString:
    discard
  of LvLone:
    for entry in this.entries:
      yield entry