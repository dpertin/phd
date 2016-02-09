
\chapter{Code à effacement Mojette systématique}

\label{sec.chap3}

\minitoc

\newpage

% Dans le chapitre précédent, nous avons vu la transformée

% de \radon fini et la transformée Mojette. Ces deux codes à

% effacement sont conçus à partir d'une approche géométrique.

% En particulier, nous avons montré que ces deux codes disposent

% d'algorithmes efficaces pour générer des données de redondance

% lors de l'encodage, puis pour décoder et reconstruire

% l'information initiale.  Bien que la transformée de \radon

% fini a l'avantage de fournir un code optimal au sens MDS,

% la transformée Mojette offre des complexités d'encodage et

% de décodage plus efficaces.

\section*{Introduction}

Nous avons vu dans le chapitre précédent que la transformée Mojette est capable
de produire efficacement de la redondance de l'information, nécessaire pour
garantir une disponibilité des données face à des pannes éventuelles. On
appelle chemin de données, l'ensemble des composants par lesquels la donnée
transite lors d'une communication.
Situé entre les unités de traitement et de transmission des données, le code à
effacement forme un maillon crucial dans le chemin de données. Il est important
que le code soit suffisamment performant pour ne pas former un goulot
d'étranglement dans cette chaîne de transmission.
L'objectif de ce chapitre est d'expliquer ma contribution dans l'élaboration
d'une version systématique du code à effacement Mojette, dans l'objectif
d'optimiser ses performances.

Nous avons vu dans le \cref{sec.chap1} que les codes systématiques intègrent la
donnée dans l'ensemble des informations encodées. En conséquence, l'encodage
systématique nécessite de calculer une quantité significativement réduite de
redondance en comparaison du même code en version non-systématique. De plus, le
principal avantage réside dans le fait que le décodage est optimal
lorsqu'aucune information n'est perdue.
Jusque là, les seuls travaux réalisés sur cette technique concerne une mise en
œuvre au sein d'un brevet \cite{david2013patent}. La \cref{sec.systematique}
présente la nécessité de mettre en œuvre une version systématique du code à
effacement, et détaille ses avantages face à la version actuellement
développée.
La \cref{sec.algo-sys} présente la mise en œuvre et l'algorithme conçu pour
décoder l'information sous cette forme. En particulier, nous verrons que
l'algorithme utilisé est une extension de l'algorithme de
\textcite{normand2006dgci}.
La \cref{sec.eval.red} analyse le gain de redondance de cette version sur la
version non-systématique, et compare ce coût face aux codes MDS.

% Pour finir, nos verrons une évaluation du code à effacement

% Mojette, et comparerons ses performances avec les meilleures

% implémentations actuelles. En particulier, nous verrons que

% cette version améliore significativement les performances du code,

% et offre de meilleures performances que l'implémentation des codes

% de Reed-Solomon développée par \textcite{intel2015isal}.



# Les avantages d'une version systématique {#sec.systematique}

Cette première section permet de comprendre les enjeux de la conception d'une
version systématique du code à effacement basé sur la transformée Mojette.
La \cref{sec.syscode} permet de comprendre la position du code
dans la chaîne de traitement. En particulier nous introduirons des rapports
entre les différents maillons de cette chaîne et expliquerons quel doit être
l'ordre de grandeur des performances du code pour ne pas former un goulot
d'étranglement. Les deux analyses suivantes permettent de comprendre en quoi
une version systématique du code peut améliorer ses performances. En
particulier, la \cref{sec.sysenc} détermine que le gain en encodage est
significatif. La \cref{sec.sysdec} montre que les performances en décodage
dépendent du schéma de perte. Plus précisément, dans le pire cas, les
performances sont équivalentes à la version non-systématique. Dans le meilleur
cas, les performances sont optimales.


## Contraintes en performances des codes à effacement {#sec.syscode}

\begin{figure}[t]
    \centering
    \def\svgwidth{\textwidth}
    \includesvg{img/data_path2}
    \caption{Représentation du chemin de données dans la transmission entre deux
    terminaux. La donnée à présente dans la mémoire principale (RAM) du nœud
    $1$. L'encodage est réalisé par le CPU de ce nœud avant de transmettre
    l'information au l'interface réseau (NIC). Cette interface transmet ensuite
    l'information encodée sur le canal à effacement. Après réception des
    données par le nœud $2$, une opération de décodage est réalisée avant de
    restituer la donnée reconstruite à la mémoire.}
    \label{fig.data_path}
\end{figure}

