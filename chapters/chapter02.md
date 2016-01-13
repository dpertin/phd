

\chapter{Conception de codes définis par géométrie discrète}

Nous avons vu précédemment que les codes à effacement linéaires correspondent à
des applications capables de calculer des informations redondantes à
partir des données utilisateurs, mais également de reconstruire ces données à
partir d'un ensemble suffisant d'information (problème inverse). Pour cela nous
avons détaillé une approche algébrique à travers l'étude des codes de
Reed-Solomon. Bien que ces codes soient MDS, la complexité des opérations
d'encodage et décodage est trop élevé pour des application temps-réel.

Dans ce chapitre, nous allons utiliser une nouvelle approche pour concevoir des
codes à effacement. L'approche géométrique semble adaptée pour
répondre aux problèmes de la tolérance aux pannes. En effet, en géométrie, la
transformée de \radon correspond une application qui permet de représenter une
fonction par ses projections suivant différents angles \cite{radon1917akad}.
Notre objectif est de déterminer à partir de cette nouvelle approche, de
nouveaux algorithmes d'inversion. En particulier, notre motivation repose sur
le fait que la transformée de \radon possède des liens étroits avec la
transformée de Fourier, à travers le théorème de la tranche centrale.

Un code à effacement travaille sur des données numériques. Afin de pouvoir
évaluer et implémenter un code à effacement, la première étape
consistera à discrétiser la transformée de \radon, initialement définie
dans domaine continu \cite{radon1917akad}. Cette étude sera réalisée en
\cref{sec.reconstruction_discrete}. \matus sont parvenus à définir une version
discrète de la transformée de \radon, qui conserve toutes les propriétés de la
version continue \cite{matus1993pami}. En particulier, le théorème de la
tranche centrale permet d'atteindre la complexité de la transformée de Fourier
rapide FFT \cite{cooley1969tae}. Ces nouveaux algorithmes offrent ainsi de
meilleures performances que les algorithmes proposés par les codes de
Reed-Solomon.

Plus particulièrement, nous verrons deux versions discrètes et exactes de la
transformée de \radon. La première mise en œuvre correspond à la transformée de
\radon finie (pour *Finite Radon Transform* ou FRT). Les projections de cette
application boucle périodiquement sur le support étudié, ce qui lui permet de
fournir un code MDS \cite{normand2010wcnc}. Nous verrons différents algorithmes
performants d'inversion et de reconstruction de la donnée en \cref{sec.frt}.
Dans la troisième partie \cref{sec.mojette}, nous verrons une version discrète
apériodique de la transformée \citeauthor{radon1917akad}. La transformée Mojette possèdent en
conséquence des caractéristiques différentes de la FRT. En particulier, nous
verrons qu'une approche géométrique nous permet de concevoir des méthodes de
reconstruction très performantes, bien que le code conçu à partir de cette
transformée ne soit pas tout à fait MDS.



# Discrétisation de la transformée de \radon continue
\label{sec.reconstruction_discrete}

La transformée de \radon est une application linéaire permettant de représenter
une fonction par ses projections suivant différents angles. L'opération inverse
consiste à reconstruire la fonction à partir des valeurs de projections.
Cette transformée possède de nombreuses applications. En imagerie, la
*tomographie* est une technique qui vise à reconstruire le contenu d'un objet
à partir de mesures prises en dehors de celui-ci (projections). En
conséquence, cette technique permet la visualisation et le stockage d'une
version numérique de l'objet.

Dans le milieu médical, il faudra attendre $1972$ avant que
\citeauthor{hounsfield1973bjr} ne parvienne à concevoir le premier scanner à
rayon X, sans pour autant qu'il n'est eu au préalable connaissance des travaux
de \radon. Il remportera le prix Nobel de médecine en $1979$ avec
\citeauthor{cormack1963jap} pour leurs travaux respectifs sur le développement
de la tomographie numérique \cite{cormack1963jap, hounsfield1973bjr}. Cette
technique, largement répandue dans le milieu médical, est aussi utilisée en
astronomie par \citeauthor{bracewell1956ajp}, en géophysique ou encore en
mécanique des matériaux \cite{bracewell1956ajp}.

Nous débuterons cette partie en introduisant la transformée de \radon dans le
domaine continu, en tant que solution du problème inverse (\cref{sec.radon}).
Afin de concevoir des codes à effacement, nous verrons par la suite quelques
notions de géométrie discrète qui nous serons nécessaires pour définir et
représenter des versions discrétiser de la transformée de \radon
(\cref{sec.geometrie}). Enfin nous verrons une représentation discrète de cette
transformée et nous déterminerons une solution au problème inverse par une
méthode algébrique en \cref{sec.inverse}.


## Transformée de \radon dans le domaine continu {#sec.radon}

La transformée de \radon est une application qui répond au problème inverse.
Nous introduirons dans un premier temps le problème inverse dans un contexte
pratique : l'imagerie médicale. Nous verrons ensuite la définition de la
transformée de \radon dans le domaine continu, telle que définie dans les
travaux fondamentaux de \radon \cite{radon1917akad}.

### Problème inverse

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


Un *problème inverse* correspond au processus qui permet de déterminer les
causes à partir d'un ensemble d'observations. En tomographie, ce problème
consiste à reconstituer une image à partir d'un ensemble de projections
mesurées sur l'image. On distingue alors deux processus dans la
résolution de ce problème : *l'acquisition* des données et la *reconstruction*
de l'image. Ces deux processus sont représentés en \cref{fig.inverse} sur
laquelle on présente les différentes étapes d'une tomographie, appliquée sur
une image composée de deux disques.

