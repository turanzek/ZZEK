*&---------------------------------------------------------------------*
*& Report ZZEK_DOWNLOAD_EXCEL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zzek_download_excel.


DATA binary_content TYPE solix_tab.

DATA :BEGIN OF ls_xls_cell,
        styleid      TYPE string,
        type         TYPE string,
        cell_content TYPE string,
      END OF ls_xls_cell,

      li_xls_cells LIKE TABLE OF ls_xls_cell,

      BEGIN OF ls_column_width,
        col_index TYPE i,
        col_width TYPE i,
      END OF ls_column_width ,

      li_column_width LIKE TABLE OF ls_column_width,

      BEGIN OF ls_xls_row,
        rownr    TYPE i,
        rowhight TYPE i,
        cells    LIKE li_xls_cells,
      END OF ls_xls_row  ,

      li_xls_row  LIKE TABLE OF ls_xls_row, "sheet1
      li_xls_row2 LIKE TABLE OF ls_xls_row, "sheet2
      li_xls_row3 LIKE TABLE OF ls_xls_row. "sheet3


DATA : BEGIN OF sheets ,
         sheetname TYPE string,
         sheetx    LIKE  li_xls_row,
         colwidth  LIKE li_column_width,
       END OF sheets ,

       it_sheets LIKE TABLE OF sheets.

DATA : lv_xml_string TYPE xstring,

       BEGIN OF ls_documentproperties,
         author TYPE string,
       END OF ls_documentproperties,

       BEGIN OF ls_font,
         family    TYPE string VALUE 'Swiss',
         fontname  TYPE string VALUE 'Arial',
         font_size TYPE i VALUE 10,
         color     TYPE string,
         bold      TYPE char1,
         italic    TYPE char1,
         underline TYPE string,
       END OF ls_font,

       BEGIN OF ls_alignment ,
         horizontal TYPE char10 , "VALUE 'Left',
         vertical   TYPE char10 , "VALUE 'Bottom',
         wraptext   TYPE char1,
       END OF ls_alignment ,

       BEGIN OF ls_border_face,
         top    TYPE string,
         bottom TYPE string,
         left   TYPE string,
         right  TYPE string,
       END OF ls_border_face,

       BEGIN OF ls_border,
         linestyle LIKE ls_border_face,
         weight    TYPE char1,
         color     LIKE ls_border_face,
       END OF ls_border,

       BEGIN OF ls_interior,
         colorindex        TYPE string,
         pattern           TYPE string,
         patterncolorindex TYPE string,
       END OF ls_interior,

       BEGIN OF ls_style,
         id        TYPE string,
         font      LIKE ls_font,
         alignment LIKE ls_alignment,
         border    LIKE ls_border,
         interior  LIKE ls_interior,
       END OF ls_style,

       BEGIN OF ls_excelmeta,
         documentproperties LIKE ls_documentproperties,
         styles             LIKE TABLE OF ls_style,
       END OF ls_excelmeta .",


ls_excelmeta-documentproperties-author = sy-uname.

* SET THE HEADER STYLE
***********includes all Excel style formatting
CLEAR: ls_style.
ls_style-id = 's21'.    " Style 1 for includes all formatting
ls_style-font-family = 'Script' ."'Swiss'.
*ls_style-font-fontname  = 'Ink Free' .
ls_style-font-bold = '1'.
ls_style-font-italic = '0'.
*ls_style-font-underline = 'Single' . " 'Double' .
ls_style-font-color = '#000000' .

ls_style-alignment-horizontal = 'Center' .
ls_style-alignment-vertical = 'Center' .
ls_style-alignment-wraptext = '1' .

*
ls_style-border-linestyle-bottom =
ls_style-border-linestyle-top =
ls_style-border-linestyle-left =
ls_style-border-linestyle-right = 'SlantDashDot'. "'Continuous' . "'SlantDashDot' "'DashDotDot "'Double' "'DashDot'  ..
ls_style-border-weight = '1'.

APPEND ls_style TO ls_excelmeta-styles.
*