Pour comprendre l'enjeu des performances des codes à effacement, nous
analyserons dans un premier temps le positionnement du code à effacement dans
la chaîne de traitement des données. Nous verrons alors qu'il doit être
suffisamment performant pour ne pas former un goulot d'étranglement dans cette
chaîne. Par la suite, nous déterminerons un ordre de grandeur des performances
que notre code doit fournir.


### Positionnement du code à effacement dans la transmission de l'information

\begin{table}[t]
    \centering
    \begin{tabular}{@{}*{3}{l}@{}}
        \toprule
            Description & Temps d'accès & Temps Normalisé\\
        \midrule
            1 cycle CPU & 0,3 ns & 1 s\\
            Accès cache niveau 1 & 0,9 ns & 3 s\\
            Accès cache niveau 2 & 2,8 ns & 9 s\\
            Accès cache niveau 3 & 12,9 ns & 43 s\\
            Accès RAM & 120 ns & 6 min\\
            E/S disque SSD & 50-150 \textmu{}s & 2-6 jours\\
            E/S disque dur & 1-10 ms & 1-12 mois\\
            Internet : SF à NYC & 40 ms & 4 ans\\
            Internet : SF à GB & 81 ms & 8 ans\\
            Internet : SF à Australie & 183 ms & 19 ans\\
            Redémarrage d'un SE virtuel & 4 s & 423 ans\\
            Redémarrage d'une machine virtuelle & 40 s & 4000 ans\\
            Redémarrage du système & 5 m & 32 millénaires\\
        \bottomrule
	\end{tabular}
	\caption{Comparaison des temps d'accès réel pour différentes opérations
	informatiques. La troisième colonne normalise ces temps sur la base d'un
	cycle CPU pour une seconde. Extrait de \cite{gregg2013performance}.
	\label{tab.delai}}
\end{table}

Dans le contexte des télécommunications, les applications sont
intrinsèquement liées au matériel qui traite et transporte la donnée, ainsi
qu'aux techniques de codage qui permettent aux informations de transiter à
travers un canal à effacement.
La \cref{fig.data_path} représente une vue générale de la chaîne de
transmission entre deux terminaux interconnectés. La donnée issue de la RAM du
nœud $1$ est traitée par le CPU afin de la transmettre sur le média de
communication à partir de l'interface réseau. Sur le réseau, l'information
passe au travers de composants gérant l'acheminement des données. Ce média
représente un canal à effacement dans lequel les paquets peuvent être perdus.
Une fois parvenue au destinataire, une opération inverse à la première étape
est réalisée afin de stocker cette donnée dans la RAM du nœud $2$. L'objectif
du code à effacement est de traiter les données avant leur transmission ou leur
stockage. En conséquence, il agit entre l'ensemble des composants de traitement
(processeur, mémoire centrale), et l'ensemble des composants de communication
(stockage de masse, réseau).

Dans notre cas, il est nécessaire de concevoir un code à effacement qui ne
forme pas un goulot d'étranglement dans cette chaîne afin que ce soit le
matériel qui limite les performances du système. Dans les systèmes
distribués par exemple, on partage les ressources de différentes unités en
concevant des algorithmes de distribution et exploiter au maximum la capacité
du matériel.

\Cref{tab.delai} donne une comparaison des délais observés pour certaines
opérations informatiques. Afin de bien visualiser le rapport de différence
entre ces opérations, la troisième colonne normalise ce délai sur la base d'un
cycle CPU pour une seconde. S'il est nécessaire d'attendre une
seconde pour un cycle CPU, le temps de récupération d'un bloc d'information sur
le disque peut durer jusqu'à un an.
En conséquence, la mise en œuvre d'un code à effacement doit favoriser les
opérations proches du processeur. On travaillera ainsi à favoriser le stockage
des données et des instructions dans les différents niveaux de cache, et éviter
les interactions avec le disque.

Naturellement, il est impossible de garantir cette situation. Par exemple,
lorsque la donnée n'est pas disponible dans le cache CPU, il est nécessaire de
la faire "remonter" de la RAM. Si la taille des données ne peut entrer dans la
RAM, il faudra nécessaire des interactions avec les disques de masse. Pour
aller plus loin, si la donnée n'est pas disponible sur le nœud qui la demande,
il faut la faire transiter par le réseau. En conséquence, il y a une forte
dépendance entre le processeur, la RAM, le support de masse et le réseau.

### Performance des codes

\begin{table}[h!]
    \centering
    \begin{tabular}{@{}*{2}{l}@{}}
            Matériel & Débits (Mo/s)\\
        \midrule
            RAM (DDR3) & $10000$\\
            Réseau (Fast Ethernet) & $1000$\\
            Disque (SSD) & $500$\\
	\end{tabular}
	\caption{Ordre de grandeur de débits}
	\label{tab.debit}
