
\chapter{Principe et évaluation des codes à effacement}

\label{sec.chap1}

\minitoc

\newpage

\section*{Introduction du chapitre}

Le terme « information » correspond à un concept et désigne à la fois un
message à communiquer et les symboles qui le compose. L'information est
disponible sous plusieurs formes (une lettre, une musique, une image \dots).
Dans nos travaux, nous traitons de l'information quelle que soit sa forme, tant
qu'il est possible de fournir une représentation numérique. Une information
disponible au niveau d'un émetteur a pour but d'être transmise à un
destinataire à travers un canal. Il existe une multitude de canal de
transmission tels qu'un réseau câblé ou un support de stockage. Naturellement,
n'importe quel canal est considéré comme non « sûr ». Plusieurs
critères sont à prendre en compte pour qu'une transmission soit fiable. En
particulier, le message reçu doit être intègre et le temps de transmission du
message doit être court. D'autres critères peuvent s'ajouter en fonction du
contexte. Par exemple, il peut être nécessaire qu'une information secrète ne
doit être lue par un tiers.

La théorie des codes est une branche de la théorie de l'information qui
s'intéresse à la forme de l'information quand elle transite sur un canal. En
particulier, on étudie comment transformer l'information avant son passage sur
le canal afin d'assurer que le récepteur puisse la reconstituer malgré de
potentiels altérations ou en tenant compte de la confidentialité de
l'information. Cette transformation doit prendre en compte la capacité du
canal, et minimiser la taille des données.

Dans le cas de la théorie des codes correcteurs, on s'intéresse en particulier
à ajouter de la redondance à l'information à transmettre. Cette redondance
permet au destinataire de reconstituer le message lorsque celui ci a été 
détérioré pendant la transmission. Une considération essentielle de cette
théorie est de déterminer la quantité de redondance nécessaire pour réduire
efficacement le bruit du canal.

Dans les travaux de cette thèse, nous nous intéresserons à la transmission
d'information par « paquets ». Dans ce mode de transmission, un flux de données
est découpé par paquets de $w$ bits qui forment un paquet (on utilisera
également le terme « bloc »). En particulier, nous étudierons le phénomène
« d'effacement » de ces paquets sur le canal. L'effacement d'un paquet se
distingue de l'altération des données par deux considérations : (i)
l'identifiant du bloc effacé est connu (on sait quel paquet a été reçu), ce qui
relaxe le processus de détection d'erreur des codes correcteurs; (ii)
l'ensemble des données du paquet est alors indéterminé. Notre étude porte donc
sur l'étude des codes à effacement qui génère de l'information redondante au
sein des blocs encodés afin d'en supporter la perte d'une partie.

Il est ainsi possible de répéter sans limite un bloc d'information à
transmettre. Une quantité suffisante de répétitions permet de réduire
significativement le bruit du canal. En revanche, plus on augmente le nombre de
répétitions, plus on réduit le taux de transmission (appelé également
« rendement ») qui correspond au rapport entre le nombre de blocs utile sur le
nombre de blocs transférés.
La question est alors de savoir quel taux de transmission utiliser pour
transmettre efficacement sur un canal. \shannon a montré en 1948 qu'en fonction
d'un canal à transmission sans mémoire, il existe une limite du rendement
appelée « capacité » du canal, notée $C$. En conséquence, si l'on cherche à
émettre avec un taux de transmission supérieur à $C$, la transmission ne sera
pas fiable. En revanche, pour un rendement inférieur à $C$, il est possible de
concevoir un code capable de corriger toutes les erreurs. Dès lors,
la théorie des codes s'est intéressée à la conception de codes et d'algorithmes
permettant d'atteindre cette limite.
Les codes *Low-Density Parity-Check* (LDPC), à matrices de parité creuses,
permettent en théorie (asymptotique) d'atteindre cette limite. En pratique, sur
des codes de longueur finie, soit le décodage est efficace mais ne permet pas
d'atteindre cette limite (décodage itératif) soit il s'en approche, mais au
prix d'une complexité algorithmique significative (décodage par maximum de
vraisemblance).

En 1950, \hamming a défini la notion de distance d'un code. La théorie
des codes algébriques s'est développée à partir de là, avec notamment la
conception des codes de \rs. La notion de « distance de séparation minimale »
(MDS, pour *Maximum Distance Separable*) concernent des codes qui nécessitent
une quantité de redondance minimale relativement à une capacité de correction
arbitrairement fixée.



