(use (prefix sdl2 sdl2:)
     (prefix sdl2-image img:)
     (prefix kiwi kw:)
     srfi-1)

(import (only sdl2-internals unwrap-renderer unwrap-window))

(sdl2:set-main-ready!)
(sdl2:init! '(everything))

(define width 640)
(define height 480)

(define-values (window renderer)
  (sdl2:create-window-and-renderer! width height))

(define gray (sdl2:make-color 100 100 100))
(define black (sdl2:make-color 0 0 0))

(define driver (kw:create-sdl2-driver (unwrap-renderer renderer)
                                      (unwrap-window window)))

(define tileset (kw:load-surface driver "tileset.png"))
(define gui (kw:init! driver tileset))

(define font (kw:load-font driver "DejaVuSans.ttf" 11))
(kw:gui-font-set! gui font)

(define image-names (command-line-arguments))

(define (filename->texture filename)
  (condition-case
   (sdl2:create-texture-from-surface
    renderer (img:load filename))
   ((exn sdl2) #f)))

(define image-textures (list->vector (filter-map filename->texture image-names)))

(define current-image #f)
(define current-image-index 0)

(define (load-image! index)
  (when (not (zero? (vector-length image-textures)))
    (set! current-image-index index)
    (set! current-image (vector-ref image-textures index))))

(define (advance-image! proc)
  (when (not (zero? (vector-length image-textures)))
    (let ((index (modulo (proc current-image-index)
                         (vector-length image-textures))))
      (load-image! index))))

(define (prev-image! _widget _button)
  (advance-image! sub1))

(define (next-image! _widget _button)
  (advance-image! add1))

(define blank-label (kw:label gui #f "No images" (kw:rect 0 0 width height)))
(define prev-button (kw:button gui #f "Prev" (kw:rect 0 (- height 24) 120 24)))
(define next-button (kw:button gui #f "Next" (kw:rect (- width 120) (- height 24) 120 24)))

(kw:handler-set! prev-button 'mouse-up prev-image!)
(kw:handler-set! next-button 'mouse-up next-image!)

(load-image! 0)

(define statusbar-rect (sdl2:make-rect 0 (- height 24) 640 24))
(define image-rect (sdl2:make-rect 0 0 width (- height 24)))

(let loop ()
  (when (not (sdl2:quit-requested?))
    (sdl2:render-clear! renderer)
    (sdl2:render-draw-color-set! renderer gray)
    (sdl2:render-fill-rect! renderer statusbar-rect)
    (kw:process-events! gui)
    (sdl2:render-draw-color-set! renderer gray)
    (kw:paint! gui)
    (when current-image
      (sdl2:render-copy! renderer current-image #f image-rect))
    (sdl2:render-present! renderer)
    (sdl2:delay! 1)
    (loop)))

(kw:quit! gui)
(sdl2:quit!)
