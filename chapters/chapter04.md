
% \chapter{Redondance dans les systèmes de stockage

% distribués par codage à effacement}

\chapter{Les codes à effacement dans le stockage distribué}

\label{sec.chap4}

\minitoc

\newpage


\section*{Introduction}

Dans les systèmes de stockage, les codes à effacement sont connus pour fournir
une alternative efficace aux techniques de réplication. Ils permettent
notamment de réduire significativement la quantité de redondance nécessaire
pour fournir une tolérance aux pannes.
Une panne correspond à l'indisponibilité d'une donnée. En pratique, ces
indisponibilités sont les conséquences de problèmes de différentes natures
(e.g.\ logicielle, matérielle, réseau, \dots).
Afin d'augmenter la disponibilité des données, il est nécessaire de distribuer
ces informations de manière redondante sur plusieurs supports de stockage.
Ainsi, il est possible de supporter l'indisponibilité d'une partie de ces
données en utilisant l'information redondante.

En \citeyear{patterson1988sigmod}, \textcite{patterson1988sigmod} publient
leurs travaux qui présentent cinq techniques d'agrégation de disques durs.
Ces techniques d'agrégation sont regroupées sous la désignation *Redundant
Array of Independant Disks* (RAID), qui peut se traduire par « Matrice
redondante de disques indépendants ». Chaque niveau RAID, identifié par un
numéro, permet d'exploiter un ensemble de disques afin d'améliorer les
performances et/ou la disponibilité des données. D'un côté, les
performances de lecture et d'écriture sont améliorées grâce à la distribution
des données qui permet d'exploiter l'ensemble des disques simultanément
(*stripping*). Cette technique est notamment à la base du RAID-0.
De l'autre, des techniques permettent d'améliorer la disponibilité des données.
En particulier, ces technique génèrent de la redondance au sein du système de
stockage. Il est par exemple possible de répliquer l'information sur l'ensemble
des disques disponibles, comme en RAID-1. D'autres méthodes permettent de
calculer $r$ disques de parité à partir de $k$ disques de données, ce qui
permet de supporter la panne de $r$ disques. C'est le cas en RAID-4
et RAID-5 pour $r=1$, et RAID-6 pour $r=2$. Ces techniques ont ainsi permis de
démocratiser l'utilisation des codes à effacement au sein de systèmes de
stockage. Elles sont encore aujourd'hui largement utilisées.

À l'origine, l'agrégation des ressources matérielles comme utilisée
dans le stockage par les méthodes RAID, est rendue possible dans
les années $80$ avec la réduction significative de la taille et du prix des
composants informatiques \cite{bell1984computer}.
En parallèle du monde du stockage, les microprocesseurs apparaissent à la même
époque et permettent de fournir une puissance de calcul bon marché et compacte.
Ces réductions permettent d'agréger les ressources de calcul au sein d'un
système multiprocesseur. \textcite{krajewski1985byte} utilise notamment
l'expression *Array Processing* pour désigner une matrice de processeurs
exécutant la même instruction sur un jeu de données.

Dans les systèmes de stockage organisés en RAID-4 et RAID-5, les informations
du disque de parité correspondent à la somme des informations des disques de
données. En revanche, il devient plus compliqué de fournir des disques de
parité supplémentaires. En particulier, il existe plusieurs méthodes pour
calculer un deuxième disque de parité en RAID-6 \cite{pertin2015sifwict}. Par
exemple, les codes de \textcite{reed1960jsiam} peuvent être utilisés pour
calculer ces disques de parité. Cependant, plusieurs méthodes optimisées pour
cette configuration ont été conçues et permettent de calculer ce deuxième
disque de façon plus performante. En particulier, les *Array* codes rassemblent
une famille de codes qui ont été conçus dans cette optique. Les codes \eo de
\textcite{blaum1995toc} et les codes *Row Diagnoal Parity* (RDP) de
\textcite{corbett2004fast} font partis de cette famille de codes. Bien que plus
performants par rapport aux codes de \rs, ces méthodes sont limitées à deux
voir trois disques de parité, et se généralisent difficilement au delà
\cite{blaum1996tit}. En conséquence, il n'existe pas de solution parfaite et
les concepteurs de systèmes de stockage doivent privilégier soit les
performances, soit la haute disponibilité des données.

Dans ce chapitre, une de nos contributions sera de fournir une étude
sur les performances théoriques des codes conçus pour RAID-6
(i.e.\ $r=2$). Plus particulièrement, les critères de comparaison porteront sur
des métriques adaptées au contexte du stockage telles que les performances
d'encodage, de décodage et de mise à jour des données.  La \cref{sec.raid6}
fournit une comparaison des codes RAID-6 traditionnels avec le code Mojette
dans sa version systématique, tel que défini précédemment dans
\cref{sec.chap3}. La \cref{sec.rsmoj} compare de manière théorique les codes de
\rs et Mojette dans le cas général. Enfin, la \cref{sec.eval.perf} présente une
évaluation des performances des implémentations du code Mojette face aux
meilleures implémentations des codes de \rs fournies par
\textcite{intel2015isal}. Nous montrerons en particulier que le code Mojette
bénéficie de meilleures performances théoriques dans l'ensemble des métriques,
au prix d'un léger surcout de données à stocker. Ces aspects théoriques seront
validés dans l'expérimentation en dernière partie.



# Cas des codes à effacement $(k+2,k)$ pour le stockage : RAID-$6$ {#sec.raid6}


## Architecture en RAID-6 

