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
  (let ((geometry (kw:widget-absolute-geometry widget)))
    (if (and (> x (- (+ (kw:rect-x geometry) (kw:rect-w geometry)) 20))
             (> y (- (+ (kw:rect-y geometry) (kw:rect-h geometry)) 20)))
        (set! drag-mode #t)
        (set! drag-mode #f))))

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

(define width 320)
(define height 240)

(define-values (window renderer)
  (sdl2:create-window-and-renderer! width height '(resizable)))

(sdl2:render-draw-color-set! renderer (sdl2:make-color 100 200 100))

(define driver (kw:create-sdl2-driver (unwrap-renderer renderer)
                                      (unwrap-window window)))

(define tileset (kw:load-surface driver "tileset.png"))
(define gui (kw:init! driver tileset))

(define font (kw:load-font driver "SourceSansPro-Semibold.ttf" 12))
(kw:font-set! gui font)

(define (->int x)
  (inexact->exact (ceiling x)))

(define (squash-rect! rect)
  (set! (kw:rect-x rect) (->int (* (kw:rect-w rect) 0.0625)))
  (set! (kw:rect-y rect) (->int (* (kw:rect-h rect) 0.0625)))
  (set! (kw:rect-w rect) (->int (* (kw:rect-w rect) 0.875)))
  (set! (kw:rect-h rect) (->int (* (kw:rect-h rect) 0.875))))

(define scrollbox-geometry (kw:rect 0 0 width height))
(squash-rect! scrollbox-geometry)

(define scrollbox (kw:scrollbox gui #f scrollbox-geometry))

(kw:handler-set! scrollbox 'drag-start drag-start)
(kw:handler-set! scrollbox 'drag drag)

(let loop ((i 0))
  (when (< i 5)
    (let* ((geometry (kw:rect 10 (* 40 i) 230 40))
           (button (kw:button gui scrollbox "Drag me, resize me." geometry)))
      (kw:handler-set! button 'drag-start drag-start)
      (kw:handler-set! button 'drag drag))
    (loop (add1 i))))

(let loop ()
  (when (not (sdl2:quit-requested?))
    (let loop ((event (sdl2:make-event)))
      (when (sdl2:poll-event! event)
        (when (and (eqv? (sdl2:event-type event) 'window)
                   (eqv? (sdl2:window-event-event event) 'size-changed))
          (set! (kw:rect-w scrollbox-geometry) (sdl2:window-event-data1 event))
          (set! (kw:rect-h scrollbox-geometry) (sdl2:window-event-data2 event))
          (squash-rect! scrollbox-geometry)
          (set! (kw:widget-geometry scrollbox) scrollbox-geometry))
        (loop event)))
    (sdl2:render-clear! renderer)
    (kw:process-events! gui)
    (kw:paint! gui)
    (sdl2:render-present! renderer)
    (sdl2:delay! 1)
    (loop)))

(kw:quit! gui)
