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

// see popup.inc for descriptions.
enum PopupItemType {
    finish,
    space,
    textList,
    option,
    text,
    string,
    password,
    number

    // select
    // checkbox
    // button
};

enum PopupItemReturn {
    escape,
    complete,
    redisplay,
    not_handled,
    app_1
};

enum PopupHandleKBEvent {
    no,
    self,
    other
};

#endif /* FN_POPUP_H */