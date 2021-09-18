# LONE: List of Ordered Named Elements
#
# Think: an ordered dictionary but with non-unique keys

## Code to create:
##
## .. code:: slone
##
##     #! SLONE 1.0
##     _ = (person) {*
##       "full_name" = (name) "Larry Smith"
##       "main home" = (building) {*
##         "mailing address" = (address) {*
##           "street" = (string_array) {*
##             _ = (string) "1234 Main St"
##             _ = (string) "Unit 3"
##           *}
##           "postal code" = _ "90210"
##         *}
##       *}
##     *}
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
  options,
  strformat

type
  LoneNothing = object
    nil

type
  LoneNull = object
    nil

type
  LoneValueKind* = enum
    LvNull,
    LvString,
    LvLone
  LoneValue* = object
    case kind*: LoneValueKind
    of LvNull:
      nil
    of LvString:
      str*: string
    of LvLone:
      entries*: seq[NamedEntry]  
  NamedEntry* = object
    name*: Option[string]
    attrType*: Option[string]
    value*: LoneValue

type
  NameIndexTuple = tuple[name: string, index: int]
  NothingIndexTuple = tuple[name: LoneNothing, index: int]

type
  Lone* = seq[NamedEntry]

type
  LoneEntryReference* = object
    parentRef: Lone
    name*: Option[string]
    index*: int
    attrType*: Option[string]
    value*: LoneValue

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
  var indexTrack: int = -1
  for loneIndex, entry in this.pairs:
    if entry.name == name:
      indexTrack += 1
      if nameIndex  == indexTrack:
        result = loneIndex
        break

proc findEntry(this: Lone, name: string, nameIndex: int): int =
  result = this.findEntry(some(name), nameIndex)

proc findEntry(this: Lone, name: LoneNothing, nameIndex: int): int =
  result = this.findEntry(none(string), nameIndex)

proc countOf(this: Lone, name: Option[string]): int =
  result = 0
  for entry in this.items:
    if entry.name == name:
      result += 1
#
# entry creation
#

proc newLone*(): Lone =
  discard

#  pure version. It is not likely an end-user will use this version.
proc add*(this: var Lone, name: Option[string], attrType: Option[string], value: LoneValue) =
  var newEntry = NamedEntry()
  newEntry.name = name
  newEntry.attrType = attrType
  newEntry.value = value
  this.add newEntry

# recursively create a clean deep copy of a lone.
proc deepCopy*(this: Lone): Lone =
  for entry in this.items:
    if entry.value.kind == LvLone:
      result.add(entry.name, entry.attrType, entry.value.deepCopy)
    else:
      result.add(entry.name, entry.attrType, entry.value)


# ---------- string value ----------------
proc newNamedEntry*(name: string, attrType: string, value: string): NamedEntry =
  result = NamedEntry(
    name: some(name),
    attrType: some(attrType),
    value: LoneValue(kind: LvString, str: value)
  )
proc newNamedEntry*(name: LoneNothing, attrType: string, value: string): NamedEntry =
  result = NamedEntry(
    name: none(string),
    attrType: some(attrType),
    value: LoneValue(kind: LvString, str: value)
  )
proc newNamedEntry*(name: string, attrType: LoneNothing, value: string): NamedEntry =
  result = NamedEntry(
    name: some(name),
    attrType: none(string),
    value: LoneValue(kind: LvString, str: value)
  )
proc newNamedEntry*(name: LoneNothing, attrType: LoneNothing, value: string): NamedEntry =
  result = NamedEntry(
    name: none(string),
    attrType: none(string),
    value: LoneValue(kind: LvString, str: value)
  )
# ---------- null value ----------------
proc newNamedEntry*(name: string, attrType: string, value: LoneNull): NamedEntry =
  result = NamedEntry(
    name: some(name),
    attrType: some(attrType),
    value: LoneValue(kind: LvNull)
  )
proc newNamedEntry*(name: LoneNothing, attrType: string, value: LoneNull): NamedEntry =
  result = NamedEntry(
    name: options.none(string),
    attrType: some(attrType),
    value: LoneValue(kind: LvNull)
  )
