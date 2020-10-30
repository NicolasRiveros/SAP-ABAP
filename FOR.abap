**&---------------------------------------------------------------------*
**&  Include           ZRPFI144_FOR
**&---------------------------------------------------------------------*
**&      Form  F_AUTHORITY_CHECK
**&---------------------------------------------------------------------*
**
**----------------------------------------------------------------------*
*FORM f_authority_check .
*  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
*           ID 'BUKRS' FIELD p_bukrs
*           ID 'ACTVT' FIELD '03'.
*  IF sy-subrc NE 0.
*    MESSAGE e113(fg) WITH p_bukrs.
*    RETURN.
*  ENDIF.
*ENDFORM.                    " F_AUTHORITY_CHECK
*
**&---------------------------------------------------------------------*
**&      Form  F_OBTENER_DATOS
**&---------------------------------------------------------------------*
**
**----------------------------------------------------------------------*
FORM f_obtener_datos.
  DATA: lv_cod_report TYPE sy-repid,
        ls_t001 TYPE gty_t001,
        lr_land1 TYPE RANGE OF land1,
        ls_land1 LIKE LINE  OF lr_land1.

* Consulta de constante
  SELECT SINGLE id_report INTO lv_cod_report                "#EC WARNOK
  FROM zbctb_reports
  WHERE progname = sy-repid.
  IF sy-subrc = 0.
    SELECT id_range zsign zoption zlow zhigh
      INTO TABLE r_bukrs
      FROM zbctb_params
      WHERE id_report = lv_cod_report
      AND   id_range  = 'BUKRS'.
    IF sy-subrc NE 0.
      MESSAGE e001(zbcin_mrpt_user) WITH 'BUKRS'  sy-repid.    " 4000153422 E2-IM014063928
    ENDIF.
  ENDIF.

  SELECT SINGLE dcpfm INTO gv_dcpfm FROM usr01 WHERE bname EQ sy-uname.

  SELECT bukrs lifnr bldat  budat
         laufd belnr vblnr  buzei
         gjahr zlsch xblnr  pswbt
         blart waers hbkid  qsshb
         qbshb laufi zbukr  wrbtr
         shkzg
        INTO TABLE gt_regup
        FROM regup
        WHERE  laufd IN s_laufd
        AND    xvorl EQ  ' '
        AND    lifnr IN s_lifnr
        AND    bukrs IN s_bukrs
        AND    vblnr IN s_vblnr
        AND    gjahr EQ p_gjahr.

  SORT gt_regup BY bukrs lifnr.

  SELECT bukrs  butxt  land1 adrnr FROM t001 INTO TABLE gt_sociedades
    WHERE bukrs IN  s_bukrs.

  SELECT bukrs butxt  land1 adrnr FROM t001
   INTO CORRESPONDING FIELDS OF TABLE  gt_t001
   WHERE bukrs IN s_bukrs.

  LOOP AT gt_sociedades INTO gs_sociedades.
    READ TABLE r_bukrs  INTO gs_bukrs WITH KEY zlow = gs_sociedades-bukrs.
    IF sy-subrc EQ 0.
      IF gt_regup[] IS NOT INITIAL.
* Seleccion valores de retención
        SELECT
          bukrs belnr  buzei qsatz
          witht wt_withcd  wt_qsshb
          wt_qssh2  wt_qbshb   wt_qbsh2
          APPENDING CORRESPONDING FIELDS OF TABLE gt_with_item_1
          FROM with_item
          FOR ALL ENTRIES IN gt_regup
          WHERE  bukrs  = gs_sociedades-bukrs
          AND    belnr  = gt_regup-belnr
          AND    gjahr  = gt_regup-gjahr
          AND    buzei  = gt_regup-buzei
          AND    wt_withcd NE ' ' .
      ENDIF.
    ELSE.
      IF gt_regup[] IS NOT INITIAL.
* Seleccion valores de retención
        SELECT
          bukrs  belnr   buzei    qsatz
          witht  wt_withcd  wt_qsshb
          wt_qssh2  wt_qbshb   wt_qbsh2
         APPENDING CORRESPONDING FIELDS OF TABLE gt_with_item_2
          FROM with_item
          FOR ALL ENTRIES IN gt_regup
          WHERE  bukrs  = gs_sociedades-bukrs
*          AND    belnr  = gt_regup-belnr
          AND    gjahr  = gt_regup-gjahr
          AND    buzei  = gt_regup-buzei
          AND    wt_withcd NE ' ' .

        IF gt_with_item_2[] IS NOT INITIAL.
          SELECT land1  witht text40 FROM t059u
            INTO TABLE gt_t059u_2
            FOR ALL ENTRIES IN gt_with_item_2
            WHERE spras EQ sy-langu
            AND   land1 IN lr_land1
            AND   witht EQ gt_with_item_2-witht.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
  LOOP AT gt_t001 INTO ls_t001.
    ls_land1-sign = 'I'.
    ls_land1-option = 'EQ'.
    ls_land1-low = ls_t001-land1.
    APPEND ls_land1 TO lr_land1.
    CLEAR ls_land1.
  ENDLOOP.
  IF gt_with_item_1[] IS NOT INITIAL.
    SELECT land1  witht text40 FROM t059u
      INTO TABLE gt_t059u
      FOR ALL ENTRIES IN gt_with_item_1
      WHERE spras EQ sy-langu
      AND   land1 IN lr_land1
      AND   witht EQ gt_with_item_1-witht.
  ENDIF.
*  Seleccion Textos correspondiente a la moneda local
  SELECT waers ltext
    INTO CORRESPONDING FIELDS OF TABLE gt_tcurt
    FROM tcurt
    FOR ALL ENTRIES IN gt_regup
    WHERE  spras = sy-langu
    AND waers = gt_regup-waers.

*Agregar numero de documento por proveedor.
  PERFORM agregar_prov_belnr.

  IF gt_regup IS NOT INITIAL.
