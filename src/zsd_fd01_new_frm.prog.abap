*&---------------------------------------------------------------------*
*&  Include           ZSD_FD01_FRM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_FILENAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_filename.
  DATA: lt_files TYPE filetable ,
        ls_files TYPE file_table,
        lv_rc    TYPE i.


  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    CHANGING
      file_table              = lt_files
      rc                      = lv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    READ TABLE lt_files INDEX 1 INTO ls_files.
    p_file = ls_files-filename.
  ENDIF.

ENDFORM.                    " GET_FILENAME
*&---------------------------------------------------------------------*
*&      Form  UPLOAD_DATA_XLS_TO_SAP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM upload_data_xls_to_sap.
  TYPE-POOLS: truxs.
  DATA it_raw TYPE truxs_t_text_data.

  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      i_line_header        = ''
      i_tab_raw_data       = it_raw
      i_filename           = p_file
    TABLES
      i_tab_converted_data = gt_file
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    STOP.
  ENDIF.

  IF gt_file[] IS INITIAL.
    MESSAGE i008(zsd01).
    STOP.
  ENDIF.

ENDFORM.                    " UPLOAD_DATA

*&---------------------------------------------------------------------*
*&      Form  check_authority
*&---------------------------------------------------------------------*
FORM check_authority.
  AUTHORITY-CHECK OBJECT 'S_TCODE' ID 'TCD' FIELD 'FD01'.
  IF sy-subrc NE 0.
    MESSAGE e600(f1) WITH text-e01.
  ENDIF.
ENDFORM.                    " check_authority

*&---------------------------------------------------------------------*
*&      Form  open_group
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM open_group.

  CHECK NOT session IS INITIAL.

  CALL FUNCTION 'BDC_OPEN_GROUP'
    EXPORTING
      client              = sy-mandt
      group               = group
      keep                = 'X'
      user                = sy-uname
    EXCEPTIONS
      client_invalid      = 1
      destination_invalid = 2
      group_invalid       = 3
      group_is_locked     = 4
      holddate_invalid    = 5
      internal_error      = 6
      queue_error         = 7
      running             = 8
      system_lock_error   = 9
      user_invalid        = 10
      OTHERS              = 11.

ENDFORM.                    " open_group
*&---------------------------------------------------------------------*
*&      Form  close_group
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM close_group.

  CHECK NOT session IS INITIAL.

  CALL FUNCTION 'BDC_CLOSE_GROUP'
    EXCEPTIONS
      not_open    = 1
      queue_error = 2
      OTHERS      = 3.

  DATA: lv_first(10),
        lv_last(10),
        lv_lines(10).

  lv_first = gv_first.
  lv_last  = gv_last.
  lv_lines = gv_lines.
  CONDENSE: lv_first, lv_last, lv_lines.

  PERFORM add_message_tab USING 'S' 'ZSD01' '001'
                                 space space space space.

  PERFORM add_message_tab USING 'S' 'ZSD01' '002'
                                 lv_first lv_last space space.

  PERFORM add_message_tab USING 'S' 'ZSD01' '003'
                                 lv_lines space space space.

  PERFORM add_message_tab USING 'S' 'ZSD01' '004'
                                 group space space space.

ENDFORM.                    "close_group
*&---------------------------------------------------------------------*
*&      Form  START_BATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM start_batch.

  break c9001546.

  REFRESH: gt_message_tab, gt_rel.
  CLEAR: gv_lines, gv_first, gv_last.

  PERFORM open_group.

  IF NOT ctu IS INITIAL.
    PERFORM log_create USING space gv_object gv_subobject.
  ENDIF.

  LOOP AT gt_file INTO gs_file WHERE int_number CA '1234567890'
                                 AND int_number GE p_start
                                 AND int_number LE p_end.
    ADD 1 TO gv_lines.
    IF gv_first IS INITIAL.
      gv_first = gs_file-int_number.
    ENDIF.
    gv_last = gs_file-int_number.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = gs_file-bukrs
      IMPORTING
        output = gs_file-bukrs.

    gv_kunnr = gs_file-must_no.
    PERFORM conversion_exit_alpha_input CHANGING gv_kunnr.

    SELECT COUNT(*)
      FROM kna1
     WHERE kunnr EQ gv_kunnr.
*&---------------------------------------------------------------------*
*/ Yarat
*&---------------------------------------------------------------------*
    IF gv_kunnr IS INITIAL.
      PERFORM bdc_fd01.
*&---------------------------------------------------------------------*
*/ Değiştir
*&---------------------------------------------------------------------*
    ELSE.
      PERFORM bdc_fd02.
    ENDIF.
  ENDLOOP.

  IF NOT sy-subrc IS INITIAL.
    MESSAGE i007(zsd01).
    STOP.
  ENDIF.

  PERFORM close_group.

  IF NOT ctu IS INITIAL.
    PERFORM cust_msg_add.
    PERFORM log_write_db.
    PERFORM log_display.
  ELSE.
    PERFORM messages_show_as_popup.
  ENDIF.

