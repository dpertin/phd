

\chapter{Conception de codes à effacement en géométrie discrète}

Nous avons vu dans le chapitre précédent que les codes à effacement
correspondent à des applications capables de fournir des informations
redondantes à partir d'un ensemble de données. Cette information redondante est
utilisée en cas de perte partielle des données afin de reconstruire
l'information perdue (réparation des données). Pour cela nous avons détaillé
une approche algébrique à travers l'étude des codes de
\textcite{reed1960jsiam}. Bien que ces codes soient optimaux au sens MDS, la
complexité des opérations d'encodage et décodage est trop élevée pour utiliser
ces techniques dans des applications qui ont des contraintes importantes de
performance.
Dans ce chapitre, une approche par géométrie discrète du problème de
reconstruction est utilisée afin de définir de nouvelles techniques d'encodage.
Nous verrons que ces techniques peuvent avoir des complexités moindres qu'en
utilisant la méthode algébrique vue précédemment.

En géométrie, la transformée de \textcite{radon1917akad} correspond une
application qui permet de représenter une fonction par ses projections suivant
différents angles. Notre objectif est de déterminer à partir de cette nouvelle
approche de nouveaux algorithmes d'inversion. En particulier, notre motivation
repose sur le fait que la transformée de \radon continue possède des liens
étroits avec la transformée de \fourier à travers le théorème de la tranche
centrale \cite{bracewell1956ajp}.

Puisqu'un code à effacement travaille sur des données numériques, la première
étape consiste à discrétiser la transformée de \radon, initialement définie
dans domaine continu \cite{radon1917akad}. Cette étude sera réalisée en
\cref{sec.reconstruction_discrete}. \matus sont parvenus à définir une version
discrète de la transformée de \radon, qui conserve toutes les propriétés de la
version continue \cite{matus1993pami}. En particulier, le théorème de la
tranche centrale permet d'atteindre la complexité de la transformée de Fourier
rapide FFT \cite{cooley1969tae}. Ces nouveaux algorithmes ouvrent donc la voie
vers des implémentations efficaces

%offrent ainsi de meilleures performances que les algorithmes

% d'inversion telles que proposés par les codes de

%\RS.

Plus particulièrement, nous verrons deux versions discrètes et exactes de la
transformée de \radon. La première mise en œuvre correspond à la transformée de
\radon finie (pour *Finite Radon Transform* ou FRT). Les projections de cette
application bouclent périodiquement sur le support étudié, ce qui lui permet de
fournir un code MDS \cite{normand2010wcnc}. L'algorithme d'inversion algébrique
ART proposé par \textcite{gordon1970jtb} permet de comprendre simplement
l'inversion en FRT. Nous verrons également une méthode plus efficace basée sur
la transformée de \fourier \cite{matus1993pami}. Ces différents éléments nous
permettront en \cref{sec.frt} de définir la FRT dans un contexte de code à
effacement.
\cref{sec.mojette} s'intéresse à la deuxième version discrète de la transformée
de \radon présentée dans cette thèse. Bien que la propriété apériodique des
projections Mojette empêche la conception d'un code à effacement MDS, elle
ouvre la voie à des algorithmes de reconstruction efficaces. Nous verrons en
particulier l'algorithme de \textcite{normand2006dgci}. Avec la définition du
critère d'unicité de la solution de reconstruction, cette méthode d'inversion
formera la base de notre conception de code à effacement.
Au travers de ces deux version, nous porterons une attention particulière
la définition des *fantômes* qui sont des éléments de l'image invisible dans
l'espace de transformée. Ces fantômes nous permettront non seulement de
comprendre les processus d'inversion dans ce chapitre, mais seront également
utilisés au \cref{sec.reprojection} afin de concevoir une méthode pour
générer de nouvelles projections.



# Discrétisation de la transformée de \radon continue
\label{sec.reconstruction_discrete}

La transformée de \radon est une application linéaire permettant de représenter
une fonction par ses projections suivant différents angles. L'opération inverse
consiste à reconstruire la fonction à partir des valeurs de projections.
Cette transformée permet de résoudre le problème de tomographie. La tomographie
correspond à un problème inverse qui consiste à reconstruire un
objet à partir de mesures, appelées projection, prises de celui-ci. En
conséquence, cette technique permet la visualisation et le stockage d'une
version numérique de l'objet.

Dans le milieu médical, il faudra attendre $1972$ avant que
\citeauthor{hounsfield1973bjr} ne parvienne à concevoir le premier scanner à
rayon X, sans pour autant qu'il n'est eu au préalable connaissance des travaux
de \radon. Il remportera le prix Nobel de médecine en $1979$ avec
\citeauthor{cormack1963jap} pour leurs travaux respectifs sur le développement
de la tomographie numérique \cite{cormack1963jap, hounsfield1973bjr}. Cette
technique, largement répandue dans le milieu médical, a également été utilisée
en astronomie par \textcite{bracewell1956ajp}, en géophysique ou encore en
mécanique des matériaux.
L'originalité de notre approche dans cette thèse est d'utiliser cette
technique, non pas pour la reconstruction en imagerie, mais pour concevoir des
codes à effacement qui seront à terme utilisés dans la transmission et le
stockage d'information. Ce chapitre a pour but d'expliquer cette conception.

Nous débuterons cette partie en introduisant en \cref{sec.radon} la transformée
de \radon continue telle que définie par \textcite{radon1917akad}.
Afin de comprendre comment discrétiser cette transformée, quelque notions de
géométrie discrète seront définies par la suite, en \cref{sec.geometrie}. Enfin
nous verrons une première approche du problème de tomographie discrète avec
un exemple en \cref{sec.inverse} présentant une méthode de résolution
algébrique.


## Transformée de \radon dans le domaine continu {#sec.radon}

La transformée de \radon est une application qui répond au problème de la
tomographie. Nous introduirons dans un premier temps ce problème dans un
contexte pratique : l'imagerie médicale. Nous verrons ensuite la définition de
la transformée de \radon dans le domaine continu, telle que définie dans les
travaux fondamentaux de \textcite{radon1917akad}.

### Problème de la tomographie

