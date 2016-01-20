
\chapter{Conception et évaluation d'une nouvelle mise en œuvre systématique du
code à effacement Mojette}


Dans le chapitre précédent, nous avons vu la transformée de \radon fini et la
transformée Mojette, deux codes à effacement conçus à partir d'une
approche géométrique. En particulier, nous avons montré que ces deux codes
disposent d'algorithmes efficaces pour générer des données de redondance lors
de l'encodage, puis pour décoder et reconstruire l'information initiale.
Bien que la transformée de \radon fini a l'avantage de fournir un code optimal
au sens MDS, la transformée Mojette offre des algorithmes d'encodage et de
décodage plus efficaces.
Le code forme un maillon crucial dans la chaîne de transmission de données,
situé entre les unités de traitement de données, et les unités de
transmission ou de stockage de l'information. Il est alors important que le
code soit suffisamment important pour ne pas former un goulot d'étranglement
dans la transmission de l'information.
Bien que ses algorithmes soient efficaces, le code à effacement par transformée
Mojette n'a été défini que sous sa forme non-systématique. Dans l'objectif
d'améliorer significativement les performances de ce code, nous allons définir
et évaluer dans ce chapitre, une version systématique de ce code. Nous
rappelons qu'en systématique, les données utilisateur sont intégrées en clair
dans les données encodées.
En particulier, ce chapitre débute par la \cref{sec.systematique} qui
s'intéresse aux enjeux des performances d'un code à effacement au sein de la
chaîne de traitement des données. Après quoi, nous verrons en quoi une version
systématique permet d'améliorer significativement à la fois les performances
d'encodage et de décodage.
La \cref{sec.algo-sys} présente en détail comment nous sommes parvenus à
concevoir cette version. En particulier, nous verrons que l'algorithme utilisé
est une extension de l'algorithme de \textcite{normand2006dgci}.
Dans une dernière partie \cref{sec.comparaison}, nous analyserons les impacts
de cette nouvelle méthode sur la quantité de donnée redondante nécessaire à
l'inversion. Nous verrons que la version systématique permet également de
réduire cette redondance d'information. Pour finir, nos verrons une évaluation
du code à effacement Mojette, et comparerons ses performances avec les
meilleures implémentations actuelles. En particulier, nous verrons que cette
version améliore significativement les performances du code, et offre de
meilleures performances que l'implémentation des codes de Reed-Solomon
développée par \textsc{Intel}.



# Les avantages d'une version systématique {#sec.systematique}

Cette première section permet de comprendre les enjeux de la conception d'une
version systématique du code à effacement basé sur la transformée Mojette.
La première étude \cref{sec.syscode} permet de comprendre la position du code
dans la chaîne de traitement. En particulier nous introduirons des rapports
entre les différents maillons de cette chaîne et expliquerons quel doit être
l'ordre de grandeur des performances du code pour ne pas former un goulot
d'étranglement. Les deux analyses suivantes permettent de comprendre en quoi
une version systématique du code peut améliorer ses performances. En
particulier, \cref{sec.sysenc} détermine que le gain en encodage est
significatif. \Cref{sec.sysdec} montre que les performances en décodage
dépendent du schéma de perte. Plus précisément, dans le pire cas, les
performances sont équivalentes à la version non-systématique. Dans le meilleur
cas, les performances sont optimales.


## Le besoin de performance en communication {#sec.syscode}

\begin{figure}[t]
    \centering
    \def\svgwidth{.7\textwidth}
    \includesvg{img/data_path}
    \caption{Représentation de la chaîne de transmission de donnée entre deux
    terminaux.}
    \label{fig.data_path}
\end{figure}

Pour comprendre l'enjeu des performances des codes à effacent, nous analyserons
dans un premier temps le positionnement du code à effacement dans la chaîne de
traitement des données. Nous verrons alors qu'il doit être suffisamment
performant pour ne pas former un goulot d'étranglement dans cette chaîne. Par
la suite, nous déterminerons un ordre de grandeur des performances que notre
codes doit fournir.


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
intrinsèquement liées au matériel qui traitent et transporte la donnée, ainsi
qu'aux techniques de codage qui permettent aux informations de transiter.
\Cref{fig.data_path} représente une vue générale de la chaîne de transmission
entre deux terminaux interconnectés. La donnée issue de la RAM du nœud $1$ est
traitée par le CPU afin de la transmettre sur le média de communication à
partir de l'interface réseau. Sur le réseau, l'information passe au travers de
composants gérant le transport et l'acheminement des données. Une fois parvenue
au destinataire, une opération inverse à la première étape est réalisée afin de
stocker cette donnée dans la RAM du nœud $2$.
L'objectif du code à effacement est de traiter les données avant leur
transmission ou leur stockage. En conséquence, ce traitement se situe entre
l'ensemble de traitement "CPU, RAM", et l'ensemble de communication
"stockage de masse, réseau".

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
complexité supplémentaire de mise en œuvre, elle est nettement plus accessible
en terme de prix. En ce qui concerne le stockage de masse, cette agrégation a
vu le jour avec la conception des différents niveaux de techniques RAID par
\textcite{patterson1988raid}. Par exemple, l'utilisation du RAID-0 permet
généralement d'augmenter les débits d'un facteur $2$. Pour le réseau, cette
agrégation peut être exploitée par l'agrégation de lien réseau, exploitée par
des algorithmes de répartition comme proposé par
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
C'est pourquoi ce chapitre s'intéresse à l'amélioration des performances du
code à effacement basé sur la transformée Mojette. Nous verrons dans les
deux parties qui suivent, les bénéfices d'une version systématique sur
l'encodage et le décodage.


## Bénéfice de cette nouvelle technique sur l'encodage {#sec.sysenc}

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
    \label{fig.comparaison_systematique}
\end{figure}

Les modifications de cette nouvelle technique sur l'encodage sont directes.
Précédemment avec la version non-systématique, il était nécessaire de calculer
$n$ projections à partir d'une grille discrète constituée de $k$. Dans cette
nouvelle version systématique, nous considérons les $k$ lignes de cette grille
comme faisant partie des données encodées. En conséquence, il suffit de
calculer $(n-k)$ projections pour fournir la même protection qu'avec l'approche
classique du code à effacement Mojette $(n,k)$. D'une manière générale, le
rapport de quantité de données $g$ à calculer correspond à :