ENDFORM.                    " START_BATCH
*&---------------------------------------------------------------------*
*&      Form  BDC_FD01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bdc_fd01.

  PERFORM bdc_dynpro      USING 'SAPMF02D' '0105'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'USE_ZAV'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'RF02D-BUKRS'
                                 gs_file-bukrs.
  PERFORM bdc_field       USING 'RF02D-KTOKD'
                                 gs_file-hesapgr.
  PERFORM bdc_field       USING 'USE_ZAV'
                                'X'.
*/ Adres
  PERFORM bdc_dynpro      USING 'SAPMF02D' '0111'.
  IF gs_file-gv_uav EQ space.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                   '/00'.
  ELSE. "Uluslararası vers.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                   '=$VER'.
  ENDIF.

  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ADDR1_DATA-NAME1'.
  PERFORM bdc_field       USING 'ADDR1_DATA-NAME1'
                                 gs_file-ad1.
  PERFORM bdc_field       USING 'ADDR1_DATA-NAME2'
                                 gs_file-ad2.
  PERFORM bdc_field       USING 'ADDR1_DATA-SORT1'
                                 gs_file-sortl.
  PERFORM bdc_field       USING 'ADDR1_DATA-STREET'
                                 gs_file-sokak.
  PERFORM bdc_field       USING 'ADDR1_DATA-HOUSE_NUM1'
                                 gs_file-ev_no.
  PERFORM bdc_field       USING 'ADDR1_DATA-CITY2'
                                 gs_file-semt.
  PERFORM bdc_field       USING 'ADDR1_DATA-POST_CODE1'
                                 gs_file-pk.
  PERFORM bdc_field       USING 'ADDR1_DATA-PO_BOX'
                                 gs_file-po_box.
  PERFORM bdc_field       USING 'ADDR1_DATA-POST_CODE2'
                                 gs_file-post_code2.
  PERFORM bdc_field       USING 'ADDR1_DATA-CITY1'
                                 gs_file-kent.
  PERFORM bdc_field       USING 'ADDR1_DATA-COUNTRY'
                                 gs_file-ulke.
  PERFORM bdc_field       USING 'ADDR1_DATA-REGION'
                                 gs_file-bolge.
  PERFORM bdc_field       USING 'ADDR1_DATA-LANGU'
                                 gs_file-dil.
  PERFORM bdc_field       USING 'SZA1_D0100-TEL_NUMBER'
                                 gs_file-tel1.
  PERFORM bdc_field       USING 'SZA1_D0100-MOB_NUMBER'
                                 gs_file-tel2.
  PERFORM bdc_field       USING 'SZA1_D0100-FAX_NUMBER'
                                 gs_file-faks.
  PERFORM bdc_field       USING 'SZA1_D0100-SMTP_ADDR'
                                 gs_file-internetadr.
  PERFORM bdc_field       USING 'ADDR1_DATA-DEFLT_COMM'
                                'TEL'.

*/ "Uluslararası vers.
  IF gs_file-gv_uav NE space. "Uluslararası vers.
    perform bdc_dynpro using 'SAPLSPO4' '0300' .
    perform bdc_field  using 'SVALD-VALUE(01)' p_nat.

    PERFORM bdc_dynpro      USING 'SAPLSZA1' '0201'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=CONT'.
    PERFORM bdc_field       USING 'ADDR1_DATA-NAME1'
                                   gs_file-uv_ad1.
    PERFORM bdc_field       USING 'ADDR1_DATA-NAME2'
                                   gs_file-uv_ad2.
    PERFORM bdc_field       USING 'ADDR1_DATA-SORT1'
                                   gs_file-uv_sortl.
    PERFORM bdc_field       USING 'ADDR1_DATA-STREET'
                                   gs_file-uv_sokak.
    PERFORM bdc_field       USING 'ADDR1_DATA-HOUSE_NUM1'
                                   gs_file-uv_ev_no.
    PERFORM bdc_field       USING 'ADDR1_DATA-CITY1'
                                   gs_file-uv_kent.
    PERFORM bdc_field       USING 'ADDR1_DATA-CITY2'
                                   gs_file-uv_semt.
    PERFORM bdc_dynpro      USING 'SAPMF02D' '0111'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
  ENDIF.