\begin{figure}
    \centering
    \begin{subfigure}{.43\textwidth}
		\centering
        \def\svgwidth{.6\textwidth}
		\includesvg{img/inverse0}
        \caption{Exemple d'une projection}
        \label{fig.inverse1}
    \end{subfigure}
    \begin{subfigure}{.43\textwidth}
		\centering
        \def\svgwidth{.6\textwidth}
		\includesvg{img/inverse1}
        \caption{Rétroprojection de $1$ projection}
        \label{fig.inverse2}
    \end{subfigure}
	\begin{subfigure}{.43\textwidth}
		\centering
        \def\svgwidth{.6\textwidth}
		\includesvg{img/inverse22}
        \caption{Rétroprojection de $2$ projections}
        \label{fig.inverse3}
    \end{subfigure}
    \begin{subfigure}{.43\textwidth}
		\centering
        \def\svgwidth{.6\textwidth}
		\includesvg{img/inverse32}
        \caption{Rétroprojection de $3$ projections}
        \label{fig.inverse4}
    \end{subfigure}
    \caption{Représentation des différentes étapes en tomographie.
    \Cref{fig.inverse1} représente une étape l'acquisition des données par
    la projection des deux formes de l'image sur l'horizontal.
    \Cref{fig.inverse1,fig.inverse2,fig.inverse3,fig.inverse4} représentent
    itérativement la rétroprojection des données.}
    \label{fig.inverse}
\end{figure}


En imagerie médicale, le problème de la tomographie correspond à un problème
inverse qui consiste à reconstituer une image à partir d'un ensemble de
projections mesurées sur l'image. On distingue alors deux processus dans la
résolution de ce problème : *l'acquisition* des données et la *reconstruction*
de l'image. Ces deux processus sont représentés en \cref{fig.inverse} sur
laquelle sont présentées les différentes étapes d'une tomographie, appliquée
sur une image composée de deux disques.

L'acquisition met en jeu la rotation d'un capteur qui mesure des projections 1D
autour d'une zone du patient. Cette technique est notamment utilisée dans les
scanners à rayons X. Ces appareils envoient une série de rayons X à travers le
patient à différents angles. Les récepteurs situés de l'autre côté du patient
mesurent alors l'absorption de ces rayons par les tissus organiques. Il est
alors possible de déterminer le volume de tissu traversé par ces rayons. Une
étape de l'acquisition est représentée \Cref{fig.inverse1}. Elle correspond à
la mesure suivant la direction horizontale. L'émetteur situé à gauche envoie
des rayons en parallèles (d'autres cas cas où les rayons sont émis en éventail
ou en cône existent, mais ne sont pas traités ici) et permet au capteur situé à
droite de mesurer l'empreinte des deux formes étudiées.

Une fois l'acquisition terminée, un traitement informatique permet de
reconstruire une coupe des structures anatomiques du patient, par une opération
inverse. Une technique pour reconstruire cette image consiste à rétroprojeter
la valeur des projections dans le support à reconstruire. Si l'on ne dispose
pas de suffisamment de projections, alors l'ensemble des solutions possibles
peut être significativement grand (voire infini) et il est impossible de
déterminer une solution unique.
Plusieurs itérations de l'opération de rétroprojection sont représentées de
\cref{fig.inverse1,fig.inverse2,fig.inverse3}. Plus particulièrement,
\cref{fig.inverse2} montre que l'ensemble de solution est infini lorsque l'on
utilise qu'une projection. Plus on utilise de projections, plus l'ensemble de
solutions se réduit, comme le montre \cref{fig.inverse3} qui met en jeu une
seconde projection. Pour finir, si suffisamment de projections sont utilisées,
on parvient à déterminer une unique solution qui correspond à l'image initiale.
C'est le cas représenté par \cref{fig.inverse4} en utilisant trois
projections. Lorsque nous étudierons la conception de codes à effacement, nous
serons amenés à fournir des critères déterministes sur le nombre de projections
nécessaires afin de garantir un processus de reconstruction qui puisse aboutir
à une solution unique.


### Transformation de \radon

\begin{figure}
    \centering
    \def\svgwidth{.7\textwidth}
    \includesvg{img/radon3}
    \caption{Représentation de la transformée de \radon $r[f](\varphi)$ de
    l'objet $f(x,y)$ suivant l'angle de projection $\varphi$.}
    \label{fig.radon}
\end{figure}

\radon définit les bases mathématiques de sa transformée dans ses travaux
fondamentaux de \citeyear{radon1917akad} comme une application mathématique
linéaire $r : f \mapsto t$ qui consiste à calculer une fonction $r(\varphi,t)$
de $\mathbb{R}$ (appelée projection) à partir d'une fonction $f(x,y)$ de
$\mathbb{R}^2$ dans $\mathbb{R}$, où $\varphi$
correspond à l'angle de projection, et $|t|$ correspond à la distance de la
droite de projection avec l'origine \cite{radon1917akad}.
Soit $P$ un point du plan, de coordonnées $(x,y)$, et $\mathcal{L}$
la droite de projection passant par ce point, d'équation $t = x \cos \varphi +
y \sin \varphi$. La transformée de \radon $r_{f}(\mathcal{L})$ de la fonction
$f(x,y)$ de $\mathbb{R}^2$ sur $\mathbb{R}$ par rapport à la droite de
projection $\mathcal{L}$, est définie ainsi :

\begin{equation}
    r_{f}(\mathcal{L}) =
        \int_{\mathcal{L}}f(x,y)\,d\ell,
    \label{eqn.integrale_curviligne}
\end{equation}

où $d\ell$ correspond aux variations le long de la droite $\mathcal{L}$.
\Cref{eqn.integrale_curviligne} permet de calculer l'intégrale sur l'ensemble
des points $(x,y)$ de densité $f(x,y)$ appartenant à la droite $\mathcal{L}$
d'équation $t = x \cos \varphi + y \sin \varphi$ (i.e.\ l'intégrale curviligne
le long de $\mathcal{L}$). En utilisant la distribution de Dirac
$\delta(\cdot)$, on peut définir la transformée de Radon ainsi :

\begin{equation}
    r_{f}(\varphi,t) =
        \int_{-\infty}^{\infty}
        \int_{-\infty}^{\infty}
        f(x,y) \delta (t - x \cos(\varphi) - y \sin(\varphi))\,dx\,dy,
    \label{eqn.radon}
\end{equation}

\Cref{eqn.radon} représente la projection de la fonction $f(x,y)$ suivant la
droite $\mathcal{L}$ sur une droite orthogonale à $\mathcal{L}$. La valeur
obtenue correspond à l'intensité cumulée le long de la droite d'acquisition. Le
principe de cette transformée est représentée en \cref{fig.radon}.

La seconde étape en tomographie consiste à inverser l'opération précédente.
Cette opération inverse consiste à reconstruire $f$ à partir de l'ensemble des
projections mesurées à partir de \cref{eqn.radon}.  \textcite{radon1917akad} a
prouvé dans ses travaux qu'il était possible de reconstruire $f$ en utilisant
le théorème de la tranche centrale.
Cependant, il existe trois raisons pour lesquelles la reconstruction par
transformée de \radon est un *problème mal posé*, au sens défini par
\textcite{hadamard1902pub} : (i) la solution ne peut être retrouvée puisque les
mesures réalisées lors de l'acquisition intègre du *bruit* dans les données;
(ii) il n'est de plus pas possible de garantir l'*unicité* de la solution
puisque l'acquisition mesure un nombre fini de projections; (iii) de part la
nature physique des capteurs, les données correspondent à un échantillon de
l'image, caractérisé par la distance des capteurs (dans le cas d'une étude
géométrique parallèle). Enfin, une petite erreur d'acquisition entraîne de
fortes variations des résultats.

\begin{figure}
    \centering
    \def\svgwidth{.7\textwidth}
    \includesvg{img/interpolation}
    \caption{L'inversion de la transformée de \fourier rapide nécessite 
    l'interpolation de la grille polaire obtenue par le théorème de la tranche
    centrale, à la grille cartésienne.}
    \label{fig.interpolation}
\end{figure}

% contenu sur le problème d'interpolation (p62 riton)

Bien que la transformée de \radon inverse peut être définie en utilisant la
transformée de \fourier, une des principales limitations de cette méthode dans
le domaine continu correspond à l'interpolation de la grille polaire à la
grille cartésienne dans le domaine de \fourier.
Dans ce chapitre, nous présenterons des versions exactes et discrètes de la
transformée de \radon. Par versions "exactes", nous entendons que ces versions
sont basées sur un échantillonnage optimal, ce qui permet de ne pas avoir à
réaliser d'interpolation. On considère un échantillonnage optimal ou complet,
lorsque les projections couvrent uniformément l'ensemble des éléments de
l'image.
Ces versions discrètes correspondent à des méthodes capable de représenter et
de reconstruire la version numérique d'une fonction par ses projections
discrètes. En particulier, nous verrons des mises en œuvre pratiques et
efficaces capables de fournir une représentation redondante de l'image, afin de
reconstruire la donnée quand elle est partiellement perdue.


## Quelques bases de la géométrie discrète {#sec.geometrie}

Le procédé permettant de transformer des éléments continus en éléments
discrets, est appelé *discrétisation* (ou *numérisation*). Il est ainsi
possible de transformer une fonction continue $f:\mathbb{R}^2 \rightarrow
\mathbb{R}$ en une fonction discrète $f:\mathbb{Z}^2 \rightarrow \mathbb{Z}$.
Pour cela nous devons au préalable définir quelques notions de géométrie
discrète décrites par \textcite{coeurjolly2007chap1}. Nous étudierons dans un
premier temps les aspects topologiques qui nous permettront de comprendre la
représentation discrète de l'image à reconstruire. Par la suite, nous verrons
quelques objets relevant de la géométrie discrète, comme les angles et les
droites, qui nous permettront de définir les droites de projection dans cette
étude.


### Notions topologiques : pavage et connexité dans le domaine discret

\begin{figure}
    \centering
    \def\svgwidth{\textwidth}
    \includesvg{img/pavages}
    \caption{Représentation des trois pavages réguliers possibles sur
    $\mathbb{Z}^2$ (carré, triangle, hexagone). Le maillage de chaque pavage
    est représenté en gris clair. Extrait de \cite{coeurjolly2007chap1}}
    \label{fig.pavage}
\end{figure}

Un espace discret $\mathbb{Z}^n$ est une décomposition du plan de dimension
$n \geq 2$ en *cellules*. L'ensemble de ces cellules forment un *pavage*.
Une cellule peut être représentée par son centre de gravité, que l'on appelle
*point discret*. L'ensemble des points discrets d'un pavage forme un
*maillage*, qui correspond à la forme dual du pavage. Par la suite, on
travaillera sur des pavages vérifiant les trois propriétés suivantes :

1. pavages réguliers : les cellules correspondent à des formes régulières
(i.e.\ des polygones dont tous les côtés et tous les angles sont égaux) et dont
les sommets sont en contact avec un nombre fini de sommets appartenant à
d'autres cellules (ce qui remplit l'espace sans recouvrement);

2. de dimension $2$, c'est à dire que l'image correspond à une partie
de $\mathbb{Z}^2$ (par la suite, on pourra utiliser le terme *pixel* pour
désigner les cellules);

