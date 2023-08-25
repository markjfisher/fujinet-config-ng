#ifndef FN_POPUP_H
#define FN_POPUP_H

struct PopupItem {
    unsigned char type;
    unsigned char num;
    unsigned char len;
    unsigned char val;
    unsigned short text;
    unsigned short spc;
};

enum PopupItemType {
    textList,
    option,
    // select
    // checkbox
    // button
    space,
    finish
};

enum PopupItemReturn {
    escape,
    complete,
    redisplay
};

enum PopupHandleKBEvent {
    no,
    self,
    other
};

#endif /* FN_POPUP_H */