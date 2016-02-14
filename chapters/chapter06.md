
\chapter{Calcul distribué de nouveaux mots encodés}

\label{sec.chap6}

\minitoc

\newpage


\section*{Introduction}

Nous avons vu dans les chapitres précédents qu'une représentation redondante de
la donnée est nécessaire en télécommunications (e.g.\ transmission d'information
ou systèmes de stockage) afin de fournir de la fiabilité dans des systèmes
subissant des pannes. Ces pannes provenant par des pertes de paquet, des pannes
disques, ou l'indisponibilité de serveurs par exemple.
Dans le cas du code à effacement Mojette non-systématique, la perte d'un
sous-ensemble de projections est contrebalancée par la présence de redondance
contenue dans les projections supplémentaires calculées lors de l'opération de
transformée. Une fois les projections calculées, on considère que l'image
n'est accessible que par reconstruction. C'est le cas par exemple dans les
applications de stockage distribué où l'image n'est utilisée que lors de la
génération des projections. Une fois calculées, les projections sont
distribuées et stockées sur différents supports de stockage.

Dans ce contexte, il peut être nécessaire de calculer de nouvelles projections
dans deux situations. Premièrement, les projections peuvent être définitivement
perdues. C'est le cas lorsque qu'un support de stockage subit une panne
permanente par exemple. Il est alors nécessaire de calculer et de distribuer de
nouvelles projections afin de rétablir la tolérance aux pannes du système.
Dans une autre mesure, il peut être désiré d'augmenter la tolérance aux pannes
d'un système. C'est le cas en télécommunication lorsqu'on sait que
l'information traverse un canal fortement bruité. Dans ce cas, il peut être
nécessaire de calculer de nouvelles projections.

La stratégie naïve pour calculer de nouvelles projections à partir d'un
ensemble existant consiste à reconstruire l'image et à la reprojeter suivant la
direction voulue. Bien que simple à mettre en pratique, cette technique
nécessite de reconstruire explicitement l'image. Ainsi l'image peut être
accessible par le nœud de reconstruction, ce qui n'est pas toujours voulu.
C'est le cas lorsque l'on utilise la Mojette non-systématique comme base pour
faire de la dispersion d'information \cite{rabin1989jacm}. Dans cette
application, on ne désire pas que les nœuds de stockage puisse accéder à
l'information utilisateur.
\textcite{guedon2012spie} ont par exemple utilisé RozoFS pour distribuer des
données sensibles (i.e.\ des documents médicaux) sur des plates-formes Cloud
privées : *Amazon S3*, *Google Cloud Storage* et *Rackspace Cloud Files*.
L'objectif de cette étude est le suivant. En considérant qu'une projection
seule ne peut permettre à un fournisseur de stockage d'avoir d'information sur
la donnée, il serait nécessaire à $k$ plate-forme Cloud de partager leurs
informations pour reconstruire la donnée. Dans le cas de la reprojection, c'est
exactement ce qui est réalisé.

Dans ce chapitre, on va s'intéresser à une nouvelle technique pour générer de
nouvelles projections. En particulier cette nouvelle méthode n'a pas besoin de
reconstruire explicitement l'image. Dans l'approche classique, le calcul de
reprojection est centralisé et réalisé par le nœud en reconstruction.
Nous verrons que cette nouvelle technique permet de distribuer l'opération de
reprojection sur l'ensemble des nœuds qui participent à la reconstruction.
En particulier, nous verrons dans la \cref{sec.dec.rec} la décomposition du
processus de reconstruction de l'image. Par la suite, nous verrons comment
réaliser l'opération de reconstruction par de simples opérations de convolution
$1$D dans la \cref{sec.conv}. Enfin, la \cref{sec.reproj} montrera l'algorithme
permettant de calculer de nouvelles projections sans avoir à reconstruire
l'image.

<!--
%Enfin, le nombre de projections transmis pour cette opération devrait être le
%plus petit possible puisque l'on souhaite diminuer la bande passante
%nécessaire.

