*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
FORM get_data .
IF p_tesl eq 'X'.

  SELECT * FROM mara
    INTO CORRESPONDING FIELDS OF TABLE gt_mara
    UP TO 10 ROWS.
ELSEIF p_tesl2 eq 'X'.
    SELECT * FROM makt
      INTO CORRESPONDING FIELDS OF TABLE gt_makt
      UP TO 10 ROWS.

ENDIF.
ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  LIST_DATA
*&---------------------------------------------------------------------*
FORM list_data .
  CALL SCREEN 0100.
ENDFORM.                    " LIST_DATA
" INIT
*&---------------------------------------------------------------------*
*&      Form  PREPARE_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM prepare_alv .
  DATA:  lv_fcat TYPE  slis_tabname .
  UNASSIGN <fs_data>.
  IF p_tesl EQ 'X'.
    lv_fcat = 'GS_MARA'.
    ASSIGN ('GT_MARA[]') TO <fs_data>.
  ELSEIF p_tesl2 EQ 'X'.
    lv_fcat = 'GS_MAKT'.
    ASSIGN ('Gt_MAKT[]') TO <fs_data>.
  ENDIF.

  IF gcl_con IS INITIAL.
    PERFORM create_container.
    PERFORM create_fcat USING lv_fcat.
    PERFORM set_fcat .
    PERFORM set_layout.
*    PERFORM set_dropdown.
    PERFORM display_alv.
    PERFORM set_handler_events.
  ELSE.
    PERFORM refresh_alv.
  ENDIF.
ENDFORM.                    " PREPARE_ALV
*&---------------------------------------------------------------------*
*&      Form  CREATE_CONTAINER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_container.

  CREATE OBJECT gcl_con
    EXPORTING
      container_name              = 'CON'
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  CREATE OBJECT gcl_grid
    EXPORTING
      i_parent          = gcl_con
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  "bu method edite acık gelmesı ıcın gereklı
  CALL METHOD gcl_grid->set_ready_for_input
    EXPORTING
      i_ready_for_input = 1.

ENDFORM.                    " CREATE_CONTAINER
*&---------------------------------------------------------------------*
*&      Form  CREATE_FCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_fcat USING p_fcat TYPE  slis_tabname .
  CLEAR: gt_fcat,gt_fcat[],it_fieldcat[].
  REFRESH: gt_fcat[].  FREE: gt_fcat[].


  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_internal_tabname     = p_fcat
      i_inclname             = 'ZZEK_OO_ALV_TEMPLATE_TOP'
    CHANGING
      ct_fieldcat            = it_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
  IF p_tesl EQ 'X'.

    CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
      EXPORTING
        it_fieldcat_alv = it_fieldcat
      IMPORTING
        et_fieldcat_lvc = gt_fcat
      TABLES
        it_data         = gt_mara[]
      EXCEPTIONS
        it_data_missing = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

  ELSEIF p_tesl2 EQ 'X'.

    CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
      EXPORTING
        it_fieldcat_alv = it_fieldcat
      IMPORTING
        et_fieldcat_lvc = gt_fcat
      TABLES
        it_data         = gt_makt[]
      EXCEPTIONS
        it_data_missing = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

  ENDIF.


ENDFORM.                    " CREATE_FCAT
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_alv .
  gs_vari-report = sy-repid.
  gs_vari-variant = ''.
*  gs_layo-cwidth_opt = 'X'.
*  gs_layo-zebra = 'X'.
*  gs_layo-stylefname = 'STYLE'.

  CALL METHOD gcl_grid->set_table_for_first_display
    EXPORTING
      is_variant                    = gs_vari
      i_save                        = 'A'
      is_layout                     = gs_layo
    CHANGING
      it_outtab                     = <fs_data>
      it_fieldcatalog               = gt_fcat
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
 gcl_grid->set_ready_for_input(
        i_ready_for_input = 1
    ).
