
Ce chapitre résume l'ensemble des contributions abordées dans cette thèse, à
savoir : l'évaluation des codes à effacement, la conception d'une version
systématique du code Mojette, son intégration dans RozoFS, ainsi que
l'élaboration d'une méthode de reprojection sans reconstruction. Pour chacune
des contributions détaillées dans la suite, des perspectives sont proposées.

<!--
Ce chapitre présente mes contributions ainsi que des pistes pour les
travaux futurs. Une conclusion générale permettra de résumer les travaux
présentés dans ce manuscrit.
-->

\section{Comparaison et évaluation des codes}

%\addcontentsline{toc}{section}{Évaluation des codes}

Au cours de ce manuscrit, nous avons comparé les codes à effacement
étudiés avec notre code à effacement Mojette proposé.
Les évaluations théoriques menées dans le \cref{sec.chap3} ont
permis de montrer que l'algorithme itératif utilisé par ce dernier, nécessite
moins d'opérations en encodage et en décodage, par rapport aux *Array* codes
dans le cas du RAID-6, et aux codes de \rs dans le cas général.
Les résultats obtenus lors de l'évaluation expérimentale appuient ce constat
dans le\ \cref{sec.chap4}. En effet, nous avons montré que notre
implémentation du code Mojette encode l'information deux fois plus rapidement
que l'encodeur fourni dans ISA-L. Par ailleurs, le gain en décodage peut
atteindre un facteur $3$ dans les conditions de notre expérimentation. Ce gain
de performance nécessite toutefois un rendement sous-optimal, dû à la géométrie
de la transformation Mojette, dont les projections ont des tailles variables.
Malgré cela, nous avons montré dans le \cref{sec.chap3}, que le rendement de
notre version du code Mojette tend vers le rendement optimal des codes MDS
quand la largeur de la grille augmente. En conséquence, on observe un très
faible surcout de $3$\% avec blocs de données de $4$ Ko (taille utilisée en
pratique), par rapport aux codes MDS, ce qui est négligeable pour un NDSS.

