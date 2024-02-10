/* Compilation des cours de SAS - Licence et Master MASS - Univ Caen */


/**************/
/*            */
/*   DEBUT    */
/* Licence L3 */
/*            */
/**************/

/*      */
/* TP 1 */
/*      */

Libname TP 'C:\Documents and Settings\e21numetu\Mes documents\SAS\TP'; 
/* Indique l'endroit ou sauver les données */

/* Création d'une table = dataset */
DATA TP.donnees; /* Nom du jeu de données */
INPUT Nom$ taille salaire reponse$ date DDMMYY10.; /* Précise les colonnes et les formats */
CARDS;
Bob 187 32000 non 13/08/1967
Bill 182 18000 oui 22/09/1992
Eva 167 35000 oui 05/01/1983
Ines 156 21500 non 03/12/1976
Lea 162 41500 oui 04/07/1959
Leo 177 20000 oui 17/06/1987
Lina 175 24000 non 31/01/1990
Tom 192 29000 non 09/11/1982
Theo 172 14500 oui 14/03/1974
Sarah 160 36000 oui 28/12/1987
Yann 179 28000 non 25/02/1971
Zoe 168 34500 oui 11/03/1984
;
Run;

Data  oubli;
Input nom$ taille salaire reponse$ date DDMMYY10.;
Cards;
Jean 174 28500 non 25/09/1981
;
Run;

PROC PRINT data=TP.donnees ;
format date DDMMYY10.;
Run;

data TP.donnees2;
set TP.donnees oubli;
format date DDMMYY10.;
run;

data TP.tpoids;
input nom$ poids;
Cards;
Bob 82
Bill 97
Eva 53
Ines 49
Jean 65
Lea 49
Leo 76
Lina 84
Tom 90
Theo 63
Sarah 53
Yann 89
Zoe 65
;
run;

/* Trier les données */
proc sort data=TP.donnees2;
by nom;
run;

proc sort data=TP.tpoids;
by nom;
run;

/* Fusionner les 2 jeux de données = merge */
data TP.donnesfus;
merge TP.donnees2 TP.tpoids;
run; /* fusionne sur le coté */

/* Fusionner les 2 jeux de données l'un en dessous de l'autre */
data TP.table;
set TP.donnesfus;
run; /*fusionne en dessous */

data TP.Table2;
set TP.Table;
IMC=(10000*(poids))/(taille)**2;
run; /* introduire une nouvelle variable */

/* introduire une nouvelle variable avec condition if else */
data TP.Table;
set TP.Table2;
If reponse="oui" then pro_num=1; 
Else pro_num=0;
run;

/* Calcul des moyennes */
Proc means data=TP.table;
run;

data sexe;
Input Nom$ Sexe$;
cards;
Bill M
Bob M
Eva F
ines F
Jean M
Lea F
Leo M
Lina F
Sarah F
Theo M 
Tom M
Yann M
Zoe F
;
run;

data TP.table;
merge TP.table sexe;
run;

proc sort data=TP.table;
by sexe; 
run;

/* Calcul des moyennes par groupes */
Proc means data=TP.table;
var salaire;
by sexe;
run;

/* Calcul des correlations */
proc corr data=TP.table;
var taille poids;
run;


/*            */
/* Licence L3 */
/*            */

/*      */
/* TP 2 */
/*      */

Libname TP2 'C:\Documents and Settings\e21numetu\Bureau\TP';

/* Lecture d'un fichier */
DATA TP2.Notes;
infile 'C:\Documents and Settings\e21numetu\Bureau\TP\notes.don';
input ident algb stat eco info angl;
run; 

/* Trier par */
proc sort data=TP2.Oubli;
by ident;
run;

/* 2) renommer une variable avec rename */
data TP2.Notes;
merge TP2.Notes TP2.Oubli;
rename aajouter=comm;
run;

/* 3) proc univariate avec l'option cibasic */
/* cibasic = pour donner un intervalle de confiance à 95% pour la moyenne d'info */
proc univariate data=TP2.Notes cibasic;
var info;
run;  /* Intervalle de confiance pour la moyenne à 95% = [43.53642  49.82722] par défaut  ...  A 90%, l'intervalle sera plus étroit*/

proc univariate data=TP2.Notes cibasic(alpha=.1);
var info;
run; /* Intervalle de confiance pour la moyenne à 90% = [44.05081 49.31282] */

/* 4) */
/* la valeur du quantile utilisée pour calculer l'intervalle de confiance à 95% est 1.66 */
/* le quantile q=1.66 verifie l'IC = [x +/- q* sqrt(var/n)}]  */

/* 5) Creation de la var Moy */
data TP2.Notes;
set TP2.Notes;
Moy=(2*algb+2*stat+2*eco+2*info+2*angl+comm)/11;
run;

/* Proc univariate fait la moyenne d'une variable */
Proc univariate data=TP2.Notes;
var Moy;
run; /* La moyenne du groupe est 46.3884298 */

/* 6) */
/* Il s'agit des élèves à l'idenifiant 1, 2 et 3, resp de moyenne 76.81, 76.27, 74.63

/* 7) */
data TP2.Notes;
set TP2.Notes;
diff=(Moy - info);
run;

/* Proc univariate de diff pour avoir sa moyenne. Si proche de 0 alors même esperance */
Proc univariate data=TP2.Notes ;
var diff;
run; 
/* On regarde la p-value donnée ds le tableau des tests de tendance 
Si p-value (= Pr >|t|) > alpha alors on accepte. Ici p-value = 0.75 > alpha =0.05
Donc on ne rejette pas Ho et on peut dire que la moyenne en Info et la même que la moyenne générale
/!\ Si test pas bilatéral on divise la p-value par deux et on compare à alpha. */

/* 8) option all : génère toutes les statistiques */
proc univariate data = TP2.Notes all;
run;

/* 9) covariance entre la note d'info et la moyenne générale */
proc corr data=TP2.Notes cov; /* Option cov donne la covariance, sinon on a le coeff de correlation */
var info Moy;
run; /* covariance = 142.4844685 */

/* 10) */
proc means data=TP2.Notes;
var info;
run; /* Moyenne des infos : 46.6818182 */
/* La moyenne du groupe est 46.3884298 (cf questions plus haut) */

data TP2.Notes;
set TP2.Notes;
cov = (88/87)*(info - 46.6818182)*(Moy - 46.3884298);
run;
/* on multiplie par n/(n-1) car SAS calcule la covariance en divisant par (n-1) */

proc means data=TP2.Notes;
var cov;
run;
/* On fait la moyenne de la var "cov", donc on divise par n, d'où le (n/(n-1)) utilisé
avant pour avoir la même valeur calculée par SAS */
/* On obtient covariance = 142.4844685 */

/* 10) - b une instruction output pour créer dans work  */
proc univariate data=TP2.Notes;
var cov;
OUTPUT OUT=Sortie mean=Varemp n=nombre;
run;

/* 10) - c */
/* Pas besoin de créer une nouvelle variable car on a déjà modofié "l'erreur" pour retrouver
la même formule que le calcul de la cov de SAS dans la question 10-a*/


/*            */
/* Licence L3 */
/*            */

/*      */
/* TP 3 */
/*      */

Libname TP 'C:\Documents and Settings\e21numetu\Bureau\TP3';

/* 2) */
proc sort data=TP.donnees1;
by individu;
run;

proc sort data=TP.donnees2;
by individu;
run;

DATA TP.base;
merge TP.donnees1 TP.donnees2;
run;

/* 3) */
proc univariate data=TP.base;
run;

proc univariate data=TP.base;
var individu sexe secteur niveau age taux inactivite salaire;
output out=sortie1 mean=moysalaire moyage moysecteur;
run; 
/* La table "sortie1" est crée dans le dossier "work" */
/* Mais SAS prend les 3 premieres variables donc on doit faire attention à l'ordre */

/* 4) */
proc univariate data=TP.base;
var salaire age secteur individu sexe  niveau taux inactivite ;
output out=sortie1 mean=moysalaire moyage moysecteur;
run; 

proc univariate data=TP.base;
var salaire age secteur individu sexe  niveau  taux inactivite ;
output out=sortie2 mean=moysalaire moyage moysecteur var=varsalaire varage varsecteur;
run; 

/* 5) */
proc means data=TP.base;
var salaire age secteur individu sexe  niveau  taux inactivite ;
output out =sortie3;
run;
/* Présentation plus claire et synthetique sous la forme d'un tableau dans l'ordre des variables */

/* 6) */
/* Penser à fair une proc sort pour utiliser une proc means spécialisé pour une variable (var... by...) */
proc sort data=TP.base;
by sexe;
run;
proc means data=TP.base;
var salaire age secteur individu niveau taux inactivite ;
by sexe;
run;

/* On remarque que les hommes travaillent plus dans le secteur 5 et les femmes dans le secteur 2 */

/* 7) */
/* Formule ecart type : sqrt((1/n-1)*(sum(xi-xmoy)²)) */
/* On doit développer cette formule pour la simplifier et utiliser les moy données par SAS */
/* On trouve alors la formule : sqrt((1/(n-1))*(n*xmoy*(1-xmoy))) */
/* On retrouve le même ecart type que SAS */

/* 8) */
/* Comparaison de deux moyennes observées : Cf test usuel
On a statistique de student = Z = (xmoy - ymoy)/(sqrt(sigmchapeau²*(1/Na + 1/Nb)))
sigmchapeau= 488772.5
Z= 9.89 */

/* 9/ */
proc Ttest data=TP.base;
Class sexe;
run; 

/* On a p-value <0.001 alors qu'alpha =0.05 : On rejette Ho */

/* 10) 
On trie par les variables demandées 
Ensuite on calcule les moyennes des salaires et des ages
SAS va trier pour cahque variable d'abord le sexe puis le secteur ... */
proc sort data= TP.base;
by sexe secteur taux inactivite;
run;

proc means data=TP.base;
var salaire age;
by sexe secteur taux inactivite;
run;

/* 11) Filter des lignes */
DATA TP.table;
merge TP.base;
if secteur > 0 then delete;
if taux < 100 then delete;
if inactivite >0 then delete;
run;
/* On a pris dans la table que les individus qui ont secteur=0, taux=100 et inacvtitie=0
On lui dit donc de "delete"=supprimer les individus qui ne remplissent pas la condition */

proc means data=TP.table;
by sexe;
run;

/* 12) */
proc corr data=TP.table;
var age salaire;
run;

proc corr data=TP.table;
var age salaire;
by sexe;
run;

/* 13) Test de student pour égalité de 2 moyennes 
On compare pour la variable salaire entre les H et F (class sexe)*/
proc Ttest data=TP.table;
var salaire;
Class sexe;
run; 

/* On accepte l'égalité des salaires */

proc Ttest data=TP.table;
var age;
Class sexe;
run; 

/* On accepte l'égalité des ages */

/* 14) */
proc plot data=TP.table;
by sexe;
plot salaire*age;
run;

proc gplot data=TP.table; /* gplot moins moche que plot */
by sexe;
plot salaire*age;
run;

/* 15) */
proc reg data=TP.table;
model salaire=age;
output r=residu p=prediction ;
run;
/* On a une p_value < 0.001 */

/* 16) */
proc Ttest data=TP.table;
var residu; /* les salaires ne sont plus calculé en fonction des ages */
Class sexe;
run; 

/* 17) */
/* Régression pour chaque groupe : by = ... */
proc reg data=TP.table;
by sexe;
model salaire=age;
output r=residu p=prediction ;
run;

proc Ttest data=TP.table;
var residu;
Class sexe;
run; 


/*            */
/* Licence L3 */
/*            */

/*      */
/* TP 4 */
/*      */

Libname TP 'C:\Documents and Settings\e21numetu\Bureau\TP4';

/* 1) */
proc Ttest data=TP.discrim;
var emploi;
class sexe;
run;

/* On teste l'egalité du taux d'emploi chez les Hs et les F ,  
On regarde le dernier tableau, sa p-value va nous dire s'il faut regarder l'égalité ou l'inégalité du tableau prècèdent
Ici on rejette H0 (test d'égalité) car pvalue < 0.05 , il n'y a pas egalité des taux, donc il y a discrimination */

/* 2) proq freq avec l'instruction tables */
/* pour obtenir un tableau croisant les variables sexe et emploi */
/* et indiquant la fréquence de chaque couple de modalités */ 
proc freq data=TP.discrim ;
tables sexe*emploi ;
run;

/* dans le tableau frequence=effectif
sexe*emploi permet de croiser les données */

/* option pour réaliser un test du Chi-2 = tester l'hypothèse d'indépendance entre les variables */ 
proc freq data=TP.discrim  ;
tables sexe*emploi/chisq; 
run;

/* Prob = p_value. Ici < 0.05, donc on rejette l'hypothèse d'égalité */

/* 3) */
proc means data=TP.discrim;
var emploi ;
class sexe ;
by diplome ;
run ;

/* la moyenne (taux d'emploi) est superieur chez les femmes pour chaque type de diplome, mais 
elles sont plus nombreuses dans les diplomes qui embauchent le moins .
on pourrait donc conclure à une discrimination envers les hommes */

/* 4) */ 
proc freq data=TP.discrim  ;
tables sexe*diplome/chisq;
run;

/* p-value <0.01 , donc on rejette l'hyp d'independance, donc elles sont dépendantes  */

/* 5) */
proc Ttest data=TP.discrim;
var emploi;
class sexe;
by diplome;
run;

/* le dernier tableau nous dit de regarder le test d'egalité.
la p-value > 0.05 dans l'avant dernier tableau donc on accepte H0, et il y a discrimination 
a l'embauche */ 

/* nb : Penser à regarder les p_values de tous les diplômes ! */

/* 6) 
On doit sommer les différences de chaque moyenne divisé par la somme des erreurs
types mises au carré et apres leur racine carré 

Test global = (somme (moy Hs - moy F ) ) / sqrt(somme (variance(moy Hs - moy F )))

somme des différence des moy = 0.3411
somme des erreurs au carré = 0.01458

Test global ~ N(0,1) 
On a quantile de N(0,1) pour alpha =0.05 = 1.96
Test=2.82 et IC = [-1.96,1.96] 
Le test n'est pas ds l'IC donc on rejette Ho */

/* 7) */

proc gplot data=TP.multiv;
plot Y*x1;
run;

proc gplot data=TP.multiv;
plot Y*x2;
run;

proc gplot data=TP.multiv;
plot Y*X3;
run;

proc gplot data=TP.multiv;
plot Y*X4;
run;

/* autre methode */ 

proc gplot data=TP.multiv;
plot Y*x1 Y*x2 Y*X3 Y*X4;
run;

/* 8) */
proc reg data=TP.multiv;
model Y=x1 x2 X3 X4 ;
output out=sortie r=residu ;
run ;

proc reg data=TP.multiv ;
model Y=x1 x2 X3 X4/partial;
output out=sortie r=residu ;
run ;

/* x1 est celui qui suit le moins la droite de regression 
x2 x3 x4 lineaire */

