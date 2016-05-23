(module kiwi
  (create-sdl2-render-driver release-render-driver!
   load-surface release-surface!
   load-font release-font!
   init! process-events! paint! quit!
   font-set!
   rect release-rect! rect-center-in-parent! rect-fill-parent-horizontally! rect-x rect-y rect-w rect-h rect-x-set! rect-y-set! rect-w-set! rect-h-set!
   frame
   label label-icon-set! label-alignment-set!
   button
   editbox editbox-font-set!
   widget-geometry widget-geometry-set!
   handler-set!)

(import chicken scheme foreign)
(use clojurian-syntax srfi-69 lolevel srfi-4)

;;; headers

#>
#include "KW_gui.h"
#include "KW_rect.h"
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

;; enum KW_RectHorizontalAlignment
(define KW_RECT_ALIGN_HORIZONTALLY_NONE (foreign-value "KW_RECT_ALIGN_HORIONTALLY_NONE" int)) ; ugh
(define KW_RECT_ALIGN_LEFT (foreign-value "KW_RECT_ALIGN_LEFT" int))
(define KW_RECT_ALIGN_CENTER (foreign-value "KW_RECT_ALIGN_CENTER" int))
(define KW_RECT_ALIGN_RIGHT (foreign-value "KW_RECT_ALIGN_RIGHT" int))

;; enum KW_RectVerticalAlignment
(define KW_RECT_ALIGN_VERTICALLY_NONE (foreign-value "KW_RECT_ALIGN_VERTICALLY_NONE" int))
(define KW_RECT_ALIGN_TOP (foreign-value "KW_RECT_ALIGN_TOP" int))
(define KW_RECT_ALIGN_MIDDLE (foreign-value "KW_RECT_ALIGN_MIDDLE" int))
(define KW_RECT_ALIGN_BOTTOM (foreign-value "KW_RECT_ALIGN_BOTTOM" int))

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
(define KW_CreateFrame (foreign-lambda (c-pointer (struct "KW_Widget")) "KW_CreateFrame" (c-pointer (struct "KW_GUI")) (c-pointer (struct "KW_Widget")) (c-pointer (struct "KW_Rect"))))
(define KW_CreateLabel (foreign-lambda (c-pointer (struct "KW_Widget")) "KW_CreateLabel" (c-pointer (struct "KW_GUI")) (c-pointer (struct "KW_Widget")) c-string (c-pointer (struct "KW_Rect"))))
(define KW_SetLabelIcon (foreign-lambda void "KW_SetLabelIcon" (c-pointer (struct "KW_Widget")) (c-pointer (struct "KW_Rect"))))
(define KW_SetLabelAlignment (foreign-lambda void "KW_SetLabelAlignment" (c-pointer (struct "KW_Widget")) (enum "KW_LabelHorizontalAlignment") int (enum "KW_LabelVerticalAlignment") int))
(define KW_CreateButton (foreign-lambda (c-pointer (struct "KW_Widget")) "KW_CreateButton" (c-pointer (struct "KW_GUI")) (c-pointer (struct "KW_Widget")) c-string (c-pointer (struct "KW_Rect"))))
(define KW_CreateEditbox (foreign-lambda (c-pointer (struct "KW_Widget")) "KW_CreateEditbox" (c-pointer (struct "KW_GUI")) (c-pointer (struct "KW_Widget")) c-string (c-pointer (struct "KW_Rect"))))
(define KW_SetEditboxFont (foreign-lambda void "KW_SetEditboxFont" (c-pointer (struct "KW_Widget")) (c-pointer (struct "KW_Font"))))
(define KW_GetWidgetGeometry (foreign-lambda void "KW_GetWidgetGeometry" (c-pointer (struct "KW_Widget")) (c-pointer (struct "KW_Rect"))))
(define KW_GetWidgetAbsoluteGeometry (foreign-lambda void "KW_GetWidgetAbsoluteGeometry" (c-pointer (struct "KW_Widget")) (c-pointer (struct "KW_Rect"))))
(define KW_SetWidgetGeometry (foreign-lambda void "KW_SetWidgetGeometry" (c-pointer (struct "KW_Widget")) (c-pointer (struct "KW_Rect"))))
(define KW_RectCenterInParent (foreign-lambda void "KW_RectCenterInParent" (c-pointer (struct "KW_Rect")) (c-pointer (struct "KW_Rect"))))
(define KW_AddWidgetMouseOverHandler (foreign-lambda void "KW_AddWidgetMouseOverHandler" (c-pointer (struct "KW_Widget")) (function void ((c-pointer (struct "KW_Widget"))))))
(define KW_AddWidgetMouseLeaveHandler (foreign-lambda void "KW_AddWidgetMouseLeaveHandler" (c-pointer (struct "KW_Widget")) (function void ((c-pointer (struct "KW_Widget"))))))
(define KW_AddWidgetMouseDownHandler (foreign-lambda void "KW_AddWidgetMouseDownHandler" (c-pointer (struct "KW_Widget")) (function void ((c-pointer (struct "KW_Widget")) int))))
(define KW_AddWidgetMouseUpHandler (foreign-lambda void "KW_AddWidgetMouseUpHandler" (c-pointer (struct "KW_Widget")) (function void ((c-pointer (struct "KW_Widget")) int))))
(define KW_AddWidgetDragStartHandler (foreign-lambda void "KW_AddWidgetDragStartHandler" (c-pointer (struct "KW_Widget")) (function void ((c-pointer (struct "KW_Widget")) int int))))
(define KW_AddWidgetDragStopHandler (foreign-lambda void "KW_AddWidgetDragStopHandler" (c-pointer (struct "KW_Widget")) (function void ((c-pointer (struct "KW_Widget")) int int))))
(define KW_AddWidgetDragHandler (foreign-lambda void "KW_AddWidgetDragHandler" (c-pointer (struct "KW_Widget")) (function void ((c-pointer (struct "KW_Widget")) int int int int))))

;;; foreign rect helpers

(define KW_CreateRect
  (foreign-lambda* (c-pointer (struct "KW_Rect")) ((int x) (int y) (int w) (int h))
    "KW_Rect *r = calloc(sizeof(KW_Rect), 1);"
    "r->x = x; r->y = y; r->w = w; r->h = h;"
    "C_return(r);"))

(define KW_Rect->x (foreign-lambda* int (((c-pointer (struct "KW_Rect")) r)) "C_return(r->x);"))
(define KW_Rect->y (foreign-lambda* int (((c-pointer (struct "KW_Rect")) r)) "C_return(r->y);"))
(define KW_Rect->w (foreign-lambda* int (((c-pointer (struct "KW_Rect")) r)) "C_return(r->w);"))
(define KW_Rect->h (foreign-lambda* int (((c-pointer (struct "KW_Rect")) r)) "C_return(r->h);"))

(define KW_Rect->x-set! (foreign-lambda* void (((c-pointer (struct "KW_Rect")) r) (int x)) "r->x = x;"))
(define KW_Rect->y-set! (foreign-lambda* void (((c-pointer (struct "KW_Rect")) r) (int y)) "r->y = y;"))
(define KW_Rect->w-set! (foreign-lambda* void (((c-pointer (struct "KW_Rect")) r) (int w)) "r->w = w;"))
(define KW_Rect->h-set! (foreign-lambda* void (((c-pointer (struct "KW_Rect")) r) (int h)) "r->h = h;"))

(define KW_RectFillParentHorizontally
  (foreign-lambda* void (((c-pointer (struct "KW_Rect")) outer) (pointer-vector rects_vector) (int rects_vector_length) (u32vector weights_vector) (int weights_vector_length) (unsigned-int count) (int padding) ((enum "KW_RectVerticalAlignment") align))
    "KW_Rect *rects[rects_vector_length];"
    "memcpy(rects, rects_vector, rects_vector_length * sizeof(KW_Rect *));"
    "unsigned int weights[weights_vector_length];"
    "memcpy(weights, weights_vector, weights_vector_length * sizeof(unsigned int));"
    "KW_RectFillParentHorizontally(outer, rects, weights, count, padding, align);"))

;;; auxiliary records

(define-record driver pointer)
(define-record surface pointer)
(define-record font pointer)
(define-record gui pointer)
(define-record rect pointer)
(define-record widget handlers pointer)

;;; generic handlers

(define (dispatch-event! widget* type . args)
  (let* ((widget (hash-table-ref widget-table widget*))
         (handlers (widget-handlers widget))
         (handler (hash-table-ref handlers type)))
    (apply handler widget args)))

(define-external (kiwi_MouseOverHandler ((c-pointer (struct "KW_Widget")) widget*)) void
  (dispatch-event! widget* 'mouse-over))

(define-external (kiwi_MouseLeaveHandler ((c-pointer (struct "KW_Widget")) widget*)) void
  (dispatch-event! widget* 'mouse-leave))

(define-external (kiwi_MouseDownHandler ((c-pointer (struct "KW_Widget")) widget*) (int button)) void
  (dispatch-event! widget* 'mouse-down button))

(define-external (kiwi_MouseUpHandler ((c-pointer (struct "KW_Widget")) widget*) (int button)) void
  (dispatch-event! widget* 'mouse-up button))

(define-external (kiwi_DragStartHandler ((c-pointer (struct "KW_Widget")) widget*) (int x) (int y)) void
  (dispatch-event! widget* 'drag-start x y))

(define-external (kiwi_DragStopHandler ((c-pointer (struct "KW_Widget")) widget*) (int x) (int y)) void
  (dispatch-event! widget* 'drag-stop x y))

(define-external (kiwi_DragHandler ((c-pointer (struct "KW_Widget")) widget*) (int x) (int y) (int relx) (int rely)) void
  (dispatch-event! widget* 'drag x y relx rely))

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

;;; GUI setup and teardown

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

;;; rects

(define (rect x y w h)
  (if-let (rect* (KW_CreateRect x y w h))
    (set-finalizer! (make-rect rect*) release-rect!)
    (abort (oom-error 'rect))))

(define (release-rect! rect)
  (and-let* ((rect* (rect-pointer rect)))
    (free rect*)
    (rect-pointer-set! rect #f)))

(define (rect-center-in-parent! outer inner)
  (and-let* ((inner* (rect-pointer inner))
             (outer* (rect-pointer outer)))
    (KW_RectCenterInParent inner* outer*)))

(define (rect-fill-parent-horizontally! outer rects weights count padding valign)
  (and-let* ((outer* (rect-pointer outer)))
    (let* ((rect-pointers (map rect-pointer rects))
           (rects-vector (apply pointer-vector rect-pointers))
           (rects-vector-length (pointer-vector-length rects-vector))
           (weights-vector (list->u32vector weights))
           (weights-vector-length (u32vector-length weights-vector))
           (valign (case valign
                     ((none) KW_RECT_ALIGN_VERTICALLY_NONE)
                     ((top) KW_RECT_ALIGN_TOP)
                     ((middle) KW_RECT_ALIGN_MIDDLE)
                     ((bottom) KW_RECT_ALIGN_BOTTOM)
                     (else
                      (abort (usage-error "Invalid vertical alignment value"
                                          'rect-fill-parent-horizontally!))))))
      (KW_RectFillParentHorizontally outer* rects-vector rects-vector-length
                                     weights-vector weights-vector-length
                                     count padding valign))))

(define (rect-x rect)
  (and-let* ((rect* (rect-pointer rect)))
    (KW_Rect->x rect*)))

(define (rect-x-set! rect x)
  (and-let* ((rect* (rect-pointer rect)))
    (KW_Rect->x-set! rect* x)))

(define rect-x (getter-with-setter rect-x rect-x-set!))

(define (rect-y rect)
  (and-let* ((rect* (rect-pointer rect)))
    (KW_Rect->y rect*)))

(define (rect-y-set! rect y)
  (and-let* ((rect* (rect-pointer rect)))
    (KW_Rect->y-set! rect* y)))

(define rect-y (getter-with-setter rect-y rect-y-set!))

(define (rect-w rect)
  (and-let* ((rect* (rect-pointer rect)))
    (KW_Rect->w rect*)))

(define (rect-w-set! rect w)
  (and-let* ((rect* (rect-pointer rect)))
    (KW_Rect->w-set! rect* w)))

(define rect-w (getter-with-setter rect-w rect-w-set!))

(define (rect-h rect)
  (and-let* ((rect* (rect-pointer rect)))
    (KW_Rect->h rect*)))

(define (rect-h-set! rect h)
  (and-let* ((rect* (rect-pointer rect)))
    (KW_Rect->h-set! rect* h)))

(define rect-h (getter-with-setter rect-h rect-h-set!))

;;; widgets

(define widget-table (make-hash-table))

(define (define-widget type gui parent geometry proc)
  (and-let* ((gui* (gui-pointer gui))
             (geometry* (rect-pointer geometry)))
    (let ((parent* (and parent (widget-pointer parent))))
      (if-let (widget* (proc gui* parent* geometry*))
        (let* ((handlers (make-hash-table eqv? eqv?-hash))
               (widget (make-widget handlers widget*)))
          (hash-table-set! widget-table widget* widget)
          widget)
        (abort (oom-error type))))))

(define (frame gui parent geometry)
  (define-widget 'frame gui parent geometry KW_CreateFrame))

(define (label gui parent text geometry)
  (define-widget 'label gui parent geometry
    (cut KW_CreateLabel <> <> text <>)))

(define (label-icon-set! label clip)
  (and-let* ((label* (widget-pointer label))
             (clip* (rect-pointer clip)))
    (KW_SetLabelIcon label* clip*)))

(define (label-alignment-set! label halign hoffset valign voffset)
  (and-let* ((label* (widget-pointer label)))
    (let ((halign (case halign
                    ((left) KW_LABEL_ALIGN_LEFT)
                    ((center) KW_LABEL_ALIGN_CENTER)
                    ((right) KW_LABEL_ALIGN_RIGHT)
                    (else
                     (abort (usage-error "Invalid horizontal alignment value"
                                         'label-alignment-set!)))))
          (valign (case valign
                    ((top) KW_LABEL_ALIGN_TOP)
                    ((middle) KW_LABEL_ALIGN_MIDDLE)
                    ((bottom) KW_LABEL_ALIGN_BOTTOM)
                    (else
                     (abort (usage-error "Invalid vertical alignment value"
                                         'label-alignment-set!))))))
      (KW_SetLabelAlignment label* halign hoffset valign voffset))))

(define (button gui parent text geometry)
  (define-widget 'button gui parent geometry
    (cut KW_CreateButton <> <> text <>)))

(define (editbox gui parent text geometry)
  (define-widget 'editbox gui parent geometry
    (cut KW_CreateEditbox <> <> text <>)))

(define (editbox-font-set! editbox font)
  (and-let* ((editbox* (widget-pointer editbox))
             (font* (font-pointer font)))
    (KW_SetEditboxFont editbox* font*)))

(define (widget-geometry widget #!optional absolute?)
  (and-let* ((widget* (widget-pointer widget)))
    (let* ((geometry (rect 0 0 0 0))
           (geometry* (rect-pointer geometry)))
      (if absolute?
          (KW_GetWidgetAbsoluteGeometry widget* geometry*)
          (KW_GetWidgetGeometry widget* geometry*))
      geometry)))

(define (widget-geometry-set! widget geometry)
  (and-let* ((widget* (widget-pointer widget))
             (geometry* (rect-pointer geometry)))
    (KW_SetWidgetGeometry widget* geometry*)))

(define widget-geometry (getter-with-setter widget-geometry widget-geometry-set!))

(define (handler-set! widget type proc)
  (and-let* ((widget* (widget-pointer widget)))
    (let ((handlers (widget-handlers widget)))
      (case type
        ((mouse-over)
         (hash-table-set! handlers 'mouse-over proc)
         (KW_AddWidgetMouseOverHandler widget* (location kiwi_MouseOverHandler)))
        ((mouse-leave)
         (hash-table-set! handlers 'mouse-leave proc)
         (KW_AddWidgetMouseLeaveHandler widget* (location kiwi_MouseLeaveHandler)))
        ((mouse-down)
         (hash-table-set! handlers 'mouse-down proc)
         (KW_AddWidgetMouseDownHandler widget* (location kiwi_MouseDownHandler)))
        ((mouse-up)
         (hash-table-set! handlers 'mouse-up proc)
         (KW_AddWidgetMouseUpHandler widget* (location kiwi_MouseUpHandler)))
        ((drag-start)
         (hash-table-set! handlers 'drag-start proc)
         (KW_AddWidgetDragStartHandler widget* (location kiwi_DragStartHandler)))
        ((drag-stop)
         (hash-table-set! handlers 'drag-stop proc)
         (KW_AddWidgetDragStopHandler widget* (location kiwi_DragStopHandler)))
        ((drag)
         (hash-table-set! handlers 'drag proc)
         (KW_AddWidgetDragHandler widget* (location kiwi_DragHandler)))
        (else
         (abort (usage-error "Unsupported event handler type" 'handler-set!)))))))

)
