
Avec le nombre croissant d'appareils interconnectés par Internet, la quantité
de données générées augmente de manière préoccupante. Alors qu'il est
aujourd'hui courant de posséder plusieurs terminaux tels que les appareils
mobiles et tablettes, on observe progressivement de nouvelles ramification
d'Internet qui s'étend aux objets du quotidien. Désignée sous le terme
« Internet des objets » cette nouvelle évolution du réseau des réseaux va
accroitre de manière exponentielle la quantité de données générées et stockées.
Cette quantité massive de données, désignée en général par le terme « *Big
Data* », vise à être fouillée et analysée pour être mise en forme par des outils
de visualisation. Nécessitant des algorithmes particulièrement efficaces et
adaptées à la taille des données, ces traitements impliquent aujourd'hui
d'importantes problématiques scientifiques.

Le rapport de \textcite{gantz2012idc} donne des prédictions sur les quantités
de données générées et stockées au niveau mondial. En particulier, il prévoit
que la quantité d'information stockée dans le monde atteindra $44$
zettaoctets\footnote{un zettaoctet correspond à $10^{21}$ octets. Si un
caractère nécessite un octet, un zettaoctet contiendrait plus de 228
milliers de milliards de fois l'œuvre \emph{Le Monde Perdu} d'Arthur Conan
Doyle.} d'ici 2020 (dont $27$\% seront générées par des objets connectés). En
particulier, le rapport pressent que cette croissance se ferra de manière
exponentielle. \textcite{hilbert2011science} rappelle que ce volume de données
correspond à la quantité d'information génétique contenue dans un corps humain,
mais que « par rapport à la capacité de la nature à traiter l'information, la
capacité du monde numérique évolue de façon exponentielle ». Toujours selon le
rapport, la quantité de données stockées par les pays des marchés émergents du
numérique (Chine, Brésil, Inde, Russie, Mexique) surpassera celle des marchés
déjà en place (Amérique du nord, Europe de l'ouest, Japon, Océanie) d'ici 2017.
Dans ce volume massif de données, nous allons voir que la part de redondance
joue un rôle significatif.

Les systèmes de stockage distribués sont sujets à des défaillances
inévitables qui entraînent l'inaccessibilité temporaire, voire la perte
définitive de blocs de données \cite{ford2010osdi}. Une panne est un phénomène
inévitable. En particulier, la probabilité d'apparition des pannes augmente
avec la taille du système de stockage (e.g.\ défaillance d'un disque,
défaillance réseau, etc). La solution classique pour supporter ces pannes
consiste à distribuer plusieurs copies d'information sur des supports de
stockage différents. Cette méthode permet d'accéder à une copie de
l'information lorsque les autres ne sont pas disponibles. Bien que simple à
mettre en œuvre, chaque copie générée correspond à une quantité significative
de redondance. Cette méthode implique alors un coût de stockage important.

Le codage à effacement est une technique qui permet de réduire considérablement
la quantité de redondance générée par rapport à la réplication
\cite{weatherspoon2001iptps}. En revanche, elle entraine nécessairement une
complexité significative due aux opérations d'encodage et de décodage. Dans le
contexte de stockage, ces opérations sont déclenchées respectivement à
l'écriture et à la lecture de blocs de données.

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
populaires  pour deux raisons : (i) leur capacité de correction peut être fixée
arbitrairement ; (ii) leur rendement est optimal (pour une capacité de
correction donnée, la quantité de redondance générée est minimale). En
revanche la complexité ajoutée par les opérations d'encodage et de décodage des
codes de \rs limite leur utilisation aux applications liées aux données
froides. Les données froides correspondent à des informations peu accédées
(utilisées typiquement dans les applications d'archivage où les données sont
écrites une fois pour être sollicitées à l'occasion). En comparaison, les
données chaudes sont fréquemment sollicitées (par exemple les bases de données
mettent en jeu plusieurs milliers d'entrées/sorties à la seconde). En
conséquence, on distingue deux types de systèmes de stockage : (i) le premier
permettant d'archiver les données à bas prix, en reposant sur du matériel de
stockage de grosse capacité et bon marché (bandes ou disque durs mécaniques) et
utilisant des codes à effacement \cite{andre2014eurosys} ; (ii) le second
utilisant (potentiellement) des techniques de réplication sur du matériel
performant et coûteux (disques SSD, RAM) afin d'accéder et traiter les données
chaudes sans ralentissement.

% manque une partie sur la maintenance


\section*{Motivations et objectifs}

\addcontentsline{toc}{section}{Motivations et objectifs}

Nous avons vu précédemment que la complexité des codes à effacement est un
frein à leur utilisation. Dans ces travaux de thèse nous proposons une solution
au problème de la complexité des codes à effacement. En particulier, nous
souhaitons obtenir des codes à effacement :

1. De rendement proche de l'optimal (c'est à dire que la quantité de redondance
nécessaire pour offrir une certaine capacité de correction est minimale) ;

2. Dont les algorithmes d'encodage et de décodage sont efficaces. Pour cela
nous proposons d'étudier l'aspect théorique et d'utiliser des algorithmes de
faible complexité. Cette étude devra également être appuyée par une évaluation
des performances fournies par la mise en œuvre de ces algorithmes. En
particulier, une comparaison de ces performances avec des références reconnues
permettra de positionner notre travail ;

3. Adaptés au contexte du stockage distribué. Dans ce contexte, la maintenance
du niveau de redondance est remise en cause par la perte définitive d'un
support de stockage. En conséquence, des algorithmes de maintenance efficaces
doivent être conçus.

Pour répondre à ces objectifs, nous proposons la conception de codes à
effacement basés sur des versions discrète de la transformée de \radon. En
particulier, ces versions correspondent à la *Finite \radon Transform* (FRT),
ou « transformée de \radon finie », et à la transformée Mojette.
Notre choix est motivé par les raisons suivantes. Tout d'abord, ces
transformées permettent une représentation redondante de l'information
(caractéristique essentielle pour concevoir un code à effacement). De plus, de
nombreuses publications proposent des algorithmes de représentation et
d'inversion efficaces. Enfin, ces transformées ont déjà fait l'objet de
publications dans le contexte de codage.

Nous verrons que ces deux versions permettent de concevoir des codes à
effacement qui disposent de propriétés différentes. Notre étude se concentrera
cependant sur le code à effacement basé sur la transformée Mojette. Ce choix
est justifié par la faible complexité des algorithmes d'encodage et de décodage
conçus pour ce code. En particulier, l'algorithme de décodage itératif proposé
par \textcite{normand2006dgci} permet de reconstruire un symbole avec une
complexité linéaire. Cette faible complexité requiert cependant que le
rendement de ce code soit sous optimal \cite{parrein2001phd}. Nous montrerons
cependant des méthodes afin de se rapprocher d'un rendement optimal.


\section*{Contexte de travail}

\addcontentsline{toc}{section}{Contexte de travail}

Dans le cadre d'une convention CIFRE, ces travaux de recherche ont été menés
conjointement au sein de l'équipe Image et Vidéo Communications (IVC) de
l'Institut de Recherche en Communications et Cybernétique de Nantes (IRCCyN),
et au sein de l'entreprise Rozo Systems. En conséquence, ces travaux mêlent
aspects théoriques et mesures de mises en œuvres. Une intention particulière a
ainsi été portée sur les implémentations réalisées et intégrées dans le
système de fichiers distribué RozoFS, développé par l'entreprise. C'est
pourquoi, un intérêt a été porté sur les performances fournies par nos
implémentations. En particulier, ces évaluations ont donné lieu à des
comparaisons avec les alternatives reconnues.


\section*{Plan et contributions}

\addcontentsline{toc}{section}{Plan et contributions}

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

