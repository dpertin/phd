
\chapter{Méthode distribuée de reprojection}

\label{sec.chap6}

\minitoc

\newpage

\section*{Introduction du chapitre}

\addcontentsline{toc}{section}{Introduction du chapitre}

\begin{figure}[t]
  \centering
    \def\svgwidth{.7\textwidth}
    \includesvg{img/reprojection_pbx}
    \caption{Représentation du problème de reprojection. Étant donné un
    ensemble suffisant (i.e.\ selon \katz) de projections, le problème consiste
    à calculer les valeurs d'une nouvelle projection sans reconstruire la
    grille. Dans cet exemple, on propose une reprojection suivant la direction
    $(2,1)$.}
  \label{fig.reprojection.pb}
\end{figure}

Les chapitres précédents ont permis de présenter le fonctionnement du code à
effacement Mojette dans un système de stockage distribué tel que RozoFS. Les
travaux que nous allons présentés dans ce chapitre utilisent le code Mojette
sous sa forme non-systématique afin de déterminer de nouvelles projections.
On rappelle que sous cette forme, l'écriture entraîne la distribution de $n$
projections sur différents supports de stockage. Ces projections représentent
de manière redondante une information contenue dans une grille de hauteur $k$,
telle que $k<n$. Le critère de \katz permet de déterminer l'unicité de la
solution de construction. Plus précisément, il permet de garantir qu'un
ensemble de $k$ projections constitue un ensemble suffisant pour reconstruire
la grille (au plus $n-k$ peuvent être perdues).

Le problème abordé dans ce chapitre sera abordé du point de vue du système de
stockage, avant d'être décrit dans le formalisme Mojette.
À l'échelle du système de stockage, chaque panne qui engendre la perte d'un
support de stockage, entraîne également la perte d'une projection.
En conséquence, la quantité de redondance diminue avec le nombre de
panne. Avec le temps, les projections sont alors vouées à disparaître.
Cette baisse de la redondance constitue le problème principal abordé
dans ce chapitre. Afin de ne pas perdre définitivement de la donnée, il est
nécessaire de rétablir le seuil de redondance du système. L'objectif de ce
chapitre est donc de fournir une méthode afin de distribuer de nouvelles
données de redondance sur différents supports de stockage.
Du point de vue de la transformée Mojette, le problème est illustré dans la
\cref{fig.reprojection.pb}. Cet exemple met en jeu un ensemble de trois
projections satisfaisant le critère de \katz. Les directions $(p,q)$ de ces
projections appartiennent à l'ensemble $\{(-1,1),(0,1),(1,1)\}$.
Le problème que l'on cherche à résoudre consiste à déterminer les valeurs d'une
nouvelle projection (ici suivant la direction $(2,1)$) à partir de l'ensemble
des projections existant. Nous appelons cette opération «\ reprojection\ ».

Une approche peu performante de résolution de ce problème consiste à
reconstruire la grille à partir des projections, avant de projeter les valeurs
reconstruites vers la direction voulue. Pour répondre à ce problème, nous
proposerons une méthode de reprojection distribuée, et sans reconstruction de
l'information initiale. Cette méthode sera détaillée dans la
\cref{sec.reprojection.sans.reconstruction}. Une évaluation de cette technique
est proposée dans la \cref{sec.eval.reproj} afin de mettre en avant le gain de
latence dû à la distribution des calculs de reprojection. Enfin, la
\cref{sec.applications.reproj} détaille trois applications dans lesquelles
cette méthode peut être avantageusement utilisée.

% + application / discussion

<!--
%Nous avons vu dans les chapitres précédents qu'une représentation redondante de
%la donnée est nécessaire en télécommunications (e.g.\ transmission d'information
%ou systèmes de stockage) afin de fournir de la fiabilité dans des systèmes
%subissant des pannes. Ces pannes provenant par des pertes de paquet, des pannes
%disques, ou l'indisponibilité de serveurs par exemple.
%Dans le cas du code à effacement Mojette non-systématique, la perte d'un
%sous-ensemble de projections est contrebalancée par la présence de redondance
%contenue dans les projections supplémentaires calculées lors de l'opération de
%transformée. Une fois les projections calculées, on considère que l'image
%n'est accessible que par reconstruction. C'est le cas par exemple dans les
%applications de stockage distribué où l'image n'est utilisée que lors de la
%génération des projections. Une fois calculées, les projections sont
%distribuées et stockées sur différents supports de stockage.
%
%Dans ce contexte, il peut être nécessaire de calculer de nouvelles projections
%dans deux situations. Premièrement, les projections peuvent être définitivement
%perdues. C'est le cas lorsque qu'un support de stockage subit une panne
%permanente par exemple. Il est alors nécessaire de calculer et de distribuer de
%nouvelles projections afin de rétablir la tolérance aux pannes du système.
%Dans une autre mesure, il peut être désiré d'augmenter la tolérance aux pannes
%d'un système. C'est le cas en télécommunication lorsqu'on sait que
%l'information traverse un canal fortement bruité. Dans ce cas, il peut être
%nécessaire de calculer de nouvelles projections.
%
%La stratégie classique pour calculer de nouvelles projections à partir d'un
%ensemble existant consiste à reconstruire l'image et à la reprojeter suivant la
%direction voulue. Bien que simple à mettre en pratique, cette technique
%nécessite de reconstruire explicitement l'image. Cette méthode est illustrée
%dans la \cref{fig.reprojection.pb} qui présente l'exemple que nous allons
%étudié tout au long de ce chapitre. Notons que pour faciliter la lecture des
%schémas dans la suite du chapitre, toutes les opérations sont réalisées modulo
%$6$ (le choix de cette valeur est strictement arbitraire). Ainsi l'image peut
%être accessible par le nœud de reconstruction, ce qui n'est pas toujours voulu.
%C'est le cas lorsque l'on utilise la Mojette non-systématique comme base pour
%faire de la dispersion d'information \cite{rabin1989jacm}. Dans cette
%application, on ne désire pas que les nœuds de stockage puisse accéder à
%l'information utilisateur.
%\textcite{guedon2012spie} ont par exemple utilisé RozoFS pour distribuer des
%données sensibles (i.e.\ des documents médicaux) sur des plates-formes Cloud
%privées : *Amazon S3*, *Google Cloud Storage* et *Rackspace Cloud Files*.
%L'objectif de cette étude est le suivant. En considérant qu'une projection
%seule ne peut permettre à un fournisseur de stockage d'avoir d'information sur
%la donnée, il serait nécessaire à $k$ plates-formes Cloud de partager leurs
%informations pour reconstruire la donnée. Dans le cas de la reprojection, c'est
%exactement ce qui est réalisé.
%
%Dans ce chapitre, on va s'intéresser à une nouvelle technique pour générer de
%nouvelles projections. En particulier cette nouvelle méthode n'a pas besoin de
%reconstruire explicitement l'image. Dans l'approche classique, le calcul de
%reprojection est centralisé et réalisé par le nœud en reconstruction.
%Nous verrons que cette nouvelle technique permet de distribuer l'opération de
%reprojection sur l'ensemble des nœuds qui participent à la reconstruction.
%En particulier, nous verrons dans la
%\cref{sec.reprojection.sans.reconstruction} cette nouvelle méthode de
%reprojection basée sur la décomposition du processus de reconstruction, et sur
%la définition des fantômes. La \cref{sec.eval.reproj} s'intéressera à
%l'évaluation de cette nouvelle technique. Nous verrons en particulier qu'elle
%permet de diviser par deux le temps nécessaire à cette opération.
-->


