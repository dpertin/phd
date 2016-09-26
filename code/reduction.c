
\begin{lstlisting}[
	caption={Fonction \emph{reduction}},
	label={lst.reduction},]
/* fusionne les produits de map() en une reprojection */
void reduce(projection_t *reproj, projection_t *p_reprojections, int nb_proj)
{
    #pragma omp parallel for 
    for (int i = 0; i < reproj->size; i++)
    {
        pxl_t sum = 0;
        for (int j = 0; j < nb_proj; j++)
            sum ^= p_reprojections[j].bins[i];
        reproj->bins[i] = sum;
    }
}
\end{lstlisting}

