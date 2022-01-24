#lang racket/base

(provide tests)

(require qi
         rackunit
         (only-in math sqr)
         (for-syntax syntax/parse
                     racket/base))

(define-qi-syntax-rule (square flo:expr)
  (feedback 2 flo))

(define-qi-syntax-rule (pare car-flo cdr-flo)
  (group 1 car-flo cdr-flo))

(define-qi-syntax-parser cube
  [(_ flo) #'(feedback 3 flo)])

(define-qi-syntax-rule (fanout n)
  'hello)

(define-qi-syntax-parser kazam
  [_:id #''hello])

(define tests
  (test-suite
   "macro tests"
   (check-equal? ((☯ (square sqr)) 2) 16)
   (check-equal? ((☯ (~> (pare sqr +) ▽)) 3 6 9) (list 9 15))
   (check-equal? ((☯ (cube sqr)) 2) 256)
   (check-equal? ((☯ (fanout 5)) 2) 'hello "extensions can override built-in forms")
   (check-equal? ((☯ kazam) 2) 'hello "extensions can add identifier macros")))