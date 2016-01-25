
% \chapter{Redondance dans les systèmes de stockage

% distribués par codage à effacement}

\chapter{Code à effacement dans le stockage distribué}


% # Redondance dans les systèmes de stockage

\section*{Introduction}

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
façon plus performante. En particulier les codes \eo de
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



# Cas des codes à effacement $(k+2,k)$ pour le stockage


## Terminologie en RAID-6 

\begin{figure}[t]
    \centering
    \def\svgwidth{\textwidth}
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


## Métriques d'analyse de performance

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


## Analyse des performance des codes RAID-6

Bien que les codes populaires de \rs fournissent un taux de codage voulu, les
*Array* codes fournissent de meilleures performances. Ces derniers ne sont
définis que pour fournir un nombre très limité de disques de parité.
Nous décrirons dans la suite deux implémentations des codes de \rs (basés sur
des matrices de \textsc{Vandermonde} et de \textsc{Cauchy}), ainsi que deux
*Array* codes (\eo et RDP). Enfin nous apporterons une comparaison des
performances de ces codes avec le code Mojette. Nous verrons que ce dernier
apporte de meilleures performances dans les différentes métriques que l'on a
défini.


### Codes de \rs

En général, les codes de \rs peuvent être définis de deux manières : (i) à
travers une matrice de \textsc{Vandermonde}; (ii) à travers une matrice de
\textsc{Cauchy}. Ces dernières matrices ont été proposées afin d'améliorer les
performances des codes de \rs. Nous verrons dans la suite ces deux versions.


#### Vandermonde-RS

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


#### Cauchy-RS

Cette version des codes de \rs est basée sur des matrices de \textsc{Cauchy}
qui permettent une inversion matricielle plus efficace \cite{plank2006nca}. De
plus, les travaux de \textcite{plank2006nca} ont permis de remplacer les
opérations de multiplications par des additions, en représentant les matrices
différemment. En particulier, cette représentation étend la matrice d'un
facteur $\beta$ dans chaque direction. Ses performances sont ainsi liées au
nombre de $1$ présents dans la matrice d'encodage ou de décodage, et des
travaux ont été mené afin de rendre les matrices les plus creuses possible.
Cependant, aucune forme close n'existe aujourd'hui afin de définir ce nombre.



### Les *Array* codes

Les *Array* codes ont été conçus à l'origine comme une alternative aux codes de
\rs afin d'éviter les opérations de multiplication dans les corps de
\textsc{Galois}. Bien que ces codes soient limités en nombre de parité qu'ils
peuvent fournir, ils ne réalisent que des additions, et sont en conséquence
performants. Les disques $P$ et $Q$ sont respectivement calculés en utilisant
des bandes horizontales et diagonales. Le calcul de $P$ est alors similaire à
\cref{eqn.rs_p}. Nous verrons dans la suite la différence relative à la
conception du disque $Q$.


#### Les codes \eo

\begin{figure}[t]
    \centering
    \def\svgwidth{.7\textwidth}
    \includesvg{img/evenodd}
    \caption{Représentation d'un code \eo sur une matrice $(k=5, w=4)$. La
    figure s'intéresse en particulier au calcul des valeurs du disque $Q$, basé
    sur la valeur des données des disques $D_i$. L'ajusteur $S$ correspond à la
    somme des éléments de la diagonale blanche. Sa valeur est additionnée à
    chaque bloc de $Q$, qui sont déterminés par une parité diagonale. Inspiré
    de \cite{plank2009fast}.}
    \label{fig.evenodd}
\end{figure}

Les codes \eo ont été conçus en \citeyear{blaum1995toc} par
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



#### Les codes RDP


Les codes RDP conçus par \textcite{corbett2004fast} ont également une
contrainte géométrique telle que $k \leq w$. Ces codes sont similaires aux
\eo mais ne nécessite pas d'ajusteur. En revanche, les
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



### Le code Mojette {#sec.eval.xor}

