
Avec le nombre toujours croissant d'appareils connecté à Internet, la quantité
de données générées augmente de manière préoccupante. Dans un avenir proche,
les appareils mobiles, tablettes et l'« Internet des objets» contribueront
également à générer de la donnée qu'il est généralement nécessaire de stocker
pour un traitement à posteriori. Un rapport de \textcite{gantz2012idc} prévoit
que la quantité d'informations stockées dans le monde atteindra 44 zettaoctets
d'ici 2020 (dont 27\% seront générées par des objets connectés), et que cette
croissance se fait de manière exponentielle.
En parallèle, on observe l'arrivée de nouveaux acteurs mondiaux. En
particulier, la quantité de données stockées par les pays des marchés
émergents (Chine, Brésil, Inde, Russie, Mexique) surpassera celle des marchés
en place (USA, Europe de l'ouest, Japon, Canada, Australie) d'ici 2017.

Dans cette évaluation, le pourcentage de données répliquées est considérable.
Dans les systèmes de stockage distribué, la réplication des données est une
technique utilisée afin de supporter les pannes du système. Les pannes
correspondent à un phénomène inévitable dont la probabilité d'apparition
augmente avec la taille du système de stockage (e.g.\ défaillance d'un disque,
défaillance réseau, etc). Le réplication consiste alors à distribuer plusieurs
copies d'information sur des supports de stockage différents afin de supporter
le cas où une partie des données est inaccessible. Bien que simple à mettre en
œuvre, chaque copie générée correspond à une quantité significative de
redondance.

Le codage à effacement est une technique qui permet de réduire considérablement
la quantité de redondance générée par rapport à la réplication
\cite{weatherspoon2001iptps}. En revanche, elle entraine nécessairement une
complexité significative lors des opérations d'encodage et de décodage,
utilisées respectivement lors de l'écriture et de la lecture. On observe un
très fort engouement pour les codes à effacement. Ainsi, plusieurs entreprises
développant des solutions de stockage comme Cleversafe, Scality, NetApp ou
Panasas s'y intéressent. Plusieurs projets académiques se sont également
développés comme OceanStore \cite{kubiatowicz2000sigplan} ou DiskReduce
\cite{fan2009diskreduce}. Enfin, plusieurs acteurs majeurs comme IBM, Microsoft
\cite{azure}, OpenStack (dans Swift) ou Amazon Glacier utilisent également les
codes à effacement dans leurs services Cloud. Bien que de nombreux codes à
effacement existent, la plupart de ces services utilisent les codes de \rs.
Cette mise en œuvre est la plus populaire pour deux raisons : (i) il n'y a pas
théoriquement pas de limite sur sa capacité de correction; (ii) son rendement
est optimal (la quantité de redondance générée est minimale).

En revanche les codes de \rs implique une complexité significative (typiquement
une complexité quadratique avec la taille de l'information) lors des opérations
d'encodage et de décodage. C'est pourquoi, leur utilisation est limitée aux
applications liées aux données froides tel que l'archivage des données. En
conséquence, on distingue deux types de systèmes de stockage : (i) le premier
permettant d'archiver les données à bas prix, utilisant des codes à effacement;
(ii) le second utilisant potentiellement des techniques de réplication afin
d'accéder et traiter les données chaudes sans ralentissement.

\section*{Motivations et objectifs}

Dans ces travaux de thèse, nous proposons de concevoir un code à effacement
performant dont la quantité de redondance soit proche de l'optimal (comme les
codes \rs) tout en réduisant significativement la complexité des opérations
d'encodage et de décodage.

Pour cela, nous proposons un code à effacement basé sur la transformée Mojette.
Cette technique est une transformée discrète et exacte de la transformée de
\radon. En particulier, elle permet de représenter une information de manière
redondante, avec un rendement quasi-optimal. De plus, cette opération est
inversible et la reconstruction des éléments d'information induit une
complexité linéaire. Cette approche utilise conjointement des aspects de
géométrie discrète et de théorie de l'information.

\section*{Contexte de travail}

Dans le cadre d'une convention CIFRE, ces travaux de recherche ont été menés
conjointement au sein de l'équipe Image et Vidéo Communications (IVC) de
l'Institut de Recherche en Communications et Cybernétique de Nantes (IRCCyN),
et au sein de l'entreprise Rozo Systems. Une intention particulière a alors été
portée sur les implémentations réalisées afin d'être mise en œuvre dans le
système de fichiers distribué RozoFS, développé par l'entreprise. En
conséquence, un intérêt a été porté sur les performances fournit par nos
implémentations. En particulier, ces évaluations ont donné lieu à des
comparaisons avec les alternatives compétitrices.

\section*{Plan et Contributions}

Les travaux de cette thèse sont organisés en deux parties. Chaque partie
comporte trois chapitres. La première partie s'intéresse aux codes à effacement
et à la conception du code basé sur la transformée Mojette : 

1. Dans le \cref{sec.chap1}, nous introduirons l'état de l'art des codes à
effacement. Plus particulièrement, nous verrons le principe des codes
correcteurs appliqué au canal à effacement. Nous verrons ainsi quelques
exemples qui représentent les grandes familles de codes à effacement.

2. Le \cref{sec.chap2} introduit la transformée de \radon. Ce chapitre utilise
conjointement la géométrie discrète et la théorie des codes afin de comprendre
la conception de codes à effacement basés sur des versions discrètes de la
transformée de \radon. Nous verrons ainsi deux conceptions différentes basées
sur la transformée de \radon fini (FRT) et la transformée Mojette.

3. La première contribution sera énoncée dans le \cref{sec.chap3}. Cette
contribution correspond à la conception du code à effacement Mojette sous sa
forme systématique et d'un algorithme de décodage. En particulier, nous verrons
que cette nouvelle mise en œuvre contribue à réduire la redondance nécessaire.
Nous évaluerons ainsi la réduction de redondance par rapport à la version
classique, et verrons que cette mise en œuvre possède un rendement
quasi optimal.

\noindent La seconde partie s'intéresse particulièrement à l'application du
code à effacement Mojette dans le contexte du système de stockage distribué. En
particulier, 

1. Le \cref{sec.chap4} débute par l'analyse théoriques des performances du code
Mojette dans le contexte du RAID-6 puis dans le cas général. Les performances
correspondent alors à des métriques liées au stockage (nombres d'opérations à
l'encodage, décodage, la mise à jour de donnée). Ces métriques permettent une
comparaison avec d'autres codes (\rs et *Array*). La dernière partie correspond
à une comparaison des performances des implémentation des codes Mojette et \rs.
Les résultats obtenus par la Mojette sont significativement meilleurs comparés
à ceux obtenus par les implémentations des codes de \rs développés par \intel.

2. La mise en œuvre du code à effacement Mojette dans le système de fichiers
distribué RozoFS est expliquée dans le \cref{sec.chap5}. En particulier, une
évaluation menée sur la plate-forme GRID-5000 permet de montrer que dans le
cadre de nos tests, RozoFS est capable de fournir de meilleures performances
que des systèmes basés sur de la réplication, tout en réduisant d'un facteur
$2$ le volume total stocké.

3. Une deuxième contribution est fournie dans le \cref{sec.chap6}. Cette
contribution concerne la conception d'une nouvelle méthode distribuée pour
calculer de nouveaux symboles de mots de code, afin de rétablir la tolérance du
système de stockage en cas de panne définitive, ou pour augmenter cette
tolérance.

\noindent Dans une dernière partie, nous aborderons la perspectives des futurs
travaux de recherche, ainsi que la conclusion des travaux présentés dans cette
thèse.
