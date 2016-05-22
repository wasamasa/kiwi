(use (prefix sdl2 sdl2:)
     (prefix kiwi kw:)
     srfi-17)

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

(define drag-mode #f)

(define (drag-start widget x y)
  (let ((geometry (kw:widget-geometry widget #t)))
    (if (and (> x (- (+ (kw:rect-x geometry) (kw:rect-w geometry)) 20))
             (> y (- (+ (kw:rect-y geometry) (kw:rect-h geometry)) 20)))
        (set! drag-mode #t)
        (set! drag-mode #f)))
  (printf "Drag has started at ~ax~a\n" x y))

(define (drag-stop widget x y)
  (printf "Drag has stopped at ~ax~a\n" x y))

(define (drag widget x y xrel yrel)
  (let ((geometry (kw:widget-geometry widget)))
    (if drag-mode
        (begin
          (set! (kw:rect-w geometry) (+ (kw:rect-w geometry) xrel))
          (set! (kw:rect-h geometry) (+ (kw:rect-h geometry) yrel)))
        (begin
          (set! (kw:rect-x geometry) (+ (kw:rect-x geometry) xrel))
          (set! (kw:rect-y geometry) (+ (kw:rect-y geometry) yrel))))
    (set! (kw:widget-geometry widget) geometry)))

(define width 640)
(define height 480)

(define-values (window renderer)
  (sdl2:create-window-and-renderer! width height))

(sdl2:render-draw-color-set! renderer (sdl2:make-color 200 100 100))

(define driver
  (kw:create-sdl2-render-driver (unwrap-renderer renderer)
                                (unwrap-window window)))

(define gui
  (kw:init! driver (kw:load-surface driver "tileset.png")))

(kw:font-set! gui (kw:load-font driver "Fontin-Regular.ttf" 12))

(define frame
  (kw:frame gui #f (kw:rect 50 50 100 100)))

(kw:handler-set! frame 'drag drag)

(define a
  (kw:button gui frame "Yay" (kw:rect 0 0 (/ width 4) (/ height 4))))

(kw:handler-set! a 'drag-start drag-start)
(kw:handler-set! a 'drag-stop drag-stop)
(kw:handler-set! a 'drag drag)

(define b
  (kw:button gui frame "Yay" (kw:rect 10 10 (/ width 4) (/ height 4))))

(kw:handler-set! b 'drag-start drag-start)
(kw:handler-set! b 'drag-stop drag-stop)
(kw:handler-set! b 'drag drag)

(let loop ()
  (when (not (sdl2:quit-requested?))
    (sdl2:render-clear! renderer)
    (kw:process-events! gui)
    (kw:paint! gui)
    (sdl2:delay! 1)
    (sdl2:render-present! renderer)
    (loop)))

(kw:quit! gui)
