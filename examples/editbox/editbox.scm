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

(define driver (kw:create-sdl2-render-driver (unwrap-renderer renderer)
                                             (unwrap-window window)))

(define tileset (kw:load-surface driver "tileset.png"))
(define gui (kw:init! driver tileset))

(define font (kw:load-font driver "DejaVuSans.ttf" 12))
(kw:font-set! gui font)

(define window-geometry (kw:rect 0 0 width height))
(define frame-geometry (kw:rect 10 10 (- width 20) (- height 20)))
(kw:rect-center-in-parent! window-geometry frame-geometry)

(define frame (kw:frame gui #f frame-geometry))
(define label-geometry (kw:rect 0 100 60 30))
(define editbox-geometry (kw:rect 0 100 100 30))

(kw:rect-fill-parent-horizontally! frame-geometry
                                   (list label-geometry editbox-geometry)
                                   '(1 4) 2 10 'middle)

(kw:label gui frame "Editbox example" (kw:rect 0 10 300 30))
(kw:label gui frame "Label" label-geometry)
(kw:editbox gui frame "Edit me!" editbox-geometry)

(define quit? #f)

(define (ok-clicked _widget _button)
  (set! quit? #t))

(define ok-button (kw:button gui frame "OK" (kw:rect 250 170 40 40)))
(kw:handler-set! ok-button 'mouse-down ok-clicked)

(let loop ()
  (when (and (not (sdl2:quit-requested?)) (not quit?))
    (sdl2:render-clear! renderer)
    (kw:process-events! gui)
    (kw:paint! gui)
    (sdl2:render-present! renderer)
    (sdl2:delay! 1)
    (loop)))

(kw:quit! gui)
