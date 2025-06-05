; queries/rholang/highlights.scm
; Comments
(line_comment) @comment
(block_comment) @comment

; Keywords
[
  "contract"
  "for"
  "in"
  "if"
  "else"
  "match"
  "select"
  "new"
  "let"
] @keyword

; Bundle keywords
[
  (bundle_write)
  (bundle_read)
  (bundle_equiv)
  (bundle_read_write)
] @keyword

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
  (send_single)
  (send_multiple)
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
; (name) @variable ; Removed due to inlined rule
(wildcard) @variable ; Added for _proc_var
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