* Seleccion de orden de pago
    SELECT  vblnr zaldt FROM reguh
      INTO CORRESPONDING FIELDS OF TABLE gt_orden_pago
      FOR ALL ENTRIES IN  gt_regup
      WHERE laufd EQ gt_regup-laufd
      AND   laufi EQ gt_regup-laufi
      AND   zbukr EQ gt_regup-zbukr
      AND   lifnr EQ gt_regup-lifnr
      AND   vblnr EQ gt_regup-vblnr.


    SELECT bukrs  belnr gjahr kursf
      FROM bkpf
      INTO TABLE gt_bkpf
      FOR ALL ENTRIES IN gt_regup
      WHERE bukrs EQ gt_regup-bukrs
      AND   belnr EQ gt_regup-belnr
      AND   gjahr EQ  gt_regup-gjahr.

    SELECT blart ltext INTO CORRESPONDING FIELDS OF TABLE gt_t003t
      FROM t003t
      FOR ALL ENTRIES IN gt_regup
      WHERE spras = sy-langu
      AND   blart = gt_regup-blart.

* Consulta de banco origen

    SELECT  laufd laufi xvorl zbukr lifnr
            name1 kunnr empfg vblnr ort01
            stras land1 hbkid zbnks zbnkl
            zland zbnkn ubnks
      FROM reguh
      INTO CORRESPONDING FIELDS OF TABLE gt_reguh
      WHERE  laufd  IN s_laufd
      AND    lifnr  IN s_lifnr
      AND    zbukr  IN s_bukrs
      AND    vblnr  IN s_vblnr
      AND    xvorl  EQ ' '.

    IF sy-subrc EQ 0.

      SELECT bukrs banks bankl hbkid FROM t012
        INTO CORRESPONDING FIELDS OF TABLE  gt_t012
        FOR ALL ENTRIES IN gt_reguh
        WHERE  bukrs EQ  gt_reguh-zbukr
        AND    hbkid EQ  gt_reguh-hbkid.

      SELECT banks bankl banka FROM bnka
        INTO CORRESPONDING FIELDS OF TABLE gt_bnka_origen
        FOR ALL ENTRIES IN gt_t012
        WHERE  bankl EQ  gt_t012-bankl
        AND    banks EQ gt_t012-banks.

    ENDIF.
*Consulta Banco Destino
    IF gt_reguh IS NOT INITIAL.

      SELECT banks bankl banka FROM bnka
        INTO TABLE gt_bnka_destino
        FOR ALL ENTRIES IN gt_reguh
        WHERE banks EQ gt_reguh-zbnks
        AND   bankl EQ   gt_reguh-zbnkl.

      SELECT lifnr banks bankl FROM lfbk
      INTO CORRESPONDING FIELDS OF TABLE gt_lfbk
      FOR ALL ENTRIES IN gt_reguh
      WHERE lifnr  EQ gt_reguh-lifnr
      AND   banks  EQ gt_reguh-zbnks.

      SELECT banks bankl banka FROM bnka
      INTO TABLE gt_bnka_des_ecu
      FOR ALL ENTRIES IN gt_lfbk
      WHERE bankl EQ gt_lfbk-bankl.

    ENDIF.

  ENDIF.

ENDFORM.                    " F_OBTENER_DATOS
**&---------------------------------------------------------------------*
**&      Form  F_PROCESAR_DATOS
**&---------------------------------------------------------------------*
**
**----------------------------------------------------------------------*
FORM f_procesar_datos .

  DATA: ls_prov_vblnr  TYPE ty_prov_vblnr,
        ls_prov_belnr  TYPE ty_prov_belnr.

  PERFORM obtener_cabecera.                                  "Rutina para obtener datos de cabecera
  LOOP AT gt_prov_vblnr INTO ls_prov_vblnr.
    PERFORM f_obtener_orden_pago  USING ls_prov_vblnr-vblnr. "Rutina para obtener datos de  orden de pago
    PERFORM f_obtener_proveedor   USING ls_prov_vblnr-lifnr
                                        ls_prov_vblnr-bukrs.
    PERFORM f_obtener_importe_palabras USING    p_regup
                                       CHANGING p_in_words.  "Obtener importe en palabras
    PERFORM f_obtener_bancos USING      ls_prov_vblnr-bukrs
                                        ls_prov_vblnr-lifnr
                                        ls_prov_vblnr-vblnr. "Obtener Bancos
    PERFORM f_obtener_retenciones USING ls_prov_vblnr-bukrs
                                        ls_prov_vblnr-vblnr
                                        ls_prov_vblnr-lifnr . "Obtener Retenciones
    PERFORM f_crear_formulario_op USING ls_prov_vblnr-bukrs . "Creacion del formulario
    PERFORM f_limpiar_datos.                                  "Limpiar datos.
  ENDLOOP.

  IF c_mail IS NOT INITIAL.                             " Envio del MAIL
    PERFORM enviar_mail USING gs_proveedor-lifnr.
    REFRESH gt_adjuntos_hexa.
    REFRESH gt_adjuntos_text.
  ENDIF.


ENDFORM.                    " F_PROCESAR_DATOS
**&---------------------------------------------------------------------*
**&      Form  F_CREAR_FORMULARIO_OP
**&---------------------------------------------------------------------*
**
**----------------------------------------------------------------------*
FORM f_crear_formulario_op USING ps_prov_vblnr-bukrs.

* Datos locales
  DATA: lv_fm_name   TYPE rs38l_fnam ##needed.

  STATICS: lsw_control_parameters TYPE ssfctrlop,
           lsw_output_options     TYPE ssfcompop.
*
  DATA ls_result        TYPE itcpp.
  DATA ls_printoptions  TYPE  itcpo.

