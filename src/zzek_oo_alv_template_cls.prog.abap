CLASS lcl_alv DEFINITION .
  PUBLIC SECTION.
    METHODS:

      handle_double_click FOR EVENT double_click   OF cl_gui_alv_grid
                          IMPORTING e_row
                                    e_column
                                    es_row_no
                                    sender,

      handle_onf4         FOR EVENT onf4           OF cl_gui_alv_grid
                          IMPORTING e_fieldname
                                    e_fieldvalue
                                    es_row_no
                                    er_event_data
                                    et_bad_cells
                                    sender,

      handle_data_changed FOR EVENT data_changed   OF cl_gui_alv_grid
                          IMPORTING er_data_changed
                                    e_onf4
                                    e_onf4_before
                                    e_onf4_after
                                    e_ucomm
                                    sender,

      handle_user_command FOR EVENT user_command   OF cl_gui_alv_grid
                          IMPORTING e_ucomm
                                    sender,

      handle_toolbar      FOR EVENT toolbar        OF cl_gui_alv_grid
                          IMPORTING e_object
                                    sender,

      handle_hotspot_click         FOR EVENT hotspot_click OF cl_gui_alv_grid
                                   IMPORTING e_row_id
                                             e_column_id
                                             es_row_no
                                             sender,

      handle_data_changed_finished FOR EVENT data_changed_finished OF cl_gui_alv_grid
                                   IMPORTING e_modified
                                             et_good_cells
                                             sender,

      handle_context_menu_request  FOR EVENT context_menu_request   OF cl_gui_alv_grid
                                   IMPORTING e_object,

      handle_menu_button           FOR EVENT menu_button            OF cl_gui_alv_grid
                                   IMPORTING  e_object
                                              e_ucomm,

      handle_button_click          FOR EVENT button_click           OF cl_gui_alv_grid
                                   IMPORTING  es_col_id
                                              es_row_no
                                              sender.

      METHODS : GET_DATA,
                LIST_DATA.
ENDCLASS.                    " lcl_alv
*&---------------------------------------------------------------------*

CLASS lcl_alv IMPLEMENTATION.
  METHOD handle_double_click.
*    PERFORM handle_double_click
*      USING e_row
*            e_column
*            es_row_no
*            sender.
  ENDMETHOD.                    "handle_double_click
  METHOD handle_onf4.
*    PERFORM handle_onf4
*      USING e_fieldname
*            e_fieldvalue
*            es_row_no
*            er_event_data
*            et_bad_cells
*            sender.
  ENDMETHOD.                    "handle_onf4
  METHOD handle_data_changed.
*    PERFORM handle_data_changed
*      USING er_data_changed
*                  e_onf4
*                  e_onf4_before
*                  e_onf4_after
*                  e_ucomm
*                  sender.

    "er_data_changed içinde değişen satırın value degerını ve
    "row indexini tutuyor
  ENDMETHOD.                    "handle_data_changed

  METHOD handle_user_command.
    PERFORM handle_user_command
      USING e_ucomm
            sender.
  ENDMETHOD.                    "handle_user_command

  METHOD handle_toolbar.
    PERFORM handle_toolbar
      USING e_object
            sender.
  ENDMETHOD.                    "handle_toolbar

  METHOD handle_hotspot_click.
    "hucre bazındakı lınklerde dusuyor
    "sütunun tamamı hotspot ise buraya düşüyor
*    PERFORM handle_hotspot_click
*      USING e_row_id
*            e_column_id
*            es_row_no
*            sender.
  ENDMETHOD.                    "handle_hotspot_click
  METHOD handle_data_changed_finished.
*    PERFORM handle_data_changed_finished
*      USING e_modified
*            et_good_cells
*            sender.

  ENDMETHOD.                    "handle_data_changed_finished
  METHOD handle_context_menu_request.
*    PERFORM handle_context_menu_request
*      USING e_object.

  ENDMETHOD.                    "handle_context_menu_request
  METHOD handle_menu_button.
*    PERFORM handle_menu_button
*      USING e_object
*            e_ucomm.
  ENDMETHOD.                    "handle_menu_button
  METHOD get_data.
    PERFORM get_data.
  ENDMETHOD.
  method list_data .
    PERFORM list_data.
  ENDMETHOD.

  METHOD handle_button_click.

  ENDMETHOD.                    "handle_button_click

ENDCLASS.                    " LCL_ALV
