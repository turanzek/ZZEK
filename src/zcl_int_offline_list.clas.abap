class ZCL_INT_OFFLINE_LIST definition
  public
  final
  create public .

public section.

  class-methods GET_LIST
    importing
      !IV_ID type ZINT_S_OPERATION
    returning
      value(RT_LIST) type ZINT_TT_OPERATION .
  class-methods SAVE_DOCUMENT
    exporting
      value(ET_RETURN) type BAPIRET2_TT
    changing
      !IS_DATA type ZINT_S_OPERATION optional .
protected section.
private section.

  class-data MT_RETURN type BAPIRET2_TT .

  class-methods SAVE_DOCUMENT_GLOBAL
    exporting
      value(ET_RETURN) type BAPIRET2_TT
    changing
      !IS_DATA type ZINT_S_OPERATION optional .
ENDCLASS.



CLASS ZCL_INT_OFFLINE_LIST IMPLEMENTATION.


  METHOD get_list.

*    DATA:   lt_dcc_files TYPE TABLE OF zpp_t_dcc_files .
*    DATA: lv_key TYPE char128.
*
*
*
*    CASE iv_application_name .
*      WHEN zif_dcc_constants=>mc_application_approve..
*
*
*        rt_list =  get_list_approve( iv_application_name = iv_Application_name ).
*
*
*      WHEN zif_dcc_constants=>mc_application_request..
*
*
*        rt_list =  get_list_request( iv_application_name = iv_Application_name iv_vendor = iv_vendor ).
*
*      WHEN OTHERS.
*    ENDCASE.
*
*
*    LOOP AT rt_list ASSIGNING  FIELD-SYMBOL(<fs_list>).
*      LOOP AT <fs_list>-revisions  ASSIGNING FIELD-SYMBOL(<fs_rev>).
*        LOOP AT <fs_rev>-files  ASSIGNING FIELD-SYMBOL(<ls_dcc_files>) WHERE id  = <fs_rev>-id
*                                                 AND rdokno = <fs_rev>-rdokno
*                                                 AND dokno = <fs_rev>-dokno.
*          lv_key = |(Itemno='{ <ls_dcc_files>-itemno }',Id='{ <ls_dcc_files>-id }',Rdokno='{ <ls_dcc_files>-rdokno }',Dokno='{ <ls_dcc_files>-dokno }')|.
*          <ls_dcc_files>-file_url =  |/sap/opu/odata/sap/ZGS_PP_DCC_SRV/FilesSet{ lv_key }/$value|.
*
*
*        ENDLOOP.
*      ENDLOOP.
*    ENDLOOP.
*
*
*



  ENDMETHOD.


  METHOD save_document.




    DATA:
      lv_id(50),
      ls_data TYPE zint_s_operation.





    MOVE-CORRESPONDING is_data TO ls_data.


*       IF line_exists( it_key_tab[  name = 'Plate' ] ).
*      DATA(ls_filter) = it_key_tab[  name = 'Plate' ]-value.
*    ENDIF.
*
    SELECT COUNT(*)
      FROM zint_t_operation
*       INTO CORRESPONDING FIELDS OF TABLE @et_entityset
       WHERE operationid EQ @ls_data-operationid.

    IF sy-subrc NE 0.
      INSERT zint_t_operation FROM ls_data.
    ELSE.
      APPEND zcl_abap_utils=>message_number_to_return( EXPORTING iv_type = 'E'
                                                         iv_number     = '001'
                                                         iv_id         = 'ZZEK'
                                                         iv_message_v1 = ''
                                                         iv_message_v2 = ''
                                                         iv_message_v3 = ''
                                                         iv_message_v4 = ''
                                                        ) TO et_return.

    ENDIF.




*
*    READ TABLE is_document-revisions ASSIGNING FIELD-SYMBOL(<fs_revisions>) INDEX 1.
*    IF sy-subrc EQ 0.
*
*
*
*      IF <fs_revisions>-rno IS NOT INITIAL.
*
*        CLEAR: ls_dcc002.
*        MOVE-CORRESPONDING <fs_revisions> TO ls_dcc002.
*
*        TRANSLATE ls_dcc002-tra TO UPPER CASE.
**
*        CONCATENATE ls_dcc002-tra_pk ls_dcc002-tra_yuk ls_dcc002-tra ls_dcc002-tra_alici
*        ls_dcc002-tra_no INTO ls_dcc002-tra_kod SEPARATED BY '-'.
*
*        ls_dcc002-rdokno = |{ ls_dcc002-dokno }-{ ls_dcc002-rno } |.
*
*
*        SELECT COUNT(*)
*          FROM zpp_t_dcc002
*          WHERE id = ls_dcc002-id
*          AND rdokno = ls_dcc002-rdokno
*          AND dokno = ls_dcc002-dokno.
*
*        IF sy-subrc NE 0.
*          INSERT zpp_t_dcc002 FROM ls_dcc002.
**ls_model-revisions[ 0 ]-rdokno = "yeni".
*          <fs_revisions>-rdokno = ls_dcc002-rdokno.
*          <fs_revisions>-tra_kod = ls_dcc002-tra_kod.
*
*          UPDATE zpp_t_dcc001
*          SET last_rno = ls_dcc002-rno
*          WHERE id = ls_dcc002-id AND
*              dokno = ls_dcc002-dokno .
*
*        ELSE.
*
*          APPEND zcl_abap_utils=>message_number_to_return( EXPORTING iv_type = 'E'
*                                                          iv_number     = '007'
*                                                          iv_id         = 'ZGT_PP'
*                                                          iv_message_v1 = ''
*                                                          iv_message_v2 = ''
*                                                          iv_message_v3 = ''
*                                                          iv_message_v4 = ''
*                                                         ) TO et_return.
*
*        ENDIF.
*
*
**    loop at <fs_revisions>-files WHERE id = ls_dcc002-id and
**                                       rdokno = ls_dcc002-rdokno and
**                                       dokno = ls_dcc002-dokn.
**       endloop.
*      ENDIF.
*
*
*    ELSE.
*
**
*
*
*
*
*
*    ENDIF.



  ENDMETHOD.


  METHOD save_document_global.



    DATA:
      lv_id(50),
      ls_data TYPE zint_s_operation.





    MOVE-CORRESPONDING is_data TO ls_data.


*       IF line_exists( it_key_tab[  name = 'Plate' ] ).
*      DATA(ls_filter) = it_key_tab[  name = 'Plate' ]-value.
*    ENDIF.
*
    SELECT COUNT(*)
      FROM zint_t_operation
*       INTO CORRESPONDING FIELDS OF TABLE @et_entityset
       WHERE operationid EQ @ls_data-operationid.

    IF sy-subrc NE 0.
      INSERT zint_t_operation FROM ls_data.
    ELSE.
      APPEND zcl_abap_utils=>message_number_to_return( EXPORTING iv_type = 'E'
                                                         iv_number     = '006'
                                                         iv_id         = 'ZGT_PP'
                                                         iv_message_v1 = ''
                                                         iv_message_v2 = ''
                                                         iv_message_v3 = ''
                                                         iv_message_v4 = ''
                                                        ) TO et_return.

    ENDIF.




  ENDMETHOD.
ENDCLASS.
