ParameterCleaner
================

Strips angle brackets from user input on the way into the application,
providing an extra level of security against XSS attacks even when
someone forgets an `h()` in a template.

__This is not a replacement for proper escaping!__

Exclusions
----------

Password fields (anything matching `/password/`) are not stripped. For one
thing, users should be allowed to make strong passwords; for another, you’re
never going to display them in the application. Right?

For fields where you want to allow angle brackets, you can disable it on a
parameter-by-parameter basis:

    class SomeController < ApplicationController
      do_not_escape_param [:thing, :html_description]
    end

The array corresponds to the hash keys used to get to the parameter; there is
no distinction between string parameters and array parameters.

    Form parameter  |  do_not_escape_array
    ----------------+---------------------
    foo             |  [:foo] or :foo
    foo[bar]        |  [:foo, :bar]
    foo[bar][]      |  [:foo, :bar]

You can specify multiple parameters in one line:

    do_not_escape_param :foo, :bar, [:nested, :baz]
