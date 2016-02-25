
\section*{Conclusion}

Les travaux de recherche présentés dans cette thèse réunissent conjointement la
théorie des codes, et la géométrie discrète afin de proposer un code à
effacement efficace. Ce mariage des deux domaines s'affiche particulièrement
dans la première partie de la thèse. La théorie des codes et les codes
correcteurs pour le canal à effacement ont été introduits dans le
\cref{sec.chap1}. En particulier, deux codes ont été présentés : (i) les codes
MDS de \rs dont la complexité des opérations d'encodage et de décodage est
quadratique (ii) les codes LDPC non MDS mais possédant une complexité linéaire.

Les notions de géométrie discrète ont été vues dans le \cref{sec.chap2}. En
particulier, nous avons détaillé deux versions discrètes de la transformée de
\radon : une version finie (FRT) et la transformée Mojette. Nous avons vu
comment ces transformées peuvent être mises en œuvre comme codes à effacement.
Au delà des mises en œuvre, des algorithmes de décodage ont été détaillés.
L'algorithme de \textcite{normand2006dgci} utilisé pour le code Mojette a
l'avantage de proposer une complexité linéaire, ce qui motive le choix de ce
code pour des raisons de performance. Notons cependant que la FRT a l'avantage
de proposer un code MDS.

Notre première contribution, détaillée au sein du \cref{sec.chap3}, a été de
concevoir une mise en œuvre systématique du code Mojette ainsi qu'un algorithme
de décodage approprié. Cette mise en œuvre permet de fournir un code avec
rendement plus proche de l'optimal que dans le cas non-systématique. En ce
sens la redondance générée par notre code est proche des codes MDS comme les
codes de \rs. Une évaluation du rendement a été réalisée à la fin du
\cref{sec.chap3} afin de confirmer cette analyse.

Un autre mariage s'opère dans la seconde partie de la thèse, unissant le code à
effacement Mojette, proposé dans la première partie, à une application de
stockage distribué. Le \cref{sec.chap4} offre une étude des performances des
codes à effacement dans le contexte du stockage distribué. En particulier, une
étude théorique visant à comparer les meilleurs codes à effacement utilisés
dans le contexte du RAID-6, a permis de montrer que le code Mojette nécessite
moins d'opérations pour l'ensemble des métriques définies. Le constat est le
même dans le cas général face aux codes de \rs. Une expérimentation de
l'implémentation confirme cette analyse et montre que le code Mojette
fourni de meilleures résultats en encodage et décodage que l'implémentation des
codes de \rs développée par \intel. 

Les bonne performances de notre implémentation nous ont motivé à l'intégrer
dans un système de stockage. Le \cref{sec.chap5} présente RozoFS, le système de
fichiers distribué développé par Rozo Systems. Nous avons intégré cette
nouvelle mise en œuvre du code Mojette dans RozoFS et avons expérimenté cette
version de RozoFS face à CephFS sur la plate-forme Grid 5000. Les performances
obtenues au cours de ce test montre que RozoFS peut fournir de meilleures
performances qu'un système basé sur de la réplication, tout en réduisant
significativement le volume stocké (ici par un facteur $2$).

Une fois que les données sont stockées, il faut pouvoir maintenir la tolérance
aux pannes mise en place au sein du système. Le \cref{sec.chap6} contient la
seconde contribution développée par nos travaux de recherche. Elle consiste à
calculer de nouvelles projections de manière distribuée, à partir d'un ensemble
de projections existants. En particulier, cette méthode présente l'avantage de
ne pas reconstruire explicitement l'information initiale. Cette méthode a été
évaluée en distribuant les opérations sur plusieurs cœurs de processeur. Un
gain est obtenue sur de grands blocs à traiter.

