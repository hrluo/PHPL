function prfunc = PRF(data_point_cloud,Betti_dimension,a,b)
    import edu.stanford.math.plex4.*;
    % a,b are the threshold numbers used to construct Vietoris-Rips complexes VR_[a,b] with threshold values;
    size_matrix=size(data_point_cloud);
    dimension=size_matrix(1,2);
    % This constructor makes use of the syntax of filtrations VietorisRipsStream in JavaPlex4.
    % public VietorisRipsStream(AbstractSearchableMetricSpace<T> metricSpace,
    %              double[] filtrationValues,
    %              int maxDimension)
    aa_stream = api.Plex4.createVietorisRipsStream(data_point_cloud, dimension + 1, [a,a]);
    ab_stream = api.Plex4.createVietorisRipsStream(data_point_cloud, dimension + 1, [a,b]);
    % Get an algorithm object.
    persistence = api.Plex4.getDefaultSimplicialAlgorithm(dimension + 1);
    
    aa_intervals = persistence.computeIntervals(aa_stream);
    ab_intervals = persistence.computeIntervals(ab_stream);

    % ab_options.min_filtration_value=a;
    % ab_options.max_filtration_value=b;
    
    % plot_barcodes(ab_intervals, ab_options);
    % Get the Betti numbers associated with VR_[a,a] and VR_[a,b]
    aa_Betti = aa_intervals.getInfiniteIntervals.getBettiSequence();
    ab_Betti = ab_intervals.getInfiniteIntervals.getBettiSequence();
    % The persistent rank function is obtained from taking the difference
    % between Betti numbers of two different VR complexes.
    % disp(aa_Betti)
    % disp(ab_Betti)
    maximal_nonzero_aa_Betti=size(aa_Betti);
    maximal_nonzero_aa_Betti=maximal_nonzero_aa_Betti(2);
    maximal_nonzero_ab_Betti=size(ab_Betti);
    maximal_nonzero_ab_Betti=maximal_nonzero_ab_Betti(2);
    
    if maximal_nonzero_aa_Betti<Betti_dimension+1
        aa_Betti_number=0;
    else
        aa_Betti_number=aa_Betti(Betti_dimension + 1,1);
    end
    if maximal_nonzero_ab_Betti<Betti_dimension+1
        ab_Betti_number=0;
    else
        ab_Betti_number=ab_Betti(Betti_dimension + 1,1);
    end
    prfunc = ab_Betti_number-aa_Betti_number;
end