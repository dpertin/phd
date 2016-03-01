
\chapter*{Introduction de la partie}

\addstarredchapter{Introduction de la partie}

La partie précédente a défini un code à effacement basé sur la transformée
Mojette afin de répondre au problème de transmission d'informations sur un
canal non-fiable. Dans cette seconde partie, nous nous intéresserons à
l'application de ce code à effacement dans un système de stockage distribué
(DSS). Dans ce contexte, le canal de communication est composé de deux parties
: une première partie pour transporter l'information (e.g.\ bus, réseau); une
seconde partie qui stocke l'information (e.g.\ bandes, disques durs, SSD).
Cette deuxième partie permettra de répondre aux deux problèmes non-résolus
présentés en introduction. Le problème de l'intégration de notre code à
effacement dans un système de stockage distribué sera traité dans les
\cref{sec.chap4,sec.chap5}. En particulier, ces chapitres porteront
respectivement sur l'utilisation des codes dans un DSS, et dans le système de
fichiers distribué (DFS) de type *scale-out* RozoFS.

Le dernier problème correspond au problème de la réparation. Une fois qu'un
seuil de redondance est mis en place dans un DSS, le système de stockage est
capable de supporter un certain nombre de pannes (qui engendre de la perte
d'information). Cependant, ces pannes tendent à réduire la quantité de
redondance. Le problème de réparation nécessite des algorithmes pour réencoder
l'information afin de rétablir un seuil de redondance.
<!--
%Nous avons vu comment les codes permettent de représenter
%l'information de façon redondante afin de transmettre les données de manière
%fiable sur des canaux de transmission bruités. Puisqu'aucun canal de
%transmission n'est sûr, les codes à effacement sont ainsi utilisés dans tous
%les domaines des télécommunications. Dans cette partie, nous allons nous
%intéresser à l'application des codes à effacement dans les systèmes de stockage
%distribué.
%Le stockage distribué permet d'agréger un ensemble de ressources de stockage,
%physique ou virtuel, afin d'offrir la vision d'un volume unique aux
%utilisateurs. Il s'agit alors d'une couche de virtualisation qui, lorsqu'elle
%est définie par un logiciel, est dénommée par le terme «\ *Software-Defined
%Storage*\ » (SDS).
%Dans ce domaine, le canal de transmission est complexe. Il est principalement
%composé des supports de stockage (bandes, disques durs, SSD) qui permettent de
%conserver l'information. Ce canal comporte également des éléments qui permette
%de transporter l'information entre ces supports et les participants (e.g.\ bus,
%réseau, etc.).
-->
Nous verrons en détail les éléments suivants dans cette partie :

1. le \cref{sec.chap4} présente l'utilisation des codes à effacement dans le
contexte du stockage distribué. En particulier, le cas du RAID-6 est introduit
avant de généraliser l'étude. Ce chapitre contient une évaluation théorique des
performances des codes à effacement. Une évaluation des implémentations de ces
codes Mojette et \rs est également fournie. Ces deux évaluations correspondent
aux contributions mineures $2$ et $3$;

2. le \cref{sec.chap5} étudie l'intégration du code à effacement Mojette dans
RozoFS, le DFS développé par Rozo Systems (contribution mineure $4$). On
comparera les latences enregistrées par RozoFS à celles fournies par un système
basé sur de la réplication (i.e.\ CephFS) lors d'une expérimentation réalisée
sur la plate-forme Grid'5000;

3. le \cref{sec.chap6} contient notre seconde principale contribution pour
répondre au problème de la réparation. Celle-ci correspond à une méthode
distribuée pour calculer de nouvelles projections Mojette à partir d'un
ensemble distribué sur un ensemble de support de stockage. En particulier cette
méthode permet de ne pas reconstruire explicitement l'information initiale
(réencodage sans reconstruction).

