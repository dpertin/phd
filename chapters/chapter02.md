
Nous avons vu précédemment que les codes à effacement linéaires correspondent à
des applications linéaires capables de calculer des informations redondantes à
partir des données utilisateurs. Également, ces applications doivent être
capables de reconstituer l'information initiale à partir d'un sous-ensemble
suffisant d'informations (problème inverse). En imagerie, la tomographie
correspond à une telle application.

La tomographie est une technique qui vise à reconstruire de manière
mathématique l'intérieur d'un objet à partir de mesures prises en dehors de
l'objet, appelées *projections*. En conséquence, cette technique permet la
visualisation et le stockage d'une version numérique de l'objet.

% La tomographie discrète étudie le cas où l'objet est une image numérique,
% représentée par un nombre limité de projections.

Bien que la tomographie discrète ait été rendue possible grâce au
développement de l'informatique moderne dans les années $1960$, le principe
théorique remonte au début du siècle avec les travaux du
mathématicien Autrichien \citeauthor{radon1917akad} \cite{radon1917akad}.
Dans son œuvre, \citeauthor{radon1917akad} pose les fondations de la
tomographie et montre qu'il est non seulement possible de représenter le
contenu d'un objet à travers un ensemble de projections, mais qu'il est
également possible d'inverser cette opération pour reconstruire l'objet.
Plus précisément, ces projections correspondent aux valeurs des intégrales le
long des lignes de projection qui traversent l'objet suivant différents angles.

La première application de cette théorie s'inscrit dans le travaux en
radioastronomie de \citeauthor{bracewell1956ajp} sur la détermination de la
position des astres à partir de mesures par ondes radios
\cite{bracewell1956ajp}.
Dans le milieu médical, il faudra attendre $1972$ avant que
\citeauthor{hounsfield1973bjr} ne parvienne à concevoir le premier scanner à
rayon X, sans qu'il n'est eu au préalable connaissance des travaux de
\citeauthor{radon1917akad}. Il remportera le prix Nobel de médecine en $1979$
avec \citeauthor{cormack1963jap} pour leurs travaux respectifs sur le
développement de la tomographie numérique qui est une technique encore
largement utilisée aujourd'hui, notamment dans le milieu médical
\cite{cormack1963jap,hounsfield1973bjr}.

# Introduction à la reconstruction et à la géométrie discrète

## Transformée de Radon dans le domaine continu

### Problème inverse

Un *problème inverse* correspond au processus qui permet de déterminer les
causes à partir d'un ensemble d'observations. En tomographie, ce problème
consiste à reconstituer une image à partir d'un ensemble de projections
mesurées sur l'image. On distingue alors deux processus dans la
résolution de ce problème : *l'acquisition* des données et la *reconstruction*
de l'image.

En tomographie médicale, cette acquisition met en jeu la rotation d'un capteur
qui mesure des projections monodimensionnel autour d'une zone du
patient. Cette technique est largement utilisée dans les scanners à rayons X.
Ces appareils envoient une série de rayons X à travers le patient à différents
angles. Les récepteurs situés de l'autre côté du patient mesurent alors
l'absorption des rayons X par ses tissus. Il est alors possible de
déterminer le volume de tissu traversé par ces rayons.

\begin{figure}[t]
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
        \caption{Reprojection de $1$ projection}
        \label{fig.farey2}
    \end{subfigure}
	\begin{subfigure}{.43\textwidth}
		\centering
        \def\svgwidth{.6\textwidth}
		\includesvg{img/inverse22}
        \caption{Reprojection de $2$ projections}
        \label{fig.farey3}
    \end{subfigure}
    \begin{subfigure}{.43\textwidth}
		\centering
        \def\svgwidth{.6\textwidth}
		\includesvg{img/inverse32}
        \caption{Reprojection de $3$ projections}
        \label{fig.farey4}
    \end{subfigure}
    \caption{Représentation des différents angles discrets $(p,q)$ obtenus par
    la suite de Farey $F_3$.}
    \label{fig:farey}
\end{figure}

Une fois l'acquisition terminée, un traitement informatique permet de
reconstruire les structures anatomiques par une opération inverse.
Une technique pour reconstruire cette image consiste à rétroprojeter la valeur
des projections dans le support à reconstruire. Si suffisamment de projections
sont disponible, alors une reconstruction partielle de l'image est obtenue. Il
est en général nécessaire de filtrer l'image obtenue pour obtenir une
approximation de l'objet.


### Transformée Radon

\begin{figure}[t]
    \centering
    \def\svgwidth{.7\textwidth}
    \includesvg{img/radon3}
    \caption{Représentation de la transformée de Radon $r[f](\varphi)$ de
    l'objet $f(x,y)$ suivant l'angle de projection $\varphi$.}
    \label{fig.pavage}
\end{figure}

La transformation de \citeauthor{radon1917akad} est une application
mathématique linéaire introduite en \citeyear{radon1917akad}
\cite{radon1917akad}.
Cette application permet de calculer une projection $r$ définie dans un
sous-espace $F$ de dimension $D$ à partir d'une fonction $f$ définie dans un
espace $E$ de dimension $D+1$. Par exemple, la transformée de Radon d'une
fonction $f(x,y)$ bidimensionnelle correspond à une projection
$r_{\varphi}(t)$ monodimensionnelle où $\varphi$ correspond à un angle de
projection, et $t$ correspond à l'index de la ligne de projection.
Dans la suite nous considérons notre étude sur $\mathbb{R}^2$. On définit $P$
un point de ce plan, de coordonnées $(x,y)$, et $\mathcal{L}$ une droite
passant par ce point.
La droite $\mathcal{L}$ d'équation $t = x \cos \varphi + y \sin \varphi$
correspond à la droite distante de $t$ par rapport à l'origine, avec un angle
$\varphi$ par rapport à l'axe $x$. On définit alors la transformée de Radon de
la fonction $f$ sur $\mathbb{R}^2$ est définie ainsi :

\begin{equation}
    r_{\mathcal{L}}(f) =
        \int_{\mathcal{L}}f(x,y)\,ds,
    \label{eqn.integrale_curviligne}
\end{equation}

où $ds$ correspond au variations le long de la droite $\mathcal{L}$.
\Cref{eqn.integrale_curviligne} permet de calculer l'intégrale sur l'ensemble
des points $(x,y)$ de densité $f(x,y)$ appartenant à la droite $\mathcal{L}$
d'équation $t = x \cos \varphi + y \sin \varphi$. En utilisant la fonction de
Dirac, on peut définir la transformée de Radon ainsi :

\begin{equation}
    r_{\varphi}(f) =
        \int_{-\infty}^{\infty}
        \int_{-\infty}^{\infty}
        f(x,y) \delta (x \cos(\varphi) + y \sin(\varphi) - t)\,dx\,dy
    \label{eqn.radon}
\end{equation}

où $\delta(x)$ correspond à l'impulsion de Dirac. \Cref{eqn.radon} représente
la projection de la fonction $f(x,y)$ suivant la droite $\mathcal{L}$ sur une
droite orthogonale à $\mathcal{L}$ pour un angle $\varphi$. La valeur obtenue
correspond à l'intensité cumulée le long de la droite d'acquisition.

Puisque l'équation de la transformée de \citeauthor{radon1917akad} correspond à
une application linéaire, elle a la propriété d'être inversible. La transformée
inverse est également énoncé dans l'œuvre de \citeauthor{radon1917akad}
\cite{radon1917akad}. Cette opération inverse consiste à reconstruire $f$ à
partir d'un ensemble suffisant de projections $r_{\varphi}$ déterminées à partir de
différents angles de projection.

La transformation d'une image correspond à la superposition des sinusoïdes
générées par chaque point $(x,y)$ de l'image. Chaque point de l'image
correspond à une sinusoïde d'amplitude $\sqrt{x^2 + y^2}$ dans le domaine de
Radon.

En pratique, la reconstruction par transformée de Radon est un *problème mal
posé*, au sens défini par \citeauthor{hadamard1902pub}, pour trois raisons
\cite{hadamard1902pub}. Premièrement, il n'existe pas de solution puisque
le processus d'acquisition intègre du *bruit* dans les données. De plus, il
n'est pas possible de garantir l'*unicité* de la solution puisque l'acquisition
mesure un nombre fini de projections. Enfin, le processus de reconstruction est
*instable* dans le sens où une petite erreur d'acquisition a des répercutions
significatives sur les résultats. Il existe plusieurs techniques d'inversion de
la transformée de Radon. Parmi elles, nous citerons deux méthodes : la
reconstruction par Fourier basée sur le théorème de la tranche centrale, et la
rétroprojection filtrée. Dans la suite, nous verrons deux versions discrètes et
exactes de la transformée de Radon. En particulier nous verrons précisément
les méthodes de reconstruction pour ces techniques.

## Quelques bases de la géométrie discrète

Le procédé permettant de transformer un espace ou un objet continu en un
pavage ou en un objet discret, est appelé *discrétisation* (ou
*numérisation*). Il est ainsi possible de transformer une fonction continue
$f:\mathbb{R}^2 \rightarrow I$ en un ensemble de cellules.


### Ensemble, topologie et connexité dans le domaine discret

\begin{figure}[t]
    \centering
    \def\svgwidth{\textwidth}
    \includesvg{img/pavages}
    \caption{Représentation des trois pavages réguliers possibles sur
    $\mathbb{Z}^2$ (carré, triangle, hexagone) et le maillage associé.}
    \label{fig.pavage}
\end{figure}

Un *espace discret* $\mathbb{Z}^n$ est une décomposition du plan de dimension
$n \geq 2$ en cellules qui forment un *pavage*. Une cellule peut être
représentée par un son centre de gravité, appelé *point discret*.
L'ensemble des points discrets d'un pavage forme un *maillage*.
Par la suite, on travaillera sur des pavages qui vérifient les trois propriétés
suivantes :

