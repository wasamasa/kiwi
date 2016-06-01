(module kiwi
  (create-sdl2-driver release-driver!
   driver-sdl2-renderer driver-sdl2-window
   load-surface release-surface!
   load-font release-font!
   init! process-events! paint! quit!
   gui-driver gui-driver-set!
   gui-tileset-surface gui-tileset-surface-set!
   gui-font gui-font-set!
   gui-text-color gui-text-color-set!
   rect rect-x rect-y rect-w rect-h rect-x-set! rect-y-set! rect-w-set! rect-h-set!
   rect-empty? enclosing-rect rect-center-in-parent! rect-center-in-parent-horizontally! rect-center-in-parent-vertically! rect-layout-vertically! rect-layout-horizontally! rect-fill-parent-vertically! rect-fill-parent-horizontally!
   color color-r color-g color-b color-a color-r-set! color-g-set! color-b-set! color-a-set!
   widget-type
   widget-by-id widgets-by-type
   widget-gui widget-driver
   widget-tileset-surface widget-tileset-surface-set!
   reparent-widget!
   widget-parent widget-children
   widget-bring-to-front! widget-focus-set! widget-clip-children?-set!
   destroy-widget!
   hide-widget! show-widget! widget-hidden?
   block-widget-input-events! unblock-widget-input-events! widget-input-events-blocked?
   enable-widget-hint! disable-widget-hint! query-widget-hint
   frame
   scrollbox scrollbox-horizontal-scroll! scrollbox-vertical-scroll!
   label label-text-set! label-icon-set! label-alignment-set! label-style-set! label-font label-font-set! label-text-color label-text-color-set! label-text-color-set?
   button button-text-set! button-icon-set! button-font-set! button-text-color button-text-color-set! button-text-color-set?
   editbox editbox-text editbox-text-set! editbox-cursor-position editbox-cursor-position-set! editbox-font editbox-font-set! editbox-text-color editbox-text-color-set! editbox-text-color-set?
   widget-geometry widget-absolute-geometry widget-composed-geometry widget-geometry-set!
   widget-center-in-parent! widget-center-in-parent-horizontally! widget-center-in-parent-vertically! widget-fill-parent-horizontally!
   handler-set! handler-remove!
   widgets)

(import chicken scheme foreign)
(use clojurian-syntax srfi-69 srfi-4 srfi-1 matchable data-structures)

;;; headers

#>
#include "KW_gui.h"
#include "KW_rect.h"
#include "KW_frame.h"
#include "KW_scrollbox.h"
#include "KW_label.h"
#include "KW_button.h"
#include "KW_editbox.h"
#include "KW_widget.h"
#include "KW_renderdriver_sdl2.h"
<#

;;; foreign values

;; KW_label.h

;; enum KW_LabelHorizontalAlignment
(define KW_LABEL_ALIGN_LEFT (foreign-value "KW_LABEL_ALIGN_LEFT" int))
(define KW_LABEL_ALIGN_CENTER (foreign-value "KW_LABEL_ALIGN_CENTER" int))
(define KW_LABEL_ALIGN_RIGHT (foreign-value "KW_LABEL_ALIGN_RIGHT" int))

;; enum KW_LabelVerticalAlignment
(define KW_LABEL_ALIGN_TOP (foreign-value "KW_LABEL_ALIGN_TOP" int))
(define KW_LABEL_ALIGN_MIDDLE (foreign-value "KW_LABEL_ALIGN_MIDDLE" int))
(define KW_LABEL_ALIGN_BOTTOM (foreign-value "KW_LABEL_ALIGN_BOTTOM" int))

;; KW_renderdriver.h

;; enum KW_RenderDriver_TextStyle
(define KW_TTF_STYLE_NORMAL (foreign-value "KW_TTF_STYLE_NORMAL" int))
(define KW_TTF_STYLE_BOLD (foreign-value "KW_TTF_STYLE_BOLD" int))
(define KW_TTF_STYLE_ITALIC (foreign-value "KW_TTF_STYLE_ITALIC" int))
(define KW_TTF_STYLE_UNDERLINE (foreign-value "KW_TTF_STYLE_UNDERLINE" int))
(define KW_TTF_STYLE_STRIKETHROUGH (foreign-value "KW_TTF_STYLE_STRIKETHROUGH" int))

;; KW_widget.h

;; enum KW_WidgetHint
(define KW_WIDGETHINT_ALLOWTILESTRETCH (foreign-value "KW_WIDGETHINT_ALLOWTILESTRETCH" int))
(define KW_WIDGETHINT_BLOCKINPUTEVENTS (foreign-value "KW_WIDGETHINT_BLOCKINPUTEVENTS" int))
(define KW_WIDGETHINT_IGNOREINPUTEVENTS (foreign-value "KW_WIDGETHINT_IGNOREINPUTEVENTS" int))
(define KW_WIDGETHINT_FRAMELESS (foreign-value "KW_WIDGETHINT_FRAMELESS" int))
(define KW_WIDGETHINT_HIDDEN (foreign-value "KW_WIDGETHINT_HIDDEN" int))

;;; typedefs

(define-foreign-type SDL_Renderer* (nonnull-c-pointer (struct "SDL_Renderer")))
(define-foreign-type SDL_Window* (nonnull-c-pointer (struct "SDL_Window")))
(define-foreign-type KW_RenderDriver* (nonnull-c-pointer (struct "KW_RenderDriver")))
(define-foreign-type KW_Surface* (nonnull-c-pointer (struct "KW_Surface")))
(define-foreign-type KW_Font* (nonnull-c-pointer (struct "KW_Font")))
(define-foreign-type KW_GUI* (nonnull-c-pointer (struct "KW_GUI")))
(define-foreign-type KW_Widget* (nonnull-c-pointer (struct "KW_Widget")))
(define-foreign-type KW_Widget*-or-null (c-pointer (struct "KW_Widget")))
(define-foreign-type int* (nonnull-c-pointer int))

;;; foreign functions

;; KW_gui.h
(define KW_Init (foreign-lambda KW_GUI* "KW_Init" KW_RenderDriver* KW_Surface*))
(define KW_Paint (foreign-lambda void "KW_Paint" KW_GUI*))
(define KW_ProcessEvents (foreign-safe-lambda void "KW_ProcessEvents" KW_GUI*))
(define KW_Quit (foreign-lambda void "KW_Quit" KW_GUI*))
(define KW_GetRenderer (foreign-lambda KW_RenderDriver* "KW_GetRenderer" KW_GUI*))
(define KW_SetRenderer (foreign-lambda void "KW_SetRenderer" KW_GUI* KW_RenderDriver*))
(define KW_GetTilesetSurface (foreign-lambda KW_Surface* "KW_GetTilesetSurface" KW_GUI*))
(define KW_SetTilesetSurface (foreign-lambda void "KW_SetTilesetSurface" KW_GUI* KW_Surface*))
;; (define KW_GetTilesetTexture)
(define KW_GetFont (foreign-lambda KW_Font* "KW_GetFont" KW_GUI*))
(define KW_SetFont (foreign-lambda void "KW_SetFont" KW_GUI* KW_Font*))
(define KW_GetTextColor (foreign-lambda* void ((KW_GUI* gui) (int* r) (int* g) (int* b) (int* a)) "KW_Color c = KW_GetTextColor(gui); *r = c.r, *g = c.g, *b = c.b, *a = c.a;"))
(define KW_SetTextColor (foreign-lambda* void ((KW_GUI* gui) (unsigned-byte r) (unsigned-byte g) (unsigned-byte b) (unsigned-byte a)) "KW_Color c = { r, g, b, a }; KW_SetTextColor(gui, c);"))
;; NOTE: seems too obscure to support, would require non-widget event handlers
;; (define KW_AddGUIFontChangedHandler)
;; (define KW_RemoveGUIFontChangedHandler)
;; (define KW_AddGUITextColorChangedHandler)
;; (define KW_RemoveGUITextColorChangedHandler)

;; KW_renderdriver.h
(define KW_LoadFont (foreign-lambda KW_Font* "KW_LoadFont" KW_RenderDriver* nonnull-c-string unsigned-int))
(define KW_ReleaseFont (foreign-lambda void "KW_ReleaseFont" KW_RenderDriver* KW_Font*))
(define KW_LoadSurface (foreign-lambda KW_Surface* "KW_LoadSurface" KW_RenderDriver* nonnull-c-string))
(define KW_ReleaseSurface (foreign-lambda void "KW_ReleaseSurface" KW_RenderDriver* KW_Surface*))
;; NOTE: there's lots more, but they're undocumented
;; TODO: figure out what textures, extents and cliprects are good for
(define KW_ReleaseRenderDriver (foreign-lambda void "KW_ReleaseRenderDriver" KW_RenderDriver*))

;; KW_renderdriver_sdl2.h
(define KW_CreateSDL2RenderDriver (foreign-lambda KW_RenderDriver* "KW_CreateSDL2RenderDriver" SDL_Renderer* SDL_Window*))
(define KW_RenderDriverGetSDL2Renderer (foreign-lambda SDL_Renderer* "KW_RenderDriverGetSDL2Renderer" KW_RenderDriver*))
(define KW_RenderDriverGetSDL2Window (foreign-lambda SDL_Window* "KW_RenderDriverGetSDL2Window" KW_RenderDriver*))

;; KW_frame.h
(define KW_CreateFrame (foreign-lambda* KW_Widget* ((KW_GUI* gui) (KW_Widget*-or-null parent) (int x) (int y) (int w) (int h)) "KW_Rect r = { x, y, w, h }; C_return(KW_CreateFrame(gui, parent, &r));"))

;; KW_scrollbox.h
(define KW_CreateScrollbox (foreign-lambda* KW_Widget* ((KW_GUI* gui) (KW_Widget*-or-null parent) (int x) (int y) (int w) (int h))" KW_Rect r = { x, y, w, h }; C_return(KW_CreateScrollbox(gui, parent, &r));"))
(define KW_ScrollboxHorizontalScroll (foreign-lambda void "KW_ScrollboxHorizontalScroll" KW_Widget* int))
(define KW_ScrollboxVerticalScroll (foreign-lambda void "KW_ScrollboxVerticalScroll" KW_Widget* int))

;; KW_label.h
(define KW_CreateLabel (foreign-lambda* KW_Widget* ((KW_GUI* gui) (KW_Widget*-or-null parent) (nonnull-c-string text) (int x) (int y) (int w) (int h)) "KW_Rect r = { x, y, w, h }; C_return(KW_CreateLabel(gui, parent, text, &r));"))
(define KW_SetLabelText (foreign-lambda void "KW_SetLabelText" KW_Widget* nonnull-c-string))
(define KW_SetLabelAlignment (foreign-lambda void "KW_SetLabelAlignment" KW_Widget* (enum "KW_LabelHorizontalAlignment") int (enum "KW_LabelVerticalAlignment") int))
(define KW_SetLabelStyle (foreign-lambda void "KW_SetLabelStyle" KW_Widget* (enum "KW_RenderDriver_TextStyle")))
(define KW_SetLabelIcon (foreign-lambda* void ((KW_Widget* label) (int x) (int y) (int w) (int h)) "KW_Rect r = { x, y, w, h }; KW_SetLabelIcon(label, &r);"))
(define KW_GetLabelFont (foreign-lambda KW_Font* "KW_GetLabelFont" KW_Widget*))
(define KW_SetLabelFont (foreign-lambda void "KW_SetLabelFont" KW_Widget* KW_Font*))
(define KW_GetLabelTextColor (foreign-lambda* void ((KW_Widget* widget) (int* r) (int* g) (int* b) (int* a)) "KW_Color c = KW_GetLabelTextColor(widget); *r = c.r, *g = c.g, *b = c.b, *a = c.a;"))
(define KW_SetLabelTextColor (foreign-lambda* void ((KW_Widget* label) (unsigned-byte r) (unsigned-byte g) (unsigned-byte b) (unsigned-byte a)) "KW_Color c = { r, g, b, a }; KW_SetLabelTextColor(label, c);"))
(define KW_WasLabelTextColorSet (foreign-lambda bool "KW_WasLabelTextColorSet" KW_Widget*))

;; KW_button.h
(define KW_CreateButton (foreign-lambda* KW_Widget* ((KW_GUI* gui) (KW_Widget*-or-null parent) (nonnull-c-string text) (int x) (int y) (int w) (int h)) "KW_Rect r = { x, y, w, h }; C_return(KW_CreateButton(gui, parent, text, &r));"))
(define KW_SetButtonText (foreign-lambda void "KW_SetButtonText" KW_Widget* nonnull-c-string))
(define KW_SetButtonIcon (foreign-lambda* void ((KW_Widget* button) (int x) (int y) (int w) (int h)) "KW_Rect r = { x, y, w, h }; KW_SetButtonIcon(button, &r);"))
(define KW_SetButtonFont (foreign-lambda void "KW_SetButtonFont" KW_Widget* KW_Font*))
(define KW_GetButtonTextColor (foreign-lambda* void ((KW_Widget* button) (int* r) (int* g) (int* b) (int* a)) "KW_Color c = KW_GetButtonTextColor(button); *r = c.r, *g = c.g, *b = c.b, *a = c.a;"))
(define KW_SetButtonTextColor (foreign-lambda* void ((KW_Widget* button) (unsigned-byte r) (unsigned-byte g) (unsigned-byte b) (unsigned-byte a)) "KW_Color c = { r, g, b, a }; KW_SetButtonTextColor(button, c);"))
(define KW_WasButtonTextColorSet (foreign-lambda bool "KW_WasButtonTextColorSet" KW_Widget*))

;; KW_editbox.h
(define KW_CreateEditbox (foreign-lambda* KW_Widget* ((KW_GUI* gui) (KW_Widget*-or-null parent) (nonnull-c-string text) (int x) (int y) (int w) (int h)) "KW_Rect r = { x, y, w, h }; C_return(KW_CreateEditbox(gui, parent, text, &r));"))
(define KW_GetEditboxText (foreign-lambda c-string "KW_GetEditboxText" KW_Widget*))
(define KW_SetEditboxText (foreign-lambda void "KW_SetEditboxText" KW_Widget* nonnull-c-string))
(define KW_GetEditboxCursorPosition (foreign-lambda unsigned-int "KW_GetEditboxCursorPosition" KW_Widget*))
(define KW_SetEditboxCursorPosition (foreign-lambda void "KW_SetEditboxCursorPosition" KW_Widget* unsigned-int))
(define KW_GetEditboxFont (foreign-lambda KW_Font* "KW_GetEditboxFont" KW_Widget*))
(define KW_SetEditboxFont (foreign-lambda void "KW_SetEditboxFont" KW_Widget* KW_Font*))
(define KW_GetEditboxTextColor (foreign-lambda* void ((KW_Widget* editbox) (int* r) (int* g) (int* b) (int* a)) "KW_Color c = KW_GetEditboxTextColor(editbox); *r = c.r, *g = c.g, *b = c.b, *a = c.a;"))
(define KW_SetEditboxTextColor (foreign-lambda* void ((KW_Widget* editbox) (unsigned-byte r) (unsigned-byte g) (unsigned-byte b) (unsigned-byte a)) "KW_Color c = { r, g, b, a }; KW_SetEditboxTextColor(editbox, c);"))
(define KW_WasEditboxTextColorSet (foreign-lambda bool "KW_WasEditboxTextColorSet" KW_Widget*))

;; KW_widget.h
;; NOTE: this requires integrating callbacks for paint/destroy
;; operations and the undocumented renderdriver functions, too
;; (define KW_CreateWidget)
(define KW_GetWidgetGUI (foreign-lambda KW_GUI* "KW_GetWidgetGUI" KW_Widget*))
(define KW_GetWidgetRenderer (foreign-lambda KW_RenderDriver* "KW_GetWidgetRenderer" KW_Widget*))
(define KW_GetWidgetTilesetSurface (foreign-lambda KW_Surface* "KW_GetWidgetTilesetSurface" KW_Widget*))
(define KW_SetWidgetTilesetSurface (foreign-lambda void "KW_SetWidgetTilesetSurface" KW_Widget* KW_Surface*))
(define KW_ReparentWidget (foreign-lambda void "KW_ReparentWidget" KW_Widget* KW_Widget*))
(define KW_GetWidgetParent (foreign-lambda KW_Widget*-or-null "KW_GetWidgetParent" KW_Widget*))
(define KW_GetWidgetChildren (foreign-lambda c-pointer "KW_GetWidgetChildren" KW_Widget* int*))
(define KW_GetWidgetChild (foreign-lambda* KW_Widget* ((c-pointer p) (int i)) "KW_Widget * const * children = p; C_return(children[i]);"))
;; NOTE: useless for stock widgets
;; (define KW_GetWidgetData)
;; (define KW_GetWidgetUserData)
;; (define KW_SetWidgetUserData)
;; (define KW_PaintWidget)
(define KW_BringToFront (foreign-lambda void "KW_BringToFront" KW_Widget*))
(define KW_SetFocusedWidget (foreign-lambda void "KW_SetFocusedWidget" KW_Widget*))
(define KW_SetClipChildrenWidgets (foreign-lambda void "KW_SetClipChildrenWidgets" KW_Widget* bool))
(define KW_DestroyWidget (foreign-lambda void "KW_DestroyWidget" KW_Widget* bool))
(define KW_HideWidget (foreign-lambda void "KW_HideWidget" KW_Widget*))
(define KW_ShowWidget (foreign-lambda void "KW_ShowWidget" KW_Widget*))
(define KW_IsWidgetHidden (foreign-lambda bool "KW_IsWidgetHidden" KW_Widget*))
(define KW_BlockWidgetInputEvents (foreign-lambda void "KW_BlockWidgetInputEvents" KW_Widget*))
(define KW_UnblockWidgetInputEvents (foreign-lambda void "KW_UnblockWidgetInputEvents" KW_Widget*))
(define KW_IsWidgetInputEventsBlocked (foreign-lambda bool "KW_IsWidgetInputEventsBlocked" KW_Widget*))
(define KW_EnableWidgetHint (foreign-lambda void "KW_EnableWidgetHint" KW_Widget* (enum "KW_WidgetHint") bool))
(define KW_DisableWidgetHint (foreign-lambda void "KW_DisableWidgetHint" KW_Widget* (enum "KW_WidgetHint") bool))
(define KW_QueryWidgetHint (foreign-lambda bool "KW_QueryWidgetHint" KW_Widget* (enum "KW_WidgetHint")))
(define KW_GetWidgetGeometry (foreign-lambda* void ((KW_Widget* widget) (int* x) (int* y) (int* w) (int* h)) "KW_Rect r; KW_GetWidgetGeometry(widget, &r); *x = r.x, *y = r.y, *w = r.w, *h = r.h;"))
(define KW_GetWidgetAbsoluteGeometry (foreign-lambda* void ((KW_Widget* widget) (int* x) (int* y) (int* w) (int* h)) "KW_Rect r; KW_GetWidgetAbsoluteGeometry(widget, &r); *x = r.x, *y = r.y, *w = r.w, *h = r.h;"))
(define KW_GetWidgetComposedGeometry (foreign-lambda* void ((KW_Widget* widget) (int* x) (int* y) (int* w) (int* h)) "KW_Rect r; KW_GetWidgetComposedGeometry(widget, &r); *x = r.x, *y = r.y, *w = r.w, *h = r.h;"))
(define KW_SetWidgetGeometry (foreign-lambda* void ((KW_Widget* widget) (int x) (int y) (int w) (int h)) "KW_Rect r = { x, y, w, h }; KW_SetWidgetGeometry(widget, &r);"))
;; (define KW_GetWidgetTilesetTexture)

(define KW_AddWidgetMouseOverHandler (foreign-lambda void "KW_AddWidgetMouseOverHandler" KW_Widget* (function void (KW_Widget*))))
(define KW_RemoveWidgetMouseOverHandler (foreign-lambda void "KW_RemoveWidgetMouseOverHandler" KW_Widget* (function void (KW_Widget*))))
(define KW_AddWidgetMouseLeaveHandler (foreign-lambda void "KW_AddWidgetMouseLeaveHandler" KW_Widget* (function void (KW_Widget*))))
(define KW_RemoveWidgetMouseLeaveHandler (foreign-lambda void "KW_RemoveWidgetMouseLeaveHandler" KW_Widget* (function void (KW_Widget*))))
(define KW_AddWidgetMouseDownHandler (foreign-lambda void "KW_AddWidgetMouseDownHandler" KW_Widget* (function void (KW_Widget* int))))
(define KW_RemoveWidgetMouseDownHandler (foreign-lambda void "KW_RemoveWidgetMouseDownHandler" KW_Widget* (function void (KW_Widget* int))))
(define KW_AddWidgetMouseUpHandler (foreign-lambda void "KW_AddWidgetMouseUpHandler" KW_Widget* (function void (KW_Widget* int))))
(define KW_RemoveWidgetMouseUpHandler (foreign-lambda void "KW_RemoveWidgetMouseUpHandler" KW_Widget* (function void (KW_Widget* int))))

(define KW_AddWidgetFocusGainHandler (foreign-lambda void "KW_AddWidgetFocusGainHandler" KW_Widget* (function void (KW_Widget*))))
(define KW_RemoveWidgetFocusGainHandler (foreign-lambda void "KW_RemoveWidgetFocusGainHandler" KW_Widget* (function void (KW_Widget*))))
(define KW_AddWidgetFocusLoseHandler (foreign-lambda void "KW_AddWidgetFocusLoseHandler" KW_Widget* (function void (KW_Widget*))))
(define KW_RemoveWidgetFocusLoseHandler (foreign-lambda void "KW_RemoveWidgetFocusLoseHandler" KW_Widget* (function void (KW_Widget*))))

(define KW_AddWidgetTextInputHandler (foreign-lambda void "KW_AddWidgetTextInputHandler" KW_Widget* (function void (KW_Widget* (const c-string)))))
(define KW_RemoveWidgetTextInputHandler (foreign-lambda void "KW_RemoveWidgetTextInputHandler" KW_Widget* (function void (KW_Widget* (const c-string)))))
;; NOTE: not representable due to SDL_Scancode in the function pointer signature
;; (define KW_AddWidgetKeyDownHandler (foreign-lambda void "KW_AddWidgetKeyDownHandler" KW_Widget* (function void (KW_Widget* SDL_Keycode SDL_Scancode))))
;; (define KW_RemoveWidgetKeyDownHandler (foreign-lambda void "KW_RemoveWidgetKeyDownHandler" KW_Widget* (function void (KW_Widget* SDL_Keycode SDL_Scancode))))
;; (define KW_AddWidgetKeyUpHandler (foreign-lambda void "KW_AddWidgetKeyUpHandler" KW_Widget* (function void (KW_Widget* SDL_Keycode SDL_Scancode))))
;; (define KW_RemoveWidgetKeyUpHandler (foreign-lambda void "KW_RemoveWidgetKeyUpHandler" KW_Widget* (function void (KW_Widget* SDL_Keycode SDL_Scancode))))

(define KW_AddWidgetDragStartHandler (foreign-lambda void "KW_AddWidgetDragStartHandler" KW_Widget* (function void (KW_Widget* int int))))
(define KW_RemoveWidgetDragStartHandler (foreign-lambda void "KW_RemoveWidgetDragStartHandler" KW_Widget* (function void (KW_Widget* int int))))
(define KW_AddWidgetDragStopHandler (foreign-lambda void "KW_AddWidgetDragStopHandler" KW_Widget* (function void (KW_Widget* int int))))
(define KW_RemoveWidgetDragStopHandler (foreign-lambda void "KW_RemoveWidgetDragStopHandler" KW_Widget* (function void (KW_Widget* int int))))
(define KW_AddWidgetDragHandler (foreign-lambda void "KW_AddWidgetDragHandler" KW_Widget* (function void (KW_Widget* int int int int))))
(define KW_RemoveWidgetDragHandler (foreign-lambda void "KW_RemoveWidgetDragHandler" KW_Widget* (function void (KW_Widget* int int int int))))

;; NOTE: not worth adding either
;; (define KW_AddWidgetGeometryChangeHandler)
;; (define KW_RemoveWidgetGeometryChangeHandler)
;; (define KW_AddWidgetChildrenChangeHandler)
;; (define KW_RemoveWidgetChildrenChangeHandler)

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

(define-external (kiwi_MouseOverHandler (KW_Widget* widget*)) void
  (dispatch-event! widget* 'mouse-over))

(define-external (kiwi_MouseLeaveHandler (KW_Widget* widget*)) void
  (dispatch-event! widget* 'mouse-leave))

(define-external (kiwi_MouseDownHandler (KW_Widget* widget*) (int button)) void
  (dispatch-event! widget* 'mouse-down button))

(define-external (kiwi_MouseUpHandler (KW_Widget* widget*) (int button)) void
  (dispatch-event! widget* 'mouse-up button))

(define-external (kiwi_FocusGainHandler (KW_Widget* widget*)) void
  (dispatch-event! widget* 'focus-gain))

(define-external (kiwi_FocusLoseHandler (KW_Widget* widget*)) void
  (dispatch-event! widget* 'focus-lose))

(define-external (kiwi_TextInputHandler (KW_Widget* widget*) ((const c-string) text)) void
  (dispatch-event! widget* 'text-input text))

(define-external (kiwi_DragStartHandler (KW_Widget* widget*) (int x) (int y)) void
  (dispatch-event! widget* 'drag-start x y))

(define-external (kiwi_DragStopHandler (KW_Widget* widget*) (int x) (int y)) void
  (dispatch-event! widget* 'drag-stop x y))

(define-external (kiwi_DragHandler (KW_Widget* widget*) (int x) (int y) (int relx) (int rely)) void
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

(define (create-sdl2-driver renderer window)
  (if-let (driver* (KW_CreateSDL2RenderDriver renderer window))
    (set-finalizer! (make-driver driver*) release-driver!)
    (abort (oom-error 'create-sdl2-render-driver))))

(define (release-driver! driver)
  (and-let* ((driver* (driver-pointer driver)))
    (KW_ReleaseRenderDriver driver*)
    (driver-pointer-set! driver #f)))

(define (driver-sdl2-renderer driver)
  (and-let* ((driver* (driver-pointer driver)))
    ;; NOTE: returns raw pointer
    (KW_RenderDriverGetSDL2Renderer driver*)))

(define (driver-sdl2-window driver)
  (and-let* ((driver* (driver-pointer driver)))
    ;; NOTE: returns raw pointer
    (KW_RenderDriverGetSDL2Window driver*)))

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

(define (gui-driver gui)
  (and-let* ((gui* (gui-pointer gui)))
    (make-driver (KW_GetRenderer gui*))))

(define (gui-driver-set! gui driver)
  (and-let* ((gui* (gui-pointer gui))
             (driver* (driver-pointer driver)))
    (KW_SetRenderer gui* driver*)))

(define gui-driver (getter-with-setter gui-driver gui-driver-set!))

(define (gui-font gui)
  (and-let* ((gui* (gui-pointer gui)))
    ;; NOTE: no finalizer as loading up the font created one already
    (make-font (KW_GetFont gui*))))

(define (gui-font-set! gui font)
  (and-let* ((gui* (gui-pointer gui))
             (font* (font-pointer font)))
    (KW_SetFont gui* font*)))

(define gui-font (getter-with-setter gui-font gui-font-set!))

(define (gui-text-color gui)
  (and-let* ((gui* (gui-pointer gui)))
    (let-location ((r int)
                   (g int)
                   (b int)
                   (a int))
      (KW_GetTextColor gui* (location r) (location g) (location b) (location a))
      (color r g b a))))

(define (gui-text-color-set! gui color)
  (and-let* ((gui* (gui-pointer gui))
             (r (color-r color))
             (g (color-g color))
             (b (color-b color))
             (a (color-a color)))
    (KW_SetTextColor gui* r g b a)))

(define gui-text-color (getter-with-setter gui-text-color gui-text-color-set!))

(define (gui-tileset-surface gui)
  (and-let* ((gui* (gui-pointer gui)))
    ;; NOTE: no finalizer as loading up the surface created one already
    (make-surface (KW_GetTilesetSurface gui*))))

(define (gui-tileset-surface-set! gui tileset)
  (and-let* ((gui* (gui-pointer gui))
             (tileset* (surface-pointer tileset)))
    (KW_SetTilesetSurface gui* tileset*)))

(define gui-tileset-surface (getter-with-setter gui-tileset-surface gui-tileset-surface-set!))

;;; rects

(define rect make-rect)

(define rect-x (getter-with-setter rect-x rect-x-set!))
(define rect-y (getter-with-setter rect-y rect-y-set!))
(define rect-w (getter-with-setter rect-w rect-w-set!))
(define rect-h (getter-with-setter rect-h rect-h-set!))

;; NOTE: the following have been ported from KW_rect.h as it is too
;; bothersome to wrap them with the FFI and involves more code than
;; for the Scheme versions below

(define (rect-empty? rect)
  (and (zero? (rect-w rect)) (zero? (rect-h rect))))

(define (extend-bounding-box r1 r2)
  (let ((x (min (rect-x r1) (rect-x r2)))
        (y (min (rect-y r1) (rect-y r2)))
        (w (max (rect-w r1) (rect-w r2)))
        (h (max (rect-w r1) (rect-w r2))))
    (rect x y w h)))

(define (enclosing-rect rects)
  (when (null? rects)
    (abort (usage-error "RECTS must be a list of at least one rect"
                        'enclosing-rect)))
  (fold extend-bounding-box (car rects) (cdr rects)))

(define (rect-center-in-parent-horizontally! parent inner)
  (set! (rect-x inner) (- (/ (rect-w parent) 2) (/ (rect-w inner) 2))))

(define (rect-center-in-parent-vertically! parent inner)
  (set! (rect-y inner) (- (/ (rect-h parent) 2) (/ (rect-h inner) 2))))

(define (rect-center-in-parent! parent inner)
  (rect-center-in-parent-horizontally! parent inner)
  (rect-center-in-parent-vertically! parent inner))

(define (rect-layout-vertically! rects padding #!optional halign)
  (when (and halign (not (member halign '(left center right))))
    (abort (usage-error "Invalid vertical alignment value"
                        'rect-layout-vertically!)))
  (let ((outer (enclosing-rect rects))
        (current 0))
    (for-each
     (lambda (inner)
       (set! (rect-y inner) current)
       (set! current (+ current (rect-h inner) padding))
       (case halign
         ((left) (set! (rect-x inner) (rect-x outer)))
         ((center)
          (rect-center-in-parent-horizontally! outer inner)
          (set! (rect-x inner) (+ (rect-x inner) (rect-x outer))))
         ((right) (set! (rect-x inner) (- (rect-w outer) (rect-w inner))))))
     rects)))

(define (rect-layout-horizontally! rects padding #!optional valign)
  (when (and valign (not (member valign '(top middle bottom))))
    (abort (usage-error "Invalid horizontal alignment value"
                        'rect-layout-horizontally!)))
  (let ((outer (enclosing-rect rects))
        (current 0))
    (for-each
     (lambda (inner)
       (set! (rect-x inner) (+ current padding))
       (set! current (+ (rect-w inner) (rect-x inner)))
       (case valign
         ((top) (set! (rect-y inner) (rect-y outer)))
         ((middle)
          (rect-center-in-parent-vertically! outer inner)
          (set! (rect-y inner) (+ (rect-y inner) (rect-y outer))))
         ((bottom) (set! (rect-y inner) (- (rect-h outer) (rect-h inner))))))
     rects)))

(define (sum numbers)
  (fold + 0 numbers))

(define (rect-fill-parent-vertically! parent rects weights padding)
  (when (not (= (length rects) (length weights)))
    (abort (usage-error "Length of RECTS and WEIGHTS must be equal"
                        'rect-fill-parent-vertically!)))
  (let* ((total (sum weights))
         (base (/ (- (rect-h parent) (* padding (add1 (length weights)))) total))
         (current 0))
    (for-each
     (lambda (inner weight)
       (set! (rect-y inner) (+ current padding))
       (set! (rect-h inner) (* base weight))
       (set! current (+ (rect-y inner) (rect-h inner))))
     rects weights)))

(define (rect-fill-parent-horizontally! parent rects weights padding valign)
  (when (not (= (length rects) (length weights)))
    (abort (usage-error "Length of RECTS and WEIGHTS must be equal"
                        'rect-fill-parent-horizontally!)))
  (when (not (member valign '(top middle bottom)))
    (abort (usage-error "Invalid vertical alignment value"
                        'rect-fill-parent-horizontally!)))
  (let* ((total (sum weights))
         (base (/ (- (rect-w parent) (* padding (add1 (length weights)))) total))
         (current 0))
    (for-each
     (lambda (inner weight)
       (set! (rect-x inner) (+ current padding))
       (set! (rect-w inner) (* base weight))
       (case valign
         ((top) (set! (rect-y inner) 0))
         ((middle) (rect-center-in-parent-vertically! parent inner))
         ((bottom) (set! (rect-y inner) (- (rect-h parent) (rect-h inner)))))
       (set! current (+ (rect-x inner) (rect-w inner))))
     rects weights)))

;;; colors

(define color make-color)

(define color-r (getter-with-setter color-r color-r-set!))
(define color-g (getter-with-setter color-g color-g-set!))
(define color-b (getter-with-setter color-b color-b-set!))
(define color-a (getter-with-setter color-a color-a-set!))

;;; widgets

;; NOTE: even if the getter  (or setter) is missing for a property,
;; one could implement a stub and use getter-with-setter on both, then
;; report an upstream bug later

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

(define (widget-gui widget)
  (and-let* ((widget* (widget-pointer widget)))
    (make-gui (KW_GetWidgetGUI widget*))))

(define (widget-driver widget)
  (and-let* ((widget* (widget-pointer widget)))
    (make-driver (KW_GetWidgetRenderer widget*))))

(define (widget-tileset-surface widget)
  (and-let* ((widget* (widget-pointer widget)))
    (make-surface (KW_GetWidgetTilesetSurface widget*))))

(define (widget-tileset-surface-set! widget tileset)
  (and-let* ((widget* (widget-pointer widget))
             (tileset* (surface-pointer tileset)))
    (KW_SetWidgetTilesetSurface widget* tileset*)))

(define widget-tileset-surface (getter-with-setter widget-tileset-surface widget-tileset-surface-set!))

(define (reparent-widget! widget parent)
  (and-let* ((widget* (widget-pointer widget))
             (parent* (widget-pointer parent)))
    (KW_ReparentWidget widget* parent*)))

(define (widget-parent widget)
  (and-let* ((widget* (widget-pointer widget)))
    (if-let (parent* (KW_GetWidgetParent widget*))
      (hash-table-ref widget-table parent*)
      #f)))

(define (widget-children widget)
  (and-let* ((widget* (widget-pointer widget)))
    (let-location ((count int 0))
      (let ((children* (KW_GetWidgetChildren widget* (location count))))
        (if (zero? count)
            '()
            (let loop ((i 0)
                       (children '()))
              (if (< i count)
                  (let* ((child* (KW_GetWidgetChild children* i))
                         (child (hash-table-ref widget-table child*)))
                    (loop (add1 i) (cons child children)))
                  (reverse children))))))))

(define (widget-bring-to-front! widget)
  (and-let* ((widget* (widget-pointer widget)))
    (KW_BringToFront widget*)))

(define (widget-focus-set! widget)
  (and-let* ((widget* (widget-pointer widget)))
    (KW_SetFocusedWidget widget*)))

(define (widget-clip-children?-set! widget flag)
  (and-let* ((widget* (widget-pointer widget)))
    (KW_SetClipChildrenWidgets widget* flag)))

(define (destroy-widget! widget #!optional children?)
  (and-let* ((widget* (widget-pointer widget)))
    (KW_DestroyWidget widget* children?)
    (widget-pointer-set! widget #f)
    (hash-table-delete! widget-table widget*)))

(define (hide-widget! widget)
  (and-let* ((widget* (widget-pointer widget)))
    (KW_HideWidget widget*)))

(define (show-widget! widget)
  (and-let* ((widget* (widget-pointer widget)))
    (KW_ShowWidget widget*)))

(define (widget-hidden? widget)
  (and-let* ((widget* (widget-pointer widget)))
    (KW_IsWidgetHidden widget*)))

(define (block-widget-input-events! widget)
  (and-let* ((widget* (widget-pointer widget)))
    (KW_BlockWidgetInputEvents widget*)))

(define (unblock-widget-input-events! widget)
  (and-let* ((widget* (widget-pointer widget)))
    (KW_UnblockWidgetInputEvents widget*)))

(define (widget-input-events-blocked? widget)
  (and-let* ((widget* (widget-pointer widget)))
    (KW_IsWidgetInputEventsBlocked widget*)))

(define (symbol->widget-hint symbol location)
  (case symbol
    ((allow-tile-stretch) KW_WIDGETHINT_ALLOWTILESTRETCH)
    ((block-input-events) KW_WIDGETHINT_BLOCKINPUTEVENTS)
    ((ignore-input-events) KW_WIDGETHINT_IGNOREINPUTEVENTS)
    ((frameless) KW_WIDGETHINT_FRAMELESS)
    ((hidden) KW_WIDGETHINT_HIDDEN)
    (else
     (abort (usage-error "Invalid widget hint" location)))))

(define (enable-widget-hint! widget hint recur?)
  (and-let* ((widget* (widget-pointer widget)))
    (let ((hint (symbol->widget-hint hint 'enable-widget-hint!)))
      (KW_EnableWidgetHint widget* hint recur?))))

(define (disable-widget-hint! widget hint recur?)
  (and-let* ((widget* (widget-pointer widget)))
    (let ((hint (symbol->widget-hint hint 'disable-widget-hint!)))
      (KW_DisableWidgetHint widget* hint recur?))))

(define (query-widget-hint widget hint)
  (and-let* ((widget* (widget-pointer widget)))
    (let ((hint (symbol->widget-hint hint 'query-widget-hint)))
      (KW_QueryWidgetHint widget* hint))))

(define (widget-text-color widget proc)
  (and-let* ((label* (widget-pointer label)))
    (let-location ((r int)
                   (g int)
                   (b int)
                   (a int))
      (proc label* (location r) (location g) (location b) (location a))
      (color r g b a))))

(define (widget-text-color-set! widget proc color)
  (and-let* ((label* (widget-pointer label))
             (r (color-r color))
             (g (color-g color))
             (b (color-b color))
             (a (color-a color)))
    (proc label* r g b a)))

(define (widget-text-color-set? widget proc)
  (and-let* ((label* (widget-pointer label)))
    (proc label*)))

(define (%widget-geometry widget proc)
  (and-let* ((widget* (widget-pointer widget)))
    (let-location ((x int)
                   (y int)
                   (w int)
                   (h int))
      (proc widget* (location x) (location y) (location w) (location h))
      (rect x y w h))))

(define (widget-absolute-geometry widget)
  (%widget-geometry widget KW_GetWidgetAbsoluteGeometry))

(define (widget-composed-geometry widget)
  (%widget-geometry widget KW_GetWidgetComposedGeometry))

(define (widget-geometry widget)
  (%widget-geometry widget KW_GetWidgetGeometry))

(define (widget-geometry-set! widget geometry)
  (and-let* ((widget* (widget-pointer widget)))
    (let ((x (rect-x geometry))
          (y (rect-y geometry))
          (w (rect-w geometry))
          (h (rect-h geometry)))
      (KW_SetWidgetGeometry widget* x y w h))))

(define widget-geometry (getter-with-setter widget-geometry widget-geometry-set!))

(define (widget-center-with-rect-proc parent inner proc)
  (and-let* ((parent-geometry (widget-geometry parent))
             (inner-geometry (widget-geometry inner)))
    (proc parent-geometry inner-geometry)
    (widget-geometry-set! inner inner-geometry)))

(define (widget-center-in-parent-horizontally! parent inner)
  (widget-center-with-rect-proc parent inner rect-center-in-parent-horizontally!))

(define (widget-center-in-parent-vertically! parent inner)
  (widget-center-with-rect-proc parent inner rect-center-in-parent-vertically!))

(define (widget-center-in-parent! parent inner)
  (widget-center-with-rect-proc parent inner rect-center-in-parent!))

(define (widget-fill-parent-horizontally! parent children weights padding valign)
  (let ((parent (widget-geometry parent))
        (rects (map widget-geometry children)))
    (rect-fill-parent-horizontally! parent rects weights padding valign)
    (for-each (lambda (item) (widget-geometry-set! (car item) (cadr item)))
              (zip children rects))))

;; TODO: define widget predicates

;; frame

(define (frame gui parent geometry)
  (define-widget 'frame gui parent geometry KW_CreateFrame))

;; scrollbox

(define (scrollbox gui parent geometry)
  (define-widget 'scrollbox gui parent geometry KW_CreateScrollbox))

(define (scrollbox-horizontal-scroll! scrollbox amount)
  (and-let* ((scrollbox* (widget-pointer scrollbox)))
    (KW_ScrollboxHorizontalScroll scrollbox* amount)))

(define (scrollbox-vertical-scroll! scrollbox amount)
  (and-let* ((scrollbox* (widget-pointer scrollbox)))
    (KW_ScrollboxVerticalScroll scrollbox* amount)))

;; label

(define (label gui parent text geometry)
  (define-widget 'label gui parent geometry
    (cut KW_CreateLabel <> <> text <> <> <> <>)))

(define (label-text-set! label text)
  (and-let* ((label* (widget-pointer label)))
    (KW_SetLabelText label* text)))

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

(define (label-style-set! label style)
  (and-let* ((label* (widget-pointer label)))
    (let ((style (case style
                   ((normal) KW_TTF_STYLE_NORMAL)
                   ((bold) KW_TTF_STYLE_BOLD)
                   ((italic) KW_TTF_STYLE_ITALIC)
                   ((underline) KW_TTF_STYLE_UNDERLINE)
                   ((strikethrough) KW_TTF_STYLE_STRIKETHROUGH)
                   (else
                    (abort (usage-error "Invalid style value" 'label-style-set!))))))
      (KW_SetLabelStyle label* style))))

(define (label-font label)
  (and-let* ((label* (widget-pointer label)))
    (make-font (KW_GetLabelFont label*))))

(define (label-font-set! label font)
  (and-let* ((label* (widget-pointer label))
             (font* (font-pointer font)))
    (KW_SetLabelFont label* font*)))

(define label-font (getter-with-setter label-font label-font-set!))

(define (label-text-color label)
  (widget-text-color label KW_GetLabelTextColor))

(define (label-text-color-set! label color)
  (widget-text-color-set! label KW_SetLabelTextColor color))

(define label-text-color (getter-with-setter label-text-color label-text-color-set!))

(define (label-text-color-set? label)
  (widget-text-color-set? label KW_WasLabelTextColorSet))

;; button

(define (button gui parent text geometry)
  (define-widget 'button gui parent geometry
    (cut KW_CreateButton <> <> text <> <> <> <>)))

(define (button-text-set! button text)
  (and-let* ((button* (widget-pointer button)))
    (KW_SetButtonText button* text)))

(define (button-icon-set! button clip)
  (and-let* ((button* (widget-pointer button)))
    (let ((x (rect-x clip))
          (y (rect-y clip))
          (w (rect-w clip))
          (h (rect-h clip)))
      (KW_SetButtonIcon button* x y w h))))

(define (button-font-set! button font)
  (and-let* ((button* (widget-pointer button))
             (font* (font-pointer font)))
    (KW_SetButtonFont button* font*)))

(define (button-text-color button)
  (widget-text-color button KW_GetButtonTextColor))

(define (button-text-color-set! button color)
  (widget-text-color-set! button KW_SetButtonTextColor color))

(define button-text-color (getter-with-setter button-text-color button-text-color-set!))

(define (button-text-color-set? button)
  (widget-text-color-set? button KW_WasButtonTextColorSet))

;; editbox

(define (editbox gui parent text geometry)
  (define-widget 'editbox gui parent geometry
    (cut KW_CreateEditbox <> <> text <> <> <> <>)))

(define (editbox-text editbox)
  (and-let* ((editbox* (widget-pointer editbox)))
    (KW_GetEditboxText editbox*)))

(define (editbox-text-set! editbox text)
  (and-let* ((editbox* (widget-pointer editbox)))
    (KW_SetEditboxText editbox* text)))

(define editbox-text (getter-with-setter editbox-text editbox-text-set!))

(define (editbox-cursor-position editbox)
  (and-let* ((editbox* (widget-pointer editbox)))
    (KW_GetEditboxCursorPosition editbox*)))

(define (editbox-cursor-position-set! editbox position)
  (and-let* ((editbox* (widget-pointer editbox)))
    (KW_SetEditboxCursorPosition editbox* position)))

(define editbox-cursor-position (getter-with-setter editbox-cursor-position editbox-cursor-position-set!))

(define (editbox-font editbox)
  (and-let* ((editbox* (widget-pointer editbox)))
    (make-font (KW_GetEditboxFont editbox*))))

(define (editbox-font-set! editbox font)
  (and-let* ((editbox* (widget-pointer editbox))
             (font* (font-pointer font)))
    (KW_SetEditboxFont editbox* font*)))

(define editbox-font (getter-with-setter editbox-font editbox-font-set!))

(define (editbox-text-color editbox)
  (widget-text-color editbox KW_GetEditboxTextColor))

(define (editbox-text-color-set! editbox color)
  (widget-text-color-set! editbox KW_SetEditboxTextColor color))

(define editbox-text-color (getter-with-setter editbox-text-color editbox-text-color-set!))

(define (editbox-text-color-set? editbox)
  (widget-text-color-set? editbox KW_WasEditboxTextColorSet))

;;; handler interface

;; TODO: write a getter thing for generic set!?
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

        ((focus-gain)
         (hash-table-set! handlers 'focus-gain proc)
         (KW_AddWidgetFocusGainHandler widget* (location kiwi_FocusGainHandler)))
        ((focus-lose)
         (hash-table-set! handlers 'focus-lose proc)
         (KW_AddWidgetFocusLoseHandler widget* (location kiwi_FocusLoseHandler)))

        ((text-input)
         (hash-table-set! handlers 'text-input proc)
         (KW_AddWidgetTextInputHandler widget* (location kiwi_TextInputHandler)))

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

(define (handler-remove! widget type)
  (and-let* ((widget* (widget-pointer widget)))
    (let ((handlers (widget-handlers widget)))
      (case type
        ((mouse-over)
         (hash-table-delete! handlers 'mouse-over)
         (KW_RemoveWidgetMouseOverHandler widget* (location kiwi_MouseOverHandler)))
        ((mouse-leave)
         (hash-table-delete! handlers 'mouse-leave)
         (KW_RemoveWidgetMouseLeaveHandler widget* (location kiwi_MouseLeaveHandler)))
        ((mouse-down)
         (hash-table-delete! handlers 'mouse-down)
         (KW_RemoveWidgetMouseDownHandler widget* (location kiwi_MouseDownHandler)))
        ((mouse-up)
         (hash-table-delete! handlers 'mouse-up)
         (KW_RemoveWidgetMouseUpHandler widget* (location kiwi_MouseUpHandler)))

        ((focus-gain)
         (hash-table-delete! handlers 'focus-gain)
         (KW_RemoveWidgetFocusGainHandler widget* (location kiwi_FocusGainHandler)))
        ((focus-lose)
         (hash-table-delete! handlers 'focus-lose)
         (KW_RemoveWidgetFocusLoseHandler widget* (location kiwi_FocusLoseHandler)))

        ((text-input)
         (hash-table-delete! handlers 'text-input)
         (KW_RemoveWidgetTextInputHandler widget* (location kiwi_TextInputHandler)))

        ((drag-start)
         (hash-table-delete! handlers 'drag-start)
         (KW_RemoveWidgetDragStartHandler widget* (location kiwi_DragStartHandler)))
        ((drag-stop)
         (hash-table-delete! handlers 'drag-stop)
         (KW_RemoveWidgetDragStopHandler widget* (location kiwi_DragStopHandler)))
        ((drag)
         (hash-table-delete! handlers 'drag)
         (KW_RemoveWidgetDragHandler widget* (location kiwi_DragHandler)))

        (else
         (abort (usage-error "Unsupported event handler type" 'handler-remove!)))))))

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
               (and-let* ((style (alist-ref 'style attributes)))
                 (label-style-set! widget style))
               (and-let* ((font (alist-ref 'font attributes)))
                 (label-font-set! widget font))
               (and-let* ((color (alist-ref 'color attributes)))
                 (label-text-color-set! widget color))
               widget))
            ((button)
             (let ((widget (button gui parent text geometry)))
               (and-let* ((spec (alist-ref 'icon attributes))
                          (spec (attributes->alist spec))
                          (x (alist-ref 'x spec))
                          (y (alist-ref 'y spec))
                          (w (alist-ref 'w spec))
                          (h (alist-ref 'h spec))
                          (geometry (rect x y w h)))
                 (button-icon-set! widget geometry))
               (and-let* ((font (alist-ref 'font attributes)))
                 (button-font-set! widget font))
               (and-let* ((color (alist-ref 'color attributes)))
                 (button-text-color-set! widget color))
               widget))
            ((editbox)
             (let ((widget (editbox gui parent text geometry)))
               (and-let* ((position (alist-ref 'cursor-position attributes)))
                 (editbox-cursor-position-set! widget position))
               (and-let* ((font (alist-ref 'font attributes)))
                 (editbox-font-set! widget font))
               (and-let* ((color (alist-ref 'color attributes)))
                 (editbox-text-color-set! widget color))
               widget))
            (else
             (abort (usage-error (format "Unimplemented widget tag name: ~a" tag) 'widget))))))
    (and-let* ((tileset (alist-ref 'tileset attributes)))
      (widget-tileset-surface-set! widget tileset))
    (and-let* ((hidden? (alist-ref 'hidden? attributes)))
      (hide-widget! widget))
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
