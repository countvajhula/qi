#lang racket/base

(require syntax/on
         rackunit
         rackunit/text-ui
         (only-in math sqr)
         racket/list
         racket/function
         "private/util.rkt")

(define tests
  (test-suite
   "On macro tests"

   (test-suite
    "on tests"

    (test-suite
     "core language"
     (test-case
         "Edge/base cases"
       (check-equal? (on (0))
                     (void)
                     "no clauses, unary")
       (check-equal? (on (5 5))
                     (void)
                     "no clauses, binary")
       (check-equal? (on ()
                         (const 3))
                     3
                     "no arguments"))
     (test-case
         "unary predicate"
       (check-false (on (5) negative?))
       (check-true (on (5) positive?)))
     (test-case
         "binary predicate"
       (check-false (on (5 6) >))
       (check-true (on (5 6) <)))
     (test-case
         "n-ary predicate"
       (check-false (on (5 5 6 7) >))
       (check-false (on (5 5 6 7) <))
       (check-true (on (5 5 6 7) <=)))
     (test-case
         "eq?"
       (check-false (on (6) (eq? 5)))
       (check-true (on (5) (eq? 5))))
     (test-case
         "equal?"
       (check-false (on ("bye") (equal? "hello")))
       (check-true (on ("hello") (equal? "hello"))))
     (test-case
         "one-of?"
       (check-false (on ("hello") (one-of? "hi" "ola")))
       (check-true (on ("hello") (one-of? "hi" "hello"))))
     (test-case
         "<"
       (check-false (on (5) (< 5)))
       (check-true (on (5) (< 10))))
     (test-case
         "<="
       (check-false (on (5) (<= 1)))
       (check-true (on (5) (<= 10)))
       (check-true (on (5) (<= 5))))
     (test-case
         ">"
       (check-false (on (5) (> 5)))
       (check-true (on (5) (> 1))))
     (test-case
         ">="
       (check-false (on (5) (>= 10)))
       (check-true (on (5) (>= 1)))
       (check-true (on (5) (>= 5))))
     (test-case
         "="
       (check-true (on (5) (= 5)))
       (check-false (on (5) (= 10))))
     (test-case
         "predicate under a mapping"
       (check-true (on ("5") (with-key string->number (< 10))))
       (check-false (on ("5") (with-key string->number (> 10)))))
     (test-case
         "and (conjoin)"
       (check-true (on (5) (and positive? integer?)))
       (check-false (on (5.4) (and positive? integer?)))
       (check-true (on (6) (and (> 5) (< 10))))
       (check-false (on (4) (and (> 5) (< 10))))
       (check-false (on (14) (and (> 5) (< 10)))))
     (test-case
         "or (disjoin)"
       (check-true (on (6) (or positive? odd?)))
       (check-true (on (-5) (or positive? odd?)))
       (check-false (on (-6) (or positive? odd?)))
       (check-true (on ("5.0" "5")
                       (or eq?
                           equal?
                           (with-key string->number =))))
       (check-true (on ("5.0" "5")
                       (or eq?
                           equal?
                           (.. = (>< string->number)))))
       (check-false (on ("5" "6")
                        (or eq?
                            equal?
                            (with-key string->number =))))
       (check-false (on ("5" "6")
                        (or eq?
                            equal?
                            (.. = (>< string->number))))))
     (test-case
         "not (predicate negation)"
       (check-true (on (-5) (not positive?)))
       (check-false (on (5) (not positive?))))
     (test-case
         "boolean combinators"
       (check-true (on (5)
                       (and positive?
                            (not even?))))
       (check-false (on (5)
                        (and positive?
                             (not odd?))))
       (check-true (on (5)
                       (and positive?
                            (or integer?
                                odd?))))
       (check-false (on (5)
                        (and positive?
                             (or (> 6)
                                 even?))))
       (check-true (on (5)
                       (and positive?
                            (or (eq? 3)
                                (eq? 5)))))
       (check-false (on (5)
                        (and positive?
                             (or (eq? 3)
                                 (eq? 6))))))
     (test-case
         "juxtaposed boolean combinators"
       (check-true (on (20 5)
                       (and% positive?
                             (or (> 10)
                                 odd?))))
       (check-false (on (20 5)
                        (and% positive?
                              (or (> 10)
                                  even?)))))
     (test-case
         "juxtaposed conjoin"
       (check-true (on (5 "hi")
                       (and% positive? string?)))
       (check-false (on (5 5)
                        (and% positive? string?)))
       (check-true (on (5 "hi")
                       (and% positive? _)))
       (check-true (on (5 "hi")
                       (and% _ string?))))
     (test-case
         "juxtaposed disjoin"
       (check-true (on (5 "hi")
                       (or% positive? string?)))
       (check-true (on (-5 "hi")
                       (or% positive? string?)))
       (check-false (on (-5 5)
                        (or% positive? string?)))
       (check-false (on (-5 "hi")
                        (or% positive? _)))
       (check-true (on (5 "hi")
                       (or% positive? _)))
       (check-true (on (5 "hi")
                       (or% _ string?)))
       (check-false (on (5 5)
                        (or% _ string?))))
     (test-case
         "all"
       (check-true (on (3 5)
                       (all positive?)))
       (check-false (on (3 -5)
                        (all positive?))))
     (test-case
         "any"
       (check-true (on (3 5)
                       (any positive?)))
       (check-true (on (3 -5)
                       (any positive?)))
       (check-false (on (-3 -5)
                        (any positive?))))
     (test-case
         "none"
       (check-true (on (-3 -5)
                       (none positive?)))
       (check-false (on (3 -5)
                        (none positive?)))
       (check-false (on (3 5)
                        (none positive?))))
     (test-case
         "all?"
       (check-true (on (3) all?))
       (check-false (on (#f) all?))
       (check-true (on (3 5 7) all?))
       (check-false (on (3 #f 5) all?)))
     (test-case
         "any?"
       (check-true (on (3) any?))
       (check-false (on (#f) any?))
       (check-true (on (3 5 7) any?))
       (check-true (on (3 #f 5) any?))
       (check-true (on (#f #f 5) any?))
       (check-false (on (#f #f #f) any?)))
     (test-case
         "none?"
       (check-false (on (3) none?))
       (check-true (on (#f) none?))
       (check-false (on (3 5 7) none?))
       (check-false (on (3 #f 5) none?))
       (check-false (on (#f #f 5) none?))
       (check-true (on (#f #f #f) none?)))
     (test-case
         ".."
       (check-equal? (on (5)
                         (.. (string-append "a" _ "b")
                             number->string
                             (* 2)
                             add1))
                     "a12b")
       (check-equal? (on (5 6)
                         (.. (string-append _ "a" _ "b")
                             (>< number->string)
                             (>< add1)))
                     "6a7b")
       (check-equal? (on (5 6)
                         (.. +
                             (>< (* 2))
                             (>< add1)))
                     26)
       (check-equal? (on ("p" "q")
                         (.. string-append
                             (>< (string-append "a" _ "b"))))
                     "apbaqb")
       (check-equal? (on (5)
                         (compose (string-append "a" _ "b")
                                  number->string
                                  (* 2)
                                  add1))
                     "a12b"
                     "named composition form"))
     (test-case
         "~>"
       (check-equal? (on (5)
                         (~> add1
                             (* 2)
                             number->string
                             (string-append "a" _ "b")))
                     "a12b")
       (check-equal? (on (5 6)
                         (~> (>< add1)
                             (>< number->string)
                             (string-append _ "a" _ "b")))
                     "6a7b")
       (check-equal? (on (5 6)
                         (~> (>< add1)
                             (>< (* 2))
                             +))
                     26)
       (check-equal? (on ("p" "q")
                         (~> (>< (string-append "a" _ "b"))
                             string-append))
                     "apbaqb")
       (check-equal? (on (5)
                         (thread add1
                                 (* 2)
                                 number->string
                                 (string-append "a" _ "b")))
                     "a12b"
                     "named threading form"))
     (test-case
         "><"
       (check-equal? (on (3 5)
                         (~> (>< sqr)
                             +))
                     34)
       (check-equal? (on (3 5)
                         (~> (amp sqr)
                             +))
                     34
                     "named amplification form"))
     (test-case
         "-<"
       (check-equal? (on (5)
                         (~> (-< sqr add1)
                             +))
                     31)
       (check-equal? (on ((range 1 10))
                         (~> (-< sum length) /))
                     5)
       (check-equal? (on (5)
                         (~> (tee sqr add1)
                             +))
                     31
                     "named tee junction form"))
     (test-case
         "=="
       (check-equal? (on (5 7)
                         (~> (== sqr add1)
                             +))
                     33)
       (check-equal? (on ((range 1 10))
                         (~> (-< sum length)
                             (== add1 sub1)
                             +))
                     54)
       (check-equal? (on (5 7)
                         (~> (relay sqr add1)
                             +))
                     33
                     "named relay form"))
     (test-case
         "template with single argument"
       (check-false (on ((list 1 2 3))
                        (apply > _)))
       (check-true (on ((list 3 2 1))
                       (apply > _)))
       (check-equal? (on ((list 1 2 3))
                         (map add1 _))
                     (list 2 3 4)
                     "map in predicate")
       (check-equal? (on ((list 1 2 3))
                         (filter odd? _))
                     (list 1 3)
                     "filter in predicate")
       (check-equal? (on ((list "a" "b" "c"))
                         (foldl string-append "" _))
                     "cba"
                     "foldl in predicate"))
     (test-case
         "template with multiple arguments"
       (check-true (on (3 7) (< 1 _ 5 _ 10))
                   "template with multiple arguments")
       (check-false (on (3 5) (< 1 _ 5 _ 10))
                    "template with multiple arguments"))
     (test-case
         "escape hatch"
       (check-equal? (on (3 7) (expr (first (list + *))))
                     10
                     "normal racket expressions")
       (check-equal? (on (3 7) (expr + (second (list + *))))
                     21
                     "normal racket expressions")))

    (test-suite
     "high-level circuit elements"
     (test-suite
      "splitter"
      (check-equal? (on (5)
                        (~> (splitter 3)
                            +))
                    15))))

   (test-suite
    "switch tests"
    (test-case
        "Edge/base cases"
      (check-equal? (switch (6 5)
                            [< 'yo])
                    (void)
                    "no matching clause")
      (check-equal? (switch (5)
                            [positive? 1 2 3])
                    3
                    "more than one body form"))
    (test-case
        "common"
      (check-equal? (switch (0)
                            [negative? 'bye]
                            [positive? 'hi]
                            [zero? 'later])
                    'later)
      (check-equal? (switch (5 6)
                            [> 'bye]
                            [< 'hi]
                            [else 'yo])
                    'hi)
      (check-equal? (switch (5 5)
                            [> 'bye]
                            [< 'hi]
                            [else 'yo])
                    'yo)
      (check-equal? (switch (5 5 6 7)
                            [> 'bye]
                            [< 'hi]
                            [else 'yo])
                    'yo)
      (check-equal? (switch (5 5 6 7)
                            [>= 'bye]
                            [<= 'hi]
                            [else 'yo])
                    'hi)
      (check-equal? (switch (5.3)
                            [(or positive? integer?) 'yes]
                            [else 'no])
                    'yes)
      (check-equal? (switch (-5.4)
                            [(or positive? integer?) 'yes]
                            [else 'no])
                    'no)
      (check-equal? (switch (1 1)
                            [(or < >) 'a]
                            [else 'b])
                    'b)
      (check-equal? (switch ('a 'a)
                            [(or eq? equal?) 'a]
                            [else 'b])
                    'a)
      (check-equal? (switch ("abc" (symbol->string 'abc))
                            [(or eq? equal?) 'a]
                            [else 'b])
                    'a)
      (check-equal? (switch ('a 'b)
                            [(or eq? equal?) 'a]
                            [else 'b])
                    'b)
      (check-equal? (switch (3 7)
                            [(< 1 _ 5 _ 10) 'yes]
                            [else 'no])
                    'yes
                    "template with multiple arguments"))
    (test-case
        "else"
      (check-equal? (switch (0)
                            [negative? 'bye]
                            [positive? 'hi]
                            [else 'later])
                    'later)
      (check-equal? (switch (0)
                            [else 'later])
                    'later)
      (check-equal? (switch (5 5)
                            [else 'yo])
                    'yo))
    (test-case
        "call"
      (check-equal? (switch (5)
                            [positive? (call add1)]
                            [else 'no])
                    6)
      (check-equal? (switch (-5)
                            [positive? (call add1)]
                            [else 'no])
                    'no)
      (check-equal? (switch (3 5)
                            [< (call +)]
                            [else 'no])
                    8
                    "n-ary predicate")
      (check-equal? (switch (3 5)
                            [> (call +)]
                            [else 'no])
                    'no
                    "n-ary predicate")
      (check-equal? (switch (3 5)
                            [< (call (.. + (>< add1)))]
                            [else 'no])
                    10
                    ".. and >< in call position")
      (check-equal? (switch (3 5)
                            [< (call (.. + (>< (.. add1 sqr))))]
                            [else 'no])
                    36
                    ".. and >< in call position")
      (check-equal? (switch (3 5)
                            [true. (call (~> (>< add1) *))]
                            [else 'no])
                    24)
      (check-equal? (switch (3 5)
                            [true. (call (~> (>< sqr) +))]
                            [else 'no])
                    34)
      (check-equal? (switch (3 5)
                            [true. (call (~> (>< add1) * (-< (/ 2) (/ 3)) +))]
                            [else 'no])
                    20)
      (check-equal? (switch (10 12)
                            [true. (call (~> (== (/ 2) (/ 3)) +))]
                            [else 'no])
                    9)
      (check-equal? (switch (5)
                            [true. (call (~> (splitter 3) +))]
                            [else 'no])
                    15)
      (check-equal? (switch ((list 1 2 3))
                            [(apply > _) 'yes]
                            [else 'no])
                    'no
                    "apply in predicate")
      (check-equal? (switch ((list 3 2 1))
                            [(apply > _) 'yes]
                            [else 'no])
                    'yes
                    "apply in predicate")
      (check-equal? (switch ((list 3 2 1))
                            [(apply > _) (call (apply + _))]
                            [else 'no])
                    6
                    "apply in consequent")
      (check-equal? (switch ((list 2 1 3))
                            [(.. (> 2) length) (call (apply sort < _ #:key identity))]
                            [else 'no])
                    (list 1 2 3)
                    "apply in consequent with non-tail arguments")
      (check-equal? (switch ((list 3 2 1))
                            [(apply > _) (call (map add1 _))]
                            [else 'no])
                    (list 4 3 2)
                    "map in consequent")
      (check-equal? (switch ((list 3 2 1))
                            [(apply > _) (call (filter even? _))]
                            [else 'no])
                    (list 2)
                    "filter in consequent")
      (check-equal? (switch ((list 3 2 1))
                            [(apply > _) (call (foldl + 1 _))]
                            [else 'no])
                    7
                    "foldl in consequent"))
    (test-case
        "connect"
      (check-equal? (switch (5)
                            [positive? (connect [(and integer? odd?) (call add1)]
                                                [else 'positive])]
                            [else 'no])
                    6)
      (check-equal? (switch (6)
                            [positive? (connect [(and integer? odd?) (call add1)]
                                                [else 'positive])]
                            [else 'no])
                    'positive)
      (check-equal? (switch (-5)
                            [positive? (connect [(and integer? odd?) (call add1)]
                                                [else 'positive])]
                            [else 'no])
                    'no)
      (check-equal? (switch (3 5)
                            [< (connect [(~> - abs (< 3)) (call +)])]
                            [else 'no])
                    8
                    "n-ary predicate")
      (check-equal? (switch (3 8)
                            [< (connect [(~> - abs (< 3)) (call +)]
                                        [else 'less])]
                            [else 'no])
                    'less
                    "n-ary predicate")
      (check-equal? (switch (5 3)
                            [< (connect [(~> - abs (< 3)) (call +)]
                                        [else 'less])]
                            [else 'no])
                    'no
                    "n-ary predicate"))
    (test-case
        "result of predicate expression"
      (check-equal? (switch (6)
                            [add1 (add1 <result>)]
                            [else 'hi])
                    8)
      (check-equal? (switch (2)
                            [(member _ (list 1 5 4 2 6)) <result>]
                            [else 'hi])
                    (list 2 6))
      (check-equal? (switch (2)
                            [(member _ (list 1 5 4 2 6)) (length <result>)]
                            [else 'hi])
                    2)
      (check-equal? (switch ((list add1 sub1))
                            [car (<result> 5)]
                            [else 'hi])
                    6)
      (check-equal? (switch (2 3)
                            [+ <result>]
                            [else 'hi])
                    5)
      (check-equal? (switch ((list 2 1 3))
                            [(apply sort < _ #:key identity) <result>]
                            [else 'no])
                    (list 1 2 3)
                    "apply in predicate with non-tail arguments"))
    (test-case
        "heterogeneous clauses"
      (check-equal? (switch (-3 5)
                            [> (call +)]
                            [(or% positive? integer?) 'yes]
                            [else 'no])
                    'yes)
      (check-equal? (switch (-3 5)
                            [> (call +)]
                            [(and% positive? integer?) 'yes]
                            [else 'no])
                    'no)))

   (test-suite
    "definition forms"
    (test-case
        "predicate lambda"
      (check-true ((predicate-lambda (x)
                                     (and positive? integer?))
                   5))
      (check-false ((predicate-lambda (x)
                                      (and positive? integer?))
                    -5))
      (check-false ((predicate-lambda (x)
                                      (and positive? integer?))
                    5.3))
      (check-true ((predicate-lambda (x y)
                                     (or < =))
                   5 6))
      (check-true ((predicate-lambda (x y)
                                     (or < =))
                   5 5))
      (check-false ((predicate-lambda (x y)
                                      (or < =))
                    5 4))
      (check-true ((π (x) (and (> 5) (< 10))) 7))
      (check-false ((π (x) (and (> 5) (< 10))) 2))
      (check-false ((π (x) (and (> 5) (< 10))) 12))
      (check-true ((π args list?) 1 2 3) "packed args")
      (check-false ((π args (.. (> 3) length)) 1 2 3) "packed args")
      (check-true ((π args (.. (> 3) length)) 1 2 3 4) "packed args")
      (check-false ((π args (apply > _)) 1 2 3) "apply with packed args")
      (check-true ((π args (apply > _)) 3 2 1) "apply with packed args"))
    (test-case
        "switch lambda"
      (check-equal? ((switch-lambda (x)
                                    [(and positive? integer?) 'a])
                     5)
                    'a)
      (check-equal? ((switch-lambda (x)
                                    [(and positive? integer?) 'a]
                                    [else 'b])
                     -5)
                    'b)
      (check-equal? ((switch-lambda (x)
                                    [(and positive? integer?) 'a]
                                    [else 'b])
                     5.3)
                    'b)
      (check-equal? ((switch-lambda (x y)
                                    [(or < =) 'a])
                     5 6)
                    'a)
      (check-equal? ((switch-lambda (x y)
                                    [(or < =) 'a])
                     5 5)
                    'a)
      (check-equal? ((switch-lambda (x y)
                                    [(or < =) 'a]
                                    [else 'b])
                     5 4)
                    'b)
      (check-equal? ((λ01 args [list? 'a]) 1 2 3) 'a)
      (check-equal? ((λ01 args
                          [(.. (> 3) length) 'a]
                          [else 'b]) 1 2 3)
                    'b
                    "packed args")
      (check-equal? ((λ01 args
                          [(.. (> 3) length) 'a]
                          [else 'b]) 1 2 3 4)
                    'a
                    "packed args")
      (check-equal? ((λ01 args
                          [(apply < _) 'a]
                          [else 'b]) 1 2 3)
                    'a
                    "apply with packed args")
      (check-equal? ((λ01 args
                          [(apply < _) 'a]
                          [else 'b]) 1 3 2)
                    'b
                    "apply with packed args")))))

(module+ test
  (just-do
   (run-tests tests)))