********************* Border design and formatting
*********************** Border with all DashDotDot and diff col
CLEAR: ls_style.
ls_style-id = 'b21'.
ls_style-border-linestyle-bottom = 'DashDotDot'.
ls_style-border-linestyle-top = 'DashDotDot'.
ls_style-border-linestyle-left = 'DashDotDot'.
ls_style-border-linestyle-right = 'DashDotDot'.
ls_style-border-weight = '2'.
ls_style-border-color-top = '#7030A0' .
ls_style-border-color-bottom = '#7030A0' .
ls_style-border-color-left = '#7030A0' .
ls_style-border-color-right = '#7030A0' .
APPEND ls_style TO ls_excelmeta-styles.

*********************** Border with bottom and right double and top DashDotDot and diff col
CLEAR: ls_style.
ls_style-id = 'b22'.
ls_style-border-linestyle-bottom = 'Double'.
ls_style-border-linestyle-top = 'DashDotDot'.
*    ls_style-border-linestyle-left = 'Double'.
ls_style-border-linestyle-right = 'Double'.
ls_style-border-weight = '2'.
ls_style-border-color-top = '#00B0F0' .
ls_style-border-color-bottom = '#00B0F0' .
ls_style-border-color-left = '#00B0F0' .
ls_style-border-color-right = '#00B0F0' .
APPEND ls_style TO ls_excelmeta-styles.

*********************** Border with all DashDot and diff col
CLEAR: ls_style.
ls_style-id = 'b23'.
ls_style-border-linestyle-bottom =
ls_style-border-linestyle-top =
ls_style-border-linestyle-left =
ls_style-border-linestyle-right = 'DashDot'. "'Continuous' . "'SlantDashDot' "'DashDotDot "'Double' "'DashDot'  ..
ls_style-border-weight = '2'.
ls_style-border-color-top = '#7030A0' .
ls_style-border-color-bottom = '#7030A0' .
ls_style-border-color-left = '#7030A0' .
ls_style-border-color-right = '#7030A0' .
APPEND ls_style TO ls_excelmeta-styles.



********************** Interior cell formatting
********************** Cell With pattern without colour
CLEAR: ls_style.
ls_style-id = 'I21'.
*    ls_style-interior-colorindex   = '#FFFFF1'.
ls_style-interior-pattern = 'HorzStripe'.
ls_style-interior-patterncolorindex = '#FF0000'.
APPEND ls_style TO ls_excelmeta-styles.

********************** Cell With pattern without colour
CLEAR: ls_style.
ls_style-id = 'I22'.
*    ls_style-interior-colorindex   = '#FFFFF1'.
ls_style-interior-pattern = 'ThinHorzCross'.
ls_style-interior-patterncolorindex = '#FF0000'.
APPEND ls_style TO ls_excelmeta-styles.

********************** Cell With pattern with colour
CLEAR: ls_style.
ls_style-id = 'I23'.
ls_style-font-font_size = 24 .
ls_style-interior-colorindex   = '#F5909C'.
ls_style-interior-pattern = 'ThinHorzCross'.
ls_style-interior-patterncolorindex = '#7030A0'.
APPEND ls_style TO ls_excelmeta-styles.





******************** installed_base sheet*******
CLEAR ls_xls_row.
********************************* Create Header for Excel output **************************************************

ls_xls_cell-type = 'String'.
ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s01.
APPEND ls_xls_cell TO ls_xls_row-cells.
*
ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s02.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s03.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s04.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s05.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s06.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s07.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s08.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s09.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s10.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s11.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s12.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s13.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s14.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s15.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s16.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s17.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s18.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s19.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s20.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s21.
APPEND ls_xls_cell TO ls_xls_row-cells.


ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s22.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s23.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s24.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s25.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s26.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s27.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s28.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s29.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s30.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s31.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s32.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s33.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s34.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s35.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s36.
APPEND ls_xls_cell TO ls_xls_row-cells.


ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s37.
APPEND ls_xls_cell TO ls_xls_row-cells.


ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s38.
APPEND ls_xls_cell TO ls_xls_row-cells.


ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s39.
APPEND ls_xls_cell TO ls_xls_row-cells.


ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s40.
APPEND ls_xls_cell TO ls_xls_row-cells.


ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s41.
APPEND ls_xls_cell TO ls_xls_row-cells.


ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s42.
APPEND ls_xls_cell TO ls_xls_row-cells.


ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s43.
APPEND ls_xls_cell TO ls_xls_row-cells.


ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s44.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s45.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s46.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s47.
APPEND ls_xls_cell TO ls_xls_row-cells.


