
\section*{Contexte}

\addcontentsline{toc}{section}{Contexte}

%### Contexte de l'étude

Le nombre d'appareils interconnectés par Internet augmente de manière
exponentielle. Alors qu'en moyenne moins d'un appareil connecté (0,08) était
détenu par habitant dans le monde en $2003$ ($0,08$), on estime que ce nombre
sera porté à plus de six ($6,58$) d'ici $2020$, totalisant $50$ milliards de
terminaux\ \cite{evans2011cisco}. Deux facteurs permettent d'expliquer cette
augmentation : (i) l'extension d'Internet aux objets du quotidien, désignée par
le terme « Internet des objets » (IoT pour *Internet of Things*); (ii)
l'émergence de nouveaux marchés numériques (Chine, Brésil, Inde, Russie,
Mexique)\ \cite{gantz2012idc}.
Afin de supporter cette croissance, Internet s'adapte : évolution des
protocoles (e.g.\ le passage à IPv6) et des infrastructures (e.g.\ construction
de centres de données). Les utilisateurs aussi s'adaptent et découvrent de
nouvelles applications (e.g.\ informatique en nuage, fouille de données).
<!--%-->
Dans ce contexte, le rôle des systèmes de stockage de l'information est
crucial. En effet, cette explosion du nombre d'appareils s'accompagne d'une
évolution exponentielle des données générées et stockées.
En particulier, la quantité d'information stockée dans le monde sera estimée à
$44$ zettaoctets\footnote{Si un caractère nécessite un octet, un zettaoctet
contiendrait plus de $200000$ milliards de fois l'œuvre \emph{Le Monde Perdu}
d'Arthur Conan Doyle. \textcite{hilbert2011science} rappellent que ce volume de
données correspond à la quantité d'information génétique contenue dans un corps
humain, mais que « par rapport à la capacité de la nature à traiter
l'information, la capacité du monde numérique évolue de façon exponentielle ».}
(i.e.\ $10^{21}$ octets) d'ici 2020 \cite{gantz2012idc}. Parmi cette quantité
massive de données, on notera que $27$\% seront générées par des objets
connectés issus de l'IoT.
<!--%-->
Le stockage de cette information permet de très nombreuses applications. La
conception d'un système de stockage nécessite de répondre à certains critères
(e.g.\ capacité de stockage, mise à l'échelle, débits en entrées/sorties). Il
est plus facile d'atteindre ces critères, lorsque l'on considère le cas des
systèmes de stockage distribués (ou DSS pour *Distributed Storage System*). Les
DSS permettent de partager l'espace mémoire entre différents supports
de stockage. En fonction de l'application qui travaille sur les données du DSS,
certains critères n'ont pas besoin d'être remplis (pour des raisons
économiques). Ainsi, nous allons voir quatre exemples importants d'application
qui nécessite de grands volumes de stockage :

* les services multimédia telle que la vidéo à la demande nécessitent de
grandes quantité de données. Par exemple, \textsc{Netflix} dispose de pas moins
de $40$ pétaoctets (i.e.\ $10^{15}$ octets) de contenus vidéos sur
\textsc{Amazon} S3. Cette application privilégie la mise à l'échelle afin de
supporter un pic de connexions (lors de la sortie d'un nouveau contenu vidéo
par exemple);

* les applications « Big Data » permettent la fouille et le traitement
analytique d'une quantité non structurée et massive de données. Par exemple,
\textsc{Amazon} utilise des algorithmes afin d'analyser différents critères
(e.g.\ les anciens achats, des évaluations de produits, la comparaison avec
d'autres clients, la présence d'articles dans le panier) pour alimenter son
système de recommandation. Ces applications nécessitent une importante quantité
de données;

* le calcul à haute performance (HPC, pour *High Performance Computing*)
traite le cas d'importantes quantités de données structurées. Par exemple, il
est possible de déterminer des profils de personnalité en se basant sur les
« *likes* » enregistrés sur \textsc{Facebook} \cite{youyou2015computer}. Les
systèmes de stockage de hauts débits favorisent ces applications;

* l'archivage de données n'a pas de contraintes fortes sur les débits. En
revanche, cette application a besoin de systèmes de stockage avec d'importantes
capacités et tolérants aux pannes.

<!--
% http://fr.slideshare.net/AmazonWebServices/ent209-netflix-cloud-migration-devops-and-distributed-systems-aws-reinvent-2014
-->

<!--
% https://code.facebook.com/posts/1433093613662262/-under-the-hood-facebook-s-cold-storage-system-/
-->

% système de stockage distribué

\section*{Problématiques}

\addcontentsline{toc}{section}{Problématiques}

Les applications citées précédemment peuvent interagir avec une quantité
massive de données (de l'ordre du pétaoctet par exemple). Il est donc
nécessaire de concevoir des systèmes de stockage capables de supporter une
charge de plus en plus importante. Les besoins de l'application peuvent
également évoluer dans le temps, et nécessiter moins de capacité de stockage.
L'approche verticale (*scale-up*) consiste à migrer les données vers des
supports de stockage de plus grandes capacités, avant que la capacité du
système de stockage ne soit atteint. Bien que facile à mettre en œuvre, cette
approche n'est ni flexible (limite de la taille des ressources) ni économique.
Notre premier problème consiste alors à pouvoir allouer dynamiquement les
ressources de stockage.

% scale-out NAS

Les systèmes de stockage sont sujets à des défaillances inévitables. Ces
défaillances entraînent l'inaccessibilité temporaire, voire la perte
définitive, de blocs de données\ \cite{ford2010osdi}. En particulier, la
probabilité d'apparition des pannes augmente avec la taille du système de
stockage (e.g.\ défaillance d'un disque, défaillance réseau). Il est donc
nécessaire d'intégrer de la redondance dans le système de stockage. La
solution classique pour supporter ces pannes exploite la nature des DSS. Elle
consiste à distribuer plusieurs copies d'information sur des supports de
stockage différents. Cette méthode permet d'accéder à une copie de
l'information lorsque les autres ne sont pas disponibles. Bien que simple à
mettre en œuvre, chaque copie générée ajoute un surcoût de redondance de
$100\%$. Cette méthode implique alors un coût de stockage important.
Notre second problème consiste à calculer une quantité minimale de redondance
afin de protéger les données du DSS face aux pannes.

Une fois qu'un seuil de redondance est mis en place dans le DSS, les pannes
entraînent la réduction de cette redondance. Il est alors
nécessaire de concevoir une méthode pour rétablir la redondance. Cette
réparation nécessite l'échange d'information entre un ensemble de supports de
stockage sains, et un support en reconstruction. Se pose alors
la question de comment rétablir un seuil de redondance tout en minimisant
la quantité de données échangées entre les différents supports de stockage. Ce
troisième point de nos problématiques est appelé « problème de réparation »
(*repair problem*)\ \cite{dimakis2010toit}.
Pour résumer, voici les trois problèmes soulevés par l'étude du contexte :

1. proposer un système de stockage distribué flexible;

2. qui minimise la redondance nécessaire pour supporter les pannes du DSS;

3. et réduisant la quantité d'information transmise lors de la réparation d'un
support.


\section*{Notre approche}

\addcontentsline{toc}{section}{Notre approche}

Pour répondre à la première problématique, nous proposons d'utiliser le
logiciel qui définit un système de stockage (ou SDS ou *Software-Defined
Storage*) RozoFS. Plus particulièrement, RozoFS est un système de fichiers
distribué (ou DFS pour *Distributed File System*) est un DSS permettant
d'interagir avec des fichiers. En particulier, il permet d'agréger l'espace
disponible depuis un ensemble de supports de stockage. Cette agrégation est
exposée à l'utilisateur sous la forme d'un volume de stockage organisé par une
arborescence (fichiers et répertoire). En particulier, RozoFS est orienté pour
les réseaux locaux (*LAN*) rapides (très haut débit, faible latence). Notre
approche se distinguent alors des architectures pair-à-pair (ou P2P pour
*Peer-to-Peer*) et des réseaux étendus (*WAN*) de latences plus importantes.
Pour répondre au problème de la flexibilité, RozoFS utilise une approche
horizontal (*scale-out*). Cette approche consiste à ajouter adapter le nombre
de serveurs de stockage participant à la grappe de stockage afin d'augmenter ou
de réduire la capacité du système. RozoFS correspond ainsi à une couche de
virtualisation capable d'exploiter du matériel varié et bon marché. Cette
solution est alors plus flexible et moins onéreuse. En particulier, RozoFS est
un logiciel libre sous licence GNU GPLv2\footnote{Le projet GitHub de RozoFS se
situe à l'adresse suivante : \url{https://github.com/rozofs/rozofs}} dans
lequel il nous est possible d'intégrer nos contributions.

Afin de minimiser le redondance, relativement au second problème, nous nous
intéresserons au codage à effacement. Le codage à effacement est une méthode
qui permet de réduire considérablement la quantité de redondance générée par
rapport aux techniques de réplication (typiquement d'un facteur
$2$)\ \cite{weatherspoon2001iptps}. En particulier les codes optimaux (dits MDS
pour *Maximum Distance Separable*) minimisent la quantité de redondance
nécessaire pour protéger l'information. Les codes de \rs sont largement
utilisés parce qu'ils sont MDS. Ils sont ainsi utilisés dans plusieurs DFS
tels que CephFS\ \cite{weil2006osdi} ou DiskReduce\ \cite{fan2009pdsw}. Des
fournisseurs de services en nuage tels que Microsoft Azure\ \cite{huang2012atc}
ou Openstack avec Swift\ \cite{luse2014snia} l'utilisent également.
L'utilisation des codes de \rs dans les systèmes de stockage s'est démocratisé
avec le développement de bibliothèques qui en fournissent des implémentations.
En particulier, Ceph et Swift ont intégré la bibliothèque ISA-L (*Intelligent
Storage Acceleration Library*) d'\textcite{intel2015isal}.
<!-- %
% autre attrait c'est repairing -->
En revanche, les codes à effacement impliquent une complexité significative due
aux opérations d'encodage et de décodage. Dans le contexte de stockage, ces
opérations sont déclenchées respectivement à l'écriture et à la lecture de
blocs de données. En conséquence, leur utilisation est limitée aux applications
liées aux données froides. Les données froides correspondent à des informations
peu accédées (utilisées typiquement dans les applications d'archivage où les
données sont écrites une fois pour être sollicitées à l'occasion). En
comparaison, les données chaudes sont fréquemment sollicitées (typiquement
le cas des applications HPC qui mettent en jeu plusieurs milliers
d'entrées/sorties à la seconde).
En conséquence, on distingue deux types de systèmes de stockage : (i)
le premier permettant d'archiver les données à bas prix, en reposant sur du
matériel de stockage de grosse capacité et bon marché (bandes ou disque durs
mécaniques) et utilisant des codes à effacement\ \cite{andre2014eurosys} ; (ii)
le second utilisant (potentiellement) des techniques de réplication sur du
matériel performant et coûteux (disques SSD, RAM) afin d'accéder et traiter les
données chaudes sans ralentissement.
Notons toutefois qu'il est possible de réduire l'impact de ces opérations en
utilisant le code sous une forme systématique. Dans cette forme, le message à
transmettre est directement accessible. En particulier, il n'est pas nécessaire
de décoder lorsqu'aucune panne ne survient.


<!--
Depuis quelques années, cette réduction du volume de données tolérant aux
pannes a motivé plusieurs acteurs du monde du stockage à utiliser des codes à
effacement. Parmi eux, on compte trois types d'acteurs : (i) des entreprises
développant des solutions de stockage comme Cleversafe \cite{dhuse2010patent},
NetApp \cite{storer2015patent} ou Streamscale \cite{anderson2014patent} ; (ii)
plusieurs projets académiques se sont également développés comme OceanStore
\cite{kubiatowicz2000sigplan} ou DiskReduce \cite{fan2009pdsw} ; (iii) et
enfin, plusieurs acteurs majeurs s'y intéressent pour leurs service Cloud tels
que Microsoft pour Azure \cite{huang2012atc}, OpenStack avec Swift
\cite{luse2014snia} ou Amazon pour
Glacier\footnote{https://aws.amazon.com/fr/glacier/}.

Bien que de nombreux codes à effacement existent, la plupart de ces services
utilisent les codes de \textcite{reed1960jsiam}. Ces codes sont devenu les plus
populaires pour deux raisons : (i) leur capacité de correction peut être fixée
arbitrairement ; (ii) leur rendement est optimal (pour une capacité de
correction donnée, la quantité de redondance générée est minimale). En
revanche la complexité ajoutée par les opérations d'encodage et de décodage des
codes de \rs 
-->

% manque une partie sur la maintenance


\section*{Notre proposition}

\addcontentsline{toc}{section}{Notre proposition}

Nous avons vu précédemment que la complexité des codes à effacement limite leur
utilisation. Dans nos travaux de thèse nous proposons d'intégrer dans RozoFS un
code à effacement qui répond aux objectifs suivants : 

1. un code MDS;

2. dont les algorithmes d'encodage et de décodage sont de faibles complexités.
En particulier, une comparaison basée sur les latences de ces opérations, avec
les code de \rs, permettra de positionner notre code;

3. et qui dispose d'algorithmes adaptés au problème de réparation.

Pour répondre à ces objectifs, nous proposons d'utiliser des versions discrète
de la transformée de \radon, comme base de notre code à effacement. En
particulier, ces versions sont la  «\ transformée de \radon finie\ » (ou FRT
pour *Finite Radon Transform*) et la transformée Mojette.
Cette proposition est motivée pour les raisons suivantes : (i) tout d'abord,
ces transformées permettent une représentation redondante de l'information
(caractéristique essentielle pour concevoir un code à effacement); (ii) de
plus, de nombreuses publications proposent des algorithmes de représentation et
d'inversion efficaces. Enfin, ces transformées ont déjà fait
l'objet de publications dans le contexte de codage.

Nous verrons que ces deux versions permettent de concevoir des codes à
effacement qui disposent de propriétés différentes. Notre étude se concentrera
cependant sur le code à effacement basé sur la transformée Mojette. Ce choix
est justifié par la faible complexité des algorithmes d'encodage et de décodage
conçus pour ce code. En particulier, l'algorithme de décodage itératif proposé
par \textcite{normand2006dgci} permet de reconstruire un symbole avec une
complexité linéaire. Cette faible complexité nécessite cependant que le
ne soit que quasi-MDS \cite{parrein2001phd}. Nous montrerons cependant des
méthodes afin de se rapprocher d'un code optimal.


\section*{Contributions}

\addcontentsline{toc}{section}{Contributions}

Nos travaux de thèse ont ainsi conduits à deux contributions principales :

1. Conception d'une version systématique du code à effacement basé sur la
transformée Mojette. De cette contribution découlent deux sous-contributions : 

    1. Comparaison théorique avec les codes de \rs;

    2. Implémentation de cette méthode et évaluation;

    3. Intégration de cette méthode dans RozoFS

2. Conception d'une méthode pour ré-encoder de la redondance. En particulier
cette méthode peut être distribuée à l'ensemble des supports de stockage
participant au ré-encodage. L'avantage de cette technique est de ne pas
reconstruire explicitement l'information initiale.


\section*{Plan}

\addcontentsline{toc}{section}{Plan}

Les travaux de cette thèse sont organisés en deux parties. Chaque partie
comporte trois chapitres. La première partie mêle théorie de l'information et
géométrie discrète afin de concevoir un code à effacement basé sur une version
discrète de la transformée de \radon. En particulier, il conduit à
l'élaboration de notre première contribution : le code à effacement Mojette
sous sa forme systématique. Les trois chapitres qui le composent présentent les
éléments suivants :

1. Dans le \cref{sec.chap1}, nous introduirons des notions de la théorie de
l'information nécessaires afin d'établir un état de l'art des codes à
effacement. Ces notions vont permettre de présenter les principes des codes
correcteurs appliqués au canal à effacement. Nous verrons ainsi quelques
exemples qui représentent les grandes familles de codes à effacement.

2. Le \cref{sec.chap2} introduit la transformée de \radon. Ce chapitre utilise
conjointement la géométrie discrète et la théorie des codes. La géométrie
discrète permettra de définir deux versions discrètes de la transformée de
\radon : la FRT et la transformée Mojette. La théorie des codes sera nécessaire
pour concevoir et comprendre les propriétés des codes à effacement basés sur
ces transformées. Nous verrons ainsi que la FRT donne un code au rendement
optimale, tandis que la transformée Mojette dispose d'un algorithme de décodage
itératif efficace.

3. La première contribution est énoncée dans le \cref{sec.chap3}. Cette
contribution est une nouvelle conception du code à effacement Mojette sous sa
forme systématique. Cette conception a des avantages sur le rendement du code
et permet de tendre d'avantage vers l'optimal. Dans un deuxième temps, un
algorithme de décodage adapté à cette forme est donné. 
Nous évaluerons ainsi la quantité de redondance générée par cette nouvelle
forme par rapport à la version classique et au cas optimal. Cette évaluation
permet de mettre en évidence le rendement quasi optimal de notre conception.

\noindent La première partie ayant permis la conception du code à effacement
Mojette, la seconde partie s'intéresse à son intégration dans le contexte du
système de stockage distribué. Dans cette partie, les deux premiers chapitres
mettent en avant les performances du code à effacement Mojette dans ce
contexte. La troisième partie s'articule autour de notre deuxième contribution
sur la maintenance du système de stockage. Plus particulièrement, les
différents chapitres comportent les éléments suivants :

1. Le \cref{sec.chap4} présente une analyse théorique et expérimentale des
performances du code Mojette dans le contexte du stockage distribué. Les
métriques utilisées (nombres d'opérations à l'encodage, décodage et mise à
jour de blocs de données) mettent en avant la simplicité algorithmique du code
Mojette par rapport à d'autres codes (codes de \rs et *Array*).
En particulier, une mesure des performances en encodage et décodage des
implémentations du code Mojette est donnée. Dans les conditions de nos tests,
notre nouvelle conception systématique permet de réduire par trois les temps
d'encodage par rapport à la forme classique. De plus, elle permet d'atteindre
des performances optimales en lecture (dans le cas où aucune panne ne
survient). En particulier, ces mesures montrent également que notre
implémentation est plus performante que l'implémentation des codes de \rs
développée par \intel.

2. La mise en œuvre et l'intégration du code à effacement Mojette dans le
système de fichiers distribué RozoFS est expliquée dans le \cref{sec.chap5}. En
particulier, une évaluation menée sur la plate-forme GRID-5000 permet de
montrer que dans le cadre de nos tests, RozoFS est capable de fournir de
meilleures performances que des systèmes basés sur de la réplication, tout en
réduisant d'un facteur $2$ le volume total stocké.

3. Notre deuxième contribution est fournie dans le \cref{sec.chap6}. Cette
contribution concerne la conception d'une nouvelle méthode distribuée pour
calculer de nouveaux symboles de mots de code. Cette méthode peut être utilisée
afin de maintenir le système de stockage à un niveau de redondance désiré. Une
évaluation est réalisée afin de mettre en avant le bénéfice de la distribution
des calculs.

\noindent Dans une dernière partie, nous aborderons la conclusion des travaux
présentés dans cette thèse, puis la perspective des futurs travaux de
recherche.


\section*{Financements de thèse}

\addcontentsline{toc}{section}{Financements de thèse}

Dans le cadre d'une convention CIFRE, ces travaux de recherche ont été menés
conjointement au sein de l'équipe Image et Vidéo Communications (IVC) de
l'Institut de Recherche en Communications et Cybernétique de Nantes (IRCCyN),
et au sein de l'entreprise Rozo Systems. En conséquence, ces travaux mêlent
aspects théoriques et mesures de mises en œuvres. Une intention particulière a
ainsi été portée sur les implémentations réalisées et intégrées dans le
système de fichiers distribué RozoFS, développé par l'entreprise. C'est
pourquoi, un intérêt a été porté sur les performances fournies par nos
implémentations.

% FEC4Cloud + montage et configuration de la plate-forme