*/
  PERFORM bdc_dynpro      USING 'SAPMF02D' '0120'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.

  PERFORM bdc_field       USING 'KNA1-VBUND'
                                 gs_file-muhatapsirket.

  PERFORM bdc_field       USING 'KNA1-STCD1'
                                 gs_file-vergidairesi.
  PERFORM bdc_field       USING 'KNA1-STCD2'
                                 gs_file-vergino.
  PERFORM bdc_field       USING 'KNA1-STCD3'
                                 gs_file-taxcode3.
  PERFORM bdc_field       USING 'KNA1-STCEG'
                                 gs_file-stceg.
  PERFORM bdc_field       USING 'KNA1-BBBNR'
                                 gs_file-bbbnr.
  PERFORM bdc_field       USING 'KNA1-BBSNR'
                                 gs_file-bbsnr.
  PERFORM bdc_field       USING 'KNA1-BUBKZ'
                                 gs_file-bubkz.
  PERFORM bdc_field       USING 'KNA1-BUBKZ'
                                 gs_file-kdv.


  PERFORM bdc_dynpro      USING 'SAPMF02D' '0125'.
  PERFORM bdc_field       USING 'KNA1-KUKLA' gs_file-kukla.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.

*-- Banka verileri
*  IF gs_file-f_bnk IS NOT INITIAL."zturan
    PERFORM bdc_dynpro USING 'SAPMF02D'         '0130'.
    PERFORM bdc_field  USING 'BDC_OKCODE'       'ENTR'.
    PERFORM bdc_field  USING 'KNBK-BANKS(01)'   gs_file-bankulke.
    PERFORM bdc_field  USING 'KNBK-BANKL(01)'   gs_file-bankanaht.
    PERFORM bdc_field  USING 'KNBK-BANKN(01)'   gs_file-bankhes.
    PERFORM bdc_field  USING 'KNBK-KOINH(01)'   gs_file-bankkessah.
    PERFORM bdc_field  USING 'KNBK-BKONT(01)'   gs_file-kk.
*  ENDIF.

      if not gs_file-iban is initial.
        perform :
            bdc_field    using  'BDC_OKCODE'  '=IBAN',
            bdc_field    using  'BDC_CURSOR'  'KNBK-BANKS(01)',
            bdc_dynpro   using  'SAPLIBMA'    '0100' .

        perform
            bdc_field    using : 'BDC_OKCODE'  '=ENTR',
                                 'BDC_CURSOR'  'IBAN01',
                                 'IBAN01'  gs_file-iban+0(4),
                                 'IBAN02'  gs_file-iban+4(4),
                                 'IBAN03'  gs_file-iban+8(4),
                                 'IBAN04'  gs_file-iban+12(4),
                                 'IBAN05'  gs_file-iban+16(4),
                                 'IBAN06'  gs_file-iban+20(4),
                                 'IBAN07'  gs_file-iban+24(4),
                                 'IBAN08'  gs_file-iban+28(4),
                                 'IBAN09'  gs_file-iban+32(2).
      endif.

  PERFORM bdc_dynpro USING 'SAPMF02D'         '0130'.
  PERFORM bdc_field  USING 'BDC_CURSOR'       'KNBK-BANKL(01)'.
  PERFORM bdc_field  USING 'BDC_OKCODE'       '=ENTR'.
* ENDIF."zturan
*--
  PERFORM bdc_dynpro USING 'SAPMF02D'         '0360'.
  PERFORM bdc_field  USING 'BDC_CURSOR'       'KNVK-NAMEV(01)'.
  PERFORM bdc_field  USING 'BDC_OKCODE'       '=ENTR'.

*--
  PERFORM bdc_dynpro USING 'SAPMF02D'         '0210'.
  PERFORM bdc_field  USING 'BDC_OKCODE'       '/00'.

  PERFORM bdc_field  USING 'KNB1-AKONT'       gs_file-mutabakathes.
  IF NOT gs_file-knrze IS INITIAL.
    PERFORM bdc_field  USING 'KNB1-KNRZE'       gs_file-knrze.
  ENDIF.
  PERFORM bdc_field  USING 'KNB1-ZUAWA'       gs_file-siralamaanaht.
  PERFORM bdc_field  USING 'KNB1-FDGRV'       gs_file-nakityon.
  PERFORM bdc_field  USING 'KNB1-VZSKZ'       gs_file-vzskz.
  PERFORM bdc_field  USING 'KNB1-ZINRT'       gs_file-zinrt.
  PERFORM bdc_field  USING 'KNB1-ALTKN'       gs_file-eskihesap.

