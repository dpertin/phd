
\section*{Perspectives}

#### Problème de la réparation

Bien que l'algorithme de reprojection sans reconstruction traite le cas de la
réparation d'un nœud de stockage, il ne permet pas de réduire le nombre
d'éléments qui transite lors d'une réparation. Certains codes sont conçus dans
cette optique

Par exemple, \textcite{sathiamoorthy2013vldb} proposent une nouvelle famille de
codes. Les *Locally Repairable Codes* (LRC) se basent sur les codes de \rs mais
proposent une mise en œuvre qui réduit le coût de la réparation, mais réduit en
conséquence le rendement du code. La particularité des LRC est d'être optimal
au sens de la localité. Le principe s'appuie sur les codes de Reed Solomon. On
augmente la localité en ajoutant des blocs de parité locaux. Ces blocs sont
calculés pour être dépendant d'un ensemble des blocs codés. On peut ainsi
former un code LRC$(16,10,5)$, où $5$ est la localité, sur la base d'un code
RS$(14,10)$. Pour se faire, on va créer deux blocs de parité locaux $S_1$ et
$S_2$ tels que : $ S_1 = c_1X_1+c_2X_2+c_3X_3+c_4X_4+c_5X_5 $. Dans ce cas, si
l'un de nos blocs devient inaccessible, il est possible de le retrouver non
plus à partir de 10 blocs, mais de 5 blocs. On a réduit notre localité $ r=5 $.
En contrepartie, la capacité de stockage a augmenté. On codait précédemment nos
10 blocs en données en 14 blocs. Il faut à présent 17 blocs pour satisfaire la
disponibilité de nos données.  Si les coefficients $c_i$ sont bien choisis, il
est possible de réduire la taille du code à 16. L'équation $S_1 + S_2 + S_3 =
0$ permet en effet de s'affranchir d'un des bloc de parité local..

D'autres méthodes utilisées sur des codes classiques utilisent des combinaisons
linéaires entre les blocs disponibles afin de réduire le volume de données
transférées. C'est le cas des *regenerating codes* proposés par
\textcite{dimakis2010toit}.

#### Construire des ponds entre les codes

De fortes connexions existent entre les codes FRT et les codes de \rs. Nous
avons vu que ces deux codes sont obtenus par une matrice de \vander. Bien que
dans le cas des codes de \rs, les coefficients de cette matrice correspondent
à des éléments du corps fini, il s'agit dans le cas des codes FRT de monômes
dont le degré caractérise une permutation cyclique. Une étude plus poussée des
relations entre ces deux codes serait intéressante.

De même, le code Mojette partage des liens avec les codes LDPC. En particulier,
les deux utilisent un algorithme itératif pour l'opération de décodage. Bien
que dans le cas des codes LDPC, cet algorithme peut être bloquer avant d'avoir
fini, dans le cas Mojette, le critère de \katz garantit que l'algorithme est
capable de tout reconstruire. En conséquence, il est possible que le code
Mojette corresponde à une structure particulièrement des codes LDPC.

