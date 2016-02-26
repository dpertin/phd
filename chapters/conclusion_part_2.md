
\chapter*{Conclusion de la partie}

\addstarredchapter{Conclusion de la partie}

L'intégration du code à effacement Mojette dans l'application du stockage
distribué a été le sujet de cette seconde et dernière partie. En particulier,
nous avons vu dans le \cref{sec.chap4} une comparaison théorique puis
expérimentale du code à effacement Mojette dans ce contexte. Les résultats
théoriques ont montré que ce code nécessite moins d'opérations en encodage, en
décodage, et lors de la mise à jour de blocs de données, que d'autres codes
(\rs et *Array*). Les résultats expérimentaux ont confirmé de meilleurs temps
d'encodage et de décodage pour le code Mojette.

Le \cref{sec.chap5} a détaillé l'intégration de ce code au sein d'un réel
système de stockage. RozoFS, le système de fichiers distribué développé par
Rozo Systems, utilise le code à effacement Mojette pour distribuer les données
de manière redondante. En particulier, une comparaison avec CephFS a permis de
montrer que l'on est capable de fournir de meilleures performances qu'un
système basé sur la réplication, tout en divisant par deux le volume de données
stockées.

L'élaboration d'une nouvelle technique de distribution du calcule de
projections Mojette, développée dans le \cref{sec.chap6}, permet de rétablir un
niveau de redondance dans un système de stockage. En particulier, une
évaluation de cette méthode a permis de mettre en avant l'avantage de la
distribution des calculs.

