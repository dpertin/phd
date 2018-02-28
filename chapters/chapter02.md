
\chapter{Conception de codes à effacement en géométrie discrète}

\label{sec.chap2}

\minitoc

\newpage

\section*{Introduction du chapitre}

\addcontentsline{toc}{section}{Introduction du chapitre}

Dans le chapitre précédent, nous avons vu que les codes à effacement permettent
de générer la redondance nécessaire pour contrebalancer la perte d'une partie
de l'information. En particulier, les codes de \textcite{reed1960jsiam} sont
les plus utilisés. Bien qu'optimal au sens MDS, ces codes utilisent des
algorithmes de complexité quadratique. Nous avons vu précédemment qu'un code
parfait doit être MDS, de paramètres $(n,k)$ arbitraires, et disposant
d'algorithmes d'encodage et de décodage de faible complexité.
Dans ce chapitre, nous proposons d'attaquer le problème de reconstruction à
partir d'une approche par géométrie discrète, en détaillant les travaux qui ont
été réalisés jusqu'à aujourd'hui, dans le but de concevoir de nouveaux codes à
effacement.
<!--
%En particulier, nous verrons que cette approche permet de définir de nouvelles
%méthodes de codage de faibles complexités plus avantageuses par rapport à la
%complexité $\mathcal{O}(n^3)$ de la méthode algébrique vue précédemment.
-->

La transformation de \textcite{radon1917akad} est une application utilisée en
reconstruction tomographique. Elle permet de représenter une fonction par ses
projections suivant différents angles. Évoqué précédemment, le problème de
reconstruction (ou d'inversion) correspond à savoir s'il est possible de
reconstruire cette fonction à partir des seules informations de projections.
Nous verrons dans la suite qu'il est possible de définir des versions de cette
transformation capables de représenter l'information de manière redondante.
Notre objectif est ainsi de déterminer des algorithmes capables de reconstruire
l'information à partir d'un ensemble suffisant de projections (comme un code à
effacement). L'inversion de la transformation de \radon possède des liens avec
la transformation de \fourier. Ces liens sont décrits par le théorème de la
tranche centrale\ \cite{bracewell1956ajp}. Ce théorème peut être utilisé pour
concevoir un algorithme de reconstruction basé sur la transformation de Fourier
rapide FFT et bénéficier d'une complexité quasi-linéaire $\mathcal{O}(n
\log{n})$\ \cite{cooley1969tae}.

La première étape consiste à discrétiser la transformation de \radon,
initialement définie dans le domaine continu\ \cite{radon1917akad}. Cette étude
sera réalisée en \cref{sec.reconstruction_discrete}. \matus sont parvenus à
définir une version discrète de la transformation de \radon, qui conserve
toutes les propriétés de la version continue\ \cite{matus1993pami} (en
particulier, le théorème de la tranche centrale).
Plus particulièrement, nous verrons deux versions discrètes et exactes de la
transformation de \radon : (i) la transformation de \radon finie (pour *Finite
Radon Transform* ou FRT); (ii) la transformation Mojette. Le principe de cette
première transformation sera étudiée dans la \cref{sec.frt}, avant de nous
intéresser à un algorithme d'inversion, ainsi que sa mise en œuvre comme code à
effacement. Nous mettrons en avant la propriété périodique de la FRT, et nous
verrons qu'elle permet d'en fournir un code MDS\ \cite{normand2010wcnc}.
<!--
%L'algorithme d'inversion algébrique
%ART proposé par \textcite{gordon1970jtb} permet de comprendre simplement 
%l'inversion en FRT. Nous verrons également une méthode plus efficace basée sur
%la transformée de \fourier \cite{matus1993pami}. Ces différents éléments nous
%permettront en \cref{sec.frt} de définir la FRT dans un contexte de code à
%effacement.
-->
La \cref{sec.mojette} présente la seconde version discrète de la transformation
de \radon. Bien que la propriété apériodique des projections Mojette empêche la
conception d'un code à effacement MDS, elle possède un algorithme de
reconstruction itératif efficace. Nous verrons en particulier l'algorithme de
\textcite{normand2006dgci} qui permet de reconstruire chaque symbole avec une
complexité linéaire.
Après avoir défini le critère de \katz permettant de garantir l'unicité de la
solution de reconstruction, nous verrons comment construire un code à
effacement à partir de cette transformation. Dans ce chapitre, nous verrons les
propriétés des *fantômes* qui sont des éléments de l'image invisible dans
l'espace transformé\ \cite{katz1978springer}. Ces fantômes nous permettront
non seulement de comprendre les processus d'inversion dans ce chapitre, mais
seront également utilisés au \cref{sec.chap6} afin de concevoir une méthode
pour générer de nouvelles projections.


# Discrétisation de la transformation de \radon continue
\label{sec.reconstruction_discrete}

La transformation de \textcite{radon1917akad} est une application linéaire
permettant de représenter une fonction par ses projections suivant différents
angles. L'inversion de cette opération consiste à reconstruire la fonction à
partir des valeurs de projections (solution du problème de reconstruction en
tomographie). La tomographie est une catégorie des problèmes inverses qui
consiste à reconstruire un objet à partir d'un ensemble de mesures partielles
et discrètes (i.e.\ les projections). En particulier, cette technique permet la
visualisation et le stockage d'une version numérique d'un objet.

Dans le milieu médical, il faudra attendre $1972$ avant
que \citeauthor{hounsfield1973bjr} ne parvienne à concevoir le premier scanner
à rayon X, sans pour autant qu'il n'ait eu au préalable connaissance des
travaux de \radon. Il remportera le prix Nobel de médecine en $1979$
avec \citeauthor{cormack1963jap} pour leurs travaux respectifs sur le
développement de la tomographie
numérique\ \cite{hounsfield1973bjr,cormack1963jap}. Cette technique, largement
répandue dans le milieu médical, a également été utilisée en astronomie par
\textcite{bracewell1956ajp}, en géophysique ou encore en mécanique des
matériaux. Une étude plus approfondie de la tomographie et de ses applications
est présentée dans les travaux de thèse de
\textcite{dersarkissian2015tomographie}.
L'originalité de nos travaux de recherche consiste à détourner l'utilisation de
cette technique utilisée en imagerie, pour concevoir des codes à effacement
appliqués à la transmission et au stockage d'information.

% bouger en intro ?

Dans la suite, nous introduirons en \cref{sec.radon} la transformation de
\radon continue telle que définie par \textcite{radon1917akad}. Afin de
comprendre comment discrétiser cette transformation, quelques notions de
géométrie discrète seront ensuite définies dans la \cref{sec.geometrie}.
Enfin nous verrons une première approche du problème de tomographie discrète
avec un exemple en \cref{sec.inverse} présentant une méthode de résolution
algébrique.


## Transformation de \radon dans le domaine continu {#sec.radon}

La transformation de \radon est une application qui répond au problème de la
tomographie. Nous introduirons dans un premier temps ce problème dans un
contexte pratique : l'imagerie médicale. Puis nous verrons la définition de
la transformation de \radon continue telle que définie dans les
travaux fondamentaux de \textcite{radon1917akad}.


### Problème de la tomographie

