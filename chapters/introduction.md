
%\section*{Contexte}

%\addcontentsline{toc}{section}{Contexte}

%### Contexte de l'étude

Le nombre d'appareils interconnectés par Internet augmente de manière
exponentielle. En $2003$, ce nombre était largement inférieur au
nombre d'habitant dans le monde (0.08 appareils par habitant en moyenne). Dans
son rapport sur l'évolution d'Internet, \citeauthor{evans2011cisco} estime que ce
nombre sera porté à plus de six appareils par habitant ($6,58$) d'ici
$2020$\ \cite{evans2011cisco}.
Si cette estimation s'avère juste, le nombre total d'appareils connectés
atteindra les $50$ milliards. L'analyse menée par le cabinet de conseil IDC,
auprès d'EMC (leader mondial des solutions de stockage), présente deux facteurs
permettant d'expliquer cette augmentation\ \cite{gantz2012idc}: (i) l'extension
d'Internet aux objets du quotidien, désignée par le terme
\ct{Internet des objets} (IoT pour *Internet of Things*); (ii) l'émergence de
nouveaux marchés numériques (Chine, Brésil, Inde, Russie, Mexique).
Afin de supporter cette croissance, Internet s'adapte : évolution des
protocoles (e.g.\ le passage à IPv6) et des infrastructures (e.g.\ construction
de centres de données). Les utilisateurs aussi s'adaptent et découvrent de
nouvelles applications (e.g.\ informatique en nuage, fouille de données).
<!--%-->
Dans ce contexte, le rôle des systèmes de stockage de données est
crucial. En effet, cette explosion du nombre d'appareils s'accompagne d'une
évolution exponentielle des données générées et stockées.
En particulier, le rapport d'IDC estime que la quantité de données stockées
dans le monde correspondra à $44$ zettaoctets\footnote{Si un caractère
nécessite un octet, un zettaoctet contiendrait plus de $200000$ milliards de
fois l'œuvre \emph{Le Monde Perdu} d'Arthur Conan Doyle.
\textcite{hilbert2011science} rappellent que ce volume de données correspond à
la quantité d'information génétique contenue dans un corps humain, mais que
\ct{par rapport à la capacité de la nature à traiter l'information, la capacité
du monde numérique évolue de façon exponentielle}.} (i.e.\ $10^{21}$ octets)
d'ici 2020 \cite{gantz2012idc}. Parmi cette quantité massive de données, on
notera que $27$\% seront générées par des objets connectés issus de l'IoT.
<!--%-->
La conception d'un système de stockage nécessite de considérer différents
critères (e.g.\ capacité de stockage, tolérance aux pannes, mise à l'échelle,
débits des lectures et écritures). Les systèmes centralisés (composés d'un seul
serveur) présentent des limites, notamment en ce qui concerne la mise à
l'échelle (les ressources du serveur sont limitées) et la tolérance aux pannes
(rien ne peut survivre à la perte du serveur). Pour satisfaire ces critères, il
est en conséquence nécessaire d'utiliser des systèmes de stockage distribués.
Un système distribué est défini par \textcite{tanenbaum2006book} comme \ct{un
ensemble de serveurs indépendants, dont les utilisateurs ont une vision
cohérente d'un système unique}. Les systèmes de stockage distribués offrent
donc une représentation cohérente d'un volume de stockage dont les données sont
réparties sur plusieurs serveurs. Dans la suite, nous utiliserons le terme
\ct{\emph{Networked Distributed Storage System}} (NDSS) défini par
\textcite{oggier2012icdcn} pour insister sur l'interconnexion des supports de
stockage à travers un réseau (e.g.\ bus, ethernet). En fonction de
l'application qui travaille sur les données du NDSS, certains critères ont
besoin d'être favorisés (pour des raisons économiques). Ainsi, nous allons voir
quatre exemples importants d'application qui nécessitent de grands volumes de
stockage :

* les services multimédias tels que la vidéo à la demande nécessitent de
grandes quantité de données. Par exemple, Netflix dispose pas moins
de $40$ pétaoctets (i.e.\ $10^{15}$ octets) de contenus vidéos sur
Amazon S3 \cite{hunt2014aws}. Cette application privilégie la mise à
l'échelle afin de supporter un pic de connexions (lors de la sortie d'un
nouveau contenu vidéo par exemple);