**>>>>> added by ZTURAN 23.11.2023 17:42:02
*IF 1 = 2.
*  PERFORM bdc_dynpro USING 'SAPMF02D'         '0211'.
*  PERFORM bdc_field  USING 'BDC_OKCODE'       '/00'.
*ENDIF.
*
*
*  PERFORM bdc_field  USING 'KNA1-KDKG3'       gs_file-kdkg3.
*  PERFORM bdc_field  USING 'KNA1-KDKG5'       gs_file-kdkg5.
**>>>>> ended by ZTURAN 23.11.2023 17:42:02
**--
  PERFORM bdc_dynpro      USING 'SAPMF02D' '0215'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'KNB1-ZTERM'
                                 gs_file-odemekosulu.
  PERFORM bdc_field       USING 'KNB1-XZVER'
                                 gs_file-odemetarihcesi.
  PERFORM bdc_field       USING 'KNB1-ZWELS'
                                 gs_file-odemebicimi.
  PERFORM bdc_field       USING 'KNB1-ZAHLS'
                                 gs_file-odemeblk.
  PERFORM bdc_field       USING 'KNB1-HBKID'
                                 gs_file-anabanka.
  PERFORM bdc_dynpro      USING 'SAPMF02D' '0220'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'KNB5-MAHNA'
                                 gs_file-mahna.
  PERFORM bdc_field       USING 'KNB5-BUSAB'
                                 gs_file-busab2.
  PERFORM bdc_field       USING 'KNB5-MANSP'
                                 gs_file-mansp.
  PERFORM bdc_field       USING 'KNB1-BUSAB'
                                 gs_file-busab.
  PERFORM bdc_field       USING 'KNB1-XAUSZ'
                                 gs_file-xausz.

  PERFORM bdc_dynpro      USING 'SAPMF02D' '0230'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=UPDA'.
  DATA:lv_tcode(10).
  lv_tcode = 'FD01'.

  PERFORM bdc_transaction USING lv_tcode.

ENDFORM.                    " BDC_FD01
*&---------------------------------------------------------------------*
*&      Form  BDC_FD02
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM bdc_fd02.

  PERFORM bdc_dynpro      USING 'SAPMF02D' '0106'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'USE_ZAV'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'RF02D-KUNNR'
                                 gs_file-must_no.
  PERFORM bdc_field       USING 'RF02D-BUKRS'
                                 gs_file-bukrs.

  IF gs_file-gv = 'X' OR gs_file-gv_uav = 'X'.
    PERFORM bdc_field       USING 'RF02D-D0110'
                                  'X'.
    PERFORM bdc_field       USING 'RF02D-D0120'
                                  'X'.
    PERFORM bdc_field       USING 'RF02D-D0125'
                                  'X'.
    PERFORM bdc_field       USING 'RF02D-D0340'
                                  'X'.
    PERFORM bdc_field       USING 'RF02D-D0370'
                                  'X'.
    PERFORM bdc_field       USING 'RF02D-D0360'
                                  'X'.
  ENDIF.

  IF gs_file-f_bnk = 'X'.
    PERFORM bdc_field       USING 'RF02D-D0130'
                                  'X'.
  ENDIF.

  IF gs_file-sk = 'X'.
    PERFORM bdc_field       USING 'RF02D-D0210'
                                  'X'.
    PERFORM bdc_field       USING 'RF02D-D0215'
                                  'X'.
    PERFORM bdc_field       USING 'RF02D-D0220'
                                  'X'.
    PERFORM bdc_field       USING 'RF02D-D0230'
                                  'X'.
    PERFORM bdc_field       USING 'RF02D-D0610'
                                  'X'.
  ENDIF.

  PERFORM bdc_field       USING 'USE_ZAV'
                                'X'.

*/ Adres
  PERFORM bdc_dynpro      USING 'SAPMF02D' '0111'.
  IF gs_file-gv_uav EQ space.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                   '/00'.
  ELSE. "Uluslararası vers.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                   '=$VER'.
  ENDIF.

  IF NOT gs_file-gv IS INITIAL.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'ADDR1_DATA-NAME1'.
    PERFORM bdc_field_chg   USING 'ADDR1_DATA-NAME1'
                                   gs_file-ad1.
    PERFORM bdc_field_chg   USING 'ADDR1_DATA-NAME2'
                                   gs_file-ad2.
    PERFORM bdc_field_chg   USING 'ADDR1_DATA-SORT1'
                                   gs_file-sortl.
    PERFORM bdc_field_chg   USING 'ADDR1_DATA-STREET'
                                   gs_file-sokak.
    PERFORM bdc_field_chg   USING 'ADDR1_DATA-HOUSE_NUM1'
                                   gs_file-ev_no.
    PERFORM bdc_field_chg   USING 'ADDR1_DATA-CITY2'
                                   gs_file-semt.
    PERFORM bdc_field_chg   USING 'ADDR1_DATA-POST_CODE1'
                                   gs_file-pk.
    PERFORM bdc_field_chg   USING 'ADDR1_DATA-PO_BOX'
                                   gs_file-po_box.
    PERFORM bdc_field_chg   USING 'ADDR1_DATA-POST_CODE2'
                                   gs_file-post_code2.
    PERFORM bdc_field_chg   USING 'ADDR1_DATA-CITY1'
                                   gs_file-kent.
    PERFORM bdc_field_chg   USING 'ADDR1_DATA-COUNTRY'
                                   gs_file-ulke.
    PERFORM bdc_field_chg   USING 'ADDR1_DATA-REGION'
                                   gs_file-bolge.
    PERFORM bdc_field_chg   USING 'ADDR1_DATA-LANGU'
                                   gs_file-dil.
    PERFORM bdc_field_chg   USING 'SZA1_D0100-TEL_NUMBER'
                                   gs_file-tel1.
    PERFORM bdc_field_chg   USING 'SZA1_D0100-MOB_NUMBER'
                                   gs_file-tel2.
    PERFORM bdc_field_chg   USING 'SZA1_D0100-FAX_NUMBER'
                                   gs_file-faks.
    PERFORM bdc_field_chg   USING 'SZA1_D0100-SMTP_ADDR'
                                   gs_file-internetadr.
    PERFORM bdc_field       USING 'ADDR1_DATA-DEFLT_COMM'
                                  'TEL'.
  ENDIF.

