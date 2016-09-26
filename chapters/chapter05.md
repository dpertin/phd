
\chapter{Application au système de fichiers distribué RozoFS}

\label{sec.chap5}

\minitoc

\newpage

\section*{Introduction du chapitre}

\addcontentsline{toc}{section}{Introduction du chapitre}

Les systèmes de fichiers distribués (DFS) permettent d'agréger en un volume
unique différents supports de stockage interconnectés par un réseau.
Plusieurs processus exécutés sur des serveurs de ce réseau peuvent ainsi
accéder simultanément à ce volume afin de partager et d'interagir avec les
données qui y sont stockées.
Comme nous l'avons énoncé précédemment, ces systèmes reposent sur la redondance
d'information afin de supporter l'indisponibilité des données. Dans la
pratique, l'apparition de pannes sur de tels systèmes est considérée comme une
norme et non une exception\ \cite{weil2006osdi}.
De par leur simplicité de mise en œuvre, les techniques de réplication sont
largement utilisées pour fournir cette redondance. Cependant, ces techniques
impliquent de stocker une quantité importante de redondance par rapport à la
donnée à protéger (e.g.\ $200$\% dans le cas de la réplication par trois). Les
codes à effacement offrent une alternative permettant de fournir la même
tolérance aux pannes, tout en diminuant très largement cette quantité de
redondance (généralement par un facteur $2$)\ \cite{weatherspoon2001iptps,
oggier2012icdcn}. En conséquence, la transition vers un système de données
encodées réduit significativement la consommation énergétique du système de
stockage.

À l'origine, les systèmes RAID-5 tolèrent la perte d'un disque, moyennant
un volume de données qui reste moins important par rapport au volume induit par
les données répliquées dans le cas de RAID-1. Côté performance, le calcul des
données de parité est une opération relativement simple pour le contrôleur
RAID. Les additions utilisées ont en effet un impact modéré sur les
performances du système en écriture, à condition que ces données soient
distribuées sur l'ensemble des disques de la matrice. Cette considération
permet en effet de répartir la charge afin qu'un disque ne forme un goulot
d'étranglement.
Toutefois, cette technique se retrouve rapidement limitée à mesure que la
taille des matrices de disques augmente. En effet, plus le nombre de disques
augmente, plus le risque qu'une double panne survienne est important. La
famille RAID s'est alors agrandie grâce à de nouvelles techniques permettant
une protection face à la perte d'un second disque (RAID-6). Pour un ensemble de
disques donné, cette technique améliore la tolérance aux pannes du système, au
prix d'une diminution de la capacité de stockage. Une première construction
repose sur les codes de \ct{\rs $\PP+\QQ$}\ \cite{chen1994acm}. Le principal
problème de cette méthode correspond à la complexité des calculs des blocs de
parité, qui impacte significativement les performances en écriture et lors des
opérations de reconstruction. En conséquence, plusieurs méthodes de codage ont
été proposées pour améliorer cette complexité, telles que l'utilisation
combinée de parités horizontales et verticales\ \cite{gibson1989sigarch}, les
codes \eo\ \cite{blaum1995toc} d'\textsc{IBM}, les codes RDP de
\textsc{NetApp}\ \cite{corbett2004fast}, ou encore des codes à densité
minimale\ \cite{blaum1999tit}. Le milieu scientifique s'est donc intéressé à
l'efficacité des implémentations de ces codes\ \cite{plank2009fast}.
Par la suite, les systèmes de stockage ont évolué en tirant parti d'un ensemble
de machines interconnectées. Des techniques de distribution RAID sont alors
apparues en exploitant la communication à travers un réseau, tout d'abord au
niveau des blocs\ \cite{long1994cs}, puis au niveau logiciel sous le terme de
*Reliable Array of Independant Nodes* (RAIN)\ \cite{bohossian1999pds}.
Apparaissent également des mises en œuvre dans les infrastructures pair à
pair\ \cite{rowstron2001sosp,weatherspoon2001iptps}. Aujourd'hui, grâce aux
codes à effacement, ces techniques sont largement étendues dans les systèmes de
fichiers distribués tels que HDFS\ \cite{fan2009pdsw},
Ceph\ \cite{weil2006osdi} ou Tahoe\ \cite{wilcox2008sss}.

Nous débuterons ce chapitre par une étude détaillée des systèmes de fichiers
distribués en \cref{sec.dfs}. La \cref{sec.rozofs} présentera en détail
RozoFS : le DFS qui intègre le code à effacement Mojette. Puis nous mesurerons
les performances en matière de lecture et d'écriture de RozoFS dans une
évaluation réalisée dans la \cref{sec.rozofs.perf}.


# Systèmes de fichiers distribués tolérants aux pannes {#sec.dfs}

Dans cette section, nous allons étudier les systèmes de fichiers distribués qui
proposent des mécanismes permettant de supporter l'inaccessibilité d'une partie
de la donnée. Il existe plusieurs façons de concevoir un système de fichiers
distribué. Pour comprendre cela, nous verrons dans la \cref{sec.architectures}
qu'il existe plusieurs architectures pour partager des données, allant d'une
conception centralisée à un schéma complètement décentralisé. Par la suite,
nous présenterons dans la \cref{sec.conception}, les principales fonctions qui
rentrent en jeu dans la conception d'un DFS (e.g.\ la gestion de la cohérence
des données). La \cref{sec.redondance.dfs} se focalisera quant à elle aux
aspects de redondance dans ce genre de système.


## Architectures {#sec.architectures}

Nous allons ici explorer les différentes architectures utilisées
dans le partage des données entre plusieurs clients. Nous verrons tout d'abord
le modèle client-serveur, utilisé notamment dans NFS. Par la suite nous verrons
une solution dont la distribution des données sur une grappe de serveur est
gérée par un serveur de métadonnées. Enfin, nous verrons une architecture
entièrement décentralisée.

### Architectures client-serveur

\begin{figure}
    \centering
    \def\svgwidth{.8\textwidth}
    \footnotesize
    \includesvg{img/nfs}
    \caption{Représentation d'une architecture client-serveur, utilisée
    notamment dans NFS.}
    \label{fig.nfs}
\end{figure}

Plusieurs DFS sont définis sur un modèle client-serveur. C'est notamment le cas
de *Network File System* (NFS) qui est le plus utilisé par les systèmes basés
sur UNIX\ \cite{haynes2015rfc7530}. Le principe de ces DFS est que
le serveur offre une vision uniformisée d'une partie de son système de fichiers
local (quel que soit le type de ce système de fichiers). NFS dispose d'un
protocole de communication qui permet aux clients d'accéder aux fichiers du
serveur. Plus précisément, le client ne sait pas comment sont implémentées les
opérations pour interagir sur le système de fichiers du serveur distant. En
revanche, le serveur, lui, propose une interface accessible par des requêtes
*Remote Procedure Calls* (RPC), pour réaliser ces opérations. Et le serveur,
qui maîtrise la façon dont ces opérations sont implémentées, les applique.
Ainsi, il est possible que des processus installés sur différentes machines,
fonctionnant sur différents systèmes d'exploitation, puissent interagir avec un
système de fichiers virtuel partagé.