\begin{figure}[t]
    \centering
    \begin{subfigure}{.43\textwidth}
		\centering
        \def\svgwidth{.6\textwidth}
		\includesvg{img/inverse0}
    \vspace{.5cm}
        \caption{Exemple d'une projection}
        \label{fig.inverse1}
    \vspace{.5cm}
    \end{subfigure}
    \begin{subfigure}{.43\textwidth}
		\centering
        \def\svgwidth{.6\textwidth}
		\includesvg{img/inverse1}
    \vspace{.5cm}
        \caption{Rétroprojection de $1$ projection}
        \label{fig.inverse2}
    \vspace{.5cm}
    \end{subfigure}
	\begin{subfigure}{.43\textwidth}
		\centering
        \def\svgwidth{.6\textwidth}
		\includesvg{img/inverse22}
    \vspace{.5cm}
        \caption{Rétroprojection de $2$ projections}
        \label{fig.inverse3}
    \end{subfigure}
    \begin{subfigure}{.43\textwidth}
		\centering
        \def\svgwidth{.6\textwidth}
		\includesvg{img/inverse3222}
    \vspace{.5cm}
        \caption{Rétroprojection de $3$ projections}
        \label{fig.inverse4}
    \end{subfigure}
    \caption{Représentation des différentes étapes en tomographie.
    \Cref{fig.inverse1} représente une étape d'acquisition des données par
    la projection des deux formes de l'image sur l'horizontale.
    \Cref{fig.inverse1,fig.inverse2,fig.inverse3,fig.inverse4} représentent
    itérativement la rétroprojection des données.}
    \label{fig.inverse}
\end{figure}


En imagerie médicale, le problème de la tomographie correspond à un problème
inverse. Ce problème consiste à reconstituer une image à partir de ses
projections. On distingue alors deux processus dans la résolution de ce
problème : (i) *l'acquisition* des données; (ii) la *reconstruction* de
l'image. Ces deux processus sont représentés dans la \cref{fig.inverse}.
Celle-ci présente les différentes étapes d'une reconstruction tomographie
appliquée à une image composée de deux disques.

L'acquisition met en jeu la rotation d'un capteur qui mesure des projections 1D
autour d'une zone du patient. Cette technique est notamment utilisée dans les
scanners à rayons X\ \cite{hounsfield1973bjr}. Ces appareils envoient une
série de rayons X à travers le patient à différents angles. Les récepteurs
situés de l'autre côté du sujet mesurent l'absorption de ces rayons par les
tissus organiques. Il est alors possible de déterminer le volume de tissu
traversé par ces rayons. La mesure suivant la direction horizontale, est
représentée dans la \cref{fig.inverse1}. L'émetteur situé à gauche envoie des
rayons en parallèle (d'autres cas où les rayons sont émis en éventail ou en
cône existent, mais ne sont pas traités ici) et permet au capteur situé à
droite de mesurer une empreinte des deux formes étudiées.

Une fois l'acquisition terminée, un traitement informatique permet de
reconstruire une coupe du patient. Ce traitement correspond à l'opération
inverse. Une technique pour reconstruire l'image consiste à rétroprojeter
la valeur des projections dans le support à reconstruire. Si l'on ne dispose
pas de suffisamment de projections, alors l'ensemble des solutions possibles
peut être significativement grand (voire infini) et il est impossible de
déterminer une solution unique.
Plusieurs itérations de l'opération de rétroprojection sont représentées dans
les \cref{fig.inverse1,fig.inverse2,fig.inverse3}. Plus particulièrement, la
\cref{fig.inverse2} montre que l'ensemble des solutions est infini lorsque l'on
n'utilise qu'une projection. Plus on utilise de projections, plus la dimension
de l'espace des solutions se réduit. La \cref{fig.inverse3} montre cela en
mettant en jeu une seconde projection. Pour finir, si suffisamment de
projections sont utilisées, on parvient à déterminer une unique solution (i.e.\
l'image initiale). C'est le cas de la \cref{fig.inverse4} dans laquelle trois
projections sont utilisées. Pour définir des codes à effacement, nous verrons
des critères sur le nombre de projections nécessaires afin de garantir
l'unicité de la solution.


### Transformation de \radon

\begin{figure}[t]
    \centering
    \def\svgwidth{\textwidth}
    \includesvg{img/radon_xxx_simple3}
    \caption{Représentation d'une projection $R_{\varphi}[f]$ de
    la fonction $f$ suivant l'angle de projection $\varphi$, et illustration
    de la reconstruction par le théorème de la tranche centrale (TF désigne
    Transformation de \fourier).}
    \label{fig.radon}
\end{figure}

En\ \citeyear{radon1917akad}, \radon a défini la théorie mathématique de sa
transformation dans ses travaux fondamentaux\ \cite{radon1917akad}.
La transformation de \radon $\mathcal{R} \colon f \mapsto R$ est une
application permettant de calculer les projections $1$D d'une fonction $2$D
$f \colon \RR^2 \to \CC$. Soit $\{{\mathcal{L}_{\varphi}}\} =
\{t = x \cos \varphi + y \sin \varphi \mid t \in \RR\}$ l'ensemble des droites
de projections définies par un angle $\varphi$. Une projection $R \colon f
\mapsto r$
<!--%\colon \RR \to \CC$-->
est l'ensemble des intégrales curvilignes de $f$ le long des droites de
projection $\{\mathcal{L}_{\varphi}\}$ :

\begin{equation}
    R_{\varphi}[f] =
        \int_{\mathcal{L_{\varphi}}}f(x,y)\,d\ell\;,
    \label{eqn.projection.radon}
\end{equation}

\noindent où $d\ell$ correspond aux variations le long des droites de
$\{\mathcal{L}\}$. La \cref{fig.radon} représente la projection
$R_{\varphi}[f]$. En particulier, une mesure de projection $r[f](\varphi,t)$
est définie telle que :

\begin{equation}
    r[f](\varphi, t)    =
        \int_{-\infty}^{\infty}
        \int_{-\infty}^{\infty}
        f(x,y) \delta (t - x \cos \varphi - y \sin \varphi)\,dx\,dy\;,
    \label{eqn.mesure.projection.radon}
\end{equation}

\noindent où $\varphi$ représente l'angle de projection, et $|t|$, la distance
par rapport à l'origine. $\delta(\cdot)$ correspond à la distribution de
\textsc{Dirac}. La mesure de projection $r[f](\varphi,t=\tau)$
est représentée dans la \cref{fig.radon}. Notons que la projection
$r[f](\varphi,t) = r[f](\varphi + \pi, -t)$. Dans ce formalisme, la transformée
de \radon d'une fonction $f$ est l'ensemble des projections tel que :

\begin{equation}
    \{r[f](\varphi,t) \mid \varphi \in [0,\pi[, t \in \RR\}\;,
    \label{eqn.radon}
\end{equation}

\begin{figure}[t]
    \centering
    \def\svgwidth{.6\textwidth}
    \includesvg{img/interpolation5}
    \caption{L'inversion de la transformée de \fourier rapide nécessite
    l'interpolation de la grille polaire (ronds rouges) obtenue par le
    théorème de la tranche centrale, à la grille cartésienne (carrés bleus).}
    \label{fig.interpolation}
\end{figure}

La seconde étape en tomographie consiste à inverser l'opération précédente.
Cette opération consiste à déterminer $f$ en tout point de l'espace, c'est à
dire :

\begin{equation}
    \{f(x,y) | (x,y) \ in \RR^2\}\;,
    \label{eqn.radon_inverse}
\end{equation}

\noindent à partir de l'ensemble des projections. \textcite{radon1917akad} a
montré qu'il était possible d'inverser l'opération décrite dans
l'\cref{eqn.mesure.projection.radon}. Pour cela, le théorème de la tranche
centrale peut être utilisé. Ce théorème crée un lien entre la transformation
de \fourier $1$D d'une projection, et la tranche orthogonale à la direction de
projection de la transformée de \fourier $2$D de $f$. La \cref{fig.radon}
illustre la transformation d'une projection de \radon en une tranche du domaine
de \fourier. En utilisant l'ensemble des projections, il est possible de
construire entièrement le domaine de \fourier. Une transformation de \fourier
$2$D inverse de ce domaine permet de reconstruire l'image $f$.

Cependant, la principale limitation de cette méthode réside dans la nécessité
d'interpoler la grille polaire à la grille cartésienne dans le domaine de
\fourier. La \cref{fig.interpolation} illustre ce problème dans lequel il faut
faire correspondre les éléments du repère polaire (ronds rouges) aux éléments
du repère cartésien (carrés bleus). Bien que des méthodes efficaces existent
pour répondre à ce problème\ \cite{averbuch2006fast}, nous verrons dans la suite
de nos travaux, des méthodes qui ne nécessitent pas d'interpolation. Pour
résumer, la reconstruction suit les étapes suivantes :

1. calculer les transformées de \fourier $1$D de chaque projection afin de
remplir la grille polaire;

2. interpoler la grille polaire sur la grille cartésienne;

3. calculer la transformation de \fourier $2$D inverse pour obtenir une version
échantillonnée de $f$.

\noindent Il existe trois raisons pour lesquelles la reconstruction par
la transformation de \radon est un *problème mal posé*, au sens défini par
\textcite{hadamard1902pub}: (i) la solution ne peut être retrouvée puisque les
mesures réalisées lors de l'acquisition intègrent du *bruit* dans les données;
(ii) il n'est de plus pas possible de garantir l'*unicité* de la solution
puisque l'acquisition mesure un nombre fini de projections; (iii) les données
mesurées correspondent à un échantillon de l'image, caractérisé par la distance
des capteurs (dans le cas d'une étude géométrique parallèle). Enfin, une petite
erreur d'acquisition entraîne de fortes variations des résultats.

Dans ce chapitre, nous présenterons des versions exactes et discrètes de la
transformation de \radon. Ces versions exactes reposent sur un échantillonnage
optimal, ce qui permet de ne pas avoir à réaliser d'interpolation lors de la
reconstruction. L'échantillonnage est optimal lorsque les projections couvrent
uniformément l'ensemble des éléments de l'image.
Pour définir ces versions discrètes, nous allons avoir besoin de notions de
géométrie discrète, que nous tacherons de définir dans la prochaine section.


## Quelques bases de la géométrie discrète {#sec.geometrie}

Le procédé permettant de transformer des éléments continus en éléments
discrets est appelé *discrétisation* (ou *numérisation*). Il est ainsi
possible de transformer une fonction continue $f:\mathbb{R}^2 \rightarrow
\mathbb{R}$ en une fonction discrète $f:\mathbb{Z}^2 \rightarrow \mathbb{Z}$.
Nous allons définir ici les notions de géométrie discrète
nécessaires pour comprendre la discrétisation de la transformation de \radon.
Nous étudierons dans un premier temps les aspects topologiques qui nous
permettront de comprendre la représentation discrète de l'image à reconstruire.
Par la suite, nous verrons quelques objets relevant de la géométrie discrète,
comme les angles et les droites, qui nous permettront de définir les droites de
projection. Ces notions sont extraites du livre de
\textcite{coeurjolly2007chap1}.


### Notions topologiques : pavage et connexité dans le domaine discret

\begin{figure}[t]
    \centering
    \def\svgwidth{\textwidth}
    \includesvg{img/pavages4}
    \caption{Représentation des trois pavages réguliers possibles sur
    $\mathbb{Z}^2$ (carré, triangle, hexagone). Le maillage de chaque pavage
    est représenté en gris clair. En particulier, le maillage du pavage carré
    est carré. L'ensemble des voisins d'une cellule (gris foncé) est également
    représenté (en gris). Extrait de\ \cite{coeurjolly2007chap1}}
    \label{fig.pavage}
\end{figure}

Un espace discret $\mathbb{Z}^n$ est une décomposition du plan de dimension
$n \geq 2$ en *cellules*, et l'ensemble de ces cellules forment un *pavage*.
Une cellule peut être représentée par son centre de gravité, que l'on appelle
*point discret*, et l'ensemble des points discrets d'un pavage forme un
*maillage*. Par la suite, on travaillera sur des pavages vérifiant les trois
propriétés suivantes :

% , qui correspond à la forme dual du pavage

1. pavages réguliers : les cellules correspondent à des formes régulières
(i.e.\ des polygones dont tous les côtés et tous les angles sont égaux) et dont
les sommets sont en contact avec un nombre fini de sommets appartenant à
d'autres cellules (ce qui remplit l'espace sans recouvrement);

2. de dimension $2$, c'est-à-dire que l'image correspond à une partie
de $\mathbb{Z}^2$ (par la suite, on pourra utiliser le terme *pixel* pour
désigner les cellules);

3. dont les cellules sont facilement adressables. Pour cela on utilisera un
pavage carré afin d'adresser directement les éléments par un couple de
coordonnées $(x,y)$ (le maillage d'un pavage carré fournit une base orthonormée
contrairement au maillage d'un pavage triangulaire ou hexagonal).

\noindent Par la suite, nous utiliserons un pavage carré semblable à celui
représenté dans la \cref{fig.pavage}. Plus précisément, on considérera une
image numérique comme l'application $f \colon E \to F$, où $E \subset \RR^2$
correspond au domaine de définition de l'image, et $F$ correspond à l'ensemble
des couleurs des pixels. Nous considérerons en général que $E = \ZZ^2$,
c'est-à-dire correspondant à un pavage carré. Le contenu des pixels dépend de
la nature de l'image\footnote{Dans le cas d'une image binaire, l'ensemble
$F=\{0,1\}$. Dans le cas d'une image dont les couleurs sont encodées par RGB,
l'ensemble $F$ correspond à $\{0,255\}^3$.}. Dans le cas général, on
considère $f:\ZZ^2 \to \RR$.

Les notions topologiques dans le domaine discret sont définies à partir de la
notion de *voisinage* et de *connexité*\ \cite{rosenfeld1970acm,
rosenfeld1979tamm}. Soient $P$ et $Q$, deux points définis par leurs
coordonnées $(x,y)$ dans un pavage carré. $P$ et $Q$ sont deux
points voisins si une et une seule de leurs coordonnées diffère d'une unité. En
particulier, le point $P$ possède quatre voisins qui correspondent aux points
de coordonnées $(x-1,y),(x+1,y),(x,y-1),(x,y+1)$. Dans ce cas, on parle de
*$4$-connexité*.
La notion de la connexité permet de définir un *chemin* comme une suite de
points de telle manière que deux points consécutifs de ce chemin soient
voisins.

Pour finir, on définit une *composante connexe* comme étant un ensemble maximal
$S$ de points discrets tel que pour tout couple de points $(P,Q)$ de $S$, il
existe un chemin reliant $P$ à $Q$ dont tous les points appartiennent à $S$.


### Angle discret et droite discrète {#sec.angles}

\begin{figure}[t]
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

Nous allons à présent introduire les représentations discrètes des angles et
des droites. Dans cette section, on cherche à déterminer les points
d'intersection entre le maillage défini par les points d'un ensemble discret de
taille $(N \times N)$, et une droite d'équation $y = ax + b$. Pour que cette
intersection ne soit pas vide, il est nécessaire que la pente de la droite soit
de la forme :

\begin{equation}
    0 \leq \frac{q}{p} \leq 1\;,
    \label{eqn.pente_droite}
\end{equation}

\noindent avec $p,q \in \ZZ$ et où $p$ et $q$ sont des entiers premiers entre
eux, vérifiant $q \leq p \leq N$. L'ensemble des pentes des droites possibles
défini par l'\cref{eqn.pente_droite} sur $[0,\frac{\pi}{4}]$ forment une suite
de Farey d'ordre $N$, notée $F_N$\ \cite{franel1924gdwg}. Les autres droites
sont obtenues par symétrie. Une suite de Farey $F_N$ est l'ensemble des
fractions irréductibles comprises entre $0$ et $1$, ordonnées de manière
croissante et dont le dénominateur n'est pas plus grand que $N$. Chaque
fraction d'une suite de Farey correspond à un vecteur $[p,q]$ de
$\mathbb{Z}^2$. En particulier, \citeauthor{minkowski1968geometrie} a montré
que si l'on considère deux vecteurs de Farey consécutifs de $F_N$, alors il ne
peut y avoir de point dans le parallélogramme formé par ces deux
vecteurs\ \cite{minkowski1968geometrie}. Par exemple, la suite de Farey d'ordre
$3$ permet d'obtenir l'ensemble des pentes possibles pour un pavage de $(3
\times 3)$, et correspond à :

\begin{equation}
    F_3 = \left\{
        \frac{0}{1},
        \frac{1}{3},
        \frac{1}{2},
        \frac{2}{3},
        \frac{1}{1}
    \right\}\;.
    \label{eqn.farey}
\end{equation}

La \cref{fig.farey} représente de manière géométrique les droites issues des
pentes générées par $F_3$ dans un pavage carré de taille $(3 \times 3)$.
Visuellement, une direction $(p,q)$ correspond à la droite reliant le point
d'origine avec le point obtenu par un décalage horizontal de $p$, et par un
décalage vertical de $q$.

Dans la suite de nos travaux, nous utiliserons le terme *direction discrète*
pour désigner le couple d'entier $(p,q) \in \mathbb{Z}^2$, premiers entre eux,
correspondant à la direction de la droite de pente $\frac{q}{p}$. Quant aux
angles discrets, ils seront nécessaires pour définir les versions discrètes de
la transformation de \radon (\cref{sec.frt,sec.mojette}).


## Méthode algébrique de reconstruction d'une image discrète {#sec.inverse}

\begin{figure}[t]
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
    2)$ par un ensemble allant de quatre à six valeurs de projection, calculées
    suivant les directions $(p,q) = \{(0,1),(1,1),(0,1),(-1,1)\}$. Ces valeurs
    de projections correspondent à la somme des valeurs des pixels
    (représentées par les lettre $\{a,b,c,d\}$) traversés par la droite de
    projection.}
    \label{fig.inverse_discret}
\end{figure}

Nous allons dans cette section utiliser une approche algébrique afin
d'introduire le processus de reconstruction d'une image discrète, à partir d'un
ensemble de projections obtenues à différents angles discrets.
La \cref{fig.inverse_discret} représente une image discrète composée de
quatre pixels identifiés par leurs valeurs $\{a,b,c,d\}$. Dans cet
exemple, les valeurs des projections correspondent à la somme des valeurs des
pixels traversés par les droites de projections. Deux questions se posent
alors : (i) est-il possible de déterminer de manière unique la solution du
problème ? (ii) quelle méthode utiliser pour reconstruire cette solution
efficacement ?

Ce problème peut être vu comme un problème d'algèbre linéaire. Dans
cette représentation, les pixels de l'image forment les inconnues à
reconstruire tandis que les projections correspondent aux équations linéaires.
Dans l'exemple proposé de la \cref{fig.inverse_discret_nok}, on souhaite
représenter l'image par ses projections verticales et horizontales. Posons le
problème sous la forme d'un système d'équations linéaires à $4$ équations et
$4$ inconnues, auxquelles on affecte des valeurs aux projections :

\begin{equation}
    \left\{
    \begin{array}{cc}
            a + b &= 5\\
            c + d &= 5\\
            a + c &= 4\\
            b + d &= 6
    \end{array}
    \right\}\;.
    \label{eqn.système}
\end{equation}

On peut écrire ce système d'équations linéaires sous la forme matricielle :
$\textbf{A}x=y$, où $\textbf{A}$ est la matrice de projection de taille $4
\times 4$, $x$ est un vecteur colonne à quatre inconnues et $y$ contient les
valeurs des projections. Cela correspond à la multiplication matricielle
suivante :

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
    \end{pmatrix}\;.
    \label{eqn.ensemble_nok}
\end{equation}

Dans cet exemple, la matrice $\textbf{A}$ n'est pas inversible (son déterminant
est nul). Seulement trois équations du système sur quatre sont
indépendantes. En effet, la somme de la première équation avec la
deuxième est égale à la somme de la troisième avec la quatrième. En
conséquence, la reconstruction depuis ces projections fournit une infinité de
solutions, tant que la valeur d'un pixel n'est pas connue. Autrement dit,
l'ensemble des projections mesurées n'est pas suffisant pour déterminer de
manière unique une solution.
En revanche, un ensemble de projections suffisant est représenté dans la
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
    \end{pmatrix}\;.
    \label{eqn.ensemble_ok}
\end{equation}

Le système comporte à présent $4$ inconnues pour $6$ équations. On est capable
de déterminer de manière unique une solution de reconstruction à travers la
méthode suivante :

\begin{align}
    \textbf{A} x &= y,\\    \label{eqn.inversion}
    \textbf{A}^{\intercal} \textbf{A} x &= \textbf{A}^{\intercal} y,\\
    x &= [\textbf{A}^{\intercal}\textbf{A}]^{-1} \textbf{A}^{\intercal} y,
    \label{eqn.art}
\end{align}

\noindent ce qui donne $(a=1, b=4, c=3, d=2)$. Bien que cette méthode
fonctionne, elle n'est pas efficace. En effet, pour déterminer l'unicité de
la solution, il faut calculer le déterminant de la matrice
$[\textbf{A}^{\intercal} \textbf{A}]$ puis inverser cette matrice, en utilisant
par exemple la méthode de \textsc{Gauss-Jordan}. Une autre méthode consiste à
utiliser la décomposition LU, qui consiste à décomposer
$\textbf{A}$ en deux matrices triangulaires $L$ et $U$ afin de faciliter les
calculs par rapport à la méthode de \textsc{Gauss-Jordan}. Puisque
$\textbf{A}=LU$, $\det \textbf{A} = \det L \det U$, ce qui est simple à
déterminer dans le cas des matrices diagonales. La complexité de calcul du
déterminant est cubique. Une fois la matrix $\textbf{A}$ décomposée, il est
possible de résoudre \cref{eqn.inversion} en $\mathcal{O}(n^2)$ opérations,
pour une matrice carrée de taille $n$. Ces calculs peuvent devenir coûteux
lorsque la taille des images augmentent.


<!--
%par la méthode de
%\textsc{Laplace}. Il faut ensuite inverser cette matrice en utilisant par
%exemple la méthode de \textsc{Gauss-Jordan}, dont la complexité est
%$\mathcal{O}(n^3)$. Enfin, pour déterminer les valeurs de $x$, une
%multiplication matricielle est nécessaire (voir \cref{eqn.art}) dont la
%complexité est $\mathcal{O}(n^3)$ également.
-->

Dans cette section, deux critères d'efficacité ont donc été mis en avant : (i)
la détermination efficace d'un critère de reconstruction (nous avons vu que le
calcul du déterminant est coûteux); (ii) la méthode d'inversion doit avoir une
complexité faible (i.e.\ meilleure que quadratique).
Dans la suite de ce chapitre, nous détaillerons deux méthodes conçues à partir
d'une approche par géométrie discrète. Il s'agit de versions discrètes et
exactes de la transformation de \radon : la FRT et la transformation Mojette
(respectivement étudiées dans les \cref{sec.frt,sec.mojette}).
Plus particulièrement, l'approche par géométrie discrète nous permettra de définir
pour ces deux méthodes, des critères de reconstruction efficaces, ainsi que des
algorithmes de reconstruction de faible complexité.



# Code MDS par transformation de \radon finie {#sec.frt}

Nous avons vu dans la section précédente que la transformation de \radon
continue constitue une application mathématique qui possède une opération
inverse. Cependant, puisque nous allons traiter des données numériques, il est
nécessaire de définir une version discrète de cette application.

Cette section présente la FRT qui est une version discrète et exacte de la
transformation de \radon définie par \textcite{matus1993pami}. La particularité
de cette transformation est de considérer une géométrie périodique,
caractérisée par la taille du support. \matus ont montré que cette
propriété permet de construire un nombre fini de projections. Le calcul de ces
projections, ainsi que la méthode de reconstruction de l'image, seront les
sujets d'étude de la \cref{sec.frt-intro}. La \cref{sec.fantome} permettra de
définir les fantômes, qui sont des éléments du noyau de
la transformée\ \cite{katz1978springer}. Les fantômes ne sont pas spécifiques à
la FRT, aussi nous les réutiliserons par la suite pour la transformation Mojette
(\cref{sec.mojette}), et pour le calcul de nouvelles projections
(\cref{sec.chap6}). \citeauthor{chandra2012tip} ont proposé un algorithme qui
permet de supprimer ces fantômes afin de reconstruire la
donnée\ \cite{chandra2008icpr, chandra2012tip}. Nous étudierons cet algorithme
afin de concevoir un code à effacement. Dans cette section, la présentation des
codes basés sur la FRT repose sur les travaux de \textcite{normand2010wcnc}.
En particulier, ces travaux proposent une mise en œuvre de la FRT qui fournit
un code à effacement MDS.


## Transformation de \radon finie {#sec.frt-intro}

Dans cette première section dédiée à la FRT, nous présenterons tout d'abord
la définition de la transformation, puis nous nous intéresserons à la méthode
de reconstruction de la grille à partir de la transformée, tel que le décrit
\textcite{matus1993pami}.


### Transformation de \radon finie directe

\begin{figure}[t]
    \centering
    \def\svgwidth{.5\textwidth}
    \includesvg{img/frt2}
    \caption{Représentation géométrique des mesures de projection FRT $m=2$.
    La mesure surlignée (en noir), d'index $t=0$, correspond à la somme des
    éléments sur la droite $y \equiv 2 x \pmod 5$ (i.e.\ $p=5,m=2,t=0$). On
    observe que l'ensemble des mesures d'une projection traverse chaque
    pixel de l'image une seule fois. Cette figure est adaptée
    de\ \cite{chandra2008dgci}.}
    \label{fig.frt_line}
\end{figure}

%avant d'être étendue par \citeauthor{svalbe2001laa} 

%\cite{matus1993pami, svalbe2001laa}.

La transformation de \radon finie, pour *Finite Radon Transform* (FRT), est une
version discrète, exacte et périodique de la transformation de \radon continue,
définie mathématiquement par \textcite{matus1993pami}. Considérons une fonction
discrète $f \colon \ZZ^2 \to \RR$, correspondant à une grille carrée de
paramètre $p \in \NN$, où $p$ est premier. Les valeurs de projections
$[Rf](m,t)$ sont définies ainsi :

% $$ \left \{

\begin{align}
    [Rf](m,t)  &= \sum_{x=0}^{p-1} \sum_{y=0}^{p-1} f(x,(mx + t) \pmod{p}),
    \label{eqn.frt}\\
    [Rf](p,t)  &= \sum_{x=0}^{p-1} \sum_{y=0}^{p-1} f(t, y),
    \label{eqn.frt_p}
\end{align}

% \right. $$

\noindent avec $x,y,m,y \in \mathbb{Z}_p$. La variable $t$ correspond à
l'index de l'élément dans la projection. De manière géométrique, elle
correspond à la valeur de translation de la projection suivant l'axe des $y$.
Quant à $m$, elle représente la pente de la droite de projection.
Notons que l'\cref{eqn.frt} qui calcule les $n$ premières
projections, contient un opérateur modulo permettant de rendre les droites de
projection périodiques, de période $p$. Quand à l'\cref{eqn.frt_p}, elle
calcule la $(p+1)$-ème projection qui correspond à la somme des éléments de la
grille suivant l'horizontale.
Dans le domaine de \radon, chacune des $(p+1)$ projections indexées par $m$
contient $p$ valeurs correspondant à un décalage de $t$ suivant l'axe des $y$.
La \cref{fig.frt_line}, \cpageref{fig.frt_line} représente l'une de ces mesures
pour la droite d'équation $y \equiv 2 x \pmod 5$ sur un pavage carré défini par
$p=5$, avec $t=0$. Dans le cas général, ces droites de projection ont pour
équation :

\begin{equation}
    y \equiv m x + t \pmod p\;.
    \label{eqn.frt_line}
\end{equation}

\textcite{matus1993pami} ont montré que les $(p+1)$ projections définies aux
\cref{eqn.frt,eqn.frt_p} permettent d'échantillonner parfaitement l'image.
En effet puisque $p$ est premier, les mesures d'une projection parcourent
l'ensemble des pixels une et une seule fois. La \cref{fig.frt} illustre cela
pour les $5$ mesures de la projection $m=2$. En conséquence, la somme des
valeurs d'une projection correspond à la somme des pixels de l'image. Cette
valeur, notée $I_{sum}$ sera utilisée dans la suite.

\begin{figure}[t]
	\centering
    \def\svgwidth{.7\textwidth}
    \includesvg{img/frt_retro}
	%\input{tikz/frt.tex}
	\caption{Représentation de la FRT et de sa rétroprojection. (a) on applique
	la FRT sur une image carrée de paramètre $p=3$. Les valeurs des pixels sont
	symboliques : $\{a, b,\dots, i\}$. (b) correspond à la transformée,
	c'est-à-dire aux $p+1=4$ projections. Un exemple de mesure est ici
	représenté par les valeurs encerclées. Il s'agit du calcul de FRT pour $t=0$
	et $m=2$ (i.e.\ la pente vaut deux). La juxtaposition des lettres indique
	leur somme. Par exemple, $afh$ correspond à la somme $a+f+h$. (c)
	représente la rétroprojection $f'$. On remarque que chaque élément
	est composé de $I_{sum}$ et de $p$ fois la valeur initiale du pixel.}
	\label{fig.frt}
\end{figure}

La \cref{fig.frt} montre la FRT d'une image $(3 \times 3)$ dans laquelle la
valeur des pixels correspond à des lettres. En particulier, les pixels en jeu
dans le calcul de la mesure $[Rf](m=2,t=0)$ sont encerclés.
<!--
%La valeur de cette projection
%correspond à la somme des éléments de l'image en partant de $a$ (i.e.\ $t=0$)
%et en se décalant de $m=2$ pixels sur la droite quand on descend d'une ligne
%(la pente m=$\frac{q}{p}=\frac{2}{1}$). On remarque sur la troisième ligne
%l'effet périodique du support, ainsi que le retour sur le pixel $a$ à
%l'itération suivante.
-->
Pour l'inversion, il est nécessaire d'avoir $(p+1)$ projections afin de pouvoir
reconstruire une image $(p \times p)$\ \cite{matus1993pami}. Dans la suite, nous
détaillons une méthode de reconstruction de l'image algébrique.


### Reconstruction de l'image par FRT inverse

La méthode de FRT inverse permet de retrouver l'image initiale à partir des
données de projections. Chaque paire de pixels distincts n'apparaît que dans
une mesure de projection puisque $p$ est premier. Par exemple $a$ et $h$
n'apparaissent que dans la combinaison $a+f+h$. En conséquence, la somme de
toutes les mesures issues d'un pixel contient : (i) $p+1$ fois ce pixel ($p+1$
étant le nombre de directions distinctes, donc le nombre de mesures qui
contiennent ce pixel); (ii) et une fois et une seule chacun des autres pixels
de l'image. \textcite{matus1993pami} proposent une méthode
d'inversion basée sur le fait que l'opérateur FRT est son propre dual.
Dans ce cas, l'inversion implique de réaliser une rétroprojection. Cette
opération consiste à appliquer l'opérateur FRT sur la transformée $[Rf](m,t)$,
le long des droites de projection
$\mathcal{L}_{m^{\prime}, t}$ d'angle $m^\prime = p-m$ (i.e.\ opposé à $m$).
On obtient une image $f^\prime$ dont chaque valeur des pixels correspond à
$f^\prime(x,y) = (f(x,y) \times p) + I_{sum}$, où $f(x,y)$ est la valeur
d'origine de l'élément $(x,y)$, et $I_{sum}$ correspond à la somme de tous les
pixels de l'image. Une représentation de la rétroprojection $f'$ est donnée
dans la partie droite de la \cref{fig.frt}. L'image initiale $f$ est alors
retrouvée en filtrant l'image de rétroprojection par la soustraction des
valeurs de ses pixels par $I_{sum}$, puis par la division par $p$. L'équation
correspondante à cette opération inverse est la suivant :

\begin{align}
    f(x,y)  &=
        \frac{1}{p}\left(
            f'(x,y) - I_{sum} \right),\\
			&=
		\frac{1}{p}\left(
			\sum\limits_{\mathcal{L}_{m^{\prime},t}}
			[Rf](m^{\prime},t) + [Rf](p,x) - I_{sum}
        \right).
    \label{eqn.frt_inverse}
\end{align}

Bien que simple à mettre en œuvre, cette méthode n'est pas efficace
puisque sa complexité algorithmique est $\mathcal{O}(p^3)$.
\textcite{matus1993pami} ont cependant démontré que la FRT conserve toutes les
propriétés de la transformation continue de \radon. En particulier, ils
définissent mathématiquement une version discrète du théorème de la tranche
centrale. Comme vu précédemment dans le domaine continu, ce théorème permet de
faire le lien entre la transformation de \fourier $1$D d'une projection, et la
tranche orthogonale dans le domaine de \fourier de $f$. La différence
principale avec la transformation de \radon continue est que l'échantillonnage
optimal de la FRT permet de recouvrir entièrement le domaine de \fourier sans
avoir besoin d'interpolation. La reconstruction consiste alors à (i) calculer
la transformée $1$D de \fourier pour chaque projection afin de remplir l'espace
de \fourier; (ii) calculer la transformée de \fourier $2$D inverse pour obtenir
l'image. Il est ainsi possible de réduire la complexité à celle de la FFT,
i.e.\ $\mathcal{O}(p^2 \log_2 p)$\ \cite{kingston2006aiep}.
\textcite{chandra2014ietcv} ont proposé une extension de cette méthode, basée
sur la transformation de \fourier modulaire. Cette méthode permet de remplacer
une racine complexe de l'unité par une racine entière de l'unité.


## Représentation partielle et fantôme discret {#sec.fantome}

Les travaux de \textcite{matus1993pami} ont montré que les $(p+1)$ projections
sont nécessaires pour déterminer de manière unique la solution du problème de
reconstruction. En conséquence, une représentation partielle correspond au cas
où l'ensemble de projections n'est pas suffisant pour reconstruire l'image de
manière unique. Dans cette situation, le problème de reconstruction devient
sous-déterminé et possède soit plusieurs solutions, soit aucune. Pour
comprendre cette situation, nous nous intéresserons à l'*espace nul* qui
correspond au noyau de l'opérateur. Plus particulièrement, nous étudierons
les *fantômes* qui correspondent aux éléments de cet espace nul.


### Introduction aux fantômes

Dans le domaine continu, \textcite{bracewell1954ajp} définissent le concept de
*distribution invisible*, qui fait référence au terme *fantôme*, utilisé plus
tard par \textcite{cornwell1982sm} dans le cas de la transformation de \radon.
D'une manière générale, on définit un fantôme comme une fonction $g \colon
\RR^2 \to \RR$ telle que\ \cite{bracewell1956ajp} :

\begin{equation}
    \int_\mathcal{L}g(x,y)d\ell = 0\;.
    \label{eqn.ghost}
\end{equation}

%Ils ont été étudiés pour la première fois dans le

%contexte de l'astronomie par \citeauthor{cornwell1982sm,

%bracewell1956ajp} \cite{cornwell1982sm,bracewell1956ajp}. 

\noindent Les fantômes correspondent ainsi à des éléments dont la somme vaut
$0$ suivant la direction de projection $\mathcal{L}$\footnote{le nom "fantôme"
fait référence au fait que ces éléments sont invisibles dans l'espace de
\radon}. De manière analogue, ils correspondent à des éléments de l'image
générés dès lors que des projections manquent.
Dans la pratique, puisque la transformation de \radon continue est un problème
*mal posé*, il existe toujours des projections manquantes (à cause de
l'échantillonnage dû à la nature des capteurs). En conséquence, les fantômes
empêchent l'aboutissement du processus de reconstruction vers une solution
unique. De par sa définition, un fantôme correspond à une distribution de la
valeur de projection manquante sur les pixels de l'image, selon un motif
particulier.

Dans le domaine discret, on définit l'espace nul FRT comme étant le noyau de
l'opérateur FRT $[R]$, c'est-à-dire, l'ensemble des éléments de l'image tel
que leur projection suivant une pente $m$ vaut $0$ :

\begin{equation}
    ker(R) = \left\{ g \colon Z_p^2 \to \RR \mid [Rg](m,t) = 0 \right\}\;.
    \label{eqn.frt_nul}
\end{equation}

\noindent Les fantômes ont un rôle essentiel dans la compréhension des
transformées et dans l'élaboration des méthodes de reconstruction à partir
d'une représentation partielle. Nous nous intéresserons plus particulièrement
aux travaux de \textcite{chandra2008dgci} qui étudient la structure des
fantômes afin de comprendre comment ils se superposent sur l'image. Nous
verrons par la suite une méthode pour supprimer les fantômes de l'image et
ainsi reconstruire sa valeur initiale.


### Structure des fantômes et distribution sur l'image

\begin{figure}[t]
	\centering \input{tikz/espace_fantome.tex}
	\caption{Représentation des distributions circulantes des fantômes
	${a, b,	c}$ générés par l'effacement respectif des projections $m={1,3,4}$.
	Les grilles de gauche correspondent à la superposition des fantômes sur une
	image $(5 \times 5)$ après reconstruction depuis les projections FRT de
	droite. Chaque étape correspond à un nouvel effacement, représenté par une
	ligne colorée. Figure inspirée de \textcite{chandra2008dgci}.}
	\label{fig.espace_fantome}
\end{figure}

Par définition, l'effacement d'une projection FRT entraîne la création d'un
fantôme dans l'image. Afin de déterminer des méthodes de reconstruction de
l'image en cas de perte de projections, il est nécessaire d'en déterminer la
structure. Soit une projection $a = \{a_0, \dots, a_{p-1}\}$ d'index $m_a$ de
l'espace de \radon $[Rf]$.
\textcite{chandra2008dgci} ont montré que la reconstruction de l'image à partir
d'un domaine de \radon partiel (où la projection $a$ est manquante) entraîne
une distribution circulaire des valeurs de $a$ sur l'image.
La \cref{fig.espace_fantome} montre la distribution des valeurs du fantôme dans
une image $(5 \times 5)$ lorsque la représentation de l'image par les
projections est partielle. Dans cette figure, la première représentation
correspond à la situation où la projection $m=1$ est manquante. Dans ce
cas, on remarque que les valeurs de la projection $a$ se superposent à l'image,
avec un décalage circulaire de $m_a$ sur chaque ligne de l'image.

\textcite{chandra2012tip} ont par la suite démontré que cette structure est
caractérisée par une matrice circulante. Plus particulièrement, chaque
projection manquante entraîne la génération d'une nouvelle distribution de
fantômes dont les décalages sont caractérisés par l'index de cette projection.
Ainsi, lorsque plusieurs projections manquent dans le domaine de \radon,
l'image contient une superposition de ces distributions.
La \cref{fig.espace_fantome} montre le cas où deux puis trois projections sont
manquantes. Dans la suite, nous nous intéresserons aux méthodes de résolution
qui permettent de supprimer ces fantômes afin de reconstruire l'image à partir
d'un espace de \radon partiel.


### Reconstruire l'information manquante

Plusieurs algorithmes ont été proposés pour reconstruire l'image à partir d'une
représentation partielle\ \cite{chandra2008dgci, normand2010wcnc}. La première
méthode de reconstruction proposée par \textcite{chandra2008dgci}
consiste à supprimer les fantômes dans l'image afin de retrouver la valeur
initiale. Cette méthode nécessite de connaître a priori une partie de l'image.
\textcite{chandra2008dgci} proposent de calibrer une zone de $r$ lignes de
l'image à zéro afin de pouvoir isoler la valeur des fantômes dans cette
zone lors de la reconstruction. Il est ainsi possible de supporter la
perte de $r$ projections.

Dans le cas où une seule projection manque, la valeur de ses éléments
est alors directement lisible sur chaque ligne de redondance. Il faut cependant
considérer le décalage circulaire dû à la structure circulaire de la
distribution des fantômes. Ce décalage est caractérisé par $m_a$ et l'index de
la ligne, comme le montre la première représentation de la
\cref{fig.espace_fantome}.
Lorsque plusieurs projections manquent, le processus de reconstruction proposé
par \textcite{chandra2008dgci} se complique. Il met en jeu trois opérations
pour la détermination d'une projection : (i) un décalage cyclique sur chaque
ligne afin de synchroniser le premier élément $a_0$ des fantômes sur le
premier pixel de chaque ligne; (ii) la soustraction des lignes afin d'enlever
la contribution du fantôme dans ces lignes de redondance; (iii) une intégration
des valeurs obtenues afin de supprimer le décalage généré par la soustraction
précédente. Pour le lecteur qui souhaite plus d'informations sur cette méthode,
toutes les étapes sont clairement indiquées dans les travaux de
\textcite{chandra2008dgci}.



## Code à effacement par transformation de \radon finie {#sec.fecfrt}

Cette section décrit à présent comment utiliser la FRT comme un code à
effacement. Plusieurs travaux ont été réalisés pour définir ce code sous une
forme systématique, et non systématique \cite{normand2010wcnc,
parrein2012isccsp, pertin2012isivc}.


### Forme non-systématique

\begin{figure}[t]
    \centering
    \def\svgwidth{.7\textwidth}
    \includesvg{img/frt_design_non-sys}
    \caption{Représentation de la mise en œuvre du code à effacement
    non-systématique basé sur la FRT. La colonne de parité correspond à une
    contrainte pour concevoir un code MDS. Les données encodées
    correspondent aux $p$ projections de l'espace de \radon. Figure inspirée
    depuis \cite{normand2010wcnc}.}
    \label{fig.frt_non-sys}
\end{figure}

La \cref{fig.frt_non-sys} représente la mise en œuvre de la FRT en
non-systématique. Dans l'objectif d'obtenir un espace de \radon de même taille
que l'image, on impose une contrainte de conception qui consiste à faire
correspondre la dernière colonne à une colonne de parité.
Cela entraîne deux conséquences : (i) la dernière projection est nulle
de part la parité horizontale; (ii) la dernière colonne du domaine
transformé correspond également à un colonne de parité. En conséquence, il
n'est alors pas nécessaire de garder ces informations.

Le code non-systématique est alors conçu de la manière suivante. La donnée est
rassemblée dans une zone de taille $k \times (p-1)$. On représente $r$ lignes
(*imaginaires* dans l'implémentation) contenant des valeurs nulles. La colonne
de parité permet de limiter notre représentation de l'image avec $p$
projections, qui correspondent à l'ensemble des données encodées dans ce
formalisme.

Lorsque des effacements surviennent sur ces données encodées, cela se traduit
par la suppression de certaines projections. Comme expliqué précédemment, la
reconstruction de l'image par cette représentation partielle va générer des
fantômes sur l'ensemble de l'image. En particulier, la valeur de ces fantômes
est contenue dans les $r$ lignes de redondance (puisqu'elles contenaient
uniquement des valeurs nulles précédemment). Si le nombre d'effacement est
au plus $r$, on peut utiliser une technique de suppression des fantômes, telle
que celle décrite précédemment, pour reconstruire la zone de $k \times (p-1)$
éléments de données.


### Forme systématique

\begin{figure}[t]
    \centering
    \def\svgwidth{.7\textwidth}
    \includesvg{img/frt_design_sys}
    \caption{Représentation de la mise en œuvre du code à effacement
    systématique basé sur la FRT. Les données encodées correspondent aux $k$
    lignes de données auxquelles on ajoute $r$ lignes de redondance.}
    \label{fig.frt_sys}
\end{figure}

La mise en œuvre du code systématique est illustrée dans la \cref{fig.frt_sys}.
Le principe de cette mise en œuvre est d'intégrer les $k$ lignes
de données dans l'ensemble des $p$ lignes encodées.
La construction de cette version du code est semblable à ce que l'on a vu
précédemment. La différence réside dans la zone de redondance. Il est
nécessaire de définir $r$ lignes de redondance de telle sorte que $r$
projections contigües soient nulles. En conséquence, l'image devient un fantôme
pour les projection. Puisque l'opérateur FRT est son propre dual, cette
opération correspond à générer des fantômes dans l'image. Une méthode pour
déterminer la valeur de ces fantômes correspond à supprimer $r$ fantômes dans
le domaine de \radon. On peut utiliser la technique de suppression proposée par
\textcite{chandra2008dgci} par exemple.

Quand des effacements suppriment des lignes de données, des fantômes sont
générés parmi les projections. On utilise alors le même algorithme que
précédemment pour retrouver la valeur des données.



## Relations avec d'autres codes MDS

La FRT possède des liens avec certains codes MDS. \textcite{normand2010wcnc}
ont montré que l'opérateur FRT peut être représenté sous la forme d'une matrice
de \vander. Cette représentation est également utilisée pour définir les codes
de \rs\ \cite{reed1960jsiam}. Quant aux Array codes, nous verrons qu'au delà de
partager une approche géométrique, ils représentent un cas particulier de la
FRT.


### Relation algébrique avec les codes de \rs

Les travaux de \textcite{normand2010wcnc} offrent une représentation
polynomiale de l'image $f$ et de l'opérateur FRT. Plus précisément, l'image est
représentée un vecteur de $p$ polynômes, où chaque polynôme $P(x)$ de degré 
$p$ représente une ligne. On note $\boldsymbol{f}$ le vecteur polynomial
représentant l'image, défini tel que : 

\begin{equation}
    \boldsymbol{f}^{\intercal} = \left(P_0, \dots, P_{p-1}\right)\;,
    \label{eqn.image_poly}
\end{equation}

\noindent avec $P_i(x) = f(0,i)x^0 + \dots + f(p-1,i)x^{p-1}$, et
$\boldsymbol{f}^{\intercal}$ correspond à la transposée de $\boldsymbol{f}$.

Le support étant périodique de période $p$, on a $(p,p) = (0,0)$. Cela signifie
que pour chaque projection $x^p \equiv x^0$. En conséquence, les polynômes $P_i
\mid i \in Z_p$ sont définis $\pmod{x^{p} - 1}$.
Dans cette représentation, la multiplication d'un polynôme par $x$ est
équivalent à un décalage cyclique de la ligne associée. En particulier,
l'opérateur FRT $R_m$ correspond à une application qui somme les éléments de
l'image après avoir appliqué des décalages circulaires $ml$ sur chaque ligne
$l$. On définit alors l'opérateur ainsi :

\begin{equation}
    R_m(x) = P_0(x) + x^{-m} P_1(x) + \dots + x^{-(p-1)m} P_{p-1}(x)\;,
    \label{eqn.frt_poly}
\end{equation}

\noindent avec $m \in \{0,\dots,p-1\}$. Il est possible de poser ce problème
sous une forme matricielle :

\begin{equation}
    R_m(\boldsymbol{f}) =
    \begin{pmatrix}
        1 & 1 & \cdots & 1\\
        1 & x^{-1} & \cdots & x^{-(p-1)}\\
        \vdots & \vdots & \ddots & \vdots \\
        1 & x^{-(p-1)} & \cdots & x^{-(p-1)^2}\\
    \end{pmatrix}
    \times
    \begin{pmatrix}
        P_0(x)\\
        P_1(x)\\
        \vdots\\
        P_{p-1}(x)\\
    \end{pmatrix}\;,
    \label{eqn.vanderFRT}
\end{equation}

\noindent avec $m \in \ZZ_p$ (voir \cref{eqn.frt}). Les coefficients de $R_m$
correspondent aux coefficients d'une matrice de \vander $\boldsymbol{R} =
\boldsymbol{V}(x^{-0}, \dots, x^{-(p-1)})$. Toute sous matrice d'une matrice de
\vander est inversible. En conséquence, on est capable de reconstruire $r$
lignes manquantes en inversant la matrice dont les coefficients correspondent à
ces lignes. \textcite{normand2010wcnc} proposent d'inverser la matrice en
utilisant la décomposition LU\ \cite{turner1966inverse}.


% résolution \rs par lacan sans multiplication

% représentation algébrique par normand

% ### Relation géométrique avec les Array codes

% cas particulier de la FRT



\subsubsection*{Bilan de la FRT}

Nous avons vu que la FRT correspond à une version discrète, exacte et
périodique de la transformation de \radon continue. Cette propriété lui permet
de fournir un code MDS en se basant sur une contrainte de construction mettant
en jeu une colonne de parité, et un calibrage des données correspondant à des
lignes de redondance. En particulier, nous avons vu deux algorithmes de
reconstruction efficaces : (i) en utilisant la FFT depuis le théorème de
tranche centrale; (ii) par la méthode de suppression des fantômes.
Ces méthodes ont ainsi permis de déterminer deux versions de code à
effacement selon une construction systématique et non-systématique.

Dès lors, la FRT peut tout à fait être mise en œuvre dans un contexte de
transmission et de stockage de l'information. Dans ce contexte, la propriété
MDS du code à effacement par FRT permet de générer une quantité minimum de
redondance pour fournir une certaine tolérance à l'effacement. Dans une autre
mesure, l'efficacité des algorithmes proposés permettent une implémentation
performante des opérations d'encodage et de décodage.

% ouverture sur la mojette non MDS mais qui poutre encore plus mieux



# Code à effacement par transformation Mojette {#sec.mojette}

Dans cette section, nous allons nous intéresser à un code à effacement basé sur
la transformation Mojette. Tout comme la FRT, cette transformation correspond à
une version discrète et exacte de la transformation de \radon continue définie
dans \textcite{radon1917akad}. Elle a été proposée pour la première fois par
\textcite{guedon1995vcip} dans le contexte du traitement et du codage
psychovisuel. Depuis, cette transformation a été utilisée dans de nombreuses
applications liées à l'imagerie numérique (codage, transmission, tatouage).
Dans cette thèse, nous proposons de l'utiliser comme code à effacement pour le
stockage et la transmission d'information.

Nous décrirons en \cref{sec.mojette-forward} la méthode de calcul des
projections Mojette, qui se distinguent des projections FRT par leur géométrie
apériodique. Nous verrons que ces projections peuvent fournir une
représentation redondante de l'image, nécessaire pour tolérer des effacements.
La \cref{sec.mojette-inverse} présentera le critère défini par
\textcite{katz1978springer} permettant de garantir l'unicité de la solution de
reconstruction d'une image rectangulaire, et nous verrons que ce critère est
nécessaire pour définir la capacité de reconstruction du code à effacement. La
méthode de reconstruction de \textcite{normand2006dgci} sera également étudiée,
et sera utilisée dans le processus de décodage afin de reconstruire
l'information. Après cette présentation de la transformation Mojette, nous
verrons comment ces éléments permettent de concevoir un code à effacement dans
la \cref{sec.fecmojette}.


## Transformation Dirac-Mojette directe {#sec.mojette-forward}

\begin{figure}[t]
    \centering
    \def\svgwidth{.7\textwidth}
    \includesvg{img/mojette_forward_xor3}
    \caption{Représentation de la transformée Mojette dans $\FF_2$. On
    considère une grille d'image $P \times Q = 3 \times 3$ sur laquelle nous
    calculons $4$ projections dont les directions $(p_i,q_i)$ sont comprises
    dans l'ensemble $\left\{(-1,1), (0,1), (1,1), (2,1)\right\}$. La base
    utilisée est représentée par les deux vecteurs unitaires $\vec{u}$ et
    $\vec{v}$.}
    \label{fig.mojette_directe}
\end{figure}

La transformation Mojette est une opération linéaire définie par
\textcite{guedon1995vcip} qui calcule un ensemble de $I$ projections à partir
d'une image discrète
$f:\ZZ^2 \mapsto\mathbb R$. Bien que cette image discrète peut avoir n'importe
quelle forme, nous considèrerons dans la suite une image rectangulaire,
composée de $P \times Q$ pixels. Une projection Mojette $\M$ est
un ensemble d'éléments appelés *bins*, qui est définie par une direction de
projection $(p,q)$, avec $p,q \in \ZZ$ premiers entre eux (comme expliqué en
\cref{sec.angles}). La transformée Dirac-Mojette $\moj{}{f}$ est définie par
\textcite{guedon1995vcip} comme l'ensemble de projections suivant :

\begin{equation}
    \moj{\{b,p_{i},q_{i}\}}{f} =
        \sum_{k=0}^{Q-1} \sum_{l=0}^{P-1}
        f \left(k,l\right)
        \Delta\left(b-lp_{i}+kq_{i}\right)\;,
    \label{eqn.mojette}
\end{equation}

\noindent où $\Delta(\cdot)$ vaut $1$ si $b=lp_{i}-kq_{i}$ et $0$ sinon.
Le paramètre $b$ correspond à l'index du bin de la projection d'angle
$(p_i,q_i)$. Plus précisément, \cref{eqn.mojette} signifie que la valeur des
bins de la projection suivant la direction $(p_i, q_i)$ résulte de la somme des
pixels situés sur la droite discrète d'équation $b = -kq_i + lp_{i}$.
Comme on peut l'observer, l'opération modulaire que l'on avait utilisée dans
l'\cref{eqn.frt} de la FRT, n'est pas utilisée ici. Cette propriété apériodique
distingue les deux transformations.

La \cref{fig.mojette_directe} représente la transformée Mojette sur $\FF_2$
d'une grille discrète $(3 \times 3)$ composée d'éléments binaires. Le
traitement transforme une image 2D en un ensemble de $I=4$ projections dont les
valeurs des directions sont comprises dans l'ensemble suivant : $\left\{(-1,1),
(0,1), (1,1), (2,1)\right\}$. Dans l'objectif de simplifier la représentation
de cet exemple et des suivants, nous avons choisi le corps $\FF_2$, dont
l'addition, noté $\oplus$, correspond à un OU exclusif. Cependant, on peut
considérer n'importe quel groupe abélien.
<!--
%la somme peut être définie
%en utilisant l'arithmétique élémentaire ou modulaire.
-->

Dans l'exemple de la projection de direction $(p=0, q=1)$, chaque bin résulte
de l'addition des pixels de la grille suivant la direction verticale. Par
exemple, le premier bin, situé tout à droite de la projection, vaut
$1 \oplus 0 \oplus 1 = 0$.
Les autres projections ont la particularité d'avoir une pente non nulle. Par
exemple, la valeur des bins des projections d'angles $(-1,1)$ et $(1,1)$
correspond à la somme des pixels suivant les diagonales. En particulier,
on remarque que les bins situés aux extrémités des ces projections 
sont entièrement définis par un seul pixel. Cette remarque sera nécessaire afin
de comprendre comment s'applique l'algorithme de reconstruction de
\textcite{normand2006dgci} que l'on détaillera dans la prochaine section.
Du point de vue de la complexité, puisqu'il faut $\mathcal{O}(I)$ opérations
par pixel et que chaque pixel est parcouru, la complexité de la transformation
Mojette vaut $\mathcal{O}(PQI)$. \textcite{normand1996vcip} précisent que si le
nombre de projections $I$ correspond à $log(PQ)$, alors la complexité de la
Mojette correspond à celle de la FFT de \textcite{cooley1969tae}.

%4+5+1 \pmod 6 = 4$


## Reconstruction par transformation Mojette {#sec.mojette-inverse}

Dans cette section, nous présenterons le critère défini par
\textcite{katz1978springer} qui permet de déterminer si un ensemble
de projections est suffisant pour reconstruire de manière unique l'image. Par
la suite, nous présenterons l'algorithme de reconstruction de
\textcite{normand2006dgci}.


### Critères de reconstruction

Le premier critère permettant de garantir l'existence d'une solution unique de
reconstruction est le critère de \textcite{katz1978springer}. Ce critère
n'est défini que pour des images rectangulaires $P \times Q$. Étant donné un
ensemble de directions de projection $\left\{(p_i,q_i)\right\}$, le critère
de \citeauthor{katz1978springer} déclare que si l'une des conditions suivantes
est remplie :
\begin{equation}
    \sum\limits_{i=1}^I{|p_i|}\geq P
    \text{ ou }
    \sum\limits_{i=1}^I{|q_i|}\geq Q\;,
    \label{eqn.katz}
\end{equation}
\noindent alors il existe une unique solution de reconstruction, et cette
solution contient les valeurs de la grille qui ont permis de calculer ces
projections. Ce critère a été étendu par \textcite{normand1996vcip} pour
n'importe quelle image convexe en utilisant la définition des fantômes.

Dans l'exemple de la \cref{fig.mojette_directe}, si l'on considère un
sous-ensemble de $3$ projections $\left\{(p_{0},q_{0}), \dots,
(p_{2},q_{2})\right\}$, la seconde condition du critère
de \citeauthor{katz1978springer} donne $\sum_{i=0}^2~|q_{i}|=3$, puisque $q=1$
pour chaque direction de projection. En conséquence, $3$ projections parmi les
$4$ calculées dans cet exemple suffisent pour reconstruire l'image de manière
unique. Autrement dit, la perte d'une projection n'influence pas le résultat du
processus de reconstruction. On considère alors que les $4$ projections
calculées dans cette figure décrivent une représentation redondante de l'image.

<!--
%\begin{figure}
%    \centering
%    \def\svgwidth{.4\textwidth}
%    \includesvg{img/katz_normand}
%    \caption{Représentation du critère de \textcite{normand1996vcip}.
%    L'ensemble $\{(1,0),(2,1),(1,1)\}$ n'est pas suffisant contrairement à
%    l'ensemble $\{(1,1),(1,2),(1,2)\}$ dont la somme des vecteurs n'est pas
%    contenu dans l'image. Extrait de \cite{guedon2009mojettebookchap4}}.
%    \label{fig.katz.normand}
%\end{figure}
-->

Alors que le critère de \citeauthor{katz1978springer} ne s'applique que sur une
image rectangulaire, \textcite{normand1996vcip} ont étendu ce critère à
n'importe quelle forme convexe.

<!--
%Pour cela, on utilise une représentation
%géométrique de l'ensemble de projection. Plus particulièrement, un ensemble de
%projections $\{(p_i,q_i) \mid i \in \ZZ_I\}$ est suffisant pour reconstruire de
%manière unique l'image si la somme des vecteurs $\vec{a} = (|p_i| \vec{u} +
%|q_i| \vec{v})$ ne peut être contenue dans l'image. La \cref{fig.katz.normand}
%illustre deux sommes de vecteurs construites à partir de deux ensembles
%distincts dont l'un est suffisant (puisque la somme sort de l'image), et
%l'autre non.
-->


### Algorithme de reconstruction

Plusieurs algorithmes de reconstruction Mojette ont été
proposés\ \cite{normand1996vcip, normand2006dgci, servieres2005spie} et sont
résumés dans\ \cite{guedon2009mojettebookchap5}. Nous choisissons de
décrire dans la suite, l'algorithme itératif d'inversion Mojette par balayage
(*Balayage Mojette Inversion*, BMI) de \textcite{normand2006dgci} pour son
efficacité. Nous verrons en effet que la complexité de décodage d'un symbole
est linéaire. Il sera en effet utilisé pour décoder l'information
dans le code à effacement, et servira également dans la compréhension de
génération de nouvelles projections dans le \cref{sec.chap6}. Bien que le sens
de reconstruction est arbitraire, nous considèrerons dans la suite, une
reconstruction de gauche à droite comme proposé par \textcite{normand2006dgci}.

Chaque droite de projection correspond à une équation faisant intervenir un bin
et un ensemble de pixels. Dans la section précédente, nous avions observé que
les pixels situés dans les coins de la grille définissent entièrement les bins
correspondants dans les projections dont la pente n'est pas nulle (i.e.\ tel
que $p$ ou $q$ est différent de $0$).
Les autres pixels de la grille en revanche, interviennent avec d'autres
éléments de l'image dans le calcul des bins de projections. Les droites de
projections définissent des équations dont les inconnues correspondent aux
pixels qui n'ont pas encore été reconstruits. Il est possible de reconstruire
la valeur d'un pixel lorsqu'il est le seul inconnu de l'équation définie par la
droite de projection. En conséquence, il existe des dépendances entre les
pixels.

