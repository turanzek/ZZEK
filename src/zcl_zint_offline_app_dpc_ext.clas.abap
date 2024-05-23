class ZCL_ZINT_OFFLINE_APP_DPC_EXT definition
  public
  inheriting from ZCL_ZINT_OFFLINE_APP_DPC
  create public .

public section.
protected section.

  methods OPERATIONSET_CREATE_ENTITY
    redefinition .
  methods OPERATIONSET_GET_ENTITY
    redefinition .
  methods OPERATIONSET_GET_ENTITYSET
    redefinition .
  methods APPLICATIONSET_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZINT_OFFLINE_APP_DPC_EXT IMPLEMENTATION.


  method APPLICATIONSET_GET_ENTITYSET.
**TRY.
*CALL METHOD SUPER->APPLICATIONSET_GET_ENTITYSET
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    io_tech_request_context  =
**  IMPORTING
**    et_entityset             =
**    es_response_context      =
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.
  endmethod.


  METHOD operationset_create_entity.
**TRY.
*CALL METHOD SUPER->OPERATIONSET_CREATE_ENTITY
*  EXPORTING
*    IV_ENTITY_NAME          =
*    IV_ENTITY_SET_NAME      =
*    IV_SOURCE_NAME          =
*    IT_KEY_TAB              =
**    io_tech_request_context =
*    IT_NAVIGATION_PATH      =
**    io_data_provider        =
**  IMPORTING
**    er_entity               =
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.
    DATA: ls_model  TYPE zint_s_operation.
    DATA: lt_return TYPE TABLE OF bapiret2.
    DATA: lo_exception TYPE REF TO /iwbep/cx_mgw_tech_exception.
    DATA: lv_text TYPE bapi_msg.



    io_data_provider->read_entry_data( IMPORTING es_data = ls_model ).

    zcl_int_offline_list=>save_document(
   IMPORTING
     et_return   =      lt_return            " Return error table type parameter
   CHANGING
     is_data =      ls_model            " DCC - Uygulama modeli
 ).
*    zcl_dcc_main_processor=>save_document(
*      CHANGING
*        is_document = ls_model
*    ).



    LOOP AT lt_return INTO DATA(ls_return) WHERE type CA 'EAX'.
    ENDLOOP.
    IF sy-subrc IS INITIAL.
      CREATE OBJECT lo_exception.
      lo_exception->get_msg_container( )->add_messages_from_bapi( it_bapi_messages = lt_return ).


      MESSAGE ID ls_return-id TYPE ls_return-type NUMBER ls_return-number WITH ls_return-message_v1
                                                                               ls_return-message_v2
                                                                               ls_return-message_v3
                                                                               ls_return-message_v4 INTO lv_text.

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid            = /iwbep/cx_mgw_busi_exception=>business_error
          message           = lv_text
          message_container = lo_exception->get_msg_container( ).
    ENDIF.
*
*    copy_data_to_ref( EXPORTING  is_data = ls_model
*                       CHANGING  cr_data = er_entity ).
  ENDMETHOD.


  method OPERATIONSET_GET_ENTITY.
**TRY.
*CALL METHOD SUPER->OPERATIONSET_GET_ENTITY
*  EXPORTING
*    IV_ENTITY_NAME          =
*    IV_ENTITY_SET_NAME      =
*    IV_SOURCE_NAME          =
*    IT_KEY_TAB              =
**    io_request_object       =
**    io_tech_request_context =
*    IT_NAVIGATION_PATH      =
**  IMPORTING
**    er_entity               =
**    es_response_context     =
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.
  endmethod.


  METHOD operationset_get_entityset.
**TRY.
*CALL METHOD SUPER->OPERATIONSET_GET_ENTITYSET
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    io_tech_request_context  =
**  IMPORTING
**    et_entityset             =
**    es_response_context      =
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.
*  DATA: itab_order TYPE TABLE OF  /IWBEP/T_MGW_SELECT_OPTION,
  DATA: itab_order TYPE TABLE OF  char_72,
          wa_order   LIKE LINE OF   itab_order.
 DATA: lt_return TYPE TABLE OF bapiret2.

    READ TABLE it_filter_select_options INTO DATA(ls_order) INDEX 1.
*    READ TABLE it_order INTO DATA(ls_order) INDEX 1.
    IF sy-subrc EQ 0.

      wa_order = ls_order-property.
      APPEND wa_order TO itab_order.
    ENDIF.


    IF line_exists( it_filter_select_options[  property = 'Operationid' ] ).
      DATA(ls_filter) = it_filter_select_options[  property = 'Operationid' ]-select_options.
    ENDIF.
*--------------------------------------------------------------------*

    TYPES: BEGIN OF ty_s_clause.
    TYPES:   line(72)  TYPE c.
    TYPES: END OF ty_s_clause.

    DATA: gs_condtab TYPE hrcond.
    DATA: gt_condtab TYPE TABLE OF hrcond.


    FIELD-SYMBOLS <fs_wherecond> TYPE ty_s_clause.
    DATA:
      gt_where_clauses  TYPE STANDARD TABLE OF ty_s_clause
                        WITH DEFAULT KEY.
    LOOP AT it_filter_select_options INTO DATA(ls_filt).

      CLEAR  gs_condtab.
      gs_condtab-field = ls_filt-property.
      gs_condtab-opera = VALUE #( ls_filt-select_options[ 1 ]-option OPTIONAL ) .
      gs_condtab-low   = VALUE #( ls_filt-select_options[ 1 ]-low OPTIONAL ) .
      APPEND  gs_condtab  TO gt_condtab.


    ENDLOOP.

    CALL FUNCTION 'RH_DYNAMIC_WHERE_BUILD'
      EXPORTING
        dbtable         = space " can be empty
      TABLES
        condtab         = gt_condtab
        where_clause    = gt_where_clauses
      EXCEPTIONS
        empty_condtab   = 01
        no_db_field     = 02
        unknown_db      = 03
        wrong_condition = 04.

*--------------------------------------------------------------------*

    SELECT * FROM zint_t_operation
      INTO CORRESPONDING FIELDS OF TABLE @et_entityset
      WHERE (gt_where_clauses).



  ENDMETHOD.
ENDCLASS.
