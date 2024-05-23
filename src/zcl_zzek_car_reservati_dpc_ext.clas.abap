class ZCL_ZZEK_CAR_RESERVATI_DPC_EXT definition
  public
  inheriting from ZCL_ZZEK_CAR_RESERVATI_DPC
  create public .

public section.
protected section.

  methods REZERVATIONSET_CREATE_ENTITY
    redefinition .
  methods REZERVATIONSET_GET_ENTITY
    redefinition .
  methods REZERVATIONSET_GET_ENTITYSET
    redefinition .
  methods REZERVATIONSET_UPDATE_ENTITY
    redefinition .
  methods VEHICLESET_CREATE_ENTITY
    redefinition .
  methods VEHICLESET_GET_ENTITY
    redefinition .
  methods VEHICLESET_GET_ENTITYSET
    redefinition .
  methods VEHICLESET_UPDATE_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZZEK_CAR_RESERVATI_DPC_EXT IMPLEMENTATION.


  method REZERVATIONSET_CREATE_ENTITY.
**TRY.
*CALL METHOD SUPER->REZERVATIONSET_CREATE_ENTITY
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


 DATA: ls_model  TYPE zzek_s_rezervation.
    DATA: lt_return TYPE TABLE OF bapiret2.
    DATA: lo_exception TYPE REF TO /iwbep/cx_mgw_tech_exception.
    DATA: lv_text TYPE bapi_msg.

*    CASE iv_entity_name.
*      WHEN 'Reservation'.
*      WHEN OTHERS.
*        RETURN.
*    ENDCASE.
*

    io_data_provider->read_entry_data( IMPORTING es_data = ls_model ).



    DATA:
      lv_id(50),
      ls_data TYPE zzek_s_rezervation.


*    MOVE-CORRESPONDING is_data TO ls_data.


*       IF line_exists( it_key_tab[  name = 'Plate' ] ).
*      DATA(ls_filter) = it_key_tab[  name = 'Plate' ]-value.
*    ENDIF.
*
    SELECT COUNT(*)
      FROM zzek_t_rezervat
*       INTO CORRESPONDING FIELDS OF TABLE @et_entityset
       WHERE guid EQ @ls_model-guid
         and plate eq @ls_model-plate.

    IF sy-subrc NE 0.
      INSERT zzek_t_rezervat FROM ls_model.
    ELSE.
      APPEND zcl_abap_utils=>message_number_to_return( EXPORTING iv_type = 'E'
                                                         iv_number     = '001'
                                                         iv_id         = 'ZZEK'
                                                         iv_message_v1 = ''
                                                         iv_message_v2 = ''
                                                         iv_message_v3 = ''
                                                         iv_message_v4 = ''
                                                        ) TO lt_return.

    ENDIF.





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

  endmethod.


  method REZERVATIONSET_GET_ENTITY.
**TRY.
*CALL METHOD SUPER->REZERVATIONSET_GET_ENTITY
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
    BREAK-POINT.
  endmethod.


  METHOD rezervationset_get_entityset.
**TRY.
*CALL METHOD SUPER->REZERVATIONSET_GET_ENTITYSET
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
**    IO_TECH_REQUEST_CONTEXT  =
**  IMPORTING
**    ET_ENTITYSET             =
**    ES_RESPONSE_CONTEXT      =
*    .
** CATCH /IWBEP/CX_MGW_BUSI_EXCEPTION .
** CATCH /IWBEP/CX_MGW_TECH_EXCEPTION .
**ENDTRY.


    IF line_exists( it_key_tab[  name = 'Plate' ] ).
      DATA(ls_filter) = it_key_tab[  name = 'Plate' ]-value.
    ENDIF.
*
    SELECT a~*,
           b~marka,
           b~model
      FROM zzek_t_rezervat AS a
      INNER JOIN zzek_t_cardata AS b ON b~plate =  a~plate
       INTO CORRESPONDING FIELDS OF TABLE @et_entityset
       WHERE a~plate EQ @ls_filter.

    LOOP AT et_entityset ASSIGNING FIELD-SYMBOL(<ls_entity>).
      GET TIME STAMP FIELD <ls_entity>-startdate     .
      GET TIME STAMP FIELD <ls_entity>-enddate     .
    ENDLOOP.
  ENDMETHOD.


  method REZERVATIONSET_UPDATE_ENTITY.