%Nous proposons une nouvelle technique permettant de générer de nouvelles
%projections à partir d'un ensemble existant et suffisant. Après un rappel sur
%la transformée Mojette en \cref{sec.mojette}, nous montrerons dans la
%\cref{sec.reprojection} que les propriétés linéaires de la reconstruction nous
%permettent de décomposer l'opération inverse en reconstructions partielles.
%Il est alors possible de distribuer cette opération sans reconstruire
%explicitement l'image.
%Plus particulièrement, on montrera
%que chaque projection participe de manière indépendante à l'opération de
%reprojection, permettant d'une part de distribuer cette opération, et d'autre
%part d'éviter la reconstruction explicite de l'image.
% convolution 1D ?
-->

<!--
%
%# Problème de génération de mots encodés {#gen_redondance}
%
%% replenishing = réapprovisionner
%
%Nous avons vu dans les chapitres précédents que les défaillances sont
%inévitables. Il est nécessaire alors de disposer de redondance pour supporter
%la perte d'information. Les codes à effacement permettent de générer cette
%redondance, et à moindre frais comparé aux techniques de réplication.
%Ainsi, il est possible de reconstruire la donnée initiale à partir d'un
%ensemble suffisant de données encodées.
%
%Parfois, ce n'est pas la donnée initiale qui nous intéresse, mais les données
%encodées. Ainsi il peut être nécessaire de rétablir la redondance perdue par
%ces défaillances, ou d'en générer davantage pour adapter la tolérance aux
%pannes à un canal particulièrement bruité.
%
%
%%      - 
%%      -                -
%%      -                -               -
%%      -    DECODING    -   ENCODING    -   RE-INSERT
%%      -                -
%%      -
%%
%% n encoded blocks   k blocks       recreate lost blocks
%
%
%On parle alors de réparation de la donnée. Cette réparation peut se faire de
%deux manières :
%
%  * réparation exacte : il s'agit de reconstruire exactement les données qui
%  ont été perdues ;
%
%  * réparation fonctionnelle : cette réparation reconstruit de nouveaux
%  symboles encodés au sein du mot de code.
%
%\noindent La réparation exacte est plus contrainte que la réparation
%fonctionnelle puisqu'il s'agit de reconstruire un ensemble de symboles exactes
%parmi les symboles du code.
%
%Le coût de ce processus de réparation peut être élevé. Considérons la
%réparation d'un bloc encodé par un code $(n,k)$. Pour être reconstruit, il est
%nécessaire de réaliser $k$ E/S sur les disques, ainsi que $k$ transferts
%réseau.
%Le recours à une approche naïve induit des coûts de réparation qui sont chers.
%C'est pourquoi de nombreux travaux ont été menés pour développer des codes à
%effacement adaptés à ce problème de réparation. Les critères qui détermine un
%bon code pour la réparation sont les suivants :
%
%1. Un surcout de stockage minimal ;
%
%2. Une bonne tolérance aux pannes ;
%
%3. Un nombre de nœuds contactés minimum ;
%
%4. Un nombre d'entrées-sorties minimal pour les disques ;
%
%5. Une bonne utilisation de la bande passante.
%
%\noindent Les deux premiers critères sont réalisés par les codes à effacement
%MDS.
%
%% Quand reconstruire :
%
%% load balancing : éviter des points chauds de calcul
%
%% rolling upgrade (?)
%
%% panne temporaire ou permanente ?
%
%Nous faisons deux hypothèses :
%
%  1. Toutes les pannes sont équivalentes, et le processus de réparation est
%  identique quelque soit le bloc perdu ;
%
%  2. Dans une application de stockage en nuage, la probabilité d'avoir une
%  panne est largement supérieure à la probabilité d'avoir deux pannes.
%
%Il est donc intéressant de fournir une méthode optimisée pour un faible nombre
%de pannes, notamment pour le cas d'une unique panne.
%
%## Les codes pyramides {#pyramides}
%
%Les codes pyramides fournissent des blocs de redondance à plusieurs niveaux.
%
%### Les codes à reconstruction locale
%
%% \cite{huang2007nca}
%
%% \cite{huang2012atc}
%
%Les codes à reconstruction locale (LRC) sont des codes pyramides à deux
%niveaux. Ils sont basés sur un code MDS afin de fournir des symboles de parité
%globale à l'ensemble des symboles de données. À cela on ajoute des symboles de
%parité locale qui permettent la reconstruction d'un sous-ensemble des
%symboles de données.
%Par exemple, un code LRC $(12,2,2)$ construit $2$ blocs sur parité globale
%et 2 blocs de parité locale à partir de $12$ blocs de données.
%
%% systèmatique
%
%Le surcout de cette redondance est de $(12+2+2)/12=1.33$. En revanche, la
%reconstruction d'un bloc de donnée ne coûte à présent que $6$ E/S et $6$
%transferts réseaux.
%Il s'agit ainsi d'une technique idéale lors de lectures dégradées puisqu'elle
%tire partie de la localité de la donnée offerte par les blocs de parité locale.
%
%
%## Les codes régénérant
%
%% regenerating codes
%
%### Codes Self-repairing
%
%% \cite{oggier2011infocom}
%
%% \cite{oggier2011itw}
%
%
%% \cite{pamies-juarez2013infocom}
%
%% \cite{pamies-juarez2013dcn}
%
%
%## Reconstruction de
%
%## Codage réseau
%
%    "You know you have a large storage system when you get paged at 1 AM
%    because you only have a few petabytes of storage left." – from Andrew Fikes
%
%Lorsqu'un émetteur transmet de la donnée vers un destinataire à travers un
%réseau, l'information transite par des nœuds intermédiaires.
%
%À contrario des techniques traditionnelles d'encodage où seuls les émetteurs
%génèrent des paquets encodés (source-based coding), le *codage réseau* est une
%méthode permettant à des noeuds intermédiaires d'encoder des paquets reçus en
%entrée en un paquet de sortie à travers une combinaison linéaire
%\cite{ahlswede2000it}. Elle généralise ainsi les techniques de commutation
%différée (store-and-forward) où les paquets sont stockés puis examinés avant
%traitement. L'avantage d'encoder des paquets sur les nœuds intermédiaire est
%d'augmenter la quantité d'information qui transite et donc, d'augmenter le
%débit dans certaines topologies. Une source peut ainsi distribuer en multicast
%des données avec un taux de transfert de données maximal.
%Le codage réseau s'intéresse alors à trois points :
%
%1. La quantité de données que l'on est capable de transmettre en considérant
%une certaine topologie réseau,
%
%2. Aux techniques d'encodage au niveau de la source et des nœuds
%intermédiaires,
%
%3. Aux techniques de décodage employées par le destinataire pour retrouver le
%message initial.
%
-->