Côté client, NFS permet de monter le système de fichiers distant. Cette
opération est possible grâce au *Virtual File System* (VFS) qui remplace
l'interface du système de fichiers local afin d'interfacer plusieurs systèmes de
fichiers\ \cite{kleiman1986usenix}. En particulier, il intercepte les appels
systèmes pour les transmettre au client NFS.


### Architectures en grappe centralisées

\begin{figure}
    \centering
    \def\svgwidth{.8\textwidth}
    \footnotesize
    \includesvg{img/gfs}
    \caption{Représentation d'une architecture en grappe centralisée comme
    utilisée dans GFS. Un client contacte le nœud \emph{master} afin de
    déterminer la position des blocs d'un fichier. Il contacte ensuite les
    serveurs de stockage appropriés pour récupérer l'information voulue.}
    \label{fig.dfs}
\end{figure}

Les architectures en grappe sont une extension du modèle client-serveur. Les
grappes de serveurs sont généralement utilisées dans le cas d'applications
parallèles. Dans ce modèle, les fichiers sont distribués sur un ensemble de
nœuds de la grappe. Puisque plusieurs éléments disposent de la donnée, il est
alors possible de distribuer également les applications.
Dans cette approche, proposée par \textsc{Google} pour son *Google File System*
(GFS)\ \cite{ghemawat2003sosp}, chaque grappe correspond à un nœud maître et
plusieurs nœuds de stockage. Le nœud maître maintient et transmet les
informations liées aux métadonnées d'un fichier. Pour y accéder, un client
doit lui fournir l'identifiant du fichier afin qu'il lui transmette les
informations permettant d'atteindre les données relatives à ce fichier,
qui sont réparties sur les serveurs de stockage.


### Architectures en grappe complètement distribuées

Le modèle précédent n'est pas adapté pour certains types d'infrastructures tels
qu'en pair à pair. Il existe des moyens pour ne pas avoir à garder un index
contenu dans un nœud *master*. Pour cela, on combine un mécanisme clé-valeur avec
un système permettant de calculer de façon unique la position des données dans
une grappe. Il est par exemple possible d'utiliser le protocole Chord pour
déterminer de manière décentralisée la position des données dans un
anneau\ \cite{stoica2001sigcomm}. Cette technique est par exemple utilisée dans
le système de fichiers pair à pair Ivy\ \cite{muthitacharoen2002sigops}.
D'autres méthodes existent telles que, la distribution des données issue de
l'algorithme \textsc{Crush} utilisé dans Ceph\ \cite{weil2006osdi}.


## Principes de conception {#sec.conception}

Cette section permet de comprendre les enjeux d'un système de fichiers
distribué. En particulier, nous étudierons une liste non exhaustive d'éléments
à prendre en compte lors de la conception d'un DFS, telles que la gestion de la
distribution des données, ou de la cohérence des données. Bien que les
mécanismes de tolérance aux pannes puissent correspondre à cette étude, ils
seront plus précisément décrits dans la section suivante.


### Transparence des opérations

L'utilité d'un système de fichiers distribué est de pouvoir interagir avec un
volume de stockage distribué sur un ensemble de supports de stockage.
Du point de vue fonctionnel, la mise en œuvre doit permettre à l'utilisateur
d'avoir l'impression d'interagir avec un système de fichiers UNIX local.
C'est le rôle du VFS que d'intercepter les appels systèmes depuis les
applications et de les fournir à la couche du DFS, afin que celui-ci applique
les opérations nécessaires sur l'ensemble des supports de stockage en jeu.


### Espace de nommage

La capacité à résoudre la correspondance entre les éléments de l'organisation
hiérarchique proposée aux client, et les données distribuées au sein du système
est relative à l'espace de nommage. Lorsqu'un client monte un système de
fichier, il dispose d'une arborescence de fichiers et de répertoires dans
laquelle il peut naviguer. Dans un système de fichiers UNIX classique,
un fichier est visible par un utilisateur comme un élément inclus au sein
d'un répertoire, et identifié par un nom. Quand le VFS recherche ce nom,
celui-ci inclut le chemin depuis la racine pour y accéder, sauf si le chemin est
relatif. Cette recherche de nom permet de déterminer le numéro d'inode qui est
un identifiant unique utilisé par le système de fichiers. Une fois que ce numéro
est déterminé, il est possible d'accéder à la structure de l'inode, et donc aux
données du fichier.

Dans le cas des DFS, le montage d'un système de fichiers permet de
placer le volume distant dans l'arborescence locale (le volume est dit
*exporté*). Par exemple dans NFS, le serveur peut définir d'exporter un
répertoire de son système de fichiers local. Un espace de nommage
supplémentaire est alors nécessaire afin de réaliser la correspondance du nom
d'un fichier proposé à l'utilisateur dans le volume exporté, avec la position
des données sur l'ensemble des nœuds de stockage de la grappe. Dans le cas de
GFS, c'est le serveur maître qui réalise cette correspondance.


### Cohérence

Dans un système UNIX classique, lorsqu'une demande de lecture survient après
deux écritures successives sur une même partie de la donnée, il est garanti que
le système retourne la donnée qui résulte des opérations d'écriture
successives.

Dans un système distribué, plusieurs problèmes surviennent. Tout d'abord le délai
nécessaire pour que la donnée transite d'un serveur vers un client peut être
suffisant pour délivrer une version dépassée. De plus, pour des raisons de
performance, les clients tendent à utiliser des techniques de cache afin de
garder une version des données localement, mais qui implique une complexité de
gestion des ressources partagées.
Il est possible de contourner ce deuxième problème de deux manières. La
première solution consiste à mettre à jour le serveur à chaque modification du
cache, ce qui n'est pas performant. La seconde consiste à relaxer la contrainte
de cohérence en affirmant que dans un premier temps, les modifications ne
seront visibles qu'à partir du client, mais qu'à terme (par exemple lors de la
fermeture du fichier) ces modifications seront accessibles à tous. Bien que
cela ne résout pas le problème de partage des ressources, on considère dans ce
cas que la lecture d'une version dépassée est valide.

% http://blog.cloudera.com/blog/2009/07/file-appends-in-hdfs/

