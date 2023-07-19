#lang racket

(require rackunit
         "midterm.rkt")

(test-case "flatten-1"
           (check-equal? (flatten-1 '(a b c)) '(a b c))
           (check-equal? (flatten-1 '(a (b) c)) '(a b c))
           (check-equal? (flatten-1 '((a b c) (b) (c d e))) '(a b c b c d e))
           (check-equal? (flatten-1 '(a ((b)) c)) '(a (b) c))
           (check-equal? (flatten-1 '((a) ((b)) ((c)))) '(a (b) (c)))
           (check-equal? (flatten-1 '((a (b) c) (d ((e f) g)) (((h)))))
                         '(a (b) c d ((e f) g) ((h)))))

(test-case "riffle"
           (check-equal? (riffle '(a b) '(1 2 3 4) '(u v w x y z))
                         '(a 1 u b 2 v 3 w 4 x y z))
           (check-equal? (riffle (range 5) (range 6 10) (range 10 15))
                         '(0 6 10 1 7 11 2 8 12 3 9 13 4 14))
           (check-equal? (riffle '(a (b) c) '((d e) f (g h)) '((i j k)))
                         '(a (d e) (i j k) (b) f c (g h)))
           (check-equal? (riffle (range 10) '() (range 90 100) '())
                         '(0 90 1 91 2 92 3 93 4 94 5 95 6 96 7 97 8 98 9 99)))

(test-case "wordle exact matches"
           (check-equal? (wordle "CAT" "CAT")       '(* * *))
           (check-equal? (wordle "BAT" "CAT")       '(_ * *))
           (check-equal? (wordle "LAP" "CAT")       '(_ * _))
           (check-equal? (wordle "CATCH" "PARCH")   '(_ * _ * *))
           (check-equal? (wordle "PANTS" "PERLS")   '(* _ _ _ *))
           (check-equal? (wordle "ABACUS" "ALARUM") '(* _ * _ * _)))

(test-case "wordle inexact matches"
           (check-equal? (wordle "MER" "ERM")       '(+ + +))
           (check-equal? (wordle "FAST" "TRAM")     '(+ _ + _))
           (check-equal? (wordle "FASTER" "STREAK") '(+ + + + + _))
           (check-equal? (wordle "ABCDEF" "BCDEFA") '(+ + + + + +)))

(test-case "wordle duplicate letters"
           (check-equal? (wordle "MASSED" "SWILLS") '(+ _ _ _ _ +))
           (check-equal? (wordle "AABBCC" "BBCCAA") '(+ + + + + +))
           (check-equal? (wordle "AABBAA" "BBAABB") '(+ + + + _ _))
           (check-equal? (wordle "ABCDEFGHI" "BCDEFGHIA") '(+ + + + + + + + +)))

(test-case "wordle exact & inexact matches"
           (check-equal? (wordle "FETCHES" "RHYMERS") '(_ + _ _ + _ *))
           (check-equal? (wordle "SWEETLY" "TWENTYS") '(_ * * _ * + +))
           (check-equal? (wordle "SWEETLY" "EEEEEEE") '(_ _ * * _ _ _))
           (check-equal? (wordle "SWEETLY" "EEFFEEE") '(+ + _ _ _ _ _))
           (check-equal? (wordle "ABRACADABRA" "BLADIBLARDA") '(+ _ + + _ + _ * + _ *)))


(test-case "until"
           (check-equal? (until (lambda (x) (> x 100))
                                (lambda (x) (* 2 x))
                                1)
                         '(1 2 4 8 16 32 64))
           (check-equal? (until (curry = 10) add1 0)
                         '(0 1 2 3 4 5 6 7 8 9))
           (check-equal? (until (curry < 1000) sqr 2)
                         '(2 4 16 256))
           (check-equal? (until empty? rest (range 10))
                         '((0 1 2 3 4 5 6 7 8 9)
                           (1 2 3 4 5 6 7 8 9)
                           (2 3 4 5 6 7 8 9)
                           (3 4 5 6 7 8 9)
                           (4 5 6 7 8 9)
                           (5 6 7 8 9)
                           (6 7 8 9)
                           (7 8 9)
                           (8 9)
                           (9))))


(test-case "alternately"
           (check-equal? (alternately (list add1 sub1 sqr) (range 10))
                         '(1 0 4 4 3 25 7 6 64 10))
           (check-equal? (alternately (list add1 sub1 sqr) (range 10 20))
                         '(11 10 144 14 13 225 17 16 324 20))
           (check-equal? (alternately (list add1) (range 10))
                         '(1 2 3 4 5 6 7 8 9 10))
           (check-equal? (alternately (list string-upcase string-downcase string-length)
                                      (list "Hello" "How" "Are" "You" "This" "Fine" "Day?"))
                         '("HELLO" "how" 3 "YOU" "this" 4 "DAY?")))


(test-case "stride"
           (check-equal? (stride x 2 '("hello" "how" "are" "you" "this" "fine" "day")
                                 (string-upcase x))
                         '("HELLO" "ARE" "THIS" "DAY"))
           (check-equal? (stride x 5 (range 30)
                                 (sqr x))
                         '(0 25 100 225 400 625))
           (check-equal? (stride x 1 '(a b c d e)
                                 x)
                         '(a b c d e)))


(test-case "case expression (basic)"
           (check-equal? (eval (desugar (parse '(case 1
                                                  [1 10]
                                                  [3 20]
                                                  [5 30]
                                                  [else 40]))))
                         10)
           (check-equal? (eval (desugar (parse '(case 3
                                                  [1 10]
                                                  [3 20]
                                                  [5 30]
                                                  [else 40]))))
                         20)
           (check-equal? (eval (desugar (parse '(case 5
                                                  [1 10]
                                                  [3 20]
                                                  [5 30]
                                                  [else 40]))))
                         30)
           (check-equal? (eval (desugar (parse '(case 2
                                                  [1 10]
                                                  [3 20]
                                                  [5 30]
                                                  [else 40]))))
                         40)
           (check-equal? (eval (desugar (parse '(case 10
                                                  [1 10]
                                                  [3 20]
                                                  [5 30]
                                                  [else 40]))))
                         40))

(test-case "case expression (non-trivial exp/body)"
           (check-equal? (eval (desugar (parse '(case 1
                                                  [1 (* 2 3)]
                                                  [3 (+ 3 4)]
                                                  [5 (* 2 (+ 3 8))]
                                                  [else (+ 30 10)]))))
                         6)
           (check-equal? (eval (desugar (parse '(case (+ 1 2)
                                                  [1 (* 2 3)]
                                                  [3 (+ 3 4)]
                                                  [5 (* 2 (+ 3 8))]
                                                  [else (+ 30 10)]))))
                         7)
           (check-equal? (eval (desugar (parse '(case (+ 2 3)
                                                  [1 (* 2 3)]
                                                  [3 (+ 3 4)]
                                                  [5 (* 2 (+ 3 8))]
                                                  [else (+ 30 10)]))))
                         22)
           (check-equal? (eval (desugar (parse '(case (* 3 3)
                                                  [1 (* 2 3)]
                                                  [3 (+ 3 4)]
                                                  [5 (* 2 (+ 3 8))]
                                                  [else (+ 30 10)]))))
                         40))

(test-case "case expression (nested)"
           (check-equal? (eval (desugar (parse '(let ([x 2]
                                                      [y 5])
                                                  (case x
                                                    [2 (+ x 2)]
                                                    [5 (* x y)]
                                                    [7 (+ y 30)]
                                                    [else (* x 1000)])))))
                         4)
           (check-equal? (eval (desugar (parse '(let ([x 2]
                                                      [y 5])
                                                  (case y
                                                    [2 (+ x 2)]
                                                    [5 (* x y)]
                                                    [7 (+ y 30)]
                                                    [else (* x 1000)])))))
                         10)
           (check-equal? (eval (desugar (parse '(let ([x 2]
                                                      [y 5])
                                                  (case (+ x y)
                                                    [2 (+ x 2)]
                                                    [5 (* x y)]
                                                    [7 (+ y 30)]
                                                    [else (* x 1000)])))))
                         35)
           (check-equal? (eval (desugar (parse '(let ([x 2]
                                                      [y 5])
                                                  (case (* x y)
                                                    [2 (+ x 2)]
                                                    [5 (* x y)]
                                                    [7 (+ y 30)]
                                                    [else (* x 1000)])))))
                         2000))