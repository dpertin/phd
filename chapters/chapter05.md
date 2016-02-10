
\chapter{Application au système de fichiers distribués RozoFS}

\label{sec.chap5}

\minitoc

\newpage

\section*{Introduction}

Les systèmes de stockage distribués reposent sur la redondance d'information
afin de supporter l'indisponibilité des données. Dans de tels systèmes,
l'apparition des pannes est devenue une norme plutôt qu'une exception
\cite{weil2006osdi}. Pour leur simplicité de mise en œuvre, les techniques de
réplication sont largement utilisées pour fournir cette redondance. Cependant,
ces techniques implique de stocker une quantité significative de redondance par
rapport à la donnée à protéger (e.g.\ $200$\% dans le cas de la réplication par
trois). Les codes à effacement proposent une alternative permettant de fournir
la même tolérance aux pannes, tout en diminuant significativement la quantité
de redondance nécessaire (généralement par un facteur $2$)
\cite{weatherspoon2001iptps, oggier2012survey}. Une des conséquences directes
du passage d'un système de données répliquées à encodées correspond à la
réduction énergétique du système de stockage.



# Notions sur les systèmes de fichiers distribués

## Systèmes de fichiers distribués (SFD)

## Redondance dans les SFD

La réplication par trois est configurée par défaut dans la plupart des systèmes
de stockage tel que *Hadoop Distributed File System* (HDFS)
\cite{shvachko2010msst}, ou encore *Google File System* (GFS)
\cite{ghemawat2003sosp}. Cependant, le facteur de réplication entraîne une
augmentation significative des systèmes de stockage. C'est pourquoi, la
réduction de la quantité de redondance est devenue une préoccupation importante
dans le milieu scientifique et industriel.

HDFS est l'une des solutions de stockage les plus populaires. Cette solution
offre un système de fichier extensible et tolérant aux pannes. Le modèle
*Map-Reduce* utilise HDFS afin de diviser et distribuer les tâches sur les
différents nœuds de travail \cite{dean2008acm}. En particulier, ce système de
fichiers est conçu pour accomplir des tâches d'analyse en parallèle sur de très
importants volumes de données immuables (i.e\ approche *write-once-read-many*).
Par exemple, les plus grosses grappes de nœuds expérimentées reposent sur
$4000$ serveurs qui agrègent une capacité totale de $14,25$ pétaoctets
exploitée par $14000$ clients simultanément \cite{shvachko2008hadoop}. Côté
performances, l'exploitation du parallélisme par Map-Reduce permet de trier un
téraoctet de données en une minute \cite{omalley2009hadoop}. HDFS est adapté
pour ce genre d'applications. En particulier, ce système de fichier travaille
de manière séquentiel sur d'importants blocs de données de $128$Mo par défaut.
Un bloc correspond à la plus petite quantité de données sur laquelle un système
de fichiers peut lire ou écrire. L'ensemble des opérations qu'il réalise est
effectué sur une quantité de données multiple de la taille d'un bloc.
La taille des blocs a une influence sur le système de stockage. L'utilisation
de grands blocs entraîne trois conséquences : (i) la réduction des interactions
entre les clients et le serveur de métadonnées; (ii) la réduction de la
quantité de métadonnée stockée; (iii) la réduction du trafic réseau en gardant
des connexions TCP persistantes \cite{ghemawat2003sosp}. Globalement, des blocs
de tailles importantes permettent d'augmenter les performances de lecture et
d'écriture dans le cas où de larges fichiers sont parcourus de manière
séquentielle (e.g.\ lecture d'une vidéo de haute
qualité). En effet, le support de stockage peut lire ou écrire la donnée de
manière continue, sans avoir à localiser le bloc suivant.  Cependant, une part
significative du bloc peut être perdue dans le cas où le fichier est plus petit
que la taille d'un bloc. En comparaison, les systèmes de fichiers POSIX
reposent sur de petites tailles de blocs (e.g.\ $4$Ko dans le cas de *ext4*
\cite{mathur2007linux}). Dans la suite, nous nous intéresserons à la conception
d'un système de fichiers distribué POSIX qui travaillera sur des blocs de
l'ordre de $4\text{-}8$Ko comme compromis entre la capacité d'accéder de
manière séquentielle les données, et le gaspillage d'espace au sein des blocs
\cite[p. 34]{gianpaolo1998fs}.

