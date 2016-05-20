(module kiwi
  (create-sdl2-render-driver release-render-driver!
   load-surface release-surface!
   load-font release-font!
   init! process-events! paint! quit!
   font-set!
   rect release-rect!
   frame
   label label-icon-set! label-alignment-set!
   button
   editbox editbox-font-set!)

(import chicken scheme foreign)
(use clojurian-syntax)

;;; headers

#>
#include "KW_gui.h"
#include "KW_frame.h"
#include "KW_label.h"
#include "KW_button.h"
#include "KW_editbox.h"
#include "KW_renderdriver_sdl2.h"
<#

;;; foreign values

;; enum KW_LabelHorizontalAlignment
(define KW_LABEL_ALIGN_LEFT (foreign-value "KW_LABEL_ALIGN_LEFT" int))
(define KW_LABEL_ALIGN_CENTER (foreign-value "KW_LABEL_ALIGN_CENTER" int))
(define KW_LABEL_ALIGN_RIGHT (foreign-value "KW_LABEL_ALIGN_RIGHT" int))

;; enum KW_LabelVerticalAlignment
(define KW_LABEL_ALIGN_TOP (foreign-value "KW_LABEL_ALIGN_TOP" int))
(define KW_LABEL_ALIGN_MIDDLE (foreign-value "KW_LABEL_ALIGN_MIDDLE" int))
(define KW_LABEL_ALIGN_BOTTOM (foreign-value "KW_LABEL_ALIGN_BOTTOM" int))

;;; foreign functions

(define KW_CreateSDL2RenderDriver (foreign-lambda (c-pointer (struct "KW_RenderDriver")) "KW_CreateSDL2RenderDriver" (c-pointer (struct "SDL_Renderer")) (c-pointer (struct "SDL_Window"))))
(define KW_ReleaseRenderDriver (foreign-lambda void "KW_ReleaseRenderDriver" (c-pointer (struct "KW_RenderDriver"))))
(define KW_LoadSurface (foreign-lambda (c-pointer (struct "KW_Surface")) "KW_LoadSurface" (c-pointer (struct "KW_RenderDriver")) c-string))
(define KW_ReleaseSurface (foreign-lambda void "KW_ReleaseSurface" (c-pointer (struct "KW_RenderDriver")) (c-pointer (struct "KW_Surface"))))
(define KW_LoadFont (foreign-lambda (c-pointer (struct "KW_Font")) "KW_LoadFont" (c-pointer (struct "KW_RenderDriver")) c-string unsigned-int))
(define KW_ReleaseFont (foreign-lambda void "KW_ReleaseFont" (c-pointer (struct "KW_RenderDriver")) (c-pointer (struct "KW_Font"))))
(define KW_Init (foreign-lambda (c-pointer (struct "KW_GUI")) "KW_Init" (c-pointer (struct "KW_RenderDriver")) (c-pointer (struct "KW_Surface"))))
(define KW_ProcessEvents (foreign-safe-lambda void "KW_ProcessEvents" (c-pointer (struct "KW_GUI"))))
(define KW_Paint (foreign-lambda void "KW_Paint" (c-pointer (struct "KW_GUI"))))
(define KW_Quit (foreign-lambda void "KW_Quit" (c-pointer (struct "KW_GUI"))))
(define KW_SetFont (foreign-lambda void "KW_SetFont" (c-pointer (struct "KW_GUI")) (c-pointer (struct "KW_Font"))))
(define CreateRect (foreign-lambda* (c-pointer (struct "KW_Rect")) ((int x) (int y) (int w) (int h)) "KW_Rect *r = calloc(sizeof(KW_Rect), 1); r->x = x; r->y = y; r->w = w; r->h = h; C_return(r);"))
(define FreeRect (foreign-lambda* void (((c-pointer (struct "KW_Rect")) r)) "free(r);"))
(define KW_CreateFrame (foreign-lambda (c-pointer (struct "KW_Widget")) "KW_CreateFrame" (c-pointer (struct "KW_GUI")) (c-pointer (struct "KW_Widget")) (c-pointer (struct "KW_Rect"))))
(define KW_CreateLabel (foreign-lambda (c-pointer (struct "KW_Widget")) "KW_CreateLabel" (c-pointer (struct "KW_GUI")) (c-pointer (struct "KW_Widget")) c-string (c-pointer (struct "KW_Rect"))))
(define KW_SetLabelIcon (foreign-lambda void "KW_SetLabelIcon" (c-pointer (struct "KW_Widget")) (c-pointer (struct "KW_Rect"))))
(define KW_SetLabelAlignment (foreign-lambda void "KW_SetLabelAlignment" (c-pointer (struct "KW_Widget")) (enum "KW_LabelHorizontalAlignment") int (enum "KW_LabelVerticalAlignment") int))
(define KW_CreateButton (foreign-lambda (c-pointer (struct "KW_Widget")) "KW_CreateButton" (c-pointer (struct "KW_GUI")) (c-pointer (struct "KW_Widget")) c-string (c-pointer (struct "KW_Rect"))))
(define KW_CreateEditbox (foreign-lambda (c-pointer (struct "KW_Widget")) "KW_CreateEditbox" (c-pointer (struct "KW_GUI")) (c-pointer (struct "KW_Widget")) c-string (c-pointer (struct "KW_Rect"))))
(define KW_SetEditboxFont (foreign-lambda void "KW_SetEditboxFont" (c-pointer (struct "KW_Widget")) (c-pointer (struct "KW_Font"))))

;;; auxiliary records

(define-record driver pointer)
(define-record surface pointer)
(define-record font pointer)
(define-record gui pointer)
(define-record rect pointer)
(define-record widget pointer)

;;; errors

(define (define-error location message . condition)
  (let ((base (make-property-condition 'exn 'location location 'message message))
        (extra (apply make-property-condition condition)))
    (make-composite-condition base extra)))

(define (oom-error location)
  (define-error location "Failed to allocate memory" 'runtime))

(define (sdl2-error message location)
  (define-error location message 'sdl2))

(define (usage-error message location)
  (define-error location message 'usage))

;;; API

(define (create-sdl2-render-driver renderer window)
  (if-let (driver* (KW_CreateSDL2RenderDriver renderer window))
    (set-finalizer! (make-driver driver*) release-render-driver!)
    (abort (oom-error 'create-sdl2-render-driver))))

(define (release-render-driver! driver)
  (and-let* ((driver* (driver-pointer driver)))
    (KW_ReleaseRenderDriver driver*)
    (driver-pointer-set! driver #f)))

(define (load-surface driver filename)
  (and-let* ((driver* (driver-pointer driver)))
    (if-let (surface* (KW_LoadSurface driver* filename))
      (set-finalizer! (make-surface surface*)
                      (cut release-surface! driver <>))
      (abort (sdl2-error "Could not load surface" 'load-surface)))))

(define (release-surface! driver surface)
  (and-let* ((driver* (driver-pointer driver))
             (surface* (surface-pointer surface)))
    (KW_ReleaseSurface driver* surface*)
    (surface-pointer-set! surface #f)))

(define (load-font driver fontname size)
  (and-let* ((driver* (driver-pointer driver)))
    (if-let (font* (KW_LoadFont driver* fontname size))
      (set-finalizer! (make-font font*)
                      (cut release-font! driver <>))
      (abort (sdl2-error "Could not load font" 'load-font)))))

(define (release-font! driver font)
  (and-let* ((driver* (driver-pointer driver))
             (font* (font-pointer font)))
    (KW_ReleaseFont driver* font*)
    (font-pointer-set! font #f)))

(define (init! driver tileset)
  (and-let* ((driver* (driver-pointer driver))
             (tileset* (surface-pointer tileset)))
    (if-let (gui* (KW_Init driver* tileset*))
      ;; NOTE: an exit handler would make more sense
      (make-gui gui*)
      (abort (oom-error 'init!)))))

(define (process-events! gui)
  (and-let* ((gui* (gui-pointer gui)))
    (KW_ProcessEvents gui*)))

(define (paint! gui)
  (and-let* ((gui* (gui-pointer gui)))
    (KW_Paint gui*)))

(define (quit! gui)
  (and-let* ((gui* (gui-pointer gui)))
    (KW_Quit gui*)
    (gui-pointer-set! gui #f)))

(define (font-set! gui font)
  (and-let* ((gui* (gui-pointer gui))
             (font* (font-pointer font)))
    (KW_SetFont gui* font*)))

(define (rect x y width height)
  (if-let (rect* (CreateRect x y width height))
    (set-finalizer! (make-rect rect*) release-rect!)
    (abort (oom-error 'rect))))

(define (release-rect! rect)
  (and-let* ((rect* (rect-pointer rect)))
    (FreeRect rect*)
    (rect-pointer-set! rect #f)))

(define (frame gui parent geometry)
  (and-let* ((gui* (gui-pointer gui))
             (geometry* (rect-pointer geometry)))
    (let ((parent* (and parent (widget-pointer parent))))
      (if-let (widget* (KW_CreateFrame gui* parent* geometry*))
        ;; NOTE: freeing widgets is *not* necessary
        (make-widget widget*)
        (abort (oom-error 'frame))))))

(define (label gui parent text geometry)
  (and-let* ((gui* (gui-pointer gui))
             (geometry* (rect-pointer geometry)))
    (let ((parent* (and parent (widget-pointer parent))))
      (if-let (widget* (KW_CreateLabel gui* parent* text geometry*))
        (make-widget widget*)
        (abort (oom-error 'label))))))

(define (label-icon-set! label clip)
  (and-let* ((label* (widget-pointer label))
             (clip* (rect-pointer clip)))
    (KW_SetLabelIcon label* clip*)))

(define (label-alignment-set! label halign hoffset valign voffset)
  (and-let* ((label* (widget-pointer label))
             (halign (case halign
                       ((left) KW_LABEL_ALIGN_LEFT)
                       ((center) KW_LABEL_ALIGN_CENTER)
                       ((right) KW_LABEL_ALIGN_RIGHT)))
             (valign (case valign
                       ((top) KW_LABEL_ALIGN_TOP)
                       ((middle) KW_LABEL_ALIGN_MIDDLE)
                       ((bottom) KW_LABEL_ALIGN_BOTTOM))))
    (when (not halign)
      (abort (usage-error "Invalid horizontal align value"
                          'label-alignment-set!)))
    (when (not valign)
      (abort (usage-error "Invalid vertical align value"
                          'label-alignment-set!)))
    (KW_SetLabelAlignment label* halign hoffset valign voffset)))

(define (button gui parent text geometry)
  (and-let* ((gui* (gui-pointer gui))
             (geometry* (rect-pointer geometry)))
    (let ((parent* (and parent (widget-pointer parent))))
      (if-let (widget* (KW_CreateButton gui* parent* text geometry*))
        (make-widget widget*)
        (abort (oom-error 'button))))))

(define (editbox gui parent text geometry)
  (and-let* ((gui* (gui-pointer gui))
             (geometry* (rect-pointer geometry)))
    (let ((parent* (and parent (widget-pointer parent))))
      (if-let (widget* (KW_CreateEditbox gui* parent* text geometry*))
        (make-widget widget*)
        (abort (oom-error 'editbox))))))

(define (editbox-font-set! editbox font)
  (and-let* ((editbox* (widget-pointer editbox))
             (font* (font-pointer font)))
    (KW_SetEditboxFont editbox* font*)))

)