proc newNamedEntry*(name: string, attrType: LoneNothing, value: LoneNull): NamedEntry =
  result = NamedEntry(
    name: some(name),
    attrType: none(string),
    value: LoneValue(kind: LvNull)
  )
proc newNamedEntry*(name: LoneNothing, attrType: LoneNothing, value: LoneNull): NamedEntry =
  result = NamedEntry(
    name: none(string),
    attrType: none(string),
    value: LoneValue(kind: LvNull)
  )
# ---------- lone value ----------------
proc newNamedEntry*(name: string, attrType: string, value: Lone): NamedEntry =
  result = NamedEntry(
    name: some(name),
    attrType: some(attrType),
    value: LoneValue(kind: LvLone, entries: value.deepCopy)
  )
proc newNamedEntry*(name: LoneNothing, attrType: string, value: Lone): NamedEntry =
  result = NamedEntry(
    name: none(string),
    attrType: some(attrType),
    value: LoneValue(kind: LvLone, entries: value.deepCopy)
  )
proc newNamedEntry*(name: string, attrType: LoneNothing, value: Lone): NamedEntry =
  result = NamedEntry(
    name: some(name),
    attrType: none(string),
    value: LoneValue(kind: LvLone, entries: value.deepCopy)
  )
proc newNamedEntry*(name: LoneNothing, attrType: LoneNothing, value: Lone): NamedEntry =
  result = NamedEntry(
    name: none(string),
    attrType: none(string),
    value: LoneValue(kind: LvLone, entries: value.deepCopy)
  )


# assignment of a string without a attrType (type is nothing)

## ex: abc["foo"] = "bar"
proc `[]=`*(this: var Lone, name: string, value: string) =
  let loc = this.findEntry(name, 0)
  if (loc >= 0):
    this[loc] = newNamedEntry(name, nothing, value)
  else:
    this.add newNamedEntry(name, nothing, value)

## ex: abc[nothing] = "bar"
proc `[]=`*(this: var Lone, name: LoneNothing, value: string) =
  let loc = this.findEntry(nothing, 0)
  if (loc >= 0):
    this[loc] = newNamedEntry(nothing, nothing, value)
  else:
    this.add newNamedEntry(nothing, nothing, value)

## ex: abc[("foo", 2)] = "bar"
proc `[]=`*(this: var Lone, ni: NameIndexTuple, value: string) =
  let loc = this.findEntry(ni.name, ni.index)
  if (loc >= 0):
    this[loc] = newNamedEntry(ni.name, nothing, value)
  else:
    if this.countOf(some(ni.name)) == ni.index:
      this.add newNamedEntry(ni.name, nothing, value)
    else:
      raise newException(IndexDefect, fmt"Name `{ni.name}` with index {ni.index} not found.")

## ex: abc[(nothing, 2)] = "bar"
proc `[]=`*(this: var Lone, ni: NothingIndexTuple, value: string) =
  let loc = this.findEntry(nothing, ni.index)
  if (loc >= 0):
    this[loc] = newNamedEntry(nothing, nothing, value)
  else:
    if this.countOf(none(string)) == ni.index:
      this.add newNamedEntry(nothing, nothing, value)
    else:
      raise newException(IndexDefect, fmt"Name nothing with index {ni.index} not found.")

# assignment of a null without a type

## ex: abc["foo"] = null
proc `[]=`*(this: var Lone, name: string, value: LoneNull) =
  let loc = this.findEntry(name, 0)
  if (loc >= 0):
    this[loc] = newNamedEntry(name, nothing, null)
  else:
    this.add newNamedEntry(name, nothing, null)

## ex: abc[nothing] = null
proc `[]=`*(this: var Lone, name: LoneNothing, value: LoneNull) =
  let loc = this.findEntry(nothing, 0)
  if (loc >= 0):
    this[loc] = newNamedEntry(nothing, nothing, null)
  else:
    this.add newNamedEntry(nothing, nothing, null)

