### Generelle Informationen aus OS.Molekulargenetik

SELECT
  organisationunit.identifier AS submission_labname,
  CASE
    WHEN kostentraegertyp = 'GKV' THEN 'GKV'
    WHEN kostentraegertyp = 'PKV' THEN 'PKV'
    ELSE 'UNK'
  END AS submission_coveragetype,
  einsendenummer AS submission_localcaseid,
  CASE
    WHEN patient.geschlecht = 'm' THEN 'male'
    WHEN patient.geschlecht = 'w' THEN 'female'
    WHEN patient.geschlecht = 'u' THEN 'unknown'
    ELSE 'other'
  END AS donors_items_gender,
  'index' AS donors_items_relation, # Fix?
  CONCAT(prop_probenmaterial.shortdesc, ' ', prop_nukleinsaeure.shortdesc) AS donors_items_labdata_items_labdataname,
    dk_molekulargenetik.entnahmedatum AS donors_items_labdata_items_sampledate,
    prop_materialfixierung.shortdesc AS donors_items_labdata_items_sampleconservation,
    LOWER(prop_nukleinsaeure.shortdesc) AS donors_items_labdata_items_sequencetype,
  CASE
    WHEN dk_molekulargenetik.artdersequenzierung = 'WES' THEN 'wes'
    WHEN dk_molekulargenetik.artdersequenzierung = 'WGS' THEN 'wgs'
    WHEN dk_molekulargenetik.artdersequenzierung = 'PanelKit' THEN 'panel'
    WHEN dk_molekulargenetik.artdersequenzierung = 'X' THEN 'unknown'
    ELSE 'other'
  END AS donors_items_labdata_items_librarytype,
  dk_molekulargenetik.panel AS x_panel, # Use this to select default Kit info
  dk_molekulargenetik.tumorzellgehalt AS donors_items_labdata_items_tumorCellCount_items_count,
  CASE
    WHEN dk_molekulargenetik.referenzgenom = 'HG19' THEN 'GRCh37'
	  WHEN dk_molekulargenetik.referenzgenom = 'HG38' THEN 'GRCh38'
	END AS donors_items_labdata_items_sequencedata_referencegenome
FROM dk_molekulargenetik
  JOIN prozedur ON (prozedur.id = dk_molekulargenetik.id)
  JOIN patient ON (patient.id = prozedur.patient_id)
  LEFT JOIN organisationunit ON (organisationunit.id = dk_molekulargenetik.durchfuehrendeoe_fachabteilung)
  LEFT JOIN property_catalogue_version_entry AS prop_nukleinsaeure ON (
    prop_nukleinsaeure.property_version_id = dk_molekulargenetik.nukleinsaeure_propcat_version
	  AND prop_nukleinsaeure.code = dk_molekulargenetik.nukleinsaeure)
  LEFT JOIN property_catalogue_version_entry AS prop_probenmaterial ON (
    prop_probenmaterial.property_version_id = dk_molekulargenetik.probenmaterial_propcat_version
	  AND prop_probenmaterial.code = dk_molekulargenetik.probenmaterial)
  LEFT JOIN property_catalogue_version_entry AS prop_materialfixierung ON (
    prop_materialfixierung.property_version_id = dk_molekulargenetik.materialfixierung_propcat_version
	  AND prop_materialfixierung.code = dk_molekulargenetik.materialfixierung)

	# Hier die Einsendenummer aus Rohdaten-Datei in diesem Format einfügen
WHERE einsendenummer = '...'


### Weitere Informationen aus den DNPM-Formularen zu Fallnummer, Krankenkasse, ICD-O-3 etc.
### Bei mehreren Fällen werden mehrere Eintäge mit jeweiliger Fallnummer ermittelt.
	