3. dont les cellules sont facilement adressables, pour cela on utilisera un
pavage carré afin d'adresser directement les éléments par un couple de
coordonnées $(x,y)$ (le maillage d'un pavage carré est carré contrairement au
maillage d'un pavage triangulaire ou hexagonal).

\noindent Par la suite, nous utiliserons un pavage carré semblable à celui
représenté en \cref{fig.pavage}. On considèrera également une distribution
d'intensité $f:\ZZ^2 \mapsto \RR$ de telle manière que les cellules d'un pavage
sont affectées à une valeur. Les images numériques par exemple,
correspondent à la distribution d'une intensité lumineuse.

Les notions topologiques dans le domaine discret sont définies à partir de la
notion de *voisinage* et de *connexité* \cite{rosenfeld1970acm,
rosenfeld1979tamm}. Soient $P$ et $Q$, deux points définis par leurs
coordonnées $(x,y)$ dans un pavage carré. Dans ce cas, $P$ et $Q$ sont deux
points voisins si une et une seule de leurs coordonnées diffère d'une unité. En
particulier, le point $P$ possède quatre voisins qui correspondent aux points
de coordonnées $(x-1,y),(x+1,y),(x,y-1),(x,y+1)$. Dans ce cas, on parle de
*$4$-connexité*.
La définition de la connexité permet de définir ce qu'est un *chemin*. Un
chemin correspond à une suite de points de telle manière que deux points
consécutifs de ce chemin soient voisins.

Pour finir, on définit une *composante connexe* comme étant un ensemble $S$ de
points discrets tel que pour tout couple de points $(P,Q)$ appartenant à $S$,
il existe un chemin reliant $P$ à $Q$ dont tous les points appartiennent à $S$.


### Angle et droite discrète {#sec.angles}

\begin{figure}
    \centering
    \begin{subfigure}{.19\textwidth}
		\centering
		\includesvg{img/angles1}
        \caption{$\frac{q}{p}=\frac{0}{1}$}
        \label{fig.farey1}
    \end{subfigure}
    \begin{subfigure}{.19\textwidth}
		\centering
		\includesvg{img/angles2}
        \caption{$\frac{q}{p}=\frac{1}{3}$}
        \label{fig.farey2}
    \end{subfigure}
	\begin{subfigure}{.19\textwidth}
		\centering
		\includesvg{img/angles3}
        \caption{$\frac{q}{p}=\frac{1}{2}$}
        \label{fig.farey3}
    \end{subfigure}
    \begin{subfigure}{.19\textwidth}
		\centering
		\includesvg{img/angles4}
        \caption{$\frac{q}{p}=\frac{2}{3}$}
        \label{fig.farey4}
    \end{subfigure}
    \begin{subfigure}{.19\textwidth}
		\centering
		\includesvg{img/angles5}
        \caption{$\frac{q}{p}=\frac{1}{1}$}
        \label{fig.faray5}
    \end{subfigure}
    \caption{Représentation des différents angles discrets $(p,q)$ qui
    composent la suite de Farey $F_3$. Cette suite permet de définir l'ensemble
    des angles possibles dans $[0,\frac{\pi}{4}]$ pour un pavage $(3 \times
    3)$.}
    \label{fig.farey}
\end{figure}

Les définitions topologiques précédentes nous permettent d'introduire certaines
représentations discrètes, comme les angles et droites. Dans cette section, on
s'intéresse à déterminer les points d'intersection entre le maillage défini par
les points d'un ensemble discret de taille $(N \times N)$, et une droite
d'équation $y = ax + b$. Pour que cette intersection ne soit pas vide, il est
nécessaire que la pente de la droite soit de la forme :

\begin{equation}
    0 \leq \frac{q}{p} \leq 1,
    \label{eqn.pente_droite}
\end{equation}

avec $p,q \in \ZZ$ et où $p$ et $q$ sont des entiers premiers entre eux,
vérifiant $q \leq p \leq N$. L'ensemble des pentes des droites possibles défini
par \cref{eqn.pente_droite} sur $[0,\frac{\pi}{4}]$ forment une suite de
Farey d'ordre $N$, notée $F_N$ \cite{franel1924gdwg}. Les autres droites sont
obtenues par symétrie. Une suite de Farey $F_N$ est l'ensemble des fractions
irréductibles comprises entre $0$ et $1$, ordonnées de manière croissante et
dont le dénominateur n'est pas plus grand que $N$.
Chaque fraction d'une suite de Farey correspond à un vecteur $[p,q]$ de
$\mathbb{Z}^2$. En particulier, \citeauthor{minkowski1968geometrie} a montré
que si l'on considère deux vecteurs de Farey consécutifs de $F_N$, alors il ne
peut y avoir de point dans le parallélogramme formé par ces deux vecteurs
\cite{minkowski1968geometrie}. Par exemple, la suite de Farey d'ordre $3$
permet d'obtenir l'ensemble des points pentes possibles pour un pavage de
$(3 \times 3)$, et correspond à :

\begin{equation}
    F_3 = \left\{
        \frac{0}{1},
        \frac{1}{3},
        \frac{1}{2},
        \frac{2}{3},
        \frac{1}{1}
    \right\}.
    \label{eqn.farey}
\end{equation}

\Cref{fig.farey} représente de manière géométrique les droites issues des
pentes générées par $F_3$ dans un pavage carré de taille $(3 \times 3)$.
Visuellement, une direction $(p,q)$ correspond à la droite reliant le point
d'origine avec le point obtenu par un décalage horizontal de $p$, et par un
décalage vertical de $q$.

Dans la suite de nos travaux, nous utiliserons le terme *direction discrète*
pour désigner le couple d'entier $(p,q) \in \mathbb{Z}^2$, premiers entre eux,
correspondant à la direction de la droite de pente $\frac{q}{p}$. Cette
définition des angles discrets sera nécessaire lorsque l'on définira des
versions discrètes de la transformée de \radon (\cref{sec.frt,sec.mojette}).


## Méthode algébrique de reconstruction d'une image discrète {#sec.inverse}

\begin{figure}
    \centering
    \begin{subfigure}{.48\textwidth}
		\centering
        \def\svgwidth{\textwidth}
        \includesvg{img/inverse_discret_nok2}
        \caption{Exemple non inversible}
        \label{fig.inverse_discret_nok}
    \end{subfigure}
    \begin{subfigure}{.48\textwidth}
		\centering
        \def\svgwidth{\textwidth}
        \includesvg{img/inverse_discret_ok2}
        \caption{Exemple inversible}
        \label{fig.inverse_discret_ok}
    \end{subfigure}

    \caption{Exemple de deux représentations d'une image discrète $(2 \times
    2)$ par un ensemble allant deux à quatre projections, calculées suivant les
    directions $(p,q) = \{(0,1),(1,1),(0,1),(-1,1)\}$. La valeur des
    projections correspond à la somme des valeurs des pixels (représentées par
    les lettre $\{a,b,c,d\}$) traversés par la droite de projection.}
    \label{fig.inverse_discret}
\end{figure}

Nous allons dans cette section utiliser une approche algébrique afin
d'introduire le processus de reconstruction d'une image discrète, à partir d'un
ensemble de projections obtenues à différents angles discrets.
\Cref{fig.inverse_discret} représente une image discrète composée de
quatre pixels identifiés par leurs valeurs $\{a,b,c,d\}$. Dans cet
exemple, les valeurs des projections correspondent à la somme des valeurs des
pixels traversés par les droites de projections. Deux considérations sont alors
à prendre : (i) est-il possible de déterminer de manière unique la solution du
problème ? (ii) quelle méthode utiliser pour reconstruire cette solution
efficacement ?

Ce problème peut être vu comme un problème d'algèbre linéaire. Dans
cette représentation, les pixels de l'image forment les inconnus à reconstruire
tandis que les projections correspondent aux équations linéaires. Dans
l'exemple proposé en \cref{fig.inverse_discret_nok}, on souhaite représenter
l'image par ses projections verticales et horizontales. Posons le problème sous
la forme d'un système d'équations linéaires à $4$ équations et $4$ inconnues
auquel des valeurs ont été affectées aux projections :

