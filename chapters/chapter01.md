
\chapter{Principe et évaluation des codes à effacement}

\label{sec.chap1}

\minitoc

\newpage

\section*{Introduction du chapitre}

\addcontentsline{toc}{section}{Introduction du chapitre}

Le terme «\ information\ » désigne à la fois un message à communiquer et les
symboles qui le composent. L'information est disponible sous plusieurs formes
(une lettre, une musique, une image, etc.). Dans nos travaux, nous traitons de
l'information quelle que soit sa forme. Il est revanche nécessaire de disposer
d'une représentation numérique. Lors d'une transmission, une information est
envoyée sur un canal par un émetteur, pour un destinataire. Il existe une
multitude de canaux de transmission (e.g.\ un réseau câblé, un support de
stockage). De par sa nature et de par les perturbations de son environnement,
un canal ne peut être sûr. Plusieurs critères peuvent être utilisés pour
définir la fiabilité d'une transmission. Par exemple, une transmission peut
être considérée fiable si le message reçu est intègre, et si le temps de
transmission est considéré court. D'autres critères peuvent parfois s'ajouter
en fonction du contexte. Par exemple, il peut être nécessaire qu'une
information secrète ne doit pas être lisible par un tiers.

La théorie des codes est une branche de la théorie de l'information qui
s'intéresse à la forme de l'information quand elle transite sur un canal.
Dans le cas des codes correcteurs, on s'intéresse à ajouter de la
redondance à l'information à transmettre. Cette redondance doit permettre au
destinataire de reconstituer le message quand celui ci a été détérioré
pendant la transmission. Une considération essentielle de cette théorie est de
déterminer la quantité minimale de redondance nécessaire pour assurer une
transmission fiable (i.e.\ réduire le bruit du canal).

Dans les travaux de cette thèse, nous nous intéresserons à la transmission
d'information par «\ paquets\ ». Dans ce mode de transmission, un flux de
données est découpé par paquets de $w$ bits qui forment un paquet (on utilisera
également le terme «\ bloc\ »). En particulier, nous étudierons le phénomène
«\ d'effacement\ » de ces paquets sur le canal. L'effacement d'un paquet se
distingue de l'altération des données par deux considérations : (i)
l'identifiant du bloc effacé est connu (on sait quel paquet a été reçu), ce qui
relaxe le processus de détection d'erreur des codes correcteurs; (ii)
l'ensemble des données du paquet est alors indéterminé.

Différentes techniques permettent de générer de la redondance. Il est par
exemple possible de répéter plusieurs fois un bloc d'information à
transmettre. Une quantité suffisante de répétitions permet de réduire
significativement le bruit du canal. En revanche, plus le nombre de
répétitions est élevé, plus le taux d'information utile diminue. Également
désigné par le terme «\ rendement\ », ce taux correspond au rapport entre le
nombre de blocs utiles sur le nombre de blocs transférés.
La difficulté consiste alors à déterminer la valeur du rendement à utiliser
pour transmettre efficacement sur un canal. On tend naturellement à penser que
la probabilité d'erreur tend vers $0$ quand le rendement tend vers $0$
En 1948, \shannon a montré qu'en réalité dans le cas d'un canal à transmission
sans mémoire, le rendement possède une valeur limite jusque laquelle la
probabilité d'erreur est nulle \cite{shannon1948bstj}. Cette valeur limite $C$
est appelée «\ capacité\ » du canal. Une transmission réalisée avec un
rendement
supérieur à $C$ ne peut pas être fiable. En revanche, il existe des codes
permettant de corriger les erreurs dans le cas où le rendement est inférieur à
$C$. Dès lors, la théorie des codes s'est intéressée à la conception de codes
et d'algorithmes permettant d'atteindre cette limite. Par exemple, les codes
*Low-Density Parity-Check* (LDPC) permettent en théorie d'atteindre cette
limite de manière asymptotique \cite{gallager1962toit}. En pratique (i.e.\ sur
des codes de longueur finie) soit le décodage est efficace mais ne permet pas
d'atteindre cette limite (décodage itératif) soit il s'en approche, mais au
prix d'une complexité algorithmique significative (décodage par maximum de
vraisemblance).

En 1950, \hamming a défini la notion de distance d'un code. La théorie des
codes algébriques s'est développée à partir de là. La notion de «\ distance de
séparation minimale\ » (MDS, pour *Maximum Distance Separable*) concernent des
codes qui fournissent une quantité redondance minimale relativement à une
capacité de correction arbitrairement fixée (i.e.\ qui atteignent la capacité
du canal). Les codes de \textcite{reed1960jsiam} sont les codes MDS les plus
connus.

Durant cette introduction, nous avons parcouru différentes notions de la
théorie des codes. La \cref{sec.theorie.codes} va détailler ces notions et
en donner les caractéristiques mathématiques. Ces notions seront nécessaire
afin de comprendre le principe des codes à effacement, présenté dans la
\cref{sec.codage.effacement}. Cette section présentera notamment comment
distinguer et évaluer les différents codes à effacement. La
\cref{sec.exemples.codes.effacement} présentent les grandes familles de codes à
effacement (\rs, LDPC, etc.). En particulier nous verrons leur construction
ainsi que les algorithmes de décodage.



# Notion de théorie des codes {#sec.theorie.codes}

