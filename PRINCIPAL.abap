*----------------------------------------------------------------------*
*Nombre programa  :  ZRPFI144 - Reporte pago proveedores.  *
*
*Modulo           :  FI                                                *
*Tipo Programa    :  Reporte                                           *

*Descripción      :  Impresión de orden de pago       *
*ID Desarrollo    :  FI-026                                            *
*----------------------------------------------------------------------*
*Compañía         :  Yara                                              *
*Autor(es)        :  Softtek - Viviana  Aldana - Consultor FI-CO         *
*                    Softtek - Nicolas Riveros - Consultor ABAP        *
*Fecha            :  15.01.2020                                        *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*                L O G.   D E   M O D I F I C A C I O N E S
*----------------------------------------------------------------------*
*    FECHA       REQ #      ABAP           DESCRIPCIÓN                 *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
REPORT zrpfi144.

INCLUDE zrpfi144_top.
INCLUDE zrpfi144_scr.
INCLUDE zrpfi144_for.

*INITIALIZATION.
*  PERFORM f_inicialization.

START-OF-SELECTION.

*  PERFORM f_authority_check.
*  PERFORM f_validar_campos.
  PERFORM f_obtener_datos.             " Consulta de datos
  IF gt_regup[] IS NOT INITIAL.
    PERFORM f_procesar_datos.          "Procesamiento de Datos para formulario.
  ELSE.
    MESSAGE text-019 TYPE 'S'.        " Mensaje de alerta
  ENDIF.