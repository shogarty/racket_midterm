CS 440 Midterm Exam (Take-Home)
===============================

This midterm exam consists of 7 separate exercises --- 3 on recursion and lists, 3 on higher order functions, and 1 involving an addition to an interpreter. They are described below:

## Part 1: Recursion and lists

- `flatten-1`: takes a list and "flattens" any nested lists by one level. E.g.,

        > (flatten-1 '(a (b c) d))
        '(a b c d)
        
        > (flatten-1 '((a) (b ((c) (d))) ((e f))))     
        '(a b ((c) (d)) (e f))
        
        > (flatten-1 (flatten-1 '((a) (b ((c) (d))) ((e f)))))
        '(a b (c) (d) e f)
        
        > (flatten-1 (flatten-1 (flatten-1 '((a) (b ((c) (d))) ((e f))))))
        '(a b c d e f)
        
- `riffle` takes one or more lists and "riffles" (shuffles) their contents together in alternating fashion into one single list. E.g.,

        > (riffle '(a b) '(1 2 3 4) '(u v w x y z))
        '(a 1 u b 2 v 3 w 4 x y z)
                         
        > (riffle (range 5) (range 6 10) (range 10 15))
        '(0 6 10 1 7 11 2 8 12 3 9 13 4 14)                         

- `wordle` takes two strings -- a solution and guess (a la [Wordle](https://www.nytimes.com/games/wordle/index.html)) -- and returns a list of clues that indicate which characters in the guess are in the correct spot (`*`), which match a character from the solution but are in the incorrect spot (`+`), and which don't match any solution characters at all (`_`).

    Correct-spot characters are given precedence, and incorrect-spot characters are matched from left to right. You should assume that the solution and guess are the same length. E.g.,

        > (wordle "CATCH" "PARCH")   
        '(_ * _ * *)

        > (wordle "FASTER" "STREAK") 
        '(+ + + + + _)

        > (wordle "SWEETLY" "TWENTYS")
        '(_ * * _ * + +)
    
    You may find it useful to use the [`string->list`](https://docs.racket-lang.org/reference/strings.html#%28def._%28%28quote._~23~25kernel%29._string-~3elist%29%29) function, which takes a string and returns a list of characters (which you can compare using `eq?`). You may also find [`for`](https://docs.racket-lang.org/reference/for.html) (or a variant) helpful, though not necessary.
  
## Part 2: Higher order functions

- `until`: takes a predicate `pred`, a function `fn`, and a starting value `x`, and returns the list of values (`x`, `(fn x)`, `(fn (fn x))`, ...), terminating on the first value which satisfies `pred`. E.g.,

        > (until (lambda (x) (> x 100))
                 (lambda (x) (* 2 x))
                 1)
        '(1 2 4 8 16 32 64)
        
        > (until (curry = 10) add1 0)
        '(0 1 2 3 4 5 6 7 8 9)
        
- `alternately`: takes a list of functions and a list of values, and returns the list created by applying each function, in turn, to successive values of the list. E.g.,

        > (alternately (list add1 sub1 sqr) (range 10))
        '(1 0 4 4 3 25 7 6 64 10)

        > (alternately (list string-upcase string-downcase string-length)
                       (list "Hello" "How" "Are" "You" "This" "Fine" "Day?"))
        '("HELLO" "how" 3 "YOU" "this" 4 "DAY?")
        
- `stride`: a macro that takes a variable name `var`, a stride length `n`, a list `lst`, and an expression `expr`, and returns the list of values resulting from evaluating `expr` with `var` set to each `n`-th value from the `lst`. E.g.,

        > (stride x 2 '("hello" "how" "are" "you" "this" "fine" "day")
                  (string-upcase x))
        '("HELLO" "ARE" "THIS" "DAY")

        > (stride x 5 (range 30)
                  (sqr x))
        '(0 25 100 225 400 625)

## Part 3: Interpreter modifications

- For this part you will add a `case` expression to the same interpreter provided for MP2. A case expression has the following form:

        (case TEST-EXPR
            [INT-VAL1 EXPR1]
            [INT-VAL2 EXPR2]
            ...
            [else ELSE-EXPR])

    The `TEST-EXPR` is first evaluated, and its result is compared to the various `INT-VAL`s --- if one matches, the corresponding `EXPR` is evaluated and becomes the result of the `case` expressions. If none of the `INT-VAL`s match, the `ELSE-EXPR` is evaluated.
    
    E.g.,
    
        > (case 1
            [1 10]
            [3 20]
            [5 30]
            [else 40])
        10    
        
        > (case (+ 2 3)
            [1 (* 2 3)]
            [3 (+ 3 4)]
            [5 (* 2 (+ 3 8))]
            [else (+ 30 10)]))))
        22
        
    You may choose to implement the `case` statement either by desugaring it to `if` expressions or by modifying the `eval` function directly. If you choose to use desugaring, feel free to reuse your code from MP2.
    
## Implementation rules

You may use any of the functions from Racket's base library, as described in the [Racket Guide](https://docs.racket-lang.org/guide/index.html) (and demonstrated in the [lecture source files](https://github.com/cs440lang/lectures/tree/completed)). You should *not* use any other libraries/modules. 

## Testing

We have provided you with test cases in "midterm-test.rkt". Feel free to add to and alter any and all tests, as we will be using our own test suite to evaluate your work. You may also find it helpful to read through the tests for more insight into how your implementations should behave.

Note that passing all the tests does not guarantee full credit! Partial credit may be awarded to implementations that fail tests. That said, code that fails to compile will receive little (if any) credit.

## Grading

Each exercise in Part 1 is worth 10 points (for 30 total points)

Each exercise in Part 2 is worth 10 points (for 30 total points)

Part 3 is worth 20 points.

The maximum possible points is 30 + 30 + 20 = 80 points.


## Submission

When you are done with your work, simply commit your changes and push them to
our shared private GitHub repository. You must commit your work before 1PM (CDT) on Saturday, March 26th. 