\begin{equation}
    g = \frac{n}{n-k}
    \label{eqn.gain}
\end{equation}

Prenons l'exemple d'un code avec un taux $r={2}$, comme un code
$(6,3)$ fournissant de la protection face à trois effacements.
\Cref{fig.comparaison_systematique} représente la comparaison entre les deux
techniques pour cet exemple. En non-systématique, il est nécessaire de générer
$6$ projections à partir d'une grille de hauteur $3$, et de transmettre ces
$n=6$ projections. Ces projections sont représentées en \cref{fig.nsys}.
La version systématique en revanche ne génère que $3$ projections pour fournir
la même protection. Plus précisément, l'ensemble des données encodées
correspond aux $k=3$ lignes de données de la grille, plus les $r=3$ projections
calculées, comme le montre \cref{fig.sys}. En conséquence, cette nouvelle version
calcule $2$ fois moins de projections dans notre exemple. Autrement dit,
l'encodage systématique améliore les performances d'un facteur $2$ dans cette
configuration. Si l'on prend le cas d'un code $(6,4)$, l'encodage est trois
fois plus performant. Nous verrons dans la suite l'impact sur le décodage.


## Bénéfice de cette technique sur le décodage {#sec.sysdec}

\begin{figure}[t]
    \centering
    \begin{subfigure}{.3\textwidth}
		\centering
        \def\svgwidth{\textwidth}
        \footnotesize
		\includesvg{img/mojette3_sys_full}
        \caption{Sans dégradation}
        \label{fig.sysfull}
    \end{subfigure}
    \centering
    \begin{subfigure}{.3\textwidth}
		\centering
        \def\svgwidth{\textwidth}
        \footnotesize
		\includesvg{img/mojette3_sys_partial}
        \caption{Grille partielle}
        \label{fig.syspartial}
    \end{subfigure}
    \begin{subfigure}{.3\textwidth}
		\centering
        \def\svgwidth{\textwidth}
        \footnotesize
		\includesvg{img/mojette3_sys_empty}
        \caption{Cas non-systématique}
        \label{fig.sysempty}
    \end{subfigure}
    \caption{Représentation de trois schémas de perte (nul, partiel et complet)
    appliquée à une grille $(3 \times 3)$. Une proposition d'affectation des
    projections est illustrée à gauche des lignes à reconstruire en (b) et (c).}
    \label{fig.sys_decodage}
\end{figure}

