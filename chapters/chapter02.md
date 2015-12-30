
# Introduction à la géométrie discrète

% grille discrète

% angle de projection (Farey)

% forme convexe

# Code MDS par transformée de Radon finie (FRT)

## Introduction à la transformée de Radon

## Transformée de Radon finie

### FRT directe

### FRT inverse

## Code à effacement par FRT

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
    \def\svgwidth{.7\textwidth}
%\includesvg{figures/mojette_forward}
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
    \label{eq:Mojette}
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
    \def\svgwidth{.3\columnwidth}
%\input{figures/dep_graph.pdf_tex}
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

Dans cette configuration, la transformée Mojette correspond à un code à
effacement puisqu'elle tolère la perte de $(I-Q)$ projections. Notons que
puisque la taille des projections varie au delà de la taille d'un bloc de
données, le code à effacement Mojette n'est pas MDS. En particulier, la taille
des projections augmente avec la valeur de $|p_i|$. Dans la mesure où n'importe
quel ensemble de $Q$ projections suffit à reconstruire la grille de manière
unique, mais que la taille des blocs encodés n'est pas optimale, on considère
alors le code Mojette comme étant *quasi-MDS* \cite{parrein2001dcc}. On
évaluera l'impact de ce surcout de stockage dans une partie future.

## Relations avec d'autres codes à effacement



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

\begin{align}
    \text{Offset}(\text{failures}(e-1)) & \\
        & = max(max(0,-p_r) + S_{minus}, max(0,p_r) + S_{plus}).
    \label{eqn.offset_last_sys}
\end{align}

Puis les offsets des lignes à reconstruire.

\begin{align}
    \text{Offset}(\text{failures}(i) & \\
        & & = \text{Offset}(\text{failures}(i+1) + p_{i+1} \\
    \text{Offset}(\text{failures}(j) & \\
        & - & = (\text{failures}(i+1) - \text{failures}(i) - 1) * p_{i+1}
    \label{eqn.offset_sys}
\end{align}

## Calcul de la valeur du pixel à reconstruire

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

\begin{figure}
\centering
%\input{./figures/ec_vs_rep.tikz}
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

## Évaluation des performances

### Analyse du nombre d'opérations

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

