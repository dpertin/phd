
# Introduction à la géométrie discrète

# Code MDS par transformée de Radon finie (FRT)

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


# Nouvelle mise en œuvre systématique

Nous avons vu précédemment la réalisation du code à effacement Mojette en
version non systématique. Dans cette partie, nous verrons une nouvelle
conception de ce code à effacement en version systématique. Dans cette nouvelle
version, la donnée utilisateur fait partie intégrante de la donnée encodée.
L'objectif ici est d'améliorer les performances du code. Plus précisément, nous
verrons dans un premier temps comment nous avons réalisé cette nouvelle mise en
œuvre du code à effacement Mojette. Par la suite, nous analyserons les impacts
de cette nouvelle méthode sur les performances du code, avant d'étudier et
comparer la quantité de redondance générée par rapport aux autre codes.

## Mise en œuvre d'une version systématique

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

### Bénéfice de cette nouvelle technique sur l'encodage

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

### Bénéfice de cette technique sur le décodage

Dans cette partie nous allons distinguer le cas où aucun effacement ne
survient, et le cas dégradé où certaines données sont perdues.

#### Accès direct sans dégradation

Le principal avantage de cette technique est de ne pas avoir besoin d'exécuter
d'opération de décodage quand aucune des $k$ lignes de données ne subit 
d'effacement. En effet, dans ce cas, la donnée est immédiatement accessible en
clair. En conséquence aucun surcout calculatoire n'est engendré et les
performances sont considérées comme optimales.
En revanche, lorsque des effacements surviennent sur la donnée, il est
nécessaire d'appliquer un algorithme de décodage afin de les reconstruire.

#### Dégradation partielle des données

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

#### Perte complète des données

Dans le cas où l'ensemble des $e = k$ lignes de la grille est effacé, il est
nécessaire de décoder l'information à partir de $k$ projections. Dans le cas où
cela est possible, l'opération de décodage correspond alors à celle réalisée
quand le code est non-systématique.

En terme de performance, les performances du décodage en systématique sont donc
au pire similaire à celles obtenues en non-systématique. Pour le reste des cas
vu précédemment, ces performances sont au mieux optimales, sinon meilleures.


### Algorithme inverse en systématique 

L'algorithme inverse présenté dans cette partie correspond à une extension de
l'algorithme inventé pour la version non-systématique par
\citeauthor{normand2006dgci}, étudié dans la partie précédente
\cite{normand2006dgci}.
Dans cette partie, nous décrivons deux modifications majeures à cet
algorithme. La première concerne la détermination des offsets pour chaque
projection. La seconde correspond au calcul de la valeur du pixel à
reconstruire.

#### Détermination des offsets pour chaque projection



#### Calcul de la valeur du pixel à reconstruire

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


## Évaluation du surcout de stockage

## Analyse des performances

# Évaluation des performances