ENDFORM.                    " DISPLAY_ALV
*&---------------------------------------------------------------------*
*&      Form  BUILD_FCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_fcat.
  FIELD-SYMBOLS : <fcat> TYPE lvc_s_fcat.
*  IF gv_okcode EQ 'SIMULATE' OR gv_okcode EQ 'SAVE'.

*  LOOP AT gt_fcat ASSIGNING <fcat>.
*    IF p_tesl EQ 'X'.
*      CASE <fcat>-fieldname.
*        WHEN 'MATNR'.
***        <fcat>-scrtext_l =
*          <fcat>-tech = 'X'.
*        WHEN OTHERS.
*      ENDCASE.
*    ELSEIF p_tesl2 EQ 'X'.
*
*    ENDIF.
*  ENDLOOP.

ENDFORM.                    " BUILD_FCAT
*&---------------------------------------------------------------------*
*&      Form  SET_LAYOUT
*&---------------------------------------------------------------------*
FORM set_layout.
  gs_layo-stylefname = 'STYLE'.
  gs_layo-cwidth_opt = 'X'.

  gs_layo-no_rowins = 'X'.
  gs_layo-no_rowmove = 'X'.

ENDFORM.                    " SET_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  SET_EVENTS
*&---------------------------------------------------------------------*
FORM set_handler_events .
*  CALL METHOD gcl_grid->register_edit_event
*    EXPORTING
*      i_event_id = cl_gui_alv_grid=>mc_evt_modified.
  CREATE OBJECT gcl_evt_rec.
  SET HANDLER gcl_evt_rec->handle_double_click
          FOR gcl_grid.
  SET HANDLER gcl_evt_rec->handle_onf4
          FOR gcl_grid.
  SET HANDLER gcl_evt_rec->handle_data_changed
          FOR gcl_grid.
  SET HANDLER gcl_evt_rec->handle_user_command
          FOR gcl_grid.
  SET HANDLER gcl_evt_rec->handle_toolbar
          FOR gcl_grid.
  SET HANDLER gcl_evt_rec->handle_hotspot_click
          FOR gcl_grid.
  SET HANDLER gcl_evt_rec->handle_data_changed_finished
          FOR gcl_grid.
  SET HANDLER gcl_evt_rec->handle_context_menu_request
          FOR gcl_grid.
  SET HANDLER gcl_evt_rec->handle_menu_button
          FOR gcl_grid.
  CALL METHOD gcl_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.
  CALL METHOD gcl_grid->set_toolbar_interactive.
*  SET HANDLER:
*       gcl_evt_rec->handle_button_click FOR gcl_grid.


ENDFORM.                    " SET_EVENTS
*&---------------------------------------------------------------------*
*&      Form  REFRESH_ALV
*&---------------------------------------------------------------------*
FORM refresh_alv .
  CALL METHOD gcl_grid->refresh_table_display
    EXPORTING
      is_stable      = gs_stbl
      i_soft_refresh = gs_soft_ref
    EXCEPTIONS
      finished       = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " REFRESH_ALV
*&---------------------------------------------------------------------*
*&      Form  FREE
*&---------------------------------------------------------------------*
FORM free .
  IF gcl_grid IS NOT INITIAL.
    CALL METHOD gcl_grid->free
      EXCEPTIONS
        cntl_error        = 1
        cntl_system_error = 2
        OTHERS            = 3.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      FREE gcl_grid.
    ENDIF.
  ENDIF.
  IF gcl_con IS NOT INITIAL.
    CALL METHOD gcl_con->free
      EXCEPTIONS
        cntl_error        = 1
        cntl_system_error = 2
        OTHERS            = 3.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      FREE gcl_con.
    ENDIF.
  ENDIF.
ENDFORM.                    " FREE

