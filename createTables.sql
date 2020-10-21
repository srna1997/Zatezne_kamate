-- Drop tables and sequence 

DROP TABLE stavke_obracuna;
DROP TABLE obracuni_zateznih;
DROP TABLE stavke_uplata;
DROP TABLE uplate;
DROP TABLE stavke_racuna;
DROP TABLE racuni;
DROP TABLE proizvodi;
DROP TABLE stranke;
DROP SEQUENCE str_seq;
DROP SEQUENCE pzd_seq;
DROP SEQUENCE rcn_seq;
DROP SEQUENCE sra_seq;
DROP SEQUENCE upa_seq;
DROP SEQUENCE sue_seq;
DROP SEQUENCE ozh_seq;
DROP SEQUENCE soa_seq;
DROP PACKAGE pck_kamate;

-- Create tables

CREATE TABLE stranke
(
    id NUMBER NOT NULL,
    sifra VARCHAR2(20) NOT NULL,
    naziv VARCHAR2(20) NOT NULL,
    CONSTRAINT str_pk PRIMARY KEY(id)
);
/

CREATE TABLE proizvodi
(
    id NUMBER NOT NULL,
    sifra VARCHAR2(20) NOT NULL,
    naziv VARCHAR2(20) NOT NULL,
    jed_cijena NUMBER(7,2) NOT NULL,
    CONSTRAINT pzd_pk PRIMARY KEY(id)
);
/

CREATE TABLE racuni
(
    id NUMBER NOT NULL,
    broj VARCHAR2(20) NOT NULL,
    ukupan_iznos NUMBER(9,2),
    datum_dospijeca DATE NOT NULL,
    str_id NUMBER NOT NULL,
    CONSTRAINT rcn_pk PRIMARY KEY(id),
    CONSTRAINT rcn_str_id_fk FOREIGN KEY(str_id)
    REFERENCES stranke(id)
);
/

CREATE TABLE stavke_racuna
(
    id NUMBER NOT NULL,
    kolicina NUMBER(4) NOT NULL,
    cijena NUMBER(9,2) NOT NULL,
    rcn_id NUMBER NOT NULL,
    pzd_id NUMBER NOT NULL,
    CONSTRAINT sra_pk PRIMARY KEY(id),
    CONSTRAINT sra_rcn_id_fk FOREIGN KEY(rcn_id)
    REFERENCES racuni(id),
    CONSTRAINT sra_pzd_id_fk FOREIGN KEY(pzd_id)
    REFERENCES proizvodi(id)
);
/

CREATE TABLE uplate
(
    id NUMBER NOT NULL,
    broj VARCHAR2(20) NOT NULL,
    datum DATE NOT NULL,
    CONSTRAINT upa_pk PRIMARY KEY(id)
);
/

CREATE TABLE stavke_uplata
(
    id NUMBER NOT NULL,
    upa_id NUMBER NOT NULL,
    rcn_id NUMBER NOT NULL,
    iznos_uplate NUMBER(9,2),
    CONSTRAINT sue_pk PRIMARY KEY(id),
    CONSTRAINT sue_upa_id_fk FOREIGN KEY(upa_id) 
    REFERENCES uplate(id),
    CONSTRAINT sue_rcn_id_fk FOREIGN KEY(rcn_id)
    REFERENCES racuni(id)
);
/

CREATE TABLE obracuni_zateznih
(
    id NUMBER NOT NULL,
    broj_obracuna VARCHAR2(20) NOT NULL,
    datum_pokretanja DATE NOT NULL,
    CONSTRAINT ozh_pk PRIMARY KEY(id)
);
/

CREATE TABLE stavke_obracuna
(
    id NUMBER NOT NULL,
    ozh_id NUMBER NOT NULL,
    rcn_id NUMBER NOT NULL,
    iznos_kamate NUMBER(9,2),
    CONSTRAINT soa_pk PRIMARY KEY(id),
    CONSTRAINT soa_ozh_id_fk FOREIGN KEY(ozh_id)
    REFERENCES obracuni_zateznih(id),
    CONSTRAINT soa_rcn_id_fk FOREIGN KEY(rcn_id)
    REFERENCES racuni(id)
);
/