*/ "Uluslararası vers.
  IF gs_file-gv_uav NE space. "Uluslararası vers.
    perform bdc_dynpro using 'SAPLSPO4' '0300' .
    perform bdc_field  using 'SVALD-VALUE(01)' p_nat.


    PERFORM bdc_dynpro      USING 'SAPLSZA1' '0201'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=CONT'.
    PERFORM bdc_field_chg   USING 'ADDR1_DATA-NAME1'
                                   gs_file-uv_ad1.
    PERFORM bdc_field_chg   USING 'ADDR1_DATA-NAME2'
                                   gs_file-uv_ad2.
    PERFORM bdc_field_chg   USING 'ADDR1_DATA-SORT1'
                                   gs_file-uv_sortl.
    PERFORM bdc_field_chg   USING 'ADDR1_DATA-STREET'
                                   gs_file-uv_sokak.
    PERFORM bdc_field_chg   USING 'ADDR1_DATA-HOUSE_NUM1'
                                   gs_file-uv_ev_no.
    PERFORM bdc_field_chg   USING 'ADDR1_DATA-CITY1'
                                   gs_file-uv_kent.
    PERFORM bdc_field_chg   USING 'ADDR1_DATA-CITY2'
                                   gs_file-uv_semt.
    PERFORM bdc_dynpro      USING 'SAPMF02D' '0111'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
  ENDIF.

*/
  PERFORM bdc_dynpro      USING 'SAPMF02D' '0120'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  IF NOT gs_file-gv IS INITIAL.
    PERFORM bdc_field_chg   USING 'KNA1-STCD1'
                                   gs_file-vergidairesi.
    PERFORM bdc_field_chg   USING 'KNA1-STCD2'
                                   gs_file-vergino.
    PERFORM bdc_field_chg   USING 'KNA1-STCD3'
                                   gs_file-taxcode3.
    PERFORM bdc_field_chg   USING 'KNA1-STCEG'
                                   gs_file-stceg.
    PERFORM bdc_field_chg   USING 'KNA1-BBBNR'
                                   gs_file-bbbnr.
    PERFORM bdc_field_chg   USING 'KNA1-BBSNR'
                                   gs_file-bbsnr.
    PERFORM bdc_field_chg   USING 'KNA1-BUBKZ'
                                   gs_file-bubkz.
    PERFORM bdc_field_chg   USING 'KNA1-BUBKZ'
                                   gs_file-kdv.
  ENDIF.

  PERFORM bdc_dynpro      USING 'SAPMF02D' '0125'.
  PERFORM bdc_field       USING 'KNA1-KUKLA' gs_file-kukla.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.

*-- Banka verileri
  IF gs_file-f_bnk IS NOT INITIAL.
    PERFORM bdc_dynpro      USING 'SAPMF02D' '0130'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  'ENTR'.
    PERFORM bdc_field_chg   USING 'KNBK-BANKS(01)'
                                   gs_file-bankulke.
    PERFORM bdc_field_chg   USING 'KNBK-BANKL(01)'
                                   gs_file-bankanaht.
    PERFORM bdc_field_chg   USING 'KNBK-BANKN(01)'
                                   gs_file-bankhes.
    PERFORM bdc_field_chg   USING 'KNBK-KOINH(01)'
                                   gs_file-bankkessah.
    PERFORM bdc_field_chg   USING 'KNBK-BKONT(01)'
                                   gs_file-kk.
*  ENDIF.
      if not gs_file-iban is initial.
        perform :
            bdc_field    using  'BDC_OKCODE'  '=IBAN',
            bdc_field    using  'BDC_CURSOR'  'KNBK-BANKS(01)',
            bdc_dynpro   using  'SAPLIBMA'    '0100' .

        perform
            bdc_field    using : 'BDC_OKCODE'  '=ENTR',
                                 'BDC_CURSOR'  'IBAN01',
                                 'IBAN01'  gs_file-iban+0(4),
                                 'IBAN02'  gs_file-iban+4(4),
                                 'IBAN03'  gs_file-iban+8(4),
                                 'IBAN04'  gs_file-iban+12(4),
                                 'IBAN05'  gs_file-iban+16(4),
                                 'IBAN06'  gs_file-iban+20(4),
                                 'IBAN07'  gs_file-iban+24(4),
                                 'IBAN08'  gs_file-iban+28(4),
                                 'IBAN09'  gs_file-iban+32(2).
      endif.


  PERFORM bdc_dynpro      USING 'SAPMF02D' '0130'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'KNBK-BANKL(01)'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ENTR'.
