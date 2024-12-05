clear all
cd "C:\Users\paolo\OneDrive\Documenti\TUTTI DOCUMENTI\PROGRAMMI data\Elaborazione DATI\ISTAT\School and work\DATI_2015"
use istat_2015

/* VARIABILI DI INTERESSE
BASE:
	v0_5
		female
	coeff
		coefficiente di riporto all'universo
	cittad
	reg
		regione	
	v0_9 
		voto medie
Scuole superiori:
	eta_diplo																**
	scula_pubblica															*
	v0_3_mfr
		tipo diploma
	v0_8 
		voto diploma 
	v1_3 
		bocciatura
	v1_1 
		cambio scuola superiore nell'arco di studisuperiori
	v1_4a ... v1_4e
		anno di bocciatura													*
	v1_5
		debiti formativi
	v1_6
		recupero anni da privatista
	v2_1
		iscrizione corso professionale 										*
Università
	v3_3
		iscrizione università												***
	v3_7
		titolo universitario conseguito										***
	v3_8
		attualmente iscritto a università
	v3_9
		motivo interruzione università
	v3_12
		tipo di corso a cui è iscritto (L, LM, master)
	v3_13
		crediti acquisiti
	v3_17
		area disciplinare 
	v3_19
		frequentazione lezioni
	v3_23
		PASSIONE PER IL CORSO												**
	v3_24
		motivo iscrizione a corso di non interesse
	v3_25
		iscrizione a università nei prossimi 12 mesi
Lavoro
	v4_1
		lavoro o attività formativa retribuita (ALTRO=NON LAV)				***
	v4_2
		motivo non lavoro (ev. scorporare percorsi di studio)
	v4_4_mfr
		tipo di dipendente
	v4_5_mfr
		tipo di autonomo
	v4_20
		lavoro part-time (vedere donne)
			v4_20 (motivo)
	mesi_lav_int
		tempo da inizio del lavoro a intervista (mesi)
	mesi_dip_lav
		tempo da diploma a lavoro
	red_tot_mfr
		reddito mensile totale netto 										***

Genitori:
	v6_5
		padre titolo di studio												**
	v6_6
		padre condizione occupazionale
	v6_10
		madre titolo di studio												**
	v6_11
		madre condizione occupazionale										***
mesi_dip_int
	mesi da diploma a intervista											*
*/
**# Bookmark #1
*aggiustamenti
	keep cittad reg eta_diplo_mfr scuola_pubblica progr v0_5 v0_3_mfr v0_8 v0_9 v1_3 v1_1 v1_4* v1_5 v1_6 v2_1 v3_3 v3_7 v3_8 v3_9 v3_12 v3_13 v3_17 v3_19 v3_23 v3_24 v3_25 v4_1 v4_2 v4_4_mfr v4_5_mfr v4_20 v4_20 mesi_lav_int mesi_dip_lav red_tot_mfr v6_5 v6_6 v6_10 v6_11 mesi_dip_int coeff
	rename v0_5 	female
	rename v0_8 	voto_dipl
	rename v0_9 	voto_medie
	rename v1_3 	respingimento
	rename v0_3_mfr tipo_diploma
	rename v3_3 	iscr_univ
	rename v3_17 	area_disciplinare
	rename v3_19 	frequenta_lezioni
	rename v3_23 	passione_corso
	rename v3_24	motivo_iscr_non_interesse
	rename v3_13	crediti_acquisiti
	rename v3_7		laurea_ottenuta
	
	sort progr

*analisi dataset
	describe
	svyset [pw=coeff]
	codebook coeff
	labelbook
	label list