Dans cette section, nous verrons dans un premier temps les caractéristiques des
canaux de transmission dans la \cref{sec.canal}. Les notions d'entropie,
d'information mutuelle et de capacité du canal y seront traitées. Nous verrons
par la suite l'exemple du canal binaire symétrique et du canal à effacement
dans la \cref{sec.exemples.canaux}. La \cref{sec.theorie.codes.correcteurs}
présentera la théorie des codes correcteurs appliqués au canal à effacement.
Nous y définirons les opérations d'encodage, de décodage, ainsi que les
caractéristiques des codes à effacement.


## Propriétés d'un canal de communication {#sec.canal}

\begin{figure}
    \centering
    \def\svgwidth{\textwidth}
    \includesvg{img/canal}
    \caption{Représentation du modèle d'un canal de communication. $X$ et $Y$
    représentent des variables aléatoires. Chaque élément de ces variables a
    une probabilité d'apparition notée respectivement $p(x_i)$ et $p(y_i)$. Une
    loi de transition $P(X|Y)$ définit les probabilité $p(x_i|y_i)$ de recevoir
    le symbole $y_i$ sachant que $x_i$ a été envoyé.}
    \label{fig.canal}
\end{figure}

Un canal de communication est un support de transmission d'information
permettant d'acheminer une information depuis un émetteur vers un destinataire.
La \cref{fig.canal} représente la modélisation d'un canal. Un canal
$C\left[X,Y,P(X|Y)\right]$ est défini par :

1. Un alphabet d'entrée $X = \{x_1,\dots,x_{r}\}$, de cardinal $r$,
représentant la source;

2. Un alphabet de sortie $Y = \{y_1,\dots,y_{s}\}$, de cardinal $s$,
représentant la destination;

3. D'une loi de transition $P(X|Y)$ qui peut être représentée par la matrice
stochastique suivante :

\begin{equation}
    P(Y|X) = \begin{pmatrix}
        P(x_1,y_1) & P(x_1,y_2) & \cdots & P(x_1,y_s)\\
        P(x_2,y_1) & P(x_2,y_2) & \cdots & P(x_2,y_s)\\
        \vdots     & \vdots     & \ddots & \vdots \\
        P(x_r,y_1) & P(x_r,y_2) & \cdots & P(x_r,y_s)
    \end{pmatrix}\;.
\end{equation}

\noindent Une source d'information $\mathcal{S}$ est défini par un couple
$\mathcal{S}=(A,P)$ où $A$ est un alphabet $A=\{s_1,\dots,s_{|A|}\}$ et $P$ est
une distribution des probabilités sur $A$, c'est à dire que $p_i$ correspond à
la probabilité d'apparition de $s_i$ lors d'une transmission. Dans un document
rédigé en français par exemple, la probabilité d'apparition de la lettre
«\ e\ » est plus importante que pour les autres lettres de l'alphabet.
La source est «\ sans mémoire\ » lorsque l'apparition de $s_i$ est indépendant
de $s_j$ pour $i \neq j$, et que leur probabilité n'évolue pas pendant la
transmission. Dans le cas de notre modélisation, chaque élément de $x_i \in X$
a une probabilité d'apparition $p(x_i)$.
Soit $p_{x_i|y_i} = P(X=x_i, Y = y_i)$, la probabilité
de recevoir le symbole $y_i$ sachant la valeur du symbole émis $x_i$.
Par exemple, sur un canal sans bruit, $p_{x|x} = 1$ et $p_{x|y} = 0$
pour $x \neq y$. Dans la section suivante, nous étudierons deux canaux
particuliers : le canal binaire symétrique, et le canal à effacement.
Dans le reste de cette section, nous allons définir les différentes
caractéristiques d'un canal, qui nous serons utiles pour la suite. En
particulier, nous définirons l'entropie, l'information mutuelle et la capacité
d'un canal.

### Entropie

Le degré d'originalité $I(s_i)$ (parfois appelé «\ auto-information\ ») est
défini comme l'information transmise par le symbole $s_i$ et vaut
\cite{shannon1948bstj}:

\begin{equation}
    I(s_i) = -\log_2(p_i).
\end{equation}

\noindent En conséquence, un symbole qui apparaît souvent ne véhicule que peu
d'information par rapport à un symbole qui apparaît très rarement.
L'entropie $H(\mathcal{S})$ d'une source correspond à la valeur moyenne du
degré d'originalité de l'ensemble des symboles de l'alphabet :

\begin{equation}
    \begin{split}
    H(\mathcal{S})  &= \mathbb{E}\left[I(s_i)\right]\\
                    &= -\sum_{x=1}^r p_x \log_2\left(p_x\right)
                    =  \sum_{x=1}^r p_x \log_2\left(\frac{1}{p_x}\right).
    \end{split}
\end{equation}

\noindent L'entropie $H(\mathcal{S})$ mesure en conséquence l'incertitude des
informations provenant de la source en bits par symbole. En particulier, si
$p(s_i) = 1$ et $p(s_j) = 0$ pour $i \neq j$, alors on a aucune incertitude sur
la source et $H(\mathcal{S})=0$ : le résultat est connu d'avance. À l'inverse,
si tous les symboles sont équiprobables $p(s_i)=\frac{1}{|A|}$, alors
$H(\mathcal{S}) = \sum_{i=1}^{|A|} \frac{1}{|A|} \log_2 |A| = \log_2 |A|$ et il
est impossible de prédire le résultat puisque l'incertitude est maximale.

### Entropie de lois conjointes

Notre modèle de canal représente l'émetteur et le destinataire par deux
variables aléatoires. Soit $(X,Y)$ la loi conjointe des variables aléatoires
$X$ et $Y$. On cherche à déterminer l'incertitude associée à ces deux
variables. Pour cela, on détermine l'entropie de la loi conjointe qui est
défini ainsi :