endif.

  PERFORM bdc_dynpro      USING 'SAPMF02D' '0360'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'KNVK-NAMEV(01)'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ENTR'.

  PERFORM bdc_dynpro      USING 'SAPMF02D' '0210'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.

*/ Şirket kodu verileri
  IF NOT gs_file-sk IS INITIAL.
    PERFORM bdc_field_chg   USING 'KNB1-AKONT'
                                   gs_file-mutabakathes.
    IF NOT gs_file-knrze IS INITIAL.
      PERFORM bdc_field  USING 'KNB1-KNRZE'       gs_file-knrze.
    ENDIF.
    PERFORM bdc_field_chg   USING 'KNB1-ZUAWA'
                                   gs_file-siralamaanaht.
    PERFORM bdc_field_chg   USING 'KNB1-FDGRV'
                                   gs_file-nakityon.
    PERFORM bdc_field_chg   USING 'KNB1-VZSKZ'
                                   gs_file-vzskz.
    PERFORM bdc_field_chg   USING 'KNB1-ZINRT'
                                   gs_file-zinrt.
    PERFORM bdc_field_chg   USING 'KNB1-ALTKN'
                                   gs_file-eskihesap.
  ENDIF.

  PERFORM bdc_dynpro      USING 'SAPMF02D' '0215'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  IF NOT gs_file-sk IS INITIAL.
    PERFORM bdc_field_chg   USING 'KNB1-ZTERM'
                                   gs_file-odemekosulu.
    PERFORM bdc_field_chg   USING 'KNB1-XZVER'
                                   gs_file-odemetarihcesi.
    PERFORM bdc_field_chg   USING 'KNB1-ZWELS'
                                   gs_file-odemebicimi.
    PERFORM bdc_field_chg   USING 'KNB1-ZAHLS'
                                   gs_file-odemeblk.
    PERFORM bdc_field_chg   USING 'KNB1-HBKID'
                                   gs_file-anabanka.
  ENDIF.

  PERFORM bdc_dynpro      USING 'SAPMF02D' '0220'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  IF NOT gs_file-sk IS INITIAL.
    PERFORM bdc_field_chg   USING 'KNB5-MAHNA'
                                   gs_file-mahna.
    PERFORM bdc_field_chg   USING 'KNB5-BUSAB'
                                   gs_file-busab2.
    PERFORM bdc_field_chg   USING 'KNB5-MANSP'
                                   gs_file-mansp.
    PERFORM bdc_field_chg   USING 'KNB1-BUSAB'
                                   gs_file-busab.
    PERFORM bdc_field_chg   USING 'KNB1-XAUSZ'
                                   gs_file-xausz.
  ENDIF.

  PERFORM bdc_dynpro      USING 'SAPMF02D' '0230'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=UPDA'.

  DATA:lv_tcode(10).
  lv_tcode = 'FD02'.

  PERFORM bdc_transaction USING lv_tcode.

ENDFORM.                    "BDC_FD02
*&---------------------------------------------------------------------*
*&      Form  bdc_dynpro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PROGRAM    text
*      -->DYNPRO     text
*----------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.
ENDFORM.                    "bdc_dynpro
*&---------------------------------------------------------------------*
*&      Form  bdc_field
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FNAM       text
*      -->FVAL       text
*----------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  IF fval <> nodata.
    CLEAR bdcdata.
    bdcdata-fnam = fnam.
    bdcdata-fval = fval.
    APPEND bdcdata.
  ENDIF.
ENDFORM.                    "bdc_field
*&---------------------------------------------------------------------*
*&      Form  bdc_field_chg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FNAM       text
*      -->FVAL       text
*----------------------------------------------------------------------*
FORM bdc_field_chg USING fnam fval.
  IF fval EQ space.
    RETURN.
  ELSEIF fval EQ c_space.
    CLEAR bdcdata.
    bdcdata-fnam = fnam.
    bdcdata-fval = space.
    APPEND bdcdata.
  ELSE.
    IF fval <> nodata.
      CLEAR bdcdata.
      bdcdata-fnam = fnam.
      bdcdata-fval = fval.
      APPEND bdcdata.
    ENDIF.
  ENDIF.