*analisi variabili
	*sesso
		des female
		label list v0_5_cl1
		recode female (1=0)
		recode female (2=1)
		label define female_lab 0 "Maschi" 1 "Femmine"
		label drop  v0_5_cl1
		label value female female_lab
		label list female_lab
		des female
		
	*età
		codebook eta_diplo_mfr
		inspect eta_diplo_mfr
			tab eta_diplo_mfr
			sum eta_diplo_mfr
				*~70% 19 anni, ~20% 20 anni, 3%≤19, 4%≥22
		codebook mesi_dip_int
		inspect mesi_dip_int
		des mesi_dip_int
		tab mesi_dip_int
		gen anni_dip_int= mesi_dip_int/12
		tab anni_dip_int
		gen eta_diplo_tot= 18 if eta_diplo_mfr==1
		replace eta_diplo_tot= 19 if eta_diplo_mfr==2
		replace eta_diplo_tot= 20 if eta_diplo_mfr==3
		replace eta_diplo_tot= 21 if eta_diplo_mfr==4
		replace eta_diplo_tot= 22 if eta_diplo_mfr==5
		gen eta_tot= eta_diplo_tot + anni_dip_int
		replace eta_tot= round(eta_tot,1)
		tab eta_tot
			*APPROSSIMATIVA SU ESTREMI
	*tipo diploma
		tab tipo_diploma, nolab
		codebook tipo_diploma
			*1 missing
		label list v0_3_mfr_cl3
		gen liceo= tipo_diploma==15 | tipo_diploma==16 | tipo_diploma==17 ///
					| tipo_diploma==18 | tipo_diploma==17 | tipo_diploma==19
		tab liceo
		sum liceo
		svy: mean liceo
		
		gen S_profess=  tipo_diploma==1 | tipo_diploma==2 | tipo_diploma==3 ///
				| tipo_diploma==4 | tipo_diploma==5
		gen S_tecnico=  tipo_diploma==6 | tipo_diploma==7 | tipo_diploma==8 ///
				| tipo_diploma==9 | tipo_diploma==10 | tipo_diploma==11 | tipo_diploma==12
		gen S_liceo_altri= tipo_diploma==13 | tipo_diploma==17 ///
				| tipo_diploma==18 | tipo_diploma==19
		gen S_liceo_SC=  tipo_diploma==15 | tipo_diploma==16
		gen S_liceo_scientifico= 	tipo_diploma==15 
		gen S_liceo_classico= 		tipo_diploma==16
		
		gen tipo_4diploma = 1 if tipo_diploma==1 | tipo_diploma==2 | tipo_diploma==3 ///
				| tipo_diploma==4 | tipo_diploma==5
			replace tipo_4diploma = 2 if tipo_diploma==6 | tipo_diploma==7 | tipo_diploma==8 ///
				| tipo_diploma==9 | tipo_diploma==10 | tipo_diploma==11 | tipo_diploma==12
			replace tipo_4diploma = 3 if tipo_diploma==13 | tipo_diploma==17 ///
				| tipo_diploma==18 | tipo_diploma==19 
			replace tipo_4diploma = 4 if tipo_diploma==15 | tipo_diploma==16
		tab tipo_diploma tipo_4diploma 
		
		gen scientificoVSclassico= 1 if tipo_diploma==15 
			replace scientificoVSclassico = 0 if tipo_diploma==16
		tab tipo_diploma scientificoVSclassico
		
		label list v0_3_mfr_cl3
		gen tipo_5diploma = tipo_4diploma
		replace tipo_5diploma= 5 if tipo_diploma==15
		label define tipo_5label 1 "profess." 2 "tecnici" 3 "altri licei" ///
			4 "classico" 5 "scientifico"
			label value tipo_5diploma  tipo_5label 
			tab tipo_diploma tipo_5diploma 
				
	*iscrizione università
		codebook iscr_univ
		tab iscr_univ
		tab iscr_univ,nolab
		des iscr_univ 
		label list v3_3_cl45
		recode iscr_univ (2=0)
		tab iscr_univ,nolab
		codebook iscr_univ
		
		label list v3_3_cl45 
		label drop v3_3_cl45 
		label define v3_3_cl45 1 "si"  0 "no" 
		label values iscr_univ v3_3_cl45
	*voto medie dicotomico
		codebook voto_medie
		tab voto_medie
		label list v0_9_cl8
		gen voto_2medie= voto_medie >3
		tab voto_2medie voto_medie
		label define medie_dic_lab 0 "Voto medie S_B_D" 1 "Voto medie O_E"
		label value voto_2medie medie_dic_lab 
		
	*voto superiori 
		tab voto_dipl
		gen voto_discr_dipl = 1 if voto_dipl<70
		replace voto_discr_dipl = 2 if voto_dipl >=70 & voto_dipl<80
		replace voto_discr_dipl = 3 if voto_dipl >=80 & voto_dipl<90
		replace voto_discr_dipl = 4 if voto_dipl >=90 & voto_dipl<100
		replace voto_discr_dipl = 5 if voto_dipl >=100 & voto_dipl<=101
		label define voti_discr_label 1 "60-69" 2 "70-79" 3 "80-89" 4 "90-99" 5 "100+"
		label values voto_discr_dipl voti_discr_label
		codebook voto_discr_dipl
			tab voto_dipl voto_discr_dipl
			tab voto_dipl voto_discr_dipl, col
		*voto superiori 3 categorie 
			gen voto_3_dipl = 1 if voto_dipl<70
			replace voto_3_dipl = 2 if voto_dipl >=70 & voto_dipl<85
			replace voto_3_dipl = 3 if voto_dipl >=85 & voto_dipl<=101
			codebook voto_3_dipl
			tab voto_dipl voto_3_dipl, miss
			
			
			tab voto_3_dipl tipo_4diploma
			
			label define voti_3_label 1 "Voto dip. 60-69" 2 "Voto dip. 70-84" 3 "Voto dip. 85-101"
			label values voto_3_dipl voti_3_label
			
	*respingimento
		tab respingimento
		tab respingimento,nolab
		recode respingimento (2=0)
		label drop v1_3_cl11 
		label define  v1_3_cl11 1   "si" 0   "no" 
		label values respingimento v1_3_cl11
		*respingimento no, si primi tre anni, si ultimi tre anni
			tab respingimento v1_4d
			tab respingimento v1_4e
			tab v1_4d v1_4e, nolab
			gen resping_diviso = respingimento 
				replace resping_diviso= 2 if v1_4d==1
				replace resping_diviso= 2 if v1_4d==1
			label define  respingimento3label 0 "no resping." ///
				1 "resp. primi 3 anni" 2 "resp. ultimi 2 anni"
			label values resping_diviso respingimento3label
			
	*ambito univesità
		codebook area_disciplinare
		tab area_disciplinare
		des area_disciplinare
		label list v3_17_cl54
		gen stem= area_disciplinare==1 | area_disciplinare==2 | area_disciplinare==3 ///
				| area_disciplinare==4 | area_disciplinare==5 | area_disciplinare==6 ///
				 | area_disciplinare==7 | area_disciplinare==8 if area_disciplinare!=.
		codebook stem
		tab area_disciplinare stem 
		
		*STEM NO AGRARIA, ARCHITETTURA, ECONOMICO-STATISTICO
		gen stem1= area_disciplinare==1 | area_disciplinare==2 | area_disciplinare==3 ///
				| area_disciplinare==4 | area_disciplinare==5 if area_disciplinare!=.
		*STEM NO ECONOMICO-STATISTICO
		gen stem2= area_disciplinare==1 | area_disciplinare==2 | area_disciplinare==3 ///
				| area_disciplinare==4 | area_disciplinare==5 | area_disciplinare==6 ///
				 | area_disciplinare==7 if area_disciplinare!=.
		*STEM NO AGRARIA, ARCHITETTURA, ECONOMICO-STATISTICO, NO MEDICINA
		gen stem3= area_disciplinare==1 | area_disciplinare==2 | area_disciplinare==3 ///
				| area_disciplinare==4 | area_disciplinare==5 |area_disciplinare==4 ///
				if area_disciplinare!=.
	
	*crediti
		tab crediti_acquisiti
		codebook crediti_acquisiti
		pctile crediti_acquis_cat= crediti_acquisiti, nquantiles(5)
		tab crediti_acquis_cat
			*troppi missing 998 "non so non ricoro" (5000+)
	*SCELTA CORSO
		tab passione_corso
		tab motivo_iscr_non_interesse
		des motivo_iscr_non_interesse
		label list v3_24_cl70
		gen motivo_noniscr_lavoro= motivo_iscr_non_interesse==3
		
		tab passione_corso female, col
		svy: tab passione_corso female, col
		tab motivo_noniscr_lavoro female, col
		svy: tab motivo_noniscr_lavoro female, col
		
		tab passione_corso motivo_iscr_non_interesse
		
	*regioni
		codebook reg
			inspect reg
			tab reg 
			label list  reg_cl144
		gen NORD_sud= reg==1 | reg==2| reg==3| reg==4| reg==5| reg==6| reg==7| reg==8
			tab reg NORD_sud 
			des NORD_sud
			label define nord_sud 0 "SUD" 1 "NORD"
			label value NORD_sud nord_sud
		gen aree_regionali = 1 if reg==13| reg== 14 | reg== 15 |reg== 16 |reg== 17 | reg== 18
			replace aree_regionali = 2 if  reg==19 | reg==20
			replace aree_regionali = 3 if reg==9 | reg==10| reg==11| reg==12
			replace aree_regionali = 4 if reg==1 | reg==2| reg==3| reg==7
			replace aree_regionali = 5 if  reg==4 | reg==5 | reg==6 |  reg==8
			tab reg aree_regionali, miss
			codebook aree_regionali
			label define aree_reg_label 1 "Sud" 2 "Isole" 3 "Centro" 4 "Nord-ovest" 5 "Nord-est"
			label value aree_regionali aree_reg_label 
			label list aree_reg_label 
			tab reg aree_regionali, miss
	*reddito mensile 
		codebook red_tot_mfr
			*dati insufficienti
		sum red_tot_mfr
		inspect red_tot_mfr		
	
	*genitori 
		*padre titolo di studio
			tab v6_5
			des v6_5
			label list  v6_5_cl150
			gen padre_laureato=  v6_5==5
		*padre condizione occupazionale
			tab v6_6
		*madre titolo di studio
			tab v6_10
			des v6_10
			label list v6_10_cl155
			gen madre_laureata= v6_10==5
			tab v6_10 madre_laureata
		*madre condizione occupazionale	
			tab v6_11
			des v6_11
			label list v6_11_cl156
			gen madre_casalinga= v6_11==3
			tab v6_11 madre_casalinga
		*VARIABILI MISTE
			*occupazione entrambi
				tab v6_6 v6_11
				des v6_6 
				label list v6_6_cl151
				gen padre_lavoro= v6_6==1
				gen madre_lavoro= v6_11==1
				gen genitori_lavoro=padre_lavoro+ 2*madre_lavoro
				tab madre_lavoro genitori_lavoro
				tab genitori_lavoro
				label define gen_lav_label 0 "No occ. genitori " 1 "padre occupato" ///
				2 "madre occupata" 3 "entrambi occupati"
				label value genitori_lavoro gen_lav_label 
			*madre laureata e casalinga
				svy: tab madre_casalinga madre_laureata
				gen madre_laur_cas= 1 if madre_casalinga==1 & madre_laureata==1
					replace madre_laur_cas= 0 if madre_laur_cas!= 1
				tab madre_laur_cas
			
			*genitori laureati 3 ways (0,1,2)
				gen genitori_laureati= madre_laureata+padre_laureato
				tab genitori_laureati madre_laureata
				tab genitori_laureati padre_laureato
				label define gen_laur_lab 0 "No gen. laureato" 1 "1 gen. laureato" ///
					2 "2 gen. laureati"
				label value genitori_laureati gen_laur_lab
				