\begin{figure}[t]
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

Il est possible de représenter ces dépendances en utilisant un graphe.
La \cref{fig.dep_graph} est un graphe orienté qui représente les dépendances entre
les pixels d'une grille $3 \times 3$, étant donné un ensemble de directions de
projection $\left\{(1,1), (0,1), (-1,1)\right\}$. Les nœuds de ce graphe
correspondent aux pixels tandis que les arêtes représentent leurs dépendances.
Il est ainsi possible de déterminer la valeur d'un pixel seulement
lorsqu'aucune dépendance ne s'applique sur lui (i.e.\ aucune arête du graphe
n'y parvient).

Afin d'assurer qu'aucune itération ne bloque l'algorithme, on affecte la
reconstruction de chaque ligne à une seule projection. Par exemple dans la
\cref{fig.dep_graph}, la projection suivant la direction $(1,1)$ est affectée à
la reconstruction de la première ligne. L'attribution des projections aux
lignes se fait de sorte que $p_i$ décroît en même temps que l'index de la ligne
augmente. Il est alors possible de déterminer un chemin dans ce graphe qui
décrit les différentes itérations qui permettent de reconstruire entièrement
l'image (plusieurs chemins peuvent exister). En particulier, chaque itération
permet de déterminer la valeur d'un pixel, permettant en conséquence de réduire
les dépendances appliquées sur les autres.
Dans l'exemple de la \cref{fig.dep_graph}, une itération possible consiste à :

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

\noindent Une fois cette première colonne reconstruite, il est possible de
répéter l'itération sur les colonnes suivantes (jusqu'à reconstruire
entièrement la grille).
En pratique, ces éléments correspondent à des zones mémoires contigües. En
particulier, les bins des projections interviennent de manière séquentielle
dans la reconstruction d'une ligne. Cette considération permet de favoriser la
localité spatiale des données et donc les performances de l'implémentation.