\begin{figure}[t]
    \centering
    \def\svgwidth{.7\textwidth}
    \includesvg{img/mojette_raid6}
    \caption{Code à effacement Mojette d'une image $(3 \times 3)$ pour les
    directions $\{(p,q)\}$ dans l'ensemble $\{(-1,1),(0,1),(1,1)\}$. La base
    utilisée est représentée par $\vec{u}$ et $\vec{v}$. $P$, $Q$, et $P'$
    correspondent à des disques de parité.}
    \label{fig.mojette_raid6}
\end{figure}

Les performances d'un code dépendent intrinsèquement de la nature et du nombre
des opérations réalisées par le code. En ce qui concerne la nature des
opérations, la transformée Mojette n'utilise que des additions, ce qui se
traduit par des opérations de OU exclusifs dans l'implémentation. Nous avons vu
dans le premier chapitre que les codes de \rs reposent en revanche sur des
opérations de multiplication, plus complexes à mettre en place. Nous verrons
dans un premier temps le nombre d'opérations nécessaires pour les opérations
d'encodage. Le nombre d'opération pour calculer une projection est identique
que la version du code soit systématique ou pas. En revanche, nous verrons
qu'il est nécessaire de distinguer ce cas pour le décodage.


%%%

Les codes à effacement que l'on a décrit dans le \cref{sec.fecgeo} peuvent être
décris par des éléments géométriques tout comme les *Array* codes. Si le code
MDS par FRT possède d'importants liens avec ces derniers, le code Mojette
propose une alternative intéressante proposant un compromis entre les
performances et une redondance optimale.

