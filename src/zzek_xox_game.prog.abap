*&---------------------------------------------------------------------*
*& Report ZZEK_XOX_GAME
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZZEK_XOX_GAME.
TYPES c4(4) TYPE c.


CLASS cl_gobang DEFINITION.
  PUBLIC SECTION.
    DATA: mo_qp TYPE REF TO cl_salv_table.
    CONSTANTS:border_ins TYPE c4 VALUE icon_border_inside."border
    CONSTANTS:player_wht TYPE c4 VALUE icon_incomplete.
    CONSTANTS:player_bak TYPE c4 VALUE icon_dummy.
    DATA:step TYPE p VALUE 0.
    DATA :BEGIN OF wa_qp,
            c100 TYPE c4, "border
            c101 TYPE c4,c102 TYPE c4,c103 TYPE c4,c104 TYPE c4,c105 TYPE c4,
            c106 TYPE c4,c107 TYPE c4,c108 TYPE c4,c109 TYPE c4,c110 TYPE c4,
            c111 TYPE c4,c112 TYPE c4,c113 TYPE c4,c114 TYPE c4,c115 TYPE c4,
            c116 TYPE c4, "border
            ctyp TYPE salv_t_int4_column,
          END OF wa_qp.
    DATA:it_qp LIKE TABLE OF wa_qp.
    METHODS: ini_gobang.
    METHODS: dis_gobang.
    METHODS: set_gobang FOR EVENT link_click OF cl_salv_events_table IMPORTING row column.
    METHODS: ai1_gobang."
    METHODS: get_gobang IMPORTING row TYPE i col TYPE i off TYPE i OPTIONAL set TYPE i OPTIONAL
                                                                       RETURNING VALUE(value) TYPE c4.

    METHODS: env_gobang IMPORTING row TYPE i col TYPE i player TYPE c4 RETURNING VALUE(value) TYPE i.
    METHODS: win_gobang IMPORTING row TYPE i off TYPE i column TYPE c4 RETURNING VALUE(score) TYPE i.
    METHODS: mes_gobang IMPORTING mes TYPE string.
ENDCLASS.


*Then we can just call method to display the board and click a cell to start the game.

NEW cl_gobang( )->dis_gobang( ).


*At last , the main logic: the class implementation:
*
*The AI use Valuation Algorithm to do estimation, not very smart, but easy to write.

