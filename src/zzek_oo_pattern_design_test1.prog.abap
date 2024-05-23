*&---------------------------------------------------------------------*
*& Report ZZEK_OO_PATTERN_DESIGN_TEST1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zzek_oo_pattern_design_test1.
DATA: lo_tutorial TYPE REF TO zcl_oo_tutorial_1.
CREATE OBJECT lo_tutorial .
DATA:ls_import TYPE string.
DATA:ls_export TYPE string.
DATA: fault      TYPE REF TO cx_root. " Generic Fault
ls_import = 'Hello'.
TRY.
    CALL METHOD lo_tutorial->my_first_method
      EXPORTING
        import = ls_import
      RECEIVING
        export = ls_export.

  CATCH cx_root INTO fault.

ENDTRY.

TRY.

*  CALL METHOD lo_tutorial->if_oo_adt_classrun~main
*    EXPORTING
*      out    = ls_export
*      .

  CATCH cx_root INTO fault.

ENDTRY.

BREAK-POINT.
