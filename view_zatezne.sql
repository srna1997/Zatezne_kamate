CREATE OR REPLACE VIEW vw_zatezne AS
  SELECT str.naziv as stranka,rcn.broj as broj_racuna,rcn.datum_dospijeca as datum_dospijeca,MAX(upa.datum) as datum_zadnje_uplate,SUM(soa.iznos_kamate) as iznos_kamate
  FROM stranke str
  INNER JOIN racuni rcn ON rcn.str_id = str.id
  INNER JOIN stavke_uplata sua ON sua.rcn_id = rcn.id
  INNER JOIN uplate upa ON upa.id = sua.upa_id
  INNER JOIN stavke_obracuna soa ON soa.rcn_id = rcn.id
  WHERE rcn.ukupan_iznos >(
  SELECT SUM(sua.iznos_uplate) FROM stavke_uplata)
  GROUP BY str.naziv, rcn.broj, rcn.datum_dospijeca, upa.datum;
/

SELECT * FROM vw_zatezne
/
/*
CREATE OR REPLACE TRIGGER trigger_for_view
    INSTEAD OF INSERT ON vw_zatezne
    FOR EACH ROW
DECLARE
str_id NUMBER;

BEGIN

INSERT INTO stranke(naziv)
VALUES(:NEW.stranka)
RETURNING id INTO str_id;
                     
INSERT INTO racuni(broj,datum_dospijeca,str_id)
VALUES(:NEW.broj_racuna,:NEW.datum_dospijeca,str_id);
            
INSERT INTO uplate(datum)
VALUES(:NEW.datum_zadnje_uplate);
        
INSERT INTO stavke_obracuna(iznos_kamate)
VALUES(:NEW.iznos_kamate);
  
END;
/
SELECT * FROM stavke_uplata;
/
INSERT INTO vw_zatezne
VALUES('str007','111111',TO_DATE('01-01-2008','DD-MM-YYYY')+round(dbms_random.value(1,60)),TO_DATE('01-02-2008', 'dd-mm-yyyy')+ round(dbms_random.value(1,365)),15000);
*/