En imagerie médicale, l'acquisition met en jeu la rotation d'un capteur
qui mesure des projections monodimensionnel autour d'une zone du
patient. Cette technique est notamment utilisée dans les scanners à rayons X.
Ces appareils envoient une série de rayons X à travers le patient à différents
angles. Les récepteurs situés de l'autre côté du patient mesurent alors
l'absorption de ces rayons par les tissus organiques. Il est alors possible de
déterminer le volume de tissu traversé par ces rayons. Une étape de
l'acquisition est représentée \Cref{fig.inverse1}. Elle correspond à la mesure
suivant la direction horizontale. L'émetteur situé à gauche envoie des rayons
en parallèles (d'autres cas cas où les rayons sont émis en éventail ou en
cône existent mais ne sont pas traités ici) et permet au capteur situé à droite
de mesurer l'empreinte des deux formes étudiées.

Une fois l'acquisition terminée, un traitement informatique permet de
reconstruire les structures anatomiques par une opération inverse.
Une technique pour reconstruire cette image consiste à rétroprojeter la valeur
des projections dans le support à reconstruire. Si l'on ne dispose pas de
suffisamment de projections, alors l'ensemble des solutions possibles peut être
significativement grand (voire infini) et il est impossible de déterminer une
solution unique.
Plusieurs itérations de l'opération de rétroprojection sont représentées de
\cref{fig.inverse1,fig.inverse2,fig.inverse3}. Plus particulièrement,
\cref{fig.inverse2} montre que l'ensemble de solution est infini lorsque l'on
utilise qu'une projection. Plus on utilise de projections, plus l'ensemble de
solutions se réduit, comme le montre \cref{fig.inverse3} qui met en jeu une
seconde projection. Pour fini, si suffisamment de projections sont utilisées,
on parvient à déterminer une unique solution qui correspond à l'image initiale.
C'est le cas que l'on observe en \cref{fig.inverse4} en utilisant trois
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

\radon définit sa transformée dans ses travaux fondamentaux de
\citeyear{radon1917akad} comme une application mathématique linéaire qui
consiste à calculer une fonction $r_\varphi(t)$ de $\mathbb{R}$ (appelée
projection) à partir d'une fonction $f(x,y)$ sur $\mathbb{R}^2$, où $\varphi$
correspond à un angle de projection, et $t$ correspond à la distance de la
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
Cette opération inverse consiste à reconstruire $f$ à partir d'un ensemble
suffisant de projections déterminées à partir de différents angles de
projection $\varphi$. Pour cela, \radon a prouvé dans ses travaux qu'il était
possible de reconstruire $f$ en utilisant le théorème de la tranche centrale
\cite{radon1917akad}.

En pratique cependant, la reconstruction par transformée de Radon est un
*problème mal posé*, au sens défini par \citeauthor{hadamard1902pub}, pour
trois raisons \cite{hadamard1902pub}. Premièrement, la solution ne peut être
retrouvée puisque les mesures réalisées lors de l'acquisition intègre du
*bruit* dans les données. Il n'est de plus pas possible de garantir l'*unicité*
de la solution puisque l'acquisition mesure un nombre fini de projections.
Enfin, de part la nature physique des capteurs, les données correspondent à un
échantillon de l'image, caractérisé par la distance des capteurs (dans le cas
d'une étude géométrique parallèle). Enfin, une petite erreur d'acquisition
entraîne de fortes variations des résultats.

L'objectif de ce chapitre est alors de fournir des versions discrètes et
exactes de la transformée de \radon. Ces versions discrètes correspondent à des
méthodes capable de représenter et de reconstruire la version numérique d'une
fonction par ses projections discrètes. En particulier, nous verrons des
mises en œuvre applicables en pratique, et des algorithmes performants capables
de reconstruire cette image dans le cas où une partie des projections est
perdue. Cette propriété permettra de les utiliser comme codes à effacement.


## Quelques bases de la géométrie discrète {#sec.geometrie}

Le procédé permettant de transformer des éléments continus en éléments
discrets, est appelé *discrétisation* (ou *numérisation*). Il est ainsi
possible de transformer une fonction continue $f:\mathbb{R}^2 \rightarrow
\mathbb{R}$ en une fonction discrète $f:\mathbb{Z}^2 \rightarrow \mathbb{Z}$.
Pour cela nous devons au préalable définir quelques notions de géométrie
discrète. Nous étudierons dans un premier temps les aspects topologiques qui
nous permettront de comprendre la représentation discrète de l'image à
reconstruire. Par la suite, nous verrons quelques objets relevant de la
géométrie discrète, comme les angles et les droites, afin de définir les
droites de projection dans cette étude.


### Notions topologiques : pavage et connexité dans le domaine discret

\begin{figure}
    \centering
    \def\svgwidth{\textwidth}
    \includesvg{img/pavages}
    \caption{Représentation des trois pavages réguliers possibles sur
    $\mathbb{Z}^2$ (carré, triangle, hexagone). Le maillage de chaque pavage
    est représenté en gris clair.}
    \label{fig.pavage}
\end{figure}

Un espace discret $\mathbb{Z}^n$ est une décomposition du plan de dimension
$n \geq 2$ en *cellules*. L'ensemble de ces cellules forment un *pavage*.
Une cellule peut être représentée par son centre de gravité, que l'on appelle
*point discret*. L'ensemble des points discrets d'un pavage forme un
*maillage*. Par la suite, on travaillera sur des pavages vérifiant les trois
propriétés suivantes :

1. réguliers : les cellules correspondent à des formes régulières
(i.e.\ des polygones dont tous les côtés et tous les angles sont égaux) et dont
les sommets sont en contact avec un nombre fini de sommets appartenant à
d'autres cellules afin de remplir sans recouvrement l'espace;

2. de dimension $2$, c'est à dire que l'image correspond à une partie
de $\mathbb{Z}^2$ (par la suite, on pourra utiliser le terme *pixel* pour
désigner les cellules);