## ex: abc[("foo", 2)] = null
proc `[]=`*(this: var Lone, ni: NameIndexTuple, value: LoneNull) =
  let loc = this.findEntry(ni.name, ni.index)
  if (loc >= 0):
    this[loc] = newNamedEntry(ni.name, nothing, null)
  else:
    if this.countOf(some(ni.name)) == ni.index:
      this.add newNamedEntry(ni.name, nothing, null)
    else:
      raise newException(IndexDefect, fmt"Name `{ni.name}` with index {ni.index} not found.")

## ex: abc[(nothing, 2)] = null
proc `[]=`*(this: var Lone, ni: NothingIndexTuple, value: LoneNull) =
  let loc = this.findEntry(nothing, ni.index)
  if (loc >= 0):
    this[loc] = newNamedEntry(nothing, nothing, null)
  else:
    if this.countOf(none(string)) == ni.index:
      this.add newNamedEntry(nothing, nothing, null)
    else:
      raise newException(IndexDefect, fmt"Name nothing with index {ni.index} not found.")

# assignment of a Lone without a type

## ex: abc["foo"] = Lone()
proc `[]=`*(this: var Lone, name: string, value: Lone) =
  let loc = this.findEntry(name, 0)
  if (loc >= 0):
    this[loc] = newNamedEntry(name, nothing, value)
  else:
    this.add newNamedEntry(name, nothing, value)

## ex: abc[nothing] = Lone()
proc `[]=`*(this: var Lone, name: LoneNothing, value: Lone) =
  let loc = this.findEntry(nothing, 0)
  if (loc >= 0):
    this[loc] = newNamedEntry(nothing, nothing, value)
  else:
    this.add newNamedEntry(nothing, nothing, value)

## ex: abc[("foo", 2)] = Lone()
proc `[]=`*(this: var Lone, ni: NameIndexTuple, value: Lone) =
  let loc = this.findEntry(ni.name, ni.index)
  if (loc >= 0):
    this[loc] = newNamedEntry(ni.name, nothing, value)
  else:
    if this.countOf(some(ni.name)) == ni.index:
      this.add newNamedEntry(ni.name, nothing, value)
    else:
      raise newException(IndexDefect, fmt"Name `{ni.name}` with index {ni.index} not found.")

## ex: abc[(nothing, 2)] = Lone()
proc `[]=`*(this: var Lone, ni: NothingIndexTuple, value: Lone) =
  let loc = this.findEntry(nothing, ni.index)
  if (loc >= 0):
    this[loc] = newNamedEntry(nothing, nothing, value)
  else:
    if this.countOf(none(string)) == ni.index:
      this.add newNamedEntry(nothing, nothing, value)
    else:
      raise newException(IndexDefect, fmt"Name nothing with index {ni.index} not found.")

# assignment of a (type, value) as (string, string)

## ex: abc["foo"] = ("title", "bar")
proc `[]=`*(this: var Lone, name: string, tv: TypeValueStringStringTuple) =
  let loc = this.findEntry(name, 0)
  if (loc >= 0):
    this[loc] = newNamedEntry(name, tv[0], tv[1])
  else:
    this.add newNamedEntry(name, tv[0], tv[1])

## ex: abc[nothing] = ("title", "bar")
proc `[]=`*(this: var Lone, name: LoneNothing, tv: TypeValueStringStringTuple) =
  let loc = this.findEntry(nothing, 0)
  if (loc >= 0):
    this[loc] = newNamedEntry(nothing, tv[0], tv[1])
  else:
    this.add newNamedEntry(nothing, tv[0], tv[1])

## ex: abc[("foo", 2)] = ("title", "bar")
proc `[]=`*(this: var Lone, ni: NameIndexTuple, tv: TypeValueStringStringTuple) =
  let loc = this.findEntry(ni.name, ni.index)
  if (loc >= 0):
    this[loc] = newNamedEntry(ni.name, tv[0], tv[1])
  else:
    if this.countOf(some(ni.name)) == ni.index:
      this.add newNamedEntry(ni.name, tv[0], tv[1])
    else:
      raise newException(IndexDefect, fmt"Name `{ni.name}` with index {ni.index} not found.")

