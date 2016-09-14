
\chapter*{Conclusion de la partie}

\addstarredchapter{Conclusion de la partie}

Le lien entre la théorie des codes et les transformées discrètes a été établi
dans cette partie. Nous avons vu dans le \cref{sec.chap1}, les notions de la
théorie des codes nécessaires à la compréhension des codes à effacement, ainsi
qu'à l'élaboration d'une liste de critères de comparaison. Cette
étude, qui a conduit à l'analyse des codes MDS de \rs, et des codes LDPC, a
montré qu'aucun des codes étudiés n'est capable de satisfaire l'ensemble des
critères proposés.

Le \cref{sec.chap2} propose une nouvelle approche à base de transformées
discrètes, dans l'objectif de concevoir de nouveaux codes. Nous y avons
notamment introduit les codes à base de FRT et de transformation Mojette. Nous
avons tout d'abord vu que la FRT peut fournir un code à effacement MDS.
L'étude qui a suivi a permis de montrer que malgré son rendement sous-optimal,
le code à effacement Mojette possède l'avantage d'avoir un algorithme de
décodage itératif efficace. Notre motivation a donc été d'utiliser ce dernier
en tâchant d'améliorer son rendement.

Dans le \cref{sec.chap3}, la construction d'une version systématique, et
l'élaboration d'un algorithme de décodage adapté, ont permis d'améliorer le
rendement et les performances de notre code.

Jusque là, le code à effacement Mojette satisfait les critères suivants :

1. une complexité théorique faible grâce à l'algorithme de décodage itératif;

2. une complexité des opérations faibles, correspondant à des additions;

3. l'indépendance des paramètres du code (la hauteur et le nombre de
projections peuvent être choisis arbitrairement);

4. une forme systématique possible, et dont la mise en œuvre est simple.

L'efficacité des opérations d'encodage et de décodage du code à effacement
Mojette se fait au détriment d'un faible surcoût de redondance nécessaire
(désigné par $\epsilon$ dans notre étude).
Le code Mojette est donc le code approprié pour concevoir un système de
stockage capable de gérer à la fois, les données froides, et les données
chaudes.
Restent alors à déterminer les performances du code dans le contexte du
stockage, notamment à travers son intégration dans un système de fichiers
distribué, tel que RozoFS. Cette application au stockage distribué est le sujet
de la seconde partie.