### Reconstruction à partir d'une représentation partielle

Lorsque l'ensemble de projections ne satisfait pas le critère de \katz
(\cref{eqn.katz}), le problème de reconstruction est sous-déterminé. En
conséquence, la reconstruction par une représentation partielle conduit à
plusieurs ou aucune solution.
Comme nous l'avons vu précédemment avec la FRT, les fantômes correspondent aux
éléments de l'espace nul. On définit un fantôme élémentaire ainsi :

\begin{equation}
    \ghost{(p,q)}:p\mapsto\begin{cases}
        1 &\text{si }p=(0,0)\\
        -1&\text{si }p=(p,q)\\
        0 &\text{sinon}.
    \end{cases}\;.
\end{equation}

\begin{figure}[t]
    \centering
    \def\svgwidth{.2\textwidth}
    \includesvg{img/fantome_elementaire}
    \caption{Fantôme élémentaire selon la direction $(p,q) = (2,1)$.}
    \label{fig.fantome_elementaire}
\end{figure}

\noindent Sur la page suivante, la \cref{fig.fantome_elementaire} représente le
fantôme élémentaire selon la direction $(p,q)=(2,1)$.

Soit un ensemble de projections suivant les directions de l'ensemble
$\{(p_i,q_i)\}$, \textcite{philippe1998phd} a montré qu'il existe une unique
décomposition de $f$ telle que :

