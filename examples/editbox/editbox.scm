(use (prefix sdl2 sdl2:)
     (prefix kiwi kw:))

(import (only sdl2-internals unwrap-renderer unwrap-window))

;;; clean-up code

(sdl2:set-main-ready!)
(sdl2:init! '(everything))

(on-exit sdl2:quit!)

(current-exception-handler
 (let ((original-handler (current-exception-handler)))
   (lambda (exception)
     (sdl2:quit!)
     (original-handler exception))))

;;; actual example

(define width 320)
(define height 240)

(define-values (window renderer)
  (sdl2:create-window-and-renderer! width height))

(sdl2:render-draw-color-set! renderer (sdl2:make-color 100 100 200))

(define driver
  (kw:create-sdl2-render-driver (unwrap-renderer renderer)
                                (unwrap-window window)))

(define gui
  (kw:init! driver (kw:load-surface driver "tileset.png")))

(define fontin
  (kw:load-font driver "Fontin-Regular.ttf" 12))

(define dejavu
  (kw:load-font driver "DejaVuSans.ttf" 12))

(kw:font-set! gui fontin)

(define frame
  (kw:frame gui #f (kw:rect 10 10 (- width 20) (- height 20))))

(kw:button gui frame "Friendship? Again?!" (kw:rect 120 110 170 30))

(define inner-frame
  (kw:frame gui frame (kw:rect 10 10 (- width 40) 100)))

(define content-editbox
  (kw:editbox gui inner-frame "Editbox #1" (kw:rect 120 20 150 30)))

(kw:editbox-font-set! content-editbox dejavu)

(define content-label
  (kw:label gui inner-frame "Type your destiny:" (kw:rect 10 20 110 30)))

(kw:label-alignment-set! content-label 'right 0 'middle 0)

(define confirmation-editbox
  (kw:editbox gui inner-frame "Editbox #2" (kw:rect 120 50 150 30)))

(kw:editbox-font-set! confirmation-editbox dejavu)

(define confirmation-label
  (kw:label gui inner-frame "Again:" (kw:rect 10 50 110 30)))

(kw:label-alignment-set! confirmation-label 'right 0 'middle 0)

(let loop ()
  (when (not (sdl2:quit-requested?))
    (sdl2:render-clear! renderer)
    (kw:process-events! gui)
    (kw:paint! gui)
    (sdl2:render-present! renderer)
    (sdl2:delay! 1)
    (loop)))

(kw:quit! gui)
