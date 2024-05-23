FUNCTION ZDENEME.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_PLATE) TYPE  CHAR10 OPTIONAL
*"  TABLES
*"      ET_DATA STRUCTURE  ZZEK_T_CARDATA OPTIONAL
*"----------------------------------------------------------------------

    SELECT *
      FROM ZZEK_T_CARdata
       INTO CORRESPONDING FIELDS OF TABLE et_data
       WHERE plate = i_plate.

ENDFUNCTION.