/* 9) Représenter les résidus + droite horizontale coupant l'axe des ordonnés en 0 */  

proc gplot data=sortie; 
plot residu*x1 residu*x2 residu*X3 residu*X4/vref=0;
run;

/* 10) */ 

data TP.multiv2;
merge TP.multiv;
X5 = (exp(x1));
run;

proc reg data=TP.multiv2 ;
model Y=x2 X3 X4 X5;
output out=sortie2 r=residu ;
run ;

proc gplot data=sortie2; 
plot residu*X5 residu*x2 residu*X3 residu*X4/vref=0;
run;

*/ Une fois qu'on a pris la bonne variable( X) la R² est supérieur */


/*            */
/* Licence L3 */
/*            */

/*      */
/* TP 5 */
/*      */

Libname TP 'C:\Documents and Settings\e21numetu\Bureau\TP5';

/* Exercice 2) */
/* 1) */
/* Pour representer les deux fonctions sur le meme graphe */
/* Differentes options : 
	- title " ..." : mettre un titre au graph
	- symbol1 color=red
			  value=star
			  interpol=none ou interpol=join : lien qui va exister entre les differents points
*/

proc gplot data=TP.base_tp3_2;
plot lproduction*periode lcapital*periode /overlay; /*overlay : met les deux graph sur un seul */
symbol1 color=red value=star interpol=join; 
symbol2 color=blue value=star interpol=join;
run;

/* 2) */ 
/* il semblerai qu'il n'y ait pas de relation entre les deux variables */
proc gplot data=TP.base_tp3_2;
plot lproduction*lcapital;
symbol1 color=red value=star interpol=R1; /* interpol=R1 : trace la droite de regression */
run;
/* La pente de la droite de régresssion est positive => elasticité non nulle entre capital et production 
droite de regression : LP = Bo +B1*LC +u */

/* 3) */
/* On va ré-estimer le modèle en instaurant des variables muettes: 
LP =Bo +B1*LC +B2*T1 +B3*T2 + B4*T3 +B5*T4 +u */

DATA TP.modele;
merge TP.base_tp3_2;
if TRIM=1  then T1=1;
if TRIM^=1  then T1=0;
if TRIM=2  then T2=1;
if TRIM^=2  then T2=0;
if TRIM=3  then T3=1;
if TRIM^=3  then T3=0;
if TRIM=4  then T4=1;
else  T4=0;
run;


proc reg data=TP.modele;
model lproduction= lcapital T1 T2 T3 ;
run;

/* Sas renvoie un msge d'erreur "Note: Model is not full rank " en dessous du tableau :
cela signifie qu'il y a un pb de colinearité entre les T1 T2 et T3
On peut tjs connaître la valeur de T4 en conniassant T1 T2 et T3 d'où le pb de colinearité parfaite
On peut donc en retirer une. (Ici T4) */

/* 4) */
proc reg data=TP.modele;
model lproduction= lcapital T1 T2 T3 ;
output out=TP.sortie r=residu p=prediction;
run;
quit;

proc gplot data=TP.sortie;
plot lproduction*lcapital lproduction*prediction /overlay;
symbol1 color =red value=star interpol=R1;
symbol2 color =blue value=star interpol=R1;
run;

/* On vérifie l'existence de la rupture sur le graphique de la Q1 .
On fait un test de CHOW :
PROC REG DATA;
Model ___ = ____ / CHOW (période de rupture [ici 40]);
run;

SAS va estimer les deux modèles : - Un modèle contraint : LPi = Bo + B1*LTt +B2*T1 + B3*T2 +B4*T3 +ut (quelque soit t)
													      LPt = &0 + &1*LCt +&2T1+&3T2+&4T3+ut (quelque soit t :1-40)
							      - Un modèle non contraint : H0 : &0 = B0 &1 = B1 &2 = B2 &3 = B3 &4 = B4
														  H1 : &0 != B0 et/ou &1 != B1 et/ou &2 != B2 et/ou &3 != B3 et/ou &4 != B4
										F = ((SCRc - (SCR1+SCR2))/Q )/(SCR1+SCR2)/ddl 		Q=5   ddl=100-10=90

SAS calcule les deux modèles et le test. Si p-value <00.5 on rejette Ho sinn on ne rejette pas (Cela signifie que les para sont tous égaux
avt et apres la période 40)
*/

proc autoreg data=TP.modele;
model lproduction= lcapital T1 T2 T3/chow=(40);
run;

/* p-value <0.05 : On rejette Ho , donc les valeurs ne sont pas identiques avant et apres la période 40.
Il y a donc bien une rupture. */

/* Exercice 1 */

/* 1) 

Modèle ANOVA : Modèle avec juste des variables indicatrices (muettes).
On va simplement mettre la taille des entreprises dans lesquelles des salariées travaillent.
1) Estimer le modele avec que ses varibales muettes
2) Interpreter le sens de ses coefficients */

proc reg data=TP.Salaire;
model salaire = taille1 taille2 taille3;
run;

/* SAS donne le msge d'erreur "Note: Model is not full rank "
Il y a donc un pb de colinéarité entre les variables */

proc reg data=TP.Salaire;
model salaire = taille1 taille2 ;
run;

/* Les coefficients des tailles sont négatifs, mais plus la taille augmente et plus ce coefficient augmente
On peut en conclure que plus la taille de l'entreprise augmente et plus le salaire augmente
la var(taille1)=0 var(taille2)=0 esperance(y)=cste. Le salaire moyen ds les entreprises de taille3 est de 6.19euros 

On a salaire = Bo + B1taille1 + B2taille2 + u 
salaire = Bo + u si taille >250 --> salaire moyen = Bo
salaire = Bo + B2 + u si  100<taille<250 --> salaire moyen = Bo+B2 
salaire = Bo + B1 + u si  taille<100 --> salaire moyen = Bo+B1 

ANOVA = calculer automatiquement le salaire moyen ds différents gpe identifiés par des var discretes et muettes */

/* 2)  

on veut voir si on retrouve les mêmes ecarts en rajoutant de nouvelles varibales
ANCOVA : ttes choses egales par ailleurs, pour un age, une exp.... est ce que travailler ds un établissement de taille 1 est
sgnificatif par rapport au salaire ? (Salaire différent selon les tailles?)*/

proc reg data=TP.Salaire;
model salaire = lanc lage lexpe sexe taille1 taille2;
run;


/* 3) Selection de variable dans un modele de regression : */
/* Quelles variables va t-on retenir pour le modèle ?  Est ce pertinant de garder toutes les variables ?*/
/* Pour savoir quel modèle est le mieux on utilise soit le critére AIC soit le R² ajusté */

proc reg data=TP.Salaire;
model salaire = lanc lage lexpe sexe taille1 taille2/ selection= f; /* methode ascendante  sinon selection=b : methode descendante */
run;
quit;

proc reg data=TP.Salaire;
model lsalaire = lanc lage lexpe sexe taille1 taille2/ selection=f; /* methode ascendante  sinon selection=b : methode descendante */
run;
quit;


proc reg data=TP.Salaire outest=lsortie ; /* on met "outest" pour que AIC marche */;
model lsalaire = lanc lage lexpe sexe taille1 taille2 /AIC ADJRSQ;
/* Calcule du critére AIC  et "ADJRSQ" pour le R² ajusté */
run;
quit;

proc reg data=TP.Salaire outest=sortieAIC; /* on met "outest" pour que AIC marche */
model salaire = lanc lage lexpe sexe taille1 taille2/ AIC ADJRSQ;
run;
quit;
/* Il vaut mieux choisir le log du salaire car le R carré ajusté est superieur */

/* 4) Test de Chow */ 

/* Modele contraint : ln(W) = B0 +B1*lanc + B2*lexp + B3*lage+B4*taille1 + B5*taille2 + ui 
: Il n'y a aucun différence sur toutes les variables entre les H et les F

Modele nn contraint : On croise ttes les variables avec les Df (1 si F et 0 sinon)
*/ 

proc reg data=TP.salaire(where=(sexe=1)); /* Base avec uniquement les sexe =1 */
model lsalaire = lanc lage lexpe taille1 taille2 ;
run;
quit; /* ==> SCR1 = 254.41747 (Somme des carrés Erreur) */

/* /!\ penser à enlever la variable pour laquelle on étudie ! ici : sexe */

proc reg data=TP.salaire(where=(sexe=0)); /* Base avec uniquement les sexe =0 */
model lsalaire = lanc lage lexpe taille1 taille2;
run;
quit; /* ==> SCR2 = 5166.79304*/

proc reg data=TP.salaire; /* Base pour tous */
model lsalaire = lanc lage lexpe taille1 taille2;
run;
quit; /* ==> SCR = 723.57827 */

/* Fchow = ((SCR-(SCR1+SCR2))/6)/(SCR1+SCR2)/(2000-12)) = 124.42 */

/* Faire des calcul ds SAS */
DATA calcul;
F = ((723.57827-(254.41747+271.62481))/6)/((254.41747+271.62481)/(2000-12));
run;
proc print data=calcul;run;


/* ou */
proc reg data=TP.salaire noprint outest=sortieProf; /* noprint : n'affiche pas pour ne pas encombrer */
title'test de CHOW contraint';
model lsalaire= lage lexpe lanc taille1 taille2 /sse; /* "sse" calcul la somme des carrés des résidus */
run;
quit;

/* 5) 1ere méthode */

/* Pour trouver la rupture (qu'on mettra dans la parenthese du test chox) */
proc sort data=TP.salaire;
by sexe; 
run; /* On va voir à quel niveau se situe la rupture entre les H et les F */

proc autoreg data=TP.salaire;
model lsalaire= lage lexpe lanc taille1 taille2/chow=(1001);
run;

/* p-value <.0001 donc on rejette. On peut aussi le voir directement par la valeur de la statistique
du test (=124.42) qui est plus gde que 1.96 */

/* 2ème méthode */
/* On doit créer une nouvelle base où il y aura les variables croisées avec la variable sexe */

data TP.base; /* Modele contraint */
set TP.salaire;
lagef= lage*sexe; /* --> X*Df */
lexpef=lexpe*sexe;
lancf=lanc*sexe;
taille1f=taille1*sexe;
taille2f=taille2*sexe;
run;
quit;

proc reg data=TP.base; /* /!\ penser à remettre la variable "sexe" */
model lsalaire= lage lexpe lanc taille1 taille2 sexe lagef lexpef lancf taille1f taille2f/sse ;
test sexe =0, lagef=0, lexpef=0, lancf=0, taille1f=0, taille2f=0;
run;quit;

/* On retombe sur la même statistique que tout à l'heure */

/* 6) */
proc reg datat =TP.base;
model lsalaire= lage lexpe lanc taille1 taille2 sexe lagef lexpef lancf taille1f taille2f/sse ;
test lagef=0, lexpef=0, lancf=0, taille1f=0, taille2f=0;
run;quit;
/* On obtient une nouvelle valeur de test = 32.77. On rejette tjs Ho 
On voit que seul lexp est significative. <0.001 derniere colonne tableau
On refait un test en l'enlevant*/

proc reg datat =TP.base;
model lsalaire= lage lexpe lanc taille1 taille2 sexe lagef lexpef lancf taille1f taille2f/sse ;
test lagef=0, lancf=0, taille1f=0, taille2f=0;
run;quit;

/* On ne rejette plus Ho (p-value = 0.16)
Le rendement de l'age, l'ancienneté et le fait d'être ds une entreprise de taille 1 et 2 
n'entraîne pas de différence entre les H et les F */



/*            */
/* Licence L3 */
/*            */

/*      */
/* TP 6 */
/*      */

Libname TP 'C:\Documents and Settings\e21numetu\Bureau\TP6';

/* ex 1 */ 

/* 1) */ 

proc gplot data=TP.conso;
plot conso*periode;
symbol1 color =red value=star interpol=join; 
run;
/* On constate une consommation cyclique 
remarque : on ne parle d'autocorrelation que losque le modele est econometrique */

proc gplot data=TP.conso;
plot conso*revenu;
symbol1 color =blue value=star interpol=r1; /* interpol=r1 trace la droite de regression */
run; 

/* on pourrait tracer une droite, graphe lineaire 
droite proche de la premiere bisectrice donc il y a une forte correlation entre la conso et le revenu */

proc gplot data=TP.conso;
plot conso*periode revenu*periode /overlay;
symbol1 color =red value=star interpol=join; 
symbol2 color=blue value=star interpol=join;
run;

/* on a l'impression qu'elles sont fortement correlées car elles suivent le meme cycle */

/* 2) */

proc reg data=TP.conso;
model conso=revenu;
run;

/* H0 : la conso n'est pas lié au revenu cad tous les coef sont nuls
H1 : il y a des liens entre les variables explicatives cad au moins des coef est significatif
ici F-value = 547, tres grande donc on rejette H0, (p-value<0.0001 meme resultat) 

test de fisher  : teste si Ho : tous les coefficients du modele sont nuls
						   H1 : Au moins 1 est significativement différent de 0

R² = 0.94 : 94% la variance de la conso est expliquée par le modele

La statistique du test de student pour les variables est tjrs plus grande que 1.96 :
les variables sont significativement differentes de 0

0.44 : quand le revenu augmente d'une unité la conso augmente de 0.44 unité de consommation 

"erreur type": ecart type 
on trouve que a1 appartient [0.41,0.48]

*/

/* 3) */

proc reg data=TP.conso;
model conso=revenu;
output out=sortie r=residu p=prediction;
run;
proc gplot data=sortie; 
plot residu*prediction;
symbol1 color =red value=star interpol=none; 
run;

/* Le nuage de points semble "bizarre", donc on peut supposer soit une hétéroscédasticité soit une auto-corrélation */

proc gplot data=sortie; 
plot residu*periode;
symbol1 color =red value=star interpol=none; 
run;
quit;

/* Le nuage de points semble "bizarre", donc on peut supposer soit une hétéroscédasticité soit une auto-corrélation */

/* 4) test DW Durbin Watson */

proc reg data=tp.conso;
model conso=revenu /DW;
run;

/* bb=1.38 et bh=1.51
DW= 1.160 < bb 
il y a autocorrelation positive : on rejette H0 */

/* test White */

proc model data=tp.conso;
parm a0 a1;
conso=a0+a1*revenu ; 
fit conso / white ;
run ; 

/* W=0.77 < 5.99 (valeur tabel Khi deux) par ailleurs p-value =0.68 > 0.05 : on accepte H0 : homoscedasticité */

/* 5) On décide d'introduire une variable retardée dans le modèle pour tenter d'améliorer l'estimation */

/* conso t = a0 + a1 * Revenu + a2 * conso (t-1) + vt 
pensez a trier la base par rapport au temps
data=
set
consot1=lag(conso);
consot2=lag2(conso);
consot3=lag3(conso);
run ; 
Introduction de variable retardée */

data tp.conso2;
set tp.conso;
consot1=lag(conso);
run ; 

proc reg data=TP.conso2;
model conso=revenu consot1;
run;

