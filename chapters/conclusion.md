
# Contributions et perspectives

Ce chapitre présente mes contributions ainsi que quelques pistes pour les
travaux futurs. Une conclusion générale permettra de résumer les travaux
présentés dans ce manuscrit.

## Évaluation des codes

% tableau chapitre 1

Au cours de ce manuscrit, nous avons tâché de comparer les codes à effacement
étudiés avec le code à effacement Mojette. Les évaluations théoriques ont
permis de montrer que l'algorithme itératif utilisé par ce dernier, nécessite
moins d'opérations en encodage et en décodage, par rapport aux *Array* codes
dans le cas du RAID-6, et aux codes de \rs dans le cas général.
Les résultats obtenus lors de l'évaluation expérimentale
appuient ce constat. Plus précisément, nous avons montré que notre
implémentation du code Mojette encode l'information deux fois plus rapidement
que l'encodeur fourni dans ISA-L. Par ailleurs, le gain en décodage peut
atteindre un facteur $3$ dans les conditions de notre expérimentation. Ce gain
de performance nécessite toutefois un rendement sous-optimal, dû à la géométrie
de la transformée Mojette qui génère de la redondance à l'intérieur des
symboles encodés. Malgré cela, nous avons montré à travers une analyse de cette
quantité, que le rendement Mojette tend vers le rendement optimal des codes MDS
quand la largeur de la grille augmente, et montre que ce rendement est
quasi-optimal.

Pour distinguer les codes, nous avons proposé une liste de critères
permettant de distinguer les codes à effacement linéaires.
Nos travaux ont montré que le code Mojette est le code le plus apte à
satisfaire ces critères. Par conséquent, il apparait alors comme le code le
plus efficace.

<!--
Ces critères ne peuvent indépendamment permettre de
comparer les codes, mais ils permettent ensemble de couvrir l'ensemble des
propriétés des codes linéaires. Nous avons par ailleurs vu que chaque code
favorise un aspect de ces critères, mais aucun ne peut les satisfaire
entièrement.
-->

#### Perspective de travail : Explorer les liens entre les codes

De fortes connexions existent entre les codes FRT et les codes de \rs. Nous
avons vu que ces deux codes sont obtenus par une matrice de \vander. Bien que
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


## Code à effacement Mojette systématique

Partant du principe que la transformation Mojette n'est pas MDS, nous nous
sommes intéressés à réduire la quantité de redondance générée. Pour cela, nous
avons fourni une description de la construction du code Mojette sous sa forme
systématique, ainsi qu'un algorithme de décodage approprié. Nous avons montré
que pour le code Mojette, la construction d'une version systématique est simple
et immédiate, par rapport aux codes de \rs. 

Un premier avantage de cette construction est la réduction de la quantité de
redondance dans les mots de code Mojette. Nous avons également fourni une
évaluation de cette quantité. Elle a montré que cette nouvelle conception
permet une convergence plus rapide du rendement Mojette, vers le rendement
optimal d'un code MDS (à mesure que la largeur de la grille augmente).

Un second avantage de cette conception est la réduction du nombre d'opérations
nécessaires lors de l'encodage. Cette réduction provient de l'intégration des
symboles sources dans le mot de code (c'est de la donnée en moins à calculer).
Cette construction permet par exemple de réduire par trois, le nombre de
projections à calculer pendant l'encodage d'un code de rendement $\frac{2}{3}$.
Par ailleurs, une analyse de la réduction du nombre d'opérations en décodage
montre que cette construction permet au code de réaliser moins d'opérations en
décodage, ce qui permet d'accélérer également la vitesse de reconstruction.

Les deux considérations précédentes ont fait l'objet d'une
publication \cite{pertin2015sifwict}. Depuis, une implémentation du code
Mojette systématique a été réalisée, et les améliorations introduites
précédemment en théorie, ont été vérifiées par une évaluation des
implémentations du code Mojette. En conséquence la forme systématique permet au
code de fournir de meilleures performances que les autres codes, tout en
améliorant son rendement, confirmant le choix de ce code performant pour
l'utiliser dans un système de communication.

#### Perspective de travail : Code Mojette non-systématique et confidentialité

Bien que la version systématique permet d'améliorer le rendement et les
performances du code à effacement Mojette, d'autres considérations peuvent
être prises en compte. Les problématiques de confidentialité sont des
considérations qui peuvent motiver le choix de la version non-systématique.

Une première approche concerne la distribution des données sous la forme de
projections. Dans ce cas, l'ensemble de la donnée n'est pas disponible en clair
par un tiers malveillant. Toutefois, certaines parties de l'information sont
disponibles en clair (i.e.\ les coins), et peuvent participer à déterminer des
a priori facilitant l'attaque (e.g.\ langue d'un texte, image).