1. réguliers : les cellules correspondent à des formes régulières
(i.e.\ des polygones dont tous les côtés et tous les angles sont égaux) dont
les sommets sont en contact avec un nombre fini de sommets appartenant à
d'autres cellules afin de remplir entièrement l'espace sans recouvrement;

2. de dimension $2$, c'est à dire que l'image correspond à une partie
de $\mathbb{Z}^2$ (on utilisera les termes *pixel* ou *éléments
structurant* pour désigner les cellules);

3. dont les cellules sont facilement adressables, pour cela on utilisera un
pavage carré afin d'adresser directement les éléments par un couple de
coordonnées $(x,y)$ (le maillage d'un pavage carré est carré contrairement au
maillage d'un pavage triangulaire ou hexagonal).

Les notions topologiques dans le domaine discret sont définies à partir de la
notion de *voisinage* et de *connexité*
\cite{rosenfeld1970acm,rosenfeld1979tamm}. Considérons deux points $P$ et $Q$
définis par leurs coordonnées $(x,y)$ dans un pavage carré. Dans ce cas, $P$ et
$Q$ sont deux points voisins si une et une seule de leurs coordonnées
diffère d'une unité. En particulier, le point $P$ possède quatre voisins qui
correspondent aux points de coordonnées $(x-1,y),(x+1,y),(x,y-1),(x,y+1)$. Dans
ce cas, on parle de *$4$-connexité*.
Un *chemin* est alors défini comme une suite de points de telle manière que
deux points consécutifs soient voisins.

Pour finir, on définit une *composante connexe* comme étant un ensemble $S$ de
points discrets tel que pour tout couple de points $(P,Q)$ appartenant à $S$,
il existe un chemin reliant $P$ à $Q$ dont tous les points appartiennent à $S$.


### Angle et droite discrète

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
    la suite de Farey $F_3$.}
    \label{fig:farey}
\end{figure}

On s'intéresse dans cette partie à déterminer les points d'intersection entre
le maillage définit par les points d'un ensemble discret de taille $(N \times
N)$, et une droite d'équation $y = ax + b$.
Pour que cette intersection ne soit pas vide, il est nécessaire que la pente de
la droite soit de la forme :

\begin{equation}
    0 \leq \frac{q}{p} \leq 1,
    \label{eqn.pente_droite}
\end{equation}

où $p$ et $q$ sont des entiers premiers entre eux, et vérifiant
$q \leq p \leq N$. L'ensemble des pentes des droites possibles défini par
\cref{eqn.pente_droite} forment alors une suite de Farey d'ordre $N$, notée
$F_N$ \cite{franel1924gdwg} (les autres droites sont obtenues par symétrie).
Une suite de Farey $F_N$ d'ordre $N$ est l'ensemble des fractions irréductibles
comprises entre $0$ et $1$, ordonnées de manière croissante et dont le
dénominateur n'est pas plus grand que $N$.
Chaque fraction d'une série de Farey correspond à un point $(x,y)$ de
$\mathbb{Z}^2$. Par exemple, la suite de Farey d'ordre $3$ correspond à
l'ensemble :

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

Par la suite, nous utiliserons le terme *direction discrète* pour désigner le
couple d'entier $(p,q) \in \mathbb{Z}^2$, premiers entre eux, et qui correspond
à une direction suivant la pente $\frac{q}{p}$.


## Méthode algébrique de reconstruction d'une image discrète

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

    \caption{Exemple de projections discrètes suivant quatre directions $(p,q) =
    \{(0,1),(1,1),(0,1),(-1,1)\}$.}
    \label{fig.inverse_discret}
\end{figure}

Par la suite, on considère une distribution d'intensité $f(x,y)$ où le couple
d'entier $(x,y)$ représente la position d'une cellule sur pavage régulier
carré. En pratique, les *images numériques* correspondent à la distribution d'une
intensité lumineuse. Le système de codage RVB indique l'intensité de chacune
des trois couleurs primaires (rouge, vert et bleu) sur un canal différent codé
sur un octet (l'intensité de chaque couleur est alors comprise entre les
valeurs $0$ et $255$).

Le problème soulevé par la tomographie discrète correspond à reconstruire
les valeurs de l'image (c'est à dire, la valeur des pixels a, b, c et d) de
manière unique, à partir des valeurs de projections calculées. Dans notre
exemple, les valeurs de projections correspondent à la somme des valeurs des
pixels traversés par les droites de projections.

Le problème peut être vu comme un problème d'algèbre linéaire. Dans cette
représentation, les pixels de l'image forment les inconnus à reconstruire
tandis que les projections correspondent aux équations linéaires.
Dans l'exemple proposé, si nous disposions uniquement des projections
verticales et horizontales nous posons le problème sous la forme d'un système
d'équations linéaires à $4$ équations et $4$ inconnues :

\begin{equation}
    \left\{
    \begin{array}{cc}
            a + b &= 7\\
            c + d &= 7\\
            a + c &= 6\\
            b + d &= 8
    \end{array}
    \right .
    \label{eqn.reconstruction_multiple}
\end{equation}

On peut écrire ce système d'équations linéaires sous la forme matricielle :
$\textbf{A}x=b$, où $\textbf{A}$ est la matrice de projection $(6 \times 4)$,
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
        7 \\ 7 \\ 6 \\ 8
    \end{pmatrix}
    \label{eqn.ensemble_nok}
\end{equation}

Dans cet exemple, la matrice $\textbf{A}$ n'est pas inversible (son déterminant
est différent de zéro). En conséquence, la reconstruction fournit un ensemble
fini de solutions (pas se solution unique).
L'ensemble des projections mesurées n'est pas suffisant pour déterminer de
manière unique une solution. Si l'on rajoute deux nouvelles mesures suivant les
diagonales, on obtient le système d'équations surdéterminé suivant :

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
        7 \\ 7 \\ 6 \\ 8 \\ 5 \\ 9
    \end{pmatrix}
    \label{eqn.ensemble_ok}
\end{equation}

Le déterminant de cette matrice est à présent nul, il est alors possible de
déterminer de manière unique une solution de reconstruction à travers la
méthode suivante :

\begin{align}
    \textbf{A} x &= b\\
    \textbf{A}^{\intercal} \textbf{A} x &= \textbf{A}^{\intercal} b\\
    x &= [\textbf{A}^{\intercal}]^{-1} \textbf{A}^{\intercal} b
    \label{eqn.art}
\end{align}

En pratique, les méthodes algébriques ne sont pas performantes.
On préfèrera une méthode itérative ou analytique sur de grandes images.

# Code MDS par transformée de Radon finie (FRT)

## Transformée de Radon finie

Nous avons vu dans la partie précédente que la transformée de Radon continue
constitue un outil mathématique capable de résoudre le problème inverse.
Cependant, ce théorème ne peut être appliqué en pratique. Nous verrons dans
cette partie une version discrète de cet outil, appelé transformée de Radon
finie.

### Transformée de Radon finie directe

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

La transformée de Radon finie (*Finite Radon Transform* ou FRT) est une version
discrète et exacte de la transformée de Radon continue. Elle a été conçue par
\citeauthor{matus1993pami} en \citeyear{matus1993pami} \cite{matus1993pami}.
Elle consiste à reconstruire une image $f(k,l)$ à deux dimensions à partir d'un
ensemble de projections 1D. Cette image peut être représentée par une grille
discrète dont chaque élément peut contenir différents types d'informations.
Pour appliquer la transformée de Radon sur cette grille, il est nécessaire
qu'elle soit carrée, de taille $p \times p$, avec $p$ un nombre premier. Dans
ce cas, il est alors possible de définir exactement $(p+1)$ directions
discrètes. La FRT consiste alors à calculer la somme des éléments de la grille
discrète suivant ces $(p+1)$ directions. Elle transforme ainsi une image
$(p \times p)$ en une représentation contenant $(p+1) \times p$ éléments.

La transformée de Radon finie est définie ainsi :

\begin{align}
    R(m,t)  &= \sum_{x=0}^{p-1} \sum_{y=0}^{p-1} f(x,(mx + t) \pmod{p}),
    \label{eqn.frt}\\
    R(p,t)  &= \sum_{x=0}^{p-1} \sum_{y=0}^{p-1} f(t, y).
    \label{eqn.frt_p}
\end{align}

\Cref{eqn.frt} signifie que les éléments des $p$ premières projections sont
issus de la somme des éléments de la grille suivant la droite $t \equiv x - m y
\pmod p$. Tandis que la ligne $(p+1)$ du domaine transformée, définie dans
\cref{eqn.frt_p}, correspond à la somme horizontale des éléments de l'image.

En conséquence, chaque ligne du domaine FRT correspond à la somme verticale des
lignes de l'image après un décalage de $m \times y$.
La particularité de la FRT est que l'image est représentée sous une forme
torique, de telle sorte que l'élément $(x,y) = (p,p) = (0,0)$.
La droite de projection se retrouve du côté opposé de l'image quand
elle dépasse du bord. En conséquence, puisque $p$ est premier, il n'existe
qu'une seule droite passant par deux éléments distants. Il est alors possible
de constituer $(p+1)$ projections de longueur $p$. Chaque projection traverse
une et une seule fois chaque éléments de la grille discrète. En conséquence, la
somme de tous les éléments d'une projection correspond à la somme de tous les
éléments de l'image, et l'on appelle cette somme $I_{sum}$.
 
