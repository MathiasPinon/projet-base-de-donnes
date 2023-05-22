
create table EVENEMENT 
(
   CDSITE               INTEGER              not null,
   NUMEV                INTEGER              not null,
   DATEDEBEV            DATE,
   DATEFINEV            DATE,
   NBPLACES             INTEGER,
      constraint CKC_NBPLACES_EVENEMEN check (NBPLACES is null or (NBPLACES >= 20)),
   TARIF                INTEGER,
   constraint PK_EVENEMENT primary key (CDSITE, NUMEV)
);

alter table EVENEMENT
   add constraint CKC_DATEFINEV_EVENELEN check (DATEFINEV is null or (DATEFINEV >= DATEDEBEV ));
   
create table PARTICIPANT 
(
   CDPERS               INTEGER              not null,
   NOMPERS              CHAR(50),
   PRENOMPERS           CHAR(50),
   ADRPERS              CHAR(50),
   CPPERS               CHAR(5),
   VILLEPERS            CHAR(50),
   TELPERS              CHAR(14),
   TPPERS               CHAR(1)             
      constraint CKC_TPPERS_PARTICIP check (TPPERS is null or (TPPERS in ('P','C','E'))),
   constraint PK_PARTICIPANT primary key (CDPERS)
);

create table RESERVATION 
(
   CDPERS               INTEGER              not null,
   CDSITE               INTEGER              not null,
   NUMEV                INTEGER              not null,
   DATERESA             DATE                 not null,
   NBPLRESA             INTEGER,
   MODEREGLT            INTEGER             
      constraint CKC_MODEREGLT_RESERVAT check (MODEREGLT is null or (MODEREGLT between 1 and 3)),
   constraint PK_RESERVATION primary key (CDSITE, CDPERS, NUMEV, DATERESA)
);

create table SITE 
(
   CDSITE               INTEGER              not null,
   CDTERR               INTEGER              not null,
   CDTHEME              INTEGER              not null,
   NOMSITE              CHAR(50),
   TPSITE               CHAR(50),
   ADRSITE              CHAR(50),
   CPSITE               CHAR(5),
   VILLESITE            CHAR(50),
   EMAILSITE            CHAR(50),
   TELSITE              CHAR(14),
   SITEWEB              CHAR(50),
   constraint PK_SITE primary key (CDSITE)
);

create table TERRITOIRE 
(
   CDTERR               INTEGER              not null,
   NOMTERR              CHAR(50),
   constraint PK_TERRITOIRE primary key (CDTERR)
);

create table THEME 
(
   CDTHEME              INTEGER              not null,
   LIBTHME              CHAR(50),
   constraint PK_THEME primary key (CDTHEME)
);

alter table EVENEMENT
   add constraint FK_EVENEMEN_ASSOCIATI_SITE foreign key (CDSITE)
      references SITE (CDSITE);
      
alter table RESERVATION
   add constraint FK_RESERVAT_ASSOCIATI_PARTICIP foreign key (CDPERS)
      references PARTICIPANT (CDPERS);
    

alter table RESERVATION
   add constraint FK_RESERVAT_ASSOCIATI_EVENEMEN foreign key (CDSITE, NUMEV)
      references EVENEMENT (CDSITE, NUMEV);
      
alter table SITE
   add constraint FK_SITE_ASSOCIATI_TERRITOI foreign key (CDTERR)
      references TERRITOIRE (CDTERR);
      
alter table SITE
   add constraint FK_SITE_ASSOCIATI_THEME foreign key (CDTHEME)
      references THEME (CDTHEME);
      
-- création de la table Activite 
create table ACTIVITE
(
   CDACT              INTEGER              not null,
   NOMACT              CHAR(50),
   constraint PK_ACTIVITE primary key (CDACT)
);

-- Création de la table programe
create table PROGRAME
(
    CDACT INTEGER CONSTRAINT FK_CDACT REFERENCES ACTIVITE(CDACT) ON DELETE CASCADE  ,
    CDSITE INTEGER CONSTRAINT FK_CDSITE REFERENCES SITE(CDSITE) ON DELETE CASCADE  ,
    TPPUBLIC CHAR(50)
);

