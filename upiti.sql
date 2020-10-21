-- upit01 za pronalazak stranke koja mora platiti najvise zateznih kamata

SELECT str.naziv
FROM stranke str,racuni rcn, stavke_obracuna soa
WHERE str.id = rcn.str_id
AND rcn.id = soa.rcn_id
AND soa.iznos_kamate = (SELECT max(iznos_kamate) FROM stavke_obracuna);
/

--upit02 za proizvod koji se ponavlja u najvise racuna... problem(ako imamo isti broj proizvoda izbacuje samo prvi zbog rownum)

SELECT * FROM 
(SELECT pzd.naziv
FROM proizvodi pzd, stavke_racuna sra
WHERE pzd.id = sra.pzd_id
GROUP BY pzd.naziv
ORDER BY count(*) DESC)
WHERE ROWNUM = 1;
/

-- upit02 pokusaj broj 2
SELECT * FROM 
(SELECT pzd.naziv
FROM proizvodi pzd, stavke_racuna sra
WHERE pzd.id = sra.pzd_id
ORDER BY sra.pzd_id DESC)
WHERE ROWNUM = 1;
/
-- upit02 pokusaj broj 3
SELECT pzd.naziv 
FROM proizvodi pzd,stavke_racuna sra
WHERE pzd.id = sra.pzd_id 
AND sra.pzd_id = (SELECT stats_mode(pzd_id) FROM stavke_racuna)
ORDER BY sra.pzd_id DESC;
/
-- upit02 pokusaj broj 4
SELECT * 
FROM (SELECT pzd.naziv 
FROM proizvodi pzd, stavke_racuna sra
WHERE pzd.id = sra.pzd_id 
AND sra.pzd_id = (SELECT stats_mode(pzd_id) FROM stavke_racuna)
ORDER BY sra.pzd_id DESC)
WHERE ROWNUM = 1;
/

--upit03 razlika zateznih kamata po zadnjem u odnosu na predzadnji 

SELECT r1.iznos_kamate - r2.iznos_kamate as razlika
FROM 
(SELECT iznos_kamate FROM stavke_obracuna WHERE id = (SELECT MAX(id) FROM stavke_obracuna)) r1,
(SELECT iznos_kamate FROM stavke_obracuna WHERE id = (SELECT MAX(id)-1 FROM stavke_obracuna))r2
WHERE ROWNUM = 1;
/
--upit04 trazi koji je racun placen u najkracem roku od datuma nastanka racuna (nije dovršeno)

SELECT rcn.id, rcn.broj FROM racuni rcn
INNER JOIN stavke_uplata sua ON sua.rcn_id = rcn.id
INNER JOIN uplate upa ON upa.id = sua.upa_id
WHERE rcn.ukupan_iznos < (SELECT SUM(iznos_uplate) FROM stavke_uplata WHERE sua.rcn_id = rcn.id)
AND upa.datum = (SELECT MIN(datum) FROM uplate);
/

----------------------------------------------------------------------------------------------------------------------------------
/*
SELECT * FROM stavke_obracuna;
/

SELECT rcn.id, rcn.ukupan_iznos,SUM(sua.iznos_uplate) as iznos_uplate, rcn.datum_dospijeca,upa.datum
FROM racuni rcn,uplate upa, stavke_uplata sua
WHERE rcn.id = sua.rcn_id
AND upa.id = sua.upa_id
GROUP BY rcn.id,rcn.ukupan_iznos,rcn.datum_dospijeca,upa.datum
ORDER BY rcn.id ASC;
/

SELECT rcn.id, rcn.ukupan_iznos,SUM(sua.iznos_uplate) as iznos_uplate
FROM racuni rcn,uplate upa, stavke_uplata sua
WHERE rcn.id = sua.rcn_id
AND upa.id = sua.upa_id
GROUP BY rcn.id,rcn.ukupan_iznos
ORDER BY rcn.id ASC;
/


SELECT rcn.id FROM racuni rcn
INNER JOIN stavke_uplata sua ON sua.rcn_id = rcn.id
INNER JOIN uplate upa ON upa.id = sua.upa_id
WHERE rcn.ukupan_iznos < (SELECT SUM(iznos_uplate) FROM stavke_uplata WHERE sua.rcn_id = rcn.id)
AND upa.datum = (SELECT MIN() FROM uplate)
GROUP BY rcn.id, rcn.ukupan_iznos,upa.datum,rcn.datum_dospijeca;
/
