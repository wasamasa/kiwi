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

(sdl2:render-draw-color-set! renderer (sdl2:make-color 100 100 100))

(define driver (kw:create-sdl2-render-driver (unwrap-renderer renderer)
                                             (unwrap-window window)))

(define tileset (kw:load-surface driver "tileset.png"))
(define gui (kw:init! driver tileset))

(define font (kw:load-font driver "Fontin-Regular.ttf" 12))
(kw:font-set! gui font)

(kw:widgets gui
 `(frame
   (@ (x 0) (y 0) (w ,width) (h ,height))
   (label
    (@ (x 0) (y 0) (w ,width) (h ,height)
       (icon ((x 0) (y 48) (w 24) (h 24)))
       (text "Label with an icon :)")))))

(let loop ()
  (when (not (sdl2:quit-requested?))
    (sdl2:render-clear! renderer)
    (kw:process-events! gui)
    (kw:paint! gui)
    (sdl2:delay! 1)
    (sdl2:render-present! renderer)
    (loop)))

(kw:quit! gui)