\begin{algorithm}[t]
    \caption{Application directe de la transformée de Radon finie}
    \label{alg.frt}
    \begin{algorithmic}[1]

    \Require L'image $f(x,y)$ et sa taille $p \times p$

    \For{$m=0 \text{ à } p-1$}
        \State $n \leftarrow i$
        \For{$y=0 \text{ à } p-1$}
            \State $n \leftarrow n - i$
            \If {$n < 0$} \State $n \leftarrow n + p$
            \EndIf
            \State $t \leftarrow n - 1$
            \For{$x=0 \text{ à } p-1$}
                \State $t \leftarrow t + 1$
                \If {$t \geq p$} \State $t \leftarrow t - p$
                \EndIf
                \State $R(m,t) \leftarrow f(x,y)$
            \EndFor
        \EndFor
    \EndFor

    \For{$y=0 \text{ à } p-1$}
        \For{$x=0 \text{ à } p-1$}
            \State $R(p,y) \leftarrow f(x,y)$
        \EndFor
    \EndFor

    \end{algorithmic}
\end{algorithm}


### FRT inverse par reconstruction algébrique

La méthode de FRT inverse permet de retrouver l'image initiale à partir des
données de projections. Pour cela, on applique la même méthode que lors de la
transformée directe, à l'exception de la direction de projection qui vaudra
$m\prime = n-m$.
%
On obtient alors une image reconstruite dont les éléments correspondent à
$(f(x,y) \times n) + I_{sum}$, où $f(x,y)$ correspond à la valeur d'origine de
l'élément $(x,y)$. Pour retrouver l'image initiale, il faut alors
filtrer ces éléments en soustrayant leur valeur par $I_{sum}$, puis en divisant
par $n$. L'équation correspond à cette opération inverse est :

\begin{equation}
    f(x,y) =
        \frac{1}{p}\left(
            \sum\limits_{m=0}^{p-1} R(m,x- y \times m \pmod p) - I_{sum}
            \right)
    \label{eqn.frt_inverse}
\end{equation}

## Code à effacement par FRT

### Encodage par FRT

Par définition, la transformée est redondante puisque le domaine de transformée
comporte une ligne supplémentaire $R(n,t)$, qui correspond à la somme des
éléments de l'image suivant l'horizontale (voir \cref{eqn.frt_p}).

De précédents travaux ont permis de concevoir un code à effacement à partir de
la FRT en ajoutant certaines contraintes à la disposition des données
\cite{normand2010wcnc}. Cette étude présente une mise en œuvre à partir de la
représentation suivante. On définit une grille discrète $n \times (n)$, dans
laquelle on considère $k$ lignes de données utilisateurs. On considèrera les
$r=n-k$ lignes restantes nulles. Dans la version non-systématique de ce code,
les blocs encodés correspondent aux projections de Radon calculées.

Dans l'objectif d'obtenir un domaine de projection de même taille que le
domaine image, on définit la dernière colonne $f(x=(n-1),y)$ comme une colonne
de parité. Cela a deux conséquences : la première est que la dernière
projection est nulle de part la parité horizontale, la seconde est que la
dernière colonne du domaine de transformée correspond à un colonne de parité.
Il n'est alors pas nécessaire de garder ces informations. Cette mise en oeuvre
permet alors de transformer une image $f(x,y)$ de taille $(n-1) \times n$ en
$n$ projections de taille $(n-1)$.

Dans la version systématique, on considère les lignes de l'image comme blocs
encodés. Pour cela, il est nécessaire de calculer $r$ lignes de redondance.
Cette redondance est calculée de sorte que $r$ lignes consécutifs dans le
domaine de Radon sont nulles. Pour calculer ces $r$ lignes de redondance, on
peut utiliser l'algorithme de *row solving*. Cet algorithme est détaillé dans
la suite.
Notons que ces $r$ lignes sont alors composés de
fantômes puisque la valeur des projections suivant $r$ directions est nulles.

### Réparation d'erreurs

\begin{figure}
	\centering \input{tikz/espace_fantome.tex}
	\caption{Représentation circulante des fantômes ${a, b, c}$ correspondant
	respectivement à $m={1,3,4}$ dans le cas où $p=5$. Les grilles de gauche
	correspondent à la superposition des fantômes dans notre image lorsque que
	l'on reconstruit les projections issues des grilles de droite. Chaque
	étape correspond à un nouvel effacement, représentée par une ligne
	colorée.}
	\label{fig.ghosted_space}
\end{figure}

\begin{figure}
\hspace{2cm}
\makebox[\textwidth][c]{\input{tikz/frt_design.tex}}
	\caption{Conception d'un code FRT sous forme systématique (a) et
	non-systématique (b).}
	\label{fig:frt_design}
\end{figure}

En fonction de la mise en œuvre, le décodage ne s'effectue pas de la même
manière. Si le code est non-systématique, l'opération permettant de
reconstruire l'image correspond à l'opération inverse de la FRT décrite dans
\cref{eqn.frt_inverse}.

En revanche, lorsque le code est systématique, les données sont accessible en
clair lorsqu'aucun effacement n'affecte les données.

Nous décrivons à présent la mise en œuvre de la reconstruction des données en
cas d'effacements. Un effacement correspond à la perte complète d'une ligne
de donnée (les données effacée sont alors mises à zéro). La perte d'information
entraîne donc un domaine de projeté incomplet. Si l'on reconstruit cet espace,
on obtient une image composée de deux sous-images. La première image correspond
à l'image initiale des données utilisateurs. La seconde correspond à une image
contenant uniquement l'information des fantômes générés par la perte de cette
information.
En particulier, les $r$ lignes de données précédemment mises à zéro comporte
uniquement l'information des fantômes. Si le nombre de fantômes, correspondant
au nombre de lignes effacées, est inférieur ou égal à $r$, alors il est
possible de retrouver l'information initiale. Ainsi, l'algorithme de
reconstruction correspond à extraire les fantômes de l'image dégradée.

\begin{equation}
    F_x = R^{-1}m + G_x
    \label{eqn.frt_dégradé}
\end{equation}

De précédents travaux ont montré qu'il était possible de résoudre ce problème
en utilisant des techniques d'algèbre linéaire. La manière dont les fantômes se
distribuent sur l'image peut être représentée par une matrice de Vandermonde.
En conséquence, s'il est possible d'inverser cette matrice, alors il est
possible d'extraire ces fantômes.


## Relation avec d'autres codes à effacement

# Code à effacement par transformée Mojette

Le code à effacement Mojette est basé sur la transformée Mojette. Cette
transformée est également une version discrète et exacte de la transformée
continue de Radon. Elle a été proposée pour la première fois en
\citeyear{guedon1995vcip} par \citeauthor{guedon1995vcip} dans le contexte du
traitement et de l'encodage d'image \cite{guedon1995vcip}. Dans ce qui suit,
on décrira dans un premier temps la transformée Mojette directe. Les
conditions de reconstructions seront ensuite présentées, avant de voir
quelques algorithmes de reconstruction. On verra dans une dernière partie, la
mise en œuvre d'un code à effacement basé sur cette transformée.

## Transformée Dirac-Mojette directe

\begin{figure}
    \centering
    \def\svgwidth{.7\textwidth}
    \includesvg{img/mojette_forward_xor}
    \caption{La transformée de Dirac-Mojette. On considère une grille d'image 
    $P \times Q = 3 \times 3$ sur laquelle nous calculons $4$ projections
    dont les directions $(p_i,q_i)$ sont compris dans l'ensemble 
    $\left\{(-1,1), (0,1), (1,1), (2,1)\right\}$. La base utilisée est
    représentée par les deux vecteurs unitaires $\vec{u}$ et $\vec{v}$.
    L'addition est ici arbitrairement réalisée modulo $6$.}
    \label{fig.mojette_directe}
\end{figure}

La transformée Mojette est une opération linéaire qui calcule un ensemble de
$I$ projections à partir d'une image discrète $f:(k,l)\mapsto\mathbb N$. Bien
que cette image discrète peut avoir n'importe quelle forme, nous considèrerons
dans la suite une image rectangulaire, composée de $P \times Q$ éléments. Nous
appelons ces éléments des *pixels*. Un pixel est défini par ses
coordonnées $(k,l)$ dans la grille. Une projection est un vecteur défini par
une direction et une taille. La direction d'une projection $i$ est définie par
deux entiers $(p_i, q_i)$ premiers entre eux. Les projections sont des vecteurs
de taille variable. Cette taille varie en fonction des paramètres de la grille
et de la direction de projection. On appelle les éléments qui constituent une
projection des *bins*. La valeur des bins de la projection suivant la
direction $(p_i, q_i)$ résulte de la somme des pixels situés sur la droite
discrète d'équation $b = -kq_i + lp_{i}$. La transformée Dirac-Mojette est
définie ainsi :
\begin{equation}
    [\M f](b,p_{i},q_{i}) = 
        \sum_{k=0}^{Q-1} \sum_{l=0}^{P-1}
        f \left(k,l\right)
        \Delta\left(b+kq_{i}-lp_{i}\right),
    \label{eqn.mojette}
\end{equation}
\noindent où $\Delta(n)$ correspond à la fonction de Kronecker Cette fonction
vaut $1$ quand $n=0$, et zéro dans les autres cas. Le paramètre $b$ est l'index
du bin que l'on calcule par l'équation, considérant une projection définie par
sa direction $(p_i,q_i)$.

La transformée Mojette directe s'applique comme décrit dans
\cref{fig.mojette_directe}. Cet exemple montre la transformée Mojette d'une
grille discrète $3 \times 3$ composée d'entiers. Le traitement transforme une
image 2D en un ensemble de $I=4$ projections dont les valeurs des directions
sont comprises dans l'ensemble suivant : $\left\{(-1,1), (0,1), (1,1),
(2,1)\right\}$. Dans l'objectif de simplifier la représentation de cet exemple
et des suivants, l'addition est arbitrairement réalisée ici modulo $6$.
Cependant, on aurait pu choisir que la somme utilise des opérations d'additions
congruent n'importe quel entier, voir considérer l'utilisation d'arithmétique
usuel.