/* cette strategie est concluante car la statistique du test est grande donc 
on rejette H0 : tous les coef sont egaux a 0.
d'ou on a au moins une variable significativement différente de 0 */

proc reg data=tp.conso2;
model conso=revenu consot1/DW;
run;

/* dw=1.299 < 1.31 = bb donc toujours autocorrelation positive */

proc autoreg data=tp.conso2;
model conso=revenu consot1/godfrey;
run;
/* AR(1)...AR(4) : autocorrelation d'ordre 1,...,4. Le 1er trimstre influence celui de l'année suivante 
et ainsi de suite */

/* 6) */
data tp.conso3;
set tp.conso;
consot1=lag(conso);
consot2=lag2(conso);
consot3=lag3(conso);
run ; 


proc reg data=TP.conso3;
model conso=revenu consot1 consot2 consot3;
run;

/* cette strategie est concluante car la statistique du test est grande donc 
on rejette H0 : tous les coef sont egaux a 0.
d'ou on a au moins une variable significativement différente de 0 */

proc reg data=tp.conso3;
model conso=revenu consot1 consot2 consot3/DW;
run;

/* 1.74 = bh < dw=1.782 < 4-1.74 = 4- bh = 2.26 donc abscence d'autocorrelation */

proc reg data=tp.conso3;
model conso=revenu consot1 consot2 consot3;
output out=sortie3 r=residu3 p=prediction3;
run;
proc univariate data=sortie3 normal;
var residu3 ;
run ;

/* toutes les p-values sont supérieures 0.05 donc on accepte l'hypothese de normalité */ 
/* s'il y a opposition entre les tests on regarde le plus puissant : Kolmogorov-smirnov */ 

/* ex 2 */ 

proc reg data=tp.salaire;
model lsalaire=lexpe lage lagelexpe;
output out=sortie4 r=residu4 p=prediction4;
run ; 
quit;

/* interpretation : 
lorsque l'experience augmente d' 1% le salaire augmente de 0.5% 
## on parle en pourcentage car c'est un modele log-log 
lorsque l'age augmente d' 1% le salire augmente de 0.8% 
l'experience influence la relation entre le salaire et l'age  
## on ne peut pas interpreter directement le chiffre car l'elasticité n'est pas constante */

/* chaque p-value du test de student des variables est <0.05 donc on rejette H0 : les variables sont = 0
donc ici les variables sont significativement differente de 0 */

/* 2) */

proc gplot data=sortie4 ;
plot residu4*lsalaire;
run;

/* on suspecte un autocorrelation ou hétéroscédasticité 
hétéroscedasticité : E(u²)=sigma²(i) */

proc model data=sortie4;
parm a0 a1;
lsalaire=a0+a1*lage+a2*lexpe +a3*lagelexpe ; 
fit lsalaire / white ;
run ; 
/* Grace au residu on a pu, par un gplot, trouver qu'il y avait un pb
On corrige donc le 1er modèle */

/* statistique du test très grande (> 7 ou 8 dans la table du X²) 
et p-value < 0.01  donc on rejette H0
-> il y a donc hétéroscédasticité */ 

/* on utilise la correction de White : */

proc reg data=tp.salaire;
model lsalaire=lage lexpe lagelexpe /acov;
run;
quit;

/* La correction nous donne la matrice de covariance.
Les variances corrigés se trouvent sur la diagonale de cette matrice.
/!\ Faire la racine des valeurs de la diago , on obtient donc les bons ecarts types (erreurs types) */


/*            */
/* Licence L3 */
/*            */

/*      */
/* TP 7 */
/*      */

Libname TP 'C:\Documents and Settings\e21numetu\Bureau\TP7';

/* ex 1 */ 

/* 1) */ 
data tp.data; 
set tp.pluie ;
d=1 ; 
run ; 
proc gplot data=tp.data ;
title "Boite à moustache";
symbol1 value=plus
        interpol=boxtf /* annonce boite à moustache = boxplot */
        width=1  /* largeur des traits */
        bwidth=10 /* largeur de la boite */
        cv=grey   /* couleur de la boite et des points */
        co=black; /* couleur trait */
axis1 order=0.5 to 1.5 by 0.5 label=none;
axis2 label=(a=90 r=0);
plot (pluie altitude latitude distance) * d /haxis=axis1 vaxis=axis2;
run;
quit;

/* on constate des variables extremes l'altitude et la pluie. */

proc boxplot data=tp.data;
axis1 order=0.5 to 1.5 by 0.5 label=none;
axis2  label=(a=90 r=0);
plot pluie*d /haxis=axis1 vaxis=axis2;
run;

/* 2) */

proc reg data=tp.data;
model pluie=altitude distance latitude ; 
run;
/* test de fisher : p-value < 0.01 , on rejette l'hypothese selon la quelle 
tous les coef sont = 0 . */
/* interpretation du R² : le modele explique 55% de la variance de la pluie */ 

/* Bo = pluviometrie moyenne si tous les coef etaient = 0.
Il est négatif car tous les coeff ne sont pas =0 */

/* coef tous significativement different de 0  car p-value < 0.05 (test de student) */
/* lorsque l'altitude augmente de 1 foot la pluie augmente de 0.004 inch.
lorsque la distance augmente de 1 miles la pluie diminue de 0.14 inch.
lorsque la latitude augmente de 1 degre la pluie augmente de 3.47 inch. */

/* 3) distance de cook */
/* test de cook */
proc reg data=tp.data ; 
model pluie=altitude distance latitude ; 
output out=sortie1 cookd=dist_cook rstudent=rstud h=levier ;
run;
quit;

/*graphique de l'effet de levier et du Rstudentisé*/ 

proc gplot data=sortie1;
plot rstud*levier;
run;
/* comme utilisation de box plot avant, penser a changer l'affichage des points */ 

proc reg data=sortie1 plot(label) =(Rstudentbyleverage);
model pluie=altitude distance latitude;
run;
quit;
/* bonne maniere d'afficher les R-studentisé en fonction du levier */

/* les variables 19 et 29 sont extremes et le 5 et le 28 semblent etranges*/ 

proc sort data=sortie1;
by levier;
run;

proc reg data=sortie1 outest=sortie2;
model pluie=altitude distance latitude /influence;
run;

/* le tableau nous confirme que les variables 29 et 19 sont extremes car 
leur |r-student| est > 2 */ 
/* pour determiner quel coef les variables influencent, on regarde celles qui depassent dans DFBETAS 2/sqrt(n) = 0.36 */
/* la variables 29 influence : B0, B2 et B3 */
/* la variables 19 influence les 4 coefficients*/


/* 4) */
proc reg data=sortie1  ;
model pluie=latitude ;
run;

/* ex 2 */ 

/* 1) */ 

proc reg data=tp.mroz ; 
model lwage= educ exper expersq ; 
run ; 

/* test de fisher : p-value < 0.01 , on rejette l'hypothese selon la quelle 
tous les coef sont = 0 . */
/* interpretation du R² : le modele explique 15% de la variance du salaire */ 

/* Bo = salaire moyen si tous les coef etaient = 0.
Il est négatif car tous les coeff ne sont pas =0*/
				/* modele semi-log mais modele non temporel */
/* coef tous significativement different de 0  car p-value < 0.05 (test de student) */
/* lorsque l'education augmente d' 1 unité le salaire augmente de 0.1 unité .
lorsque l'experience augmente d' 1 unité le salaire augmente de 0.04 unité.
lorsque lexperience au carré augmente d' 1 unité le salaire diminue de 0.0008 unité. */

/* 2) */
/* test d'endogènéité */
/* etape 1 */
proc reg data=tp.mroz ; 
model educ= MOTHEDUC FATHEDUC exper expersq ; 
output out=sortie3 r=residu3;
run ; 

/* etape 2 */
proc reg data=sortie3;
model lwage=exper expersq educ residu3 ; 
run; 

/* p-value du residu > 0.05 donc on accepte l'hypothese d'endogènéité */

/* 3) */
/* la méthode des variables instrumentales */
/* On utilise la méthode des doubles moindres carrés */

proc syslin data=TP.mroz 2sls;
instruments MOTHEDUC FATHEDUC;
endogenous educ;
model lwage= exper expersq educ;
run;

/* Le syslin recalcule le bon coeff de la variable endogène Educ en tenant 
comtpe de l'endogénéité = 0.06. 
A cause de l'endegénéité on avait tendance à surestimer l'influence de l'éducation sur le salaire.
Donc désormais, qd l'education augmente d'1 unité, le salaire augmente en fait de 0.06 unités */

/* 4) */
/* On fait un test de SARGAN qui teste la pertinence des instruments */

proc syslin data=tp.mroz 2sls out=sortie4;
instruments MOTHEDUC FATHEDUC;
endogenous educ;
model lwage= exper expersq educ;
output r=residu4;
run;

proc reg data=sortie4 outest=sargan;
model residu4 = MOTHEDUC FATHEDUC exper expersq/adjrsq;
run;

data SARGAN;
set sargan;
s=_EDF_*_RSQ_;
stat=CINV(0.95,2);
run;

/* On considére le R²=0.001. On calcule la stat de SARGAN : S=(N-k-1)*R² = 0.437.
On regarde dans la table SARGAN qu'on a créé. On compare avec la stat du X² pour ddl=2 --> 5.99 (dans la table)
On a S< la valeur du X² donc on ne rejette pas Ho, donc les instruments n'influencent pas directement le
salaire, ils sont donc pertinents.*/



/*            */
/* Licence L3 */
/*            */

/*                       */
/* Correction des TP SAS */
/*                       */


/*********************************************/
/*            TP1:                           */
/*   AUTOCORRELATION ET HETEROSCEDASTICITE   */
/*********************************************/

/*****************/
/*    EXERCICE 1 */
/*****************/

libname tata "D:\cours_caen\L3_MASS_SHS\TD-TP\2012\TD-TP1";

data base;
set tata.conso;run;

/* question 1a : représenter graphiquement l'évolution consommation*/
proc gplot data=base;
Title1 "Evolution de la consommation";
Title2 "de 1975 à 2008";
Footnote justify =right "Source: OCDE";
symbol1 color=black
        interpol=join 
        value=NONE;
plot conso*periode;
run;

proc gplot data=base;
Title1 "Evolution de la consommation et du revenu";
Title2 "de 1975 à 2008";
Footnote justify =right "Source: OCDE";
symbol1 color=black
        interpol=join 
        value=NONE;
symbol2 color=red
        interpol=join 
        value=NONE;
plot conso*periode revenu*periode/overlay ;
run;

/* question 1b : représenter graphiquement l'évolution consommation*/
proc gplot data=base;
Title1 "Relation entre le revenu et la consommation";
Title2 "de 1975 à 2008";
Footnote justify =right "Source: OCDE";
axis1 label=(angle=90 "CONSOMMATION") ;
axis2 label=("REVENU");
symbol1 color=black
        interpol=none
        value=dot;
plot conso*revenu/vaxis=axis1 haxis=axis2;run;


/* Question 2: Estimer le modèle*/
proc reg data=base;
model conso=revenu periode;
output out=baseres r=residus p=consoest;
run;

/* Question 3: Etude des résidus*/
GOPTIONS RESET = SYMBOL;
proc gplot data=baseres;
title 'Vérification distribution des résidus';
symbol1 color=black /* la couleur */
        interpol=none/* on affiche que les points */
        value=plus; /* on utilise une croix '+' */
plot residus*consoest/vaxis=axis1 vref=0;run;

GOPTIONS RESET = SYMBOL;
proc gplot data=baseres;
title 'Vérification distribution des résidus';
symbol1 color=black /* la couleur */
        interpol=line /* on affiche que les points */
        value=plus; /* on utilise une croix '+' */
		 axis1 label=(a=90 r=0);
plot residus*periode/vaxis=axis1;
run;

/* question 4a : Faire un test de Durbin  Watson autocorrélation d'ordre 1*/
proc reg data = base;
  model conso = revenu/dw;
run;
quit;

/* question 4b: Faire un test de white*/
proc model data=base;
  parm a1 a2;
  conso = a1+ a2*revenu;
  fit conso / white ;
run;
quit;

/* option test de Breusch Pagan*/
proc model data=base;
  parm a1 a2;
  conso = a1+ a2*revenu;
  fit conso / pagan=(1 revenu) ;
run;
quit;
   
/* Question 5 : */

data base;
set base;
conso_t=lag(conso);
by periode;
run;

proc reg data=base;
model conso=revenu conso_t/DW;
run;

/* option pour voir si pb d'auto-correlation supérieur à 1*/
proc autoreg data=base;
model conso=revenu conso_t/godfrey ;run;

/* Question 6 : */

data base;
set base;
conso_t2=lag2(conso);
conso_t3=lag3(conso);
by periode;
run;

proc reg data=base;
model conso=revenu conso_t conso_t2 conso_t3/DW;
run;

/* deux stratégies*/
/*cas1 :*/
proc reg data=base;
model conso=revenu conso_t conso_t2 conso_t3/DW;
output out=baseres r=residus p=consoest;
run;

proc univariate data=baseres normal;
var residus;run;
/*cas2 :*/
proc autoreg data=base;
model conso=revenu conso_t conso_t2 conso_t3/normal;
run;
  
/*****************/
/*    EXERCICE 2 */
/*****************/

libname titi "D:\cours_caen\L3_MASS_SHS\TD-TP\2012\TD-TP1";

data b;
set titi.salaire;
run;

proc reg data=b;
title 'régression linéaire simple';
model lsalaire=lexpe lage lagelexpe;
output out=residus r=residus p=y_hat;
run;

data residus;
set residus;
label residus="Residus estimes" y_hat="log du salaire estimé";run;

proc gplot data=residus;
symbol1 color=black /* la couleur */
        interpol=NONE /* on affiche que les points */
        value=circle;
title 'Analyse du résidu';
plot residus*y_hat ;
run;

proc reg data=b;
title 'régression linéaire simple';
model lsalaire=lexpe lage lagelexpe;
run;

proc model data=b;
      parm a1 a2 a3 a4;
      lsalaire = a1+ a2*lexpe + a3*lage + a4*lagelexpe;
      fit lsalaire / white ;
   run;
quit;

/* option ACOV permet d'introduire la correction de White*/
proc reg data=b;
  model lsalaire = lexpe lage lagelexpe/acov;
run;


/*******************************************************/
/*             CORRECTION DU TP 3                      */
/*              VARIABLES EXTREMES ET ENDOGENEITE      */
/*******************************************************/

/* exercice 1*/
proc gplot data=base;
title "Boite à moustache";
symbol1 value=plus
        interpol=boxtf /* annonce boite à moustache*/
        width=1  /* largeur des traits*/
        bwidth=10 /* largeur de la boite*/
        cv=grey   /* couleur de la boite et des points*/
        co=black; /* couleur trait*/
axis1 order=0.5 to 1.5 by 0.5 label=none;
axis2  label=(a=90 r=0);;
plot (Altitude Latitude Distance) * d/haxis=axis1 vaxis=axis2;
run;

