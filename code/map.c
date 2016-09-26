
\begin{lstlisting}[
	caption={Fonction \emph{map}. La directive \emph{pragma omp parallel}
	permet de rendre la boucle parralèle.},
	label={lst.map},]
/* assigne le processus de reprojection pour chaque projection, retourne les reconstructions partielles */
void map(int w, int k, projection_t *projections, projection_t *p_reprojections, int nb_proj, int extra_dir)
{
    #pragma omp parallel for schedule(static)
    for (int i = 0; i < nb_proj; i++)
        reprojection(projections, i, w, k, nb_proj, p_reprojections + i, extra_dir);
}
\end{lstlisting}

