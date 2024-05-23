*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZZEK_T_CARDATA..................................*
DATA:  BEGIN OF STATUS_ZZEK_T_CARDATA                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZZEK_T_CARDATA                .
*.........table declarations:.................................*
TABLES: *ZZEK_T_CARDATA                .
TABLES: ZZEK_T_CARDATA                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