\begin{equation}
    f = f^{\{(p_i,q_i)\}} + \sum_{j=1}^{r}a_i\ghost{(p_i,q_i)}\;,
    \label{eqn.decomposition}
\end{equation}

\noindent où $a_i$ correspondent aux inconnues.


## Code à effacement Mojette {#sec.fecmojette}

Nous avons vu que la transformation Mojette est capable de fournir une
représentation redondante de l'image. Cette propriété essentielle forme la base
de notre motivation pour concevoir un code à effacement à partir de la
transformation Mojette. On rappelle ici qu'en théorie des codes, un code à
effacement $(n,k)$ transforme $k$ blocs de données en un ensemble de $n$ blocs
encodés plus grand (i.e.\ $n \geq k$).
Nous verrons dans la suite comment a été conçu le code à effacement Mojette
sous sa forme non-systématique, puis nous verrons que le code obtenu n'est pas
MDS.


### Conception du code à effacement non-systématique

Contrairement à la FRT, il est nécessaire en Mojette de déterminer l'ensemble
des projections que l'on souhaite calculer. Afin de concevoir simplement un
code à effacement, on fixe l'un des paramètres $(p,q)$ à $1$. Considérons par
la suite que pour chaque projection, $q_i = 1$ pour $i \in \ZZ_I$ comme cela à
déjà été utilisé dans de précédents travaux\ \cite{parrein2001gretsi}.
Soit une image discrète de taille $(P \times Q)$, avec $Q$ le nombre de lignes
de cette image, et soit un ensemble de $I$ projections. Nous rappelons que la
condition sur $Q$ pour garantir l'unicité de la solution de reconstruction est
$Q \leq \sum\limits_{i=1}^{I}|q_i|$ (extrait de \cref{eqn.katz}). En
conséquence, si l'on fixe $q_i = 1$, le critère de
\citeauthor{katz1978springer} est réduit au principe suivant : $Q$ projections
suffisent pour reconstruire l'information contenue dans une image de hauteur
$Q$\ \cite{parrein2001phd}. Dans ces conditions, $Q$ projections constituent un
ensemble suffisant pour reconstruire l'image. En particulier, la transformée
Mojette correspond à un code à effacement $(n,k)$ où $k$ correspond à la
hauteur de l'image $Q$, et $n$ correspond au nombre de projections $I$. En
conséquence, cette condition permet à la transformation Mojette de garantir une
solution unique au problème de reconstruction lorsqu'un nombre maximal de
$(n-k) = (I-Q)$ projections sont manquantes.


