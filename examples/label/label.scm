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

(define bg (sdl2:make-color 100 100 100))
(sdl2:render-draw-color-set! renderer bg)

(define driver
  (kw:create-sdl2-render-driver (%renderer-pointer renderer)
                                (%window-pointer window)))

(define tileset
  (kw:load-surface driver "tileset.png"))

(define gui
  (kw:init! driver tileset))

(define font
  (kw:load-font driver "Fontin-Regular.ttf" 12))

(kw:font-set! gui font)

(define geometry
  (kw:rect 0 0 width height))

(define frame
  (kw:frame gui #f geometry))

(define label
  (kw:label gui frame "Label with an icon :)" geometry))

(define icon-rect
  (kw:rect 0 48 24 24))

(kw:label-icon-set! label icon-rect)

(let loop ()
  (when (not (sdl2:quit-requested?))
    (sdl2:render-clear! renderer)
    (kw:paint! gui)
    (sdl2:delay! 1)
    (sdl2:render-present! renderer)
    (loop)))

(kw:quit! gui)
(kw:release-surface! driver tileset)
(kw:release-font! driver font)
(kw:release-render-driver! driver)
(kw:rect-free! geometry)
(kw:rect-free! icon-rect)