-- Ajout de la colonne dateNais
ALTER TABLE PARTICIPANT 
ADD DATENAIS DATE ;


-- Ajout de la colonne  DUREEEV
ALTER TABLE EVENEMENT 
ADD DUREEEV GENERATED ALWAYS AS ( DATEFINEV - DATEDEBEV) ;
  
-- Index 

CREATE INDEX fk_CDTERR ON SITE (CDTERR);
CREATE INDEX fk_CDTHEME ON SITE (CDTHEME);
CREATE INDEX fk_CDSITE ON EVENEMENT (CDSITE);
CREATE INDEX fk_CDSITES ON RESERVATION (CDSITE);
CREATE INDEX fk_NUMEV ON RESERVATION (NUMEV);
CREATE INDEX fk_CDPERS ON RESERVATION (CDPERS);
CREATE INDEX ck_NOMSITE ON SITE (NOMSITE);
CREATE INDEX ck_NOMPERS ON PARTICIPANT (NOMPERS);
CREATE INDEX ck_PRENOMPERS ON PARTICIPANT (PRENOMPERS);
CREATE INDEX ck_NOMACT  ON ACTIVITE (NOMACT);

-- Insertion des valeurs de la table THEME

INSERT INTO THEME VALUES (1,'Animaux');
INSERT INTO THEME VALUES (2,'Sport');
INSERT INTO THEME VALUES (3,'Bateaux');
INSERT INTO THEME VALUES (4,'Ferme pédagogique');
INSERT INTO THEME VALUES (5,'Parcs et jardins');
INSERT INTO THEME VALUES (6,'Jeux pour enfants');
INSERT INTO THEME VALUES (7,'Patrimoine');
INSERT INTO THEME VALUES (8,'Parcours Sportifs');
INSERT INTO THEME VALUES (9,'Golf');
INSERT INTO THEME VALUES (10,'Sports nautiques');
INSERT INTO THEME VALUES (11,'Parc d"attractions');

-- Insertion des valeurs de la table TERRITOIRE

INSERT INTO TERRITOIRE VALUES (1,'Autour du Louvres - Lens');
INSERT INTO TERRITOIRE VALUES (2,'Vallées et Marais');
INSERT INTO TERRITOIRE VALUES (3,'Côte d"opale');

-- Insertion des valeurs de la table PARTICIPANT

CREATE SEQUENCE cdPersSq start with 1;

INSERT INTO PARTICIPANT
SELECT cdPersSq.NEXTVAL, nomPers, prenomPers, adrPers, cpPers, villePers,telPers,tpPers,dateNais
FROM TESTS1.EMPRUNTEUR;

INSERT INTO PARTICIPANT
SELECT cdPersSq.NEXTVAL, nom, prnm, adr, cp, localite,NULL,'P',datNs
FROM TESTS1.CLIENT;

-- Insertion des valeurs de la table SITE

INSERT INTO SITE
SELECT cdSite, si.cdTerr, si.cdTheme, nomSite, tpSite, adrSite, cpSite, villeSite, emailSite, telSite, siteweb
FROM TESTSAELD.SITE si, TERRITOIRE te, THEME th
WHERE si.cdTerr = te.cdTerr AND si.cdTheme = th.cdTheme;

-- Insertion des valeurs de la table EVENEMENT

ALTER TABLE EVENEMENT ADD nomEV CHAR(50);

INSERT INTO EVENEMENT (cdSite, numEv, nomEv, dateDebEv, dateFinEv, NbPlaces, Tarif)
SELECT e.cdSite, numEv, nomEv, dateDebEv, dateFinEv, NbPlaces, Tarif
FROM TESTSAELD.EVENEMENT e, SITE s
WHERE e.cdSite = s.cdSite;


-- Insertion des valeurs de la table RESERVATION 

INSERT INTO RESERVATION
SELECT DISTINCT i.cdPers, i.cdSite, i.numEv, i.DateInscr AS "DateResa", i.NbPlResa, i.ModeReglt
FROM TESTSAELD.INSCRIPTION i, PARTICIPANT p, SITE s, EVENEMENT e
WHERE i.cdPers = p.cdPers AND i.cdSite = s.cdSite AND i.numEv = e.numEv ;





