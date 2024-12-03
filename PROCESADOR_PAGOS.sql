/*==============================================================*/
/* User: PROCESADORPAGOS                                        */
/*==============================================================*/
CREATE SCHEMA IF NOT EXISTS PROCESADORPAGOS;

/*==============================================================*/
/* Table: BANCO                                                 */
/*==============================================================*/
CREATE TABLE IF NOT EXISTS BANCO (
   COD_BANCO            INT2                 not null,
   CODIGO_INTERNO       varchar(10)          not null,
   RUC                  varchar(13)          not null,
   RAZON_SOCIAL         varchar(100)         null,
   NOMBRE_COMERCIAL     varchar(100)         not null,
   FECHA_CREACION       TIMESTAMP            not null,
   COD_COMISION         INT2                 not null,
   ESTADO               varchar(3)           not null
      constraint CKC_ESTADO_BANCO check (ESTADO in ('ACT','INA','QUI')),
   FECHA_INACTIVACION   TIMESTAMP            null,
   constraint PK_BANCO primary key (COD_BANCO)
);

/*==============================================================*/
/* Table: COMISION                                              */
/*==============================================================*/
CREATE TABLE IF NOT EXISTS COMISION (
   COD_COMISION         INT2                 not null,
   TIPO                 VARCHAR(2)           not null
      constraint CKC_TIPO_COMISION check (TIPO in ('POR','FIJ')),
   MONTO_BASE           numeric(20,4)        not null,
   TRANSACCIONES_BASE   numeric(9)           not null,
   MANEJA_SEGMENTOS     boolean              not null,
   constraint PK_COMISION primary key (COD_COMISION)
);

/*==============================================================*/
/* Table: COMISION_SEGMENTO                                     */
/*==============================================================*/
CREATE TABLE IF NOT EXISTS COMISION_SEGMENTO (
   COD_COMISION         INT2                 not null,
   TRANSACCIONES_DESDE  numeric(9)           not null,
   TRANSACCIONES_HASTA  numeric(9)           not null,
   MONTO                numeric(20,4)        not null,
   constraint PK_COMISION_SEGMENTO primary key (COD_COMISION, TRANSACCIONES_DESDE)
);

/*==============================================================*/
/* Table: HISTORIAL_ESTADO_TRANSACCION                          */
/*==============================================================*/
CREATE TABLE IF NOT EXISTS PROCESADORPAGOS.HISTORIAL_ESTADO_TRANSACCION (
   COD_HISTORIAL_ESTADO INT2                 not null,
   COD_TRANSACCION      INT2                 not null,
   ESTADO               VARCHAR(3)           not null
      constraint CKC_ESTADO_HISTORIA check (ESTADO in ('PEN','APR','REC')),
   FECHA_ESTADO_CAMBIO  TIMESTAMP            not null,
   DETALLE              VARCHAR(50)          null,
   constraint PK_HISTORIAL_ESTADO_TRANSACCIO primary key (COD_HISTORIAL_ESTADO)
);

/*==============================================================*/
/* Table: LOG_CONEXION                                          */
/*==============================================================*/
CREATE TABLE IF NOT EXISTS PROCESADORPAGOS.LOG_CONEXION (
   COD_LOG              INT2                 not null,
   MARCA                VARCHAR(4)           null
      constraint CKC_MARCA_LOG_CONE check (MARCA is null or (MARCA in ('VISA','AMEX','MSCD','DINE'))),
   COD_SEGURIDAD_PROCESADOR INT2             null,
   FECHA                TIMESTAMP            null default CURRENT_TIMESTAMP,
   IP_ORIGEN            VARCHAR(15)          not null,
   OPERACION            VARCHAR(50)          not null,
   RESULTADO            VARCHAR(3)           not null
      constraint CKC_RESULTADO_LOG_CONE check (RESULTADO in ('EXI','FRA','ERR')),
   constraint PK_LOG_CONEXION primary key (COD_LOG)
);

/*==============================================================*/
/* Table: MONITOREO_FRAUDE                                      */
/*==============================================================*/
CREATE TABLE IF NOT EXISTS PROCESADORPAGOS.MONITOREO_FRAUDE (
   COD_MONITOREO_FRAUDE INT2                 not null,
   COD_REGLA            INT2                 null,
   RIESGO               VARCHAR(5)           null default '1'
      constraint CKC_RIESGO_MONITORE check (RIESGO is null or (RIESGO between '1' and '5' and RIESGO in ('M'))),
   FECHA_DETECCION      TIMESTAMP            null,
   constraint PK_MONITOREO_FRAUDE primary key (COD_MONITOREO_FRAUDE)
);

