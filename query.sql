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
    WHEN dk_molekulargenetik.artdersequenzierung = 'X' THEN 'unknown'
    ELSE 'other'
  END AS donors_items_labdata_items_librarytype,
  dk_molekulargenetik.tumorzellgehalt AS donors_items_labdata_items_tumorCellCount_items_count,
  CASE
    WHEN dk_molekulargenetik.referenzgenom = 'HG19' THEN 'GRCh37'
	  WHEN dk_molekulargenetik.referenzgenom = 'HG38' THEN 'GRCh38'
	END AS donors_items_labdata_items_sequencedata_referencegenome
FROM dk_molekulargenetik
  JOIN prozedur ON (prozedur.id = dk_molekulargenetik.id)
  JOIN patient ON (patient.id = prozedur.patient_id)
  JOIN organisationunit ON (organisationunit.id = dk_molekulargenetik.durchfuehrendeoe_fachabteilung)
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
WHERE einsendenummer = "..."
