
\chapter{Code à effacement Mojette systématique}

\label{sec.chap3}

\minitoc

\newpage

\section*{Introduction du chapitre}

\addcontentsline{toc}{section}{Introduction du chapitre}

Le chapitre précédent a permis de définir les codes à effacement basés sur les
transformations FRT et Mojette. Bien que le rendement de ce dernier soit
sous-optimal (c'est à dire $(1+\epsilon)$-MDS), il a la particularité de
disposer d'un algorithme de reconstruction itératif, de faible
complexité\ \cite{normand2006dgci}. Puisqu'elle détermine le nombre
d'opérations réalisées à l'encodage et au décodage, cette complexité joue alors
un rôle important dans les latences du code, et donc, sur les latences du
système de communication qui les utilise. Dans nos travaux de thèse, nous nous
intéressons au cas des codes à effacement AL-FEC, utilisés par les couches
\ct{hautes} du modèle TCP/IP (i.e.\ transport et application), dont le
rendement et la latence sont des critères essentiels. En effet,
le rendement joue un rôle sur l'utilisation des ressources (e.g.\ bande
passante sur un réseau, capacité d'un système de stockage). Quant à la latence,
elle ne doit pas limiter les performances du système de communication, étant
donné que l'encodeur et le décodeur sont des composants branchés en série dans
la chaîne de traitement de l'information.
Dans les systèmes de stockage distribués logiciels (*Software Defined Storage*
ou SDS), le chemin de données (communément appelé *data path*) correspond à
l'ensemble des composants par lesquels la donnée transite lors d'une
communication. Dans ce contexte, le rendement et la latence ne doivent ni
utiliser à outrance la capacité de stockage du système, ni limiter la latence
des transferts de fichiers.

L'objectif de ce chapitre est de proposer une nouvelle conception du code à
effacement Mojette sous sa forme systématique, qui permet en somme
d'intégrer les symboles sources dans les mots de code générés à l'encodage.
Cette construction sera présentée dans la \cref{sec.algo-sys}. Les
\cref{sec.eval.red,sec.systematique} qui suivent, mettront respectivement en
avant les deux principaux avantages de cette version, à savoir : (i)
l'amélioration du rendement du code à effacement Mojette provoquée par la
géométrie même de la transformation; une évaluation de ce gain de rendement
sera d'ailleurs présentée afin de positionner le rendement de notre code par
rapport au rendement optimal des codes MDS; (ii) la réduction du nombre
d'opérations réalisées par le code.

<!--
%Jusque là, les seuls travaux réalisés sur cette technique concerne une mise en
%œuvre au sein d'un brevet \cite{david2013patent}.
-->



# Conception du code à effacement Mojette systématique {#sec.algo-sys}

Cette section présente notre conception du code à effacement Mojette dans sa
version systématique. La \cref{sec.construction.code.systematique} présentera
dans un premier temps l'intégration des symboles sources dans le mot de code
lors de l'opération d'encodage. Dans un second temps, nous proposerons un
algorithme de reconstruction dans la \cref{sec.algorithme}, afin de
reconstituer les symboles sources en cas d'effacement. Nous verrons que
l'algorithme d'inversion présenté ici correspond à une extension de
l'algorithme inverse de \textcite{normand2006dgci}, qui a été étudié dans le
chapitre précédent.
<!--
%Une bonne compréhension de cet algorithme est nécessaire pour
%comprendre ce qui est réalisé dans cette section.
-->



## Construction du code systématique {#sec.construction.code.systematique}

Définissons tout d'abord la notion d'image dégradée. On appelle \ct{image
dégradée} (ou image partielle) $f'$, une grille dans laquelle $e$ lignes ont
été effacées. Une mise en œuvre du code à effacement Mojette sous sa forme
systématique précédemment a été proposée par \textcite{david2013patent}.  Dans
ce brevet, le procédé pour reconstruire une image $f'$ repose sur les trois
étapes suivantes :

1. calculer les valeurs des projections $\moj{\dir{(p_i,q_i)}}{f'}$ de la
grille partielle $f'$. Un ensemble suffisant de projections est défini par un
ensemble $(p_i,q_i)_{i \in {1,\dots,e}}$ de directions, nécessaire pour
reconstruire une grille dont $e$ lignes sont manquantes;

2. calculer la différence $\moj{\dir{(p_i,q_i)}}{f} -
\moj{\dir{(p_i,q_i)}}{f'}$;

3. appliquer l'algorithme de reconstruction de \textcite{normand1996vcip} en
utilisant les projections obtenues précédemment. Dans la suite, nous allons
présenter une nouvelle mise en œuvre basée sur l'algorithme de
\textcite{normand2006dgci}.

\noindent Ce que montre ce brevet, c'est que la construction de la version
systématique du code à effacement Mojette est directe. Les $n$ symboles du mot
de code correspondent aux $k$ lignes de la grille, auxquels on ajoute $(n-k)$
projections. Cette simplicité de conception en Mojette se distingue de la
détermination d'une matrice d'encodage d'un code de \rs systématique. Comme
nous l'avions précisé dans le premier chapitre, cette détermination nécessite
une élimination de \gj pour faire apparaître la partie identité de la matrice.
Toutefois cette technique ne s'est limitée qu'au brevet. Dans la suite nous
proposons une nouvelle méthode moins coûteuse en capacité et en accès mémoire.


## Algorithme de reconstruction {#sec.algorithme}

\input{alg/systematique}

L'algorithme de reconstruction présenté ici repose sur deux principales
modifications de l'algorithme de\ \cite{normand2006dgci}. Ces modifications
correspondent à : (i) une nouvelle détermination des décalages (i.e.\ appelés
*offsets* dans\ \cite{normand2006dgci}),
prenant en compte les lignes de la grille (i.e.\ les symboles sources) déjà
présentes dans la grille. Cette modification sera le sujet de la
\cref{sec.offsets}; (ii) une nouvelle méthode de calcul de la valeur d'un pixel
à reconstruire, prenant en compte les pixels déjà présents sur la droite de
projection. Cette méthode sera introduite dans la \cref{sec.pxl}.

L'\cref{alg.systematique} de reconstruction que nous avons conçu est présenté
en \cpageref{alg.systematique}. Dans un soucis de cohérence avec la description
de l'algorithme de \textcite{normand2006dgci}, nous utiliserons le terme
\ct{offset} pour parler des décalages nécessaires à la détermination du
parcours de reconstruction dans la grille. Pour les mêmes raisons, une
projection $\moj{\dir{(p,q)}}{}$ est désignée par Proj$_f(p,q)$.


### Détermination des *offsets* pour la reconstruction {#sec.offsets}

De manière comparable à ce qui a été réalisé dans l'algorithme de
\textcite{normand2006dgci}, il est nécessaire de déterminer la valeur des
*offsets*. Ces *offsets* désignent les décalages attribués à
chaque ligne à reconstruire, dans le but de définir l'ordre des pixels à
reconstruire. Cet ordre correspond donc au chemin de reconstruction de notre
algorithme. L'ordre de reconstruction des pixels est primordial pour que
l'algorithme de reconstruction ne soit pas bloqué. Plus particulièrement, cet
ordre permet à chaque itération, de ne considérer que les pixels du graphe sur
lesquels ne s'applique aucune dépendance.

Dans la version non-systématique, toutes les lignes de la grille doivent être
reconstruites.  En conséquence, pour déterminer la valeur de l'offset d'une
ligne, il est nécessaire de connaitre son index, ainsi que la direction de la
projection utilisée pour la reconstruire.
Dans la version systématique, il est par ailleurs nécessaire de prendre en
compte les lignes déjà présentes dans le calcul des *offsets* des lignes à
reconstruire.
On considère dans la suite l'ensemble des index $\text{Eff}(i)$ des lignes
effacées, triées par ordre décroissant, avec $i \in \ZZ_e$, tel que $e$ désigne
le nombre de lignes effacées. La détermination des valeurs des *offsets* se
fera de la dernière ligne à reconstruire, jusqu'à la première. Il est ainsi
nécessaire de calculer au préalable l'offset de la dernière ligne à
reconstruire $\text{Offset}(\text{Eff}(e-1))$. Pour cela, nous définissons
$S_{\text{minus}}$ et $S_{\text{plus}}$, qui permettent de déterminer la valeur
de $\text{Offset}(\text{Eff}(e-1))$, tel que :

\begin{align}
    S_{\text{minus}} &= \sum_{I=1}^{Q-2}\text{max}(0,-p_i),\label{eqn.sp}\\
    S_{\text{plus}} &= \sum_{I=1}^{Q-2}\text{max}(0,p_i),\label{eqn.sm}\\
    \text{Offset}(\text{Eff}(e-1)) &=
        \text{max}(\text{max}(0,-p_r) + S_{\text{minus}}, \text{max}(0,p_r)
        + S_{\text{plus}}).\label{eqn.offr}
\end{align}

\noindent La méthode pour déterminer la valeur de l'offset des autres lignes
est décrite entre les \cref{alg.offsets,alg.offsets.fin} de
l'\cref{alg.systematique} de reconstruction (cf. \cpageref{alg.systematique}).


### Calcul de la valeur du pixel à reconstruire {#sec.pxl}
\label{sec.valeur_pxl}

Comme nous l'avons vu dans le chapitre précédent, en non-systématique,
lorsqu'aucune dépendance ne s'applique sur un pixel que l'on souhaite
reconstruire, la valeur du pixel est directement lue dans le bin associé
$\text{Proj}_f(p_i, q_i, b)$. Dans la version systématique en revanche, lors de
la reconstruction, les valeurs des pixels ne dépendent plus seulement des
valeurs de bins, mais elles peuvent également dépendre des valeurs des pixels
déjà présents dans la grille.
Par définition de la transformation Mojette, un pixel participe à la valeur de
$\text{Proj}_f(p_i, q_i, b)$, comme élément de la somme des pixels situés sur
la droite d'équation $b = -kq_i + lp_{i}$.
Pour reconstruire sa valeur, on fait la différence de la valeur du bin de la
projection de $f$ avec le bin correspondant de la projection de $f'$. Plus
précisément, cette opération est définie comme suit :

\begin{equation}
    f(k,l) = \text{Proj}_f(p_i, 1, k - lp_i)
        + \text{Proj}_{f'}(p_i, 1, k - lp_i).
    \label{eqn.sys_pxl}
\end{equation}

\noindent où $Proj_{f'}(p_i, 1, k - lp_i)$ correspond à la somme des
valeurs des pixels de l'image en reconstruction, selon la droite passant par le
pixel de coordonnées $(k,l)$, d'équation $b=-kq_i +lp_i$. Cette équation est
utilisée pour reconstruire l'ensemble des pixels effacés de l'image partielle
$f'$, tel que décrit dans les instructions entre les
\cref{alg.pixel,alg.pixel.fin} de l'\cref{alg.systematique}.



# Évaluation du gain dans le rendement du code {#sec.eval.red}
\label{sec.surcout_stockage}

Un code MDS génère la quantité minimale de redondance pour une tolérance aux
pannes donnée. Dans le chapitre précédent, nous avons vu que le code à
effacement Mojette n'est pas optimal et est considéré comme $(1+\epsilon)$
MDS\ \cite{parrein2001phd}. Cette désignation met en exergue deux types de
redondance dans le code à effacement Mojette : (i) le premier type de
redondance correspond à la définition du rendement du code $\frac{k}{n}$. En ce
sens, le code Mojette définit un nombre de symboles optimal pour une capacité
de correction donnée; (ii) le second type de redondance provient de la
géométrie même de la transformation. Nous avons vu en effet dans le chapitre
précédent que la taille des projections augmente à mesure que la valeur de
$|p_i|$ s'accroit. Rappelons à présent que la valeur d'$\epsilon$ désigne le
facteur de la redondance présente à l'intérieur de $k$ symboles (i.e.\ un
ensemble suffisant pour reconstruire)\ \cite{parrein2001phd}. Ce critère dépend
ainsi du choix des $k$ symboles étudiés parmi les $n$ générés.

Afin de mieux correspondre au contexte du stockage, nous choisissons plutôt de
nous intéresser à la redondance totale générée par le code, afin d'évaluer la
taille totale occupée par les données encodées dans le cas de ce contexte.
Pour cela, nous définissons $\mu$ comme le rapport entre le nombre d'éléments
de symboles encodés (i.e.\ bins Mojette), et le nombre d'éléments sources
(i.e.\ pixels de la grille). Dans la suite nous évaluerons dans un premier
temps le gain de redondance induit par la version systématique du code Mojette,
par rapport à sa version non-systématique. Une seconde étude permettra de
positionner le coût de la redondance du code Mojette par rapport aux coûts
qui résultent des techniques de réplication et des codes MDS.


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
    systématique. L'ensemble $\{a,\dots,i\}$ correspond aux valeurs des pixels
    de l'image $3 \times 3$ (i.e.\ de hauteur $k=3$) qui ont permis de calculer
    les $n=6$ blocs encodés de la version non-systématique.}
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
somme du nombre de bins $B$ de chaque projection de l'ensemble $\{(p_i,q_i)\}$,
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
    valeur optimale obtenue par un code MDS (i.e.\ $1.50$).}
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
l'image :

\begin{equation}
    \mu = \frac
        {P \times Q + \sum\limits_{i=0}^{n-k-1} B(P,Q,p_i,q_i)}
        {P \times Q}.
    \label{eqn.f_non_systematic2}
\end{equation}

\noindent Puisque la taille d'une projection ne peut être inférieure à la
longueur d'une ligne de la grille (i.e.\ $Q \leq B(P,Q,p_i,q_i)$), le coût $\mu$
des données encodées est moindre en systématique qu'en non-systématique.
Dans la suite de notre évaluation, nous considérons un ensemble de projections
de telle sorte que $q_i =1$ pour $i \in \mathbb{Z}_Q$, on peut alors écrire
l'\cref{eqn.nombre_bins2} ainsi :

\begin{equation}
    B(P,Q,p_i,1) = (Q-1)|p_i| + P.
    \label{eqn.taille}
\end{equation}

\noindent La valeur de $\mu$ dépend naturellement de l'ensemble de projections
choisi. En particulier, pour une taille de grille fixée, la valeur du paramètre
$p$ de direction de projection influence la valeur de $\mu$. Afin de réduire
cette valeur, nous choisirons alternativement des entiers positifs puis
négatifs, dont la valeur croît à partir de zéro, comme valeurs de $p_i$. Par
exemple, pour le code sous sa forme systématique, nous considérerons les
ensembles de projection $S_{\left(\frac{n}{k}\right)} = \{(p_i,q_i)\}$ suivants :

1. $S_{\left(\frac{3}{2}\right)} = \left\{(0,1)\right\}$,

2. $S_{\left(\frac{6}{4}\right)} = \left\{(0,1),(1,1)\right\}$,

3. $S_{\left(\frac{9}{6}\right)} = \left\{(0,1),(1,1),(-1,1)\right\}$,

4. $S_{\left(\frac{12}{8}\right)} = \left\{(0,1),(1,1),(-1,1),(2,1)\right\}$.

\noindent Ces ensembles partagent le même taux de codage $r=\frac{3}{2}$ et
fournissent respectivement une tolérance face à une, deux, trois et quatre
pannes.

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

Le \cref{tab.f} compare les résultats des coûts $\mu$ (à l'arrondi près) pour
les deux versions du code à effacement Mojette avec les ensembles de
projections proposés précédemment. Pour obtenir ces résultats, on a utilisé une
taille de pixel de $64$ bits. En conséquence, la valeur de $P$ qui correspond à
la largeur de la grille peut être obtenue ainsi :

\begin{equation}
    P = \frac{\mathcal{M} \times 8}{k \times 64},
\end{equation}

\noindent avec $\mathcal{M}$ qui correspond à la taille des données traitées en
octets. Ces résultats permettent d'observer que la valeur de $\mu$ croît
lorsque les paramètres $(n,k)$ du code augmentent. Plus précisément, en $(12,8)$,
la version non-systématique possède un coût élevé de $\mu=3,47$, contre $1,72$ en
systématique. Dans ce cas, $P = 16$, ce qui correspond à $(2 \times Q)$. Or,
cette faible différence entraîne de grandes valeurs dans l'\cref{eqn.taille}.
Plus la valeur de $P$ augmente, plus la valeur de $\mu$ diminue. C'est ce que
l'on observe dans le tableau, où les valeurs de $\mu$ convergent vers la valeur
optimale $\mu=1,50$ qui correspond à la valeur atteinte par un code MDS. En
conséquence, on tâchera de considérer des tailles de blocs $\mathcal{M}$
suffisamment grandes (dans la mesure du possible), afin de réduire au mieux la
redondance contenue dans les symboles du mot de code.


## Coût de la redondance par rapport à d'autres codes

Dans notre évaluation, nous allons considérer trois techniques qui permettent
de générer de la redondance : la réplication, le code à effacement MDS, et le
code à effacement Mojette dans sa version systématique. La \cref{fig.ec_vs_rep}
(cf. \cpageref{fig.ec_vs_rep}) présente notre évaluation.

Dans le cas de la réplication, le facteur de redondance $\mu$ correspond au
nombre de copies générées. Par exemple, dans le cas où l'on souhaite protéger
la donnée face à deux pannes, il est nécessaire de générer deux copies en plus
de l'information initiale. Dans cet exemple, le facteur de redondance $\mu$
vaut $3$.

Dans le cas des codes à effacement, nous fixons le taux de codage de $r =
\frac{3}{2}$ afin comparer la valeur de $\mu$ équitablement. Nous comparons
ces techniques pour plusieurs paramètres de code $(n,k)$ définis dans
l'ensemble $\left\{(3,2),(6,4),(9,6),(12,8)\right\}$.
Pour les codes MDS, la valeur du facteur de redondance $\mu$ correspond au taux
de codage. En effet $r$ correspond à la quantité de donnée en sortie $n$ sur la
quantité de donnée en entrée $k$. C'est pourquoi, si l'on fixe un taux de
codage $r$, la quantité de redondance produite reste la même, indépendamment de
la tolérance aux pannes du code. En conséquence dans la \cref{fig.ec_vs_rep},
la valeur de $\mu$ correspond à $r=\frac{3}{2}=1,5$ quelle que soit la
tolérance aux pannes fixée.



# Considérations sur la réduction du nombre d'opérations {#sec.systematique}

Afin de ne pas former de goulot d'étranglement dans la chaine de transmission
du système de communication dans lequel il est utilisé, un code doit
fournir de bonnes latences en encodage et en décodage.
La \cref{sec.syscode} permet de comprendre la position du code
dans la chaîne de traitement. Nous introduirons des rapports
entre les différents maillons de cette chaîne et expliquerons quel doit être
l'ordre de grandeur des performances du code pour ne pas former un goulot
d'étranglement. Les deux analyses suivantes permettent de comprendre en quoi
une version systématique du code peut améliorer ses performances. En
particulier, la \cref{sec.sysenc} confirme que le gain en encodage est
significatif. La \cref{sec.sysdec} montre quant à elle, que les performances en
décodage dépendent du schéma de perte.


## Contraintes en performances des codes à effacement {#sec.syscode}

\begin{figure}[t]
    \centering
    \def\svgwidth{\textwidth}
    \includesvg{img/data_path3}
    \caption{Représentation du chemin de données dans la transmission entre deux
    terminaux. La donnée est présente dans la mémoire principale (RAM) du nœud
    $1$. L'encodage est réalisé par le CPU de ce nœud avant de transmettre
    l'information de l'interface réseau (NIC). Cette interface transmet ensuite
    l'information encodée sur le canal à effacement. Après réception des
    données par le nœud $2$, une opération de décodage est réalisée avant de
    restituer la donnée reconstruite à la mémoire. Cette figure est inspirée
    de\ \cite{tanenbaum2014os}.}
    \label{fig.data_path}
\end{figure}

Pour comprendre l'enjeu des performances des codes à effacement, nous
analyserons dans un premier temps son positionnement dans la chaîne de
traitement des données. Nous verrons alors que le code doit être suffisamment
performant pour ne pas former un goulot d'étranglement dans cette chaîne. Par
la suite, nous déterminerons un ordre de grandeur des performances que notre
code doit fournir.


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
	\caption{Comparaison des temps d'accès réels pour différentes opérations
	informatiques. La troisième colonne normalise ces temps sur la base d'un
	cycle CPU pour une seconde. Extrait de\ \cite{gregg2013performance}.
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
stockage. En conséquence, l'encodage s'opère entre l'ensemble des composants de
traitement (processeur, mémoire centrale), et l'ensemble des composants de
communication (stockage de masse, réseau).

Dans notre cas, il est nécessaire de concevoir un code à effacement qui ne
forme pas un goulot d'étranglement dans cette chaîne afin que ce soit le
matériel qui limite les performances du système. Dans les systèmes
distribués par exemple, on partage les ressources de différentes unités en
concevant des algorithmes distribués pour exploiter au maximum la capacité
du matériel.

Le \cref{tab.delai} donne une comparaison des délais observés pour certaines
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
RAM, il faudra nécessairement des interactions avec les disques de masse. Pour
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

Le \cref{tab.debit} donne l'ordre de grandeur des débits atteints par la RAM, les
interfaces réseaux, et les disques. En particulier on observe que les disques
et le réseau forment les éléments limitants.
Afin d'améliorer les performances d'un système composé de ces différents
éléments, il existe deux possibilités: (i) attendre puis acheter au prix fort
la nouvelle génération de matériel; (ii) agréger plusieurs composants ensemble
afin de partager leurs ressources. Bien que la seconde option apporte une
complexité de mise en œuvre, son prix est nettement plus accessible.
En ce qui concerne le stockage de masse, cette agrégation a
vu le jour avec la conception des différents niveaux de techniques RAID par
\textcite{patterson1988sigmod}. Par exemple, l'utilisation du RAID-0 permet
généralement d'augmenter les débits d'un facteur $2$. Côté réseau, des
techniques d'agrégation des liens réseaux existent, comme proposé par
\textcite{adiseshu1996sigcomm}. Il est alors possible d'améliorer les
performances en exploitant plusieurs interfaces et liens réseaux.

La présence du code au sein de la chaîne de traitement entraîne un
calcul intermédiaire entre le processeur et les médias de communication. Afin
de ne pas former un goulot d'étranglement dans cette chaîne, le code doit
être suffisamment performant pour supporter les débits montants des disques
et/ou du réseau. Une évaluation des performances des codes à effacement
utilisés dans les applications de stockage a été réalisée par
\textcite{plank2009fast}. Dans cette étude, les auteurs montrent
que les débits d'encodage et de décodage observés par les meilleurs codes sont
de l'ordre d'un gigaoctet par seconde. Par conséquent, il est possible que ces
codes forment un goulot d'étranglement dans le cas où un agrégat de disques ou
de liens réseaux sature le nœud.

Il est alors essentiel qu'un code puisse fournir de bonnes performances.
C'est pourquoi ce chapitre s'intéresse à l'optimisation des performances du
code à effacement basé sur la transformation Mojette. Nous verrons dans les
deux parties qui suivent, les bénéfices d'une version systématique sur
l'encodage et le décodage.


## Bénéfices de cette nouvelle technique sur l'encodage {#sec.sysenc}

\begin{figure}[t]
    \centering
    \def\svgwidth{\textwidth}
    \includesvg{img/mojette_sys_nsys2}
    \caption{Comparaison du nombre de projections calculées entre la forme
    systématique et non-systématique pour un code Mojette $(6,3)$. En
    particulier, les projections suivant les directions de l'ensemble $\{(p_i
    \geq 2,1)\}$ (en pointillés rouge) correspondent aux projections
    supplémentaires qu'il est nécessaire de calculer sous la forme
    non-systématique.}
    \label{fig.comparaison_systematique}
\end{figure}

Par rapport à la version non-systématique, cette nouvelle technique permet de
réduire significativement le complexité à l'encodage. En version
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
La \cref{fig.comparaison_systematique}
(cf.\ \cpageref{fig.comparaison_systematique}) représente la comparaison entre
les deux techniques pour cet exemple.
En version systématique, l'ensemble des données encodées correspond aux $k$
lignes de la grille, auxquelles on ajoute $r=3$ projections calculées. Dans
notre exemple, ces projections sont construites suivant les directions
$\{(p_i,q_i)\} = \{(-1,1),(0,1),(1,1)\}$. Sous sa forme non-systématique, le
code à effacement Mojette doit calculer trois projections supplémentaires afin
de fournir la même disponibilité des données. Sur la
\cref{fig.comparaison_systematique}, ces projections supplémentaires sont
représentées en rouge. Cette nouvelle version systématique
nécessite de calculer deux fois moins de projections dans cet exemple.
Cette réduction du nombre d'opérations dépend des paramètres du code. Si
l'on prend le cas d'un code $(6,4)$, l'encodage génère trois fois moins de
projections. Nous verrons dans la suite l'impact sur le décodage.


## Bénéfice de cette technique sur le décodage {#sec.sysdec}

Dans cette partie nous allons étudier le comportement du code systématique en
fonction du schéma de perte. On distingue trois schémas de pertes : (i) le cas
optimal correspond à la situation où la grille n'a subi aucun effacement; (ii)
le cas où la grille est dégradée (i.e.\ elle subit un nombre $e$ d'effacements,
où $e<k$); (iii) le pire cas où toute la grille est effacée.

% La \cref{fig.sys_decodage} représente ces trois cas avec

% un code à effacement $(6,3)$ appliquée sur une grille

% $(3 \times 3)$.

### Accès direct sans dégradation

Lorsqu'aucune ligne de la grille n'est effacée, il s'agit du meilleur cas.
C'est dans cette situation que réside le principal avantage de cette technique
puisqu'il n'est pas nécessaire d'exécuter d'opération de décodage. Si aucune
des $k$ lignes de données ne subit d'effacement, la donnée est immédiatement
accessible en clair. En conséquence aucun calcul n'est réalisé et les
performances sont optimales.

% En pratique dans certaines applications, il s'agit

% du cas le plus courant. {CITER QUELQUE CHOSE}

En comparaison, dans le cas non-systématique, il est toujours nécessaire de
reconstruire la grille entière, même lorsqu'aucun effacement ne survient. Quel
que soit le schéma de perte, le décodage met en jeu $k$ projections pour
reconstruire les $k$ lignes. En conséquence, le décodage nécessite toujours un
travail calculatoire dont le coût est significatif.
Dans la suite, nous analysons le cas où des effacements se produisent.

### Dégradation partielle des données

Une dégradation des données entraîne nécessairement une opération de décodage
afin de restaurer la donnée perdue. Nous considérons à présent que le nombre de
lignes de grille discrète effacées $e$ est inférieur à $k$. Dans ce cas,
l'opération de décodage est possible dès lors que l'on accède à un ensemble
suffisant de $e$ projections pour reconstruire les $e$ lignes effacées. Plus
précisément, ce problème correspond à reconstruire une grille partiellement
remplie.
%L'algorithme d'inversion doit donc prendre en compte non seulement la valeur
%des bins des projections, mais également la valeur des pixels déjà présents
%dans la grille. Nous verrons en détail ce nouvel algorithme dans la prochaine
%partie.

% \Cref{fig.syspartial} montre une le cas où $e=2$

% lignes de la grille discrète ont été effacées. L'opération

%de décodage consiste à rétablir les données des lignes perdues

%à partir de $e = 2$ projections.

En comparaison avec la version non-systématique, cette nouvelle mise en œuvre
est plus performante. En effet, quelque soit le schéma de perte en
non-systématique, il est nécessaire d'utiliser $k$ projections pour
reconstruire l'ensemble de la grille tout entière.
Toutefois, cette nouvelle technique correspond à la reconstruction d'une
grille partiellement reconstruite. En conséquence, l'ensemble des pixels à
reconstruire est moins important que dans le cas non-systématique et donc,
moins d'opérations sont nécessaires pour le décodage.


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
Ces performances se dégradent alors avec le nombre de lignes effacées, et le
pire cas est obtenu quand toute la grille est effacée. Dans cette situation,
l'opération de décodage correspond à l'opération effectuée en non-systématique,
et les performances sont en conséquence semblables pour les deux techniques.
Rappelons que la forme non-systématique fournit les mêmes performances quel que
soit le schéma de perte puisqu'il est nécessaire de reconstruire la grille
entière à partir de $k$ projections. En comparaison, cette situation correspond
au pire scénario de perte dans le cas systématique. Dans tous les autres cas,
les performances en systématique sont meilleures.




\section*{Conclusion du chapitre}

\addcontentsline{toc}{section}{Conclusion du chapitre}

Dans ce chapitre, nous avons présenté un moyen permettant d'améliorer le code à
effacement Mojette selon deux critères parmi la liste élaborée dans le premier
chapitre, à savoir : (i) le rendement; (ii) le nombre d'opérations nécessaires
pour l'encodage et le décodage. Cette méthode consiste à utiliser le code à
effacement Mojette sous sa forme systématique. Une construction de cette
version a été proposée dans la \cref{sec.algo-sys}. Cette construction (simple
à mettre en œuvre) consiste à considérer que les $n$ symboles d'un mot de code,
sont composés des $k$ lignes de la grille, et de $n-k$ projections Mojette.
Pour accompagner cette proposition de conception, un algorithme d'inversion a
été proposé afin de reconstruire la grille dans le cas systématique. Par la
suite, nous avons analysé les conséquences de cette construction, et avons
déterminé deux améliorations.

La première amélioration concerne le rendement du code Mojette. La
\cref{sec.eval.red} a permis de montrer que le surcoût de redondance de ce code
provient de la géométrie de la transformation. Plus précisément, les
projections sont de taille variable, et cette taille augmente avec l'index de
la projection. La version systématique permet de réduire la quantité de
redondance générée par le code en diminuant la quantité de projections à
générer. Bien que le rendement converge vers l'optimal (au sens MDS) à mesure
que la largeur de la grille augmente, nous avons pu observer une réduction de
la quantité de données encodées par deux dans le cas extrême de notre
évaluation. Ce cas met en jeu une grille de faible largeur (i.e.\ $P=16,Q=8$).

La seconde amélioration, traitée dans la \cref{sec.systematique} s'intéresse
à l'amélioration du critère lié au nombre d'opérations nécessaires pour
l'encodage et le décodage. Pour les mêmes raisons que pour le rendement
(i.e.\ moins de projections à calculer), le nombre d'opérations nécessaires en
encodage est réduit. Par exemple, dans le cas d'un code de rendement
$\frac{3}{2}$, il y a trois fois moins de projections à calculer. Le décodage
nécessite également moins d'opérations, dans le cas où certaines lignes de la
grille sont disponibles. En particulier, cette amélioration permet un accès
immédiat aux données lorsqu'aucun des symboles sources (i.e.\ les lignes de la
grille) n'est effacé.

% ça poutre !