Alors que la réplication par trois est le paramètre de haute disponibilité par
défaut dans HDFS, \textcite{fan2009pdsw} ont développé une version modifiée
basée sur les codes de \rs, dénommée *DiskReduce*. Dans leur publication,
l'utilisation des codes à effacement permet de réduire le volume de stockage
d'un facteur de $2,4$. Cependant, cette technique est mise en œuvre en tâche de
fond, et permet d'encoder des blocs d'information de $64$ Mo issus des
répliquas, ce qui n'est pas adapté dans le cas des applications POSIX.
\textcite{muralidhar2014osdi} ont également utilisé les codes de \rs au sein
des grappes de stockage de \textsc{Facebook} pour des données considérées «
tièdes » (i.e.\ $80$ lectures par seconde).
GlusterFS\footnote{http://www.gluster.org/} et CephFS \cite{weil2006osdi} sont
d'autres exemples de système de fichiers distribués populaires. Par rapport à
HDFS, ils sont conçus pour des applications POSIX. Les techniques de
réplication sont par défaut utilisées pour fournir de la haute disponibilité
dans ces systèmes. Le codage à effacement est en revanche recommandé que dans
le cas d'applications liées aux données froides, telles que l'archivage.



# Principe de RozoFS

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
    Les similitudes correspondent aux : serveur de métadonnées (*exportd* et
    MDS), serveur de stockage (*storaged* et OSD) et aux clients
    (*rozofsmount*). De plus, CephFS utilise un service de monitorage (MON).
    Alors que les serveurs de stockage de RozoFS stockent des projections
    Mojette, ils contiennent des objets pour CephFS.}
    \label{fig.rozoceph_archi}
\end{figure}

Dans cette section, nous présenterons la conception des systèmes de fichiers
distribués RozoFS et CephFS. Ces deux systèmes sont à « code source ouvert » et
POSIX. En particulier, ils reposent sur un ensemble de système de fichiers
locaux sous-jacents. Une fois montés, ils fournissent un espace de noms globale
(i.e.\ un ensemble de répertoires et fichiers structuré comme une arborescence)
qui repose sur un ensemble de nœuds de stockage standards (*commodity*). Alors
que traditionnellement, CephFS repose sur des techniques de réplication, la
spécificité de RozoFS est d'être conçu sur la base du code à effacement
Mojette. La \cref{fig.rozoceph_archi} montre les similitudes entre
l'architecture de RozoFS en \cref{fig.rozo_archi}, et de CephFS en
\cref{fig.ceph_archi}, et met en avant la correspondance des noms entre les
différents services. Dans la suite, nous décrirons les composants de RozoFS et
leurs interactions, avant d'analyser les principales différences avec CephFS.

## L'architecture de RozoFS

L'architecture de RozoFS est composée de trois composants qui sont représentés
dans la \cref{fig.rozo_archi} :

1. Le service de gestion des métadonnées, appelé *exportd*;

2. Le service de stockage des projections, appelé *storaged*;

3. Les clients qui utilisent le processus *rozofsmount* pour monter RozoFS.

\noindent Dans la suite, ces différents composants sont décrits comme s'ils
étaient distribués sur différents serveurs.

#### Serveur de métadonnées

