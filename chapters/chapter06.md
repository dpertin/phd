
\chapter{Calcul distribué de nouveaux mots encodés}



# Problème de génération de mots encodés


# Décomposition de la reconstruction {#decomposition}

Dans cette section, nous présentons une nouvelle approche basée sur la
linéarité de la transformée Mojette permettant de décomposer l'opération
inverse en reconstructions partielles. En outre, nous montrons que chaque
projection contribue indépendamment à l'opération de re-projection. La seconde
partie met en avant une méthode équivalente reposant sur des opérations de
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

# Reconstruction par Convolutions 1-D

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
qui reconstruit une image $f_S^R$ depuis un ensemble de projections $R$ (i.e.
invalidant \cref{eqn.katz} si $R\subsetneq S$) et considérant les projections
manquantes comme nulles dans les directions $S\setminus R$.
Si les sous-ensembles $R_i$ forment une partition de $S$, alors par linéarité,
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

# Re-projection sans reconstruction


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



# Évaluation