ls_xls_row-rowhight = 105 . " Row 1 Hight will be 100
APPEND ls_xls_row TO li_xls_row.
CLEAR ls_xls_cell-cell_content.
CLEAR ls_xls_row.



***************************** sheet 2 text*********************
ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s48.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s49.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s50.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s51.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s52.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_row-rowhight = 105 . " Row 1 Hight will be 100
APPEND ls_xls_row TO li_xls_row2.
CLEAR ls_xls_cell-cell_content.
CLEAR ls_xls_row.




********SHEET 3 TEXT ************

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-S01.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-S49.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s50.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s53.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s54.
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_cell-styleid = 's21'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-cell_content = TEXT-s55.
APPEND ls_xls_cell TO ls_xls_row-cells.


ls_xls_row-rowhight = 105 . " Row 1 Hight will be 100
APPEND ls_xls_row TO li_xls_row3.
CLEAR ls_xls_cell-cell_content.
CLEAR ls_xls_row.




" numarayı eğer string version ilede yazabiliriz. " DATA DOLDURMA ...

ls_xls_cell-styleid = 'Default'.
CLEAR ls_xls_cell-cell_content.
ls_xls_cell-type = 'Number'.
ls_xls_cell-cell_content = '0002345677' .
APPEND ls_xls_cell TO ls_xls_row-cells.

ls_xls_row-rowhight = 25 .
APPEND ls_xls_row TO li_xls_row.
CLEAR ls_xls_cell-cell_content.
CLEAR ls_xls_row.




DATA : lv_index TYPE i VALUE '1' .
" kolonların genişliğini ayarladığımız kod.

DO 47 TIMES.

  ls_column_width-col_index = lv_index .
  ls_column_width-col_width = 150 .
  APPEND ls_column_width TO li_column_width .

  lv_index = lv_index + 1.
ENDDO.


sheets-colwidth = li_column_width .

sheets-sheetx = li_xls_row .
sheets-sheetname =  'Installed Base  ' .
TRANSLATE sheets-sheetname TO UPPER CASE .
APPEND  sheets TO it_sheets.
CLEAR sheets.
*CLEAR lv_index.


********installed base description hazırlık.

DO 5 TIMES.

  ls_column_width-col_index = lv_index .
  ls_column_width-col_width = 150 .
  APPEND ls_column_width TO li_column_width .

  lv_index = lv_index + 1.
ENDDO.


sheets-colwidth = li_column_width .

sheets-sheetx = li_xls_row2 .
sheets-sheetname =  'Installed Base Description' .
TRANSLATE sheets-sheetname TO UPPER CASE .
APPEND  sheets TO it_sheets.
CLEAR sheets.


DO 5 TIMES.

  ls_column_width-col_index = lv_index .
  ls_column_width-col_width = 150 .
  APPEND ls_column_width TO li_column_width .

  lv_index = lv_index + 1.
ENDDO.


sheets-colwidth = li_column_width .

sheets-sheetx = li_xls_row3 .
sheets-sheetname =  'Installed Base Other Parties' .
TRANSLATE sheets-sheetname TO UPPER CASE .
APPEND  sheets TO it_sheets.
CLEAR sheets.

CALL TRANSFORMATION zexcel_xml_trans
      SOURCE excelmeta = ls_excelmeta
             sheets = it_sheets
      RESULT XML  lv_xml_string.


CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
  EXPORTING
    buffer     = lv_xml_string
  TABLES
    binary_tab = binary_content.




DATA : filename TYPE string .

CONCATENATE  'C:\TestExcel' '\Excel_sheet_' sy-datum '_' sy-uzeit '.XLS' INTO filename .

CONDENSE filename .

CALL FUNCTION 'GUI_DOWNLOAD'
  EXPORTING
    filename = filename
    filetype = 'BIN'
  TABLES
    data_tab = binary_content.