/* exercice 2*/
proc reg data=base plot(label)=(RStudentByLeverage CooksD);
model pluie=Altitude Latitude Distance;
output out=sortie cookd=cook rstudent=rstudent h=levier ; 
run;
quit;

proc reg data=base plot(label)=(RStudentByLeverage CooksD);
model pluie=Altitude Latitude Distance;
output out=sortie cookd=cook rstudent=rstudent h=levier 
; 
run;
quit;

proc reg data=base;
model pluie=Altitude Latitude Distance/influence;
ods output  OutputStatistics=dfbetas; 
run;
quit;

proc means mean data=dfbetas;run; 

/*la valeur du dfbetas signifie qu'en incluant l'observation (comparativement en l'excluant), l'observation augmente le coefficient étudié 
par le bfbeta multiplié par l'écart-type du coefficient étudié 
par exemple si dfbetas=0,14 et le coefficient de 3 et son ecart-type de 15 l'introduction de la variable augmente de  0,14*15*/

data dfbetas; 
set dfbetas; 
limite=2/(30**0.5);
obs=_N_;
run;

GOPTIONS RESET=all ;
proc gplot data=dfbetas; 
title "Analyse des DFbetas";
symbol1 color=black
        interpol=none
        value=X;
symbol2 color=red
        interpol=none
        value=dot;
symbol3 color=green
        interpol=none
        value=dot;
symbol4 color=green
        interpol=none
        value=star;
axis2  label=(a=90 r=0 "DfBETAS");
plot DFB_Intercept*obs=1 
DFB_Altitude*obs=2 
DFB_Latitude*obs=3 
DFB_Distance*obs=4 
/overlay vref=-0.365 vref=0.365 vaxis=axis2;
run;

/* idem mais avec le numéro en label*/

GOPTIONS RESET=all ;
proc gplot data=dfbetas; 
title "Analyse des DFbetas";
symbol1 color=black
        interpol=none
        pointlabel=("#obs") font=simplex value=none;
symbol2 color=red
        interpol=none
        pointlabel=("#obs") font=simplex value=none;
symbol3 color=green
        interpol=none
        pointlabel=("#obs") font=simplex value=none;
symbol4 color=green
        interpol=none
        pointlabel=("#obs") font=simplex value=none;
axis2  label=(a=90 r=0 "DfBETAS");
plot DFB_Intercept*obs=1 
DFB_Altitude*obs=2 
DFB_Latitude*obs=3 
DFB_Distance*obs=4 
/overlay vref=-0.365 vref=0.365 vaxis=axis2;
run;

/* exercice 3*/ 

GOPTIONS RESET=all ;

proc reg data=base;
model pluie=Latitude  ;
output out=sortie p=y_hat ; 
run;
quit;

proc reg data=base(where=(obs not in (19,29)));
model pluie=Latitude ;
output out=sortie1 p=y_hat1 ; 
run;
quit;
proc sort data=sortie;by obs;run;

proc sort data=sortie1;by obs;run;
data sortie;
merge sortie sortie1;
by obs;run;

proc gplot data=sortie;
title "Droite de régression";
symbol1 color=black
        interpol=none
        value=plus;
symbol2 color=red
        interpol=none
        value=dot;
symbol3 color=green
        interpol=none
        value=dot;
axis2  label=(a=90 r=0);
plot pluie*Latitude  y_hat*Latitude  y_hat1*Latitude /overlay vaxis=axis2;
run;

/* exercice 4*/ 

data base;
set base;
d_29=obs=29;
d_19=obs=19;
run;

proc reg data=base;
model pluie= Latitude d_29 d_19;
output out=sortie2 p=y_hat3 ; 
run;
quit;

proc sort data=sortie;by obs;run;

proc sort data=sortie2;by obs;run;
data sortie;
merge sortie sortie2;
by obs;run;

proc gplot data=sortie;
title "Droite de régression";
symbol1 color=black
        interpol=none
        value=plus;
symbol2 color=red
        interpol=join
        value=dot;
symbol3 color=green
        interpol=join
        value=dot;
symbol4 color=blue
        interpol=none
        value=dot;
axis2  label=(a=90 r=0);
plot pluie*Latitude  y_hat*Latitude  y_hat1*Latitude  y_hat3*Latitude /overlay vaxis=axis2;
run;

proc reg data=base outest=aic;
model pluie=Altitude Latitude Distance d_19 d_29/aic adjrsq; 
run;
quit;

proc reg data=base outest=aic1;
model pluie=Altitude Latitude Distance/aic adjrsq; 
run;
quit;

proc reg data=base(where=(obs not in (19,29))) outest=aic2;
model pluie=Altitude Latitude Distance/aic adjrsq; 
run;
quit;

data aic;set aic; keep _AIC_ _adjrsq_;run;
data aic1;set aic1; keep _AIC_ _adjrsq_;run;
data aic2;set aic2; keep _AIC_ _adjrsq_;run;

data aic;
set aic aic1 aic2;run;


/*******************************************************/
/*                QUESTION 2)  ENDOGENEITE             */
/*******************************************************/

libname toto "D:\cours_caen\M2_econometrie\theme_rappel";

/*
Mroz, T.A. (1987): "The Sensitiviy of an Empirical Model of Married Women's Hours of Work to Economic and Statistical Assumptions", 
Econometrica, 55, 765-799.
*/

data base;
set toto.mroz;
if hours>0;
lwage=log(wage);run;
/* 428 observations*/

proc reg data=base;
model lwage= educ exper expersq;run;

/**************************************/
/*  TESTER l'ENDOGENEITE DE EDUC      */
/**************************************/

proc reg data=base noprint;;
model educ = exper expersq motheduc fatheduc huseduc;
 /* endogène en fonction ensemble exogènes et instruments*/ 
output out=res r=educ_res;	/* on récupère résidu*/
quit;

proc reg data=res;;
model  lwage= educ educ_res exper expersq; /* y en fonction de x et x_res*/
test educ_res=0; /* test sur la significativité du coefficient*/
quit;

/******************************************/
/*  MODELE UTILISANT LA TECHNIQUE DES VI  */
/******************************************/

/* double moindre carré direct*/
proc syslin data=base 2sls ;
	endogenous educ; /* variables endogenes*/ 
	instruments motheduc fatheduc huseduc; /* instruments retenus */
	model lwage= educ exper expersq ; /* modelisation */  /* pondération*/
	run;
	quit;
/* double moindre carré à la main */

/* etape 1 : on estime educ en fonction des variables explicatives et des instruments*/	
proc reg data=base;
model educ= motheduc fatheduc huseduc exper expersq;
output out=sortie p=estim;/* récupère le résidu et estimé*/
run;
quit;

/* etape 2 : on estime lwage en utilisant educ_hat*/
proc reg data=sortie;
model lwage= estim exper expersq;
run;
quit;


/******************************************/
/*  TEST SUR pertinence des instruments   */
/******************************************/

/* pertinence des instruments */
/* F test*/
proc reg data=base;
model educ= motheduc fatheduc huseduc exper expersq;
  test motheduc=fatheduc=huseduc=0;
run;
quit; 

/* test de suridentification*/
proc syslin data=base 2sls out=residu;
	endogenous educ; /* variables endogenes*/ 
	instruments motheduc fatheduc huseduc; /* instruments retenus */
	model lwage= educ exper expersq ; /* modelisation */  /* pondération*/
output r=residu;
run;
quit;

proc reg data=residu OUTEST=sortie noprint;			
model residu=motheduc fatheduc huseduc educ exper expersq/adjrsq ;run;

quit; 
data sortie;
set sortie;
stat_SARGAN= (_EDF_)*_RSQ_;/*_EDF_=N-k-1*/
value_CHi=cinv(0.95,3);
pvalue=1-probCHI(stat_SARGAN,3);
run;

proc print data=sortie;
var  stat_SARGAN value_chi pvalue;run;



/**************/
/*            */
/*   FIN      */
/* Licence L3 */
/*            */
/**************/



/**************/
/*            */
/*   DEBUT    */
/* MASTER M1  */
/* Semestre S1*/
/*            */
/**************/

/*######
# TP 1 #
######*/

/* lib : sas */
libname sas "C:\Documents and Settings\e21numetu\Bureau\sas";
/* lib par defaut */
options user=sas;
/* lire un fichier.sas : script sas*/
%include "C:\Documents and Settings\e21numetu\Bureau\TPSAS\sas\ex-data-1.sas";
/* la table s'affiche et la base de données est importée */

/* ou en macro var :  */

/* variable macro contenant un chemin utilisee souvent;  */
%let rep=C:\Documents and Settings\Prof\My Documents\Teaching\2013-2014\Semestre 1\M1 MASS Analyse des donnees\TP 1;
/* controle (optionel): affichage de la valeur de la macro variable rep;  */
%put &rep;
/* lecture du fichier;  */
%include "&rep\ex-data-1.sas";


/* Creer des tables de données en saisissant les valeurs */
data test_num;
input x;
cards;
1
2
;
run;

data test_char;
input x$;  /*  $  : pour indiquer que c'est un caractere */
cards;
a
b
;
run;

/* merge : fusionne deux tables par colonne */
data testx; 
input x;
cards; 
1
run;
data testy; 
input y;
cards; 
2
run;
data somme;
merge testx testy;
s=x+y; /* créer une nouvelle variable */
run;

data tab3;
input x y$ z;
cards; 
1.0 AA 12
2.0 AB 1
4.0 AB 4
3.0 ACCC -10
run;

data tab33;
set tab3; /* copie la table tab3 */
If z<0 and z>10 then delete ;  /* supprime les lignes ou z<0 et z>10*/
if y ne 'AB' then delete; /* supprime les lignes ou Y!='AB' */
run;
/* Pour juste afficher le resultat ci dessus */
proc print data = tab3(where=((z>0) and (z<10) and ( y='AB')));
run;

/* Lecture de donnees avec sas : infile */
data characters;
infile 'C:\Documents and Settings\e21numetu\Bureau\sas\data-characteres.txt';
input pn$ 1-20 age ville$  29-37; /* $1-20 : de la premiere colonne a la 20  */
run;
/* $20. : precise le nombre de caractere */

data data3x3;
infile 'C:\Documents and Settings\e21numetu\Bureau\sas\data-3x3.txt';
input x1$ x2$ x3$ @@; /* @@ : oblige a lire toute la ligne */
run;

data datasep;
infile 'C:\Documents and Settings\e21numetu\Bureau\sas\data-sep.txt'
delimiter=',';  /* indiquer le separateur : delimiter  (arg de infile, donc sur la meme ligne) */
length nom $10.;
input nom$ age;
run;

/* lire que entre 3 et 5 */
data datasep2;
infile 'C:\Documents and Settings\e21numetu\Bureau\sas\data-sep.txt'
delimiter=',' firstobs=3 obs=5; /* fistobs démarre à la ligne 3 et obs signifie jusqu'a 5 */
input nom$ age;
run;

data classe1;
infile 'C:\Documents and Settings\e21numetu\Bureau\sas\classe.txt' ;
input nom$ sexe$ age hauteur poids;
run;
/* Ne prendre que les données pour les garcons */
data garcon;
set classe1;
If sexe='F' then delete ; 
run;
/* autre methode */
data garc;
set classe1(where=(sexe='M'));
run;

proc sort data= classe1;
by sexe ;
run;
/* penser a proc sort avant plot */
proc gplot data=classe1;
by sexe; /* faire un graph pour H et un graph pour F */
plot poids*hauteur; /* poids en fonction de hauteur */
run;

/* les deux sexes sur le meme graphique */
proc gplot data=classe1;
plot poids*hauteur=sexe;
run;

axis1 label=(a=90 f="Ariel/Bold"); /* pour ajouter un axe */
proc gchart data=classe1;
title "histogramme de la hauteur";
vbar hauteur / space = 0 raxis=axis1; /* histogramme de hauteur, vbar : barres verticales (sinon hbar) */
run;

data mergelapin;
infile 'C:\Documents and Settings\e21numetu\Bureau\TPSAS\sas\data-merge-lapin.txt' ;
input traitement numeroT temperature temperature4;
run;
proc means data=mergelapin ;
var temperature temperature4; /* affiche la moyenne des temperatures (à T0 et T4) ecart type, min max */ 
by traitement; /* pour chaque traitement */
run;

/* Si on veut seulement les moyennes */
proc means data=mergelapin mean;
class traitement; /* Pour chaque traitement */
var temperature temperature4; /* calcule la temperature moyenne */
output out=moylapin mean(temperature temperature4)=moy0 moy4;
run;
/* output : pour créer une table et enregistrer les données
premiere ligne : moyenne de toute la table
les trois autres lignes : moyennes des temperature pour chaque traitement */



/*######
# TP 2 #
######*/

data pass_ligne ;
input x y @@;
cards;
1 3 5 2 4 6
;
run;
/* sur une meme ligne donne : x vaut (1) et y vaut (3)*/
/* donc x vaut (1,5,4) et y vaut (3,2,6)*/

data lec_champ125;
infile 'C:\Documents and Settings\e21numetu\Bureau\SAS2\SAS.TP2-champs-var.txt'
delimiter=',';
input #1 x : $15.; output;  /* input nom : $nb. ; signifie que la variable 'nom' est de longueur nb */
input #2 x : $15.; output;
input #5 x : $15.; output;
run;
/* lecture des lignes 1,2 et 5*/

data lec_champ;
infile 'C:\Documents and Settings\e21numetu\Bureau\SAS2\SAS.TP2-champs-var.txt'
delimiter=',';
input x : $20.;
run;
/* lecture de toutes les lignes */

/* dsd DLM : option de infile pour preciser que ce qui est entre " " fait un seul bloc
ex : dsd DLM=','; */

/* Pour enregistrer des dates */
data label;
infile 'C:\Documents and Settings\e21numetu\Bureau\SAS2\SAS.TP2-label.txt' ;
input nom$ 1-30 prenom$ 31-47 date DDMMYY8.;
format date DDMMYY8.;
run ;

/* ou */

data essai15;
format z ddmmyy8.;
label x='nom' y='prénom' z='date';
infile "&rep/Data/SAS.TP2-label.txt";
input x $ 1-30 y $ 31-47 z ddmmyy8.;
run;

/* Pour modifier la saisie d'une variable 1 en Master1  et 2 en Master2 */
proc format;
value formatdip
	1='Master 1ère année'
	2='Master 2ème année';
run;
data essai16;
infile "&rep/Data/SAS.TP2-format.txt" delimiter=',';
format diplome formatdip.;
input nom $ : 15. diplome;
run;

/* ou */

data donneeDiplome;
infile 'C:\Documents and Settings\e21numetu\Bureau\TPSAS\SAS2\SAS.TP2-format.txt' 
delimiter=',';
input nom: $15. diplome;
if diplome=1 then annee='Master1';
else annee='Master2';
drop diplome; /* laisse tomber la variable diplome */
run;


/*######
# TP 3 #
######*/

