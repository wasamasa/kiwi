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

(define driver (kw:create-sdl2-driver (unwrap-renderer renderer)
                                      (unwrap-window window)))

(define normal-bg (sdl2:make-color 100 100 200))
(define normal-tileset (kw:load-surface driver "tileset.png"))

(define alloy-bg (sdl2:make-color 64 67 70))
(define alloy-tileset (kw:load-surface driver "tileset-alloy.png"))

(define flat-bg (sdl2:make-color 200 100 100))
(define flat-tileset (kw:load-surface driver "tileset-flat.png"))

(define futter-bg (sdl2:make-color 118 152 162))
(define futter-tileset (kw:load-surface driver "tileset-futterpedia.png"))

(define fontin (kw:load-font driver "Fontin-Regular.ttf" 12))
(define source-pro (kw:load-font driver "SourceSansPro-Semibold.ttf" 12))
(define dejavu (kw:load-font driver "DejaVuSans.ttf" 11))

(define styles
  `((normal
     (x . ,(+ 10 (* 72 0)))
     (bg . ,normal-bg)
     (tileset . ,normal-tileset)
     (font . ,fontin))
    (alloy
     (x . ,(+ 10 (* 72 1)))
     (bg . ,alloy-bg)
     (tileset . ,alloy-tileset)
     (font . ,source-pro))
    (futter
     (x . ,(+ 10 (* 72 2)))
     (bg . ,futter-bg)
     (tileset . , futter-tileset)
     (font . ,fontin))
    (flat
     (x . ,(+ 10 (* 72 3)))
     (bg . ,flat-bg)
     (tileset . ,flat-tileset)
     (font . ,source-pro))))

(sdl2:render-draw-color-set! renderer futter-bg)

(define gui (kw:init! driver futter-tileset))
(kw:gui-font-set! gui fontin)

(define (switch-to font tileset bg)
  (kw:gui-font-set! gui font)
  (sdl2:render-draw-color-set! renderer bg)
  (kw:gui-tileset-surface-set! gui tileset))

(define quit? #f)

(define (kthxbai-clicked widget _button)
  (set! quit? #t))

(kw:widgets gui
 `(frame (@ (x 10) (y 10) (w ,(- width 20)) (h ,(- height 20)))
    (frame (@ (x 10) (y ,(/ width 2)) (w 280) (h 48)
              (id buttons)))
    (frame (@ (x 10) (y 10) (w 280) (h 100))
      (label (@ (x 10) (y 20) (w 110) (h 35)
                (align (right 0 middle 0))
                (text "Can you do UTF-8?")))
      (editbox (@ (x 120) (y 20) (w 150) (h 35)
                  (text "βέβαιος (sure)")
                  (font ,dejavu)))
      (button (@ (x 120) (y 60) (w 150) (h 25)
                 (text "kthxbai")
                 (mouse-down ,kthxbai-clicked))))))

(let ((buttons (kw:widget-by-id 'buttons)))
  (for-each
   (lambda (style)
     (let* ((x (alist-ref 'x style))
            (bg (alist-ref 'bg style))
            (tileset (alist-ref 'tileset style))
            (font (alist-ref 'font style)))
       (kw:widgets gui (kw:widget-by-id 'buttons)
        `(button (@ (x ,x) (y 8) (w 32) (h 32)
                    (tileset ,tileset)
                    (text "")
                    (mouse-down
                     ,(lambda (_widget _button)
                        (switch-to font tileset bg))))))))
   (map cdr styles)))

(let loop ()
  (when (and (not (sdl2:quit-requested?)) (not quit?))
    (sdl2:render-clear! renderer)
    (kw:process-events! gui)
    (kw:paint! gui)
    (sdl2:render-present! renderer)
    (sdl2:delay! 1)
    (loop)))

(kw:quit! gui)
