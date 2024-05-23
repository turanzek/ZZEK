*&---------------------------------------------------------------------*
*& Report  ZTEST_SOURAV_EXCEL
*&
*&---------------------------------------------------------------------*
*& Sourav Bhaduri 02-Dec-2008
*&---------------------------------------------------------------------*

REPORT  ztest_sourav_excel NO STANDARD PAGE HEADING.

DATA:
oref_container   TYPE REF TO cl_gui_custom_container,
iref_control     TYPE REF TO i_oi_container_control,
iref_document    TYPE REF TO i_oi_document_proxy,
iref_spreadsheet TYPE REF TO i_oi_spreadsheet,
iref_error       TYPE REF TO i_oi_error.

DATA:
v_document_url TYPE c LENGTH 256,
i_sheets TYPE soi_sheets_table,
wa_sheets TYPE soi_sheets,
i_data        TYPE soi_generic_table,
wa_data       TYPE soi_generic_item,
i_ranges      TYPE soi_range_list.

PARAMETERS:
p_file  TYPE  localfile OBLIGATORY,
p_rows TYPE i DEFAULT 100 OBLIGATORY,   "Rows (Maximum 65536)
p_cols TYPE i DEFAULT 10 OBLIGATORY.    "Columns (Maximum 256)

INITIALIZATION.

  CALL METHOD c_oi_container_control_creator=>get_container_control
    IMPORTING
      control = iref_control
      error   = iref_error.
  IF iref_error->has_failed = 'X'.
    CALL METHOD iref_error->raise_message
      EXPORTING
        type = 'E'.
  ENDIF.


  CREATE OBJECT oref_container
    EXPORTING
      container_name              = 'CONT'
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.
  IF sy-subrc <> 0.
    MESSAGE e001(00) WITH 'Error while creating container'.
  ENDIF.

  CALL METHOD iref_control->init_control
    EXPORTING
      inplace_enabled      = 'X'
      r3_application_name  = 'EXCEL CONTAINER'
      parent               = oref_container
    IMPORTING
      error                = iref_error
    EXCEPTIONS
      javabeannotsupported = 1
      OTHERS               = 2.
  IF iref_error->has_failed = 'X'.
    CALL METHOD iref_error->raise_message
      EXPORTING
        type = 'E'.
  ENDIF.

  CALL METHOD iref_control->get_document_proxy
    EXPORTING
      document_type  = soi_doctype_excel_sheet
    IMPORTING
      document_proxy = iref_document
      error          = iref_error.
  IF iref_error->has_failed = 'X'.
    CALL METHOD iref_error->raise_message
      EXPORTING
        type = 'E'.
  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

* To provide F4 help for the file
  PERFORM sub_file_f4.

START-OF-SELECTION.

  CONCATENATE 'FILE://' p_file INTO v_document_url.

  CALL METHOD iref_document->open_document
    EXPORTING
      document_title = 'Excel'
      document_url   = v_document_url
      open_inplace   = 'X'
    IMPORTING
      error          = iref_error.
  IF iref_error->has_failed = 'X'.
    CALL METHOD iref_error->raise_message
      EXPORTING
        type = 'I'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  CALL METHOD iref_document->get_spreadsheet_interface
    EXPORTING
      no_flush        = ' '
    IMPORTING
      error           = iref_error
      sheet_interface = iref_spreadsheet.

  IF iref_error->has_failed = 'X'.
    CALL METHOD iref_error->raise_message
      EXPORTING
        type = 'I'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  CALL METHOD iref_spreadsheet->get_sheets
    EXPORTING
      no_flush = ' '
    IMPORTING
      sheets   = i_sheets
      error    = iref_error.
  IF iref_error->has_failed = 'X'.
    CALL METHOD iref_error->raise_message
      EXPORTING
        type = 'I'.
    LEAVE LIST-PROCESSING.
  ENDIF.
  LOOP AT i_sheets INTO wa_sheets.
    CALL METHOD iref_spreadsheet->select_sheet
      EXPORTING
        name  = wa_sheets-sheet_name
      IMPORTING
        error = iref_error.
    IF iref_error->has_failed = 'X'.
      EXIT.
    ENDIF.
    CALL METHOD iref_spreadsheet->set_selection
      EXPORTING
        top     = 1
        left    = 1
        rows    = p_rows
        columns = p_cols.

    CALL METHOD iref_spreadsheet->insert_range
      EXPORTING
        name     = 'Test'
        rows     = p_rows
        columns  = p_cols
        no_flush = ''
      IMPORTING
        error    = iref_error.
    IF iref_error->has_failed = 'X'.
      EXIT.
    ENDIF.

    REFRESH i_data.

    CALL METHOD iref_spreadsheet->get_ranges_data
      EXPORTING
        all      = 'X'
      IMPORTING
        contents = i_data
        error    = iref_error
      CHANGING
        ranges   = i_ranges.
    DELETE i_data WHERE value IS INITIAL OR value = space.
    ULINE.
    WRITE:/1 wa_sheets-sheet_name COLOR 3.
    ULINE.

    LOOP AT i_data INTO wa_data.
      WRITE:(50) wa_data-value.
      AT END OF row.
        NEW-LINE.
      ENDAT.
    ENDLOOP.
  ENDLOOP.

  CALL METHOD iref_document->close_document
    IMPORTING
      error = iref_error.
  IF iref_error->has_failed = 'X'.
    CALL METHOD iref_error->raise_message
      EXPORTING
        type = 'I'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  CALL METHOD iref_document->release_document
    IMPORTING
      error = iref_error.
  IF iref_error->has_failed = 'X'.
    CALL METHOD iref_error->raise_message
      EXPORTING
        type = 'I'.
    LEAVE LIST-PROCESSING.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  SUB_FILE_F4
*&---------------------------------------------------------------------*
*       F4 help for file path
*----------------------------------------------------------------------*
FORM sub_file_f4 .
  DATA:
  l_desktop       TYPE string,
  l_i_files       TYPE filetable,
  l_wa_files      TYPE file_table,
  l_rcode         TYPE int4.

* Finding desktop
  CALL METHOD cl_gui_frontend_services=>get_desktop_directory
    CHANGING
      desktop_directory    = l_desktop
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.
  IF sy-subrc <> 0.
    MESSAGE e001(00) WITH
    'Desktop not found'.
  ENDIF.

* Update View
  CALL METHOD cl_gui_cfw=>update_view
    EXCEPTIONS
      cntl_system_error = 1
      cntl_error        = 2
      OTHERS            = 3.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = 'Select Excel file'
      default_extension       = '.xls'
      file_filter             = '.xls'
      initial_directory       = l_desktop
    CHANGING
      file_table              = l_i_files
      rc                      = l_rcode
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc <> 0.
    MESSAGE e001(00) WITH 'Error while opening file'.
  ENDIF.

  READ TABLE l_i_files INDEX 1 INTO l_wa_files.
  IF sy-subrc = 0.
    p_file = l_wa_files-filename.
  ELSE.
    MESSAGE e001(00) WITH 'Error while opening file'.
  ENDIF.

ENDFORM.                    " SUB_FILE_F4