libname SAS3 "C:\Documents and Settings\e21numetu\Bureau\TPSAS\sas3";
title ’Etude billets de banques suisse’; /* Donner un titre a toutes les sorties */

proc gchart data=Billet(where=(type='vrai'));
vbar d; /* d : la longueur diagonal des billets*/
run; 

proc gchart data=Billet gout=graphique;
/*subgroup=superposer deux graphiques*/
vbar d / subgroup=type;
vbar longueur / subgroup=type;
vbar hauteurL / subgroup=type;
vbar hauteurR / subgroup=type;
vbar margeB / subgroup=type;
vbar margeH / subgroup=type;
run;

proc gplot data=Billet;
plot d* (longueur hauteurL hauteurR margeB margeH)=type; /* d en fct de (chaque var) = type separe les points vrai/faux (en bleu/rouge) */
run;

/* insight SAS/Insight Statements*/ 
/* scatterplot : diagramme de dispersion */

PROC INSIGHT DATA=user.Billet;
SCATTER d longueur hauteurL hauteurR margeB margeH *  d longueur hauteurL hauteurR margeB margeH;
title ’Scatterplot’;
run;quit;

/* Créer une table avec une boucle do.. to.. by.. */
data table;
do x=0 to 5 by 0.05;
y1=x*sin(x);
y2=x*cos(x);
output;
end;
run;

proc gplot data=table;
plot y1*x y2*x /OVERLAY; /*OVERLAY = superposer deux courbes sur un meme graphique*/
run;

/*4 et 5*/
symbol1 interpol=join ci=blue v='square'; 
symbol2 interpol=join ci=red v='circle';
proc gplot data=table;
plot y1*x=1 y2*x=2 / OVERLAY;
run;
/* =1 et =2 on utilise les symboles 1 et 2
si on ne specifie rien, c'est fait par defaut */

/* Reinitialiser les options */
goptions reset=all;
/* pour re initialiser, juste mettre:
symbol1;
symbol2;
*/

PROC GPLOT DATA=table ;
PLOT y1*x y2*x/ overlay vaxis=axis2 haxis=axis1; 
Title 'Graphe de y1=xsin(x) et y2=xcos(x) '; 
axis1 order=(0 2.5 5) label=("abscisse"); /* haxis=0 to 5 by 2.5; */
axis2 order=(-5 0 5) label=(angle=-90 rotate=+90 "ordonnee"); /* vaxis=-5 to 5 by 5 */
run;



/**********/
/* TP REG */
/**********/

/* tp Regression lineaire 
model Y= a0 + a1*x + a2*x^2 + ... e
test global : F-test : h0:  a1=a2=...=0
test des coefs Student: h0: a0=0 et a1=0 
*/

libname tpReg "C:\Documents and Settings\e21numetu\Bureau\TPSAS\tpReg";
options user=tpReg;

/*Exercice1: Vitesse et distance de freinage*/
data cars;
infile "C:\Documents and Settings\e21numetu\Bureau\TPSAS\tpReg\cars.dat" dlm=" ";
input vitesse freinage;
vitesse2=vitesse*vitesse; /* on calcule la vitesse^2 */
run;

/* nuage de points */
proc gplot data=cars;
plot freinage*vitesse;
run;
/* histogramme */
proc gchart data=cars;
vbar vitesse freinage;
run;

/* Estimation des modeles M1 et M2 */
proc reg data=cars ;
model freinage = vitesse ; /* dist = B0 + B1*speed + e */
output out = sortie r=residu  ;
run;
quit;

proc reg data=cars ;
model freinage = vitesse vitesse2; /* dist = B0 + B1*speed + B2*speed^2 + e */
output out = sortie2  r=residu2;
run;
quit;

/* pour afficher la table : 
proc print data=sortie2;
run;
*/

/* interprétation des tests : 
test global : F-test : h0:  les coef de toutes les variables sont nuls (sauf la constante)
test des coefs Student : t-Test : h0: a0=0 et a1=0 

Pour M1
F<0.05 donc rejet de l'hyp H0 :  il y a au moins une variable avec un coef different de 0. 
t de chaq coef <0.05 donc rejet de l'hyp H0 : chaque coef est different de 0 :
						: h0: a0=0 : p<5% rejeter pour alpha <0.05 et a1=0 : p<1% rejeter pour alpha<0.01

Pour M2
F<0.05 donc rejet de l'hyp H0 : il y a au moins une variable avec un coef different de 0
t de chaq coef >0.05 donc non rejet de l'hyp H0 : tous sont nuls
Probleme : vient de la forte correlation de vitesse et vitesse2 

*/

/* L'erreur standardisée des résidus : sqrt(MSE) */

/* Nuage de point + droite estimée visuelement
a0 = -17.57909
a1 = 3.93241
*/

data car2;
set cars;
droite=-17+3.9*vitesse;
run;

proc gplot data=car2;
plot freinage*vitesse droite*vitesse/overlay;
symbol1 color=red;
symbol2 interpol=JOIN color=red interpol=JOIN;
run;

/* Losrqu'il ya  presence d'autocorrelation : 
--> VIF : facteur d'inflation de variance i.e. inflation des estimateurs pour les parametres

VIF = 1/ 1- R
*/

/* Model 3 :  sans cste : notint (no intercep) et sans la vitesse */

proc reg data=cars;
model freinage = vitesse2 /noint ;
output out = sortie3  r=residu3;
run;
quit;

/* faire une prédiction de la distance d'arret quand on roule a 16 km/h */

data tmp;
 vitesse=16;
 vitesse2=vitesse*vitesse;
 output;
run;

data cars;
  set cars tmp; /* combine l'un en dessous de l'autre */
run;

proc sort data=cars;
 by vitesse;
run;

proc reg data=cars;
mod3: model freinage=vitesse2 /noint all; /* on re decrit notre modele choisi pour une prediction */
plot residual. * vitesse2; 
output out=cars_mod3_out p=distest r=resid; 
run;
quit;
/* dans la table cars_mod3_out : on trouve la prédiction : 39.263680714 */


/* exercice 2 White noise */
PROC IMPORT OUT=whitenoise DATAFILE= "C:\Documents and Settings\e21numetu\Bureau\TPSAS\tpReg\white.noise.xls"
DBMS=excel REPLACE;
RUN;

proc gplot data=Whitenoise;
plot y*(x1-x10); /* un graphe y en fct de x1 ... jusqu'a y en fct de x10 */
run;

/* coef de correlation */
PROC CORR DATA=Whitenoise;
var  y ; /* Liste des variables dont on veut les corrélations. */
WITH x1 x2 x3 x4 x5 x6 x7 x8 x9 x10; /* Évalue les corrélations entre ces variables et celles déclarées dans l'instruction VAR */ 
run;

/* corr (y , x3 ) = 0.68642
et elle est significative car  0.0284 < 0.05 , on rejette l'hypothese que la corr=Rho=0 
idem avec x8
*/

/* multiple comparaison : on a fait 10 tests, on a donc 'cumulé' le risque alpha 
    overfitting : on met trop de variables dans le modele juste pour augmenter le R² 
	se test avec la validation croiser : cross-validation
	ex : si on a un  jeu de donnees, on estimer le modele avec les 9 var et on fait un prevision de la 10ieme, puis on regarde les erreurs
Solution ::: 
Bonferroni : Pour on ajuster le alpha :  alpha/(nb de test) ici 0.5/10
ou Molen (mieux car Bonferroni est trop restrictif ) */ 

proc reg data=Whitenoise;
mod1: model y=x3 /all;
output out=WNout1 p=Yest r=resid;
mod2: model y=x8/all;
output out=WNout2 p=Yest r=resid;
mod3: model y= x3 x8 /all; 
output out=WNout3 p=Yest r=resid;
run;
quit;


/************/
/* TP Anova */
/************/

Libname tpAnova 'C:\Documents and Settings\e20902387\Bureau\TPSAS\tpAnova';
options user=tpAnova;

/* ex1 ANOVA à un facteur */
data donnee; 
input x$ y;
cards;
g1 15 
g1 19 
g2 17 
g2 20 
g2 23 
g3 22 
g3 25 
g3 27 
g3 30
; 
run;
/* x la variable des groupe, y les mesures  */

proc anova data = donnee;
class x;
model y = x; /* on classe les groupes x en fonction des observations y */
run;
/* pv = 0.0336 < 0.05 donc on rejette l'H0 : l'hyp d'égallié des moyennes.
Pour determiner d'ou les differences viennent: ils nous faut des test post hoc
exemple t-test apparié mais avec correction : Bonferroni
Tuckey HSD (honnest significant difference) */

proc glm data = donnee;
class x;
model y = x; 
run;
/* pv=0.0336 
il y a une difference, on a en plus les lignes Type I et III
Mais ici les valeurs sont les meme car on fait une anova a un facteur. */

proc glm data = donnee;
class x;
model y = x; 
means x;
run;

proc glm data = donnee;
class x;
model y = x; 
output out=sortie p=predict r=residu ;
proc print data=sortie; /* affiche les predictions résidus */
run;
quit; 

proc gchart data=sortie;
vbar residu;
run; 

/* test Shapiro Wilks : test de normalité des residus (pour petit echantillon car test tres puissant)
H0 : normalité */
PROC UNIVARIATE data=sortie NORMALTEST alpha=0.1; 
var residu ;
run;
/* pv= 0.9136 >> 0.05 donc non rejet de H0 : les residus sont normalement distribués 
presque 1 p-value donc on ne rejette pas la normalité */

/* ex sur les sportif : */
proc import
datafile="C:\Documents and Settings\e21numetu\Bureau\TPSAS\tpAnova\sport.dat" 
DBMS=tab 
out=sportif
REPLACE;
getnames=yes;
run;

/* b */

proc boxplot data=sportif;
plot value*level;
run;
/* peut etre un pb d'hétéroscedasticité avec le level National */
/* autre test : on test la variabilité de Y pour chaque groupe : 
d'ou les box plot sur le graphique : 
On veut l'homoscedasticité. s'il y a de grande disparité, il y a hétéroscedasticité 
option Bartlett et levene dans glm */

proc univariate data=sportif normal;
class level;
var value;
histogram /normal; /* histo avec affichage d'une densité de loi normale estimée */
run;
/* /normal : rajouter des lignes pour les disctributions gaussiennes à tous les histo */

/* c  test d'heteroscedasticité*/

PROC glm data=sportif; 
class level;
model value = level; 
MEANS level/ HOVTEST=BARTLETT hovtest=levene;
output out=sportif2 p=predict r=residu ;
proc print data=sortie;
run;
quit;

/* Bartlett's Test for Homogeneity of value Variance
pv = 0.7451 > 0.05 donc non rejet de H0 il y a homoscedasticité (egalité des variances)
donc les conditions d'une anova sont satisfaites

Levene's Test for Homogeneity of value Variance
pv= 0.3950 > 0.05 donc non rejet de H0

Turkey HSD : fait la comparaison apparié de tous les facteurs
*/

PROC glm data=sportif; 
class level;
model value = level; 
MEANS level/ HOVTEST=BARTLETT hovtest=levene;
lsmeans level / pdiff adjust=turkey;
run;
quit;
/* on voit une difference significative entre la classe 2 et 4 : regional et international
car pvalue<0.05 rejet de h0 (tukey) l'hyp d'egalité des moyennes est rejetée */ 

/* e */

proc anova data = sportif ; 
class level;
model value = level; 
run;
/* l'anova avec le Ftest : nous permet simplement de conclure qu'il y a au moins une moyenne differente 
(car 0.0322<0.05), mais on ne sait pas la quelle */
/* international et loisir ont des moyennes differentes : grace au test tukey */


/* ex 3 */

/* a */
proc import
datafile="C:\Documents and Settings\e20902387\Bureau\TPSAS\tpAnova\mortgage1.dat" 
DBMS=tab 
out=prets
REPLACE;
getnames=yes;
run;

proc boxplot data=prets;
plot rate*bank;
run;

/*on regroupe nos groupes avec l'aide de la proc sort*/
proc sort data=prets;
by group;
run;
proc boxplot data=prets;
plot rate*group;
run;

proc univariate data=prets normal;
var rate;
histogram /normal; /* histo avec affichage d'une densité de loi normale estimée */
run;
/* si on fait l'histo des rates on voit qu'ils sont asymétrique et que la distribution normale semble ne pas concorder */

/* b : procedure Anova */
proc glm data = prets;
class bank;
model rate = bank; 
output out=prets2 p=predict r=residu ;
proc print data=prets2;
quit;
run;

/* F=0.7227 > 0.05 donc non rejet de H0. tous les taux semblent egaux */

/* condition pour faire une anova */
/* test de normalité des residus */
PROC UNIVARIATE data=prets2 NORMALTEST alpha=0.05; 
var residu ;
run;
/* shapiro : pvalue= 0.0041 <0.05 donc rejet de H0 : les residus ne sont pas nomalement distribués
On n'a pas le droit de faire une anova 
les resultats sont à regarder avec prudence */

/* souvent pour remedier au pb on fait log(rate) */


/* c */
proc glm data = prets;
class group;
model rate = group; 
output out=prets3 p=predict r=residu ;
proc print data=prets3;
quit;
run;

PROC UNIVARIATE data=prets3 NORMALTEST alpha=0.05; 
var residu ;
run;

/* avec l'anova : Fvalue<.0001 : rejet de h0, les moyennes sont egales
et avec le test de normalité : shapiro pvalu = 0.9893 >> 0.05 : non rejet de l'hyp H0, les residus sont normalement distribués 

Il y a des diffences quant aux rejet de demande de prets selon si on appartient aux groupes White ou minority */

/* d 
l'egalité de moyennes entre 2 groupe <=> T test apparié (car c'est la meme bank !!! )
ou anova a mesures répétées
*/

/* e 
si la condition de normalité n'est pas respecter, on peut prendre le log de la variable (lorsqu'il y a un pb d'asymetrie)
ou 
Box Cox transformation : meilleur solution

si pas de normalité : test non parametrique : pas besoin de l'homogeniéité des variances ni de la normalité
Kruskal-Wallis
(mais on perd de la puissance)
*/

/* f */
/* nouvelle base pour rajouter une nouvelle colonne dans notre tableau prets precedent */
data pretslog;
set prets;
lograte=log(rate);
run;

/* anova a deux facteur : bank et group */
proc glm data = pretslog;
class bank group;
model lograte = bank group; 
output out=prets3 p=predict r=residu ;
quit;
run;


/********/
/* TP 4 */
/********/

/* pour faire une macro variable : %let var1='abc'
   pour l'executer : &var1 => 'abc' 

Macro ~ fonction en R
%macro nom(var1,var2...)
...
%mend

*/

Libname tp4 'C:\Documents and Settings\e20902387\Bureau\SAS\TP4';
/*lib par defaut */
options user=tp4;

%macro lecacp(in,out,ident,listev,lib=user,dlm=' ');
data &lib..&out;
infile "&in" dlm=&dlm;
input &ident $ &listev; run;
%mend;