\end{table}

\Cref{tab.debit} donne l'ordre de grandeur des débits atteints par la RAM, les
interfaces réseaux, et les disques. En particulier on observe que les disques
et le réseau forment les éléments limitant.
Afin d'améliorer les performances d'un système composé de ces différents
éléments, il existe deux possibilités: (i) attendre puis acheter au prix cher
la nouvelle génération de matériel; (ii) agréger plusieurs composants ensembles
afin de partager leurs ressources. Bien que la seconde option apporte une
complexité de mise en œuvre, elle est nettement plus accessible
en terme de prix. En ce qui concerne le stockage de masse, cette agrégation a
vu le jour avec la conception des différents niveaux de techniques RAID par
\textcite{patterson1988sigmod}. Par exemple, l'utilisation du RAID-0 permet
généralement d'augmenter les débits d'un facteur $2$. Côté, des techniques
d'agrégation des liens réseaux existent, comme proposé par
\textcite{adiseshu1996sigcomm}. Il est alors possible d'améliorer les
performances en exploitant plusieurs interfaces et liens réseaux.

La présence du code au sein de la chaîne de traitement entraîne un
calcul intermédiaire entre le processeur et les médias de communication. Afin
de ne pas représenter un goulot d'étranglement dans cette chaîne, le code doit
être suffisamment performant pour supporter les débits montants des disques
et/ou du réseau. Une évaluation des performances des codes à effacement
utilisés dans les applications de stockage a été réalisée par
\textcite{plank2009fast}. Dans cette étude, \citeauthor{plank2009fast} montrent
que les débits d'encodage et de décodage observés par les meilleurs codes sont
de l'ordre d'un gigaoctet par seconde. En conséquence, il est possible que ces
codes forment un goulot d'étranglement dans le cas où un agrégat de disques ou
de liens réseaux sature le nœud.

Il est alors essentiel qu'un code puisse fournir de bonnes performances.
C'est pourquoi ce chapitre s'intéresse à l'optimisation des performances du
code à effacement basé sur la transformée Mojette. Nous verrons dans les
deux parties qui suivent, les bénéfices d'une version systématique sur
l'encodage et le décodage.


## Bénéfice de cette nouvelle technique sur l'encodage {#sec.sysenc}

\begin{figure}[t]
    \centering
    \def\svgwidth{\textwidth}
    \includesvg{img/mojette_sys_nsys}
    \caption{Comparaison du nombre de projections calculées entre la forme
    systématique et non-systématique pour un code Mojette $(6,3)$. En
    particulier, les projections en rouge correspondent aux projections
    supplémentaires qu'il est nécessaire de calculer sous la forme
    non-systématique.}
    \label{fig.comparaison_systematique}
\end{figure}

Par rapport à la version non-systématique, cette nouvelle technique permet de
réduire significativement le complexité à l'encodage.  En version
non-systématique, il est nécessaire de calculer $n$ projections à partir
d'une grille discrète constituée de $k$. Dans cette nouvelle version
systématique, nous considérons les $k$ lignes de cette grille comme faisant
partie des données encodées. En conséquence, il suffit de calculer $(n-k)$
projections pour fournir la même protection qu'avec l'approche classique du
code à effacement Mojette $(n,k)$. D'une manière générale, le rapport $g$ de
blocs de parité générés entre les deux versions s'exprime ainsi :

\begin{equation}
    g = \frac{n}{n-k}
    \label{eqn.gain}
\end{equation}

Prenons l'exemple d'un code avec un taux $r={2}$, comme un code
$(6,3)$ fournissant de la protection face à trois effacements.
La \cref{fig.comparaison_systematique} représente la comparaison entre les deux
techniques pour cet exemple.
En version systématique, l'ensemble des données encodées correspondent aux $k$
lignes de la grille, auxquelles on ajoute $r=3$ projections calculées. Dans
notre exemple, ces projections sont construites suivant les directions
$\{(p_i,q_i)\} = \{(-1,1),(0,1),(1,1)\}$. Sous sa forme non-systématique, le
code à effacement Mojette doit calculer trois projections supplémentaires afin
de fournir la même disponibilité des données. Sur la
\cref{fig.comparaison_systematique}, ces projections supplémentaires sont
représentées en rouge. En conséquence, cette nouvelle version systématique
calcule deux fois moins de projections dans notre exemple (elle est deux fois
plus performante en conséquence). Ce gain dépend des paramètres du code. Si
l'on prend le cas d'un code $(6,4)$, l'encodage est trois fois plus performant.
Nous verrons dans la suite l'impact sur le décodage.


