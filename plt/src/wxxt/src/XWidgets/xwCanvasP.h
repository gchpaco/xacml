/* Generated by wbuild
 * (generator version 3.2)
 */
#ifndef ___XWCANVASP_H
#define ___XWCANVASP_H
#include <./xwBoardP.h>
#include <./xwCanvas.h>
_XFUNCPROTOBEGIN

typedef struct {
/* methods */
/* class variables */
int dummy;
} XfwfCanvasClassPart;

typedef struct _XfwfCanvasClassRec {
CoreClassPart core_class;
CompositeClassPart composite_class;
XfwfCommonClassPart xfwfCommon_class;
XfwfFrameClassPart xfwfFrame_class;
XfwfBoardClassPart xfwfBoard_class;
XfwfCanvasClassPart xfwfCanvas_class;
} XfwfCanvasClassRec;

typedef struct {
/* resources */
int  backingStore;
/* private state */
} XfwfCanvasPart;

typedef struct _XfwfCanvasRec {
CorePart core;
CompositePart composite;
XfwfCommonPart xfwfCommon;
XfwfFramePart xfwfFrame;
XfwfBoardPart xfwfBoard;
XfwfCanvasPart xfwfCanvas;
} XfwfCanvasRec;

externalref XfwfCanvasClassRec xfwfCanvasClassRec;

_XFUNCPROTOEND
#endif /* ___XWCANVASP_H */