# Décomposition de la reconstruction {#sec.dec.rec}

Dans cette section, nous présentons une nouvelle approche basée sur la
linéarité de la transformée Mojette permettant de décomposer l'opération
inverse en reconstructions partielles. En outre, nous montrons que chaque
projection peut contribuer indépendamment à l'opération de re-projection. La
seconde partie met en avant une méthode équivalente reposant sur des opérations de
convolution 1D.

## Reconstructions Partielles

\begin{figure}%[th]
  \centering
  \includegraphics[width=\columnwidth]
    {img/mojette_reprojection2.pdf}
    \caption{Reconstructions partielles à partir des projections
        $(0,1)$, $(1,1)$ et $(-1,1)$. La reprojection se fait suivant la
    direction $(2,1)$. La somme des reconstructions partielles est égale à
    l'image d'origine (bleu) et la somme des reprojections vaut la projection
    de l'image (rouge). Les opérations sont réalisées modulo $6$.}
  \label{fig.reprojection}
\end{figure}

# Reconstruction par Convolutions 1-D {#sec.conv}

Les fantômes sont des éléments de l'image constitués de valeurs positives et
négatives, dont la somme vaut zéro suivant certaines directions. Bien que les
fantômes modifient la valeur de l'image, ils sont invisibles dans le domaine
projeté suivant ces directions. Un fantôme est défini ainsi :
\begin{equation}
    \ghost{(p,q)}:p\mapsto\begin{cases}
        1 &\text{si }p=(0,0)\\
        -1&\text{si }p=(p,q)\\
        0 &\text{sinon}
    \end{cases}.
\end{equation}
Toute image convoluée avec $\ghost{(p,q)}$ possède des valeurs de projection
nulles suivant la direction $(p,q)$.
En conséquence, un fantôme composé $\ghost{(p_i,q_i)}$ de l'ensemble de
directions de projection $\dirset{(p_i,q_i)}$ est obtenu en faisant la
convolution de fantômes simples $\ghost{(p,q)}$.

Par définition, la reconstruction partielle considère un ensemble $R$ de
directions de projection tel que les projections de directions appartenant à
$S \setminus R$ soient nulles.

Cela signifie que l'image $f_S^R$ issue de la reconstruction partielle est
constituée de fantômes composés $G_{S\setminus\dirset{(p_i,q_i)}}$, définis
par les directions de ces projections manquantes.
En conséquence, il existe une séquence $h$ tel que :
\begin{equation}
    f_S^{\dirset{(p_i,q_i)}}=h\ast G_{S\setminus\dirset{(p_i,q_i)}}.
    \label{eqn.reconstruction_partielle}
\end{equation}
Par linéarité de l'opérateur Mojette, pour n'importe quelle direction
$(p_k,q_k)$ :
\begin{equation}
    M_{(p_k,q_k)}f_S^{\dirset{(p_i,q_i)}}
        = h\ast (M_{(p_k,q_k)}G_{S\setminus\dirset{(p_i,q_i)}})\;
    \label{eqn.reprojection_p_k}
\end{equation}
En particulier pour la direction $(p_i,q_i)$ :
\begin{equation}
    M_{(p_i,q_i)}f_S^{\dirset{(p_i,q_i)}}
        = h\ast (M_{(p_i,q_i)}G_{S\setminus\dirset{(p_i,q_i)}}),
    \label{eqn.reprojection_p_i}
\end{equation}
et par définition de $f_S^{\dirset{(p_i,q_i)}}$ :
$$M_{(p_i,q_i)}f_S^{\dirset{(p_i,q_i)}} = M_{(p_i,q_i)}f$$

<!--
%d'où
%\begin{equation}\label{eqn.deconvolution}
%    h=(M_{(p_i,q_i)}f)\ast^{-1}(M_{(p_i,q_i)}G_{S\setminus\dirset{(p_i,q_i)}})\;.
%\end{equation}
-->

Il est alors possible de calculer les valeurs de reprojection par des
opérations de convolutions et de déconvolutions 1-D. \cref{alg.reprojection}
décrit les étapes pour obtenir une projection suivant
la direction $(p_k,q_k)$ à partir d'un ensemble de projections suffisant pour
garantir la reconstruction unique de l'objet dont les directions sont dans $S$.
Pour cela, on considère indépendamment chaque projection de l'image
$M_{(p_i,q_i)}f$ et une direction de reprojection $(p_k,q_k)$. On détermine
ensuite les projections du fantôme $G_{S\setminus\dirset{(p_i,q_i)}}$ suivant
les directions $(p_i,q_i)$ et $(p_k,q_k)$.
La séquence $h$ est alors calculée par déconvolution depuis
\cref{eqn.reprojection_p_i}. Connaissant $h$ il suffit ensuite de réaliser la
convolution décrite dans \cref{eqn.reprojection_p_k} pour obtenir
$M_{(p_k,q_k)}f_S^{\dirset{(p_i,q_i)}}$. Une fois les reprojections calculées,
on les somme pour obtenir la projection $M_{(p_k,q_k)}f$ comme indiqué dans
\cref{eqn.somme_reprojection}.

\begin{algorithm*}
    \caption{Algorithme de reprojection}
    \label{alg.reprojection}
    \begin{algorithmic}[1]
        \Require un ensemble suffisant de projections de l'image
        $M_{(p_j,q_j)}f$ et
        <!--%projection fantômes $M_{(p_i,q_i)}G_{S \setminus R}$,-->
        la direction $(p_k,q_k)$
        \ForAll{$(p_i,q_i)$ d'une partition de $S$}
            \State Calculer $M_{(p_i,q_i)}G_{S\setminus\dirset{(p_i,q_i)}}$
            \State Calculer $M_{(p_k,q_k)}G_{S\setminus\dirset{(p_i,q_i)}}$
            \State Calculer $h$ par déconvolution 1-D
                \Comment{\cref{eqn.reprojection_p_i}}
            \State Calculer $M_{(p_k,q_k)}f_S^{\dirset{(p_i,q_i)}}$ par
                convolution 1-D
                \Comment{\cref{eqn.reprojection_p_k}}
        \EndFor
        \State Calculer $M_{(p_k,q_k)}f$ par somme 
            \Comment{\cref{eqn.somme_reprojection}}
    \end{algorithmic}
\end{algorithm*}


Les propriétés linéaires de la Mojette permettent la décomposition de
l'opération inverse en reconstructions partielles. Celles ci participent
<!--%individuellement à la reprojection suivant une direction arbitraire.-->
Soit $S$ un ensemble de $Q$ directions de projection de la forme $(p_i,
q_i=1)$. Alors la somme $\sum q_i=Q$ et selon \cref{eqn.katz}, tout image $P
\times Q$ peut être reconstruite de manière unique par l'ensemble de
projections de directions dans $S$.
Soit $R$ un sous-ensemble de $S$, une reconstruction partielle est le processus
qui reconstruit une image $f_S^R$ depuis un ensemble de projections $R$
(i.e.\ invalidant \cref{eqn.katz} si $R\subsetneq S$) et considérant les
projections manquantes comme nulles dans les directions $S\setminus R$.  Si les
sous-ensembles $R_i$ forment une partition de $S$, alors par linéarité,
$f=\sum_i f_S^{R_i}$.
<!--% exemple-->

De même, la somme des projections de ces images issues de reconstructions
partielles suivant la direction $(p_k,q_k)$ donne la projection
$M_{(p_k,q_k)}f$ de l'image d'origine suivant la direction $(p_k,q_k)$ :
\begin{equation}
    M_{(p_k,q_k)}f = \sum_{R}M_{(p_k,q_k)}{f_S^R}.
    \label{eqn.somme_reprojection}
\end{equation}
\cref{fig.reprojection} montre le calcul de la projection $(2,1)$ à
partir des trois projections de directions dans
$S=\left\{(0,1),(1,1),(-1,1)\right\}$ issues de \cref{fig.mojette}.
On calcule respectivement les reconstructions partielles $f_S^{\{(0,1)\}}$,
$f_S^{\{(1,1)\}}$, $f_S^{\{(-1,1)\}}$, depuis les projections $M_{(0,1)}f$,
$M_{(1,1)}f$ et $M_{(-1,1)}f$, ainsi que leurs reprojections respectives
$M_{(2,1)}f_S^{\{(0,1)\}}$, $M_{(2,1)}f_S^{\{(1,1)\}}$,
$M_{(2,1)}f_S^{\{(-1,1)\}}$ suivant la direction $(2,1)$. Bien que la
reconstruction de l'image originale est de taille infinie, la partie en dehors
de la grille $3 \times 3$ vaut zéro est peut donc être tronquée. La prochaine
section présente une technique équivalente qui permet d'éviter la
reconstruction 2-D des images.
<!--
%où $S$ contient les directions d'un ensemble suffisant de projections pour la
%reconstruction de l'image, et $f_S^R$ est la reconstruction partielle depuis
%les projections dont les directions sont dans le sous-ensemble $R$ d'une
%partition $P$ de $S$.
% exemple
-->

# Re-projection sans reconstruction {#sec.reproj}


\paragraph{Reconstruction par Convolutions 1-D}

Les fantômes sont des éléments de l'image constitués de valeurs positives et
négatives, dont la somme vaut zéro suivant certaines directions. Bien que les
fantômes modifient la valeur de l'image, ils sont invisibles dans le domaine
projeté suivant ces directions. Un fantôme est défini ainsi :
\begin{equation}
    \ghost{(p,q)}:p\mapsto\begin{cases}
        1 &\text{si }p=(0,0)\\
        -1&\text{si }p=(p,q)\\
        0 &\text{sinon}
    \end{cases}.
\end{equation}
Toute image convoluée avec $\ghost{(p,q)}$ possède des valeurs de projection
nulles suivant la direction $(p,q)$.
En conséquence, un fantôme composé $\ghost{(p_i,q_i)}$ de l'ensemble de
directions de projection $\dirset{(p_i,q_i)}$ est obtenu en faisant la
convolution de fantômes simples $\ghost{(p,q)}$.

Par définition, la reconstruction partielle considère un ensemble $R$ de
directions de projection tel que les projections de directions appartenant à
$S \setminus R$ soient nulles.

Cela signifie que l'image $f_S^R$ issue de la reconstruction partielle est
constituée de fantômes composés $G_{S\setminus\dirset{(p_i,q_i)}}$, définis
par les directions de ces projections manquantes.

En conséquence, il existe une séquence $h$ tel que :
\begin{equation}
    f_S^{\dirset{(p_i,q_i)}}=h\ast G_{S\setminus\dirset{(p_i,q_i)}}.
    \label{eqn.reconstruction_partielle}
\end{equation}
Par linéarité de l'opérateur Mojette, pour n'importe quelle direction
$(p_k,q_k)$ :
\begin{equation}
    M_{(p_k,q_k)}f_S^{\dirset{(p_i,q_i)}}
        = h\ast (M_{(p_k,q_k)}G_{S\setminus\dirset{(p_i,q_i)}})\;
    \label{eqn.reprojection_p_k}
\end{equation}
En particulier pour la direction $(p_i,q_i)$ :
\begin{equation}
    M_{(p_i,q_i)}f_S^{\dirset{(p_i,q_i)}}
        = h\ast (M_{(p_i,q_i)}G_{S\setminus\dirset{(p_i,q_i)}}),
    \label{eqn.reprojection_p_i}
\end{equation}
et par définition de $f_S^{\dirset{(p_i,q_i)}}$ :
$$M_{(p_i,q_i)}f_S^{\dirset{(p_i,q_i)}} = M_{(p_i,q_i)}f$$

<!--%d'où
%\begin{equation}\label{eqn.deconvolution}
%    h=(M_{(p_i,q_i)}f)\ast^{-1}(M_{(p_i,q_i)}G_{S\setminus\dirset{(p_i,q_i)}})\;.
%\end{equation}-->
Il est alors possible de calculer les valeurs de reprojection par des
opérations de convolutions et de déconvolutions 1-D. \cref{alg.reprojection}
décrit les étapes pour obtenir une projection suivant
la direction $(p_k,q_k)$ à partir d'un ensemble de projections suffisant pour
garantir la reconstruction unique de l'objet dont les directions sont dans $S$.
Pour cela, on considère indépendamment chaque projection de l'image
$M_{(p_i,q_i)}f$ et une direction de reprojection $(p_k,q_k)$. On détermine
ensuite les projections du fantôme $G_{S\setminus\dirset{(p_i,q_i)}}$ suivant
les directions $(p_i,q_i)$ et $(p_k,q_k)$.
La séquence $h$ est alors calculée par déconvolution depuis
\cref{eqn.reprojection_p_i}. Connaissant $h$ il suffit ensuite de réaliser la
convolution décrite dans \cref{eqn.reprojection_p_k} pour obtenir
$M_{(p_k,q_k)}f_S^{\dirset{(p_i,q_i)}}$. Une fois les reprojections calculées,
on les somme pour obtenir la projection $M_{(p_k,q_k)}f$ comme indiqué dans
\cref{eqn.somme_reprojection}.

\begin{algorithm*}
    \caption{Algorithme de reprojection}
    \label{alg.reprojection}
    \begin{algorithmic}[1]
        \Require un ensemble suffisant de projections de l'image
        $M_{(p_j,q_j)}f$ et
        %projection fantômes $M_{(p_i,q_i)}G_{S \setminus R}$,
        la direction $(p_k,q_k)$
        \ForAll{$(p_i,q_i)$ d'une partition de $S$}
            \State Calculer $M_{(p_i,q_i)}G_{S\setminus\dirset{(p_i,q_i)}}$
            \State Calculer $M_{(p_k,q_k)}G_{S\setminus\dirset{(p_i,q_i)}}$
            \State Calculer $h$ par déconvolution 1-D
                \Comment{\cref{eqn.reprojection_p_i}}
            \State Calculer $M_{(p_k,q_k)}f_S^{\dirset{(p_i,q_i)}}$ par
                convolution 1-D
                \Comment{\cref{eqn.reprojection_p_k}}
        \EndFor
        \State Calculer $M_{(p_k,q_k)}f$ par somme 
            \Comment{\cref{eqn.somme_reprojection}}
    \end{algorithmic}
\end{algorithm*}



% # Évaluation {#sec.eval.reproj}


