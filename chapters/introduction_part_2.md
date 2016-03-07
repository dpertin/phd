
\chapter*{Introduction de la partie}

\addstarredchapter{Introduction de la partie}

Nous avons défini dans la partie précédente le code à effacement Mojette 
afin de répondre au problème de la transmission d'informations sur un
canal non-fiable. Dans cette nouvelle partie, nous nous intéresserons à
l'application de ce code dans un système de stockage distribué (NDSS).
Dans ce contexte particulier, le phénomène de panne est considéré comme la
norme plutôt que l'exception. L'objectif de cette nouvelle partie est de
concevoir un NDSS capable de gérer à la fois un seuil de redondance (capacité
nécessaire à l'archivage de données froides), et de fournir de bonnes
performances (nécessaire pour le traitement de données chaudes).
Nous verrons en détail, les éléments suivants dans cette partie :

<!--
%Le problème de l'intégration de notre code à effacement dans un système de
%stockage distribué sera traité dans les \cref{sec.chap4,sec.chap5}. En
%particulier, ces chapitres porteront respectivement sur nos contributions qui
%vise à évaluer théoriquement le code Mojette systématique dans un NDSS, puis à
%l'intégrer spécifiquement dans le système de fichiers distribué (DFS) RozoFS,
%de type *scale-out*. Le \cref{sec.chap6} traite de notre dernière contribution
%relativement à l'élaboration d'une méthode de 
%
%
%
%le canal de communication est composé de deux
%parties : (i) les supports de transport des données (e.g.\ bus, réseau); (ii)
%les supports de stockage des données (e.g.\ bandes, disques durs, SSD).
%
%Le dernier problème correspond au problème de la réparation. Une fois qu'un
%seuil de redondance est mis en place dans un DSS, le système de stockage est
%capable de supporter un certain nombre de pannes (qui engendre de la perte
%d'information). Cependant, ces pannes tendent à réduire la quantité de
%redondance. Le problème de réparation nécessite des algorithmes pour réencoder
%l'information afin de rétablir un seuil de redondance.
-->

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

1. le \cref{sec.chap4} présente l'utilisation des codes à effacement dans le
contexte du stockage distribué. En particulier, le cas du RAID-6 est introduit
avant de généraliser l'étude. Ce chapitre contient deux contributions
concernant : (i) l'évaluation théorique des performances des codes à
effacement (ii) l'évaluation des performances d'encodage et de décodage des
implémentations des codes Mojette et \rs;

2. le \cref{sec.chap5} étudie l'intégration du code à effacement Mojette dans
RozoFS, le DFS développé par Rozo Systems. Une évaluation des latences de
lecture et d'écriture enregistrées par RozoFS sera comparée à celle fournie par
le DFS CephFS, basé sur une technique de réplication;

3. dans le \cref{sec.chap6}, nous proposons une nouvelle méthode distribuée
pour réencoder de nouveaux symboles de mots de code (i.e.\ projections
Mojette), sans avoir à reconstruire explicitement la donnée initiale. Cette
technique sera particulièrement utile dans le cas de la réparation de
supports de stockage, ou d'allocation dynamique de redondance.