\begin{equation}
    H(X,Y)  = \mathbb{E}\left[\log_2 \left(\frac{1}{P(X,Y)}\right)\right]
            = - \sum_x%{i=1}^{|X|}
                \sum_y%{i=1}^{|Y|}
                p_{x|y} \log_2 \left( p_{x|y} \right),
\end{equation}

\noindent où $p_{x|y}$ correspond à la probabilité $p(X=x,Y=y)$.

### Entropie de lois conditionnelles

Dans l'objectif d'obtenir une modélisation d'un canal, on cherche à modéliser
les perturbations du canal par des probabilités conditionnelles. Pour cela, on
utilise l'entropie conditionnelle $H(X|Y=y)$ qui correspond à l'incertitude de
$X$ lorsqu'une valeur de Y est connues :

\begin{equation}
    H(X|Y=y) = - \sum_x p_{x|y} \log_2 p_{x|y}\;,
\end{equation}

\noindent Cette notion peut être ensuite étendue dans le cas où l'on connait
l'ensemble des degrés d'originalité des symboles de $Y$ :

\begin{equation}
    H(X|Y) = - \sum_{x,y} p_{x|y} \log_2 \left( \frac{p_y}{p_{x|y}} \right).
\end{equation}

\noindent $H(X|Y)$ correspond à la quantité d'information perdue sur le canal.


### Information mutuelle

Lors d'une transmission d'information sur un canal, le récepteur doit être
capable de déterminer le symbole $x_i$ transmis depuis la source, à partir des
informations reçues $y_i$ par le récepteur. L'information mutuelle $I(X,Y)$
mesure la quantité d'information reçue. Elle correspond à la quantité
d'information restante lorsque l'on soustrait l'information perdue sur le
canal $H(X|Y)$, à l'information émise par l'émetteur $H(X)$ :

\begin{equation}
    \begin{split}
        I(X,Y)  &= H(X) - H(X|Y) \\
                &= \sum_x \sum_y
                    p_{x|y} \log_2 \left( \frac{p_{x|y}}{p_xp_y} \right).
    \end{split}
\end{equation}

\noindent En conséquence, deux cas particuliers découlent de cette notion. Si
$H(X) = H(X|Y)$, les variables sont indépendantes, ce qui signifie qu'aucune
information n'est obtenue. Dans le deuxième cas, $H(X|Y) = 0$, ce qui signifie
que l'information mutuelle est maximum. Dans ce cas $Y$ est entièrement
déterminée par $X$ et le canal ne provoque pas d'erreur.

### Capacité d'un canal

La capacité d'un canal $C(X,Y)$ est définie ainsi :

\begin{equation}
    C(X,Y) = \max{I(X,Y)}\;.
\end{equation}

\noindent Elle correspond à la quantité maximale d'information qui peut être transmise par le canal.



## Exemples de canaux {#sec.exemples.canaux}

Notre étude va s'intéresser aux deux canaux suivants : le canal binaire
symétrique, et le canal à effacement.

### Canal binaire symétrique

\begin{figure}
    \centering
    \def\svgwidth{.6\textwidth}
    \includesvg{img/cbs}
    \caption{Représentation d'un canal binaire symétrique. La source transmet
    sur le canal des bits dont la valeur peut être altérée avec une probabilité
    $p$.}
    \label{fig.cbs}
\end{figure}

Le canal binaire symétrique (CBS) est un simple à étudier. La source binaire
est définie par un alphabet $A=\{0,1\}$. En conséquence, elle émet des
bits à travers un canal caractérisé par une probabilité $p$ d'inverser la
valeur du bit. La \cref{fig.cbs} illustre ce canal. Ainsi, la loi de transition
est définie ainsi :

\begin{equation}
    P(X|Y) = \begin{cases}
        1-p     &\text{si X=Y}\\
        p       &\text{sinon}
    \end{cases}\;.
\end{equation}

\noindent L'entropie est à son maximal lorsque la distribution de $Y$ est
uniforme. Dans le cas du canal symétrique, cela correspond à une distribution
de $X$ uniforme. En conséquence, l'information mutuelle est maximale lorsque
$p=0.5$. La capacité du CBS correspond à \cite[p. 316]{dumas2007book} :

\begin{equation}
    \begin{split}
        C   &= 1 - H_2(p)\\
            &= 1 - + p \log_2(p) + (1-p) \log_2(1-p)\\
    \end{split}\;,
\end{equation}

\noindent où $H_2(p)$ correspond à l'entropie d'une variable aléatoire d'une
loi de \textsc{Bernoulli} (ou loi binaire), de paramètre $p$. La capacité du
signal vaut donc $1$ quand la probabilité d'erreur $p$ a valeur dans $\{0,1\}$.
En particulier, lorsque $p=0$, il n'y a jamais d'erreur de transmission, et $Y$
correspond à $X$. En revanche, lorsque $p=1$, la valeur du symbole reçu
correspond toujours à l'inverse du symbole émis. Un code dont le rendement vaut
$1$ (i.e.\ sans redondance) suffit alors dans ce cas. En revanche, la capacité
est nulle quand $p=0,5$. Ce dernier cas est le plus défavorable puisque $X$ et
$Y$ sont indépendants (la sortie n'apporte aucune connaissance sur l'entrée).
Du point de vue du rendement, la quantité de redondance nécessaire doit alors
tendre vers l'infini.


### Canal à effacement

