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

(sdl2:render-draw-color-set! renderer (sdl2:make-color 200 150 100))

(define driver (kw:create-sdl2-driver (unwrap-renderer renderer)
                                      (unwrap-window window)))

(define tileset (kw:load-surface driver "tileset.png"))
(define gui (kw:init! driver tileset))

(define font (kw:load-font driver "DejaVuSans.ttf" 11))
(kw:font-set! gui font)

(define messagebox #f)

(define (greet _widget _button)
  (when (not messagebox)
    (kw:widgets gui
     `(frame (@ (x 0) (y 0) (w 192) (h 120)
                (id messagebox))
       (label (@ (x 0) (y 0) (w 192) (h 48)
                 (text "Hello World!")))
       (button (@ (x 120) (y 84) (w 48) (h 24)
                  (text "OK")
                  (mouse-up ,messagebox-ok-clicked)))))
    (set! messagebox (kw:widget-by-id 'messagebox))
    (kw:widget-center-in-parent! (kw:widget-by-id 'frame) messagebox)))

(define quit? #f)

(define (messagebox-ok-clicked widget _button)
  (kw:destroy-widget! messagebox #t)
  (set! messagebox #f))

(kw:widgets gui
 `(frame (@ (x 0) (y 0) (w ,width) (h ,height)
            (id frame))
   (button (@ (x 48) (y 144) (w 96) (h 48)
              (text "Click me!")
              (mouse-up ,greet)))
   (button (@ (x 192) (y 144) (w 96) (h 48)
              (text "Quit")
              (mouse-up ,(lambda (_widget _button) (set! quit? #t)))))))

(let loop ()
  (when (and (not (sdl2:quit-requested?)) (not quit?))
    (sdl2:render-clear! renderer)
    (kw:process-events! gui)
    (kw:paint! gui)
    (sdl2:render-present! renderer)
    (sdl2:delay! 1)
    (loop)))

(kw:quit! gui)
