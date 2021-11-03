lone Reference
==============================================================================

The following are the references for lone.



Types
=====



.. _Lone.type:
Lone
---------------------------------------------------------

    .. code:: nim

        Lone* = ref LoneObj


    source line: `88 <../src/lone.nim#L88>`__



.. _LoneKind.type:
LoneKind
---------------------------------------------------------

    .. code:: nim

        LoneKind* = enum
          LvNull,
          LvNothing,
          LvString,
          LvLone


    source line: `83 <../src/lone.nim#L83>`__







Procs, Methods, Iterators
=========================


.. _`$`.p:
`$`
---------------------------------------------------------

    .. code:: nim

        proc `$`*(this: Lone): string =

    source line: `297 <../src/lone.nim#L297>`__



.. _`==`.p:
`==`
---------------------------------------------------------

    .. code:: nim

        proc `==`*(this: LoneNothing, other: Option[string]): bool =

    source line: `364 <../src/lone.nim#L364>`__



.. _`==`.p:
`==`
---------------------------------------------------------

    .. code:: nim

        proc `==`*(this: Option[string], other: LoneNothing): bool =

    source line: `367 <../src/lone.nim#L367>`__



.. _`==`.p:
`==`
---------------------------------------------------------

    .. code:: nim

        proc `==`*(this: Option[string], other: string): bool =

    source line: `374 <../src/lone.nim#L374>`__



.. _`==`.p:
`==`
---------------------------------------------------------

    .. code:: nim

        proc `==`*(this: string, other: Option[string]): bool =

    source line: `370 <../src/lone.nim#L370>`__



.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(this: var Lone, key: LoneNothing, value: Lone) = this.assign 0, newLone(none(string), none(string), value)

    source line: `258 <../src/lone.nim#L258>`__



.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(this: var Lone, key: LoneNothing, value: LoneNull) = this.assign 0, newNull(none(string), none(string))

    source line: `261 <../src/lone.nim#L261>`__



.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(this: var Lone, key: LoneNothing, value: string) = this.assign 0, newString(none(string), none(string), value)

    source line: `259 <../src/lone.nim#L259>`__



.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(this: var Lone, key: LoneNull, value: Lone) = raise newException(IndexDefect, "(Lone) A name cannot be null.")

    source line: `263 <../src/lone.nim#L263>`__



.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(this: var Lone, key: LoneNull, value: LoneNothing) = raise newException(IndexDefect, "(Lone) A name cannot be null.")

    source line: `265 <../src/lone.nim#L265>`__



.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(this: var Lone, key: LoneNull, value: LoneNull) = raise newException(IndexDefect, "(Lone) A name cannot be null.")

    source line: `266 <../src/lone.nim#L266>`__



.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(this: var Lone, key: LoneNull, value: string) = raise newException(IndexDefect, "(Lone) A name cannot be null.")

    source line: `264 <../src/lone.nim#L264>`__



.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(this: var Lone, key: string, value: Lone) = this.assign 0, newLone(some(key), none(string), value)

    source line: `253 <../src/lone.nim#L253>`__



.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(this: var Lone, key: string, value: LoneNull) = this.assign 0, newNull(some(key), none(string))

    source line: `256 <../src/lone.nim#L256>`__



.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(this: var Lone, key: string, value: string) = this.assign 0, newString(some(key), none(string), value)

    source line: `254 <../src/lone.nim#L254>`__



.. _`[]`.p:
`[]`
---------------------------------------------------------

    .. code:: nim

        proc `[]`*(this: var Lone, key: LoneNothing): Lone = this.retrieveRef(none(string), 0)

    source line: `223 <../src/lone.nim#L223>`__



.. _`[]`.p:
`[]`
---------------------------------------------------------

    .. code:: nim

        proc `[]`*(this: var Lone, key: LoneNull): Lone = raise newException(IndexDefect, "(Lone) A name cannot be null.")

    source line: `224 <../src/lone.nim#L224>`__



.. _`[]`.p:
`[]`
---------------------------------------------------------

    .. code:: nim

        proc `[]`*(this: var Lone, key: string): Lone = this.retrieveRef(some(key), 0)

    source line: `222 <../src/lone.nim#L222>`__



.. _deepCopy.p:
deepCopy
---------------------------------------------------------

    .. code:: nim

        proc deepCopy*(this: Lone): Lone =

    source line: `147 <../src/lone.nim#L147>`__



.. _getString.p:
getString
---------------------------------------------------------

    .. code:: nim

        proc getString*(this: Lone): string =

    source line: `280 <../src/lone.nim#L280>`__



.. _getString.p:
getString
---------------------------------------------------------

    .. code:: nim

        proc getString*(this: Lone, default: string): string =

    source line: `291 <../src/lone.nim#L291>`__



.. _getType.p:
getType
---------------------------------------------------------

    .. code:: nim

        proc getType*(this: Lone): Option[string] =

    source line: `277 <../src/lone.nim#L277>`__



.. _newLone.p:
newLone
---------------------------------------------------------

    .. code:: nim

        proc newLone*(): Lone =

    source line: `182 <../src/lone.nim#L182>`__



.. _newLone.p:
newLone
---------------------------------------------------------

    .. code:: nim

        proc newLone*(name: Option[string], attrType: Option[string], value: Lone): Lone =

    source line: `172 <../src/lone.nim#L172>`__








Table Of Contents
=================

1. `Introduction to lone <https://github.com/JohnAD/lone>`__
2. Appendices

    A. `lone Reference <lone-ref.rst>`__