* Obtengo el nombre de la funcion del SmartForm.
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = 'ZSFFI011'
    IMPORTING
      fm_name            = lv_fm_name
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ENDIF.

  IMPORT ls_result TO ls_result FROM MEMORY ID 'ZRFWTCT10_RESULT'.
  IF ls_result IS NOT INITIAL.
    MOVE-CORRESPONDING ls_result TO lsw_output_options.
    MOVE 'X' TO lsw_control_parameters-no_dialog.
  ENDIF.

  IF c_print IS INITIAL.
    MOVE 'X' TO lsw_control_parameters-no_dialog.
  ENDIF.

  IF c_print EQ 'X' OR  c_mail EQ 'X'.
*  lsw_output_options-tdnewid     = 'X'.
    lsw_output_options-tddest       = 'LOCL'.
    lsw_output_options-tdimmed      = 'X'.
*  lsw_control_parameters-device  = 'LOCL'.
    lsw_control_parameters-getotf   = 'X'.
  ELSEIF c_prevw EQ 'X'.
*  lsw_output_options-tdnewid     = 'X'.
    lsw_output_options-tddest       = 'LOCL'.
    lsw_output_options-tdimmed      = 'X'.
*    lsw_control_parameters-getotf   = 'X'.
    lsw_control_parameters-preview   = 'X' .
  ENDIF.
  CLEAR gs_cabecera.
  READ TABLE gt_cabecera INTO gs_cabecera WITH KEY bukrs = ps_prov_vblnr-bukrs.

*Llamado a la funcion para la impresion del formulario
  CALL FUNCTION lv_fm_name"'/1BCDWB/SF00000246'
    EXPORTING
*     ARCHIVE_INDEX        =
*     ARCHIVE_INDEX_TAB    =
*     ARCHIVE_PARAMETERS   =
      control_parameters   = lsw_control_parameters
*     CONTROL_PARAMETERS   =
*     MAIL_APPL_OBJ        =
*     MAIL_RECIPIENT       =
*     MAIL_SENDER          =
      output_options       = lsw_output_options
      user_settings        = ''
      ls_cabecera          = gs_cabecera
      ls_proveedor         = gs_proveedor
      ls_orden_pago        = gs_orden_pago
      in_words             = p_in_words
      s_tcurt              = gs_tcurt
    IMPORTING
*     DOCUMENT_OUTPUT_INFO =
      job_output_options   = lw_job_output_options
      job_output_info      = lw_job_output_info
    TABLES
      t_documento          = gt_documentos
      t_retenciones        = gt_retenciones
      t_bancos             = gt_bancos
    EXCEPTIONS
      formatting_error     = 1
      internal_error       = 2
      send_error           = 3
      user_canceled        = 4
      OTHERS               = 5.
  IF sy-subrc <> 0.
    MESSAGE text-018 TYPE 'S'.
  ENDIF.

  IF ls_result IS INITIAL.
    MOVE-CORRESPONDING lw_job_output_options TO ls_result.
    EXPORT ls_result FROM ls_result TO MEMORY ID 'ZRFWTCT10_RESULT'.
  ENDIF.

  IF c_print IS NOT INITIAL.
    CLEAR ls_printoptions.
    MOVE-CORRESPONDING ls_result TO ls_printoptions.
    CALL FUNCTION 'PRINT_OTF'
      EXPORTING
        printoptions = ls_printoptions
      TABLES
        otf          = lw_job_output_info-otfdata.
  ENDIF.

  IF c_mail IS NOT INITIAL.
    PERFORM crear_pdf USING p_regup-belnr
                            text-012
                            lw_job_output_info-otfdata.
  ENDIF.

ENDFORM.                    " F_CREAR_FORMULARIO_OP
**&---------------------------------------------------------------------*
**&      Form  F_OBTENER_PROVEEDOR
**&---------------------------------------------------------------------*
**
**----------------------------------------------------------------------*
FORM f_obtener_proveedor  USING  ps_prov_vblnr-lifnr ps_prov_vblnr-bukrs.

*Datos locales
  DATA:  ls_proveedor TYPE gty_proveedor,
         ls_sociedades TYPE ty_sociedades.
  DATA:  ls_regup  TYPE ty_regup.

  READ TABLE gt_regup INTO ls_regup WITH KEY  lifnr = ps_prov_vblnr-lifnr
                                              bukrs = ps_prov_vblnr-bukrs
                                              gjahr = p_gjahr.
  IF sy-subrc EQ 0.
    SELECT SINGLE  name1 stras land1 ort01 stcd1 lifnr
      INTO ls_proveedor FROM lfa1
      WHERE  lifnr EQ ls_regup-lifnr.
    MOVE-CORRESPONDING ls_proveedor TO gs_proveedor.
    MOVE : ls_proveedor-stcd TO gs_proveedor-stcd1.
    IF sy-subrc EQ 0.
      SELECT SINGLE landx FROM t005t INTO gs_proveedor-landx
        WHERE spras EQ sy-langu
        AND   land1 EQ ls_proveedor-land1.
    ENDIF.
    CLEAR ls_proveedor.
  ENDIF.

ENDFORM.                    " F_OBTENER_PROVEEDOR
*&---------------------------------------------------------------------*
*&      Form  F_OBTENER_IMPORTE_PALABRAS
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM f_obtener_importe_palabras    USING  p_regup      TYPE ty_regup
                                   CHANGING p_in_words TYPE spell.
  DATA: lv_in_words TYPE spell,
        ls_tcurt    TYPE tcurt.

  CLEAR lv_in_words.

  CALL FUNCTION 'SPELL_AMOUNT'
    EXPORTING
      amount    = gv_total
      currency  = p_regup-waers
      language  = sy-langu
    IMPORTING
      in_words  = lv_in_words
    EXCEPTIONS
      not_found = 1
      too_large = 2
      OTHERS    = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    MOVE lv_in_words TO p_in_words.
    READ TABLE gt_tcurt INTO ls_tcurt WITH KEY waers = p_regup-waers.
    IF sy-subrc EQ 0.
      gs_tcurt-ltext = ls_tcurt-ltext.
    ENDIF.

  ENDIF.