## ex: abc[(nothing, 2)] = ("title", "bar")
proc `[]=`*(this: var Lone, ni: NothingIndexTuple, tv: TypeValueStringStringTuple) =
  let loc = this.findEntry(nothing, ni.index)
  if (loc >= 0):
    this[loc] = newNamedEntry(nothing, tv[0], tv[1])
  else:
    if this.countOf(none(string)) == ni.index:
      this.add newNamedEntry(nothing, tv[0], tv[1])
    else:
      raise newException(IndexDefect, fmt"Name nothing with index {ni.index} not found.")

# assignment of a (type, value) as (nothing, string)

## ex: abc["foo"] = (nothing, "bar")
proc `[]=`*(this: var Lone, name: string, tv: TypeValueNothingStringTuple) =
  let loc = this.findEntry(name, 0)
  if (loc >= 0):
    this[loc] = newNamedEntry(name, tv[0], tv[1])
  else:
    this.add newNamedEntry(name, tv[0], tv[1])

## ex: abc[nothing] = (nothing, "bar")
proc `[]=`*(this: var Lone, name: LoneNothing, tv: TypeValueNothingStringTuple) =
  let loc = this.findEntry(nothing, 0)
  if (loc >= 0):
    this[loc] = newNamedEntry(nothing, tv[0], tv[1])
  else:
    this.add newNamedEntry(nothing, nothing, tv[1])

## ex: abc[("foo", 2)] = (nothing, "bar")
proc `[]=`*(this: var Lone, ni: NameIndexTuple, tv: TypeValueNothingStringTuple) =
  let loc = this.findEntry(ni.name, ni.index)
  if (loc >= 0):
    this[loc] = newNamedEntry(ni.name, tv[0], tv[1])
  else:
    if this.countOf(some(ni.name)) == ni.index:
      this.add newNamedEntry(ni.name, tv[0], tv[1])
    else:
      raise newException(IndexDefect, fmt"Name `{ni.name}` with index {ni.index} not found.")

## ex: abc[(nothing, 2)] = (nothing, "bar")
proc `[]=`*(this: var Lone, ni: NothingIndexTuple, tv: TypeValueNothingStringTuple) =
  let loc = this.findEntry(nothing, ni.index)
  if (loc >= 0):
    this[loc] = newNamedEntry(nothing, tv[0], tv[1])
  else:
    if this.countOf(none(string)) == ni.index:
      this.add newNamedEntry(nothing, tv[0], tv[1])
    else:
      raise newException(IndexDefect, fmt"Name nothing with index {ni.index} not found.")

# assignment of a (type, value) as (string, null)

## ex: abc["foo"] = ("title", null)
proc `[]=`*(this: var Lone, name: string, tv: TypeValueStringNullTuple) =
  let loc = this.findEntry(name, 0)
  if (loc >= 0):
    this[loc] = newNamedEntry(name, tv[0], tv[1])
  else:
    this.add newNamedEntry(name, tv[0], tv[1])

## ex: abc[nothing] = ("title", null)
proc `[]=`*(this: var Lone, name: LoneNothing, tv: TypeValueStringNullTuple) =
  let loc = this.findEntry(nothing, 0)
  if (loc >= 0):
    this[loc] = newNamedEntry(nothing, tv[0], tv[1])
  else:
    this.add newNamedEntry(nothing, tv[0], tv[1])

## ex: abc[("foo", 2)] = ("title", null)
proc `[]=`*(this: var Lone, ni: NameIndexTuple, tv: TypeValueStringNullTuple) =
  let loc = this.findEntry(ni.name, ni.index)
  if (loc >= 0):
    this[loc] = newNamedEntry(ni.name, tv[0], tv[1])
  else:
    if this.countOf(some(ni.name)) == ni.index:
      this.add newNamedEntry(ni.name, tv[0], tv[1])
    else:
      raise newException(IndexDefect, fmt"Name `{ni.name}` with index {ni.index} not found.")