Une autre solution pour résoudre ce problème est de rendre les fichiers
immuables. C'est le cas des premières versions de HDFS puisque ce fonctionnement
est cohérent avec les traitements *Map-Reduce* qui lisent des fichiers en entrée
et écrivent les résultats dans de nouveaux fichiers.
Une dernière façon de gérer le partage de données est d'utiliser des
transactions atomiques.

% #### Sécurité

% chiffrement

% gestion accès

% quota

% intégrité ?



## Redondance dans les DFS {#sec.redondance.dfs}

Dans cette section, nous nous intéresserons à la gestion de la redondance dans les
DFS afin de supporter l'inaccessibilité d'une partie de la donnée.
Pour cela nous chercherons à estimer la disponibilité d'une donnée dans un
système de stockage en fonction de la technique utilisée (réplication ou
codage à effacement). Par la suite, nous donnerons un état de l'art de
l'utilisation de ces techniques dans les DFS.


### Disponibilité de la donnée

L'utilisation des techniques de réplication permet de garantir la
disponibilité des données d'un système de stockage en conservant plusieurs
copies distribuées sur différents supports de stockage. Il faut toutefois
relativiser la disponibilité de cette donnée puisque les probabilités qu'une
panne survienne dans un système composé d'une grappe importante de serveurs sont
significatives.

Soit $\rho_F$ la probabilité qu'un disque devienne inaccessible. Une estimation
de la valeur de $\rho_F$ dépend du *Mean Time Between Failures* (MTBF),
c'est-à-dire le temps moyen qui s'écoule entre deux pannes, ainsi que le *Mean
Time To Repair* (MTTR) qui correspond au temps nécessaire pour remplacer le
disque. Par exemple, pour un disque qui fonctionne pendant $1000$ jours, et qui
peut être remplacé, formaté et fonctionnel en un jour,
$\rho_F=0.001$\ \cite{cook2014hitachi}.

Considérons un système de stockage qui réplique chaque objet à stocker d'un
facteur $n$. Ce système peut perdre de la donnée lorsque l'ensemble de ces $n$
disques tombent en panne. En supposant que les pannes correspondent à des
phénomènes *indépendants*, la probabilité de perdre de la donnée $\rho_P$
vaut $\rho_F^n$. En comparaison, dans un système utilisant un code à effacement
$(n,k)$, on perd de la donnée lorsque plus de $k$ disques tombent en panne. Par
conséquent, la probabilité de perdre de la donnée vaut :

\begin{equation}
    \rho_P = \sum_{i=n-k+1}^{n} \binom{n}{i} \rho_F^i (1 - \rho_F)^{n-i}.
\end{equation}

\noindent En conclusion, pour une une même disponibilité, un code à effacement
permet à un système de stockage de disposer d'une capacité de stockage plus
importante qu'en utilisant de la réplication.

% papier cook : # efficiency considerations

% ec plus lent parce que le délai dépend du dernier bloc

% sauf qu'il en reste n-k autres

% de plus la taille des blocs est inférieure au bloc rép

% et que l'envoie peut être réalisée en parallèle


### Gestion de la redondance dans les DFS

La réplication par trois est configurée par défaut dans la plupart des systèmes
de stockage tel que *Hadoop Distributed File System*
(HDFS)\ \cite{shvachko2010msst}, ou encore *Google File System*
(GFS)\ \cite{ghemawat2003sosp}. Cependant, le facteur de réplication entraîne une
augmentation significative des volumes de ces systèmes de stockage. C'est
pourquoi, la réduction de la quantité de redondance est devenue une
préoccupation importante dans le milieu scientifique et industriel.