*
ENDFORM.                    " F_OBTENER_IMPORTE_PALABRAS
*&---------------------------------------------------------------------*
*&      Form  CREAR_NOMBRE_ADJUNTO
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM crear_nombre_adjunto  USING    p_texto       TYPE string
                                    p_belnr       TYPE belnr_d
                           CHANGING p_subject     TYPE so_obj_des.
  CLEAR p_subject.
  CONCATENATE p_texto p_belnr INTO p_subject SEPARATED BY space.
ENDFORM.                    " CREAR_NOMBRE_ADJUNTO
**&---------------------------------------------------------------------*
**&      Form  CREAR_PDF
**&---------------------------------------------------------------------*
**
**----------------------------------------------------------------------*
FORM crear_pdf USING p_belnr   TYPE belnr_d
                     p_texto   TYPE string
                     p_otfdata TYPE tt_itcoo.

* datos locales
  DATA lt_adjunto_text TYPE soli_tab.
  DATA lt_adjunto_hexa TYPE solix_tab.
  DATA ls_adjuntos_hexa TYPE zsd_adjuntos_hexa.

  IF p_otfdata IS NOT INITIAL.

    PERFORM crear_adjunto USING    p_otfdata
                                   c_otf
                                   c_pdf
                          CHANGING lt_adjunto_text
                                   lt_adjunto_hexa.

    CLEAR ls_adjuntos_hexa.
    REFRESH ls_adjuntos_hexa-solix_tab.
    MOVE lt_adjunto_hexa TO ls_adjuntos_hexa-solix_tab.
    MOVE c_pdf TO ls_adjuntos_hexa-type.
    PERFORM crear_nombre_adjunto USING    p_texto
                                          p_belnr
                                 CHANGING ls_adjuntos_hexa-subject.

    APPEND ls_adjuntos_hexa TO gt_adjuntos_hexa.

  ENDIF.

ENDFORM.                    " CREAR_PDF
*&---------------------------------------------------------------------*
*&      Form  CREAR_ADJUNTO
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM crear_adjunto  USING    p_otfdata       TYPE otf_t_itcoo
                             p_src           TYPE sx_format
                             p_dst           TYPE sx_format
                    CHANGING p_adjunto_text  TYPE soli_tab
                             p_adjunto_hexa  TYPE solix_tab.
* datos locales
  DATA ls_otfdata TYPE itcoo.

  DATA lv_format_src  TYPE  sx_format.
  DATA lv_format_dst  TYPE  sx_format.
  DATA lv_devtype     TYPE  sx_devtype.

  DATA lv_transfer_bin  TYPE  sx_boolean.
  DATA lt_content_txt   TYPE  soli_tab.
  DATA ls_content_txt   TYPE  soli.
  DATA lt_content_bin   TYPE  solix_tab.
  DATA lt_objhead       TYPE  soli_tab.
  DATA lv_len           TYPE  so_obj_len.

  REFRESH: p_adjunto_text,
           p_adjunto_hexa.

  REFRESH: lt_content_txt.

  LOOP AT p_otfdata INTO ls_otfdata.
    CLEAR ls_content_txt.
    ls_content_txt = ls_otfdata.
    APPEND ls_content_txt TO lt_content_txt.
  ENDLOOP.

  IF lt_content_txt IS NOT INITIAL.
    MOVE lt_content_txt TO p_adjunto_text.
  ENDIF.

  CLEAR: lv_transfer_bin, lv_len, lv_format_src, lv_format_dst, lv_devtype.
  REFRESH: lt_content_bin, lt_objhead.

  lv_format_src = p_src.
  lv_format_dst = p_dst.
*  lv_devtype    = 'LP01'.

  CALL FUNCTION 'SX_OBJECT_CONVERT_OTF_PDF'
    EXPORTING
      format_src      = lv_format_src
      format_dst      = lv_format_dst
*     ADDR_TYPE       =
*     devtype         = lv_devtype
*     FUNCPARA        =
    CHANGING
      transfer_bin    = lv_transfer_bin
      content_txt     = lt_content_txt
      content_bin     = lt_content_bin
      objhead         = lt_objhead
      len             = lv_len
    EXCEPTIONS
      err_conv_failed = 1
      OTHERS          = 2.
  IF sy-subrc IS INITIAL.
    MOVE lt_content_bin TO p_adjunto_hexa.
  ENDIF.

ENDFORM.                    " CREAR_ADJUNTO

*&---------------------------------------------------------------------*
*&      Form  ENVIAR_MAIL
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM enviar_mail USING p_lifnr TYPE lifnr.

  DATA lv_remitente     TYPE ad_smtpadr.
  DATA lt_destinatarios TYPE zty_destinatarios.
  DATA lt_concopia      TYPE zty_destinatarios.
  DATA lv_asunto        TYPE string.
  DATA lt_cuerpo        TYPE soli_tab.
  DATA lv_lifnr         TYPE symsgv.
  DATA lv_texto         TYPE symsgv.

  MOVE p_lifnr TO lv_lifnr.
  PERFORM obtener_remitente      CHANGING lv_remitente.
  PERFORM obtener_mail_proveedor USING    p_lifnr
                                 CHANGING lt_destinatarios.
  APPEND lv_remitente TO lt_concopia.
  PERFORM obtener_asunto  CHANGING lv_asunto.
  PERFORM obtener_cuerpo  CHANGING lt_cuerpo.

  IF lt_destinatarios IS INITIAL.

* mensaje de error al LOG
    lv_texto = text-017.
    PERFORM add_message USING 'E' '00' '398' lv_texto lv_lifnr space space.
    EXIT.
  ENDIF.

  IF lv_asunto IS NOT INITIAL
    AND lt_cuerpo IS NOT INITIAL.

    CALL FUNCTION 'ZFM_ENVIAR_EMAIL_FILE2'
      EXPORTING
        remitente            = lv_remitente
        destinatarios        = lt_destinatarios
        concopia             = lt_concopia
        asunto               = lv_asunto
        cuerpo               = lt_cuerpo
        idioma               = sy-langu
        adjuntos_hexa        = gt_adjuntos_hexa
      EXCEPTIONS
        documento_no_enviado = 1
        OTHERS               = 2.
    IF sy-subrc IS INITIAL.