\begin{figure}[t]
    \centering
    \def\svgwidth{\textwidth}
    \includesvg{img/array}
    \caption{Représentation d'une matrice de disques organisés en RAID-6. Un
    ensemble de $k$ disques de données sont utilisés pour encoder $2$ disques
    de parité : $\PP$ et $\QQ$. Les disques sont partitionnés en $w$ blocs. Une
    bande correspond à un ensemble de $n$ blocs impliqués dans un processus
    d'encodage.}
    \label{fig.array}
\end{figure}

La particularité de l'organisation des disques en RAID-6 est d'améliorer les
performances de lecture et d'écriture par la répartition des données sur les
disques, et la protection des données face à deux pannes disques en proposant
deux disques de parité. On représente généralement cette organisation sous la
forme d'une matrice de $n$ disques possédant la même capacité de stockage. Ces
$n$ disques sont divisés en deux parties : (i) un ensemble de $k$ disques de
données; (ii) un ensemble de $(n-k)$ disques de parité contenant les données de
redondance calculées depuis les disques de données. Chaque disque est divisé en
$w$ blocs d'information de $\beta$ bits. La \cref{fig.array} représente une
matrice RAID-6
avec $w=2$ blocs. En pratique, un bloc correspond à un mot de $\beta$ bits
(e.g.\ $\{8,\dots,256\}$). En réalité, si l'on divise un disque en blocs
de $\beta$ bits, la valeur de $w$ est trop grand. C'est pourquoi, on applique
la technique de codage sur des sous-ensembles de $w$ blocs adaptés pour le code.
Nous verrons dans la suite quelle valeur de $w$ est utilisée pour chaque code.
Les codes RAID-6 correspondent à une famille de codes généralement MDS,
de paramètres $(n=k+2,k)$. En conséquence, le nombre de blocs $w$ des disques
de parité correspond au nombre de blocs des disques de données.


## Métriques d'analyse de performance {#sec.metriques}

Le contenu du premier disque de parité $\PP$ est toujours calculé de la même
manière. Les $w$ blocs qu'il contient correspondent à des informations de
parité horizontale des blocs des $n$ disques de données. En revanche, plusieurs
méthodes présentées dans ce chapitre permettent de calculer les données du
disque $\QQ$. Nous allons ainsi comparer ces techniques selon les métriques
suivantes qui sont classiquement utilisées dans les papiers respectifs des
codes étudiés :

* Le **coût à l'encodage** correspond au nombre d'opérations nécessaires pour
encoder un disque de parité;

* Le **coût de mise à jour** correspond au nombre d'opérations nécessaires pour
modifier un bloc de donnée et mettre à jour les données associées dans les
disques de parité. Par rapport aux études habituelles, nous considérerons une
mise à jour différentielle dans notre étude. C'est à dire qu'au lieu de
ré-encoder complètement les informations, nous calculerons seulement la
différence avec la valeur d'origine. Par la suite, nous appliquerons par
linéarité de l'opération d'encodage cette différence sur la donnée de parité,
tel que proposé par \textcite{zhang2012nas}. Nous verrons en particulier que
dans la cas de certains codes, la position du bloc modifié dans la matrice a un
impact significatif sur les performances;

* Le **coût au décodage** correspond au nombre d'opérations nécessaires pour
reconstruire l'information d'un disque de données qui subit une panne. On
considère dans la suite qu'une panne entraîne l'indisponibilité totale d'un
disque de données. Nous verrons durant notre analyse que certains codes
possèdent de meilleures performances en reconstruisant l'information depuis le
disque $\QQ$ plutôt que $\PP$.


## Analyse des performances des codes RAID-6

Par rapport aux codes de \rs qui peuvent fournir un taux de codage
arbitraire, les *Array* codes sont conçus et optimisés pour gérer une quantité
limitée de redondance.
Dans la suite, nous décrirons et analyserons les performances des codes de \rs,
ainsi que deux *Array* codes (\eo et RDP). Enfin nous apporterons une
comparaison des performances de ces codes avec le code Mojette. Nous verrons
que ce dernier apporte de meilleures performances dans les différentes
métriques définies précédemment.

% Les résultats de cette analyse seront

%regroupés dans le \cref{tab.comparaison}

%situé en \cpageref{tab.comparaison}.


### Codes de \rs

Les codes de \rs peuvent être utilisés pour définir la méthode de calcul des
données de parité. Contrairement à la construction d'une matrice d'encodage
systématique dans le cas général, la matrice d'encodage dans le cas particulier
du RAID-6 est simple et scindée en deux partie : $G = [I_k | R]$. La première
partie correspond à la matrice carrée identité $I_k$ de taille $(k \times k)$
et permet d'intégrer l'information à traiter dans les données encodées. La
seconde partie correspond à la matrice de redondance $R$ de taille $(2 \times
k)$ permettant de calculer les valeurs des disques de parité $\PP$ et $\QQ$. La
matrice $R$ correspond à une matrice de \vander de la forme :

\begin{equation}
    \begin{pmatrix}
        1 & 1 & 1 & \cdots & 1 \\
        \alpha^0 & \alpha^1 & \alpha^2 & \cdots & \alpha^{k-1}
    \end{pmatrix},
    \label{eqn.matrice.h}
\end{equation}

\noindent avec $\alpha \in \text{GF}(q)$ un générateur du corps. Si l'on
utilise par exemple le corps de \galois GF$(2^8)$ et un générateur de ce corps
tel que $\alpha=2$, l'opération d'encodage d'une bande correspond alors à
l'équation matricielle suivante :

\begin{equation}
    \begin{pmatrix}
        1 & 0 & 0 & \cdots & 0 \\
        0 & 1 & 0 & \cdots & 0 \\
        0 & 0 & 1 & \cdots & 0 \\
        \vdots & \vdots & \vdots & \ddots & \vdots \\
        0 & 0 & 0 & \ddots & 1 \\
        1 & 1 & 1 & \cdots & 1 \\
        1 & 2 & 4 & \cdots & 2^{k-1}
        %\alpha_1^1 & \alpha_1^2 & \alpha_1^3 & \cdots & \alpha_1^{k},
    \end{pmatrix} \times
    \begin{pmatrix}
    d_0 \\ d_1 \\ d_2 \\ \vdots \\ d_{k-1} \\ 
    \end{pmatrix} =
    \begin{pmatrix}
    d_0 \\ d_1 \\ d_2 \\ \vdots \\ d_{k-1} \\ p \\ q \\
    \end{pmatrix},
    \label{eqn.matrice.raid6}
\end{equation}

\noindent où $p,q \in \text{GF}(2^8)$ correspondent aux valeurs des données de
parité, respectivement stockées dans les disques $\PP$ et $\QQ$, impliquées
dans le calcul d'une bande. Dans la suite, nous allons uniquement considérer
le calcul de $p$ et $q$. Puisque dans notre représentation, un disque est
composé de $w$ bandes, l'encodage nécessite $w$ fois cette opération.
L'\cref{eqn.matrice.raid6} montre ainsi que l'encodage du disque $\PP$ ne
requiert que $(k-1)w$ additions, tandis que le calcul des valeurs du disque
$\QQ$ nécessite $(k-1)w$ additions et $kw$ multiplications.
Les mises en œuvre des codes \rs souffrent notamment de
l'implémentation des opérations dans les corps de \galois. En particulier, la
multiplication est une opération coûteuse qui peut être implémentée de
plusieurs manières. Par exemple, afin d'améliorer les performances de
l'encodage, \textcite{anvin2004raid} propose de décomposer le calcul de $q$
en utilisant la méthode de \textsc{Ruffini-Horner}, illustrée dans
l'\cref{eqn.anvin.raid6} :

\begin{align}
    q   & = d_0 + (2 \times d_1) + (4 \times d_2) + (8 \times d_3) + (16
    \times d_4) \\
        & = d_0 + ( 2 \times d_1 + ( 2 \times d_2 + ( 2 \times d_3 + (2 \times
        d_4)))). \label{eqn.anvin.raid6}
\end{align}

\noindent Dans cette représentation, il suffit alors de développer une
implémentation efficace de la multiplication par deux.

La modification d'un bloc de donnée entraîne la mise à jour de deux blocs de
parité. Une addition est réalisée pour calculer la différence, deux
supplémentaires sont nécessaires pour mettre à jour le bloc correspondant dans
$\PP$ puis dans $\QQ$. Enfin, une multiplication permet de finir la mise à jour
du bloc dans $\QQ$. En conséquence, la modification d'un bloc entraîne trois
additions et une multiplication.

Le décodage nécessite autant d'opérations que l'encodage en considérant que
la matrice inverse est pré-calculée. Pour reconstruire un disque, dans le cas
où il y a une seule panne, le processus de décodage favorise l'utilisation de
$\PP$ puisque cela entraînerait le recours à $(k-1) \times w$ additions.
En effet, l'utilisation du disque $\QQ$ nécessite des opérations de
multiplication supplémentaires, plus complexes à mettre en place. Dans le cas
de deux pannes, l'opération nécessite autant d'opérations qu'à l'encodage,
c'est à dire : $2 \times (k-1)w$ additions et $k \times w$ multiplications.


% peut être faux non ?

% voir minimal density blabla



### Les *Array* codes

Les *Array* codes ont été conçus à l'origine comme une alternative aux codes de
\rs afin d'éviter les opérations de multiplication dans les corps de
\galois. Bien que ces codes fournissent une quantité de redondance limitée, ils
ne réalisent que des opérations d'addition, et sont en conséquence performants.
Les disques $\PP$ et $\QQ$ sont respectivement calculés en utilisant des bandes
horizontales et diagonales. Le calcul de $\PP$ correspond également à un mot de
code de parité. On s'intéressera en particulier à la conception du disque
$\QQ$ pour les codes \eo \cite{blaum1995toc} et RDP \cite{corbett2004fast}.

%est alors également décrit par l'\cref{eqn.rs_p}

#### Les codes \eo

\begin{figure}[t]
    \centering
    \def\svgwidth{.7\textwidth}
    \includesvg{img/evenodd}
    \caption{Représentation d'un code \eo sur une matrice $(k=5, w=4)$. La
    figure s'intéresse en particulier au calcul des valeurs du disque $\QQ$, basé
    sur la valeur des données des disques $D_i$. L'ajusteur $S$ correspond à la
    somme des éléments de la diagonale blanche. Sa valeur est additionnée à
    chaque bloc de $\QQ$, qui sont déterminés par une parité diagonale. Figure
    inspirée de \cite{plank2009fast}.}
    \label{fig.evenodd}
\end{figure}

Les codes \eo ont été conçus en \citeyear{blaum1995toc} par
\textcite{blaum1995toc}. Les paramètres du code sont contraints de telle
manière que $(w+1)$ soit premier, et que $k \leq w+1$. Lorsque le disque $\QQ$
est impliqué, que ce soit pour l'encodage ou le décodage, une valeur
intermédiaire $S$ (nommée *ajusteur*) doit être déterminée afin de garantir la
propriété MDS du code. La \cref{fig.evenodd} représente le processus pour
calculer $\QQ$. La valeur de l'ajusteur correspond à la somme des éléments
suivant la diagonale blanche. La valeur des blocs de $\QQ$ correspond à la
somme des éléments des disques de données suivant différentes diagonales
(représentées par des couleurs différentes sur la \cref{fig.evenodd}), à
laquelle on rajoute la valeur de $S$.

Lors de l'encodage, cet ajusteur nécessite $(k-2)$ additions. L'encodage
nécessite $(k-1) \times w$ additions pour calculer $\PP$ et $(k-1)w + k - 2$ pour
calculer les valeurs de $\QQ$. En conséquence, le disque $\QQ$ requiert plus
d'opérations que le disque $\PP$.

Les conséquences de la modification d'un bloc de donnée dépend de la position
de ce bloc. Dans la plupart des cas, cette modification entraîne la mise à jour
d'une valeur optimale de $2$ blocs de parité. On calcule ainsi la différence
entre l'ancienne et la nouvelle valeur du bloc, puis on met à jour un bloc de
$\PP$ et un bloc de $\QQ$, ce qui coûte trois additions. En revanche, lorsque la
modification affecte un bloc de la diagonale qui définit la valeur de $S$,
l'ensemble des blocs du disque $\QQ$ est affecté. En conséquence, $w$ additions
sont réalisées, une autre est nécessaire pour calculer la différence, et une
dernière pour la mise à jour du bloc du disque $\PP$. Cette situation
correspondant au pire cas nécessite alors $(w+2)$ additions.

Concernant la reconstruction d'un disque, plusieurs scénarios sont possibles.
Quand une panne affecte un seul disque, il est recommandé de reconstruire en
utilisant le disque $\PP$ pour ne pas avoir à calculer la valeur de $S$. Une
panne est alors réparée en utilisant $(k-1) \times w$ additions. Lorsque les
disques de données subissent deux pannes, il est tout d'abord nécessaire de
recalculer la valeur de $S$. Le coût du calcul de $S$ dépend de la position des
disques en panne. Soit $\gamma(S)$ le nombre d'opérations nécessaires pour
recalculer la valeur de $S$. Soit deux entiers $i,j \in \ZZ_w$ tel que $i \neq
j$ correspondant respectivement à l'index du premier et second disque en panne.
Dans ce cas, on distingue les trois cas suivants :

1. Si $i=0$ et $j \geq k$, alors la méthode utilisée lors de l'encodage permet
de recalculer la valeur de $S$, puisque le disque en panne n'impacte pas la
diagonale blanche. En conséquence, $\gamma(S) = k-2$ opérations;

2. Si $i<k$ et $j=k$, alors il est nécessaire de calculer $S$ à partir de
n'importe quelle autre diagonale, donc $\gamma(S) = k-1$ opérations;

3. Si $i,j < k$, alors $S$ peut être calculée en additionnant l'ensemble des
valeurs des disques de parité. Cela nécessite $\gamma(S) = 2(k-2)$ opérations.
Cette situation correspond au pire cas.

\noindent Une fois que la valeur de $S$ est calculée, il est possible de
reconstruire les éléments des disques effacés par un processus itératif. La
première itération consiste à reconstruire la valeur d'un bloc effacé en
utilisant une bande diagonale. La seconde itération utilise la bande
horizontale de ce bloc afin de reconstruire un nouveau bloc. En utilisant
alternativement parité diagonale et horizontale, on parvient à reconstruire
l'ensemble des données effacées. Le coût total de la reconstruction est
$2(k-1)w + \gamma(S)$. Le pire cas correspond à la perte de deux disques
impliqués dans la diagonale de $S$. Dans cette situation, la reconstruction
nécessite $2(k-1)w + 2(k-2)$ additions.



#### Les codes RDP


Les codes RDP conçus par \textcite{corbett2004fast} ont également une
contrainte géométrique telle que $k \leq w$. Ces codes sont similaires aux
\eo mais ne nécessitent pas d'ajusteur. Les informations du second disque de
parité sont également calculées en utilisant une parité diagonale. En
particulier, la diagonale spéciale précédemment utilisée pour calculer $S$
n'intervient pas dans ce calcul. En revanche, les informations du disque $\PP$
sont utilisées pour calculer les valeurs du disque $\QQ$, ce qui nécessite une
dépendance et une séquentialité dans la mise en œuvre de l'encodage. En
particulier, les codes RDP nécessitent moins d'opérations pour l'encodage, le
décodage et la mise à jour, que les codes de \rs et \eo.

Le nombre d'opérations nécessaires pour le calcul des informations de $\PP$ et de
$\QQ$ est identique et correspond à $(k-1)w$ additions. De manière similaire
aux \eo, le coût de la mise à jour d'un bloc dépend de la position du bloc.
Lorsque celui ci est situé sur la première ligne ou sur la diagonale spéciale,
seulement deux blocs de parité sont impactés sur $\PP$ et $\QQ$ respectivement. En
conséquence, trois opérations sont nécessaires. Dans tous les autres cas, trois
blocs sont impactés du fait de l'interdépendance entre les disques de parité.
La reconstruction d'un disque de données est quant à elle réalisée en $(k-1)w$
opérations quel que soit le disque de parité utilisé. En conséquence, $2(k-1)$
opérations sont nécessaires pour reconstruire l'information lorsque deux
disques sont en panne.



### Le code Mojette {#sec.eval.xor}

\begin{figure}[t]
    \centering
    \def\svgwidth{.7\textwidth}
    \includesvg{img/mojette_raid6_2}
    \caption{Code à effacement Mojette d'une image $(3 \times 3)$ pour les
    directions $\{(p,q)\}$ dans l'ensemble $\{(-1,1),(0,1),(1,1)\}$. La base
    utilisée est représentée par $\vec{u}$ et $\vec{v}$. $\PP$, $\QQ$, et $\PP'$
    correspondent à des disques de parité.}
    \label{fig.mojette_raid6}
\end{figure}

Dans la représentation des codes $(k+2,k)$, le code à effacement Mojette, sous
forme systématique, calcule deux projections à partir d'une grille de hauteur
$k$. Il est ainsi possible de reconstruire deux lignes de la grille à partir de
ces projections. Le choix des directions de projection sera motivé par la
réduction du coup de la redondance. On choisira ainsi comme ensemble de
projections $\{(p,q)\}$ = $\{((0,1),(\pm{1},1)\}$, où le disque $\PP$ contiendra
les éléments de projections suivant la direction $(0,1)$, et $\QQ$ suivant
$(\pm{1},1)$.
La \cref{fig.mojette_raid6} montre cette représentation pour une grille $(3
\times 3)$. En particulier le choix du signe pour la valeur de $p_Q$ n'a pas
d'impact ni sur la complexité des opérations, ni sur le coût de la redondance.

Pour l'encodage, le nombre d'opérations nécessaires pour le calcul d'une
projection dépend de la taille de la grille et de la direction de projection.
On le définit ainsi :

\begin{equation}
    \gamma(k,w)^{(p,q)} = k \times w - B(k,w,p,q),
    \label{eqn.xor_enc}
\end{equation}

\noindent où $B(k,w,p,q)$ correspond au nombre de bins de la projection (voir
\cref{eqn.nombre_bins}). Puisque le disque $\PP$ correspond à la projection
suivant l'horizontal : le nombre de bin $B(k,w,0,1) = w$. Le calcul de cette
projection nécessite alors $(k-1)w$ opérations. Le nombre d'opérations pour le
disque $\QQ$ correspond quant à lui à $(k-1)w - k + 1$. On remarque ici que pour
la première fois, le nombre d'opérations nécessaires est inférieur pour
calculer le disque $\QQ$ que pour le disque $\PP$. On peut également noter que si
l'on utilise le disque $\PP'$ (correspondant à la projection suivant la
direction $(-1,1)$) à la place du disque $\PP$, on réduit le nombre
d'opérations global au prix d'un coût de redondance plus élevé.

Les mises à jour dans le cas du code Mojette sont optimaux. En effet, la
modification d'un bloc de donnée impacte uniquement un bloc de parité
correspondant dans chaque disque. Dans le cas étudié, on modifie uniquement
deux bins quelque soit la position du pixel modifié.

% cependant la position du pixel entraînera plus ou moins

% d'opérations

\begin{figure}[t]
    \centering
    \def\svgwidth{.8\textwidth}
    \includesvg{img/dec_sys_mojette2}
    \caption{Représentation de la méthode de détermination du nombre
    d'opérations nécessaire pour reconstruire une ligne $l$ à partir d'une
    projection. Cet exemple représente une grille $(P=12,Q=6)$. On cherche à
    reconstruire la ligne $l=2$ à partir de la projection suivant la direction
    $(p=1,q=1)$. Les éléments en rouge représentent les éléments impliqués dans
    la reconstruction de la ligne.}
    \label{fig.dec_sys_mojette}
\end{figure}

Dans le cas de la perte d'un disque, il est cette fois plus avantageux de
reconstruire la donnée en utilisant le disque $\QQ$ qu'en utilisant le disque
$\PP$. 
Rappelons que le nombre d'opérations nécessaires à la reconstruction d'un pixel
dépend de sa position dans la grille. En effet, un pixel situé dans un coin de
la grille nécessitera en général moins d'opérations qu'un pixel situé au milieu
de la grille. De plus, ce nombre va dépendre de la projection utilisée pour la
reconstruction. Si l'on reprend l'exemple d'un pixel situé dans un coin de la
grille, aucune opération n'est nécessaire si $(p,q) \ne (0,0)$. En revanche, si
$(p,q)=(0,1)$, alors $(Q-1)$ opérations seront nécessaires.

%Lors du décodage en systématique, en cas d'effacement de la 

%donnée, on affecte la reconstruction d'une projection à 

%une ligne effacée de la grille. Comme vu précédemment dans

%\cref{sec.valeur_pxl}, la valeur du pixel à reconstruire dépend

%non seulement d'un bin $b$ dans la projection affectée, mais

%également de la somme des valeurs d'un ensemble d'éléments de

%la grille.

Soit $l$ l'index d'une ligne à reconstruire. La \cref{fig.dec_sys_mojette}
représente la situation où l'on souhaite reconstruire la ligne $l=2$ d'une
grille $(P=12,Q=8)$ en utilisant la projection suivant la direction
$(p=1,q=1)$. Les éléments de la grille en rouge représente les pixels utilisés
dans la reconstruction de la ligne $l$. Le nombre d'opérations nécessaires à la
reconstruction d'une ligne $l$ est défini par l'ensemble des pixels représentés
en rouge. Cet ensemble correspond aux éléments de la grille discrète (hors
éléments de la ligne $l$) contenus entre les deux droites de projection $y =
p_i x + l$ et $y = p_i x + l + P$, qui passent par les extrémités de la ligne
$l$. Dans le cas général, ce nombre correspond à la surface de la grille
$(P \times Q)$ à laquelle on soustrait le nombre d'éléments de la ligne à
reconstruire $P$, et auquel on soustrait la surface de deux triangles. Dans
l'exemple de la \cref{fig.dec_sys_mojette}, le triangle supérieur possède une
base et une hauteur de $l$, et le triangle inférieur possède une base et une
hauteur de $(Q-l)$. Le nombre d'opérations nécessaires pour reconstruire cette
ligne correspond à :

\begin{equation}
    \gamma(P,Q,l)^{(1,1)} = (Q-1)P 
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

La \cref{fig.decodeur_raid6} représente le nombre d'opérations
nécessaires pour reconstruire une ligne depuis la projection $(1,1)$ en fonction
de l'index de cette ligne. On peut remarquer le comportement quadratique de
cette courbe. En particulier, les lignes situées aux extrémités (i.e.\ $l=0$ et
$l=k-1$) nécessitent moins d'opérations pour être construites. En effet, la
surface des pixels impliqués dans la reconstruction est moins importante pour
ces lignes, alors qu'elle est maximale pour la ligne centrale. En particulier,
ces lignes bénéficient du fait qu'elles possèdent des pixels proches des coins
de la grille, et dont le nombre de dépendances est réduit.



\subsection*{Bilan et discussion}

\begin{table}
    \centering
    \resizebox{\columnwidth}{!}{%
        \input{removed/xor_table}
    }
    \caption{Tableau de comparaison du nombre d'opérations nécessaires pour
    différents code à effacement selon les métriques définies dans la
    \cref{sec.metriques}. Les paramètres $k$ et $w$ correspondent
    respectivement au nombre de disques de données, et au nombre de blocs
    qu'ils contiennent.}
    \label{tab.comparaison}
\end{table}

Le \cref{tab.comparaison} résume les résultats obtenus précédemment. On y exprime
le nombre d'opérations nécessaires pour chaque métrique détaillée en première
section, en fonction des différents codes. En particulier, on distingue les
métriques d'encodage et de décodage en fonction de l'utilisation du disque $\PP$
ou $\QQ$. On remarque que la génération ou la réparation relatives au disque
$\PP$ nécessite toujours $(k-1)w$ opérations. En effet, ce disque correspond à
la parité horizontale des disques de données. En revanche, le nombre
d'opérations nécessaires quand on interagit avec $\QQ$ forme un critère
intéressant puisque celui ci varie pour chaque code. Le critère de mis à jour
d'un bloc est également décisif et est optimal pour la Mojette. 

#### Les spécificités des codes de \rs

Les performances théoriques des codes de \rs sont compliquées à définir. En
effet, la multiplication dans les corps de \galois peut être
implémentée de différentes manières : par exemple \textcite{blaum1993tit}
proposent d'utiliser des permutations circulaires, \textcite{rizzo1997sigcomm}
propose des tables de correspondance et \textcite{blomer1995icsi} utilisent des
matrices binaires. C'est pourquoi dans le \cref{tab.comparaison}, nous
distinguons les opérations de multiplication des opérations d'addition en
utilisant le symbole $\otimes$.


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
d'additions pour calculer $\QQ$ que pour calculer $\PP$.

Côté reconstruction d'un disque en utilisant les données du disque de parité
$\QQ$, le même constat peut être fait. Les codes RDP nécessite encore $(k-1)w$
opérations. De manière similaire à l'encodage, les codes de \rs et \eo ont un
surcout calculatoire respectivement dû aux multiplications et au calcul de $S$.
Pour le code Mojette, le nombre d'opérations à réaliser dépend du disque
inaccessible (voir \cref{eqn.dec_sys_mojette}). Cependant, quel que soit le
disque inaccessible, sa reconstruction par le disque $\QQ$ nécessitera toujours
un nombre d'opérations inférieur à $(k-1)w$ comme le montre la
\cref{fig.decodeur_raid6}.

Quant aux mises à jour d'un bloc de données, bien que tous les codes sont
capables d'atteindre la meilleure performances de $3$ additions dans le
meilleur des cas, seul le code Mojette fournit ces performances quelle que
soit la position du bloc modifié.
En conclusion, les codes Mojette nécessitent moins d'opérations dans l'ensemble
des métriques étudiées par rapport aux codes MDS utilisés pour le stockage
distribué en RAID-6. Ceci se traduit par un gain en performance qui
nécessite toutefois une quantité de redondance supplémentaire. Nous avons
cependant montré dans le chapitre précédent que ce coût est modéré et tend vers
l'optimal quand la largeur de la grille augmente.


Bien que les performances théoriques sont liées par le nombre et la nature des
opérations réalisées durant l'encodage et le décodage, d'autres critères
entrent en jeu en pratique. Comme nous l'avons vu dans le chapitre précédent,
les opérations doivent être réalisées au plus près du processeur. Un autre
enjeu correspond à la localité spatiale de nos données. Cette considération
correspond à la caractéristique de notre algorithme à traiter les données de
manière séquentielle. L'intérêt d'un accès séquentiel aux données repose sur
deux considérations : (i) il n'est pas nécessaire de calculer la position de la
donnée et d'atteindre sa position (les disques durs mécaniques par exemple
perdent un temps considérable à déplacer les têtes de lecture pour accéder à
des données distantes); (ii) il est possible de charger en avance la donnée
pour la placer dans les zones mémoires près du processeur (c'est notamment
l'objectif de l'appel système *readahead* sur Linux). Bien qu'il soit possible
de favoriser ces comportements, il est compliqué de les quantifier. Dans le cas
du code à effacement Mojette, nous avons vu que la géométrie du problème permet
de favoriser la localité spatiale.



# Généralisation de la construction des codes {#sec.rsmoj}


## \rs

Les codes à effacement de \reed correspondent à des codes $(n,k)$ MDS, dont la
valeur des paramètres peut être arbitrairement choisie. En
particulier, cette application calcule $n$ mots encodés à partir de $k$ mots de
données tel que $k \geq n$. Pour cela, une matrice d'encodage de taille
$n \times k$ est utilisée pour la transformation. Pour définir un code MDS,
cette matrice doit nécessaire posséder la propriété suivante : toute
sous-matrice de taille $k \times k$ doit être inversible. À l'origine, une
matrice de \vander était utilisée puisque qu'elle possède une telle propriété.
\textcite{blomer1995icsi} ont par la suite utilisé des matrices de
\cauchy qui possèdent également cette propriété. En particulier, la complexité
d'inversion d'une matrice de \cauchy est $\mathcal{O}(k^2)$. Dans leurs
travaux, \textcite{blomer1995icsi} ont également proposé une représentation de
la matrice qui permet d'implémenter les opérations de multiplication par des
fonctions de OU-exclusif.


#### Vandermonde-RS

Les matrices de \vander $V$ permettent de générer de l'information redondante.
En particulier, cette matrice est définie par un vecteur de $n$ éléments
$\left( \alpha_0, \alpha_1, \dots, \alpha_{n-1} \right)$. Cette matrice est de
la forme :

\begin{equation}
    V = 
    \begin{pmatrix}
        1 & 1 & \cdots & 1 & 1 \\
        \alpha_0^1 & \alpha_1^1 & \cdots & \alpha_{k-2}^1 & \alpha_{k-1}^1 \\
        \alpha_0^2 & \alpha_1^2 & \cdots & \alpha_{k-2}^2 & \alpha_{k-1}^2 \\
        \vdots & \vdots & \ddots & \vdots & \vdots \\
        \alpha_0^{n-1} & \alpha_1^{n-1} & \cdots & \alpha_{k-2}^{n-1} &
            \alpha_{k-1}^{n-1} \\
    \end{pmatrix} \in F_q^{k \times n},
    \label{eqn.vander}
\end{equation}

\noindent où $\alpha_{i}$ correspondent aux coefficients d'une matrice de
\vander. Pour que l'ensemble des sous-matrices $k \times k$ soient
inversibles, il est nécessaire que les éléments $\alpha_i$ du corps fini soient
deux à deux distincts. Dans le cas d'un code de \rs non-sytématique, la matrice
d'encodage correspond à une matrice de \vander tel que $G=V$. Pour obtenir un
code de \rs systématique avec des paramètres $(n,k)$ arbitraire, il n'est pas
possible de construire une matrice d'encodage de la forme $G=[I_k | V]$ (comme
nous l'avons vu précédemment dans le cas particulier de RAID-6). Dans une telle
matrice, toute sous-matrice carrée n'est pas
inversible \cite{lacan2004letters}. On peut cependant obtenir un code de \rs
systématique à partir d'une matrice de \vander en appliquant un algorithme
d'élimination de \textsc{Gauss} sur les colonnes de $V$ afin de faire
apparaître une matrice identité. Cette méthode est décrite dans
\textcite{plank2003rs}. Une autre méthode est proposée par
\textcite{lacan2004letters}. Une fois que l'on a déterminé la matrice
d'encodage $G$, l'opération de codage correspond à calculer $Y = GX$.

N'importe quelle sous-matrice carrée $G'$ d'une matrice de \vander est
inversible (en particulier une sous-matrice $k \times k$). Cette
caractéristique des matrices de \vander permet d'inverse l'opération et
reconstruire l'information perdue. En particulier, si l'on considère un message
$X'$ de $k$ blocs, alors $Y' = G'X'$ où $Y'$ correspond à $k$ blocs encodés.
Quand l'information subit des effacements, les lignes correspondant dans la
matrice d'encodage sont supprimées pour donner une sous matrice $G'$ de taille
$(k \times k)$. L'inverse de cette matrice est déterminée afin de retrouver le
message initiale : $X = G'^{-1}Y'$. 
Considérons deux ensembles $i \in \ZZ_k$ et $j \in \ZZ_w$. Ainsi, $d_{i,j}$
correspond au bloc de donnée situé dans la colonne $i$ et à la ligne $j$. Dans
ce cas, les données d'un disque de parité $\mathcal{R}_j$ sont calculées ainsi :

\begin{equation}
    \mathcal{R}_j = \xor_{i=0}^{k-1}d_{i,j}\alpha^{i}.
    \label{eqn.rs_r}
\end{equation}

\noindent L'\cref{eqn.rs_r} montre que $(k-1)$ additions et $k$ multiplications
sont nécessaires pour calculer un bloc d'un disque de parité.

Les codes de \rs souffrent des multiplications de l'\cref{eqn.rs_r}
réalisées dans un corps de \galois. De nombreux travaux ont été
réalisés afin de produire des implémentations efficaces de l'opération de
multiplication. Par exemple, \textcite{blaum1993tit} ont proposé une
méthode pour remplacer ces multiplications par des opérations de soustractions
et de rotations cycliques. Par la suite, \textcite{rizzo1997sigcomm} a proposé
d'utiliser des tables de correspondance.

#### \cauchy-RS

Cette version des codes de \rs basée sur des matrices de \cauchy a été proposée
par \textcite{blomer1995icsi}. Un avantage de cette technique est de permettre
une inversion matricielle plus efficace en $\mathcal{O}(n^2)$. De
plus, les travaux de \citeauthor{blomer1995icsi} ont permis de remplacer les
opérations de multiplications par des additions. Pour cela, chaque élément de
la matrice d'encodage et étendu par $\beta$ dans les deux directions. Ses
performances sont ainsi liées au nombre de $1$ présents dans la matrice
d'encodage ou de décodage. Des travaux ont été menés afin de rendre les
matrices les plus creuses possible. En effet, étant donné les paramètres
$(n,k)$ d'un code défini dans un corps de \galois, il existe une quantité
importante de matrices de \cauchy permettant d'encoder l'information.
\textcite{plank2006nca} ont déterminé que
chaque matrice n'est pas égale en matière de performance. En particulier, 
si l'on souhaite trouver la meilleure matrice, il faut énumérer tous les
cas possibles, dont le nombre croît de manière exponentielle avec $n$. En
conséquence, cette méthode peut convenir pour des codes avec des paramètres
$(n,k,w)$ de faibles valeurs (e.g. $w \leq 4$).
\citeauthor{plank2006nca} donnent toutefois un algorithme pour déterminer
une « bonne » matrice de \cauchy. Cependant, le nombre de $1$ dépend des
ensembles d'éléments du corps de \galois choisis pour construire la matrice de
\cauchy. En conséquence, aucune méthode efficace n'existe aujourd'hui afin de
définir ce nombre minimum de $1$ dans la matrice d'encodage.

## Généralisation du code Mojette

### Performances de l'encodeur Mojette

Nous allons analyser le nombre d'opérations nécessaires pour le calcul d'une
projection.
Bien que la génération d'une projection met en jeu l'ensemble des
éléments de la grille discrète une et une seule fois (voir \cref{eqn.mojette}),
le nombre $\gamma$ d'opérations nécessaires pour l'encodage varie en fonction de
deux paramètres : la taille de la grille, et la direction de projection.
Le nombre d'additions nécessaires pour générer une projection
$\text{Proj}_{f}(p,q,b)$ correspond à :

\begin{equation}
    \begin{aligned}
        \gamma(P,Q)^{(p,q)} &= P \times Q - B(P,Q,p,q), \\
                    &= P \times Q - \left((Q-1)|p|+(P-1)|q|+1\right),
    \end{aligned}
    \label{eqn.enc_mojette}
\end{equation}

\noindent et représente le nombre d'éléments de la grille discrète ($P \times
Q$) auquel on soustrait le nombre de bins de la projection, tel que défini dans
\cref{eqn.nombre_bins}. Considérons à présent que l'on fixe la taille de la
grille, ainsi qu'un paramètre de projection. Si l'on considère comme
précédemment que $q_i=1$ :

\begin{align}
    \gamma(P,Q)^{(p,1)} &= P \times Q - ((Q-1)|p| + P), \\
                            &= (Q-1) (P - |p|).
    \label{eqn.enc_mojette_q}
\end{align}

\noindent En conséquence, quand les dimensions de la grille sont fixées, si la
valeur de $|p|$ augmente, le nombre d'opérations nécessaires pour générer
une projection $\gamma(P,Q)^{(p,q)}$ diminue. Cela signifie que pour une taille
de grille fixée, plus une projection est grande, moins elle nécessite
d'opérations d'addition pour être calculée.
En conséquence, si seules les performances sont essentielles pour
une application, on choisira des projections avec de grandes valeurs de $|p|$.
Pour un ensemble de projections $\{(p_i,1)\}$ donné, l'ensemble des opérations
nécessaire pour l'encodage correspond à $\sum\limits_i \gamma(P,Q)^{\{(p_i,1)\}}$.


% ### Performances du décodeur Mojette non-systématique


% ajouter le cas de l'algorithme dim'dim

% Nous comparerons ici deux algorithmes. Le premier correspond

% à l'algorithme de

% Le second correspond à un cas particulier

% de l'algorithme de reconstruction systématique, dans le cas où 

% toutes les lignes de la grille ont été effacées.

%Nous prendrons comme sujet d'étude, l'algorithme de

%reconstruction BMI défini par \textcite{normand2006dgci}.

% Dans cet algorithme, les opérations réalisées correspondent à

%: (i) la reconstruction de $(P \times Q)$ pixels; (ii) la mise

%à jour de l'ensemble des $k$

%de chaque projection liés à chaque pixel

%reconstruit. En conséquence, 

%il est nécessaire de réaliser $P \times Q \times Q$

%additions pour reconstruire la grille entière.


### Performances du décodeur systématique

Le nombre d'opérations nécessaires $\gamma(k,w,l)$ pour reconstruire un pixel
d'index $i$ depuis une projection de direction $(p,1)$ est défini par :

\begin{equation}
    \gamma(k,w)_i^{(p,1)} = \left [
        \sum_{a=0}^{w-1}
            \sum_{b=0}^{k-1}
                \Delta\left(i+a-(b \times |p| \right)
        \right ] -1.
    \label{eqn.mojette_decoding}
\end{equation}

\noindent En conséquence, le nombre d'opérations nécessaires pour reconstruire
une ligne d'index $l$ correspond à la somme des valeurs calculées à partir de
l'\cref{eqn.mojette_decoding} pour chaque pixel de la ligne :

\begin{equation}
    \gamma(k,w)_{l}^{(p,1)} =
        \sum_{i=l-w+1}^{i=l} \left( \gamma(k,w)_{i}^{(p,1)}\right).
    \label{eqn.mojette_decoding2}
\end{equation}

Dans le cas où $e$ lignes sont effacées, le nombre total d'opérations
nécessaires correspond à la somme des opérations nécessaires pour chaque ligne.
Dans ce cas, une projection différente, issue d'un ensemble suffisant
$\{(p_i,1)\} \mid i \in \ZZ_e$, est associé à la reconstruction d'une ligne.
On détermine alors le nombre d'opération nécessaire ainsi :

\begin{equation}
    \gamma(k,w)_e^{\{(p_e,1)\}} =
        \sum_{e} \left( \gamma(k,w)_{l_e}^{(p_e,1)}\right).
    \label{eqn.mojette_decoding3}
\end{equation}



# Expérimentations {#sec.eval.perf}

Dans cette section, nous évaluons les performances du code à effacement
Mojette et comparons ces résultats avec les performances des meilleures
implémentations des codes de \rs.
Nous détaillons en \cref{sec.implem} les caractéristiques des implémentations
étudiées. La \cref{sec.expe} présente la mise en œuvre de l'expérimentation
pour permettre le calcul des performances de ces implémentations. Enfin, nous
verrons dans la dernière \cref{sec.expe.resultat} les résultats que nous
analyserons.

## Les implémentations à comparer {#sec.implem}

Nous avons choisi de comparer les implémentations du code à effacement Mojette
avec une implémentation des codes de \rs. De par leur popularité et
leur accessibilité, les codes de \rs représentent un compétiteur 
essentiel pour notre comparaison. Ces codes sont en effet largement
distribués à travers de nombreuses bibliothèques.

### Implémentations Mojette

Nous avons implémenté une version systématique du code à effacement Mojette en
langage C. Le choix de ce langage est judicieux lorsque l'on développe une
technique de codage devant fournir de hautes performances.
En effet la possibilité de laisser la gestion mémoire à l'utilisateur, ainsi
que le recours à diverses instructions particulières du processeur, permettent
d'atteindre d'excellentes performances \cite{hundt2011sd}.

Dans la suite, nous reprenons la terminologie utilisée dans le
\cref{sec.chap2}. En pratique, la taille des pixels et des bins doivent
correspondre à un mot machine.
Un mot correspond à l'unité de base, exprimée en bits, manipulée par
un processeur. Pour les architectures classiques, la taille d'un mot
correspond à $32$ ou $64$ bits. Il s'agit plus exactement de la taille des
registres du processeurs. En conséquence, un processeur est d'autant plus
rapide que ses mots sont longs puisqu'une plus grande quantité d'information
est traitée à chaque cycle. Nous avons alors fixé la taille des bins
et pixels à $64$ bits. Cette valeur correspond à la taille des registres des
architectures usuelles aujourd'hui.

La plupart des processeurs proposent des extensions de leur jeu d'instructions
afin d'améliorer les performances de certains traitements. Les instructions
*Single Instruction, Multiple Data* (SIMD) correspondent à un mode de
fonctionnement du processeur qui permet de profiter de parallélisme. Plus
particulièrement, il s'agit d'appliquer en parallèle la même instruction sur
plusieurs données afin d'obtenir plusieurs résultats. Bien que proposées par
\citeauthor{flynn1972toc} en 1966 et utilisées pour la première fois dans le
supercalculateur \textsc{Cray-1} en 1976, les instructions SIMD ne seront
seulement disponibles dans les processeurs grand public d'\intel et
\textsc{AMD} qu'à partir de 1997.
Les processeurs \intel par exemple, proposent des extensions pour flux SIMD
(*Streaming SIMD Extensions* SSE) qui ajoutent jusqu'à 16 registres de 128 bits
et 70 instructions supplémentaires pour les processeurs x86. Ce mode de
fonctionnement permet donc de traiter $2048$ octets en parallèle, en un cycle
processeur. Les applications peuvent alors bénéficier de cela dès lors qu'une
instruction peut être réalisée sur plusieurs données. En pratique, ce mode est
largement utilisé dans les applications multimédias, scientifiques ou
financières. Dans le stockage, il permet notamment d'augmenter les performances
de traitement du RAID logiciel implémenté dans Linux en réalisant plusieurs
instructions en parallèle \cite{anvin2004raid}.

Ce mode de fonctionnement est donc très intéressant pour notre code à
effacement étant donné que la quantité de données traitées pour un cycle CPU
est cruciale dans les systèmes d'information. Les algorithmes d'encodage et de
décodage Mojette sont propices à ce fonctionnement puisque nous appliquons une
instruction, qui correspond à l'addition, sur une multitude de données,
représentées par les éléments de la grille discrète et des projections. En
conséquence, dans notre mise en œuvre, l'addition est implémentée par des
opérations de OU exclusif (XOR), correspondant à des additions modulo deux, sur
des données de $128$ bits.

Dans cette partie, nous allons comparer les débits observés dans une évaluation
des performances d'encodage et et de décodage des deux implémentations de notre
code à effacement Mojette et des codes de \rs. En particulier pour le code
Mojette, nous évaluerons la version non-systématique, que l'on appellera
*NS-Mojette*, ainsi que l'implémentation systématique que l'on désignera
simplement par *Mojette*.

### Implémentation des codes \rs

ISA-L (pour *\intel Storage Acceleration Library*) est une bibliothèques
*open-source* développée par \textcite{intel2015isal} fournissant une
implémentation des codes de \rs. En particulier, cette bibliothèque fournit des
codes optimisée pour les applications de stockage. Dans
la limite de notre expérience orientée dans le contexte du stockage, et des
paramètres utilisés dans notre expérimentation, cette
implémentation fournit de meilleurs résultats que d'autres bibliothèques
fournissant des codes pour de la transmission, telles que \citetitle{openfec}
et \textsc{Jerasure} \cite{openfec,plank2014jerasure}.
En particulier, cette implémentation des codes de \rs utilise le polynôme
irréductible $x^8+x^4+x^3+x^2+1$. Pour les opérations de multiplication, des
instructions spécifiques aux architectures *x86* sont utilisées afin de
réaliser efficacement les nécessaires dans les codes de \rs
\cite{gueron2014intel}.

## Configuration de l'expérimentation {#sec.expe}

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
décodage des implémentations des codes à effacement Mojette et \rs,
présentés précédemment. Ces tests sont réalisés sur un seul processeur.

Les tests réalisés dans cette partie mettent en jeu plusieurs paramètres. Ainsi
nous allons faire varier les paramètres $n$ et $k$ des codes à effacement, qui
définissent implicitement la tolérance aux pannes que fournit le code. En
pratique, ce facteur dépend de la nature des données, des applications et du
support sur lequel transite la donnée. Les fournisseurs de service web
proposent en général une protection face à quatre pannes. C'est le cas de
\textsc{Facebook}, qui utilise des codes de \rs au sein de leurs grappes de
stockage \cite{sathiamoorthy2013vldb}. Un second paramètre concerne la taille
des données $\mathcal{M}$ que nous allons traiter. Dans la terminologie
Mojette, cette taille correspond au nombre de pixels de la grille discrète. Ce
paramètre dépend de l'application utilisée. Dans le cadre de stockage de
données POSIX, on choisira une taille $\mathcal{M}$ correspondante à la taille
des blocs du système de fichiers. Dans l'exemple d'*ext4*, cette taille de
blocs est de $4$ Ko. En revanche, dans des applications mettant en jeu des
accès séquentiels sur de grands fichiers, on choisira une taille de bloc
beaucoup plus importante afin de limiter le nombre d'entrées/sorties. C'est le
cas du système de fichiers *Hadoop Distributed File Systems* HDFS, qui met en
jeu des applications d'analyse parallèle grâce à *Hadoop Map-Reduce* sur des
blocs de *128* Mo par défaut \cite{shvachko2010msst}.

La \cref{fig.expe_code} représente l'expérimentation que l'on réalise.
Notre mesure lors de l'encodage corresponde
aux performances du CPU lors de la génération de $n$ blocs encodés à
partir de $k$ blocs de données. Ces $k$ blocs totalisent $\mathcal{M}$ octets.
Plus particulièrement dans notre mise en œuvre, ces $k$ blocs correspondent à
une zone mémoire de $\mathcal{M}$ octets de données aléatoire, dont on
représente chaque bloc par $k$ pointeurs vers l'adresse de début de ces blocs.
L'encodage non systématique consiste alors à la génération de $n$ blocs de
données encodés à partir de ces données d'entrées. En revanche, pour les
versions systématiques, l'encodage correspond aux opérations suivantes : (i)
copie des $k$ blocs de données; (ii) puis génération de $(n-k)$ blocs de
parité. Le critère de comparaison de performance entre les différents codes
correspond donc à l'effort du CPU pour offrir une certaine tolérance aux
pannes.

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
ne pas créer d'interactions avec le disque dur. Plus exactement, nous ne
considérons pas certains pré-traitements tels que la génération des matrices
d'encodage dans le cas des codes de \rs, ou la détermination du chemin
de reconstruction dans le cas des codes Mojette.

Puisque l'on mesure des fonctions d'encodage et de décodage hautement
optimisées pour nos architectures processeurs dont les temps d'exécution sont
de l'ordre de la nanoseconde, il est imprécis, voire impossible, de mesurer le
temps d'exécution de ces fonctions de nos implémentations. En revanche, puisque
ces calculs sont bornées par les considérations vues dans la partie
précédentes, et puisque nos instructions sur réalisées au sein d'un *thread*
sur un processeur, il est possible d'obtenir une mesure sur le nombre de cycles
du processeur. Plus précisément, on utilise le compteur temporel (*Time Stamp
Counter* TSC) qui est un registre spécial qui s'incrémente à chaque cycle CPU.
Pour cela, on utilise l'instruction *ReaD Time Stamp Counter* (ou RDTSC) qui
permet de récupérer la valeur de ce registre. Il suffit alors d'enregistrer sa
valeur avant et après nos fonctions d'encodage et de décodage et d'afficher la
différence. \intel propose une mise en œuvre afin de filtrer les résultats
aberrants \cite{intel1997rdtsc}.

Enfin, nous affichons la valeur moyenne qui résulte de $100$ itérations.
L'écart type n'est pas présenté puisqu'il est trop négligeable (et correspond à
moins d'un pour-cent des valeurs présentées). La machine utilisée provient de
la plate-forme *FEC4Cloud* située à Polytech Nantes. Cette machine dispose d'un
processeur \intel Xeon à $1,80$GHz, de $16$Go de mémoire RAM et de caches
processeurs de $128$Ko, $1$Mo et $10$Mo pour les niveaux *L1*, *L2* et *L3*
respectivement. Notons que cette plate-forme a été utilisée dans des
expérimentations soumises à plusieurs publications \cite{pertin2014eurosys,
pertin2015corr, parrein2015ressi}.

## Résultats de l'expérimentation {#sec.expe.resultat}

### Performances à l'encodage

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
    \rs sont comparées par le nombre de cycles CPU nécessaires pour
    réaliser l'opération d'encodage (plus le résultat est petit, plus il est
    bon). Deux paramètres de codage ont été utilisés: $(6,4)$ et $(12,8)$. Les
    performances optimales sont représentées par « no coding ».}
    \label{fig.encoding}
\end{figure}

Nous analysons dans cette partie les résultats à l'issu de notre
expérimentation sur les performances d'encodage correspondant au nombre de
cycles CPU nécessaires pour encoder la donnée. Les 
\cref{fig.encoding4k,fig.encoding8k} montrent les résultats obtenus pour
des tailles de blocs $\mathcal{M}$ équivalent à $4096$ et $8192$ octets
respectivement. Nous avons représenté en hachuré sur ces courbes, les
performances optimales obtenues par une opération équivalente sans encodage.
Plus précisément, ces performances correspondent à la copie de $n$ blocs de
données. Dans le cas où $\mathcal{M}$ vaut $4$Ko, cette opération correspond à
copier $6$Ko. Pour une taille de bloc de $\mathcal{M}=8$Ko, les performances
optimaux représentées correspondent à la copie de $12$Ko de données. Dans notre
expérimentation, cette opération de copie de cette information est implémentée
à partir de la fonction *memcpy()* de la bibliothèque standard du C.

La première observation générale que l'on peut faire sur ces courbes d'encodage
est que les performances de la Mojette non-systématique sont comparables à
celles fournies par l'implémentation des codes de \rs d'ISA-L. Plus
précisément, ces derniers sont moins performants lors de trois tests sur
quatre (la tendance s'inverse dans le test $(12,8)$ présenté dans la 
\cref{fig.encoding8k}). En réalité, il est important de rappeler que cette
implémentation du code Mojette doit calculer trois fois plus de données que les
autres implémentations testées dans notre expérimentation. En effet, puisque
cette version est non-systématique, elle doit calculer $12$ projections Mojette
dans le cas d'un code $(12,8)$, tandis que le code de \rs doit
calculer seulement $4$ blocs de parité. On observe cependant dans le cas du
test de la \cref{fig.encoding4k}, qu'il nécessite plus de $30$\% de cycles
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
Mojette $(6,4)$ sur des blocs de $4$Ko, présentés dans la
\cref{fig.encoding4k}, on observe que $(705-321) \times 3 = 1152$, où $321$
correspond aux nombres de cycles CPU nécessaires pour copier $4096$ octets, et
où $1152$ correspond à la valeur observée dans les résultats de la version
non-systématique de la même courbe. Ces résultats nous permettent donc de
valider que l'encodage systématique est trois fois plus performant que
l'encodage non-systématique dans le cas où nos codes sont paramétrés sur un
taux $r=\frac{3}{2}$.

En conséquence, nos courbes de résultats montrent que pour les paramètres
choisis dans nos expériences, l'encodage de l'implémentation non-systématique
offre des performances comparables à la meilleure implémentation des codes de
\rs développée par \intel. De plus, la version systématique du code
Mojette que nous avons développée offre des performances d'encodage largement
supérieures à ce que proposent les autres codes utilisés dans nos tests. En
particulier, les résultats atteint par notre nouvelle mise en œuvre sont
proches des résultats optimaux correspondant à la copie de l'information, sans
opération d'encodage. Ceci montre que le surcout calculatoire de cette nouvelle
version est particulièrement réduit.


### Performances au décodage

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
    \ref{named2}
    \caption{Comparaison des performances de décodage pour des paramètres de
    codes $(6,4)$ (\cref{fig.decoding_4k_l1,fig.decoding_8k_l1}) et $(12,8)$
    (\cref{fig.decoding_4k_l2,fig.decoding_8k_l2}). Les courbes à gauche
    montrent les résultats pour des tailles de blocs de $4$Ko
    (\cref{fig.decoding_4k_l1,fig.decoding_4k_l2}) tandis que les courbes de
    droite concernent des blocs de $8$Ko
    (\cref{fig.decoding_8k_l1,fig.decoding_8k_l2}). Les performances des codes
    Mojette et \rs sont comparées par le nombre de cycles CPU enregistré durant
    l'opération de décodage (plus c'est bas, mieux c'est) alors que l'on
    augmente progressivement le nombre d'effacement. Un effacement correspond à
    la perte d'un bloc encodé. Les valeurs optimales sont représentées par « No
    coding ».}
    \label{fig:decoding}
\end{figure}

Nous analysons dans cette partie les résultats à l'issu de notre
expérimentation sur les performances de décodage en matière de cycles CPU
nécessaires pour reconstruire la donnée initiale. Les
\cref{fig.decoding_4k_l1,fig.decoding_8k_l1} donnent le nombre de cycles CPU
nécessaires pour le décodage des codes $(6,4)$ pour des blocs de $4$Ko et $8$Ko
respectivement.
De manière similaire, les \cref{fig.decoding_4k_l2,fig.decoding_8k_l2}
concernent des codes $(12,8)$. Nous avons représenté sur ces courbes les
performances optimales de décodage correspondant à la copie de $k$ blocs
d'information.

La première observation générale que l'on peut faire concerne le cas où aucun
effacement ne survient lors du décodage. Dans ce cas, les deux codes
systématiques Mojette et \rs atteignent les performances optimales
représentées sur nos courbes par « no coding ». Ce résultat était attendu puisque
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
nombre d'opérations est comparable quel que soit l'ensemble des blocs encodés
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
Mojette sont plus coûteuses que la copie utilisée dans *memcpy()*, les
performances décroissent.

Notons cependant que malgré la baisse de performances du décodage observée
lorsque l'on augmente le nombre d'effacement pour le code systématique Mojette,
les valeurs enregistrées sont d'une part toujours meilleures que celles
observées pour la version non systématique (puisqu'il s'agit du cas où la
grille doit être entièrement reconstruite). D'autre part, ces performances sont
significativement meilleures que les performances observées par
l'implémentation systématique des codes de \rs.

% ### Influence de la tolérance aux pannes

% ### Impact de la taille des blocs




\section*{Conclusion}

Nous avons vu dans ce chapitre une évaluation théorique des performances du
code à effacement Mojette sous sa forme systématique, dans le contexte du
stockage distribué. Pour cela, nous avons défini trois métriques : (i)
le nombre d'opérations nécessaires à l'encodage; (ii) le nombre de blocs
modifiés lors d'une mise à jour; (iii) le nombre d'opérations nécessaires au
décodage. En particulier, nous avons montré que le code à effacement Mojette
nécessite moins d'opérations dans ces trois métriques, comparé aux *Array*
codes et codes de \rs, dans un contexte RAID-6 où la tolérance aux pannes est
limitée à deux (i.e.\ paramètres de code $(k+2,k)$). Par la suite, nous avons
étendu le même constat pour des paramètres de code $(n,k)$ arbitraires, en
comparant les codes Mojette et \rs. Dans une dernière section, nous avons
évalué par la pratique les performances de notre implémentation. En
particulier, notre expérimentation a permis de montrer le gain significatif de
notre nouvelle mise en œuvre du code systématique par rapport à la version
non-systématique. De plus, dans les cadres de notre expérimentation, notre
implémentation obtient de meilleurs résultats en encodage et décodage que
l'implémentation des codes de \rs contenue dans la bibliothèque développée par
\textcite{intel2015isal}.

Rappelons cependant que les bonnes performances obtenues par le code à
effacement Mojette nécessitent davantage d'information encodée que ce qui est
produit dans le cas des codes MDS. Toutefois, nous avons montré dans le
\cref{sec.chap3} que ce coût est modéré, et tend vers la borne minimale quand
la taille des blocs augmente.

Ce chapitre a permis de mettre en avant le fait que le code a effacement
Mojette est suffisamment efficace pour ne pas former un goulot d'étranglement
dans la chaîne de transmission des données. Dans le chapitre suivant, nous
allons nous intéresser à l'intégration de ce code au sein d'un système de
stockage distribué.