## ex: abc[(nothing, 2)] = ("title", null)
proc `[]=`*(this: var Lone, ni: NothingIndexTuple, tv: TypeValueStringNullTuple) =
  let loc = this.findEntry(nothing, ni.index)
  if (loc >= 0):
    this[loc] = newNamedEntry(nothing, tv[0], tv[1])
  else:
    if this.countOf(none(string)) == ni.index:
      this.add newNamedEntry(nothing, tv[0], tv[1])
    else:
      raise newException(IndexDefect, fmt"Name nothing with index {ni.index} not found.")


# assignment of a (type, value) as (nothing, null)

## ex: abc["foo"] = (nothing, null)
proc `[]=`*(this: var Lone, name: string, tv: TypeValueNothingNullTuple) =
  let loc = this.findEntry(name, 0)
  if (loc >= 0):
    this[loc] = newNamedEntry(name, tv[0], tv[1])
  else:
    this.add newNamedEntry(name, tv[0], tv[1])

## ex: abc[nothing] = (nothing, null)
proc `[]=`*(this: var Lone, name: LoneNothing, tv: TypeValueNothingNullTuple) =
  let loc = this.findEntry(nothing, 0)
  if (loc >= 0):
    this[loc] = newNamedEntry(nothing, tv[0], tv[1])
  else:
    this.add newNamedEntry(nothing, nothing, tv[1])

## ex: abc[("foo", 2)] = (nothing, null)
proc `[]=`*(this: var Lone, ni: NameIndexTuple, tv: TypeValueNothingNullTuple) =
  let loc = this.findEntry(ni.name, ni.index)
  if (loc >= 0):
    this[loc] = newNamedEntry(ni.name, tv[0], tv[1])
  else:
    if this.countOf(some(ni.name)) == ni.index:
      this.add newNamedEntry(ni.name, tv[0], tv[1])
    else:
      raise newException(IndexDefect, fmt"Name `{ni.name}` with index {ni.index} not found.")

## ex: abc[(nothing, 2)] = (nothing, null)
proc `[]=`*(this: var Lone, ni: NothingIndexTuple, tv: TypeValueNothingNullTuple) =
  let loc = this.findEntry(nothing, ni.index)
  if (loc >= 0):
    this[loc] = newNamedEntry(nothing, tv[0], tv[1])
  else:
    if this.countOf(none(string)) == ni.index:
      this.add newNamedEntry(nothing, tv[0], tv[1])
    else:
      raise newException(IndexDefect, fmt"Name nothing with index {ni.index} not found.")


# assignment of a (type, value) as (string, lone)

## ex: abc["foo"] = ("title", Lone())
proc `[]=`*(this: var Lone, name: string, tv: TypeValueStringLoneTuple) =
  let loc = this.findEntry(name, 0)
  if (loc >= 0):
    this[loc] = newNamedEntry(name, tv[0], tv[1].deepCopy)
  else:
    this.add newNamedEntry(name, tv[0], tv[1].deepCopy)

## ex: abc[nothing] = ("title", Lone())
proc `[]=`*(this: var Lone, name: LoneNothing, tv: TypeValueStringLoneTuple) =
  let loc = this.findEntry(nothing, 0)
  if (loc >= 0):
    this[loc] = newNamedEntry(nothing, tv[0], tv[1].deepCopy)
  else:
    this.add newNamedEntry(nothing, nothing, tv[1].deepCopy)

## ex: abc[("foo", 2)] = ("title", Lone())
proc `[]=`*(this: var Lone, ni: NameIndexTuple, tv: TypeValueStringLoneTuple) =
  let loc = this.findEntry(ni.name, ni.index)
  if (loc >= 0):
    this[loc] = newNamedEntry(ni.name, tv[0], tv[1].deepCopy)
  else:
    if this.countOf(some(ni.name)) == ni.index:
      this.add newNamedEntry(ni.name, tv[0], tv[1].deepCopy)
    else:
      raise newException(IndexDefect, fmt"Name `{ni.name}` with index {ni.index} not found.")