* mensaje de success al LOG
      lv_texto = text-016.
      PERFORM add_message USING 'S' '00' '398' lv_texto lv_lifnr space space.
    ELSE.
* mensaje de error al LOG
      lv_texto = text-017.
      PERFORM add_message USING 'E' '00' '398' lv_texto lv_lifnr space space.
    ENDIF.
  ENDIF.

ENDFORM.                    " ENVIAR_MAIL

*&---------------------------------------------------------------------*
*&      Form  OBTENER_REMITENTE
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM obtener_remitente  CHANGING p_remitente TYPE ad_smtpadr.
  CLEAR p_remitente.
  CALL FUNCTION 'ZFM_GET_CONSTANT_TVARVC'
    EXPORTING
      name  = 'ZRPFI117_REMITENTE'
    IMPORTING
      value = p_remitente.
ENDFORM.                    " OBTENER_REMITENTE
**&---------------------------------------------------------------------*
**&      Form  OBTENER_MAIL_PROVEEDOR
**&---------------------------------------------------------------------*
**
**----------------------------------------------------------------------*
FORM obtener_mail_proveedor USING    p_lifnr         TYPE lifnr
                            CHANGING p_destinatarios TYPE zty_destinatarios.
  DATA lv_adrnr     TYPE adrnr.
  DATA lt_smtp_addr TYPE TABLE OF ad_smtpadr.

  CLEAR p_destinatarios.

* Selección de LFA1 - Maestro de proveedores (parte general)
  CLEAR lv_adrnr.
  SELECT SINGLE adrnr FROM lfa1 INTO lv_adrnr
   WHERE lifnr EQ p_lifnr.
  IF sy-subrc IS INITIAL.

*   Selección de ADR6 - Direcciones correo electrónico (Gestión Central Direcciones)
    REFRESH lt_smtp_addr.
    SELECT  smtp_addr FROM adr6 INTO TABLE lt_smtp_addr
     WHERE addrnumber EQ lv_adrnr
       AND smtp_addr NE ''.
    IF sy-subrc IS INITIAL.
      MOVE lt_smtp_addr TO p_destinatarios.
    ENDIF.
  ENDIF.

ENDFORM.                    " OBTENER_MAIL_PROVEEDOR
**&---------------------------------------------------------------------*
**&      Form  OBTENER_ASUNTO
**&---------------------------------------------------------------------*
**
**----------------------------------------------------------------------*
FORM obtener_asunto  CHANGING p_asunto TYPE string.

  DATA: lt_lines  TYPE TABLE OF tline.
  DATA: ls_lines  TYPE tline.

  REFRESH lt_lines.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = 'ST'
      language                = sy-langu
      name                    = 'ZRPFI144_ASUNTO'
      object                  = 'TEXT'
    TABLES
      lines                   = lt_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc IS INITIAL.

    CLEAR ls_lines.
    READ TABLE lt_lines INTO ls_lines
    INDEX 1.
    IF sy-subrc IS INITIAL.
      MOVE ls_lines-tdline TO p_asunto.
    ENDIF.

  ENDIF.

ENDFORM.                    " OBTENER_ASUNTO
**&---------------------------------------------------------------------*
**&      Form  OBTENER_CUERPO
**&---------------------------------------------------------------------*
**
**----------------------------------------------------------------------*
FORM obtener_cuerpo  CHANGING p_cuerpo TYPE soli_tab.

  DATA: lt_lines  TYPE TABLE OF tline.
  DATA: ls_lines  TYPE tline.
  DATA  ls_objtxt TYPE solisti1.

  REFRESH lt_lines.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = 'ST'
      language                = sy-langu
      name                    = 'ZRPFI144_CUERPO'
      object                  = 'TEXT'
    TABLES
      lines                   = lt_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc IS INITIAL.

    LOOP AT lt_lines INTO ls_lines.
      CLEAR ls_objtxt.
      MOVE ls_lines-tdline TO ls_objtxt.
      APPEND ls_objtxt TO p_cuerpo.
    ENDLOOP.

  ENDIF.

ENDFORM.                    " OBTENER_CUERPO
**&---------------------------------------------------------------------*
**&      Form  F_VALIDAR_CAMPOS
**&---------------------------------------------------------------------*
**
**----------------------------------------------------------------------*
FORM f_validar_campos .

* validamos formularios a procesar
  IF c_soli IS INITIAL.
    MESSAGE s368(00) WITH text-e01 DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

* validamos operaciones a realizar
  IF c_print IS INITIAL
  AND c_mail IS INITIAL.
    MESSAGE s368(00) WITH text-e02 DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.                    " F_VALIDAR_CAMPOS