\begin{figure}
    \centering
    \def\svgwidth{.6\textwidth}
    \includesvg{img/cbe}
    \caption{Représentation d'un canal binaire à effacement. La source transmet
    sur le canal des bits qui peuvent être effacés avec une probabilité $p$.
    L'effacement représente la transition d'un bit vers «\ $?$\ ».}
    \label{fig.cbe}
\end{figure}

Un canal binaire à effacement (CBE) se distingue du canal précédent par le fait
que l'information n'est pas modifiée, mais effacée lors de la transmission. Un
effacement correspond simplement à la perte de l'information. La \cref{fig.cbe}
illustre ce canal. On représente la perte d'information par le symbole
«\ $?$\ ». La probabilité qu'un symbole soit effacé vaut $p$, ce qui
signifie qu'un symbole est correctement transmis avec une probabilité $1-p$. En
conséquence, on peut représenter la loi de transition $P(X|Y)$ ainsi :

\begin{equation}
    P(X|Y) = \begin{pmatrix}
        1-p & p & 0 \\
        0 & p & 1-p
    \end{pmatrix}\;.
\end{equation}

\noindent Si l'on reçoit un $0$ ou un $1$, alors il n'y a aucun
doute sur la valeur émise. En conséquence, $H(X|Y=0) = H(X|Y=1) = 0$. En
revanche, si on reçoit un « ? », on n'a rien appris sur l'entrée, et donc
$H(X|Y=?) = H(X)$. La capacité du canal à effacement vaut $C=1-p$. On peut
ainsi comparer la capacité de ce canal par rapport au précédent. En
particulier, puisque $\forall p \in [0,\frac{1}{2}], p < H(p)$, la capacité du
canal à effacement est supérieure à celle du CAE. Il est donc plus facile de
gérer les effacements que les modifications de valeurs. Ce résultat était
prévisible puisque dans le cas du CBS, la correction d'erreurs nécessite au
préalable de détecter l'emplacement de ces erreurs avant de pouvoir rectifier
leurs valeurs. Dans le cas du canal à effacement en revanche, la position de
l'erreur est connue, et la correction correspond uniquement à restituer la
valeur de l'information perdue.

% comparer les deux courbes de capacité

% mettre en annexe le calcul des capacités des canaux



## Théorie des codes correcteurs {#sec.theorie.codes.correcteurs}

On appelle «\ code\ » une technique qui permet de transformer la représentation
d'une information en une autre représentation. Le terme code est également
utilisé pour désigner le résultat de cette transformation.  En transmission de
l'information, on distingue principalement deux types de codage. Le premier,
appelé «\ codage source\ », concerne la compression des informations à
transmettre. Cette compression a pour but de réduire la redondance interne au
message à transmettre afin d'optimiser le débit de transmission. À l'inverse,
le «\ codage canal\ », qui intervient en général après, a pour objectif de
générer de la redondance afin de permettre une transmission fiable.


### Codes en blocs

Pour transmettre une information, il faut définir un «\ alphabet\ » $A$ qui
correspond à un ensemble fini de symboles. Bien que l'information à traiter n'a
pas toujours de taille définie, il est préférable de travailler sur des
éléments de tailles fixes, c'est le cas des codes en bloc. Une succession finie
de symboles correspond à un «\ mot\ » (ou bloc, ou paquet). Les mots de codes
correspondent à l'information encodée que l'on transmet sous la forme de mots.
La «\ longueur\ » $n$ d'un code correspond au nombre de symboles transmis dans
chaque mot encodé. La «\ dimension\ » d'un code correspond à la taille du mot à
transmettre.

#### Encodage

Pour un code correcteur $(n,k)$, l'encodage correspond à une application
injective $\phi : A^k \to A^n$, où $A$ est un alphabet (dans le cas du canal
binaire, $A=\{0,1\}$) et où $k \leq n$.
L'ensemble $\mathcal{C}_{\phi}=\{\phi(s) : s \in A^k\}$ correspond au code
$(n,k)$ dont les éléments sont des mots de codes. Les corps finis correspondent
à des structures discrètes adaptées aux applications de codage. Les mots de
codes sont donc transmis sur le canal lors de la transmission.

#### Décodage

Le décodage consiste à vérifier si les mots reçus appartiennent à respecte bien
$\mathcal{C}_\phi$. Si ce n'est pas le cas, deux stratégies sont possible pour
corriger l'erreur :

1. Le récepteur peut demander à la source de réémettre le message. Cette
stratégique appelée *Automatic Repeat reQuest* (ARQ), n'est pas toujours
possible (certains médias ne disposent pas de canal de retour),

2. L'émetteur intègre a priori de l'information redondante afin que le
destinataire puisse reconstituer l'information en cas de perte. C'est cette
stratégie, appelée *Forward Erasure Code* (FEC), qui sera particulièrement
étudiée dans cette thèse.

\noindent Dans le deuxième cas, s'il existe un entier $i$ et un unique mot de
code ayant au moins $n-i$ bits égaux au mot reçu, alors on corrige le mot reçu
par ce mot. Sinon, on ne peut pas corriger l'erreur.

#### Rendement

Le «\ rendement\ » $R$ d'un code $(n,k)$ correspond à la quantité de symboles
sources contenus dans un mot de code. Il est défini ainsi :

\begin{equation}
    R = \frac{k}{n}.
\end{equation}

\noindent Plus le rendement est grand, plus les mots de code contiennent
d'information utiles. En revanche, la capacité de correction diminue.
Pour conclure, une «\ bonne\ » fonction de codage $\phi$ doit pouvoir fournir
une grande capacité de correction et un rendement important, à travers des
techniques efficaces. En particulier, on s'intéressera au coût des algorithmes
d'encodage et de décodage (vérification et correction de l'erreur).