/*==============================================================*/
/* Table: REGLA_FRAUDE                                          */
/*==============================================================*/
CREATE TABLE IF NOT EXISTS PROCESADORPAGOS.REGLA_FRAUDE (
   COD_REGLA            INT2                 not null,
   COD_TRANSACCION      INT2                 null,
   NOMBRE_REGLA         VARCHAR(50)          not null,
   LIMITE_TRANSACCIONES NUMERIC(9,0)         null
      constraint CKC_LIMITE_TRANSACCIO_REGLA_FR check (LIMITE_TRANSACCIONES is null or (LIMITE_TRANSACCIONES >= 0)),
   PERIODO_TIEMPO       VARCHAR(3)           null
      constraint CKC_PERIODO_TIEMPO_REGLA_FR check (PERIODO_TIEMPO is null or (PERIODO_TIEMPO in ('1HORA','1DIA','1SEMANA'))),
   LIMITE_MONTO_TOTAL   NUMERIC(18, 2)       null
      constraint CKC_LIMITE_MONTO_TOTA_REGLA_FR check (LIMITE_MONTO_TOTAL is null or (LIMITE_MONTO_TOTAL >= 0)),
   FECHA_CREACION       TIMESTAMP            null default CURRENT_TIMESTAMP,
   FECHA_ACTUALIZACION  TIMESTAMP            null default CURRENT_TIMESTAMP,
   constraint PK_REGLA_FRAUDE primary key (COD_REGLA)
);

/*==============================================================*/
/* Table: SEGURIDAD_BANCO                                       */
/*==============================================================*/
CREATE TABLE IF NOT EXISTS SEGURIDAD_BANCO (
   COD_SEGURIDAD_PROCESADOR INT2             not null,
   CLAVE                varchar(128)         not null,
   FECHA_ACTUALIZACION  TIMESTAMP            not null,
   FECHA_ACTIVACION     DATE                 not null,
   ESTADO               varchar(3)           not null,
   constraint PK_SEGURIDAD_BANCO primary key (COD_SEGURIDAD_PROCESADOR)
);

/*==============================================================*/
/* Table: SEGURIDAD_GATEWAY                                     */
/*==============================================================*/
CREATE TABLE IF NOT EXISTS SEGURIDAD_GATEWAY (
   COD_CLAVE_GATEWAY    SERIAL               not null,
   CLAVE                varchar(128)         not null,
   FECHA_CREACION       TIMESTAMP            not null,
   FECHA_ACTIVACION     date                 not null,
   ESTADO               varchar(3)           not null
      constraint CKC_ESTADO_SEGURIDA check (ESTADO in ('ACT','INA','PEN')),
   constraint PK_SEGURIDAD_GATEWAY primary key (COD_CLAVE_GATEWAY)
);

/*==============================================================*/
/* Table: SEGURIDAD_MARCA                                       */
/*==============================================================*/
CREATE TABLE IF NOT EXISTS SEGURIDAD_MARCA (
   MARCA                VARCHAR(4)           not null
      constraint CKC_MARCA_SEGURIDA check (MARCA in ('VISA','AMEX','MSCD','DINE')),
   CLAVE                varchar(128)         not null,
   FECHA_ACTUALIZACION  TIMESTAMP            not null,
   constraint PK_SEGURIDAD_MARCA primary key (MARCA)
);

/*==============================================================*/
/* Table: SEGURIDAD_PROCESADOR                                  */
/*==============================================================*/
CREATE TABLE IF NOT EXISTS SEGURIDAD_PROCESADOR (
   COD_SEGURIDAD_PROCESADOR INT2             not null,
   CLAVE                varchar(128)         not null,
   FECHA_ACTUALIZACION  TIMESTAMP            not null,
   FECHA_ACTIVACION     date                 not null,
   ESTADO               varchar(3)           not null,
   constraint PK_SEGURIDAD_PROCESADOR primary key (COD_SEGURIDAD_PROCESADOR)
);

/*==============================================================*/
/* Table: TRANSACCION                                           */
/*==============================================================*/
CREATE TABLE IF NOT EXISTS PROCESADORPAGOS.TRANSACCION (
   COD_TRANSACCION      INT2                 not null,
   COD_BANCO            INT2                 null,
   COD_COMISION         INT2                 null,
   MONTO                NUMERIC(18, 2)       not null,
   CODIGO_MONEDA        VARCHAR(3)           not null default '00',
   MARCA                VARCHAR(4)           not null
      constraint CKC_MARCA_TRANSACC check (MARCA in ('VISA','AMEX','MSCD','DINE')),
   FECHA_EXPIRACION_TARJETA VARCHAR(64)          not null,
   NOMBRE_TARJETA       VARCHAR(64)          not null,
   NUMERO_TARJETA       VARCHAR(64)          not null,
   DIRECCION_TARJETA    VARCHAR(64)          not null,
   CVV                  VARCHAR(64)          not null,
   ESTADO               VARCHAR(3)           not null
      constraint CKC_ESTADO_TRANSACC check (ESTADO in ('PEN','APRO','RECHA')),
   DETALLE              VARCHAR(50)          null,
   FECHA_CREACION       TIMESTAMP            not null,
   constraint PK_TRANSACCION primary key (COD_TRANSACCION)
);

