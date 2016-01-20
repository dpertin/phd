
\chapter{Redondance dans les systèmes de stockage distribués par codage à
effacement}



# Introduction 

Dans les systèmes de stockage, les codes à effacement sont connus pour fournir
une alternative efficace aux techniques de réplication. Ils permettent
notamment de réduire significativement la quantité de redondance nécessaire
pour fournir une certaine tolérance aux pannes.
Afin d'augmenter la disponibilité des données, il est nécessaire de distribuer
ces données redondantes sur plusieurs supports de stockage. Ainsi il est
possible de supporter l'indisponibilité d'une partie de cette information.
On considère que l'indisponibilité d'une donnée provient d'une panne. En
pratique, cette panne peut être de plusieurs natures (e.g.\ logicielle,
matérielle, réseau, \dots).

En \citeyear{patterson1988sigmod}, \textcite{patterson1988sigmod} publient
leurs travaux qui présentent $5$ techniques d'agrégation de disques durs. Cette
agrégation, nommée *Redundant Array of Independant Disks* (RAID), peut se
traduire par "Matrice redondante de disques indépendants". Chaque technique, ou
niveau, RAID permet d'exploiter un ensemble de disques afin d'améliorer les
performances et/ou la disponibilité des données, par rapport à une utilisation
de disques sans organisation. En particulier, les performances sont améliorées
par la répartition des données sur l'ensemble de ces disques (*stripping*),
cette technique est à la base du RAID-0. D'autres techniques améliorent la
disponibilité des données en répliquant celle-ci sur l'ensemble des disques,
comme en RAID-1, ou en calculant $r$ disques de parité à partir de $k$ disques
de données, capable de supporter la panne de $r$ disques. C'est le cas en
RAID-4 et RAID-5 pour $r=1$, et RAID-6 pour $r=2$.

Ces travaux s'inscrivent dans le contexte technologique des années $80$ où l'on
parvient à significativement réduire la taille du matériel. Cette
miniaturisation des ressources permet d'agréger physiquement les composants
\cite{bell1984computer}. Dans cette période, les microprocesseurs par exemple,
fournissent une puissance de calcul bon marché et compacte, qui permettent
l'agrégation de ressources de calcul au sein d'un système multiprocesseur,
\textcite{krajewski1985byte} utilise notamment l'expression *Array Processing*
pour désigner un ensemble de processeurs exécutant la même instruction sur un
jeu de donnée.

Bien que le calcul d'un disque de parité dans le cas du RAID-4 et RAID-5 est
direct, il existe de nombreuses méthodes pour calculer un deuxième disque de
parité en RAID-6. Classiquement, les codes de \textcite{reed1960jsiam} peuvent
être utilisés pour calculer ces disques de parité. Cependant, plusieurs
méthodes spécialisées ont été conçues pour le calculer ce deuxième disque de
façon plus performante. En particulier les codes *EvenOdd* de
\textcite{blaum1995toc} et *Row Diagnoal Parity* (RDP) de
\textcite{corbett2004fast} sont des mises en œuvres conçues pour être plus
efficaces. Bien que plus performants par rapport aux code de \rs, ces méthodes
sont limitées à deux disques de parité, et sont donc limités si l'on souhaite
fournir une meilleure disponibilité des données. En conséquence, il n'y a pas
de solution parfaite, et les concepteurs de systèmes de stockage doivent
privilégier soit les performances, soit la haute disponibilité des données.

Dans ce chapitre, nous allons apporter une nouvelle étude comparative des
performances des codes conçus pour RAID-6 (i.e.\ $r=2$). Plus particulièrement,
les critères de comparaison porteront sur des métriques liées au stockage tel
que les performances d'encodage, de décodage et de mise à jour des données. Les
codes traditionnels seront en particulier comparer au code Mojette dans sa
version systématique, tel que défini précédemment dans \cref{sec.chapitre3}.
Nous montrerons que notre code améliore significativement les performances dans
l'ensemble des métriques, au prix d'un léger surcout de données à stocker.
Cette méthode est alors intéressante quand le besoin de performances est plus
important que la capacité de stockage des disques.


### Terminologie en RAID-6 

