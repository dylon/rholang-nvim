; queries/rholang/highlights.scm

; Comments
(_line_comment) @comment
(_block_comment) @comment

; Keywords
"contract" @keyword
"for" @keyword
"in" @keyword
"if" @keyword
"else" @keyword
"match" @keyword
"select" @keyword
"new" @keyword
"let" @keyword
"case" @keyword

; Bundle keywords
(bundle_write) @keyword
(bundle_read) @keyword
(bundle_equiv) @keyword
(bundle_read_write) @keyword

; Literals
(bool_literal) @boolean
(long_literal) @number
(string_literal) @string
(uri_literal) @string
(nil) @constant.builtin
(simple_type) @type

; Operators
[
  "|"
  "!?"
  "!"
  "!!"
  "or"
  "and"
  "matches"
  "=="
  "!="
  "<"
  "<="
  ">"
  ">="
  "+"
  "++"
  "-"
  "--"
  "*"
  "/"
  "%"
  "%%"
  "not"
  "~"
  "\\/"
  "/\\"
  "<-"
  "<=-"
  "<<-"
  "?!"
  "=>"
  ":"
] @operator

; Punctuation
[
  "("
  ")"
  "{"
  "}"
  "["
  "]"
  ","
  ";"
  "."
] @punctuation.delimiter

; Variables and Names
(var) @variable
(name) @variable
(var_ref) @variable

; Channels and Quotes
(quote) @function
(eval) @function

; Collections
(list) @constructor
(tuple) @constructor
(set) @constructor
(map) @constructor
(key_value_pair key: (_) @variable value: (_) @variable)

; Methods
(method name: (_) @method)

; Case patterns
(case pattern: (_) @variable)

; Function-like constructs
(contract name: (_) @function)