--Create sequences and triggers for autoincrement id

CREATE SEQUENCE str_seq
START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE TRIGGER Autoincrement_str
BEFORE INSERT
ON stranke
REFERENCING NEW AS NEW
FOR EACH ROW 
BEGIN
    IF(:NEW.id IS NULL) THEN
    SELECT str_seq.NEXTVAL
    INTO :NEW.id
    FROM dual;
    END IF;
END;
/

CREATE SEQUENCE pzd_seq
START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE TRIGGER Autoincrement_pzd
BEFORE INSERT
ON proizvodi
REFERENCING NEW AS NEW
FOR EACH ROW 
BEGIN
    IF(:NEW.id IS NULL) THEN
    SELECT pzd_seq.NEXTVAL
    INTO :NEW.id
    FROM dual;
    END IF;
END;
/

CREATE SEQUENCE rcn_seq
START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE TRIGGER Autoincrement_rcn
BEFORE INSERT
ON racuni
REFERENCING NEW AS NEW
FOR EACH ROW 
BEGIN
    IF(:NEW.id IS NULL) THEN
    SELECT rcn_seq.NEXTVAL
    INTO :NEW.id
    FROM dual;
    END IF;
END;
/

CREATE SEQUENCE sra_seq
START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE TRIGGER Autoincrement_sra
BEFORE INSERT
ON stavke_racuna
REFERENCING NEW AS NEW
FOR EACH ROW 
BEGIN
    IF(:NEW.id IS NULL) THEN
    SELECT sra_seq.NEXTVAL
    INTO :NEW.id
    FROM dual;
    END IF;
END;
/

CREATE SEQUENCE upa_seq
START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE TRIGGER Autoincrement_upa
BEFORE INSERT
ON uplate
REFERENCING NEW AS NEW
FOR EACH ROW 
BEGIN
    IF(:NEW.id IS NULL) THEN
    SELECT upa_seq.NEXTVAL
    INTO :NEW.id
    FROM dual;
    END IF;
END;
/

CREATE SEQUENCE sue_seq
START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE TRIGGER Autoincrement_sue
BEFORE INSERT
ON stavke_uplata
REFERENCING NEW AS NEW
FOR EACH ROW 
BEGIN
    IF(:NEW.id IS NULL) THEN
    SELECT sue_seq.NEXTVAL
    INTO :NEW.id
    FROM dual;
    END IF;
END;
/

CREATE SEQUENCE ozh_seq
START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE TRIGGER Autoincrement_ozh
BEFORE INSERT
ON obracuni_zateznih
REFERENCING NEW AS NEW
FOR EACH ROW 
BEGIN
    IF(:NEW.id IS NULL) THEN
    SELECT ozh_seq.NEXTVAL
    INTO :NEW.id
    FROM dual;
    END IF;
END;
/

CREATE SEQUENCE soa_seq
START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE TRIGGER Autoincrement_soa
BEFORE INSERT
ON stavke_obracuna
REFERENCING NEW AS NEW
FOR EACH ROW 
BEGIN
    IF(:NEW.id IS NULL) THEN
    SELECT soa_seq.NEXTVAL
    INTO :NEW.id
    FROM dual;
    END IF;
END;
/

-- Inserting in str and pzd

INSERT ALL
INTO stranke(sifra,naziv) VALUES('0001', 'str01')
INTO stranke(sifra,naziv) VALUES('0002', 'str02')
INTO stranke(sifra,naziv) VALUES('0003', 'str03')
SELECT * FROM DUAL;
/
INSERT ALL
INTO proizvodi(sifra,naziv,jed_cijena) VALUES('01','pzd01',10)
INTO proizvodi(sifra,naziv,jed_cijena) VALUES('02','pzd02',20)
INTO proizvodi(sifra,naziv,jed_cijena) VALUES('03','pzd03',30)
INTO proizvodi(sifra,naziv,jed_cijena) VALUES('04','pzd04',40)
INTO proizvodi(sifra,naziv,jed_cijena) VALUES('05','pzd05',50)
SELECT * FROM DUAL;
/