Dans la représentation des codes $(k+2,k)$, la code à effacement Mojette, sous
forme systématique, calcule deux projections à partir d'une grille de hauteur
$k$. Il est ainsi possible de reconstruire deux lignes de la grille à partir de
ces projections. Le choix des directions de projection sera motivé par la
réduction du coup de la redondance. On choisira ainsi comme ensemble de
projections $\{(p,q)\}$ = $\{((0,1),(\pm{1},1)\}$, où le disque $P$ contiendra
les éléments de projections suivant la direction $(0,1)$, et $Q$ suivant
$(\pm{1},1)$.
La \cref{fig.mojette_raid6} montre cette représentation pour une grille $(3
\times 3)$. En particulier le choix du signe pour $Q$ n'a pas d'impact ni sur
la complexité des opérations, ni sur le coût de la redondance.

Pour l'encodage, le nombre d'opérations nécessaires pour le calcul d'une
projection dépend de la taille de la grille et de la direction de projection.
On le définit ainsi :

\begin{equation}
    c(k,w,p,q) = k \times w - B(k,w,p,q),
    \label{eqn.xor_enc}
\end{equation}

où $B(k,w,p,q)$ correspond au nombre de bins de la projection (voir
\cref{eqn.nombre_bins}). Puisque le disque $P$ correspond à la projection
suivant l'horizontal : le nombre de bin $B(k,w,0,1) = w$. Le calcul de cette
projection nécessite alors $(k-1)w$ opérations. Le nombre d'opération pour le
disque $Q$ correspond quant à lui à $(k-1)w - k + 1$. On remarque ici que pour
la première fois, le nombre d'opérations nécessaires est inférieur pour
calculer le disque $Q$ que pour le disque $P$. On peut également noter que si
l'on utilise le disque $P'$ à la place du disque $P$, on réduit le nombre
d'opération global au prix d'un coût de redondance plus élevé.

Les mise à jour dans le cas du code Mojette sont optimaux. En effet, la
modification d'un bloc de donnée impacte uniquement un bloc de parité
correspondant dans chaque disque. Dans le cas étudié, on modifie uniquement
deux bins quelque soit la position du pixel modifié.

% cependant la position du pixel entraînera plus ou moins

% d'opérations

\begin{figure}[t]
    \centering
    \def\svgwidth{.8\textwidth}
    \includesvg{img/dec_sys_mojette}
    \caption{Représentation de la méthode de détermination du nombre
    d'opérations nécessaire pour reconstruire une ligne $l$ à partir d'une
    projection. Cet exemple représente une grille $(P=12,Q=6)$. On cherche à
    reconstruire la ligne $l=2$ à partir de la projection suivant la direction
    $(p=1,q=1)$. Les éléments en rouge représentent les éléments impliqués dans
    la reconstruction de la ligne.}
    \label{fig.dec_sys_mojette}
\end{figure}

Dans le cas de la perte d'un disque, il est cette fois plus avantageux de
reconstruire la donnée en utilisant le disque $Q$ qu'en utilisant le disque
$P$. 
Lors du décodage en systématique, en cas d'effacement de la donnée, on affecte
la reconstruction d'une projection à une ligne effacée de la grille. Comme vu
précédemment dans \cref{sec.valeur_pxl}, la valeur du pixel à
reconstruire dépend non seulement d'un bin $b$ dans la projection
affectée, mais également de la somme des valeurs d'un ensemble d'éléments de la
grille. Notons qu'en fonction du pixel à reconstruire, le nombre d'opérations
nécessaire à sa reconstruction peut varier en fonction de sa position dans la
grille. En effet, un pixel situé dans un coin de la grille nécessitera en
général moins d'opérations qu'un pixel situé au milieu de la grille. De plus,
ce nombre va dépendre de la projection utilisée pour la reconstruction.
Si l'on reprend l'exemple d'un pixel situé dans un coin de la
grille, aucune opération n'est nécessaire si $(p,q) \ne (0,0)$, mais si
$(p,q)=(0,1)$ par exemple, alors $(Q-1)$ opérations seront nécessaires.

Soit $l$ l'index d'une ligne à reconstruire. \Cref{fig.dec_sys_mojette}
représente la situation où l'on souhaite reconstruire la ligne $l=2$ d'une
grille $(P=12,Q=8)$ en utilisant la projection suivant la direction
$(p=1,q=1)$. Les éléments de la grille en rouge représente les pixels utilisés
dans la reconstruction de la ligne $l$. Le nombre d'opérations nécessaires à la
reconstruction d'une ligne $l$ est défini par cet ensemble de pixel représenté
en rouge. Cet ensemble correspond aux éléments de la grille discrète contenus
entre les deux droites de projection qui passent par les extrémités de la ligne
$l$. Dans le cas général, ce nombre correspond à la surface de la grille
$(P \times Q)$ à laquelle on soustrait le nombre d'éléments de la ligne à
reconstruire $P$, et auquel on soustrait la surface en rouge. Dans notre
exemple, cette surface correspond à deux triangles rectangle discrets. Le
triangle supérieur possède une base et une hauteur de $l$, et le triangle
inférieur possède une base et une hauteur de $(Q-l)$. Le nombre d'opérations
nécessaires pour reconstruire cette ligne correspond à :

\begin{equation}
    c(P,Q,p,q,l) = (Q-1)P 
        - \frac{l(l+1)}{2}
        - \frac{(Q-l-1)(Q-l)}{2}.
    \label{eqn.dec_sys_mojette}
\end{equation}

\begin{figure}[t]
    \centering
    \pgfplotsset{width=0.7\linewidth}
    \input{tikz/xor_dec.tex}
    \caption{Nombre d'opérations nécessaires pour le reconstruction Mojette
    depuis la projection de direction $(1,1)$, en fonction de
    la position de la ligne effacée. La grille utilisée correspond à $k=11$ et
    $w=20$. La ligne en tirets représente les performances obtenues autant lors
    de la reconstruction par la projection $(0,1)$, que par les codes RDP
    (i.e.\ $(k-1)w$).}
    \label{fig.decodeur_raid6}
\end{figure}

En particulier, la \cref{fig.decodeur_raid6} représente le nombre d'opérations
nécessaires pour reconstruire un ligne depuis la projection $(1,1)$ en fonction
de l'index de cette ligne. On peut remarque le comportement quadratique de
cette courbe. En particulier, les lignes situées aux extrémités (i.e.\ $l=0$ et
$l=k-1$) nécessitent moins d'opérations pour être construites. En effet, la
surface des pixels impliqué dans la reconstruction est moins importante pour
ces lignes, alors qu'elle est maximale pour la ligne centrale. En particulier,
ces lignes bénéficient du fait qu'elles possèdent des pixels proches des coins
de la grille, et dont le nombre de dépendance est réduit.



## Bilan et discussion

\begin{table}
    \centering
    \resizebox{\columnwidth}{!}{%
        \input{removed/xor_table}
    }
    \caption{Tableau de comparaison du nombre d'opérations nécessaires pour
    différents code à effacement selon les métriques définies dans la partie
    \cref{sec.nomenclature}. Pour les codes de \rs, les opérations de
    multiplications sont symbolisées par $\otimes$. Lorsque différents résultats
    existent, le pire cas est affiché (e.g.\ les performances de décodage pour les
    codes \eo pour $Q$ dépendent du calcul de $S$).}
    \label{tab.comparaison}
\end{table}

\Cref{tab.comparaison} résume les résultats obtenus précédemment. On y exprime
le nombre d'opérations nécessaires pour chaque métriques détaillées en première
section, en fonction des différents codes. En particulier, on distingue les
métriques d'encodage et de décodage en fonction de l'utilisation du disque $P$
ou $Q$. On remarque que la génération du disque $P$ nécessite toujours $(k-1)w$
opérations. En effet, ce disque correspond toujours à la parité horizontale des
disques de données. Pour les même raisons, la reconstruction depuis le disque
$P$ nécessite toujours ce même nombre d'opérations. En revanche, le nombre
d'opérations nécessaires quand on interagit avec $Q$ forme un critère
intéressant puisque celui ci varie pour chaque code. Le critère de mis à jour
d'un bloc est également décisif.

#### Les spécificités des codes de \rs

Les performances théoriques des codes de \rs sont compliqués à définir. En
effet, la multiplication dans les corps de \textsc{Galois} peut être
implémentée de différentes manières.
Les tables de correspondance permettent de remplacer le calcul d'une opération
par la lecture d'un résultat, mais peuvent avoir des tailles significatives et
ainsi impacter les performances de la mémoire. Bien qu'il existe une version
des codes de \rs qui remplacent les opérations de multiplications par des XOR,
il n'existe pas de forme close permettant de déterminer le nombre d'opérations
nécessaires en fonction des paramètres de codes. C'est pourquoi dans le
\cref{tab.comparaison}, nous distinguons les opérations de multiplications par
$\otimes$.


#### Analyse des performances

Afin de comparer les performances d'encodage et de décodage, prenons $(k-1)w$
opérations, comme référence. Cette référence correspond au meilleur résultat
obtenu par les codes MDS RDP.
Concernant l'encodage, les codes de \rs et \eo ont tous les deux un coût
supplémentaire par rapport à cette référence : (i) les codes de \rs nécessite
deux multiplications supplémentaires; (ii) les code de \eo nécessite $(k-2)$
additions supplémentaires à cause du calcul de $S$. Le code Mojette en
revanche, requiert moins d'opérations pour calculer le disque $Q$. Comme
précisé précédemment, il s'agit par ailleurs du seul code qui nécessite moins
d'additions pour calculer $Q$ que pour calculer $P$.

Côté reconstruction d'un disque en utilisant les données du disque de parité
$Q$, le même constat peut être fait. Les codes RDP nécessite encore $(k-1)$
opérations. Les codes de \rs et \eo ont un surcout calculatoire respectivement
dû aux multiplication et au calcul de $S$ encore une fois. Pour le code
Mojette, le nombre d'opérations à réalisé dépend du disque inaccessible (voir
\cref{eqn.dec_sys_mojette}). Cependant, quelque soit le disque perdue, sa
reconstruction par le disque $Q$ nécessitera toujours un nombre d'opérations
inférieur à $(k-1)w$ comme le montre la \cref{fig.decodeur_raid6}.

