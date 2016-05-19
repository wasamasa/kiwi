(use (prefix sdl2 sdl2:)
     (prefix kiwi kw:))

;; HACK
(define-record-type sdl2:renderer
  (wrap-renderer pointer)
  renderer?
  (pointer %renderer-pointer %renderer-pointer-set!))

(define-record-type sdl2:window
  (wrap-window pointer)
  window?
  (pointer %window-pointer %window-pointer-set!))

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

(define bg (sdl2:make-color 100 100 200))
(sdl2:render-draw-color-set! renderer bg)

(define driver
  (kw:create-sdl2-render-driver (%renderer-pointer renderer)
                                (%window-pointer window)))

(define tileset
  (kw:load-surface driver "tileset.png"))

(define gui
  (kw:init! driver tileset))

(define fontin
  (kw:load-font driver "Fontin-Regular.ttf" 12))

(define dejavu
  (kw:load-font driver "DejaVuSans.ttf" 12))

(kw:font-set! gui fontin)

(define frame-geometry
  (kw:rect 10 10 (- width 20) (- height 20)))

(define frame
  (kw:frame gui #f frame-geometry))

(define button-geometry
  (kw:rect 120 110 170 30))

(kw:button gui frame "Friendship? Again?!" button-geometry)

(define inner-frame-geometry
  (kw:rect 10 10 (- width 40) 100))

(define inner-frame
  (kw:frame gui frame inner-frame-geometry))

(define content-editbox-geometry
  (kw:rect 120 20 150 30))

(define content-editbox
  (kw:editbox gui inner-frame "Editbox #1" content-editbox-geometry))

(kw:editbox-font-set! content-editbox dejavu)

(define content-label-geometry
  (kw:rect 10 20 110 30))

(define content-label
  (kw:label gui inner-frame "Type your destiny:" content-label-geometry))

(kw:label-alignment-set! content-label 'right 0 'middle 0)

(define confirmation-editbox-geometry
  (kw:rect 120 50 150 30))

(define confirmation-editbox
  (kw:editbox gui inner-frame "Editbox #2" confirmation-editbox-geometry))

(kw:editbox-font-set! confirmation-editbox dejavu)

(define confirmation-label-geometry
  (kw:rect 10 50 110 30))

(define confirmation-label
  (kw:label gui inner-frame "Again:" confirmation-label-geometry))

(kw:label-alignment-set! confirmation-label 'right 0 'middle 0)

(let loop ()
  (when (not (sdl2:quit-requested?))
    (sdl2:render-clear! renderer)
    (kw:paint! gui)
    (sdl2:render-present! renderer)
    (sdl2:delay! 1)
    (loop)))

(kw:quit! gui)
