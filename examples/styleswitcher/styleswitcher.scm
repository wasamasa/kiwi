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

(define driver (kw:create-sdl2-render-driver (unwrap-renderer renderer)
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
(kw:font-set! gui fontin)

(define (switch-to font tileset bg)
  (kw:font-set! gui font)
  (sdl2:render-draw-color-set! renderer bg)
  (kw:tileset-surface-set! gui tileset))

(define frame (kw:frame gui #f (kw:rect 10 10 (- width 20) (- height 20))))

(define buttons-frame (kw:frame gui frame (kw:rect 10 (/ width 2) 280 48)))

(for-each
 (lambda (style)
   (let* ((x (alist-ref 'x style))
          (bg (alist-ref 'bg style))
          (tileset (alist-ref 'tileset style))
          (font (alist-ref 'font style))
          (button (kw:button gui buttons-frame "" (kw:rect x 8 32 32))))
     (kw:widget-tileset-surface-set! button tileset)
     (kw:handler-set! button 'mouse-down
                      (lambda (_widget _button)
                        (switch-to font tileset bg)))))
 (map cdr styles))

(define editbox-frame (kw:frame gui frame (kw:rect 10 10 280 100)))

(define editbox (kw:editbox gui editbox-frame "βέβαιος (sure)" (kw:rect 120 20 150 35)))
(kw:editbox-font-set! editbox dejavu)

(define editbox-label (kw:label gui editbox-frame "Can you do UTF-8?" (kw:rect 10 20 110 35)))

(kw:label-alignment-set! editbox-label 'right 0 'middle 0)

(define quit? #f)

(define (kthxbai-clicked widget _button)
  (set! quit? #t))

(define kthxbai-button
  (kw:button gui editbox-frame "kthxbai" (kw:rect 120 60 150 25)))
(kw:handler-set! kthxbai-button 'mouse-down kthxbai-clicked)

(let loop ()
  (when (and (not (sdl2:quit-requested?)) (not quit?))
    (sdl2:render-clear! renderer)
    (kw:process-events! gui)
    (kw:paint! gui)
    (sdl2:render-present! renderer)
    (sdl2:delay! 1)
    (loop)))

(kw:quit! gui)
