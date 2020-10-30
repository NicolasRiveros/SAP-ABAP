*&---------------------------------------------------------------------*
*&  Include           ZRPFI144_SCR
*&---------------------------------------------------------------------*

DATA: lv_vblnr TYPE vblnr,
      lv_laufd TYPE laufd,
      lv_bukrs TYPE bukrs,
      lv_lifnr TYPE lifnr.


*Parametros de Entrada
SELECT-OPTIONS  s_bukrs FOR  lv_bukrs .          " Sociedad
SELECT-OPTIONS  s_lifnr FOR  lv_lifnr.           " Acreedor
SELECT-OPTIONS: s_vblnr FOR  lv_vblnr.           " Documento FI
SELECT-OPTIONS: s_laufd FOR  lv_laufd     OBLIGATORY.      " Fecha de creación del pago
PARAMETERS:     p_gjahr TYPE regup-gjahr  OBLIGATORY.   " Ejecicio

SELECTION-SCREEN SKIP 1 .

SELECTION-SCREEN BEGIN OF BLOCK bl_1 WITH FRAME TITLE text-005.

PARAMETERS: c_soli AS CHECKBOX DEFAULT 'X'.

SELECTION-SCREEN END OF BLOCK bl_1.

SELECTION-SCREEN BEGIN OF BLOCK bl_2 WITH FRAME TITLE text-015.

PARAMETERS: c_print RADIOBUTTON GROUP gr1 DEFAULT 'X',     " Imprimir
            c_prevw RADIOBUTTON GROUP gr1.                 " Vizualizar
PARAMETERS: c_mail  AS CHECKBOX.                           " Enviar email a proveedor

SELECTION-SCREEN END OF BLOCK bl_2.

SELECTION-SCREEN FUNCTION KEY 1.