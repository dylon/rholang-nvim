;; Variable definitions
(name_decl (var) @definition.var)
(linear_bind (names (var) @definition.var))
(repeated_bind (names (var) @definition.var))
(peek_bind (names (var) @definition.var))
(decl (names (var) @definition.var))
(contract name: (var) @definition.var)

;; Variable references
(match expression: (var) @reference.var)
(send (inputs (var) @reference.var))
(var_ref (var) @reference.var)
(quote (var) @reference.var)
(eval (var) @reference.var)
