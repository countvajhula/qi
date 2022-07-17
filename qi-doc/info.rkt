#lang info

(define version "2.0")
(define collection "qi")
(define deps '("base"))
(define build-deps '("scribble-lib"
                     "scribble-abbrevs"
                     "scribble-math"
                     "racket-doc"
                     "sandbox-lib"
                     "math-lib"
                     "qi-lib"
                     "qi-probe"
                     "relation"))
(define scribblings '(("scribblings/qi.scrbl" (multi-page) (language))))
(define clean '("compiled" "doc" "doc/qi"))