ALTER TABLE BANCO
  DROP CONSTRAINT IF EXISTS FK_BANCO_REFERENCE_COMISION;
ALTER TABLE BANCO
  ADD CONSTRAINT FK_BANCO_REFERENCE_COMISION FOREIGN KEY (COD_COMISION)
    REFERENCES COMISION (COD_COMISION)
    ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE COMISION_SEGMENTO
  DROP CONSTRAINT IF EXISTS FK_COMISION_REFERENCE_COMISION;
ALTER TABLE COMISION_SEGMENTO
  ADD CONSTRAINT FK_COMISION_REFERENCE_COMISION FOREIGN KEY (COD_COMISION)
    REFERENCES COMISION (COD_COMISION)
    ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE PROCESADORPAGOS.HISTORIAL_ESTADO_TRANSACCION
  DROP CONSTRAINT IF EXISTS FK_HISTORIA_REFERENCE_TRANSACC;
ALTER TABLE PROCESADORPAGOS.HISTORIAL_ESTADO_TRANSACCION
  ADD CONSTRAINT FK_HISTORIA_REFERENCE_TRANSACC FOREIGN KEY (COD_TRANSACCION)
    REFERENCES PROCESADORPAGOS.TRANSACCION (COD_TRANSACCION)
    ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE PROCESADORPAGOS.LOG_CONEXION
   DROP CONSTRAINT IF EXISTS FK_LOG_CONE_REFERENCE_SEGURIDA;
ALTER TABLE PROCESADORPAGOS.LOG_CONEXION
   ADD CONSTRAINT FK_LOG_CONE_REFERENCE_SEGURIDA foreign key (MARCA)
      references SEGURIDAD_MARCA (MARCA)
      on delete restrict on update restrict;

ALTER TABLE PROCESADORPAGOS.LOG_CONEXION
   DROP CONSTRAINT IF EXISTS FK_LOG_CONE_REFERENCE_SEGURID;
ALTER TABLE PROCESADORPAGOS.LOG_CONEXION
   ADD CONSTRAINT FK_LOG_CONE_REFERENCE_SEGURID foreign key (COD_SEGURIDAD_PROCESADOR)
      references SEGURIDAD_BANCO (COD_SEGURIDAD_PROCESADOR)
      on delete restrict on update restrict;

ALTER TABLE PROCESADORPAGOS.MONITOREO_FRAUDE
   DROP CONSTRAINT IF EXISTS FK_MONITORE_REFERENCE_REGLA_FR;
ALTER TABLE PROCESADORPAGOS.MONITOREO_FRAUDE
   ADD CONSTRAINT FK_MONITORE_REFERENCE_REGLA_FR foreign key (COD_REGLA)
      references PROCESADORPAGOS.REGLA_FRAUDE (COD_REGLA)
      on delete restrict on update restrict;

ALTER TABLE PROCESADORPAGOS.REGLA_FRAUDE
   DROP CONSTRAINT IF EXISTS FK_REGLA_FR_REFERENCE_TRANSACC;
ALTER TABLE PROCESADORPAGOS.REGLA_FRAUDE
   ADD CONSTRAINT FK_REGLA_FR_REFERENCE_TRANSACC foreign key (COD_TRANSACCION)
      references PROCESADORPAGOS.TRANSACCION (COD_TRANSACCION)
      on delete restrict on update restrict;

ALTER TABLE PROCESADORPAGOS.TRANSACCION
   DROP CONSTRAINT IF EXISTS FK_TRANSACC_REFERENCE_BANCO;
ALTER TABLE PROCESADORPAGOS.TRANSACCION
   ADD CONSTRAINT FK_TRANSACC_REFERENCE_BANCO foreign key (COD_BANCO)
      references BANCO (COD_BANCO)
      on delete restrict on update restrict;

ALTER TABLE PROCESADORPAGOS.TRANSACCION
   DROP CONSTRAINT IF EXISTS FK_TRANSACC_REFERENCE_COMISION;
ALTER TABLE PROCESADORPAGOS.TRANSACCION
   ADD CONSTRAINT FK_TRANSACC_REFERENCE_COMISION foreign key (COD_COMISION)
      references COMISION (COD_COMISION)
      on delete restrict on update restrict;