# Notion de théorie des codes {#sec.theorie.codes}

## Caractérisation d'un canal de communication

\begin{figure}
    \centering
    \def\svgwidth{\textwidth}
    \includesvg{img/canal}
    \caption{Représentation d'un canal de communication. $X$ et $Y$
    représentent des variables aléatoires.}
    \label{fig.canal}
\end{figure}

Un canal de communication est un support de transmission d'information
permettant d'acheminer une information depuis un émetteur vers un destinataire.
La \cref{fig.canal} représente la modélisation d'un canal. Un canal
$C(X,Y,P(Y|X)$ est défini par :

1. Un alphabet d'entrée $X = \{x_1,\dots,x_{r}\}$, de cardinal $r$,

2. Un alphabet de sortie $Y = \{y_1,\dots,y_{s}\}$, de cardinal $s$,

3. D'une loi de transition $P(Y|X)$ qui peut être représentée par la matrice
stochastique suivant :

\begin{equation}
    P(Y|X) = \begin{pmatrix}
        P(y_1,x_1) & P(y_2,x_1) & \cdots & P(y_s|x_1)\\
        P(y_1,x_2) & P(y_2,x_2) & \cdots & P(y_s|x_2)\\
        \vdots     & \vdots     & \ddots & \vdots \\
        P(y_1,x_r  & P(y_2,x_r) & \cdots & P(y_s|x_r)
    \end{pmatrix}
\end{equation}

\noindent On considère un canal bruité sans mémoire qui transmet des symboles
d'un alphabet d'entrée $S = \{s_1,\dots,s_{|A|}\}$., Soit $X$ et $Y$ des
variables aléatoires à valeur dans $A$ modélisant respectivement l'entrée et la
sortie du canal. Il existe une distribution de transition qui détermine la
probabilité $p_{j|i}$ d'obtenir $s_j$ en sortie du canal sachant que $s_i$ a
été émis en entrée. La connaissance du canal permet d'obtenir la distribution
de ces probabilités :

\begin{equation*}
    p_{y|x} = P(Y=y | X = x).
\end{equation*}

\noindent Par exemple, sur un canal sans bruit, $p_{x|x} = 1$ et $p_{y|x} = 0$
pour $x \neq y$. Dans la suite, nous représenterons deux canaux particuliers :
le canal binaire symétrique, et le canal à effacement.

### Entropie

Une source d'information $\mathcal{S}$ définit par un couple
$\mathcal{S}=(A,P)$ où $A$ est un alphabet $A=\{s_1,\dots,s_{|A|}\}$ et $P$ est
une distribution des probabilités sur $A$, c'est à dire que $p_i$ correspond à
la probabilité d'apparition de $s_i$ lors d'une transmission. Dans un document
rédigé en français par exemple, la probabilité d'apparition de la lettre « e »
est plus importante que pour les autres lettres de l'alphabet. La source est
« sans mémoire » lorsque l'apparition de $s_i$ est indépendant de $s_j$ pour
$i \neq j$, et que leur probabilité n'évolue pas pendant la transmission.

Le degré d'originalité $I(s_i)$ (parfois appelé « auto-information ») est
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
    H(\mathcal{S})  = -\sum_{x=1}^r p_x \log_2(p_x)
                    =  \sum_{x=1}^r p_x \log_2(\frac{1}{p_x}).
\end{equation}

\noindent L'entropie $H(\mathcal{S})$ mesure en conséquence l'incertitude des
informations provenant de la source en bits par symbole. En particulier, si
$p(s_i) = 1$ et $p(s_j) = 0$ pour $i \neq j$, alors on a aucune incertitude sur
la source et $H(\mathcal{S})=0$ : le résultat est connu d'avance. À l'inverse,
si tous les symboles sont équiprobables $p(s_i)=\frac{1}{|A|}$, alors
$H(\mathcal{S}) = \sum_{i=1}^{|A|} \frac{1}{|A|} \log_2 |A = \log_2 |A|$ et il
est impossible de prédire le résultat puisque l'incertitude est maximale.

### Entropie de lois conjointes

Dans le cas d'un canal, la modélisation d'un canal de transmission entre en
émetteur et un destinataire met en jeu deux valeurs aléatoires.
Soit $(X,Y)$ la loi conjointe de deux valeurs aléatoires $X$ et $Y$. On cherche
à déterminer l'incertitude associée à deux variables. Pour cela, on calcule
l'entropie de la loi conjointe :

\begin{equation}
    H(X,Y)  = \mathbb{E}\left[\log_2 \left(\frac{1}{P(X,Y)}\right)\right]
            = - \sum_x%{i=1}^{|X|}
                \sum_y%{i=1}^{|Y|}
                p_{x,y} \log_2 \left( p_{x,y} \right),
\end{equation}

\noindent où $p_{x,y}$ correspond à la probabilité $p(X=x,Y=y)$.

### Entropie de lois conditionnelles

Dans l'objectif d'obtenir une modélisation d'un canal, on cherche à modéliser
les perturbations du canal par des probabilités conditionnelles. Pour cela, on
utilise l'entropie conditionnelle $H(X|Y=y)$ qui correspond à l'incertitude de
$X$ lorsqu'un valeur de Y est connues :

\begin{equation}
    H(X|Y=y) = - \sum_x p_{x|y} \log_2 p_{x|y},
\end{equation}

\noindent où $p_{x|y} = P(X=x|Y=y)$. Cette notion peut être ensuite étendue
dans le cas où l'on connait l'ensemble des degrés d'originalité des symboles de
$Y$ :

\begin{equation}
    H(X|Y) = - \sum_{x,y} p_{x,y} \log_2 \left( \frac{p_y}{p_{x,y}} \right).
\end{equation}


### Information mutuelle

Lors d'une transmission d'information sur un canal, le récepteur doit être
capable de déterminer $X$ transmis depuis la source, à partir des informations
reçues $Y$ par le récepteur. L'information mutuelle $I(X,Y)$ mesure la
quantité d'information reçue, qui correspond à la quantité d'information
restante lorsque l'on soustrait l'information perdue sur le canal à
l'information émise par l'émetteur :

\begin{equation}
    \begin{split}
        I(X,Y)  &= H(X) - H(X|Y) \\
                &= \sum_x \sum_y
                    p_{x,y} \log_2 \left( \frac{p_{x,y}}{p_xp_y} \right).
    \end{split}
\end{equation}

\noindent En conséquence, deux cas particulier découlent de cette notion. Si
$H(X) = H(X|Y)$, les variables sont indépendantes, ce qui signifie que la
réalisation de l'une n'apporte aucune information sur la réalisation de
l'autre. Dans le deuxième cas, $H(X|Y) = 0$, ce qui signifie que l'information
mutuelle est maximum. Dans ce cas $Y$ est entièrement déterminée par $X$ et le
canal ne provoque pas d'erreur.

### Capacité d'un canal

La capacité d'un canal $C(X,Y)$ correspond à la quantité maximale d'information
qui peut être transmise par le canal. L'entropie conditionnelle $H(X|Y)$
représente la perte d'information en entrée. La capacité du canal correspond
alors au maximum de la quantité d'information en entrée à laquelle on soustrait
cette perte :

\begin{equation}
    C(X,Y) = \max(I(X,Y)).
\end{equation}


## Exemple de canaux

Notre étude va s'intéresser à deux canaux classiques : le canal binaire
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

Le canal binaire symétrique (CBS) correspond au cas le plus simple. La source
possède un alphabet limité à $A={0,1}$. En conséquence, elle émet des bits à
travers un canal caractérisé par une probabilité $p$ d'inverser la valeur du
bit. La \cref{fig.cbs} illustre ce canal. En particulier :

\begin{equation}
    P(Y|X) = \begin{cases}
        1-p     &\text{si Y=X}\\
        p       &\text{sinon}
    \end{cases}\;.
\end{equation}

\noindent L'entropie est à son maximal lorsque la distribution de $Y$ est
uniforme. Dans le cas du canal symétrique, cela correspond à une distribution
de $X$ uniforme. En conséquence, l'information mutuelle est maximale lorsque
$p=0.5$. La capacité du CBS correspond à \cite[p. 316]{dumas2007book} :

\begin{equation}
    \begin{split}
        C   &= 1 - H(p)\\
            &= 1 - + p \log_2(p) + (1-p) \log_2(1-p)\\
    \end{split}\;,
\end{equation}

\noindent où $H_2(p)$ correspond à l'entropie d'une variable aléatoire d'une
loi de \textsc{Bernoulli} (ou loi binaire), de paramètre $p$. La capacité du
signal vaut donc $1$ quand la probabilité d'erreur $p$ a valeur dans $\{0,1\}$.
En particulier, lorsque $p=0$, il n'y a jamais d'erreur de transmission, et $Y$
correspond à $X$. En revanche, lorsque $p=1$, la valeur du symbole reçu
correspond toujours à l'inverse du symbole émis. La capacité est nulle quand
$p=0,5$. Ce dernier cas est le plus défavorable puisque $X$ et $Y$ sont
indépendants (la sortie n'apporte aucune connaissance sur l'entrée).

### Canal à effacement

\begin{figure}
    \centering
    \def\svgwidth{.6\textwidth}
    \includesvg{img/cbe}
    \caption{Représentation d'un canal binaire à effacement. La source transmet
    sur le canal des bits qui peuvent être effacés avec une probabilité $p$.
    L'effacement représentation la transition d'un bit vers $\epsilon$.}
    \label{fig.cbe}
\end{figure}

Un canal à effacement (CAE) se distingue du canal précédent par le fait que
l'information n'est pas modifiée, mais effacée lors de la transmission. Un
effacement correspond simplement à la perte de l'information. La \cref{fig.cbe}
illustre ce canal. En général, on représente la perte d'information par le
symbole $\epsilon$. La probabilité qu'un symbole soit effacé vaut $p$, ce qui
signifie qu'un symbole est correctement transmis avec une probabilité $1-p$. En
conséquence, on peut représenter la loi de transition $P(Y|X)$ ainsi :

\begin{equation}
    P(Y|X) = \begin{pmatrix}
        1-p & p & 0 \\
        0 & p & 1-p
    \end{pmatrix}
\end{equation}

\noindent La capacité du canal à effacement vaut $C=1-p$. On peut ainsi
comparer la capacité de ce canal par rapport au précédent. Puisque $\forall p
\in [0,1], p < H(p)$, la capacité du canal à effacement est supérieure à celle
du CAE. Ce résultat était prévisible puisque dans le cas du CAE, la correction
d'erreurs nécessite au préalable de détecter l'emplacement de ces erreurs avant
de pouvoir rectifier leurs valeurs. Dans le cas du canal à effacement, la
position de l'erreur et connue, et la correction correspond uniquement à
restituer la valeur de l'information perdue.


## Théorie des codes correcteurs

On appelle « code » une technique qui permet de transformer la représentation
d'une information en une autre représentation. Le terme code est également
utilisé pour désigner le résultat de cette transformation.
En transmission de l'information, on distingue principalement deux types de
codage. Le premier, appelé « codage source », concerne la compression des
informations à transmettre. Cette compression a pour but de réduire la
redondance interne au message à transmettre afin d'optimiser le débit de
transmission. À l'inverse, le codage canal, qui intervient en général après, a
pour objectif de générer de la redondance afin de permettre une transmission
fiable.


### Codes en blocs

Pour transmettre une information, il faut définir un « alphabet » $A$ qui
correspond à un ensemble fini de symboles. Bien que l'information à traiter n'a
pas toujours de taille définie, il est préférable de travailler sur des
éléments de tailles fixes, c'est le cas des codes en bloc. Une succession finie
de symboles correspond à un « mot » (ou bloc, ou paquet). Les mots de codes
correspondent à l'information encodée que l'on transmet sous la forme de mots.
La « longueur » $n$ d'un code correspond au nombre de symboles transmis dans
chaque mot encodé. La « dimension » d'un code correspond à la taille du mot à
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

Le « rendement » $R$ d'un code $(n,k)$ correspond à la quantité de symboles
sources contenus dans un mot de code. Il est défini ainsi :

\begin{equation}
    R = \frac{k}{n}.
\end{equation}

\noindent Plus le rendement est grand, plus les mots de code contiennent
d'information utiles. En revanche, la capacité de correction diminue.
Pour conclure, une « bonne » fonction de codage $\phi$ doit pouvoir fournir
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
par une matrice $H$, appelé « matrice de parité » :

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
$Hy$, qui est appelé le « syndrome ». Si le syndrome n'est pas nul, c'est qu'il
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
linéaire $\mathcal{O}(n)$ reposant sur des opérations de « OU exlusif » (XOR),
il ne sont pas MDS. Les codes de \rs ont en revanche un rendement optimal
(codes MDS). Cependant, leur complexité au décodage est moins bon que les
codes LDPC. Bien que la complexité des codes de \rs soit souvent considérée
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
