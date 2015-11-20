
# Introduction à la géométrie discrète

# Code MDS par transformée de Radon finie (FRT)

# Code à effacement par transformée Mojette

Le code à effacment Mojette est basée sur la transformée Mojette. Cette
transformée est également une version discrète et exacte de la transformée
continue de Radon. Elle a été proposé pour la première fois en
\citeyear{guedon1995vcip} par \citeauthor{guedon1995vcip} dans le contexte du
traitement et de l'encodage d'image \cite{guedon1995vcip}. Dans ce qui suit,
on décrira dans un premier temps la transformée Mojette directe. Les
conditions de reconstructions seront ensuite présentées, avant de voir
quelques algorithmes de reconstruction. On verra dans une dernière partie, la
mise en oeuvre d'un code à effacement basé sur cette transformée.

## Transformée Dirac-Mojette directe

\begin{figure}
    \def\svgwidth{.7\textwidth}
%\includesvg{figures/mojette_forward}
    \caption{La transformée de Dirac-Mojette. On considère une grille d'image 
    $P \times Q = 3 \times 3$ sur laquelle nous calculons $4$ projections
    dont les directions $(p_i,q_i)$ sont compris dans l'ensemble 
    $\left\{(-1,1), (0,1), (1,1), (2,1)\right\}$. La base utilisée est
    représentée par les deux vecteurs unitaires $\vec{u}$ and $\vec{v}$.
    L'addition est ici arbitrairement réalisée modulo $6$.}
    \label{fig.mojette_directe}
\end{figure}

La transformée Mojette est une opération linéaire qui calcule un ensemble de
$I$ projections à partir d'une image discrète $f:(k,l)\mapsto\mathbb N$. Bien
que cette image discrète peut avoir n'importe quelle forme, nous considèrerons
dans la suite une image rectangulaire, composé de $P \times Q$ éléments. Nous
appellons ces éléments des *pixels*. Un pixel est défini par ses
coordonnées $(k,l)$ dans la grille. Une projection est un vecteur défini par
une direction et une taille. La direction d'une projection $i$ est définie par
deux entiers $(p_i, q_i)$ premiers entre eux. Les projections sont des vecteurs
de taille variable. Cette taille varie en fonction des paramètres de la grille
et de la direction de projection. On appelle les éléments qui constituent une
projection des *bins*. La valeur des bins de la projection suivant la
direction $(p_i, q_i)$ résulte de la somme des pixels situés sur la droite
discrète d'équation $m = -kq_i + lp_{i}$. La transformée Dirac-Mojette est
définie ainsi :

\begin{equation}
    [\M f](b,p_{i},q_{i}) = 
        \sum_{k=0}^{Q-1} \sum_{l=0}^{P-1}
        f \left(k,l\right)
        \Delta\left(b+kq_{i}-lp_{i}\right),
    \label{eq:Mojette}
\end{equation}

où $\Delta(n)$ correspond à la fonction de Kronecker Cette fonction vaut $1$
quand $n=0$, et zéro dans les autres cas. Le paramètre $b$ est l'index du bin
que l'on calcule par l'équation, considérant la projection définie par sa
direction $(p_i,q_i)$.

La transformée Mojette directe s'applique comme décrit dans
\cref{fig.mojette_directe}. Cette exemple montre la transformée Mojette d'une
image $3 \times 3$ composée d'entiers. Le traitement transforme une image 2D en
un ensemble de $I=4$ projections dont les valeurs des directions sont comprises
dans l'ensemble suivant : $\left\{(-1,1), (0,1), (1,1), (2,1)\right\}$. Dans
l'objectif de simplifier la représentation de cet exemple et des suivants,
l'addition est arbitrairement réalisée ici modulo $6$. Cependant, on aurait pu
choisir que l'addition se réalisé par des opérations modulo congruent n'importe
quel entier, voir considérer l'utilisation d'arithmétique usuel.

Considérons la projection suivant la direction $(p=0, q=1)$. Il s'agit alors de
la direction verticale puisque l'on considère que l'on se "déplace" de zéro
pixel vers la gauche, et de un pixel vers le haut. Chaque bin de cette
projection résulte de l'addition des pixels de la grille suivant la direction
verticale. Par exemple, le premier bin (situé à droite de la projection
représentée sur la figure) vaut $4+5+1 \pmod 6 = 4$.
Si l'on considère à présent une projection composée, les bins qui le
constituent résultent de la somme des pixels suivant une pente définie par la
projection. Par exemple, si l'on considère les projections suivant les
directions $(-1,1)$ et $(1,1)$, la valeur de leurs bins correspond
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
    B(P,Q,p_i,q_i)=(Q-1)|p_{i}|+(P-1)|q_{i}|+1.
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
l'existence d'une solution de reconstruction unique. Par la suite, nous
présentons un algorithme de reconstruction.

### Critères de reconstruction

Le premier critère permettant de garantir l'existence d'une solution unique de
reconstruction est le critère de \citeauthor{katz1978springer}
\cite{katz1978springer}. Ce critère n'est défini que pour des images $P \times
Q$ rectangulaires. Étant donné un ensemble de directions de projection
$\left\{(p_i,q_i)\right\}$, le critère de \citeauthor{katz1978springer} déclare
que si l'une des conditions suivantes est remplie :
$\sum\limits_{i=1}^I{|p_i|}\geq P$ \textbf{ou} $\sum\limits_{i=1}^I{|q_i|}\geq
Q$, alors il existe une unique solution de reconstruction, et cette solution
contient les valeurs de la grille qui a permis de calculer les projections.
Cela signifie qu'il existe un moyen de reconstruire la grille à partir de cet
ensemble de projections.

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
    \def\svgwidth{.3\columnwidth}
%\input{figures/dep_graph.pdf_tex}
    \caption{Graphe de dépendance des pixels. On considère une image $3 \times
    3$ ainsi qu'un ensemble de directions de projection $(p_i,q_i)$ à valeur
    dans $\left\{(-1,1),(0,1),(1,1)\right\}$. Les noeuds correspondent aux
    pixels tandis que les arêtes représentent les dépendances entre eux.
    Un pixel peut être reconstruit par un bin lorsqu'aucune dépendance ne
    s'applique sur lui.}
    \label{fig.dep_graph}
\end{figure}

Plusieurs algorithmes ont été proposés dans la litterature
\cite{guedon2009mojettebookchap5}. Nous décrirons dans la suite, l'algorithme
de reconstruction itératif \cite{normand2006dgci}.

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
projection $\left\{(1,1), (0,1), (-1,1)\right\}$. Les noeuds de ce graphe
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
    \item puisque les deux précéndents pixels ont été reconstruits, plus aucune
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

Dans cette configuration, la transformée Mojette correspond à un code à
effacement puisqu'elle tolère la perte de $(I-Q)$ projections. Notons que
puisque la taille des projections varie au dela de la taille d'un bloc de
données, le code à effacement Mojette n'est pas MDS. En particulier, la taille
des projections augmente avec la valeur de $|p_i|$. Dans la mesure où n'importe
quel ensemble de $Q$ projections suffit à reconstruire la grille de manière
unique, mais que la taille des blocs encodés n'est pas optimale, on considère
alors le code Mojette comme étant *quasi-MDS* \cite{parrein2001dcc}. On
évaluera l'impact de ce surcoût de stockage dans une partie future.


# Nouvelle mise en oeuvre systématique

## Mise en oeuvre d'une version systèmatique

## Évaluation du surcoût de stockage

## Analyse des performances

# Évaluation des performances