**&---------------------------------------------------------------------*
**&      Form  F_CREAR_LOG
**&---------------------------------------------------------------------*
**
**----------------------------------------------------------------------*
*FORM f_crear_log .
*
*  IF c_mail IS NOT INITIAL.
*
** Create the Log
*    CLEAR: gs_log, gv_log_handle.
*    gs_log-object    = 'ZFI_ZRPFI117'.
*    gs_log-subobject = 'MAIL_LOG'.
*    gs_log-aldate    = sy-datum.
*    gs_log-altime    = sy-uzeit.
*    gs_log-aluser    = sy-uname.
*
*    CALL FUNCTION 'BAL_LOG_CREATE'
*      EXPORTING
*        i_s_log                 = gs_log
*      IMPORTING
*        e_log_handle            = gv_log_handle
*      EXCEPTIONS
*        log_header_inconsistent = 1
*        OTHERS                  = 2.
*    IF sy-subrc <> 0.
**      RAISE EXCEPTION TYPE zcx_idoc_app_log_error.
*    ENDIF.
*
*  ENDIF.
*
*ENDFORM.                    " F_CREAR_LOG
**&---------------------------------------------------------------------*
**&      Form  ADD_MESSAGE
**&---------------------------------------------------------------------*
**
**----------------------------------------------------------------------*
FORM add_message  USING   p_msgty TYPE symsgty
                          p_msgid TYPE symsgid
                          p_msgno TYPE symsgno
                          p_msgv1 TYPE symsgv
                          p_msgv2 TYPE symsgv
                          p_msgv3 TYPE symsgv
                          p_msgv4 TYPE symsgv.

  CLEAR gs_msg.
  gs_msg-msgty = p_msgty.
  gs_msg-msgid = p_msgid.
  gs_msg-msgno = p_msgno.
  gs_msg-msgv1 = p_msgv1.
  gs_msg-msgv2 = p_msgv2.
  gs_msg-msgv3 = p_msgv3.
  gs_msg-msgv4 = p_msgv4.
  APPEND gs_msg TO gt_msg.

ENDFORM.                    " ADD_MESSAGE
**&---------------------------------------------------------------------*
**&      Form  VISUALIZAR_LOG
**&---------------------------------------------------------------------*
**
**----------------------------------------------------------------------*
*FORM visualizar_log .
*
*  CHECK c_mail IS NOT INITIAL.
*  CHECK gt_msg IS NOT INITIAL.
*
*  LOOP AT gt_msg INTO gs_msg.
*
*    CALL FUNCTION 'BAL_LOG_MSG_ADD'
*      EXPORTING
*        i_log_handle     = gv_log_handle
*        i_s_msg          = gs_msg
*      EXCEPTIONS
*        log_not_found    = 1
*        msg_inconsistent = 2
*        log_is_full      = 3
*        OTHERS           = 4.
*    IF sy-subrc <> 0.
*      WRITE: / 'Error while adding message to Log'.
*    ENDIF.
*
*  ENDLOOP.
*
*  INSERT gv_log_handle INTO gt_log_handle INDEX 1.
*
**  CALL FUNCTION 'BAL_DB_SAVE'
**    EXPORTING
**      i_client         = sy-mandt
**      i_save_all       = ' '
**      i_t_log_handle   = gt_log_handle
**    IMPORTING
**      e_new_lognumbers = gt_log_num
**    EXCEPTIONS
**      log_not_found    = 1
**      save_not_allowed = 2
**      numbering_error  = 3
**      OTHERS           = 4.
**  IF sy-subrc <> 0.
**    WRITE: / 'Error while Saving Log to DB'.
***  ELSE.
***    WRITE: / 'Log Generated'.
**  ENDIF.
*
*  CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'.
*
*ENDFORM.                    " VISUALIZAR_LOG

FORM obtener_cabecera .

  DATA:  lt_gt_t001   TYPE STANDARD TABLE OF  gty_t001,
         ls_gt_t001    TYPE gty_t001,
         lt_gt_adrc   TYPE STANDARD TABLE OF gty_adrc,
         ls_gt_adrc   TYPE gty_adrc.

*Obtener datos de cabecera
  SELECT t001~bukrs t001~land1 t001~butxt
          adrc~street adrc~city1 adrc~post_code1 adrc~tel_number
    FROM t001 INNER JOIN adrc
    ON t001~adrnr EQ adrc~addrnumber
    INTO TABLE gt_cabecera
    WHERE bukrs IN s_bukrs.

ENDFORM.                    " OBTENER_CABECERA
*&---------------------------------------------------------------------*
*&      Form  F_OBTENER_ORDEN_PAGO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*FORM f_obtener_orden_pago .
FORM f_obtener_orden_pago USING  ls_prov_vblnr-vblnr."p_vblnr TYPE vblnr.
  DATA: ls_orden_pago TYPE  gty_orden_pago,
        ls_bkpf       TYPE  ty_bkpf,
        ls_t003t      TYPE  t003t.
* procesar orden pago.
  IF gt_regup IS NOT INITIAL.

    CLEAR gv_total.
    LOOP AT gt_regup INTO p_regup WHERE vblnr = ls_prov_vblnr-vblnr.
      "Orden de pago
      gs_orden_pago-vblnr = p_regup-vblnr.
      READ TABLE gt_orden_pago INTO ls_orden_pago WITH KEY vblnr = ls_prov_vblnr-vblnr."p_regup-vblnr.
      IF sy-subrc EQ 0.
        gs_orden_pago-zaldt =  ls_orden_pago-zaldt.
      ENDIF.
* Tabla de salida Orden de pago

      MOVE-CORRESPONDING p_regup TO  gs_documentos.
      IF p_regup-shkzg = 'H'.
        p_regup-wrbtr = p_regup-wrbtr * -1.
      ENDIF.
      READ TABLE gt_bkpf INTO ls_bkpf WITH KEY bukrs = p_regup-bukrs
                                               belnr = p_regup-belnr
                                               gjahr = p_regup-gjahr.
      IF sy-subrc EQ 0.
        gs_documentos-kursf = ls_bkpf-kursf.
      ENDIF.
      READ TABLE gt_t003t INTO ls_t003t WITH KEY blart = p_regup-blart.
      IF sy-subrc EQ 0.
        gs_documentos-ltext = ls_t003t-ltext.
      ENDIF.
      gv_total = gv_total + p_regup-wrbtr.
      APPEND gs_documentos TO gt_documentos.
      IF  gv_total IS INITIAL.
        REFRESH gt_documentos.
      ENDIF.
      CLEAR gs_documentos.
      SORT gt_documentos BY belnr.
    ENDLOOP.

  ENDIF.