*&---------------------------------------------------------------------*
*&      Form  HANDLE_USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM handle_user_command USING e_ucomm TYPE sy-ucomm
                               e_sender TYPE REF TO cl_gui_alv_grid...
  DATA: lv_ucomm LIKE sy-ucomm,
        lv_subrc LIKE sy-subrc.
  DATA: lt_row_no TYPE lvc_t_roid,
        ls_row_no TYPE lvc_s_roid.
  DATA: lv_index TYPE i.
  CALL METHOD gcl_grid->get_selected_rows
    IMPORTING
      et_row_no = lt_row_no.
  CLEAR: gt_row_no[].
  gt_row_no = lt_row_no.


  IF lines( lt_row_no ) < 1.
*    MESSAGE s005 DISPLAY LIKE 'E'.
*    RETURN.
*  ELSEIF lines( lt_row_no ) > 1.
*    MESSAGE s002(zace) DISPLAY LIKE 'E'..
*    RETURN.
  ENDIF.

  "bu alv nın ustundekı ekledıgımız butonların dustugu method
  CASE e_ucomm.

    WHEN 'PRINT'.
*      CLEAR:gv_flag.
*      PERFORM print_control TABLES lt_row_no CHANGING gv_flag.
*      IF gv_flag EQ 'X'.
*        MESSAGE s003 DISPLAY LIKE 'E'..
*      ELSE.
*        DO pa_sayi TIMES.
*          PERFORM print TABLES lt_row_no USING e_ucomm.
**        PERFORM output.
*        ENDDO.
*      ENDIF.
    WHEN 'PREVIEW'.
*      PERFORM print TABLES lt_row_no USING e_ucomm.

    WHEN OTHERS.
  ENDCASE.
  PERFORM refresh_alv.
ENDFORM.                    " HANDLE_USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  HANDLE_TOOLBAR
*&---------------------------------------------------------------------*
*       text  LAYOUTUN ÜSTÜNDEKİ TOOLBARLARI DEĞİŞTİREBİLMEMİZİ SAĞLAR.
*----------------------------------------------------------------------*
FORM handle_toolbar  USING e_object TYPE REF TO cl_alv_event_toolbar_set
                           e_sender TYPE REF TO cl_gui_alv_grid.

 DATA  : lt_toolbar TYPE ttb_button.
 DATA  : ls_toolbar TYPE stb_button.
 CASE e_sender.
    WHEN gcl_grid.

    ls_toolbar-function  = 'PREVIEW'."'Yazdırma öngörünümü'.
    ls_toolbar-quickinfo = TEXT-002."Yazdırma öngörünümü'.
    ls_toolbar-butn_type = '0'.
    ls_toolbar-text      = TEXT-002."Yazdırma öngörünümü'.
    ls_toolbar-icon      = icon_display_text."icon_start_viewer.
    INSERT ls_toolbar INTO TABLE lt_toolbar .

    ls_toolbar-function  = 'PRINT'."'Yazdır'.
    ls_toolbar-quickinfo = TEXT-001."'Yazdır'.
    ls_toolbar-butn_type = '0'.
    ls_toolbar-text      = TEXT-001."'Yazdır'.
    ls_toolbar-icon      =  icon_print.
    INSERT ls_toolbar INTO TABLE lt_toolbar.


      ls_toolbar-function  = 'DEL'."'Sil'.
      ls_toolbar-quickinfo = text-002."'Sil'.
      ls_toolbar-butn_type = '0'.
      ls_toolbar-text      = text-002."'Sil'.
      ls_toolbar-icon      = icon_delete.
      INSERT ls_toolbar INTO TABLE lt_toolbar." INDEX 29.

      ls_toolbar-function  = 'ADD'."'Yeni Giriş'.
      ls_toolbar-quickinfo = text-003."'Yeni Giriş'.
      ls_toolbar-butn_type = '0'.
      ls_toolbar-text      = text-003."'Yeni Giriş'.
      ls_toolbar-icon      = icon_add_row.
      INSERT ls_toolbar INTO TABLE  lt_toolbar." INDEX 30.

      ls_toolbar-function  = 'SAVE'."'Kaydet'.
      ls_toolbar-quickinfo = text-001."'Kaydet'.
      ls_toolbar-butn_type = '0'.
      ls_toolbar-text      = text-001."'Kaydet'.
      ls_toolbar-icon      = icon_system_save.
      INSERT ls_toolbar INTO TABLE  lt_toolbar." INDEX 31.


  ENDCASE.

  INSERT LINES OF lt_toolbar INTO TABLE  e_object->mt_toolbar[].