ENDFORM.                    "bdc_field_chg
*&---------------------------------------------------------------------*
*&      Form  bdc_transaction
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->TCODE      text
*----------------------------------------------------------------------*
FORM bdc_transaction USING tcode.

  DATA: l_subrc LIKE sy-subrc.

  IF NOT session IS INITIAL.
    CALL FUNCTION 'BDC_INSERT'
      EXPORTING
        tcode     = tcode
      TABLES
        dynprotab = bdcdata.
  ELSE.
    REFRESH messtab.
    CALL TRANSACTION tcode USING bdcdata
                     MODE   ctumode
                     UPDATE cupdate
                     MESSAGES INTO messtab.
    l_subrc = sy-subrc.

*/ Değişiklikte sistem mesajı müşteri numarasını vermiyor,
*/ Her mesajın ilk satırına eklendi.
    CASE tcode.
      WHEN 'FD01'.
        PERFORM msg_add USING gv_probclass
                              'S'
                              'ZSD01'
                              '010'
                              gs_file-int_number
                              space
                              space
                              space.
      WHEN 'FD02'.
        PERFORM msg_add USING gv_probclass
                              'S'
                              'ZSD01'
                              '009'
                              gs_file-must_no
                              space
                              space
                              space.
    ENDCASE.
    LOOP AT messtab.
      PERFORM msg_add USING gv_probclass
                            messtab-msgtyp
                            messtab-msgid
                            messtab-msgnr
                            messtab-msgv1
                            messtab-msgv2
                            messtab-msgv3
                            messtab-msgv4.
    ENDLOOP.
*/ Dahili no - müşteri no eşleşmesi
    IF tcode EQ 'FD01'.
      LOOP AT messtab WHERE msgtyp EQ 'S'
                        AND msgid  EQ 'F2'
                        AND msgnr  EQ '171'.
        gt_rel-int_number = gs_file-int_number.
        gt_rel-must_no    = messtab-msgv1.
        SHIFT gt_rel-must_no LEFT DELETING LEADING '0'.
        APPEND gt_rel.
      ENDLOOP.
    ENDIF.
  ENDIF.

  CLEAR: bdcdata, bdcdata[].

ENDFORM.                    "bdc_transaction
*&---------------------------------------------------------------------*
*&      Form  add_message_tab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_MSGTY    text
*      -->P_MSGID    text
*      -->P_MSGNO    text
*      -->P_MSGV1    text
*      -->P_MSGV2    text
*      -->P_MSGV3    text
*      -->P_MSGV4    text
*----------------------------------------------------------------------*
FORM add_message_tab USING p_msgty p_msgid p_msgno
                       p_msgv1 p_msgv2 p_msgv3 p_msgv4.
  DATA: lv_cnt TYPE i.
  DESCRIBE TABLE gt_message_tab LINES lv_cnt.
  ADD 1 TO lv_cnt.
  gs_message_tab-msgty = p_msgty.
  gs_message_tab-msgid = p_msgid.
  gs_message_tab-msgno = p_msgno.
  gs_message_tab-lineno = lv_cnt.
  gs_message_tab-msgv1 = p_msgv1.
  gs_message_tab-msgv2 = p_msgv2.
  gs_message_tab-msgv3 = p_msgv3.
  gs_message_tab-msgv4 = p_msgv4.
  APPEND gs_message_tab TO gt_message_tab.
  CLEAR gs_message_tab.
ENDFORM.                    "ADD_MESSAGE_TAB
*&---------------------------------------------------------------------*
*&      Form  MESSAGES_SHOW_AS_POPUP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM messages_show_as_popup.
  IF NOT gt_message_tab[] IS INITIAL.
    CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
      TABLES
        i_message_tab = gt_message_tab.
  ENDIF.
ENDFORM.                    "messages_show_as_popup
"MESSAGES_SHOW_AS_POPUP
*&---------------------------------------------------------------------*
*&      Form  conversion_exit_alpha_input
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_KUNNR    text
*----------------------------------------------------------------------*
FORM conversion_exit_alpha_input  CHANGING p_kunnr LIKE kna1-kunnr.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_kunnr
    IMPORTING
      output = p_kunnr.
ENDFORM.                    "conversion_exit_alpha_input
*&---------------------------------------------------------------------*
*&      Form  log_create
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_EXTNUMBER  text
*      -->P_OBJECT     text
*      -->P_SUBOBJECT  text
*----------------------------------------------------------------------*
FORM log_create  USING  p_extnumber
                        p_object
                        p_subobject.

  CLEAR: gs_log, gv_log_handle.
  gs_log-extnumber = p_extnumber.
  gs_log-object    = p_object.
  gs_log-subobject = p_subobject.
  gs_log-aldate    = sy-datum.
  gs_log-altime    = sy-uzeit.
  gs_log-aluser    = sy-uname.
  gs_log-alprog    = sy-repid.

  CALL FUNCTION 'BAL_LOG_CREATE'
    EXPORTING
      i_s_log                 = gs_log
    IMPORTING
      e_log_handle            = gv_log_handle
    EXCEPTIONS
      log_header_inconsistent = 1
      OTHERS                  = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    "log_create
