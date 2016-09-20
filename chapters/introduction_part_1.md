
\chapter*{Introduction de la partie}

\addstarredchapter{Introduction de la partie}

<!--
%, les supports de transmission et de stockage de
%données ne sont pas fiables. Dans les systèmes distribués en particulier, le
%phénomène de panne est considéré comme une norme plutôt qu'une exception
%\cite{ford2010osdi}. Afin de supporter ces pannes, 
-->

Les systèmes d'information nécessitent l'ajout de données de redondance au
message à transmettre afin que le destinataire puisse reconstituer
l'information lorsque celle-ci est détériorée. Dans cette partie, nous
nous intéressons d'une part à minimiser la quantité de redondance générée, et,
d'autre part, à optimiser les performances du code.
L'objectif ici est de concevoir de nouveaux codes à effacement qui se basent
sur des transformées discrètes afin de fournir deux choses : un rendement
optimal (code MDS), et de nouveaux algorithmes d'encodage et de décodage de
faible complexité.

Pour cela, les bases mathématiques de la théorie des codes sont introduites
dans le \cref{sec.chap1} à travers l'étude des travaux fondamentaux de
\textcite{shannon1948bstj}. En particulier, nous proposons une liste de
critères comme base pour notre première contribution, à savoir, la comparaison
des différents codes présentés dans ce manuscrit. Le \cref{sec.chap2} décrit
notre approche pour concevoir des codes à effacement à partir de versions discrètes
de la transformation de \radon. Le \cref{sec.chap3} décrit notre seconde
contribution correspondant à l'élaboration d'une construction
du code à effacement Mojette sous une forme systématique. Cette construction
vise à réduire la complexité du code, ainsi que la quantité
de redondance générée. À l'issue de cette étude, nous présentons une évaluation
de cette réduction de redondance par rapport à la version non-systématique et
aux codes MDS.

<!--
%par une étude la
%théorie des codes à travers lesette partie s'intéresse au codage à effacement comme
%moyen de générer une quantité minimale de redondance de la redondance à la conception de codes à
%effacement Afin de transmettre l'information de manière fiable, il
%est nécessaire d'intégrer de la redondance d'information
%
%
%ystèmes de communication et stockage reposent sur des supports éléments qui ne sont pas fiables. En particulier, les pannes dans de
%tels systèmes sont inévitables\ \cite{ford2010osdi}. Les canaux de
%communication ne sont ainsi pas sûrs, et l'information peut être altérée ou
%perdue durant la transmission. En conséquence, des techniques doivent être
%mises en œuvre pour rendre une transmission fiable sur un canal instable
%(relatif au problème $2$ posé en introduction générale). Cette partie
%s'intéresse ainsi à l'élaboration de méthodes efficaces afin de répondre à ce
%problème. Cette efficacité met en jeu les latences de la méthode proposée,
%ainsi que sa capacité de correction. Pour cela, nous proposons d'étudier des
%versions discrètes de la transformation de \radon, appliquées aux codes
%correcteurs d'erreur. Cette partie se compose de trois chapitres dans
%lesquelles nous allons voir les éléments suivants :
%
%1. le \cref{sec.chap1} définira des notions de théorie de codes correcteurs à
%travers l'étude des travaux fondamentaux de \textcite{shannon1948bstj}. Notre
%étude s'intéressera en particulier aux codes linéaires en bloc. Ces notions
%seront nécessaires à la compréhension des codes à effacement, qui permettent de
%répondre au problème de la fiabilité d'une transmission dans le cas de perte
%d'information sur le canal. Une proposition des critères permettant de
%distinguer les différents codes à effacement sera notre première contribution
%mineure. Une analyse de différents codes (dont notre
%référence\ \cite{reed1960jsiam}) permettra de mettre en avant les défauts de
%chacun;
%
%2. le \cref{sec.chap2} portera sur notre proposition d'utiliser conjointement
%transformée discrète et théorie des codes. Nous verrons en particulier deux
%versions discrètes de la transformation de \textcite{radon1917akad} qui
%permettent de représenter de manière redondante l'information. En conséquence,
%nous verrons que la FRT fournit un code MDS, tandis que le code à effacement
%Mojette dispose d'un algorithme de reconstruction itératif efficace, basé sur
%l'algorithme de \textcite{normand2006dgci};
%
%3. le \cref{sec.chap3} décrira notre première contribution. Nous y présenterons
%la construction d'une version systématique du code à effacement Mojette, ainsi
%qu'un algorithme de décodage adaptée à cette construction.
%Cet algorithme, basé sur celui de \textcite{normand2006dgci}, permet un
%décodage itératif efficace (en nombre d'opérations). De plus, bien qu'elle ne
%permet pas de fournir un code MDS, cette construction permet de se rapprocher
%de cette optimale. Cette contribution est alors une proposition de solution au
%second problème présenté dans l'introduction générale.


<!--
%shannon a donné naissance en $1940$ à la théorie de l'information, dont
%l'objectif est de fournir une formulation mathématique des systèmes de
%communication\ \cite{shannon1948bstj}. Dans ses travaux sur l'étude de la
%langue, \shannon retirait une partie des lettres d'un message et montrait que
%le message pouvait toujours être lu\footnote{\emph{En l'bsnce de crtaines
%letres, le mssage rste lisibl}}\ \cite[chap~7]{shannon1948bstj}.
%Ces lettres ne sont alors pas nécessaire pour lire le message, et elles forment
%alors une partie redondante du message. La formulation de la quantité de
%redondance d'un message. Cette redondance est liée à la notion d'entropie qui
%détermine la quantité d'information délivrée.
%Le codage de l'information est une branche de la théorie de l'information. Il
%permet d'exploiter cette formulation dans les applications de compression, de
%chiffrement et de correction d'information. Dans nos travaux nous nous
%intéresserons à la correction de l'information par des codes correcteurs. Les
%codes correcteurs sont par exemple présents dans les supports de stockage
%optiques (CD, DVD) afin de supporter les rayures, dans les code-barres comme le
%code QR, ou encore dans les télécommunications avec des engins spatiaux (comme
%la sonde *Voyager*). Nous nous intéressons en particulier au cas des codes
%linéaires en bloc.
%
%
%Notre motivation repose sur la
%conception d'un code à effacement à partir des représentations redondantes
%fournies par les versions discrète de la transformée de \radon. Pour cela, les
%éléments suivants seront détaillés :
%
%
%
%La transformation de \radon est une application permettant de représenter une
%information par un ensemble de projections. Cette application est notamment
%utilisée en tomographie discrète afin d'obtenir une version numérique d'un
%objet. Nous définirons deux versions discrètes de cette transformation :
%la transformée de \radon finie (FRT) et à la transformée Mojette. Ces
%transformées sont des versions discrètes et exactes de la transformée de
%\radon. 
-->
