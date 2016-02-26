
\chapter*{Introduction de la partie}

\addstarredchapter{Introduction de la partie}

Nous avons vu comment les codes permettent de représenter
l'information de façon redondante afin de transmettre les données de manière
fiable sur des canaux de transmission bruités. Puisqu'aucun canal de
transmission n'est sûr, les codes à effacement sont ainsi utilisés dans tous
les domaines des télécommunications. Dans cette partie, nous allons nous
intéresser à l'application des codes à effacement dans les systèmes de stockage
distribué.
Le stockage distribué permet d'agréger un ensemble de ressources de stockage,
physique ou virtuel, afin d'offrir la vision d'un volume unique aux
utilisateurs. Il s'agit alors d'une couche de virtualisation qui, lorsqu'elle
est définie par un logiciel, est dénommée par le terme «\ *Software-Defined
Storage*\ » (SDS).
Dans ce domaine, le canal de transmission est complexe. Il est principalement
composé des supports de stockage (bandes, disques durs, SSD) qui permettent de
conserver l'information. Ce canal comporte également des éléments qui permette
de transporter l'information entre ces supports et les participants (e.g.\ bus,
réseau, etc.).
Nous verrons en détail les éléments suivants dans cette partie :

1. Le \cref{sec.chap4} présente l'utilisation des codes à effacement dans le
contexte du stockage distribué. En particulier, le cas du RAID-6 est introduit
avant de généraliser l'étude. Ce chapitre contient une étude théorique des
performances des codes à effacement. Une évaluation des implémentations de ces
codes Mojette et \rs est également fournie.

2. L'intégration du code à effacement Mojette dans un système de fichiers
distribué (DFS) est étudiée dans le \cref{sec.chap5}. Nous étudions en
particulier RozoFS, le DFS développé par Rozo Systems. Une comparaison des
performances de RozoFS à CephFS réalisée sur la plate-forme Grid'5000 est
également fournie.

3. Dans le contexte du stockage distribué, la perte définitive d'un support de
stockage entraîne la réduction de la quantité de redondance d'information au
sein du système. Le \cref{sec.chap6} donne une nouvelle méthode pour ré-encoder
de nouvelles projections Mojette. Cette technique a l'avantage de pouvoir
distribuer le calcul des nouvelles projections sur un ensemble de nœuds
participants au ré-encodage, sans avoir à reconstruire explicitement
l'information initiale. 