* le \ct{\emph{Big Data}} concerne la fouille et le traitement analytique d'une
quantité massive et non structurée de données. Les moteurs de recherche par
exemple, doivent gérer une quantité de données théoriquement limitée par
l'échelle d'Internet. Pour adresser ce problème, Google a développé
son propre système de fichiers distribué, *Google File System*
(GFS)\ \cite{ghemawat2003sosp}, ainsi que le modèle de programmation
*MapReduce*\ \cite{dean2008acm}. Ces outils permettent d'extraire des relations
entre différents types de contenus, tels que des données collectées sur les
pages web, les contenus générés par les utilisateurs, ou encore les données
proposées par les différents services Google (e.g.\ maps, shopping);
<!--
%utilise des algorithmes afin de proposer sur la base de
%différents critères (e.g.\ les anciens achats, des évaluations de produits, la
%comparaison avec d'autres clients, la présence d'articles dans le panier) des
%recommandations \cite{linden2003ic}. Ce type d'applications nécessitent une
%importante quantité de données;
-->

* le calcul à haute performance (HPC, pour *High Performance Computing*)
traite le cas d'importantes quantités de données structurées. Par exemple,
\textcite{zwaenepoel2015wos} adresse le problème de l'optimisation du
traitement d'analyse d'un graphe très large (i.e.\ $32$ milliards de sommets, et
$10^{12}$ arêtes) par un système distribué constitué de seulement $32$
serveurs. Ce type d'application nécessite principalement de hauts débits en
lecture et écriture;
<!--
%e nœuds
%est possible d'analyser et d'explorer les graphes que forment les réseaux
%sociaux. Il est ainsi possible d'établir des profils de personnalité en se
%basant sur les « *likes* » enregistrés sur
%\textsc{Facebook}\ \cite{youyou2015computer}. Les systèmes de stockage de hauts
%débits favorisent ces applications;
-->