\begin{equation}
    \left\{
    \begin{array}{cc}
            a + b &= 5\\
            c + d &= 5\\
            a + c &= 4\\
            b + d &= 6
    \end{array}
    \right .
    \label{eqn.système}
\end{equation}

On peut écrire ce système d'équations linéaires sous la forme matricielle :
$\textbf{A}x=b$, où $\textbf{A}$ est la matrice de projection $(4 \times 4)$,
$x$ est un vecteur colonne à quatre inconnus et $b$ contient les valeurs des
projections. Cela correspond à la multiplication matricielle suivante :

\begin{equation}
    \begin{pmatrix}
        1 & 1 & 0 & 0\\
        0 & 0 & 1 & 1\\
        1 & 0 & 1 & 0\\
        0 & 1 & 0 & 1
    \end{pmatrix}
    %
    \begin{pmatrix}
        a \\ b \\ c \\ d
    \end{pmatrix} =
    %
    \begin{pmatrix}
        5 \\ 5 \\ 4 \\ 6
    \end{pmatrix}
    \label{eqn.ensemble_nok}
\end{equation}

Dans cet exemple, la matrice $\textbf{A}$ n'est pas inversible (son déterminant
est nul). En effet seulement trois équations du système sur quatre sont
indépendantes. En effet, la somme de la première équation avec la
deuxième est égale à la somme de la troisième avec la quatrième. En
conséquence, la reconstruction depuis ces projections fournit une infinité de
solutions, tant que la valeur d'un pixel n'est pas connu. Autrement dit,
l'ensemble des projections mesurées n'est pas suffisant pour déterminer de
manière unique une solution.
En revanche, un ensemble de projections suffisant est représenté en
\cref{fig.inverse_discret_ok}. Dans cet exemple, on rajoute deux nouvelles
mesures suivant les directions des diagonales. En conséquence, on obtient un
système surdéterminé que l'on peut représenter sous forme matricielle :

\begin{equation}
    \begin{pmatrix}
        1 & 1 & 0 & 0\\
        0 & 0 & 1 & 1\\
        1 & 0 & 1 & 0\\
        0 & 1 & 0 & 1\\
        1 & 0 & 0 & 1\\
        0 & 1 & 1 & 0
    \end{pmatrix}
    %
    \begin{pmatrix}
        a \\ b \\ c \\ d
    \end{pmatrix} =
    %
    \begin{pmatrix}
        5 \\ 5 \\ 4 \\ 6 \\ 3 \\ 7
    \end{pmatrix}
    \label{eqn.ensemble_ok}
\end{equation}

Le système comporte à présent $4$ inconnus pour $6$ équations. On est capable
de déterminer de manière unique une solution de reconstruction à travers la
méthode suivante :

\begin{align}
    \textbf{A} x &= b,\\
    \textbf{A}^{\intercal} \textbf{A} x &= \textbf{A}^{\intercal} b,\\
    x &= [\textbf{A}^{\intercal}\textbf{A}]^{-1} \textbf{A}^{\intercal} b,
    \label{eqn.art}
\end{align}

ce qui donne $(a=1, b=4, c=3, d=2)$. Bien que cette méthode fonctionne, elle
n'est pas efficace. D'une part, pour déterminer l'unicité de la solution, il
faut calculer le déterminant de la matrice $[\textbf{A}^{\intercal}
\textbf{A}]$. La complexité de ce calcul est de $\mathcal{O}(n!)$ pour une
matrice carrée de taille $n$ par la méthode de \textsc{Laplace}. Il faut
ensuite inverser cette matrice en utilisant par exemple la méthode de
\textsc{Gauss-Jordan}, dont la complexité est $\mathcal{O}(n^3)$. Enfin, pour
déterminer les valeurs de $x$, une multiplication matricielle est nécessaire
(voir \cref{eqn.art}) dont la complexité est $\mathcal{O}(n^3)$ également.

Dans la suite de ce chapitre, nous détaillerons deux versions discrètes et
exactes de la transformée de \radon : la FRT et la transformée Mojette
(respectivement \cref{sec.frt,sec.mojette}). Plus particulièrement, ces
transformées vont nous servir à deux choses : (i) elles vont permettre de
définir des critères simples permettant de déterminer l'unicité de la solution
de reconstruction: (ii) l'approche géométrique va permettre de définir des
algorithmes de reconstruction efficaces qui n'ont jamais été définis en théorie
des codes.


# Code optimal par transformée de \radon finie {#sec.frt}

Nous avons vu dans la partie précédente que la transformée de \radon
constitue un outil mathématique capable de résoudre le problème inverse.
Cependant, puisque les ordinateurs ne sont pas capable de travailler sur des
ensembles d'éléments continus, il est nécessaire de définir une version
discrète de cette application.

Cette partie présente une version discrète et exacte de la transformée de
\radon, proposée à l'origine par \matus \cite{matus1993pami}. La particularité
de cette version est de considérer un support discret périodique. Ils ont
montré que cette propriété permet de construire un nombre fini de projections,
et que cet ensemble garantit l'unicité de la solution de reconstruction. Nous
verrons en particulier la mise en œuvre de cette transformée à travers la
méthode de calcul des projections, puis de reconstruction de l'image en
\cref{sec.frt-intro}. \cref{sec.fantome} apportera la définition
géométrique des fantômes, qui sont des éléments de l'image générés lorsqu'une
projection est manquante. Les fantômes ne sont pas spécifiques à la
FRT, aussi nous les réutiliserons pour la transformée Mojette
(\cref{sec.mojette}), et le calcul de nouvelles projection
(\cref{sec.reprojection}). En particulier, nous verrons un algorithme de
reconstruction proposé par \citeauthor{chandra2012tip} afin de supprimer ces
fantômes et reconstruire la donnée \cite{chandra2008icpr, chandra2012tip}. 
Cet algorithme nous permettra de concevoir un code à effacement. L'étude de la
FRT a sa place dans ce travail de thèse puisque sa périodicité permet de
fournir un code à effacement MDS. Nous verrons par ailleurs que
\textcite{normand2010wcnc} ont montré cela par une approche algébrique.


## Transformée de \radon finie {#sec.frt-intro}


### Transformée de \radon finie directe

\begin{figure}
    \centering
    \def\svgwidth{.5\textwidth}
    \includesvg{img/frt}
    \caption{Représentation des trois pavages réguliers possibles sur
    $\mathbb{Z}^2$ (carré, triangle, hexagone). Le maillage de chaque pavage
    est représenté en gris clair.}
    \label{fig.frt_line}
\end{figure}

%avant d'être étendue par \citeauthor{svalbe2001laa} 

%\cite{matus1993pami, svalbe2001laa}.

La transformée de \radon finie, pour *Finite Radon Transform* (FRT), est une
version discrète, exacte et périodique de la transformée de \radon continue,
définie mathématiquement par \textcite{matus1993pami}. Elle calcule la
projection $R(m,t)$ d'une fonction discrète $f:\ZZ^2 \mapsto \RR$ qui
correspond à un pavage carré $(p \times p)$, en sommant la valeur des pixels
tel que :

% $$ \left \{

\begin{align}
    R(m,t)  &= \sum_{x=0}^{p-1} \sum_{y=0}^{p-1} f(x,(mx + t) \pmod{p}),
    \label{eqn.frt}\\
    R(p,t)  &= \sum_{x=0}^{p-1} \sum_{y=0}^{p-1} f(t, y),
    \label{eqn.frt_p}
\end{align}

% \right. $$

où $0 \leq m < p$ et $x,y,m,y \in \mathbb{Z}$. La variable $t$ correspond à
l'index de translation de la projection suivant l'axe des $y$
(i.e.\ la verticale) tandis que $m$ représente la pente de la droite de
projection. En particulier, \cref{eqn.frt} contient un opérateur modulo qui
permet de rendre les lignes de l'image périodique de période $p$.

Chaque projection indexée par $m$ contient $p$ valeurs correspondant à un
décalage de $t$ suivant l'axe des $y$. \Cref{fig.frt_line} représente l'une de
ces mesures pour la droite d'équation $y \equiv 2 x \pmod 5$ sur un pavage
carré défini par $p=5$. Dans le cas général, ces droites de projection ont pour
équation :

\begin{equation}
    y \equiv m x + t \pmod p.
    \label{eqn.frt_line}
\end{equation}

\textcite{matus1993pami} ont montré que les $(p+1)$ projections définies aux
\cref{eqn.frt,eqn.frt_p} permettent d'avoir un échantillonnage optimale de
l'image. En effet puisque $p$ est premier, une projection permet de parcourir
l'ensemble des pixels une et une seule fois. En conséquence, la somme des
valeurs d'une projection correspond à la somme des pixels $I_{sum}$.

\Cref{fig.frt} montre la FRT d'une image $(3 \times 3)$ dans laquelle la valeur
des pixels correspond à des lettres. En particulier, la projection $R(m=2,t=0)$
est représentée en rouge. La valeur de cette projection correspond à la somme
des éléments de l'image en partant de $a$ (i.e.\ $t=0$) et en se décalant de
$m=2$ pixels sur la droite quand on descend d'une ligne (la pente
m=$\frac{q}{p}=\frac{2}{1}$). On remarque sur la troisième ligne l'effet
périodique du support, ainsi que le retour sur le pixel $a$ à l'itération
suivante.
\citeauthor{matus1993pami} ont montré qu'il est nécessaire de calculer $(p+1)$
projections afin de pouvoir reconstruire l'image. Dans la suite, nous
détaillons une méthode de reconstruction de l'image algébrique.