\begin{figure}[t]
    \centering
    \def\svgwidth{.7\textwidth}
    \includesvg{img/array}
    \caption{Représentation d'une matrice de disques organisés en RAID-6. Un
    ensemble de $k$ disques de données sont utilisés pour encoder $2$ disques
    de parité : $P$ et $Q$. Les disques sont partitionnés en $w$ blocs. Une
    bande correspond à un ensemble de $n$ blocs impliqués dans un processus
    d'encodage.}
    \label{fig.array}
\end{figure}

La particularité de l'organisation des disques en RAID-6 est d'améliorer les
performances de lecture et d'écriture par la répartition des données sur les
disques, et la protection des données face à deux pannes disques en proposant
deux disques de parité. On représente généralement ces disques sous la forme
d'une matrice de $n$ disques possédant la même capacité de stockage. Ces $n$
disques sont divisés en deux parties : (i) un ensemble de $k$ disques de
données; (ii) un ensemble de $(n-k)$ disques de parité contenant des données de
redondance calculées depuis les disques de données. Chaque disque est divisé en
$w$ bloc de $\beta$ bits. \Cref{fig.array} représente une matrice simple de
disque, organisée en RAID-6, où $w=2$ blocs. En pratique, $w$ est généralement
plus grand que cela, et un bloc correspond à un mot (e.g.\ $\{8,\dots,64\}$
bits). Les codes RAID-6 correspondent à une famille de codes généralement MDS,
de paramètres $(n=k+2,k)$.


### Métriques

Le contenu du premier disque de parité $P$ est toujours calculé de la même
manière. Les $w$ blocs qu'il contient correspondent à des informations de
parité horizontale des blocs des $n$ disques de données. En revanche, plusieurs
méthodes présentées dans ce chapitre permettent de calculer les données du
disque $Q$. Nous allons ainsi comparer ces techniques selon les métriques
suivantes :

* Le **coût à l'encodage** correspond au nombre d'opérations nécessaires pour
encoder un disque de parité;

* Le **coût de mise à jour** correspond au nombre d'opérations nécessaires pour
modifier un bloc de donnée et mettre à jour les données de parité. Pour plus
d'efficacité, nous considérerons une mise à jour différentielle. C'est à dire
qu'au lieu de ré-encoder complètement les informations, nous calculerons
seulement la différence avec la valeur d'origine et appliquerons par linéarité
de l'opération cette différence sur la donnée de parité, tel que proposer par
\textcite{zhang2012nas}. Nous verrons en particulier que dans certains codes,
la position du bloc modifié dans la matrice a un impact significatif sur les
performances;

* Le **coût au décodage** correspond au nombre d'opérations nécessaires pour
reconstruire l'information d'un disque qui subit une panne. On considère dans
la suite qu'une panne entraîne l'indisponibilité totale d'un disque de données.
Nous verrons durant notre analyse que certains codes possèdent de meilleures
performances en reconstruisant l'information depuis le disque $Q$ plutôt que
$P$.


# Comparaison des codes RAID-6

Bien que les codes populaires de \rs fournissent un taux de codage voulu, les
*Array* codes fournissent de meilleures performances. Ces derniers ne sont
définis que pour fournir un nombre très limité de disques de parité.
Nous décrirons dans la suite deux implémentations des codes de \rs (basés sur
des matrices de \textsc{Vandermonde} et de \textsc{Cauchy}), ainsi que deux
*Array* codes (EvenOdd et RDP). Enfin nous apporterons une comparaison des
performances de ces codes avec le code Mojette. Nous verrons que ce dernier
apporte de meilleures performances dans les différentes métriques que l'on a
défini.


## Codes MDS

En général, les codes de \rs peuvent être définis de deux manières : (i) à
travers une matrice de \textsc{Vandermonde}; (ii) à travers une matrice de
\textsc{Cauchy}. Ces dernières matrices ont été proposées afin d'améliorer les
performances des codes de \rs. Nous verrons dans la suite ces deux versions.


### Vandermonde-RS

Les codes de \rs sont basés sur une approche algrébrique. Ainsi le processus
d'encodage est déterminé par une matrice d'encodage. Les matrices de \vand $(n
\times k)$ sont adaptées pour l'application des codes à effacement puisque
n'importe quelle sous-matrice carrée d'une matrice de \vand est inversible.
C'est en particulier cette caractéristique des matrices que nous utiliserons
pour reconstruire l'information. Plus précisément, quand de l'information est
impactée, les lignes endommagées sont supprimés et l'inverse de la matrice dont
on aura supprimer les lignes correspondantes, sera utilisé pour reconstituer
les données originales. Cette opération s'effectue sur des mots de $\beta$ bits
avec $k+m \leq 2^{\beta}$. Naturellement, le paramètre $\beta$ doit faire la
taille d'un mot (e.g.\ $\beta = 8$ ou $16$ ou $32$ bits). Considérons deux
ensembles $i \in \ZZ_k$ et $j \in \ZZ_w$. Ainsi, $d_{i,j}$ correspond au
bloc de donnée situé dans la colonne $i$ et à la ligne $j$. Dans ce cas, les
blocs $P_j$ et $Q_j$ sont calculés ainsi :

\begin{align}
    P_j &= \xor_{i=0}^{k-1}d_{i,j},              \label{eqn.rs_p}\\
    Q_j &= \xor_{i=0}^{k-1}d_{i,j}\alpha^{i}.    \label{eqn.rs_q}
\end{align}

Les implémentations classiques souffrent des multiplications de \cref{eqn.rs_q}
réalisées dans un corps de \textsc{Galois}. Afin d'éviter ces opérations, de
nouvelles alternatives ont été proposées par \textcite{blaum1993tit} pour
remplacer ces multiplications par des rotations cycliques, et par
\textcite{rizzo1997sigcomm} pour utiliser des tables de correspondance.

Encoder le disque $P$ correspond à additionner $k$ blocs, comme le décrit
\cref{eqn.rs_p}. En conséquence, $(k-1)$ opérations sont nécessaires.
\cref{eqn.rs_q} montre que $(k-1)$ additions et $k$ multiplications sont
nécessaires pour calculer les valeurs du disque $Q$. En conséquence, la
construction de ces deux disques de parité engendre $2 \times (k-1)w$
additions et $(k \times w)$ multiplications.

La modification d'un bloc de donnée entraîne la mise à jour de deux blocs de
parité. Une addition est réalisée pour calculer la différence, deux
supplémentaires sont nécessaires mettre à jour le bloc correspondant dans $P$
puis dans $Q$. Enfin, une multiplication permet de finir la mise à jour du bloc
dans $Q$. En conséquence, la modification d'un bloc entraîne trois additions et
une multiplication.

Pour reconstruire un disque, dans le cas où il y a une seule panne, le
processus de décodage favoriserait l'utilisation de $P$, puisque cela
entraînerait le recours à $(k-1) \times w$ additions. En revanche,
l'utilisation du disque $Q$ nécessite des opérations de multiplication, plus
complexes à mettre en place. Dans le cas de deux pannes, l'opération nécessite
autant d'opérations qu'à l'encodage, c'est à dire : $2 \times (k-1)w$


### Cauchy-RS

Cette version des codes de \rs est basée sur des matrices de \textsc{Cauchy}
qui permettent une inversion matricielle plus efficace \cite{plank2006nca}. De
plus, les travaux de \textcite{plank2006nca} ont permis de remplacer les
opérations de multiplications par des additions, en représentant les matrices
différemment. En particulier, cette représentation étend la matrice d'un
facteur $\beta$ dans chaque direction. Ses performances sont ainsi liées au
nombre de $1$ présents dans la matrice d'encodage ou de décodage, et des
travaux ont été mené afin de rendre les matrices les plus creuses possible.
Cependant, aucune forme close n'existe aujourd'hui afin de définir ce nombre.


## *Array* codes

Les *Array* codes ont été conçus à l'origine comme une alternative aux codes de
\rs afin d'éviter les opérations de multiplication dans les corps de
\textsc{Galois}. Bien que ces codes soient limités en nombre de parité qu'ils
peuvent fournir, ils ne réalisent que des additions, et sont en conséquence
performants. Les disques $P$ et $Q$ sont respectivement calculés en utilisant
des bandes horizontales et diagonales. Le calcul de $P$ est alors similaire à
\cref{eqn.rs_p}. Nous verrons dans la suite la différence relative à la
conception du disque $Q$.


### Le code EvenOdd

\begin{figure}[t]
    \centering
    \def\svgwidth{.7\textwidth}
    \includesvg{img/evenodd}
    \caption{Représentation d'un code EvenOdd sur une matrice $(k=5, w=4)$. La
    figure s'intéresse en particulier au calcul des valeurs du disque $Q$, basé
    sur la valeur des données des disques $D_i$. L'ajusteur $S$ correspond à la
    somme des éléments de la diagonale blanche. Sa valeur est additionnée à
    chaque bloc de $Q$, qui sont déterminés par une parité diagonale. Inspiré
    de \cite{plank2009fast}.}
    \label{fig.evenodd}
\end{figure}

Les codes EvenOdd ont été conçus en \citeyear{blaum1995toc} par
\textcite{blaum1995toc}. Ils sont caractérisés par une géométrie restreinte.
Plus particulièrement, la valeur de $w$ doit être choisie de telle manière que
$(w+1)$ soit premier, et que $k \leq w+1$. Lorsque le disque $Q$ est impliqué,
que ce soit pour l'encodage ou le décodage, une valeur intermédiaire $S$
(nommée *ajusteur*), $S$, doit être déterminée afin de garantir la propriété
MDS du code. \Cref{fig.evenodd} représente le processus pour calculer $Q$. La
valeur de l'ajusteur correspond à la somme des éléments suivant la diagonale
blanche. La valeur des blocs de $Q$ correspond à la somme des éléments des
disques de données suivant différentes diagonales représentées par des couleurs
différentes, à laquelle on rajoute la valeur de $S$.

Lors de l'encodage, cet ajusteur nécessite $(k-2)$ additions. L'encodage
nécessite $(k-1) \times w$ additions pour calculer $P$ et $(k-1)w + k - 2$ pour
calculer les valeurs de $Q$. En conséquence, le disque $Q$ requiert plus
d'opérations que le disque $P$.

Les conséquences de la modification d'un bloc de donnée dépend de la position
de ce bloc. Dans la plupart des cas, cette modification entraîne la mise à jour
d'une valeur optimale de $2$ blocs de parité. On calcule ainsi la différence
entre l'ancienne et la nouvelle valeur du bloc, puis on met à jour un bloc de
$P$ et un bloc de $Q$, ce qui coûte trois additions. En revanche, lorsque la
modification affecte un bloc de la diagonale qui définit la valeur de $S$,
l'ensemble des blocs du disque $Q$ est affecté. En conséquence, $w$ additions
sont réalisées, une autre est nécessaire pour calculer la différence, et une
dernière pour la mise à jour du bloc du disque $P$. Cette situation
correspondant au pire cas nécessite alors $(w+2$ additions.

Concernant la reconstruction d'un disque, plusieurs scénarios sont possibles.
Quand une panne affecte un seul disque, il est recommandé de reconstruire en
utilisant le disque $P$ puisque dans l'autre cas, il sera nécessaire de
calculer la valeur de $S$ ce qui engendre des opérations supplémentaires. Une
panne est alors réparée en utilisant $(k-1) \times w$ additions. Lorsque les
disques de données subissent deux pannes, il est tout d'abord nécessaire de
recalculer la valeur de $S$. Le coût du calcul de $S$ dépend de la position des
disques en panne. Soit $c(S)$ le nombre d'opérations nécessaires pour
recalculer la valeur de $S$. Soit deux entiers $i,j \in \ZZ$ tel que $i \neq j$
correspondant respectivement à l'index du premier et second disque en panne.
Dans ce cas, on distingue les trois cas suivants :

1. si $i=0$ et $j \geq k$, alors la méthode utilisée lors de l'encodage permet
de recalculer la valeur de $S$, puisqu'au disque en panne n'impacte la
diagonale blanche. En conséquence, $c(S) = k-2$ opérations;

2. si $i<k$ et $j=k$, alors il est nécessaire de calculer $S$ à partir de
n'importe quelle autre diagonale, donc $c(S) = k-1$ opérations;

3. si $i,j < k$, alors $S$ peut être calculée en additionnant l'ensemble des
valeurs des disques de parité. Cela nécessite $c(S) = 2(k-2)$ opérations.

Une fois que la valeur de $S$ est calculée, il est possible de reconstruire les
éléments des disques effacés par un processus itératif. La première itération
consiste à reconstruire la valeur d'un bloc effacé en utilisant une bande
diagonale. La seconde itération utilise la bande horizontale de ce bloc afin de
reconstruire un nouveau bloc. En utilisant alternativement parité diagonale et
horizontale, on parvient à reconstruire l'ensemble des données effacées.
Le coût total de la reconstruction est $2(k-1)w + c(S)$. Le pire cas correspond
à la perte de deux disques impliqués dans la diagonale de $S$. Dans cette
situation, la reconstruction nécessite $2(k-1)w + 2(k-2)$ additions.

% représentation du décodage



## RDP


Les codes RDP conçus par \textcite{corbett2004fast} ont également une
contrainte géométrique telle que $k \leq w$. Ces codes sont similaires aux
\textsc{EVENODD} mais ne nécessite pas d'ajusteur. En revanche, les
informations du disque $P$ sont utilisées pour calculer les valeurs du disque
$Q$, ce qui nécessite une dépendance et une séquentialité dans la mise en œuvre
de l'encodage. Les codes RDP nécessitent ainsi moins d'opérations pour
l'encodage, le décodage et la mise à jour, que les codes de \rs et \eo.

Le nombre d'opérations nécessaires pour le calcul des informations de $P$ et de
$Q$ sont identiques et correspond à $(k-1)w$ additions. De manière similaire
aux \eo, le coût de la mise à jour d'un bloc dépend de la position du bloc.
Lorsque celui ci est situé sur la première ligne ou sur la diagonale spéciale,
seulement deux blocs de parité sont impactés sur $P$ et $Q$ respectivement. En
conséquence, trois opérations sont nécessaires. Dans tous les autres cas, trois
blocs sont impactés du fait de l'interdépendance entre les disques de parité.
La reconstruction d'un disque de données est quant à elle réalisée en $(k-1)w$
opérations quelque soit le disque de parité utilisé. En conséquence, $2(k-1)$
opérations sont nécessaires pour reconstruire l'information lorsque deux
disques sont en panne.



# Redondance dans les systèmes de stockage distribués



# Matrice de disques, RAID



# Array Codes



# Évaluation


% ça poutre !