### Un code à effacement "quasi MDS"

Il est important de considérer avec attention la taille des projections
puisque cette taille a des conséquences sur la consommation mémoire. En
particulier dans les applications de transmission et stockage, on souhaite
réduire au maximum cette consommation.
La taille $B$ d'une projection, correspondant au nombre de bins qu'elle
contient, est définie par \textcite{guedon1995vcip} ainsi :

\begin{equation}
    B(P,Q,p_i,q_i) = (Q-1)|p_{i}|+(P-1)|q_{i}|+1\;,
    \label{eqn.nombre_bins}
\end{equation}

\noindent où $(P,Q)$ correspond à la taille de l'image et $(p_i,q_i)$
correspond à la direction de la projection étudiée. Dans le cas du code à
effacement, où l'on fixe $q_i=1$, l'\cref{eqn.nombre_bins} s'écrit :

\begin{equation}
    B(P,Q,p_i,q_i) = (Q-1)|p_{i}|+P\;.
    \label{eqn.nombre_bins_fec}
\end{equation}

\noindent En conséquence, la taille des projections augmente avec $p_i$.
Rappelons que dans le cas d'un code MDS, la taille d'un bloc encodé correspond
à la taille d'un bloc de données. Du point de vue des projections, la
transformation Mojette permet de concevoir un code optimal puisqu'un ensemble de
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
\textcite{parrein2001phd} définit ce coût de surpopulation, noté $\epsilon$,
comme étant le rapport du nombre de bins (défini dans \cref{eqn.nombre_bins})
sur le nombre de pixels :