### FRT inverse par reconstruction algébrique

\begin{figure}
	\centering
	\input{tikz/frt.tex}
	\caption{Représentation de la FRT et de son inverse. (a) on applique la
	FRT sur une image $3\times3$ (i.e. $p=3$). Les valeurs des pixels sont
	symboliques : 9 pixels prennent des valeurs ${a, b,\dots, i}$. (b)
	correspond au résultat de la transformée, c'est à dire les $p+1=4$
	projections. Un exemple de calcul est ici représenté en pointillé rouge.
	Il s'agit du calcul de FRT pour $t=0$ et $m=2$ (i.e. la pente vaut deux).
	On désigne $afh$ comme étant la somme $a+f+h$. (c) représente la
	reconstruction de l'image par la FRT$^{-1}$. Chaque élément reconstruit
	est la somme de $p$ fois la valeur initial du pixel avec
	$I_{sum}=a+b+\dots+i$.}
	\label{fig.frt}
\end{figure}

La méthode de FRT inverse permet de retrouver l'image initiale à partir des
données de projections. Puisque chaque pixel de l'image a été utilisé une seule
fois lors de la génération des projections, la reconstruction ne nécessite pas
d'interpolation comme il en existe dans le domaine continu.
\matus on montré que l'opérateur inverse de la FRT correspond à l'opération FRT
lui même. En conséquence, on applique la transformée de \radon finie sur les
projections $R(m,t)$ mais avec un angle $m^\prime$ opposé à $m$, c'est à dire
tel que $m^\prime = p-m$.
On obtient alors une image reconstruite $f^\prime$ dont les éléments
correspondent à $f^\prime(x,y) = (f(x,y) \times p) + I_{sum}$, où $f(x,y)$
est la valeur d'origine de l'élément $(x,y)$, et $I_{sum}$ correspond
à la somme de tous les pixels de l'image. L'image initiale est alors retrouvée
en normalisant l'image reconstruite par la soustraction de ses éléments par
$I_{sum}$, puis par la division par $p$. L'équation correspondante à cette
opération inverse est :

\begin{equation}
    f(x,y) =
        \frac{1}{p}\left(
            \sum\limits_{m^{\prime}=0}^{p-1} R(m^{\prime},t) + R(p,x) - I_{sum}
            \right).
    \label{eqn.frt_inverse}
\end{equation}

Cette opération est représentée en \cref{fig.frt}. Le schéma de gauche
correspond à la reconstruction de l'image $f'(x,y)$ avant normalisation.
Bien que simple à mettre en œuvre, cette méthode n'est pas efficace. La
complexité algorithmique de cette méthode est $\mathcal{O}(p^3)$.

\textcite{matus1993pami} ont cependant démontré que la FRT conserve toutes les
propriétés de la transformée continue de \radon. En particulier,
\textcite{kingston2006aiep} ont montré que théorème de la tranche centrale peut
être utilisé pour reconstruire efficacement l'image, et ainsi diminuer cette
complexité à celle de la FFT, i.e.\ $\mathcal{O}(p^2 log_2 p)$. En particulier,
la version discrète ne nécessite pas d'interpolation puisque la grille polaire
correspond à la grille cartésienne dans le domaine de \fourier.


## Fantôme discret {#sec.fantome}

### Introduction aux fantômes

Pour une transformée comme celle de \radon définie par \cref{eqn.radon},
\textcite{bracewell1956ajp} définit les fantômes ainsi comme :

\begin{equation}
    \int_\mathcal{L}g(x,y)\ell = 0.
    \label{eqn.ghost}
\end{equation}

%Ils ont été étudiés pour la première fois dans le

%contexte de l'astronomie par \citeauthor{cornwell1982sm,

%bracewell1956ajp} \cite{cornwell1982sm,bracewell1956ajp}. 