*&---------------------------------------------------------------------*
*&      Form  msg_add
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->VALUE          text
*      -->(P_PROBCLASS)  text
*      -->VALUE          text
*      -->(P_MSGTY)      text
*      -->VALUE          text
*      -->(P_MSGID)      text
*      -->VALUE          text
*      -->(P_MSGNO)      text
*      -->VALUE          text
*      -->(P_MSGV1)      text
*      -->VALUE          text
*      -->(P_MSGV2)      text
*      -->VALUE          text
*      -->(P_MSGV3)      text
*      -->VALUE          text
*      -->(P_MSGV4)      text
*----------------------------------------------------------------------*
FORM msg_add USING value(p_probclass) TYPE bal_s_msg-probclass
                   value(p_msgty)
                   value(p_msgid)
                   value(p_msgno)
                   value(p_msgv1)
                   value(p_msgv2)
                   value(p_msgv3)
                   value(p_msgv4).

  DATA: l_s_msg TYPE bal_s_msg.

* define data of message for Application Log
  gs_msg-probclass = p_probclass.
  gs_msg-msgty     = p_msgty.
  gs_msg-msgid     = p_msgid.
  gs_msg-msgno     = p_msgno.
  gs_msg-msgv1     = p_msgv1.
  gs_msg-msgv2     = p_msgv2.
  gs_msg-msgv3     = p_msgv3.
  gs_msg-msgv4     = p_msgv4.

* add this message to log file
* (I_LOG_HANDLE is not specified, we want to add to the default log.
*  If it does not exist we do not care =>EXCEPTIONS log_not_found = 0)
  CALL FUNCTION 'BAL_LOG_MSG_ADD'
    EXPORTING
      i_log_handle  = gv_log_handle
      i_s_msg       = gs_msg
    EXCEPTIONS
      log_not_found = 0
      OTHERS        = 1.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    "msg_add
*&---------------------------------------------------------------------*
*&      Form  LOG_WRITE_DB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM log_write_db.

  DATA: lt_lognum TYPE TABLE OF balnri WITH HEADER LINE.

  CALL FUNCTION 'APPL_LOG_WRITE_DB'
    EXPORTING
      object                = gv_object
      subobject             = gv_subobject
      log_handle            = gv_log_handle
    TABLES
      object_with_lognumber = lt_lognum
    EXCEPTIONS
      object_not_found      = 1
      subobject_not_found   = 2
      internal_error        = 3
      OTHERS                = 4.

ENDFORM.                    " LOG_WRITE_DB
*&---------------------------------------------------------------------*
*&      Form  log_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM log_display.

  CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
    EXCEPTIONS
      profile_inconsistent = 1
      internal_error       = 2
      no_data_available    = 3
      no_authority         = 4
      OTHERS               = 5.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    "log_display
*&---------------------------------------------------------------------*
*&      Form  CUST_MSG_ADD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cust_msg_add.

  DATA: lv_first(10),
        lv_last(10),
        lv_lines(10).

  lv_first = gv_first.
  lv_last  = gv_last.
  lv_lines = gv_lines.
  CONDENSE: lv_first, lv_last, lv_lines.

  PERFORM msg_add USING gv_probclass 'S' 'ZSD01' '006'
                        space space space space.

  PERFORM msg_add USING gv_probclass 'S' 'ZSD01' '001'
                        space space space space.

  PERFORM msg_add USING gv_probclass 'S' 'ZSD01' '002'
                        lv_first lv_last space space.

  PERFORM msg_add USING gv_probclass 'S' 'ZSD01' '005'
                        lv_lines space space space.

  PERFORM msg_add USING gv_probclass 'S' 'ZSD01' '006'
                        space space space space.

  IF NOT gt_rel[] IS INITIAL.
    PERFORM msg_add USING gv_probclass 'S' 'ZSD01' '006'
                          space space space space.
    PERFORM msg_add USING gv_probclass 'S' 'ZSD01' '011'
                          space space space space.
    LOOP AT gt_rel.
      PERFORM msg_add USING gv_probclass 'S' 'ZSD01' '012'
                            gt_rel-int_number gt_rel-must_no space space.
    ENDLOOP.
    PERFORM msg_add USING gv_probclass 'S' 'ZSD01' '006'
                          space space space space.
  ENDIF.

ENDFORM.                    " CUST_MSG_ADD
*&---------------------------------------------------------------------*
*&      Form  SEL_SCR_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sel_scr_output.

  CLEAR gs_obj.
  gs_obj-objtype = c_objtype.

  SELECT SINGLE name
    INTO gs_obj-objkey
    FROM trdir
   WHERE name EQ sy-repid.

  CREATE OBJECT gr_manager
    EXPORTING
      is_object        = gs_obj
      ip_no_commit     = space
    EXCEPTIONS
      object_invalid   = 1
      callback_invalid = 2
      OTHERS           = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " SEL_SCR_OUTPUT
