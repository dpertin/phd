
\chapter*{Introduction de la partie}

\addstarredchapter{Introduction de la partie}

La théorie des codes traite des méthodes qui permettent de représenter
l'information sous une forme qui lui permettent d'être transmise de manière
fiable. Cette théorie remonte à 1948 avec les travaux de \shannon. On raconte
que pendant ses travaux sur l'étude de la langue, il s'amusait à retirer
une partie des lettres d'un message\footnote{\emph{En l'bsnce de crtaines
letres, le mssage rste lisibl}} et montrait que le message pouvait toujours
être lu. Ces lettres sont alors «\ redondantes\ ». La détermination de la
quantité de redondance d'un message fait partie de la théorie de l'information
dont découle la théorie des codes. Les codes sont notamment utilisés dans la
compression, le chiffrement et la correction de l'information. Dans le cas de
la correction de l'information, cette théorie a été utilisée dans de nombreux
champs d'applications. Les codes correcteurs sont par exemple présents dans les
supports de stockage optiques (CD, DVD) afin de supporter les rayures, dans les
code-barres comme le code QR, ou encore dans les télécommunications avec des
engins spatiaux (comme la sonde *Voyager*). Nous nous intéressons en
particulier au cas des codes linéaires dont les opérations sont généralement
décrites par une approche algébrique.

La transformée de \radon est une application permettant de représenter une
information par un ensemble de projections. Cette application est notamment
utilisée en tomographie discrète afin d'obtenir une version numérique d'un
objet. En particulier, nous nous intéressons à la transformée de \radon finie
(FRT) et à la transformée Mojette. Ces transformées sont des version discrètes
et exactes de la transformée de \radon. En particulier, elles permettent de
représenter l'information de manière redondante.

Dans cette première partie, nous proposons d'étudier conjointement la théorie
des codes et des transformées discrètes. Notre motivation repose sur la
conception d'un code à effacement à partir des représentation redondante
fournies par les versions discrète de la transformée de \radon. Pour cela, les
éléments suivants seront détaillés :

1. Le \cref{sec.chap1} introduit des notions de théorie de codes nécessaires à
la compréhension des codes à effacement, et à leurs caractéristiques. Nous
verrons en particulier les codes de \rs et les codes LDPC qui représentent deux
familles de codes largement utilisées.

2. Cette compréhension des codes nous serons utile pour concevoir des codes par
transformée discrète. Dans le \cref{sec.chap2}, nous discrétiserons la
transformée de \radon pour former deux transformées discrètes capable de
représenter l'information de manière redondante. En particulier, chacune
possède un avantage : la FRT permet de fournir un code au rendement optimal,
tandis que la transformée Mojette utilise un algorithme de reconstruction
itératif efficace.

3. Le code à effacement Mojette sera au cœur de notre première contribution. Le
\cref{sec.chap3} contient la construction d'une version systématique du code à
effacement Mojette. Il fournit également un algorithme de décodage adaptée à
cette construction. Nous verrons que cette contribution offre un code dont
l'algorithme de décodage est efficace, et dont le rendement tend davantage vers
l'optimal. La réduction de la quantité de redondance par rapport à la version
classique est également évaluée.