ENDFORM.                    " F_OBTENER_ORDEN_PAGO
*&---------------------------------------------------------------------*
*&      Form  F_OBTENER_RETENCIONES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_obtener_retenciones USING ps_prov_vblnr-bukrs
                                 ps_prov_vblnr-vblnr
                                 ps_prov_vblnr-lifnr.

  DATA: ls_gt_with_item_1 TYPE gty_with_item,
        ls_gt_with_item_2 TYPE gty_with_item,
        ls_t059u          TYPE gty_t059u,
        ls_t059u_2        TYPE gty_t059u,
        ls_t001           TYPE gty_t001,
        lv_valor(22)      TYPE c,
        lv_valor1(22)     TYPE c,
        lv_waers          TYPE waers,
        ls_documentos     TYPE zsfi056,
        ls_regup          TYPE ty_regup.

  FIELD-SYMBOLS: <lfs_regup> TYPE  ty_regup.

  DELETE gt_with_item_1 WHERE wt_qsshb IS INITIAL OR wt_qbshb IS INITIAL.

  IF gt_with_item_1 IS NOT INITIAL.

    READ TABLE gt_regup ASSIGNING <lfs_regup> WITH KEY bukrs = ps_prov_vblnr-bukrs
                                                       lifnr = ps_prov_vblnr-lifnr.
    IF sy-subrc EQ 0.
      lv_waers = <lfs_regup>-waers.
    ENDIF.
    READ TABLE r_bukrs INTO gs_bukrs WITH KEY zlow = ps_prov_vblnr-bukrs.
    IF ps_prov_vblnr-bukrs = gs_bukrs-zlow.

      LOOP AT gt_with_item_1 INTO ls_gt_with_item_1.
        READ TABLE gt_documentos INTO ls_documentos WITH KEY belnr = ls_gt_with_item_1-belnr.
        IF sy-subrc = 0.
          MOVE-CORRESPONDING ls_gt_with_item_1 TO gs_retenciones.

          WRITE gs_retenciones-wt_qsshb  TO lv_valor  CURRENCY lv_waers.
          WRITE gs_retenciones-wt_qbshb  TO lv_valor1 CURRENCY lv_waers.

          PERFORM con_val USING lv_valor lv_waers.
          gs_retenciones-wt_qsshb = lv_valor.
          PERFORM con_val USING lv_valor1 lv_waers.
          gs_retenciones-wt_qbshb  = lv_valor1.

          READ TABLE gt_t001 INTO ls_t001 WITH KEY bukrs = ps_prov_vblnr-bukrs.
          IF sy-subrc EQ 0.
            READ TABLE gt_t059u INTO ls_t059u WITH KEY  land1 = ls_t001-land1
                                                        witht = ls_gt_with_item_1-witht.
            IF sy-subrc EQ 0.
              gs_retenciones-text40 = ls_t059u-text40.
            ENDIF.
          ENDIF.
          APPEND gs_retenciones TO gt_retenciones.
          CLEAR gs_retenciones.
        ENDIF.
      ENDLOOP.
      SORT gt_retenciones BY belnr witht.
    ENDIF.
  ELSE.

    IF gt_with_item_2[] IS NOT INITIAL.
      LOOP AT  gt_documentos INTO ls_documentos.
        READ TABLE  gt_regup INTO ls_regup WITH  KEY belnr =  ls_documentos-belnr
                                                     bukrs =  ps_prov_vblnr-bukrs.
        IF sy-subrc EQ 0.
          lv_waers = ls_regup-waers.
          MOVE ls_regup-qbshb TO gs_retenciones-wt_qbshb.
          MOVE ls_regup-qsshb TO gs_retenciones-wt_qsshb.
          WRITE gs_retenciones-wt_qsshb  TO lv_valor CURRENCY lv_waers.
          WRITE gs_retenciones-wt_qbshb  TO lv_valor1 CURRENCY lv_waers.

          PERFORM con_val USING lv_valor lv_waers.
          gs_retenciones-wt_qsshb = lv_valor.
          PERFORM con_val USING lv_valor1 lv_waers.
          gs_retenciones-wt_qbshb  = lv_valor1.

          READ TABLE gt_with_item_2 INTO ls_gt_with_item_2 WITH KEY belnr = ls_regup-belnr.
          MOVE ls_gt_with_item_2-witht TO gs_retenciones-witht.
          IF sy-subrc EQ 0.
            READ TABLE gt_t001 INTO ls_t001 WITH KEY bukrs = ps_prov_vblnr-bukrs.
            IF sy-subrc EQ 0.
              READ TABLE gt_t059u_2 INTO ls_t059u_2 WITH KEY  land1 = ls_t001-land1
                                                              witht = ls_gt_with_item_2-witht.
              IF sy-subrc EQ 0.
                gs_retenciones-text40 = ls_t059u_2-text40.
              ENDIF.
            ENDIF.
          ENDIF.
          APPEND gs_retenciones TO gt_retenciones.
          CLEAR gs_retenciones.
        ENDIF.
      ENDLOOP.
      DELETE gt_retenciones WHERE  wt_qsshb IS INITIAL OR wt_qbshb IS INITIAL.
      SORT gt_retenciones BY belnr witht.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_OBTENER_RETENCIONES
