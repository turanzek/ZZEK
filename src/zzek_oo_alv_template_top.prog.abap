TABLES: mara,makt.

************************************************************************
* TYPE POOLS                                                           *
************************************************************************
TYPE-POOLS: slis, icon.
DATA: gv_okcode TYPE sy-ucomm.
*--------------------------------------------------------------------*
************************************************************************
*SELECTION SCREENS                                                     *
************************************************************************
SELECTION-SCREEN FUNCTION KEY 1.
*SELECTION-SCREEN BEGIN OF BLOCK blk0.
*  SELECTION-SCREEN BEGIN OF LINE.
*    SELECTION-SCREEN PUSHBUTTON  2(30) TEXT-005 USER-COMMAND bt1.
*  SELECTION-SCREEN END OF LINE.
*SELECTION-SCREEN END OF BLOCK blk0.

SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE TEXT-h01.

  SELECT-OPTIONS: s_matnr FOR mara-matnr.
  PARAMETERS: p_tesl  RADIOBUTTON GROUP rbg1 DEFAULT 'X',
              p_tesl2 RADIOBUTTON GROUP rbg1.
SELECTION-SCREEN END OF BLOCK blk1.

*--------------------------------------------------------------------*
FIELD-SYMBOLS: <fs_data> TYPE ANY TABLE.
***Data definiton for display ALV
DATA:gs_mara TYPE mara.
DATA:gt_mara LIKE TABLE OF gs_mara." WITH HEADER LINE.
DATA:gs_makt TYPE makt.
DATA:gt_makt LIKE TABLE OF gs_makt." WITH HEADER LINE.
DATA: gv_flag.

"STRUCTUREDAN WİTH HEADER LİNE İLE AL.
DATA:gs_row_no TYPE lvc_s_roid,
     gt_row_no TYPE lvc_t_roid.
"STRUCTUREDAN WİTH HEADER LİNE İLE AL.
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
***popup message,
DATA: gs_message  LIKE bapiret2.
DATA: gt_message  LIKE TABLE OF gs_message.
*--------------------------------------------------------------------*

*>*ALV Tanımlamaları
CLASS : lcl_alv     DEFINITION DEFERRED.
DATA  : gcl_evt_rec TYPE REF TO lcl_alv.
DATA  : gcl_alv     TYPE REF TO lcl_alv,
        gcl_grid    TYPE REF TO cl_gui_alv_grid,
        gcl_con     TYPE REF TO cl_gui_custom_container,
        gcl_docking TYPE REF TO cl_gui_docking_container.
DATA  : it_fieldcat TYPE slis_t_fieldcat_alv.
DATA  : gt_fcat     TYPE lvc_t_fcat.
DATA  : gs_fcat     TYPE lvc_t_fcat.
DATA  : gs_layo     TYPE lvc_s_layo.
DATA  : gs_vari     TYPE disvariant.
DATA  : gs_stbl     TYPE lvc_s_stbl.
DATA  : gs_soft_ref TYPE char1 VALUE 'X'.
DATA  : gv_declaration_no TYPE char20.
DATA  : gt_drop TYPE lvc_t_drop.



DATA: fm_name         TYPE rs38l_fnam,
      fp_docparams    TYPE sfpdocparams,
      fp_outputparams TYPE sfpoutputparams,
      formname        TYPE fpname,
      fp_formoutput   TYPE fpformoutput.