SELECT DISTINCT
  dk_dnpm_kpa.fallnummermv AS fallnummer,
  dk_dnpm_kpa.krankenkasse AS krankenkasse,
  dk_dnpm_kpa.icdo3lokalisation AS icdo3lokalisation,
  dk_dnpm_kpa.artderkrankenkasse AS art_der_krankenkasse,
  dk_dnpm_consentmv.date AS consent_presentationDate,
  consentverlauf.version AS consent_version,
  consentverlauf.date AS consent_date,
  dk_dnpm_consentmv.sequencing AS consent_seqencing,
  dk_dnpm_consentmv.caseidentification AS consent_caseidentification,
  dk_dnpm_consentmv.reidentification AS consent_reidentification
FROM dk_dnpm_kpa
JOIN prozedur p_dnpm_kpa ON (p_dnpm_kpa.id = dk_dnpm_kpa.id)
JOIN erkrankung_prozedur ON (p_dnpm_kpa.id = erkrankung_prozedur.prozedur_id)
JOIN dk_dnpm_consentmv ON (dk_dnpm_kpa.consentmv64e = dk_dnpm_consentmv.id)
LEFT JOIN (
    SELECT
        dk_dnpm_uf_consentmvverlauf.version,
        dk_dnpm_uf_consentmvverlauf.date,
        prozedur.hauptprozedur_id
    FROM dk_dnpm_uf_consentmvverlauf
    JOIN prozedur ON (dk_dnpm_uf_consentmvverlauf.id = prozedur.id)
    ORDER BY dk_dnpm_uf_consentmvverlauf.date DESC
    LIMIT 1
) consentverlauf ON (consentverlauf.hauptprozedur_id = dk_dnpm_consentmv.id)
WHERE erkrankung_prozedur.erkrankung_id IN (
    SELECT DISTINCT erkrankung_prozedur.erkrankung_id
    FROM dk_molekulargenetik
    JOIN prozedur p_molekulargenetik ON (p_molekulargenetik.id = dk_molekulargenetik.id)
    JOIN erkrankung_prozedur ON (p_molekulargenetik.id = erkrankung_prozedur.prozedur_id)
    
	# Hier die Einsendenummer aus Rohdaten-Datei in diesem Format einfügen
    WHERE einsendenummer = '...'
);


### Weitere Informationen aus den DNPM-Formularen zu Fallnummer, Krankenkasse, ICD-O-3 etc. anhand der Fallnummer

SELECT DISTINCT
  dk_dnpm_kpa.krankenkasse AS krankenkasse,
  dk_dnpm_kpa.icdo3lokalisation AS icdo3lokalisation,
  dk_dnpm_kpa.artderkrankenkasse AS art_der_krankenkasse,
  dk_dnpm_consentmv.date AS consent_presentationDate,
  consentverlauf.version AS consent_version,
  consentverlauf.date AS consent_date,
  dk_dnpm_consentmv.sequencing AS consent_seqencing,
  dk_dnpm_consentmv.caseidentification AS consent_caseidentification,
  dk_dnpm_consentmv.reidentification AS consent_reidentification
FROM dk_dnpm_kpa
JOIN prozedur p_dnpm_kpa ON (p_dnpm_kpa.id = dk_dnpm_kpa.id)
JOIN erkrankung_prozedur ON (p_dnpm_kpa.id = erkrankung_prozedur.prozedur_id)
JOIN dk_dnpm_consentmv ON (dk_dnpm_kpa.consentmv64e = dk_dnpm_consentmv.id)
LEFT JOIN (
    SELECT
        dk_dnpm_uf_consentmvverlauf.version,
        dk_dnpm_uf_consentmvverlauf.date,
        prozedur.hauptprozedur_id
    FROM dk_dnpm_uf_consentmvverlauf
    JOIN prozedur ON (dk_dnpm_uf_consentmvverlauf.id = prozedur.id)
    ORDER BY dk_dnpm_uf_consentmvverlauf.date DESC
    LIMIT 1
) consentverlauf ON (consentverlauf.hauptprozedur_id = dk_dnpm_consentmv.id)
WHERE fallnummermv = '...';