Considérons la projection suivant la direction $(p=0, q=1)$. Il s'agit alors de
la direction verticale puisque l'on considère que l'on se "déplace" de zéro
pixel vers la gauche, et de un pixel vers le haut. Chaque bin de cette
projection résulte de l'addition des pixels de la grille suivant la direction
verticale. Par exemple, le premier bin (situé à droite de la projection
représentée sur la figure) vaut $4+5+1 \pmod 6 = 4$.
Si l'on considère à présent une projection composée, les bins qui le
constituent résultent de la somme des pixels suivant la pente définie par la
direction de projection. Par exemple, si l'on considère les projections suivant
les directions $(-1,1)$ et $(1,1)$, la valeur de leurs bins correspond
respectivement à la somme des pixels de la grille suivant les deux diagonales.
Ce procédé est réitéré une nouvelle fois dans la figure afin de calculer la
projection suivant la direction $(2,1)$.
On peut remarquer que les bins situés aux extrémités des projections sont
entièrement définis par un unique pixel. Cette remarque sera nécessaire afin de
comprendre comment s'applique les algorithmes de reconstruction, qui sont
détaillés dans la prochaine partie.

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


## Reconstruction par transformée Mojette

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

## Code à effacement Mojette

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
%
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
Nous verrons à présent qu'il est possible de réduire la taille de ces
projections.

Lors du processus de reconstruction de la grille discrète, chaque ligne est
reconstruite à partir d'une projection dédiée. Puisque chaque ligne contient
$k$ pixels, cela signifie que la reconstruction va nécessiter la lecture de $k$
bins dans chaque projection.
%
Plus précisément, lors d'une reconstruction, les projections qui vont
participer à la première et la dernière ligne, vont devoir lire sur les $k$
premiers bins. Pour les projections intermédiaires, la lecture se fera sur $k$
bins à partir d'un certain offset.
%
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

Une analyse a été proposée par \citeauthor{verbert2004wiamis} sur ce sujet
\cite{verbert2004wiamis}. En revanche, aucun algorithme efficace n'existe
aujourd'hui pour déterminer le nombre de bins inutilisé, ainsi que leur
position.

## Relations avec d'autres codes à effacement

### Matrice d'encodage

### Connexions avec les codes LDPC


\chapter{Nouvelle mise en œuvre systématique}

Nous avons vu précédemment la réalisation du code à effacement Mojette en
version non systématique. Dans cette partie, nous verrons une nouvelle
conception de ce code à effacement en version systématique. Dans cette nouvelle
version, la donnée utilisateur fait partie intégrante de la donnée encodée.
L'objectif ici est d'améliorer les performances du code. Plus précisément, nous
verrons dans un premier temps comment nous avons réalisé cette nouvelle mise en
œuvre du code à effacement Mojette. Par la suite, nous analyserons les impacts
de cette nouvelle méthode sur les performances du code, avant d'étudier et
comparer la quantité de redondance générée par rapport aux autre codes.

# Mise en œuvre d'une version systématique

Cette partie présente une nouvelle mise en œuvre du code à effacement basé
sur la transformée Mojette. Précédemment nous avons vu qu'il était possible
d'utiliser les propriétés de la transformée Mojette afin représenter un objet de
manière redondante.
Cependant, dans le contexte des télécommunications, les applications
font face à des contraintes temps-réel. Dans la suite de notre étude, nous
inscrirons nos travaux dans un contexte de stockage distribué. Dans ce
contexte, de fortes contraintes existent sur les délais de réponse. En
conséquence, il est nécessaire de fournir un code à effacement  
qui puisse être suffisamment réactif pour ne pas être un goulot d'étranglement
sur la chaîne de traitement des données.

Dans la forme non-systématique du code à effacement Mojette, nous considérons
la génération de $n$ projections Mojette à partir d'une grille discrète de
hauteur $k$. Cette méthode permet de reconstituer la donnée utilisateur dans le
cas où $(n-k)$ projections sont inaccessibles.
Nous verrons dans les deux parties qui suivent, les bénéfices de cette nouvelle
approche pour l'encodage, puis pour le décodage.

## Bénéfice de cette nouvelle technique sur l'encodage

Les modifications de cette nouvelle technique sont l'encodage sont simples.
Précédemment avec la version systématique, il était nécessaire de calculer $n$
projections à partir d'une grille discrète constituée de $k$. Dans cette
nouvelle version systématique, nous considérons les $k$ lignes de cette grille
comme faisant partie des données encodées. En conséquence, il suffit de
calculer $(n-k)$ projections pour fournir la même protection qu'avec l'approche
classique du code à effacement Mojette $(n,k)$. Prenons l'exemple d'un code
avec un taux de $\frac{3}{2}$, comme un code
$(6,4)$ fournissant de la protection face à deux effacements. En
non-systématique, il est nécessaire de générer $6$ projections à partir d'une
grille de hauteur $4$, et de transmettre ces $6$ projections. À présent, en
systématique, il suffit de générer $2$ projections, et de transmettre les $4$
lignes de données de la grille ainsi que les $2$ projections. On considère
l'ensemble des données encodées comme étant ces $4$ lignes de données et ces
$2$ projections Mojette. En conséquence, dans notre exemple qui correspond à
des paramètres de code classiques, cette nouvelle version calcule $3$
fois moins de projections.
Nous verrons dans la prochaine partie que le décodage nécessite davantage de
travail.

## Bénéfice de cette technique sur le décodage

Dans cette partie nous allons distinguer le cas où aucun effacement ne
survient, et le cas dégradé où certaines données sont perdues.

### Accès direct sans dégradation

Le principal avantage de cette technique est de ne pas avoir besoin d'exécuter
d'opération de décodage quand aucune des $k$ lignes de données ne subit 
d'effacement. En effet, dans ce cas, la donnée est immédiatement accessible en
clair. En conséquence aucun surcout calculatoire n'est engendré et les
performances sont considérées comme optimales.
En revanche, lorsque des effacements surviennent sur la donnée, il est
nécessaire d'appliquer un algorithme de décodage afin de les reconstruire.

### Dégradation partielle des données

\begin{figure}
    \def\svgwidth{.7\textwidth}
%\includesvg{figures/partial_mojette_systematic}
    \caption{Grille partiellement reconstruite. On considère une grille
    discrète de hauteur $k = 4$, à partir de laquelle ont été calculées $2$
    projections Mojette. Cet ensemble de données fourni $6$ blocs encodés sous
    une forme systématique. Dans cette représentation, $e = 2$ lignes de la
    grille ont subi des effacements. En conséquence, la grille est
    partiellement reconstruite, et l'opération de décodage consiste a rétablir
    les deux lignes perdues à partir des deux projections.}
    \label{fig.mojette_systematique_partielle}
\end{figure}

Une dégradation des données entraîne nécessaire une opération de décodage
afin de restaurer la donnée perdue. Nous considérons à présent que le nombre de
lignes de grille discrète effacés $e$ est inférieur à $k$. Dans ce cas,
l'opération de décodage est possible dés lors que l'on accède à un ensemble
suffisant de $e$ projections pour reconstruire les $e$ lignes effacées. Plus
précisément, il s'agit de reconstruire une grille qui serait partiellement
reconstruite.

L'algorithme d'inversion doit donc prendre en compte non seulement la valeur
des bins des projections, mais également la valeur des pixels déjà présents
dans la grille. Nous verrons en détail ce nouvel algorithme dans la prochaine
partie.

\Cref{fig.mojette_systematique_partielle} montre une grille discrète de hauteur
$k = 4$ à partir de laquelle ont été calculées deux projections. La grille est
partielle puisque $e = 2$ lignes ont été effacées. L'opération de décodage
consiste à rétablir les données des lignes perdues à partir de $e = 2$
projections.

En terme de performance, cette nouvelle mise en œuvre est plus performante
qu'en version systématique quand des effacement surviennent sur la donnée. En
effet, dans une version systématique, quelque soit le schéma de perte sur les
projections (qui correspondent entièrement aux données encodées), toute la
grille doit être reconstruite. En revanche, dans notre cas, puisque l'opération
de décodage correspond à la reconstruction d'une grille partiellement
reconstruite, moins d'éléments dans la grille doivent être reconstruite. En
conséquence, moins d'opérations sont nécessaires pour rétablir les données.

### Perte complète des données

Dans le cas où l'ensemble des $e = k$ lignes de la grille est effacé, il est
nécessaire de décoder l'information à partir de $k$ projections. Dans le cas où
cela est possible, l'opération de décodage correspond alors à celle réalisée
quand le code est non-systématique.

En terme de performance, les performances du décodage en systématique sont donc
au pire similaire à celles obtenues en non-systématique. Pour le reste des cas
vu précédemment, ces performances sont au mieux optimales, sinon meilleures.


# Algorithme inverse en systématique 

L'algorithme inverse présenté dans cette partie correspond à une extension de
l'algorithme inventé pour la version non-systématique par
\citeauthor{normand2006dgci}, étudié dans la partie précédente
\cite{normand2006dgci}.
Dans cette partie, nous décrivons deux modifications majeures à cet
algorithme. La première concerne la détermination des offsets pour chaque
projection. La seconde correspond au calcul de la valeur du pixel à
reconstruire.

## Détermination des offsets pour la reconstruction