**TRY.
*CALL METHOD SUPER->REZERVATIONSET_UPDATE_ENTITY
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
  endmethod.


  method VEHICLESET_CREATE_ENTITY.
**TRY.
*CALL METHOD SUPER->VEHICLESET_CREATE_ENTITY
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
  endmethod.


  method VEHICLESET_GET_ENTITY.
**TRY.
*CALL METHOD SUPER->VEHICLESET_GET_ENTITY
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
*    BREAK-POINT.
  endmethod.


  METHOD vehicleset_get_entityset.
**TRY.
*CALL METHOD SUPER->VEHICLESET_GET_ENTITYSET
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
**    IO_TECH_REQUEST_CONTEXT  =
**  IMPORTING
**    ET_ENTITYSET             =
**    ES_RESPONSE_CONTEXT      =
*    .
** CATCH /IWBEP/CX_MGW_BUSI_EXCEPTION .
** CATCH /IWBEP/CX_MGW_TECH_EXCEPTION .
**ENDTRY.

*for order by

    DATA: itab_order TYPE TABLE OF  char_72,
          wa_order   LIKE LINE OF   itab_order.


    READ TABLE it_order INTO DATA(ls_order) INDEX 1.
    IF sy-subrc EQ 0.

      wa_order = ls_order-property.
      APPEND wa_order TO itab_order.
    ENDIF.


    IF line_exists( it_filter_select_options[  property = 'Model' ] ).
      DATA(lt_filter) = it_filter_select_options[  property = 'Model' ]-select_options.
    ENDIF.
*--------------------------------------------------------------------*

*    TYPES: BEGIN OF ty_s_clause.
*    TYPES:   line(72)  TYPE c.
*    TYPES: END OF ty_s_clause.
*
*    DATA: gs_condtab TYPE hrcond.
*    DATA: gt_condtab TYPE TABLE OF hrcond.
*
*
*    FIELD-SYMBOLS <fs_wherecond> TYPE ty_s_clause.
*    DATA:
*      gt_where_clauses  TYPE STANDARD TABLE OF ty_s_clause
*                        WITH DEFAULT KEY.
*    LOOP AT it_filter_select_options INTO DATA(ls_filt).
*
*      CLEAR  gs_condtab.
*      gs_condtab-field = ls_filt-property.
*      gs_condtab-opera = VALUE #( ls_filt-select_options[ 1 ]-option OPTIONAL ) .
*      gs_condtab-low   = VALUE #( ls_filt-select_options[ 1 ]-low OPTIONAL ) .
*      APPEND  gs_condtab  TO gt_condtab.
*
*
*    ENDLOOP.
*
*    CALL FUNCTION 'RH_DYNAMIC_WHERE_BUILD'
*      EXPORTING
*        dbtable         = space " can be empty
*      TABLES
*        condtab         = gt_condtab
*        where_clause    = gt_where_clauses
*      EXCEPTIONS
*        empty_condtab   = 01
*        no_db_field     = 02
*        unknown_db      = 03
*        wrong_condition = 04.
*
**--------------------------------------------------------------------*



**
**SELECT *
**  FROM ztable_name
**  INTO itab_ztable_name
**  ORDER BY (itab_order).
**  ENDSELECT.
*

    DATA: lv_model TYPE zzek_t_cardata-model.


    IF lt_filter IS  NOT INITIAL.

      lv_model = lt_filter[ 1 ]-low.

      TRANSLATE lv_model USING '*%'.

      SELECT *
        FROM zzek_t_cardata
         INTO CORRESPONDING FIELDS OF TABLE et_entityset
         WHERE model LIKE lv_model
      ORDER BY (itab_order).

    ELSE.

      SELECT *
         FROM zzek_t_cardata
          INTO CORRESPONDING FIELDS OF TABLE et_entityset
       ORDER BY (itab_order).

    ENDIF.
  ENDMETHOD.


  method VEHICLESET_UPDATE_ENTITY.
**TRY.
*CALL METHOD SUPER->VEHICLESET_UPDATE_ENTITY
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
  endmethod.
ENDCLASS.