Quant aux mises à jour d'un bloc de données, bien que tous les codes sont
capables d'atteindre la meilleure performances de $3$ additions dans le
meilleur des cas, seul les codes Mojette fournissent ces performances quelque
soit la position du bloc modifié.
En conclusion, les codes Mojette fournissent des performances meilleures que
les codes MDS utilisés pour le stockage distribué en RAID-6. Ces performances
nécessite en revanche un léger surcout de redondance que l'on a mesuré
précédemment.


Bien que les performances théoriques sont liées par le nombre d'opérations
réalisées durant les opérations d'encodage et de décodage, d'autre critères
entrent en jeu en pratique, dans l'implémentation. Comme nous l'avons vu dans
la première section, les opérations doivent être réalisées au plus près du
processeur.
Un autre enjeu correspond à la localité spatiale de nos données. Cette
considération correspond à la caractéristique de notre algorithme à traiter les
données de manière séquentielle. L'intérêt d'un accès séquentiel aux données
repose sur deux considérations : (i) il n'est pas nécessaire de calculer et
d'accéder à de l'information distante (les disques durs mécaniques par exemple
perdent un temps considérable à déplacer les têtes de lecture pour accéder à
des données distantes); (ii) il est possible de charger en avance la donnée
pour la placer dans les zones mémoires près du processeur (c'est l'objectif de
l'appel système *readahead* sur Linux par exemple). Bien qu'il soit possible de
favoriser ces comportements, il est compliqué de les quantifier. Dans le cas du
code à effacement Mojette, nous avons vu que la géométrie du problème permet de
favoriser la localité spatiale.



# Généralisation de la construction des codes


## Reed-Solomon


## Array Codes


## Mojette

### Performances de l'encodeur Mojette

L'opération d'encodage génère $n$ projections à partir d'une grille discrète de
hauteur $k$. Dans la suite, nous analyserons le nombre d'opérations nécessaires
pour le calcul d'une projection.
Bien que la génération d'une projection met en jeu l'ensemble des
éléments de la grille discrète une et une seule fois (voir \cref{eqn.mojette}),
le nombre $c$ d'opérations nécessaires pour l'encodage varie en fonction de
deux paramètres : la taille de la grille, et la direction de projection.
Le nombre d'additions nécessaires pour générer une projection
$\text{Proj}_{f}(p,q,b)$ correspond à :

\begin{equation}
    \begin{aligned}
        c(P,Q,p,q)  &= P \times Q - B(P,Q,p,q), \\
                    &= P \times Q - \left((Q-1)|p_{i}|+(P-1)|q_{i}|+1\right),
    \end{aligned}
    \label{eqn.enc_mojette}
\end{equation}

et représente le nombre d'éléments de la grille discrète ($P \times Q$) auquel
on soustrait le nombre de bins de la projection, tel que défini dans
\cref{eqn.nombre_bins}. 
Considérons à présent que l'on fixe la taille de la grille, ainsi qu'un
paramètre de projection. Nous reprendrons notre exemple avec $q_i=1$. Dans ce
cas, si $p=0$, alors :

\begin{equation}
    c(P,Q,0,1) = (Q-1) \times (P - |p_i|).
    \label{eqn.enc_mojette_q}
\end{equation}

En conséquence, quand les dimensions de la grille sont fixées, si la valeur de
$|p|$ augmente, alors le nombre d'opérations nécessaire pour générer une
projection $c(P,Q,p,q)$ diminue. Cela signifie que plus une projection est
grande, moins elle nécessite d'opérations d'addition pour être calculée.
En conséquence, si seules les performances sont essentielles pour une
application, on choisira des projections avec de grandes valeurs de $|p|$.


### Performances du décodeur Mojette non-systématique


% ajouter le cas de l'algorithme dim'dim

% Nous comparerons ici deux algorithmes. Le premier correspond

% à l'algorithme de

% Le second correspond à un cas particulier

% de l'algorithme de reconstruction systématique, dans le cas où 

% toutes les lignes de la grille ont été effacées.

Nous prendrons comme sujet d'étude, l'algorithme de reconstruction BMI défini
par \textcite{normand2006dgci}. Dans cet algorithme, les opérations réalisées
correspondent à : (i) la reconstruction de $(P \times Q)$ pixels; (ii) la mise
à jour de l'ensemble des $k$ de chaque projection liés à chaque pixel
reconstruit. En conséquence, il est nécessaire de réaliser
$P \times Q \times Q$ additions pour reconstruire la grille entière.


### Performances du décodeur en systématique



# Expérimentations {#sec.eval.perf}

Dans cette section, nous évaluons les performances du code à effacement
Mojette et comparons ces résultats avec les performances des meilleures
implémentations des codes de Reed-Solomon.
Nous détaillons dans une première section les caractéristiques des codes
étudiés. Dans la suite, nous présenterons comment nous avons réalisé cette
expérimentation avant de nous intéresser aux résultats.

## Les implémentations à comparer

Nous avons choisi de comparer nos implémentations du code à effacement Mojette
avec une implémentation des codes de Reed-Solomon. De par leur popularité et
leur accessibilité, les codes de Reed-Solomon représentent le compétiteur
évident pour notre comparaison. Ces codes sont en effet largement distribués à
travers de nombreuses bibliothèques.

### Implémentations Mojette

Nous avons implémenté une version systématique du code à effacement Mojette en
langage C. Le choix de ce langage est judicieux lorsque l'on développe une
technique de codage devant fournir de hautes performances. En effet la
possibilité de laisser la gestion mémoire à l'utilisateur, ainsi que le recours
à diverses instructions particulières du processeur, permettent d'atteindre
d'excellentes performances.

Dans la suite, nous reprenons la terminologie utilisée dans le chapitre
précédent \ref{sec:mojette_directe}. En pratique, la taille des pixels de la
grille discrète, et des bins des projections, doivent correspondre à un mot
machine. Un mot correspond à l'unité de base, exprimée en bits, manipulée par
un processeur. Pour les architectures classiques, la taille d'un mot
correspond à $32$ ou $64$ bits. Il s'agit plus exactement de la taille des
registres du processeurs. En conséquence, un processeur est d'autant plus
rapide que ses mots sont longs puisqu'une plus grande quantité d'information
est traitée à chaque cycle. Nous avons alors fixé la taille des bins
et pixels à $64$ bits. Cette valeur correspond à la taille des registres des
architectures usuelles aujourd'hui.

La plupart des processeurs proposent depuis 1997 des extensions de leur jeu
d'instructions afin d'améliorer les performances de certains traitements. Les
instructions *Single Instruction, Multiple Data* (SIMD) correspondent à un mode
de fonctionnement du processeur afin de profiter de parallélisme. Plus
particulièrement, il s'agit d'appliquer en parallèle la même instruction sur
plusieurs données afin d'obtenir plusieurs résultats. Les processeurs Intel par
exemple, proposent des extensions pour flux SIMD (*Streaming SIMD Extensions*
SSE) qui ajoutent jusqu'à 16 registres de 128 bits et 70 instructions
supplémentaires pour les processeurs x86. Ce mode de fonctionnement permet donc
de traiter $2048$ octets en parallèle, en un cycle processeur. Les applications
peuvent alors bénéficier de cela dés lors qu'une instruction
peut être réalisée sur plusieurs données. En pratique, ce mode est largement
utilisé dans les applications multimédias, scientifiques ou financières. Dans
le stockage, il permet notamment d'augmenter les performances du RAID logiciel
utilisé dans Linux \cite{anvin2004raid}.

Ce mode de fonctionnement est donc très intéressant pour notre code à
effacement étant donné que les performances sont cruciales dans les systèmes
temps-réel. Les algorithmes d'encodage et de décodage Mojette sont adaptés à ce
fonctionnement puisque nous appliquons une instruction, qui correspond à
l'addition, sur une multitude de données, représentées par les éléments de la
grille discrète et des projections. En conséquence, dans notre mise en œuvre,
l'addition est implémentée par des opérations de OU exclusif (XOR),
correspondant à des additions modulo deux, sur des données de $128$ bits.

Dans cette partie, nous allons comparer les performances de deux
implémentations de notre code à effacement Mojette : une première version
non-systématique, que l'on appellera *NS-Mojette* dans la suite de la
rédaction, puis une implémentation systématique que l'on désignera simplement
par *Mojette*.

## Configuration de l'expérimentation

\begin{figure}[t]
    \centering
    \def\svgwidth{\textwidth}
    \footnotesize
    \includesvg{img/expe_code2}
    \caption{Représentation de l'expérimentation. Les données aléatoires sont
    stockées dans un \emph{buffer} indexé par $k$ adresses. Le décodage est
    réalisé après avoir supprimé $e \times \frac{\mathcal{M}}{k}$ octets. On
    enregistre le compteur de cycles avant et après la fonction d'encodage et
    de décodage pour mesurer les performances.}
    \label{fig.expe_code}
\end{figure}

Dans cette partie, nous allons évaluer les performances d'encodage et de
décodage des implémentations des codes à effacement Mojette et Reed-Solomon,
présentés précédemment. Ces tests sont réalisés sur un seul processeur afin de
mettre en évidence la différence de performance entre les différentes
implémentations.

Les tests réalisés dans cette partie mettent en jeu plusieurs
plusieurs paramètres. Ainsi nous allons faire varier les paramètres $n$ et $k$
des codes à effacement, qui définissent implicitement la tolérance aux pannes
que fourni le code. En pratique, ce facteur dépend de la nature des données,
des applications et du support sur lequel transite la donnée.
Les fournisseurs de service web proposent en général une protection face à
quatre pannes. C'est le cas de Facebook, qui utilise des codes de Reed-Solomon
au sein de leurs grappes de stockage \cite{sathiamoorthy2013vldb}.
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
sur des blocs de *128* Mo par défaut \cite{shvachko2010msst}.

\cref{fig.expe_code} représente l'expérimentation que l'on réalise.
Les performances enregistrées lors de l'encodage correspondent au
nombre de cycles CPU nécessaires pour générer $n$ blocs encodés à
partir de $k$ blocs de données. Ces $k$ blocs totalisent $\mathcal{M}$ octets.
Plus particulièrement dans notre mise en œuvre, ces $k$ blocs correspondent à
une zone mémoire de $\mathcal{M}$ octets de données aléatoire, dont on
représente chaque bloc par $k$ pointeurs vers l'adresse de début de ces blocs.
L'encodage non systématique consiste alors à la génération de $n$ blocs de
données encodés à partir de ces données d'entrées. En revanche, pour les
versions systématiques, les performances d'encodage correspondent à la copie
des $k$ blocs de données, plus la génération de $(n-k)$ blocs de parité. Le
critère de comparaison de performance entre les différents codes correspond
donc au nombre d'opérations du CPU nécessaires pour offrir une certaine
tolérance aux pannes.

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

## Résultats de l'expérimentation

### Performances d'encodage

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
\cref{fig.encoding4k,fig.encoding8k} montrent les résultats obtenus pour
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
cette version est non-systématique, elle doit calculer $12$ projections Mojette
dans le cas d'un code $(12,8)$, tandis que le code de Reed-Solomon doit
calculer seulement $4$ blocs de parité. On observe cependant dans le cas du
test de \cref{fig.encoding4k}, qu'il nécessite plus de $30$\% de cycles
supplémentaires par rapport à NS Mojette, pour protéger la donnée face à $4$
pannes. On observe donc que malgré le désavantage calculatoire de notre code en
version non-systématique, il parvient dans le cadre de nos tests à être
compétitif avec des codes systématiques.

Une deuxième observation est que la version systématique du code Mojette est
plus performante que sa version non-systématique. Ce résultat était attendu
puisque cette dernière version doit calculer
trois fois plus d'information lors de l'encodage. Notons cependant que la
différence observée entre les résultats de ces deux implémentations n'est pas
un facteur trois. Lors de nos tests d'encodage, le nombre de cycles CPU mesuré
des implémentations systématiques correspond à : (i) la copie des $k$ blocs
d'informations en clair; (ii) plus le calcul des $(n-k)$ blocs de
parité. Les résultats observés correspondent donc à la somme de cette copie et
de l'encodage. En revanche, si l'on prend l'exemple des résultats du code
Mojette $(6,4)$ sur des blocs de $4$Ko, présentés dans \cref{fig.encoding4k},
on observe que $(705-321) \times 3 = 1152$, où $321$ correspond aux nombres de
cycles CPU nécessaires pour copier $4096$ octets, et où $1152$ correspond à la
valeur observée dans les résultats de la version non-systématique de la même
courbe. Ces résultats nous permettent donc de valider que l'encodage
systématique est trois fois plus performant que l'encodage non-systématique
dans le cas où nos codes sont réglés sur un taux $r=\frac{3}{2}$.

En conséquence, nos courbes de résultats montrent que pour les paramètres
choisis dans nos expériences, l'encodage de l'implémentation non-systématique
offre des performances comparables à la meilleure implémentation des codes de
Reed-Solomon développée par Intel. De plus, la version systématique du code
Mojette que nous avons développée offre des performances d'encodage largement
supérieures à ce que proposent les autres codes utilisés dans nos tests. En
particulier, les résultats atteint par notre nouvelle mise en œuvre sont
proches des résultats optimaux correspondant à la copie de l'information, sans
opération d'encodage. Ceci montre que le surcout calculatoire de cette nouvelle
version est particulièrement réduit.


### Performances de décodage

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
déclenchées. Une première remarque globale est que l'influence des effacements
n'est pas le même selon si le code est systématique ou non. Pour NS Mojette, le
nombre d'effacement $e$ n'a pas d'influence sur les performances de décodage.
Ce résultat provient du fait que le décodage des codes non-systématiques
correspond à la reconstruction entière des informations utilisateurs. Ainsi le
nombre d'opérations est comparable quelque soit l'ensemble des blocs encodés
utilisé pour cette reconstruction.

Dans le cas des codes systématiques en revanche, le décodage correspond à
reconstruire un ensemble partiellement reconstruit de la donnée. En
conséquence, le nombre de cyles CPU nécessaires pour le décodage augmente au
fur et à mesure que l'on augmente le nombre de blocs de données effacés.
En particulier, la différence entre les performances de l'implémentation
systématique du code Mojette et des valeurs optimales augmente avec le nombre
d'effacement puisque l'on supprime progressivement des lignes de la grille
discrète. En effet, puisque l'on considère une grille de moins en moins
remplie, et puisque les opérations d'additions nécessaires à la reconstruction
Mojette sont plus coûteuses que la copie utilisée dans memcpy(), les
performances décroissent.

Notons cependant que malgré la baisse de performances du décodage observée
lorsque l'on augmente le nombre d'effacement pour le code systématique Mojette,
les valeurs enregistrées sont d'une part toujours meilleures que celles
observées pour la version non systématique (puisqu'il s'agit du cas où la
grille doit être entièrement reconstruite). D'autre part, ces performances sont
significativement meilleures que les performances observées par
l'implémentation systématique des codes de Reed-Solomon.

% ### Influence de la tolérance aux pannes

% ### Impact de la taille des blocs




\section*{Conclusion}





% # Évaluation


% ça poutre !