*&---------------------------------------------------------------------*
*&      Form  F_OBTENER_BANCO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_obtener_bancos USING ls_prov_vblnr-bukrs
                            ls_prov_vblnr-lifnr
                            ls_prov_vblnr-vblnr.

  DATA: ls_reguh        TYPE gty_reguh,
        ls_t012         TYPE gty_t012,
        ls_bnka_origen  TYPE gty_bnka,
        ls_bnka_destino TYPE gty_bnka,
        ls_regup        TYPE ty_regup,
        ls_bancos       TYPE zsfi058,
        lv_mpago        TYPE c,
        lr_pago         TYPE RANGE OF c,
        ls_pago         LIKE LINE  OF lr_pago,
        ls_lfbk         TYPE  ty_lfbk.

  DATA: lv_cod_report TYPE sy-repid.
  SELECT SINGLE id_report INTO lv_cod_report                "#EC WARNOK
  FROM zbctb_reports
  WHERE progname = sy-repid.
  IF sy-subrc = 0.
    SELECT id_range zsign zoption zlow zhigh
      INTO TABLE r_pagos
      FROM zbctb_params
     WHERE id_report = lv_cod_report
       AND id_range = 'ZLSCH'.
    IF sy-subrc NE 0.
      MESSAGE e001(zbcin_mrpt_user) WITH 'ZLSCH'  sy-repid.    " 4000153422 E2-IM014063928
    ENDIF.
  ENDIF.

  LOOP AT gt_reguh INTO ls_reguh WHERE zbukr = ls_prov_vblnr-bukrs
                                 AND lifnr   = ls_prov_vblnr-lifnr
                                 AND vblnr   = ls_prov_vblnr-vblnr.
    CLEAR gs_pagos.
    CLEAR gs_bancos.
    gs_bancos-zbnkn = ls_reguh-zbnkn.

    LOOP AT r_pagos INTO gs_pagos.
      READ TABLE gt_regup INTO ls_regup WITH KEY  zlsch = gs_pagos-zlow. "#EC WARNOK
      IF sy-subrc EQ  0.
        IF gs_pagos-zlow EQ 'E'.
          gs_bancos-denominacion =  c_efect.
        ELSEIF  gs_pagos-zlow EQ 'T'.
          gs_bancos-denominacion =  c_trans.
        ELSEIF gs_pagos-zlow EQ 'M'.
          gs_bancos-denominacion =  c_manual.
        ENDIF.
      ELSE.
        gs_bancos-denominacion =  c_trans.
      ENDIF.
    ENDLOOP.
* Procesar Banco origen
    READ TABLE gt_t012 INTO ls_t012 WITH KEY bukrs = ls_prov_vblnr-bukrs.
    IF sy-subrc EQ 0.
      READ TABLE gt_bnka_origen INTO ls_bnka_origen WITH KEY  banks = ls_reguh-ubnks
                                                              bankl = ls_t012-bankl.
      IF sy-subrc EQ 0.
        gs_bancos-ban_origen = ls_bnka_origen-banka.
      ENDIF.
    ENDIF.
* Procesar Banco destino.
* Si la sociedad es ECUADOR O GUATEMALA
    IF ls_prov_vblnr-bukrs = 'EC01' OR ls_prov_vblnr-bukrs = 'NHG1'.

      READ TABLE gt_lfbk INTO ls_lfbk WITH KEY banks = ls_reguh-zbnks.
      IF sy-subrc EQ 0.
        READ TABLE gt_bnka_des_ecu INTO ls_bnka_destino WITH KEY  banks = ls_reguh-zbnks
                                                                  bankl = ls_lfbk-bankl.
        IF sy-subrc EQ 0.
          gs_bancos-ban_dest = ls_bnka_destino-banka.
        ENDIF.
      ENDIF.
*      gs_bancos-zbnkn = ls_reguh-zbnkn.
      APPEND gs_bancos TO gt_bancos.
      READ TABLE gt_bancos INTO ls_bancos WITH KEY zbnkn = ls_reguh-zbnkn.
      IF sy-subrc EQ 0.
        EXIT.
      ENDIF.
    ELSE.
* Para todas las Sociedades
      READ TABLE gt_bnka_destino INTO ls_bnka_destino WITH KEY banks = ls_reguh-zbnks
                                                               bankl = ls_reguh-zbnkl.
      IF sy-subrc EQ 0.
        gs_bancos-ban_dest = ls_bnka_destino-banka.
      ENDIF.
*      gs_bancos-zbnkn = ls_reguh-zbnkn.
      APPEND gs_bancos TO gt_bancos.
      READ TABLE gt_bancos INTO ls_bancos WITH KEY zbnkn = ls_reguh-zbnkn.
      IF sy-subrc EQ 0.
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " F_OBTENER_BANCO
*&---------------------------------------------------------------------*
*&      Form  CON_VAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM con_val  USING p_valor TYPE c
                    p_waers TYPE waers.

  IF   p_waers NE 'CLP'.
    CASE gv_dcpfm.
      WHEN ' '. "Coma Decimal - 1.234.567,89
        REPLACE ALL OCCURRENCES OF '.' IN p_valor WITH ' '.
        REPLACE ',' IN p_valor WITH '.'.
      WHEN 'X'. "Punto Decimal - 1,234,567.89
        REPLACE ALL OCCURRENCES OF ',' IN p_valor WITH ' '.
      WHEN 'Y'. "Coma Decima - 1 234 567,89
        REPLACE ',' IN p_valor WITH '.'.
    ENDCASE.
  ELSE.
    REPLACE ',' IN p_valor WITH '.'.
  ENDIF.
  CONDENSE p_valor NO-GAPS.

ENDFORM.                    " CON_VAL
*&---------------------------------------------------------------------*
*&      Form  AGREGAR_PROV_BELNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM agregar_prov_belnr .
  DATA: ls_regup      TYPE ty_regup,
        ls_prov_vblnr TYPE ty_prov_vblnr.
  LOOP AT gt_regup INTO ls_regup.
    MOVE-CORRESPONDING ls_regup TO ls_prov_vblnr.
    APPEND ls_prov_vblnr TO gt_prov_vblnr.
  ENDLOOP.
  SORT gt_prov_vblnr BY vblnr.
  DELETE ADJACENT DUPLICATES FROM gt_prov_vblnr COMPARING vblnr.

ENDFORM.                    " AGREGAR_PROV_BELNR
*&---------------------------------------------------------------------*
*&      Form  F_LIMPIAR_DATOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_limpiar_datos .

  REFRESH gt_documentos.
  REFRESH gt_retenciones.
  REFRESH gt_bancos.

ENDFORM.                    " F_LIMPIAR_DATOS