## Bénéfice de cette technique sur le décodage {#sec.sysdec}

Dans cette partie nous allons étudier le comportement du code systématique en
fonction du schéma de perte. On distingue trois schémas de pertes : (i) le cas
optimal correspond à la situation où la grille n'a subit aucun effacement; (ii)
le cas où la grille est dégradée (i.e.\ elle subit un nombre $e$ d'effacements,
où $e<k$); (iii) le pire cas où toute la grille est effacée.

% La \cref{fig.sys_decodage} représente ces trois cas avec

% un code à effacement $(6,3)$ appliquée sur une grille

% $(3 \times 3)$.

### Accès direct sans dégradation

Lorsqu'aucune ligne de la grille n'est effacée, il s'agit du meilleur cas.
C'est dans cette situation que réside le principal avantage de cette technique
puisqu'il n'est pas nécessaire d'exécuter d'opération de décodage. Si aucune
des $k$ lignes de données ne subit  d'effacement, la donnée est immédiatement
accessible en clair. En conséquence aucun calcul n'est réalisé et les
performances sont optimales.

% En pratique dans certaines applications, il s'agit

% du cas le plus courant. {CITER QUELQUE CHOSE}

En comparaison avec la version non-systématique, même si aucune information ne
subit d'effacement, il est nécessaire de reconstruire la grille entière. Quel
que soit le schéma de perte, le décodage met en jeu $k$ projections pour
reconstruire les $k$ lignes. En conséquence, le décodage nécessite toujours un
travail calculatoire dont le coût est significatif.
Dans la suite, nous analysons le cas où des effacements se produisent.

### Dégradation partielle des données

Une dégradation des données entraîne nécessairement une opération de décodage
afin de restaurer la donnée perdue. Nous considérons à présent que le nombre de
lignes de grille discrète effacés $e$ est inférieur à $k$. Dans ce cas,
l'opération de décodage est possible dés lors que l'on accède à un ensemble
suffisant de $e$ projections pour reconstruire les $e$ lignes effacées. Plus
précisément, ce problème correspond à reconstruire une grille partiellement
remplie.
L'algorithme d'inversion doit donc prendre en compte non seulement la valeur
des bins des projections, mais également la valeur des pixels déjà présents
dans la grille. Nous verrons en détail ce nouvel algorithme dans la prochaine
partie.

% \Cref{fig.syspartial} montre une le cas où $e=2$

% lignes de la grille discrète ont été effacées. L'opération

%de décodage consiste à rétablir les données des lignes perdues

%à partir de $e = 2$ projections.

En comparaison avec la version non-systématique, cette nouvelle mise en œuvre
est plus performante. En effet, quelque soit le schéma de perte en
non-systématique, il est nécessaire d'utiliser $k$ projections pour
reconstruire l'ensemble de la grille tout entière.
En revanche, cette nouvelle technique correspond à la reconstruction d'une
grille partiellement reconstruite. En conséquence, l'ensemble des pixels à
reconstruire est moins important qu'en non-systématique et donc, moins
d'opérations sont nécessaires pour le décodage.

### Perte complète des données

Dans le cas où $(e=k)$, l'ensemble des lignes de la grille est effacé. Il est
alors nécessaire de décoder l'information à partir de $k$ projections.
L'opération de décodage est alors identique, que le code soit systématique ou
non.

### Bilan de l'impact en décodage

L'avantage principal de la version systématique est de fournir des performances
optimales quand la grille ne subit aucune dégradation. Il n'y a pas besoin dans
ce cas de décoder l'information, qui est disponible en clair dans la grille.
Lorsque des effacements apparaissent, les performances décroissent puisqu'il
est nécessaire de déclencher l'opération de décodage.
Ces performances se dégradent alors avec le nombre de lignes effacées. Le pire
cas est obtenu quand toute la grille est effacée. Dans ce cas, l'opération de
décodage correspond à l'opération effectuée en non-systématique. En
conséquence dans ce cas, les performances sont semblables dans les deux
techniques.
Rappelons que la forme non-systématique fournit les mêmes performances quel que
soit le schéma de perte puisqu'il est nécessaire de reconstruire la grille
entière à partir de $k$ projections. En comparaison, cette situation correspond
au pire scénario de perte dans le cas systématique. Dans tous les autres cas,
les performances sont meilleures.



# Algorithme inverse en systématique {#sec.algo-sys}