Plus particulièrement, nous avons proposé une liste de critères
(cf.\ \cpageref{sec.criteres}), permettant de distinguer les codes à effacement
linéaires entre eux (e.g.\ critères sur la complexité théorique, l'indépendance
des paramètres, ou les débits de l'implémentation). Après avoir observé
qu'aucun code de l'état de l'art ne parvenait à répondre à l'ensemble des
critères, nous avons montré que le code Mojette est le plus apte à les
satisfaire.

<!--
Ces critères ne peuvent indépendamment permettre de
comparer les codes, mais ils permettent ensemble de couvrir l'ensemble des
propriétés des codes linéaires. Nous avons par ailleurs vu que chaque code
favorise un aspect de ces critères, mais aucun ne peut les satisfaire
entièrement.
-->

#### Perspective de travail : explorer les liens entre les codes.

De fortes connexions existent entre les codes FRT et les codes de \rs. Nous
avons notamment vu que ces deux codes sont obtenus par une matrice
de \vander\ \cite{normand2010wcnc}. Bien que
dans le cas des codes de \rs, les coefficients de cette matrice correspondent
à des éléments du corps fini, il s'agit dans le cas des codes FRT de monômes
dont le degré caractérise une permutation cyclique. Une étude plus poussée des
relations entre ces deux codes permettrait d'adapter des algorithmes aux deux
formalismes.

De même, le code Mojette partage des liens avec les codes LDPC. En particulier,
les deux codes utilisent un algorithme itératif pour l'opération de décodage.
Bien que dans le cas des codes LDPC, cet algorithme puisse être bloqué avant
d'avoir fini, dans le cas Mojette, le critère de \katz est un moyen efficace
pour garantir la capacité de l'algorithme à reconstruire exactement
l'information initiale. En conséquence, il est possible que le code Mojette
corresponde à une structure particulière des codes LDPC.

<!--
% Mojette non-systématique
% moins d'opérations, ok
% presque MDS
-->

\section{Code à effacement Mojette systématique}

<!--
% Mojette systématique
% encore moins d'opération -> plus performant
% encore plus MDS

%\addcontentsline{toc}{section}{Code à effacement Mojette systématique}
-->

Partant du principe que la transformation Mojette n'est pas MDS, nous nous
sommes intéressés à réduire la quantité de redondance qu'elle génère.
Pour cela, nous avons conçu une version du code Mojette sous sa forme
systématique, et avons proposé un algorithme de décodage approprié.
Par ailleurs, nous avons montré que la construction de cette version
systématique est simple et immédiate, ce qui n'est pas le cas par exemple des
codes de \rs.

Par sa conception hybride (projections et message), le code Mojette systématique
s'approche davantage de l'optimal MDS que sa version non-systématique. Cette
amélioration, évaluée dans le \cref{sec.chap3}, montre que le code est ainsi
quasi-MDS.

Un second aspect de cette conception est la réduction du nombre d'opérations
nécessaires lors de l'encodage. Cette réduction provient de l'intégration des
symboles sources dans le mot de code (c'est de la donnée en moins à calculer).
Cette construction permet par exemple de réduire par trois, le nombre de
projections à calculer pendant l'encodage d'un code de rendement $\frac{2}{3}$.
Par ailleurs, une analyse du nombre d'opérations a permis de montrer que cette
construction permet au code de réaliser moins d'opérations en décodage,
accélérant ainsi la vitesse de reconstruction.

Ces deux propriétés ont fait l'objet d'une publication
\cite{pertin2015sifwict}. Depuis, une implémentation du code Mojette
systématique a été réalisée, et les améliorations introduites précédemment en
théorie, ont été vérifiées par une évaluation dans le \cref{sec.chap4}. En
conséquence la forme systématique permet au code Mojette de fournir de
meilleures performances que les autres codes, tout en améliorant son rendement.
Ces éléments permettent de confirmer le choix de ce code performant pour
améliorer la vitesse de transmission dans un système de communication protégé
par du code à effacement.

#### Perspective de travail : code Mojette non-systématique et confidentialité.

Bien que dans le cas de la gestion des données chaudes, nous nous intéressons
principalement aux performances du code (améliorées par la version
systématique), d'autres considérations peuvent
être prises en compte. En particulier, les problématiques de confidentialité
peuvent motiver le choix de la version non-systématique.

Une première approche concerne la distribution des données exclusivement sous
la forme de projections. Dans ce cas, l'ensemble de la donnée n'est pas
disponible en clair par un tiers malveillant.
Toutefois, dans le cas du code Mojette, certaines parties de l'information sont
disponibles en clair (typiquement les coins de la grille), et peuvent
participer à déterminer des connaissances a priori, facilitant
l'attaque, telles que la nature du document (e.g.\ texte, image), ou la langue
d'un fichier texte.

Une seconde approche consiste à tirer profit de la propagation d'information de
l'algorithme de reconstruction, pour chiffrer efficacement les blocs
d'information. Plus précisément, il suffit de chiffrer les premiers bins des
projections pour protéger l'information contenue dans la grille. Cet aspect,
est étudié de manière préalable dans \cite{guedon2009mojettebook}. En
comparaison, la version systématique nécessite de chiffrer l'ensemble des
symboles de la partie systématique (ce qui nécessite beaucoup plus
d'opérations). Cette considération présente un exemple où la version
non-systématique est plus performante.


\section{Rôle et impact du code Mojette dans RozoFS}

%\addcontentsline{toc}{section}{Rôle et impact du code Mojette dans RozoFS}

Les bonnes performances des implémentations du code Mojette nous ont motivé à
l'intégrer dans le système de fichiers distribué RozoFS. Nous avons ainsi
montré dans le \cref{sec.chap5}, qu'en plaçant le code au niveau des clients,
il est possible de distribuer le calcul des projections, afin de ne pas
surcharger le serveur de stockage. Ce choix permet également de
profiter de l'envoi en parallèle des projections sur plusieurs liens réseau.
Nous avons alors fourni une évaluation des performances de RozoFS par rapport à
CephFS (réglé en mode réplication des données), à partir de la plate-forme
Grid'5000. Cette évaluation montre que RozoFS est capable de fournir de
meilleures performances qu'un système basé sur de la réplication, tout en
divisant par deux le coût du volume de données. RozoFS est ainsi le seul
système de fichiers distribué reposant sur un code à effacement, capable de
gérer à la fois des données froides et des données chaudes. Ces travaux ont
fait l'objet d'une publication à *CLOSER 2014*\ \cite{pertin2014closer}, et ont
depuis été soumis à la revue *Transactions on Storage*\ \cite{pertin2016tos}.


#### Perspective de travail : décentralisation des métadonnées.

Un aspect qui n'a pas été abordé dans nos travaux concerne la mise à l'échelle
de RozoFS. Premièrement, le serveur de métadonnées de RozoFS est un point de
défaillance unique (bien qu'en pratique, il est répliqué sur plusieurs
serveurs). Une première piste pour répondre à ce problème serait de distribuer
les métadonnées sous la forme de projections Mojette comme on le fait
actuellement pour les données. Cela nécessite en revanche un travail important
dans la conception de la gestion des métadonnées puisqu'il est nécessaire de
déterminer, à la manière de l'algorithme \textsc{Crush}\ \cite{weil2007phd} de
Ceph, l'ensemble des serveurs en charge des métadonnées, à partir d'une
information du fichier (e.g.\ identifiant unique, chemin de fichier).

Second problème, la centralisation des métadonnées implique un problème dans la
mise à l'échelle du système. En effet, le serveur de métadonnées reçoit
actuellement l'ensemble des requêtes. À mesure que le nombre de clients
augmente, la sollicitation du serveur peut engendrer un problème de ressources.
La distribution des métadonnées permettrait de décentraliser ce service et
d'harmoniser la charge sur un ensemble de serveurs. La thèse de Bastien
\textsc{Confais} (débutée en octobre 2015) traite ce sujet dans le contexte de
l'Internet des objets.


\section{Reprojection sans reconstruction}

%\addcontentsline{toc}{section}{Reprojection sans reconstruction}

Dans le dernier chapitre (cf.\ \cref{sec.chap6}), nous avons proposé un
algorithme distribué permettant de calculer de nouvelles projections sans
reconstruire la grille d'origine. Nous avons donné une évaluation de cette
méthode dans la \cref{sec.eval.reproj}, qui montre que la distribution des
calculs permet une réduction de la latence par un facteur $2$.
Cette contribution peut s'appliquer à la fois aux systèmes de stockage
distribués comme à un contexte réseau (*network coding*). Ces travaux ont fait
l'objet d'une publication à Reims Image\ \cite{pertin2014ri}.

#### Perspective de travail : réparation partielle des projections.

Jusque là, nous avons étudié les relations mathématiques entre
les projections et la grille. Cependant, il existe également des relations
entre les bins des projections. On peut notamment définir des groupes de bins
dont la somme des valeurs est nulle. Il est ainsi possible de déterminer la
valeur de certains bins, en utilisant cette définition, et par conséquent,
d'envisager de reconstruire des bins plutôt que des projections.
Cette solution a l'avantage de ne pas avoir à reconstruire la grille, ni la
projection entièrement.
La première difficulté consiste à déterminer l'ensemble des relations entre les
bins pour un ensemble de projections et une grille donnée. Un deuxième problème
consiste à déterminer s'il existe des groupes qui engendrent moins d'opérations
de reconstruction que d'autres, et comment les déterminer efficacement dans un
processus de réparation. Cet aspect correspond à des travaux en cours, en
collaboration avec Suayb \textsc{Arslan}, Professeur associé à la MEF
Université d'Istamboul.


<!--
\section*{Conclusion générale}

%\addcontentsline{toc}{section}{Conclusion générale}

Les travaux présentés dans ce manuscrit confirment le potentiel du code
par transformée Mojette à corriger efficacement les effacements.
Ce code s'est rapidement imposé dans ces travaux de thèse. La description
de la transformée Mojette a permis de comprendre comment concevoir un code à
effacement à partir d'une application mathématique simple. Car en effet, un
grand intérêt de cette transformée repose dans sa simplicité. Le fait qu'elle
ne repose que sur des opérations d'addition le prouve.
Ces opérations de base sont pratiques, aussi bien pour expliquer le principe de
cette transformée, que pour son application dans les processeurs (qui préfèrent
calculer des additions que des multiplications). Sa simplicité se retrouve
également dans l'opération de reconstruction, dont le principe rappelle celui
du jeu de Sudoku.

Nous avons ensuite décrit le code à effacement basé sur cette
transformée. Son principe découle de la capacité de la transformée à
pouvoir représenter de l'information de façon redondante. Par ailleurs, le
nombre de projections que l'on peut calculer n'est pas contraint, par rapport à
certains codes. En revanche, la limite du code Mojette repose sur la longueur
des projections qui augmente avec l'index de la projection. C'est pourtant
cette redondance interne aux projections qui permet d'utiliser l'algorithme
itératif de reconstruction.

% distinguer redondances dans mojette

Les codes de \rs et le code basé sur la FRT sont quant à eux MDS. Toutefois, au
vu des résultats théoriques et expérimentaux obtenus dans cette thèse, le code
Mojette est clairement plus performant que les codes de \rs. Pour s'en
convaincre, l'expérimentation nous a montré que la Mojette peut être jusqu'à
deux fois plus rapide en encodage, et trois fois plus rapide en décodage, par
rapport aux implémentations des codes \rs fournies dans ISA-L.
La relation avec les codes LDPC est intéressante et fera l'objet de travaux
futurs. Toutefois, on peut se prononcer sur une distinction principale, qui
réside dans la formulation du critère de \katz. Celui-ci permet au code Mojette
de garantir la reconstruction sur le critère du nombre de projections
disponibles.

Nous avons également prouvé que le coût de la redondance générée par le code
Mojette peut être diminué afin de s'approcher de la valeur optimale des codes
MDS. Nous avons ainsi proposé une représentation du code sous forme
systématique, qui a permis de réduire significativement ce coût.
Sa construction se distingue par ailleurs des mises en œuvre plus compliquées
dans le cas des codes de \rs. Au vu des résultats expérimentaux, les
performances mesurées prouvent que ni la version systématique, ni la version
non-systématique du code Mojette ne représentent un composant limitant dans un
système de communication. Toutefois, cette seconde version a des propriétés
intéressantes (e.g.\ équité des projections) qui peuvent la favoriser dans
certaines applications, ce qui va à l'encontre de la pensée communément admise
que les codes systématique sont forcément meilleurs.

Dans ces conditions, l'utilisation du code à effacement Mojette dans RozoFS
permet de distribuer efficacement des blocs de données sur différents supports
de stockage. L'expérimentation a permis de montrer que RozoFS est ainsi capable
de fournir de très hautes performances, tout en proposant un moyen de protéger
la donnée face aux pannes. En particulier, cette expérimentation met en avant
le fait que RozoFS est capable de gérer les données chaudes, et froides, tout
en divisant par deux le volume de stockage par rapport aux systèmes basés sur
de la réplication.

Pour finir, nous avons fourni une nouvelle méthode capable de calculer de
nouvelles projections, de façon distribuée, et sans reconstruire l'image
initiale. L'expérimentation de cette méthode a montré une réduction de la
latence de l'opération de reprojection par deux. Elle peut ainsi permettre de
rétablir efficacement la redondance d'un système de stockage, et s'inscrire
dans un mécanisme de support de stockage. Pour conclure, nous pouvons dire que
le code à effacement Mojette est parfaitement adapté pour garantir efficacement
la fiabilité des systèmes de communication.
-->