De manière comparable à ce qui est réalisé dans l'algorithme de
\citeauthor{normand2006dgci}, il est nécessaire de déterminer la valeur des
offsets pour chaque ligne. De manière graphique, ces offsets correspondent aux
décalages nécessaires sur chaque ligne relativement au chemin de
reconstruction. Plus précisément, ils permettent à l'algorithme de déterminer
quelle ligne de la grille discrète doit être considérée afin de garantir la
reconstruction d'un nouveau pixel.

Dans le cas de la version non-systématique, ces offsets étaient simplement
déterminés à partir de l'index de la ligne à reconstruire et de la direction de
la projection utilisée pour la reconstruire. Dans la version systématique, il
est de plus nécessaire de prendre en compte le schéma de perte. Puisque
dans cette version, certaines lignes de la grille peuvent être déjà présentes,
la reconstruction met en jeu un sous-ensemble de lignes à reconstruire. En
conséquence, il est nécessaire de prendre en compte les lignes déjà présentes
dans le calcul des offsets des lignes à reconstruire.

Ainsi, on calcule l'offset de la dernière ligne à reconstruire :

\begin{multline}
    \text{Offset}(\text{failures}(e-1)) =\\
        max(max(0,-p_r) + S_{minus}, max(0,p_r) + S_{plus}).
    \label{eqn.offset_last_sys}
\end{multline}

Puis les offsets des lignes à reconstruire.