L'algorithme d'inversion présenté dans cette section correspond à une extension
de l'algorithme inverse de \textcite{normand2006dgci}, étudié dans le chapitre
précédent. Une bonne compréhension de cet algorithme est nécessaire pour
comprendre ce qui est réalisé dans cette section.
Dans la suite, nous décrirons deux principales modifications à cet
algorithme : (i) une nouvelle détermination des offsets de chaque projection
est nécessaire pour prendre en compte les lignes déjà reconstruites de la
grille, cette détermination sera présentée en \cref{sec.offsets}; (ii) un
nouveau calcul de la valeur du pixel à reconstruire qui prend en compte la
valeur des pixels présents sur la droite de projection, étudié en
\cref{sec.pxl}. Les différentes étapes pour reconstruire l'image en
systématique sont énumérées dans l'\cref{alg.systematique}.
 
\input{alg/systematique}


## Mise en œuvre de la version systématique

% ajouter une superbe figure !

Une mise en œuvre de l'opération de décodage du code à effacement Mojette sous
sa forme systématique est donnée par \textcite{david2013patent}. Dans ce
brevet, le procédé pour reconstruire l'information manquante d'une image
dégradée $f'$ repose sur trois étapes : (i) la première étape consiste à
calculer les valeurs des projections de la grille partielle
$[Mf'](b, p_i, q_i)$. Les directions de projection sont définies par un
ensemble suffisant de $e$ projections pour reconstruire une grille dont $e$
lignes sont manquantes; (ii) la seconde étape consiste à calculer la différence
entre les projections obtenues $[Mf](b, p_i, q_i)$ par l'image d'origine, et
l'image partielle $[Mf'](b, p_i, q_i)$; (iii) la dernière étape consiste à
appliquer l'algorithme de reconstruction de \textcite{normand1996vcip} en
utilisant les valeurs des différences entre projections, et une grille
construite à partir des lignes effacées.
Dans la suite, nous allons présenter une nouvelle mise en œuvre basée sur
l'algorithme de \textcite{normand2006dgci}.



## Détermination des *offsets* pour la reconstruction {#sec.offsets}

De manière comparable à ce qui est réalisé dans l'algorithme de
\textcite{normand2006dgci}, il est nécessaire de déterminer la valeur des
*offsets* pour chaque ligne à reconstruire.
De manière graphique, ces *offsets* correspondent à des décalages attribués à
chaque ligne à reconstruire afin de parcourir le chemin de reconstruction. En
particulier, ces *offsets* permettent à l'algorithme de déterminer pour chaque
itération, un pixel reconstructible (i.e.\ auquel ne s'applique aucune
dépendance).

En non-systématique, puisque toutes les lignes doivent être reconstruites, ces
offsets étaient déterminés à partir de l'index de la ligne à reconstruire et de
la direction de la projection utilisée pour la reconstruire.
Dans la version systématique, il est nécessaire de prendre en compte les lignes
déjà présentes dans le calcul des offsets des lignes à reconstruire. On
considère dans la suite l'ensemble des indexes des lignes effacées
$\text{Eff}(i)$ trié par ordre décroissant, avec $i \in \ZZ_e$, et $e$ le
nombre de lignes effacées. Il faut tout d'abord calculer l'offset de la
dernière ligne à reconstruire $\text{Offset}(\text{Eff}(e-1))$ :

\begin{align}
    S_{\text{minus}} &= \sum_{I=1}^{Q-2}\text{max}(0,-p_i),\label{eqn.sp}\\
    S_{\text{plus}} &= \sum_{I=1}^{Q-2}\text{max}(0,p_i),\label{eqn.sm}\\
    \text{Offset}(\text{Eff}(e-1)) &=
        \text{max}(\text{max}(0,-p_r) + S_{\text{minus}}, \text{max}(0,p_r)
        + S_{\text{plus}}).\label{eqn.offr}
\end{align}

\noindent La méthode pour déterminer la valeur des offsets est ensuite décrite
à la \cref{alg.offsets} de l'\cref{alg.systematique}.


## Calcul de la valeur du pixel à reconstruire {#sec.pxl}
\label{sec.valeur_pxl}