Dans cette partie nous allons étudier le comportement du code systématique dans
le cas de trois schémas de perte. Nous verrons tout d'abord le cas optimal où
aucun effacement ne s'applique sur la grille. Puis nous analyserons le cas où
la grille est dégradée (i.e. elle subit un nombre $e$ d'effacements, où $e<k$).
Enfin nous verrons le pire cas où toute la grille est effacée.
\Cref{fig.sys_decodage} représente ces trois cas avec un code à effacement
$(6,3)$ appliquée sur une grille $(3 \times 3)$.

### Accès direct sans dégradation

Le principal avantage de cette technique est de ne pas avoir besoin d'exécuter
d'opération de décodage quand aucune des $k$ lignes de données ne subit 
d'effacement. En effet, dans ce cas, la donnée est immédiatement accessible en
clair. En conséquence aucun surcout calculatoire n'est engendré et les
performances sont considérées comme optimales. Ce cas est représenté en
\cref{fig.sysfull}.
Nous verrons dans la suite qu'en revanche, lorsque des effacements surviennent
sur la donnée, il est nécessaire d'appliquer un algorithme de décodage afin de
les reconstruire.

### Dégradation partielle des données

Une dégradation des données entraîne nécessaire une opération de décodage
afin de restaurer la donnée perdue. Nous considérons à présent que le nombre de
lignes de grille discrète effacés $e$ est inférieur à $k$. Dans ce cas,
l'opération de décodage est possible dés lors que l'on accède à un ensemble
suffisant de $e$ projections pour reconstruire les $e$ lignes effacées. Plus
précisément, il s'agit de reconstruire une grille qui serait partiellement
reconstruite.
L'algorithme d'inversion doit donc prendre en compte non seulement la valeur
des bins des projections, mais également la valeur des pixels déjà présents
dans la grille. Nous verrons en détail ce nouvel algorithme dans la prochaine
partie.
\Cref{fig.syspartial} montre une le cas où $e=2$ lignes de la grille discrète
ont été effacées. L'opération de décodage consiste à rétablir les données des
lignes perdues à partir de $e = 2$ projections.

En terme de performance, dans le cas où $e<k$, cette nouvelle mise en œuvre est
plus performante qu'en version non-systématique. Dans cette dernière, quelque
soit le schéma de perte, toute la grille doit être reconstruite à partir des
informations de projections.
En revanche, dans notre cas, l'opération de décodage correspond à la
reconstruction d'une grille partiellement reconstruite. En conséquence,
l'ensemble de pixels à reconstruire est moins important qu'en non-systématique
et donc, moins d'opérations sont nécessaires pour rétablir les données.

### Perte complète des données

Dans le cas où $(e=k)$, l'ensemble des lignes de la grille est effacé. Il est
alors nécessaire de décoder l'information à partir de $k$ projections.
L'opération de décodage correspond alors à l'opération de décodage réalisée
quand le code est non-systématique.

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



# Algorithme inverse en systématique {#sec.algo-sys}

L'algorithme d'inversion présenté dans cette section correspond à une extension
de l'algorithme inverse de \textcite{normand2006dgci}, étudié dans le chapitre
précédent.
Dans la suite, nous décrirons deux modifications majeures à cet
algorithme : (i) une nouvelle détermination des offsets de chaque projection
est nécessaire pour prendre en compte les lignes déjà reconstruites de la
grille, cette détermination sera présentée en \cref{sec.offsets}; (ii) un
nouveau calcul de la valeur du pixel à reconstruire qui prend en compte la
valeur des pixels présents sur la droite de projection, étudié en
\cref{sec.pxl}. Les différentes étapes pour reconstruire l'image en
systématique sont énumérées dans \cref{alg.systematique}.
 
\input{alg/systematique}



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
nombre de lignes effacées. Il faut tout d'abord on calcule l'offset de la
dernière ligne à reconstruire $\text{Offset}(\text{Eff}(e-1))$ :

\begin{align}
    S_{\text{minus}} &= \sum_{I=1}^{Q-2}\text{max}(0,-p_i),\label{eqn.sp}\\
    S_{\text{plus}} &= \sum_{I=1}^{Q-2}\text{max}(0,p_i),\label{eqn.sm}\\
    \text{Offset}(\text{Eff}(e-1)) &=
        \text{max}(\text{max}(0,-p_r) + S_{\text{minus}}, \text{max}(0,p_r)
        + S_{\text{plus}}).\label{eqn.offr}
\end{align}

La méthode pour déterminer la valeur des offsets est ensuite décrite dans
\cref{alg.systematique,alg.offsets}.


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

où $Proj_{\tilde{f}}(p_i, 1, k - lp_i)$ correspond à la somme des valeurs des
pixels de l'image en reconstruction selon la droite passant par le pixel de
coordonnées $(k,l)$, et d'équation $b=-kq_i +lp_i$, et où 
$Proj_{f}(p_i, 1, k - lp_i)$ correspond à la valeur du bin de la projection.



# Évaluations du code Mojette {#sec.comparaison}

Dans cette section, nous allons évalué la version systématique que nous venons
de concevoir. En particulier, nous verrons en \cref{sec.eval.red} une
évaluation du coût de la donnée encodée. Cette analyse permettra de voir que la
version systématique permet de réduire le nombre de bin nécessaires par rapport
à la version non-systématique. Nous comparerons ensuite les performances
théoriques du code à effacement Mojette, en montrant en \cref{sec.eval.xor} que
la version systématique nécessite moins d'opérations en encodage et décodage.
Enfin, nous verrons une évaluation des implémentations du code Mojette et
nous montrerons qu'ils fournissent de meilleures performances que les meilleurs
implémentations des codes de \rs. En particulier, \cref{sec.eval.perf} mettra
en avant les performances de la version systématique sur la version
non-systématique.


## Évaluation du coût de la donnée encodée {#sec.eval.red}
\label{sec.surcout_stockage}

Un code MDS génère la quantité minimale de redondance pour une tolérance aux
pannes donnée. Dans le chapitre précédent, nous avons vu que le code à
effacement Mojette n'est pas optimal et est considéré $(1+\epsilon)$ MDS.
En effet, bien qu'il soit capable de décoder $k$ blocs de données à partir de
$k$ blocs encodés, la taille de ces blocs peuvent dépasser la taille optimale.
En conséquence, pour une protection donnée, notre code génère plus de données
que la quantité minimale.
Dans cette section, nous allons définir et évaluer le surcout de redondance
généré par le code à effacement Mojette. Nous définissons pour cela $f$ comme
étant le coût de la donnée encodée. Plus particulièrement, $f$ correspond
au quotient du nombre d'éléments générés par le code, sur le nombre d'éléments
du message à encoder.

Dans notre évaluation, nous allons considérer trois techniques qui permettent
de générer de la redondance : la réplication, le code à effacement MDS, et le
code à effacement Mojette. Dans le cas des codes à effacement, nous allons
considérer un taux de codage de $r = \frac{3}{2}$ afin de les comparer
équitablement. Nous allons comparer ces techniques pour plusieurs paramètres de
protection, correspondant à une, deux et quatre pannes. En conséquence, les
paramètres $(n,k)$ des codes à effacement correspondant seront définis dans
l'ensemble $\left\{(3,2),(6,4),(12,8)\right\}$.

Dans le cas de la réplication, le facteur de redondance $f$ correspond au
nombre de copies générées, c'est à dire, à la tolérance aux pannes plus un. Par
exemple, dans le cas où l'on souhaite protéger la donnée face à deux pannes, il
est nécessaire de générer trois copies de l'information. En conséquence, dans
le cas de la réplication par trois copies, le facteur de redondance $f$ vaut
trois.

\begin{figure}
\centering
\input{./tikz/ec_vs_rep.tikz}
\caption{Comparaison du coût de stockage $f$ généré par différentes
    techniques de codes à effacement, en fonction de la tolérance aux pannes.
    Les paramètres des codes correspondent à $(n,k)$ égal $(3,2)$, $(6,4)$ et
    $(12,8)$, fournissant une protection face à une, deux et quatre pannes
    respectivement. Dans le cas particulier du code à effacement Mojette, deux
    tailles de bloc de données sont données : $\mathcal{M} = 4$~Ko et $8$~Ko.}
\label{fig:ec_vs_rep}
\end{figure}

Pour les codes MDS, la valeur du facteur de redondance $f$ correspond au taux
de codage. En effet $r$ correspond à la quantité de donnée en sortie $n$ sur la
quantité de donnée en entrée $k$. C'est pourquoi, si l'on fixe un taux de
codage $r$, quelque soit la tolérance au panne de notre code, la quantité de
redondance produite reste la même. En conséquence dans \cref{fig.ec_vs_rep}, la
valeur de $f$ correspond à $r=\frac{3}{2}=1,5$ quel que soit la tolérance aux
pannes fixée.

Pour le code à effacement Mojette, l'étude est moins triviale. Nous avons vu
dans la partie précédente que la taille des projections varie en fonction des
paramètres de la grille discrète $P$ et $Q$, ainsi que des paramètres des
directions de projections $(p_i, q_i)$. Sa valeur est donnée dans
\cref{eqn.nombre_bins}.
Dans le cas du code à effacement non-systématique, la valeur de $f$ correspond
au quotient de la somme du nombre de bin $B$ de chaque projection $(p_i,q_i)$
sur le nombre d'éléments de la grille :

\begin{equation}
    f = \frac
        {\sum\limits_{i=0}^{n-1} B(P,Q,p_i,q_i)}
        {P \times Q}.
    \label{eqn.f_non_systematic}
\end{equation}

Dans le cas où le code est systématique, $k$ projections sont remplacées par
les $k$ lignes de la grille discrète. En conséquence, la valeur de $f$
correspond au quotient du nombre de pixels et de bins, sur le nombre de pixels :

\begin{equation}
    f = \frac
        {P \times Q + \sum\limits_{i=0}^{n-k-1} B(P,Q,p_i,q_i)}
        {P \times Q}.
    \label{eqn.f_non_systematic}
\end{equation}

Puisque la taille d'une projection ne peut être inférieure à la longueur d'une
ligne de la grille (i.e.\ $Q \leq B(P,Q,p_i,q_i)$), la coût $f$ des données
encodées est inférieur en systématique qu'en non-systématique.

Dans notre évaluation, nous considérons un ensemble de projection de telle
sorte que $q_i =1$ pour $i \in \mathbb{Z}_Q$, alors :

\begin{equation}
    B(P,Q,p_i,1) = (Q-1)|p_i| + P.
    \label{eqn.taille}
\end{equation}

La valeur de $f$ dépend naturellement de l'ensemble de projections choisi. En
particulier, la valeur de $p_i$ influence sa valeur. Afin de réduire cette
valeur, nous choisirons alternativement des entiers positifs puis négatifs,
dont la valeur croît à partir de zéro, comme valeurs de $p_i$. Par exemple en
systématique, nous considérerons les ensembles de projection
$S_{\left(\frac{n}{k}\right)} = \{(p_i,q_i)\}$ suivants :

1. $S_{\left(\frac{3}{2}\right)} = \left\{(0,1)\right\}$,

2. $S_{\left(\frac{6}{4}\right)} = \left\{(0,1),(1,1)\right\}$,

3. $S_{\left(\frac{12}{8}\right)} = \left\{(0,1),(1,1),(-1,1),(2,1)\right\}$,

afin de protéger la donnée face à une, deux et quatre pannes respectivement.

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
	\caption{Résultats arrondis des coûts $f$ des données encodées pour les
	versions non-systématique (nsys) et systématique (sys) du code Mojette en
	fonction de différents paramètres de code $(n,k)$ et de différentes tailles
	de $\mathcal{M}$ en octets. Les résultats en italique représentent la
	valeur optimale obtenue par un code MDS.}
	\label{tab.f}
\end{table}

\Cref{tab.f} compare les résultats arrondis des coûts $f$ de la donnée encodées
pour les deux versions du code à effacement Mojette, avec un taux
$r=\frac{3}{2}$. Pour obtenir ces résultats, on a utilisé une taille de pixel
de $64$ bits. En particulier, la valeur $P$ correspond à :

\begin{equation}
    P = \frac{\mathcal{M} \times 8}{k \times 64},
\end{equation}

où $\mathcal{M}$ correspond à la taille des données traitées en octets.
Ces résultats permettent d'observer que lorsque les paramètres $(n,k)$ du code
augmentent, le coût $f$ augmente. Plus précisément, en $(12,8)$, la version
non-systématique possède un coût élevé de $f=3,47$. Dans ce cas, la valeur de
$P = 2 \times Q = 16$ et cette faible différence entraîne de grandes valeurs
dans \cref{eqn.taille}. Plus la valeur de $P$ augmente, plus la valeur de $f$
diminue. C'est ce que l'on observe dans le tableau, où les valeurs de $f$
convergent vers la valeur optimale $f=1,50$ correspondant à la valeur atteinte
par un code MDS.



## Analyse du nombre d'opérations {#sec.eval.xor}

Les performances d'un code dépendent intrinsèquement de la nature et du nombre
des opérations réalisées par le code. En ce qui concerne la nature des
opérations, la transformée Mojette n'utilise que des additions, ce qui se
traduit par des opérations de OU exclusifs dans l'implémentation. Nous avons vu
dans le premier chapitre que les codes de \rs reposent en revanche sur des
opérations de multiplication, plus complexes à mettre en place. Nous verrons
dans un premier temps le nombre d'opérations nécessaires pour les opérations
d'encodage. Le nombre d'opération pour calculer une projection est identique
que la version du code soit systématique ou pas. En revanche, nous verrons
qu'il est nécessaire de distinguer ce cas pour le décodage.


### Performances de l'encodeur Mojette

L'opération d'encodage génère $n$ projections à partir d'une grille discrète de
hauteur $k$. Dans la suite, nous analyserons le nombre d'opérations nécessaires
pour le calcul d'une projection.
Bien que la génération d'une projection met en jeu l'ensemble des
éléments de la grille discrète une et une seule fois (voir \cref{eqn.mojette}),
le nombre $c$ d'opérations nécessaires pour l'encodage varie en fonction de
deux paramètres : la taille de la grille, et la direction de projection.
Le nombre d'additions nécessaires pour générer une projection
$\text{Proj}_{f}(p,q,b)$ correspond à :

\begin{equation}
    \begin{aligned}
        c(P,Q,p,q)  &= P \times Q - B(P,Q,p,q), \\
                    &= P \times Q - \left((Q-1)|p_{i}|+(P-1)|q_{i}|+1\right),
    \end{aligned}
    \label{eqn.enc_mojette}
\end{equation}

et représente le nombre d'éléments de la grille discrète ($P \times Q$) auquel
on soustrait le nombre de bins de la projection, tel que défini dans
\cref{eqn.nombre_bins}. 
Considérons à présent que l'on fixe la taille de la grille, ainsi qu'un
paramètre de projection. Nous reprendrons notre exemple avec $q_i=1$. Dans ce
cas, si $p=0$, alors :

\begin{equation}
    c(P,Q,0,1) = (Q-1) \times (P - |p_i|).
    \label{eqn.enc_mojette_q}
\end{equation}

En conséquence, quand les dimensions de la grille sont fixées, si la valeur de
$|p|$ augmente, alors le nombre d'opérations nécessaire pour générer une
projection $c(P,Q,p,q)$ diminue. Cela signifie que plus une projection est
grande, moins elle nécessite d'opérations d'addition pour être calculée.
En conséquence, si seules les performances sont essentielles pour une
application, on choisira des projections avec de grandes valeurs de $|p|$.


### Performances du décodeur Mojette non-systématique

% ajouter le cas de l'algorithme dim'dim

% Nous comparerons ici deux algorithmes. Le premier correspond

% à l'algorithme de

% Le second correspond à un cas particulier

% de l'algorithme de reconstruction systématique, dans le cas où 

% toutes les lignes de la grille ont été effacées.

Nous prendrons comme sujet d'étude, l'algorithme de reconstruction BMI défini
par \textcite{normand2006dgci}. Dans cet algorithme, les opérations réalisées
correspondent à : (i) la reconstruction de $(P \times Q)$ pixels; (ii) la mise
à jour de l'ensemble des $k$ de chaque projection liés à chaque pixel
reconstruit. En conséquence, il est nécessaire de réaliser
$P \times Q \times Q$ additions pour reconstruire la grille entière.


### Performances du décodeur en systématique

\begin{figure}[t]
    \centering
    \def\svgwidth{.8\textwidth}
    \includesvg{img/dec_sys_mojette}
    \caption{Représentation de la méthode de détermination du nombre
    d'opérations nécessaire pour reconstruire une ligne $l$ à partir d'une
    projection. Cet exemple représente une grille $(P=12,Q=6)$. On cherche à
    reconstruire la ligne $l=2$ à partir de la projection suivant la direction
    $(p=1,q=1)$. Les éléments en rouge représentent les éléments impliqués dans
    la reconstruction de la ligne.}
    \label{fig.dec_sys_mojette}
\end{figure}

Lors du décodage en systématique, en cas d'effacement de la donnée, on affecte
la reconstruction d'une projection à une ligne effacée de la grille. Comme vu
précédemment dans \cref{sec.valeur_pxl}, la valeur du pixel à
reconstruire dépend non seulement d'un bin $b$ dans la projection
affectée, mais également de la somme des valeurs d'un ensemble d'éléments de la
grille. Notons qu'en fonction du pixel à reconstruire, le nombre d'opérations
nécessaire à sa reconstruction peut varier en fonction de sa position dans la
grille. En effet, un pixel situé dans un coin de la grille nécessitera en
général moins d'opérations qu'un pixel situé au milieu de la grille. De plus,
ce nombre va dépendre de la projection utilisée pour la reconstruction.
Si l'on reprend l'exemple d'un pixel situé dans un coin de la
grille, aucune opération n'est nécessaire si $(p,q) \ne (0,0)$, mais si
$(p,q)=(0,1)$ par exemple, alors $(Q-1)$ opérations seront nécessaires..

Soit $l$ l'index d'une ligne à reconstruire. \Cref{fig.dec_sys_mojette}
représente la situation où l'on souhaite reconstruire la ligne $l=2$ d'une
grille $(P=12,Q=8)$ en utilisant la projection suivant la direction
$(p=1,q=1)$. Les éléments de la grille en rouge représente les pixels utilisés
dans la reconstruction de la ligne $l$. Le nombre d'opérations nécessaires à la
reconstruction d'une ligne $l$ est défini par cet ensemble de pixel représenté
en rouge. Cet ensemble correspond aux éléments de la grille discrète contenus
entre les deux droites de projection qui passent par les extrémités de la ligne
$l$. Dans le cas général, ce nombre correspond à la surface de la grille
$(P \times Q)$ à laquelle on soustrait le nombre d'éléments de la ligne à
reconstruire $P$, et auquel on soustrait la surface en rouge. Dans notre
exemple, cette surface correspond à deux triangles rectangle discrets. Le
triangle supérieur possède une base et une hauteur de $l$, et le triangle
inférieur possède une base et une hauteur de $(Q-l)$. Le nombre d'opérations
nécessaires pour reconstruire cette ligne correspond à :

\begin{equation}
    c(P,Q,p,q,l) = (Q-1)P 
        - \frac{l(l+1)}{2}
        - \frac{(Q-l-1)(Q-l)}{2}
    \label{eqn.dec_sys_mojette}
\end{equation}

### Discussion

Bien que les performances théoriques sont liées par le nombre d'opérations
réalisées durant les opérations d'encodage et de décodage, d'autre critères
entrent en jeu en pratique, dans l'implémentation. Comme nous l'avons vu dans
la première section, les opérations doivent être réalisées au plus près du
processeur.
Un autre enjeu correspond à la localité spatiale de nos données. Cette
considération correspond à la caractéristique de notre algorithme à traiter les
données de manière séquentielle. L'intérêt d'un accès séquentiel aux données
repose sur deux considérations : (i) il n'est pas nécessaire de calculer et
d'accéder à de l'information distante (les disques durs mécaniques par exemple
perdent un temps considérable à déplacer les têtes de lecture pour accéder à
des données distantes); (ii) il est possible de charger en avance la donnée
pour la placer dans les zones mémoires près du processeur (c'est l'objectif de
l'appel système *readahead* sur Linux par exemple). Bien qu'il soit possible de
favoriser ces comportements, il est compliqué de les quantifier. Dans le cas du
code à effacement Mojette, nous avons vu que la géométrie du problème permet de
favoriser la localité spatiale.



## Expérimentations {#sec.eval.perf}

Dans cette section, nous évaluons les performances du code à effacement
Mojette et comparons ces résultats avec les performances des meilleures
implémentations des codes de Reed-Solomon.
Nous détaillons dans une première section les caractéristiques des codes
étudiés. Dans la suite, nous présenterons comment nous avons réalisé cette
expérimentation avant de nous intéresser aux résultats.

### Les implémentations à comparer

Nous avons choisi de comparer nos implémentations du code à effacement Mojette
avec une implémentation des codes de Reed-Solomon. De par leur popularité et
leur accessibilité, les codes de Reed-Solomon représentent le compétiteur
évident pour notre comparaison. Ces codes sont en effet largement distribués à
travers de nombreuses bibliothèques.

#### Implémentations Mojette

Nous avons implémenté une version systématique du code à effacement Mojette en
langage C. Le choix de ce langage est judicieux lorsque l'on développe une
technique de codage devant fournir de hautes performances. En effet la
possibilité de laisser la gestion mémoire à l'utilisateur, ainsi que le recours
à diverses instructions particulières du processeur, permettent d'atteindre
d'excellentes performances.

Dans la suite, nous reprenons la terminologie utilisée dans le chapitre
précédent \ref{sec:mojette_directe}. En pratique, la taille des pixels de la
grille discrète, et des bins des projections, doivent correspondre à un mot
machine. Un mot correspond à l'unité de base, exprimée en bits, manipulée par
un processeur. Pour les architectures classiques, la taille d'un mot
correspond à $32$ ou $64$ bits. Il s'agit plus exactement de la taille des
registres du processeurs. En conséquence, un processeur est d'autant plus
rapide que ses mots sont longs puisqu'une plus grande quantité d'information
est traitée à chaque cycle. Nous avons alors fixé la taille des bins
et pixels à $64$ bits. Cette valeur correspond à la taille des registres des
architectures usuelles aujourd'hui.

La plupart des processeurs proposent depuis 1997 des extensions de leur jeu
d'instructions afin d'améliorer les performances de certains traitements. Les
instructions *Single Instruction, Multiple Data* (SIMD) correspondent à un mode
de fonctionnement du processeur afin de profiter de parallélisme. Plus
particulièrement, il s'agit d'appliquer en parallèle la même instruction sur
plusieurs données afin d'obtenir plusieurs résultats. Les processeurs Intel par
exemple, proposent des extensions pour flux SIMD (*Streaming SIMD Extensions*
SSE) qui ajoutent jusqu'à 16 registres de 128 bits et 70 instructions
supplémentaires pour les processeurs x86. Ce mode de fonctionnement permet donc
de traiter $2048$ octets en parallèle, en un cycle processeur. Les applications
peuvent alors bénéficier de cela dés lors qu'une instruction
peut être réalisée sur plusieurs données. En pratique, ce mode est largement
utilisé dans les applications multimédias, scientifiques ou financières. Dans
le stockage, il permet notamment d'augmenter les performances du RAID logiciel
utilisé dans Linux \cite{anvin2004raid}.

Ce mode de fonctionnement est donc très intéressant pour notre code à
effacement étant donné que les performances sont cruciales dans les systèmes
temps-réel. Les algorithmes d'encodage et de décodage Mojette sont adaptés à ce
fonctionnement puisque nous appliquons une instruction, qui correspond à
l'addition, sur une multitude de données, représentées par les éléments de la
grille discrète et des projections. En conséquence, dans notre mise en œuvre,
l'addition est implémentée par des opérations de OU exclusif (XOR),
correspondant à des additions modulo deux, sur des données de $128$ bits.

Dans cette partie, nous allons comparer les performances de deux
implémentations de notre code à effacement Mojette : une première version
non-systématique, que l'on appellera *NS-Mojette* dans la suite de la
rédaction, puis une implémentation systématique que l'on désignera simplement
par *Mojette*.

### Configuration de l'expérimentation

\begin{figure}[t]
    \centering
    \def\svgwidth{\textwidth}
    \footnotesize
    \includesvg{img/expe_code2}
    \caption{Représentation de l'expérimentation. Les données aléatoires sont
    stockées dans un \emph{buffer} indexé par $k$ adresses. Le décodage est
    réalisé après avoir supprimé $e \times \frac{\mathcal{M}}{k}$ octets. On
    enregistre le compteur de cycles avant et après la fonction d'encodage et
    de décodage pour mesurer les performances.}
    \label{fig.expe_code}
\end{figure}

Dans cette partie, nous allons évaluer les performances d'encodage et de
décodage des implémentations des codes à effacement Mojette et Reed-Solomon,
présentés précédemment. Ces tests sont réalisés sur un seul processeur afin de
mettre en évidence la différence de performance entre les différentes
implémentations.

Les tests réalisés dans cette partie mettent en jeu plusieurs
plusieurs paramètres. Ainsi nous allons faire varier les paramètres $n$ et $k$
des codes à effacement, qui définissent implicitement la tolérance aux pannes
que fourni le code. En pratique, ce facteur dépend de la nature des données,
des applications et du support sur lequel transite la donnée.
Les fournisseurs de service web proposent en général une protection face à
quatre pannes. C'est le cas de Facebook, qui utilise des codes de Reed-Solomon
au sein de leurs grappes de stockage \cite{sathiamoorthy2013vldb}.
Un second paramètre concerne la taille des données $\mathcal{M}$ que nous
allons traiter. Dans la terminologie Mojette, cette taille correspond au nombre
d'éléments de la grille discrète. Ce paramètre dépend de l'application
utilisée. Dans le cadre de stockage de données POSIX, on choisira une taille
$\mathcal{M}$ correspondante à la taille des blocs du système de fichiers. Dans
l'exemple d'*ext4*, cette taille de blocs est de $4$ Ko. En revanche, dans des
applications mettant en jeu des accès séquentiels sur de grands fichiers, on
choisira une taille de bloc beaucoup plus importante afin de limiter le nombre
d'entrées/sorties. C'est le cas dans *Hadoop Distributed File Systems* HDFS,
qui met en jeu des applications d'analyse parallèle grâce à *Hadoop Map-Reduce*
sur des blocs de *128* Mo par défaut \cite{shvachko2010msst}.

\cref{fig.expe_code} représente l'expérimentation que l'on réalise.
Les performances enregistrées lors de l'encodage correspondent au
nombre de cycles CPU nécessaires pour générer $n$ blocs encodés à
partir de $k$ blocs de données. Ces $k$ blocs totalisent $\mathcal{M}$ octets.
Plus particulièrement dans notre mise en œuvre, ces $k$ blocs correspondent à
une zone mémoire de $\mathcal{M}$ octets de données aléatoire, dont on
représente chaque bloc par $k$ pointeurs vers l'adresse de début de ces blocs.
L'encodage non systématique consiste alors à la génération de $n$ blocs de
données encodés à partir de ces données d'entrées. En revanche, pour les
versions systématiques, les performances d'encodage correspondent à la copie
des $k$ blocs de données, plus la génération de $(n-k)$ blocs de parité. Le
critère de comparaison de performance entre les différents codes correspond
donc au nombre d'opérations du CPU nécessaires pour offrir une certaine
tolérance aux pannes.

Concernant le décodage, les performances enregistrées correspondent à la
reconstruction des $k$ blocs de données. Un nouveau paramètre entre en jeu dans
les opérations de décodage puisque le schéma de perte influence les
performances du code à effacement. En conséquence, nous enregistrons les
performances du CPU pendant le décodage tout en augmentant le nombre de pannes
jusqu'à la tolérance limite qu'offre le code. Dans notre cas, une panne
correspond à l'absence d'information dans un bloc de données si le code est
systématique, sinon il s'agira de la perte d'un bloc encodé.

Nos tests sont exécutés sur une seule machine, un seul processeur et un seul
*thread*. Toutes les opérations sont réalisées en mémoire, en prenant soin de
ne pas créer d'interactions avec le disque dur. Les cycles CPU concernent
précisément les opérations décrites précédemment. Plus exactement, nous ne
considérons pas certains pré-traitements tels que la génération des matrices
d'encodage dans le cas des codes de Reed-Solomon, ou la détermination du chemin
de reconstruction dans le cas des codes Mojette.

Puisque l'on mesure des fonctions d'encodage et de décodage hautement
optimisées pour nos architectures processeurs dont les temps d'exécution sont
de l'ordre de la nanoseconde, il est imprécis, voire impossible, de mesurer le
temps d'exécution de ces fonctions de nos implémentations. En revanche, puisque
ces calculs sont bornées par les considérations vues dans la partie
précédentes, et puisque nos instructions sur réalisées au sein d'un thread sur
un processeur, il est possible d'obtenir une mesure sur le nombre de cycles du
processeur. Plus précisément, on utilise le compteur temporel (*Time Stamp
Counter* TSC) qui est un registre spécial qui s'incrémente à chaque cycle CPU.
Pour cela, on utilise l'instruction *ReaD Time Stamp Counter* (ou RDTSC) qui
permet de récupérer la valeur de ce registre. Il suffit alors d'enregistrer sa
valeur avant et après nos fonctions d'encodage et de décodage et d'afficher la
différence. Intel propose une mise en œuvre afin de filtrer les résultats
aberrants \cite{intel1997rdtsc}.

Enfin, nous affichons la valeur moyenne qui résulte de $100$ itérations.
L'écart type n'est pas présenté puisqu'il est trop négligeable (et correspond à
moins d'un pour-cent des valeurs présentées). La machine utilisée provient de
la plate-forme *FEC4Cloud* située à Polytech Nantes. Cette machine dispose d'un
processeur Intel Xeon à $1,80$GHz, de $16$Go de mémoire RAM et de caches
processeurs de $128$Ko, $1$Mo et $10$Mo pour les niveaux *L1*, *L2* et *L3*
respectivement.

### Résultats de l'expérimentation

#### Performances d'encodage

\begin{figure}
    \begin{subfigure}{.49\textwidth}
        \centering
        \caption{$\mathcal{M}=4096$ octets.}
        \tikzset{every picture/.style={scale=0.85}}
        \input{expe_data/enc12.tex}
        \label{fig.encoding4k}
    \end{subfigure}
    \begin{subfigure}{.49\textwidth}
        \centering
        \caption{$\mathcal{M}=8192$ octets.}
        \tikzset{every picture/.style={scale=0.85}}
        \input{expe_data/enc13.tex}
        \label{fig.encoding8k}
    \end{subfigure}
    \centering
    \ref{named}
    \caption{Comparaison des performances d'encodage sur des blocs de données
    de $4$Ko (a) et $8$Ko (b). Les performances des codes Mojette et
    Reed-Solomon sont comparées par le nombre de cycles CPU nécessaire pour
    réaliser l'opération d'encodage (plus le résultat est petit, plus il est
    bon). Deux paramètres de codage ont été utilisés: $(6,4)$ et $(12,8)$. Les
    performances optimales sont représentées par \emph{no coding}.}
    \label{fig.encoding}
\end{figure}

Nous analysons dans cette partie les résultats à l'issu de notre
expérimentation sur les performances d'encodage. Les 
\cref{fig.encoding4k,fig.encoding8k} montrent les résultats obtenus pour
des tailles de blocs $\mathcal{M}$ équivalent à $4096$ et $8192$ octets
respectivement. Nous avons représenté sur ces courbes, les performances
optimales obtenues par une opération équivalente sans encodage. Plus
précisément, ces performances correspondent à la copie de $n$ blocs de données.
Dans le cas où $\mathcal{M}$ vaut $4$Ko, cela correspond à la copie de $6144$
octets. Pour une taille de bloc de $8$Ko, cela correspond à la copie de $12288$
octets. L'opération de copie de cette information est implémentée dans la
fonction *memcpy()* de la bibliothèque standard du C.

La première observation générale que l'on peut faire sur ces courbes d'encodage
est que les performances de la Mojette non-systématique sont comparables à
celles fournies par l'implémentation des codes de Reed-Solomon d'ISA-L. Plus
précisément, ces derniers sont moins performants lors de trois tests sur
quatre (la tendance s'inverse dans le test $(12,8)$ présenté dans
\cref{fig.encoding8k}). En réalité, il est important de rappeler que cette
implémentation du code Mojette doit calculer trois fois plus de données que les
autres implémentations testées dans notre expérimentation. En effet, puisque
cette version est non-systématique, elle doit calculer $12$ projections Mojette
dans le cas d'un code $(12,8)$, tandis que le code de Reed-Solomon doit
calculer seulement $4$ blocs de parité. On observe cependant dans le cas du
test de \cref{fig.encoding4k}, qu'il nécessite plus de $30$\% de cycles
supplémentaires par rapport à NS Mojette, pour protéger la donnée face à $4$
pannes. On observe donc que malgré le désavantage calculatoire de notre code en
version non-systématique, il parvient dans le cadre de nos tests à être
compétitif avec des codes systématiques.

Une deuxième observation est que la version systématique du code Mojette est
plus performante que sa version non-systématique. Ce résultat était attendu
puisque cette dernière version doit calculer
trois fois plus d'information lors de l'encodage. Notons cependant que la
différence observée entre les résultats de ces deux implémentations n'est pas
un facteur trois. Lors de nos tests d'encodage, le nombre de cycles CPU mesuré
des implémentations systématiques correspond à : (i) la copie des $k$ blocs
d'informations en clair; (ii) plus le calcul des $(n-k)$ blocs de
parité. Les résultats observés correspondent donc à la somme de cette copie et
de l'encodage. En revanche, si l'on prend l'exemple des résultats du code
Mojette $(6,4)$ sur des blocs de $4$Ko, présentés dans \cref{fig.encoding4k},
on observe que $(705-321) \times 3 = 1152$, où $321$ correspond aux nombres de
cycles CPU nécessaires pour copier $4096$ octets, et où $1152$ correspond à la
valeur observée dans les résultats de la version non-systématique de la même
courbe. Ces résultats nous permettent donc de valider que l'encodage
systématique est trois fois plus performant que l'encodage non-systématique
dans le cas où nos codes sont réglés sur un taux $r=\frac{3}{2}$.

En conséquence, nos courbes de résultats montrent que pour les paramètres
choisis dans nos expériences, l'encodage de l'implémentation non-systématique
offre des performances comparables à la meilleure implémentation des codes de
Reed-Solomon développée par Intel. De plus, la version systématique du code
Mojette que nous avons développée offre des performances d'encodage largement
supérieures à ce que proposent les autres codes utilisés dans nos tests. En
particulier, les résultats atteint par notre nouvelle mise en œuvre sont
proches des résultats optimaux correspondant à la copie de l'information, sans
opération d'encodage. Ceci montre que le surcout calculatoire de cette nouvelle
version est particulièrement réduit.


#### Performances de décodage

\begin{figure}
    \centering
    \begin{subfigure}{.49\textwidth}
        \caption{$(n,k) = (6,4)$, $\mathcal{M} = 4096$ octets}
        \tikzset{every picture/.style={scale=0.85}}
        \input{expe_data/dec12_1.tex}
        \label{fig.decoding_4k_l1}
    \end{subfigure}
    \begin{subfigure}{.49\textwidth}
        \caption{$(n,k) = (6,4)$, $\mathcal{M}= 8192$ octets}
        \tikzset{every picture/.style={scale=0.85}}
        \input{expe_data/dec13_1.tex}
        \label{fig.decoding_8k_l1}
    \end{subfigure}
    \begin{subfigure}{.49\textwidth}
        \caption{$(n,k) = (12,8)$, $\mathcal{M}= 4096$ octets}
        \tikzset{every picture/.style={scale=0.85}}
        \input{expe_data/dec12_2.tex}
        \label{fig.decoding_4k_l2}
    \end{subfigure}
    \begin{subfigure}{.49\textwidth}
        \caption{$(n,k) = (12,8)$, $\mathcal{M}= 8192$ octets}
        \tikzset{every picture/.style={scale=0.85}}
        \input{expe_data/dec13_2.tex}
        \label{fig.decoding_8k_l2}
    \end{subfigure}
    \ref{named}
    \caption{Comparaison des performances de décodage pour des paramètres de
    codes $(6,4)$ (a,b) et $(12,8)$ (c,d). Les courbes à gauche montrent les
    résultats pour des tailles de blocs de $4$Ko (a,c) tandis que les courbes
    de droite concernent des blocs de $8$Ko (b,d). Les performances des codes
    Mojette et Reed-Solomon sont comparées par le nombre de cycles CPU
    enregistré durant l'opération de décodage (plus c'est bas, mieux c'est)
    alors que l'on augmente progressivement le nombre d'effacement. Un
    effacement correspond à la perte d'un bloc encodé. Les valeurs optimales
    sont représentées par "No coding".}
    \label{fig:decoding}
\end{figure}

Nous analysons dans cette partie les résultats à l'issu de notre
expérimentation sur les performances de décodage. Les 
\cref{fig.decoding_4k_l1,fig.decoding_8k_l1} donnent les nombres de cycles CPU
nécessaires pour le décodage des codes $(6,4)$ pour des blocs de $4$Ko et $8$Ko
respectivement.
De manière similaire, les \cref{fig.decoding_4k_l2,fig.decoding_8k_l2}
concernent des codes $(12,8)$. Nous avons représenté sur ces courbes les
performances optimales de décodage correspondant à la copie de $k$ blocs
d'information.

La première observation générale que l'on peut faire concerne le cas où aucun
effacement ne survient lors du décodage. Dans ce cas, les deux codes
systématiques Mojette et Reed-Solomon atteignent les performances optimales
représentées sur nos courbes par "no coding". Ce résultat était attendu puisque
dans le cas des codes systématiques, lorsqu'aucun des $k$ blocs de données
n'est effacé, le décodage correspond à la lecture direct de ces $k$ blocs. Au
niveau de l'implémentation, cette lecture correspond à la copie de cette
information en clair.

À présent, lorsque des effacements surviennent, des opérations de décodage sont
déclenchées. Une première remarque globale est que l'influence des effacements
n'est pas le même selon si le code est systématique ou non. Pour NS Mojette, le
nombre d'effacement $e$ n'a pas d'influence sur les performances de décodage.
Ce résultat provient du fait que le décodage des codes non-systématiques
correspond à la reconstruction entière des informations utilisateurs. Ainsi le
nombre d'opérations est comparable quelque soit l'ensemble des blocs encodés
utilisé pour cette reconstruction.

Dans le cas des codes systématiques en revanche, le décodage correspond à
reconstruire un ensemble partiellement reconstruit de la donnée. En
conséquence, le nombre de cyles CPU nécessaires pour le décodage augmente au
fur et à mesure que l'on augmente le nombre de blocs de données effacés.
En particulier, la différence entre les performances de l'implémentation
systématique du code Mojette et des valeurs optimales augmente avec le nombre
d'effacement puisque l'on supprime progressivement des lignes de la grille
discrète. En effet, puisque l'on considère une grille de moins en moins
remplie, et puisque les opérations d'additions nécessaires à la reconstruction
Mojette sont plus coûteuses que la copie utilisée dans memcpy(), les
performances décroissent.

Notons cependant que malgré la baisse de performances du décodage observée
lorsque l'on augmente le nombre d'effacement pour le code systématique Mojette,
les valeurs enregistrées sont d'une part toujours meilleures que celles
observées pour la version non systématique (puisqu'il s'agit du cas où la
grille doit être entièrement reconstruite). D'autre part, ces performances sont
significativement meilleures que les performances observées par
l'implémentation systématique des codes de Reed-Solomon.

% #### Influence de la tolérance aux pannes

% #### Impact de la taille des blocs



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
de l'algorithme efficace de \textcite{normand2006dgci}.

Enfin une évaluation théorique puis pratique ont été réalisées. En particulier,
l'évaluation théorique a permis de montrer que la version systématique du code
Mojette permet de fournir de meilleures performances que la version
non-systématique, tout en réduisant le coût des données encodées. Dans
l'évaluation pratique, l'implémentation de cette version systématique a montré
des performances supérieures à celle fourni par sa version non-systématique et
par la meilleure implémentation des codes de \rs développée par Intel. En
particulier, elle permet d'atteindre des performances optimales en décodage
lorsqu'aucun effacement n'affecte les données encodées.

% ça poutre !

