
\chapter*{Conclusion de la partie}

\addstarredchapter{Conclusion de la partie}

Le lien entre la théorie des codes et les transformées discrètes a été établi
dans cette partie. Nous avons vu dans le \cref{sec.chap1}, les notions de la
théorie des codes nécessaires à la compréhension des codes à effacement. Cette
étude a conduit à l'analyse des codes MDS de \rs, et des codes LDPC. Elle a
montré qu'aucun des codes étudiés ne satisfait l'ensemble des critères
proposés.

Le \cref{sec.chap2} propose une nouvelle approche à base de transformées
discrètes, dans l'objectif de concevoir de nouveaux codes. Nous y avons
notamment introduit les codes à base de FRT et de transformation Mojette. Nous
avons vu que la FRT peut fournir un code à effacement MDS.
Bien que son rendement soit sous optimal, le code à effacement Mojette possède
l'avantage d'avoir un algorithme de décodage itératif efficace. Notre
motivation a donc été d'utiliser ce code en tâchant d'améliorer son rendement.

Dans le \cref{sec.chap3}, la construction d'une version systématique, et
l'élaboration d'un algorithme de décodage adapté, ont permis d'améliorer le
rendement de notre code.

Jusque là, le code à effacement Mojette satisfait les critères suivants :

1. complexité théorique grâce à l'algorithme de décodage itératif;

2. complexité des opérations, qui consiste qu'à réaliser des additions;

3. indépendance des paramètres du code (la hauteur et le nombre de
projections peuvent être choisis arbitrairement);

4. code sous la forme systématique, et dont la mise en œuvre est simple.

Bien que le code ne soit pas MDS, c'est le léger surcoût désigné par $\epsilon$
qui permet à l'algorithme d'être performant. Le code Mojette est donc le code
approprié pour concevoir un système de stockage capable de gérer à la fois, les
données froides, et les données chaudes.
Restent alors à déterminer les performances du code dans le contexte du
stockage, notamment à travers son intégration dans un système de fichiers
distribué : RozoFS. Cette application au stockage distribué est le sujet de la
seconde partie.