*  e_object->mt_toolbar[] = lt_toolbar[].
ENDFORM.                    " HANDLE_TOOLBAR

*--------------------------------------------------------------------*
*& Form print
*&---------------------------------------------------------------------*
FORM print  TABLES  pt_row_no STRUCTURE lvc_s_roid USING p_ucomm.

  IF p_ucomm = 'PRINT'.
    fp_outputparams-nodialog = 'X'.
    fp_outputparams-getpdf   = ''.
    fp_outputparams-dest     = 'ZPDF1'.
    fp_outputparams-reqnew   = 'X'.
    fp_outputparams-reqimm   = 'X'.
    fp_outputparams-noprint  = ''.
  ELSEIF p_ucomm  = 'PREVIEW'.
    fp_outputparams-nodialog = ''.
    fp_outputparams-getpdf   = ''.
*    fp_outputparams-dest     = 'ZPDF1'.
*    fp_outputparams-noprint  = 'X'.
  ENDIF.



  CALL FUNCTION 'FP_JOB_OPEN'
    CHANGING
      ie_outputparams = fp_outputparams
    EXCEPTIONS
      cancel          = 1
      usage_error     = 2
      system_error    = 3
      internal_error  = 4
      OTHERS          = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  IF p_tesl EQ 'X'.
    formname = 'FORMNAME1'.
  ELSEIF p_tesl2 EQ 'X'.
    formname = 'FORMNAME2'.
  ENDIF.

  CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
    EXPORTING
      i_name     = formname
    IMPORTING
      e_funcname = fm_name.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF p_tesl = 'X'.
*    LOOP AT pt_row_no INTO DATA(ps_row_no).
*      READ TABLE gt_mara INTO gs_mara INDEX ps_row_no-row_id.
*
*      CALL FUNCTION fm_name
*        EXPORTING
*          /1bcdwb/docparams  = fp_docparams
*          is_alv             = gs_mara
*        IMPORTING
*          /1bcdwb/formoutput = fp_formoutput
*        EXCEPTIONS
*          usage_error        = 1
*          system_error       = 2
*          internal_error     = 3.
*      IF sy-subrc <> 0.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*      ENDIF.
*
*    ENDLOOP.


  ELSEIF p_tesl2 = 'X'.

*    LOOP AT pt_row_no INTO DATA(ps_row_no).
*      READ TABLE gt_makt INTO gs_makt INDEX ps_row_no-row_id.
*
*      CALL FUNCTION fm_name
*        EXPORTING
*          /1bcdwb/docparams  = fp_docparams
*          is_alv             = gs_makt
*        IMPORTING
*          /1bcdwb/formoutput = fp_formoutput
*        EXCEPTIONS
*          usage_error        = 1
*          system_error       = 2
*          internal_error     = 3.
*      IF sy-subrc <> 0.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*      ENDIF.
*
*    ENDLOOP.
  ENDIF.
*
  CALL FUNCTION 'FP_JOB_CLOSE'
    EXCEPTIONS
      usage_error    = 1
      system_error   = 2
      internal_error = 3
      OTHERS         = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.