3. dont les cellules sont facilement adressables, pour cela on utilisera un
pavage carré afin d'adresser directement les éléments par un couple de
coordonnées $(x,y)$ (le maillage d'un pavage carré est carré contrairement au
maillage d'un pavage triangulaire ou hexagonal).

\noindent Par la suite, nous utiliserons un pavage carré semblable à celui
représenté en \cref{fig.pavage}.

Les notions topologiques dans le domaine discret sont définies à partir de la
notion de *voisinage* et de *connexité* \cite{rosenfeld1970acm,
rosenfeld1979tamm}. Soient $P$ et $Q$, deux points définis par leurs
coordonnées $(x,y)$ dans un pavage carré. Dans ce cas, $P$ et $Q$ sont deux
points voisins si une et une seule de leurs coordonnées diffère d'une unité. En
particulier, le point $P$ possède quatre voisins qui correspondent aux points
de coordonnées $(x-1,y),(x+1,y),(x,y-1),(x,y+1)$. Dans ce cas, on parle de
*$4$-connexité*.
À présent que l'on a définit la connexité, on peut définir un *chemin* comme
une suite de points de telle manière que deux points consécutifs de ce chemin
soient voisins.

Pour finir, on définit une *composante connexe* comme étant un ensemble $S$ de
points discrets tel que pour tout couple de points $(P,Q)$ appartenant à $S$,
il existe un chemin reliant $P$ à $Q$ dont tous les points appartiennent à $S$.
Ces définitions nous permettent de comprendre la représentation discrète de
l'image.

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
    \caption{Représentation des différents angles discrets $(p,q)$ obtenus par
    la suite de Farey $F_3$. Cette suite permet de définir l'ensemble des
    pentes possibles jusqu'à $\frac{\pi}{4}$ pour un pavage $(3 \times 3)$.}
    \label{fig.farey}
\end{figure}

On s'intéresse dans cette partie à déterminer les points d'intersection entre
le maillage défini par les points d'un ensemble discret de taille $(N \times
N)$, et une droite d'équation $y = ax + b$.
Pour que cette intersection ne soit pas vide, il est nécessaire que la pente de
la droite soit de la forme :

\begin{equation}
    0 \leq \frac{q}{p} \leq 1,
    \label{eqn.pente_droite}
\end{equation}

où $p$ et $q$ sont des entiers premiers entre eux, vérifiant
$q \leq p \leq N$. L'ensemble des pentes des droites possibles défini par
\cref{eqn.pente_droite} sur $[0,\frac{\pi}{4}]$ forment une suite de
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
pentes générés par $F_3$ dans un pavage carré de taille $(3 \times 3)$.
Visuellement, la direction d'une droite est obtenue en reliant l'origine avec
le point obtenu par un décalage horizontal de $p$, et par un décalage vertical
de $q$.

Dans la suite de nos travaux, nous utiliserons le terme *direction discrète*
pour désigner le couple d'entier $(p,q) \in \mathbb{Z}^2$, premiers entre eux,
correspondant à la direction de la droite de pente $\frac{q}{p}$. Cette
définition des angles discrets sera nécessaire lorsque l'on définira des
versions discrètes de la transformée de \radon (\cref{sec.frt,sec.mojette}).
Nous allons dans la suite utiliser une approche algébrique afin d'introduire le
processus de reconstruction d'une image discrète, à partir d'un ensemble de
projections obtenues à différents angles discrets.


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

Par la suite, on considère une distribution d'intensité $f(x,y)$ où le couple
d'entier $(x,y)$ représente la position d'une cellule sur pavage régulier
carré. Les images numériques par exemple, correspondent à la distribution d'une
intensité lumineuse.

%Pour cela, un système de codage est utilisé. Le système

%RGB par exemple, indique l'intensité de chacune des trois

%couleurs primaires

%(rouge, vert et bleu) sur un canal différent, codé sur un octet.

Le problème soulevé par la tomographie discrète correspond à reconstruire
les valeurs de l'image à partir des valeurs des projections préalablement
calculées. \Cref{fig.inverse_discret} représente une image discrète composée de
quatre pixels identifiés par leur valeur $\{a,b,c,d\}$. Dans cet
exemple, les valeurs des projections correspondent à la somme des valeurs des
pixels traversés par les droites de projections. Deux considérations sont alors
à prendre. La première considération interroge la possibilité de déterminer de
manière unique une solution du problème. La seconde consiste à déterminer une
méthode de reconstruction efficace de cette solution.

En réalité, ce problème peut être vu comme un problème d'algèbre linéaire. Dans
cette représentation, les pixels de l'image forment les inconnus à reconstruire
tandis que les projections correspondent aux équations linéaires. Dans
l'exemple proposé, la représentation de l'image par les projections verticales et
horizontales, comme représenté en \cref{fig.inverse_discret_nok}, correspond à
poser le problème sous la forme d'un système d'équations linéaires à $4$
équations et $4$ inconnues. Nous proposons la représentation suivant à laquelle
des valeurs de projection ont été affectées :

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
est nul). En effet seulement trois équations sur quatre du système
(\cref{eqn.système}) sont indépendantes puisque la somme de la première avec la
deuxième est égale à la somme de la troisième avec la quatrième. En
conséquence, la reconstruction depuis ces projections fournit une infinité de
solutions tant que la valeur d'un pixel n'est pas connu. Autrement dit,
l'ensemble des projections mesurées n'est pas suffisant pour déterminer de
manière unique une solution.
Un ensemble de projection suffisant est représenté en
\cref{fig.inverse_discret_ok}. Dans cet exemple, on rajoute deux nouvelles
mesures suivant les diagonales. En conséquence, on obtient un système
surdéterminé que l'on peut représenter sous forme matricielle :

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
matrice carrée de taille $n$ par la méthode de Laplace. Il faut ensuite
inverser cette matrice en utilisant par exemple la méthode de Gauss-Jordan,
dont la complexité est $\mathcal{O}(n^3)$. Enfin, pour déterminer les valeurs
de $x$, une multiplication matricielle est nécessaire (voir \cref{eqn.art})
dont la complexité est $\mathcal{O}(n^3)$ également.