Une seconde approche consiste à tirer profit de la propagation d'information de
l'algorithme de reconstruction, pour chiffrer efficacement les blocs
d'information. Plus précisément, il suffit de chiffrer les premiers bins des
projections pour protéger l'information contenue dans la grille. En
comparaison, la version systématique nécessite de chiffrer l'ensemble des
symboles de la partie systématique (ce qui nécessite beaucoup plus
d'opérations). Cette considération présente un exemple où la version
non-systématique est plus performante.


## Rôle et impact du code Mojette dans RozoFS 

Les bonnes performances des implémentations du code Mojette nous ont motivé à
l'intégrer dans le système de fichiers distribué RozoFS. Nous avons ainsi
montré qu'en plaçant le code au niveau des clients, il est possible de
distribuer le calcul des projections, afin de ne pas surcharger le serveur de
stockage. Par ailleurs, ce choix permet également de profiter de l'envoi en
parallèle des projections sur plusieurs liens réseau.
Nous avons alors fourni une évaluation des performances de RozoFS par rapport à
CephFS (réglé en mode réplication des données), réalisée sur la plate-forme
Grid'5000. Cette évaluation montre que RozoFS est capable de fournir de
meilleures performances qu'un système basé sur de la réplication, tout en
divisant par deux le coût du volume de données. RozoFS est ainsi le seul
système de fichiers distribué capable de gérer à la fois des données froides et
des données chaudes. Ces travaux ont fait l'objet d'une publication à *CLOSER
2014*\ \cite{pertin2014closer}, et ont depuis été soumis à la revue
*Transactions on Storage*\ \cite{pertin2016tos}.


#### Perspective de travail : Décentralisation des métadonnées

Un aspect qui n'a pas été abordé dans nos travaux concerne la mise à l'échelle
de RozoFS. Le serveur de métadonnées de RozoFS est un point de défaillance
unique (qui est en pratique répliqué). La centralisation des métadonnées
implique un problème dans la mise à l'échelle du système. À la manière de
l'algorithme \textsc{Crush},<!--%\ \cite{weil2007phd}, -->
la distribution des métadonnées (sous forme de projections Mojette) sur une
grappe de serveurs de stockage permettrait de décentraliser ce service
important. Les requêtes issues des client serait ainsi mieux gérer et ce, en
décentralisant la gestion des métadonnées.

## Reprojection sans reconstuction

Enfin, nous nous sommes également intéressés à l'élaboration d'une méthode
permettant de rétablir un seuil de redondance au sein d'un système de fichiers
distribué. Nous avons ainsi proposé un algorithme distribué permettant de
calculer de nouvelles projections. Son avantage est de ne pas avoir à
reconstruire explicitement l'information initiale. Nous avons donné une
évaluation de cette méthode qui montre une réduction significative de la
latence par un facteur $2$. Cette réduction peut être mise à profit pour
réduire l'impact de la reconstruction sur le système de stockage. Ces travaux
ont fait le sujet d'une publication à Reims Image\ \cite{pertin2014ri}.

#### Perspective de travail : Réparation partielle des projections

Jusque là, nous avons étudié les relations mathématiques entre
les projections et la grille. Cependant, il existe également des relations
entre les bins des projections. On peut notamment définir des groupes de bins
dont la somme des valeurs est nulle. Il est ainsi possible de déterminer la
valeur de certains bins, en utilisant cette définition, et par conséquent,
d'envisager de la réparation sur les bins plutôt que sur les projections.
Cette solution a l'avantage de ne pas nécessiter la reconstruction de la
grille. La première difficulté consiste à déterminer l'ensemble des relations
pour un ensemble de projections et un grille donnée. Un deuxième problème
consiste à déterminer s'il existe des groupes qui engendrent moins d'opérations
de reconstruction que d'autres, et comment les déterminer efficacement dans un
processus de réparation. Cet aspect correspond à des travaux en cours, en
collaboration avec Suayb \textsc{Arslan}, professeur associé à l'université
d'Istanbul.


# Conclusion générale

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

