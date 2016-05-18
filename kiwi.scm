(module kiwi
  (create-sdl2-render-driver
   load-surface release-surface!
   load-font release-font!
   init! quit!
   font-set!
   rect rect-free!
   frame
   label label-icon-set!
   paint!)

(import chicken scheme foreign)

;;; headers

(foreign-declare "#include \"KW_gui.h\"
#include \"KW_frame.h\"
#include \"KW_label.h\"
#include \"KW_renderdriver_sdl2.h\"")

;;; foreign functions

(define KW_CreateSDL2RenderDriver (foreign-lambda (c-pointer (struct "KW_RenderDriver")) "KW_CreateSDL2RenderDriver" (c-pointer (struct "SDL_Renderer")) (c-pointer (struct "SDL_Window"))))
(define KW_LoadSurface (foreign-lambda (c-pointer (struct "KW_Surface")) "KW_LoadSurface" (c-pointer (struct "KW_RenderDriver")) c-string))
(define KW_ReleaseSurface (foreign-lambda void "KW_ReleaseSurface" (c-pointer (struct "KW_RenderDriver")) (c-pointer (struct "KW_Surface"))))
(define KW_LoadFont (foreign-lambda (c-pointer (struct "KW_Font")) "KW_LoadFont" (c-pointer (struct "KW_RenderDriver")) c-string unsigned-int))
(define KW_ReleaseFont (foreign-lambda void "KW_ReleaseFont" (c-pointer (struct "KW_RenderDriver")) (c-pointer (struct "KW_Font"))))
(define KW_Init (foreign-lambda (c-pointer (struct "KW_GUI")) "KW_Init" (c-pointer (struct "KW_RenderDriver")) (c-pointer (struct "KW_Surface"))))
(define KW_Quit (foreign-lambda void "KW_Quit" (c-pointer (struct "KW_GUI"))))
(define KW_SetFont (foreign-lambda void "KW_SetFont" (c-pointer (struct "KW_GUI")) (c-pointer (struct "KW_Font"))))
(define CreateRect (foreign-lambda* (c-pointer (struct "KW_Rect")) ((unsigned-int x) (unsigned-int y) (unsigned-int w) (unsigned-int h)) "KW_Rect *r = calloc(sizeof(*r), 1); r->x = x; r->y = y; r->w = w; r->h = h; C_return(r);"))
(define FreeRect (foreign-lambda* void (((c-pointer (struct "KW_Rect")) r)) "free(r);"))
(define KW_CreateFrame (foreign-lambda (c-pointer (struct "KW_Widget")) "KW_CreateFrame" (c-pointer (struct "KW_GUI")) (c-pointer (struct "KW_Widget")) (c-pointer (struct "KW_Rect"))))
(define KW_CreateLabel (foreign-lambda (c-pointer (struct "KW_Widget")) "KW_CreateLabel" (c-pointer (struct "KW_GUI")) (c-pointer (struct "KW_Widget")) c-string (c-pointer (struct "KW_Rect"))))
(define KW_SetLabelIcon (foreign-lambda void "KW_SetLabelIcon" (c-pointer (struct "KW_Widget")) (c-pointer (struct "KW_Rect"))))
(define KW_Paint (foreign-lambda void "KW_Paint" (c-pointer (struct "KW_GUI"))))

;;; auxiliary records
(define-record driver pointer)
(define-record surface pointer)
(define-record font pointer)
(define-record gui pointer)
(define-record rect pointer)
(define-record widget pointer)

;;; API

(define (create-sdl2-render-driver renderer window)
  ;; TODO: this can fail on insufficient memory
  (let ((driver* (KW_CreateSDL2RenderDriver renderer window)))
    (make-driver driver*)))

(define (load-surface driver filename)
  ;; TODO: this can fail if file not found
  (let ((surface* (KW_LoadSurface (driver-pointer driver) filename)))
    (make-surface surface*)))

(define (release-surface! driver surface)
  ;; TODO: set pointer to #f, deal with #f case
  (KW_ReleaseSurface (driver-pointer driver) (surface-pointer surface)))

(define (load-font driver fontname size)
  ;; TODO: this can fail if font not found
  (let ((font* (KW_LoadFont (driver-pointer driver) fontname size)))
    (make-font font*)))

(define (release-font! driver font)
  ;; TODO: set pointer to #f, deal with #f case
  (KW_ReleaseFont (driver-pointer driver) (font-pointer font)))

(define (init! driver tileset)
  ;; TODO: this can fail on insufficient memory
  (let ((gui* (KW_Init (driver-pointer driver) (surface-pointer tileset))))
    (make-gui gui*)))

(define (quit! gui)
  ;; TODO: set pointer to #f, deal with #f case
  (KW_Quit (gui-pointer gui)))

(define (font-set! gui font)
  ;; TODO: this can fail if font is null
  (KW_SetFont (gui-pointer gui) (font-pointer font)))

(define (rect x y width height)
  ;; TODO: this can fail on insufficient memory
  (make-rect (CreateRect x y width height)))

(define (rect-free! rect)
  ;; TODO: set pointer to #f, deal with #f case
  (FreeRect (rect-pointer rect)))

;; NOTE: freeing widgets is *not* necessary
(define (frame gui parent geometry)
  ;; TODO: deal with potential null pointers, evaluate
  ;; widget/specialized widget problem
  ;; TODO: can widget creation ever fail?
  (make-widget (KW_CreateFrame (gui-pointer gui) (and parent (widget-pointer parent)) (rect-pointer geometry))))

(define (label gui parent caption geometry)
  ;; TODO: deal with potential null pointers, evaluate
  ;; widget/specialized widget problem
  ;; TODO: can widget creation ever fail?
  (make-widget (KW_CreateLabel (gui-pointer gui) (and parent (widget-pointer parent)) caption (rect-pointer geometry))))

(define (label-icon-set! label clip)
  (KW_SetLabelIcon (widget-pointer label) (rect-pointer clip)))

(define (paint! gui)
  (KW_Paint (gui-pointer gui)))

)
