#lang info

(define collection "qi")
(define deps '("base"))
(define build-deps '("rackunit-lib"
                     "cover"
                     "cover-coveralls"
                     "math-lib"
                     "qi-lib"
                     "relation"))
(define test-include-paths '("tests"))
(define test-omit-paths '("dev" "coverage"))
(define clean '("compiled" "tests/compiled" "tests/private/compiled"))