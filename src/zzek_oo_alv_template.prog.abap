*&---------------------------------------------------------------------*
*& Report ZZEK_OO_ALV_TEMPLATE
*&---------------------------------------------------------------------*
* Project           : OO ALV Sablon
*----------------------------------------------------------------------*
* Program           : ZZEK_OO_ALV_TEMPLATE
* Development ID    :
* Jira ID           :
* Module            :
* Module Consultant :
* ABAP Consultant   : Zekeriya Turan -
* Date              :
* ———————————————————————–———–———–———–
* Title             : OO ALV Sablon
* Description       : OO ALV Sablon
*&---------------------------------------------------------------------*
REPORT ZZEK_OO_ALV_TEMPLATE.

INCLUDE ZZEK_OO_ALV_TEMPLATE_top.
INCLUDE ZZEK_OO_ALV_TEMPLATE_cls.
INCLUDE ZZEK_OO_ALV_TEMPLATE_f01.
INCLUDE ZZEK_OO_ALV_TEMPLATE_pbo.
INCLUDE ZZEK_OO_ALV_TEMPLATE_pai.



*----------------------------------------------------------------------*
*INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
*  MOVE 'Seçim Ektanını Temizle' TO sscrfields-functxt_01.
  CREATE OBJECT gcl_alv TYPE lcl_alv.
*----------------------------------------------------------------------*
*AT SELECTION-SCREEN.
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
*  CASE sy-ucomm.
*    WHEN 'FC01'.
*      CLEAR: so_palet,so_charg,so_vbeln,so_matnr,
*             so_palet[],so_charg[],so_vbeln[],so_matnr[].
*    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
*      PERFORM free.
*      LEAVE PROGRAM.
*    WHEN 'ONLI'.
*      IF so_palet[] IS INITIAL AND so_vbeln IS INITIAL.
*        IF ( so_matnr[] IS INITIAL AND so_charg IS NOT INITIAL )
*        OR ( so_matnr[] IS NOT INITIAL AND so_charg IS INITIAL ).
*          MESSAGE e004 DISPLAY LIKE 'S'.
*
*        ELSEIF  so_matnr[] IS INITIAL AND so_charg IS INITIAL.
*          MESSAGE e006 DISPLAY LIKE 'S'.
*        ENDIF.
*      ENDIF.
*  ENDCASE.

*----------------------------------------------------------------------*
*AT SELECTION-SCREEN OUTPUT.
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
*  SET PF-STATUS 'INIT_STATUS'.
*  PERFORM screen_loop.

*----------------------------------------------------------------------*
*START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  CALL METHOD gcl_alv->get_data( ).

*----------------------------------------------------------------------*
*END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.
  CALL METHOD gcl_alv->list_data( ).