%lecacp('C:\Documents and Settings\e20902387\Bureau\SAS\TP4\temp.dat', 
temp, ville, janv fevr mars avri mai juin juil aout sept oct nov dec);
proc print;
run;

/* sous repertoire : dans le dossier work/ sasmacr / on trouve Lecacp 

sinon : on enregistre macro1.sas
to include macro, save it as test file (copy/paste)
 %include "le chemin vers le fichier texte/macros/lecacp.sas 

*/

/* 2.1 Représentations de courbes : Transposition et concaténation */

data ttemp (keep= i nom temp);
	set user.temp;
	array c{*} _numeric_;  /* c{*} créé un array de dim inconnu, et n'accede qu'aux parties numeric de chaque ligne */
	do i=1 to dim(c); /*dim(c) ici =12 pour nos 12 mois*/
		nom=ville;
		temp=c{i};
		output;/* sans le output : i va jsuqu'a 12 mais n'a rien enregistré. sas ne prend que les données rencontré au dernier pas */ 
	end;
	run;

/* 2.2 Graphe */
/* Graphe de l'évolution des temperatures en fonction des mois */

%let vil1=ajac;
%let vil2=lill;
%let vil3=bres;

goptions colors=(black);
proc gplot data=ttemp;
where nom="&vil1" or nom="&vil2" or nom="&vil3";
symbol1 v=dot i=spline;
symbol2 v=triangle i=spline;
symbol3 v=square i=spline;
plot temp*i=nom;
run;
quit;
goptions reset=all;

%macro gtemp(vil1,vil2,vil3);
goptions colors=(black);
proc gplot data=ttemp;
where nom="&vil1" or nom="&vil2" or nom="&vil3";
symbol1 v=dot i=spline;
symbol2 v=triangle i=spline;
symbol3 v=square i=spline;
plot temp*i=nom;
run;
%mend;

%gtemp(tlse,pari,lill);

/* 2.3 Impression : en pdf */
%macro epdf(file,l=10,h=10);
quit;
filename gsasfile "&file..pdf";
goptions device=pdfc vsize=&h cm hsize=&l cm
gaccess=gsasfile;
%mend;

%epdf(C:\Documents and Settings\e20902387\Bureau\SAS\TP4\tlpali);
%gtemp(tlse,pari,lill);
%epdf(C:\Documents and Settings\e20902387\Bureau\SAS\TP4\ajlibr);
%gtemp(ajac,lill,bres);
/* la sorti pdf ne fonctionne pas.. on a l'image en png */


/* 3 Traitement bivarié */
/* pour produire un nuage de points a 2 dim */
proc gplot data=temp;
	symbol1 v=dot i=none;
	plot janv*fevr=1;
	run;
	quit;

%macro nuagedepoint(table,var1,var2,v=dot);
title1 "Nuage de Point";
proc gplot data=&table; /* ici notre table=temp toutes nos données de temperature*/
	symbol1 v=dot i=none;
	plot &var1*&var2=1;
	run;
	quit;
%mend;
/* ne pas oublier le & devant les variables */

%nuagedepoint(temp,janv,juin);
/* deux mois proche seront fortement corrélé, 
ici entre janv et juin, aucune correlation visible, grande variation de temperature */

/* 4 Analyse en composantes principales

4.1 Acp de base de SAS  = princomp

*/
proc princomp data=temp
outstat=eltpr /* la table eltpr comprend des statistiques elementaires ainsi que les valeurs propres et vec propres unitaires */
out=compr; /* la table compr contient les coordonnees des individus sur les axes principaux */
run;
proc print data=eltpr round noobs;run;
proc print data=compr round noobs;run;

/* dans eltpr 
mean et sd pour chaque mois
matrice de correlation : exemple : janv et fev sont tres corrélé

eigenvalues of correlation matrix : valeurs propres
lambda1 : 10.472183219
lambda2 : 1.4064722164 ... les autres sont tres petites

la prop de l'information expliqué par chaque composantes : Lambda(i) / somme(lambda) 
lambda 1 : 0.8727 : la premiere composante explique 87% de la variablité des données (1er ecart de 10 dans les nouvelles coordonnes entre temp(max) et temp(min)
lambda 2 : 0.9899 : la 1iere et 2ieme composantes expliqueront 98% de la variablité des données (2e ecart de 5, 3e 1 ...)

on utiliserai que les deux premiers axes

On a les vecteurs propres en dessous en ligne V1 : (0.2715102827 , 0.2884616403 ...)

*/

/*  4.2 Acp détaillée
4.2.1 Analyse pas à pas
*/

%include "C:/Documents and Settings/e20902387/Bureau/SAS/TP4/TP4_SAS_Macro_AnaDon_macro.sas";

/* ou contenu ci-dessous de la macro acp = fichier TP4_SAS_Macro_AnaDon_macro.sas */
/* DEBUT macro acp */

/* la variable pvar alloue dans la macro acp doit etre visible de l'exterieur */
%global pvar;

%macro acp(dataset, ident, listev,q=3);
    %* Acp de dataset ;
    %*          ident : variable contenant les identificateurs;
    %*                  des individus;
    %*        listev : liste des variables (numeriques);
    %*              q : nombre de composantes retenues;

    options linesize=80 pagesize=66 nonumber nodate;
    footnote;
    title "A.c.p. des donnees de &dataset";

    data donnees (keep=&ident &listev);
        set &dataset;
    run;

    proc princomp data=donnees 
        noprint
        outstat=eltpr 
        out=compr;
        var &listev;	
    run;
    
    %* nettoyage des resultats;
    data tlambda (drop=_type_)
        tvectp (drop=_type_)
        sigma (drop=_type_)
        statel;
        set eltpr;
        select (_type_);
            when ('EIGENVAL') do;
                _name_ = 'lambda';
                output tlambda;
                end;
            when ('CORR','COV')  output sigma;
            when ('SCORE')       output tvectp;
            otherwise output statel;
            end;
    run;

    proc print data=statel noobs round;
        title2 'Statistiques elementaires';
    run;

    title;

    proc print data=sigma noobs round;
        title2 'Matrice des covariances ou des correlations';
    run;
    
    data lambda (keep=k lambda pctvar cumpct);
        set tlambda (drop= _name_) ;
        array l{*} _numeric_;
        tr=sum(of l{*});
        cumpct=0;
        do k=1 to dim(l);
            lambda=l{k};
            pctvar=l{k}/tr;
            cumpct=pctvar + cumpct;
            output;
            end;
    run;
    
    data lambda ;
        set lambda nobs=pvar;
        call symput('pvar',compress(pvar));
    run;
    proc print data=lambda noobs round;
        title2 'Valeurs propres, variances expliquees';
        var k lambda pctvar cumpct;
    run;


    %* matrice des vecteurs propres;
    proc transpose data=tvectp out=vectp prefix=v;
    run;

    %* vecteur contenant les ecarts types;
    data sigma (keep=sig);
        set sigma;
        array covcor{*} _numeric_;
        sig=sqrt(covcor{_n_});
    run;

    %* Calculs concernant les individus;
    %* ================================;
    %* Calculs  des contributions et cos carres;
    data coorindq;
        if _n_ = 1 then set tlambda;
        set compr (drop= &listev) nobs=nind;
        array c{*}  prin1-prin&pvar;
        array cosca{&q};
        array cont{&q};
        array l{*} &listev;
        disto=uss(of c{*});
        poids=1/(nind-1);
        do j = 1 to &q;
            cosca{j}=c{j}*c{j}/disto;
            cont{j}=100*poids*c{j}*c{j}/l{j};
            end;
        contg=100*poids*disto/sum(of l{*});
        keep &ident prin1-prin&q contg cont1-cont&q cosca1-cosca&q ;
    run;
    
    proc print noobs round;
        title2 'Coordonnees des individus contributions et cosinus carres';
        var &ident prin1-prin&q contg cont1-cont&q cosca1-cosca&q ;
    run;
    
    %* calcul des coordonnees des variables;
    %* ====================================;
    
    proc print data=vectp noobs round;
        title2 'Vecteurs propres';
    run;
    
    data coordvar (drop=i lambda);
        set tvectp;
        set lambda (keep=lambda);
        array coord{*} &listev;
        do i = 1 to dim(coord);
            coord{i}=coord{i}*sqrt(lambda);
            end;
    run;

    proc transpose data=coordvar out=coordvar prefix=v;
        var _numeric_;
    run;
    
    proc print noobs round;
        title2 'Coordonnees des variables (isométrique colonnes)';
    run;
    

    %* calcul des correlations variables x facteurs;
    
    data covarfac (drop=i sig);
        set  coordvar;
        set sigma;
        array coord{*} _numeric_;
        do i = 1 to dim(coord);
            coord{i}=coord{i}/sig;
            end;
    run;
    
    proc print data=covarfac noobs round;
        title2 'Correlations  variables x facteurs';
        var _name_ _numeric_;
    run;
    title2;
    %mend;


/* Graphiques */
/* Eboulis de valeurs propres */
%macro gacpsx;
    proc gplot data=lambda;
        title;
        footnote;
        symbol1 i=join v=dot;
        plot pctvar*k=1 / haxis= 0 to &pvar by 1 hminor=0
            vaxis= 0 to 1 by 0.2 vminor=1;
    run;
    quit;
    goptions reset=all;
    %mend;


/* Boxplot des axes */
%macro gacpbx;
    data conccomp (keep=k cc);
        set compr (keep=prin1--prin&pvar);
        array c{*} _numeric_;
        do k = 1 to &pvar;
            cc=c{k};
            output;
            end;
    run;

    proc gplot data=conccomp;
        footnote;
        symbol1 i=box v=star;
        plot cc*k=1 / haxis= 0 to &pvar by 1 hminor=0;
    run;
    quit;
    goptions reset=all;
    %mend;

    
/*    Graphique des individus */

%macro gacpix(ident,x=1,y=2,nc=4,coeff=1);
    %* Graphique des individus;
    %*     x : numero axe horizontal;
    %*     y : numero axe vertical;
    %*  ident: variable identifiant les individus;
    %*    nc : nombre max de caracteres;
    %* coeff : coefficient d agrandissement;
	%* les labels sont place au dessus des point;

    data anno;
        set coorindq;
        retain xsys ysys '2';
        style='swiss';
        y= prin&y;
        x= prin&x;
		function='label';
        text=substr(left(&ident),1,&nc);
		position='2';
        size=&coeff*(cosca&x+cosca&y)+0.2;
        label y = "Axe &y" x = "Axe &x";
    run;
    
    proc gplot data=anno;
        title;
        symbol1 v='dot' h=0.5;
        plot y*x=1 / annotate=anno frame  href=0 vref=0;
    run;
    quit;
    goptions reset=all;
    %mend;


/* Graphique des variables avec cercle des correlations*/
%macro gacpvx(x=1,y=2,nc=4,coeff=1);
    %* Graphique des variables avec cercle des correlations;
    %*     x : numero axe horizontal;
    %*     y : numero axe vertical;
    %*    nc : nombre max de caracteres;
    %* coeff : coefficient d agrandissement;

    %* cercle unité;    
    data cercle_unite;
        do theta=0 to 2*3.146 by .01;
            x=cos(theta);
            y=sin(theta);
            output;
            end;
    run;

    %* table des annotations;
    data anno;
		lenght function $6;
        set covarfac;
        retain  xsys ysys '2';
        x=v&x;
        y=v&y;
        style='swiss';
        label y = "Axe &y" x = "Axe &x";
        function='move';x=0;y=0;output;
        function='draw';x=v&x;y=v&y;line=3;output;
        function='label';x=v&x;y=v&y;text=substr(_name_,1,&nc);
        size=&coeff*sqrt(x*x+y*y);position='6';output;
        keep  function xsys ysys x y text line size position;
    run;

    %* graphique;
    proc gplot data=cercle_unite;
        symbol1 interpol=join v='none';
        title;
        axis1 order = (-1 to 1 by 0.5) length=12CM;
        plot y*x=1  / annotate=anno href=0 vref=0 haxis=axis1 vaxis=axis1;
    run;
    quit;
    goptions reset=all;
    %mend;

/* FIN macro acp */



%let dataset=temp;
%let ident=ville;
%let listev=janv fevr mars avri mai juin juil aout sept oct nov dec;
%let q=3;

/* 
apres avoir fait tourner la marcro ACP : 
premier axe : nord/sud
deuxieme axe : proche/loin de la mer 

cf dossier ACP
*/


/**************/
/*            */
/*   FIN      */
/* MASTER M1  */
/* Semestre S1*/
/*            */
/**************/


/**************/
/*            */
/*   DEBUT    */
/* MASTER M1  */
/* Semestre S2*/
/*            */
/**************/

/* Classification */
/* aide pourles methode de classif SAS : https://support.sas.com/documentation/cdl/en/statug/63347/HTML/default/viewer.htm#statug_cluster_sect004.htm */

/*         */
/* TP 0    */
/* Classif */
/* knn     */
/* kmeans  */
/*         */

data adn(type=distance);
input w1-w6;
/* ou input w1 w2 w3 w4 w5 w6; */ 
cards;
0 0.84 0.95 1.49 1.85 2.56
0.84 0 0.7 1.11 1.87 2.38
0.95 0.7 0 1.35 2.05 2.15
1.49 1.11 1.35 0 1.96 2.32
1.85 1.87 2.05 1.96 0 2.30
2.56 2.38 2.15 2.32 2.30 0
;
run;

/* classification avec methode "plus proche voisin" */ 

proc cluster data=adn method=single nonorm outtree=adn_tree;
run;

proc tree data=adn_tree;
run;

/* classification avec methode "distance moyenne" */ 

proc cluster data=adn method=average nonorm nosquare outtree=adn_tree2;
run;

proc tree data=adn_tree2;
run;

/* Ex 2 : Résultats scolaire */

data notes;
    input nom : $9. franc maths anglais histoire scdt techno
          ed_mus art_plas educ_p;
    cards;
Boris 7 10 11 5 5 11 6 10 14
Mohammad 13 12 16 12 14 13 13 13 15
Stephanie 11 5 16 6 4 12 2 11 9
Andre 14 13 16 11 18 15 8 13 14
Aurelie 7 6 7 9 3 11 2 6 14
Camille 11 18 12 11 15 13 13 12 14
;
run;

/* le nom$:93 signifie que nom sera au plus de longueur 9 */

/* 2. CHA  avec la methode du plus proche voisin */

proc cluster data=notes method=single nonorm outtree=notes_tree;
  var _numeric_;
  id nom;
run;
/* pour lui dire de travailler sur toutes les var quantitative : var _numeric_ ; */

proc tree data=notes_tree;
 id nom;
run; /* sera utile quand on voudra recup des groupes */ 

proc transpose data=notes out=tnotes;
	id nom;
	var _numeric_;
run;

proc means data=tnotes;
run;

/* Ex 3 : etude indistrielle  */
/* kmeans = Nuées Dynamiques = moyennes mobiles */ 

data indus;
  input id $3. x1 x2;
  cards;
	w1 2 10
	w2 2 5
	w3 8 4
	w4 5 8
	w5 7 5
	w6 6 4
	w7 1 2
	w8 4 9
  ;