* l'archivage de données en revanche ne possède pas de contraintes fortes sur
les débits. Toutefois, cette application a besoin de DSS avec d'importantes
capacités de stockage, et, qui soient tolérants aux pannes. Par exemple,
Amazon Glacier fournit
un : \ct{service de stockage sécurisé, durable et à très faible coût pour
l'archivage (\dots) de données rarement consultées et pour lesquelles un délai
d'extraction de plusieurs heures reste
acceptable}\footnote{https://aws.amazon.com/fr/glacier/}.

<!--
% http://fr.slideshare.net/AmazonWebServices/ent209-netflix-cloud-migration-devops-and-distributed-systems-aws-reinvent-2014
-->

<!--
% https://code.facebook.com/posts/1433093613662262/-under-the-hood-facebook-s-cold-storage-system-/
-->

% système de stockage distribué

\section*{Problèmes du stockage distribué identifiés}

\addcontentsline{toc}{section}{Problèmes du stockage distribué identifiés}

Nous avons vu précédemment des applications qui répondent à des problèmes
différents. L'offre des systèmes de stockage est en conséquence fragmentée afin
de favoriser certains des critères énoncés. Par exemple, les délais garantis
par Amazon Glacier ne sont pas appropriés pour gérer des données sur lesquelles
seront exécutés des traitements HPC. À l'inverse, le coût d'une grappe de
calcul est beaucoup trop élevé pour y archiver des données. On peut ainsi
différencier deux types de données : (i) les données froides qui correspondent
à du contenu peu accédé (utilisé typiquement dans les applications d'archivage
où les données sont écrites une fois pour être sollicitées à l'occasion); (ii)
les données chaudes, qui à l'inverse sont fréquemment sollicitées (typiquement
le cas des applications HPC qui mettent en jeu plusieurs milliers
d'entrées/sorties à la seconde). Les administrateurs des systèmes de stockage
sont souvent contraints de définir deux systèmes de stockage différents (un
système coûteux pour le traitement intensif, l'autre bon marché pour archiver
des données). Dans ce formalisme, notre premier problème consiste alors à
\textbf{concevoir un système de stockage capable de gérer aussi bien les
données froides, que les données chaudes}.

Les applications citées précédemment peuvent interagir avec une quantité
massive de données (de l'ordre du pétaoctet par exemple). Il est donc
nécessaire de concevoir des systèmes de stockage capables de supporter une
charge de plus en plus importante. Les besoins de l'application peuvent
également évoluer dans le temps, et nécessiter moins de capacité de stockage.
L'approche verticale (*scale-up*) consiste à migrer les données vers des
supports de stockage de plus grandes capacités, avant que la capacité du
système de stockage ne soit atteinte. Cette approche n'est ni flexible (limite
de la taille des ressources) ni économique (requiert d'acheter du matériel
récent). Notre second problème consiste alors à \textbf{permettre l'allocation
dynamique des ressources de stockage}.

% scale-out NAS

Les systèmes de stockage sont sujets à des défaillances inévitables. Ces
défaillances entraînent l'inaccessibilité temporaire, voire la perte
définitive, de blocs de données\ \cite{ford2010osdi}. En particulier, la
probabilité d'apparition des pannes augmente avec la taille du système de
stockage (e.g.\ défaillance d'un disque, défaillance réseau). Il est donc
nécessaire d'intégrer de la redondance dans le système de stockage. La
solution classique pour supporter ces pannes consiste à exploiter la nature des
NDSS en distribuant plusieurs copies des blocs de données sur des supports de
stockage différents. Cette méthode permet d'accéder à la copie d'un
bloc lorsque les autres ne sont pas disponibles. Bien que simple à
mettre en œuvre, chaque copie générée ajoute un surcoût de redondance de
$100\%$. Cette méthode implique alors un coût de stockage important.
Notre troisième problème consiste à \textbf{garantir un seuil de redondance
permettant au NDSS de supporter les pannes, tout en minimisant cette quantité
de redondance}.

Une fois qu'un seuil de redondance est mis en place dans le NDSS, les pannes
inévitables entraînent nécessairement la réduction de cette redondance dans le
temps. Notre quatrième problème sera de \textbf{rétablir un seuil de
redondance}. Pour résumer, les quatre problèmes identifiés dans cette section
visent à concevoir un NDSS capable :

<!--
%Il est alors
%nécessaire de concevoir une méthode pour rétablir la redondance. Cette
%réparation nécessite l'échange de données entre un ensemble de supports de
%stockage sains, et un support en reconstruction. Par exemple, un nœud de
%stockage chez Facebook fait $15$\ Po (i.e.\ $10^3$\ Go)\
%\cite{sathiamoorthy2013vldb}. La réparation d'une telle quantité de données
%entraîne en conséquence un trafic réseau significatif, qui peut prendre un
%temps considérable (plusieurs jours si plusieurs pannes surviennent
%simultanément) et ralentir le fonctionnement des services qui utilisent les
%données du NDSS. Ce problème consiste alors à rétablir un seuil de redondance
%tout en minimisant la quantité de données échangées entre les différents
%supports de stockage. Ce troisième point de nos problématiques est appelé «
%problème de réparation » (*repair problem*)\ \cite{dimakis2010toit}.
-->


1. de gérer les données chaudes (i.e.\ délivrant de très hauts débits de lecture
et d'écriture) ainsi que les données froides (i.e.\ tolérant aux pannes);

2. d'adapter dynamiquement ses ressources de stockage;

3. de minimiser la redondance nécessaire pour supporter les pannes;

4. de maintenir cette redondance dans le temps.


\section*{Notre approche}

\addcontentsline{toc}{section}{Notre approche}

Afin de minimiser la redondance, notre approche sera d'utiliser des codes à
effacement. Cette méthode permet de réduire considérablement la quantité de
redondance générée par rapport aux techniques de réplication (typiquement d'un
facteur
$2$)\ \cite{weatherspoon2001iptps,oggier2012icdcn,cook2014hitachi}. En
particulier les codes optimaux (dits MDS pour *Maximum Distance Separable*)
minimisent la quantité de redondance nécessaire pour protéger les données. Les
codes de \rs sont largement utilisés parce qu'ils sont
MDS\ \cite{reed1960jsiam}. Ils sont ainsi utilisés dans plusieurs DFS tels
que CephFS\ \cite{weil2006osdi} ou DiskReduce\footnote{DiskReduce est une
modification de \emph{Hadoop Distributed File System} (HDFS) qui intègre les
codes de \rs. HDFS est un DFS open-source basé sur \emph{Google File System}
(GFS)\ \cite{ghemawat2003sosp}.} \cite{fan2009pdsw}. Des fournisseurs de
services en nuage tels que Microsoft Azure\ \cite{huang2012atc} ou Openstack
avec Swift\ \cite{luse2014snia} l'utilisent également. L'utilisation des codes
de \rs dans les systèmes de stockage s'est démocratisée avec le développement
de bibliothèques qui en fournissent des implémentations. En particulier, Ceph
et Swift ont intégré la bibliothèque ISA-L (*Intelligent Storage Acceleration
Library*) d'\textcite{intel2015isal}.

En revanche, les codes à effacement impliquent une complexité significative due
aux opérations d'encodage et de décodage. Dans le contexte de stockage, ces
opérations sont déclenchées respectivement à l'écriture et à la lecture de
blocs de données. En conséquence, leur utilisation est généralement limitée aux
systèmes qui stockent des données froides.
Il est toutefois possible de réduire l'impact de ces opérations en
utilisant le code sous une forme systématique. Sous cette forme, les données
encodées contiennent deux parties : (i) une première partie contient exactement
le message à transmettre; (ii) la seconde partie correspond à des données de
redondance. Cette forme permet notamment de ne pas avoir à décoder
l'information lorsque la partie contenant le message est disponible. En
conséquence, sous cette forme, les débits en lecture et écriture sont plus
importants. La conception d'un code sous cette forme sera le sujet d'une de nos
contributions dans ce travail de thèse.

<!--
%En conséquence, on distingue deux types de systèmes de stockage : (i)
%le premier permettant d'archiver les données à bas prix, reposant sur du
%matériel de stockage de grande capacité et bon marché (bandes ou disque durs
%mécaniques) et utilisant des codes à effacement\ \cite{andre2014eurosys} ; (ii)
%le second utilisant (potentiellement) des techniques de réplication sur du
%matériel performant et coûteux (disques SSD, RAM) afin de traiter les données
%chaudes sans ralentissement.
-->

Pour la conception d'un NDSS, nous proposons d'utiliser une
approche horizontale (*scale-out*). Cette approche consiste à composer un
ensemble flexible de serveurs de stockage (on parle de grappe). Cette approche
permet d'adapter le nombre de serveurs (physiques, virtuels ou les deux)
participant à la grappe de stockage. Il est ainsi possible d'augmenter
ou de réduire la capacité du système. Cette approche est en conséquence plus
flexible et plus économique que l'approche *scale-up*\ \cite{oggier2012icdcn}.
En particulier, nous proposons d'utiliser RozoFS : un logiciel qui définit un
système de stockage (ou SDS ou *Software-Defined Storage*). Plus précisément,
RozoFS est un système de fichiers distribué (ou DFS pour *Distributed File
System*), ce qui correspond à un NDSS permettant d'interagir avec des fichiers.
Notons que d'autres représentations de la donnée existent telles que la forme en
blocs (interface proposée par les disques) ou en objets (interface au cœur du
DFS Ceph\ \cite{weil2006osdi}).
En particulier, il permet d'agréger l'espace disponible depuis un ensemble de
supports de stockage. Cette agrégation est exposée à l'utilisateur sous la
forme d'un volume de stockage organisé par une arborescence (fichiers et
répertoires). En particulier, RozoFS est orienté pour les réseaux locaux
(*LAN*) rapides (très haut débit, faible latence). Notre approche se distingue
alors des architectures pair-à-pair (ou P2P pour *Peer-to-Peer*) et du stockage
sur réseaux étendus (*WAN*) de latences plus importantes.
RozoFS correspond ainsi à une couche de virtualisation capable d'exploiter du
matériel varié et bon marché. Cette solution est alors plus flexible et moins
onéreuse. En particulier, RozoFS est un logiciel libre sous licence GNU
GPLv2\footnote{Le projet GitHub de RozoFS est accessible à l'adresse suivante :
\url{https://github.com/rozofs/rozofs}} dans lequel il nous sera possible
d'intégrer nos contributions.


<!--
%Depuis quelques années, cette réduction du volume de données tolérant aux
%pannes a motivé plusieurs acteurs du monde du stockage à utiliser des codes à
%effacement. Parmi eux, on compte trois types d'acteurs : (i) des entreprises
%développant des solutions de stockage comme Cleversafe \cite{dhuse2010patent},
%NetApp \cite{storer2015patent} ou Streamscale \cite{anderson2014patent} ; (ii)
%plusieurs projets académiques se sont également développés comme OceanStore
%\cite{kubiatowicz2000sigplan} ou DiskReduce \cite{fan2009pdsw} ; (iii) et
%enfin, plusieurs acteurs majeurs s'y intéressent pour leurs service Cloud tels
%que Microsoft pour Azure \cite{huang2012atc}, OpenStack avec Swift
%\cite{luse2014snia} ou Amazon pour
%Glacier\footnote{https://aws.amazon.com/fr/glacier/}.
%
%Bien que de nombreux codes à effacement existent, la plupart de ces services
%utilisent les codes de \textcite{reed1960jsiam}. Ces codes sont devenu les plus
%populaires pour deux raisons : (i) leur capacité de correction peut être fixée
%arbitrairement ; (ii) leur rendement est optimal (pour une capacité de
%correction donnée, la quantité de redondance générée est minimale). En
%revanche la complexité ajoutée par les opérations d'encodage et de décodage des
%codes de \rs 
-->


\section*{Contributions}

\addcontentsline{toc}{section}{Contributions}

Nous proposons une approche basée sur la géométrie discrète, dans l'objectif de
proposer une nouvelle représentation du problème de correction des effacements.
En particulier, cette nouvelle approche permet l'élaboration de nouveaux
algorithmes pour le codage à effacement. Dans cette optique, nous proposons
d'étudier la transformation de \radon qui est une application mathématique
pouvant être utilisée afin de représenter des données de manière redondante.
Des travaux sur une version discrète de cette transformation, la
\ct{transformation de \radon finie} (ou FRT pour *Finite Radon Transform*) ont
déjà permis de concevoir un code à effacement MDS\ \cite{normand2010wcnc}.
Dans ce travail de thèse, nous proposons l'utilisation d'une autre version
discrète de cette application : la transformation
Mojette\ \cite{guedon1995vcip}. Il a notamment été établi que la transformée
Mojette dispose d'un algorithme de reconstruction itératif, permettant de
reconstruire les données avec une complexité linéaire\ \cite{normand2006dgci}.
La conception d'un code systématique, basé sur cette transformée, est motivée
par l'objectif de bénéficier d'un code fournissant de bonnes performances en
encodage et en décodage. Cette motivation est étendue à l'intégration du code
dans RozoFS, afin de fournir un DFS capable de fournir de bonnes performances
en lecture et écriture, tout en tolérant les pannes avec une quantité minimum
de redondance (code MDS).
Ce travail de thèse a ainsi conduit aux contributions suivantes :

1. la conception d'une version systématique du code à effacement basé sur la
transformation Mojette;

2. une comparaison théoriques de notre code avec différentes alternatives
(e.g.\ les codes de \rs), basée sur une proposition de critère de comparaison;

3. une implémentation des codes Mojette, ainsi qu'une évaluation des
latences d'encodage et de décodage (comparaison avec les codes de \rs fournis
dans ISA-L));

4. une comparaison du coût de la redondance des versions systématique et
non-systématique du code Mojette avec les codes MDS (e.g.\ \rs);

5. l'intégration du code à effacement Mojette systématique dans RozoFS,
ainsi qu'une comparaison des performances fournies en lecture et en écriture
avec le DFS CephFS, basé sur la technique de réplication;

6. une méthode pour ré-encoder de la redondance de façon distribuée, sans
reconstruction explicite de la donnée initiale, dans l'objectif de rétablir un
seuil de redondance au sein du NDSS.


\section*{Plan du manuscrit}

\addcontentsline{toc}{section}{Plan du manuscrit}

Les travaux de cette thèse sont organisés en deux parties qui comportent
chacune trois chapitres. La première partie utilise conjointement théorie de
l'information et géométrie discrète afin de concevoir un code à effacement basé
sur une version discrète de la transformation de \radon. En particulier, cette
partie conduit à l'élaboration de notre première contribution : le code à
effacement Mojette sous sa forme systématique. Les éléments abordés dans cette
partie touchent l'ensemble des applications de transmission de données. Les
trois chapitres qui le composent présentent les éléments suivants :

1. dans le \cref{sec.chap1}, nous introduisons des notions de la théorie de
l'information nécessaires afin d'établir un état de l'art des codes à
effacement. Ces notions vont permettre de présenter les principes des codes
correcteurs appliqués au canal à effacement. Nous verrons ainsi quelques
exemples qui représentent les grandes familles de codes à effacement (codes MDS
et non-MDS);

2. le \cref{sec.chap2} introduit la transformation de \radon. Ce chapitre
utilise conjointement la géométrie discrète et la théorie des codes. La
géométrie discrète permettra de définir deux versions discrètes de la
transformation de \radon : la FRT et la transformation Mojette. La théorie des
codes sera nécessaire pour concevoir et comprendre les propriétés des codes à
effacement basés sur ces transformations. Nous verrons ainsi que la FRT donne
un code MDS, tandis que la transformation Mojette dispose d'un algorithme de
décodage itératif efficace;

3. la première contribution est énoncée dans le \cref{sec.chap3}. Cette
contribution est une nouvelle conception du code à effacement Mojette sous sa
forme systématique. Cette conception a des avantages sur le rendement du code
et permet de tendre d'avantage vers un code MDS. Dans un deuxième temps, un
algorithme de décodage adapté à cette forme est donné. 
Nous évaluerons ainsi la quantité de redondance générée par cette nouvelle
forme par rapport à la version classique et au cas MDS. Cette évaluation
permet de mettre en évidence le rendement quasi-MDS de notre conception.

\noindent La première partie ayant permis la conception du code à effacement
Mojette, la seconde partie s'intéresse à son intégration dans le contexte des
systèmes de stockage distribués. Dans cette partie, les deux premiers chapitres
mettent en avant l'utilisation du code à effacement Mojette dans une
architecture de stockage distribué, puis spécifiquement dans RozoFS. Le
troisième chapitre tente de répondre au problème de réparation. Plus
particulièrement, les différents chapitres comportent les éléments suivants :

1. le \cref{sec.chap4} présente une analyse théorique et expérimentale des
performances du code Mojette dans le contexte du stockage distribué. Les
métriques utilisées (nombres d'opérations à l'encodage et au décodage, nombre
de blocs impacté par la mise à jour de données) mettent en avant la simplicité
algorithmique du code Mojette par rapport à d'autres codes (e.g.\ codes de \rs).
En particulier, une mesure des latences en encodage et décodage des
implémentations du code Mojette est donnée. Dans les conditions de nos tests,
notre nouvelle conception systématique permet de réduire par trois les temps
d'encodage par rapport à la forme classique. De plus, aucun décodage n'est
nécessaire en lecture, dans le cas où aucune panne ne survient. En particulier,
ces mesures montrent également que notre implémentation est plus performante
que l'implémentation des codes de \rs fournit dans ISA-L;

2. la mise en œuvre et l'intégration du code à effacement Mojette dans le
système de fichiers distribué RozoFS est expliquée dans le \cref{sec.chap5}.
Une évaluation menée sur la plate-forme GRID-5000 permet de
montrer que dans le cadre de nos tests, RozoFS est capable de fournir de
meilleures performances que des systèmes basés sur de la réplication, tout en
réduisant d'un facteur $2$ le volume total stocké;

3. notre contribution sur le rétablissement du seuil de redondance du NDSS est
fournie dans le \cref{sec.chap6}. Cette contribution concerne la conception
d'une nouvelle méthode distribuée pour calculer de nouveaux symboles de mots de
code. Cette méthode peut être utilisée afin de maintenir le système de stockage
à un niveau de redondance désiré. Une évaluation est réalisée afin de mettre en
avant le bénéfice de la distribution des calculs.

\noindent Dans une dernière partie, nous aborderons la conclusion des travaux
présentés dans cette thèse, ainsi que la perspective des futurs travaux de
recherche.


\section*{Contexte de la thèse}

\addcontentsline{toc}{section}{Contexte de la thèse}

Dans le cadre d'une convention CIFRE, ces travaux de recherche ont été menés
conjointement au sein de l'équipe Image et Vidéo Communications (IVC) de
l'Institut de Recherche en Communications et Cybernétique de Nantes (IRCCyN),
et au sein de l'entreprise Rozo Systems. Cette entreprise développe le système
de fichiers distribué RozoFS.

Une partie de ce travail de recherche a également été financée par le projet
ANR FEC4Cloud (appel Emergence 2012). Ce projet a pour objectifs d'analyser et
de concevoir des codes à effacement pour le stockage distribué. Les partenaires
de ce projet sont l’IRCCyN (coordinateur), Supaero-ISAE et la SATT Ouest
Valorisation.