## ex: abc[(nothing, 2)] = ("title", Lone())
proc `[]=`*(this: var Lone, ni: NothingIndexTuple, tv: TypeValueStringLoneTuple) =
  let loc = this.findEntry(nothing, ni.index)
  if (loc >= 0):
    this[loc] = newNamedEntry(nothing, tv[0], tv[1].deepCopy)
  else:
    if this.countOf(none(string)) == ni.index:
      this.add newNamedEntry(nothing, tv[0], tv[1].deepCopy)
    else:
      raise newException(IndexDefect, fmt"Name nothing with index {ni.index} not found.")


# assignment of a (type, value) as (nothing, lone)

## ex: abc["foo"] = (nothing, Lone())
proc `[]=`*(this: var Lone, name: string, tv: TypeValueNothingLoneTuple) =
  let loc = this.findEntry(name, 0)
  if (loc >= 0):
    this[loc] = newNamedEntry(name, tv[0], tv[1].deepCopy)
  else:
    this.add newNamedEntry(name, tv[0], tv[1].deepCopy)

## ex: abc[nothing] = (nothing, Lone())
proc `[]=`*(this: var Lone, name: LoneNothing, tv: TypeValueNothingLoneTuple) =
  let loc = this.findEntry(nothing, 0)
  if (loc >= 0):
    this[loc] = newNamedEntry(nothing, tv[0], tv[1].deepCopy)
  else:
    this.add newNamedEntry(nothing, nothing, tv[1].deepCopy)

## ex: abc[("foo", 2)] = (nothing, Lone())
proc `[]=`*(this: var Lone, ni: NameIndexTuple, tv: TypeValueNothingLoneTuple) =
  let loc = this.findEntry(ni.name, ni.index)
  if (loc >= 0):
    this[loc] = newNamedEntry(ni.name, tv[0], tv[1].deepCopy)
  else:
    if this.countOf(some(ni.name)) == ni.index:
      this.add newNamedEntry(ni.name, tv[0], tv[1].deepCopy)
    else:
      raise newException(IndexDefect, fmt"Name `{ni.name}` with index {ni.index} not found.")

## ex: abc[(nothing, 2)] = (nothing, Lone())
proc `[]=`*(this: var Lone, ni: NothingIndexTuple, tv: TypeValueNothingLoneTuple) =
  let loc = this.findEntry(nothing, ni.index)
  if (loc >= 0):
    this[loc] = newNamedEntry(nothing, tv[0], tv[1].deepCopy)
  else:
    if this.countOf(none(string)) == ni.index:
      this.add newNamedEntry(nothing, tv[0], tv[1].deepCopy)
    else:
      raise newException(IndexDefect, fmt"Name nothing with index {ni.index} not found.")

# ----------------------------------------------------------
#
# append
#
#
proc addWithKey*(this: var Lone, name: string, value: LoneNull) =
  this.add newNamedEntry(name, nothing, value)

proc addWithKey*(this: var Lone, name: string, value: string) =
  this.add newNamedEntry(name, nothing, value)

proc addWithKey*(this: var Lone, name: string, value: Lone) =
  this.add newNamedEntry(name, nothing, value)

proc addWithKey*(this: var Lone, name: string, tv: TypeValueStringNullTuple) =
  this.add newNamedEntry(name, tv.attrType, tv.value)

proc addWithKey*(this: var Lone, name: string, tv: TypeValueNothingNullTuple) =
  this.add newNamedEntry(name, tv.attrType, tv.value)

proc addWithKey*(this: var Lone, name: string, tv: TypeValueStringStringTuple) =
  this.add newNamedEntry(name, tv.attrType, tv.value)

proc addWithKey*(this: var Lone, name: string, tv: TypeValueNothingStringTuple) =
  this.add newNamedEntry(name, tv.attrType, tv.value)

proc addWithKey*(this: var Lone, name: string, tv: TypeValueStringLoneTuple) =
  this.add newNamedEntry(name, tv.attrType, tv.value)