Dans la suite de ce chapitre, nous détaillerons deux versions discrètes et
exactes de la transformée de \radon : la FRT et la transformée Mojette
(respectivement \cref{sec.frt,sec.mojette}). Plus particulièrement, nous
verrons qu'en utilisant ces transformées, nous serons capable d'une part de
déterminer efficacement si le processus de reconstruction aboutit à une
solution unique. D'autre part, nous verrons qu'une approche géométrique permet
de concevoir des méthodes de reconstruction performantes. En particulier, nous
verrons des algorithmes efficaces permettant de reconstruire l'image en cas de
perte de la donnée.



# Code optimal par transformée de \radon finie {#sec.frt}

Nous avons vu dans la partie précédente que la transformée de \radon
constitue un outil mathématique capable de résoudre le problème inverse.
Cependant, puisque les ordinateurs ne sont pas capable de travailler sur des
ensembles d'éléments continus, il est nécessaire de définir une version
discrète de cette application.

Cette partie présente une version discrète et exacte de la transformée de
\radon, proposée à l'origine par \matus \cite{matus1993pami}. La particularité
de cette version est de considérer un support discret périodique. \matus ont
montré que cette propriété permet de construire un nombre fini de projections,
et que cet ensemble garantit l'unicité de la solution de reconstruction. Nous
verrons en particulier la mise en œuvre de cette transformée à travers la
méthode de calcul des projections, puis de reconstruction de l'image en
\cref{sec.frt-intro}. \cref{sec.fantome} apportera la définition
géométrique des fantômes. Les fantômes sont des éléments de l'image qui sont
invisibles dans le domaine de \radon. En particulier, nous verrons en
\cref{sec.fecfrt} que \citeauthor{chandra2012tip} ont utilisé les fantômes afin
de reconstruire l'image quand certaines projection manquent
\cite{chandra2008icpr, chandra2012tip}. Nous verrons également que
\textcite{normand2010wcnc} ont montré que la FRT peut être utilisée pour
fournir un code à effacement MDS.


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

La transformée de \radon finie (*Finite Radon Transform* ou FRT) est une version
discrète et exacte de la transformée de \radon continue. Elle a été conçue sur
la base des travaux de \citeauthor{matus1993pami} en \citeyear{matus1993pami}
avant d'être étendue par \citeauthor{svalbe2001laa} \cite{matus1993pami,
svalbe2001laa}.
La particularité de la FRT est de considérer un pavage carré périodique de
taille $p$. L'image est alors représentée sous la forme d'un tore, de telle
sorte que le pixel de coordonnées $(x,y)=(p,p)$ correspond au pixel $(0,0)$.
En conséquence, les droites de projection se retrouvent du côté opposé de
l'image quand elles "dépassent du bord". Les lignes de projections s'écrivent
sous la forme de la congruence suivante :

\begin{equation}
    y \equiv m x + t \pmod p,
    \label{eqn.frt_line}
\end{equation}

avec $m$ la pente de la droite, $t$ la valeur du décalage de la droite de
projection suivant l'axe des $y$, et $x,y,m,t \in \mathbb{Z}$. Un exemple est
fournie en \cref{fig.frt_line} qui représente la droite d'équation $y \equiv 2
x \pmod 5$ sur un pavage carré de taille $p=5$.

Pour appliquer la FRT telle que définie par \matus, il est nécessaire
d'utiliser un support carré de taille $p$, avec $p$ un nombre premier. Cette
particularité permet de définir exactement $(p+1)$ directions de projections
discrètes. Puisque $p$ est premier, ces $(p+1)$ directions permettent
d'échantillonner de manière optimale l'image, dont chaque pixel est parcouru
une et une seule fois.

Étant une version discrète de la transformée de \radon continue, la FRT
remplace les intégrales (voir \cref{eqn.radon}) par des sommes. Plus
précisément, cette transformée est définie comme la somme des pixels de l'image
le long des droites de projections définies par \cref{eqn.frt_line}. La FRT est
définie ainsi : 

