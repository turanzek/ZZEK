*&---------------------------------------------------------------------*
*&  Include           ZSD_FD01_TOP
*&---------------------------------------------------------------------*
*       Batchinputdata of single transaction
DATA:   bdcdata LIKE bdcdata OCCURS 0 WITH HEADER LINE.
*       messages of call transaction
DATA:   messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
DATA:   nodata TYPE c VALUE '/'.

*/ Selection screen >
PARAMETERS: p_file LIKE rlgrap-filename DEFAULT 'C:\' OBLIGATORY,
            p_start TYPE n LENGTH 6 OBLIGATORY DEFAULT 1,
            p_end TYPE n LENGTH 6 OBLIGATORY DEFAULT 999999.

SELECTION-SCREEN SKIP 1.
PARAMETERS p_nat LIKE tsadv-nation.
SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS session RADIOBUTTON GROUP ctu.  "create session
SELECTION-SCREEN COMMENT 3(20) text-s07 FOR FIELD session.
SELECTION-SCREEN POSITION 45.
PARAMETERS ctu RADIOBUTTON GROUP  ctu.     "call transaction
SELECTION-SCREEN COMMENT 48(20) text-s08 FOR FIELD ctu.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 3(20) text-s01 FOR FIELD group.
SELECTION-SCREEN POSITION 25.
PARAMETERS group(12) DEFAULT 'ZSD_MUS_FD0X' OBLIGATORY. "group name of session
SELECTION-SCREEN COMMENT 48(20) text-s05 FOR FIELD ctumode.
SELECTION-SCREEN POSITION 70.
PARAMETERS ctumode LIKE ctu_params-dismode DEFAULT 'N' OBLIGATORY.
"A: show all dynpros
"E: show dynpro on error only
"N: do not display dynpro
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 48(20) text-s06 FOR FIELD cupdate.
SELECTION-SCREEN POSITION 70.
PARAMETERS cupdate LIKE ctu_params-updmode DEFAULT 'L' OBLIGATORY.
"S: synchronously
"A: asynchronously
"L: local
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(80) text-s12.
SELECTION-SCREEN END OF LINE.
*/ Selection screen <

CONSTANTS: c_objtype TYPE borident-objtype VALUE 'ZGOS'.
DATA: gr_manager TYPE REF TO cl_gos_manager,
      gs_obj TYPE borident.

TYPE-POOLS: esp1.
DATA: gv_lineno TYPE mesg-zeile,
      gt_message_tab TYPE esp1_message_tab_type,
      gs_message_tab TYPE LINE OF esp1_message_tab_type.

DATA: gs_log TYPE bal_s_log,
      gs_msg TYPE bal_s_msg,
      gv_probclass TYPE bal_s_msg-probclass VALUE '1',
      gv_log_handle TYPE balloghndl,
      gv_object LIKE balhdr-object VALUE 'ZMUSTERI',
      gv_subobject LIKE balhdr-subobject VALUE 'FD0X',
      gv_lines TYPE i,
      gv_first TYPE i,
      gv_last  TYPE i,
      gv_kunnr TYPE kna1-kunnr.

CONSTANTS: c_space TYPE c VALUE '/'.

DATA: BEGIN OF gs_file,
        int_number TYPE char20,
        must_no TYPE kunnr,
        gv TYPE mark,
        gv_uav TYPE mark,
        f_bnk,"banka verileri kontrol flag
        sk TYPE mark,
        hesapgr LIKE kna1-ktokd,
        bukrs LIKE rf02d-bukrs,
        ad1 LIKE adrc-name1,
        ad2 LIKE adrc-name2,
        sortl LIKE addr1_data-sort1,
        sokak LIKE addr1_data-street,
        ev_no LIKE adrc-house_num1,
        pk LIKE kna1-pstlz,
        post_code2 LIKE addr1_data-post_code2,
        po_box LIKE addr1_data-po_box,
        kent LIKE kna1-ort01,
        semt LIKE kna1-ort02,
        ulke LIKE kna1-land1,
        bolge LIKE kna1-regio,
        dil(2),
        tel1 LIKE kna1-telf1,
        faks LIKE kna1-telfx,
        tel2 LIKE kna1-telf2,
        internetadr LIKE adr6-smtp_addr,
        kdkg3 LIKE kna1-kdkg3,
        kdkg5 LIKE kna1-kdkg5,
        kukla LIKE kna1-kukla,
        uv_ad1 LIKE addr1_data-name1,
        uv_sortl LIKE addr1_data-sort1,
        uv_ad2 LIKE addr1_data-name1,
        uv_sokak LIKE addr1_data-street,
        uv_ev_no LIKE addr1_data-house_num1,
        uv_pk  LIKE addr1_data-post_code1,
        uv_kent LIKE addr1_data-city1,
        uv_semt LIKE addr1_data-city2,
        bbbnr(7), "LIKE kna1-bbbnr,
        bbsnr(7),  "LIKE kna1-bbsnr,
        bubkz(1),  "LIKE kna1-bubkz,
        musterino LIKE kna1-kunnr,
        muhatapsirket LIKE kna1-vbund,
        vergidairesi LIKE kna1-stcd1,
        vergino LIKE kna1-stcd2,
        taxcode3 LIKE kna1-stcd3,
        stceg LIKE kna1-stceg,
        kdv LIKE kna1-stkzu,
        bankulke LIKE knbk-banks,
        bankanaht LIKE knbk-bankl,
        bankhes LIKE knbk-bankn,
        bankkessah LIKE knbk-koinh,
        kk LIKE knbk-bkont,
        iban LIKE tiban-iban,
        mutabakathes LIKE knb1-akont,
        siralamaanaht LIKE knb1-zuawa,
        nakityon LIKE knb1-fdgrv,
        vzskz LIKE knb1-vzskz,
        zinrt(2),  "LIKE knb1-zinrt,
        eskihesap LIKE knb1-altkn,
        odemekosulu LIKE knb1-zterm,
        odemetarihcesi LIKE knb1-xzver,
        odemebicimi LIKE knb1-zwels,
        odemeblk LIKE knb1-zahls,
        anabanka LIKE knb1-hbkid,
        mahna LIKE knb5-mahna,
        busab2 LIKE knb5-busab,
        mansp LIKE knb5-mansp,
        busab LIKE knb1-busab,
        xausz LIKE knb1-xausz,
        knrze LIKE knb1-knrze,
      END OF gs_file,
      BEGIN OF gs_rel,
        int_number TYPE char20,
        must_no TYPE kunnr,
      END OF gs_rel.

DATA: gt_file LIKE TABLE OF gs_file WITH HEADER LINE,
      gt_rel LIKE TABLE OF gs_rel WITH HEADER LINE.