# Reprojection sans reconstruction {#sec.reprojection.sans.reconstruction}

Dans cette section, nous présentons la nouvelle méthode de reprojection.
Nous définissons dans la \cref{sec.reconstruction.partielle} la méthode de
reprojection. La \cref{sec.conv} montre ensuite, comment traduire ces
opérations par des convolutions et des déconvolutions 1D. Cette méthode permet
en conséquence une reprojection sans reconstruction de l'image initiale.
Enfin, la \cref{sec.simplification.operations} expose des simplifications dans
les opérations de convolution.


## Méthode de reprojection {#sec.reconstruction.partielle}

Cette section présente la méthode de reprojection. Pour cela, nous définissons
dans un premier temps la notion de reconstruction partielle, afin de
décomposer le processus de reconstruction de la grille. Cette décomposition
permet notamment la distribution des calculs de reprojection. Par linéarité de
l'opérateur Mojette, nous montrons que la reprojection par des opérations 2D
est possible.

### Reconstruction partielle

\label{sec.dec.rec}

\begin{figure}[t]
  \centering
    \def\svgwidth{.7\textwidth}
    \includesvg{img/part_image3}
    \caption{Reconstruction partielle $f_S^{\{(0,1)\}}$ d'une grille $3 \times
    3$ à partir de la projection suivant la direction $(0,1)$, avec
    $S=\{(0,1),(1,1),(-1,1)\}$. En pratique, l'algorithme de
    \textcite{normand2006dgci}, utilisé pour reconstruire la grille, s'arrête à
    lorsque les pixels de la grille sont reconstruits. Dans le cas de cet
    exemple, nous l'avons itéré au delà de la grille (partie grisée). Les
    opérations sont arbitrairement réalisées modulo $6$.}
    \label{fig.part_image}
\end{figure}

