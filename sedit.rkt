#!/usr/bin/racket
#lang racket

(require racket/cmdline)
(require 2htdp/image)
(require 2htdp/universe)

(define filename "/dev/null")

(define app-name (find-system-path 'run-file))

(define (arg-error)
  (printf "No argument provided for file\n")
  (printf "Usage: ~a filename\n" app-name)
  (exit))

(let ([args (current-command-line-arguments)])
  (if (vector-empty? args)
      (arg-error)
      (set! filename (vector-ref args 0))))

(define WIDTH 500)
(define HEIGHT 40)
(define TEXT-SIZE 18)
(define CURSOR-WIDTH 1)

(define MT-SCN
  (empty-scene WIDTH HEIGHT))

(define CURSOR
  (rectangle CURSOR-WIDTH TEXT-SIZE "solid" "red"))

(define-struct editor [pre post] #:transparent)

(define (text-renderer txt)
  (text txt TEXT-SIZE "black"))

(define (render ed)
  (overlay/align "left" "center"
                 (beside
                  (text-renderer (editor-pre ed))
                  CURSOR
                  (text-renderer (editor-post ed)))
                 MT-SCN))

;; fer|had --> fe|rhad
;; |ferhad --> |ferhad
(define (go-left ed)
  (let* ([pre (editor-pre ed)]
         [post (editor-post ed)]
         [pre-len (string-length pre)]
         [post-len (string-length post)])
    (if (= pre-len 0)
        ed
        (editor
         (substring pre 0 (- pre-len 1))
         (string-append
          (substring pre (- pre-len 1) pre-len)
          post)))))

;; ferh|ad --> ferha|d
;; ferhad| --> ferhad|
(define (go-right ed)
  (let* ([pre (editor-pre ed)]
         [post (editor-post ed)]
         [pre-len (string-length pre)]
         [post-len (string-length post)])
    (if (= post-len 0)
        ed
        (editor
         (string-append
          pre
          (substring post 0 1))
        (substring post 1 post-len)))))

(define (remove-letter ed)
  (let* ([pre (editor-pre ed)]
         [post (editor-post ed)]
         [pre-len (string-length pre)])
    (if (= (string-length pre) 0) ed
        (make-editor
         (substring pre 0 (- pre-len 1))
         post))))

;; ferha|d --> ferha|
;; fer|had --> fer|ad
(define (remove-letter-del ed)
  (let* ([pre (editor-pre ed)]
         [post (editor-post ed)]
         [post-len (string-length post)])
    (if (= post-len 0) ed
        (make-editor pre
                     (substring post 1 post-len)))))

(define (append-letter ed a-key)
  (let ([pre (editor-pre ed)]
        [post (editor-post ed)])
    (make-editor
     (string-append pre a-key)
     post)))

(define (edit ed a-key)
  (cond
    [(key=? a-key "left") (go-left ed)]
    [(key=? a-key "right") (go-right ed)]
    [(key=? a-key "\b") (remove-letter ed)]
    [(key=? a-key "\u007F") (remove-letter-del ed)]
    [(= (string-length a-key) 1) (append-letter ed a-key)]
    [else ed]))

(define (read-file)
  (make-editor
   (call-with-input-file filename
     (λ (in)
       (read-line in)))
   ""))

(define (read-file-if-exists)
  (if (file-exists? filename)
      (read-file)
      (make-editor "" "")))

(define (editor-app)
  (big-bang
   (read-file-if-exists)
   [to-draw render]
   [on-key edit]))

(editor-app)