En non-systématique, la valeur du pixel est directement lu dans le bin associé
$\text{Proj}_f(p_i, q_i, b)$. Dans la version systématique, lors de la
reconstruction, les valeurs des pixels ne dépendent plus seulement des valeurs
de bins, mais elles peuvent dépendre des valeurs des pixels non-effacés ou déjà
reconstruits.
En particulier, si l'on observe la reconstruction d'un pixel par une
projection suivant la direction $(p_i,q_i)$, il participe à la somme de la
valeur des pixels qui détermine la valeur du bin $b$ tel que ces pixels sont
situés sur la droite d'équation $b = -kq_i + lp_{i}$.
On définit alors deux versions de l'image : (i) $\tilde{f}(k,l)$
correspond à la valeur des pixels durant le processus de reconstruction; (ii)
${f}(k,l)$ qui correspond à la valeur des pixels de l'image d'origine.
En conséquence, la valeur du pixel à reconstruire est donnée par :

\begin{equation}
    f(k,l) = Proj_f(p_i, q_i, k - lp_i) + Proj_{\tilde{f}}(p_i, 1, k - lp_i).
    \label{eqn.sys_pxl}
\end{equation}

\noindent où $Proj_{\tilde{f}}(p_i, 1, k - lp_i)$ correspond à la somme des
valeurs des pixels de l'image en reconstruction selon la droite passant par le
pixel de coordonnées $(k,l)$, et d'équation $b=-kq_i +lp_i$, et où
$Proj_{f}(p_i, 1, k - lp_i)$ correspond à la valeur du bin de la projection.




# Évaluation du coût de la redondance du code Mojette {#sec.eval.red}
\label{sec.surcout_stockage}

Un code MDS génère la quantité minimale de redondance pour une tolérance aux
pannes donnée. Dans le chapitre précédent, nous avons vu que le code à
effacement Mojette n'est pas optimal et est considéré comme $(1+\epsilon)$ MDS.
En effet, bien qu'il soit capable de décoder $k$ blocs de données à partir de
$k$ blocs encodés, la taille de ces blocs peuvent dépasser la taille optimale.
En conséquence, pour une protection donnée, notre code génère plus de données
que la quantité minimale.
Dans cette section, nous allons définir et évaluer le surcout de redondance
généré par le code à effacement Mojette. Pour cette évaluation, nous
définissons $\mu$ comme étant le facteur correspondant au rapport de la quantité
de données encodées sur la quantité de données initiale. Dans la suite nous
évaluerons dans un premier temps le gain de redondance induit par la version
systématique du code Mojette, par rapport à sa version non-systématique. Une
seconde étude permettra de positionner le coût de la redondance du code Mojette
par rapport aux coûts induits par les techniques de réplication et les codes MDS.


## Réduction de la redondance en systématique

\begin{figure}[t]
    \centering
	\begin{subfigure}{.5\textwidth}
 		\centering
        \def\svgwidth{\textwidth}
        \footnotesize
			\includesvg{img/mojette3_nsys}
        \caption{Non-systématique}
        \label{fig.nsys}
    \end{subfigure}
    \begin{subfigure}{.3\textwidth}
    	\centering
        \def\svgwidth{\textwidth}
        \footnotesize
        	\includesvg{img/mojette3_sys}
        \caption{Systématique}
        \label{fig.sys}
    \end{subfigure}
    \caption{Comparaison entre l'encodage Mojette non-sytématique et
    systématique. Les lettres correspondent à la valeur des pixels de l'image
    $3 \times 3$ (i.e.\ de hauteur $k=3$) d'où sont calculées ces $n=6$ blocs
    encodés.}
    \label{fig.nsys.sys}
\end{figure}

La \cref{fig.nsys.sys} illustre le gain de la version systématique d'un code
Mojette $(6,3)$ par rapport à la version non-systématique. L'objectif de cette
section est d'analyser ce gain. Nous avons vu précédemment que la taille des
projections varie en fonction des paramètres de la grille discrète $P$ et $Q$,
ainsi que des paramètres de l'ensemble des directions de projection $\{(p_i,
q_i)\}$. Nous rappelons ici la formule permettant de déterminer la taille d'une
projection :

\begin{equation}
    B(P,Q,p,q) = |p_i|(Q-1) + |q_i|(P-1) + 1.
    \label{eqn.nombre_bins2}
\end{equation}

\noindent Puisque dans le cas des codes à effacement Mojette, la taille des
blocs encodés (i.e.\ les projections) varie, nous allons étudier le nombre
d'éléments de projection par rapport au nombre de pixels. Dans le cas du code à
effacement non-systématique, la valeur de $\mu$ correspond au quotient de la
somme du nombre de bin $B$ de chaque projection de l'ensemble $\{(p_i,q_i)\}$,
sur le nombre d'éléments de la grille :

