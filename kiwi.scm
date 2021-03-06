(module kiwi
  (create-sdl2-driver release-driver!
   driver? driver-sdl2-renderer driver-sdl2-window
   surface? load-surface release-surface!
   font? load-font release-font!
   gui? init! process-events! paint! quit!
   gui-driver gui-driver-set!
   gui-tileset-surface gui-tileset-surface-set!
   gui-font gui-font-set!
   gui-text-color gui-text-color-set!
   rect rect? rect-x rect-y rect-w rect-h rect-x-set! rect-y-set! rect-w-set! rect-h-set!
   rect-empty? enclosing-rect rect-center-in-parent! rect-center-in-parent-vertically! rect-center-in-parent-horizontally! rect-layout-vertically! rect-layout-horizontally! rect-fill-parent-vertically! rect-fill-parent-horizontally! rect-margin!
   color color? color-r color-g color-b color-a color-r-set! color-g-set! color-b-set! color-a-set!
   widget? widget-type
   widget-gui widget-driver
   widget-parent widget-children
   reparent-widget! bring-widget-to-front! widget-focus-set! widget-clip-children?-set! destroy-widget!
   hide-widget! show-widget! widget-hidden?
   block-widget-input-events! unblock-widget-input-events! widget-input-events-blocked?
   enable-widget-hint! disable-widget-hint! query-widget-hint
   widget-tileset-surface widget-tileset-surface-set!
   widget-geometry widget-absolute-geometry widget-composed-geometry widget-geometry-set!
   widget-center-in-parent! widget-center-in-parent-vertically! widget-center-in-parent-horizontally! widget-layout-vertically! widget-layout-horizontally! widget-fill-parent-vertically! widget-fill-parent-horizontally! widget-margin!
   frame frame?
   scrollbox scrollbox? scrollbox-horizontal-scroll! scrollbox-vertical-scroll!
   label label? label-text-set! label-icon-set! label-alignment-set! label-style-set! label-font label-font-set! label-text-color label-text-color-set! label-text-color-set?
   button button* button? button-label button-label-set!
   editbox editbox? editbox-text editbox-text-set! editbox-cursor-position editbox-cursor-position-set! editbox-font editbox-font-set! editbox-text-color editbox-text-color-set! editbox-text-color-set?
   toggle toggle-checked? toggle-checked?-set!
   handler-set! handler-remove!
   widgets widget-by-id)

(import chicken scheme foreign)
(use extras data-structures lolevel
     srfi-1 srfi-4 srfi-69
     clojurian-syntax matchable)

;; TODO: megawidget example?

;;; headers

#>
#include "KW_gui.h"
#include "KW_rect.h"
#include "KW_frame.h"
#include "KW_scrollbox.h"
#include "KW_label.h"
#include "KW_button.h"
#include "KW_editbox.h"
#include "KW_toggle.h"
#include "KW_widget.h"
#include "KW_renderdriver_sdl2.h"
<#

;;; foreign values

;; KW_label.h

;; enum KW_LabelVerticalAlignment
(define KW_LABEL_ALIGN_TOP (foreign-value "KW_LABEL_ALIGN_TOP" int))
(define KW_LABEL_ALIGN_MIDDLE (foreign-value "KW_LABEL_ALIGN_MIDDLE" int))
(define KW_LABEL_ALIGN_BOTTOM (foreign-value "KW_LABEL_ALIGN_BOTTOM" int))

;; enum KW_LabelHorizontalAlignment
(define KW_LABEL_ALIGN_LEFT (foreign-value "KW_LABEL_ALIGN_LEFT" int))
(define KW_LABEL_ALIGN_CENTER (foreign-value "KW_LABEL_ALIGN_CENTER" int))
(define KW_LABEL_ALIGN_RIGHT (foreign-value "KW_LABEL_ALIGN_RIGHT" int))

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
(define-foreign-type KW_Rect* (nonnull-c-pointer (struct "KW_Rect")))
(define-foreign-type KW_Color* (nonnull-c-pointer (struct "KW_Color")))
(define-foreign-type int* (nonnull-c-pointer int))
(define-foreign-type unsigned-int* (nonnull-c-pointer unsigned-int))

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
(define KW_GetTextColor (foreign-lambda* void ((KW_GUI* gui) (KW_Color* out)) "KW_Color c = KW_GetTextColor(gui); out->r = c.r, out->g = c.g, out->b = c.b, out->a = c.a;"))
(define KW_SetTextColor (foreign-lambda* void ((KW_GUI* gui) (KW_Color* c)) "KW_SetTextColor(gui, *c);"))
;; NOTE: seems too obscure to support, would require non-widget event handlers
;; (define KW_AddGUIFontChangedHandler)
;; (define KW_RemoveGUIFontChangedHandler)
;; (define KW_AddGUITextColorChangedHandler)
;; (define KW_RemoveGUITextColorChangedHandler)

;; KW_renderdriver.h
(define KW_LoadFont (foreign-lambda KW_Font* "KW_LoadFont" KW_RenderDriver* nonnull-c-string unsigned-int))
;; NOTE: not worth supporting either
;; (define KW_LoadFontFromMemory)
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
(define KW_CreateFrame (foreign-lambda KW_Widget* "KW_CreateFrame" KW_GUI* KW_Widget*-or-null KW_Rect*))

;; KW_scrollbox.h
(define KW_CreateScrollbox (foreign-lambda KW_Widget* "KW_CreateScrollbox" KW_GUI* KW_Widget*-or-null KW_Rect*))
(define KW_ScrollboxHorizontalScroll (foreign-lambda void "KW_ScrollboxHorizontalScroll" KW_Widget* int))
(define KW_ScrollboxVerticalScroll (foreign-lambda void "KW_ScrollboxVerticalScroll" KW_Widget* int))

;; KW_label.h
(define KW_CreateLabel (foreign-lambda KW_Widget* "KW_CreateLabel" KW_GUI* KW_Widget*-or-null nonnull-c-string KW_Rect*))
(define KW_SetLabelText (foreign-lambda void "KW_SetLabelText" KW_Widget* nonnull-c-string))
(define KW_SetLabelAlignment (foreign-lambda void "KW_SetLabelAlignment" KW_Widget* (enum "KW_LabelHorizontalAlignment") int (enum "KW_LabelVerticalAlignment") int))
(define KW_SetLabelStyle (foreign-lambda void "KW_SetLabelStyle" KW_Widget* (enum "KW_RenderDriver_TextStyle")))
(define KW_SetLabelIcon (foreign-lambda void "KW_SetLabelIcon" KW_Widget* KW_Rect*))
(define KW_GetLabelFont (foreign-lambda KW_Font* "KW_GetLabelFont" KW_Widget*))
(define KW_SetLabelFont (foreign-lambda void "KW_SetLabelFont" KW_Widget* KW_Font*))
(define KW_GetLabelTextColor (foreign-lambda* void ((KW_Widget* widget) (KW_Color* out)) "KW_Color c = KW_GetLabelTextColor(widget); out->r = c.r, out->g = c.g, out->b = c.b, out->a = c.a;"))
(define KW_SetLabelTextColor (foreign-lambda* void ((KW_Widget* label) (KW_Color* c)) "KW_SetLabelTextColor(label, *c);"))
(define KW_WasLabelTextColorSet (foreign-lambda bool "KW_WasLabelTextColorSet" KW_Widget*))

;; KW_button.h
(define KW_CreateButton (foreign-lambda KW_Widget* "KW_CreateButton" KW_GUI* KW_Widget*-or-null KW_Widget*-or-null KW_Rect*))
;; (define KW_CreateButtonAndLabel (foreign-lambda KW_Widget* "KW_CreateButtonAndLabel" KW_GUI* KW_Widget*-or-null nonnull-c-string KW_Rect*))
(define KW_GetButtonLabel (foreign-lambda KW_Widget* "KW_GetButtonLabel" KW_Widget*))
(define KW_SetButtonLabel (foreign-lambda KW_Widget* "KW_SetButtonLabel" KW_Widget* KW_Widget*))

;; KW_editbox.h
(define KW_CreateEditbox (foreign-lambda KW_Widget* "KW_CreateEditbox" KW_GUI* KW_Widget*-or-null nonnull-c-string KW_Rect*))
(define KW_GetEditboxText (foreign-lambda c-string "KW_GetEditboxText" KW_Widget*))
(define KW_SetEditboxText (foreign-lambda void "KW_SetEditboxText" KW_Widget* nonnull-c-string))
(define KW_GetEditboxCursorPosition (foreign-lambda unsigned-int "KW_GetEditboxCursorPosition" KW_Widget*))
(define KW_SetEditboxCursorPosition (foreign-lambda void "KW_SetEditboxCursorPosition" KW_Widget* unsigned-int))
(define KW_GetEditboxFont (foreign-lambda KW_Font* "KW_GetEditboxFont" KW_Widget*))
(define KW_SetEditboxFont (foreign-lambda void "KW_SetEditboxFont" KW_Widget* KW_Font*))
(define KW_GetEditboxTextColor (foreign-lambda* void ((KW_Widget* editbox) (KW_Color* out)) "KW_Color c = KW_GetEditboxTextColor(editbox); out->r = c.r, out->g = c.g, out->b = c.b, out->a = c.a;"))
(define KW_SetEditboxTextColor (foreign-lambda* void ((KW_Widget* editbox) (KW_Color* c)) "KW_SetEditboxTextColor(editbox, *c);"))
(define KW_WasEditboxTextColorSet (foreign-lambda bool "KW_WasEditboxTextColorSet" KW_Widget*))

(define KW_CreateToggle (foreign-lambda KW_Widget* "KW_CreateToggle" KW_GUI* KW_Widget*-or-null KW_Rect*))
(define KW_IsToggleChecked (foreign-lambda bool "KW_IsToggleChecked" KW_Widget*))
(define KW_SetToggleChecked (foreign-lambda void "KW_SetToggleChecked" KW_Widget* bool))

;; KW_widget.h
;; NOTE: this requires integrating callbacks for paint/destroy
;; operations and the undocumented renderdriver functions, too
;; (define KW_CreateWidget)
(define KW_GetWidgetGUI (foreign-lambda KW_GUI* "KW_GetWidgetGUI" KW_Widget*))
(define KW_GetWidgetRenderer (foreign-lambda KW_RenderDriver* "KW_GetWidgetRenderer" KW_Widget*))
(define KW_GetWidgetTilesetSurface (foreign-lambda KW_Surface* "KW_GetWidgetTilesetSurface" KW_Widget*))
(define KW_SetWidgetTilesetSurface (foreign-lambda void "KW_SetWidgetTilesetSurface" KW_Widget* KW_Surface*))
(define KW_ReparentWidget (foreign-lambda void "KW_ReparentWidget" KW_Widget* KW_Widget*-or-null))
(define KW_GetWidgetParent (foreign-lambda KW_Widget*-or-null "KW_GetWidgetParent" KW_Widget*))
(define KW_GetWidgetChildren (foreign-lambda c-pointer "KW_GetWidgetChildren" KW_Widget* unsigned-int*))
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
(define KW_GetWidgetGeometry (foreign-lambda void "KW_GetWidgetGeometry" KW_Widget* KW_Rect*))
(define KW_GetWidgetAbsoluteGeometry (foreign-lambda void "KW_GetWidgetAbsoluteGeometry" KW_Widget* KW_Rect*))
(define KW_GetWidgetComposedGeometry (foreign-lambda void "KW_GetWidgetComposedGeometry" KW_Widget* KW_Rect*))
(define KW_SetWidgetGeometry (foreign-lambda void "KW_SetWidgetGeometry" KW_Widget* KW_Rect*))
;; (define KW_GetWidgetTilesetTexture)
;; TODO: KW_IsCursorOverWidget KW_IsCursorPressedOnWidget KW_IsCursorReleasedOnWidget

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

(define (format-pointer pointer)
  (if pointer
      (sprintf "0x~x" (pointer->address pointer))
      "NULL"))

(define-record driver pointer)
(define-record-printer (driver d out)
  (fprintf out "#<driver: ~a>" (format-pointer (driver-pointer d))))

(define-record surface pointer)
(define-record-printer (surface s out)
  (fprintf out "#<surface: ~a>" (format-pointer (surface-pointer s))))

(define-record font pointer)
(define-record-printer (font f out)
  (fprintf out "#<font: ~a>" (format-pointer (font-pointer f))))

(define-record gui pointer)
(define-record-printer (gui g out)
  (fprintf out "#<gui: ~a>" (format-pointer (gui-pointer g))))

(define-record widget handlers type id pointer)
(define-record-printer (widget w out)
  (fprintf out "#<~a: ~a>" (widget-type w) (format-pointer (widget-pointer w))))

(define-record rect storage)
(define-record-printer (rect r out)
  (fprintf out "#<rect: ~a|~a ~ax~a>"
           (rect-x r) (rect-y r) (rect-w r) (rect-h r)))

(define-record color storage)
(define-record-printer (color c out)
  (fprintf out "#<color: ~a|~a|~a|~a>"
           (color-r c) (color-g c) (color-b c) (color-a c)))

;;; generic handlers

(define (dispatch-event! widget* type #!rest args)
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

(define (define-error location message #!rest condition)
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
    (KW_RenderDriverGetSDL2Renderer driver*)))

(define (driver-sdl2-window driver)
  (and-let* ((driver* (driver-pointer driver)))
    (KW_RenderDriverGetSDL2Window driver*)))

(define (load-surface driver filename)
  (and-let* ((driver* (driver-pointer driver)))
    (if-let (surface* (KW_LoadSurface driver* filename))
      (set-finalizer! (make-surface surface*)
                      (cut release-surface! driver <>))
      ;; TODO: the actual error appears twice, fix error printing upstream
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
      ;; TODO: the actual error appears twice, fix error printing upstream
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
    (let* ((color (color 0 0 0 0))
           (color* (color-pointer color)))
      (KW_GetTextColor gui* color*)
      color)))

(define (gui-text-color-set! gui color)
  (and-let* ((gui* (gui-pointer gui))
             (color* (color-pointer color)))
    (KW_SetTextColor gui* color*)))

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

(define (rect-pointer rect)
  (make-locative (rect-storage rect)))

(define KW_Rect-size (foreign-type-size (struct "KW_Rect")))

(define (rect x y w h)
  (let* ((rect (make-rect (make-blob KW_Rect-size)))
         (rect* (rect-pointer rect)))
    ((foreign-lambda* void ((KW_Rect* r) (int x) (int y) (int w) (int h))
       "r->x = x, r->y = y, r->w = w, r->h = h;")
     rect* x y w h)
    rect))

(define (rect-x rect)
  (let ((rect* (rect-pointer rect)))
    ((foreign-lambda* int ((KW_Rect* r)) "C_return(r->x);") rect*)))

(define (rect-x-set! rect x)
  (let ((rect* (rect-pointer rect)))
    ((foreign-lambda* void ((KW_Rect* r) (int x)) "r->x = x;") rect* x)))

(define rect-x (getter-with-setter rect-x rect-x-set!))

(define (rect-y rect)
  (let ((rect* (rect-pointer rect)))
    ((foreign-lambda* int ((KW_Rect* r)) "C_return(r->y);") rect*)))

(define (rect-y-set! rect y)
  (let ((rect* (rect-pointer rect)))
    ((foreign-lambda* void ((KW_Rect* r) (int y)) "r->y = y;") rect* y)))

(define rect-y (getter-with-setter rect-y rect-y-set!))

(define (rect-w rect)
  (let ((rect* (rect-pointer rect)))
    ((foreign-lambda* int ((KW_Rect* r)) "C_return(r->w);") rect*)))

(define (rect-w-set! rect w)
  (let ((rect* (rect-pointer rect)))
    ((foreign-lambda* void ((KW_Rect* r) (int w)) "r->w = w;") rect* w)))

(define rect-w (getter-with-setter rect-w rect-w-set!))

(define (rect-h rect)
  (let ((rect* (rect-pointer rect)))
    ((foreign-lambda* int ((KW_Rect* r)) "C_return(r->h);") rect*)))

(define (rect-h-set! rect h)
  (let ((rect* (rect-pointer rect)))
    ((foreign-lambda* void ((KW_Rect* r) (int h)) "r->h = h;") rect* h)))

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

(define (rect-center-in-parent-vertically! parent inner)
  (set! (rect-y inner) (- (/ (rect-h parent) 2) (/ (rect-h inner) 2))))

(define (rect-center-in-parent-horizontally! parent inner)
  (set! (rect-x inner) (- (/ (rect-w parent) 2) (/ (rect-w inner) 2))))

(define (rect-center-in-parent! parent inner)
  (rect-center-in-parent-vertically! parent inner)
  (rect-center-in-parent-horizontally! parent inner))

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

(define (rect-margin! parent inner margin)
  (set! (rect-x inner) margin)
  (set! (rect-y inner) margin)
  (set! (rect-w inner) (- (rect-w parent) (* 2 margin)))
  (set! (rect-h inner) (- (rect-h parent) (* 2 margin))))

;;; colors

(define (color-pointer color)
  (make-locative (color-storage color)))

(define KW_Color-size (foreign-type-size (struct "KW_Color")))

(define (color r g b a)
  (let* ((color (make-color (make-blob KW_Color-size)))
         (color* (color-pointer color)))
    ((foreign-lambda* void ((KW_Color* c) (unsigned-byte r) (unsigned-byte g) (unsigned-byte b) (unsigned-byte a))
       "c->r = r, c->g = g, c->b = b, c->a = a;")
     color* r g b a)
    color))

(define (color-r color)
  (let ((color* (color-pointer color)))
    ((foreign-lambda* unsigned-byte ((KW_Color* c)) "C_return(c->r);") color*)))

(define (color-r-set! color r)
  (let ((color* (color-pointer color)))
    ((foreign-lambda* void ((KW_Color* c) (unsigned-byte r)) "c->r = r;") color* r)))

(define color-r (getter-with-setter color-r color-r-set!))

(define (color-g color)
  (let ((color* (color-pointer color)))
    ((foreign-lambda* unsigned-byte ((KW_Color* c)) "C_return(c->g);") color*)))

(define (color-g-set! color g)
  (let ((color* (color-pointer color)))
    ((foreign-lambda* void ((KW_Color* c) (unsigned-byte g)) "c->g = g;") color* g)))

(define color-g (getter-with-setter color-g color-g-set!))

(define (color-b color)
  (let ((color* (color-pointer color)))
    ((foreign-lambda* unsigned-byte ((KW_Color* c)) "C_return(c->b);") color*)))

(define (color-b-set! color b)
  (let ((color* (color-pointer color)))
    ((foreign-lambda* void ((KW_Color* c) (unsigned-byte b)) "c->b = b;") color* b)))

(define color-b (getter-with-setter color-b color-b-set!))

(define (color-a color)
  (let ((color* (color-pointer color)))
    ((foreign-lambda* unsigned-byte ((KW_Color* c)) "C_return(c->a);") color*)))

(define (color-a-set! color a)
  (let ((color* (color-pointer color)))
    ((foreign-lambda* void ((KW_Color* c) (unsigned-byte a)) "c->a = a;") color* a)))

(define color-a (getter-with-setter color-a color-a-set!))

;;; widgets

;; NOTE: even if the getter (or setter) is missing for a property,
;; one could implement a stub and use getter-with-setter on both, then
;; report an upstream bug later

(define widget-table (make-hash-table))

(define (widget-by-id id)
  (find
   (lambda (widget) (eqv? (widget-id widget) id))
   (hash-table-values widget-table)))

(define (define-widget type gui parent geometry proc)
  (and-let* ((gui* (gui-pointer gui)))
    (let ((parent* (and parent (widget-pointer parent)))
          (geometry* (rect-pointer geometry)))
      (if-let (widget* (proc gui* parent* geometry*))
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

(define (reparent-widget! widget parent)
  (and-let* ((widget* (widget-pointer widget)))
    (let ((parent* (and parent (widget-pointer parent))))
      (KW_ReparentWidget widget* parent*))))

(define (bring-widget-to-front! widget)
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

(define (widget-tileset-surface widget)
  (and-let* ((widget* (widget-pointer widget)))
    (make-surface (KW_GetWidgetTilesetSurface widget*))))

(define (widget-tileset-surface-set! widget tileset)
  (and-let* ((widget* (widget-pointer widget))
             (tileset* (surface-pointer tileset)))
    (KW_SetWidgetTilesetSurface widget* tileset*)))

(define widget-tileset-surface (getter-with-setter widget-tileset-surface widget-tileset-surface-set!))

(define (widget-text-color widget proc)
  (and-let* ((widget* (widget-pointer widget))
             (color (make-color (make-blob KW_Color-size)))
             (color* (color-pointer color)))
    (proc widget* color*)
    color))

(define (widget-text-color-set! widget proc color)
  (and-let* ((widget* (widget-pointer widget))
             (color* (color-pointer color)))
    (proc widget* color*)))

(define (widget-text-color-set? widget proc)
  (and-let* ((widget* (widget-pointer widget)))
    (proc widget*)))

(define (%widget-geometry widget proc)
  (and-let* ((widget* (widget-pointer widget))
             (geometry (rect 0 0 0 0))
             (geometry* (rect-pointer geometry)))
    (proc widget* geometry*)
    geometry))

(define (widget-absolute-geometry widget)
  (%widget-geometry widget KW_GetWidgetAbsoluteGeometry))

(define (widget-composed-geometry widget)
  (%widget-geometry widget KW_GetWidgetComposedGeometry))

(define (widget-geometry widget)
  (%widget-geometry widget KW_GetWidgetGeometry))

(define (widget-geometry-set! widget geometry)
  (and-let* ((widget* (widget-pointer widget))
             (geometry* (rect-pointer geometry)))
    (KW_SetWidgetGeometry widget* geometry*)))

(define widget-geometry (getter-with-setter widget-geometry widget-geometry-set!))

(define (widget-center-with-rect-proc! parent inner proc)
  (let ((parent-geometry (widget-geometry parent))
        (inner-geometry (widget-geometry inner)))
    (proc parent-geometry inner-geometry)
    (widget-geometry-set! inner inner-geometry)))

(define (widget-center-in-parent-vertically! parent inner)
  (widget-center-with-rect-proc! parent inner rect-center-in-parent-vertically!))

(define (widget-center-in-parent-horizontally! parent inner)
  (widget-center-with-rect-proc! parent inner rect-center-in-parent-horizontally!))

(define (widget-center-in-parent! parent inner)
  (widget-center-with-rect-proc! parent inner rect-center-in-parent!))

(define (widget-alter-geometries! widgets proc)
  (let ((rects (map widget-geometry widgets)))
    (proc rects)
    (for-each widget-geometry-set! widgets rects)))

(define (widget-layout-vertically! widgets padding #!optional halign)
  (widget-alter-geometries! widgets (cut rect-layout-vertically!
                                         <> padding halign)))

(define (widget-layout-horizontally! widgets padding #!optional valign)
  (widget-alter-geometries! widgets (cut rect-layout-horizontally!
                                         <> padding valign)))

(define (widget-fill-parent-vertically! parent children weights padding)
  (widget-alter-geometries! children (cut rect-fill-parent-vertically!
                                          (widget-geometry parent)
                                          <> weights padding)))

(define (widget-fill-parent-horizontally! parent children weights padding valign)
  (widget-alter-geometries! children (cut rect-fill-parent-horizontally!
                                          (widget-geometry parent)
                                          <> weights padding valign)))

(define (widget-margin! parent inner margin)
  (let ((parent-geometry (widget-geometry parent))
        (inner-geometry (widget-geometry inner)))
    (rect-margin! parent-geometry inner-geometry margin)
    (widget-geometry-set! inner inner-geometry)))

;; frame

(define (frame gui parent geometry)
  (define-widget 'frame gui parent geometry KW_CreateFrame))

(define (frame? arg)
  (and (widget? arg) (eqv? (widget-type arg) 'frame)))

;; scrollbox

(define (scrollbox gui parent geometry)
  (define-widget 'scrollbox gui parent geometry KW_CreateScrollbox))

(define (scrollbox? arg)
  (and (widget? arg) (eqv? (widget-type arg) 'scrollbox)))

(define (scrollbox-vertical-scroll! scrollbox amount)
  (and-let* ((scrollbox* (widget-pointer scrollbox)))
    (KW_ScrollboxVerticalScroll scrollbox* amount)))

(define (scrollbox-horizontal-scroll! scrollbox amount)
  (and-let* ((scrollbox* (widget-pointer scrollbox)))
    (KW_ScrollboxHorizontalScroll scrollbox* amount)))

;; label

(define (label gui parent text geometry)
  (define-widget 'label gui parent geometry
    (cut KW_CreateLabel <> <> text <>)))

(define (label? arg)
  (and (widget? arg) (eqv? (widget-type arg) 'label)))

(define (label-text-set! label text)
  (and-let* ((label* (widget-pointer label)))
    (KW_SetLabelText label* text)))

(define (label-icon-set! label clip)
  (and-let* ((label* (widget-pointer label)))
    (let ((clip* (rect-pointer clip)))
      (KW_SetLabelIcon label* clip*))))

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

;; NOTE: this doesn't use KW_CreateButtonAndLabel to track the label
(define (button gui parent text geometry)
  (let* ((label (label gui #f text geometry))
         (label* (widget-pointer label)))
    (define-widget 'button gui parent geometry
      (cut KW_CreateButton <> <> label* <>))))

(define (button* gui parent label geometry)
  (let ((label* (and label (widget-pointer label))))
    (define-widget 'button gui parent geometry
      (cut KW_CreateButton <> <> label* <>))))

(define (button? arg)
  (and (widget? arg) (eqv? (widget-type arg) 'button)))

(define (button-label button)
  (and-let* ((button* (widget-pointer button))
             (label* (KW_GetButtonLabel button*)))
    (hash-table-ref widget-table label*)))

(define (button-label-set! button label)
  (and-let* ((button* (widget-pointer button))
             (label* (widget-pointer label))
             (old-label* (KW_SetButtonLabel button* label*)))
    (hash-table-ref widget-table old-label*)))

(define button-label (getter-with-setter button-label button-label-set!))

;; editbox

(define (editbox gui parent text geometry)
  (define-widget 'editbox gui parent geometry
    (cut KW_CreateEditbox <> <> text <>)))

(define (editbox? arg)
  (and (widget? arg) (eqv? (widget-type arg) 'editbox)))

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

;; toggle

(define (toggle gui parent geometry)
  (define-widget 'toggle gui parent geometry KW_CreateToggle))

(define (toggle-checked? toggle)
  (and-let* ((toggle* (widget-pointer toggle)))
    (KW_IsToggleChecked toggle*)))

(define (toggle-checked?-set! toggle checked?)
  (and-let* ((toggle* (widget-pointer toggle)))
    (KW_SetToggleChecked toggle* checked?)))

(define toggle-checked? (getter-with-setter toggle-checked? toggle-checked?-set!))

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
             (button gui parent text geometry))
            ((editbox)
             (let ((widget (editbox gui parent text geometry)))
               (and-let* ((position (alist-ref 'cursor-position attributes)))
                 (editbox-cursor-position-set! widget position))
               (and-let* ((font (alist-ref 'font attributes)))
                 (editbox-font-set! widget font))
               (and-let* ((color (alist-ref 'color attributes)))
                 (editbox-text-color-set! widget color))
               widget))
            ((toggle)
             (let ((widget (toggle gui parent geometry)))
               (and-let* ((checked? (alist-ref 'checked? attributes)))
                 (toggle-checked?-set! toggle checked?))
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