% $$ \left \{

\begin{align}
    R(m,t)  &= \sum_{x=0}^{p-1} \sum_{y=0}^{p-1} f(x,(mx + t) \pmod{p}),
    \label{eqn.frt}\\
    R(p,t)  &= \sum_{x=0}^{p-1} \sum_{y=0}^{p-1} f(t, y),
    \label{eqn.frt_p}
\end{align}

% \right. $$

où $0 \leq m < p$ et $x,y,m,y \in \mathbb{Z}$. La variable $t$ correspond à
l'index de translation de la projection $m$ suivant l'axe des $x$
(i.e.\ l'horizontal). La variable $m$ représente la valeur de l'angle discret
de la projection.

Il est intéressant de noter que l'ensemble des angles de projection est
uniquement déterminer par la taille de la grille $p$. Il n'y a donc pas besoin
de déterminer la valeur des couples $(p,q)$. La FRT consiste alors à calculer
$(p+1)$ projections de taille $p$, indexées par la valeur de $m$. En
particulier, \cref{eqn.frt} signifie que les éléments des $p$ premières
projections sont issues de la somme des pixels de la grille suivant les droites
décrites en \cref{eqn.frt_line}. Tandis que la projection $(p+1)$ définie dans
\cref{eqn.frt_p}, correspond à la somme horizontale des éléments de l'image.
Puisque chaque projection traverse une et une seule fois chaque élément de la
grille discrète, la somme de tous les éléments d'une projection correspond à la
somme de tous les éléments de l'image. Par la suite, on appellera cette somme
$I_{sum}$.

\Cref{fig.frt} montre la FRT d'une image $(3 \times 3)$ dans laquelle la valeur
des pixels correspond à des lettres. En particulier, la projection $R(m=2,t=0)$
est représentée en rouge. La valeur de cette projection correspond à la somme
des éléments de l'image en partant de $a$ (puisque $t=0$) et en se décalant de
$m=2$ pixels sur la droite quand on descend d'une ligne (la pente
m=$\frac{q}{p}=\frac{2}{1}$). On remarque sur la troisième ligne l'effet
torique du support, ainsi que le retour sur le pixel $a$ à l'itération
suivante.
\citeauthor{matus1993pami} ont montré qu'il est nécessaire de calculer les
$(p+1)$ projections afin de pouvoir reconstruire une image $(p \times p)$. Dans
la suite, nous détaillons une méthode de reconstruction de l'image algébrique.



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
de technique de filtrage pour retrouver les valeurs initiales des pixels
(échantillonnage optimal). Pour cela, on applique la même méthode, c'est à dire
la transformée de \radon finie, mais cette fois sur les projections $R(m,t)$,
et avec un angle $m^\prime$ opposé à $m$, c'est à dire tel que
$m^\prime = p-m$.
On obtient alors une image reconstruite $f^\prime$ dont les éléments
correspondent à $f^\prime(x,y) = (f(x,y) \times p) + I_{sum}$, où $f(x,y)$
correspond à la valeur d'origine de l'élément $(x,y)$, et $I_{sum}$ correspond
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
Cependant, \matus ont montré que la FRT conserve toutes les propriétés de la
transformée continue de \radon. En particulier, le théorème de la tranche
centrale peut être utilisé pour reconstruire efficacement l'image, et ainsi
diminuer cette complexité à $\mathcal{O}(p^2 log_2 p)$.


## Fantôme discret {#sec.fantome}


### Introduction aux fantômes

Les fantômes correspondent à des éléments de l'image générés dés lors que
des projections manquent. Ils ont été étudiés pour la première fois dans le
contexte de l'astronomie par \citeauthor{cornwell1982sm,bracewell1956ajp}
\cite{cornwell1982sm,bracewell1956ajp}. En pratique, pour la transformée de
\radon continue,
il existe toujours des projections manquantes. En conséquence,
les fantômes empêchent l'aboutissement du processus de reconstruction vers une
solution unique. De par sa définition, un fantôme est une distribution sur
l'image dont la somme des éléments suivant la direction de la projection
manquante vaut zéro. En conséquence, ils sont "invisibles" suivant ces
directions.

Les fantômes ont un rôle essentiel dans la compréhension des transformées, et
d'en l'élaboration de méthode de reconstruction avec perte de données. En
particulier, nous nous intéresserons dans un premier temps à la structure des
fantômes afin de comprendre comment ils influencent la donnée en FRT. La
structure des fantômes a tout d'abord été étudiée par
\citeauthor{chandra2008dgci} \cite{chandra2008dgci}. En particulier, ces
travaux montrent que l'absence d'information de projection entraîne la
distribution des fantômes sur l'image. En conséquence, une méthode permettant
de supprimer ces méthodes est énoncée, et permet de reconstruire l'image. Nous
verrons en détail la structure des fantômes ainsi que la façon de les
éradiquer, dans la partie suivante.


### Structure des fantômes et distribution sur l'image

\begin{figure}
	\centering \input{tikz/espace_fantome.tex}
	\caption{Représentation des distributions circulantes des fantômes
	${a, b,	c}$ générés par l'effacement respectif des projections $m={1,3,4}$.
	Les grilles de gauche correspondent à la superposition des fantômes sur une
	image $(5 \times 5)$ après reconstruction depuis les projections FRT de
	droite. Chaque étape correspond à un nouvel effacement, représentée par une
	ligne colorée.}
	\label{fig.espace_fantome}
\end{figure}

\katz a montré que l'effacement d'une projection FRT entraîne la création d'un
fantôme dans l'image \cite{katz1978springer}. Afin de déterminer des méthodes
de reconstruction de l'image en cas de perte de projections, il est nécessaire
de déterminer la structure d'un fantôme. Soit une projection $a =
\{a_0, \dots, a_{p-1}\}$ correspondant à la projection d'index $m_a$ de
l'espace de \radon $R(m,t)$. Les premières études sur la détermination des
structures des fantômes ont montré que la reconstruction de l'image à partir
d'un domaine de \radon partiel (c'est à dire, sans la projection $a$) entraîne
une distribution particulière des valeurs de $a$ sur l'image
\cite{chandra2008dgci}. Plus particulièrement, les valeurs de la projection $a$
se superposent à l'image, avec un décalage circulaire de $m_a$ sur chaque ligne
de l'image. \Cref{fig.espace_fantome} montre la distribution d'un fantôme dans
une image $(5 \times 5)$ lorsque la projection $m=1$ est effacée.

\citeauthor{chandra2012tip} ont par la suite démontré que cette structure
correspond à celle obtenue par une matrice circulante \cite{chandra2008icpr,
chandra2012tip}. Plus particulièrement, chaque projection manquante entraîne la
génération d'une nouvelle distribution de fantômes dont les décalages sont
caractérisés par l'index de cette projection. Ainsi, lorsque plusieurs
projections manquent dans le domaine de \radon, l'image contient une
superposition des distributions de ces fantômes. \Cref{fig.espace_fantome}
montre le cas où deux puis trois projections sont manquantes. Dans la suite,
nous nous intéresserons aux méthodes de résolution qui permettent de supprimer
ces fantômes afin de reconstruire l'image à partir d'une représentation
partielle.