\begin{equation}
    \text{Offset}(\text{failures}(i) =\\
        \text{Offset}(\text{failures}(i+1) + p_{i+1} \\
    \label{eqn.offset_sys_i}
\end{equation}
\begin{multline}
    \text{Offset}(\text{failures}(j) =\\
        \text{Offset}(\text{failures}(j)
        - (\text{failures}(i+1) - \text{failures}(i) - 1) * p_{i+1}
    \label{eqn.offset_sys_j}
\end{multline}

## Calcul de la valeur du pixel à reconstruire
\label{sec.valeur_pxl}

L'algorithme BMI repose sur deux choses. La première est la détermination des
offsets afin de toujours traiter des pixels qui ne possèdent aucune dépendance. 
La seconde est la mise à jour des valeurs des bins de chaque projections en
relation avec le pixel reconstruit. Grâce à cela, il est d'une part facile de
déterminer l'index du prochain pixel à reconstruire, d'autre part sa valeur
peut être immédiatement lue à partir d'un bin d'une projection.

Dans la version systématique, lors de la reconstruction, les valeurs des pixels
ne dépendent plus seulement des valeurs de bins, mais elles peuvent dépendre
des valeurs des pixels non-effacés et/ou déjà reconstruits.
En particulier, si l'on observe la reconstruction d'un pixel par une
projection, il dépend de l'ensemble des pixels situés sur la droite de
projection $b = -kq_i + lp_{i}$, et aussi de la valeur du bin $b$ de cette
projection. Nous considérons à présent $\tilde{f}(k,l)$ comme étant le pixel
à reconstruire, où l'on définit $\tilde{f}$ comme étant l'image à
reconstruire. Alors, on considère $Proj_{\tilde{f}}(p_i, 1, k - lp_i)$
comme étant la somme des valeurs des pixels selon la droite définie
par ce pixel, étant donné une direction de projection.
En conséquence, la valeur du pixel à reconstruire est donné par :

\begin{equation}
    f(k,l) = Proj_f(p_i, q_i, k - lp_i) + Proj_{\tilde{f}}(p_i, 1, k - lp_i).
    \label{eqn.sys_pxl}
\end{equation}
 
\begin{algorithm}
    \caption{Extension pour la version systématique de l'algorithme BMI}
    \label{alg.systematique}
    \begin{algorithmic}[1]

    \Require $Proj(p_i,1,b)$ trié par $p_i$ ascendant
    \Require $e$ trié par ordre descendant

    \Comment Calcule $S-$, $S+$ et $S$

    \State $S_{minus} \leftarrow S_{plus} \leftarrow 0$
    \For{$i=0 \text{ à } Q-2$}
        \State $S_{minus} \leftarrow S_{minus} + max(0, -p_i)$
        \State $S_{plus} \leftarrow S_{plus} + max(0, p_i)$
    \EndFor
    \State $S \leftarrow S_{minus} - S_{plus}$

%    \Comment Calcule la valeur de l'offset pour chaque projection

    \State offset$(I-1) \leftarrow max(max(0,-p_r)
        + S_{minus}, max(0, p_r) + S_{plus})$
    \For{$i \leftarrow (np - 2) \text{ à } 0$}
        \State $\text{offset}(i) \leftarrow \text{offset}(i+1) + p_{i+1}$
%        \Comment offset relatif à la direction de projection
        \For{$j \leftarrow (i + 1) \text{ à } np$}
            \State $\text{offset}(j) \leftarrow \text{offset}(j) -
            \left((e_{i+1}-e_i-1) \times p_{i+1}\right)$
%            \Comment mise à jour des offsets des lignes inférieures
        \EndFor
    \EndFor

    \For{$k \leftarrow \text{offset}(r) \text{ à } (P - 1)$}
        \For{$l \leftarrow 0 \text{ à } \text{offset}(r - 1)$}
            \State $pv = Proj_{\tilde{f}}(p_i, q_i, k - (p_i \times l))$
            \State $f(k,l) \leftarrow Proj_f(p_i, q_i, k - (p_r \times l) + pv$
        \EndFor
    \EndFor
    
%    \KwData{the ordered set of projections $Proj(p_i,1,b)$ (increasing $p_i$)}
%    \KwData{the set of data rows $f(l)$ for $l \in \mathbb{Z_Q}$}
%    \KwData{the ordered set of erased data rows index $failures(l)$ for $l \in
%        \mathbb{Z_e}$}

    \end{algorithmic}
\end{algorithm}



# Évaluations du code Mojette

## Évaluation du surcout de stockage
\label{sec.surcout_stockage}

\begin{figure}
\centering
\input{./tikz/ec_vs_rep.tikz}
\caption{Comparaison du facteur de coût de stockage $f$ généré par différentes
    techniques de codes à effacement, en fonction de la tolérance aux pannes.
    Les paramètres des codes correspondent à $(n,k)$ égal $(3,2)$, $(6,4)$ et
    $(12,8)$, fournissant une protection face à une, deux et quatre pannes
    respectivement. Dans le cas particulier du code à effacement Mojette, deux
    tailles de bloc de données sont données : $\mathcal{M} = 4$Ko et $8$Ko.}
\label{fig:ec_vs_rep}
\end{figure}


Un code MDS génère la quantité minimale de redondance pour une tolérance aux
pannes donnée. Dans la partie précédente, nous avons vu que le code à
effacement Mojette n'est pas tout à fait MDS mais $(1+\epsilon)$ MDS. En effet,
bien qu'il soit capable de décoder $k$ blocs de données à partir de $k$ blocs
encodés, la taille de ces blocs peuvent dépasser la taille optimale. En
conséquence, pour une protection donnée, notre code génère plus de données que
la quantité minimale.

Dans cette partie, nous allons définir et évaluer le surcout de redondance
généré par le code à effacement Mojette. Nous définissons pour cela $f$ comme
étant le facteur de redondance du code. Plus particulièrement, $f$ correspond
au quotient du nombre d'éléments généré par le code, sur le nombre d'éléments
du message à encoder.
%
Dans notre évaluation, nous allons considérer trois techniques qui permettent
de générer de la redondance : la réplication, le code à effacement MDS, et le
code à effacement Mojette. Dans le cas des codes à effacement, nous allons
considérer un taux de codage de $r = \frac{2}{3}$ afin de les comparer
équitablement. Nous allons comparer ces techniques pour plusieurs paramètres de
protection, correspondant à une, deux et quatre pannes. En conséquence, les
paramètres $(n,k)$ des codes à effacement correspondant seront définis dans
l'ensemble $\left\{(3,2),(6,4),(12,8)\right\}$.

Dans le cas de la réplication, le facteur de redondance $f$ correspond au
nombre de copies généré, c'est à dire, à la tolérance aux pannes plus un. Par
exemple, dans le cas où l'on souhaite protéger la donnée face à deux pannes, il
est nécessaire de générer trois copies de l'information. En conséquence, dans
le cas de la réplication par trois, le facteur de redondance $f$ vaut trois.

Pour les codes MDS, la valeur du facteur de redondance $f$ correspond à
l'inverse du taux de codage. En effet $r$ correspond à la quantité de donnée
en entrée $k$ sur la quantité de donnée de sortie $n$. C'est pourquoi, si l'on
fixe un taux de codage $r$, quelque soit la tolérance au panne de notre code,
la quantité de redondance produite reste la même, à savoir $\frac{1}{r}$.

Pour le code à effacement Mojette, c'est moins trivial. Nous avons vu dans la
partie précédente que la taille des projections varie en fonction des
paramètres de la grille discrète $P$ et $Q$, ainsi que des paramètres des
directions de projections $(p_i, q_i)$. Sa valeur est donnée dans
\cref{eqn.nombre_bins}. 

Dans le cas du code à effacement non systématique, la valeur de $f$ correspond
à :

\begin{equation}
    f = \frac
        {\sum\limits_{i=0}^{n-1} B(P,Q,p_i,q_i)}
        {P \times Q}.
    \label{eqn.f_non_systematic}
\end{equation}

Dans le cas où le code est systématique, $k$ projections sont remplacées par
$k$ lignes de la grille discrète. En conséquence, la valeur de $f$ correspond à
:

\begin{equation}
    f = \frac
        {P \times Q \sum\limits_{i=0}^{n-k-1} B(P,Q,p_i,q_i)}
        {P \times Q}.
    \label{eqn.f_non_systematic}
\end{equation}

Dans notre évaluation, nous considérons un ensemble de projection de telle
sorte que $q_i =1$ pour $i \in \mathbb{Z}_Q$, alors $B(P,Q,p_i,1) = (Q-1)|p_i|
+ P$.

La valeur de $f$ dépend ainsi de l'ensemble de projection choisi. En
particulier, la valeur de $p_i$ influence sa valeur. Afin de réduire cette
valeur, nous choisirons alternativement des entiers positifs puis négatifs,
dont la valeur croît à partir de zéro, comme valeurs de $p_i$.
En particulier, dans notre évaluation, nous considérerons les ensembles de
projection suivants:

1. $S_1 = \left\{(0,1)\right\}$,

2. $S_2 = \left\{(0,1),(1,1)\right\}$,

3. $S_4 = \left\{(0,1),(1,1),(-1,1),(2,1)\right\}$,

afin de protéger la donnée face à une, deux et quatre pannes respectivement.
Observons que dans le premier cas, la taille de la projection calculée selon la
verticale est optimale. En conséquence, dans cette configuration particulière,
le code est MDS. Ce n'est pas le cas en général.

## Analyse du nombre d'opérations

Les performances d'un code dépendent intrinsèquement de la nature et du nombre
des opérations réalisées par le code. Nous verrons dans un premier temps le
nombre d'opérations nécessaires pour les opérations d'encodage. Les
performances en encodage sont similaires que la version du code soit
systématique ou pas. Dans la suite nous distinguerons les deux cas pour l'étude
en décodage.

### Encodage

L'opération d'encodage génère $n$ projections à partir d'une grille discrète de
hauteur $k$. Bien que la génération d'une projection met en jeu l'ensemble des
éléments de la grille discrète une et une seule fois (voir \cref{eqn.mojette}),
le nombre $c$ d'opérations nécessaires pour l'encodage varie en fonction de
deux paramètres : la taille de la grille, et la direction de projection.
Le nombre d'additions nécessaires pour générer une projection
$\text{Proj}_{f}(p,q,b)$ est correspond à :

\begin{align}
    c(P,Q,p,q)  &= P \times Q - B(P,Q,p,q), \\
                &= P \times Q - \left((Q-1)|p_{i}|+(P-1)|q_{i}|+1\right).
    \label{eqn.enc_mojette}
\end{align}

et représente le nombre d'éléments de la grille discrète ($P \times Q$) auquel
on soustrait le nombre de bins de la projection, tel que défini dans
\cref{eqn.nombre_bins}. 
Considérons à présent que l'on fixe la taille de la grille, ainsi qu'un
paramètre de projection. Nous reprendrons notre exemple avec $q_i=1$. Dans ce
cas, si $p=0$, alors $c(P,Q,0,1) = (P-1)w - P$. De plus, si la valeur de $|p|$
augmente, alors le nombre d'opérations nécessaire pour générer une projection
$c(P,Q,p,q)$ diminue. Cela signifie que plus une projection est grande, moins
elle nécessite d'opérations d'addition pour être générée.
En conséquence, si seules les performances sont essentielles pour une
application, on choisira des projections avec de grandes valeurs de $p$.

### Décodage pour la version non-systématique

Nous comparerons ici deux algorithmes. Le premier correspond à l'algorithme de
reconstruction MBI défini par \citeauthor{normand2006dgci}
\cite{normand2006dgci}. Le second correspond à un cas particulier de
l'algorithme de reconstruction systématique, dans le cas où toutes les lignes
de la grille ont été effacées.

Dans le premier algorithme, il s'agit de reconstruire un pixel avant de mettre
à jour l'ensemble des bins correspondant dans les $k$ projections utilisées
lors de la reconstruction. Puisqu'en non systématique, il est par définition
nécessaire de reconstruire tous les pixels de la grille, le décodage nécessaire
$P \times Q \times Q$ additions correspondant à ces mises à jour. La
reconstruction du pixel en lui même correspond toujours à la lecture simple du
bin correspondant.

### Coût pour la version systématique

\begin{figure}
    \def\svgwidth{.7\textwidth}
%\includesvg{figures/dec_sys_mojette}
    \caption{Représentation de la méthode de détermination du nombre
    d'opérations nécessaire pour reconstruire une ligne $l$ à partir d'une
    projection. Cet exemple représente une grille $(P=12,Q=6)$. On cherche à
    reconstruire la ligne $l=3$ à partir de la projection suivant la direction
    $(p=1,q=1)$. Les éléments en rouge représentent les éléments impliqués dans
    la reconstruction de la ligne.}
    \label{fig.dec_sys_mojette}
\end{figure}

Lors du décodage en systématique, en cas d'effacement de la donnée, on affecte
la reconstruction d'une projection à une ligne effacée de la grille. Comme l'on
l'avons vu précédemment dans \cref{sec.valeur_pxl}, la valeur du pixel à
reconstruire dépend non seulement d'un bin $b$ dans la projection
affectée, mais également de la somme des valeurs d'un ensemble d'éléments de la
grille. Notons qu'en fonction du pixel à reconstruire, le nombre d'opérations
nécessaire à sa reconstruction peut varier en fonction de sa position dans la
grille. Comme nous l'avons vu précédemment, un pixel situé dans un coin de la
grille nécessitera en général moins d'opérations qu'un pixel situé au milieu de
la grille. De plus, ce nombre va dépendre de la projection utilisée pour la
reconstruction. Si l'on reprend l'exemple d'un pixel situé dans un coin de la
grille, aucune opération n'est nécessaire si $(p,q) \ne (0,0)$, mais si
$(p,q)=(0,1)$ par exemple, alors $(Q-1)$ opérations seront nécessaires..

Le nombre d'opérations $c$ nécessaires par projection dépend ainsi non
seulement de la direction de cette projection, mais également de la ligne de la
grille discrète à reconstruire. Nous considérons $l$ l'index de cette ligne.
\Cref{fig.dec_sys_mojette} représente la situation où l'on souhaite
reconstruire la ligne $l=3$ d'une grille $(P=12,Q=8)$ en utilisant la
projection suivant la direction $(p=1,q=1)$. Les éléments de la grille en rouge
représente les pixels utilisés dans la reconstruction de la ligne $l$.

Le nombre d'opérations nécessaires à la reconstruction d'une ligne $l$ est
défini par le nombre d'éléments de la grille discrète contenus entre les deux
droites de projection qui passent par chaque extrémité de la ligne $l$.
Ce nombre correspond donc à la surface de la grille à laquelle on soustrait le
nombre d'éléments de la ligne à reconstruire $(Q-1)P$ auquel on soustrait les
deux triangles discrets supérieur et inférieur :

\begin{equation}
    c(P,Q,p,q,l) = (Q-1)P 
        - \frac{l(l+1)}{2}
        - \frac{(Q-l-1)(Q-l)}{2}
    \label{eqn.dec_sys_mojette}
\end{equation}

### Discussion

Bien que les performances théoriques sont liées par le nombre d'opérations
réalisées durant les opérations d'encodage et de décodage, d'autre critères
entrent en jeu dans la pratique.

% localité spatiale

% localité temporelle

\begin{table*}
\centering
\begin{tabular}{@{} l L L L L L @{} >{\kern\tabcolsep}l @{}}    \toprule
    \emph{Code} & \emph{Encoder $P$}& \emph{Encoder $Q$} & \emph{Mise à jour} &
    \emph{Décoder depuis $P$} & \emph{Décoder depuis $Q$} \\\midrule
    RS  & 
        $(k-1)w$ & 
        $(k-1)w + (kw)_{\otimes}$ & 
        $3 + 1_{\otimes}$ &
        $(k-1)w$ &
        $(k-1)w + (kw)_{\otimes}$  \\ 
    \rowcolor{black!20}[0pt][0pt] EVENODD & 
        $(k-1)w$ &
        $(k-1)w + k-2$ &
        $w+2$ &
        $(k-1)w$ &
        $(k-1)w+2(k-2)$ \\ 
    RDP &
        $(k-1)w$ &
        $(k-1)w$ &
        $4$ &
        $(k-1)w$ & 
        $(k-1)w$ \\ 
    \rowcolor{black!20}[0pt][0pt]Mojette &
        $(k-1)w$ &
        $(k-1)w-k+1$ &
        $3$ &
        $(k-1) w$ &
        $c_{decode}(l,k,w)$ (i.e.\ \cref{eqn.mojette_decoding}) \\\bottomrule
\end{tabular}
 \caption{Tableau de comparaison du nombre d'opérations nécessaires pour
 différents code à effacement selon les métriques définies dans la partie
 \cref{sec.nomenclature}. Pour les codes de Reed-Solomon, les opérations de
 multiplications sont symbolisées par $\otimes$. Lorsque différents résultats
 existent, le pire cas est affiché (e.g. les performances de décodage pour les
 codes EVENODD pour $Q$ dépendent du calcul de $S$).}
 \label{tab.comparison}
\end{table*}

## Expérimentations

Dans cette partie, nous évaluons les performances du code à effacement
Mojette et comparons ces résultats avec les performances des meilleures
implémentations des codes de Reed-Solomon.
Nous détaillons dans une première section les caractéristiques des codes
étudiés. Dans la suite, nous présenterons comment nous avons réalisé cette
expérimentation avant de nous intéresser aux résultats.

### Les implémentations à comparer

Nous avons choisi de comparer nos implémentations du code à effacement Mojette
avec une implémentation des codes de Reed-Solomon. De par leur popularité et
leur accessibilité, les codes de Reed-Solomon représentent le candidat évident
pour notre comparaison. Ces codes sont en effet largement distribués à travers
des bibliothèques.

#### Implémentations Mojette

Nous avons implémenté une version systématique du code à effacement Mojette en
langage C. Le choix de ce langage est judicieux lorsque l'on développe une
technique de codage devant fournir de hautes performances. En effet la
possibilité de laisser la gestion mémoire à l'utilisateur, ainsi que le recours
à diverses instructions particulières du processeur, permettent d'atteindre
d'excellentes performances.
%
Dans la suite, nous reprenons la terminologie utilisée dans la partie
précédente \ref{sec:mojette_directe}. En pratique, la taille des pixels de la
grille discrète, et des bins des projections, doivent correspondre à un mot
machine. Un mot correspond à l'unité de base, exprimée en bits, manipulée par
un processeur. Pour les architectures classiques, la taille d'un mot
correspond à $32$ ou $64$ bits. Il s'agit plus précisément de la taille des
registres du processeurs. En conséquence, un processeur est d'autant plus
rapide que ses mots sont longs puisqu'une plus grande quantité d'information
est traitée à chaque cycle. En conséquence nous avons fixé la taille des bins
et pixels à $64$ bits, ce qui correspond aux tailles de registres des
architectures largement déployés aujourd'hui.
%
La plupart des processeurs proposent depuis 1997 des extensions de leur jeu
d'instructions afin d'améliorer les performances de certains traitements. Les
instructions *Single Instruction, Multiple Data* (SIMD) correspondent à un mode
de fonctionnement du processeur afin de profiter de parallélisme. Plus
particulièrement, il s'agit d'appliquer en parallèle la même instruction sur
plusieurs données afin d'obtenir plusieurs résultats. Dans le cas d'Intel par
exemple, les extensions pour flux SIMD (*Streaming SIMD Extensions* SSE)
ajoutent jusqu'à 16 registres de 128 bits et 70 instructions supplémentaires
pour les processeurs x86. Ce mode de fonctionnement permet donc de traiter
$2048$ octets en parallèle, en un cycle processeur. Les applications tirent
donc un gain de performance significatif dés lors qu'une instruction peut être
réalisée sur plusieurs données. En pratique, ce mode est largement utilisé dans
les applications multimédias, scientifiques ou financières. Il permet notamment
d'augmenter les performances du RAID logiciel utilisé dans Linux
\cite{anvin2004raid}.
%
Ce mode de fonctionnement est donc très intéressant pour notre code à
effacement étant donné que les performances sont cruciales dans les systèmes
temps-réel. Les algorithmes d'encodage et de décodage Mojette sont adaptés à ce
fonctionnement puisque nous appliquons une instruction, qui correspond à
l'addition, sur une multitude de données, représentées par les éléments de la
grille discrète et des projections. En conséquence, dans notre mise en œuvre,
l'addition est implémenté par des opérations de OU exclusif (XOR),
correspondant à des additions modulo deux, sur des données de $128$ bits.

Dans cette partie, nous allons comparer les performances de deux
implémentations de notre code à effacement Mojette : une première version
non-systématique, que l'on appellera *NS-Mojette* dans la suite de la
rédaction, puis une implémentation systématique que l'on désignera simplement
par *Mojette*.

#### Implémentations Reed-Solomon

De nombreuses implémentations existent pour les codes de Reed-Solomon.
Plusieurs bibliothèques de codes à effacement proposent différentes
implémentations et les codes de Reed-Solomon s'y retrouvent dans la majorité
des cas. Les bibliothèques les plus connus sont OpenFEC \cite{openfec},
Jerasure \cite{plank2008jerasure} et ISA-L \cite{isa-l}.
Dans le contexte de nos tests, l'implémentation développée dans ISA-L offre les
meilleurs résultats en terme de performance. C'est pourquoi notre choix s'est
porté dessus pour notre comparaison. L'implémentation des codes de Reed-Solomon
proposée dans ISA-L se base sur des matrices de Vandermonde construite à partir
d'un corps de Galois GF($2^8$) et un polynôme primitif
$x^8 + x^4 + x^3 + x^2 + 1$.

### Configuration de l'expérimentation

Dans cette partie, nous allons évalué les performances d'encodage et de
décodage des implémentations des code à effacement Mojette et Reed-Solomon,
présentés précédemment. Ces tests sont réalisés sur un seul processeur afin de
mettre en évidence la différence de performance entre les différentes
implémentations.

Les tests que nous réalisons dans cette partie mettent en jeu plusieurs
plusieurs paramètres. Ainsi nous allons faire varier les paramètres $n$ et $k$
des codes à effacement, qui définissent implicitement la tolérance aux pannes
que fourni le code. En pratique, ce facteur dépend de la nature des données,
des applications et du support sur lequel transite la donnée.
Les fournisseurs de service web proposent en général une protection face à
quatre pannes. C'est le cas de Facebook, qui utilise des codes de Reed-Solomon
$(n,k)$ au sein de leurs grappe de stockage.
Un second paramètre concerne la taille des données $\mathcal{M}$ que nous
allons traiter. Dans la terminologie Mojette, cette taille correspond au nombre
d'éléments de la grille discrète. Ce paramètre dépend de l'application
utilisée. Dans le cadre de stockage de données POSIX, on choisira une taille
$\mathcal{M}$ correspondante à la taille des blocs du système de fichiers. Dans
l'exemple d'*ext4*, cette taille de blocs est de $4$ Ko. En revanche, dans des
applications mettant en jeu des accès séquentiels sur de grands fichiers, on
choisira une taille de bloc beaucoup plus importante afin de limiter le nombre
d'entrées/sorties. C'est le cas dans *Hadoop Distributed File Systems* HDFS,
qui met en jeu des applications d'analyse parallèle grâce à *Hadoop Map-Reduce*
sur des blocs de *128* Mo par défaut.

Les performances enregistrées lors de l'encodage correspondent au
nombre de cycles CPU nécessaire pour générer $n$ blocs encodés à
partir de $k$ blocs de données. Ces $k$ blocs totalisent $\mathcal{M}$ octets.
Plus particulièrement dans notre mise en œuvre, ces $k$ blocs correspondent à
une zone mémoire de $\mathcal{M}$ octets de données aléatoire, dont on
représente chaque bloc par $k$ pointeurs vers l'adresse de début de ces blocs.
L'encodage non systématique consiste alors à la génération de $n$ blocs de
données encodés à partir de ces données d'entrées. En revanche, pour les
versions systématiques, les performances d'encodage correspondent à la copie
des $k$ blocs de données, plus la génération de $(n-k)$ blocs de parité. Le
critère de comparaison de performance entre les différents codes correspond
donc au nombre d'opérations du CPU nécessaire pour offrir une certaine
tolérance aux pannes. Nous verrons dans la suite d'autres critères telles que
la consommation mémoire.

Concernant le décodage, les performances enregistrées correspondent à la
reconstruction des $k$ blocs de données. Un nouveau paramètre entre en jeu dans
les opérations de décodage puisque le schéma de perte influence les
performances du code à effacement. En conséquence, nous enregistrons les
performances du CPU pendant le décodage tout en augmentant le nombre de pannes
jusqu'à la tolérance limite qu'offre le code. Dans notre cas, une panne
correspond à l'absence d'information dans un bloc de données si le code est
systématique, sinon il s'agira de la perte d'un bloc encodé.

Nos tests sont exécutés sur une seule machine, un seul processeur et un seul
*thread*. Toutes les opérations sont réalisées en mémoire, en prenant soin de
ne pas créer d'interactions avec le disque dur. Les cycles CPU concernent
précisément les opérations décrites précédemment. Plus exactement, nous ne
considérons pas certains pré-traitements tels que la génération des matrices
d'encodage dans le cas des codes de Reed-Solomon, ou la détermination du chemin
de reconstruction dans le cas des codes Mojette.

Puisque l'on mesure des fonctions d'encodage et de décodage hautement
optimisées pour nos architectures processeurs dont les temps d'exécution sont
de l'ordre de la nanoseconde, il est imprécis, voire impossible, de mesurer le
temps d'exécution de ces fonctions de nos implémentations. En revanche, puisque
ces calculs sont bornées par les considérations vues dans la partie
précédentes, et puisque nos instructions sur réalisées au sein d'un thread sur
un processeur, il est possible d'obtenir une mesure sur le nombre de cycles du
processeur. Plus précisément, on utilise le compteur temporel (*Time Stamp
Counter* TSC) qui est un registre spécial qui s'incrémente à chaque cycle CPU.
Pour cela, on utilise l'instruction *ReaD Time Stamp Counter* (ou RDTSC) qui
permet de récupérer la valeur de ce registre. Il suffit alors d'enregistrer sa
valeur avant et après nos fonctions d'encodage et de décodage et d'afficher la
différence. Intel propose une mise en œuvre afin de filtrer les résultats
aberrants \cite{intel1997rdtsc}.

Enfin, nous affichons la valeur moyenne qui résulte de $100$ itérations.
L'écart type n'est pas présenté puisqu'il est trop négligeable (et correspond à
moins d'un pour-cent des valeurs présentées). La machine utilisée provient de
la plate-forme *FEC4Cloud* située à Polytech Nantes. Cette machine dispose d'un
processeur Intel Xeon à $1,80$GHz, de $16$Go de mémoire RAM et de caches
processeurs de $128$Ko, $1$Mo et $10$Mo pour les niveaux *L1*, *L2* et *L3*
respectivement.

### Résultats de l'expérimentation

Nous présentons dans cette partie les résultats de notre expérimentation. Plus
précisément, nous verrons dans un premier temps les performances d'encodage,
puis de décodage. Par la suite, nous analyserons l'influence du facteur de
protection, paramétré par le couple $(n,k)$, puis nous étudierons l'impact
de la taille des blocs de données $\mathcal{M}$ sur les performances des codes.

#### Performances d'encodage

\begin{figure}
    \begin{subfigure}{.49\textwidth}
        \centering
        \caption{$\mathcal{M}=4096$ octets.}
        \tikzset{every picture/.style={scale=0.85}}
        \input{expe_data/enc12.tex}
        \label{fig.encoding4k}
    \end{subfigure}
    \begin{subfigure}{.49\textwidth}
        \centering
        \caption{$\mathcal{M}=8192$ octets.}
        \tikzset{every picture/.style={scale=0.85}}
        \input{expe_data/enc13.tex}
        \label{fig.encoding8k}
    \end{subfigure}
    \centering
    \ref{named}
    \caption{Comparaison des performances d'encodage sur des blocs de données
    de $4$Ko (a) et $8$Ko (b). Les performances des codes Mojette et
    Reed-Solomon sont comparées par le nombre de cycles CPU nécessaire pour
    réaliser l'opération d'encodage (plus le résultat est petit, plus il est
    bon). Deux paramètres de codage ont été utilisés: $(6,4)$ et $(12,8)$. Les
    performances optimales sont représentées par \emph{no coding}.}
    \label{fig.encoding}
\end{figure}

Nous analysons dans cette partie les résultats à l'issu de notre
expérimentation sur les performances d'encodage. Les 
\cref{fig.encoding4k,fig.encoding8k} montre les résultats obtenus pour
des tailles de blocs $\mathcal{M}$ équivalent à $4096$ et $8192$ octets
respectivement. Nous avons représenté sur ces courbes, les performances
optimales obtenues par une opération équivalente sans encodage. Plus
précisément, ces performances correspondent à la copie de $n$ blocs de données.
Dans le cas où $\mathcal{M}$ vaut $4$Ko, cela correspond à la copie de $6144$
octets. Pour une taille de bloc de $8$Ko, cela correspond à la copie de $12288$
octets. L'opération de copie de cette information est implémentée dans la
fonction *memcpy()* de la bibliothèque standard du C.

La première observation générale que l'on peut faire sur ces courbes d'encodage
est que les performances de la Mojette non-systématique sont comparables à
celles fournies par l'implémentation des codes de Reed-Solomon d'ISA-L. Plus
précisément, ces derniers sont moins performants lors de trois tests sur
quatre (la tendance s'inverse dans le test $(12,8)$ présenté dans
\cref{fig.encoding8k}). En réalité, il est important de rappeler que cette
implémentation du code Mojette doit calculer trois fois plus de données que les
autres implémentations testées dans notre expérimentation. En effet, puisque
cette version est systématique, elle doit calculer $12$ projections Mojette
dans le cas d'un code $(12,8)$, tandis que le code de Reed-Solomon doit
calculer seulement $4$ blocs de parité. On observe cependant qu'il nécessite
dans le cas de le test de \cref{fig.encoding4k} plus de $30$\% de cycles
supplémentaires par rapport à NS Mojette, pour protéger la donnée face à $4$
pannes. On observe donc que malgré le désavantage de notre code en version
non-systématique, il parvient dans le cadre de nos tests à être compétitif avec
des codes systématiques.

Une deuxième observation est que la version systématique du code Mojette est
plus performante que sa version non systématique. Ce résultat était attendu
puisque comme on l'a précisé précédemment, cette dernière version doit calculer
trois fois plus d'information lors de l'encodage. Notons cependant que la
différence observée entre les résultats de ces deux implémentations n'est pas
un facteur trois. Lors de nos tests d'encodage, nous avons enregistré
le nombre de cycles CPU des implémentations systématiques comme étant la copie
des $k$ blocs d'informations en clair, plus le calcul des $(n-k)$ blocs de
parité. Les résultats observés correspondent donc à la somme de cette copie et
de l'encodage. En revanche, si l'on prend l'exemple des résultats du code
Mojette $(6,4)$ sur des blocs de $4$Ko, présentés dans \cref{fig.encoding4k},
on observe que $(705-321)*3 = 1152$, où $321$ correspond aux nombres de cycles
CPU nécessaire pour copier $4096$ octets, et où $1152$ correspond à la valeur
observée dans les résultats de la version non-systématique de la même courbe.
Ces résultats nous permettent donc de valider que l'encodage systématique est
trois fois plus performant que l'encodage non-systématique dans le cas où nos
codes sont réglés sur un taux $r=\frac{2}{3}$.

En conséquence, nos courbes de résultats montrent que pour les paramètres
choisis dans nos expériences, l'encodage de l'implémentation non-systématique
offre des performances comparables à la meilleure implémentation des codes de
Reed-Solomon développée par Intel. De plus, la version systématique du code
Mojette que nous avons développés offre des performances d'encodage largement
supérieures à ce que proposent les autres codes utilisés dans nos tests. En
particulier, les résultats atteint par notre nouvelle mise en œuvre sont
proches des résultats optimaux correspondant à la copie de l'information, sans
opération d'encodage. Ceci montre que le surcout calculatoire de cette nouvelle
version est particulièrement réduit.


#### Performances de décodage

\begin{figure}
    \centering
    \begin{subfigure}{.49\textwidth}
        \caption{$(n,k) = (6,4)$, $\mathcal{M} = 4096$ octets}
        \tikzset{every picture/.style={scale=0.85}}
        \input{expe_data/dec12_1.tex}
        \label{fig.decoding_4k_l1}
    \end{subfigure}
    \begin{subfigure}{.49\textwidth}
        \caption{$(n,k) = (6,4)$, $\mathcal{M}= 8192$ octets}
        \tikzset{every picture/.style={scale=0.85}}
        \input{expe_data/dec13_1.tex}
        \label{fig.decoding_8k_l1}
    \end{subfigure}
    \begin{subfigure}{.49\textwidth}
        \caption{$(n,k) = (12,8)$, $\mathcal{M}= 4096$ octets}
        \tikzset{every picture/.style={scale=0.85}}
        \input{expe_data/dec12_2.tex}
        \label{fig.decoding_4k_l2}
    \end{subfigure}
    \begin{subfigure}{.49\textwidth}
        \caption{$(n,k) = (12,8)$, $\mathcal{M}= 8192$ octets}
        \tikzset{every picture/.style={scale=0.85}}
        \input{expe_data/dec13_2.tex}
        \label{fig.decoding_8k_l2}
    \end{subfigure}
    \ref{named}
    \caption{Comparaison des performances de décodage pour des paramètres de
    codes $(6,4)$ (a,b) et $(12,8)$ (c,d). Les courbes à gauche montrent les
    résultats pour des tailles de blocs de $4$Ko (a,c) tandis que les courbes
    de droite concernent des blocs de $8$Ko (b,d). Les performances des codes
    Mojette et Reed-Solomon sont comparées par le nombre de cycles CPU
    enregistré durant l'opération de décodage (plus c'est bas, mieux c'est)
    alors que l'on augmente progressivement le nombre d'effacement. Un
    effacement correspond à la perte d'un bloc encodé. Les valeurs optimales
    sont représentées par "No coding".}
    \label{fig:decoding}
\end{figure}

Nous analysons dans cette partie les résultats à l'issu de notre
expérimentation sur les performances de décodage. Les 
\cref{fig.decoding_4k_l1,fig.decoding_8k_l1} donnent les nombres de cycles CPU
nécessaires pour le décodage des codes $(6,4)$ pour des blocs de $4$Ko et $8$Ko
respectivement.
De manière similaire, les \cref{fig.decoding_4k_l2,fig.decoding_8k_l2}
concernent des codes $(12,8)$. Nous avons représenté sur ces courbes les
performances optimales de décodage correspondant à la copie de $k$ blocs
d'information.

La première observation générale que l'on peut faire concerne le cas où aucun
effacement ne survient lors du décodage. Dans ce cas, les deux codes
systématiques Mojette et Reed-Solomon atteignent les performances optimales
représentées sur nos courbes par "no coding". Ce résultat était attendu puisque
dans le cas des codes systématiques, lorsqu'aucun des $k$ blocs de données
n'est effacé, le décodage correspond à la lecture direct de ces $k$ blocs. Au
niveau de l'implémentation, cette lecture correspond à la copie de cette
information en clair.

À présent, lorsque des effacements surviennent, des opérations de décodage sont
déclenchées. Une première remarque globale est que l'influence des effacement
n'est pas le même selon si le code est systématique ou non. Pour NS Mojette, le
nombre d'effacement $e$ n'a pas d'influence sur les performances de décodage.
Ce résultat provient du fait que le décodage des codes non-systématiques
correspond à la reconstruction entière des informations utilisateurs. Ainsi le
nombre d'opérations est comparable quelque soit l'ensemble des blocs encodés
utilisé pour cette reconstruction.
%
Dans le cas des codes systématiques en revanche, le décodage correspond à
reconstruire un ensemble partiellement reconstruit de la donnée. En
conséquence, le nombre de CPU nécessaire pour le décodage augmente au fur et à
mesure que l'on augmente le nombre de blocs de données effacés. En particulier,
la différence entre les performances de l'implémentation systématique du code
Mojette et des valeurs optimales augmente avec le nombre d'effacement puisque
l'on supprime progressivement des lignes de la grille discrète. En effet,
puisque l'on considère une grille de moins en moins remplie, et puisque les
opérations d'additions nécessaires à la reconstruction Mojette sont plus
coûteuses que la copie utilisée dans memcpy(), les performances décroissent.
%
Notons cependant que malgré la baisse de performances du décodage observée
lorsque l'on augmente le nombre d'effacement pour le code systématique Mojette,
les valeurs enregistrées sont d'une part toujours meilleures que celles
observées pour la version non systématique (puisqu'il s'agit du cas où la
grille doit être entièrement reconstruite). D'autre part, ces performances sont
significativement meilleures que les performances observées par
l'implémentation systématique des codes de Reed-Solomon.

#### Influence de la tolérance aux pannes

#### Impact de la taille des blocs