HDFS est l'une des solutions de stockage les plus populaires. Cette solution
offre un système de fichiers extensible et tolérant aux pannes. Le modèle
*Map-Reduce* utilise HDFS afin de diviser et distribuer les tâches sur les
différents nœuds de travail\ \cite{dean2008acm}. En particulier, ce système de
fichiers est conçu pour accomplir des tâches d'analyse en parallèle sur de très
importants volumes de données immuables (i.e\ approche *write-once-read-many*).
Par exemple, les plus grosses grappes de nœuds expérimentées reposent sur
$4000$ serveurs qui agrègent une capacité totale de $14,25$ pétaoctets
exploitée par $14000$ clients simultanément\ \cite{shvachko2008hadoop}. Côté
performances, l'exploitation du parallélisme par *Map-Reduce* permet de trier
un téraoctet de données en une minute\ \cite{omalley2009hadoop}. HDFS est adapté
pour ce genre d'applications puisque ce système de fichiers travaille
de manière séquentielle sur d'importants blocs de données de $128$\ Mo (valeur
fixée par défaut).
Un bloc correspond à la plus petite quantité de données sur laquelle un système
de fichiers peut lire ou écrire. L'ensemble des opérations qu'il réalise est
effectué sur une quantité de données multiples de la taille d'un bloc. Cette
taille a donc une influence sur le système de stockage. L'utilisation de
grands blocs entraîne trois conséquences : (i) la réduction des interactions
entre les clients et le serveur de métadonnées; (ii) la réduction de la
quantité de métadonnées stockées; (iii) la réduction du trafic réseau en gardant
des connexions TCP persistantes\ \cite{ghemawat2003sosp}. Globalement, des blocs
de tailles importantes permettent d'augmenter les performances de lecture et
d'écriture dans le cas où de larges fichiers sont parcourus de manière
séquentielle (e.g.\ lecture d'une vidéo de haute qualité). En effet, le support
de stockage peut lire ou écrire la donnée de manière continue, sans avoir à
localiser le bloc suivant. Cependant, une part significative du bloc peut être
perdue dans le cas où le fichier est plus petit que la taille d'un bloc. En
comparaison, les systèmes de fichiers compatibles POSIX\footnote{POSIX est le
standard des interfaces de programmation utilisés par les logiciels conçus pour
les systèmes de type UNIX.} reposent sur de petites
tailles de blocs (e.g.\ $4$\ Ko dans le cas de *ext4*\ \cite{mathur2007linux}).
Dans la suite, nous nous intéresserons à la conception d'un système de fichiers
distribué compatible POSIX qui travaillera sur des blocs de l'ordre de
$4\text{-}8$\ Ko comme compromis entre la capacité d'accéder de manière
séquentielle aux données, et le gaspillage d'espace au sein des
blocs\ \cite[p. 34]{gianpaolo1998fs}.

Alors que la réplication par trois est le paramètre de haute disponibilité par
défaut dans HDFS, \textcite{fan2009pdsw} ont développé une version modifiée
basée sur les codes de \rs, dénommée *DiskReduce*. Dans leur publication,
l'utilisation des codes à effacement permet de réduire de $2,4$ fois le volume
de stockage. Cependant, cette technique est mise en œuvre en tâche de fond, et
permet d'encoder des blocs d'information de $64$\ Mo issus des répliquas, ce
qui n'est pas adapté dans le cas des applications compatibles avec POSIX.
\textcite{muralidhar2014osdi} ont également utilisé les codes de \rs au sein
des grappes de stockage de \textsc{Facebook} pour des données considérées
\ct{tièdes} (i.e.\ $80$ lectures par seconde).
GlusterFS\footnote{http://www.gluster.org/} et Ceph\ \cite{weil2006osdi} sont
d'autres exemples de systèmes de stockage distribués populaire. Ceph a la
particularité de stocker les données sous la forme d'objets. Toutefois,
il dispose d'un système de fichiers, nommé CephFS (pour *Ceph File System*),
permettant de créer une interface POSIX entre les applications et les volumes
de stockage objet. Par rapport à HDFS qui est spécialisé pour des applications
spécifiques, CephFS et GlusterFS sont destinés à toute application. Ces DFS
fournissent des techniques de tolérance aux pannes, dont la réplication
est la technique proposée par défaut. Le codage à effacement, bien que
disponible, n'est en revanche recommandé que dans le cas d'applications liées
aux données froides, telles que l'archivage.




# RozoFS : le DFS basé sur le code à effacement Mojette {#sec.rozofs}

\begin{figure}
    \begin{subfigure}{.49\textwidth}
        \centering
        \def\svgwidth{\textwidth}
        \scriptsize
        \includesvg{img/rozo_archi2}
        \caption{Architecture de RozoFS}
        \label{fig.rozo_archi}
    \end{subfigure}
    \begin{subfigure}{.49\textwidth}
        \centering
        \def\svgwidth{\textwidth}
        \scriptsize
        \includesvg{img/ceph_archi2}
        \caption{Architecture de CephFS}
        \label{fig.ceph_archi}
    \end{subfigure}
    \caption{Représentations des architectures de RozoFS (a) et CephFS (b).
    Les similitudes correspondent aux : serveur de métadonnées (\emph{exportd} et
    MDS), serveur de stockage (\emph{storaged} et OSD) et aux clients
    (\emph{rozofsmount}). De plus, CephFS utilise un service de monitorage (MON).
    Alors que les serveurs de stockage de RozoFS stockent des projections
    Mojette, les OSD contiennent des objets pour CephFS.}
    \label{fig.rozoceph_archi}
\end{figure}

Dans cette section, nous présenterons la conception des systèmes de fichiers
distribués RozoFS et CephFS. Ces deux systèmes sont à \ct{code source ouvert}
et compatibles avec POSIX. En particulier, ils reposent sur un ensemble de
systè.es de fichiers locaux sous-jacents. Une fois montés, ils fournissent un
espace de noms global (i.e.\ un ensemble de répertoires et fichiers structurés
comme une arborescence) qui repose sur un ensemble de nœuds de stockage
standards (*commodity*). Alors que traditionnellement, CephFS repose sur des
techniques de réplication, la spécificité de RozoFS est d'être conçu sur la
base du code à effacement Mojette. La \cref{fig.rozoceph_archi} montre les
similitudes entre l'architecture de RozoFS en \cref{fig.rozo_archi}, et de
CephFS en \cref{fig.ceph_archi}, et met en avant la correspondance des noms
entre les différents services. Dans la suite, nous décrirons les composants de
RozoFS et leurs interactions, avant d'analyser les principales différences avec
CephFS.



## L'architecture de RozoFS

L'architecture de RozoFS est bâtie de trois composants qui sont représentés
dans la \cref{fig.rozo_archi} :

1. le service de gestion des métadonnées, appelé *exportd*;

2. le service de stockage des projections, appelé *storaged*;

3. les clients qui utilisent le processus *rozofsmount* pour monter RozoFS.

\noindent Bien qu'il soit possible de combiner différents services au sein d'un
même serveur, nous décrirons dans la suite ces différents composants de telle
manière qu'ils soient distribués sur différents serveurs.


#### Serveur de métadonnées

Ce serveur gère le processus *exportd* qui stocke les métadonnées, et gère les
différentes opérations qui sont liées. Les métadonnées correspondent à une
petite quantité d'information qui décrit la donnée elle-même. Elles sont
composées d'attributs POSIX (e.g.\ horodatages des fichiers, permissions,
\dots), auxquelles s'ajoutent des attributs étendus définis par RozoFS, tels
que l'identification ou la localisation des fichiers sur le système de
stockage. Ce serveur garde des statistiques sur la capacité des nœuds de
stockage afin de répartir la charge sur les différents disques. En particulier,
dans le cas d'une demande de lecture ou d'écriture, il fournit au client la
liste des supports de stockage relatifs aux informations d'un fichier. La haute
disponibilité de ce service n'est pour l'instant pas gérée par RozoFS. En
pratique, des logiciels tiers tels que DRBD\footnote{http://www.drbd.org/}
(pour la réplication du service) et Pacemaker\footnote{http://clusterlabs.org/}
(pour la haute disponibilité) sont utilisés.

#### Nœud de stockage

Cette machine gère le service *storaged*. Deux fonctions sont gérées par ce
service : (i) la gestion des requêtes vers *exportd*; (ii) les *threads* d'E/S
des données qui gèrent les requêtes issues des clients en parallèle. De plus, ce
service est en charge de la réparation des nœuds de stockage. Lorsqu'un nœud
est définitivement perdu, il est nécessaire de reconstruire de la redondance
afin de rétablir la tolérance aux pannes du système. Nous verrons plus en
détail cette considération dans le \cref{sec.chap6}.

#### Les clients RozoFS

Un client utilise le processus *rozofsmount* afin de monter localement un
volume défini par RozoFS. Ce processus utilise
FUSE\footnote{http://www.fuse.sourceforge.net} (*Filesystem in UserSpacE*) pour
intercepter les appels systèmes et définir les opérations distribuées de
RozoFS. Les clients gèrent deux types d'opération : (i) les opérations de
métadonnées (*lookup*, *getattr*, \dots) en interaction avec *exportd*; (ii)
les opérations d'E/S des données avec *storaged*. Les clients
sont responsables de l'encodage et du décodage lors des opérations d'écriture
et de lecture respectivement.



## Distribution de l'information

\begin{table}[t]
    \centering
    \begin{tabular}{@{}l*4c@{}}
      \toprule
      \emph{Layout} & $k$ & $n$ & nœuds de stockage & capacité de correction \\
      \midrule
      $0$ & $2$ & $3$ & $4$ & $1$ \\
      $1$ & $4$ & $6$ & $8$ & $2$ \\
      $2$ & $8$ & $12$ & $16$ & $4$ \\
      \bottomrule
    \end{tabular}
        \caption{Caractéristiques des trois \emph{layouts} fournis par RozoFS.
        Les paramètres du code à effacement Mojette sont donnés par $(n,k)$. Le
        nombre minimum de supports de stockage correspond à $n + (n-k)$ afin de
        garantir une certaine capacité de stockage durant les opérations
        d'écriture.}
        \label{tab.layout}
\end{table}

La distribution des données sur plusieurs supports de stockage est définie par
les paramètres de l'encodage Mojette. Tel qu'on a pu le voir dans les chapitres
précédents, un sous-ensemble de $k$ parmi les $n$ blocs encodés est suffisant
pour reconstruire l'information initiale. Les paramètres de protection,
appelés *layouts* dans RozoFS, définissent les valeurs de $k$, de $n$, ainsi
qu'un nombre minimal de supports de stockage requis afin de fournir une
capacité de correction face aux pannes (en lecture comme en écriture).

Actuellement, trois *layouts* sont définis dans RozoFS. Le \cref{tab.layout}
représente les informations relatives à ces trois configurations. Chaque
*layout* correspond à un taux de codage de $r=\frac{3}{2}$. En conséquence, le
volume de données stockées vaut un peu plus de $1,5$ fois la taille du volume
d'entrée. Lors d'une opération d'écriture, au moins $(n-k)$ nœuds de secours
sont nécessaires en plus des $n$ supports désignés pour recevoir la donnée, afin
de supporter les éventuelles pannes durant l'opération. Par exemple, en
*layout* $2$, le nombre minimum de supports de stockage correspond à $12 +
(12-8) = 16$ afin de supporter l'indisponibilité de quatre nœuds durant
l'opération d'écriture.

\begin{figure}
    \centering
    \small
    \begin{subfigure}{.48\textwidth}
        \def\svgwidth{\textwidth}
        \input{img/scenarios_sys1.pdf_tex}
        \caption{}
        \label{fig.write}
    \end{subfigure}
    \hspace{8pt}
    \begin{subfigure}{.48\textwidth}
        \def\svgwidth{\textwidth}
        \input{img/scenarios_sys3.pdf_tex}
        \caption{}
        \label{fig.read}
    \end{subfigure}
    \begin{subfigure}{.48\textwidth}
        \def\svgwidth{\textwidth}
        \input{img/scenarios_sys22.pdf_tex}
        \caption{}
        \label{fig.write1}
    \end{subfigure}
    \hspace{8pt}
    \begin{subfigure}{.48\textwidth}
        \def\svgwidth{\textwidth}
        \input{img/scenarios_sys44.pdf_tex}
        \caption{}
        \label{fig.read1}
    \end{subfigure}
    \caption{Scénarios d'écriture et de lecture en \emph{layout} $0$
    (i.e.\ utilisant le code Mojette systématique $(3,2)$). Les
    \cref{fig.write,fig.read} concernent les situations sans dégradation, alors
    que les \cref{fig.write1,fig.read1} concernent des opérations dégradées.
    Les blocs de données, identifiés par $d_i$, et les projections Mojette,
    identifiées par $p_j$, sont distribués sur les supports de stockage $S_k$.
    Cette figure est inspirée de\ \cite{fan2009pdsw}.}
    \label{fig.scenarios}
\end{figure}


## Des entrées/sorties tolérantes aux pannes {#sec.entrees.sorties}

Cette section s'intéresse aux interactions entre les différents composants de
RozoFS lors des opérations d'écriture, et de lecture. Nous verrons ensuite
quel est l'impact les pannes sur le fonctionnement du système.

### Les opérations d'écriture

Lorsqu'un client initialise une opération d'écriture, cela déclenche un
processus d'encodage Mojette. Plus particulièrement, un flux de données à
écrire est découpé en blocs de $\mathcal{M} = 4$\ Ko (valeur par défaut).
Ces blocs de données remplissent un *buffer* adressé par $k$ pointeurs, qui
représentent les $k$ lignes d'une grille Mojette. On utilise des *threads*, qui
permettent de gérer plusieurs opérations d'encodage et de décodage en
parallèle. Puisque l'on considère le code à effacement Mojette sous sa forme
systématique, chaque *thread* du client calcule $(n-k)$ projections et transmet
les $n$ blocs encodés sur $n$ supports de stockage. L'identification des
supports concernés est fourni par *exportd*. Prenons l'exemple de l'écriture
d'un gigaoctet d'information sur un volume RozoFS défini en *layout* $0$, comme
illustré dans la \cref{fig.write}. L'écriture distribue trois fichiers
contenant les informations de projections. Plus précisément, chacun de ces
fichiers fait environ $500$\ Mo tel que $d_1$ et $d_2$ contiennent les données
en clair, et $p_1$ contient les données de la projection suivant la direction
$(0,1)$.

### Les opérations de lecture

Lorsqu'une application demande la lecture d'une donnée présente sur le point de
montage de RozoFS, celui-ci favorise la lecture des $k$ blocs de données en
clair (i.e.\ $d_1$ et $d_2$). Cette situation est représentée dans la
\cref{fig.read} (cf. \cpageref{fig.read}). Le processus transfère alors environ
$2 \times 500$\ Mo en parallèle. Ensuite, la donnée est transmise à
l'application.

### Impact en cas de pannes

La \cref{fig.write1} illustre la situation d'une panne qui surviendrait lors d'une
opération d'écriture. Dans ce cas, la donnée destinée au support de stockage
défaillant est transférée au prochain nœud de secours disponible. De manière
similaire en lecture, le processus essaie d'accéder à l'information depuis
le prochain nœud de secours disponible. Les nœuds de secours sont renseignés
dans la liste des supports de stockage émis par *exportd*. Une fois que le
client accède à $k$ blocs, une opération de décodage est déclenchée afin de
reconstruire l'information initiale. Cette situation est illustrée dans la
\cref{fig.read1}.

\begin{figure}
    \centering
    \def\svgwidth{.8\textwidth}
    \footnotesize
    \includesvg{img/rozofs_archi}
    \caption{Interactions entre les différents composants de RozoFS pendant les
    opérations d'écriture et de lecture en \emph{layout} $0$ (i.e.\ $(n=3,k=2)$).
    Lorsqu'une application émet une requête, le client contacte le serveur de
    métadonnées afin d'obtenir la liste des supports de stockage $s_i$, au sein
    d'une grappe de serveurs $c_j$, relatifs à un fichier. Les serveurs de
    secours sont illustrés entre crochets. Les blocs de données correspondent à
    $d_k$ alors que les projections Mojette correspondent à $p_l$.}
    \label{fig.rozofs_interactions}
\end{figure}

La \cref{fig.rozofs_interactions} représente la situation où des opérations
d'écriture et de lecture sont respectivement déclenchées par client$_1$ et
client$_2$. Le premier client envoie une requête d'écriture vers le serveur de
métadonnées qui répond avec la liste d'identifiants de nœuds de stockage et d'un
identifiant de grappe (*cluster id*) relative à un fichier. Ces identifiants
sont en correspondance avec l'adresse IP des serveurs de stockage afin que les
clients puissent les joindre directement, et transmettre les données en
parallèle. En *layout* $0$, le client calcule une projection $p_1$ depuis les
données utilisateurs. La liste renvoyée par *exportd*
correspond à l'ensemble des identifiants des nœuds de stockage
$\{s_1,s_2,s_3\}$. Si l'un de ces nœuds n'est pas joignable, $s_4$ est défini
comme nœud de secours.
Après quoi de son côté, client$_2$ reçoit la même liste de la part d'*exportd*,
une fois qu'il a émis la requête de lire ce même fichier. Dans l'exemple de la
\cref{fig.rozofs_interactions} (cf. \cpageref{fig.rozofs_interactions}), une
panne survient sur le nœud $s_1$ lors de la lecture. En conséquence, le client
reçoit $d_2$ et $p_1$. Une fois obtenues, ces informations sont passées en
entrée du décodeur Mojette afin de reconstituer $d_1$.



# Évaluation {#sec.rozofs.perf}

Nous traitons ici l'expérimentation que nous avons réalisée. Sa mise en œuvre
est présentée dans la \cref{sec.oeuvre.expe}, tandis que les
\cref{sec.res.expe,sec.discussion.expe} présentent et analysent respectivement
les résultats.


## Mise en place de l'évaluation {#sec.oeuvre.expe}

Dans ce qui suit, on décrivons la configuration et les conditions de notre
expérimentation.


### Configuration des compétiteurs

CephFS est un compétiteur intéressant dans une comparaison avec RozoFS
puisqu'il s'agit d'un système de fichiers distribué POSIX basé sur des
techniques de réplication. Par défaut, CephFS propose une réplication par
trois, permettant de supporter deux pannes. En comparaison avec HDFS, CephFS
n'est pas conçu pour une application en particulier. L'architecture de CephFS
est représentée dans la \cref{fig.rozoceph_archi}
(cf.\ \cpageref{fig.rozoceph_archi}). Elle est composée de services similaires
à RozoFS. Toutefois, un service de monitorage supplémentaire est proposé afin
de vérifier par exemple l'état d'une grappe de serveurs.

Des éléments aussi complexes que des systèmes de fichiers distribués peuvent
être réglés avec de grandes quantités de paramètres. En conséquence, nous
suivrons les recommandations énoncées dans les documentations respectives. La
plupart du temps ces paramètres correspondent aux valeurs par défaut. Nous
configurons RozoFS en *layout* $1$ (i.e\ les écritures distribuent six fichiers
de projection et les lectures nécessitent quatre fichiers parmi eux), afin de
fournir la même capacité de correction que CephFS qui recommande par défaut de
la réplication par trois. Dans CephFS, un paramètre important concerne le
nombre de *placement group* (PG). Un PG agrège les objets dans un ensemble de
supports de stockage. Dans notre expérimentation, on dispose de $64$\ PGs pour
le stockage des objets, et $64$\ PGs pour les métadonnées.


### Mise en place de l'expérimentation

Toutes les expériences ont été réalisées sur la plate-forme expérimentale
Grid'5000\ \cite{balouek2013ccss}. En particulier, elles ont été conduites sur
la grappe \ct{econome}, composée de $22$ serveurs. Chaque serveur contient deux
CPU \intel Xeon E5-2660 cadencés à $2,2$\ Ghz, $64$\ Go de RAM, de $1$\ To de
disque dur SATA d'une vitesse de 7200 tours par minute, et d'une interface
réseau $10$\ GbE. Huit serveurs sont utilisés pour stocker les données. Un nœud
supplémentaire contient le serveur de métadonnées. Une machine supplémentaire
est nécessaire pour le monitorage de CephFS. Enfin, côté clients, neuf machines
sont réservées pour réaliser les opérations de lecture et d'écriture.


### Configuration de l'expérimentation

Nous avons utilisé le logiciel IOzone pour cette expérimentation. Il s'agit
d'un logiciel largement utilisé pour tester les systèmes de fichiers et les
supports de stockage. Il est possible de définir différents tests en fonction
de l'E/S désirée : lecture ou écriture; ainsi qu'en fonction du schéma d'accès
voulu : séquentiel ou aléatoire. La particularité d'IOzone est de fournir un
mode \ct{cluster} permettant de mesurer les bandes passantes dans le cas où
plusieurs clients sont impliqués simultanément dans l'expérimentation. Cette
particularité est adaptée aux systèmes de fichiers distribués. IOzone fournit
ainsi le débit, ou le nombre d'E/S par seconde (ESPS), mesuré au niveau de
chaque client. Dans notre expérimentation, un client implique une opération sur
un fichier de $100$\ Mo. En pratique, les accès séquentiels sont généralement
plus longs que les accès aléatoires. C'est pourquoi nous fixons la taille des
E/S en accès séquentiel à $64$\ Ko, et $8$\ Ko pour les tests en aléatoire
(valeurs classiques dans ce type d'expérimentation). Dans la suite, nous
évaluons le débit enregistré à mesure que l'on augmente le nombre de clients
(de $3$ à $9$) impliqués simultanément dans les opérations réalisées sur le
point de montage ciblé (RozoFS puis CephFS). Les résultats illustrés
correspondent à la moyenne de $30$ itérations. Les caches des clients sont
effacés entre chaque itération afin de garantir l'absence d'effet de cache du
côté client.


## Résultats de l'expérimentation {#sec.res.expe}

Nous verrons dans un premier temps les résultats de l'expérimentation en
écriture, avant de nous intéresser aux lectures.

### Évaluation en écriture

\begin{figure}
    \begin{subfigure}{.49\textwidth}
        \centering
        \tikzset{every picture/.style={scale=0.82}}
        \input{expe_data/seq_write.tex}
        \caption{Débits d'écriture séquentielle (Go/s).}
        \label{fig.seq_write}
    \end{subfigure}
    \begin{subfigure}{.49\textwidth}
        \centering
        \tikzset{every picture/.style={scale=0.82}}
        \input{expe_data/rand_write.tex}
        \caption{Débits d'écriture aléatoire (kESPS).}
        \label{fig.rand_write}
    \end{subfigure}
    \caption{Évaluation des performances d'écriture séquentielle et aléatoire.
    Les performances sont représentées comme les débits cumulés enregistrés par
    un nombre croissant de clients. La charge de travail correspond à
    l'écriture d'un fichier de $100$\ Mo par client simultanément. En
    particulier, les accès sont réalisés par blocs de $64$\ Ko et $8$\ Ko
    respectivement pour les accès séquentiels et aléatoires.}
    \label{fig.write_dfs}
\end{figure}

Dans cette section, nous étudions les performances de RozoFS et de CephFS en
écriture séquentielle, puis aléatoire. Les débits mesurés correspondent
au quotient de la taille du fichier écrit sur le temps nécessaire pour stocker
de façon \ct{sûre} la donnée. Cette \ct{sûreté} correspond à la confirmation que
la donnée est stockée de manière redondante au niveau des $n$ supports de
stockage. Notons cependant qu'en pratique, à un moment donné, la donnée peut
être contenue dans le cache d'un nœud de stockage et non de manière sûre sur le
support de stockage de masse sous-jacent.

La \cref{fig.write_dfs} illustre les débits obtenus à mesure que l'on augmente
le nombre de clients qui écrivent simultanément dans les points de montage.
Plus particulièrement, les \cref{fig.seq_write,fig.rand_write}
représentent respectivement les résultats pour des accès séquentiels et
aléatoires. Dans les deux cas, on observe que les performances de RozoFS sont
supérieures à celles fournies par CephFS. Alors qu'à mesure que l'on ajoute de
nouveaux clients, les performances de RozoFS augmentent jusqu'à une limite
correspondant à $2.7$\ Go/s en séquentiel, et $60000$\ ESPS en aléatoire, les
mesures obtenues pour CephFS n'évoluent pas de manière distinctive.

Il semble alors que RozoFS ait atteint les limites imposées par le matériel
(e.g.\ les disques ou le réseau), tandis que CephFS soit limité par des
considérations logicielles. Notre principale intuition à cette proposition est
la suivante. Durant l'écriture, grâce au code à effacement Mojette, RozoFS
génère, transfère et stocke une quantité d'informations largement inférieure à
CephFS (i.e.\ environ moitié moins comme nous l'avons vu dans la
\cref{fig.ec_vs_rep}, cf.\ \cpageref{fig.ec_vs_rep}). De plus, des spécificités
liées aux deux logiciels expliquent ces résultats. La plus importante correspond
au mode de transmission des données. Lors de l'écriture d'un fichier, RozoFS
gère en parallèle plusieurs requêtes d'écriture et est capable de profiter de
plusieurs liens réseaux lors de la distribution des blocs sur les différents
supports de stockage. En revanche, CephFS souffre de son mode de distribution
des répliquas. Lorsqu'une requête d'écriture est émise, CephFS copie un premier
répliqua sur un OSD primaire. Cet OSD est par la suite responsable de la
réplication et de la distribution des données aux seins des différents OSD du
PG. Cette distribution séquentielle des données entraîne un coût significatif
dans les débits mesurés.

\begin{figure}
    \centering
    \input{./expe_data/ceph_rep.tex}
    \caption{Impact du facteur de réplication sur les performances en écriture
    séquentielle dans CephFS. Ces performances correspondent aux débits
    cumulés relevés à mesure que l'on augmente le nombre de clients. Chaque
    client écrit un fichier de $100$\ Mo par blocs de $64$\ Ko. La valeur du
    facteur de réplication $r$ évolue dans l'ensemble $\{1,2,3\}$.}
    \label{fig.ceph_sequential_write}
\end{figure}

Pour mettre en évidence cette considération, nous avons réalisé une évaluation
des performances en écriture de CephFS. Les paramètres sont similaires à
l'expérience précédente, cependant, le facteur de réplication $r$ varie de $1$
à $3$. Les résultats de cette expérimentation sont fournis dans la
\cref{fig.ceph_sequential_write}. Par exemple, lorsque dix clients écrivent
simultanément, CephFS atteint un débit proche des $300$\ Mo/s quand aucune
copie d'information n'est générée (i.e.\ $r=1$). En revanche, la valeur de ce
débit chute à $120$\ Mo/s lorsque le système gère $r=3$ copies d'information.
Enfin un élément supplémentaire concerne la gestion de la cohérence des
données. Dans CephFS, un journal est tenu afin garantir des transactions
fiables. En conséquence, lorsqu'une E/S modifie la donnée, une E/S
supplémentaire est nécessaire pour enregistrer une entrée dans ce journal. Cela
réduit significativement les performances, en particulier lorsque plusieurs
répliquas sont en jeu (puisqu'autant d'entrées sont nécessaires dans le
journal). Un moyen de contrer ce problème est de mettre en place le journal sur
un disque séparé, ce qui aurait pu être mis en place sur une plate-forme plus
grande qu'*econome*.


### Évaluation en lecture

\begin{figure}
    \begin{subfigure}{.49\textwidth}
        \centering
        \tikzset{every picture/.style={scale=0.82}}
        \input{expe_data/seq_read.tex}
        \caption{Débits de lecture séquentiel (Go/s).}
        \label{fig.seq_read}
    \end{subfigure}
    \begin{subfigure}{.49\textwidth}
        \centering
        \tikzset{every picture/.style={scale=0.82}}
        \input{expe_data/rand_read.tex}
        \caption{Débits de lecture aléatoire (kESPS).}
        \label{fig.rand_read}
    \end{subfigure}
    \caption{Évaluation des performances de lecture séquentielle et aléatoire.
    Les performances sont représentées comme les débits cumulés enregistrés par
    un nombre croissant de clients. La charge de travail correspond à
    la lecture d'un fichier de $100$\ Mo par chaque client simultanément. En
    particulier, les accès sont réalisés par blocs de $64$\ Ko et $8$\ Ko
    respectivement pour les accès séquentiels et aléatoires.}
    \label{fig.read_dfs}
\end{figure}

On considère à présent les performances des deux systèmes en lecture. Les
résultats des tests sont illustrés dans la \cref{fig.read_dfs}. En particulier,
la \cref{fig.seq_read} présente les résultats en accès séquentiel.
Dans ce test, les performances de RozoFS sont $30$\% plus faibles que celles
fournies par CephFS. À la différence des opérations en écriture, la lecture met
en jeu la récupération de la même quantité d'informations pour les deux
systèmes. La différence provient probablement de la taille des blocs utilisés
dans chaque système. CephFS accède aux données par des blocs de $4$\ Mo, tandis
que RozoFS utilise des blocs de $4$\ Ko. En conséquence, le nombre d'E/S
nécessaire pour le premier est moins important et CephFS bénéficie des accès
séquentiels du test.

La \cref{fig.rand_read} présente les résultats obtenus en accès aléatoire. Dans
ce cas, les performances de RozoFS sont trois plus élevées que celles obtenues
par CephFS. Bien que les performances augmentent globalement pour les deux
systèmes, il est intéressant de remarquer que celles de RozoFS plafonnent
à proximité des $60000$ ESPS. Cette limite correspond à la même limite
rencontrée dans le test en séquentiel, et représentée dans la
\cref{fig.seq_write} (cf.\ \cpageref{fig.seq_write}). Les disques rotatifs
offrent généralement les mêmes performances en lecture ou écriture quand les
accès se font en aléatoire. En conséquence, cette limite correspond
probablement à la limite des performances des disques. Il serait intéressant de
vérifier si cette limite est repoussée dans le cas où on utilise soit plus de
disques durs (pour répartir la charge) soit des disques SSD.


## Discussion {#sec.discussion.expe}

Avant de conclure le chapitre, nous proposons de discuter dans un premier temps
des résultats obtenus dans notre expérimentation, puis du choix de la version
du code à effacement Mojette.

#### Choix de CephFS

CephFS a été choisi comme DFS de comparaison à RozoFS dans cette
expérimentation parce qu'il s'agit d'un logiciel libre, proposant un système de
fichiers compatible POSIX et de type *scale-out* (i.e.\ extension du système
par ajout de serveurs). Toutefois, ces systèmes sont trop complexes pour
pouvoir les comparer directement. Pour s'en convaincre, il suffit de considérer
les différences de conception, d'architecture, et de paramètres disponibles.
Sans toutes les énumérer, nous proposons de discuter de deux différences
fondamentales : Ceph est conçu pour la mise à l'échelle
et la cohérence des données. La mise à échelle repose principalement sur
l'algorithme décentralisé de distribution de données \textsc{Crush}, proposé par
\textcite{weil2007phd} dans ses travaux de thèse. Le second point, qui
concerne la cohérence des données, joue un rôle essentiel dans les mesures des
performances enregistrées. Ceph est un système de fichiers qui garde trace des
opérations de lecture et d'écriture afin de garantir une cohérence forte des
données et des transactions. En conséquence, chaque opération d'écriture sur
un OSD entraîne une seconde écriture dans le journal. En particulier, si le
facteur de réplication vaut $2$, une écriture de l'application revient à
déclencher $4$ opérations d'écritures ($1$ E/S sur deux OSDs, et $2$ E/S dans
le journal).

En conséquence, les résultats obtenus ne permettent pas clairement de se
prononcer sur quel est le système de fichiers le plus efficace. Toutefois, ces
résultats laissent apparaître le fait que RozoFS est capable de fournir de
bonnes performances, tout en divisant le volume de données stockées par deux.

#### Choix entre version systématique et non-systématique

Bien que l'on se soit focalisé sur des codes systématiques pour des raisons
de performance, les versions non-systématiques peuvent convenir pour d'autres
considérations. Nous proposons de discuter de deux avantages intéressants. Tout
d'abord, la distribution des données sous forme de projections peut permettre
de compliquer la lecture de la donnée à un tiers malveillant (les données ne
sont en effet pas stockées en clair). C'est le principe de l'algorithme de
dispersion d'information (ou IDA, pour *Information Dispersal Algorithm*) de
\textcite{rabin1989jacm}. Pour reconstituer exactement la donnée initiale, il
doit disposer de $k$ projections, ce qui signifie corrompre $k$ supports de
stockage.

L'équité de l'ensemble des symboles du mot de code constitue le deuxième
avantage de cette version. On s'intéresse ici au poids d'une projection dans la
distribution d'un bloc de données. En particulier, chaque projection d'un code
non-systématique possède le même poids. En revanche, dans le cas systématique,
l'opération de lecture tend à favoriser la récupération des $k$ premiers
symboles (i.e.\ les lignes de la grille) dans le cas du code systématique.
En conséquence, cela complique la prise de décision concernant par exemple, le
délai d'attente en lecture avant de réclamer une projection, lorsque le dernier
symbole systématique tarde à arriver.

Les \cref{sec.chap3,sec.chap4} ont montré que malgré le gain observé des
performances en systématique, la version non-systématique permet déjà de fournir de
très hauts débits. Le goulot d'étranglement du système réside alors soit dans
la partie matérielle (e.g.\ disques ou réseau), soit dans le surcoût impliqué
par la gestion logicielle du DFS (e.g.\ journalisation, réplication). Le
critère des performances n'est donc pour l'instant pas déterminant dans le choix
de la version du code. Par conséquent, l'utilisation du code non-systématique
dans RozoFS peut se justifier par les avantages présentés précédemment.
<!--
%; (ii)
%l'ensemble des nœuds à contacter pour récupérer un bloc de donnée. Dans le cas
%systématique, on essaie toujours de contacter les $k$ premiers, tandis qu'en
%non-systématique, on peut par exemple l'ensemble de le critère qui détermine quel ensemble de
%projections pour éviter le décodage, ou demand
-->



%cephfs

\section*{Conclusion du chapitre}

\addcontentsline{toc}{section}{Conclusion du chapitre}

Ce chapitre a permis de détailler la mise en œuvre du code à effacement Mojette
au sein du système de fichiers distribué RozoFS. La \cref{sec.dfs} a présenté
quelques notions sur les systèmes de stockage. En particulier, nous avons
expliqué l'évolution de la distribution des données sur des supports de
stockage depuis l'invention du RAID dans les années 80. On a par la suite
expliqué comment fonctionne un système de fichiers distribué et comment gérer
la redondance dans les systèmes de fichiers distribués actuels.

La \cref{sec.rozofs} a décrit le fonctionnement de RozoFS à travers ses trois
composants : (i) le serveur de métadonnées, (ii) les serveurs de stockage,
(iii) les clients. Nous avons également détaillé les interactions entre ces
éléments, et en particulier, le cas des entrées/sorties tolérantes aux pannes
grâce au code à effacement Mojette.

Dans une dernière partie, nous avons évalué les performances de RozoFS dans des
tests de charges intensives, menés sur la plate-forme de test Grid'5000. La
\cref{sec.rozofs.perf} donne une comparaison des performances de latence en
encodage et décodage, de RozoFS avec CephFS. Les résultats obtenus ont montré
que dans les conditions de nos tests, RozoFS est capable de fournir de
meilleures performances qu'un système de fichiers distribué basé sur de la
réplication, tout en divisant par deux le volume de stockage grâce au code à
effacement Mojette.

<!--
%Le DFS RozoFS est ainsi capable de gérer à la fois : (i)
les données froides (i.e.\ données à archiver), grâce à la capacité de
correction du code à effacement Mojette; (ii) et les données

%chaudes (i.e.\ nécessitant de , que stockage 
-->

