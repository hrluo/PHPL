function prfunc= PRF(data_point_cloud,dimension,a,b)
    import edu.stanford.math.plex4.*;
    % a=0.5;
    % b=0.75;
    ab_stream = api.Plex4.createVietorisRipsStream(data_point_cloud, dimension + 1, [a,b]);

    persistence = api.Plex4.getDefaultSimplicialAlgorithm(dimension + 1);
    ab_intervals = persistence.computeIntervals(ab_stream);

    % ab_options.min_filtration_value=a;
    % ab_options.max_filtration_value=b;
    % plot_barcodes(ab_intervals, ab_options);

    prfunc=ab_intervals.getInfiniteIntervals.getBettiSequence();
end