\begin{table}[t]
	\centering
	\begin{tabular}{@{}*{10}{l}@{}}
		\toprule
			& & 1024 & 2048 & 4096 & 8192 & 16384 & 32768 & 65536 & 131072\\
		\midrule
			\multirow{2}{*}{(3,2)} & nsys & 1,51 & 1,51 & \emph{1,50} &
			    \emph{1,50} & \emph{1,50} & \emph{1,50} & \emph{1,50} &
			    \emph{1,50}\\
			& sys & \emph{1,50} & \emph{1,50} & \emph{1,50} & \emph{1,50} &
    			\emph{1,50} & \emph{1,50} & \emph{1,50} & \emph{1,50}\\
		\midrule
			\multirow{2}{*}{(6,4)} & nsys & 1,71 & 1,61 & 1,55 & 1,53 & 1,51 &
			    1,51 & \emph{1,50} &\emph{1,50}\\
			& sys & 1,52 & 1,51 & \emph{1,50} & \emph{1,50} & \emph{1,50} &
    			\emph{1,50} & \emph{1,50} & \emph{1,50}\\
		\midrule
		    \multirow{2}{*}{(12,8)} & nsys & 3,47 & 2,48 & 1,99 & 1,75 & 1,62 &
    		    1,56 & 1,53 & 1,52\\
		    & sys & 1,72 & 1,61 & 1,55 & 1,53 & 1,51 & \emph{1,50} & \emph{1,50}
    		    & \emph{1,50}\\
		\bottomrule
	\end{tabular}
	\caption{Résultats arrondis des coûts $\mu$ des données encodées pour les
	versions non-systématique (nsys) et systématique (sys) du code Mojette en
	fonction de différents paramètres de code $(n,k)$ et de différentes tailles
	de $\mathcal{M}$ en octets. Les résultats en italique représentent la
	valeur optimale obtenue par un code MDS.}
	\label{tab.f}
\end{table}

\begin{equation}
    \mu = \frac
        {\sum\limits_{i=0}^{n-1} B(P,Q,p_i,q_i)}
        {P \times Q}.
    \label{eqn.f_non_systematic}
\end{equation}

\noindent Par rapport à la forme non-systématique, $k$ projections sont
remplacées par les $k$ lignes de la grille discrète quand le code est
systématique. En conséquence, la valeur de $\mu$ correspond au quotient de la
somme du nombre de pixels et de bins produits, sur le nombre de pixels de
l'image:

\begin{equation}
    \mu = \frac
        {P \times Q + \sum\limits_{i=0}^{n-k-1} B(P,Q,p_i,q_i)}
        {P \times Q}.
    \label{eqn.f_non_systematic}
\end{equation}

\noindent Puisque la taille d'une projection ne peut être inférieure à la
longueur d'une ligne de la grille (i.e.\ $Q \leq B(P,Q,p_i,q_i)$), le coût $\mu$
des données encodées est inférieur en systématique qu'en non-systématique.
Dans la suite de notre évaluation, nous considérons un ensemble de projections
de telle sorte que $q_i =1$ pour $i \in \mathbb{Z}_Q$, on peut alors écrire
\cref{eqn.nombre_bins2} ainsi :

\begin{equation}
    B(P,Q,p_i,1) = (Q-1)|p_i| + P.
    \label{eqn.taille}
\end{equation}

\noindent La valeur de $\mu$ dépend naturellement de l'ensemble de projections
choisi. En particulier, pour une taille de grille fixée, la valeur du paramètre
$p$ des directions de projections influence la valeur de $\mu$. Afin de réduire
cette valeur, nous choisirons alternativement des entiers positifs puis
négatifs, dont la valeur croît à partir de zéro, comme valeurs de $p_i$. Par
exemple, pour le code sous sa forme systématique, nous considérerons les
ensembles de projection $S_{\left(\frac{n}{k}\right)} = \{(p_i,q_i)\}$ suivants :

1. $S_{\left(\frac{3}{2}\right)} = \left\{(0,1)\right\}$,

2. $S_{\left(\frac{6}{4}\right)} = \left\{(0,1),(1,1)\right\}$,

3. $S_{\left(\frac{9}{6}\right)} = \left\{(0,1),(1,1),(-1,1)\right\}$,

4. $S_{\left(\frac{12}{8}\right)} = \left\{(0,1),(1,1),(-1,1),(2,1)\right\}$.

\noindent Ces ensembles partagent le même taux de codage $r=\frac{3}{2}$ et
fournissent respectivement une tolérance face à une, deux et quatre pannes.