save "r_school",replace
——Break——
**# Bookmark #2 ################################################################

*test distributions
	/* hist voto_dipl 
	gen voto_weight=voto_dipl*coeff
	codebook coeff
	tab coeff
	inspect coeff
	hist voto_dipl, by(voto_weight)
	
	bysort voto_dipl: gen voto_weightSUM= sum(voto_weight)
	hist voto_weightSUM, by(voto_dipl)
	scatter voto_weightSUM voto_dipl 
	
	
	hist voto_dipl [weight=coeff]
	line */

/TEST INIZIALI			
	*voto diploma ~ voto medie 
		reg voto_dipl i.female voto_medie, robust
		reg voto_dipl i.female voto_medie
		reg voto_dipl i.female i.voto_medie
			*differenza varianza
		rvfplot, yline(0)
			hettest
		predict res, residuals
		kdensity res, normal
		swilk res
	
			
	*tipo di diploma ~ voto esame medie + sesso; respingimento e media
		*logit
			help logit
			logit S_profess i.voto_medie 
			logistic S_profess i.voto_medie
			logit S_liceo_SC i.voto_medie
			logistic S_liceo_SC i.voto_medie 
			logit S_liceo_SC i.voto_medie i.female
			logistic S_liceo_SC i.voto_medie i.female 
		*probit
			probit S_liceo_SC i.voto_medie
			probit S_liceo_SC i.voto_medie i.female
			margins, dydx (*)
				*continue: c.ang
				*discrete: intercetta
			test voto_medie
			lab
			svy: probit S_liceo_SC i.voto_medie i.female
			margins, dydx (*)
				*non cambiano coefficienti, cambia SD 