proc addWithKey*(this: var Lone, name: string, tv: TypeValueNothingLoneTuple) =
  this.add newNamedEntry(name, tv.attrType, tv.value)

# ----------------------------------------------------------
#
# get []
#
#

proc `[]`*(this: Lone, name: string): LoneEntryReference =
  let loc = this.findEntry(some(name), 0)
  if loc >= 0:
    result = LoneEntryReference(
      parentRef: this,
      name: some(name),
      index: loc,
      attrType: this[loc].attrType, 
      value: this[loc].value
    )
  else:
    raise newException(IndexDefect, fmt"Name `{name}` with index {0} not found.")

proc `[]`*(this: Lone, name: LoneNothing): LoneEntryReference =
  let loc = this.findEntry(none(string), 0)
  if loc >= 0:
    result = LoneEntryReference(
      parentRef: this,
      name: none(string),
      index: loc,
      attrType: this[loc].attrType, 
      value: this[loc].value
    )
  else:
    raise newException(IndexDefect, fmt"Name nothing with index {0} not found.")

proc `[]`*(this: Lone, ni: NameIndexTuple): LoneEntryReference =
  let loc = this.findEntry(some(ni.name), ni.index)
  if loc >= 0:
    result = LoneEntryReference(
      parentRef: this,
      name: none(string),
      index: loc,
      attrType: this[loc].attrType, 
      value: this[loc].value
    )
  else:
    raise newException(IndexDefect, fmt"Name `{ni.name}` with index {ni.index} not found.")

proc `[]`*(this: Lone, ni: NothingIndexTuple): LoneEntryReference =
  let loc = this.findEntry(none(string), ni.index)
  if loc >= 0:
    result = LoneEntryReference(
      parentRef: this,
      name: none(string),
      index: loc,
      attrType: this[loc].attrType, 
      value: this[loc].value
    )
  else:
    raise newException(IndexDefect, fmt"Name nothing with index {ni.index} not found.")

proc getType*(this: LoneEntryReference): Option[string] =
  result = this.attrType

proc getString*(this: LoneEntryReference): string =
  case this.value.kind:
  of LvString:
    result = this.value.str
  of LvNull:
    raise newException(FieldDefect, "Cannot `getString` on a null value. There is a version of `getString` that supports a default on non-strings.")
  of LvLone:
    raise newException(FieldDefect, "Cannot `getString` on subtending LONE. There is a version of `getString` that supports a default on non-strings.")

proc getString*(this: LoneEntryReference, default: string): string =
  if this.value.kind == LvString:
    result = this.value.str
  else:
    result = default

proc `$`*(this: LoneEntryReference): string =
  case this.value.kind:
  of LvNull:
    result = "null"
  of LvString:
    result = "\"" & this.value.str & "\""
  of LvLone:
    result = "{*\n"
    result &= "*}"

# ---------------------------------------------------------
#
# comparisons
#
#

proc isNull*(this: LoneEntryReference): bool =
  case this.value.kind:
  of LvNull:
    result = true
  of LvString:
    result = false
  of LvLone:
    result = false

proc isString*(this: LoneEntryReference): bool =
  case this.value.kind:
  of LvNull:
    result = false
  of LvString:
    result = true
  of LvLone:
    result = false

proc isLone*(this: LoneEntryReference): bool =
  case this.value.kind:
  of LvNull:
    result = false
  of LvString:
    result = false
  of LvLone:
    result = true

proc `==`*(this: LoneEntryReference, other: LoneEntryReference): bool =
  if this.value.kind != other.value.kind:
    return false
  if this.attrType != other.attrType:
    return false
  case this.value.kind:
  of LvNull:
    discard
  of LvString:
    if this.value.str != other.value.str:
      return false
  of LvLone:
    if this.value.entries.len == other.value.entries.len:
      if this.value.entries.len == 0:
        return true
      else:
        raise newException(IndexDefect, "TBD not ready for this yet.")
    else:
      return false
  return true

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