Ce serveur gère le processus *exportd* qui stocke les métadonnées, et gère les
différentes opérations qui sont liées. Les métadonnées correspondent à une
petite quantité d'information qui décrit la donnée elle même. Elles sont
composées d'attributs POSIX (e.g.\ horodatages des fichiers, permissions,
\dots) et des attributs étendus définis par RozoFS tels que la l'identification
ou la localisation des fichiers sur le système de stockage. Ce serveur
garde des statistiques sur la capacité des nœuds de stockage afin de répartir
la charge sur les différents disques. En particulier, dans le cas d'une demande
de lecture ou d'écriture, il fournit au client la liste des supports de
stockage relatifs aux informations d'un fichier. La haute disponibilité de ce
service n'est pour l'instant pas géré par RozoFS. En pratique, des logiciels
tiers tels que DRBD\footnote{http://www.drbd.org/} (pour la réplication du
service) et Pacemaker\footnote{http://clusterlabs.org/} (pour la haute
disponibilité) sont utilisés.

#### Nœud de stockage

Cette machine gère le service *storaged*. Deux fonctions sont gérées par ce
service : (i) la gestion des requêtes vers *exportd*; (ii) les *threads* d'E/S
des données qui gère les requêtes issues des clients en parallèle. De plus, ce
service est en charge de la réparation des nœuds de stockage. Lorsqu'un nœud
est définitivement perdu, il est nécessaire de reconstruire de la redondance
afin de rétablir la tolérance aux pannes du système. Nous verrons plus en
détail cette considération dans le \cref{sec.chap6}.

#### Les client RozoFS