\begin{figure}
\centering
\input{./tikz/ec_vs_rep.tikz}
\caption{Calcul de la valeur de $\mu$ pour différentes techniques de
    redondance en fonction de différents paramètres de code $(n,k)$.
    Le taux de codage est fixé à $\frac{3}{2}$ tel que ces paramètres valent
    respectivement $(3,2)$, $(6,4)$, $(9, 6)$ et $(12,8)$. Les codes issus de
    ces paramètres sont capables de supporter de une à quatre pannes
    respectivement. La valeur illustrée pour le code à effacement Mojette
    correspond à une taille de bloc de données de $\mathcal{M} = 1$~Ko.}
\label{fig.ec_vs_rep}
\end{figure}

Le \cref{tab.f} compare les résultats des coûts $\mu$ (à l'arrondis près) pour
les deux versions du code à effacement Mojette avec les ensembles de projection
proposés précédemment. Pour obtenir ces résultats, on a utilisé une taille de
pixel de $64$ bits. En conséquence, la valeur de $P$ qui correspond à la
largeur de la grille est calculé peut être obtenu ainsi :

\begin{equation}
    P = \frac{\mathcal{M} \times 8}{k \times 64},
\end{equation}

\noindent avec $\mathcal{M}$ qui correspond à la taille des données traitées en
octets. Ces résultats permettent d'observer que lorsque les paramètres $(n,k)$
du code augmentent, la valeur de $\mu$ augmente. Plus précisément, en $(12,8)$,
la version non-systématique possède un coût élevé de $\mu=3,47$, contre $1,72$ en
systématique. Dans ce cas, $P = 16$, ce qui correspond à $(2 \times Q)$. Or,
cette faible différence entraîne de grandes valeurs dans \cref{eqn.taille}.
Plus la valeur de $P$ augmente, plus la valeur de $\mu$ diminue. C'est ce que
l'on observe dans le tableau, où les valeurs de $\mu$ convergent vers la valeur
optimale $\mu=1,50$ qui correspond à la valeur atteinte par un code MDS.


## Coût de la redondance par rapport à d'autres codes

Dans notre évaluation, nous allons considérer trois techniques qui permettent
de générer de la redondance : la réplication, le code à effacement MDS, et le
code à effacement Mojette dans sa version systématique. La \cref{fig.ec_vs_rep}
présente notre évaluation.

Dans le cas de la réplication, le facteur de redondance $\mu$ correspond au
nombre de copies générées. Par exemple, dans le cas où l'on souhaite protéger
la donnée face à deux pannes, il est nécessaire de générer deux copies en plus
de l'information initiale. Dans cet exemple, le facteur de redondance $\mu$
vaut $3$.

Dans le cas des codes à effacement, nous fixons le taux de codage de $r =
\frac{3}{2}$ afin comparer la valeur de $\mu$ équitablement. Nous allons
comparer ces techniques pour plusieurs paramètres de code $(n,k)$ définis dans
l'ensemble $\left\{(3,2),(6,4),(9,6),(12,8)\right\}$.
Pour les codes MDS, la valeur du facteur de redondance $\mu$ correspond au taux
de codage. En effet $r$ correspond à la quantité de donnée en sortie $n$ sur la
quantité de donnée en entrée $k$. C'est pourquoi, si l'on fixe un taux de
codage $r$, quelque soit la tolérance au panne de notre code, la quantité de
redondance produite reste la même. En conséquence dans la \cref{fig.ec_vs_rep},
la valeur de $\mu$ correspond à $r=\frac{3}{2}=1,5$ quel que soit la tolérance
aux pannes fixée.




\section*{Conclusion}

Ce chapitre a permis de mettre en évidence l'intérêt de la conception d'une
version systématique du code à effacement Mojette. En particulier, nous avons
vu que le code s'inscrit comme un maillon important de la chaîne de
transmission de données, et qu'il doit être suffisamment performant pour ne pas
former un goulot d'étranglement entre les unités de traitement et les unités de
communication (stockage et réseau). Nous avons ainsi montré que le recours à
une version systématique permet d'améliorer significativement les performances
lors de l'encodage, et permet d'atteindre des performances optimales lors du
décodage.

Un algorithme d'inversion a été donné afin de reconstruire la grille dans le
cas systématique. Cet algorithme repose essentiellement sur deux modifications
de l'algorithme de \textcite{normand2006dgci}.

Enfin une évaluation du coût de la redondance a été réalisée. Cette évaluation
a permis de montrer que la version systématique peut également réduire
significativement la quantité de redondance générée par rapport au code sous sa
forme non-systématique. En particulier, lorsque la largeur de la grille
augmente, cette version converge plus rapidement vers la valeur optimale qui
correspond au cas MDS.

% ça poutre !

