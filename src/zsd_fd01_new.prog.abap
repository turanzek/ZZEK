*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZSD_FD01
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zsd_fd01_new.

INCLUDE ZSD_FD01_NEW_TOP.
INCLUDE ZSD_FD01_NEW_FRM.


AT SELECTION-SCREEN.
  PERFORM check_authority.

AT SELECTION-SCREEN OUTPUT.
  PERFORM sel_scr_output.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_filename.

START-OF-SELECTION.
  PERFORM upload_data_xls_to_sap.
  PERFORM start_batch.
