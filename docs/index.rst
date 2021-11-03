Introduction to lone
==============================================================================
ver 0.1.0

Code to create:

.. code:: slone

    #! SLONE 1.0
    _ = (person) {*
      "full_name" = (name) "Larry Smith"
      "main home" = (building) {*
        "mailing address" = (address) {*
          "street" = (string_array) {*
            _ = (string) "1234 Main St"
            _ = (string) "Unit 3"
          *}
          "postal code" = _ "90210"
        *}
      *}
    *}

.. code:: nim

    # test.nim
    #
    import lone

    # first way (to x):
    #
    var x = Lone()
    x[nothing] = ("person", Lone())
    x[nothing]["full_name"] = ("name", "Larry Smith")
    x[nothing]["main home"] = ("building", Lone())
    x[nothing]["main home"]["mailing address"] = ("address", Lone())
    x[nothing]["main home"]["mailing address"]["street"] = ("string_array", Lone())
    x[nothing]["main_home"]["mailing address"]["street"].add (nothing, "string", "1234 Main St")
    x[nothing]["main_home"]["mailing address"]["street"].add (nothing, "string", "Unit 3")
    x[nothing]["main_home"]["mailing address"]["postal code"] = "90210"

    # another way (to y):
    #
    var streetAddress = @["1234 Main St", "Unit 3"]
    var mailingAddress = Lone()
    mailingAddress["street"] = streetAddress.toLone("string_array")
    mailingAddress["postal code"] = "90210"
    var mainHome = Lone()
    mainHome["mailing address"] = mailingAddress
    var person = Lone()
    person["full_name"] = ("name", "Larry Smith")
    person["main home"] = ("building", mainHome)
    var y = Lone()
    y[nothing] = ("person", person)

    # using a type schema (to z):
    #
    var z = newLoan()
    var person = Lone()(personSchema)   # see section on schema support
    person["full_name"] = "Larry Smith"
    person["main_home"]["mailing address"]["street"].addItem "1234 Main St"  # 'addItem' adds an entry with name of nothing and a default type
    person["main_home"]["mailing address"]["street"].addItem "Unit 3"
    person["main_home"]["mailing address"]["postal code"] = "90210"
    z.addItem person   # z does not have a schema, so the attrType defaults to nothing




Table Of Contents
=================

1. `Introduction to lone <https://github.com/JohnAD/lone>`__
2. Appendices

    A. `lone Reference <lone-ref.rst>`__