Un client utilise le processus *rozofsmount* afin de monter localement un
volume défini par RozoFS. Ce processus utilise
FUSE\footnote{http://www.fuse.sourceforge.net} (*Filesystem in Userspace*) pour
intercepter les appels systèmes et définir les opérations distribuées de
RozoFS. Les clients gèrent deux types d'opération : (i) les opérations de
métadonnées (*lookup*, *getattr*, \dots) en interaction avec *exportd*; (ii)
les opérations d'E/S des données avec *storaged*. En particulier, les clients
sont responsables de l'encodage et du décodage lors des opérations d'écriture
et de lecture respectivement.



##  Les interactions entre les composants de RozoFS

### Distribution de l'information

\begin{table}[t]
    \centering
    \begin{tabular}{@{}l*4c@{}}
      \toprule
      Layout & $k$ & $n$ & nœuds de stockage & capacité de correction \\
      \midrule
      $0$ & $2$ & $3$ & $4$ & $1$ \\
      $1$ & $4$ & $6$ & $8$ & $2$ \\
      $2$ & $8$ & $12$ & $16$ & $4$ \\
      \bottomrule
    \end{tabular}
        \caption{Caractéristiques des trois layouts fournit par RozoFS. Les
        paramètres du code à effacement Mojette sont donnés par $(n,k)$. Le
        nombre minimum de supports de stockage correspond à $n + (n-k)$ afin de
        garantir une certaine capacité de stockage durant les opérations
        d'écriture.}
        \label{tab.layout}
\end{table}

La distribution des données sur plusieurs supports de stockage est définie par
les paramètres de l'encodage Mojette. Tel que l'on a vu dans les chapitres
précédents, un sous-ensemble de $k$ parmi les $n$ blocs encodés est suffisant
pour reconstruire l'information initiale. Les paramètres de protections,
appelés *layouts* dans RozoFS, définissent les valeurs de $k$, de $n$, ainsi
qu'un nombre minimal de supports de stockage requit afin de fournir une
capacité de correction face aux pannes, durant les opérations de lecture et
d'écriture.

Actuellement, trois *layouts* sont définis dans RozoFS. Le \cref{tab.layout}
représente les informations relatives à ces trois configurations. Chaque
*layout* correspond à un taux de codage de $r=\frac{3}{2}$. En conséquence, le
volume de données stocké vaut un peu plus de $1,5$ fois la taille du volume
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
    \caption{Scénarios d'écriture et de lecture en *layout* $0$ (i.e.\
    utilisant le code Mojette systématique $(3,2)$). Les
    \cref{fig.write,fig.read} concernent les situations sans dégradation, alors
    que les \cref{fig.write1,fig.read1} concernent des opérations dégradées.
    Les blocs de données, identifiés par $d_i$, et les projections Mojette,
    identifiées par $p_j$, sont distribués sur les supports de stockage $S_k$.
    Cette figure est inspirée de \cite{fan2009pdsw}.}
    \label{fig.scenarios}
\end{figure}


## Les entrées/sorties dans RozoFS

### Les opérations d'écriture

Une opération d'écriture déclenche un processus d'encodage Mojette. En
particulier, un flux de donnée à écrire est découpé en blocs de $\mathcal{M} =
4Ko$ par défaut. Ces blocs de données remplissent un buffer adressé par $k$
pointeurs, qui représentent les $k$ lignes d'une grille Mojette. Les *threads*
permettent de gérer plusieurs opérations d'encodage et de décodage en
parallèle. Plus précisément, puisque l'on considère le code à effacement
Mojette sous sa forme systématique, chaque *thread* du client calcule $(n-k)$
projections et transmet les $n$ blocs encodés sur $n$ supports de stockage. Les
supports concernés sont fournis par *exportd*. Prenons l'exemple de
l'écriture d'un gigaoctet d'information sur un volume RozoFS défini en *layout*
$0$, comme illustré dans la \cref{fig.write}. L'écriture distribue trois
fichiers contenant les informations de projections. Plus précisément, chaque
fichier fait environ $500$Mo tel que $d_1$ et $d_2$ contiennent les données en
clair, et $p_1$ contient les données de la projection suivant la direction
$(0,1)$.

### Les opérations de lecture

Lorsqu'une application demande la lecture d'une donnée présente sur le point de
montage de RozoFS, celui ci favorise la lecture des $k$ blocs de données en
clair (i.e.\ $d_1$ et $d_2$). Cette situation est représentée dans la
\cref{fig.read}. Le processus transfère alors environ $2 \times 500$Mo en
parallèle. Ensuite, la donnée est transmise à l'application.

### Impact en cas de pannes

La \cref{fig.write1} illustre la situation où une panne survient lors d'une
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
    opérations d'écriture et de lecture en *layout* $0$ (i.e.\ $(n=3,k=2)$).
    Lorsqu'une application émet une requête, le client contacte le serveur de
    métadonnée afin d'obtenir la liste des supports de stockage $s_i$, au sein
    d'une grappe de serveurs $c_j$, relatifs à un fichier. Les serveurs de
    secours sont illustrés par [~]. Les blocs de données correspondent à $d_k$
    alors que les projections Mojette correspondent à $p_l$.}
    \label{fig.rozofs_interactions}
\end{figure}

La \cref{fig.rozofs_interactions} représente la situation où des opérations
d'écriture et de lecture sont respectivement déclenchées par client$_1$ et
client$_2$. Le premier client envoie une requête d'écriture vers le serveur de
métadonnées qui répond avec la liste d'identifiant de nœuds de stockage et d'un
identifiant de grappe (*cluster id*) relatif à un fichier. Ces identifiants
sont en correspondance avec l'adresse IP des serveurs afin que les clients
puissent joindre directement les serveurs de stockage, en parallèle. En
*layout* $0$, le client calcule une projection $p_1$ depuis les données
utilisateurs. En conséquence, la liste renvoyée par *exportd* correspond à
l'ensemble des identifiants des nœuds de stockage $\{s_1,s_2,s_3\}$. Si l'un de
ces nœuds n'est pas joignable, $s_4$ est défini comme nœud de secours. De même,
client$_2$ reçoit la même liste depuis *exportd* quand il émet la requête de
lire le même fichier. Dans l'exemple de \cref{fig.rozofs_interactions}, une
panne survient sur le nœud $s_1$ lors de la lecture. En conséquence, le client
reçoit $d_2$ et $p_1$. Une fois obtenues, ces informations sont passés en
entrée du décodeur Mojette afin de reconstituer $d_1$.


### CephFS

CephFS est un compétiteur intéressant dans une comparaison avec RozoFS
puisqu'il s'agit d'un système de fichier distribué POSIX basé sur des
techniques de réplication. Par défaut, CephFS propose une réplication par
trois, permettant de supporter deux pannes.



# Évaluation

## Mise en place de l'évaluation

### Configuration des compétiteurs

Des éléments aussi complexes que des systèmes de fichiers distribués
peuvent être réglés avec de grandes quantités de paramètres. En conséquence,
nous suivrons les recommandations énoncées dans les documentations respectives.
La plupart du temps ces paramètres correspondent aux valeurs par défaut. Nous
configurons ainsi RozoFS en *layout* $1$ (i.e\ les écritures distribuent $6$
fichiers de projection et les lectures nécessitent $4$ fichiers parmi eux),
afin de fournir la même capacité de correction que CephFS qui utilise de la
réplication par trois. Dans CephFS, le nombre de *placement group* (PG) doit
être correctement choisi. Un PG agrège les objets dans un ensemble de support
de stockage. Dans notre expérimentation, on dispose de $64$ PGs pour le
stockage des objets, et $64$ PGs pour les métadonnées.

### Mise en place de l'expérimentation

Toutes les expériences ont été réalisées sur la plate-forme expérimentale
Grid5000. En particulier, elles ont été conduites sur la grappe « econome »,
composée de $22$ serveurs. Chaque serveur contient deux CPU \intel Xeon E5-2660
cadencés à $2,2$Ghz, $64$Go de RAM, de $1$To de disque dur SATA d'une vitesse
de 7200 tours par minute, et d'une interface réseau $10$GbE. En particulier,
$8$ serveurs sont utilisés pour stocker les données dans le cas de RozoFS et de
CephFS. Un nœud supplémentaire contient le serveur de métadonnées. Une machine
supplémentaire est nécessaire pour le monitorage de CephFS. Enfin, côté
clients, neuf machines sont réservées pour réaliser les opérations de lecture
et d'écriture.

### Configuration de l'expérimentation

Nous avons utilisé le logiciel IOzone pour cette expérimentation. Il s'agit
d'un logiciel populaire pour tester les systèmes de fichiers et les supports de
stockage. En particulier, il est possible de définir différents tests en
fonction de l'E/S désirée : lecture ou écrite; ainsi qu'en fonction du schéma
d'accès voulu : séquentiel ou aléatoire. La particularité d'IOzone est de
fournir un mode « cluster » permettant de mesurer les bandes passantes dans le
cas où plusieurs clients sont impliqués simultanément dans l'expérimentation.
Cette particularité est adaptée aux systèmes de fichiers distribués.
IOzone fournit ainsi le débit, ou le nombre d'E/S par seconde (ESPS), mesuré au
niveau de chaque client. Dans notre expérimentation, un client implique une
opération sur un fichier de $100$Mo. En pratique, les accès séquentiels sont
plus importants que les accès aléatoires. C'est pourquoi nous fixons la taille
des E/S en accès séquentiel à $64$Ko, et $8$Ko pour les tests en aléatoire. Il
s'agit de valeurs classiques dans ce genre de test. Dans la suite, nous
évaluons le débit enregistré à mesure que l'on augmente le nombre de clients
(de $3$ à $9$) impliqués simultanément sur un point de montage RozoFS, puis
CephFS. Les résultats illustrées correspondent à la moyenne de $30$ itérations.
Les caches des clients sont effacés entre chaque itération afin de garantir
l'absence d'effet de cache côté client.

## Résultats de l'expérimentation

Nous verrons dans un premier temps les résultats de l'expérimentation en
écriture, avant de nous intéresser aux lectures.

### Évaluation en écriture

\begin{figure}
    \begin{subfigure}{.49\textwidth}
        \centering
        \tikzset{every picture/.style={scale=0.82}}
        \input{expe_data/seq_write.tex}
        \caption{Débit d'écriture séquentielle (Mo/s).}
        \label{fig.seq_write}
    \end{subfigure}
    \begin{subfigure}{.49\textwidth}
        \centering
        \tikzset{every picture/.style={scale=0.82}}
        \input{expe_data/rand_write.tex}
        \caption{Débit d'écriture aléatoire (ESPS).}
        \label{fig.rand_write}
    \end{subfigure}
    \caption{Évaluation des performances d'écriture séquentielle et aléatoire.
    Les performances sont représentées comme les débits cumulés enregistrés par
    un nombre croissant de clients. La charge de travail correspond à
    l'écriture d'un fichier de $100$Mo par chaque client simultanément. En
    particulier, les accès sont réalisés par blocs de $64$Ko et $8$Ko
    respectivement pour les accès séquentiels et aléatoires.}
    \label{fig.write_dfs}
\end{figure}

Dans cette section, nous étudions les performances de RozoFS et de CephFS en
écriture séquentielle, puis aléatoire. Les débits mesurés correspondent
au quotient de la taille du fichier écrit sur le temps nécessaire pour stocker
de façon « sûre » la donnée. Cette « sureté » correspond à la confirmation que
la donnée est stockée de manière redondante au niveau des $n$ supports de
stockage. Notons cependant qu'en pratique, à un moment donné, la donnée peut
être contenue dans le cache d'un nœud de stockage et non de manière sûre sur le
support de stockage de masse sous-jacent.

La \cref{fig.write_dfs} illustre les débits obtenus à mesure que l'on augmente
le nombre de clients qui écrivent simultanément dans le point de montage pour
RozoFS et de CephFS. En particulier, les \cref{fig.seq_write,fig.rand_write}
représentent respectivement les résultats pour des accès séquentiels et
aléatoires. Dans les deux cas, on observe que les performances de RozoFS sont
supérieures à celles fournies par CephFS. Alors qu'à mesure que l'on ajoute de
nouveaux clients, les performances de RozoFS augmentent jusqu'à une limite
correspondant à $2.7$Go/s en séquentiel, et $60000$ ESPS en aléatoire, les
mesures obtenues pour CephFS n'évolue pas significativement.

Il semble alors que RozoFS ait atteint les limites imposées par le matériel
(e.g.\ les disques ou le réseau), tandis que CephFS soit limité par des
considérations logicielles. Notre principale intuition à cette proposition est
la suivante. Durant l'écriture, grâce au code à effacement Mojette, RozoFS
génère, transfère et stocke une quantité d'information significativement
inférieure à CephFS (i.e.\ environ moitié moins comme nous l'avons vu dans la
\cref{fig.ec_vs_rep}). De plus, des spécificités liées aux deux logiciels
expliquent ces résultats. Le plus important correspond au mode de transmission
des données. Lors de l'écriture d'un fichier, RozoFS gère en parallèle
plusieurs requête d'écriture et est capable de profiter de plusieurs liens
réseaux lors de la distribution des blocs sur les différents supports de
stockage. En revanche, CephFS souffre de son mode de distribution des
répliquas. Lorsqu'une requête d'écriture est émise, CephFS copie un premier
répliqua sur un OSD primaire. Cet OSD est par la suite responsable de la
réplication et de la distribution des données aux seins des différents OSD du
PG. Cette distribution séquentielle des données entraîne un coût significatif
dans les débits mesurés.

\begin{figure}
    \centering
    \input{./expe_data/ceph_rep.tex}
    \caption{Impact du facteur de réplication sur les performances en écritures
    séquentielles dans CephFS. Ces performances correspondent aux débits
    cumulés mesurés à mesure que l'on augmente le nombre de clients. Chaque
    client écrit un fichier de $100$Mo par blocs de $64$Ko. La valeur du
    facteur de réplication $r$ évolue dans l'ensemble $\{1,2,3\}$.}
    \label{fig.ceph_sequential_write}
\end{figure}

Pour mettre en évidence cette considération, nous avons réalisé une évaluation
des performances en écriture de CephFS. Les paramètres sont similaires à
l'expérience précédente, cependant, le facteur de réplication $r$ varie de $1$
à $3$. Les résultats de cette expérimentation sont fournis dans la
\cref{fig.ceph_sequential_write}. Par exemple, lorsque dix clients écrivent
simultanément, CephFS atteint un débit proche des $300$Mo/s quand aucune
copie d'information n'est générée (i.e.\ $r=1$). En revanche, la valeur de ce
débit chute à $120$Mo/s lorsque le système gère $r=3$ copies d'information.
Enfin un élément supplémentaire concerne la gestion de la cohérence des
données. Dans CephFS, un journal est tenu afin garantir des transactions
fiables. En conséquence, lorsqu'une E/S modifie la donnée, une E/S
supplémentaire est nécessaire pour enregistrer une entrée dans le journal. Cela
réduit significativement les performances, en particulier lorsque plusieurs
répliquas sont en jeu (puisqu'autant d'entrées sont nécessaires dans le
journal). Un moyen de contrer ce problème est de mettre en place le journal sur
un disque séparé, ce qui n'a pas pu être mis en place sur la plate-forme
*econome*.


### Évaluation en écriture

\begin{figure}
    \begin{subfigure}{.49\textwidth}
        \centering
        \tikzset{every picture/.style={scale=0.82}}
        \input{expe_data/seq_read.tex}
        \caption{Débit de lecture séquentiel (Mo/s).}
        \label{fig.seq_read}
    \end{subfigure}
    \begin{subfigure}{.49\textwidth}
        \centering
        \tikzset{every picture/.style={scale=0.82}}
        \input{expe_data/rand_read.tex}
        \caption{Débit de lecture aléatoire (ESPS).}
        \label{fig.rand_read}
    \end{subfigure}
    \caption{Évaluation des performances de lecture séquentielle et aléatoire.
    Les performances sont représentées comme les débits cumulés enregistrés par
    un nombre croissant de clients. La charge de travail correspond à
    la lecture d'un fichier de $100$Mo par chaque client simultanément. En
    particulier, les accès sont réalisés par blocs de $64$Ko et $8$Ko
    respectivement pour les accès séquentiels et aléatoires.}
    \label{fig.read_dfs}
\end{figure}

On considère à présent les performances des deux systèmes en lecture. Les
résultats des tests sont illustrés dans la \cref{fig.read_dfs}. En particulier,
la \cref{fig.seq_read} présente les résultats en accès séquentiel.
Dans ce test, les performances de RozoFS sont $30$\% plus faibles que celles
fournies par CephFS. À la différence des opérations en écriture, la lecture met
en jeu la récupération de la même quantité d'information pour les deux
systèmes. La différence provient probablement de la taille des blocs utilisée
dans chaque système. CephFS accède aux données par des blocs de $4$Mo, tandis
que RozoFS utilise des blocs de $4$Ko. En conséquence, le nombre d'E/S
nécessaire pour le premier est moins important et le comportement séquentiel du
test bénéficie à ce système.

La \cref{fig.rand_read} présente les résultats obtenus en accès aléatoire. Dans
ce cas, les performances de RozoFS sont trois plus élevées que celles obtenues
par CephFS. Bien que les performances augmentent globalement pour les deux
systèmes, il est intéressant de remarquer que celles de RozoFS plafonnent
à proximité des $60000$ IOPS. Cette limite correspond à la même limite
rencontrée en séquentiel dans la \cref{fig.seq_write}. Les disques rotatifs
offrent généralement les mêmes performances en lecture ou écriture quand les
accès se font en aléatoire. En conséquence, cette limite correspond
probablement à la limite des performances des disques. Il serait intéressant de
vérifier si cette limite est repoussée dans le cas où on utilise soit plus de
disques durs (pour répartir la charge) soit des disques SSD.

## Discussion


