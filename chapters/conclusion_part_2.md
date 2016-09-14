
\chapter*{Conclusion de la partie}

\addstarredchapter{Conclusion de la partie}

L'intégration du code à effacement Mojette dans l'application du stockage
distribué a été le sujet de cette seconde et dernière partie. En particulier,
nous avons vu dans le \cref{sec.chap4} une comparaison théorique puis
expérimentale du code à effacement Mojette dans ce contexte. Les résultats
théoriques ont montré que ce code nécessite moins d'opérations en encodage, en
décodage, et lors de la mise à jour de blocs de données, que d'autres codes MDS
de référence (\rs et *Array*).
Les résultats expérimentaux ont par ailleurs confirmé des vitesses d'encodage
et de décodage jusqu'à trois fois supérieures pour le code Mojette.
Cette expérience a donc permis de prouver que le code Mojette est le code le
plus performant sur des blocs de données adaptés au contexte du stockage (i.e.\
$4$ à $8$\ Ko).

Le \cref{sec.chap5} a détaillé l'intégration de ce code au sein d'un réel
système de stockage, en l'occurrence, le système de fichier distribué RozoFS.
Celui-ci est la seule solution de stockage qui repose sur le code à effacement
Mojette pour distribuer les données de manière redondante.
Cette conception a donné suite à une comparaison avec CephFS, qui a
permis de montrer que RozoFS est capable de fournir de meilleures performances
qu'un système basé sur la réplication, tout en divisant par deux le volume de
données stockées.

Enfin, une nouvelle technique de distribution du calcul de projections Mojette,
développée dans le \cref{sec.chap6}, a également été présentée. L'évaluation
de cette méthode met en avant la réduction par deux de la
latence de l'opération de reprojection grâce à la distribution des calculs.
Cette méthode permet ainsi de rétablir un niveau de redondance dans un système
de stockage, et peut en conséquence s'inscrire dans un mécanisme de réparation
dans le cas de supports de stockage défaillants.