Les fantômes correspondent ainsi à des éléments dont la somme vaut $0$ suivant
la direction de projection $\mathcal{L}$\footnote{le nom "fantôme" provient du
fait que ces éléments sont invisibles dans l'espace de \radon}. De manière
similaire, ils correspond à des éléments de l'image générés dés lors que des
projections manquent.

En pratique, puisque la transformée de \radon continue est un problème *mal
posé*, il existe toujours des projections manquantes de par la nature des
mesures et de la physique des capteurs. En conséquence, les fantômes empêchent
l'aboutissement du processus de reconstruction vers une solution unique. De par
sa définition, un fantôme correspond à la valeur de la projection manquante,
distribuée sur les pixels de l'image selon un motif particulier.

Les fantômes ont un rôle essentiel dans la compréhension des transformées, et
d'en l'élaboration des méthodes de reconstruction avec perte de données. En
particulier, nous nous intéresserons aux travaux de \textcite{chandra2008dgci}
qui étudie la structure des fantômes afin de comprendre comment ils influencent
la donnée en FRT. Nous verrons par la suite une méthode pour supprimer les
fantômes de l'image et ainsi reconstruire sa valeur initiale.


### Structure des fantômes et distribution sur l'image

\begin{figure}
	\centering \input{tikz/espace_fantome.tex}
	\caption{Représentation des distributions circulantes des fantômes
	${a, b,	c}$ générés par l'effacement respectif des projections $m={1,3,4}$.
	Les grilles de gauche correspondent à la superposition des fantômes sur une
	image $(5 \times 5)$ après reconstruction depuis les projections FRT de
	droite. Chaque étape correspond à un nouvel effacement, représentée par une
	ligne colorée. Figure inspirée de \textcite{chandra2008dgci}.}
	\label{fig.espace_fantome}
\end{figure}

\textcite{katz1978springer} a montré que l'effacement d'une projection FRT
entraîne la création d'un fantôme dans l'image. Afin de déterminer des méthodes
de reconstruction de l'image en cas de perte de projections, il est nécessaire
d'en déterminer la structure. Soit une projection $a = \{a_0, \dots, a_{p-1}\}$
correspondante à la projection d'index $m_a$ de l'espace de \radon $R(m,t)$.
\textcite{chandra2008dgci} ont montré que la reconstruction de l'image à partir
d'un domaine de \radon partiel (où la projection $a$ est manquante) entraîne
une distribution particulière des valeurs de $a$ sur l'image. Plus
particulièrement, les valeurs de la projection $a$ se superposent à l'image,
avec un décalage circulaire de $m_a$ sur chaque ligne de l'image.
\Cref{fig.espace_fantome} montre la distribution des valeurs du fantôme dans
une image $(5 \times 5)$ lorsque la projection $m=1$ est manquante.

\textcite{chandra2012tip} ont par la suite démontré que cette structure est
caractérisée par une matrice circulante. Plus particulièrement, chaque
projection manquante entraîne la génération d'une nouvelle distribution de
fantômes dont les décalages sont caractérisés par l'index de cette projection.
Ainsi, lorsque plusieurs projections manquent dans le domaine de \radon,
l'image contient une superposition des distributions de ces fantômes.
\Cref{fig.espace_fantome} montre le cas où deux puis trois projections sont
manquantes. Dans la suite, nous nous intéresserons aux méthodes de résolution
qui permettent de supprimer ces fantômes afin de reconstruire l'image à partir
d'un espace de \radon partiel.


### Reconstruire l'information manquante

Plusieurs algorithmes ont été proposés pour reconstruire l'image à partir d'un
espace de \radon partiel. La première méthode de reconstruction de l'image par
la méthode des fantômes a été proposée par \textcite{chandra2008dgci}. Cette
méthode repose sur deux choses : 

1. la présence d'une zone de redondance dans l'image dont la valeur des pixels
doit être connue:

2. un processus de reconstruction permettant de supprimer ces fantômes.

La présence d'une zone de redondance dans l'image est essentielle pour la
reconstruction d'un domaine partiel. \textcite{chandra2008dgci} ont montré
qu'il était nécessaire de calibrer une les valeurs d'une zone de l'image afin
d'isoler la valeur des fantômes dans cette zone lors de la reconstruction d'un
espace de \radon incomplet. Plus particulièrement, il est possible de
reconstruire $r$ projections dés lors que cette zone de redondance implique $r$
lignes de l'image. Il est ainsi judicieux de fixer la valeur nulle pour ces
lignes de redondance afin que les pixels ne contiennent que la valeur des
fantômes lors de la reconstruction.

Lorsqu'une seule projection manque, la valeur de ses éléments est alors
accessible sur une ligne de redondance, à un décalage près qui est caractérisé
par $m_a$ et l'index de la ligne. Le premier exemple représenté en
\cref{fig.espace_fantome} montre bien que cette conséquence.
Lorsque plusieurs projections manquent, le processus de reconstruction proposé
par \textcite{chandra2008dgci} se complique. Il met en jeu trois opérations
pour la détermination d'une projection : (i) un décalage cyclique sur chaque
lignes afin de synchroniser le premier élément $a_0$ des fantômes sur le
premier pixel de chaque ligne; (ii) la soustraction des lignes afin d'enlever
la contribution du fantôme dans ces lignes de redondance; (iii) une intégration
des valeurs obtenues afin de supprimer l'offset généré par la soustraction
précédente. Pour le lecteur qui souhaite plus d'information sur cette méthode,
toutes les étapes sont clairement indiquées dans \textcite{chandra2008dgci}.


## Code à effacement par transformée de \radon finie {#sec.fecfrt}

### Représentation algébrique

\textcite{normand2010wcnc} ont publié une construction du code à effacement FRT
à partir d'une approche algébrique. En particulier, ils ont montré que
l'opérateur de transformée peut d'écrire sous la forme d'une matrice de
Vandermonde. La définition de la FRT inverse est toujours valable puisque les
sous matrices d'une matrice de Vandermonde sont toujours inversibles
\cite{macon1958maa}.

### Forme non-systématique

\begin{figure}
    \centering
    \def\svgwidth{.7\textwidth}
    \includesvg{img/frt_design_non-sys}
    \caption{Représentation de la mise en œuvre du code à effacement
    non-systématique basé sur la FRT. La colonne de parité correspond à une
    contrainte nécessaire pour concevoir un code MDS. Les données encodées
    correspond aux $p$ projections de l'espace de \radon.}
    \label{fig.frt_non-sys}
\end{figure}

\Cref{fig.frt_non-sys} représente la mise en œuvre de la FRT en
non-systématique. Dans l'objectif d'obtenir un espace de \radon de même taille
que l'image, la dernière colonne $f(x=(n-1),y)$ correspond à une colonne de
parité. Cela entraîne deux conséquences : (i) la dernière projection est nulle
de part la parité horizontale; (ii) la dernière colonne du domaine de
transformée correspond également à un colonne de parité. En conséquence, il
n'est alors pas nécessaire de garder ces informations. Dans ces conditions, la
FRT permet de transformer une image $f(x,y)$ de taille $(n-1) \times n$ en $n$
projections de taille $(n-1)$. En utilisant les propriétés de reconstruction
que l'on a vu précédemment, la FRT est ainsi capable de fournir un code MDS.


### Forme systématique

\begin{figure}
    \centering
    \def\svgwidth{.7\textwidth}
    \includesvg{img/frt_design_sys}
    \caption{Représentation de la mise en œuvre du code à effacement
    systématique basé sur la FRT. Les données encodées correspond aux $k$
    lignes de données auxquelles on ajoute $r$ lignes de redondance.}
    \label{fig.frt_sys}
\end{figure}

\Cref{fig.frt_sys} représente la mise en œuvre de la FRT en systématique.
De précédents travaux ont permis de concevoir un code à effacement à partir de
la FRT en ajoutant certaines contraintes à la disposition des données
\cite{normand2010wcnc}. Cette étude présente une mise en œuvre à partir de la
représentation suivante. On définit une grille discrète $(n \times n)$, dans
laquelle on considère $k$ lignes de données utilisateurs. On considèrera les
$r=n-k$ lignes restantes nulles. Dans la version non-systématique de ce code,
les blocs encodés correspondent aux projections de \radon calculées.

Dans la version systématique, on considère les lignes de l'image comme blocs
encodés. Pour cela, il est nécessaire de calculer $r$ lignes de redondance.
Cette redondance est calculée de sorte que $r$ lignes consécutifs dans le
domaine de \radon sont nulles. Cette opération revient à générer des fantômes.

\subsubsection*{Bilan de la FRT}

Nous avons vu que la FRT correspond à une version discrète, exacte et
périodique de la transformée de \radon continue. Cette propriété lui permet de
fournir un code MDS en se basant sur une contrainte de construction mettant en
jeu une colonne de parité, et un calibrage des données correspondant à des
lignes de redondance. En particulier, nous avons vu deux algorithmes de
reconstruction efficaces : (i) par utilisation de la FFT depuis le théorème de
tranche centrale; (ii) par la méthode de suppression des fantômes.
En conséquence, ces méthodes ont permis de déterminer deux versions de code à
effacement selon une construction systématique et non-systématique.

En conséquence, la FRT peut tout à fait être mise en œuvre dans un contexte de
transmission et de stockage de l'information. Dans ce contexte, la propriété
MDS du code à effacement par FRT permet de générer une quantité minimum de
redondance pour fournir une certaine tolérance à l'effacement. Dans une autre
mesure, l'efficacité des algorithmes proposés permettent une implémentation
performante des opérations d'encodage et de décodage.

% ouverture sur la mojette non MDS mais qui poutre encore plus mieux



# Code à effacement par transformée Mojette {#sec.mojette}

Dans cette section, nous allons nous intéresser à un code à effacement basé sur
la transformée Mojette. Tout comme la FRT, cette transformée correspond à une
version discrète et exacte de la transformée de \radon continue définie dans
\textcite{radon1917akad} (voir \cref{eqn.radon}). Elle a été proposée pour la
première fois par \textcite{guedon1995vcip} dans le contexte du traitement et
du codage psychovisuel. Depuis, cette transformée a été utilisée dans de
nombreuses applications liées à l'imagerie numérique (codage, transmission,
tatouage). Dans cette thèse, nous proposons de l'utiliser comme code à
effacement pour le stockage et la transmission d'information.

Nous décrirons en \cref{sec.mojette-forward} la méthode de calcul des
projections Mojette, qui se distinguent des projections FRT par leur définition
apériodique. Nous verrons que ces projections peuvent fournir une
représentation redondante de l'image, nécessaire pour tolérer des effacements.
\Cref{sec.mojette-inverse} présentera le critère défini par
\textcite{katz1978springer} permettant de garantir l'unicité de la solution de
reconstruction d'une image rectangulaire. Nous verrons que ce critère est
nécessaire pour définir la capacité de reconstruction du code à effacement. La
méthode de reconstruction de \textcite{normand2006dgci} sera également étudiée,
puisque qu'elle sera utilisée dans le processus de décodage afin de
reconstruire l'information. Après cette présentation de la transformée Mojette,
nous verrons comment ces éléments permettent de concevoir un code à effacement
en \cref{sec.fecmojette}.


## Transformée Dirac-Mojette directe {#sec.mojette-forward}

\begin{figure}
    \centering
    \def\svgwidth{.7\textwidth}
    \includesvg{img/mojette_forward_xor}
    \caption{La transformée de Dirac-Mojette. On considère une grille d'image 
    $P \times Q = 3 \times 3$ sur laquelle nous calculons $4$ projections
    dont les directions $(p_i,q_i)$ sont compris dans l'ensemble 
    $\left\{(-1,1), (0,1), (1,1), (2,1)\right\}$. La base utilisée est
    représentée par les deux vecteurs unitaires $\vec{u}$ et $\vec{v}$.
    L'addition est ici arbitrairement réalisée modulo $2$.}
    \label{fig.mojette_directe}
\end{figure}

La transformée Mojette est une opération linéaire définie par
\textcite{guedon1995vcip} qui calcule un ensemble de $I$ projections à partir
d'une image discrète
$f:\ZZ^2 \mapsto\mathbb R$. Bien que cette image discrète peut avoir n'importe
quelle forme, nous considèrerons dans la suite une image rectangulaire,
composée de $P \times Q$ pixels. Une projection Mojette $\M$ est
un ensemble d'éléments appelés *bins*, qui est définie par une direction de
projection $(p,q)$, avec $p,q \in \\Z$ premiers entre eux (comme expliqué en
\cref{sec.angles}). En particulier, la transformée Dirac-Mojette $[\M f]$ est
définie par \textcite{guedon1995vcip} ainsi :

\begin{equation}
    [\M f](b,p_{i},q_{i}) = 
        \sum_{k=0}^{Q-1} \sum_{l=0}^{P-1}
        f \left(k,l\right)
        \Delta\left(b-lp_{i}+kq_{i}\right),
    \label{eqn.mojette}
\end{equation}

\noindent où $\Delta(\cdot)$ vaut $1$ si $b=lp_{i}-kq_{i}$ et $0$ sinon.
Le paramètre $b$ correspond à l'index du bin de la projection d'angle
$(p_i,q_i)$. Plus précisément, \cref{eqn.mojette} signifie que la valeur des
bins de la projection suivant la direction $(p_i, q_i)$ résulte de la somme des
pixels situés sur la droite discrète d'équation $b = -kq_i + lp_{i}$.
Comme on peut l'observer, l'opération modulaire que l'on a pu voir dans
l'opérateur FRT \cref{eqn.frt}, n'est pas utilisé ici, représentant la
propriété apériodique de la transformée Mojette.

\Cref{fig.mojette_directe} représente la transformée Mojette d'une
grille discrète $(3 \times 3)$ composée de binaires. Le traitement transforme une
image 2D en un ensemble de $I=4$ projections dont les valeurs des directions
sont comprises dans l'ensemble suivant : $\left\{(-1,1), (0,1), (1,1),
(2,1)\right\}$. Dans l'objectif de simplifier la représentation de cet exemple
et des suivants, l'addition est arbitrairement réalisée ici modulo $2$ (la
somme correspond alors à un OU exclusif). Cependant, la somme peut être définie
en utilisant l'arithmétique élémentaire ou modulaire.