### Reconstruire l'information manquante

Plusieurs algorithmes ont été proposés pour reconstruire l'image lorsqu'elle
est altérée par la distribution de fantômes générés par l'absence de
projections. La première méthode de reconstruction de l'image par la méthode
des fantômes a été proposée par \textcite{chandra2008dgci}. Cette méthode
repose sur deux choses :

1. une zone de redondance de l'image dont la valeur des pixels doit être
connue;

2. un processus de reconstruction permettant de supprimer ces fantômes.

La présence d'une zone de redondance dans l'image est essentielle pour la
reconstruction d'un domaine partiel. Plus précisément,
\textcite{chandra2008dgci} ont montré qu'il était nécessaire de calibrer une
les valeurs d'une zone de l'image afin d'isoler la valeur des fantômes dans
cette zone lors de la reconstruction partielle. Par exemple, il est possible de
reconstruire $r$ projections dés lors que cette zone de redondance implique $r$
lignes de l'image. En particulier, si l'on fixe une valeur nulle pour ces
lignes de redondance, les pixels ne contiendront que la valeur des fantômes.

Lorsqu'une seule projection manque, la valeur de ses éléments est alors
accessible sur une ligne de redondance, à un décalage près qui est caractérisé
par $m_a$ et l'index de la ligne.
Lorsque plusieurs projections manquent, le processus de reconstruction proposé
par \textcite{chandra2008dgci} met en jeu trois opérations pour la
détermination d'une projection : (i) un décalage cyclique sur chaque lignes
afin de synchroniser le premier élément $a_0$ des fantômes sur le premier pixel
de chaque ligne; (ii) la soustraction des lignes afin d'enlever la contribution
du fantôme dans ces lignes de redondance; (iii) une intégration des valeurs
obtenues afin de supprimer l'offset généré par la soustraction précédente.
Pour le lecteur qui souhaite plus d'information sur cette méthode, toutes les
étapes sont clairement indiquées dans \textcite{chandra2008dgci}.

\textcite{normand2010wcnc} ont proposé une approche algébrique de la FRT. En
particulier, ils ont montré que l'opérateur de transformée peut d'écrire sous
la forme d'une matrice de Vandermonde. La définition de la FRT inverse est
toujours valable puisque les sous matrices d'une matrice de Vandermonde sont
toujours inversibles \cite{macon1958maa}.


## Code à effacement par transformée de \radon finie {#sec.fecfrt}

### Forme non-systématique

\begin{figure}
    \centering
    \def\svgwidth{.9\textwidth}
    \includesvg{img/frt_design_non-sys}
    \caption{Représentation de la mise en œuvre du code à effacement
    non-systématique basé sur la FRT.}
    \label{fig.frt_non-sys}
\end{figure}

\textcite{normand2010wcnc} présentent une construction du code à effacement
FRT. \Cref{fig.frt_non-sys} représente la mise en œuvre de la FRT en
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
    \fbox{
    \def\svgwidth{\textwidth}
    \includesvg{img/frt_design_sys}
    }
    \caption{Représentation de la mise en œuvre du code à effacement
    systématique basé sur la FRT.}
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



# Code à effacement par transformée Mojette {#sec.mojette}

Dans cette section, nous allons nous intéresser à un code à effacement basé sur
la transformée Mojette. Tout comme la FRT, cette transformée correspond à une
version discrète et exacte de la transformée de \textcite{radon1917akad}
(définie en \cref{eqn.radon}). Elle a été proposée pour la première fois par
\textcite{guedon1995vcip} dans le contexte du traitement et de l'encodage
d'image. Nous décrirons en \cref{sec.mojette-forward} la méthode de calcul des
projections Mojette. Ces projections permettront de fournir une représentation
redondante de l'image, principe qui sera nécessaire pour encoder les données de
manière redondante. En particulier nous distinguerons cette méthode de celle
vue en FRT précédemment. \Cref{sec.mojette-inverse} présentera en quoi
\textcite{katz1978springer} a permis d'énoncé le critère garantissant l'unicité
de la solution dans le cas d'une image rectangulaire. Ce critère sera utile
pour définir la capacité de reconstruction du code à effacement. Nous verrons
par la suite l'algorithme de reconstruction énoncé par
\textcite{normand2006dgci}, qui sera utilisé dans le processus de décodage
afin de reconstruire l'information.


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

La transformée Mojette de \textcite{guedon1995vcip} est une opération linéaire
qui calcule un ensemble de $I$ projections à partir d'une image discrète
$f:(k,l)\mapsto\mathbb N$. Bien que cette image discrète peut avoir n'importe
quelle forme, nous considèrerons dans la suite une image rectangulaire,
composée de $P \times Q$ éléments, appelés *pixels*. Un pixel est défini par
ses coordonnées $(k,l)$ dans l'image et une valeur. Une projection Mojette est
un ensemble d'éléments, appelés *bins*, définie par une direction de
projection.  Comme expliqué en \cref{sec.angles}, la direction d'une projection
$i$ est définie par deux entiers $(p_i, q_i)$ premiers entre eux. La
transformée Dirac-Mojette est définie ainsi \cite{guedon1995vcip} :

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

\Cref{fig.mojette_directe} représente la transformée Mojette d'une
grille discrète $3 \times 3$ composée de binaires. Le traitement transforme une
image 2D en un ensemble de $I=4$ projections dont les valeurs des directions
sont comprises dans l'ensemble suivant : $\left\{(-1,1), (0,1), (1,1),
(2,1)\right\}$. Dans l'objectif de simplifier la représentation de cet exemple
et des suivants, l'addition est arbitrairement réalisée ici modulo $2$ (la
somme correspond alors au OU exclusif). Cependant, la somme peut être définie
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

%4+5+1 \pmod 6 = 4$

