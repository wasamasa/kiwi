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

(define driver (kw:create-sdl2-driver (unwrap-renderer renderer)
                                      (unwrap-window window)))

(define tileset (kw:load-surface driver "tileset.png"))
(define gui (kw:init! driver tileset))

(define font (kw:load-font driver "DejaVuSans.ttf" 12))
(kw:gui-font-set! gui font)

(define quit? #f)

(define (ok-clicked _widget _button)
  (set! quit? #t))

(kw:widgets gui
 `(frame (@ (x 10) (y 10) (w ,(- width 20)) (h ,(- height 20))
            (id frame))
   (label (@ (x 0) (y 10) (w 300) (h 30)
             (text "Editbox example")))
   (label (@ (x 0) (y 100) (w 60) (h 30)
             (text "Label")
             (id label)))
   (editbox (@ (x 0) (y 100) (w 100) (h 30)
               (text "Edit me!")
               (id editbox)))
   (button (@ (x 250) (y 170) (w 40) (h 40)
              (text "OK")
              (mouse-down ,ok-clicked)))))

(kw:widget-fill-parent-horizontally! (kw:widget-by-id 'frame)
                                     (list (kw:widget-by-id 'label)
                                           (kw:widget-by-id 'editbox))
                                     '(1 4) 10 'middle)

(let loop ()
  (when (and (not (sdl2:quit-requested?)) (not quit?))
    (sdl2:render-clear! renderer)
    (kw:process-events! gui)
    (kw:paint! gui)
    (sdl2:render-present! renderer)
    (sdl2:delay! 1)
    (loop)))

(kw:quit! gui)