*--------------------------------------------------------------------*
*FORM get_popup .
*--------------------------------------------------------------------*
*FORM get_popup .
*  CLEAR: gs_message, gt_message.
*  gs_message-message_v1 = 'sss'.
*  gs_message-message = 'gshdjk'.
*  APPEND gs_message TO gt_message.
*
*  CALL FUNCTION 'RSCRMBW_DISPLAY_BAPIRET2'
*    TABLES
*      it_return = gt_message.
*
*  CLEAR: gs_message,gt_message.
*
*ENDFORM.
*&---------------------------------------------------------------------*
*& Form screen_loop
*&---------------------------------------------------------------------*
*FORM screen_loop .
*  LOOP AT SCREEN.
*    CASE screen-group1.
*      WHEN 'SG1'.
**        IF pa_pal = 'X'.
***          screen-input = 0.
***          screen-invisible = 1.
**          screen-active = 0.
**        ENDIF.
*      WHEN 'SG2'.
*        IF pa_ham = 'X'.
**          screen-input = 0.
**          screen-invisible = 1.
*          screen-active = 0.
*        ENDIF.
*    ENDCASE.
*    MODIFY SCREEN.
*  ENDLOOP.
*ENDFORM.
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*FORM handle_double_click  USING e_row     TYPE lvc_s_row
*                                e_column  TYPE lvc_s_col
*                                es_row_no TYPE lvc_s_roid
*                                e_sender TYPE REF TO cl_gui_alv_grid..
*
**  CASE e_column-fieldname.
**  when 'XXX'
**  ENDCASE.
*
*ENDFORM.                    " HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*&      Form  HANDLE_ONF4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*FORM handle_onf4  USING e_fieldname   TYPE lvc_fname
*                        e_fieldvalue  TYPE lvc_value
*                        es_row_no     TYPE lvc_s_roid
*                        er_event_data TYPE REF TO cl_alv_event_data
*                        et_bad_cells  TYPE lvc_t_modi
*                        e_sender TYPE REF TO cl_gui_alv_grid...
*
*ENDFORM.                    " HANDLE_ONF4
*&---------------------------------------------------------------------*
*&      Form  HANDLE_DATA_CHANGED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*FORM handle_data_changed  USING er_data_changed TYPE REF TO cl_alv_changed_data_protocol
*                                e_onf4          TYPE char01
*                                e_onf4_before   TYPE char01
*                                e_onf4_after    TYPE char01
*                                e_ucomm         TYPE sy-ucomm
*                                e_sender        TYPE REF TO cl_gui_alv_grid.
*  "DEGISEN VERIYI ALGILAMAK ICIN GEREKLI
*  "EDITLI ALAN VAR ISE VEYA CHECKBOX O DURUMDA KULLANILIR
*
*ENDFORM.                    " HANDLE_DATA_CHANGED
*&---------------------------------------------------------------------*
*&      Form  HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*FORM handle_hotspot_click  USING e_row_id     TYPE lvc_s_row
*                                 e_column_id  TYPE lvc_s_col
*                                 es_row_no    TYPE lvc_s_roid
*                                 e_sender TYPE REF TO cl_gui_alv_grid.
*
*  "HOTSPOT BURAYA DÜŞÜYOR TIKLANDIĞINDA.
*
*
*ENDFORM.                    " HANDLE_HOTSPOT_CLICK
**&---------------------------------------------------------------------*
**&      Form  HANDLE_DATA_CHANGED_FINISHED
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*FORM handle_data_changed_finished  USING e_modified
*                                         et_good_cells TYPE lvc_t_modi
*                                         e_sender TYPE REF TO cl_gui_alv_grid.
*
*ENDFORM.                    " HANDLE_DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*&      Form  HANDLE_CONTEXT_MENU_REQUEST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*FORM handle_context_menu_request  USING e_object TYPE REF TO cl_ctmenu.
*
*ENDFORM.                    " HANDLE_CONTEXT_MENU_REQUEST
**&---------------------------------------------------------------------*
**&      Form  HANDLE_MENU_BUTTON
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*FORM handle_menu_button  USING e_object
*                               e_ucomm.
*
*ENDFORM.                    " HANDLE_MENU_BUTTON
*" EDIT
**&---------------------------------------------------------------------*
**&      Form  BUTTON_CLICK
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*FORM button_click .
*
*ENDFORM.                    " BUTTON_CLICK
*--------------------------------------------------------------------*
