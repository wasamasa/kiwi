(module kiwi
  (create-sdl2-render-driver release-render-driver!
   load-surface release-surface!
   load-font release-font!
   init! process-events! paint! quit!
   tileset-surface-set!
   font-set!
   rect rect-x rect-y rect-w rect-h rect-x-set! rect-y-set! rect-w-set! rect-h-set!
   rect-center-in-parent! rect-center-in-parent-horizontally! rect-center-in-parent-vertically! rect-fill-parent-horizontally!
   color color-r color-g color-b color-a color-r-set! color-g-set! color-b-set! color-a-set!
   widget-by-id widgets-by-type
   widget-tileset-surface-set!
   hide-widget! show-widget! widget-hidden?
   frame
   scrollbox
   label label-icon-set! label-alignment-set! label-color-set!
   button
   editbox editbox-font-set!
   widget-geometry widget-geometry-set!
   widget-center-in-parent! widget-center-in-parent-horizontally! widget-center-in-parent-vertically! widget-fill-parent-horizontally!
   handler-set!
   widgets)

(import chicken scheme foreign)
(use clojurian-syntax srfi-69 lolevel srfi-4 srfi-1 matchable data-structures)

;;; headers

#>
#include "KW_gui.h"
#include "KW_rect.h"
#include "KW_frame.h"
#include "KW_scrollbox.h"
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
(define KW_SetTilesetSurface (foreign-lambda void "KW_SetTilesetSurface" (c-pointer (struct "KW_GUI")) (c-pointer (struct "KW_Surface"))))
(define KW_SetWidgetTilesetSurface (foreign-lambda void "KW_SetWidgetTilesetSurface" (c-pointer (struct "KW_Widget")) (c-pointer (struct "KW_Surface"))))
(define KW_HideWidget (foreign-lambda void "KW_HideWidget" (c-pointer (struct "KW_Widget"))))
(define KW_ShowWidget (foreign-lambda void "KW_ShowWidget" (c-pointer (struct "KW_Widget"))))
(define KW_IsWidgetHidden (foreign-lambda bool "KW_IsWidgetHidden" (c-pointer (struct "KW_Widget"))))

(define KW_CreateFrame (foreign-lambda* (c-pointer (struct "KW_Widget")) (((c-pointer (struct "KW_GUI")) gui) ((c-pointer (struct "KW_Widget")) parent) (int x) (int y) (int w) (int h)) "KW_Rect r = { x, y, w, h }; C_return(KW_CreateFrame(gui, parent, &r));"))

(define KW_CreateScrollbox (foreign-lambda* (c-pointer (struct "KW_Widget")) (((c-pointer (struct "KW_GUI")) gui) ((c-pointer (struct "KW_Widget")) parent) (int x) (int y) (int w) (int h))" KW_Rect r = { x, y, w, h }; C_return(KW_CreateScrollbox(gui, parent, &r));"))

(define KW_CreateLabel (foreign-lambda* (c-pointer (struct "KW_Widget")) (((c-pointer (struct "KW_GUI")) gui) ((c-pointer (struct "KW_Widget")) parent) (c-string text) (int x) (int y) (int w) (int h)) "KW_Rect r = { x, y, w, h }; C_return(KW_CreateLabel(gui, parent, text, &r));"))
(define KW_SetLabelIcon (foreign-lambda* void (((c-pointer (struct "KW_Widget")) label) (int x) (int y) (int w) (int h)) "KW_Rect r = { x, y, w, h }; KW_SetLabelIcon(label, &r);"))
(define KW_SetLabelAlignment (foreign-lambda void "KW_SetLabelAlignment" (c-pointer (struct "KW_Widget")) (enum "KW_LabelHorizontalAlignment") int (enum "KW_LabelVerticalAlignment") int))
(define KW_SetLabelColor (foreign-lambda* void (((c-pointer (struct "KW_Widget")) label) (unsigned-byte r) (unsigned-byte g) (unsigned-byte b) (unsigned-byte a)) "KW_Color c = { r, g, b, a }; KW_SetLabelColor(label, c);"))

(define KW_CreateButton (foreign-lambda* (c-pointer (struct "KW_Widget")) (((c-pointer (struct "KW_GUI")) gui) ((c-pointer (struct "KW_Widget")) parent) (c-string text) (int x) (int y) (int w) (int h)) "KW_Rect r = { x, y, w, h }; C_return(KW_CreateButton(gui, parent, text, &r));"))

(define KW_CreateEditbox (foreign-lambda* (c-pointer (struct "KW_Widget")) (((c-pointer (struct "KW_GUI")) gui) ((c-pointer (struct "KW_Widget")) parent) (c-string text) (int x) (int y) (int w) (int h)) "KW_Rect r = { x, y, w, h }; C_return(KW_CreateEditbox(gui, parent, text, &r));"))
(define KW_SetEditboxFont (foreign-lambda void "KW_SetEditboxFont" (c-pointer (struct "KW_Widget")) (c-pointer (struct "KW_Font"))))

(define KW_GetWidgetGeometry (foreign-lambda* void (((c-pointer (struct "KW_Widget")) widget) ((c-pointer int) x) ((c-pointer int) y) ((c-pointer int) w) ((c-pointer int) h)) "KW_Rect r; KW_GetWidgetGeometry(widget, &r); *x = r.x, *y = r.y, *w = r.w, *h = r.h;"))
(define KW_GetWidgetAbsoluteGeometry (foreign-lambda* void (((c-pointer (struct "KW_Widget")) widget) ((c-pointer int) x) ((c-pointer int) y) ((c-pointer int) w) ((c-pointer int) h)) "KW_Rect r; KW_GetWidgetAbsoluteGeometry(widget, &r); *x = r.x, *y = r.y, *w = r.w, *h = r.h;"))
(define KW_SetWidgetGeometry (foreign-lambda* void (((c-pointer (struct "KW_Widget")) widget) (int x) (int y) (int w) (int h)) "KW_Rect r = { x, y, w, h }; KW_SetWidgetGeometry(widget, &r);"))

(define KW_AddWidgetMouseOverHandler (foreign-lambda void "KW_AddWidgetMouseOverHandler" (c-pointer (struct "KW_Widget")) (function void ((c-pointer (struct "KW_Widget"))))))
(define KW_AddWidgetMouseLeaveHandler (foreign-lambda void "KW_AddWidgetMouseLeaveHandler" (c-pointer (struct "KW_Widget")) (function void ((c-pointer (struct "KW_Widget"))))))
(define KW_AddWidgetMouseDownHandler (foreign-lambda void "KW_AddWidgetMouseDownHandler" (c-pointer (struct "KW_Widget")) (function void ((c-pointer (struct "KW_Widget")) int))))
(define KW_AddWidgetMouseUpHandler (foreign-lambda void "KW_AddWidgetMouseUpHandler" (c-pointer (struct "KW_Widget")) (function void ((c-pointer (struct "KW_Widget")) int))))
(define KW_AddWidgetDragStartHandler (foreign-lambda void "KW_AddWidgetDragStartHandler" (c-pointer (struct "KW_Widget")) (function void ((c-pointer (struct "KW_Widget")) int int))))
(define KW_AddWidgetDragStopHandler (foreign-lambda void "KW_AddWidgetDragStopHandler" (c-pointer (struct "KW_Widget")) (function void ((c-pointer (struct "KW_Widget")) int int))))
(define KW_AddWidgetDragHandler (foreign-lambda void "KW_AddWidgetDragHandler" (c-pointer (struct "KW_Widget")) (function void ((c-pointer (struct "KW_Widget")) int int int int))))

;;; auxiliary records

(define-record driver pointer)
(define-record surface pointer)
(define-record font pointer)
(define-record gui pointer)
(define-record widget handlers type id pointer)

(define-record rect x y w h)
(define-record color r g b a)

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

(define (tileset-surface-set! gui tileset)
  (and-let* ((gui* (gui-pointer gui))
             (tileset* (surface-pointer tileset)))
    (KW_SetTilesetSurface gui* tileset*)))

;;; rects

(define rect make-rect)

(define rect-x (getter-with-setter rect-x rect-x-set!))
(define rect-y (getter-with-setter rect-y rect-y-set!))
(define rect-w (getter-with-setter rect-w rect-w-set!))
(define rect-h (getter-with-setter rect-h rect-h-set!))

(define (rect-center-in-parent-horizontally! parent inner)
  (set! (rect-x inner) (- (/ (rect-w parent) 2) (/ (rect-w inner) 2))))

(define (rect-center-in-parent-vertically! parent inner)
  (set! (rect-y inner) (- (/ (rect-h parent) 2) (/ (rect-h inner) 2))))

(define (rect-center-in-parent! parent inner)
  (rect-center-in-parent-horizontally! parent inner)
  (rect-center-in-parent-vertically! parent inner))

(define (rect-fill-parent-horizontally! parent rects weights count padding valign)
  (let* ((total (foldr + 0 weights))
         (base (/ (- (rect-w parent) (* padding (add1 (length weights)))) total)))
    (let loop ((current 0)
               (rects rects)
               (weights weights))
      (when (pair? weights)
        (let ((inner (car rects))
              (weight (car weights)))
          (set! (rect-x inner) (+ current padding))
          (set! (rect-w inner) (* base weight))
          (case valign
            ((top) (set! (rect-y inner) 0))
            ((middle) (rect-center-in-parent-vertically! parent inner))
            ((bottom) (set! (rect-y inner) (- (rect-h parent) (rect-h inner)))))
          (loop (+ (rect-x inner) (rect-w inner))
                (cdr rects) (cdr weights)))))))

;;; colors

(define color make-color)

(define color-r (getter-with-setter color-r color-r-set!))
(define color-g (getter-with-setter color-g color-g-set!))
(define color-b (getter-with-setter color-b color-b-set!))
(define color-a (getter-with-setter color-a color-a-set!))

;;; widgets

(define widget-table (make-hash-table))

(define (widgets-by-type type)
  (filter
   (lambda (widget) (eqv? (widget-type widget) type))
   (hash-table-values widget-table)))

(define (widget-by-id id)
  (find
   (lambda (widget) (eqv? (widget-id widget) id))
   (hash-table-values widget-table)))

(define (define-widget type gui parent geometry proc)
  (and-let* ((gui* (gui-pointer gui)))
    (let ((parent* (and parent (widget-pointer parent)))
          (x (rect-x geometry))
          (y (rect-y geometry))
          (w (rect-w geometry))
          (h (rect-h geometry)))
      (if-let (widget* (proc gui* parent* x y w h))
        (let* ((handlers (make-hash-table eqv? eqv?-hash))
               (widget (make-widget handlers type #f widget*)))
          (hash-table-set! widget-table widget* widget)
          widget)
        (abort (oom-error type))))))

(define (widget-tileset-surface-set! widget tileset)
  (and-let* ((widget* (widget-pointer widget))
             (tileset* (surface-pointer tileset)))
    (KW_SetWidgetTilesetSurface widget* tileset*)))

(define (hide-widget! widget)
  (and-let* ((widget* (widget-pointer widget)))
    (KW_HideWidget widget*)))

(define (show-widget! widget)
  (and-let* ((widget* (widget-pointer widget)))
    (KW_ShowWidget widget*)))

(define (widget-hidden? widget)
  (and-let* ((widget* (widget-pointer widget)))
    (KW_IsWidgetHidden widget*)))

(define (frame gui parent geometry)
  (define-widget 'frame gui parent geometry KW_CreateFrame))

(define (scrollbox gui parent geometry)
  (define-widget 'scrollbox gui parent geometry KW_CreateScrollbox))

(define (label gui parent text geometry)
  (define-widget 'label gui parent geometry
    (cut KW_CreateLabel <> <> text <> <> <> <>)))

(define (label-icon-set! label clip)
  (and-let* ((label* (widget-pointer label)))
    (let ((x (rect-x clip))
          (y (rect-y clip))
          (w (rect-w clip))
          (h (rect-h clip)))
      (KW_SetLabelIcon label* x y w h))))

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

(define (label-color-set! label color)
  (and-let* ((label* (widget-pointer label))
             (r (color-r color))
             (g (color-g color))
             (b (color-b color))
             (a (color-a color)))
    (KW_SetLabelColor label* r g b a)))

(define (button gui parent text geometry)
  (define-widget 'button gui parent geometry
    (cut KW_CreateButton <> <> text <> <> <> <>)))

(define (editbox gui parent text geometry)
  (define-widget 'editbox gui parent geometry
    (cut KW_CreateEditbox <> <> text <> <> <> <>)))

(define (editbox-font-set! editbox font)
  (and-let* ((editbox* (widget-pointer editbox))
             (font* (font-pointer font)))
    (KW_SetEditboxFont editbox* font*)))

(define (widget-geometry widget #!optional absolute?)
  (and-let* ((widget* (widget-pointer widget)))
    (let ((geometry (rect 0 0 0 0))
          (proc (if absolute? KW_GetWidgetAbsoluteGeometry KW_GetWidgetGeometry)))
      (let-location ((x int)
                     (y int)
                     (w int)
                     (h int))
        (proc widget* (location x) (location y) (location w) (location h))
        (set! (rect-x geometry) x)
        (set! (rect-y geometry) y)
        (set! (rect-w geometry) w)
        (set! (rect-h geometry) h))
      geometry)))

(define (widget-geometry-set! widget geometry)
  (and-let* ((widget* (widget-pointer widget)))
    (let ((x (rect-x geometry))
          (y (rect-y geometry))
          (w (rect-w geometry))
          (h (rect-h geometry)))
      (KW_SetWidgetGeometry widget* x y w h))))

(define widget-geometry (getter-with-setter widget-geometry widget-geometry-set!))

(define (widget-center-with-rect-proc parent inner proc)
  (let ((geometry (widget-geometry inner)))
    (proc (widget-geometry parent) geometry)
    (widget-geometry-set! inner geometry)))

(define (widget-center-in-parent-horizontally! parent inner)
  (widget-center-with-rect-proc parent inner rect-center-in-parent-horizontally!))

(define (widget-center-in-parent-vertically! parent inner)
  (widget-center-with-rect-proc parent inner rect-center-in-parent-vertically!))

(define (widget-center-in-parent! parent inner)
  (widget-center-with-rect-proc parent inner rect-center-in-parent!))

(define (widget-fill-parent-horizontally! parent children weights padding valign)
  (let ((count (length weights))
        (parent (widget-geometry parent))
        (rects (map widget-geometry children)))
    (rect-fill-parent-horizontally! parent rects weights count padding valign)
    (for-each (lambda (item) (widget-geometry-set! (car item) (cadr item)))
              (zip children rects))))

;;; handler interface

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

;;; SXML interface

(define (attributes->alist attributes)
  (map (lambda (item) (cons (car item) (cadr item)))
       attributes))

(define (widget gui tag parent attributes)
  (let* ((text (alist-ref 'text attributes))

         (id (alist-ref 'id attributes))
         (x (alist-ref 'x attributes))
         (y (alist-ref 'y attributes))
         (w (alist-ref 'w attributes))
         (h (alist-ref 'h attributes))
         (geometry (rect x y w h))

         (known-handlers '(mouse-over mouse-leave mouse-down mouse-up
                           drag-start drag-stop drag))
         (handlers (lset-intersection eqv? (map car attributes) known-handlers))

         (widget
          (case tag
            ((frame)
             (frame gui parent geometry))
            ((label)
             (let ((widget (label gui parent text geometry)))
               (and-let* ((spec (alist-ref 'icon attributes))
                          (spec (attributes->alist spec))
                          (x (alist-ref 'x spec))
                          (y (alist-ref 'y spec))
                          (w (alist-ref 'w spec))
                          (h (alist-ref 'h spec))
                          (geometry (rect x y w h)))
                 (label-icon-set! widget geometry))
               (and-let* ((spec (alist-ref 'align attributes)))
                 (apply label-alignment-set! widget spec))
               (and-let* ((color (alist-ref 'color attributes)))
                 (label-color-set! widget color))
               widget))
            ((editbox)
             (let ((widget (editbox gui parent text geometry)))
               (and-let* ((font (alist-ref 'font attributes)))
                 (editbox-font-set! widget font))
               widget))
            ((button)
             (button gui parent text geometry))
            (else
             (abort (usage-error (format "Unimplemented widget tag name: ~a" tag) 'widget))))))
    (and-let* ((tileset (alist-ref 'tileset attributes)))
      (widget-tileset-surface-set! widget tileset))
    (when (pair? handlers)
      (for-each
       (lambda (handler)
         (let ((proc (alist-ref handler attributes)))
           (handler-set! widget handler proc)))
       handlers))
    (when id
      (widget-id-set! widget id))
    widget))

;; (widgets gui [parent] sxml)
(define (widgets gui sxml-or-parent #!optional arg)
  (define (inner gui sxml parent)
    (match sxml
      ((tag ('@ attributes ...) children ...)
       (let ((parent (widget gui tag parent (attributes->alist attributes))))
         (for-each (lambda (child) (inner gui child parent))
                   children)))
      (_ (abort (usage-error "Invalid SXML syntax" 'widgets)))))
  (inner gui (or arg sxml-or-parent) (if arg sxml-or-parent #f)))

)