Considérons $B$ la taille d'une projection. Cette taille, qui correspond au nombre
de bin d'une projection, varie en fonction des paramètres $P$ et $Q$ de la
grille, ainsi que de la direction de projection $(p,q)$. Elle est définie ainsi :

\begin{equation}
    B(P,Q,p_i,q_i) = (Q-1)|p_{i}|+(P-1)|q_{i}|+1.
    \label{eqn.nombre_bins}
\end{equation}

Si l'on considère une taille de grille fixe, on remarque que $B$ augmente
linéairement avec $p_i$ et $q_i$. En revanche, lorsque l'un des paramètres de
la grille est significativement plus grand que l'autre, cette évolution est
réduite.

La complexité de la transformée Mojette vaut $\mathcal{O}(PQI)$. Elle est
linéaire avec le nombre de pixels de la grille et avec le nombre de projections
calculées.


## Reconstruction par transformée Mojette {#sec.mojette-inverse}

Dans cette partie, nous présentons les critères qui permettent de garantir
qu'à partir d'un ensemble de projections, la solution reconstruite correspond
aux valeurs à partir desquelles ces projections ont été calculées.
Par la suite, nous présentons un algorithme de reconstruction.

### Critères de reconstruction

Le premier critère permettant de garantir l'existence d'une solution unique de
reconstruction est le critère de \citeauthor{katz1978springer}
\cite{katz1978springer}. Ce critère n'est défini que pour des images $P \times
Q$ rectangulaires. Étant donné un ensemble de directions de projection
$\left\{(p_i,q_i)\right\}$, le critère de \citeauthor{katz1978springer} déclare
que si l'une des conditions suivantes est remplie :
\begin{equation}
    \sum\limits_{i=1}^I{|p_i|}\geq P
    \text{ ou }
    \sum\limits_{i=1}^I{|q_i|}\geq Q,
    \label{eqn:katz}
\end{equation}
\noindent alors il existe une unique solution de reconstruction, et cette
solution contient les valeurs de la grille qui a permis de calculer les
projections.  Cela signifie qu'il existe un moyen de reconstruire la grille à
partir de cet ensemble de projections.

Dans l'exemple de \cref{fig.mojette_directe}, si l'on considère un
sous-ensemble de $3$ projections
$\left\{(p_{0},q_{0}),\dots,(p_{2},q_{2})\right\}$, la seconde condition du
critère de \citeauthor{katz1978springer} donne $\sum_{i=0}^2~|q_{i}|=3$,
puisque $q=1$ pour chaque direction de projection. Alors, les $4$ projections
calculées dans cette figure décrivent une représentation redondante de l'image.
En effet, n'importe quel ensemble de $3$ projections parmi les $4$ suffit à
garantir que la reconstruction à partir de cet ensemble correspondra à l'image
initiale.

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

Plusieurs algorithmes ont été proposés dans la littérature
\cite{guedon2009mojettebookchap5}. Nous choisissons de décrire dans la suite,
l'algorithme itératif d'inversion Mojette par balayage (*Balayage Mojette
Inversion*, BMI) \cite{normand2006dgci} pour deux raisons. La première étant
que cet algorithme fournit de très bonnes performances nécessaires pour les
systèmes temps-réel. De plus, les travaux présentés dans la suite sont basés
sur cet algorithme. Ainsi, une bonne compréhension de cette technique est
nécessaire pour comprendre les contributions de cette thèse.

La reconstruction est directe pour les pixels situés dans les coins de la
grille. En effet, ils définissent entièrement certains bins des projections.
Cela signifie qu'il est possible de connaître la valeur de ces pixels à partir
de la valeur des bins correspondant.
Quant aux autres éléments de la grille, ils interviennent avec d'autres pixels
dans le calcul des bins de projections. Tant que la valeur de ces pixels n'est
pas connu, il est impossible de déterminer à priori la valeur de ce pixel.
En conséquence, il existe des dépendances entre les pixels.
\Cref{fig.dep_graph} est un graphe orienté qui représente les dépendances entre
les pixels d'une grille $3 \times 3$, étant donné un ensemble de directions de
projection $\left\{(1,1), (0,1), (-1,1)\right\}$. Les nœuds de ce graphe
correspondent aux pixels tandis que les arêtes représentent leurs dépendances.
Il est ainsi possible de reconstruire un pixel à partir d'un bin lorsqu'aucune
dépendance ne s'applique sur lui.

Dans l'algorithme proposé par \citeauthor{normand2006dgci}, un sens de
reconstruction est défini. Bien que n'importe quelle direction peut être
choisi, nous considérerons une reconstruction de gauche à droite dans la suite.
Chaque projection est utilisée pour la reconstruction d'une seule ligne de la
grille. Dans l'exemple de la figure, la projection suivant la direction $(1,1)$
est ainsi utilisée pour reconstruire la première ligne. L'attribution des
projections aux lignes se fait de sorte que $p_i$ décroît en même temps que
l'index de la ligne augmente.
Il est alors possible de déterminer un chemin dans ce graphe afin de
reconstruire la grille entière. Il est d'ailleurs possible que plusieurs
chemins existent.

En particulier, si l'on est capable de déterminer un chemin rejoignant le pixel
supérieur gauche, au pixel inférieur gauche, il suffit de répéter l'itération
par un décalage à droite, afin de reconstruire entièrement la grille.
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

Cette itération peut être répétée par des décalages vers la droite afin de
reconstruire la grille entièrement. En particulier, il suffit de décrémenter
les indexes des pixels et des bins de un (ou moins un) pour chaque itération.

En pratique dans une implémentation, ces éléments correspondent à des zones
mémoires juxtaposées. De plus le calcul des indexes de ces zones mémoires est
simple pour chaque itérations. Ces deux considérations permettent de fournir
de hautes performances au niveau de l'implémentation.

