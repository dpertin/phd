
%\chapter{Calcul distribué de nouveaux mots encodés}

\chapter{Nouvelle méthode distribuée de reprojection}

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

\begin{figure}[t]
  \centering
  \includegraphics[width=.8\columnwidth]
    {img/reprojection_pb2.pdf}
    \caption{Représentation du problème de reprojection. Il s'agit de calculer
    les valeur d'une nouvelle projection (en rouge) suivant la direction
    $(2,1)$ à partir d'un ensemble de projections (en bleu) suffisant.
    Classiquement, cela nécessite de reconstruire la grille et de reprojeter
    les valeurs de l'image suivant la nouvelle direction.}
  \label{fig.reprojection.pb}
\end{figure}

La stratégie classique pour calculer de nouvelles projections à partir d'un
ensemble existant consiste à reconstruire l'image et à la reprojeter suivant la
direction voulue. Bien que simple à mettre en pratique, cette technique
nécessite de reconstruire explicitement l'image. Cette méthode est illustrée
dans la \cref{fig.reprojection.pb} qui présente l'exemple que nous allons
étudié tout au long de ce chapitre. Notons que pour faciliter la lecture des
schémas dans la suite du chapitre, toutes les opérations sont réalisées modulo
$6$ (le choix de cette valeur est strictement arbitraire). Ainsi l'image peut
être accessible par le nœud de reconstruction, ce qui n'est pas toujours voulu.
C'est le cas lorsque l'on utilise la Mojette non-systématique comme base pour
faire de la dispersion d'information \cite{rabin1989jacm}. Dans cette
application, on ne désire pas que les nœuds de stockage puisse accéder à
l'information utilisateur.
\textcite{guedon2012spie} ont par exemple utilisé RozoFS pour distribuer des
données sensibles (i.e.\ des documents médicaux) sur des plates-formes Cloud
privées : *Amazon S3*, *Google Cloud Storage* et *Rackspace Cloud Files*.
L'objectif de cette étude est le suivant. En considérant qu'une projection
seule ne peut permettre à un fournisseur de stockage d'avoir d'information sur
la donnée, il serait nécessaire à $k$ plates-formes Cloud de partager leurs
informations pour reconstruire la donnée. Dans le cas de la reprojection, c'est
exactement ce qui est réalisé.

Dans ce chapitre, on va s'intéresser à une nouvelle technique pour générer de
nouvelles projections. En particulier cette nouvelle méthode n'a pas besoin de
reconstruire explicitement l'image. Dans l'approche classique, le calcul de
reprojection est centralisé et réalisé par le nœud en reconstruction.
Nous verrons que cette nouvelle technique permet de distribuer l'opération de
reprojection sur l'ensemble des nœuds qui participent à la reconstruction.
En particulier, nous verrons dans la
\cref{sec.reprojection.sans.reconstruction} cette nouvelle méthode de
reprojection basée sur la décomposition du processus de reconstruction, et sur
la définition des fantômes. La \cref{sec.eval.reproj} s'intéressera à
l'évaluation de cette nouvelle technique. Nous verrons en particulier qu'elle
permet de diviser par deux le temps nécessaire à cette opération.


# Reprojection sans reconstruction {#sec.reprojection.sans.reconstruction}

Dans cette section, nous présentons la nouvelle méthode pour reprojeter de
l'information. La \cref{sec.reconstruction.partielle} définit les notions
permettant de décomposer le processus de reconstruction de l'image et de
reprojeter les informations suivant une nouvelle direction.
Par la suite, la \cref{sec.conv} montre comment réaliser cette reprojection par
de simples opérations de convolution et de déconvolution 1D. Ces opérations
permettent en conséquence de reprojeter les informations sans avoir à
reconstruire explicitement l'image. Enfin, une nouvelle représentation des
opérations est proposée dans la \cref{sec.simplification.operations}. Cette
représentation décompose les opérations de notre algorithme afin de simplifier
certains calculs.



## Reconstruction partielle {#sec.reconstruction.partielle}

\label{sec.dec.rec}

\begin{figure}[t]
  \centering
  \includegraphics[width=.8\columnwidth]
    {img/part_image.pdf}
    \caption{Reconstruction partielle d'une grille $3 \times 3$ à partir de
    la projection suivant la direction $(0,1)$. On utilise l'algorithme de
    \textcite{normand2006dgci} pour la reconstruction.
    Les opérations sont réalisées modulo $6$.}
  \label{fig.part_image}
\end{figure}

Soit $S$ un ensemble de $Q$ directions de projection de la forme $(p_i,
q_i=1)$. Alors la somme $\sum q_i=Q$ et selon \cref{eqn.katz}, toute image
$P \times Q$ peut être reconstruite de manière unique par l'ensemble des
projections de directions dans $S$.
Si $R$ est un sous-ensemble non vide de $S$, alors une reconstruction partielle
est le processus qui reconstruit une image $f_S^R$ depuis un ensemble de
projections de directions dans $R$ (i.e.\ invalidant le critère de
\cref{eqn.katz} si $R\subsetneq S$). Cette reconstruction considère que les
informations des autres projections sont nulles, c'est à dire pour l'ensemble
des projections de directions $S \setminus R$. La \cref{fig.part_image} illustre
la reconstruction partielle d'une image à partir la projection $(0,1)$ calculée
depuis la \cref{fig.reprojection.pb}. Il est cependant nécessaire de considérer
un ensemble de projections suffisant pour la reconstruction. Puisque l'on ne
connait pas la valeur des autres projections en jeu (de direction $(-1,1)$
et $(1,1)$), on considère qu'elles sont nulles. Pour la reconstruction, on
utilisera par exemple l'algorithme de \textcite{normand2006dgci}.
En particulier, si l'ensemble des directions des projections utilisées forme
une partition $\mathcal{P}(S)$, alors par linéarité :

\begin{equation}
    f=\sum_{i} f_S^{R_i}, 
        \text{ si } \bigcup_{R_i \in \mathcal{P}(S)} R_i = S\;.
    \label{eqn.somme_image}
\end{equation}

\noindent Il est ainsi possible de reconstruire une image de hauteur $Q$ à
partir de $Q$ reconstructions partielles.  À partir d'une image $f_S^R$ obtenue
par reconstruction partielle, on peut calculer une projection
$M_{(p_k,q_k)}f_S^R$ suivant une nouvelle direction $(p_k,q_k)$. Il est alors
possible de calculer une projection suivant cette direction pour chacune des
$Q$ images obtenues par reconstruction partielle.  Par linéarité, la somme de
ces $Q$ projections suivant la direction $(p_k,q_k)$ correspond à la projection
$M_{(p_k,q_k)}f$ de l'image d'origine suivant la direction $(p_k,q_k)$ :

\begin{equation}
    M_{(p_k,q_k)}f = \sum_{R \in \mathcal{P}(S)}M_{(p_k,q_k)}{f_S^R}\;.
    \label{eqn.somme_reprojection}
\end{equation}

%http://tex.stackexchange.com/questions/19017/how-to-place-a-table-on-a-new-page-with-landscape-orientation-without-clearing-t
\afterpage{%
    \clearpage% Flush earlier floats (otherwise order might not be correct)
        \thispagestyle{empty}% empty page style (?)
\begin{landscape}
\begin{figure}[t]
\vspace{-2.8cm}
  \centering
  \includegraphics[width=.8\columnwidth]
    {img/mojette_reprojection2.pdf}
    \caption{Reconstructions partielles à partir des projections $(0,1)$,
    $(1,1)$ et $(-1,1)$. La reprojection se fait suivant la direction $(2,1)$.
    La somme des reconstructions partielles est égale à l'image d'origine
    (bleu) et la somme des reprojections vaut la projection de l'image (rouge).
    Les opérations sont réalisées modulo $6$.}
  \label{fig.reprojection}
\end{figure}
\end{landscape}
    \clearpage% Flush page
}

\noindent La \cref{fig.reprojection} représente un exemple appliqué sur une
grille de taille $3 \times 3$. Les trois considérations précédentes sont
illustrées sur cette figure. Tout d'abord, chaque image $f_S^R$ représente la
reconstruction partielle à partir d'une projection de l'ensemble $S=\left\{
(0,1), (1,1), (-1,1) \right\}$. On calcule respectivement les images issues des
reconstructions partielles $f_S^{\{(0,1)\}}$, $f_S^{\{(1,1)\}}$,
$f_S^{\{(-1,1)\}}$, respectivement depuis les projections $M_{(0,1)}f$,
$M_{(1,1)}f$ et $M_{(-1,1)}f$. L'image $f_S^{\{(0,1)\}}$ par exemple représente
la reconstruction à partir de la projection verticale $(0,1)$, et en
considérant les valeurs des projections diagonales nulles. Pour la
reconstruction, l'algorithme de \textcite{normand2006dgci} est utilisé. En
appliquant le même procédé sur chacune des trois projections, on obtient trois
images. La seconde considération consiste à additionner les valeurs de ces
trois images afin de retrouver les valeurs de l'image $f$ depuis laquelle les
projections ont été calculées. On peut observer que l'ensemble des valeurs
calculées en dehors de la grille $3 \times 3$ valent $0$. La dernière
considération consiste à calculer les projections $M_{(2,1)}f_S^{\{(0,1)\}}$,
$M_{(2,1)}f_S^{\{(1,1)\}}$, $M_{(2,1)}f_S^{\{(-1,1)\}}$ de chaque image obtenue
suivant la nouvelle direction $(2,1)$. On observe bien que la somme des valeurs
de ces projections correspond à la valuer de $M_{(2,1)}f$.  Bien que la
reconstruction de l'image originale est de taille infinie, la partie en dehors
de la grille $3 \times 3$ vaut zéro est peut donc être tronquée. La prochaine
section présente une technique équivalente qui permet d'éviter la
reconstruction 2D des images.



## Reconstruction par Convolutions 1D {#sec.conv}

Dans cette section, nous utiliserons la définition des fantômes afin de définir
l'opération de reprojection à travers des opérations de convolution $1$D.

### Rappel sur les fantômes

Nous rappelons que les fantômes sont des éléments de l'image $f$ définis par un
ensemble de directions discrètes. Ils sont constitués de valeurs positives et
négatives, dont la somme vaut zéro suivant ces directions. En conséquence,
bien que les fantômes modifient la valeur d'une image, ils sont invisibles dans
le domaine projeté suivant les directions pour lesquelles ils sont définis. 
Un fantôme suivant la direction $(p,q)$ est défini ainsi :

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
    \includesvg{img/fantomes}
    \caption{Représentation de quatre fantômes élémentaires. Chaque fantôme est
    défini suivant une direction de l'ensemble $\{(0,1),(1,1),(-1,1),(2,1)\}$.}
    \label{fig.fantomes}
\end{figure}

\noindent La \cref{fig.fantomes} représente quatre fantômes suivant chaque
direction de l'ensemble $\{(0,1),(1,1),(-1,1),(2,1)\}$. En particulier, il est
possible de construire un fantôme composé $\ghost{(p,q)}$ à partir de fantômes
élémentaires. Pour cela, l'opérateur de convolution 2D $*$ est utilisé ainsi :

\begin{equation}
    \ghost{(p,q)} = \Conv_{i} G_{(p_i,q_i)}\;.
    \label{eqn.fantome.compose}
\end{equation}

\begin{figure}[t]
    \centering
    \def\svgwidth{\textwidth}
    \includesvg{img/fantome_compose}
    \caption{Représentation de quatre fantômes élémentaires. Chaque fantôme est
    défini suivant une direction de l'ensemble $\{(0,1),(1,1),(-1,1),(2,1)\}$.}
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
ensemble de projections. \textcite{normand1996vcip} a montré que si ce fantôme
ne pouvait être contenu dans l'image, alors l'ensemble de projections est
suffisant pour reconstruire l'image de manière unique.

\begin{figure}[t]
    \centering
    \def\svgwidth{\textwidth}
    \includesvg{img/convolution_fg}
    \caption{Convolution d'une image avec le fantôme composé
    $\ghost{(0,1),(1,1)}$. Le résultat est une image dont les projections
    suivant les directions du fantôme sont nulles.}
    \label{fig.convolution.fg}
\end{figure}


Puisque les projections d'un fantôme sont nulle, la convolution d'une image $f$
avec un fantôme $\ghost{(p,q)}$ donne une image dont les valeurs des projections
suivant les directions de $\dirset{(p,q)}$ sont nulles. La
\cref{fig.convolution.fg} illustre un exemple dans lequel une image $f$ est
convoluée avec le fantôme composé $\ghost{(0,1),(1,1)}$.


### Reprojection par convolutions 1D

Dans cette section, nous faisons le lien entre la reprojection vu dans la
\cref{sec.dec.rec}, et les fantômes vus précédemment. Par définition, la
reconstruction partielle considère un ensemble insuffisant $R$ de directions de
projection, tel que les projections de directions appartenant à $S \setminus R$
soient nulles. Dans la suite, nous considèrerons la reconstruction partielle à
partir d'une projection de direction $(p_i,q_i)$.
Cela signifie que l'image $f_S^{\{(p_i,q_i)\}}$ issue de cette reconstruction
partielle est constituée du fantôme composé $G_{S\setminus\dirset{(p_i,q_i)}}$,
défini par l'\cref{eqn.fantome.compose}, puisque l'image a des projections
nulles suivant les directions de l'ensemble $S \setminus R$. Autrement dit,
l'image obtenue peut être décrite comme une séquence de ce fantôme composé. En
conséquence, il existe une séquence $h$ tel que :

\begin{equation}
    f_S^{\dirset{(p_i,q_i)}}=h\ast G_{S\setminus\dirset{(p_i,q_i)}}\;.
    \label{eqn.reconstruction_partielle}
\end{equation}

\noindent Par linéarité de l'opérateur Mojette, pour n'importe quelle direction
$(p,q)$, l'\cref{eqn.reconstruction_partielle} devient :

\begin{equation}
    M_{(p,q)}f_S^{\dirset{(p_i,q_i)}}
        = h\ast (M_{(p,q)}G_{S\setminus\dirset{(p_i,q_i)}})\;.
    \label{eqn.reprojection_p_k}
\end{equation}

\noindent En particulier pour la direction $(p_i,q_i)$, qui correspond à la
direction la projection dont on connait les valeurs,
l'\cref{eqn.reprojection_p_k} peut s'écrire :

\begin{align}
    M_{(p_i,q_i)}f_S^{\dirset{(p_i,q_i)}}
        &= h\ast (M_{(p_i,q_i)}G_{S\setminus\dirset{(p_i,q_i)}})\;,\\
    M_{(p_i,q_i)}f
        &= h\ast (M_{(p_i,q_i)}G_{S\setminus\dirset{(p_i,q_i)}})\;,
    \label{eqn.reprojection_p_i}
\end{align}

\noindent puisque par définition : $M_{(p_i,q_i)}f_S^{\dirset{(p_i,q_i)}} =
M_{(p_i,q_i)}f$. Puisque nous connaissons la valeur de la projection
$M_{(p_i,q_i)}f$, et que l'on peut déterminer la valeur des projections du
fantôme composé $M_{(p_i,q_i)}G_{S\setminus\dirset{(p_i,q_i)}}$ et
$M_{(p,q)}G_{S\setminus\dirset{(p_i,q_i)}}$ (suivant la nouvelle direction),
alors il est possible de calculer la reprojection
$M_{(p,q)}f_S^{\dirset{(p_i,q_i)}}$. Ce qui est intéressant ici, c'est que
l'obtention de la reprojection ne nécessite que des opérations de convolution
et de déconvolution 1D.

\begin{algorithm*}[t]
    \begin{algorithmic}[1]
        \Require un ensemble suffisant de projections de l'image
        $M_{(p_i,q_i)}f \mid $ et la direction de reprojection $(p,q)$
        \ForAll{$(p_i,q_i)$ d'une partition de $S$} \label{alg.reproj.a}
            \State Calculer $M_{(p_i,q_i)}G_{S\setminus\dirset{(p_i,q_i)}}$
                \label{alg.reproj.b}
            \State Calculer $M_{(p,q)}G_{S\setminus\dirset{(p_i,q_i)}}$
                \label{alg.reproj.c}
            \State Calculer $h$ par déconvolution 1D
                \label{alg.reproj.d}
                \Comment{\cref{eqn.reprojection_p_i}}
            \State Calculer $M_{(p,q)}f_S^{\dirset{(p_i,q_i)}}$ par
                \label{alg.reproj.e}
                convolution 1D
                \Comment{\cref{eqn.reprojection_p_k}}
        \EndFor  \label{alg.reproj.f}
        \State Calculer $M_{(p,q)}f$ par somme \label{alg.reproj.g}
            \Comment{\cref{eqn.somme_reprojection}}
    \end{algorithmic}
    \caption{Algorithme de reprojection}
    \label{alg.reprojection}
\end{algorithm*}

L'\cref{alg.reprojection} décrit les étapes pour obtenir une projection suivant
une direction $(p,q)$ à partir d'un ensemble de projections suffisant. Pour
cela, on considère indépendamment chaque projection de l'image $M_{(p_i,q_i)}f$
et une direction de reprojection $(p,q)$. Prenons l'exemple de la
\cref{fig.part_image} dans laquelle on détermine la reprojection suivant
$(2,1)$ à partir de la projection suivant la direction $(0,1)$.
Dans un premier temps, on détermine le fantôme composé qui correspond à
$G_{S\setminus\dirset{0,1}}=\ghost{(1,1),(-1,1)}$. Il est ensuite nécessaire de
déterminer la valeur de ses projections suivant la direction $(p_i,q_i)$ et
$(p,q)$ :

\begin{align}
    M_{(0,1)}G_{S\setminus\dirset{(0,1)}} &= 
        \begin{pmatrix} -1 & 2 &-1 \end{pmatrix}\;,\\
    M_{(2,1)}G_{S\setminus\dirset{(0,1)}} & =
        \begin{pmatrix} 1 -1 & 0 & -1 & 1 \end{pmatrix}\;.
\end{align}

\noindent La séquence $h$ est alors calculée par déconvolution depuis
\cref{eqn.reprojection_p_i} :

\begin{align}
    h   &= (M_{(0,1)}f)\ast^{-1}(M_{(0,1)}G_{S\setminus\dirset{(0,1)}})\;,\\
        &= \begin{pmatrix} 3 & 3 & 4 \end{pmatrix}
            \ast^{-1} \begin{pmatrix} -1 & 2 & -1 \end{pmatrix}\;.
\end{align}

\noindent Connaissant $h$ il suffit ensuite de réaliser la convolution décrite
dans \cref{eqn.reprojection_p_k} pour obtenir $M_{(p,q)}f_S^{\dirset{(0,1)}}$ :
    
\begin{align}
    M_{(2,1)}f_S^{\{(0,1)\}}
        &= h \ast (M_{(2,1)}G_{S\setminus\dirset{(0,1)}})\;,\\
        &= \begin{pmatrix} 3 & 3 & 4 \end{pmatrix}
            \ast^{-1} \begin{pmatrix} 1 & -1 & 0 & -1 & 1 \end{pmatrix}\;,\\
        &= \begin{pmatrix}
            0 & 3 & 0 & 2 & 5 & 2 & 0 & 5 & 3 & 3 & 5
            \end{pmatrix}\;.
\end{align}

\noindent Ce qui correspond bien au résultat attendu. Une fois les
reprojections calculées, on les somme pour obtenir la projection
$M_{(p_k,q_k)}f$ comme indiqué dans \cref{eqn.somme_reprojection}.



## Simplification des opérations {#sec.simplification.operations}

% analyse et simplification des opérations

L'\cref{alg.reprojection} suppose que l'on ait déterminé les projections du
fantôme composé $\ghost{(p,q)}$ suivant les direction $(p_i,q_i) \in
\mathcal{P}(S)$ et $(p_q)$ au préalable. Or, par définition, le fantôme
composé est issu de la convolution de fantômes élémentaires (voir
\cref{eqn.fantome.compose}). En conséquence, Puiqsue $\ghost{(p,q)}$ est 

\begin{equation}
    \begin{split}
        M_{(p,q)} f_S^{\dirset{(p_i,q_i)}}
            &= (M_{(p_i,q_i)}f)\\
            & \bigastinv_{(p_j,q_j) \in S \setminus \dirset{(p_i,q_i)}}
                (M_{(p_i,q_i)} G_{(p_j,q_j)})\\
            & \bigast_{(p_j,q_j) \in S \setminus \dirset{(p_i,q_i)}}
                (M_{(p,q)} G_{(p_j,q_j)})\;.
    \end{split}
    \label{eqn.simplification}
\end{equation}

\noindent En particulier, chaque $(M_{(p_i,q_i)} G_{(p_j,q_j)}$ de
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
cette représentation est que dans certains cas, des opérations de convolution
s'annulent. Par exemple :

\begin{equation}
    \begin{split}
        M_{(0,1)} G_{S \setminus \{(0,1)\}}
            &= \begin{pmatrix} -1 & 2 & -1 \end{pmatrix}\\
        M_{(0,1)} G_{S \setminus \{(0,1)\}}
            &= (M_{(0,1)} G_{(-1,1)}) \bigast (M_{(0,1)} G_{(-1,1)})\\
            &= \begin{pmatrix} -1 & 1 \end{pmatrix}
                    \bigast \begin{pmatrix} 1 & -1 \end{pmatrix}
    \end{split}
    \label{eqn.simplification.exemple1}
\end{equation}

\begin{equation}
    \begin{split}
        M_{(2,1)} G_{S \setminus \{(0,1)\}}
            &= \begin{pmatrix} 1 & -1 & 0 & -1 & 1 \end{pmatrix}\\
        M_{(2,1)} G_{S \setminus \{(0,1)\}}
            &= (M_{(2,1)} G_{(-1,1)}) \bigast (M_{(2,1)} G_{(-1,1)})\\
            &= \begin{pmatrix} -1 & 0 & 0 & 1 \end{pmatrix}
                    \bigast \begin{pmatrix} -1 & 1 \end{pmatrix}
    \end{split}
    \label{eqn.simplification.exemple2}
\end{equation}

\noindent L'\cref{eqn.simplification} devient alors :

\begin{equation}
    \begin{split}
        M_{(2,1)} f_S^{\dirset{(0,1)}}
            &= (M_{(0,1)}f)\\
            & \bigastinv \left( 
                \textcolor{red}{ \begin{pmatrix} -1 & 1 \end{pmatrix} }
                \ast \begin{pmatrix} 1 & -1 \end{pmatrix} \right)\\
            & \bigast \left(
                    \begin{pmatrix} -1 & 0 & 0 & 1 \end{pmatrix}
                    \ast \textcolor{red}{\begin{pmatrix} -1 & 1 \end{pmatrix}}
                \right)\\
            &= (M_{(0,1)}f) 
                \bigastinv \begin{pmatrix} 1 & -1 \end{pmatrix}
                \bigast \begin{pmatrix} -1 & 0 & 0 & 1 \end{pmatrix}\;.
    \end{split}
    \label{eqn.simplification}
\end{equation}

\noindent La décomposition des projections de fantôme permet ici de simplifier
l'opération de reprojection en supprimant les éléments en rouge.
En conséquence, la reprojection d'une reconstruction partielle peut
être calculée à partir de la connaissance d'une projection et d'un ensemble de
directions qui vérifie le critère de \katz. L'\cref{eqn.simplification} montre
comment obtenir ce résultat en utilisant uniquement des opérations de
convolutions et de déconvolution 1D, dont les opérations peuvent parfois se
simplifier quand on décompose les projections du fantôme composé.

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
Le \cref{lst.map} donne un extrait du code qui correspond à cette
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
\cref{alg.reproj.g} de l'\cref{alg.reprojection}. Le \cref{lst.reduction} donne
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
	$4$Ko à $128$Ko.}
    \label{fig.eval.reproj}
\end{figure}

La \cref{fig.eval.reproj} représente les résultats obtenus lors de notre
expérimentation. Il est tout d'abord intéressant de remarquer que la courbe se
croise lorsque la taille de bloc $\mathcal{M}=8$Ko. Avant ce point, la méthode
classique est plus efficace que la nouvelle méthode. Ce désavantage de la
nouvelle technique provient de la création et de la gestion des *threads* qui
coûte un temps significatif dans le cas où l'opération de réduction est simple
à réaliser. Après ce point, l'écart des performances enregistrées pour chaque
technique devient plus en plus significatif. En particulier, lorsque
$\mathcal{M}=128$Ko, la nouvelle technique calcule la reprojection en
$\num*{1.217e-3}$s, ce qui correspond à la moitié du temps nécessaire pour
l'ancienne méthode qui nécessite $\num*{2.591e-3}$ms. À mesure que la taille du
bloc augmente, l'opération de reprojection devient de plus en plus compliqué à
réaliser. En comparaison, le coût de la gestion des *threads* devient
négligeable. De plus, l'utilisation de plusieurs cœurs CPU en parallèle offre
un gain de temps linéaire. 


% # Perspectives et conclusion

% ## Réduction des données en transmission

% ## Codage réseau

% ## Conclusion

\section*{Conclusion du chapitre}

Ce chapitre a permis de présenter une nouvelle méthode pour déterminer de
nouvelles projections, à partir d'un ensemble déjà existant. Cette technique est
décrite dans \cref{sec.reprojection.sans.reconstruction}. Cette méthode se
base sur la proposition de reconstruction partielle.  En particulier, nous
avons qu'un ensemble suffisant de reconstructions partielles permet de
reconstruire l'image. Par linéarité, la somme des projections calculées depuis
ces reconstructions, suivant $(p,q)$, donne la projection correspondante de
l'image. Cette technique permet donc de reprojeter l'image suivant une nouvelle
direction. Chaque reconstruction est indépendante et peut alors être réalisée
de manière distribuée.

En se basant sur la définition des fantômes, nous sommes parvenus à définir
ces opérations à travers des opérations de convolutions et de déconvolutions
1D. Il est ainsi possible de reprojeter les valeurs d'un ensemble suffisant de
projections, sans avoir à explicitement reconstruire l'image. Cette méthode
présente un intérêt particulier dans le cas d'algorithmes de dispersion
d'information, tel que propose \textcite{rabin1989jacm}.

L'algorithme nécessite de connaître les projections du fantôme composé suivant
les directions en jeu. Nous sommes cependant parvenus à décomposer les
opérations utilisées dans notre algorithme afin de déterminer ces valeurs par
des opérations de convolutions. De plus, en faisant cette décomposition, des
simplifications dans le calcul peuvent apparaître.

La \cref{sec.eval.reproj} s'est intéressé à la mise en œuvre d'une
expérimentation visant à déterminer le gain de cette nouvelle technique. En
particulier, notre expérimentation repose sur l'utilisation d'*OpenMP* pour
distribuer les calculs sur l'ensemble des cœurs CPU disponibles. Bien que notre
méthode ne permet pas de diminuer la complexité des opérations de reprojcetion,
la distribution des calculs permet un gain significatif lorsque de grandes
quantités d'information sont traitées (i.e.\ classiquement un facteur $2$).
Dans un contexte de stockage distribué, la réparation d'un disque est un
processus qui met en jeu de très grandes quantité d'information.


% ça poutre