run;

/* 1. tableau des distances  proc distance */ 
proc distance data=indus method=euclid out=dindus;
	var interval(x1--x2); /* sur les var allant de x1 a x2 */ 
	id id;
run;

proc print data=dindus;
run;


proc distance data=indus method=sqeuclid out=dindussq;
	var interval(x1--x2);
	id id;
run;

proc print data=dindussq;
run;

/* 2. classification par l'algorithme des centres mobiles  avec m1(2,10) ; m2(5,8) ; et m3(1,2) */ 
data indseed;
set ind;
where id='w1' or id='w4' or id='w7';
run;

/* ou */ 

data centres;
    set indus;
    select (_n_); /* _n_ indique le numero de ligne */ 
    when (1,4,7) output;
    otherwise;
    end;
run;

proc fastclus data=indus
    maxclusters=3      /* nb max de classes */
    maxiter=99         /* nb max itération */
    mean=indus_mean      /*  sortie centres de gravités des classes */
    out=indus_fastclus  /* table de sortie */
    outstat=indus_fstat /* sortie pour redémarrer */
	outiter /* pour voire l'évolution des itérations */
    seed=centres     /* table des centres initiaux */
    ;
    var _numeric_;
run;

data indus_anno;    
    set indus;
    	x=x1;
    	y=x2;
        xsys='2';
        ysys='2';
        format text $2.;
        text=id;
    	function='label';
    	label x="&x";
    	label y="&y";
    	keep x y text xsys ysys  function;
run;

symbol1 color=blue   height=4 VALUE='CIRCLE';
symbol2 color=red    height=4 VALUE='CIRCLE';
symbol3 color=green  height=4 VALUE='CIRCLE';

proc gplot data=indus_fastclus;
    plot x2*x1=cluster/
        annotate=indus_anno
        description="Nuees dynamiques centres=w1,w4,w7"
        name="fastclus";
run;
quit;

/* dessiner le graph +

proc gplot ...
... / annotate=indus_fastclus 

Pour que chaque point soit nommé

*/

proc gplot data=indus_fastclus;
	symbol1  v=circle h=5 color='red' ;
	symbol2  v=circle h=5 color='green' ; 
	symbol3  v=circle h=5 color='blue' ;
	plot x2*x1=cluster /annotate=indus_anno 
		description="Nuees dynamiques centre=w1,w4,w7" /* quand le souris est au dessus d'un pt la description s'affiche */
		name="fastclus"; /* nomme le graphique dans notre repertoire */
run;
quit;



/*         */
/* TP 1    */
/* Classif */
/* CHA     */
/* kmeans  */
/*         */

/* TP1 Classification Hiérarchique Ascendante et Nuées Dynamiques Données CNS */


/*
-------------------------------------------------------------
tp clustering sur cns
cluster(ascendante)
fastclust(nuee dyn)
-------------------------------------------------------------
*/

/* note : Les centres mobiles ou nuées dynamiques = k-means */

/* 2 Lecture et mise en forme des données */

/* 2.1 */
%let home=C:\Documents and Settings\e21numetu\Bureau\classif ;
/* ensuite &home pour ecrire le chemin */
%let idate=%sysfunc(datetime()) ;
%let date=%sysfunc(putn(&idate,datetime20.)); 

%put &idate ; 
%put &date ; 
/* 27FEB2014:09:43:28 */ 

/* 2.2 */
options user="&home" ; /* librairie utilisateur */
/* alias */
filename fichier "&home/cns.txt" ; 

/* 2.3 */
/*
-------------------------------------------------------------
format
-------------------------------------------------------------
*/
proc format ;
  value gr /* codage groupe */
    1='Alzheimer' 2='Pick' 3='Senile' 4='50-60' 5='>60';
run;

/* 2.4 */
/*
-------------------------------------------------------------
lecture
-------------------------------------------------------------
*/
data cns;
  infile fichier;
  label
         no = 'numero'
         groupe = 'groupe'
         an = 'astrocytes / neurones'
         on = 'oligodendrocytes / neurones'
         mn = 'microgliales / gliales'
         gn = 'gliales / neurones'
         ao = 'astrocytes / oligodendrocytes'
         statut = 'statut';
  input  no  groupe  an  on  mn  gn  ao  statut $ ;
   /* input no groupe an on mn gn ao statut$ : 7.; */  /* pour penser a dire que statut est une chaine de caractere */  
  format groupe gr.; /* on indique que la var groupe utilise le format gr */ 
run;

proc print data=cns;
run;


/* 3 Classification Hiérarchique Ascendante */
/*
-----------------------------------------
classification méthode de ward
-----------------------------------------
*/
/* 3.1 */ 
title 'Classification hierarchique sur donnees CNS'; /* Donner un titre a toutes les sorties */

/* 3.2 */
%let x=an; /* variable étudiée */
%let y=on; /* variable étudiée */
%let methode=ward; /* méthode utilisée */

/* 3.3 */ 
/* footnote justify=left "as &date" justify=right "&methode";  */
footnote justify=left 'M.B ' " &date " " &methode ";

/* 3.4 classification hiérarchique ascendante */
proc cluster data=cns method=&methode nonorm outtree=cns_tree plots=NONE; /* ne dessine rien */ 
  copy groupe; /* recopie la variable groupe dans la table de sortie */
  var &x &y; /* les variables an et on */
run;

/* 3.5 */
proc tree data=cns_tree nclusters=5 out=cns_classe;
  copy &x &y groupe;
run;

/* 3.6 dessiner les points correspondant aux individus dans le plan (an, on) */
/*
--------------------------------------------
graphique
--------------------------------------------
*/
/* 3.6.1 */
/* Creation de la table d'annotation */
data cns_anno;
	set cns;
	x=&x;y=&y;
	xsys='2'; ysys='2';
	format text $1.;
	text=groupe;
	function='label';
	label x="&x" y="&y"; 
	keep x y xsys ysys text function ; 
	run;

/* 3.6.2 */
/*
symbol1 color=blue   height=4 value='circle';
symbol2 color=red    height=4 value='circle';
symbol3 color=green  height=4 value='circle';
symbol4 color=yellow height=4 value='circle';
symbol5 color=purple height=4 value='circle';
*/
symbol1  value=circle height=4 color='red' ;
symbol2  v=circle h=4 color='green' ; 
symbol3  v=circle h=4 color='blue' ;
symbol4  v=circle h=4 color='purple' ;
symbol5  v=circle h=4 color='black' ; 

/* 3.6.3 */
proc gplot data=cns_classe;
  plot &y*&x=cluster /annotate=cns_anno 
	description="methode de &methode " /* quand le souris est au dessus d'un pt la description s'affiche */
	name="Utilisation de la methode de &methode"; /* nomme le graphique dans notre repertoire */
run;
quit;

/* 3.7 contingency */
proc freq data=cns_classe;
  tables cluster*groupe;
run;


/* 3.8 */ 
%macro clustcha (x,y,methode);

/* 3.3 */ 
/* footnote justify=left "AS &date" justify=right "&methode"; */
footnote 'M.B' &date &methode;

/* 3.4 classification hiérarchique ascendante */
proc cluster data=cns method=&methode outtree=cns_tree plots=NONE; /* ne dessine rien */ 
  copy groupe; /* recopie la variable groupe dans la table de sortie */
  var &x &y; /* les variables an et on */
run;

/* 3.5 */
proc tree data=cns_tree nclusters=5 out=cns_classe;
  copy &x &y groupe;
run;

/* 3.6 dessiner les points correspondant aux individus dans le plan (an, on) */
/* 3.6.1 */
/* Creation de la table d'annotation */
data cns_anno;
	set cns;
	x=&x;y=&y;
	xsys='2'; ysys='2';
	format text $1.;
	text=groupe;
	function='label';
	label x="&x" y="&y"; 
	keep x y xsys ysys text function ; 
run;

/* 3.6.2 */

symbol1  v=circle h=4 color='red' ;
symbol2  v=circle h=4 color='green' ; 
symbol3  v=circle h=4 color='blue' ;
symbol4  v=circle h=4 color='purple' ;
symbol5  v=circle h=4 color='black' ; 

/* 3.6.3 */

proc gplot data=cns_classe;
  plot &y*&x=cluster /annotate=cns_anno 
	description="methode de &methode " /* quand le souris est au dessus d'un pt la description s'affiche */
	name="Utilisation de la methode de &methode"; /* nomme le graphique dans notre repertoire */
run;
quit;

/* 3.7 contingency */
proc freq data=cns_classe;
tables cluster*groupe;
run;

%mend;

/* 3.9 */

%clustcha(an,on,ward);
%clustcha(an,on,single);
%clustcha(an,on,average);
%clustcha(an,on,complete);

title 'classification hierarchique sur cns';
%clustcha(x=&x,y=&y,methode=single);
%clustcha(x=&x,y=&y,methode=average);
%clustcha(x=&x,y=&y,methode=complete);
%clustcha(x=&x,y=&y,methode=ward);

/* 4 Nuées Dynamiques */
/*
-------------------------------------------------------------   
 nuees dynamiques 
-------------------------------------------------------------
*/
/* 4.1 */ 
title 'Classification nuees dynamiques sur donnees CNS';

/* 4.2 */ 
%let x=an;
%let y=on;

/* 4.3 */ 
/* footnote justify=left "as &date" justify=r 'nuees dynamiques'; */
footnote  "M.B  &date " ;

/* 4.4 */
PROC FASTCLUS DATA=cns 
	MAXCLUSTERS=5 /* nb max de class */
	maxiter=99 /* nb max d'iteration */
	mean=cns_mean /* sortie des centre de gravite des classe */ 
	out=cns_fastclus /* table de sortie */
	outstat=cns_fstat /* autres statistiques récupérées dans une table */ 
	outiter /* pour voire l'evolution des iteration */ 
	replace=random;  /* genere des centres aleatoires ou drift; ?? */
	VAR &x &y ; /* ou  var _numeric_ ; */
run;

/* 4.5 */ 
/* 4.5.1 */

data cns_anno;
	set cns;
	x=&x;y=&y;
	xsys='2'; ysys='2';
	format text $1.;
	text=groupe;
	function='label';
	label x="&x" y="&y"; 
	keep x y xsys ysys text function ; 
run;

/* 4.5.2 */
symbol1  v=circle h=4 color='red' ;
symbol2  v=circle h=4 color='green' ; 
symbol3  v=circle h=4 color='blue' ;
symbol4  v=circle h=4 color='purple' ;
symbol5  v=circle h=4 color='black' ; 

/* 4.5.3 */
proc gplot data=cns_fastclus;
  plot &y*&x=cluster /annotate=cns_anno 
	description="nuees dynamiques " 
	name="fastclus"; 
run;
quit;

/* 4.6 */ 
proc freq data=cns_fastclus;
tables cluster*groupe;
run;

/* 4.7 avec centre initiaux*/
data centre;
	set cns;
	select (_n_) ; /* _n_ indique le numero de ligne */ 
	when (10,20,30,40,50) output;
	otherwise;
	end;
run;


PROC FASTCLUS DATA=cns 
	MAXCLUSTERS=5 /* nb max de class */
	maxiter=99 /* nb max d'iteration */
	mean=cns_mean /* sortie des centre de gravite des classe */ 
	out=cns_fastclus /* table de sortie */
	outstat=cns_fstat /* autres statistiques récupérées dans une table */ 
	outiter /* pour voire l'evolution des iteration */
	seed=centre; /*table des centres initiaux */ 
	VAR &x &y ; /* ou  var _numeric_ ; */
run;

proc gplot data=cns_fastclus;
  plot &y*&x=cluster /annotate=cns_anno 
	description="nuees dynamiques " 
	name="fastclus"; 
run;
quit;


proc freq data=cns_fastclus;
  tables cluster*groupe;
run;

/* 4.8 */

%macro nueedyn (c1='',c2='',c3='',c4='',c5='');

title 'nuees dynamiques sur cns';

%if &c1='' %then %do; 
	/* 4.4 */
	PROC FASTCLUS DATA=cns 
		MAXCLUSTERS=5 /* nb max de class */
		maxiter=99 /* nb max d'iteration */
		mean=cns_mean /* sortie des centre de gravite des classe */ 
		out=cns_fastclus /* table de sortie */
		outstat=cns_fstat /* autres statistiques récupérées dans une table */ 
		outiter /* pour voire l'evolution des iteration */ 
		replace=random; /* genere des centres aleatoires */
		VAR &x &y ; /* ou  var _numeric_ ; */
	run;
%end;
%else %do;
	footnote  "M.B  &date methode : nuees dynamiques centres=centres=&c1,&c2,&c3,&c4,&c5" ;

	/* 4.7 avec centre initiaux*/
	data centre;
		set cns;
		select (_n_) ; /* _n_ indique le numero de ligne */ 
		when (&c1,&c2,&c3,&c4,&c5) output;
		otherwise;
	end;
	run;

	PROC FASTCLUS DATA=cns 
		MAXCLUSTERS=5 /* nb max de class */
		maxiter=99 /* nb max d'iteration */
		mean=cns_mean /* sortie des centre de gravite des classe */ 
		out=cns_fastclus /* table de sortie */
		outstat=cns_fstat /* autres statistiques récupérées dans une table */ 
		outiter /* pour voire l'evolution des iteration */
		seed=centre; /*table des centres initiaux */ 
		VAR &x &y ; /* ou  var _numeric_ ; */
	run;
%end;

data cns_anno;
	set cns;
	x=&x;
	y=&y;
	xsys='2'; ysys='2';
	format text $1.;
	text=groupe;
	function='label';
	label x="&x" y="&y"; 
	keep x y xsys ysys text function ; 
run;

symbol1  v=circle h=4 color='red' ;
symbol2  v=circle h=4 color='green' ; 
symbol3  v=circle h=4 color='blue' ;
symbol4  v=circle h=4 color='purple' ;
symbol5  v=circle h=4 color='black' ; 

	proc gplot data=cns_fastclus;
		plot &y*&x=cluster /annotate=cns_anno 
		description="nuees dynamiques " 
		name="fastclus"; 
	run;
	quit;

	proc freq data=cns_fastclus;
		tables cluster*groupe;
	run;

%mend nueedyn;


%nueedyn ();
%nueedyn(c1=5,c2=10,c3=15,c4=20,c5=25); 


/*
-------------------------------------------------------------
sorties
-------------------------------------------------------------
*/
/* pour des sorties graphique en pdf
   pb pour la taille des fontes */
goptions gsfname=pdfdir device=pdfc
         papersize=a4 rotate=portrait
         autosize=off htext=10pt
		 hsize=19cm vsize=27.7cm;


/* pour des sorties graphiques en postscript 
   meilleur gestion de la taille des fontes */
/*goptions gsfname=pdfdir device=pslepsfc
		 papersize=a4 rotate=portrait;*/

proc greplay igout=graphique nofs ;
    replay _all_;
run;
quit;
goptions reset=all;