\begin{equation}
    %\epsilon    &= \frac{\#_{bins}}{\#_{pixels}},\\
    \epsilon = \frac{\sum\limits_{i=0}^{n-1}B(P,Q,p_i,q_i)}{P \times Q}\;.
    \label{eqn.epsilon}
\end{equation}

\noindent En particulier, \citeauthor{parrein2001phd} montre que cette valeur
est significativement réduite à mesure que la largeur $P$ de l'image augmente.
Par conséquent, le code est MDS de façon asymptotique. On appelle ce genre de
code sous-optimaux des codes $(1+\epsilon)$-MDS tel que discuté
par \textcite{parrein2001phd}. Dans le prochain chapitre de cette thèse,
l'impact de l'encodage sera précisément évalué et comparé avec d'autres
techniques (\cref{sec.surcout_stockage}).


#### Réduction du surcout de redondance

\textcite{verbert2004wiamis} ont proposé une méthode basée sur l'analyse de
l'algorithme de reconstruction afin de réduire la taille des projections.
Prenons l'exemple d'une grille discrète $(P=6,Q=2)$ sur
laquelle on calcule trois projections suivant les directions
$\left\{(1,1),(0,1),(-1,1)\right\}$. Dans ce cas, puisqu'il est nécessaire
d'avoir deux projections pour reconstruire la grille, il n'existe que 3
combinaisons possibles d'affection des projections aux lignes :
$\left\{(1,0),(0,-1),(1,-1)\right\}$. La première ligne ne peut alors être
reconstruite que par les projections suivant $(p=1)$ ou $(p=0)$. De même, la
seconde ligne ne peut être reconstruire que par les projections suivant $(p=0)$
ou $(p=-1)$. En conséquence, quel que soit l'ensemble de projections utilisé
lors de la reconstruction, le processus ne va utiliser que les $k=6$ premiers
bins de chaque projection. Ce qui signifie qu'il n'est pas nécessaire de
calculer et stocker le septième et dernier bin des projections $(p={1,-1})$.
Notons que dans ce cas particulier, le code Mojette est optimal puisque les
projections font la même taille que les lignes de l'image.

Dans le cas général, \textcite{verbert2004wiamis} ont montré que cette
réduction du nombre de bin ne peut amener le code à être optimal. Toutefois ils
fournissent une méthode permettant de réduire la valeur d'$\epsilon$. Cela
permet deux choses : (i) l'opération d'encodage est plus performante puisque
moins de calculs sont nécessaires; (ii) la taille des projections est réduite
ce qui améliore le transfert et le stockage des projections en pratique.

% ## Relations avec d'autres codes à effacement

% ### Matrice d'encodage

% ### Connexions avec les codes LDPC

\section*{Conclusion du chapitre}

\addcontentsline{toc}{section}{Conclusion du chapitre}

La transformation de \radon pose les bases de la reconstruction tomographique.
Son étude dans le domaine continu a ouvert la voie à de nombreuses techniques
d'inversion. Nous avons vu que la tomographie discrète attaque le problème de
la reconstruction tomographique par une représentation discrète des éléments et
des algorithmes. Cette représentation a l'avantage de répondre au problème par
une solution exacte par rapport aux solutions émanant du domaine continu, grâce
à l'échantillonnage possible par la géométrie du problème.

Nous avons étudié la FRT et la transformation Mojette qui sont des versions
discrètes et exactes de la transformation de \radon. La capacité d'inversion de
ces transformations forme la base de la conception de nouveaux codes à
effacement. Plus particulièrement nous avons étudié comment ces transformations
peuvent être utilisées afin d'encoder et générer des informations redondantes,
nécessaires pour tolérer l'effacement. Afin de déterminer la capacité des
codes, nous avons énoncé les critères qui garantissent si un ensemble de
projections donné permet de résoudre le problème de reconstruction. Les
méthodes itératives et efficaces d'inversion ont été détaillées et permettent
à ces codes de reconstruire l'information dans le cas où les données ont été
altérées.

La transformation Mojette correspond à une version apériodique de la FRT, ce
qui a pour conséquence de rendre le code à effacement associé non-MDS,
contrairement au code fourni par la FRT. Toutefois ce surcout d'encodage est
limité et la Mojette correspond à un code «\ quasi-MDS\ ». Ce léger surcout
ouvre la voie à des algorithmes de reconstruction très efficaces. Actuellement
disponible sous sa forme non-systématique, nous verrons qu'une
mise en œuvre du code sous sa forme systématique peut améliorer les
performances, et réduire la quantité de redondance. La conception de cette
version systématique est l'objectif du chapitre suivant.