CLASS cl_gobang IMPLEMENTATION.

  METHOD: win_gobang.
    score = 1.
    DATA(col_cur)  = CONV i( column+1(3) - 99 ).
    ASSIGN COMPONENT column OF STRUCTURE it_qp[ row ] TO FIELD-SYMBOL(<pawn>) .
    DO 4 TIMES.
      IF <pawn> NE get_gobang( row = row col = col_cur off = off set =  sy-index  ).EXIT.ENDIF.
      score = score + 1.
    ENDDO.

    DO 4 TIMES.
      IF <pawn> NE get_gobang( row = row col = col_cur off = off set = - sy-index ).EXIT.ENDIF.
      score = score + 1.
    ENDDO.

  ENDMETHOD.

  METHOD: get_gobang.
    DATA(row_now) = row.
    DATA(col_now) = col.
    CASE off.
      WHEN 1.row_now = row_now + set.                               "
      WHEN 2.col_now = col_now + set.                               "                   7      2      8
      WHEN 3.row_now = row_now - set.                               "
      WHEN 4.col_now = col_now - set.                               "
      WHEN 5.row_now = row_now + set.col_now = col_now + set.       "                   4      0      3
      WHEN 6.row_now = row_now + set.col_now = col_now - set.       "
      WHEN 7.row_now = row_now - set.col_now = col_now - set.       "
      WHEN 8.row_now = row_now - set.col_now = col_now + set.       "                   6      1      5
      WHEN OTHERS.
    ENDCASE.

    ASSIGN COMPONENT col_now OF STRUCTURE it_qp[ row_now ] TO FIELD-SYMBOL(<pawn_cur>).
    value = COND #( WHEN <pawn_cur> IS ASSIGNED THEN <pawn_cur> ELSE border_ins ).

  ENDMETHOD.

  METHOD: ini_gobang.

    it_qp = VALUE #( FOR j = 1 UNTIL j > 15 (
                       c100 = border_ins
                       c116 = border_ins
                       ctyp = VALUE #( FOR i = 1 UNTIL i > 15 (
                          columnname = |C{ i + 100 }|
                          value = if_salv_c_cell_type=>hotspot ) ) ) ).
    DO 17 TIMES.
      ASSIGN COMPONENT sy-index  OF STRUCTURE wa_qp TO FIELD-SYMBOL(<value>).
      <value> = border_ins.
    ENDDO.

    INSERT wa_qp INTO it_qp INDEX 1.
    APPEND wa_qp TO it_qp.

  ENDMETHOD.

  METHOD: mes_gobang.
    MESSAGE mes TYPE 'I'.
    ini_gobang( ).
    dis_gobang( ).
  ENDMETHOD.

  METHOD: dis_gobang.

    DATA: lo_h_label TYPE REF TO cl_salv_form_label,
          lo_h_flow  TYPE REF TO cl_salv_form_layout_flow.
    IF mo_qp IS NOT BOUND.
      ini_gobang( ).

      cl_salv_table=>factory( IMPORTING r_salv_table = mo_qp CHANGING t_table = it_qp ).
      SET HANDLER me->set_gobang FOR mo_qp->get_event( ).

      DATA(gr_columns) = mo_qp->get_columns( ).
      gr_columns->set_cell_type_column( 'CTYP' ).
      DO 17 TIMES.
        DATA(gr_column) = gr_columns->get_column( CONV lvc_fname( |C{ sy-index + 99 }| ) ).
        gr_column->set_output_length( 2 ).
        gr_column->set_alignment( 3 ).
      ENDDO.
      DATA(lo_header) = NEW cl_salv_form_layout_grid( ).

      lo_h_label = lo_header->create_label( row = 1 column = 1 ).
      lo_h_label->set_text( 'GoBang!' ).
      mo_qp->set_top_of_list( lo_header ).
      mo_qp->display( ).
    ELSE.

      lo_header = NEW cl_salv_form_layout_grid( ).
      lo_h_label = lo_header->create_label( row = 1 column = 1 ).
      lo_h_label->set_text( 'GoBang!' ).
      mo_qp->get_columns( )->set_cell_type_column( 'CTYP' ).
      mo_qp->set_top_of_list( lo_header ).
      mo_qp->refresh( s_stable = VALUE lvc_s_stbl( row = 'X' col = 'X') refresh_mode = 2 ).
    ENDIF.

  ENDMETHOD.

  METHOD: set_gobang.

    ASSIGN COMPONENT column OF STRUCTURE it_qp[ row ] TO FIELD-SYMBOL(<pawn>).
    CHECK <pawn> IS INITIAL AND <pawn> IS ASSIGNED.
    <pawn> = COND #( WHEN step MOD 2 EQ 1 THEN player_wht ELSE player_bak ).
    WAIT UP TO '0.5' SECONDS.
    step = step + 1.
    dis_gobang( ).

    IF win_gobang( row = row column = CONV #( column ) off = 1 ) >= 5
    OR win_gobang( row = row column = CONV #( column ) off = 2 ) >= 5
    OR win_gobang( row = row column = CONV #( column ) off = 5 ) >= 5
    OR win_gobang( row = row column = CONV #( column ) off = 6 ) >= 5.
      mes_gobang( COND #( WHEN step MOD 2 EQ 1 THEN |You Win!| ELSE |You Lost!| ) ).
      EXIT.
    ENDIF.
    IF step = 15 * 15.
      mes_gobang( |No Win!|  ).
      EXIT.
    ENDIF.
    CHECK step MOD 2 EQ 1.
    ai1_gobang( ).
  ENDMETHOD.

  METHOD: ai1_gobang.

    DATA: best_x TYPE i, best_y TYPE i, max TYPE i VALUE 0.

    LOOP AT it_qp INTO wa_qp.
      DATA(x1) = sy-tabix.
      DO 16 TIMES.
        DATA(y1) = sy-index.
        IF get_gobang( row = x1 col = y1 ) IS NOT INITIAL.
          CONTINUE.
        ENDIF.

        IF max < env_gobang( row = x1 col = y1 player = player_wht ).
          max = env_gobang( row = x1 col = y1 player = player_wht ).
          best_x = x1.
          best_y = y1.
        ENDIF.

        IF max <= env_gobang( row = x1 col = y1 player = player_bak ).
          max = env_gobang( row = x1 col = y1 player = player_bak ).
          best_x = x1.
          best_y = y1.
        ENDIF.

      ENDDO.
    ENDLOOP.

    set_gobang( row = CONV #( best_x ) column = CONV #( |C{ best_y + 99 }| ) ).

  ENDMETHOD.

  METHOD: env_gobang."X Y PLAYER

    DATA(opsite) = COND #( WHEN player = player_wht THEN player_bak ELSE player_wht ).

    value = 16 - abs( row - 8 ) - abs( col - 8 ).

    DO 8 TIMES.
      DATA(i) = sy-index.

      IF ( get_gobang( row = row col = col off = i set = 1 ) = player
       AND get_gobang( row = row col = col off = i set = 2 ) = player
       AND get_gobang( row = row col = col off = i set = 3 ) = player
       AND get_gobang( row = row col = col off = i set = 4 ) = player
       AND get_gobang( row = row col = col off = i set = 5 ) IS INITIAL ).
        value = value + 4500000.
        IF player EQ player_wht.value = value + 100000.ENDIF.
      ENDIF.

      IF ( get_gobang( row = row col = col off = i set = 1 ) = player
       AND get_gobang( row = row col = col off = i set = 2 ) = player
       AND get_gobang( row = row col = col off = i set = 3 ) = player
       AND get_gobang( row = row col = col off = i set = 4 ) = player
       AND
         ( get_gobang( row = row col = col off = i set = 5 ) = opsite
        OR get_gobang( row = row col = col off = i set = 5 ) = border_ins ) ).
        value = value + 300000.
      ENDIF.

      IF ( get_gobang( row = row col = col off = i set = -1 ) = player
       AND get_gobang( row = row col = col off = i set =  1 ) = player
       AND get_gobang( row = row col = col off = i set =  2 ) = player
       AND get_gobang( row = row col = col off = i set =  3 ) = player
       AND
         ( get_gobang( row = row col = col off = i set =  4 ) = opsite
        OR get_gobang( row = row col = col off = i set =  4 ) = border_ins ) ).
        value = value + 300000.
      ENDIF.

      IF ( get_gobang( row = row col = col off = i set = -1 ) = player
       AND get_gobang( row = row col = col off = i set = -2 ) = player
       AND get_gobang( row = row col = col off = i set =  1 ) = player
       AND get_gobang( row = row col = col off = i set =  2 ) = player
       AND
         ( get_gobang( row = row col = col off = i set =  3 ) = opsite
        OR get_gobang( row = row col = col off = i set =  3 ) = border_ins ) ).
        value = value + 300000.
      ENDIF.

      IF ( get_gobang( row = row col = col off = i set =  1 ) = player
       AND get_gobang( row = row col = col off = i set =  2 ) = player
       AND get_gobang( row = row col = col off = i set =  3 ) = player
       AND get_gobang( row = row col = col off = i set =  4 ) IS INITIAL ).
        value = value + 200000.
      ENDIF.

      IF ( get_gobang( row = row col = col off = i set =  1 ) = player
       AND get_gobang( row = row col = col off = i set =  2 ) = player
       AND get_gobang( row = row col = col off = i set =  3 ) IS INITIAL ).
        value = value + 100000.
      ENDIF.

      IF ( get_gobang( row = row col = col off = i set = -1 ) = player
       AND get_gobang( row = row col = col off = i set = -2 ) = player
       AND get_gobang( row = row col = col off = i set =  1 ) = opsite )
       OR
         ( get_gobang( row = row col = col off = i set =  1 ) = player
       AND get_gobang( row = row col = col off = i set =  2 ) = player
       AND get_gobang( row = row col = col off = i set = -1 ) = opsite ).
        value = value + 80000.
      ENDIF.

      IF ( get_gobang( row = row col = col off = i set =  1 ) = player
       AND get_gobang( row = row col = col off = i set =  2 ) IS INITIAL
       AND get_gobang( row = row col = col off = i set =  3 ) IS INITIAL ).
        value = value + 100.
      ENDIF.

      IF  ( get_gobang( row = row col = col off = i set = -1 ) IS NOT INITIAL
       AND  get_gobang( row = row col = col off = i set = -1 ) <> border_ins )
       OR ( get_gobang( row = row col = col off = i set =  1 ) IS NOT INITIAL
        AND get_gobang( row = row col = col off = i set =  1 ) <> border_ins ).
        value = value + 25.
      ENDIF.

    ENDDO.

* Just for fun
    DATA ran TYPE i.
    CALL FUNCTION 'QF05_RANDOM_INTEGER'
      EXPORTING
        ran_int_max = 2
        ran_int_min = 1
      IMPORTING
        ran_int     = ran.
    value = COND #( WHEN ran EQ 1 THEN value * 99 / 100 ELSE value * 101 / 100 ).
  ENDMETHOD.
ENDCLASS.