/*         */
/* TP 2    */
/* Classif */
/*         */

/* TP2  Classifcation d’un grand fichier  bus et toulouse */

/* 1 Les données */

%let pdfdir=&home\pdf;
%let pdffile=&pdfdir\bustoulouse.pdf;
%let idate=%sysfunc(datetime());
%let date=%sysfunc(putn(&idate,datetime20.));
%let titre='Classification données Bus Toulouse';

%macro sortiedeb(type,fich);
%if &type='pdf' %then
  %do;
   ods listing close;
   ods printer pdf file="&fich";
  %end;
%mend;

%macro sortiefin(type);
%if &type='pdf' %then
  %do;
   ods printer close;
   ods listing;
  %end;
%mend;


/* Librairie utilisateur et taille des pages de sortie */
options user="&home" linesize=80 pagesize=66;  
title &titre;
footnote justify=left "AS &date";
filename  fichier  "&home\busrm.dat";
filename  pdfdir   "&pdfdir";
%let s='';
*%let s='pdf'; 
%sortiedeb(&s,&pdffile);proc print; run;


/* 1. Créer une librairie de travail par défaut*/ 
%let home=C:\Documents and Settings\e21numetu\Bureau\classif ; /* home directory */

/*2. Définir une table SAS bus à partir du fichier busrm.dat*/ 
options user="&home"; /*librairie utilisateur*/ 
filename bus "&home/busrm.dat"; /* alias sur le bus*/ 

/*3.*/ 
data bus0 ; 
	infile bus ; 
	input id$ CHUouFAC Ponsan Rocade Recollet JGuesde Esquirol Strasbg Bonrepos Matabiau ;
run;
proc print; run;

data bus1 ; 
	set bus0; 
	CHU_Pons=Ponsan-CHUouFAC; 
	Pons_Roc=Rocade-Ponsan;
	Roc_Rec=Recollet-Rocade;
	Rec_JGu=JGuesde-Recollet;
	JGu_Esq=Esquirol-JGuesde;
	Esq_Stra=Strasbg-Esquirol;
	Stra_Bon=Bonrepos-Strasbg;
	Bon_Mata=Matabiau-Bonrepos;
	keep id CHU_Pons Pons_Roc Roc_Rec Rec_JGu JGu_Esq Esq_Stra Stra_Bon Bon_Mata ; 
run ;
proc print; run;


/* 2 Choix du nombre de classes */ 

/* 2.1 FASTCLUS : classif centre mobile */

PROC FASTCLUS DATA=Bus1
	MAXCLUSTERS=28 /* nb max de class */
	mean=bus_mean /* sortie des centre de gravite des classes */ 
	out=bus_fastclus /* table de sortie */
	outstat=bus_fstat; /* autres statistiques récupérées dans une table */ 
VAR _numeric_ ; /* var CHU_Pons -- Bon_Mata ; */
run;

/* 2.2 Classification Ascendante Hierarchique */

proc cluster data=bus_mean method=ward outtree=bus_tree ; 
	id cluster;
	freq _freq_ ; /* contient les poids de nos classes obtenu precedement */
	var CHU_Pons Pons_Roc Roc_Rec Rec_JGu JGu_Esq Esq_Stra Stra_Bon Bon_Mata ; 
	/* var CHU_Pons--Bon_Mata; */ 
run;

/* 2.3 */
proc tree data=bus_tree ncl=28 out=bus_class;
run;

/* voir correction */
proc sort data=bus_tree;
  by _ncl_; 
run ;

data sprsq ; 
	set bus_tree ;
	by _ncl_ ;
	if first._ncl_ then output;
	keep _ncl_ _sprsq_ ;
run;

symbol1 interpol=join; 

proc gplot data=sprsq (where=(_ncl_>1 and _ncl_<10));
  plot _sprsq_*_ncl_; 
run;

goptions reset=all;
quit;


/* 3. Classification */

/* Classification ascendante hierarchique methode=ward
   sur les données brutes
*/

/* 3.1 K=5 */

proc cluster data=bus1 method=ward outtree=tree ; 
  var CHU_Pons Pons_Roc Roc_Rec Rec_JGu JGu_Esq Esq_Stra Stra_Bon Bon_Mata ; 
  copy id;
run;

proc sort data=tree;
  by _ncl_;
run;

proc tree data=tree ncl=5 out=class;
	copy CHU_Pons -- Bon_Mata ;
run;


proc sort data=class;
	by cluster;
run ;

/* calcule des centres de gravité */ 
proc means data=class;
	var CHU_Pons -- Bon_Mata ;
	by cluster;
	output out=poles;
run ;

/* récup des centre de gravité */
data poles(drop=_type_);
	set poles;
	if _stat_='MEAN';
run;

/* ACP et visualisation des résultats */
title "A.c.p. des donnees Bus Toulouse";

/* Acp de base de SAS */
proc princomp data=Bus1
	outstat=eltpr /*la table eltpr comprend des statistiques elementaires ainsi que les valeurs propres et vec propres unitaires*/
	out=compr; /*la table compr contient les coordonnees des individus sur les axes principaux*/
run;

proc print data=eltpr round noobs;run;
proc print data=compr round noobs;run;


/* dans eltpr 
mean et sd pour chaque ligne de bus
matrice de correlation 

eigenvalues of correlation matrix : valeurs propres
lambda1 : 2.45151512
lambda2 : 1.22597759 ... les autres sont <1

le coude est clairement a 2 

on utiliserai que les deux premiers axes

On a les vecteurs propres en dessous
*/

/* utiliser la macro ACP.sas */ 
%include "E:/MASTER1 MASS/S1/TPSAS/ACP/TP4_SAS_Macro_AnaDon_macro.sas";

%let dataset=Bus1;
%let ident=id;
%let listev=CHU_Pons -- Bon_Mata ;
%let q=3; /* nombre d'axe que je retiens par defaut */

%acp (&dataset,&ident,&listev);
/* Eboulis de valeurs propres */
%gacpsx();
/* Boxplot des axes */
%gacpbx();

/* Graphique des individus */
%gacpix(&ident); 
/* ax1 : ecart moy sur l'ens des differnces de trajet */
/* les ind tres a gauche ou tres a droite ont une moyenne de temps bien au dessus ou bien en dessous (sur l'axe 1) */ 
/* les inds a gauche : bien en dessous de la moyenne, trajet rapide, pas de bouchon, bonne circulation */

/* Graphique des variables avec cercle des correlations*/
%gacpvx();
/* tous est correlé dans le meme sens (positif) pour l'axe 1 : effet taille (sur les individu ils y en a qui ont de grandes valeurs pour l'ens des var et ils y en a qui ont des petites valeurs pour l'ens de var) ,
les vars en bas sont corrélé negativement pour l'axe 2 et celle en haut corr positivement .
*/ 
/* axe 2 : oppositions entre les deux temps de trajet extrems  */

/* detecter les ind aberants : dans le nuages de points, avec une tables d'annotation : mettre des couleurs pour identifier les regroupements */


/* code de la macro modifié pour afficher le nuage des individus avec leur num de classe et la couleur */

%acp (Class,cluster,&listev);
x=1,y=2,nc=4,coeff=1;

data anno;
        set coorindq;
		format color $8.;
        retain xsys ysys '2';
        style='swiss';
        y= prin2;
        x= prin1;
		function='label';
		text=substr(left(cluster),1,4);
		position='2';
        size=(cosca1+cosca2)+0.2;
	select (cluster);
		when(1) color='red' ;
		when(2) color='green' ; 
		when(3) color='blue' ;
		when(4) color='purple' ;
		when(5) color='black' ; 
	end;
	label y = "Axe 2" x = "Axe 1";
   		run;

 proc gplot data=anno;
        title;
        symbol1 v=none;
        plot y*x=1 / annotate=anno frame  href=0 vref=0;
 run;
 quit;
 goptions reset=all;


/* 3.2 Nuées dynamiques */ 

/* les poles de departs sont les 5 centres de gravité sortie dans la data Poles */

PROC FASTCLUS DATA=Bus1
	MAXCLUSTERS=5 /* nb max de class */
	seed=Poles /* sortie des centre de gravite des classes */
	out=ndclass(keep= id CHU_Pons -- Bon_Mata classe )/* table de sortie */
	mean=stat
	cluster=classe; 
VAR CHU_Pons -- Bon_Mata ;
run;

%acp (Bus1,classe,CHU_Pons -- Bon_Mata);

data anno;
        set coorindq;
		format color $8.;
        retain xsys ysys '2';
        style='swiss';
        y= prin2;
        x= prin1;
		function='label';
		text=substr(left(classe),1,4);
		position='2';
        size=(cosca1+cosca2)+0.2;
	select (classe);
		when(1) color='red' ;
		when(2) color='green' ; 
		when(3) color='blue' ;
		when(4) color='purple' ;
		when(5) color='black' ; 
	end;
	label y = "Axe 2" x = "Axe 1";
   		run;

 proc gplot data=anno;
        title;
        symbol1 v=none;
        plot y*x=1 / annotate=anno frame  href=0 vref=0;
 run;
 quit;
 goptions reset=all;


/*         */
/* TP noté */
/*         */
/***************************************
    Regression logistique
****************************************/

title "Regression logistique";
filename fichier1 "&home\pg.dat";
filename fichier2 "&home\pginc.dat";

data pg;
 infile fichier1 firstobs=3;
 input id$ taille gpe;
run;

data pginc;
 infile fichier2 firstobs=3;
 input id$ taille;
run;


proc logistic data=pg descending; /* la procedure de regression logistique
                                    les modalites de la variable categorielle 
                                    seront prises en ordre decroissant */
  model  gpe = taille ;            /* le model pour la regression */
  output out=sortie1 predprobs=(i);  /* sortie pour la table d'apprentissage 
                                       avec les probabilites d'appartenance 
                                       aux groupes */
  score  data=pginc out=sortie2; /* sortie pour la table a classer avec 
                                       les groupes d'affectation et les 
                                       probabilites correspondantes */
run;

/* affichage des résultats  */

title2 "Resultat pour les donnees d'origine";
proc print data=sortie1 ;
run;

title2 "Resultat pour les nouvelles donnees";
proc print data=sortie2 ;
run ;

data sortie; 
set sortie1 (keep=id taille gpe ip_1) sortie2(rename=(p_1=ip_1));
keep id taille gpe i_gpe ip_1;
run;

proc sort data=sortie;
by taille;
run;

data anno;
set sortie;
format color $8.;
format text $3.;
retain  xsys ysys '2';
select (gpe);
when (1) do;
  function='symbol'; x=taille;y=gpe;color='red';text='dot';size=1;output;
  function='symbol'; x=taille;y=ip_1;color='green';text='dot';size=1;output;
  end;
when (0) do;
  function='symbol'; x=taille;y=gpe;color='black';text='dot';size=1;output;
  function='symbol'; x=taille;y=ip_1;color='green';text='dot';size=1;output;
  end;
otherwise do;
  function='symbol'; x=taille;y=ip_1;color='blue';text='dot';size=1;output;
end;
end;
run;
  

title2 "individus groupe d'origine (noir rouge)";
title3 "proba gpe1 individus d'origine (vert), nouveau (bleu)";
proc gplot data=sortie;
symbol1 v=none  i=join ci=blue;
plot ip_1*taille/ annotate=anno vref=0.5 cvref='red';
run;
goptions reset=goptions;
quit;

/* pour les sortie pdf */
*ods printer close;
*ods html;



/**************/
/*            */
/*   FIN      */
/* MASTER M1  */
/* Semestre S2*/
/*            */
/**************/



/**************/
/*            */
/*   DEBUT    */
/* MASTER M2  */
/*            */
/**************/

/** Etude marketing **/

/* 
variable : 

- Lieu : Australie , Islande , Egypte , Bresil , Canada
- Activites : visiteLieuAtypique , croisiereBateauAquarium , restaurantDecouverteCulinaire  
- Services : massages , guide , navette , accesCentreAquatique
- Prix : 90 , 140 , 190 , 240 , 290  

nombre de concepts par plance : 5 pays
modalité maximum = 5
10 planches * 54 individus -> 6 blocks	*/

libname Marketing "C:\Documents and Settings\20902387.MATHETU\Bureau\Marketing";
option user=Marketing;

/* PLAN D'EXPERIENCE */
title 'Plan dexperience';
%mktruns(5 3 2 2 2 2 5 ) /* taille matrice design =60 une seule violation */
%mktex(5 3 2 2 2 2 5,n=300,seed=151)/* n doit etre multiple de 60 */
%Mkteval(data=work.randomized)
%mktblock(data=randomized,nalts=5,nblocks=6,factors=x1-x7,seed=151) 
/* dans explorateur, matrice Blocked : 
Block nous permet de ne présenter qu'une partie des 300 combinaisons possibles (au block 1 par exemple, on ne montre que  50 concepts differents)
Set correspond à l'écran que la personne voit,
Alt correspond a une alternative = un concept
et apres on a toutes les valeurs des 7 variables pour nous indiquer ce que verra la personne
*/


title 'Frozen Diet Entrees';
/* Nous aides a choisir le nombre de combinaisons produit ideale*/
%mktruns(3 3 3 2)
/*1er tableau : frequences
2e : Les plans que l'on peut choisir, tailles 18 et 36 seraient optimale
Nous pouvons contruire un design a 100% d'efficacité avec ces tailles; Divisible par 1,3,6 et 9.
3e : indique d'ou on peut sortir ces plans, reference veut dire qu'il existe deja un tableau d'ou on peut extraire pour realiser notre plan orthogonal
La macro nous indique que otre design, qui est désigné 2**1 3**7, cad 1 facteur a 2 niveaux et 7 facteurs a 3 niveaux */

/*%MKTex génère le design */
%mktex(3 3 3 2,n=108,seed=151)
/* 1er tableau : plan d'efficacité 100% 
Tab veut dire que %mktex a pu trouver le design dans un catalogue de tableaux orthogonaux. %mktex peut aussi avoir besoin de créer le design de façon algorithmique

%mktex va crer deux tableaux de données "Design" et "Randomized"
Design est trié et Randomized de façon aléatoire (par défaut)*/

%Mkteval(data=work.randomized)
/* %Mkteval vérifie la qualité du design. Verification design orthogonal et equilibré
Canonical correlations : idealement nous allons avoir une matrice identité -> cela veut dire que les facteurs(attributs) ne sont pas corrélés
Frequencies : on s'attend à avoir une fréquence équilibré (chaque attribut apparait le meme nombre de fois) */

/*%mktblock : va organiser le design en blocks - chaque repondant va avoir un seul block de taches */
%mktblock(data=randomized,nalts=2,nblocks=3,factors=x1-x4,seed=151) 
/*nalts=nb d'alternative(de concepts par ecran),nblocks= */
ODS html;
proc print; run;
ods html close;
/* La macro va créer un faceur de blocage qui est orthogonal à tous les attributs de toutes les alternatives.
En d'autres termes, la macro rajoute un facteur supplémentaire de manière optimale */