Dans l'exemple de la projection de direction $(p=0, q=1)$, chaque bin résulte
de l'addition des pixels de la grille suivant la direction verticale. Par
exemple, le premier bin, situé tout à droite de la projection, vaut
$1 \oplus 0 \oplus 1 = 0$.
Les autres projections ont la particularité d'avoir une pente non nulle. Par
exemple, la valeur des bins des projections d'angles $(-1,1)$ et $(1,1)$
correspondent à la somme des pixels suivant les diagonales. En particulier pour
ces projections, on remarque que les bins situés aux extrémités des projections
sont entièrement définis par un seul pixel. Cette remarque sera nécessaire afin
de comprendre comment s'applique l'algorithme de reconstruction de
\textcite{normand2006dgci} que l'on détaillera dans la prochaine section.
Du point de vue de la complexité, puisqu'il faut $\mathcal{O(I}$ opération par
pixel et que chaque pixel et parcouru, la complexité de la transformée Mojette
vaut $\mathcal{O}(PQI)$. \textcite{normand1996vcip} précise que si le nombre de
projections $I$ correspond à $log(PQ)$, alors la complexité de la Mojette
correspond à celle de la FFT de \textcite{cooley1969tae}.

%4+5+1 \pmod 6 = 4$


## Reconstruction par transformée Mojette {#sec.mojette-inverse}

Dans cette section, nous présentons le critère défini par
\textcite{katz1978springer} qui permet de déterminer si un ensemble
de projections est suffisant pour reconstruire de manière unique l'image. Par
la suite, nous présentons l'algorithme de reconstruction de
\textcite{normand2006dgci}.

### Critères de reconstruction

Le premier critère permettant de garantir l'existence d'une solution unique de
reconstruction est le critère de \textcite{katz1978springer}. Ce critère
n'est défini que pour des images rectangulaires $P \times Q$. Étant donné un
ensemble de directions de projection $\left\{(p_i,q_i)\right\}$, le critère de
\citeauthor{katz1978springer} déclare que si l'une des conditions suivantes est
remplie :
\begin{equation}
    \sum\limits_{i=1}^I{|p_i|}\geq P
    \text{ ou }
    \sum\limits_{i=1}^I{|q_i|}\geq Q,
    \label{eqn.katz}
\end{equation}
\noindent alors il existe une unique solution de reconstruction, et cette
solution contient les valeurs de la grille qui ont permis de calculer ces
projections. Ce critère a été étendu par \textcite{normand1996vcip} pour
n'importe quelle image convexe en utilisant la définition des fantômes.

Dans l'exemple de \cref{fig.mojette_directe}, si l'on considère un
sous-ensemble de $3$ projections $\left\{(p_{0},q_{0}), \dots,
(p_{2},q_{2})\right\}$, la seconde condition du critère de
\citeauthor{katz1978springer} donne $\sum_{i=0}^2~|q_{i}|=3$, puisque $q=1$
pour chaque direction de projection. En conséquence, $3$ projections parmi les
$4$ calculées dans cet exemple suffisent pour reconstruire l'image de manière
unique. Autrement dit, la perte d'une projection n'influence pas le résultat du
processus de reconstruction. On considère alors que les $4$ projections
calculées dans cette figure décrivent une représentation redondante de l'image.

### Algorithme de reconstruction

\begin{figure}
    \centering
    \def\svgwidth{.3\textwidth}
    \input{img/graphe_dependance.pdf_tex}
    \caption{Graphe de dépendance des pixels. On considère une image $3 \times
    3$ ainsi qu'un ensemble de directions de projection $(p_i,q_i)$ à valeur
    dans $\left\{(-1,1),(0,1),(1,1)\right\}$. Les nœuds correspondent aux
    pixels tandis que les arêtes représentent les dépendances entre eux.
    Un pixel peut être reconstruit par un bin lorsqu'aucune dépendance ne
    s'applique sur lui.}
    \label{fig.dep_graph}
\end{figure}

%, et sont énumérés dans \textcite{guedon2009mojettebookchap5}.

Plusieurs algorithmes de reconstruction Mojette ont été proposés
\cite{normand1996vcip, normand2006dgci, serviere2005spie}. Nous choisissons de
décrire dans la suite,
l'algorithme itératif d'inversion Mojette par balayage (*Balayage Mojette
Inversion*, BMI) de \textcite{normand2006dgci} pour son efficacité. Cet
algorithme est essentiel dans ces travaux de thèse. Il sera en effet utilisé
pour décoder l'information dans le code à effacement, et servira également dans
la compréhension de génération de nouvelles projections en
\cref{sec.reprojection}.

Nous avions abordé dans la section précédente une observation essentielle pour
commencer la reconstruction. Celle ci remarquait que les pixels situés dans les
coins de la grille définissent entièrement les bins correspondants dans les
projections dont la pente n'est pas nulle (i.e.\ tel que $p$ ou $q$ soient
différents de $0$).
On remarque que les autres pixels en revanche, interviennent avec d'autres
éléments de l'image dans le calcul des bins de projections. Tant que la valeur
de ces pixels n'est pas connue, il est impossible de déterminer la valeur de ce
pixel.
En conséquence, il existe des dépendances entre les pixels.
\Cref{fig.dep_graph} est un graphe orienté qui représente les dépendances entre
les pixels d'une grille $3 \times 3$, étant donné un ensemble de directions de
projection $\left\{(1,1), (0,1), (-1,1)\right\}$. Les nœuds de ce graphe
correspondent aux pixels tandis que les arêtes représentent leurs dépendances.
Il est ainsi possible de déterminer la valeur d'un pixel seulement
lorsqu'aucune dépendance ne s'applique sur lui (i.e.\ aucune arête du graphe
n'y parvient).

Bien que le sens de reconstruction est arbitraire, on considèrera une
reconstruction de gauche à droite comme proposé dans
\textcite{normand2006dgci}. Afin d'assurer qu'aucune itération ne bloque
l'algorithme, on affecte la reconstruction de chaque ligne à une seule
projection. Par exemple dans \cref{fig.dep_graph}, la projection suivant la
direction $(1,1)$ est affectée à la reconstruire la première ligne.
L'attribution des projections aux lignes se fait de sorte que $p_i$ décroît en
même temps que l'index de la ligne augmente. Il est alors possible de
déterminer un chemin dans ce graphe qui décrit les différentes itérations qui
permettent de reconstruire entièrement l'image (plusieurs chemins peuvent
exister). En particulier, chaque itération permet de déterminer la valeur d'un
pixel, permettant en conséquence de réduire les dépendances appliquées sur les
autres.

Dans l'exemple de \cref{fig.dep_graph}, une itération possible consiste à :

\begin{enumerate}
    \item débuter en reconstruisant le pixel supérieur gauche par la projection
    suivant la direction $(1,1)$ puisqu'aucune dépendance ne s'y applique ;
    \item récupérer la valeur du pixel inférieur gauche depuis un bin de la
    projection suivant $(-1,1)$ pour la même raison ;
    \item puisque les deux précédents pixels ont été reconstruits, plus aucune
    dépendance ne s'applique sur le premier pixel de la deuxième ligne, il est
    alors possible de récupérer sa valeur à partir de la projection suivant
    $(0,1)$.
\end{enumerate}

\noindent Une fois cette première colonne reconstruite, il est possible de répéter
l'itération sur les colonnes suivantes (jusqu'à reconstruire entièrement la
grille).

En pratique, ces éléments correspondent à des zones mémoires contigües. En
particulier, les bins des projections interviennent de manière séquentielle
dans la reconstruction d'une ligne. Cette considération permet de favoriser la
localité spatiale des données et donc les performances de l'implémentation.


## Code à effacement Mojette {#sec.fecmojette}

### Conception du code à effacement non-systématique

Nous avons vu que la transformée Mojette est capable de fournir une
représentation de l'image. Cette propriété essentielle forme la base de notre
motivation à concevoir code à effacement à partir de cette transformée Mojette.
On rappelle ici qu'en théorie des codes, un code à effacement $(n,k)$
transforme $k$ blocs de données en un ensemble de $n$ blocs encodés plus grand
(i.e.\ $n \geq k$).