*/
		
*iscrizione università (maybe conclusione università?)
	*probit
		probit iscr_univ voto_dipl i.female i.voto_medie i.respingimento
		margins, dydx (*)
		probit iscr_univ voto_dipl i.female i.voto_2medie i.resping_diviso
		margins, dydx (*)
			*continue: c.ang
			*discrete: intercetta
		margins, atmeans
		help marginsplot 
		marginsplot
		margins voto_medie, atmeans
		marginsplot
		test 
	
	*voto diploma CONTINUO, grafico voto_medie
		svy: probit iscr_univ voto_dipl i.female i.voto_medie i.resping_diviso
		margins, dydx (*)
		margins voto_medie, atmeans
		marginsplot
	
	*voto diploma discreto (ma no categorie)
		svy: probit iscr_univ i.voto_dipl i.female i.voto_medie i.resping_diviso
		margins, dydx (*)
		margins voto_dipl, atmeans
		marginsplot
	
	*voto diploma discreto: CATEGORIE (diploma in 3, medie in 2)
		svy: probit iscr_univ i.voto_3_dipl i.female i.voto_2medie i.resping_diviso
		margins, dydx (*)
		margins voto_3_dipl , atmeans
		marginsplot

	
	*MADRE CASALINGA E LAUREATA
		svy: probit iscr_univ i.female i.voto_3_dipl i.voto_2medie ///
			i.resping_diviso i.madre_laur_cas
		margins, dydx (*)
		tab madre_laur_cas voto_discr_dipl
		
	*genitori laureati
		svy: probit iscr_univ i.voto_3_dipl i.female i.voto_2medie ///
			i.resping_diviso i.genitori_laureati
			margins, dydx (*) 
	*test iscrizione università
		local a=1
		local max=5
		while `a'<=`max'{
			quietly probit iscr_univ i.female i.voto_2medie ib2.voto_3_dipl i.resping_diviso ///
				i.genitori_laureati ib1.genitori_lavoro ib3.aree_regionali ///
				[pw=coeff] if tipo_5diploma==[`a']
				quietly margins, dydx (*)
				eststo school`a'
				quietly estat ic
				matrix p`a' = r(S)
				local a=`a'+1
		}
		matrix p= p1 \ p2 \ p3 \ p4 \ p5
		esttab, scalars("ll Log lik." "chi2 Chi-squared") label ///
		mtitles(professionale tecnico altri_licei classico scientifico) ///
			title(Confornto scuole superiori) b(%9.3g) not lines 
		matlist p, format(%9.1g)
			eststo drop *
			matrix drop p p1 p2 p3 p4 p5
			
		*play before modify:
			probit iscr_univ i.female i.voto_2medie ib2.voto_3_dipl i.resping_diviso ///
				i.genitori_laureati ib1.genitori_lavoro ib3.aree_regionali ///
				[pw=coeff] if tipo_5diploma==2
			margins, dydx (*)
			estat ic
			
			fitstat
			estat summarize
			estat vce
			help estat