## Code à effacement Mojette {#fecmojette}

### Conception du code à effacement non-systématique

Le code à effacement Mojette est conçu à partir de la transformée Mojette.
Comme on a pu le voir dans la partie précédente, cette transformée est capable
de fournir une représentation redondante de l'information. Il est alors
concevable de l'utiliser comme code à effacement afin de tolérer
l'indisponibilité d'une partie de la donnée.
En théorie des codes, un code à effacement $(n,k)$ transforme $k$ blocs de
données en un ensemble de $n$ blocs encodés plus grand (i.e.\ $n \geq k$).

La conception de ce code à effacement repose sur la simplification suivante.
Nous considérons que pour chaque projection, le paramètre $q$ est égal à un,
comme cela à déjà été utilisé dans de précédents travaux \cite{parrein2001phd}.
Puisque $Q$ correspond au nombre de ligne de l'image discrète, et puisque
$q_i = 1$, le critère de \citeauthor{katz1978springer} est réduit au principe
suivant : étant donné une grille de taille $P \times Q$, et un ensemble de
projections $I$, alors $Q$ projections suffisent pour reconstruire la donnée
initiale de la grille.
Dans cette configuration, la transformée Mojette correspond à un code à
effacement puisqu'elle tolère la perte de $(I-Q)$ projections.

### Caractéristique du code (1+$\epsilon$)-MDS

Par définition, la taille des blocs encodés d'un code MDS correspond à la
taille d'un bloc de donnée qui vaut $\frac{\mathcal{M}}{k}$.
Pour l'encodage Mojette; seule la projection suivant la direction $(p=0,q=1)$
possède la même taille qu'un bloc de donnée (qui correspond à une ligne de la
grille discrète). Puisque dans les autres cas, la taille des projections
augmente au delà de la taille d'un bloc de donnée à mesure que $|p_i|$
augmente, le code à effacement Mojette n'est pas MDS.

Du point de vue des projections, dans la mesure où n'importe quel ensemble de
$Q$ projections suffit à reconstruire la grille de manière unique, le code
Mojette est MDS. En revanche, si l'on regarde au niveau de éléments de
projections, la taille des blocs encodés n'est pas optimale.
On considère alors le code Mojette comme étant *quasi-MDS*
\cite{parrein2001dcc}.

On détermine le surcout de redondance comme étant le rapport du nombre de bins
sur le nombre de pixels :

\begin{align}
    \epsilon    &= \frac{\#_{bins}}{\#_{pixels}},\\
                &= \frac{\sum\limits_{i=0}^{n-1}B(P,Q,p_i,q_i)}{P \times Q}.
    \label{eqn.epsilon}
\end{align}

On évaluera précisément l'impact de ce surcout de redondance dans une
l'analyse et comparaison en \cref{sec.surcout_stockage}.

### Réduction du surcout de redondance

Lorsque l'on génère un ensemble redondant de $n$ projections à partir d'une
image de hauteur $k$, on sait que l'on est capable de reconstruire cette image
à partir d'un ensemble de $k$ projections si l'on considère $q_i=1$.
\citeauthor{verbert2004wiamis} ont proposé une étude montrant comment réduire
la taille de ces projections \cite{verbert2004wiamis}.

Lors du processus de reconstruction de la grille discrète, chaque ligne est
reconstruite à partir d'une projection dédiée. Puisque chaque ligne contient
$k$ pixels, cela signifie que la reconstruction va nécessiter la lecture de $k$
bins dans chaque projection.
Plus précisément, lors d'une reconstruction, les projections qui vont
participer à la première et la dernière ligne, vont devoir lire sur les $k$
premiers bins. Pour les projections intermédiaires, la lecture se fera sur $k$
bins à partir d'un certain offset.
À présent, si l'on considère l'ensemble des combinaisons possibles entre les
lignes et les projections lors de la reconstruction, il est possible de
déterminer des bins qui ne seront jamais utilisés quelque soit le sous-ensemble
de projection utilisé. En particulier, puisque nous reconstruisons la grille
discrète de gauche à droite, ces bins sont placés à l'extrémité droite des
projections.
Puisque ces bins ne sont pas utilisés lors de la reconstruction, il est alors
envisageable de ne pas les calculer lors de la génération des projections. Cela
entraîne deux avantages en conséquence : l'opération d'encodage est plus
performante puisque moins de calcul est nécessaire, et de plus, cela réduit la
taille des projections et donc de la redondance nécessaire.
En revanche, bien qu'il soit possible d'obtenir certaines configurations MDS,
cela ne suffit pas à définir un code MDS.

Prenons l'exemple d'une grille discrète $(P=6,Q=2)$ sur laquelle on calcule
trois projections suivant les directions $\left\{(1,1),(0,1),(-1,1)\right\}$.
Dans ce cas, puisqu'il est nécessaire d'avoir deux projections pour
reconstruire la grille, il n'existe que 3 combinaisons possibles d'affection
des projections aux lignes : $\left\{(1,0),(0,-1),(1,-1)\right\}$. La première
ligne ne peut alors être reconstruite que par les projections suivant $(p=1)$
ou $(p=0)$. De même, la seconde ligne ne peut être reconstruire que par les
projections suivant $(p=0)$ ou $(p=-1)$. En conséquence, quelque soit la
l'ensemble de projection utilisé lors de la reconstruction, le processus ne va
utiliser que les $k=6$ premiers bins de chaque projection. Ce qui signifie que
le septième et dernier bin des deux projections $(p={1,-1})$ n'est pas
nécessaire. Dans ce cas particulier, on obtient une configuration MDS.

% ## Relations avec d'autres codes à effacement

% ### Matrice d'encodage

% ### Connexions avec les codes LDPC