Contrairement à la FRT, il est nécessaire en Mojette de déterminer l'ensemble
des projections que l'on souhaite calculer. Afin de concevoir simplement un
code à effacement, on fixe l'un des paramètres $(p,q)$ à $1$. Considérons par
la suite que pour chaque projection, $q_i = 1$ pour $i \in \ZZ_I$ comme cela à
déjà été utilisé dans de précédents travaux \cite{parrein2001gretsi,
parrein2001phd}.
Soit une image discrète de taille $(P \times Q)$, avec $Q$ le nombre de lignes
de cette image, et soit un ensemble de $I$ projections. Nous rappelons que la
condition sur $Q$ pour garantir l'unicité de la solution de reconstruction est
$Q \leq \sum\limits_{i=1}^{I}|q_i|$ (extrait de \cref{eqn.katz}). En
conséquence, si l'on fixe $q_i = 1$, le critère de
\citeauthor{katz1978springer} est réduit au principe suivant : $Q$ projections
suffisent pour reconstruire l'information contenue dans une image de hauteur
$Q$. Dans ces conditions, $Q$ projections constituent un ensemble
suffisant pour reconstruire l'image. En particulier, la transformée Mojette
correspond à un code à effacement $(n,k)$ où $k$ correspond à la hauteur de
l'image $Q$, et $n$ correspond au nombre de projections $I$. En conséquence,
cette condition permet à la transformée Mojette de garantir une solution unique
au problème de reconstruction lorsqu'un maximal de $(n-k) = (I-Q)$ projections
sont manquantes.

### Un code à effacement "quasi MDS"

Il est important de considérer avec attention la taille des projections
puisque cette taille a des conséquences sur la consommation mémoire. En
particulier dans les applications de transmission et stockage, on souhaite
réduire au maximum cette consommation.
La taille $B$ d'une projection, correspondant au nombre de bins qu'elle
contient, est définie par \textcite{guedon1995vcip} ainsi :

\begin{equation}
    B(P,Q,p_i,q_i) = (Q-1)|p_{i}|+(P-1)|q_{i}|+1,
    \label{eqn.nombre_bins}
\end{equation}

où $(P,Q)$ correspond à la taille de l'image et $(p_i,q_i)$ correspond à la
direction de la projection étudiée. Dans le cas du code à effacement, où l'on
fixe $q_i=1$, \cref{eqn.nombre_bins} s'écrit :

\begin{equation}
    B(P,Q,p_i,q_i) = (Q-1)|p_{i}|+P.
    \label{eqn.nombre_bins_fec}
\end{equation}

En conséquence, la taille des projections augmente avec $p_i$.
Rappelons que dans le cas d'un code MDS, la taille d'un bloc encodé correspond
à la taille d'un bloc de donnée. Du point de vue des projections, la
transformée Mojette permet de concevoir un code optimal puisqu'un ensemble de
$k$ projections suffisent pour reconstruire une image composée de $k$ lignes.
En revanche, du point de vue des bins, ce code n'est pas optimal puisque la
taille des projections augmente avec la valeur de $p_i$. En conséquence, le
code Mojette n'est pas MDS.

#### Choix de l'ensemble de projections

Afin de réduire cet impact, la première étape consiste à
déterminer la valeur des $p_i$ permettant de générer l'ensemble des projections
le plus compact possible. Pour cela, il est nécessaire de choisir les valeurs
de $p_i$ dans l'ensemble des entiers issus de l'énumération des entiers
alternativement positifs et négatifs\footnote{séquence fournie par
l'encyclopédie de \textcite{sloane1996siam} \url{http://oeis.org/A001057}.}
(i.e.\ $\{0,1,-1,2,\dots\})$, comme proposé par \textcite{verbert2004wiamis}.

Dans le cas d'un code MDS, la taille d'un bloc encodé correspond à la taille
d'un bloc de donnée. Pour l'encodage Mojette d'une image rectangulaire, c'est
le cas seulement pour la projection verticale $(p=0,q=1)$ et horizontale
$(p=1,q=0)$. Dans le cas général, les projections sont plus grandes qu'une
ligne de l'image. En conséquence, cette surpopulation du nombre de bins induit
que le code à effacement Mojette n'est pas MDS.
\textcite{parrein2001phd} définit ce cout de surpopulation, noté $\epsilon$,
comme étant le rapport du nombre de bins (défini dans \cref{eqn.nombre_bins})
sur le nombre de pixels :

\begin{align}
    \epsilon    &= \frac{\#_{bins}}{\#_{pixels}},\\
                &= \frac{\sum\limits_{i=0}^{n-1}B(P,Q,p_i,q_i)}{P \times Q}.
    \label{eqn.epsilon}
\end{align}

En particulier, il montre que cette valeur est significativement réduite à
mesure que la largeur $P$ de l'image augmente. Le terme "quasi MDS" appliqué
au code à effacement Mojette provient de désignation $(1+\epsilon)-MDS$ de
\textcite{parrein2001phd}. Dans le prochain chapitre de cette thèse, l'impact
de l'encodage sera précisément évalué et comparé avec d'autres techniques
(\cref{sec.surcout_stockage}).

#### Réduction du surcout de redondance

\textcite{verbert2004wiamis} ont proposé une méthode basée sur l'analyse de
l'algorithme de reconstruction, afin de réduire la taille des projections.
Prenons l'exemple d'une grille discrète $(P=6,Q=2)$ sur
laquelle on calcule trois projections suivant les directions
$\left\{(1,1),(0,1),(-1,1)\right\}$. Dans ce cas, puisqu'il est nécessaire
d'avoir deux projections pour reconstruire la grille, il n'existe que 3
combinaisons possibles d'affection des projections aux lignes :
$\left\{(1,0),(0,-1),(1,-1)\right\}$. La première ligne ne peut alors être
reconstruite que par les projections suivant $(p=1)$ ou $(p=0)$. De même, la
seconde ligne ne peut être reconstruire que par les projections suivant $(p=0)$
ou $(p=-1)$. En conséquence, quelque soit l'ensemble de projections utilisé
lors de la reconstruction, le processus ne va utiliser que les $k=6$ premiers
bins de chaque projection. Ce qui signifie qu'il n'est pas nécessaire de
calculer et stocker le septième et dernier bin des projections $(p={1,-1})$.
Notons que dans ce cas particulier, le code Mojette est optimal puisque les
projections font la même taille que les lignes de l'image.

Dans le cas général, \textcite{verbert2004wiamis} ont montré que cette
réduction du nombre de bin ne peut amener le code à être optimal. Toutefois ils
ont montré  une méthode permettant de réduire la valeur d'*epsilon*. Cela
permet deux choses : (i) l'opération d'encodage est plus performante puisque
moins de calculs sont nécessaires; (ii) la taille des projections est réduite
ce qui améliore le transfert et le stockage des projections en pratique.

% ## Relations avec d'autres codes à effacement

% ### Matrice d'encodage

% ### Connexions avec les codes LDPC

\section*{Conclusion du chapitre}

La transformée de \radon pose les bases de la reconstruction tomographique. Son
étude dans le domaine continue a ouvert la voie à de nombreuses techniques
d'inversion. En particulier, nous avons vu que la tomographie discrète
attaque le problème de la reconstruction tomographique par une représentation
discrète des éléments et des algorithmes. Cette représentation a l'avantage de
répondre au problème par une solution exacte par rapport aux solutions émanant
du domaine continu, grâce à l'échantillonnage possible par la géométrie du
problème.

Nous avons étudié la FRT et la transformée Mojette qui sont des versions
discrètes et exactes de la transformée de \radon. La capacité d'inversion de
ces transformée forme la base de leur conception sous la forme de code à
effacement. Plus particulièrement nous avons étudié comment ces transformées
peuvent être utilisées afin d'encoder et générer des informations redondantes,
nécessaires pour tolérer l'effacement. Afin de déterminer la capacité des
codes, nous avons énoncé les critères qui garantissent si un ensemble de
projections donné permet de résoudre le problème de reconstruction. Les
méthodes itératives et efficaces d'inversion ont été détaillées et permettent
à ces codes de reconstruire l'information dans le cas où les données ont été
altérées.

La transformée Mojette correspond à une version apériodique de la FRT. En
conséquence, le code à effacement bâti sur la Mojette n'est pas MDS
contrairement au code fourni par la FRT. Toutefois ce surcout d'encodage est
limité et la Mojette correspond à un code "quasi MDS". Ce léger surcout ouvre
la voie à des algorithmes de reconstruction très efficaces. Cependant, aucune
version aboutie du code à effacement Mojette n'existe à ce jour. Nous tâcherons
dans le chapitre suivant de concevoir cette nouvelle version afin d'améliorer
significativement les performances du code.
