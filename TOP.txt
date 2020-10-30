*&---------------------------------------------------------------------*
*&  Include           ZRPFI144_TOP
*&---------------------------------------------------------------------*

* Inicio NRBA
TYPES: BEGIN OF ty_regup,
       bukrs TYPE regup-bukrs,      "sociedad
       lifnr TYPE regup-lifnr,      "Acreedor
       bldat TYPE regup-bldat,      "Fecha de documento
       budat TYPE regup-budat,      "Fecha de contabilización
       laufd TYPE regup-laufd,      "Fecha de ejecución de programa
       belnr TYPE regup-belnr,      "Numero de documento de pago
       vblnr TYPE regup-vblnr,      "Numero de documento de pago
       buzei TYPE regup-buzei,      "Posicion documento
       gjahr TYPE regup-gjahr,      "Ejercicio
       zlsch TYPE regup-zlsch,      "Via de pago
       xblnr TYPE regup-xblnr,      "Nunmero de documento de referencia
       pswbt TYPE regup-pswbt,      "Importe de actualizacion libro mayor
       blart TYPE regup-blart,      "Descripcion moneda
       waers TYPE regup-waers,      " Moneda
       hbkid TYPE regup-hbkid,
       qsshb TYPE regup-qsshb,
       qbshb TYPE regup-qbshb,
       laufi TYPE regup-laufi,
       zbukr TYPE regup-zbukr,
       wrbtr TYPE regup-wrbtr,
       shkzg TYPE regup-shkzg,
     END OF ty_regup.


TYPES: BEGIN OF gty_reguh,


laufd TYPE  reguh-laufd,
laufi TYPE  reguh-laufi,
xvorl TYPE  reguh-xvorl,
zbukr TYPE  reguh-zbukr,
lifnr TYPE  reguh-lifnr,
kunnr TYPE  reguh-kunnr,
empfg TYPE  reguh-empfg,
name1 TYPE  reguh-name1,
ort01 TYPE  reguh-ort01,
stras TYPE  reguh-stras,
land1 TYPE  reguh-land1,
hbkid TYPE  reguh-hbkid,
zbnks TYPE  reguh-zbnks,
zbnkl TYPE  reguh-zbnkl,
zland TYPE  reguh-zland,
zbnkn TYPE  reguh-zbnkn,
vblnr TYPE  reguh-vblnr,
ubnks TYPE  banks,


END OF gty_reguh.




TYPES: BEGIN OF gty_with_item,
     bukrs     TYPE bukrs,
     belnr     TYPE belnr_d,
     gjahr     TYPE gjahr,
     witht     TYPE with_item-witht,
     wt_withcd TYPE with_item-wt_withcd,
     wt_qsshb  TYPE with_item-wt_qsshb,
     wt_qssh2  TYPE with_item-wt_qssh2,
     wt_qbshb  TYPE with_item-wt_qbshb,
     wt_qbsh2  TYPE with_item-wt_qbsh2,
     buzei     TYPE regup-buzei,
     qsatz     TYPE with_item-qsatz,
    END OF gty_with_item.


TYPES: BEGIN OF ty_bkpf,

     bukrs TYPE bukrs,
     belnr TYPE belnr_d,
     gjahr TYPE gjahr,
     kursf TYPE kursf,

    END OF ty_bkpf.


TYPES: BEGIN OF gty_t059u,

    land1  TYPE land1,
    witht  TYPE witht,
    text40 TYPE  text40,

    END OF gty_t059u.


TYPES: BEGIN OF gty_t001,
   bukrs   TYPE   t001-bukrs,
   butxt   TYPE   t001-butxt,
   land1   TYPE   t001-land1,
   adrnr   TYPE   t001-adrnr,
  END OF  gty_t001.


TYPES: BEGIN OF gty_adrc,
  street     TYPE   adrc-street,
  city1      TYPE   adrc-city1,
  addrnumber TYPE   adrc-addrnumber,
  post_code1 TYPE   adrc-post_code1,
  tel_number TYPE   adrc-tel_number,
  END OF  gty_adrc.

TYPES: BEGIN OF gty_proveedor,

  name1 TYPE lfa1-name1,
  stras TYPE lfa1-stras,
  land1 TYPE lfa1-land1,
  ort01 TYPE lfa1-ort01,
  stcd  TYPE lfa1-stcd1,
  lifnr TYPE  regup-lifnr,

END OF  gty_proveedor.

TYPES: BEGIN OF gty_orden_pago,

   vblnr TYPE  reguh-vblnr,
   zaldt TYPE  reguh-zaldt,
END OF gty_orden_pago.



TYPES: BEGIN OF gty_t012,
    bukrs TYPE bukrs,
    hbkid TYPE hbkid,
    bankl TYPE bankk,
    banks TYPE banks,
END OF gty_t012.

TYPES: BEGIN OF gty_bnka,
    banks TYPE banks,
    bankl TYPE bankl,
    banka TYPE banka,
END OF gty_bnka.


TYPES : BEGIN OF ty_zbctb_params,
  id_range TYPE c,
  zsign    TYPE zbctb_params-zsign,
  zoption  TYPE zbctb_params-zoption ,
  zlow     TYPE zbctb_params-zlow,
  zhigh    TYPE zbctb_params-zhigh,
  END OF ty_zbctb_params.



