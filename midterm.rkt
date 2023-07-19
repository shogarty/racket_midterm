#lang racket

#|-----------------------------------------------------------------------------
;; CS 440 Midterm Exam (Take Home)
-----------------------------------------------------------------------------|#

(provide flatten-1
         riffle
         wordle
         until
         alternately
         stride
         parse
         desugar
         eval)


;;; Part 1: Recursion and Lists


(define (flatten-1 lst)
  (cond [(empty? lst) '()]
        [(not (list? (car lst))) (append (list (car lst)) (flatten-1 (cdr lst)))] 
        [else (append (car lst) (flatten-1 (cdr lst)))])
   )


(define (riffle . lsts)
  (let ([out '()])
    (letrec ([rec (lambda (lsts out)
                    (if (empty? lsts)
                        out
                        (if (empty?(car lsts))
                            (rec (cdr lsts) out)
                            (rec (append (cdr lsts) (list(cdr(car lsts)))) (append out (list(car(first lsts))))))
                        )
                    )])
      (rec lsts out)
      )                    
    )                                
  )                     


(define (wordle sol guess)
  (let ([sol (string-copy sol)]
        [guess (string-copy guess)])
    

    (for ([i (in-range (string-length guess))])
      (when (equal?(string-ref sol i) (string-ref guess i))
        (string-set! sol (index-of (string->list sol)(string-ref guess i)) #\^)
        (string-set! guess i #\* )))
    
      
     (for ([i (in-range (string-length guess))])
       (cond [(equal? (string-ref guess i) #\*) (values)]
             [(not(equal? (member (string-ref guess i) (string->list sol)) #f))
             (begin (string-set! sol (index-of (string->list sol)(string-ref guess i)) #\^)
                    (string-set! guess i #\+ ))]
            [else (string-set! guess i #\_ )]
            )
      )
    (map string->symbol (map string(string->list guess)))
    )
      
  )
           

;;; Part 2: HOFs

(define (until pred fn x)
  (if (pred x)
      '()
      (append (list x) (until pred fn (fn x))) )
  )

;;back from mp1, helper for alternatively
(define (rotate n lst)
  (if (= n 0)
      lst
      (rotate (- n 1) (append (cdr lst) (list (car lst)))))
  )


(define (alternately fns vals)
  (letrec ([rec (lambda(fns vals idx)
                  (if (< idx (length vals))
                      (rec (rotate 1 fns) (list-update vals idx (car fns)) (+ idx 1))
                      vals))])
    (rec fns vals 0)
    )    
  )

(define (do-null v)
  v)
  
(define (set-val val setter)
  setter)


(define-syntax-rule (stride var n lst expr)
  (remove* (list 'blarg) (alternately (cons (lambda (var) expr) (make-list (- n 1) (lambda (arg) (set-val arg 'blarg)))) lst))
  )


;;; Part 3: Interpreter (case expression)

;; in the interest of "I don't want to bother rewriting code and it might be useful"
;; i will now proceed to copy paste my entire mp2 into here.
;; For your convenience I will make a comment on any new stuff i added for the midterm.

;; integer value
(struct int-exp (val) #:transparent)

;; arithmetic expression
(struct arith-exp (op lhs rhs) #:transparent)

;; variable
(struct var-exp (id) #:transparent)

;; let expression
(struct let-exp (ids vals body) #:transparent)

;; lambda expression
(struct lambda-exp (id body) #:transparent)

;; function application
(struct app-exp (fn arg) #:transparent)

;; boolean literal
(struct bool-exp (bool) #:transparent)

;;logic expression
(struct logic-exp (op args) #:transparent)

;; if expression
(struct if-exp (bool tbody fbody) #:transparent)

;; cond expression
(struct cond-exp (bools vals elseval) #:transparent)

;;relational expression
(struct rel-exp (op lhs rhs) #:transparent)

;;case expression (NEW FEATURE! BUY DISCORD NITRO TO TRY NOW)
(struct case-exp (test nums vals elseval) #:transparent)

;; Parser
(define (parse sexp)
  (match sexp
    ;; integer literal
    [(? integer?)
     (int-exp sexp)]

    ;; arithmetic expression
    [(list (and op (or '+ '* '-)) lhs rhs)
     (arith-exp (symbol->string op) (parse lhs) (parse rhs))]

    ;; identifier (variable)
    [(? symbol?)
     (var-exp sexp)]

    ;;logic expresiion
    [(list 'and args ...)
     (logic-exp "and" (map parse args))]
    [(list 'or args ...)
     (logic-exp "or" (map parse args))]

    ;;cond expression
    [(list 'cond (list bools vals) ... (list 'else elseval))
     (cond-exp (map parse bools) (map parse vals) (parse elseval))]

    ;;case expression (NOW AVAILABLE FOR AMAZON PRIME CUSTOMERS ONLY!)
    [(list 'case test (list nums vals) ... (list 'else elseval))
     (case-exp (parse test) (map parse nums) (map parse vals) (parse elseval))]
    
    ;; boolean expression
    [(? boolean?)
     (bool-exp sexp)]

    ;;relational expresssion
    [(list (and op (or '= '< '> '<= '>= '!=)) lhs rhs)
     (rel-exp (symbol->string op) (parse lhs) (parse rhs))]

    ;; let expressions
    [(list 'let (list (list id val) ...) body)
     (let-exp (map parse id) (map parse val) (parse body))]

    ;; if expression
    [(list 'if bool tbody fbody)
     (if-exp (parse bool) (parse tbody) (parse fbody))]

    ;; lambda expression -- modified for > 1 params
    [(list 'lambda (list ids ...) body)
     (lambda-exp ids (parse body))]

    ;; function application -- modified for > 1 args
    [(list f args ...)
     (app-exp (parse f) (map parse args))]

    ;; basic error handling
    [_ (error (format "Can't parse: ~a" sexp))]))


;; Desugar-er -- i.e., syntax transformer
(define (desugar exp)
  (match exp

    ((arith-exp (and op (or "+" "*")) lhs rhs)
     (arith-exp op (desugar lhs) (desugar rhs)))  

    ((arith-exp "-" lhs rhs)
     (arith-exp "+" (desugar lhs) (desugar (arith-exp "*" (int-exp -1) rhs)) ))

    ((rel-exp (and op (or "=" "<")) lhs rhs)
     (rel-exp op (desugar lhs) (desugar rhs)))

    ((rel-exp ">" lhs rhs)
      (rel-exp "<" (desugar rhs) (desugar lhs)))
    
    ((rel-exp "<=" lhs rhs)
     (if-exp (rel-exp "<" (desugar rhs) (desugar lhs))
             (bool-exp #f)
             (bool-exp #t)))

    ((rel-exp ">=" lhs rhs)
     (if-exp (rel-exp "<" (desugar lhs) (desugar rhs))
             (bool-exp #f)
             (bool-exp #t)))

    ((logic-exp "and" args)
     (if(empty? args)
        (bool-exp #t)
        (if-exp (bool-exp(desugar(first args)))
                (desugar (logic-exp "and" (rest args)))
                (bool-exp #f))))
                                      
     
    ((logic-exp "or" args)
     (if(empty? args)
        (bool-exp #f)
        (if-exp (bool-exp(desugar(first args)))
                (bool-exp #t)
                (desugar (logic-exp "or" (rest args))))))

    ;lets the arguments of if-exps get desugared. NECESSARY FOR LOAD-DEFS
    ((if-exp bool tbody fbody)
     (if-exp (desugar bool) (desugar tbody) (desugar fbody)))

    ((cond-exp bools vals elseval)
     (if(empty? bools)
        (desugar elseval)
        (if-exp (bool-exp(desugar (first bools)))
                (desugar (first vals))
                (desugar (cond-exp (rest bools) (rest vals) elseval)))))
    
    ;;Am I doing this as a desugaring even tho it's harder just to flex?
    ;;yes yes I am
    ;;Also,
    ;;NEW FEATURE, PLATINUM MEMBERS ONLY
    ;;UNLOCK NOW FOR THE LOW PRICE OF YOUR MORTAL SOUL
    ;;ENTER PROMO CODE "THIS CLASS SHOULD HAVE BEEN IN HASKELL"
    ;;AND YOU CAN HAVE YOUR DIGNITY DISCOUNTED OFF THE PRICE
    ((case-exp test nums vals elseval)
     (if(empty? nums)
        (desugar elseval)
        (if-exp (rel-exp "=" (desugar test) (desugar (first nums)))
                (desugar (first vals))
                (desugar (case-exp test (rest nums) (rest vals) elseval)))))

                     
     
    ((let-exp ids vals body)
     (let-exp ids (map desugar vals) (desugar body)))
    
    ((lambda-exp ids body)
     (foldr (lambda (id lexp) (lambda-exp id lexp))
            (desugar body)
            ids))

    ((app-exp f args)
     (foldl (lambda (id fexp) (app-exp fexp id))
            (desugar f)
            (map desugar args)))

    
    ;lets items in lists get desugared.
    ((list items ...)
     (map desugar items))
     
    (_ exp)))


;; function value + closure
(struct fun-val (id body env) #:prefab)


;; Interpreter
(define (eval expr [env '()])
  (match expr
    ;; int literal
    [(int-exp val) val]

    ;; boolean
    [(bool-exp (and bool (or '#t '#f))) bool]
    [(bool-exp bool) (eval bool env)]

    ;; if expression
    [(if-exp bool tbody fbody)
     (if (eval bool env) (eval tbody env) (eval fbody env))]

    ;; arithmetic expression
    [(arith-exp "+" lhs rhs)
     (+ (eval lhs env) (eval rhs env))]
    [(arith-exp "*" lhs rhs)
     (* (eval lhs env) (eval rhs env))]
    

    ;;relational expression
    [(rel-exp "=" lhs rhs)
     ( if ( = (eval lhs env) (eval rhs env)) #t #f)]
    [(rel-exp "<" lhs rhs)
     ( if ( < (eval lhs env) (eval rhs env)) #t #f)]
          
    ;; variable binding
    [(var-exp id)
     (let ([pair (assoc id env)])
       (if pair (cdr pair) (error (format "~a not bound!" id))))]

    ;; let expression
    [(let-exp (list (var-exp id) ...) (list val ...) body)
     (let ([vars (map cons id
                      (map (lambda (v) (eval v env)) val))])
       (eval body (append vars env)))]

     
    ;; lambda expression
    [(lambda-exp id body)
     (fun-val id body env)]

    ;; function application
    [(app-exp f arg)
     (match-let ([(fun-val id body clenv) (eval f env)]
                 [arg-val (eval arg env)])
       (eval body (cons (cons id arg-val) clenv)))]

    ;; basic error handling
    [_ (error (format "Can't evaluate: ~a" expr))]))