*stem not stem
	
	*voto medie 4 categorie, voto diploma CONTINUO, respingimento dicotomico
	probit stem i.female i.voto_medie voto_dipl i.respingimento
	margins,dydx (*)
	
	*voto medie dicotomico, voto diploma discreto 5 categorie, resp.dicot.
	svy: probit stem i.female i.voto_2medie i.voto_discr_dipl i.respingimento
	margins,dydx (*)
	
	*********************
		*voto medie dicot., Voto dipl. 3 livelli (cateogoria centrale base), 
			*resping diviso primi 3 e ulitmi 2 anni
		probit stem3 i.female i.voto_2medie ib2.voto_3_dipl i.resping_diviso [pw=coeff]
		margins,dydx (*)
			eststo
							***!!!***
		margins voto_3_dipl, atmeans
			tab voto_3_dipl stem3 if iscr_univ==1, row
			*informazioni simili a tab ma corrette
		marginsplot
			*scegliere variabili da rappresentare per renderlo più pulito
		*TEST
			test 1.voto_3_dipl 3.voto_3_dipl
			test 3.voto_3_dipl
			test 1.voto_3_dipl
			
			test 1.voto_2medie
			
			test 1.female
			test 0.female=1.female
			
			tab resping_diviso,nolab
			test 1.resping_diviso 2.resping_diviso
				*LA BOCCIATURA ANDREBBE LEVATA DA QUESTO MODELLO 
				
	*TEST CON ESTAB E MATRIX AIC
		/* 5 TIPI DIPLOMI + TUTTI I DIPLOMI */ {
				quietly probit stem3 i.female i.voto_2medie ib2.voto_3_dipl i.resping_diviso ///
				i.genitori_laureati i.passione_corso i.reg[pw=coeff]
				quietly margins, dydx (*)
				eststo Generale,
				quietly estat ic
				matrix s0 = r(S)
			local a=1
			local max=5
			while `a'<=`max'{
				quietly probit stem3 i.female i.voto_2medie ib2.voto_3_dipl i.resping_diviso ///
				i.genitori_laureati i.passione_corso i.reg[pw=coeff] if tipo_5diploma==[`a']
					quietly margins, dydx (*)
					eststo school`a'
					quietly estat ic
					matrix s`a' = r(S)
					local a=`a'+1
			}
			matrix s= s0\ s1 \ s2 \ s3 \ s4 \ s5
			esttab, scalars("ll Log lik." "chi2 Chi-squared") label ///
			mtitles(tutte professionale tecnico altri_licei classico scientifico) ///
				title(Confornto scuole superiori) b(%9.3g) not lines 
				/*
				esttab, scalars("ll Log lik." "chi2 Chi-squared") label mtitles	///
				title(Confornto scuole superiori) mtitles(tutte professionale ///
				tecnico altri_licei classico scientifico) b(%9.3g)  se(%9.1g) not lines
				*/
			matlist s, format(%9.1g)
			eststo drop *
			matrix drop s s0 s1 s2 s3 s4 s5
			}	
		
	
	**# TEST stem3 5 DIPLOMI IN PROGRSS 
			local a=1
			local max=5
			while `a'<=`max'{
				quietly probit stem3 i.female i.voto_2medie ib2.voto_3_dipl i.resping_diviso ///
					i.genitori_laureati i.passione_corso ib2.genitori_lavoro i.aree_regionali ///
					[pw=coeff] if tipo_5diploma==[`a']
					quietly margins, dydx (*)
					eststo school`a'
					quietly estat ic
					matrix p`a' = r(S)
					local a=`a'+1
			}
			matrix p= p1 \ p2 \ p3 \ p4 \ p5
			esttab, scalars("ll Log lik." "chi2 Chi-squared") label ///
			mtitles(professionale tecnico altri_licei classico scientifico) ///
				title(Confornto scuole superiori) b(%9.3g) not lines 
				/*
				esttab, scalars("ll Log lik." "chi2 Chi-squared") label mtitles	///
				title(Confornto scuole superiori) mtitles(professionale ///
				tecnico altri_licei classico scientifico) b(%9.3g)  se(%9.1g) not lines
				*/
			matlist p, format(%9.1g)
			eststo drop *
			matrix drop p p1 p2 p3 p4 p5
	*********************
	
	
	
	*TIPO DIPLOMA, PROBLEMA RANK
		svy: tab stem tipo_4diploma, row
		svy: tab stem3 tipo_4diploma, row
		svy: tab stem scientificoVSclassico, row
		svy: tab stem3 scientificoVSclassico, row
		
		svy:probit stem3 i.female i.voto_2medie ib2.voto_3_dipl ///
			i.resping_diviso ib5.tipo_5diploma 
		margins,dydx (*)
			*BUT CATEGORIA BASE PROFESSIONALE
		
	*APPROFONDITO PER TIPO DI DIPLOMA CLASSICO E SCIENTIFICO
		*scientifico VS CLASSICO 
			tab scientificoVSclassico tipo_5diploma
				*BASE CLASSICO, MODIFICA SCIENTIFICO
			svy:probit stem3 i.female i.voto_2medie ib2.voto_3_dipl i.resping_diviso ///
						i.scientificoVSclassico
			margins,dydx (*)
		*solo scientifico
			svy:probit stem3 i.female i.voto_2medie ib2.voto_3_dipl i.resping_diviso ///
					if S_liceo_scientifico==1
			margins,dydx (*)
				table iscr_univ stem3 S_liceo_scientifico, notot 
				svy: tab stem3 S_liceo_scientifico, col 
				svy: tab stem3
				svy: tab area_disciplinare S_liceo_scientifico, col
				tab area_disciplinare
				
		*solo classico
			probit stem3 i.female i.voto_2medie ib2.voto_3_dipl i.resping_diviso ///
					[pw=coeff] if S_liceo_classico==1
			margins,dydx (*)
				table iscr_univ stem3 S_liceo_classico, notot 
				tab stem3 S_liceo_classico, col
				svy: tab area_disciplinare S_liceo_classico, col
				help table
		*solo ALTRI LICEI
			svy:probit stem3 i.female i.voto_2medie ib2.voto_3_dipl i.resping_diviso ///
					if S_liceo_altri==1
					margins,dydx (*)
					svy: tab area_disciplinare S_liceo_altri, col
					svy: tab tipo_5diploma
					svy: tab tipo_diploma
					svy: tab tipo_5diploma if iscr_univ==1
					svy: tab tipo_diploma if iscr_univ==1
					des
			
				table iscr_univ stem3 S_liceo_altri, notot			
		*SOLO TECNICI
			svy:probit stem i.female i.voto_2medie ib2.voto_3_dipl i.resping_diviso ///
					if S_tecnico==1
			margins,dydx (*)
				table iscr_univ stem3 S_tecnico, notot
				svy: tab area_disciplinare S_tecnico, col
				tab S_tecnico iscr_univ
				tab S_tecnico stem3
		*SOLO PROFESSIONALI
			svy:probit stem3 i.female i.voto_2medie ib2.voto_3_dipl i.resping_diviso ///
					if S_profess==1
			margins,dydx (*)
				tab S_profess iscr_univ
				table iscr_univ stem3 S_profess, notot
				svy: tab area_disciplinare S_profess, col
	*TIPI DI DIPLOMA VS TUTTO IL RESTO 
		*scientifico		VS altro
			svy:probit stem3 i.female i.voto_2medie ib2.voto_3_dipl i.resping_diviso ///
					i.S_liceo_scientifico
			margins,dydx (*)
		*classico			VS altro
			svy:probit stem3 i.female i.voto_2medie ib2.voto_3_dipl i.resping_diviso ///
					i.S_liceo_classico
			margins,dydx (*)
	
		*ALTRI LICEI		VS altro
			svy:probit stem3 i.female i.voto_2medie ib2.voto_3_dipl i.resping_diviso ///
					i.S_liceo_altri
			margins,dydx (*)
	
		*SOLO TECNICI		VS altro
			svy:probit stem3 i.female i.voto_2medie ib2.voto_3_dipl i.resping_diviso ///
					i.S_tecnico
			margins,dydx (*)
		
		*SOLO PROFESSIONALI	VS altro
			svy:probit stem3 i.female i.voto_2medie ib2.voto_3_dipl i.resping_diviso ///
					i.S_profess
			margins,dydx (*)
	
	*per regioni 
			svy:probit stem3 i.female i.voto_2medie ib2.voto_3_dipl i.resping_diviso ///
				i.NORD_sud
				margins,dydx (*) 
					*non rilevante
		*NORD E SUD ISOLATI: 
			*cambia rilevanza di alcune variabili
				*SOLO NORD
					svy:probit stem3 i.female i.voto_2medie ib2.voto_3_dipl ///
						i.resping_diviso if NORD_sud==1
						margins,dydx (*)
				*SOLO SUD
					svy:probit stem3 i.female i.voto_2medie ib2.voto_3_dipl ///
						i.resping_diviso if NORD_sud==0
						margins,dydx (*) 
				*BASE NEUTRA PER CONFRONTO
					svy:probit stem3 i.female i.voto_2medie ib2.voto_3_dipl ///
						i.resping_diviso
						margins,dydx (*) 

	*genitori
		*genitori laureati influenza su licei scintifico e altri licei 
				*(TUTTI GLI ALTRI SONO IRRILEVANTI)
			svy:probit stem3 i.female i.voto_2medie ib2.voto_3_dipl i.resping_diviso ///
						i.genitori_laureati if S_liceo_scientifico==1
			margins,dydx (*)
		
			svy:probit stem3 i.female i.voto_2medie ib2.voto_3_dipl i.resping_diviso ///
						i.genitori_laureati if S_liceo_altri==1
			margins,dydx (*)
		
		*tutte superiori insieme	(GENITORI LAUREATI NON RILEVANTI)
			svy:probit stem1 i.female i.voto_2medie ib2.voto_3_dipl i.resping_diviso ///
						i.genitori_laureati 
				margins,dydx (*)
		
	
*STEM E LAUREA OTTENUTA (NON ISCRIZIONE)
	tab laurea_ottenuta iscr_univ
	tab laurea_ottenuta
	tab laurea_ottenuta, nolab
	des laurea_ottenuta
	label list v3_7_cl49
			
	svy:probit stem3 i.female i.voto_2medie iB2.voto_3_dipl i.resping_diviso ///
		i.genitori_laureati if S_liceo_scientifico==1 & laurea_ottenuta==1
	margins,dydx (*)
		*Pretty much tutto irrilevante
	

		