#### Poids et distance de \hamming

Le poids de \hamming $w$ d'un mot de code correspond au nombre de symboles non
nuls.
Soit $x$ et $y$ deux mots de même longueur, construits sur un alphabet $A$. La
distance de \hamming $d_H(x,y)$ entre $x$ et $y$ correspond au nombre de symboles
qui diffèrent entre les deux mots. Par exemple $d(118,218) = 1$.
La distance minimale d'un code $\mathcal{C}$ est définie par :

\begin{equation}
    \min_{x,y \in \mathcal{C}} d_H(x,y).
\end{equation}

\noindent Les capacités des codes correcteurs sont exprimées grâce à la
distance de \hamming. En particulier, un code $\mathcal{C}$ peut détecter
$t$ erreurs si $d(\mathcal{C} = t+1$ et corrige $t$ erreurs quand
$d(\mathcal{C}=2t+1)$.


### Codes linéaires 

Dans le cas où l'application $\phi$ est linéaire, on dit que le code $(n,k)$
est linéaire. L'avantage des codes linéaires est que les opérations de codage
et de décodage sont réalisées en temps polynomial en $n$. Il faut alors munir
$A$ d'une structure vectorielle telle que les corps $\FF$ dont le nombre
d'éléments doit être fini. 

#### Encodage

Un code $(n,k)$ est linéaire s'il
existe une application linéaire $\phi : \FF^k \to \FF^n \mid \phi(\FF^k) =
\mathcal{C}$. Une telle application peut alors être décrite par une matrice de
taille $k \times n$, à coefficient dans $\FF$, appelée « matrice génératrice »
$G$. L'encodage correspond à la multiplication matricielle suivante :

\begin{equation}
    Y = X G,
\end{equation}

\noindent où $X \in \FF^k$ et $Y \in \FF^n$. La forme et le contenu de cette
matrice sont déterminants pour définir un bon code correcteur. Au cours de ce
manuscrit, plusieurs matrices d'encodage seront présentées et nous verrons
quels influences elles ont sur l'efficacité des opérations d'encodage et de
décodage. Dans un premier temps, il est intéressant d'évaluer le rapport entre
la capacité de correction et le rendement, ce qui nécessite de définir la borne
de Singleton.

#### Borne de \singleton et codes MDS

La distance minimale $d$ d'un code linéaire $(n,k)$ correspond au plus petit
poids non nul de ce code. En particulier, il existe une relation entre $d$ et
les paramètres du code, appelée la borne de \singleton, définie tel que
\cite{singleton1964toit} :

\begin{equation}
    d \leq n-k+1\;.
\end{equation}

\noindent En conséquence, un code linéaire de distance $d$ doit nécessairement
générer au moins $n - k + 1$ symboles supplémentaires. Lorsqu'un code atteint la
borne de \singleton, il fournit précisément cette quantité de redondance qui est
optimale pour une valeur de rendement fixé. Un tel code est MDS, pour *Maximum
Distance Separable*.

#### Forme systématique des codes

En général, une matrice génératrice peut être représentée sous la forme
suivante :

\begin{equation}
    G = \left[ \underset{k \times k}{L} 
        \middle| \underset{(n-k) \times k}{R}
        \right]
\end{equation}

\noindent La matrice d'encodage $G$ peut être définie sous une forme
particulière, en intégrant une sous matrice identité de taille $k \times k$ :

\begin{equation}
    G = \left[ {I_{k}} 
        \middle| {T},
        \right]
\end{equation}

\noindent Tout code linéaire peut être écrit sous cette forme, appelé forme
systématique. Contrairement au cas général, la forme systématique permet
d'intégrer le message au sein du mot encodé. En particulier, les $k$ premiers
symboles du mot de code correspondent au message, tandis que les $r=n-k$
derniers correspondent à des symboles de parité, calculés à partir de la
matrice $T$. Il est possible de transformer une matrice $G$ sous sa forme
systématique en utilisant l'algorithme de \gauss.

En pratique, cette forme permet au récepteur d'accéder directement
à la donnée lorsque les $k$ premiers symboles n'ont pas été altérés durant la
transmission. Il en résulte un gain significatif sur les performance du
décodage puisqu'aucun calcul n'est nécessaire.

#### Matrice de parité

Il est également possible de définir un code linéaire en définissant une
application linéaire dont il est le noyau. Cette application est représentée
par une matrice $H$, appelé «\ matrice de parité\ » :

\begin{equation}
    \mathcal{C} = \Big\{(x_1,\dots,x_n) : H \times \begin{pmatrix}
        x_1 \\ x_2 \\ \vdots \\ x_n
        \end{pmatrix} = 0 \Big\}\;.
\end{equation}

\noindent Une telle matrice est facilement déterminée à partir de la matrice
$G=[I|T]$ définie précédemment, tel que :

\begin{equation}
    H = \left[ T^{t}
        \middle |
        -I_r \right],
\end{equation}

\noindent où $T^t$ est la transposée de la matrice $T$, et $I_r$ est une
matrice identité de taille $r \times r$, où $r=n-k$.

#### Syndrome et décodage

Lorsqu'un message $y$ est reçu, pour déterminer si celui correspond à un mot de
code (et donc s'il n'a pas été altéré, a priori) il suffit de calculer
$Hy$, qui est appelé le «\ syndrome\ ». Si le syndrome n'est pas nul, c'est qu'il
y a une erreur. On cherche alors à déterminer la valeur du mot de code $x$ à
partir de $y$. Pour cela, on calcule le vecteur d'erreurs $e=y-x$. Le décodage
consiste donc à trouver l'unique élément $x \in \mathcal{C} \mid d_H(x,y) \leq
t$, où $t$ correspond au nombre d'erreur que peut corriger le code.



# Codage à effacement {#sec.codage.effacement}

Dans les travaux de cette thèse, nous nous intéressons en particulier au cas
des codes appliqués au canal à effacement.

## Considération sur les symboles

Jusque là nous avons considéré que les codes travaillent sur des mots
constitués de $w$ symboles. En informatique, la transmission d'informations
réalisée au niveau applicatif travaillent sur des paquets (ou blocs). Les codes
à effacement appliqués à la couche applicative, les codes AL-FEC (pour
*Application-Level Forward Erasure Codes*) ont alors pour but de créer de
la redondance sur l'information contenue au sein d'un ensemble de paquets afin
que le destinataire puisse reconstituer des paquets effacés.

En pratique les symboles peuvent représenter des données à différentes
échelles. Sur la couche physique, les symboles correspondent à des bits. Ils
peuvent représenter un octet d'information. C'est le cas par exemple dans le
standard de transmission vidéo DVB-H \cite{faria2006ieee}. Ils peuvent
représenter des paquets dans un protocole réseau
\cite{tournoux2010tom,roca2015rfc}. Dans un contexte de stockage, ils peuvent
également représenter des morceaux ou des fichiers entiers \cite{huang2012atc}.

## Principe des codes à effacement par paquets

\begin{figure}
    \centering
    \small
    \def\svgwidth{\textwidth}
    \includesvg{img/ec}
    \caption{Principe d'un code à effacement $(n,k)$. Un flux d'information
    de $\mathcal{M}$ octets est découpé en $k$ blocs de données (en gris).
    L'encodage systématique consiste à générer $r = (n-k)$ paquets de parité
    (en bleu clair). L'ensemble de ces $n$ paquets encodés est envoyé sur le
    canal. Le décodage consiste à reconstruire les $k$ blocs de données. Si le
    code est MDS, ce décodage tolère la perte de n'importe quel ensemble de $r$
    paquets (en rouge).}
    \label{fig.ec}
\end{figure}

Un code à effacement $(n,k)$ permet de générer $n$ paquets encodés à partir
d'un ensemble de $k$ paquets de données où $(k \leq n)$. La \cref{fig.ec}
illustre le principe d'un code à effacement $(n,k)$ MDS. Dans l'exemple de la
figure, le code est présenté sous sa forme systématique. Les $n$ paquets
encodés contiennent alors les $k$ paquets d'information (blocs systématique),
auxquels s'ajoutent $r$ paquets de parité (ou de redondance). Lors de la
réception des paquets, il est nécessaire de vérifier si certains blocs
systématiques ont été perdus. Le cas échéant, l'opération de décodage consiste
à reconstruire cette information à partir des informations de parité.
Si le code est MDS, l'information contenue dans les $r$ blocs de parité
permettent de reconstruire n'importe quel sous-ensemble de $r$ blocs de données
perdus.

## Distinction entre les différents codes

De nombreux codes à effacement existent
\cite{reed1960jsiam,gallager1962toit,luby2002focs,shokrollahi2006toit}. Ce qui
les différencie correspond aux relations linéaires permettant
de calculer les informations de redondance. En particulier, cette distinction
de conception entraîne des différences sur la complexité d'encodage et de
décodage. Cette complexité théorique dépend du type et du nombre d'opérations
nécessaires (il s'agit généralement d'additions et de multiplications dans un
corps fini). Un autre critère essentiel correspond à la capacité de correction.
Par exemple, bien que les codes LDPC possèdent une complexité de décodage
linéaire $\mathcal{O}(n)$ reposant sur des opérations de «\ OU exlusif\ »
(XOR), il ne sont pas MDS. Les codes de \rs ont en revanche un rendement
optimal (codes MDS). Cependant, leur complexité au décodage est moins bon que
les codes LDPC. Bien que la complexité des codes de \rs soit souvent considérée
quadratique, de récents travaux ont permis de réduire cette complexité à
$\mathcal{O}(n \log n)$ \cite{lacan2010ccnc}. Nous allons détailler dans la
suite quelques exemples de codes à effacement.

%### Quelques applications des codes à effacements

%#### Application en réseau

%#### Application dans le stockage

# Exemples de codes à effacement {#sec.exemples.codes.effacement}

Les codes à effacement ont été un sujet de recherche très prolifique en
publications scientifiques. Aussi le nombre de codes qui ont été conçus est
très important.
Dans cette section, nous allons étudier en détail quatre codes à effacement.qui
représentent au mieux les différentes familles de codes à effacement : les
codes de répétition, les codes de parité, les codes de \rs et les codes LDPC.
Nous verrons en particulier leurs caractéristiques et leurs distinctions.

## Les codes de répétition

Les codes de répétition représentent des codes $(n,1)$. Ils correspondent à une
technique simple à mettre en œuvre. Il s'agit de transmettre plusieurs copies
de l'information à transmettre. Si l'on considère le canal binaire symétrique,
chaque bit est répété un nombre $n$, arbitraire, de fois. Dans le cas d'un code
de longueur $3$, le code génère les deux mots de codes suivant :
$\mathcal{C}=\{(000),(111)\}$. La matrice d'encodage de ce code correspond à la
matrice suivante :

\begin{equation}
    G = \underbrace{\begin{pmatrix} 1 & 1 & \cdots & 1 \end{pmatrix}}_{n}\;.
\end{equation}

Dans le cas du canal binaire symétrique, le décodage consiste à déterminer
quelle valeur est le plus répétée dans le mot reçu. Pour le canal à effacement,
dés lors qu'un symbole ($k=1$) parmi les $n$ est reçu, il correspond au symbole
transmis par l'émetteur.

Puisque les mots de code n'ont aucun bit en commun, cela signifie que la
distance minimale de \hamming vaut $d(\mathcal{C})=n$. En conséquence, ce code
est MDS. En revanche, le problème de cette technique est que la transmission
d'un symbole coûte l'envoie de $n$ symbole : le rendement de ce code correspond
à $R=\frac{1}{n}$. Cela signifie que cette technique réduit significativement
le débit utile. Nous verrons dans la suite des codes proposant de meilleurs
rendements.

## Les codes de parité

Le code de parité est un autre code simple à mettre en œuvre. Il permet un
meilleur rendement que les codes de répétition, mais sa capacité à corriger est
limité à une erreur : il s'agit d'un code $(n, k = n-1)$. La matrice d'encodage
d'un code de parité binaire de longueur $n$ correspond à :

\begin{equation}
    G = \left( \begin{matrix} 
        1 & 1 & \cdots & 0 \\
        0 & 1 & \cdots & 0 \\
        \vdots & \vdots & \ddots & \vdots \\
        \tikzmark{lower1}0 & 0 & \cdots & 1\tikzmark{lower2} \\
    \end{matrix}
    \ \middle |\ 
    \begin{matrix} 
            1 \\ 1 \\ \vdots \\ 1
    \end{matrix}\right)\;.
\end{equation}

\begin{tikzpicture}[overlay, remember picture,decoration={brace,amplitude=5pt}]
\draw[decorate,thick] (lower2.south) -- (lower1.south)
      node [midway,below=5pt] {$I_{n-1}$};
\end{tikzpicture}

\vspace{2em}

\noindent Le code de parité étant systématique, sa matrice génératrice $G$ est
composée d'une matrice identité $I_{n-1}$. La dernière colonne correspond à la
colonne de parité. Cette colonne permet de construire un symbole dont la valeur
correspond à la somme de la valeur des autres symboles. En conséquence, s'il
manque un symbole à la réception, sa valeur peut être calculé comme la somme
des valeurs des autres symboles. La distance minimale de \hamming de ce code
vaut $2$, ce qui signifie qu'il est capable de corriger qu'un seul effacement.
En revanche, son rendement vaut $R=\frac{n-1}{n}$ ce qui est signifie qu'une
quantité plus importante de données utiles est contenue dans un mot de
code. 

## Les codes de \rs

Les codes de \textcite{reed1960jsiam} sont les codes à effacement les plus
populaires. Cette popularité provient du fait qu'ils correspondent à des codes
MDS, dont les paramètres $(n,k)$ peuvent être choisis arbitrairement. Pour
cela, la matrice génératrice de taille $n \times k$ doit avoir la propriété
suivante : n'importe quelle sous matrice de taille $k \times k$ de $G$ doit
être inversible. Les matrices de \vander $V_{i,j} = \alpha_i^{j-1}$, où
$\alpha$ correspondent à des éléments du corps fini, possèdent une telle
propriété. L'encodage correspond alors à multiplier une matrice de \vander avec
le vecteur colonne représentant le message à transmettre.

Soit $y$ le message à transmettre, $x$ le mot de code transmis, et $x'$ le
message reçu. Dès que le destinataire reçoit $k$ symboles parmi les $n$
calculés, il est capable de décoder le message. Pour cela, on construit une
matrice $G'$ constituée des $k$ lignes de $G$ correspondant aux symboles reçus.
Puisque $G$ est une matrice de \vander, $G'$ est nécessairement inversible. En
conséquence, le message $y$ est reconstitué par l'opération suivante :
$y=G'^{-1}x'$.

Bien que les codes de \rs soient MDS, leur défaut provient de leur complexité
calculatoire lors des opérations d'encodage et de décodage. Le décodage
nécessitant une multiplication matricielle, implique $\mathcal{O}(k^3)$
opérations arithmétiques dans un corps de \galois. Notons que la mise en œuvre
des multiplications dans un corps de \galois a un coût significativement élevé
par rapport aux additions.
Plusieurs méthodes ont été proposées pour réduire cette complexité.
\textcite{blomer1995icsi} représente la matrice d'encodage de telle sorte à
définir les opérations qu'avec des additions, permettant de réduire la
complexité à $\mathcal{O}(k^2)$. \textcite{lacan2010ccnc} a par la suite réduit
cette complexité à $\mathcal{O}(k \log k)$ en utilisant la transformée de
\fourier.

% frédéric didier -> k \log(k)^2

## Les codes LDPC

Nous avons vu que malgré l'optimalité des codes de \rs en matière de rendement
(codes MDS), ils induisent une complexité significative lors des opérations
d'encodage et de décodage. Les codes LDPC sont à l'inverse des codes aux
complexités linéaires, mais non MDS. Pour répondre au problème du canal binaire
symétrique, \textcite{gallager1962toit} a proposé des codes basés sur une
matrice de parité à faible densité (LDPC). Ils ont ensuite été proposé dans le
cas du canal à effacement \cite{luby1997stoc}. Ces codes utilisent l'algorithme
de propagation de croyance (*Belief Propagation*) : un algorithme itératif qui
permet au décodage d'atteindre une complexité linéaire.

Les codes LDPC peuvent être représentés de manière équivalente de deux
manières : (i) une matrice de parité; (ii) un graphe de \textsc{Tanner}.

#### La matrice de parité

Pour faciliter l'opération de décodage, la matrice de parité $H$ doit être
creuse. Dans le cas du corps à deux éléments $\FF_2$, cela signifie que la
matrice $H$ est essentiellement constituée de $0$ par rapport à la quantité de
$1$. Prenons l'exemple suivant représentant une matrice de parité de taille $8
\times 4$ définissant un code LDPC :

\begin{equation}
    H = \begin{pmatrix}
        0 & 1 & 0 & 1 & 1 & 0 & 0 & 1\\
        1 & 1 & 1 & 0 & 0 & 1 & 0 & 0\\
        0 & 0 & 1 & 0 & 0 & 1 & 1 & 1\\
        1 & 0 & 0 & 1 & 1 & 0 & 1 & 0
    \end{pmatrix}\;.
    \label{eqn.ldpc}
\end{equation}

\noindent Pour être creuse, une matrice doit garantir que le nombre de $1$ dans
chaque colonne $w_c \ll n$ et le nombre de $1$ par ligne $w_r \ll k$. En
pratique, la taille des matrices des codes LDPC sont importantes pour pouvoir
garantir cela (ce n'est pas le cas de notre exemple). La matrice de
l'\cref{eqn.ldpc} permet de représenter $4$ équations  mettant en jeu les
bits d'un octet.

#### Le graphe de \textsc{Tanner}

\begin{figure}
    \centering
    \def\svgwidth{\textwidth}
    \includesvg{img/ldpc}
    \caption{Représentation d'un graphe de \textsc{Tanner} correspondant au
    code LDPC de l'\cref{eqn.ldpc}}
    \label{fig.ldpc}
\end{figure}

La \cref{fig.ldpc} représente le graphe de \textsc{Tanner} correspondant à
l'\cref{eqn.ldpc}. Un tel graphe contient deux ensembles de sommets qui
correspondent à (i) les bits à transférer; (ii) les sommets de contrainte.
Chaque arête fait le lien entre les deux ensembles de sommets.

### Décodage

Il existe deux techniques usuelles de décodage : le décodage itératif et le
décodage au maximum de vraisemblance.

#### Décodage itératif

Le décodage itératif est particulièrement performant, en revanche il n'est pas
optimal en capacité de correction. Il consiste à considérer les équations
décrites par l'\cref{eqn.ldpc} dont l'une des variables est inconnue. La valeur
de cette variable correspond donc à la constante de l'équation. Par la suite,
la valeur de cette variable est mise à jour dans l'ensemble des équations du
système. Lorsque qu'aucune des équations ne contient qu'une seule inconnue,
l'algorithme s'arrête. 

#### Décodage au maximum de vraisemblance

Contrairement à la méthode itérative, cette méthode de décodage est optimale en
capacité de correction. En revanche, elle a une complexité plus importante.
Dans le canal binaire symétrique, cette technique consiste à déterminer le mot
de code le plus proche du mot reçu (le plus vraisemblable). Dans le cas du
canal à effacement, cette méthode revient à résoudre un système linéaire avec
une technique semblable à une élimination de \gauss. \textcite{cunche2006itml}
ont conçu une méthode hybride permettant de commencer le décodage par une
méthode itérative, puis de passer par une technique au maximum de vraisemblance
si l'algorithme s'arrête.


\section*{Conclusion du chapitre}

\addcontentsline{toc}{section}{Conclusion du chapitre}

Ce chapitre nous a permis de présenter un état de l'art des codes correcteurs
pour le canal à effacement. La \cref{sec.theorie.codes} a introduit les notions
nécessaires pour comprendre la théorie des codes. En particulier nous avons
étudié le cas du canal à effacement dans lequel certains symboles ont une
probabilité d'être effacé. Ce cas est plus simple à résoudre que le cas du
canal binaire symétrique puisque l'on connait précisément l'emplacement du
symbole effacé dans le mot reçu.

Afin de résoudre le problème du canal à effacement, il est nécessaire de
proposer des codes à effacement capables de générer de la redondance
d'information au niveau du récepteur, afin que le destinataire puisse
reconstituer l'information même lorsqu'une partie a été effacée. La
\cref{sec.codage.effacement} présente le principe de ces codes à effacement
linéaires et leurs distinctions.

Nous avons vu dans la dernière section, quelques exemples de représentatif des
familles de codes à effacement.  En particulier, les codes de parité sont
simples à mettre en œuvre, mais particulièrement coûteux puisque leur rendement
est mauvais. Les codes de parité offrent un meilleur rendement mais ne peuvent
corriger qu'un effacement. Les codes de \rs sont les plus populaires puisque
leur capacité de correction n'a théoriquement pas de limite, et que leur
rendement est optimal (ce sont des codes MDS). En revanche, ils induisent une
complexité quadratique au décodage qui les pénalise. Les codes LDPC possèdent
une complexité de décodage linéaire mais n'ont pas un rendement optimal (MDS
dans le cas asymptotique).

En conséquence, les codes que nous avons proposé ne sont pas parfait. Dans le
meilleur des mondes, on disposerait d'un code MDS, de faible complexité, et
dont la capacité de protection est arbitraire. Nous verrons dans les prochains
chapitre que le codes à effacement Mojette s'en rapproche.
