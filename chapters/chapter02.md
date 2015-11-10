
# Introduction à la géométrie discrète

# Code par transformée de Radon finie (FRT)

# Code par transformée Mojette



%\subsubsection{La Transformée Mojette}
%\label{sec:mojette}
%
%\begin{figure}
%  \centering
%  \includegraphics[width=0.65\columnwidth]{img/mojette_forward2.pdf}
%  \caption{Transformée Mojette d'une image $(P \times Q) = (3 \times 3)$ pour
%      les directions $(p,q)$ dans l'ensemble $S=\left\{(-1,1), (0,1), (1,1),
%      (2,1)\right\}$. Pour simplifier la compréhension par la suite,
%      l'addition est réalisée modulo $6$.}
%  \label{fig.mojette}
%\end{figure}
%
%La transformée Mojette calcule un ensemble de projections 1-D suivant
%différentes directions à partir d'une image discrète $f:(k,l)\mapsto\mathbb N$
%composée de $P \times Q$ \emph{pixels}.
%Une direction de projection est définie par un couple d'entiers $(p,q)$
%premiers entre eux. Les projections sont des vecteurs de taille variable dont
%les éléments sont appelés \emph{bins}.
%Un bin dans la transformée Mojette de $f$ est caractérisé par sa position $b$
%dans la projection correspondant à une ligne discrète d'équation
%$b = -kq + lp$.
%Sa valeur est le résultat de la somme des pixels centrés sur la ligne :
%\begin{equation}
%    (M_{(p,q)}f)(b) = \sum^{P-1}_{k=0} \sum^{Q-1}_{l=0} f(k,l) [b=-kq+lp],
%    \label{eqn.mojette}
%\end{equation}
%où $[\cdot]$ correspond au crochet d'Iverson ($[Pr]=1$ lorsque $Pr$ est vraie,
%$0$ dans les autres cas). Considérant un ensemble de directions de projection $
%S $, il a été montré que pour une image de taille $P \times Q$, la
%reconstruction donne une solution unique, si l'une des conditions suivantes est
%remplie :
%\begin{equation}
%    P \leq \sum^{I-1}_{i=0} |p_i| \text{ ou } Q \leq \sum^{I-1}_{i=0} |q_i|,
%    \label{eqn.katz}
%\end{equation}
%avec $I$ correspondant au nombre de projections \cite{guedon2009mojettebook}.
%La \cref{fig.mojette} donne un exemple de transformée Mojette sur une grille $3
%\times 3$ avec un ensemble de $4$ projections. Dans cet exemple, l'opération
%est inversible lorsque l'on prend un sous-ensemble de $3$ projections
%$\left\{(p_{j_0},q_{j_0}),\dots,(p_{j_2},q_{j_2})\right\}$ puisque
%$\sum_{i=0}^2 |q_{j_i}|=3 \geq Q$. Il s'agit alors d'une représentation redondante
%de l'image puisque la perte d'une projection sur les quatre est tolérée pour la
%reconstruction.
%%Lorsque le fantôme composé, construit à partir des directions d'un ensemble de
%%projections, ne peut être contenu dans l'image à reconstruire, il existe une
%%solution d'inversion unique \cite{guedon2009mojettebook}. Cette proposition
%%généralise \cref{eqn.katz}.
%
%L'algorithme de reconstruction \cite{normand2006dgci} vise à déterminer les
%bins reconstructibles et à réécrire leur valeur dans l'image. Il est possible
%de reconstruire des bins lorsque qu'ils résultent de la somme d'un unique pixel
%de l'image. Une fois que le bin est reconstruit, sa contribution est soustraite
%dans l'ensemble des projections en jeu dans la reconstruction. De plus, le
%pixel reconstruit est enlevé du problème, ce qui permet la reconstruction
%d'autres bins.
%%Il est ainsi
%%possible de construire un graphe de dépendance des pixels pour définir un
%%chemin de reconstruction .