La notion de reconstruction partielle a été introduite par \textcite[chap.
3]{philippe1998phd} dans ses travaux de thèse. Rappelons que le critère de
\katz permet de déterminer l'unicité de la solution de reconstruction,
relativement à un ensemble de projections.
Considérons par ailleurs, un ensemble de projections insuffisant au regard du
critère de \katz. Dans ce cas, l'algorithme de reconstruction ne permet pas de
reconstruire entièrement la grille. En revanche, les informations contenues
dans les projections permettent de reconstruire une partie de la grille.
L'algorithme de reconstruction peut ainsi reconstruire un nombre insuffisant
de pixels avant d'être bloqué. Dans ce cas, \textcite{philippe1998phd} propose
d'affecter une valeur arbitraire à certaine partie de l'image (appelée
«\ érodée\ » de l'image), afin de poursuivre la reconstruction exacte des pixels
de la grille.

Dans cette section, nous proposons de débloquer le processus de reconstruction
en étendant l'ensemble de projection disponible par des projections de valeur
arbitraire (typiquement des projections nulles). L'ensemble de projection ainsi
étendu permet de reconstruire exactement la grille. Dû fait de l'absence de
l'information des projections nulles, nous appelons l'image ainsi
obtenue «\ reconstruction partielle\ ».
La \cref{fig.part_image} illustre la reconstruction partielle d'une image $3
\times 3$ par la projection $(0,1)$ calculée depuis l'exemple de la figure
précédente (cf.\ \cref{fig.reprojection.pb}). Afin de satisfaire le critère de
\katz, l'ensemble des projections utilisé pour la reconstruction est étendu par
deux nouvelles directions, suivant les directions $(-1,1)$ et $(1,1)$. Bien que
les éléments de ces deux projections soient nulles, l'algorithme de
reconstruction peut être utilisé pour reconstruire de manière exacte une image.
Pour la reconstruction, on utilise l'algorithme de \textcite{normand2006dgci}.
Notons que dans l'exemple de la figure, l'algorithme ne s'est pas arrêté
lorsque tous les pixels de la grille ont été reconstruits. L'information en
dehors de la grille (partie grisée) n'est pas essentielle pour l'instant, mais
sera utilisée dans la suite de cette étude. 

Nous détaillons à présent la théorie mathématique liée, dans le formalisme de
la transformée Mojette. Soit $S$ un ensemble de $Q$ directions de projection
de la forme $(p_i, q_i=1)$. En conséquence $\sum q_i=Q$ et selon le critère de
\katz, toute image $P \times Q$ peut être reconstruite de manière unique par
l'ensemble des projections de directions dans $S$.
Si $R$ est un sous-ensemble non vide de $S$, alors une reconstruction partielle
est le processus qui reconstruit une image $f_S^R$ depuis un ensemble de
projections de directions dans $R$ (i.e.\ invalidant le critère de
\katz si $R\subsetneq S$). Parce que les projections dont les directions sont
dans l'ensemble $S \setminus R$ sont nulles, la reconstruction partielle
$f_S^R$ est un fantôme pour ces même directions. Les fantômes ont été
introduits dans le second chapitre. Un fantôme est une image $f :
\MM_{\{(p_q\}}f = 0$. Les propriétés des fantômes seront utilisées dans la
\cref{sec.conv}.


### Reprojection 2D

<!-- %projection partielle -->
On considère à présent un ensemble de projections suffisant, dont l'ensemble
des directions est $S$. Soit $\MM_{S}f$ l'ensemble des projections
(i.e.\ transformée) de $f$, engendré par l'ensemble des directions $S$. Soit
$R$ un sous-ensemble non vide de $S$. On considère alors $\MM_Rf$, qui
correspond à un sous-ensemble de projections de la transformée engendrée par
$S$.  En conséquence, si l'ensemble des directions de projection utilisées
forme une partition $\mathcal{P}(S)$ (i.e.\ $\cup_{R_i \in \mathcal{P}(S)} R_i =
S$) alors l'ensemble des projections engendré par $R_i$ est égale à la
transformée de $f$ par $S$ :

\begin{equation}
    \bigcup_{R_i \in \mathcal{P}(S)} {\MM_{R_i}}f = \MM_Sf\;.
    \label{eqn.somme_projection}
\end{equation}

\noindent En particulier, il est possible de déterminer les reconstructions
partielles engendrées par l'ensemble des directions formant une partition de
$S$. En conséquence, par linéarité de l'opérateur Mojette inverse, la somme des
valeurs de ces reconstructions partielles donne l'image $f$ : 

\begin{equation}
    \sum_{i} f_S^{R_i} = f\;.
    \label{eqn.somme_image}
\end{equation}

%http://tex.stackexchange.com/questions/19017/how-to-place-a-table-on-a-new-page-with-landscape-orientation-without-clearing-t
\afterpage{%
    %    \clearpage% Flush earlier floats (otherwise order might not be correct)
    %        \thispagestyle{empty}% empty page style (?)
    \begin{landscape}
    \begin{figure}[t]
    \vspace{-2.5cm}
      \centering
      \includegraphics[width=.8\columnwidth]
        {img/mojette_reprojection3.pdf}
        \caption{Reconstructions partielles à partir des projections $(0,1)$,
        $(1,1)$ et $(-1,1)$. La reprojection se fait suivant la direction
        $(2,1)$. La somme des reconstructions partielles est égale à l'image
        d'origine (pointillés bleu) et la somme des reprojections vaut la
        projection corresponde de l'image (lignes rouge). Les opérations sont
        réalisées modulo $6$.}
      \label{fig.reprojection}
    \end{figure}
    \end{landscape}
    %    \clearpage% Flush page
}


\noindent Il est ainsi possible de reconstruire une image de hauteur $Q$ à
partir de ces reconstructions partielles. En particulier, chaque reconstruction
partielle $f_S^R$ peut être utilisée pour calculer une projection
$\MM_{(p_k,q_k)}f_S^R$ suivant une direction $(p_k,q_k)$. Par
linéarité de l'opérateur Mojette, la somme des projections obtenues
correspond à la projection $\MM_{(p_k,q_k)}f$.
L'\cref{eqn.somme_image} peut alors s'écrire :

\begin{equation}
    \MM_{(p_k,q_k)}f =
        \sum_{R_i \in \mathcal{P}(S)} \MM_{(p_k,q_k)}{f_S^{R_i}}\;.
    \label{eqn.somme_reprojection}
\end{equation}

\noindent La \cref{fig.reprojection} (de la \cpageref{fig.reprojection})
représente un exemple appliqué sur une grille de taille $3 \times 3$. Trois
remarques peuvent être faites à partir de l'analyse de cette figure.
<!-- %1 -->
Premièrement, chaque image $f_S^R$ correspond à la reconstruction partielle
obtenue à partir d'une projection de direction dans $S=\left\{(0,1), (1,1),
(-1,1) \right\}$. Cette reconstruction est réalisée à la manière de la
\cref{fig.part_image}. Plus précisément, les images $f_S^{\{(0,1)\}}$,
$f_S^{\{(1,1)\}}$, et $f_S^{\{(-1,1)\}}$, sont respectivement reconstruites
depuis les projections $\MM_{(0,1)}f$, $\MM_{(1,1)}f$ et $\MM_{(-1,1)}f$. 
<!-- %2 -->
Deuxièmement, puisque les trois projections utilisés forment une partition de
$S$, la somme des images obtenues par reconstructions partielles reconstruise
l'image $f$ (cf.\ \cref{eqn.somme_image}). Ce traitement est symbolisé sur la
figure par le fléchage en pointillés bleu. Notons qu'en pratique, la
reconstruction peut se limiter à la taille de l'image. Par ailleurs, on observe
que l'ensemble des valeurs obtenues externes à la grille $3 \times 3$, est
nul (et peut donc être tronqué).
<!-- %3 -->
Troisièmement, on représente les projections $\MM_{(2,1)}f_S^{\{(0,1)\}}$,
$\MM_{(2,1)}f_S^{\{(1,1)\}}$ et $\MM_{(2,1)}f_S^{\{(-1,1)\}}$ de chaque
reconstruction partielle, suivant la nouvelle direction $(2,1)$. 
La somme de ces projections permet de déterminer la projection $\MM_{(2,1)}f$
que l'on recherche (cf.\ \cref{eqn.somme_projection}. En pratique, dans le cas
où les projections sont distribuées (comme dans le cas du stockage distribué,
présenté en introduction) le processus de reconstruction peut être distribué
puisque la valeur des projections distantes n'a pas besoin d'être connu.
En particulier, l'image n'a pas besoin d'être reconstruite pour déterminer la
valeur de la nouvelle projection.

Cette première approche a permis de valider la méthode de reprojection par des
opérations 2D (i.e.\ reconstruction et projection de l'image). La notion de
reconstruction partielle, permet de distribuer la tâche de reprojection sans
avoir à reconstruire l'image.



## Reconstruction par convolutions 1D {#sec.conv}

Nous avons vu précédemment une méthode de reprojection 2D. Dans cette section,
nous expliciterons le rôle des fantômes dans la méthode précédente, afin de
définir l'opération de reprojection à travers des opérations de convolution
$1$D.

### Rappel sur les fantômes

Les fantômes sont des images pour lesquelles les projections suivant un
ensemble de directions sont nulles. En conséquence, ils sont invisibles dans
le domaine projeté suivant les directions pour lesquelles ils sont définis. 
Un fantôme élémentaire est défini par une unique direction $(p,q)$ tel que :

\begin{equation}
    G_{(p,q)}(x,y) = \begin{cases}
        1 &\text{si }(x,y)=(0,0)\\
        -1&\text{si }(x,y)=(p,q)\\
        0 &\text{sinon}
    \end{cases}\;.
\end{equation}

\begin{figure}[t]
    \centering
    \def\svgwidth{\textwidth}
    \includesvg{img/fantomes2}
    \caption{Représentation de quatre fantômes élémentaires. Chaque fantôme est
    défini suivant une direction $(p,q)$ appartenant à l'ensemble
    $\{(0,1),(1,1),(-1,1),(2,1)\}$.  Par définition, la somme des valeurs de
    l'image suivant la direction du fantôme est nulle.}
    \label{fig.fantomes}
\end{figure}

\noindent La \cref{fig.fantomes} représente quatre fantômes élémentaire
(i.e.\ défini par une seule direction) suivant chaque direction de l'ensemble
$\{(0,1),(1,1), (-1,1), (2,1)\}$. Il est possible de construire
un fantôme composé $\ghost{(p,q)}$ à partir de fantômes élémentaires. Pour
cela, l'opérateur de convolution 2D $*$ est utilisé ainsi :
\begin{equation}
    \ghost{(p,q)} = \Conv_{i} G_{(p_i,q_i)}\;.
    \label{eqn.fantome.compose}
\end{equation}

\begin{figure}[t]
    \centering
    \def\svgwidth{\textwidth}
    \includesvg{img/fantome_compose2}
    \caption{Différentes itérations de la construction du fantôme composé
    $\ghost{(2,1),(-1,1),(0,1),(1,1)}$. Par définition, la somme des valeurs de
    l'image suivant chaque direction du fantôme est nulle.}
    \label{fig.fantomes.composes}
\end{figure}

\noindent Le fantôme composé est donc obtenu par la convolution 2D d'un
ensemble de fantômes élémentaires. La \cref{fig.fantomes.composes} illustre
cette opération à travers plusieurs itérations de convolution :

\begin{align*}
  \ghost{(0,1),(1,1)}               &= G_{(0,1)} \ast G_{(1,1)}\;,\\
  \ghost{(-1,1),(0,1),(1,1)}        &= \ghost{(0,1),(1,1)} \ast G_{(-1,1)}\;,\\
  \ghost{(2,1),(-1,1),(0,1),(1,1)}  &= \ghost{(-1,1),(0,1),(1,1)} \ast
      G_{(2,1)}\;.
\end{align*}

\noindent Considérons le fantôme composé construit à partir des directions d'un
ensemble de projections. \textcite{normand1996vcip} ont montré que si ce
fantôme ne pouvait être contenu dans l'image, alors l'ensemble de projections
est suffisant pour reconstruire l'image de manière unique.

\begin{figure}[t]
    \centering
    \def\svgwidth{\textwidth}
    \includesvg{img/convolution_fg2}
    \caption{Convolution d'une image $f$ avec le fantôme composé
    $\ghost{(0,1),(1,1)}$. Le résultat est une image dont les projections
    suivant les directions du fantôme sont nulles.}
    \label{fig.convolution.fg}
\end{figure}

Puisque les projections d'un fantôme sont nulles, la convolution d'une image $f$
avec un fantôme $\ghost{(p,q)}$ donne une image dont les valeurs des projections
suivant les directions de $\dirset{(p,q)}$ sont nulles. La
\cref{fig.convolution.fg} illustre un exemple dans lequel une image $f$ est
convoluée avec le fantôme composé $\ghost{(0,1),(1,1)}$.


### Reprojection par convolutions 1D

Dans cette section, nous explicitons le rôle des fantômes dans la méthode de
reprojection définie dans la prière section. La reconstruction partielle est
par définition une image issue d'un ensemble insuffisant de directions dans
$R$, tel que les projections de directions appartenant à $S \setminus R$ soient
nulles. Nous remarquions très justement dans la première section que l'image
obtenue est alors un fantôme pour les directions de $S \setminus R$. 
En conséquence, cette image $f_S^{\{(p_i,q_i)\}}$ est constituée du fantôme
composé $G_{S\setminus\dirset{(p_i,q_i)}}$.

<!-- % O.Philippe -->
Cette conséquence a été étudiée par \citeauthor{philippe1998phd} dans ses
travaux de thèse. En particulier, dans son théorème de la «\ Décomposition
Unique en Fantômes\ », \textcite[p. 76]{philippe1998phd} démontre qu'il existe
une décomposition unique de l'image $f$ par la somme d'une image sous
contrainte $f_{SC}$ avec un ensemble de fantômes ${g_i}$ de directions dans
$S$, telle que :

\begin{equation}
    f = f_{SC} + \sum_i a_ig_i\;.
    \label{eqn.decomposition.fantome}
\end{equation}

\noindent Comme énoncé avec lors de l'introduction de la reconstruction
partielle, \citeauthor{philippe1998phd} fait le choix de débloquer l'algorithme
de reconstruction en initialisant les valeurs d'une partie de l'image (cette
partie correspond à l'image érodée). L'image $f_{SC}$ correspond au résultat de
la reconstruction partielle quand l'image érodée est nulle.
L'ensemble ${g_i}$ correspond aux fantômes pour chaque élément de
l'érodée.

Notre approche diffère de celle de \citeauthor{philippe1998phd} puisque pour
débloquer l'algorithme, nous initialisons les valeurs des projections de
direction dans $S \setminus R$ tel que ces projections soient nulles. Si l'on
considère à présent la reconstruction partielle à partir d'une seule et une
seule projection de direction $(p_i,q_i)$, alors :

1. $f_{SC}$ correspond à la reconstruction à partir des projections de
directions dans $S \setminus R$, initialisées à zéro. En conséquence 
$f_{SC}$ est nulle;

2. l'érodée correspond alors à une image 1D (i.e.\ de hauteur $1$), et l'image
issue de la reconstruction partielle résulte d'une convolution de l'image
érodée avec le fantôme composé $G_{S\setminus\dirset{(p_i,q_i)}}$.

\noindent En conséquence, l'\cref{eqn.decomposition.fantome} peut s'écrire :

\begin{equation}
    f_S^{\dirset{(p_i,q_i)}}=h \ast G_{S\setminus\dirset{(p_i,q_i)}}\;,
    \label{eqn.reconstruction_partielle}
\end{equation}

\noindent où $h$ est une image de hauteur $1$. Par linéarité de l'opérateur
Mojette, quelle que soit la direction $(p,q)$,
l'\cref{eqn.reconstruction_partielle} devient :

\begin{align}
    \MM_{(p,q)}f_S^{\dirset{(p_i,q_i)}}
        & = \MM_{(p,q)}h \ast \MM_{(p,q)}(G_{S\setminus\dirset{(p_i,q_i)}})\\
        & = h \ast \MM_{(p,q)}(G_{S\setminus\dirset{(p_i,q_i)}})\;,
    \label{eqn.reprojection_p_k}
\end{align}

\noindent puisque la transformée d'une image 1D pour n'importe quelle direction
correspond à l'image. En particulier pour la direction $(p_i,q_i)$, qui
correspond à la direction la projection dont on connait les valeurs,
l'\cref{eqn.reprojection_p_k} peut s'écrire :

\begin{align}
    \MM_{(p_i,q_i)}f_S^{\dirset{(p_i,q_i)}}
        &= h\ast (\MM_{(p_i,q_i)}G_{S\setminus\dirset{(p_i,q_i)}})\;,\\
    \MM_{(p_i,q_i)}f
        &= h\ast (\MM_{(p_i,q_i)}G_{S\setminus\dirset{(p_i,q_i)}})\;,
    \label{eqn.reprojection_p_i}
\end{align}

\noindent puisque par définition : $\MM_{(p_i,q_i)}f_S^{\dirset{(p_i,q_i)}} =
\MM_{(p_i,q_i)}f$. Puisque nous connaissons la valeur de la projection
$\MM_{(p_i,q_i)}f$, et que l'on peut déterminer la valeur des projections du
fantôme composé $\MM_{(p_i,q_i)}G_{S\setminus\dirset{(p_i,q_i)}}$ et
$\MM_{(p,q)}G_{S\setminus\dirset{(p_i,q_i)}}$ (suivant la nouvelle direction),
alors il est possible de calculer la reprojection
$\MM_{(p,q)}f_S^{\dirset{(p_i,q_i)}}$. Ce qui est intéressant ici, c'est que
l'obtention de la reprojection ne nécessite que des opérations de convolution
et de déconvolution 1D.

\begin{algorithm*}[t]
    \begin{algorithmic}[1]
        \Require un ensemble suffisant de projections de l'image
        $\MM_{(p_i,q_i)}f \mid $ et la direction de reprojection $(p,q)$
        \ForAll{$(p_i,q_i)$ d'une partition de $S$} \label{alg.reproj.a}
            \State Calculer $\MM_{(p_i,q_i)}G_{S\setminus\dirset{(p_i,q_i)}}$
                \label{alg.reproj.b}
            \State Calculer $\MM_{(p,q)}G_{S\setminus\dirset{(p_i,q_i)}}$
                \label{alg.reproj.c}
            \State Calculer $h$ par déconvolution 1D
                \label{alg.reproj.d}
                \Comment{\cref{eqn.reprojection_p_i}}
            \State Calculer $\MM_{(p,q)}f_S^{\dirset{(p_i,q_i)}}$ par
                \label{alg.reproj.e}
                convolution 1D
                \Comment{\cref{eqn.reprojection_p_k}}
        \EndFor  \label{alg.reproj.f}
        \State Calculer $\MM_{(p,q)}f$ par somme \label{alg.reproj.g}
            \Comment{\cref{eqn.somme_reprojection}}
    \end{algorithmic}
    \caption{Algorithme de reprojection}
    \label{alg.reprojection}
\end{algorithm*}

L'\cref{alg.reprojection} décrit les étapes pour obtenir une projection suivant
une direction $(p,q)$ à partir d'un ensemble de projections suffisant. Pour
cela, on considère indépendamment chaque projection de l'image $\MM_{(p_i,q_i)}f$
et une direction de reprojection $(p,q)$. Prenons l'exemple de la
\cref{fig.part_image} dans laquelle on détermine la reprojection suivant
$(2,1)$ à partir de la projection suivant la direction $(0,1)$.
Dans un premier temps, on détermine le fantôme composé qui correspond à
$G_{S\setminus\dirset{0,1}}=\ghost{(1,1),(-1,1)}$. Il est ensuite nécessaire de
déterminer la valeur de ses projections suivant la direction $(p_i,q_i)$ et
$(p,q)$ :

\begin{align}
    \MM_{(0,1)}G_{S\setminus\dirset{(0,1)}} &= 
        \begin{pmatrix} -1 & 2 &-1 \end{pmatrix}\;,\\
    \MM_{(2,1)}G_{S\setminus\dirset{(0,1)}} & =
        \begin{pmatrix} 1 -1 & 0 & -1 & 1 \end{pmatrix}\;.
\end{align}

\noindent La séquence $h$ est alors calculée par déconvolution depuis
\cref{eqn.reprojection_p_i} :

\begin{align}
    h   &= (\MM_{(0,1)}f)\ast^{-1}(\MM_{(0,1)}G_{S\setminus\dirset{(0,1)}})\;,\\
        &= \begin{pmatrix} 3 & 3 & 4 \end{pmatrix}
            \ast^{-1} \begin{pmatrix} -1 & 2 & -1 \end{pmatrix}\;.
\end{align}

\noindent Connaissant $h$, il suffit ensuite de réaliser la convolution décrite
dans \cref{eqn.reprojection_p_k} pour obtenir $\MM_{(p,q)}f_S^{\dirset{(0,1)}}$ :
    
\begin{align}
    \MM_{(2,1)}f_S^{\{(0,1)\}}
        &= h \ast (\MM_{(2,1)}G_{S\setminus\dirset{(0,1)}})\;,\\
        &= \begin{pmatrix} 3 & 3 & 4 \end{pmatrix}
            \ast^{-1} \begin{pmatrix} 1 & -1 & 0 & -1 & 1 \end{pmatrix}\;,\\
        &= \begin{pmatrix}
            0 & 3 & 0 & 2 & 5 & 2 & 0 & 5 & 3 & 3 & 5
            \end{pmatrix}\;.
\end{align}

\noindent Ce qui correspond bien au résultat attendu. Une fois les
reprojections calculées, on les somme pour obtenir la projection
$\MM_{(p_k,q_k)}f$ comme indiqué dans \cref{eqn.somme_reprojection}.



## Simplification des opérations {#sec.simplification.operations}

% analyse et simplification des opérations

L'\cref{alg.reprojection} suppose que l'on ait déterminé les projections du
fantôme composé $\ghost{(p,q)}$ suivant les directions $(p_i,q_i) \in
\mathcal{P}(S)$ et $(p_q)$ au préalable. Or, par définition, le fantôme
composé est issu de la convolution de fantômes élémentaires (voir
\cref{eqn.fantome.compose}). En conséquence, Puisque $\ghost{(p,q)}$ est 

\begin{equation}
    \begin{split}
        \MM_{(p,q)} f_S^{\dirset{(p_i,q_i)}}
            &= (\MM_{(p_i,q_i)}f)\\
            & \bigastinv_{(p_j,q_j) \in S \setminus \dirset{(p_i,q_i)}}
                (\MM_{(p_i,q_i)} G_{(p_j,q_j)})\\
            & \bigast_{(p_j,q_j) \in S \setminus \dirset{(p_i,q_i)}}
                (\MM_{(p,q)} G_{(p_j,q_j)})\;.
    \end{split}
    \label{eqn.simplification}
\end{equation}

\noindent En particulier, chaque $(\MM_{(p_i,q_i)} G_{(p_j,q_j)}$ de
l'\cref{eqn.simplification} correspond à la projection d'un fantôme élémentaire
suivant la direction $(p_i,q_i)$. La détermination de cette projection est
triviale et correspond à la séquence :

\begin{equation}
    t \mapsto \begin{cases}
            1&\text{si }t=0\\
           -1&\text{si }t=j-i\\
            0&\text{sinon}
        \end{cases}\;.
    \label{eqn.projection.fantome}
\end{equation}

\noindent L'intérêt de cette décomposition est de pouvoir exprimer le calcul de
reprojection sans avoir à réaliser d'opération de projection. La conséquence de
cette représentation est de pouvoir révéler parfois quelques simplifications
dans les opérations de convolution. En particulier, convoluer et déconvoluer
par la même séquences revient à ne rien faire. Par exemple :

\begin{equation}
    \begin{split}
        \MM_{(0,1)} G_{S \setminus \{(0,1)\}}
            &= \begin{pmatrix} -1 & 2 & -1 \end{pmatrix}\\
        \MM_{(0,1)} G_{S \setminus \{(0,1)\}}
            &= (\MM_{(0,1)} G_{(-1,1)}) \bigast (\MM_{(0,1)} G_{(-1,1)})\\
            &= \begin{pmatrix} -1 & 1 \end{pmatrix}
                    \bigast \begin{pmatrix} 1 & -1 \end{pmatrix}
    \end{split}
    \label{eqn.simplification.exemple1}
\end{equation}

\begin{equation}
    \begin{split}
        \MM_{(2,1)} G_{S \setminus \{(0,1)\}}
            &= \begin{pmatrix} 1 & -1 & 0 & -1 & 1 \end{pmatrix}\\
        \MM_{(2,1)} G_{S \setminus \{(0,1)\}}
            &= (\MM_{(2,1)} G_{(-1,1)}) \bigast (\MM_{(2,1)} G_{(-1,1)})\\
            &= \begin{pmatrix} -1 & 0 & 0 & 1 \end{pmatrix}
                    \bigast \begin{pmatrix} -1 & 1 \end{pmatrix}
    \end{split}
    \label{eqn.simplification.exemple2}
\end{equation}

\noindent L'\cref{eqn.simplification} devient alors :

\begin{equation}
    \begin{split}
        \MM_{(2,1)} f_S^{\dirset{(0,1)}}
            &= (\MM_{(0,1)}f)\\
            & \bigastinv \left( 
                \textcolor{red}{ \begin{pmatrix} -1 & 1 \end{pmatrix} }
                \ast \begin{pmatrix} 1 & -1 \end{pmatrix} \right)\\
            & \bigast \left(
                    \begin{pmatrix} -1 & 0 & 0 & 1 \end{pmatrix}
                    \ast \textcolor{red}{\begin{pmatrix} -1 & 1 \end{pmatrix}}
                \right)\\
            &= (\MM_{(0,1)}f) 
                \bigastinv \begin{pmatrix} 1 & -1 \end{pmatrix}
                \bigast \begin{pmatrix} -1 & 0 & 0 & 1 \end{pmatrix}\;.
    \end{split}
    \label{eqn.simplification2}
\end{equation}

\noindent La décomposition des projections de fantôme permet ici de révéler les
opérations de convolution et de déconvolution par la séquence $\begin{pmatrix}
-1 & 1
\end{pmatrix}$. En conséquence, il est possible de simplifier l'opération de
reprojection en supprimant les éléments en rouge. La reprojection d'une
reconstruction partielle peut ainsi être calculée à partir de la
connaissance d'une projection et d'un ensemble de directions qui vérifie le
critère de \katz. L'\cref{eqn.simplification2} montre comment obtenir ce
résultat en utilisant uniquement des opérations de convolutions et de
déconvolution 1D, dont les opérations peuvent parfois se simplifier quand on
décompose les projections du fantôme composé.

% # Applications

# Évaluation de la nouvelle technique {#sec.eval.reproj}

Dans cette section, nous nous intéresserons à l'évaluation de la technique
décrite dans la section précédente. En particulier, nous verrons dans un
premier temps comment nous avons mis en place cette évaluation qui distribue le
calcul de reprojection sur différent cœurs CPU. Par la suite, nous analyserons
les résultats et verrons que cette technique induit un gain significatif
lorsque la taille des blocs utilisés sont importants.

## Implémentation distribuée par *OpenMP*

L'évaluation met en avant le bénéfice de la distribution des calculs. Pour
cela, nous avons réalisé une implémentation de l'\cref{alg.reprojection} en
langage de programmation C. Afin d'exploiter l'ensemble des cœurs du CPU à
notre disposition, nous avons utilisé la bibliothèque *Open Multi-Processing*
(OpenMP) qui offre un ensemble de directives pour le compilateur, ainsi qu'une
interface de programmation pour le calcul parallèle \cite{dagum1998cse}.

\begin{figure}
    \begin{minipage}{.96\textwidth}
        \input{code/map.c}
    \end{minipage}
\end{figure}

En particulier, notre code repose sur deux fonctions principales inspirées du
patron d'architecture *Map-Reduce*. La première fonction *map* consiste à
distribuer la tâche de reprojection à l'ensemble des nœuds de calcul. Puisque
chaque reprojection peut être réalisée de manière indépendante (chaque
opération traite des données bien distinctes, que sont les valeurs de
projection), le processus gagnera en efficacité à condition que l'opération de
reprojection soit un processus coûteux.
La \cref{lst.map} donne un extrait du code qui correspond à cette
fonction *map()*. La boucle *for* permettant d'itérer sur chaque projection
correspond à la boucle de l'\cref{alg.reprojection}, \cref{alg.reproj.a}.
La ligne $4$ contient les directives utilisées par *OpenMP* pour distribuer le
calcul sur les cœurs du CPU. La fonction *reprojection()* contient l'ensemble
des instructions indiquées dans l'\cref{alg.reprojection}
(\cref{alg.reproj.b,alg.reproj.c,alg.reproj.d,alg.reproj.e}).
En particulier, elle permet de calculer la valeur des reprojections, et de
remplir le buffer *p\_reprojections* avec ces valeurs.

\begin{figure}
    \begin{minipage}{.96\textwidth}
        \input{code/reduction.c}
    \end{minipage}
\end{figure}

La deuxième fonction *réduction* consiste à réduire la solution à partir des
différentes reprojections calculées précédemment. Pour cela, elle va retourner
un buffer *reproj* correspondant à la projection voulue. Chaque élément de
cette projection correspond à la somme des éléments correspondants dans
l'ensemble des reprojections. Cette fonction correspond à la
\cref{alg.reproj.g} de l'\cref{alg.reprojection}. La \cref{lst.reduction} donne
un extrait du code qui correspond à cette fonction *reduce()*. Bien que la
ligne $4$ concerne les directives d'*OpenMP*, l'addition est une opération trop
efficace pour gagner en parallélisme.

Dans notre expérience, nous enregistrons la latence nécessaire pour réaliser
ces opérations en fonction de la technique utilisée. En particulier, nos tests
mettent en jeu la technique classique qui consiste à reconstruire l'image à
priori et la nouvelle technique précédente qui permet de ne pas reconstruire
l'image. Puisque ces résultats dépendent de la difficulté de l'opération de
reprojection, nous faisons varier la taille $\mathcal{M}$ des blocs étudiés.
Les résultats correspondent à la moyenne de $10$ itérations, auxquels figurent
également l'écart-type des résultats obtenus. Cette expérience a été conduite
sur la plate-forme *FEC4Cloud* présentée précédemment.



## Résultats et comparaison avec l'approche classique

\begin{figure}
    \centering
    \input{tikz/reprojection.tex}
	\caption{Évaluation des performances de latence de la nouvelle technique de
	reprojection sans reconstruction (continu) par rapport à la reprojection
	classique (pointillé). La taille $\mathcal{M}$ des blocs étudiés évolue de
	$4$ Ko à $128$ Ko.}
    \label{fig.eval.reproj}
\end{figure}

La \cref{fig.eval.reproj} représente les résultats obtenus lors de notre
expérimentation. Il est tout d'abord intéressant de remarquer que la courbe se
croise lorsque la taille de bloc $\mathcal{M}=8$ Ko. Avant ce point, la méthode
classique est plus efficace que la nouvelle méthode. Ce désavantage de la
nouvelle technique provient de la création et de la gestion des *threads* qui
coûte un temps significatif dans le cas où l'opération de réduction est simple
à réaliser. Après ce point, l'écart des performances enregistrées pour chaque
technique devient de plus en plus significatif. En particulier, lorsque
$\mathcal{M}=128$ Ko, la nouvelle technique calcule la reprojection en
$\num*{1.217e-3}$s, ce qui correspond à la moitié du temps nécessaire pour
l'ancienne méthode qui nécessite $\num*{2.591e-3}$s. À mesure que la taille du
bloc augmente, l'opération de reprojection devient de plus en plus compliquée à
réaliser. En comparaison, le coût de la gestion des *threads* devient
négligeable. De plus, l'utilisation de plusieurs cœurs CPU en parallèle offre
un gain de temps linéaire. 


# Applications de la reprojection {#sec.applications.reproj}

La méthode présentée précédemment peut être utilisée dans plusieurs
applications du stockage distribué. Nous proposons dans cette section trois
applications. La \cref{sec.dispersion.information} présente tout d'abord une
méthode de distribution de données incompréhensibles sur des supports de
stockages non fiables (en matière de protection de la vie privée par exemple).
La \cref{sec.retablir.seuil} concerne la génération de redondance
supplémentaire dans l'objectif : (i) de rétablir un seuil de redondance; (ii)
d'allouer dynamiquement un seuil de redondance. Enfin, la \cref{sec.reduction}
traitera de la réduction de la bande passante utilisée pour la réparation.

## Dispersion d'information incompréhensible {#sec.dispersion.information}

% schéma

L'utilisation d'une méthode de reprojection sans reconstruction peut être
nécessaire dans certaines applications de stockage. Par exemple, la Mojette
non-systématique peut être utilisée dans un DSS afin de distribuer des données
incompréhensibles. Cette technique est basée sur l'«\ algorithme de dispersion
de l'information\ » (ou IDA pour *Information Dispersal Algorithm*)
\cite{rabin1989jacm}. Dans cette application, on ne désire pas que les nœuds de
stockage puisse accéder à l'information de l'utilisateur.
\textcite{guedon2012spie} ont par exemple utilisé RozoFS pour distribuer des
données sensibles (i.e.\ des documents médicaux) sur des plates-formes de
stockage en nuage publiques : *\textsc{Amazon} S3*, *Google Cloud Storage* et
*Rackspace Cloud Files*. Dans leur étude, \citeauthor{guedon2012spie} partent
du principe qu'il parait compliqué de reconstruire les données utilisateurs à
partir d'une seule projection. Pour reconstruire efficacement la donnée, il
serait nécessaire que $k$ plates-formes de stockage partagent leurs
informations. C'est le cas de la reprojection avec reconstruction, qui consiste
à fournir à un moment donné (par l'opération de reconstruction), l'information
de l'utilisateur.


## Rétablir un seuil de redondance {#sec.retablir.seuil}

% schéma

Afin de protéger les systèmes de stockage distribués (DSS) face aux pannes
inévitables, il est nécessaire de distribuer des informations de redondance.
Cette redondance permet en conséquence de compenser la perte d'une partie de
l'information lors de la lecture d'une donnée. Dans de tels systèmes, le seuil
de redondance peut évoluer avec le temps pour deux raisons. La première
correspond à la perte naturelle de la redondance. En effet, les phénomènes de
pannes entraîne la perte d'information, et cette perte contribue à faire
diminuer la redondance au sein du système d'information. La deuxième raisons
concernent une volonté de modifié le seuil de tolérance par l'administrateur du
système d'information. On parle d'allocation dynamique de la tolérance du DSS.
Par exemple, il peut être nécessaire d'augmenter le seuil de redondance de
données cruciales pour une entreprise. À l'inverse, il peut être nécessaire de
réduire le seuil de redondance pour des raisons économiques.

Dans les deux cas, le principe consiste à générer de nouvelles projections au
sein de supports de stockage supplémentaires (i.e.\ qui ne contient pas déjà de
données relatives à la donnée à protéger). Dans le cas de RozoFS, notre méthode
de reprojection pourrait agir de la manière suivante : 

1. l'administrateur décide de rétablir un seuil de redondance pour un ensemble
de fichiers et en fait la demande au serveur de métadonnées;

2. le serveur de métadonnées liste les projections relatives à ces fichiers;

3. pour chaque fichier, un ensemble de $k$ supports de stockage contenant une
projection participe au calcule de reprojection et transfère le résultat à
l'ensemble des supports de reconstruction;

4. les supports de reconstruction reconstitue les reprojections en sommant les
valeurs qui leur sont transférer.


## Réduction de la bande passante {#sec.reduction}

La bande passante de la réparation correspond à la quantité d'information
transférée lors de l'opération de réencodage. Dans le cas où la quantité de
données contenues dans les disques est très importante (i.e.\ plusieurs
téraoctets), le processus de réparation peut à la fois nécessiter plusieurs
heures de transfère, et affecter le trafic réseau nécessaire à l'application
qui utilise le DSS. C'est le cas chez \textsc{Facebook} qui analyse une grappe
de $3000$ nœuds de stockage \cite{sathiamoorthy2013vldb}. Chaque nœud
comptabilise $15$\ To de données, et l'étude présent une moyenne de $20$ pannes
par jour. Pour donner une référence au lecteur, le transfert de $15$\ To
d'information nécessite un peu moins de $5$\ heures sur un réseau délivrant un
débit de $1$\ Gops.

Pour répondre à ce problème, de nouveaux codes ont été proposés. Une première
proposition consiste à distinguer des blocs de parité locale (i.e.\ interne à
une baie de stockage) et blocs de parité globale (i.e.\ distribué sur plusieurs
baies). Désignés sous le nom *Locally Repairable Code* (LRC), ces codes
permettent de limiter le trafic réseau généré par la réparation entre les baies
en favorisant les transfert intra-baies\ \cite{sathiamoorthy2013vldb}.
Une deuxième méthode consiste à utiliser la technique de codage réseau (ou NC
pour *Network Coding*). Cette technique consiste à combiner l'information de
blocs de données au sein d'un nœud de stockage afin de réduire la quantité de
données transmise. Ces opérations de combinaisons linéaires ont été par exemple
appliquées sur les *Array codes* \cite{dimakis2011ieee} ou sur les codes
aléatoires \cite{andre2014eurosys}.

\begin{figure}[t]
    \centering
    \def\svgwidth{\textwidth}
    \includesvg{img/mojette_nc8}
    \caption{Mise en situation permettant d'exploiter notre méthode de
    reprojection pour faire du codage réseau. L'objectif est de reconstruire
    une nouvelle projection dans la baie $3$. Les reprojections provenant des
    nœuds cerclés sont successivement réduites par les nœuds intermédiaires
    (en gris) afin de transmettre l'équivalent d'une projection (au lieu de
    trois) vers la baie $3$.}
    \label{fig.mojette_nc}
\end{figure}

Dans cette optique, nos travaux permettent également de combiner l'information
par l'opération de réduction. Notre solution se distinguent des travaux
cités précédemment puisque la combinaison n'est pas réalisée par les nœuds de
stockage participant au réencodage. La réduction ne peut être faite que par des
nœuds intermédiaires. La \cref{fig.mojette_nc} intègre l'exemple présenté au
cours de ce chapitre, dans cette application. Dans cet exemple, trois
projections situées dans les baies $1$ et $2$ sont utilisées pour construire la
nouvelle projection à placer dans la baie $3$. Les nœuds contenant ces
projections calculent respectivement leur reprojection $M_{2,1}f_S^{R_i}$. Dans
cet exemple, deux nœuds intermédiaires sont utilisés pour combiner les
résultats et réduire la quantité d'information transportée par le reste du
réseau.



\section*{Conclusion du chapitre}

\addcontentsline{toc}{section}{Conclusion du chapitre}

Ce chapitre a présenté une nouvelle méthode pour déterminer de nouvelles
projections, à partir d'un ensemble déjà existant. En particulier, cette
technique permet de répondre au problème de la flexibilité et de la tolérance
aux pannes du système au cours du temps.

Cette méthode de reprojection a été décrite dans la
\cref{sec.reprojection.sans.reconstruction}. Elle se base en particulier sur la
définition des reconstructions partielles. En particulier, nous avons vu qu'un
ensemble suffisant de reconstructions partielles permet de reconstruire
l'image. Par linéarité, la somme des projections calculées depuis ces
reconstructions partielles donne la projection correspondante issue des valeurs
de la grille. Cette technique permet donc de reprojeter l'image suivant une
nouvelle direction. Chaque reconstruction peut être menée pour chacune des
projections participant à la reprojection de manière indépendante. En
conséquence, cette méthode peut alors être réalisée de manière distribuée. En
se basant sur la définition des fantômes, nous sommes également parvenus à
définir ces opérations en utilisant des opérations de convolutions et de
déconvolutions 1D. Il est ainsi possible de reprojeter les valeurs d'un
ensemble suffisant de projections, sans reconstruire les données de la grille.
Enfin, nous sommes parvenus à décomposer les opérations utilisées dans notre
algorithme afin de simplifier certaines opérations de convolution.

La \cref{sec.eval.reproj} s'est intéressée à la mise en œuvre d'une
expérimentation visant à déterminer le gain de cette nouvelle technique. En
particulier, notre expérimentation repose sur l'utilisation d'*OpenMP* pour
distribuer les calculs sur l'ensemble des cœurs CPU disponibles.
<!--
%Bien que notre
%méthode ne permet pas de diminuer la complexité des opérations de reprojection,
-->
La distribution des calculs de reprojection permet un gain dans les
performances de latence lorsque de grandes quantités d'information sont
traitées. Dans notre expérimentation, nous avons observé que la latence était
divisée par $2$ en utilisant cette méthode distribuée.
<!--
%Dans un contexte de stockage
%distribué, la réparation d'un disque est un processus qui met en jeu de très
%grandes quantité d'information.
-->

Trois applications du stockage distribué ont été présentées dans la
\cref{sec.applications.reproj}. La première propose d'exploiter l'absence de
reconstruction de la donnée initiale, pour distribuer des projections non
exploitables sur des fournisseurs de stockage publics. La seconde application
permet de maintenir un seuil de redondance voulu dans le système de stockage.
La dernière application permet d'exploiter la réduction des reprojections pour
faire du codage réseau.

% ça poutre

%Dans cette section, nous présentons la nouvelle méthode de reprojection.
%Nous définissons dans la \cref{sec.reconstruction.partielle} la notion de
%reconstruction partielle, afin de décomposer le processus de reconstruction de
%la grille. Cette décomposition permet notamment la distribution des calculs de
%reprojection. Par linéarité de l'opérateur Mojette, nous montrons que la
%reprojection par des opérations 2D est possible.
%La \cref{sec.conv} montre ensuite, comment traduire ces opérations par des
%convolutions et des déconvolutions 1D. Cette méthode permet en conséquence une
%reprojection sans reconstruction de l'image initiale.
%Enfin, la \cref{sec.simplification.operations} expose des simplifications dans
%les opérations de convolution.
