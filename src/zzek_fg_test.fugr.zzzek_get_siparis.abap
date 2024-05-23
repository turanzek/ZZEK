FUNCTION ZZZEK_GET_SIPARIS.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_MAX) TYPE  I DEFAULT 0
*"     VALUE(IR_VBELN) TYPE  RANGE_VBELN_VA_TAB OPTIONAL
*"  TABLES
*"      ET_DATA STRUCTURE  ZZEK_S_SIPB
*"----------------------------------------------------------------------

    SELECT a~*,
           b~bezei
      FROM ZZEK_T_SIPB as a
      INNER JOIN tvakt as b on b~auart = a~auart
                            and b~spras = @sy-langu
       INTO CORRESPONDING FIELDS OF TABLE @et_data.

*      select

*      LOOP AT et_data ASSIGNING FIELD-SYMBOL(<fs_data>).
*        SELECT
*
*      ENDLOOP.

ENDFUNCTION.