TYPES:  BEGIN OF ty_prov_vblnr,
        bukrs TYPE bukrs,
        lifnr TYPE lifnr,
        vblnr TYPE vblnr,
        belnr TYPE belnr_d,
      END OF ty_prov_vblnr.

TYPES:  BEGIN OF ty_prov_belnr,
        belnr TYPE belnr_d,
      END OF ty_prov_belnr.

TYPES: BEGIN OF ty_sociedades,

   bukrs TYPE bukrs,
   lifnr TYPE lifnr,
   butxt   TYPE   t001-butxt,
   land1   TYPE   t001-land1,
   adrnr   TYPE   t001-adrnr,

  END OF ty_sociedades.

TYPES:  BEGIN OF ty_lfbk,

 lifnr  TYPE lifnr,
 banks  TYPE banks,
 bankl  TYPE bankk,

END OF   ty_lfbk.

*INICIO NRBA
DATA: gt_regup        TYPE STANDARD TABLE OF ty_regup,
      p_regup         TYPE ty_regup,
      gt_with_item_2  TYPE STANDARD TABLE OF gty_with_item,
      gt_with_item_1  TYPE STANDARD TABLE OF gty_with_item,
      gt_t059u        TYPE STANDARD TABLE OF gty_t059u,
      gt_t059u_2      TYPE STANDARD TABLE OF gty_t059u,
      gt_t001         TYPE STANDARD TABLE OF gty_t001,
      gt_orden_pago   TYPE STANDARD TABLE OF gty_orden_pago,
      gt_reguh        TYPE STANDARD TABLE OF gty_reguh,
      gt_bkpf         TYPE STANDARD TABLE OF ty_bkpf,
      gs_cabecera     TYPE zsfi053,
      gt_cabecera     TYPE STANDARD TABLE OF zsfi053,
      gs_proveedor    TYPE zsfi054,
      gs_orden_pago   TYPE zsfi055,
      gs_documentos   TYPE zsfi056,
      gs_retenciones  TYPE zsfi057,
      gs_bancos       TYPE zsfi058,
      gt_documentos   TYPE STANDARD TABLE OF  zsfi056,
      gt_retenciones  TYPE STANDARD TABLE OF  zsfi057,
      gt_bancos       TYPE STANDARD TABLE OF  zsfi058,
      p_in_words      TYPE spell,
      gt_t003t        TYPE TABLE OF t003t,
      gt_t012         TYPE STANDARD TABLE OF gty_t012,
      gt_bnka_origen  TYPE STANDARD TABLE OF gty_bnka,
      gt_bnka_destino TYPE STANDARD TABLE OF gty_bnka,
      gt_bnka_des_ecu TYPE STANDARD TABLE OF gty_bnka,
      gt_lfbk         TYPE STANDARD TABLE OF ty_lfbk,
      gt_tcurt        TYPE STANDARD TABLE OF tcurt,
      gs_tcurt        TYPE tcurt,
      gt_prov_vblnr   TYPE STANDARD TABLE OF ty_prov_vblnr,
      gt_prov_belnr   TYPE STANDARD TABLE OF ty_prov_belnr,
*      gt_soc_acre     TYPE STANDARD TABLE OF gty_soc_acre,
*      gs_soc_acre     TYPE gty_soc_acre,
      gt_sociedades        TYPE TABLE OF ty_sociedades,
      gs_sociedades        TYPE ty_sociedades,
      gt_proveedor TYPE TABLE OF ty_sociedades.


DATA: r_bukrs TYPE STANDARD TABLE OF ty_zbctb_params,
      r_pagos TYPE STANDARD TABLE OF ty_zbctb_params,
      gs_bukrs TYPE ty_zbctb_params,
      gs_pagos TYPE ty_zbctb_params.

DATA gt_adjuntos_hexa TYPE zty_adjuntos_hexa.
DATA: gt_adjuntos_text TYPE zty_adjuntos_text.

*DATA gs_log          TYPE bal_s_log.
*DATA gv_log_handle   TYPE balloghndl.
*DATA gt_log_handle   TYPE bal_t_logh.
*DATA gt_log_num      TYPE bal_t_lgnm.
DATA gt_msg          TYPE STANDARD TABLE OF bal_s_msg.
DATA gs_msg          LIKE LINE OF gt_msg.

CONSTANTS:  c_zsffi011 TYPE tnapr-sform VALUE 'ZSFFI011', "Orden de pago
            c_trans    TYPE char20      VALUE 'TRANSFERENCIA',
            c_efect    TYPE char20      VALUE 'EFECTIVO',
            c_manual   TYPE char20      VALUE 'MANUAL',
            c_pdf      TYPE char3       VALUE 'PDF',
            c_otf      TYPE char3       VALUE 'OTF'.

*INCLUDE zbcin_mrpt_user.

DATA: lw_job_output_info    TYPE ssfcrescl,
      lw_job_output_options TYPE ssfcresop.

DATA: gv_dcpfm TYPE xudcpfm,
      gv_total  TYPE  wrbtr.