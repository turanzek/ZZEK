*&---------------------------------------------------------------------*
*& Report ZZEK_SCRAMBLE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZZEK_SCRAMBLE.
TABLES sscrfields.
*--------------------------------------------------------------*
* Selection-Screen
*--------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF LINE.
SELECTION-SCREEN: PUSHBUTTON 2(5)  btn1 USER-COMMAND btn1.
SELECTION-SCREEN: PUSHBUTTON 8(5)  btn2 USER-COMMAND btn2.
SELECTION-SCREEN: PUSHBUTTON 14(5) btn3 USER-COMMAND btn3.
SELECTION-SCREEN: END OF LINE.
SELECTION-SCREEN: BEGIN OF LINE.
SELECTION-SCREEN: PUSHBUTTON 2(5)  btn4 USER-COMMAND btn4.
SELECTION-SCREEN: PUSHBUTTON 8(5)  btn5 USER-COMMAND btn5.
SELECTION-SCREEN: PUSHBUTTON 14(5) btn6 USER-COMMAND btn6.
SELECTION-SCREEN: END OF LINE.
SELECTION-SCREEN: BEGIN OF LINE.
SELECTION-SCREEN: PUSHBUTTON 2(5)  btn7 USER-COMMAND btn7.
SELECTION-SCREEN: PUSHBUTTON 8(5)  btn8 USER-COMMAND btn8.
SELECTION-SCREEN: PUSHBUTTON 14(5) btn9 USER-COMMAND btn9.
SELECTION-SCREEN: END OF LINE.
SELECTION-SCREEN: SKIP 2.
SELECTION-SCREEN: PUSHBUTTON 2(17) random USER-COMMAND rand.
*--------------------------------------------------------------*
*At Selection-Screen Output
*--------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM win.
*--------------------------------------------------------------*
*At Selection-Screen
*--------------------------------------------------------------*
AT SELECTION-SCREEN.
  CASE sscrfields.
    WHEN 'BTN1'.
      PERFORM check_button CHANGING btn1 btn2.
      PERFORM check_button CHANGING btn1 btn4.
    WHEN 'BTN2'.
      PERFORM check_button CHANGING btn2 btn1.
      PERFORM check_button CHANGING btn2 btn3.
      PERFORM check_button CHANGING btn2 btn5.
    WHEN 'BTN3'.
      PERFORM check_button CHANGING btn3 btn2.
      PERFORM check_button CHANGING btn3 btn6.
    WHEN 'BTN4'.
      PERFORM check_button CHANGING btn4 btn1.
      PERFORM check_button CHANGING btn4 btn5.
      PERFORM check_button CHANGING btn4 btn7.
    WHEN 'BTN5'.
      PERFORM check_button CHANGING btn5 btn2.
      PERFORM check_button CHANGING btn5 btn6.
      PERFORM check_button CHANGING btn5 btn8.
      PERFORM check_button CHANGING btn5 btn4.
    WHEN 'BTN6'.
      PERFORM check_button CHANGING btn6 btn3.
      PERFORM check_button CHANGING btn6 btn5.
      PERFORM check_button CHANGING btn6 btn9.
    WHEN 'BTN7'.
      PERFORM check_button CHANGING btn7 btn4.
      PERFORM check_button CHANGING btn7 btn8.
    WHEN 'BTN8'.
      PERFORM check_button CHANGING btn8 btn7.
      PERFORM check_button CHANGING btn8 btn5.
      PERFORM check_button CHANGING btn8 btn9.
    WHEN 'BTN9'.
      PERFORM check_button CHANGING btn9 btn6.
      PERFORM check_button CHANGING btn9 btn8.
    WHEN 'RAND'.
      PERFORM random.
  ENDCASE.
*&---------------------------------------------------------------------*
*& INITIALIZATION.
*&---------------------------------------------------------------------*
INITIALIZATION.
  random = 'Reset'.
  PERFORM random.
*&---------------------------------------------------------------------*
*&      Form  CHECK_BUTTON
*&---------------------------------------------------------------------*
FORM check_button  CHANGING p_b1
                            p_b2.
  IF p_b2 IS INITIAL.
    p_b2 = p_b1.
    CLEAR p_b1.
  ENDIF.
ENDFORM.                    " CHECK_BUTTON
*&---------------------------------------------------------------------*
*&      Form  RANDOM
*&---------------------------------------------------------------------*
FORM random.

  DATA: it TYPE TABLE OF c.
  DATA: wa TYPE c.
  DATA: lv_random TYPE qf00-ran_int.
  DATA: temp.
  DATA: lv_counter TYPE i.
  CONSTANTS: lv_btn(3) TYPE c VALUE 'BTN'.
  DATA: lv_button(4) TYPE c.
  FIELD-SYMBOLS: <fs> TYPE c.

  DO.
    CALL FUNCTION 'QF05_RANDOM_INTEGER'
      EXPORTING
        ran_int_max   = 9
        ran_int_min   = 1
      IMPORTING
        ran_int       = lv_random
      EXCEPTIONS
        invalid_input = 1
        OTHERS        = 2.

    wa = lv_random.
    READ TABLE it TRANSPORTING NO FIELDS
               WITH KEY wa.
    IF sy-subrc <> 0.
      APPEND wa TO it.
    ENDIF.

    lv_counter = LINES( it ).
    IF lv_counter = 9.
      EXIT.
    ENDIF.

  ENDDO.

  LOOP AT it INTO wa.
    temp = sy-tabix.
    CONCATENATE lv_btn temp INTO lv_button.
    ASSIGN (lv_button) TO <fs>.
    IF wa = '9'.
      CLEAR wa.
    ENDIF.
     <fs> = wa.
    CLEAR wa.
  ENDLOOP.
ENDFORM.                    " RANDOM
*&---------------------------------------------------------------------*
*&      Form  WIN
*&---------------------------------------------------------------------*
FORM win .
  IF btn1 = '1' AND
     btn2 = '2' AND
     btn3 = '3' AND
     btn4 = '4' AND
     btn5 = '5' AND
     btn6 = '6' AND
     btn7 = '7' AND
     btn8 = '8' AND
     btn9 IS INITIAL.
    MESSAGE 'You Won!' TYPE 'I'.
    PERFORM random.
  ENDIF.
ENDFORM.                    " WIN
